-- UIManager.client.lua
-- Manages all game UI: HUD, tower selection, upgrades, etc.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local TowerData = require(ReplicatedStorage.Shared.TowerData)
local Config = require(ReplicatedStorage.Shared.Config)

local player = Players.LocalPlayer
local playerGui = player.PlayerGui

local UIManager = {}

-- ============================================================
-- MAIN SCREEN GUI
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BloonsTD5"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- ============================================================
-- HUD (top bar)
-- ============================================================
local hudFrame = Instance.new("Frame")
hudFrame.Name = "HUD"
hudFrame.Size = UDim2.new(1, 0, 0, 60)
hudFrame.Position = UDim2.new(0, 0, 0, 0)
hudFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
hudFrame.BackgroundTransparency = 0.2
hudFrame.BorderSizePixel = 0
hudFrame.Parent = screenGui

-- Lives display
local livesFrame = Instance.new("Frame")
livesFrame.Size = UDim2.new(0, 150, 1, -10)
livesFrame.Position = UDim2.new(0, 10, 0, 5)
livesFrame.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
livesFrame.BackgroundTransparency = 0.3
livesFrame.BorderSizePixel = 0
livesFrame.Parent = hudFrame

local uiCorner1 = Instance.new("UICorner")
uiCorner1.CornerRadius = UDim.new(0, 6)
uiCorner1.Parent = livesFrame

local livesLabel = Instance.new("TextLabel")
livesLabel.Name = "LivesLabel"
livesLabel.Size = UDim2.new(1, 0, 1, 0)
livesLabel.BackgroundTransparency = 1
livesLabel.Text = "❤ Lives: 200"
livesLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
livesLabel.TextScaled = true
livesLabel.Font = Enum.Font.GothamBold
livesLabel.Parent = livesFrame

-- Cash display
local cashFrame = Instance.new("Frame")
cashFrame.Size = UDim2.new(0, 150, 1, -10)
cashFrame.Position = UDim2.new(0, 170, 0, 5)
cashFrame.BackgroundColor3 = Color3.fromRGB(200, 180, 50)
cashFrame.BackgroundTransparency = 0.3
cashFrame.BorderSizePixel = 0
cashFrame.Parent = hudFrame

local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(0, 6)
uiCorner2.Parent = cashFrame

local cashLabel = Instance.new("TextLabel")
cashLabel.Name = "CashLabel"
cashLabel.Size = UDim2.new(1, 0, 1, 0)
cashLabel.BackgroundTransparency = 1
cashLabel.Text = "$ 650"
cashLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
cashLabel.TextScaled = true
cashLabel.Font = Enum.Font.GothamBold
cashLabel.Parent = cashFrame

-- Round display
local roundFrame = Instance.new("Frame")
roundFrame.Size = UDim2.new(0, 150, 1, -10)
roundFrame.Position = UDim2.new(0.5, -75, 0, 5)
roundFrame.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
roundFrame.BackgroundTransparency = 0.3
roundFrame.BorderSizePixel = 0
roundFrame.Parent = hudFrame

local uiCorner3 = Instance.new("UICorner")
uiCorner3.CornerRadius = UDim.new(0, 6)
uiCorner3.Parent = roundFrame

local roundLabel = Instance.new("TextLabel")
roundLabel.Name = "RoundLabel"
roundLabel.Size = UDim2.new(1, 0, 1, 0)
roundLabel.BackgroundTransparency = 1
roundLabel.Text = "Round 1/85"
roundLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
roundLabel.TextScaled = true
roundLabel.Font = Enum.Font.GothamBold
roundLabel.Parent = roundFrame

-- Start Round button
local startButton = Instance.new("TextButton")
startButton.Name = "StartButton"
startButton.Size = UDim2.new(0, 140, 1, -10)
startButton.Position = UDim2.new(1, -150, 0, 5)
startButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
startButton.Text = "▶ START"
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.TextScaled = true
startButton.Font = Enum.Font.GothamBold
startButton.BorderSizePixel = 0
startButton.Parent = hudFrame

local uiCorner4 = Instance.new("UICorner")
uiCorner4.CornerRadius = UDim.new(0, 6)
uiCorner4.Parent = startButton

