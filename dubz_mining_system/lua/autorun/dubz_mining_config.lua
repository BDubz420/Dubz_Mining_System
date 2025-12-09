DMS = {}

-- Models and Materials

DMS.RockModels = {  -- Ore Models
    "models/props_wasteland/rockgranite02c.mdl", 
    "models/props_wasteland/rockgranite03a.mdl", 
    "models/props_wasteland/rockgranite03b.mdl",
    "models/props_wasteland/rockgranite03c.mdl"
} 

DMS.AccentColor = Color(25, 140, 200)

DMS.BackgroundColor = Color(0, 0, 0, 190)

DMS.StoneModels = {"models/props_junk/rock001a.mdl"} -- Stone Models

DMS.GemModels = {"models/hunter/plates/plate.mdl"} -- Gem Models

DMS.IngotModels = {"models/hunter/plates/plate025.mdl"} -- Ingot Models

DMS.ForgeModels = {"models/props_forest/furnace01.mdl"} -- Forge Models

DMS.BuyerModels = {"models/Humans/Group03/male_06.mdl"} -- Buyer Models

DMS.CraftingTableModels = {"models/props_c17/FurnitureTable002a.mdl"} -- Crafting Table Model

DMS.Material = "models/debug/debugwhite" -- Gems and Ingot Materials

-- Tools

DMS.MiningTools = {"weapon_dubz_pickaxe_temp", "weapon_dubz_pickaxe_basic", "weapon_dubz_pickaxe_topaz", "weapon_dubz_pickaxe_amethyst", "weapon_dubz_pickaxe_emerald", "weapon_dubz_pickaxe_ruby", "weapon_dubz_pickaxe_sapphire", "weapon_dubz_pickaxe_diamond"} -- Tools which helps players break rocks.

DMS.ScanningTools = {"weapon_dubz_scanner"} -- Tools which helps players see what ores are in the rocks.

-- NPC

DMS.NPCShopRefreshTime = 60 -- In seconds

-- XP

DMS.XPDropTime = 300 -- In seconds

DMS.XPDropAmount = 1

-- Rock

DMS.RockRespawnTime = 30 -- In seconds

DMS.XPPerLevel = 100  -- Default to 100 XP per level

DMS.MinXPPerRock = 5 -- Example XP per rock (ensure this is also set)

DMS.MaxXPPerRock = 15 -- Example XP per rock (ensure this is also set)

DMS.RockHealth = 100 -- Example rock health (ensure this is also set)

DMS.RockDrawDistance = 200 -- The rock's draw distance

DMS.RockDamagePerHit = 2 -- Damage per hit

DMS.StoneSpawnAmountMin = 0 -- Ex(Between 1 and 5 stones per rock break.)

DMS.StoneSpawnAmountMax = 3 -- Ex(Between 1 and 5 stones per rock break.)

-- Gems

DMS.GemSpawnAmountMin = 0 -- Ex(Between 1 and 5 gems per rock break.)

DMS.GemSpawnAmountMax = 3 -- Ex(Between 1 and 3 gems per rock break.)

DMS.DespawnTime = 120 -- Time (in seconds) after which the rock despawns if not mined

DMS.MiningJob = TEAM_MINER -- Jobs that can mine.

DMS.StartingInventorySize = 20 -- Starting Inventory Size (ex. max 20 Ores and Ingots total)

DMS.Buyer = {
    MaxInventory = 100,  -- Maximum number of items the buyer can hold
    FullWarningThreshold = 90,  -- Percentage of inventory capacity to show warning

    -- Colors for UI Elements
    InventoryBarColor = Color(50, 200, 50),  -- Normal color for the inventory bar
    InventoryBarWarningColor = Color(255, 100, 0),  -- Warning color for the inventory bar
    InventoryBarBackground = Color(0, 0, 0, 200),  -- Background color of the inventory bar
    InventoryTextColor = Color(255, 255, 255),  -- Text color for inventory items

    -- Material price multipliers
    MinPriceMultiplier = 1.0,  -- Minimum multiplier for the material prices (e.g., 1.0 means no minimum)
    MaxPriceMultiplier = 2.0,  -- Maximum multiplier for the material prices (e.g., 2.0 doubles the price)
}

