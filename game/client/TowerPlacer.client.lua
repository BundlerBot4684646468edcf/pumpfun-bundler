-- TowerPlacer.client.lua
-- Handles tower placement preview and mouse interaction

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TowerData = require(ReplicatedStorage.Shared.TowerData)

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local TowerPlacer = {}

local placingTowerType = nil
local previewModel = nil
local isValidPlacement = false
local placementCallback = nil

-- Colors for valid/invalid placement
local VALID_COLOR = Color3.fromRGB(50, 200, 50)
local INVALID_COLOR = Color3.fromRGB(200, 50, 50)

-- Zones where towers cannot be placed (path, water, etc.)
-- These are approximate based on the map layout
local NO_PLACE_ZONES = {
    -- Path segments (rough rectangles)
    {min = Vector3.new(-65, -5, -3), max = Vector3.new(0, 5, 3)},     -- horizontal top
    {min = Vector3.new(-43, -5, -2), max = Vector3.new(-37, 5, 33)},  -- first vertical
    {min = Vector3.new(-43, -5, 27), max = Vector3.new(3, 5, 33)},    -- horizontal mid
    {min = Vector3.new(-3, -5, -23), max = Vector3.new(3, 5, 33)},    -- second vertical
    {min = Vector3.new(-3, -5, -23), max = Vector3.new(43, 5, -17)},  -- horizontal bottom
    {min = Vector3.new(37, -5, -23), max = Vector3.new(43, 5, 23)},   -- third vertical
    {min = Vector3.new(37, -5, 17), max = Vector3.new(65, 5, 23)},    -- exit horizontal
}

local function isOnPath(position)
    for _, zone in ipairs(NO_PLACE_ZONES) do
        if position.X >= zone.min.X and position.X <= zone.max.X and
           position.Z >= zone.min.Z and position.Z <= zone.max.Z then
            return true
        end
    end
    return false
end

local function isOverlappingTower(position, size)
    for _, obj in ipairs(workspace.Towers:GetChildren()) do
        if obj:IsA("Model") then
            local base = obj:FindFirstChild("Base")
            if base then
                local dist = (base.Position - position).Magnitude
                if dist < size + 2 then
                    return true
                end
            end
        end
    end
    return false
end

local function getGroundPosition()
    local unitRay = camera:ViewportPointToRay(mouse.X, mouse.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    if previewModel then
        raycastParams.FilterDescendantsInstances = {previewModel}
    end

    local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, raycastParams)
    if result then
        local pos = result.Position
        -- Snap to grid
        pos = Vector3.new(
            math.round(pos.X / 4) * 4,
            0.5,
            math.round(pos.Z / 4) * 4
        )
        return pos
    end
    return nil
end

local function createPreview(towerType)
    local data = TowerData.getTower(towerType)
    if not data then return end

    if previewModel then
        previewModel:Destroy()
    end

    previewModel = Instance.new("Model")
    previewModel.Name = "PlacementPreview"

    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(data.size, 1, data.size)
    base.Anchored = true
    base.CanCollide = false
    base.Color = VALID_COLOR
    base.Transparency = 0.5
    base.Material = Enum.Material.Neon
    base.Parent = previewModel

    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(data.size * 0.7, data.size, data.size * 0.7)
    body.Anchored = true
    body.CanCollide = false
    body.Color = VALID_COLOR
    body.Transparency = 0.5
    body.Material = Enum.Material.Neon
    body.Parent = previewModel

    -- Range circle preview
    local rangeCircle = Instance.new("Part")
    rangeCircle.Name = "RangeCircle"
    rangeCircle.Shape = Enum.PartType.Cylinder
    rangeCircle.Size = Vector3.new(0.1, (data.range or 18) * 2, (data.range or 18) * 2)
    rangeCircle.Orientation = Vector3.new(0, 0, 90)
    rangeCircle.Anchored = true
    rangeCircle.CanCollide = false
    rangeCircle.Transparency = 0.8
    rangeCircle.Color = Color3.fromRGB(255, 255, 100)
    rangeCircle.Material = Enum.Material.Neon
    rangeCircle.Parent = previewModel

    previewModel.Parent = workspace
end

function TowerPlacer.startPlacing(towerType, callback)
    placingTowerType = towerType
    placementCallback = callback
    createPreview(towerType)
    mouse.TargetFilter = previewModel
end

function TowerPlacer.stopPlacing()
    placingTowerType = nil
    placementCallback = nil
    if previewModel then
        previewModel:Destroy()
        previewModel = nil
    end
    isValidPlacement = false
end

function TowerPlacer.isPlacing()
    return placingTowerType ~= nil
end

-- Update preview position every frame
RunService.RenderStepped:Connect(function()
    if not placingTowerType or not previewModel then return end

    local pos = getGroundPosition()
    if not pos then return end

    local data = TowerData.getTower(placingTowerType)
    local size = data and data.size or 2

    -- Validate placement
    local onPath = isOnPath(pos)
    local overlapping = isOverlappingTower(pos, size)
    isValidPlacement = not onPath and not overlapping

    -- Update preview color
    local color = isValidPlacement and VALID_COLOR or INVALID_COLOR
    for _, part in ipairs(previewModel:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "RangeCircle" then
            part.Color = color
        end
    end

    -- Update positions
    local base = previewModel:FindFirstChild("Base")
    local body = previewModel:FindFirstChild("Body")
    local rangeCircle = previewModel:FindFirstChild("RangeCircle")

    if base then base.Position = pos end
    if body then body.Position = pos + Vector3.new(0, size / 2, 0) end
    if rangeCircle then rangeCircle.Position = pos + Vector3.new(0, 0.2, 0) end
end)

-- Handle clicks for placement
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if placingTowerType and isValidPlacement then
            local pos = getGroundPosition()
            if pos and placementCallback then
                placementCallback(placingTowerType, pos)
            end
        end
    elseif input.KeyCode == Enum.KeyCode.Escape then
        if TowerPlacer.isPlacing() then
            TowerPlacer.stopPlacing()
        end
    end
end)

return TowerPlacer
