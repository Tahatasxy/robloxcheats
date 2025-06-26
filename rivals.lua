local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

-- Improved player scanner with custom character support
local function ScanPlayers()
    local detectedPlayers = {}
    
    -- Method 1: Standard player list
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            table.insert(detectedPlayers, player)
        end
    end

    -- Method 2: Workspace scanning (catches custom loaders)
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("Model") then
            local humanoid = descendant:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid:IsA("Humanoid") then
                local player = Players:GetPlayerFromCharacter(descendant)
                if player and player ~= localPlayer and not table.find(detectedPlayers, player) then
                    table.insert(detectedPlayers, player)
                end
            end
        end
    end

    -- Method 3: Network ownership check
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part:GetNetworkOwner() then
            local player = part:GetNetworkOwner()
            if player and player ~= localPlayer and not table.find(detectedPlayers, player) then
                table.insert(detectedPlayers, player)
            end
        end
    end

    return detectedPlayers
end

-- Robust character detection
local function GetCharacter(player)
    -- Try standard method first
    if player.Character then
        return player.Character
    end

    -- Fallback to delayed check for custom loaders
    local character
    local success = pcall(function()
        character = player.CharacterAdded:Wait(3) -- 3 second timeout
    end)

    -- Last resort: Find any model with player's name
    if not success or not character then
        for _, model in ipairs(workspace:GetDescendants()) do
            if model:IsA("Model") and model.Name == player.Name then
                local humanoid = model:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    return model
                end
            end
        end
    end

    return character
end

-- Main detection loop
RunService.Heartbeat:Connect(function()
    local allPlayers = ScanPlayers()
    
    for _, player in ipairs(allPlayers) do
        local character = GetCharacter(player)
        if character then
            -- Process character here
            print("Detected:", player.Name, "with character:", character:GetFullName())
        end
    end
end)
