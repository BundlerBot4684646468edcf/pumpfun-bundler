-- WaveData.lua
-- All 85 rounds of Bloons TD5 wave definitions

-- Format: {bloonType, count, interval}
-- interval = time in seconds between each bloon spawn
-- camo = true/false
-- regen = true/false

local WaveData = {}

WaveData.Rounds = {
    -- Round 1
    {
        {type="Red", count=20, interval=0.7}
    },
    -- Round 2
    {
        {type="Red", count=35, interval=0.5}
    },
    -- Round 3
    {
        {type="Blue", count=20, interval=0.7}
    },
    -- Round 4
    {
        {type="Blue", count=30, interval=0.5},
        {type="Red", count=5, interval=0.5, delay=5}
    },
    -- Round 5
    {
        {type="Red", count=10, interval=0.5},
        {type="Blue", count=15, interval=0.5, delay=3},
        {type="Green", count=5, interval=0.7, delay=8}
    },
    -- Round 6
    {
        {type="Blue", count=20, interval=0.5},
        {type="Green", count=10, interval=0.7, delay=6}
    },
    -- Round 7
    {
        {type="Green", count=20, interval=0.5},
        {type="Blue", count=10, interval=0.4, delay=4}
    },
    -- Round 8
    {
        {type="Green", count=30, interval=0.4}
    },
    -- Round 9
    {
        {type="Yellow", count=10, interval=0.7},
        {type="Green", count=20, interval=0.4, delay=3}
    },
    -- Round 10
    {
        {type="Yellow", count=20, interval=0.6}
    },
    -- Round 11
    {
        {type="Yellow", count=15, interval=0.5},
        {type="Pink", count=5, interval=0.8, delay=6}
    },
    -- Round 12
    {
        {type="Yellow", count=10, interval=0.5},
        {type="Pink", count=10, interval=0.6, delay=3}
    },
    -- Round 13
    {
        {type="Pink", count=20, interval=0.6}
    },
    -- Round 14
    {
        {type="Pink", count=15, interval=0.5},
        {type="Black", count=5, interval=1.0, delay=5}
    },
    -- Round 15
    {
        {type="Pink", count=10, interval=0.5},
        {type="Black", count=10, interval=0.8, delay=3}
    },
    -- Round 16
    {
        {type="Black", count=15, interval=0.7},
        {type="White", count=5, interval=0.8, delay=6}
    },
    -- Round 17
    {
        {type="Black", count=10, interval=0.7},
        {type="White", count=10, interval=0.7, delay=4}
    },
    -- Round 18
    {
        {type="Lead", count=5, interval=1.5}
    },
    -- Round 19
    {
        {type="Lead", count=5, interval=1.2},
        {type="Pink", count=20, interval=0.4, delay=3}
    },
    -- Round 20
    {
        {type="Lead", count=8, interval=1.0},
        {type="Black", count=10, interval=0.7, delay=5}
    },
    -- Round 21
    {
        {type="Zebra", count=5, interval=1.5}
    },
    -- Round 22
    {
        {type="Zebra", count=8, interval=1.2},
        {type="Black", count=10, interval=0.6, delay=5}
    },
    -- Round 23
    {
        {type="Zebra", count=5, interval=1.2},
        {type="Lead", count=5, interval=1.2, delay=4}
    },
    -- Round 24
    {
        {type="Rainbow", count=5, interval=1.5}
    },
    -- Round 25
    {
        {type="Rainbow", count=8, interval=1.2},
        {type="Zebra", count=5, interval=1.0, delay=6}
    },
    -- Round 26
    {
        {type="Rainbow", count=10, interval=1.0}
    },
    -- Round 27
    {
        {type="Rainbow", count=8, interval=1.0},
        {type="Lead", count=5, interval=1.5, delay=5}
    },
    -- Round 28
    {
        {type="Rainbow", count=12, interval=0.9},
        {type="Zebra", count=8, interval=1.0, delay=7}
    },
    -- Round 29
    {
        {type="Ceramic", count=2, interval=2.5},
        {type="Rainbow", count=10, interval=0.8, delay=4}
    },
    -- Round 30
    {
        {type="Ceramic", count=5, interval=2.0}
    },
    -- Round 31
    {
        {type="Ceramic", count=6, interval=1.8},
        {type="Rainbow", count=8, interval=0.8, delay=8}
    },
    -- Round 32
    {
        {type="Ceramic", count=8, interval=1.5}
    },
    -- Round 33
    {
        {type="Ceramic", count=5, interval=1.5},
        {type="Lead", count=8, interval=1.2, delay=6}
    },
    -- Round 34
    {
        {type="Ceramic", count=10, interval=1.4}
    },
    -- Round 35
    {
        {type="Ceramic", count=8, interval=1.3},
        {type="Rainbow", count=15, interval=0.7, delay=8}
    },
    -- Round 36
    {
        {type="Ceramic", count=12, interval=1.2}
    },
    -- Round 37
    {
        {type="Ceramic", count=10, interval=1.1},
        {type="Ceramic", count=5, interval=1.1, delay=8}
    },
    -- Round 38
    {
        {type="MOAB", count=1, interval=5.0}
    },
    -- Round 39
    {
        {type="Ceramic", count=20, interval=0.9},
        {type="MOAB", count=1, interval=5.0, delay=15}
    },
    -- Round 40
    {
        {type="MOAB", count=2, interval=8.0}
    },
    -- Round 41
    {
        {type="Ceramic", count=15, interval=0.9},
        {type="MOAB", count=1, interval=5.0, delay=10},
        {type="Ceramic", count=10, interval=0.9, delay=20}
    },
    -- Round 42
    {
        {type="MOAB", count=2, interval=7.0},
        {type="Ceramic", count=10, interval=0.8, delay=10}
    },
    -- Round 43
    {
        {type="MOAB", count=3, interval=6.0}
    },
    -- Round 44
    {
        {type="Ceramic", count=20, interval=0.8},
        {type="MOAB", count=2, interval=6.0, delay=12}
    },
    -- Round 45
    {
        {type="MOAB", count=4, interval=5.0}
    },
    -- Round 46
    {
        {type="MOAB", count=3, interval=5.0},
        {type="Ceramic", count=15, interval=0.7, delay=10}
    },
    -- Round 47
    {
        {type="MOAB", count=4, interval=5.0},
        {type="Ceramic", count=10, interval=0.7, delay=15}
    },
    -- Round 48
    {
        {type="MOAB", count=5, interval=4.0}
    },
    -- Round 49
    {
        {type="MOAB", count=4, interval=4.0},
        {type="Ceramic", count=20, interval=0.7, delay=12}
    },
    -- Round 50
    {
        {type="BFB", count=1, interval=10.0}
    },
    -- Round 51
    {
        {type="MOAB", count=6, interval=4.0},
        {type="BFB", count=1, interval=10.0, delay=20}
    },
    -- Round 52
    {
        {type="BFB", count=1, interval=10.0},
        {type="MOAB", count=5, interval=4.0, delay=8}
    },
    -- Round 53
    {
        {type="BFB", count=2, interval=8.0}
    },
    -- Round 54
    {
        {type="MOAB", count=8, interval=3.5},
        {type="BFB", count=1, interval=10.0, delay=20}
    },
    -- Round 55
    {
        {type="BFB", count=2, interval=7.0},
        {type="MOAB", count=5, interval=3.5, delay=10}
    },
    -- Round 56
    {
        {type="BFB", count=3, interval=7.0}
    },
    -- Round 57
    {
        {type="MOAB", count=10, interval=3.0},
        {type="BFB", count=2, interval=7.0, delay=20}
    },
    -- Round 58
    {
        {type="BFB", count=3, interval=6.0},
        {type="MOAB", count=5, interval=3.0, delay=15}
    },
    -- Round 59
    {
        {type="BFB", count=4, interval=6.0}
    },
    -- Round 60
    {
        {type="BFB", count=3, interval=5.0},
        {type="Ceramic", count=30, interval=0.6, delay=12}
    },
    -- Round 61
    {
        {type="BFB", count=4, interval=5.0},
        {type="MOAB", count=5, interval=3.0, delay=15}
    },
    -- Round 62
    {
        {type="BFB", count=5, interval=5.0}
    },
    -- Round 63
    {
        {type="MOAB", count=12, interval=2.8},
        {type="BFB", count=3, interval=5.0, delay=25}
    },
    -- Round 64
    {
        {type="BFB", count=5, interval=4.5},
        {type="MOAB", count=8, interval=3.0, delay=15}
    },
    -- Round 65
    {
        {type="BFB", count=6, interval=4.5}
    },
    -- Round 66
    {
        {type="Ceramic", count=50, interval=0.5, camo=true}
    },
    -- Round 67
    {
        {type="BFB", count=4, interval=4.0},
        {type="Ceramic", count=20, interval=0.5, camo=true, delay=12}
    },
    -- Round 68
    {
        {type="BFB", count=6, interval=4.0},
        {type="MOAB", count=5, interval=3.0, delay=18}
    },
    -- Round 69
    {
        {type="BFB", count=7, interval=4.0}
    },
    -- Round 70
    {
        {type="ZOMG", count=1, interval=15.0}
    },
    -- Round 71
    {
        {type="BFB", count=8, interval=3.5},
        {type="ZOMG", count=1, interval=15.0, delay=25}
    },
    -- Round 72
    {
        {type="ZOMG", count=1, interval=15.0},
        {type="BFB", count=5, interval=3.5, delay=12}
    },
    -- Round 73
    {
        {type="ZOMG", count=2, interval=12.0}
    },
    -- Round 74
    {
        {type="BFB", count=10, interval=3.0},
        {type="ZOMG", count=1, interval=15.0, delay=25}
    },
    -- Round 75
    {
        {type="ZOMG", count=2, interval=10.0},
        {type="BFB", count=6, interval=3.0, delay=15}
    },
    -- Round 76
    {
        {type="ZOMG", count=3, interval=10.0}
    },
    -- Round 77
    {
        {type="ZOMG", count=2, interval=9.0},
        {type="BFB", count=8, interval=3.0, delay=15}
    },
    -- Round 78
    {
        {type="ZOMG", count=3, interval=9.0},
        {type="MOAB", count=10, interval=2.5, delay=20}
    },
    -- Round 79
    {
        {type="ZOMG", count=4, interval=8.0}
    },
    -- Round 80
    {
        {type="ZOMG", count=3, interval=8.0},
        {type="BFB", count=10, interval=2.5, delay=18}
    },
    -- Round 81
    {
        {type="ZOMG", count=4, interval=7.0},
        {type="BFB", count=6, interval=2.5, delay=22}
    },
    -- Round 82
    {
        {type="ZOMG", count=5, interval=7.0}
    },
    -- Round 83
    {
        {type="ZOMG", count=4, interval=6.0},
        {type="BFB", count=12, interval=2.5, delay=18}
    },
    -- Round 84
    {
        {type="ZOMG", count=5, interval=6.0},
        {type="MOAB", count=15, interval=2.0, delay=20}
    },
    -- Round 85
    {
        {type="ZOMG", count=6, interval=5.0}
    },
}

-- Freeplay rounds (85+) use escalating difficulty
function WaveData.getFreeplayRound(roundNumber)
    local offset = roundNumber - 85
    local zomgCount = math.floor(offset / 3) + 1
    local bfbCount = math.floor(offset / 2) + 2
    return {
        {type="ZOMG", count=zomgCount, interval=math.max(2.0, 5.0 - offset * 0.1)},
        {type="BFB", count=bfbCount, interval=math.max(1.5, 3.0 - offset * 0.05), delay=10},
    }
end

return WaveData
