-- BloonData.lua
-- All bloon type definitions for Bloons TD5

local BloonData = {}

-- speed is studs/second
-- hp = layers before popping
-- children = bloons spawned when this layer is destroyed
-- immune = damage types this bloon is immune to
-- camo = whether bloon is camouflaged
-- regen = whether bloon regenerates layers
-- moab_class = true for MOAB-class bloons

BloonData.Types = {
    Red = {
        displayName = "Red Bloon",
        speed = 25,
        hp = 1,
        children = {},
        immune = {},
        size = 1.2,
        zIndex = 1,
    },
    Blue = {
        displayName = "Blue Bloon",
        speed = 30,
        hp = 1,
        children = {"Red"},
        immune = {},
        size = 1.2,
        zIndex = 2,
    },
    Green = {
        displayName = "Green Bloon",
        speed = 35,
        hp = 1,
        children = {"Blue"},
        immune = {},
        size = 1.2,
        zIndex = 3,
    },
    Yellow = {
        displayName = "Yellow Bloon",
        speed = 53,
        hp = 1,
        children = {"Green"},
        immune = {},
        size = 1.2,
        zIndex = 4,
    },
    Pink = {
        displayName = "Pink Bloon",
        speed = 68,
        hp = 1,
        children = {"Yellow"},
        immune = {},
        size = 1.2,
        zIndex = 5,
    },
    Black = {
        displayName = "Black Bloon",
        speed = 40,
        hp = 1,
        children = {"Pink", "Pink"},
        immune = {"Explosion"},
        size = 1.5,
        zIndex = 6,
    },
    White = {
        displayName = "White Bloon",
        speed = 45,
        hp = 1,
        children = {"Pink", "Pink"},
        immune = {"Freeze"},
        size = 1.5,
        zIndex = 7,
    },
    Lead = {
        displayName = "Lead Bloon",
        speed = 23,
        hp = 1,
        children = {"Black", "Black"},
        immune = {"Sharp"},
        size = 1.6,
        zIndex = 8,
    },
    Zebra = {
        displayName = "Zebra Bloon",
        speed = 40,
        hp = 1,
        children = {"Black", "White"},
        immune = {"Explosion", "Freeze"},
        size = 1.6,
        zIndex = 9,
    },
    Rainbow = {
        displayName = "Rainbow Bloon",
        speed = 55,
        hp = 1,
        children = {"Zebra", "Zebra"},
        immune = {},
        size = 1.6,
        zIndex = 10,
    },
    Ceramic = {
        displayName = "Ceramic Bloon",
        speed = 25,
        hp = 10,
        children = {"Rainbow", "Rainbow"},
        immune = {},
        size = 1.8,
        zIndex = 11,
    },
    MOAB = {
        displayName = "M.O.A.B.",
        speed = 10,
        hp = 200,
        children = {"Ceramic", "Ceramic", "Ceramic", "Ceramic"},
        immune = {},
        size = 3.5,
        zIndex = 12,
        moab_class = true,
    },
    BFB = {
        displayName = "B.F.B.",
        speed = 6,
        hp = 700,
        children = {"MOAB", "MOAB", "MOAB", "MOAB"},
        immune = {},
        size = 5.0,
        zIndex = 13,
        moab_class = true,
    },
    ZOMG = {
        displayName = "Z.O.M.G.",
        speed = 3.25,
        hp = 4000,
        children = {"BFB", "BFB", "BFB", "BFB"},
        immune = {},
        size = 7.0,
        zIndex = 14,
        moab_class = true,
    },
}

-- Camo variants
BloonData.CamoTypes = {"Green", "Yellow", "Pink", "Black", "White", "Zebra", "Rainbow", "Ceramic", "MOAB", "BFB", "ZOMG"}

-- Regen variants
BloonData.RegenTypes = {"Red", "Blue", "Green", "Yellow", "Pink", "Black", "White", "Lead", "Zebra", "Rainbow", "Ceramic"}

function BloonData.getChildren(bloonType, hp)
    local data = BloonData.Types[bloonType]
    if not data then return {} end
    if data.moab_class then
        -- MOAB-class bloons spawn children when destroyed
        return data.children
    end
    -- Regular bloons spawn children when layer popped
    if hp <= 1 then
        return data.children
    end
    return {bloonType} -- same type but reduced hp
end

function BloonData.isImmune(bloonType, damageType)
    local data = BloonData.Types[bloonType]
    if not data then return false end
    for _, immune in ipairs(data.immune) do
        if immune == damageType then
            return true
        end
    end
    return false
end

return BloonData
