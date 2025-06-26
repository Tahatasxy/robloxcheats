local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPEnabled = false
local espCache = {}

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
    
    local elements = espCache[player]
    local width = 100 / math.clamp(screenData.depth, 0.1, math.huge)
    local height = 200 / math.clamp(screenData.depth, 0.1, math.huge)
    
    elements.box.Visible = true
    elements.box.Position = screenData.position - Vector2.new(width/2, height/2)
    elements.box.Size = Vector2.new(width, height)
    elements.box.Color = screenData.visible and Color3.new(1, 0, 0) or Color3.new(0, 0, 1)
    elements.box.Thickness = 2
    
    elements.name.Visible = true
    elements.name.Position = screenData.position + Vector2.new(0, -height/2 - 15)
    elements.name.Text = player.Name
    elements.name.Color = Color3.new(1, 1, 1)
    elements.name.Size = 14
end

local function ClearESP()
    for _, elements in pairs(espCache) do
        if elements.box then elements.box.Visible = false end
        if elements.name then elements.name.Visible = false end
    end
end

local function ESPLoop()
    while ESPEnabled do
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local screenData = WorldToScreen(player.Character.Head.Position)
                DrawBox(player, screenData)
            else
                -- Hide ESP for players without valid character
                if espCache[player] then
                    espCache[player].box.Visible = false
                    espCache[player].name.Visible = false
                end
            end
        end
        task.wait(0.1)
    end
    ClearESP()
end

-- Call this to start ESP when needed
local espCoroutine
local function SetESPEnabled(enabled)
    ESPEnabled = enabled
    if enabled then
        espCoroutine = coroutine.wrap(ESPLoop)
        espCoroutine()
    else
        ClearESP()
    end
end

-- Example toggle:
-- SetESPEnabled(true) to start ESP
-- SetESPEnabled(false) to stop ESP
