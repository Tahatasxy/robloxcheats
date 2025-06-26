local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Create a simple UI label
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "PartViewer"

local textLabel = Instance.new("TextLabel", gui)
textLabel.Size = UDim2.new(0.6, 0, 0.6, 0)
textLabel.Position = UDim2.new(0.2, 0, 0.2, 0)
textLabel.BackgroundColor3 = Color3.new(0, 0, 0)
textLabel.TextColor3 = Color3.new(1, 1, 1)
textLabel.TextScaled = true
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.TextYAlignment = Enum.TextYAlignment.Top
textLabel.Font = Enum.Font.Code
textLabel.Text = "Scanning players..."

-- Build the part list
local output = ""

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        output = output .. "🧍 "..player.Name..":\n"
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                output = output .. "   • " .. part.Name .. " [" .. part.ClassName .. "]\n"
            end
        else
            output = output .. "   🚫 Character not loaded\n"
        end
    end
end

textLabel.Text = output