-- Fast Forward button
local fastButton = Instance.new("TextButton")
fastButton.Name = "FastButton"
fastButton.Size = UDim2.new(0, 120, 1, -10)
fastButton.Position = UDim2.new(1, -280, 0, 5)
fastButton.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
fastButton.Text = "⏩ x2"
fastButton.TextColor3 = Color3.fromRGB(255, 255, 255)
fastButton.TextScaled = true
fastButton.Font = Enum.Font.GothamBold
fastButton.BorderSizePixel = 0
fastButton.Parent = hudFrame

local uiCorner5 = Instance.new("UICorner")
uiCorner5.CornerRadius = UDim.new(0, 6)
uiCorner5.Parent = fastButton

-- ============================================================
-- TOWER SHOP (right sidebar)
-- ============================================================
local shopFrame = Instance.new("Frame")
shopFrame.Name = "TowerShop"
shopFrame.Size = UDim2.new(0, 200, 1, -70)
shopFrame.Position = UDim2.new(1, -210, 0, 65)
shopFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
shopFrame.BackgroundTransparency = 0.1
shopFrame.BorderSizePixel = 0
shopFrame.Parent = screenGui

local shopCorner = Instance.new("UICorner")
shopCorner.CornerRadius = UDim.new(0, 8)
shopCorner.Parent = shopFrame

local shopTitle = Instance.new("TextLabel")
shopTitle.Size = UDim2.new(1, 0, 0, 30)
shopTitle.Position = UDim2.new(0, 0, 0, 0)
shopTitle.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
shopTitle.BackgroundTransparency = 0
shopTitle.Text = "TOWERS"
shopTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
shopTitle.TextScaled = true
shopTitle.Font = Enum.Font.GothamBold
shopTitle.BorderSizePixel = 0
shopTitle.Parent = shopFrame

local shopScroll = Instance.new("ScrollingFrame")
shopScroll.Size = UDim2.new(1, 0, 1, -30)
shopScroll.Position = UDim2.new(0, 0, 0, 30)
shopScroll.BackgroundTransparency = 1
shopScroll.ScrollBarThickness = 4
shopScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
shopScroll.Parent = shopFrame

local shopList = Instance.new("UIListLayout")
shopList.Padding = UDim.new(0, 3)
shopList.SortOrder = Enum.SortOrder.LayoutOrder
shopList.Parent = shopScroll

-- Tower colors for the shop buttons
local towerColors = {
    DartMonkey       = Color3.fromRGB(180, 120, 60),
    TackShooter      = Color3.fromRGB(200, 150, 50),
    SniperMonkey     = Color3.fromRGB(80, 140, 80),
    BoomerangThrower = Color3.fromRGB(160, 100, 50),
    NinjaMonkey      = Color3.fromRGB(60, 60, 80),
    BombTower        = Color3.fromRGB(200, 80, 80),
    IceTower         = Color3.fromRGB(100, 180, 220),
    GlueGunner       = Color3.fromRGB(120, 200, 80),
    MonkeyBuccaneer  = Color3.fromRGB(50, 100, 180),
    MonkeyAce        = Color3.fromRGB(150, 150, 200),
    SuperMonkey      = Color3.fromRGB(200, 50, 200),
    MortarTower      = Color3.fromRGB(140, 120, 100),
    DartlingGun      = Color3.fromRGB(180, 180, 60),
    SpikeFactory     = Color3.fromRGB(160, 60, 60),
    MonkeyVillage    = Color3.fromRGB(100, 160, 80),
    EngineerMonkey   = Color3.fromRGB(180, 140, 60),
}

local towerButtons = {}
local towerOrder = {
    "DartMonkey", "TackShooter", "SniperMonkey", "BoomerangThrower",
    "NinjaMonkey", "BombTower", "IceTower", "GlueGunner",
    "MonkeyBuccaneer", "MonkeyAce", "SuperMonkey", "MortarTower",
    "DartlingGun", "SpikeFactory", "MonkeyVillage", "EngineerMonkey"
}

