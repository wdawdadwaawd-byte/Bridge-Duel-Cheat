-- Utils.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Config = getgenv().BDSettings

local Utils = {}

function Utils.IsCharacterValid(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    return humanoid and rootPart
end

function Utils.IsEnemy(player)
    return player ~= LocalPlayer
end

function Utils.GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Config.KillAuraRange

    for _, player in ipairs(Players:GetPlayers()) do
        if Utils.IsEnemy(player) and player.Character and Utils.IsCharacterValid(player.Character) then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDistance then
                    closestPlayer = player
                    shortestDistance = dist
                end
            end
        end
    end
    return closestPlayer
end

return Utils
