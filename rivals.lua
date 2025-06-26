local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        print("----", player.Name, "----")
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                print(part.Name, "-", part.ClassName)
            end
        else
            print("No character loaded for", player.Name)
        end
    end
end
