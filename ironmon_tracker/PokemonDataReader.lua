local function PokemonDataReader(initialProgram)
    local self = {}
    local program = initialProgram
    local addresses = program.getAddresses()
    local gameInfo = program.getGameInfo()
    local decryptedData
    local seed
    local pid
    local currentBase
    local constants = {
        GEN = gameInfo.GEN,
        GEN_5_BATTLE_HP_OFFSET = 548,
        POKEMON_DATA_SIZE = gameInfo.ENCRYPTED_POKEMON_SIZE,
        BLOCK_TOTAL = 4,
        BLOCK_SIZE = 32,
        BLOCK_SHUFFLE_ORDER = {
            "ABCD",
            "ABDC",
            "ACBD",
            "ACDB",
            "ADBC",
            "ADCB",
            "BACD",
            "BADC",
            "BCAD",
            "BCDA",
            "BDAC",
            "BDCA",
            "CABD",
            "CADB",
            "CBAD",
            "CBDA",
            "CDAB",
            "CDBA",
            "DABC",
            "DACB",
            "DBAC",
            "DBCA",
            "DCAB",
            "DCBA"
        },
        DEFAULT_POKEMON = {
            pid = 0,
            alternateForm = 0x0000,
            pokemonID = 0,
            trainerID = 0,
            heldItem = 0,
            friendship = 0,
            ability = 0,
            move1 = 0,
            move2 = 0,
            move3 = 0,
            move4 = 0,
            move1PP = 0,
            move2PP = 0,
            move3PP = 0,
            move4PP = 0,
            status = 0,
            level = 0,
            curHP = 0,
            HP = 0,
            stats = {
            HP = 0,
            ATK = "---",
            DEF ="---",
            SPE = "---",
            SPA = "---",
            SPD = "---",},
            nature = 0,
            encounterType = 0,
            moveIDs = {
                0,
                0,
                0,
                0
            },
            movePPs = {
                "---",
                "---",
                "---",
                "---"
            },
            statStages = {
                ["HP"] = 6,
                ["ATK"] = 6,
                ["DEF"] = 6,
                ["SPE"] = 6,
                ["SPA"] = 6,
                ["SPD"] = 6,
            }
        },
        IMPORTANT_BLOCK_DATA = {
            A = {
                {0, {"pokemonID"}},
                {2, {"heldItem"}},
                {4, {"trainerID"}},
                {12, {"friendship", "ability"}}
            },
            B = {
                {0, {"move1"}},
                {2, {"move2"}},
                {4, {"move3"}},
                {6, {"move4"}},
                {8, {"move1PP", "move2PP"}},
                {10, {"move3PP", "move4PP"}},
                {24, {"alternateForm", "nature"}}
            },
            C = {},
            D = {
                {28, {"unused", "encounterType"}}
            }
        },
        BATTLE_STAT_OFFSETS = {
            {0, {"status", "unused"}},
            {4, {"level", "unused"}},
            {6, {"curHP"}},
            {8, {"HP"}},
            {10, {"ATK"}},
            {12, {"DEF"}},
            {14, {"SPE"}},
            {16, {"SPA"}},
            {18, {"SPD"}}
        },
    }

    local function advanceRNG()
        seed = BitUtils.mult32(seed, 0x41C64E6D) + 0x00006073
    end

    local function advanceRNGByDifference(difference)
        for _ = 1, difference, 2 do
            advanceRNG()
        end
    end

    local function decryptWord(offsetData, address)
        local offsetAmount = offsetData[1]
        local dataName = offsetData[2]
        local combineBytes = (#dataName == 1)
        local encryptedWord = Memory.read_u16_le(address + offsetAmount)
        local encryptedByte1 = bit.band(encryptedWord, 0xFF)
        local encryptedByte2 = bit.band(bit.rshift(encryptedWord, 8), 0xFF)

        local shift16 = bit.rshift(seed, 16)
        local shift24 = bit.rshift(seed, 24)

        local byte1Data = bit.bxor(encryptedByte1, bit.band(shift16, 0xFF))
        byte1Data = bit.band(byte1Data, 0xFF)

        local byte2Data = bit.bxor(encryptedByte2, bit.band(shift24, 0xFF))
        byte2Data = bit.band(byte2Data, 0xFF)

        if combineBytes then
            local combinedBytes = bit.band(byte2Data, 0x00FF)
            combinedBytes = bit.lshift(combinedBytes, 8)
            combinedBytes = bit.bor(combinedBytes, byte1Data)
            decryptedData[dataName[1]] = combinedBytes
        else
            decryptedData[dataName[1]] = byte1Data
            if dataName[2] == "nature" then
                if gameInfo.GEN == 5 then
                    decryptedData[dataName[2]] = byte2Data
                end
            else
                decryptedData[dataName[2]] = byte2Data
            end
        end
    end

    local function decryptBlocks(blockReadingStart, blockOrder)
        for i = 0, constants.BLOCK_TOTAL - 1, 1 do
            local currentBlockStart = blockReadingStart + (constants.BLOCK_SIZE * i)
            local totalBytesAdvanced = 0
            local currentBlockLetter = string.sub(blockOrder, i + 1, i + 1)
            local offsets = constants.IMPORTANT_BLOCK_DATA[currentBlockLetter]
            local previousOffset = 0
            advanceRNG()
            totalBytesAdvanced = totalBytesAdvanced + 2
            if offsets ~= nil then
                for _, offsetData in ipairs(offsets) do
                    local offsetAmount = offsetData[1]
                    local difference = offsetAmount - previousOffset
                    advanceRNGByDifference(difference)
                    totalBytesAdvanced = totalBytesAdvanced + difference
                    decryptWord(offsetData, currentBlockStart)
                    previousOffset = offsetAmount
                end
            end
            local remainder = constants.BLOCK_SIZE - totalBytesAdvanced
            for _ = 2, remainder, 2 do
                advanceRNG()
            end
        end
    end

    local function decryptBattleStats(battleStatStart, monIndex, checkingEnemy)
        local offsets = constants.BATTLE_STAT_OFFSETS
        local previousOffset = 0
        seed = pid
        advanceRNG()
        if offsets ~= nil then
            for _, offsetData in ipairs(offsets) do
                local offsetAmount = offsetData[1]
                local difference = offsetAmount - previousOffset
                advanceRNGByDifference(difference)
                decryptWord(offsetData, battleStatStart)
                previousOffset = offsetAmount
            end
        end
        --Gen 5 does not update the current HP or moves/PP in the player's battle party memory. It's stored elsewhere as unencrypted data.
        if program.isInBattle() and gameInfo.GEN == 5 then
            decryptedData.curHP = Memory.read_u16_le(addresses.curHPBattlePlayer + monIndex * 548)
            decryptedData.HP = Memory.read_u16_le(addresses.HPBattlePlayer + monIndex * 548)
            local movesStart = addresses.statStagesStart + 8
            if checkingEnemy then
                local totalPlayerMons = Memory.read_u8(addresses.totalMonsParty)
                movesStart = movesStart + totalPlayerMons * 0x224
            end
            movesStart = movesStart + monIndex * 0x224
            local moveIDs = {"move1", "move2", "move3", "move4"}
            local movePPs = {"move1PP", "move2PP", "move3PP", "move4PP"}
            for i = 0, 3, 1 do
                local currentMove = movesStart + i * 14
                local moveID = Memory.read_u16_le(currentMove)
                local movePP = Memory.read_u8(currentMove + 2)
                decryptedData[moveIDs[i + 1]] = moveID
                decryptedData[movePPs[i + 1]] = movePP
            end
        end
    end

    function self.getDefaultPokemon()
        return constants.DEFAULT_POKEMON
    end

    function self.decryptPokemonInfo(checkingParty, monIndex, checkingEnemy)
        decryptedData = {}
        --Find the first mon that hasn't fainted.
        for _ = 1, 6, 1 do
            pid = Memory.read_u32_le(currentBase)
            local checksum = Memory.read_u16_le(currentBase + 0x06)
            if checksum ~= 0 then
                decryptedData["pid"] = pid
                decryptedData.nature = (pid % 25)
                local blockShift = bit.rshift(bit.band(pid, 0x3E000), 0xD) % 24
                local blockOrder = constants.BLOCK_SHUFFLE_ORDER[blockShift + 1]
                local blockReadingStart = currentBase + 0x08
                seed = checksum
                decryptBlocks(blockReadingStart, blockOrder)
                local battleStatStart = currentBase + 0x88
                decryptBattleStats(battleStatStart, monIndex, checkingEnemy)
                decryptedData.moveIDs = {
                    decryptedData.move1,
                    decryptedData.move2,
                    decryptedData.move3,
                    decryptedData.move4
                }

                local sum = 0
                for _, moveID in pairs(decryptedData.moveIDs) do
                    sum = sum + moveID
                end
                if sum == 0 then
                    return {}
                end
                decryptedData.movePPs = {
                    decryptedData.move1PP,
                    decryptedData.move2PP,
                    decryptedData.move3PP,
                    decryptedData.move4PP
                }
                decryptedData.stats = {
                    HP = decryptedData.HP,
                    ATK = decryptedData.ATK,
                    DEF = decryptedData.DEF,
                    SPA = decryptedData.SPA,
                    SPD = decryptedData.SPD,
                    SPE = decryptedData.SPE
                }
                if checkingParty then
                    if decryptedData.curHP ~= 0 then
                        return decryptedData
                    end
                else
                    break
                end
                currentBase = currentBase + constants.POKEMON_DATA_SIZE
            else
                break
            end
        end

        return decryptedData
    end

    function self.setCurrentBase(newBase)
        currentBase = newBase
    end

    function self.readBattleStatStages(isEnemy, index)
        local base = currentBase
        if gameInfo.GEN == 5 then
            base = base + (0x224 * index)
            if isEnemy then
                local totalPlayerMons = Memory.read_u8(addresses.totalMonsParty)
                base = base + totalPlayerMons * 0x224
            end
        end
        local first4Bytes = Memory.read_u32_le(base)
        local last4Bytes = Memory.read_u32_le(base + 4)
        local HP = 6
        local ATK = 6
        local DEF = 6
        local SPE = 6
        local SPA = 6
        local SPD = 6
        --local ACC = 6
        --local EVA = 6

        if gameInfo.GEN == 4 then
            --format(gen 4):
            --HP, ATK, DEF, SPEED, SPATK, SPDEF, ACC, EVASION,
            HP = bit.band(first4Bytes, 0xFF)
            ATK = bit.band(bit.rshift(first4Bytes, 8), 0xFF)
            DEF = bit.band(bit.rshift(first4Bytes, 16), 0xFF)
            SPE = bit.band(bit.rshift(first4Bytes, 24), 0xFF)

            SPA = bit.band(last4Bytes, 0xFF)
            SPD = bit.band(bit.rshift(last4Bytes, 8), 0xFF)
            --ACC = bit.band(bit.rshift(last4Bytes, 16), 0xFF)
            --EVA = bit.band(bit.rshift(last4Bytes, 24), 0xFF)
        elseif gameInfo.GEN == 5 then
            ATK = bit.band(first4Bytes, 0xFF)
            DEF = bit.band(bit.rshift(first4Bytes, 8), 0xFF)
            SPA = bit.band(bit.rshift(first4Bytes, 16), 0xFF)
            SPD = bit.band(bit.rshift(first4Bytes, 24), 0xFF)

            SPE = bit.band(last4Bytes, 0xFF)
           -- ACC = bit.band(bit.rshift(last4Bytes, 8), 0xFF)
           -- EVA = bit.band(bit.rshift(last4Bytes, 16), 0xFF)
            HP = 6
        end

        local statStages = {
            ["HP"] = HP,
            ["ATK"] = ATK,
            ["DEF"] = DEF,
            ["SPE"] = SPE,
            ["SPA"] = SPA,
            ["SPD"] = SPD,
           -- ["ACC"] = ACC,
           -- ["EVA"] = EVA
        }

        if gameInfo.GEN == 5 then
            statStages = {
                ["ATK"] = ATK,
                ["DEF"] = DEF,
                ["SPE"] = SPE,
                ["SPA"] = SPA,
                ["SPD"] = SPD,
              --  ["ACC"] = ACC,
               -- ["EVA"] = EVA
            }
        end

        local validStats = true
        local sum = 0

        --Make sure all are in range.
        for _, stat in pairs(statStages) do
            if stat < 0 or stat > 12 then
                validStats = false
                break
            end
            sum = sum + stat
        end

        --Basic sanity check, sum of stat stages should not be anywhere near 0
        if not validStats or sum < 3 then
            for i, _ in pairs(statStages) do
                statStages[i] = 6
            end
        end

        return statStages
    end

    return self
end

return PokemonDataReader
