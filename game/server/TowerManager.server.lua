-- TowerManager.server.lua
-- Handles tower placement, targeting, attacking, and upgrades

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TowerData = require(ReplicatedStorage.Shared.TowerData)
local BloonData = require(ReplicatedStorage.Shared.BloonData)
local Config = require(ReplicatedStorage.Shared.Config)

local TowerManager = {}
TowerManager.__index = TowerManager

local activeTowers = {}
local towerIdCounter = 0

-- Tower targeting modes
TowerManager.TargetMode = {
    FIRST  = "First",  -- furthest along path
    LAST   = "Last",   -- least progress
    STRONG = "Strong", -- highest RBE
    CLOSE  = "Close",  -- closest to tower
}

function TowerManager.init()
    activeTowers = {}
    towerIdCounter = 0
end

function TowerManager.placeTower(towerType, position, playerId)
    local data = TowerData.getTower(towerType)
    if not data then
        return nil, "Unknown tower type"
    end

    towerIdCounter = towerIdCounter + 1
    local id = towerIdCounter

    -- Create tower model
    local model = Instance.new("Model")
    model.Name = "Tower_" .. id

    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(data.size, 1, data.size)
    base.Position = position
    base.Anchored = true
    base.CanCollide = true
    base.Color = Color3.fromRGB(100, 180, 100)
    base.Material = Enum.Material.SmoothPlastic
    base.Parent = model

    -- Tower body
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(data.size * 0.7, data.size, data.size * 0.7)
    body.Position = position + Vector3.new(0, data.size / 2, 0)
    body.Anchored = true
    body.CanCollide = false
    body.Color = Color3.fromRGB(60, 140, 60)
    body.Material = Enum.Material.SmoothPlastic
    body.Parent = model

    -- Range indicator (invisible normally, shown on selection)
    local rangeIndicator = Instance.new("Part")
    rangeIndicator.Name = "RangeIndicator"
    rangeIndicator.Shape = Enum.PartType.Cylinder
    rangeIndicator.Size = Vector3.new(0.1, data.range * 2, data.range * 2)
    rangeIndicator.Position = position + Vector3.new(0, 0.1, 0)
    rangeIndicator.Orientation = Vector3.new(0, 0, 90)
    rangeIndicator.Anchored = true
    rangeIndicator.CanCollide = false
    rangeIndicator.Transparency = 1.0
    rangeIndicator.Color = Color3.fromRGB(255, 255, 100)
    rangeIndicator.Material = Enum.Material.Neon
    rangeIndicator.Parent = model

    -- Tower type tag
    local typeTag = Instance.new("StringValue")
    typeTag.Name = "TowerType"
    typeTag.Value = towerType
    typeTag.Parent = model

    local ownerTag = Instance.new("NumberValue")
    ownerTag.Name = "OwnerId"
    ownerTag.Value = playerId or 0
    ownerTag.Parent = model

    model.PrimaryPart = base
    model.Parent = workspace.Towers

    local tower = {
        id = id,
        type = towerType,
        data = data,
        position = position,
        playerId = playerId,
        model = model,
        range = data.range,
        attackSpeed = data.attackSpeed,
        damage = data.damage,
        pierce = data.pierce,
        damageType = data.damageType,
        projectileSpeed = data.projectileSpeed or 80,
        attackCooldown = 0,
        targetMode = TowerManager.TargetMode.FIRST,
        upgrades = {0, 0}, -- [path1Level, path2Level]
        totalCost = data.cost,
        detectsCamo = data.detectsCamo or false,
        -- Special properties
        explosionRadius = data.explosionRadius or 0,
        freezeDuration = data.freezeDuration or 0,
        slowFactor = data.slowFactor or 1.0,
        glueDuration = data.glueDuration or 0,
        burstCount = data.burstCount or 1,
        support = data.support or false,
        isActive = true,
    }

    activeTowers[id] = tower
    return id, nil
end

