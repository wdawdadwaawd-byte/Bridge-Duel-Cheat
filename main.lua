-- Bridge Duel Cheat v2 - Main Loader
print("🔥 Bridge Duel Cheat v2 Yükleniyor...")

-- Diğer modülleri GitHub'dan yükle
loadstring(game:HttpGet("https://raw.githubusercontent.com/wdawdadwaawd-byte/Bridge-Duel-Cheat/main/variables.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/wdawdadwaawd-byte/Bridge-Duel-Cheat/main/helpers.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/wdawdadwaawd-byte/Bridge-Duel-Cheat/main/hitbox.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/wdawdadwaawd-byte/Bridge-Duel-Cheat/main/killcounter.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/wdawdadwaawd-byte/Bridge-Duel-Cheat/main/targethud.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/wdawdadwaawd-byte/Bridge-Duel-Cheat/main/combat.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/wdawdadwaawd-byte/Bridge-Duel-Cheat/main/esp.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/wdawdadwaawd-byte/Bridge-Duel-Cheat/main/fly.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/wdawdadwaawd-byte/Bridge-Duel-Cheat/main/autoclick.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/wdawdadwaawd-byte/Bridge-Duel-Cheat/main/ui.lua"))()

-- Hitbox ve Reach döngüsü (main'de başlat)
task.spawn(function()
    while true do
        if HITBOX_EXPAND_ENABLED then
            expandHitboxes()
        else
            restoreAllHitboxes()
        end
        if REACH_ENABLED then
            applyReach()
        end
        task.wait(0.05)
    end
end)

-- RenderStepped (spin, kill aura, strafe, HUD update)
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        updateTargetHUD(nil)
        return
    end
    -- SPINBOT
    if SPIN_ENABLED and isHoldingMouse1 then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            spinAngle = spinAngle + 0.3
            tool.Grip = CFrame.new(0, 0, 0) * CFrame.Angles(0, spinAngle, math.rad(90))
        end
    elseif not isHoldingMouse1 then
        spinAngle = 0
    end
    -- KILL AURA & TARGET STRAFE
    if KILL_AURA_ENABLED then
        currentTarget = getClosestPlayer()
        if currentTarget and currentTarget.Character then
            local root = char:FindFirstChild("HumanoidRootPart")
            local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
            if root and targetRoot then
                if STRAFE_ENABLED then
                    strafeAngle = strafeAngle + math.rad(STRAFE_SPEED)
                    local offsetX = math.cos(strafeAngle) * STRAFE_RADIUS
                    local offsetZ = math.sin(strafeAngle) * STRAFE_RADIUS
                    local strafePosition = targetRoot.Position + Vector3.new(offsetX, 0, offsetZ)
                    root.CFrame = CFrame.lookAt(Vector3.new(strafePosition.X, root.Position.Y, strafePosition.Z), Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z))
                else
                    root.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z))
                end
            end
        end
    else
        currentTarget = nil
    end
    updateTargetHUD(currentTarget)
end)

-- BindToClose (cleanup)
game:BindToClose(function()
    restoreAllHitboxes()
    for _, v in pairs(TargetHUD) do v:Remove() end
end)

print("🔥 Bridge Duel Cheat v2 Yüklendi - Kill Aura Auto Attack Aktif!")
