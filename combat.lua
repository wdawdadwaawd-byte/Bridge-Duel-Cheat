-- combat.lua
HITBOX_EXPAND = true
ROOT_MULT = 10
HEAD_MULT = 15
REACH_ENABLED = false
REACH_SIZE = 15
KILL_RANGE = 20
STRAFE = false
STRAFE_SPEED = 5
STRAFE_RADIUS = 10

originalSizes = {}
currentTarget = nil

local function isEnemy(p)
    return p ~= LocalPlayer
end

local function validChar(c)
    return c and c:FindFirstChild("HumanoidRootPart")
        and c:FindFirstChildOfClass("Humanoid")
end

function GetClosestEnemy()
    local best, dist = nil, KILL_RANGE
    for _, p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) and validChar(p.Character) then
            local d = (
                LocalPlayer.Character.HumanoidRootPart.Position -
                p.Character.HumanoidRootPart.Position
            ).Magnitude
            if d < dist then
                dist = d
                best = p
            end
        end
    end
    return best
end