function TowerManager.update(dt, bloonManager)
    for id, tower in pairs(activeTowers) do
        if tower.support then continue end
        if not tower.isActive then continue end

        tower.attackCooldown = tower.attackCooldown - dt

        if tower.attackCooldown <= 0 then
            local target = TowerManager.findTarget(tower, bloonManager)
            if target then
                TowerManager.attack(tower, target, bloonManager)
                tower.attackCooldown = 1.0 / tower.attackSpeed
            end
        end
    end
end

function TowerManager.findTarget(tower, bloonManager)
    local bloons = bloonManager.getBloonsSortedByDistance()
    local bestBloon = nil
    local bestValue = nil

    for _, bloon in ipairs(bloons) do
        -- Check camo detection
        if bloon.isCamo and not tower.detectsCamo then
            continue
        end

        -- Skip frozen bloons for certain towers
        if bloon.isFrozen and tower.damageType == "Freeze" then
            continue
        end

        -- Check range
        local dist = (bloon.position - tower.position).Magnitude
        if dist > tower.range then
            continue
        end

        -- Target selection logic
        if tower.targetMode == TowerManager.TargetMode.FIRST then
            if bestValue == nil or bloon.distanceTravelled > bestValue then
                bestValue = bloon.distanceTravelled
                bestBloon = bloon
            end
        elseif tower.targetMode == TowerManager.TargetMode.LAST then
            if bestValue == nil or bloon.distanceTravelled < bestValue then
                bestValue = bloon.distanceTravelled
                bestBloon = bloon
            end
        elseif tower.targetMode == TowerManager.TargetMode.STRONG then
            local rbe = Config.RBE[bloon.type] or 1
            if bestValue == nil or rbe > bestValue then
                bestValue = rbe
                bestBloon = bloon
            end
        elseif tower.targetMode == TowerManager.TargetMode.CLOSE then
            local d = (bloon.position - tower.position).Magnitude
            if bestValue == nil or d < bestValue then
                bestValue = d
                bestBloon = bloon
            end
        end
    end

    return bestBloon
end

function TowerManager.attack(tower, target, bloonManager)
    local totalCashEarned = 0

    if tower.damageType == "Freeze" then
        -- Ice tower: freeze all bloons in range
        for id, bloon in pairs(bloonManager.getActiveBloons()) do
            local dist = (bloon.position - tower.position).Magnitude
            if dist <= tower.range then
                bloonManager.freezeBloon(id, tower.freezeDuration)
            end
        end
        TowerManager._playAttackEffect(tower, target.position)
        return 0
    end

    if tower.damageType == "Glue" then
        -- Glue gunner
        local pierceLeft = tower.pierce
        local bloonsSorted = bloonManager.getBloonsSortedByDistance()
        for _, bloon in ipairs(bloonsSorted) do
            if pierceLeft <= 0 then break end
            local dist = (bloon.position - tower.position).Magnitude
            if dist <= tower.range then
                bloonManager.glueBloon(bloon.id, tower.glueDuration, tower.slowFactor)
                pierceLeft = pierceLeft - 1
            end
        end
        TowerManager._playAttackEffect(tower, target.position)
        return 0
    end

    -- Standard projectile attack
    -- Fire projectiles (burstCount determines how many)
    local projectilesFired = tower.burstCount or 1
    local piercePerProjectile = tower.pierce

    -- Build list of bloons to hit based on targeting
    local bloonsSorted = bloonManager.getBloonsSortedByDistance()

    for proj = 1, projectilesFired do
        local pierceLeft = piercePerProjectile
        local hitBloons = {}

        -- Find bloons this projectile can hit
        if tower.explosionRadius > 0 then
            -- Explosive: target one bloon, then splash
            local targetDist = (target.position - tower.position).Magnitude
            if targetDist <= tower.range then
                for _, bloon in ipairs(bloonsSorted) do
                    local splashDist = (bloon.position - target.position).Magnitude
                    if splashDist <= tower.explosionRadius then
                        table.insert(hitBloons, bloon)
                    end
                    if #hitBloons >= pierceLeft then break end
                end
            end
        else
            -- Linear: hit first N bloons in range along path
            for _, bloon in ipairs(bloonsSorted) do
                if pierceLeft <= 0 then break end
                local dist = (bloon.position - tower.position).Magnitude
                if dist <= tower.range then
                    if not (bloon.isCamo and not tower.detectsCamo) then
                        table.insert(hitBloons, bloon)
                        pierceLeft = pierceLeft - 1
                    end
                end
            end
        end

        -- Deal damage
        for _, bloon in ipairs(hitBloons) do
            if bloonManager.getBloon(bloon.id) then
                local dmgDealt, children = bloonManager.damageBloon(
                    bloon.id, tower.damage, tower.damageType, tower.id
                )
                totalCashEarned = totalCashEarned + dmgDealt * (Config.POP_CASH[bloon.type] or 1)
            end
        end
    end

    TowerManager._playAttackEffect(tower, target.position)
    return totalCashEarned
