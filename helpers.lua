-- Helpers
local function isCharacterValid(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    return humanoid and rootPart
end

local function isEnemy(player)
    return player ~= LocalPlayer
end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = KILL_AURA_RANGE
    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) and player.Character and isCharacterValid(player.Character) then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortestDistance then
                closestPlayer = player
                shortestDistance = dist
            end
        end
    end
    return closestPlayer
end