for i, towerType in ipairs(towerOrder) do
    local data = TowerData.getTower(towerType)
    if not data then continue end

    local btn = Instance.new("TextButton")
    btn.Name = towerType
    btn.Size = UDim2.new(1, -6, 0, 50)
    btn.BackgroundColor3 = towerColors[towerType] or Color3.fromRGB(100, 100, 100)
    btn.BackgroundTransparency = 0.2
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.LayoutOrder = i
    btn.Parent = shopScroll

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -60, 0.6, 0)
    nameLabel.Position = UDim2.new(0, 5, 0, 2)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = data.displayName
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = btn

    local costLabel = Instance.new("TextLabel")
    costLabel.Name = "CostLabel"
    costLabel.Size = UDim2.new(1, -10, 0.4, 0)
    costLabel.Position = UDim2.new(0, 5, 0.6, 0)
    costLabel.BackgroundTransparency = 1
    costLabel.Text = "$" .. data.cost
    costLabel.TextColor3 = Color3.fromRGB(255, 230, 100)
    costLabel.TextScaled = true
    costLabel.Font = Enum.Font.Gotham
    costLabel.TextXAlignment = Enum.TextXAlignment.Left
    costLabel.Parent = btn

    towerButtons[towerType] = btn
end

shopScroll.CanvasSize = UDim2.new(0, 0, 0, #towerOrder * 53)

-- ============================================================
-- UPGRADE PANEL (shown when tower selected)
-- ============================================================
local upgradePanel = Instance.new("Frame")
upgradePanel.Name = "UpgradePanel"
upgradePanel.Size = UDim2.new(0, 250, 0, 350)
upgradePanel.Position = UDim2.new(0, 10, 0.5, -175)
upgradePanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
upgradePanel.BackgroundTransparency = 0.1
upgradePanel.BorderSizePixel = 0
upgradePanel.Visible = false
upgradePanel.Parent = screenGui

local upgPanelCorner = Instance.new("UICorner")
upgPanelCorner.CornerRadius = UDim.new(0, 8)
upgPanelCorner.Parent = upgradePanel

-- Tower name
local upgTowerName = Instance.new("TextLabel")
upgTowerName.Name = "TowerName"
upgTowerName.Size = UDim2.new(1, 0, 0, 40)
upgTowerName.Position = UDim2.new(0, 0, 0, 0)
upgTowerName.BackgroundColor3 = Color3.fromRGB(40, 80, 160)
upgTowerName.BackgroundTransparency = 0
upgTowerName.Text = "Tower Name"
upgTowerName.TextColor3 = Color3.fromRGB(255, 255, 255)
upgTowerName.TextScaled = true
upgTowerName.Font = Enum.Font.GothamBold
upgTowerName.Parent = upgradePanel

-- Target mode buttons
local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(1, -10, 0, 20)
targetLabel.Position = UDim2.new(0, 5, 0, 45)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "Target:"
targetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
targetLabel.TextScaled = true
targetLabel.Font = Enum.Font.Gotham
targetLabel.TextXAlignment = Enum.TextXAlignment.Left
targetLabel.Parent = upgradePanel

local targetModes = {"First", "Last", "Strong", "Close"}
local targetButtons = {}

for i, mode in ipairs(targetModes) do
    local tb = Instance.new("TextButton")
    tb.Name = "Target_" .. mode
    tb.Size = UDim2.new(0.23, -3, 0, 24)
    tb.Position = UDim2.new((i-1) * 0.25, 3, 0, 68)
    tb.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    tb.Text = mode
    tb.TextColor3 = Color3.fromRGB(255, 255, 255)
    tb.TextScaled = true
    tb.Font = Enum.Font.Gotham
    tb.BorderSizePixel = 0
    tb.Parent = upgradePanel

    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 4)
    tbCorner.Parent = tb

    targetButtons[mode] = tb
end

-- Path 1 upgrades
local path1Label = Instance.new("TextLabel")
path1Label.Size = UDim2.new(1, -10, 0, 20)
path1Label.Position = UDim2.new(0, 5, 0, 100)
path1Label.BackgroundTransparency = 1
path1Label.Text = "-- Path 1 --"
path1Label.TextColor3 = Color3.fromRGB(100, 200, 100)
path1Label.TextScaled = true
path1Label.Font = Enum.Font.GothamBold
path1Label.Parent = upgradePanel