end

function TowerManager._playAttackEffect(tower, targetPos)
    -- Create a brief visual line from tower to target
    local attachment0 = Instance.new("Attachment")
    attachment0.WorldPosition = tower.position + Vector3.new(0, tower.data.size, 0)

    local attachment1 = Instance.new("Attachment")
    attachment1.WorldPosition = targetPos

    local beam = Instance.new("Beam")
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.Width0 = 0.1
    beam.Width1 = 0.1
    beam.Transparency = NumberSequence.new(0, 0)
    beam.LightEmission = 1

    -- Color based on damage type
    local color = Color3.fromRGB(255, 255, 0)
    if tower.damageType == "Explosion" then color = Color3.fromRGB(255, 150, 0)
    elseif tower.damageType == "Freeze" then color = Color3.fromRGB(150, 200, 255)
    elseif tower.damageType == "Energy" then color = Color3.fromRGB(255, 50, 255)
    elseif tower.damageType == "Glue" then color = Color3.fromRGB(150, 255, 100)
    end

    beam.Color = ColorSequence.new(color)
    attachment0.Parent = workspace.Terrain
    attachment1.Parent = workspace.Terrain
    beam.Parent = workspace.Terrain

    -- Remove after brief flash
    task.delay(0.05, function()
        beam:Destroy()
        attachment0:Destroy()
        attachment1:Destroy()
    end)
end

function TowerManager.upgradeTower(towerId, path)
    local tower = activeTowers[towerId]
    if not tower then return false, "Tower not found" end

    local pathIndex = path
    local currentLevel = tower.upgrades[pathIndex]

    if currentLevel >= 4 then
        return false, "Already at max upgrade level"
    end

    -- Can't have both paths at 4 (BTD5 rule: max 4/2 or 2/4)
    local otherPath = pathIndex == 1 and 2 or 1
    if currentLevel >= 2 and tower.upgrades[otherPath] >= 4 then
        return false, "Cannot upgrade: other path is at max"
    end
    if tower.upgrades[otherPath] >= 3 and currentLevel >= 3 then
        return false, "Cannot have 3+ upgrades on both paths"
    end

    local cost = TowerData.getUpgradeCost(tower.type, pathIndex, currentLevel + 1)
    if cost <= 0 then
        return false, "Invalid upgrade"
    end

    -- Apply upgrade effects
    tower.upgrades[pathIndex] = currentLevel + 1
    tower.totalCost = tower.totalCost + cost
    TowerManager._applyUpgrade(tower, pathIndex, currentLevel + 1)

    return true, cost
end

