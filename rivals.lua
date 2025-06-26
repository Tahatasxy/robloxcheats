-- ⚙️ Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ⚙️ State
local MenuVisible = false
local ESPEnabled = false
local AimbotEnabled = false
local espCache = {}

-- 🧠 Utilities
local function WorldToScreen(position)
    local screenPos, visible = Camera:WorldToViewportPoint(position)
    return {
        position = Vector2.new(screenPos.X, screenPos.Y),
        visible = visible,
        depth = screenPos.Z
    }
end

local function DrawBox(player, screenData)
    if not espCache[player] then
        espCache[player] = {
            box = Drawing.new("Square"),
            name = Drawing.new("Text")
        }
    end

    local width = 100 / math.clamp(screenData.depth, 0.1, math.huge)
    local height = 200 / math.clamp(screenData.depth, 0.1, math.huge)

    local elements = espCache[player]

    elements.box.Visible = true
    elements.box.Position = screenData.position - Vector2.new(width / 2, height / 2)
    elements.box.Size = Vector2.new(width, height)
    elements.box.Color = screenData.visible and Color3.new(1, 0, 0) or Color3.new(0, 0, 1)
    elements.box.Thickness = 2

    elements.name.Visible = true
    elements.name.Position = screenData.position + Vector2.new(0, -height / 2 - 15)
    elements.name.Text = player.Name
    elements.name.Color = Color3.new(1, 1, 1)
    elements.name.Size = 14
end

local function ClearESP()
    for _, v in pairs(espCache) do
        if v.box then v.box.Visible = false end
        if v.name then v.name.Visible = false end
    end
end

-- 🧠 ESP Loop
local function ESPLoop()
    while ESPEnabled do
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local screenData = WorldToScreen(player.Character.Head.Position)
                DrawBox(player, screenData)
            elseif espCache[player] then
                espCache[player].box.Visible = false
                espCache[player].name.Visible = false
            end
        end
        task.wait(0.1)
    end
    ClearESP()
end

-- 🎯 Toggle Handler
local function ToggleESP(state)
    ESPEnabled = state
    if state then
        coroutine.wrap(ESPLoop)()
    else
        ClearESP()
    end
end

-- 🖱️ GUI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "CheatMenu"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 150)
Frame.Position = UDim2.new(0.5, -110, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Visible = false

local AimbotButton = Instance.new("TextButton", Frame)
AimbotButton.Size = UDim2.new(1, 0, 0.33, 0)
AimbotButton.Position = UDim2.new(0, 0, 0, 0)
AimbotButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AimbotButton.Text = "Aimbot: OFF"
AimbotButton.TextColor3 = Color3.new(1, 1, 1)
AimbotButton.Font = Enum.Font.SourceSans
AimbotButton.TextSize = 20

local ESPButton = Instance.new("TextButton", Frame)
ESPButton.Size = UDim2.new(1, 0, 0.33, 0)
ESPButton.Position = UDim2.new(0, 0, 0.33, 0)
ESPButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ESPButton.Text = "ESP: OFF"
ESPButton.TextColor3 = Color3.new(1, 1, 1)
ESPButton.Font = Enum.Font.SourceSans
ESPButton.TextSize = 20

local InfoLabel = Instance.new("TextLabel", Frame)
InfoLabel.Size = UDim2.new(1, 0, 0.34, 0)
InfoLabel.Position = UDim2.new(0, 0, 0.66, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
InfoLabel.Font = Enum.Font.SourceSans
InfoLabel.TextSize = 16
InfoLabel.Text = "Press RightShift to toggle menu"

-- 🎛️ Toggle logic
AimbotButton.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    AimbotButton.Text = AimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
end)

ESPButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPButton.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
    ToggleESP(ESPEnabled)
end)

-- ⌨️ RightShift opens menu
UserInputService.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MenuVisible = not MenuVisible
        Frame.Visible = MenuVisible
    end
end)

print("✅ Menu loaded. Press RightShift to toggle.")
