MiscConstants = {}

MiscConstants.TRACKER_VERSION = "5.5.4"

MiscConstants.BIZHAWK_VERSION = client.getversion()

MiscConstants.UPDATE_NOTES = {
    '-- Added a HG/SS Tourney Tracker under a new "Extras" section for those that participate in Crozwords\' tournaments.',
    '-- Thanks to kittenchilly, Judgment will now correctly change type based on what plate you\'re holding.',
}

MiscConstants.DEFAULT_SETTINGS = {
    appearance = {
        AUTO_POKEMON_THEMES = false,
        EXPERIENCE_BAR = true,
        RIGHT_JUSTIFIED_NUMBERS = true,
        SHOW_ACCURACY_AND_EVASION = true,
        RANDOM_BALL_PICKER = true,
        SHOW_POKECENTER_HEALS = false,
        ICON_SET_INDEX = 2,
        BLIND_MODE = false,
    },
    controls = {
        CHANGE_VIEW = "Start",
        LOAD_NEXT_SEED = "A B Start Select",
        CYCLE_STAT = "L",
        CYCLE_PREDICTION = "R",
        LOCK_ENEMY = "Select"
    },
    battle = {
        AUTO_SWAP_TO_ENEMY = false,
        CALCULATE_VARIABLE_DAMAGE = true,
        SHOW_MOVE_EFFECTIVENESS = true,
        SHOW_ACTUAL_ENEMY_PP = true,
        SHOW_1ST_FIGHT_STATS_PLATINUM = true,
        ENABLE_ENEMY_LOCKING = false
    },
    colorScheme = {
        ["Main background color"] = 4278190080,
        ["Top box text color"] = 4294967295,
        ["Bottom box text color"] = 4294967295,
        ["Positive text color"] = 4278255360,
        ["Negative text color"] = 4294901760,
        ["Intermediate text color"] = 4294967040,
        ["Move header text color"] = 4294967295,
        ["Top box border color"] = 4289374890,
        ["Bottom box border color"] = 4289374890,
        ["Top box background color"] = 4280427042,
        ["Bottom box background color"] = 4280427042,
        ["Physical icon color"] = 4294952497,
        ["Special icon color"] = 4286428927,
        ["Gear icon color"] = 4292598747,
        ["Black"] = 4278190080
    },
    colorSettings = {
        ["Color move names by type"] = true,
        ["Draw shadows"] = true,
        ["Draw move type icons"] = false,
        ["Color move type icons"] = false,
        ["Transparent backgrounds"] = false,
        ["Show phys/spec move icons"] = true
    },
    quickLoad = {
        LOAD_TYPE = "GENERATE_ROMS",
        ROMS_FOLDER_PATH = "",
        ROM_PATH = "",
        JAR_PATH = "",
        SETTINGS_PATH = ""
    },
    badgesAppearance = {
        SINGLE_BADGE_ALIGNMENT = "RIGHT",
        DOUBLE_BADGE_ALIGNMENT = "LEFT_AND_RIGHT",
        SHOW_BOTH_BADGES = true,
        SPACER = true,
        PRIMARY_BADGE_SET = "JOHTO"
    },
    automaticUpdates = {
        LAST_DAY_CHECKED = "",
        UPDATE_WAS_DONE = true
    },
    trackedInfo = {
        FAINT_DETECTION = PlaythroughConstants.FAINT_DETECTIONS.ON_FIRST_SLOT_FAINT
    },
    extras = {
        BROWS_ENABLED = false,
        BROWS_FRAMES = 8,
    },
    tourneyTracker = {
        ENABLED = false
    }
}

MiscConstants.DEFAULT_POKEMON = {
    pid = 0,
    alternateForm = 0x0000,
    experience = 0,
    pokemonID = 0,
    trainerID = 0,
    heldItem = 0,
    friendship = 0,
    ability = 0,
    moves = {},
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
        HP = "---",
        ATK = "---",
        DEF = "---",
        SPE = "---",
        SPA = "---",
        SPD = "---"
    },
    isEgg = 0,
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
        ["SPD"] = 6
    }
}
