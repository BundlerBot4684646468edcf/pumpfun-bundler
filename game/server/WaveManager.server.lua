-- WaveManager.server.lua
-- Controls wave spawning and round progression

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WaveData = require(ReplicatedStorage.Shared.WaveData)
local Config = require(ReplicatedStorage.Shared.Config)

local WaveManager = {}
WaveManager.__index = WaveManager

function WaveManager.new()
    local self = setmetatable({}, WaveManager)
    self.currentRound = Config.STARTING_ROUND
    self.isRunning = false
    self.isComplete = false
    self.spawnQueue = {}   -- {type, camo, regen, delay}
    self.spawnTimer = 0
    self.autoStart = false
    self.betweenRounds = true
    return self
end

function WaveManager:getRoundData(round)
    if round <= #WaveData.Rounds then
        return WaveData.Rounds[round]
    else
        return WaveData.getFreeplayRound(round)
    end
end

function WaveManager:startRound()
    if self.isRunning then return false, "Round already running" end
    if self.currentRound > 85 and not self.autoStart then
        -- Freeplay confirmation needed
    end

    self.betweenRounds = false
    self.isRunning = true
    self.isComplete = false
    self.spawnQueue = {}
    self.spawnTimer = 0

    local roundData = self:getRoundData(self.currentRound)
    self:buildSpawnQueue(roundData)

    return true
end

function WaveManager:buildSpawnQueue(roundData)
    -- Build a time-sorted list of bloon spawns
    local events = {}

    for _, group in ipairs(roundData) do
        local baseDelay = group.delay or 0
        for i = 1, group.count do
            local spawnTime = baseDelay + (i - 1) * group.interval
            table.insert(events, {
                time = spawnTime,
                bloonType = group.type,
                camo = group.camo or false,
                regen = group.regen or false,
            })
        end
    end

    -- Sort by spawn time
    table.sort(events, function(a, b) return a.time < b.time end)

    self.spawnQueue = events
    self.queueIndex = 1
    self.roundStartTime = 0
    self.roundElapsed = 0
end

-- Returns a list of bloons to spawn this tick
function WaveManager:update(dt)
    if not self.isRunning then return {} end

    self.roundElapsed = self.roundElapsed + dt
    local toSpawn = {}

    while self.queueIndex <= #self.spawnQueue do
        local event = self.spawnQueue[self.queueIndex]
        if self.roundElapsed >= event.time then
            table.insert(toSpawn, {
                bloonType = event.bloonType,
                camo = event.camo,
                regen = event.regen,
            })
            self.queueIndex = self.queueIndex + 1
        else
            break
        end
    end

    return toSpawn
end

-- Call this when the last bloon of the round is defeated
function WaveManager:checkRoundComplete(activeBloonCount)
    if not self.isRunning then return false end
    if self.queueIndex <= #self.spawnQueue then return false end
    if activeBloonCount > 0 then return false end

    self.isRunning = false
    self.betweenRounds = true
    self.isComplete = true
    local completedRound = self.currentRound
    self.currentRound = self.currentRound + 1

    return true, completedRound
end

function WaveManager:getCurrentRound()
    return self.currentRound
end

function WaveManager:isInProgress()
    return self.isRunning
end

function WaveManager:isBetweenRounds()
    return self.betweenRounds
end

function WaveManager:getRoundCashBonus(round)
    return Config.ROUND_CASH.base + (round * Config.ROUND_CASH.perRound)
end

function WaveManager:setAutoStart(enabled)
    self.autoStart = enabled
end

return WaveManager
