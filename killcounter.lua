-- Kill Counter
local function checkForKill(target)
    if not target or not target.Character then return end
    local hum = target.Character:FindFirstChildWhichIsA("Humanoid")
    local userId = target.UserId
    if hum and hum.Health <= 0.1 then
        if not deadPlayers[userId] then
            getgenv().BD_KillCount = getgenv().BD_KillCount + 1
            killCount = getgenv().BD_KillCount
            deadPlayers[userId] = true
            print("🎯 KILL! Toplam: " .. killCount)
            task.delay(5, function()
                deadPlayers[userId] = nil
                getgenv().BD_DeadPlayers = deadPlayers
            end)
        end
    end
end
