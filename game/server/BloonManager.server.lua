-- BloonManager.server.lua
-- Manages bloon spawning, movement, and removal

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BloonData = require(ReplicatedStorage.Shared.BloonData)
local Config = require(ReplicatedStorage.Shared.Config)

local BloonManager = {}
BloonManager.__index = BloonManager

-- Active bloons table: bloonId -> bloon state
local activeBloons = {}
local bloonIdCounter = 0
local pathWaypoints = {}  -- filled by GameManager

-- Bloon state structure:
-- {
--   id, type, hp, position, waypointIndex, distanceTravelled,
--   speed, isCamo, isRegen, isFrozen, frozenTimer,
--   isGlued, gluedTimer, slowFactor,
--   model (BasePart)
-- }

function BloonManager.init(waypoints)
    pathWaypoints = waypoints
    activeBloons = {}
    bloonIdCounter = 0
end

function BloonManager.spawnBloon(bloonType, camo, regen)
    local data = BloonData.Types[bloonType]
    if not data then
        warn("Unknown bloon type: " .. tostring(bloonType))
        return nil
    end

    bloonIdCounter = bloonIdCounter + 1
    local id = bloonIdCounter

    -- Create visual model
    local model = Instance.new("Part")
    model.Name = "Bloon_" .. id
    model.Shape = Enum.PartType.Ball
    model.Size = Vector3.new(data.size, data.size, data.size)
    model.Color = Config.BLOON_COLORS[bloonType] or Color3.fromRGB(255,255,255)
    model.Material = Enum.Material.SmoothPlastic
    model.Anchored = true
    model.CanCollide = false
    model.CastShadow = false

    -- Camo visual (transparent with outline)
    if camo then
        model.Transparency = 0.5
    end

    -- Regen visual (pulsing -- handled client side)
    local tag = Instance.new("StringValue")
    tag.Name = "BloonType"
    tag.Value = bloonType
    tag.Parent = model

    if camo then
        local camoTag = Instance.new("BoolValue")
        camoTag.Name = "IsCamo"
        camoTag.Value = true
        camoTag.Parent = model
    end

    if regen then
        local regenTag = Instance.new("BoolValue")
        regenTag.Name = "IsRegen"
        regenTag.Value = true
        regenTag.Parent = model
    end

    -- HP label (BillboardGui)
    if data.moab_class then
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 60, 0, 20)
        billboard.StudsOffset = Vector3.new(0, data.size + 0.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = model

        local hpLabel = Instance.new("TextLabel")
        hpLabel.Name = "HpLabel"
        hpLabel.Size = UDim2.new(1, 0, 1, 0)
        hpLabel.BackgroundTransparency = 1
        hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        hpLabel.TextStrokeTransparency = 0
        hpLabel.TextScaled = true
        hpLabel.Text = tostring(data.hp)
        hpLabel.Parent = billboard
    end

    model.Position = pathWaypoints[1] + Vector3.new(0, data.size / 2, 0)
    model.Parent = workspace.Bloons

    local bloon = {
        id = id,
        type = bloonType,
        hp = data.hp,
        maxHp = data.moab_class and data.hp or nil,
        position = pathWaypoints[1],
        waypointIndex = 1,
        distanceTravelled = 0,
        speed = data.speed,
        isCamo = camo or false,
        isRegen = regen or false,
        isFrozen = false,
        frozenTimer = 0,
        isGlued = false,
        gluedTimer = 0,
        slowFactor = 1.0,
        regenTimer = 0,
        model = model,
        data = data,
        zIndex = data.zIndex,
    }

    activeBloons[id] = bloon
    return id
end

function BloonManager.update(dt)
    local bloonsToRemove = {}
    local bloonsAtEnd = {}

    for id, bloon in pairs(activeBloons) do
        -- Update frozen timer
        if bloon.isFrozen then
            bloon.frozenTimer = bloon.frozenTimer - dt
            if bloon.frozenTimer <= 0 then
                bloon.isFrozen = false
                bloon.model.Transparency = bloon.isCamo and 0.5 or 0
            end
        end

        -- Update glue timer
        if bloon.isGlued then
            bloon.gluedTimer = bloon.gluedTimer - dt
            if bloon.gluedTimer <= 0 then
                bloon.isGlued = false
                bloon.slowFactor = 1.0
            end
        end

        -- Regen: restore a layer every 3 seconds if damaged
        if bloon.isRegen and not bloon.data.moab_class then
            bloon.regenTimer = bloon.regenTimer + dt
            if bloon.regenTimer >= 3.0 then
                bloon.regenTimer = 0
                if bloon.hp < bloon.data.hp then
                    bloon.hp = bloon.hp + 1
                    bloon.type = BloonManager._getRegenType(bloon)
                end
            end
        end

        -- Skip movement if frozen
        if bloon.isFrozen then
            continue
        end

        -- Move bloon along path
        local effectiveSpeed = bloon.speed * bloon.slowFactor
        local remaining = effectiveSpeed * dt

        while remaining > 0 and bloon.waypointIndex < #pathWaypoints do
            local targetWP = pathWaypoints[bloon.waypointIndex + 1]
            local currentPos = bloon.position
            local dir = (targetWP - currentPos)
            local dist = dir.Magnitude

            if dist <= 0.01 then
                bloon.waypointIndex = bloon.waypointIndex + 1
                continue
            end

            if remaining >= dist then
                remaining = remaining - dist
                bloon.distanceTravelled = bloon.distanceTravelled + dist
                bloon.position = targetWP
                bloon.waypointIndex = bloon.waypointIndex + 1
            else
                local move = (dir / dist) * remaining
                bloon.distanceTravelled = bloon.distanceTravelled + remaining
                bloon.position = currentPos + move
                remaining = 0
            end
        end

        -- Check if bloon reached the end
        if bloon.waypointIndex >= #pathWaypoints then
            table.insert(bloonsAtEnd, bloon)
            table.insert(bloonsToRemove, id)
        else
            -- Update model position
            local yOffset = bloon.data.size / 2
            bloon.model.Position = bloon.position + Vector3.new(0, yOffset, 0)

            -- Update HP label for MOAB-class
            if bloon.data.moab_class then
                local billboard = bloon.model:FindFirstChild("BillboardGui")
                if billboard then
                    local label = billboard:FindFirstChild("HpLabel")
                    if label then
                        label.Text = tostring(math.max(0, bloon.hp))
                    end
                end
            end
        end
    end

    -- Remove bloons that reached the end
    for _, id in ipairs(bloonsToRemove) do
        BloonManager.removeBloon(id)
    end

    return bloonsAtEnd
end

function BloonManager._getRegenType(bloon)
    -- When a regen bloon regenerates, restore the bloon type
    return bloon.data and bloon.data.displayName or bloon.type
end

-- Returns damage dealt and children spawned
function BloonManager.damageBloon(bloonId, damage, damageType, sourceId)
    local bloon = activeBloons[bloonId]
    if not bloon then return 0, {} end

    -- Frozen bloons take damage from any source
    -- Check immunity
    if damageType ~= "Normal" and damageType ~= "Energy" then
        if BloonData.isImmune(bloon.type, damageType) then
            return 0, {}
        end
    end

    -- Lead immune to Sharp unless upgraded
    if damageType == "Sharp" and BloonData.isImmune(bloon.type, "Sharp") then
        return 0, {}
    end

    local children = {}
    local totalDamage = 0

    -- Deal damage
    if bloon.data.moab_class then
        -- MOAB-class: subtract HP directly
        local actualDamage = math.min(damage, bloon.hp)
        bloon.hp = bloon.hp - actualDamage
        totalDamage = actualDamage

        if bloon.hp <= 0 then
            -- Spawn children
            for _, childType in ipairs(bloon.data.children) do
                local childId = BloonManager.spawnBloonAtPosition(
                    childType, bloon.position, bloon.waypointIndex,
                    bloon.distanceTravelled, bloon.isCamo, false
                )
                table.insert(children, childId)
            end
            BloonManager.removeBloon(bloonId)
        end
    else
        -- Regular bloon: remove layers
        local layersToRemove = damage
        local currentBloon = bloon

        while layersToRemove > 0 and currentBloon do
            currentBloon.hp = currentBloon.hp - 1
            totalDamage = totalDamage + 1
            layersToRemove = layersToRemove - 1

            if currentBloon.hp <= 0 then
                -- Pop this layer, spawn children
                local childTypes = BloonData.getChildren(currentBloon.type, currentBloon.hp + 1)
                -- First child continues in-place; additional children spawn near
                for i, childType in ipairs(childTypes) do
                    if i == 1 and layersToRemove > 0 then
                        -- Continue damaging next layer
                        local childId = BloonManager.spawnBloonAtPosition(
                            childType, currentBloon.position, currentBloon.waypointIndex,
                            currentBloon.distanceTravelled, currentBloon.isCamo, currentBloon.isRegen
                        )
                        local childBloon = activeBloons[childId]
                        if childBloon and childBloon.data.immune then
                            -- Check if child is immune to this damage
                            if not BloonData.isImmune(childType, damageType) then
                                currentBloon = childBloon
                            else
                                table.insert(children, childId)
                                currentBloon = nil
                            end
                        else
                            currentBloon = childBloon
                        end
                    else
                        local childId = BloonManager.spawnBloonAtPosition(
                            childType, currentBloon.position, currentBloon.waypointIndex,
                            currentBloon.distanceTravelled, currentBloon.isCamo, currentBloon.isRegen
                        )
                        table.insert(children, childId)
                    end
                end

                -- Remove the popped bloon
                BloonManager.removeBloon(currentBloon and currentBloon.id or bloonId)
                if i == 1 and layersToRemove > 0 then
                    -- already set currentBloon
                else
                    currentBloon = nil
                end
                break
            end
        end
    end

    return totalDamage, children
end

function BloonManager.freezeBloon(bloonId, duration)
    local bloon = activeBloons[bloonId]
    if not bloon then return end

    if BloonData.isImmune(bloon.type, "Freeze") then return end

    bloon.isFrozen = true
    bloon.frozenTimer = math.max(bloon.frozenTimer, duration)
    bloon.model.Transparency = 0.7
end

function BloonManager.glueBloon(bloonId, duration, slowFactor)
    local bloon = activeBloons[bloonId]
    if not bloon then return end

    bloon.isGlued = true
    bloon.gluedTimer = math.max(bloon.gluedTimer, duration)
    bloon.slowFactor = math.min(bloon.slowFactor, slowFactor)
end

function BloonManager.spawnBloonAtPosition(bloonType, position, waypointIndex, distanceTravelled, camo, regen)
    local id = BloonManager.spawnBloon(bloonType, camo, regen)
    if not id then return nil end

    local bloon = activeBloons[id]
    bloon.position = position
    bloon.waypointIndex = waypointIndex
    bloon.distanceTravelled = distanceTravelled
    bloon.model.Position = position + Vector3.new(0, bloon.data.size / 2, 0)

    return id
end

function BloonManager.removeBloon(bloonId)
    local bloon = activeBloons[bloonId]
    if not bloon then return end

    if bloon.model and bloon.model.Parent then
        bloon.model:Destroy()
    end

    activeBloons[bloonId] = nil
end

function BloonManager.getActiveBloons()
    return activeBloons
end

function BloonManager.getBloon(bloonId)
    return activeBloons[bloonId]
end

function BloonManager.getBloonCount()
    local count = 0
    for _ in pairs(activeBloons) do
        count = count + 1
    end
    return count
end

function BloonManager.clearAll()
    for id, bloon in pairs(activeBloons) do
        if bloon.model and bloon.model.Parent then
            bloon.model:Destroy()
        end
    end
    activeBloons = {}
end

-- Get bloons sorted by distance travelled (first = furthest ahead)
function BloonManager.getBloonsSortedByDistance()
    local list = {}
    for id, bloon in pairs(activeBloons) do
        table.insert(list, bloon)
    end
    table.sort(list, function(a, b)
        return a.distanceTravelled > b.distanceTravelled
    end)
    return list
end

return BloonManager
