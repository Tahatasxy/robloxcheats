-- Simple Aimbot + ESP for Rivals | Xeno executor compatible

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local AimbotEnabled = false
local ESPEnabled = false
local MenuVisible = false

local FOV_RADIUS = 150
local AIM_PART = "UpperTorso" -- try UpperTorso since Rivals uses R15
local TEAM_CHECK = true

-- Create GUI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "RivalsCheatUI"
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

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = FOV_RADIUS
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- Toggles
AimbotButton.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    AimbotButton.Text = AimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
    FOVCircle.Visible = AimbotEnabled and MenuVisible
end)

ESPButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPButton.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
    if not ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local box = player.Character:FindFirstChild("ESP_Box")
                if box then box:Destroy() end
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MenuVisible = not MenuVisible
        Frame.Visible = MenuVisible
        FOVCircle.Visible = AimbotEnabled and MenuVisible
    end
end)

local function getClosestPlayer()
    local closest
    local shortestDist = FOV_RADIUS

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AIM_PART) then
            if TEAM_CHECK and player.Team == LocalPlayer.Team then continue end

            local part = player.Character[AIM_PART]
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
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

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)

    if AimbotEnabled then
        local target = getClosestPlayer()
        if target then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
        end
    end

    if ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if TEAM_CHECK and player.Team == LocalPlayer.Team then continue end

                local char = player.Character
                local box = char:FindFirstChild("ESP_Box")
                if not box then
                    box = Instance.new("BoxHandleAdornment")
                    box.Name = "ESP_Box"
                    box.Adornee = char.HumanoidRootPart
                    box.AlwaysOnTop = true
                    box.ZIndex = 5
                    box.Size = Vector3.new(4, 6, 1)
                    box.Color3 = Color3.new(1, 0, 0)
                    box.Transparency = 0.5
                    box.Parent = char
                end
            end
        end
    end
end)
