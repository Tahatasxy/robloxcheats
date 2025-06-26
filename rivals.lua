-- Ultimate Training Toolkit (Safe, Legal Alternative)
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- ===== CORE SYSTEMS =====
local menuActive = false
local trainingActive = false
local highlightsActive = false

-- ===== UI CONSTRUCTION =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TrainingSystem"
screenGui.Parent = PlayerGui
screenGui.Enabled = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.3, 0, 0.35, 0)
mainFrame.Position = UDim2.new(0.35, 0, 0.325, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.Parent = screenGui

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0.15, 0)
header.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Text = "TRAINING SYSTEM"
title.Size = UDim2.new(0.8, 0, 1, 0)
title.Position = UDim2.new(0.1, 0, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.Parent = header

-- ===== FUNCTIONALITY =====
-- 1. Right Shift Toggle
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        menuActive = not menuActive
        screenGui.Enabled = menuActive
    end
end)

-- 2. Team Highlight System
local teamHighlights = {}
local highlightToggle = Instance.new("TextButton")
highlightToggle.Text = "ENABLE TEAM VISUALIZER"
highlightToggle.Size = UDim2.new(0.9, 0, 0.15, 0)
highlightToggle.Position = UDim2.new(0.05, 0, 0.2, 0)
highlightToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
highlightToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
highlightToggle.Font = Enum.Font.Gotham
highlightToggle.Parent = mainFrame

local function updateHighlights()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= player and player.Team == player.Team then
            local character = player.Character or player.CharacterAdded:Wait()
            if not teamHighlights[player] then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(0, 200, 0)
                highlight.OutlineColor = Color3.fromRGB(0, 150, 0)
                highlight.Parent = character
                teamHighlights[player] = highlight
            end
        end
    end
end

highlightToggle.MouseButton1Click:Connect(function()
    highlightsActive = not highlightsActive
    if highlightsActive then
        updateHighlights()
        highlightToggle.Text = "DISABLE TEAM VISUALIZER"
    else
        for _, highlight in pairs(teamHighlights) do
            highlight:Destroy()
        end
        teamHighlights = {}
        highlightToggle.Text = "ENABLE TEAM VISUALIZER"
    end
end)

-- 3. Aim Training System
local target = Instance.new("Part")
target.Size = Vector3.new(4, 4, 4)
target.Shape = Enum.PartType.Ball
target.Color = Color3.fromRGB(255, 50, 50)
target.Material = Enum.Material.Neon
target.Anchored = true
target.CanCollide = false
target.Parent = workspace
target.Position = Vector3.new(0, 10, 0)

local aimToggle = Instance.new("TextButton")
aimToggle.Text = "START AIM TRAINER"
aimToggle.Size = UDim2.new(0.9, 0, 0.15, 0)
aimToggle.Position = UDim2.new(0.05, 0, 0.4, 0)
aimToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
aimToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
aimToggle.Font = Enum.Font.Gotham
aimToggle.Parent = mainFrame

local statsDisplay = Instance.new("TextLabel")
statsDisplay.Text = "Hits: 0 | Accuracy: 0%"
statsDisplay.Size = UDim2.new(0.9, 0, 0.1, 0)
statsDisplay.Position = UDim2.new(0.05, 0, 0.6, 0)
statsDisplay.BackgroundTransparency = 1
statsDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
statsDisplay.Font = Enum.Font.Gotham
statsDisplay.Parent = mainFrame

local hits = 0
local attempts = 0

local function moveTarget()
    if not trainingActive then return end
    target.Position = Vector3.new(
        math.random(-40, 40),
        math.random(5, 20),
        math.random(-40, 40)
    )
    task.wait(1.5)
    moveTarget()
end

aimToggle.MouseButton1Click:Connect(function()
    trainingActive = not trainingActive
    if trainingActive then
        aimToggle.Text = "STOP AIM TRAINER"
        hits = 0
        attempts = 0
        statsDisplay.Text = "Hits: 0 | Accuracy: 0%"
        moveTarget()
    else
        aimToggle.Text = "START AIM TRAINER"
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if trainingActive and input.UserInputType == Enum.UserInputType.MouseButton1 then
        attempts = attempts + 1
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {target}
        
        local ray = workspace:Raycast(
            player:GetMouse().UnitRay.Origin,
            player:GetMouse().UnitRay.Direction * 1000,
            raycastParams
        )
        
        if ray then
            hits = hits + 1
            target.Color = Color3.fromRGB(50, 255, 50)
            task.delay(0.2, function()
                if trainingActive then
                    target.Color = Color3.fromRGB(255, 50, 50)
                end
            end)
        end
        
        local accuracy = attempts > 0 and math.floor((hits/attempts)*100) or 0
        statsDisplay.Text = string.format("Hits: %d | Accuracy: %d%%", hits, accuracy)
    end
end)

-- Initial positioning
target.Position = Vector3.new(0, 10, 0)
