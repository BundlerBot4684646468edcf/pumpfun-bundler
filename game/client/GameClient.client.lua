-- GameClient.client.lua
-- Client-side game controller: connects UI, remotes, and tower placement

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Wait for remotes to be set up by server
local remoteFolder = ReplicatedStorage:WaitForChild("Remotes", 30)
if not remoteFolder then
    error("[GameClient] Remotes folder not found!")
end

local Remotes = {
    PlaceTower        = remoteFolder:WaitForChild("PlaceTower"),
    SellTower         = remoteFolder:WaitForChild("SellTower"),
    UpgradeTower      = remoteFolder:WaitForChild("UpgradeTower"),
    SetTargetMode     = remoteFolder:WaitForChild("SetTargetMode"),
    StartRound        = remoteFolder:WaitForChild("StartRound"),
    UpdateGameState   = remoteFolder:WaitForChild("UpdateGameState"),
    BloonSpawned      = remoteFolder:WaitForChild("BloonSpawned"),
    BloonPopped       = remoteFolder:WaitForChild("BloonPopped"),
    TowerPlaced       = remoteFolder:WaitForChild("TowerPlaced"),
    TowerSold         = remoteFolder:WaitForChild("TowerSold"),
    TowerUpgraded     = remoteFolder:WaitForChild("TowerUpgraded"),
    RoundStarted      = remoteFolder:WaitForChild("RoundStarted"),
    RoundComplete     = remoteFolder:WaitForChild("RoundComplete"),
    GameOver          = remoteFolder:WaitForChild("GameOver"),
    Victory           = remoteFolder:WaitForChild("Victory"),
}

-- Load shared modules
local TowerData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("TowerData"))
local Config    = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

-- Load client modules (these are local scripts in StarterPlayerScripts)
local UIManager   = require(script.Parent:WaitForChild("UIManager"))
local TowerPlacer = require(script.Parent:WaitForChild("TowerPlacer"))

local player = Players.LocalPlayer

-- ============================================================
-- CLIENT STATE
-- ============================================================
local clientState = {
    cash = Config.STARTING_CASH,
    lives = Config.STARTING_LIVES,
    round = 1,
    roundInProgress = false,
    selectedTowerId = nil,
    towers = {},  -- towerId -> {type, upgrades, totalCost, position}
    isFastForward = false,
}

-- ============================================================
-- TOWER SELECTION (clicking on placed towers)
-- ============================================================
local function onTowerClicked(towerId)
    local tower = clientState.towers[towerId]
    if not tower then return end

    clientState.selectedTowerId = towerId
    UIManager.showUpgradePanel(
        towerId,
        tower.type,
        tower.upgrades,
        tower.totalCost
    )
end

-- Detect clicks on tower models
local mouse = player:GetMouse()
local function setupTowerClickDetection()
    mouse.Button1Down:Connect(function()
        if TowerPlacer.isPlacing() then return end

        local target = mouse.Target
        if not target then
            UIManager.hideUpgradePanel()
            clientState.selectedTowerId = nil
            return
        end

        -- Check if we clicked on a tower
        local model = target:FindFirstAncestorOfClass("Model")
        if model and model.Parent == workspace.Towers then
            local towerIdPart = model.Name:match("Tower_(%d+)")
            if towerIdPart then
                local towerId = tonumber(towerIdPart)
                onTowerClicked(towerId)
                return
            end
        end

        -- Clicked elsewhere, deselect
        UIManager.hideUpgradePanel()
        clientState.selectedTowerId = nil
    end)
end

-- ============================================================
-- UI CALLBACKS
-- ============================================================
UIManager.onTowerSelect = function(towerType)
    local data = TowerData.getTower(towerType)
    if not data then return end

    if clientState.cash < data.cost then
        -- Flash the cash display
        return
    end

    if TowerPlacer.isPlacing() then
        TowerPlacer.stopPlacing()
    end

    TowerPlacer.startPlacing(towerType, function(tType, position)
        -- Send placement to server
        Remotes.PlaceTower:FireServer(tType, position)
        -- Stop placing (one tower at a time)
        TowerPlacer.stopPlacing()
    end)
end

UIManager.onStartRound = function()
    if clientState.roundInProgress then return end
    Remotes.StartRound:FireServer()
end

