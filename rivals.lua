--[[ 📌 Simple Aimbot with GUI Toggle | By xSNYZ ]]--

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- // Variables
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local AimbotEnabled = false
local MenuVisible = false
local FOV_RADIUS = 100
local AIM_PART = "Head"
local TEAM_CHECK = true

-- // Create GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "RivalsAimbotUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0.5, -100, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Visible = false

local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(1, 0, 0.5, 0)
ToggleButton.Position = UDim2.new(0, 0, 0, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleButton.Text = "Aimbot: OFF"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.SourceSans
ToggleButton.TextSize = 20

local InfoLabel = Instance.new("TextLabel", Frame)
InfoLabel.Size = UDim2.new(1, 0, 0.5, 0)
InfoLabel.Position = UDim2.new(0, 0, 0.5, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
InfoLabel.Font = Enum.Font.SourceSans
InfoLabel.TextSize = 16
InfoLabel.Text = "Press RightShift to toggle menu"

-- // Toggle button logic
ToggleButton.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    ToggleButton.Text = AimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
end)

-- // Menu toggle with RightShift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MenuVisible = not MenuVisible
        Frame.Visible = MenuVisible
    end
end)

-- // Aimbot logic
local function getClosestPlayer()
    local closest, shortestDist = nil, FOV_RADIUS

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AIM_PART) then
            if TEAM_CHECK and player.Team == LocalPlayer.Team then
                continue
            end

            local part = player.Character[AIM_PART]
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = part
                end
            end
        end
    end

    return closest
end

-- // Run Aimbot when enabled
RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then return end
    local target = getClosestPlayer()
    if target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
    end
end)