function TowerManager._applyUpgrade(tower, path, level)
    local towerDef = TowerData.Towers[tower.type]
    if not towerDef then return end

    -- Generic upgrades by tower type and path
    -- This implements the stat changes for each upgrade
    local upgradeDef = path == 1 and towerDef.path1[level] or towerDef.path2[level]

    -- Apply common improvements based on upgrade name patterns
    local name = upgradeDef and upgradeDef.name or ""

    -- Speed upgrades
    if name:find("Faster") or name:find("Quick") or name:find("Rapid") then
        tower.attackSpeed = tower.attackSpeed * 1.4
    end

    -- Range upgrades
    if name:find("Range") or name:find("Long") or name:find("Extended") then
        tower.range = tower.range + 5
    end

    -- Damage upgrades
    if name:find("Heavy") or name:find("Deadly") or name:find("Point Five") then
        tower.damage = tower.damage + 5
    end

    -- MOAB damage
    if name:find("MOAB Mauler") then
        tower.moabBonus = (tower.moabBonus or 0) + 10
    end

    -- Camo detection
    if name:find("Night Vision") or name:find("Camo") or name:find("Eye Sight") or name:find("Spy") then
        tower.detectsCamo = true
    end

    -- Lead popping
    if name:find("Full Metal") or name:find("Red Hot") or name:find("Hot Shot") or name:find("White Hot") then
        -- Remove Sharp immunity: tower now uses Normal for lead
        if tower.damageType == "Sharp" then
            tower.canPopLead = true
        end
    end

    -- Burst count increases
    if name:find("Triple") or name:find("Double Shot") then
        tower.burstCount = (tower.burstCount or 1) + 2
    end

    -- Pierce increases
    if name:find("Bigger") or name:find("Extra Pierce") or name:find("Sharp Shurikens") then
        tower.pierce = tower.pierce + 3
    end

    -- Energy upgrade
    if name:find("Laser") then
        tower.damageType = "Energy"
    end
    if name:find("Plasma") then
        tower.damageType = "Energy"
        tower.damage = tower.damage + 2
        tower.pierce = tower.pierce + 1
    end

    -- Tier 4 power spikes
    if level == 4 then
        tower.attackSpeed = tower.attackSpeed * 1.5
        tower.damage = tower.damage + 3
        tower.pierce = tower.pierce + 5
    end

    -- Update range indicator
    if tower.model then
        local ri = tower.model:FindFirstChild("RangeIndicator")
        if ri then
            ri.Size = Vector3.new(0.1, tower.range * 2, tower.range * 2)
        end
    end
end

function TowerManager.sellTower(towerId)
    local tower = activeTowers[towerId]
    if not tower then return 0 end

    local refund = math.floor(tower.totalCost * Config.SELL_REFUND_RATE)

    if tower.model and tower.model.Parent then
        tower.model:Destroy()
    end

    activeTowers[towerId] = nil
    return refund
end

function TowerManager.setTargetMode(towerId, mode)
    local tower = activeTowers[towerId]
    if not tower then return false end
    tower.targetMode = mode
    return true
end

function TowerManager.getTower(towerId)
    return activeTowers[towerId]
end

function TowerManager.getActiveTowers()
    return activeTowers
end

function TowerManager.getTowerCount()
    local count = 0
    for _ in pairs(activeTowers) do count = count + 1 end
    return count
end

function TowerManager.clearAll()
    for id, tower in pairs(activeTowers) do
        if tower.model and tower.model.Parent then
            tower.model:Destroy()
        end
    end
    activeTowers = {}
end

-- Get village buffs for a tower position
function TowerManager.getVillageBuffs(position)
    local speedMult = 1.0
    local cashMult = 1.0

    for id, tower in pairs(activeTowers) do
        if tower.type == "MonkeyVillage" then
            local dist = (tower.position - position).Magnitude
            if dist <= tower.range then
                -- Jungle Drums buff
                if tower.upgrades[1] >= 2 then
                    speedMult = speedMult * 1.15
                end
                -- Monkey Town cash buff
                if tower.upgrades[2] >= 3 then
                    cashMult = cashMult * 2.0
                end
                if tower.upgrades[2] >= 4 then
                    cashMult = cashMult * 3.0
                end
            end
        end
    end

    return speedMult, cashMult
end

return TowerManager