local path1Buttons = {}
for i = 1, 4 do
    local ub = Instance.new("TextButton")
    ub.Name = "Path1_" .. i
    ub.Size = UDim2.new(1, -10, 0, 26)
    ub.Position = UDim2.new(0, 5, 0, 122 + (i-1) * 28)
    ub.BackgroundColor3 = Color3.fromRGB(50, 130, 50)
    ub.Text = "Upgrade " .. i
    ub.TextColor3 = Color3.fromRGB(255, 255, 255)
    ub.TextScaled = true
    ub.Font = Enum.Font.Gotham
    ub.BorderSizePixel = 0
    ub.Parent = upgradePanel

    local ubCorner = Instance.new("UICorner")
    ubCorner.CornerRadius = UDim.new(0, 4)
    ubCorner.Parent = ub

    path1Buttons[i] = ub
end

-- Path 2 upgrades
local path2Label = Instance.new("TextLabel")
path2Label.Size = UDim2.new(1, -10, 0, 20)
path2Label.Position = UDim2.new(0, 5, 0, 238)
path2Label.BackgroundTransparency = 1
path2Label.Text = "-- Path 2 --"
path2Label.TextColor3 = Color3.fromRGB(100, 150, 255)
path2Label.TextScaled = true
path2Label.Font = Enum.Font.GothamBold
path2Label.Parent = upgradePanel

local path2Buttons = {}
for i = 1, 4 do
    local ub = Instance.new("TextButton")
    ub.Name = "Path2_" .. i
    ub.Size = UDim2.new(1, -10, 0, 26)
    ub.Position = UDim2.new(0, 5, 0, 260 + (i-1) * 28)
    ub.BackgroundColor3 = Color3.fromRGB(50, 80, 180)
    ub.Text = "Upgrade " .. i
    ub.TextColor3 = Color3.fromRGB(255, 255, 255)
    ub.TextScaled = true
    ub.Font = Enum.Font.Gotham
    ub.BorderSizePixel = 0
    ub.Parent = upgradePanel

    local ubCorner = Instance.new("UICorner")
    ubCorner.CornerRadius = UDim.new(0, 4)
    ubCorner.Parent = ub

    path2Buttons[i] = ub
end

-- Sell button
local sellButton = Instance.new("TextButton")
sellButton.Name = "SellButton"
sellButton.Size = UDim2.new(1, -10, 0, 30)
sellButton.Position = UDim2.new(0, 5, 1, -35)
sellButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
sellButton.Text = "SELL ($0)"
sellButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sellButton.TextScaled = true
sellButton.Font = Enum.Font.GothamBold
sellButton.BorderSizePixel = 0
sellButton.Parent = upgradePanel

local sellCorner = Instance.new("UICorner")
sellCorner.CornerRadius = UDim.new(0, 6)
sellCorner.Parent = sellButton

-- Close upgrade panel button
local closeUpgradeBtn = Instance.new("TextButton")
closeUpgradeBtn.Size = UDim2.new(0, 24, 0, 24)
closeUpgradeBtn.Position = UDim2.new(1, -28, 0, 8)
closeUpgradeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeUpgradeBtn.Text = "X"
closeUpgradeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeUpgradeBtn.TextScaled = true
closeUpgradeBtn.Font = Enum.Font.GothamBold
closeUpgradeBtn.BorderSizePixel = 0
closeUpgradeBtn.Parent = upgradePanel

local closeUpgradeCorner = Instance.new("UICorner")
closeUpgradeCorner.CornerRadius = UDim.new(0, 4)
closeUpgradeCorner.Parent = closeUpgradeBtn

-- ============================================================
-- ROUND NOTIFICATION
-- ============================================================
local roundNotif = Instance.new("Frame")
roundNotif.Name = "RoundNotif"
roundNotif.Size = UDim2.new(0, 300, 0, 60)
roundNotif.Position = UDim2.new(0.5, -150, 0, 70)
roundNotif.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
roundNotif.BackgroundTransparency = 0.3
roundNotif.BorderSizePixel = 0
roundNotif.Visible = false
roundNotif.Parent = screenGui

local roundNotifCorner = Instance.new("UICorner")
roundNotifCorner.CornerRadius = UDim.new(0, 8)
roundNotifCorner.Parent = roundNotif

local roundNotifLabel = Instance.new("TextLabel")
roundNotifLabel.Size = UDim2.new(1, 0, 1, 0)
roundNotifLabel.BackgroundTransparency = 1
roundNotifLabel.Text = "Round 1"
roundNotifLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
roundNotifLabel.TextScaled = true
roundNotifLabel.Font = Enum.Font.GothamBold
roundNotifLabel.Parent = roundNotif