UIManager.onSellTower = function(towerId)
    Remotes.SellTower:FireServer(towerId)
    clientState.towers[towerId] = nil
    UIManager.hideUpgradePanel()
end

UIManager.onUpgradeTower = function(towerId, path, level)
    local tower = clientState.towers[towerId]
    if not tower then return end

    local cost = TowerData.getUpgradeCost(tower.type, path, (tower.upgrades[path] or 0) + 1)
    if clientState.cash < cost then return end

    Remotes.UpgradeTower:FireServer(towerId, path)
end

UIManager.onSetTargetMode = function(towerId, mode)
    Remotes.SetTargetMode:FireServer(towerId, mode)
end

UIManager.onFastForward = function(enabled)
    clientState.isFastForward = enabled
    -- Fast forward is cosmetic on client (server controls actual speed)
    -- In a real implementation, this would send to server to change game speed
end

-- ============================================================
-- REMOTE EVENT HANDLERS
-- ============================================================
Remotes.UpdateGameState.OnClientEvent:Connect(function(state)
    if state.cash ~= nil then
        clientState.cash = state.cash
        UIManager.updateCash(state.cash)
    end
    if state.lives ~= nil then
        clientState.lives = state.lives
        UIManager.updateLives(state.lives)
    end
    if state.round ~= nil then
        clientState.round = state.round
        UIManager.updateRound(state.round, state.roundInProgress or false)
    end
end)

Remotes.TowerPlaced.OnClientEvent:Connect(function(towerId, towerType, position, ownerId)
    -- Track tower client-side
    local data = TowerData.getTower(towerType)
    clientState.towers[towerId] = {
        id = towerId,
        type = towerType,
        position = position,
        upgrades = {0, 0},
        totalCost = data and data.cost or 0,
        ownerId = ownerId,
    }
end)

Remotes.TowerSold.OnClientEvent:Connect(function(towerId, refund)
    clientState.towers[towerId] = nil
    if clientState.selectedTowerId == towerId then
        UIManager.hideUpgradePanel()
        clientState.selectedTowerId = nil
    end
end)

Remotes.TowerUpgraded.OnClientEvent:Connect(function(towerId, path, newLevel)
    local tower = clientState.towers[towerId]
    if tower then
        tower.upgrades[path] = newLevel

        -- Recalculate total cost
        local data = TowerData.getTower(tower.type)
        if data then
            local upgradePath = path == 1 and data.path1 or data.path2
            if upgradePath and upgradePath[newLevel] then
                tower.totalCost = tower.totalCost + upgradePath[newLevel].cost
            end
        end

        -- Refresh upgrade panel if this tower is selected
        if clientState.selectedTowerId == towerId then
            UIManager.showUpgradePanel(towerId, tower.type, tower.upgrades, tower.totalCost)
        end
    end
end)

Remotes.RoundStarted.OnClientEvent:Connect(function(round)
    clientState.round = round
    clientState.roundInProgress = true
    UIManager.updateRound(round, true)
    UIManager.showRoundNotification(round, "Round " .. round .. " - Begin!")
end)

Remotes.RoundComplete.OnClientEvent:Connect(function(completedRound, cashBonus)
    clientState.roundInProgress = false
    UIManager.updateRound(completedRound + 1, false)
    UIManager.showRoundNotification(
        completedRound,
        "Round " .. completedRound .. " Complete! +$" .. cashBonus
    )
end)

Remotes.GameOver.OnClientEvent:Connect(function(round)
    UIManager.showGameOver(round)
end)

Remotes.Victory.OnClientEvent:Connect(function()
    UIManager.showVictory()
end)

-- ============================================================
-- KEYBOARD SHORTCUTS
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- ESC to cancel tower placement
    if input.KeyCode == Enum.KeyCode.Escape then
        if TowerPlacer.isPlacing() then
            TowerPlacer.stopPlacing()
        elseif clientState.selectedTowerId then
            UIManager.hideUpgradePanel()
            clientState.selectedTowerId = nil
        end
    end

    -- SPACE to start round
    if input.KeyCode == Enum.KeyCode.Space then
        if not clientState.roundInProgress then
            Remotes.StartRound:FireServer()
        end
    end
end)

-- ============================================================
-- INIT
-- ============================================================
setupTowerClickDetection()
print("[GameClient] Bloons TD5 client initialized!")