-- ⛏ Pickaxe Sound Tables
DMS.Sounds = {}

-- Swing / Miss Sounds
DMS.Sounds.Swing = {
    --"weapons/iceaxe/iceaxe_swing1.wav",
    "weapons/slam/throw.wav",
}

-- Generic world impact (wood, metal, etc.)
DMS.Sounds.HitWorld = {
    "physics/metal/metal_solid_impact_bullet3.wav",
    "weapons/crossbow/hitbod2.wav",
    "physics/wood/wood_solid_impact_hard1.wav",
    "physics/wood/wood_solid_impact_hard2.wav"
}

-- Rock impact (mining)
DMS.Sounds.HitRock = {
    "physics/concrete/concrete_impact_strong1.wav",
    "physics/concrete/concrete_impact_strong2.wav",
    "physics/concrete/concrete_impact_strong3.wav",
    "physics/concrete/concrete_break2.wav",
    "physics/concrete/concrete_break3.wav",
    "physics/rock/rock_impact_hard1.wav",
    "physics/rock/rock_impact_hard2.wav"
}

DMS.PickaxeTiers = {
    { level = 1,  name = "Topaz",       damage = 2,  speed = 1.00, color = Color(255, 200, 0) },       -- Golden yellow
    { level = 4,  name = "Quartz",      damage = 2,  speed = 0.95, color = Color(255, 255, 255) },     -- White
    { level = 7,  name = "Amethyst",    damage = 3,  speed = 0.90, color = Color(153, 102, 204) },     -- Purple
    { level = 10, name = "Amber",       damage = 4,  speed = 0.85, color = Color(255, 126, 0) },       -- Orange
    { level = 13, name = "Peridot",     damage = 5,  speed = 0.80, color = Color(142, 229, 63) },      -- Lime green
    { level = 16, name = "Citrine",     damage = 6,  speed = 0.75, color = Color(238, 201, 0) },       -- Deep yellow
    { level = 20, name = "Emerald",     damage = 7,  speed = 0.70, color = Color(80, 200, 120) },      -- Green
    { level = 24, name = "Opal",        damage = 8,  speed = 0.65, color = Color(204, 238, 255) },     -- Pale sky blue
    { level = 28, name = "Garnet",      damage = 9,  speed = 0.60, color = Color(115, 0, 0) },         -- Deep red
    { level = 32, name = "Ruby",        damage = 10, speed = 0.55, color = Color(224, 17, 95) },       -- Vibrant red
    { level = 36, name = "Sapphire",    damage = 11, speed = 0.50, color = Color(15, 82, 186) },       -- Deep blue
    { level = 40, name = "Aquamarine",  damage = 12, speed = 0.47, color = Color(127, 255, 212) },     -- Aqua
    { level = 44, name = "Zircon",      damage = 13, speed = 0.44, color = Color(185, 242, 255) },     -- Crystal blue
    { level = 48, name = "Obsidian",    damage = 14, speed = 0.42, color = Color(35, 35, 35) },        -- Charcoal black
    { level = 50, name = "Diamond",     damage = 15, speed = 0.40, color = Color(185, 242, 255) }      -- Icy blue/white
}

DMS.Ores = {
    Gems = {
        {
            name = "Topaz",
            color = Color(255, 200, 0),
            chance = 40,
            multiplier = 1.5,
            price = 200
        },
        {
            name = "Amethyst",
            color = Color(153, 102, 204),
            chance = 25,
            multiplier = 2,
            price = 350
        },
        {
            name = "Emerald",
            color = Color(0, 255, 0),
            chance = 20,
            multiplier = 2.5,
            price = 500
        },
        {
            name = "Ruby",
            color = Color(255, 0, 0),
            chance = 10,
            multiplier = 3,
            price = 700
        },
        {
            name = "Sapphire",
            color = Color(0, 0, 255),
            chance = 4,
            multiplier = 3.5,
            price = 900
        },
        {
            name = "Diamond",
            color = Color(200, 255, 255),
            chance = 1,
            multiplier = 4,
            price = 1500
        },
    },
    Ingots = {
        {
            name = "Copper",
            color = Color(184, 115, 51),
            chance = 30,
            forgetime = 10,
            price = 100
        },
        {
            name = "Iron",
            color = Color(192, 192, 192),
            chance = 25,
            forgetime = 15,
            price = 200
        },
        {
            name = "Steel",
            color = Color(70, 70, 70),
            chance = 20,
            forgetime = 20,
            price = 300
        },
        {
            name = "Silver",
            color = Color(220, 220, 220),
            chance = 15,
            forgetime = 30,
            price = 450
        },
        {
            name = "Gold",
            color = Color(255, 215, 0),
            chance = 7,
            forgetime = 45,
            price = 650
        },
        {
            name = "Titanium",
            color = Color(176, 224, 230),
            chance = 3,
            forgetime = 60,
            price = 1000
        },
    }
}

