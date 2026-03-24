-- GameManager.server.lua
-- Main game loop - coordinates all game systems

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Require shared modules
local Config    = require(ReplicatedStorage.Shared.Config)
local TowerData = require(ReplicatedStorage.Shared.TowerData)

-- Require server modules
local BloonManager  = require(script.Parent.BloonManager)
local TowerManager  = require(script.Parent.TowerManager)
local WaveManager   = require(ReplicatedStorage.Shared.WaveData) -- use as data only

-- ============================================================
-- SETUP WORKSPACE FOLDERS
-- ============================================================
local bloonsFolder = Instance.new("Folder")
bloonsFolder.Name = "Bloons"
bloonsFolder.Parent = workspace

local towersFolder = Instance.new("Folder")
towersFolder.Name = "Towers"
towersFolder.Parent = workspace

local projectilesFolder = Instance.new("Folder")
projectilesFolder.Name = "Projectiles"
projectilesFolder.Parent = workspace

-- ============================================================
-- REMOTE EVENTS & FUNCTIONS
-- ============================================================
local remoteFolder = Instance.new("Folder")
remoteFolder.Name = "Remotes"
remoteFolder.Parent = ReplicatedStorage

local function makeRemote(name, isFunction)
    local r
    if isFunction then
        r = Instance.new("RemoteFunction")
    else
        r = Instance.new("RemoteEvent")
    end
    r.Name = name
    r.Parent = remoteFolder
    return r
end

local Remotes = {
    -- Client -> Server
    PlaceTower        = makeRemote("PlaceTower"),
    SellTower         = makeRemote("SellTower"),
    UpgradeTower      = makeRemote("UpgradeTower"),
    SetTargetMode     = makeRemote("SetTargetMode"),
    StartRound        = makeRemote("StartRound"),
    -- Server -> Client
    UpdateGameState   = makeRemote("UpdateGameState"),
    BloonSpawned      = makeRemote("BloonSpawned"),
    BloonPopped       = makeRemote("BloonPopped"),
    TowerPlaced       = makeRemote("TowerPlaced"),
    TowerSold         = makeRemote("TowerSold"),
    TowerUpgraded     = makeRemote("TowerUpgraded"),
    RoundStarted      = makeRemote("RoundStarted"),
    RoundComplete     = makeRemote("RoundComplete"),
    GameOver          = makeRemote("GameOver"),
    Victory           = makeRemote("Victory"),
}

-- ============================================================
-- MAP DEFINITION (Bloons TD5 style single path)
-- ============================================================
-- Waypoints form the bloon path across the map
local MAP_WAYPOINTS = {
    Vector3.new(-60, 0.5, 0),   -- Entry
    Vector3.new(-40, 0.5, 0),
    Vector3.new(-40, 0.5, 30),
    Vector3.new(0,   0.5, 30),
    Vector3.new(0,   0.5, -20),
    Vector3.new(40,  0.5, -20),
    Vector3.new(40,  0.5, 20),
    Vector3.new(60,  0.5, 20),  -- Exit
}

-- ============================================================
-- GAME STATE
-- ============================================================
local gameState = {
    lives = Config.STARTING_LIVES,
    cash = Config.STARTING_CASH,
    round = Config.STARTING_ROUND,
    isGameOver = false,
    isVictory = false,
    roundInProgress = false,
    totalPops = 0,
}

-- Per-player cash (multiplayer support)
local playerCash = {}

-- Wave spawning state
local currentWaveManager = nil
local waveQueue = {}
local waveElapsed = 0
local waveIndex = 1

