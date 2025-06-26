-- Simple Aimbot Script by xSNYZ (educational only)
local FOV_RADIUS = 100
local AIM_PART = "Head"
local TEAM_CHECK = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function getClosestPlayer()
    local closest = nil
    local shortestDist = FOV_RADIUS

    for _, player in pairs(Players:GetPlayers()) do
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

RunService.RenderStepped:Connect(function()
    local target = getClosestPlayer()
    if target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
    end
end)