DMS.CraftingRecipes = {
    -- Basic Items (Easier to craft, lower level requirements)
    ["Crowbar"] = {
        displayName = "Crowbar",
        spawnType = "weapon",
        class = "weapon_crowbar",
        model = "models/weapons/w_crowbar.mdl",
        requiredItems = {
            ["Copper"] = 2,
            ["Topaz"] = 1
        },
        resultAmount = 1,
        requiredLevel = 1
    },

    ["Colt1911"] = {
        displayName = "Colt 1911",
        spawnType = "weapon",
        class = "m9k_colt1911",
        model = "models/weapons/s_dmgf_co1911.mdl",
        requiredItems = {
            ["Steel"] = 4,
            ["Topaz"] = 3,
            ["Silver"] = 2
        },
        resultAmount = 1,
        requiredLevel = 5
    },

    ["Grenade"] = {
        displayName = "Grenade",
        spawnType = "weapon",
        class = "m9k_m61_frag",
        model = "models/weapons/w_grenade.mdl",
        requiredItems = {
            ["Copper"] = 5,
            ["Iron"] = 3,
            ["Topaz"] = 1
        },
        resultAmount = 1,
        requiredLevel = 25
    },

    -- Mid-Tier Explosives and Weapons
    ["C4"] = {
        displayName = "C4 Explosive",
        spawnType = "weapon",
        class = "m9k_suicide_bomb",
        model = "models/weapons/w_c4.mdl",
        requiredItems = {
            ["Steel"] = 15,
            ["Silver"] = 10,
            ["Gold"] = 5,
            ["Emerald"] = 3,
            ["Ruby"] = 2
        },
        resultAmount = 1,
        requiredLevel = 35
    },

    ["Lockpick"] = {
        displayName = "Lockpick",
        spawnType = "weapon",
        class = "lockpick",
        model = "models/weapons/w_crowbar.mdl",
        requiredItems = {
            ["Copper"] = 6,
            ["Topaz"] = 3
        },
        resultAmount = 1,
        requiredLevel = 3
    },

    ["KeypadCracker"] = {
        displayName = "Keypad Cracker",
        spawnType = "weapon",
        class = "keypad_cracker",
        model = "models/weapons/w_c4.mdl",
        requiredItems = {
            ["Copper"] = 6,
            ["Topaz"] = 3,
            ["Emerald"] = 1
        },
        resultAmount = 1,
        requiredLevel = 4
    },

    ["MedKit"] = {
        displayName = "Med Kit",
        spawnType = "weapon",
        class = "med_kit",
        model = "models/items/healthkit.mdl",
        requiredItems = {
            ["Copper"] = 2,
            ["Silver"] = 1
        },
        resultAmount = 1,
        requiredLevel = 1
    },

    -- High-Tier Explosives and Weapons
    ["RPG7"] = {
        displayName = "RPG-7",
        spawnType = "weapon",
        class = "m9k_rpg7",
        model = "models/weapons/w_rocket_launcher.mdl",
        requiredItems = {
            ["Steel"] = 20,
            ["Gold"] = 10,
            ["Titanium"] = 8,
            ["Sapphire"] = 3,
            ["Diamond"] = 1
        },
        resultAmount = 1,
        requiredLevel = 45
    },

    ["Minigun"] = {
        displayName = "Minigun",
        spawnType = "weapon",
        class = "m9k_minigun",
        model = "models/weapons/w_m134_minigun.mdl",
        requiredItems = {
            ["Steel"] = 50,
            ["Titanium"] = 15,
            ["Sapphire"] = 5,
            ["Diamond"] = 2
        },
        resultAmount = 1,
        requiredLevel = 50
    },

    -- Melee Weapons (M9K and others)
    ["Hook"] = {
        displayName = "Hook",
        spawnType = "weapon",
        class = "weapon_hl2hook",
        model = "models/weapons/hl2meleepack/w_hook.mdl",
        requiredItems = {
            ["Iron"] = 6,
            ["Emerald"] = 2
        },
        resultAmount = 1,
        requiredLevel = 15
    },

    ["Pan"] = {
        displayName = "Pan",
        spawnType = "weapon",
        class = "weapon_hl2pan",
        model = "models/weapons/hl2meleepack/w_pan.mdl",
        requiredItems = {
            ["Steel"] = 8,
            ["Topaz"] = 3
        },
        resultAmount = 1,
        requiredLevel = 20
    },

    ["Pickaxe"] = {
        displayName = "Pickaxe",
        spawnType = "weapon",
        class = "weapon_hl2pickaxe",
        model = "models/weapons/hl2meleepack/w_pickaxe.mdl",
        requiredItems = {
            ["Silver"] = 10,
            ["Ruby"] = 2
        },
        resultAmount = 1,
        requiredLevel = 25
    },

    ["Pipe"] = {
        displayName = "Pipe",
        spawnType = "weapon",
        class = "weapon_hl2pipe",
        model = "models/props_canal/mattpipe.mdl",
        requiredItems = {
            ["Gold"] = 12,
            ["Emerald"] = 3
        },
        resultAmount = 1,
        requiredLevel = 30
    },

    ["Pot"] = {
        displayName = "Pot",
        spawnType = "weapon",
        class = "weapon_hl2pot",
        model = "models/weapons/hl2meleepack/w_pot.mdl",
        requiredItems = {
            ["Iron"] = 8,
            ["Sapphire"] = 4
        },
        resultAmount = 1,
        requiredLevel = 35
    },

    ["Shovel"] = {
        displayName = "Shovel",
        spawnType = "weapon",
        class = "weapon_hl2shovel",
        model = "models/weapons/hl2meleepack/w_shovel.mdl",
        requiredItems = {
            ["Diamond"] = 2,
            ["Gold"] = 18
        },
        resultAmount = 1,
        requiredLevel = 40
    },

    ["Axe"] = {
        displayName = "Axe",
        spawnType = "weapon",
        class = "weapon_hl2axe",
        model = "models/weapons/hl2meleepack/w_axe.mdl",
        requiredItems = {
            ["Steel"] = 20,
            ["Sapphire"] = 5
        },
        resultAmount = 1,
        requiredLevel = 45
    },

    ["Bottle"] = {
        displayName = "Bottle",
        spawnType = "weapon",
        class = "weapon_hl2bottle",
        model = "models/weapons/hl2meleepack/w_bottle.mdl",
        requiredItems = {
            ["Copper"] = 4,
            ["Topaz"] = 3
        },
        resultAmount = 1,
        requiredLevel = 50
    },

    ["TopazMoneyPrinter"] = {
        displayName = "Topaz Money Printer",
        spawnType = "entity",
        model = "models/props_c17/consolebox01a.mdl",  -- Replace with the model of your choice
        class = "topaz_money_printer",
        requiredItems = {
            ["Copper"] = 5,
            ["Topaz"] = 3
        },
        resultAmount = 1,
        requiredLevel = 10,  -- Level required to purchase this printer
    },

    -- Amethyst Money Printer
    ["AmethystMoneyPrinter"] = {
        displayName = "Amethyst Money Printer",
        spawnType = "entity",
        model = "models/props_c17/consolebox01a.mdl",  -- Replace with the model of your choice
        class = "amethyst_money_printer",
        requiredItems = {
            ["Copper"] = 10,
            ["Amethyst"] = 5
        },
        resultAmount = 1,
        requiredLevel = 20,  -- Level required to purchase this printer
    },

    -- Emerald Money Printer
    ["EmeraldMoneyPrinter"] = {
        displayName = "Emerald Money Printer",
        spawnType = "entity",
        model = "models/props_c17/consolebox01a.mdl",  -- Replace with the model of your choice
        class = "emerald_money_printer",
        requiredItems = {
            ["Copper"] = 15,
            ["Emerald"] = 3
        },
        resultAmount = 1,
        requiredLevel = 30,  -- Level required to purchase this printer
    },

    -- Ruby Money Printer
    ["RubyMoneyPrinter"] = {
        displayName = "Ruby Money Printer",
        spawnType = "entity",
        model = "models/props_c17/consolebox01a.mdl",  -- Replace with the model of your choice
        class = "ruby_money_printer",
        requiredItems = {
            ["Copper"] = 20,
            ["Ruby"] = 4
        },
        resultAmount = 1,
        requiredLevel = 40,  -- Level required to purchase this printer
    },

    -- Sapphire Money Printer
    ["SapphireMoneyPrinter"] = {
        displayName = "Sapphire Money Printer",
        spawnType = "entity",
        model = "models/props_c17/consolebox01a.mdl",  -- Replace with the model of your choice
        class = "sapphire_money_printer",
        requiredItems = {
            ["Copper"] = 25,
            ["Sapphire"] = 5
        },
        resultAmount = 1,
        requiredLevel = 50,  -- Level required to purchase this printer
    },

    -- Light Saber
    ["LightSaber"] = {
        displayName = "Light Saber",
        spawnType = "weapon",
        model = "models/sgg/starwars/weapons/w_anakin_ep2_saber_hilt.mdl",  -- Replace with the model of your choice
        class = "ent_lightsaber",
        requiredItems = {
            ["Steel"] = 25,
            ["Iron"] = 25,
            ["Titanium"] = 8,
            ["Diamond"] = 5,
            ["Ruby"] = 10,
            ["Sapphire"] = 10,
        },
        resultAmount = 1,
        requiredLevel = 50,  -- Level required to purchase this printer
    },

    -- Sapphire Money Printer
    ["ATMHacker"] = {
        displayName = "ATM Hacker",
        spawnType = "weapon",
        model = "models/props_lab/reciever01d.mdl",  -- Replace with the model of your choice
        class = "weapon_dubz_hacktool",
        requiredItems = {
            ["Copper"] = 15,
            ["Sapphire"] = 5,
            ["Diamond"] = 1,
            ["Steel"] = 10,

        },
        resultAmount = 1,
        requiredLevel = 10,  -- Level required to purchase this printer
    }
}