-- ============================================================
-- BUILD MAP
-- ============================================================
local function buildMap()
    -- Ground plane
    local ground = Instance.new("Part")
    ground.Name = "Ground"
    ground.Size = Vector3.new(150, 1, 100)
    ground.Position = Vector3.new(0, -0.5, 5)
    ground.Anchored = true
    ground.Color = Color3.fromRGB(100, 160, 80)
    ground.Material = Enum.Material.Grass
    ground.Parent = workspace

    -- Build path
    for i = 1, #MAP_WAYPOINTS - 1 do
        local a = MAP_WAYPOINTS[i]
        local b = MAP_WAYPOINTS[i + 1]
        local midpoint = (a + b) / 2
        local length = (b - a).Magnitude
        local direction = (b - a).Unit

        local pathSegment = Instance.new("Part")
        pathSegment.Name = "Path_" .. i
        pathSegment.Size = Vector3.new(
            math.abs(direction.X) > 0.5 and length or Config.PATH_WIDTH,
            0.3,
            math.abs(direction.Z) > 0.5 and length or Config.PATH_WIDTH
        )
        pathSegment.Position = midpoint + Vector3.new(0, 0.15, 0)
        pathSegment.Anchored = true
        pathSegment.Color = Color3.fromRGB(190, 160, 110)
        pathSegment.Material = Enum.Material.SandWet
        pathSegment.CanCollide = false
        pathSegment.Parent = workspace
    end

    -- Entry/Exit markers
    local function makeMarker(pos, label, color)
        local marker = Instance.new("Part")
        marker.Size = Vector3.new(4, 4, 0.5)
        marker.Position = pos
        marker.Anchored = true
        marker.Color = color
        marker.Material = Enum.Material.Neon
        marker.Parent = workspace

        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.Parent = marker

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = label
        text.TextScaled = true
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.Font = Enum.Font.GothamBold
        text.Parent = gui
    end

    makeMarker(MAP_WAYPOINTS[1] + Vector3.new(-2, 2, 0), "START", Color3.fromRGB(50, 200, 50))
    makeMarker(MAP_WAYPOINTS[#MAP_WAYPOINTS] + Vector3.new(2, 2, 0), "END", Color3.fromRGB(200, 50, 50))

    -- Decorative trees (non-placeable areas)
    local treePositions = {
        Vector3.new(-50, 0, -30), Vector3.new(-30, 0, -30), Vector3.new(10, 0, -30),
        Vector3.new(50, 0, -30), Vector3.new(-50, 0, 50),  Vector3.new(20, 0, 50),
    }
    for _, pos in ipairs(treePositions) do
        local trunk = Instance.new("Part")
        trunk.Size = Vector3.new(1.5, 6, 1.5)
        trunk.Position = pos + Vector3.new(0, 3, 0)
        trunk.Anchored = true
        trunk.Color = Color3.fromRGB(100, 70, 40)
        trunk.Material = Enum.Material.Wood
        trunk.CanCollide = false
        trunk.Parent = workspace

        local top = Instance.new("Part")
        top.Shape = Enum.PartType.Ball
        top.Size = Vector3.new(5, 5, 5)
        top.Position = pos + Vector3.new(0, 8, 0)
        top.Anchored = true
        top.Color = Color3.fromRGB(50, 130, 50)
        top.Material = Enum.Material.Grass
        top.CanCollide = false
        top.Parent = workspace
    end

    print("[GameManager] Map built with " .. #MAP_WAYPOINTS .. " waypoints")
end

-- ============================================================
-- WAVE SPAWNING
-- ============================================================
local WaveDataModule = require(ReplicatedStorage.Shared.WaveData)

local activeWaveData = nil
local waveSpawnTimer = 0
local waveGroupIndex = 1
local waveGroupSpawnCount = {}

local function startWaveSpawning(round)
    local roundData
    if round <= #WaveDataModule.Rounds then
        roundData = WaveDataModule.Rounds[round]
    else
        roundData = WaveDataModule.getFreeplayRound(round)
    end

    activeWaveData = roundData
    waveSpawnTimer = 0
    waveGroupIndex = 1
    waveGroupSpawnCount = {}

    for i = 1, #roundData do
        waveGroupSpawnCount[i] = 0
    end

    gameState.roundInProgress = true
    Remotes.RoundStarted:FireAllClients(round)
    print("[GameManager] Round " .. round .. " started!")
end

local function updateWaveSpawning(dt)
    if not activeWaveData then return end
    if not gameState.roundInProgress then return end

    waveSpawnTimer = waveSpawnTimer + dt
    local allGroupsDone = true

    for i, group in ipairs(activeWaveData) do
        local spawnedSoFar = waveGroupSpawnCount[i]
        if spawnedSoFar < group.count then
            allGroupsDone = false
            local groupDelay = group.delay or 0
            local targetCount = math.floor((waveSpawnTimer - groupDelay) / group.interval) + 1
            targetCount = math.max(0, math.min(targetCount, group.count))

            while waveGroupSpawnCount[i] < targetCount do
                local bloonId = BloonManager.spawnBloon(
                    group.type,
                    group.camo or false,
                    group.regen or false
                )
                waveGroupSpawnCount[i] = waveGroupSpawnCount[i] + 1

                Remotes.BloonSpawned:FireAllClients(bloonId, group.type, group.camo, group.regen)
            end
        end
    end

    -- Check if wave spawning is complete and all bloons are gone
    local bloonCount = BloonManager.getBloonCount()
    local allSpawned = allGroupsDone

    if allSpawned and bloonCount == 0 then
        -- Round complete!
        local roundCash = Config.ROUND_CASH.base + (gameState.round * Config.ROUND_CASH.perRound)
        for _, player in ipairs(Players:GetPlayers()) do
            addCash(player, roundCash)
        end

        activeWaveData = nil
        gameState.roundInProgress = false
        local completedRound = gameState.round
        gameState.round = gameState.round + 1

        Remotes.RoundComplete:FireAllClients(completedRound, roundCash)
        print("[GameManager] Round " .. completedRound .. " complete! +" .. roundCash .. " cash")

        -- Check victory (beat round 85)
        if completedRound >= 85 then
            gameState.isVictory = true
            Remotes.Victory:FireAllClients()
            print("[GameManager] VICTORY! All 85 rounds complete!")
        end
    end
end

-- ============================================================
-- CASH MANAGEMENT
-- ============================================================
function addCash(player, amount)
    if not playerCash[player.UserId] then
        playerCash[player.UserId] = Config.STARTING_CASH
    end
    playerCash[player.UserId] = playerCash[player.UserId] + amount
    Remotes.UpdateGameState:FireClient(player, {cash = playerCash[player.UserId]})
end

function spendCash(player, amount)
    if not playerCash[player.UserId] then
        playerCash[player.UserId] = Config.STARTING_CASH
    end
    if playerCash[player.UserId] < amount then
        return false
    end
    playerCash[player.UserId] = playerCash[player.UserId] - amount
    Remotes.UpdateGameState:FireClient(player, {cash = playerCash[player.UserId]})
    return true
end

function getCash(player)
    return playerCash[player.UserId] or Config.STARTING_CASH
end

-- ============================================================
-- LIVES MANAGEMENT
-- ============================================================
local function loseLives(count, bloonType)
    if gameState.isGameOver then return end
    gameState.lives = math.max(0, gameState.lives - count)
    Remotes.UpdateGameState:FireAllClients({lives = gameState.lives})

    if gameState.lives <= 0 then
        gameState.isGameOver = true
        Remotes.GameOver:FireAllClients(gameState.round)
        print("[GameManager] GAME OVER! Survived to round " .. gameState.round)
    end
end

-- ============================================================
-- REMOTE HANDLERS
-- ============================================================
Remotes.PlaceTower.OnServerEvent:Connect(function(player, towerType, position)
    if gameState.isGameOver then return end

    local data = TowerData.getTower(towerType)
    if not data then return end

    if TowerManager.getTowerCount() >= Config.MAX_TOWERS then
        return
    end

    -- Check player cash
    if not spendCash(player, data.cost) then
        return -- Not enough cash
    end

    local towerId, err = TowerManager.placeTower(towerType, position, player.UserId)
    if not towerId then
        addCash(player, data.cost) -- Refund
        warn("[GameManager] Tower placement failed: " .. tostring(err))
        return
    end

    Remotes.TowerPlaced:FireAllClients(towerId, towerType, position, player.UserId)
    print("[GameManager] " .. player.Name .. " placed " .. towerType .. " (id=" .. towerId .. ")")
end)

Remotes.SellTower.OnServerEvent:Connect(function(player, towerId)
    local tower = TowerManager.getTower(towerId)
    if not tower then return end
    if tower.playerId ~= player.UserId then return end

    local refund = TowerManager.sellTower(towerId)
    addCash(player, refund)

    Remotes.TowerSold:FireAllClients(towerId, refund)
    print("[GameManager] " .. player.Name .. " sold tower " .. towerId .. " for " .. refund)
end)

Remotes.UpgradeTower.OnServerEvent:Connect(function(player, towerId, path)
    local tower = TowerManager.getTower(towerId)
    if not tower then return end
    if tower.playerId ~= player.UserId then return end

    local cost = TowerData.getUpgradeCost(tower.type, path, tower.upgrades[path] + 1)
    if cost <= 0 then return end

    if not spendCash(player, cost) then return end

    local success, result = TowerManager.upgradeTower(towerId, path)
    if not success then
        addCash(player, cost) -- Refund
        return
    end

    Remotes.TowerUpgraded:FireAllClients(towerId, path, tower.upgrades[path])
    print("[GameManager] " .. player.Name .. " upgraded tower " .. towerId .. " path" .. path)
end)

Remotes.SetTargetMode.OnServerEvent:Connect(function(player, towerId, mode)
    local tower = TowerManager.getTower(towerId)
    if not tower then return end
    if tower.playerId ~= player.UserId then return end
    TowerManager.setTargetMode(towerId, mode)
end)

Remotes.StartRound.OnServerEvent:Connect(function(player)
    if gameState.isGameOver then return end
    if gameState.isVictory then return end
    if gameState.roundInProgress then return end
    startWaveSpawning(gameState.round)
end)

-- ============================================================
-- PLAYER JOINS
-- ============================================================
Players.PlayerAdded:Connect(function(player)
    playerCash[player.UserId] = Config.STARTING_CASH

    -- Send current game state to new player
    task.wait(1) -- Wait for client to load
    Remotes.UpdateGameState:FireClient(player, {
        cash = playerCash[player.UserId],
        lives = gameState.lives,
        round = gameState.round,
        roundInProgress = gameState.roundInProgress,
    })
    print("[GameManager] " .. player.Name .. " joined. Cash: " .. playerCash[player.UserId])
end)

Players.PlayerRemoving:Connect(function(player)
    playerCash[player.UserId] = nil
end)

-- ============================================================
-- MAIN GAME LOOP
-- ============================================================
local function initialize()
    print("[GameManager] Initializing Bloons TD5...")

    -- Initialize managers
    BloonManager.init(MAP_WAYPOINTS)
    TowerManager.init()

    -- Build map
    buildMap()

    print("[GameManager] Game ready! Starting Round: " .. Config.STARTING_ROUND)
end

local lastTick = tick()
local gameLoopActive = true

RunService.Heartbeat:Connect(function()
    if not gameLoopActive then return end
    if gameState.isGameOver then return end

    local now = tick()
    local dt = math.min(now - lastTick, 0.1) -- Cap dt to prevent huge jumps
    lastTick = now

    -- Update bloon movement
    local bloonsAtEnd = BloonManager.update(dt)

    -- Handle bloons that reached the end
    for _, bloon in ipairs(bloonsAtEnd) do
        local livesLost = Config.RBE[bloon.type] or 1
        loseLives(livesLost)
    end

    -- Update wave spawning
    updateWaveSpawning(dt)

    -- Update towers (attack bloons)
    TowerManager.update(dt, BloonManager)
end)

-- Start initialization
initialize()
