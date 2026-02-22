-- Target HUD
local function updateTargetHUD(target)
    if not KILL_AURA_ENABLED then
        if TargetHUD.Main.Visible then
            TargetHUD.Main.Visible = false
            TargetHUD.Portrait.Visible = false
            TargetHUD.Name.Visible = false
            TargetHUD.Kills.Visible = false
            TargetHUD.HealthBarBack.Visible = false
            TargetHUD.HealthBarMain.Visible = false
            lastTargetUserId = nil
            cachedPortraitData = nil
        end
        return
    end
    if not target or not target.Character then
        if TargetHUD.Main.Visible then
            TargetHUD.Main.Visible = false
            TargetHUD.Portrait.Visible = false
            TargetHUD.Name.Visible = false
            TargetHUD.Kills.Visible = false
            TargetHUD.HealthBarBack.Visible = false
            TargetHUD.HealthBarMain.Visible = false
        end
        lastTargetUserId = nil
        cachedPortraitData = nil
        return
    end
    local hum = target.Character:FindFirstChildWhichIsA("Humanoid")
    checkForKill(target)
    if not hum or hum.Health <= 0 then
        if TargetHUD.Main.Visible then
            TargetHUD.Main.Visible = false
            TargetHUD.Portrait.Visible = false
            TargetHUD.Name.Visible = false
            TargetHUD.Kills.Visible = false
            TargetHUD.HealthBarBack.Visible = false
            TargetHUD.HealthBarMain.Visible = false
        end
        return
    end
    if lastTargetUserId ~= target.UserId then
        lastTargetUserId = target.UserId
        task.spawn(function()
            local success, result = pcall(function()
                return game:HttpGetAsync(
                    "https://www.roblox.com/headshot-thumbnail/image?userId=" .. target.UserId .. "&width=420&height=420&format=png"
                )
            end)
            if success and result and #result > 100 then
                cachedPortraitData = result
                TargetHUD.Portrait.Data = cachedPortraitData
            else
                TargetHUD.Portrait.Data = ""
            end
        end)
    end
    local screenSize = Camera.ViewportSize
    local center = screenSize / 2
    local hudPos = center + Vector2.new(80, 80)
    TargetHUD.Main.Position = hudPos
    TargetHUD.Portrait.Position = hudPos + Vector2.new(8, 8)
    TargetHUD.Name.Position = hudPos + Vector2.new(55, 10)
    TargetHUD.Kills.Position = hudPos + Vector2.new(55, 45)
    TargetHUD.HealthBarBack.Position = hudPos + Vector2.new(55, 32)
    TargetHUD.HealthBarMain.Position = hudPos + Vector2.new(55, 32)
    TargetHUD.Name.Text = target.Name .. " [" .. math.floor(hum.Health) .. " HP]"
    TargetHUD.Kills.Text = "KILLS: " .. tostring(killCount)
    local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
    TargetHUD.HealthBarMain.Size = Vector2.new(90 * hpPercent, 10)
    TargetHUD.HealthBarMain.Color = Color3.fromHSV(0.3 * hpPercent, 0.9, 0.9)
    if not TargetHUD.Main.Visible then
        TargetHUD.Main.Visible = true
        TargetHUD.Portrait.Visible = true
        TargetHUD.Name.Visible = true
        TargetHUD.Kills.Visible = true
        TargetHUD.HealthBarBack.Visible = true
        TargetHUD.HealthBarMain.Visible = true
    end
end