DMS.Levels = {
    Enabled = true,           -- Toggle level system on/off
    MaxLevel = 50,            -- Max level cap

    -- Base XP and multiplier for dynamic scaling if XPTable isn't fully defined
    BaseXP = 100,             -- XP required for level 1 → 2
    XPMultiplier = 1.25,      -- Multiplier applied to XP required per level

    -- XPTable: Optional manual XP requirements per level
    -- If a level is not in this table, BaseXP * (Level ^ XPMultiplier) will be used instead.
    XPTable = {
        [1] = 100,
        [2] = 125,
        [3] = 160,
        [4] = 200,
        [5] = 250,
        [6] = 310,
        [7] = 380,
        [8] = 460,
        [9] = 550,
        [10] = 650,
        [11] = 770,
        [12] = 920,
        [13] = 1100,
        [14] = 1300,
        [15] = 1500,
        [16] = 1750,
        [17] = 2000,
        [18] = 2300,
        [19] = 2650,
        [20] = 3000,
        [21] = 3400,
        [22] = 3850,
        [23] = 4350,
        [24] = 4900,
        [25] = 5500,
        [26] = 6200,
        [27] = 7000,
        [28] = 7900,
        [29] = 8900,
        [30] = 10000,
        [31] = 11300,
        [32] = 12700,
        [33] = 14250,
        [34] = 15900,
        [35] = 17700,
        [36] = 19650,
        [37] = 21750,
        [38] = 24000,
        [39] = 26400,
        [40] = 29000,
        [41] = 31800,
        [42] = 34800,
        [43] = 38000,
        [44] = 41400,
        [45] = 45000,
        [46] = 48800,
        [47] = 52800,
        [48] = 57000,
        [49] = 61400,
        [50] = 66000,
    }
}

DMS.CraftingColumns = 4

hook.Add("PlayerInitialSpawn", "InitializeDMS", function(ply)
    local data = ply:GetPData("DMS_PlayerOres", "{}")
    ply.Ores = util.JSONToTable(data)
end)