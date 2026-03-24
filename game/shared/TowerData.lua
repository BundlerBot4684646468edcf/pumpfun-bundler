-- TowerData.lua
-- All tower definitions with upgrades for Bloons TD5

local TowerData = {}

--[[
Tower upgrade paths: each tower has path1 and path2, each with 4 upgrades.
Each upgrade modifies stats or adds abilities.
damageType: "Sharp", "Explosion", "Freeze", "Glue", "Normal", "Energy"
Sharp hits normal bloons but NOT lead
Explosion hits lead but NOT black/zebra
Freeze hits nothing immune to it (white/zebra immune)
Normal hits everything
Energy hits everything (laser/plasma)
]]

TowerData.Towers = {

    -- ==================== DART MONKEY ====================
    DartMonkey = {
        displayName = "Dart Monkey",
        description = "Throws darts at nearby bloons.",
        cost = 170,
        range = 18,
        attackSpeed = 1.4, -- attacks per second
        damage = 1,
        pierce = 1, -- bloons hit per projectile
        damageType = "Sharp",
        projectileSpeed = 80,
        size = 1.5,
        path1 = {
            {name = "Long Range Darts",      cost = 85,  description = "+5 range"},
            {name = "Enhanced Eye Sight",    cost = 170, description = "+5 range, detects camo"},
            {name = "Spike-o-pult",          cost = 380, description = "Throws spiked balls, +10 pierce, slower speed"},
            {name = "Juggernaut",            cost = 2550,description = "Giant spiked ball, extreme pierce, pops lead"},
        },
        path2 = {
            {name = "Quick Shots",           cost = 85,  description = "+0.4 attack speed"},
            {name = "Very Quick Shots",      cost = 170, description = "+0.4 attack speed"},
            {name = "Triple Darts",          cost = 425, description = "Throws 3 darts per shot"},
            {name = "Super Monkey Fan Club", cost = 17000,description = "Ability: Super Monkey fan club"},
        },
    },

    -- ==================== TACK SHOOTER ====================
    TackShooter = {
        displayName = "Tack Shooter",
        description = "Shoots 8 tacks in all directions.",
        cost = 230,
        range = 14,
        attackSpeed = 1.0,
        damage = 1,
        pierce = 1,
        damageType = "Sharp",
        projectileSpeed = 60,
        burstCount = 8, -- projectiles per attack
        size = 1.3,
        path1 = {
            {name = "Faster Shooting",       cost = 115, description = "+0.5 attack speed"},
            {name = "Even Faster Shooting",  cost = 200, description = "+0.5 attack speed"},
            {name = "Ring of Fire",          cost = 850, description = "Shoots fire, higher damage, no pierce limit"},
            {name = "Inferno Ring",          cost = 3825,description = "Massive fire damage, pops all bloon types"},
        },
        path2 = {
            {name = "Extra Range Tacks",     cost = 115, description = "+4 range"},
            {name = "Super Range Tacks",     cost = 230, description = "+4 range"},
            {name = "Long Reach Tacks",      cost = 375, description = "+4 range"},
            {name = "Tack Sprayer",          cost = 2125,description = "Shoots 16 tacks instead of 8"},
        },
    },

    -- ==================== SNIPER MONKEY ====================
    SniperMonkey = {
        displayName = "Sniper Monkey",
        description = "Long range, high damage. Can be set to target specific bloon layers.",
        cost = 350,
        range = math.huge, -- full map range
        attackSpeed = 0.5,
        damage = 2,
        pierce = 1,
        damageType = "Normal",
        projectileSpeed = math.huge, -- instant
        size = 1.5,
        path1 = {
            {name = "Full Metal Jacket",     cost = 350, description = "Pops lead and frozen bloons"},
            {name = "Point Five Oh",         cost = 2100,description = "+5 damage per shot"},
            {name = "Deadly Precision",      cost = 2550,description = "+10 damage, pops MOAB-class"},
            {name = "Cripple MOAB",          cost = 3000,description = "Ability: Cripple a MOAB-class bloon"},
        },
        path2 = {
            {name = "Night Vision Goggles",  cost = 175, description = "Detects camo bloons"},
            {name = "Faster Firing",         cost = 255, description = "+0.5 attack speed"},
            {name = "Even Faster Firing",    cost = 1360,description = "+0.5 attack speed"},
            {name = "Supply Drop",           cost = 7650,description = "Ability: Drops cash supply"},
        },
    },

    -- ==================== BOOMERANG THROWER ====================
    BoomerangThrower = {
        displayName = "Boomerang Thrower",
        description = "Throws boomerangs that arc and can hit multiple bloons.",
        cost = 325,
        range = 20,
        attackSpeed = 0.9,
        damage = 1,
        pierce = 4,
        damageType = "Sharp",
        projectileSpeed = 50,
        size = 1.5,
        path1 = {
            {name = "Sonic Boom",            cost = 250, description = "Ability: Destroys a layer from all bloons on screen"},
            {name = "Red Hot Rangs",         cost = 350, description = "Pops lead and frozen bloons"},
            {name = "Bionic Boomerang",      cost = 1700,description = "3x attack speed, +3 pierce"},
            {name = "Turbo Charge",          cost = 3400,description = "Ability: 5x attack speed temporarily"},
        },
        path2 = {
            {name = "Multi-Target",          cost = 200, description = "Throws 2 boomerangs per shot"},
            {name = "Glaive Thrower",        cost = 550, description = "Throws glaives with higher pierce"},
            {name = "Glaive Ricochet",       cost = 2550,description = "Glaive bounces between bloons"},
            {name = "MOAB Press",            cost = 3825,description = "Knocks back and damages MOAB-class"},
        },
    },

    -- ==================== NINJA MONKEY ====================
    NinjaMonkey = {
        displayName = "Ninja Monkey",
        description = "Throws ninja stars. Detects camo bloons.",
        cost = 425,
        range = 20,
        attackSpeed = 1.5,
        damage = 1,
        pierce = 2,
        damageType = "Sharp",
        projectileSpeed = 90,
        detectsCamo = true,
        size = 1.5,
        path1 = {
            {name = "Ninja Discipline",      cost = 250, description = "+0.5 attack speed"},
            {name = "Sharp Shurikens",       cost = 325, description = "+1 pierce"},
            {name = "Double Shot",           cost = 850, description = "Throws 2 shurikens per shot"},
            {name = "Bloonjitsu",            cost = 3400,description = "Throws 5 shurikens per shot"},
        },
        path2 = {
            {name = "Seeking Shuriken",      cost = 200, description = "Shurikens home in on bloons"},
            {name = "Distraction",           cost = 250, description = "Bloons pushed back on hit"},
            {name = "Flash Bomb",            cost = 1275,description = "Throws flash bombs that stun bloons"},
            {name = "Master Bomber",         cost = 3825,description = "Flash bombs stun MOAB-class bloons"},
        },
    },

    -- ==================== BOMB TOWER ====================
    BombTower = {
        displayName = "Bomb Tower",
        description = "Launches bombs that explode on impact.",
        cost = 550,
        range = 22,
        attackSpeed = 0.7,
        damage = 1,
        pierce = 20, -- explosion radius pierce
        damageType = "Explosion",
        projectileSpeed = 45,
        explosionRadius = 8,
        size = 1.8,
        path1 = {
            {name = "Bigger Bombs",          cost = 425, description = "+4 explosion radius"},
            {name = "Extra Range Bombs",     cost = 225, description = "+5 range"},
            {name = "Frag Bombs",            cost = 425, description = "Bombs release shrapnel on impact"},
            {name = "Cluster Bombs",         cost = 2550,description = "Bombs split into cluster bombs"},
        },
        path2 = {
            {name = "Faster Reload",         cost = 250, description = "+0.3 attack speed"},
            {name = "Missile Launcher",      cost = 300, description = "+0.3 attack speed, faster projectile"},
            {name = "MOAB Mauler",           cost = 1700,description = "+10 damage vs MOAB-class"},
            {name = "MOAB Assassin",         cost = 7650,description = "Ability: Fire a bomb dealing 10000 damage to MOAB-class"},
        },
    },

    -- ==================== ICE TOWER ====================
    IceTower = {
        displayName = "Ice Tower",
        description = "Freezes all bloons in range.",
        cost = 340,
        range = 15,
        attackSpeed = 0.4,
        damage = 0, -- doesn't deal damage directly
        pierce = math.huge,
        damageType = "Freeze",
        freezeDuration = 2.0,
        size = 1.5,
        path1 = {
            {name = "Enhanced Freeze",       cost = 200, description = "+0.5s freeze duration"},
            {name = "Deep Freeze",           cost = 300, description = "+0.5s freeze duration"},
            {name = "Arctic Wind",           cost = 1700,description = "Slows bloons in wide radius permanently"},
            {name = "Absolute Zero",         cost = 3825,description = "Ability: Freeze everything on screen"},
        },
        path2 = {
            {name = "Snap Freeze",           cost = 400, description = "Freeze deals 1 layer damage"},
            {name = "Cold Snap",             cost = 500, description = "Freeze affects white/zebra bloons"},
            {name = "Super Freeze",          cost = 850, description = "+5 range, bigger freeze radius"},
            {name = "Viral Frost",           cost = 2550,description = "Frozen bloons spread freeze to nearby bloons"},
        },
    },

    -- ==================== GLUE GUNNER ====================
    GlueGunner = {
        displayName = "Glue Gunner",
        description = "Shoots globs of glue that slow bloons.",
        cost = 275,
        range = 20,
        attackSpeed = 0.6,
        damage = 0,
        pierce = 1,
        damageType = "Glue",
        slowFactor = 0.5, -- bloon speed multiplier
        glueDuration = 8.0,
        size = 1.5,
        path1 = {
            {name = "Glue Soak",             cost = 90,  description = "Glue soaks through layers"},
            {name = "Solvent",               cost = 300, description = "Glue pops a layer every 2s"},
            {name = "Bloon Dissolver",       cost = 3000,description = "Glue pops layers rapidly"},
            {name = "Bloon Liquefier",       cost = 5100,description = "Glue destroys bloons rapidly"},
        },
        path2 = {
            {name = "Bigger Globs",          cost = 135, description = "+1 pierce"},
            {name = "Glue Splatter",         cost = 850, description = "Glue splashes on nearby bloons"},
            {name = "Glue Strike",           cost = 1700,description = "Ability: Glue all bloons on screen"},
            {name = "Glue Storm",            cost = 3825,description = "Ability: Repeated glue strikes"},
        },
    },

    -- ==================== MONKEY BUCCANEER ====================
    MonkeyBuccaneer = {
        displayName = "Monkey Buccaneer",
        description = "Must be placed on water. Shoots darts and cannonballs.",
        cost = 425,
        range = 22,
        attackSpeed = 0.9,
        damage = 1,
        pierce = 2,
        damageType = "Sharp",
        projectileSpeed = 70,
        requiresWater = true,
        size = 2.0,
        path1 = {
            {name = "Longer Cannons",        cost = 250, description = "+5 range"},
            {name = "Faster Shooting",       cost = 300, description = "+0.4 attack speed"},
            {name = "Double Shot",           cost = 600, description = "Shoots 2 projectiles per shot"},
            {name = "Destroyer",             cost = 5950,description = "Extremely fast firing, massive damage"},
        },
        path2 = {
            {name = "Grape Shot",            cost = 425, description = "Shoots grapes instead of darts (5 projectiles)"},
            {name = "Hot Shot",              cost = 550, description = "Grapes are hot, pop lead"},
            {name = "Cannon Ship",           cost = 1275,description = "Also fires cannonballs with explosion"},
            {name = "Aircraft Carrier",      cost = 11900,description = "Deploys fighter planes"},
        },
    },

    -- ==================== MONKEY ACE ====================
    MonkeyAce = {
        displayName = "Monkey Ace",
        description = "Flies in circles, dropping darts.",
        cost = 875,
        range = 50,
        attackSpeed = 1.0,
        damage = 1,
        pierce = 2,
        damageType = "Sharp",
        projectileSpeed = 80,
        flightRadius = 20,
        size = 2.0,
        path1 = {
            {name = "Rapid Fire",            cost = 550, description = "2x attack speed"},
            {name = "Lots More Darts",       cost = 600, description = "Drops 8 darts per volley"},
            {name = "Fighter Plane",         cost = 2125,description = "Flies faster, fires missiles"},
            {name = "Operation: Dart Storm", cost = 3400,description = "Ability: Dart storm covers entire map"},
        },
        path2 = {
            {name = "Lots More Darts",       cost = 425, description = "+2 pierce per dart"},
            {name = "Fighter Plane",         cost = 600, description = "Plane targets bloons directly"},
            {name = "Spy Plane",             cost = 850, description = "Detects camo bloons"},
            {name = "Bomber Ace",            cost = 2125,description = "Drops bombs instead of darts"},
        },
    },

    -- ==================== SUPER MONKEY ====================
    SuperMonkey = {
        displayName = "Super Monkey",
        description = "Extremely powerful monkey that shoots lasers.",
        cost = 3000,
        range = 26,
        attackSpeed = 10, -- 10 shots/sec
        damage = 1,
        pierce = 1,
        damageType = "Energy",
        projectileSpeed = 150,
        size = 2.0,
        path1 = {
            {name = "Laser Blasts",          cost = 2125,description = "Shoots lasers (Energy, pops lead)"},
            {name = "Plasma Blasts",         cost = 4250,description = "Shoots plasma (+1 pierce, more damage)"},
            {name = "Sun God",               cost = 19550,description = "Worshipped as a Sun God, massive power"},
            {name = "True Sun God",          cost = 85000,description = "Ultimate Sun God power"},
        },
        path2 = {
            {name = "Super Range",           cost = 1700,description = "+8 range"},
            {name = "Epic Range",            cost = 1700,description = "+8 range"},
            {name = "Robo Monkey",           cost = 7650,description = "Dual guns, attacks on both sides"},
            {name = "Tech Terror",           cost = 17000,description = "Ability: Destroys bloons on screen"},
        },
    },

    -- ==================== MORTAR TOWER ====================
    MortarTower = {
        displayName = "Mortar Tower",
        description = "Manually targeted, lobs explosive shells anywhere on the map.",
        cost = 700,
        range = math.huge,
        attackSpeed = 0.5,
        damage = 1,
        pierce = 30,
        damageType = "Explosion",
        projectileSpeed = 35,
        explosionRadius = 10,
        manualTarget = true,
        size = 2.0,
        path1 = {
            {name = "Bigger Blast",          cost = 400, description = "+4 explosion radius"},
            {name = "Bloon Buster",          cost = 500, description = "+2 damage vs ceramic and below"},
            {name = "Heavy Shells",          cost = 2125,description = "+5 damage, bigger explosion"},
            {name = "The Big One",           cost = 12750,description = "Massive explosion, extreme damage"},
        },
        path2 = {
            {name = "Faster Reload",         cost = 350, description = "+0.3 attack speed"},
            {name = "Rapid Reload",          cost = 600, description = "+0.3 attack speed"},
            {name = "Mortar Acceleration",   cost = 1700,description = "+0.4 attack speed"},
            {name = "Pop and Awe",           cost = 7650,description = "Ability: Stuns all bloons on screen"},
        },
    },

    -- ==================== DARTLING GUN ====================
    DartlingGun = {
        displayName = "Dartling Gun",
        description = "Shoots a stream of darts towards the cursor.",
        cost = 1700,
        range = math.huge,
        attackSpeed = 8,
        damage = 1,
        pierce = 1,
        damageType = "Sharp",
        projectileSpeed = 120,
        cursorTarget = true,
        size = 2.0,
        path1 = {
            {name = "Focused Firing",        cost = 500, description = "Reduced spread"},
            {name = "Laser Cannon",          cost = 2000,description = "Shoots laser beams (Energy)"},
            {name = "Ray of Doom",           cost = 35000,description = "Fires a continuous ray of pure doom"},
            {name = "Ray of Doom+",          cost = 100000,description = "Upgraded Ray of Doom"},
        },
        path2 = {
            {name = "Faster Barrel Spin",    cost = 1000,description = "+4 attack speed"},
            {name = "Even Faster Spinning",  cost = 1500,description = "+4 attack speed"},
            {name = "Hydra Rocket Pods",     cost = 5100,description = "Fires rockets instead of darts"},
            {name = "Bloon Area Denial System", cost = 42500, description = "Extreme rocket barrage"},
        },
    },

    -- ==================== SPIKE FACTORY ====================
    SpikeFactory = {
        displayName = "Spike Factory",
        description = "Drops spikes on the track that damage passing bloons.",
        cost = 850,
        range = 15,
        attackSpeed = 0.5,
        damage = 1,
        pierce = 10,
        damageType = "Sharp",
        spikeLifetime = 30, -- seconds before spikes disappear
        size = 1.8,
        path1 = {
            {name = "Bigger Stacks",         cost = 500, description = "+5 pierce per spike pile"},
            {name = "White Hot Spikes",      cost = 425, description = "Pops frozen and lead bloons"},
            {name = "Spiked Balls",          cost = 1700,description = "Deploys spiked balls with high pierce"},
            {name = "Spiked Mines",          cost = 5950,description = "Exploding spike mines, massive area damage"},
        },
        path2 = {
            {name = "Faster Production",     cost = 335, description = "+0.4 production speed"},
            {name = "Even Faster Production",cost = 550, description = "+0.4 production speed"},
            {name = "MOAB SHREDR",           cost = 1275,description = "Spikes deal 10x damage to MOAB-class"},
            {name = "Pre-Emptive Strike",    cost = 12750,description = "Ability: Deploy massive spike pile"},
        },
    },

    -- ==================== MONKEY VILLAGE ====================
    MonkeyVillage = {
        displayName = "Monkey Village",
        description = "Supports nearby towers with buffs.",
        cost = 1200,
        range = 25,
        attackSpeed = 0,
        damage = 0,
        pierce = 0,
        damageType = "None",
        support = true,
        size = 2.5,
        path1 = {
            {name = "Bigger Radius",         cost = 425, description = "+8 support radius"},
            {name = "Jungle Drums",          cost = 1275,description = "Nearby towers attack 15% faster"},
            {name = "Primary Training",      cost = 3000,description = "Primary towers in range get one free upgrade"},
            {name = "Primary Expertise",     cost = 20000,description = "Primary towers +1 damage, max pierce"},
        },
        path2 = {
            {name = "Monkey Business",       cost = 550, description = "Towers in range cost 10% less"},
            {name = "Monkey Commerce",       cost = 850, description = "Towers in range cost 10% less"},
            {name = "Monkey Town",           cost = 8500,description = "Earn double cash from bloons in range"},
            {name = "Monkey City",           cost = 170000,description = "Earn triple cash from bloons in range"},
        },
    },

    -- ==================== ENGINEER MONKEY ====================
    EngineerMonkey = {
        displayName = "Engineer Monkey",
        description = "Builds sentries and uses a nail gun.",
        cost = 475,
        range = 18,
        attackSpeed = 1.2,
        damage = 1,
        pierce = 2,
        damageType = "Sharp",
        projectileSpeed = 80,
        size = 1.5,
        path1 = {
            {name = "Faster Engineering",    cost = 350, description = "+0.5 attack speed"},
            {name = "Sprockets",             cost = 300, description = "+0.5 attack speed, +1 pierce"},
            {name = "Sentry Gun",            cost = 850, description = "Builds a sentry gun"},
            {name = "Overclock",             cost = 8500,description = "Ability: Greatly speed up a target tower"},
        },
        path2 = {
            {name = "Cleansing Foam",        cost = 300, description = "Foam removes camo and regen from bloons"},
            {name = "Nailing",               cost = 500, description = "Nails pin bloons in place briefly"},
            {name = "Bloon Trap",            cost = 1275,description = "Places a bloon trap that catches bloons"},
            {name = "XXXL Trap",             cost = 17000,description = "Massive bloon trap"},
        },
    },
}

function TowerData.getTower(towerType)
    return TowerData.Towers[towerType]
end

function TowerData.getUpgradeCost(towerType, path, level)
    local tower = TowerData.Towers[towerType]
    if not tower then return 0 end
    local upgradePath = path == 1 and tower.path1 or tower.path2
    if not upgradePath or not upgradePath[level] then return 0 end
    return upgradePath[level].cost
end

function TowerData.getTowerList()
    local list = {}
    for k, _ in pairs(TowerData.Towers) do
        table.insert(list, k)
    end
    table.sort(list)
    return list
end

return TowerData
