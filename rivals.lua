--[[ 📌 Aimbot + ESP with Toggleable Menu | By xSNYZ ]]--

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- // Variables
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local AimbotEnabled = false
local ESPEnabled = false
local MenuVisible = false
local FOV_RADIUS = 100
local AIM_PART = "Head"
local TEAM_CHECK = true
local espObjects = {}

-- // GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "RivalsCheatMenu"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 130)
Frame.Position = UDim2.new(0.5, -100, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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
InfoLabel.Text = "RightShift to toggle menu"

-- // Aimbot toggle
AimbotButton.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    AimbotButton.Text = AimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
end)

-- // ESP toggle
ESPButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPButton.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"

    -- Refresh ESP visibility
    for player, gui in pairs(espObjects) do
        if gui and gui.Parent then
            gui.Enabled = ESPEnabled
        end
    end
end)

-- // Menu toggle with RightShift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MenuVisible = not MenuVisible
        Frame.Visible = MenuVisible
    end
end)

-- // Aimbot target
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

-- // Aimbot logic
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = getClosestPlayer()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- // ESP logic
local function createESP(player)
    if espObjects[player] then return end
    local box = Instance.new("BillboardGui")
    box.Name = "ESP"
    box.Size = UDim2.new(4, 0, 5, 0)
    box.AlwaysOnTop = true
    box.Enabled = ESPEnabled

    local frame = Instance.new("Frame", box)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0

    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        box.Parent = hrp
        espObjects[player] = box
    end
end

-- // Cleanup on leave
Players.PlayerRemoving:Connect(function(player)
    if espObjects[player] then
        espObjects[player]:Destroy()
        espObjects[player] = nil
    end
end)

-- // Create ESP for new players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        if TEAM_CHECK and player.Team == LocalPlayer.Team then return end
        createESP(player)
    end)
end)

-- // Setup existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            wait(1)
            if TEAM_CHECK and player.Team == LocalPlayer.Team then return end
            createESP(player)
        end)
        if player.Character then
            if TEAM_CHECK and player.Team == LocalPlayer.Team then continue end
            createESP(player)
        end
    end
end