-- ============================================================
-- GAME OVER / VICTORY SCREENS
-- ============================================================
local function createOverlay(title, subtitle, bgColor)
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = bgColor
    overlay.BackgroundTransparency = 0.3
    overlay.Visible = false
    overlay.ZIndex = 100
    overlay.Parent = screenGui

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.6, 0, 0.2, 0)
    titleLabel.Position = UDim2.new(0.2, 0, 0.3, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.ZIndex = 101
    titleLabel.Parent = overlay

    local subLabel = Instance.new("TextLabel")
    subLabel.Name = "SubLabel"
    subLabel.Size = UDim2.new(0.6, 0, 0.1, 0)
    subLabel.Position = UDim2.new(0.2, 0, 0.5, 0)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = subtitle
    subLabel.TextColor3 = Color3.fromRGB(255, 230, 100)
    subLabel.TextScaled = true
    subLabel.Font = Enum.Font.Gotham
    subLabel.ZIndex = 101
    subLabel.Parent = overlay

    return overlay
end

local gameOverScreen = createOverlay("GAME OVER", "You were defeated!", Color3.fromRGB(150, 20, 20))
local victoryScreen = createOverlay("VICTORY!", "You defeated all 85 rounds!", Color3.fromRGB(20, 100, 20))

-- ============================================================
-- STATE
-- ============================================================
UIManager.currentCash = Config.STARTING_CASH
UIManager.currentLives = Config.STARTING_LIVES
UIManager.currentRound = 1
UIManager.roundInProgress = false
UIManager.selectedTowerId = nil
UIManager.selectedTowerType = nil
UIManager.onTowerSelect = nil
UIManager.onStartRound = nil
UIManager.onSellTower = nil
UIManager.onUpgradeTower = nil
UIManager.onSetTargetMode = nil

-- ============================================================
-- UPDATE FUNCTIONS
-- ============================================================
function UIManager.updateLives(lives)
    UIManager.currentLives = lives
    livesLabel.Text = "❤ Lives: " .. lives
    if lives <= 0 then
        livesLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    elseif lives <= 20 then
        livesLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    else
        livesLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

function UIManager.updateCash(cash)
    UIManager.currentCash = cash
    cashLabel.Text = "$ " .. cash

    -- Dim unavailable towers
    for towerType, btn in pairs(towerButtons) do
        local data = TowerData.getTower(towerType)
        if data then
            if cash < data.cost then
                btn.BackgroundTransparency = 0.6
                btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            else
                btn.BackgroundTransparency = 0.2
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
    end
end

function UIManager.updateRound(round, inProgress)
    UIManager.currentRound = round
    UIManager.roundInProgress = inProgress
    roundLabel.Text = "Round " .. round .. "/85"

    if inProgress then
        startButton.Text = "IN PROGRESS"
        startButton.BackgroundColor3 = Color3.fromRGB(150, 80, 30)
        startButton.Active = false
    else
        startButton.Text = "▶ START"
        startButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        startButton.Active = true
    end
end

function UIManager.showRoundNotification(round, text)
    roundNotifLabel.Text = text or ("Round " .. round .. " Starting!")
    roundNotif.Visible = true

    local tween = TweenService:Create(roundNotif,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0.1}
    )
    tween:Play()

    task.delay(2.5, function()
        local fadeTween = TweenService:Create(roundNotif,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad),
            {BackgroundTransparency = 1}
        )
        fadeTween:Play()
        fadeTween.Completed:Connect(function()
            roundNotif.Visible = false
            roundNotif.BackgroundTransparency = 0.3
        end)
    end)
end

function UIManager.showGameOver(round)
    local sub = gameOverScreen:FindFirstChild("SubLabel")
    if sub then sub.Text = "Defeated on Round " .. round end
    gameOverScreen.Visible = true
end

function UIManager.showVictory()
    victoryScreen.Visible = true
end

