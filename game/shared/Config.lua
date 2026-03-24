-- Config.lua
-- Global game configuration for Bloons TD5 Roblox

local Config = {}

-- Game settings
Config.STARTING_CASH = 650
Config.STARTING_LIVES = 200
Config.MAX_LIVES = 200
Config.STARTING_ROUND = 1
Config.FREEPLAY_START = 86

-- Tick rates
Config.SERVER_TICK = 0.05       -- 20 tps server update
Config.BLOON_UPDATE_RATE = 0.05
Config.TOWER_ATTACK_RATE = 0.05

-- Map settings
Config.TILE_SIZE = 4
Config.PATH_WIDTH = 4

-- Tower settings
Config.MAX_TOWERS = 100
Config.SELL_REFUND_RATE = 0.75  -- 75% refund on sell

-- Pop rewards (cash per bloon popped)
Config.POP_CASH = {
    Red    = 1,
    Blue   = 1,
    Green  = 1,
    Yellow = 1,
    Pink   = 1,
    Black  = 1,
    White  = 1,
    Lead   = 1,
    Zebra  = 1,
    Rainbow = 1,
    Ceramic = 1,
    MOAB   = 1,
    BFB    = 1,
    ZOMG   = 1,
}

-- End-of-round cash bonus
Config.ROUND_CASH = {
    base = 100,
    perRound = 25,
}

-- Bloon layer RBE values (Red Bloon Equivalent)
Config.RBE = {
    Red    = 1,
    Blue   = 2,
    Green  = 3,
    Yellow = 4,
    Pink   = 5,
    Black  = 11,
    White  = 11,
    Lead   = 23,
    Zebra  = 23,
    Rainbow = 47,
    Ceramic = 104,
    MOAB   = 616,
    BFB    = 2544,
    ZOMG   = 16656,
}

-- Colors for bloon types
Config.BLOON_COLORS = {
    Red    = Color3.fromRGB(255, 50, 50),
    Blue   = Color3.fromRGB(50, 100, 255),
    Green  = Color3.fromRGB(50, 200, 50),
    Yellow = Color3.fromRGB(255, 255, 0),
    Pink   = Color3.fromRGB(255, 100, 200),
    Black  = Color3.fromRGB(30, 30, 30),
    White  = Color3.fromRGB(240, 240, 240),
    Lead   = Color3.fromRGB(150, 150, 160),
    Zebra  = Color3.fromRGB(200, 200, 200),
    Rainbow = Color3.fromRGB(255, 150, 0),
    Ceramic = Color3.fromRGB(180, 120, 60),
    MOAB   = Color3.fromRGB(50, 100, 200),
    BFB    = Color3.fromRGB(180, 50, 50),
    ZOMG   = Color3.fromRGB(50, 180, 50),
}

return Config