function UIManager.showUpgradePanel(towerId, towerType, upgrades, totalCost)
    UIManager.selectedTowerId = towerId
    UIManager.selectedTowerType = towerType

    local data = TowerData.getTower(towerType)
    if not data then return end

    upgTowerName.Text = data.displayName
    local sellValue = math.floor(totalCost * Config.SELL_REFUND_RATE)
    sellButton.Text = "SELL ($" .. sellValue .. ")"

    -- Update path 1 buttons
    for i, btn in ipairs(path1Buttons) do
        if data.path1 and data.path1[i] then
            local upg = data.path1[i]
            if i <= (upgrades[1] or 0) then
                btn.Text = "✓ " .. upg.name
                btn.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
                btn.Active = false
            else
                btn.Text = upg.name .. " ($" .. upg.cost .. ")"
                if UIManager.currentCash >= upg.cost and i == (upgrades[1] or 0) + 1 then
                    btn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
                    btn.Active = true
                else
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    btn.Active = false
                end
            end
        else
            btn.Text = "---"
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.Active = false
        end
    end

    -- Update path 2 buttons
    for i, btn in ipairs(path2Buttons) do
        if data.path2 and data.path2[i] then
            local upg = data.path2[i]
            if i <= (upgrades[2] or 0) then
                btn.Text = "✓ " .. upg.name
                btn.BackgroundColor3 = Color3.fromRGB(30, 60, 130)
                btn.Active = false
            else
                btn.Text = upg.name .. " ($" .. upg.cost .. ")"
                if UIManager.currentCash >= upg.cost and i == (upgrades[2] or 0) + 1 then
                    btn.BackgroundColor3 = Color3.fromRGB(50, 80, 200)
                    btn.Active = true
                else
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    btn.Active = false
                end
            end
        else
            btn.Text = "---"
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.Active = false
        end
    end

    upgradePanel.Visible = true
end

function UIManager.hideUpgradePanel()
    upgradePanel.Visible = false
    UIManager.selectedTowerId = nil
    UIManager.selectedTowerType = nil
end

-- ============================================================
-- BUTTON CONNECTIONS
-- ============================================================
startButton.MouseButton1Click:Connect(function()
    if UIManager.onStartRound then
        UIManager.onStartRound()
    end
end)

local isFastForward = false
fastButton.MouseButton1Click:Connect(function()
    isFastForward = not isFastForward
    if isFastForward then
        fastButton.BackgroundColor3 = Color3.fromRGB(200, 120, 50)
        fastButton.Text = "⏩ x2 ON"
        -- Note: actual speed change handled by GameClient
        if UIManager.onFastForward then UIManager.onFastForward(true) end
    else
        fastButton.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
        fastButton.Text = "⏩ x2"
        if UIManager.onFastForward then UIManager.onFastForward(false) end
    end
end)

for towerType, btn in pairs(towerButtons) do
    btn.MouseButton1Click:Connect(function()
        if UIManager.onTowerSelect then
            UIManager.onTowerSelect(towerType)
        end
    end)
end

for mode, btn in pairs(targetButtons) do
    btn.MouseButton1Click:Connect(function()
        if UIManager.selectedTowerId and UIManager.onSetTargetMode then
            UIManager.onSetTargetMode(UIManager.selectedTowerId, mode)
            -- Highlight selected mode
            for m, b in pairs(targetButtons) do
                b.BackgroundColor3 = m == mode
                    and Color3.fromRGB(100, 100, 200)
                    or  Color3.fromRGB(60, 60, 80)
            end
        end
    end)
end

for i, btn in ipairs(path1Buttons) do
    btn.MouseButton1Click:Connect(function()
        if UIManager.selectedTowerId and UIManager.onUpgradeTower then
            UIManager.onUpgradeTower(UIManager.selectedTowerId, 1, i)
        end
    end)
end

for i, btn in ipairs(path2Buttons) do
    btn.MouseButton1Click:Connect(function()
        if UIManager.selectedTowerId and UIManager.onUpgradeTower then
            UIManager.onUpgradeTower(UIManager.selectedTowerId, 2, i)
        end
    end)
end

sellButton.MouseButton1Click:Connect(function()
    if UIManager.selectedTowerId and UIManager.onSellTower then
        UIManager.onSellTower(UIManager.selectedTowerId)
        UIManager.hideUpgradePanel()
    end
end)

closeUpgradeBtn.MouseButton1Click:Connect(function()
    UIManager.hideUpgradePanel()
end)

return UIManager
