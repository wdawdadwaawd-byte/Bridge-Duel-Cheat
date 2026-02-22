local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera

-- ===== KILL SAYACI - YENİ SİSTEM =====
getgenv().BD_KillCount = getgenv().BD_KillCount or 0
getgenv().BD_DeadPlayers = getgenv().BD_DeadPlayers or {}
getgenv().BD_LastHealths = getgenv().BD_LastHealths or {}

if not Drawing then
    warn("Drawing API yok, ESP çalışmaz.")
    return
end

-- ===== TEMEL DEĞİŞKENLER =====
local espEnabled = false
local espObjects = {}
local flyEnabled = false
local flySpeed = 38
local bodyVelocity = nil
local flyConnection = nil
local keysPressed = {}
local HITBOX_EXPAND_ENABLED = true
local ROOTPART_SIZE_MULTIPLIER = 10
local HEAD_SIZE_MULTIPLIER = 15
local originalSizes = {}
local AUTOCLICK_ENABLED = false
local AUTOCLICK_DELAY = 0.055
local isHoldingMouse1 = false
local KILL_AURA_ENABLED = false
local KILL_AURA_RANGE = 20
local currentTarget = nil

-- ===== ADVANCED COMBAT DEĞİŞKENLERİ (YENİ) =====
local STRAFE_ENABLED = false
local STRAFE_SPEED = 5
local STRAFE_RADIUS = 10
local strafeAngle = 0
local REACH_ENABLED = false
local REACH_SIZE = 15
local AUTO_BLOCK_ENABLED = false

-- ===== KILL SAYACI DEĞİŞKENLERİ =====
local killCount = getgenv().BD_KillCount
local deadPlayers = getgenv().BD_DeadPlayers
local lastHealths = getgenv().BD_LastHealths

-- ===== HUD OLUŞTURMA =====
local TargetHUD = {
    Main = Drawing.new("Square"),
    Portrait = Drawing.new("Image"),
    Name = Drawing.new("Text"),
    Kills = Drawing.new("Text"),
    HealthBarBack = Drawing.new("Square"),
    HealthBarMain = Drawing.new("Square")
}
TargetHUD.Main.Thickness = 1
TargetHUD.Main.Filled = true
TargetHUD.Main.Color = Color3.fromRGB(30, 30, 30)
TargetHUD.Main.Transparency = 0.8
TargetHUD.Main.Size = Vector2.new(150, 65)
TargetHUD.Main.Visible = false
TargetHUD.Portrait.Size = Vector2.new(40, 40)
TargetHUD.Portrait.Visible = false
TargetHUD.Name.Size = 16
TargetHUD.Name.Color = Color3.new(1, 1, 1)
TargetHUD.Name.Center = false
TargetHUD.Name.Outline = true
TargetHUD.Name.Visible = false
TargetHUD.Kills.Size = 14
TargetHUD.Kills.Color = Color3.fromRGB(255, 215, 0)
TargetHUD.Kills.Center = false
TargetHUD.Kills.Outline = true
TargetHUD.Kills.Visible = false
TargetHUD.HealthBarBack.Size = Vector2.new(90, 8)
TargetHUD.HealthBarBack.Color = Color3.fromRGB(50, 0, 0)
TargetHUD.HealthBarBack.Filled = true
TargetHUD.HealthBarBack.Visible = false
TargetHUD.HealthBarMain.Size = Vector2.new(0, 8)
TargetHUD.HealthBarMain.Color = Color3.fromRGB(255, 0, 0)
TargetHUD.HealthBarMain.Filled = true
TargetHUD.HealthBarMain.Visible = false

local SPIN_ENABLED = false
local spinAngle = 0
local lastTargetUserId = nil
local cachedPortraitData = nil

-- ===== YENİ: INFINITE JUMP DEĞİŞKENİ =====
local INFINITE_JUMP_ENABLED = false

-- ===== YARDIMCI FONKSİYONLAR =====
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

local function expandHitboxes()
    if not HITBOX_EXPAND_ENABLED then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if not isEnemy(player) then continue end
        local char = player.Character
        if not char or not isCharacterValid(char) then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not root or not head then continue end
        if not originalSizes[player] then
            originalSizes[player] = { Root = root.Size, Head = head.Size }
        end
        pcall(function()
            if root.Size ~= originalSizes[player].Root * ROOTPART_SIZE_MULTIPLIER then
                root.Size = originalSizes[player].Root * ROOTPART_SIZE_MULTIPLIER
            end
            if head.Size ~= originalSizes[player].Head * HEAD_SIZE_MULTIPLIER then
                head.Size = originalSizes[player].Head * HEAD_SIZE_MULTIPLIER
            end
            root.Transparency = 1
            head.Transparency = 1
            root.CanCollide = false
            head.CanCollide = false
            root.Massless = true
            head.Massless = true
        end)
    end
end

local function restoreHitboxesForPlayer(player)
    local sizes = originalSizes[player]
    if not sizes then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    pcall(function()
        if root and sizes.Root then
            root.Size = sizes.Root
            root.Transparency = 0
            root.CanCollide = true
            root.Massless = false
        end
        if head and sizes.Head then
            head.Size = sizes.Head
            head.Transparency = 0
            head.CanCollide = true
            head.Massless = false
        end
    end)
    originalSizes[player] = nil
end

local function restoreAllHitboxes()
    for player in pairs(originalSizes) do
        restoreHitboxesForPlayer(player)
    end
    originalSizes = {}
end

local function applyReach()
    if not REACH_ENABLED then return end
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if tool then
        local handle = tool:FindFirstChild("Handle")
        if handle then
            handle.Size = Vector3.new(REACH_SIZE, REACH_SIZE, REACH_SIZE)
            handle.Transparency = 1
            handle.Massless = true
        end
    end
end

-- ===== KILL SAYACI FONKSİYONU =====
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

-- HITBOX VE REACH DÖNGÜSÜ
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
    -- KILL AURA & TARGET STRAFE (DEĞİŞTİRİLDİ - Artık sol tık şartı yok)
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

-- ESP FONKSİYONLARI (değişmedi)
local function createEspForPlayer(player)
    local esp = { lines = {} }
    for i = 1, 8 do
        local line = Drawing.new("Line")
        line.Color = Color3.new(1, 0, 0)
        line.Thickness = 2.5
        line.Transparency = 1
        line.Visible = false
        esp.lines[i] = line
    end
    esp.name = Drawing.new("Text")
    esp.name.Color = Color3.new(1,1,1)
    esp.name.Size = 15
    esp.name.Center = true
    esp.name.Outline = true
    esp.name.Font = 2
    esp.name.Visible = false
    esp.distance = Drawing.new("Text")
    esp.distance.Color = Color3.new(0.8,0.8,0.8)
    esp.distance.Size = 13
    esp.distance.Center = true
    esp.distance.Outline = true
    esp.distance.Font = 2
    esp.distance.Visible = false
    esp.healthBar = Drawing.new("Square")
    esp.healthBar.Filled = true
    esp.healthBar.Transparency = 1
    esp.healthBar.Color = Color3.new(0,1,0)
    esp.healthBar.Visible = false
    return esp
end

local function removeEsp(esp)
    if not esp then return end
    for _, line in ipairs(esp.lines) do if line then line:Remove() end end
    if esp.name then esp.name:Remove() end
    if esp.distance then esp.distance:Remove() end
    if esp.healthBar then esp.healthBar:Remove() end
end

local function updateEsp()
    if not espEnabled then
        for _, esp in pairs(espObjects) do removeEsp(esp) end
        espObjects = {}
        return
    end
    local seenPlayers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not (char and isCharacterValid(char)) then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not (root and head) then continue end
        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.6,0))
        if onScreen and headPos.Z > 0 then
            seenPlayers[player] = true
            if not espObjects[player] then espObjects[player] = createEspForPlayer(player) end
            local esp = espObjects[player]
            local height = (rootPos.Y - headPos.Y) * 1.05
            local width = height * 0.5
            local x, y = rootPos.X, rootPos.Y
            local tl = Vector2.new(x - width/2, y - height/2)
            local tr = Vector2.new(x + width/2, y - height/2)
            local bl = Vector2.new(x - width/2, y + height/2)
            local br = Vector2.new(x + width/2, y + height/2)
            local seg = width / 4
            esp.lines[1].From = tl; esp.lines[1].To = tl + Vector2.new(seg, 0)
            esp.lines[2].From = tl; esp.lines[2].To = tl + Vector2.new(0, seg)
            esp.lines[3].From = tr; esp.lines[3].To = tr - Vector2.new(seg, 0)
            esp.lines[4].From = tr; esp.lines[4].To = tr + Vector2.new(0, seg)
            esp.lines[5].From = bl; esp.lines[5].To = bl + Vector2.new(seg, 0)
            esp.lines[6].From = bl; esp.lines[6].To = bl - Vector2.new(0, seg)
            esp.lines[7].From = br; esp.lines[7].To = br - Vector2.new(seg, 0)
            esp.lines[8].From = br; esp.lines[8].To = br - Vector2.new(0, seg)
            for _, line in ipairs(esp.lines) do line.Visible = true end
            esp.name.Text = player.Name
            esp.name.Position = Vector2.new(x, tl.Y - 18)
            esp.name.Visible = true
            local dist = (LocalPlayer.Character and (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 999
            esp.distance.Text = math.floor(dist) .. "m"
            esp.distance.Position = Vector2.new(x, br.Y + 4)
            esp.distance.Visible = true
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                esp.healthBar.Size = Vector2.new(3, height * hp)
                esp.healthBar.Position = Vector2.new(tl.X - 8, br.Y - height * hp)
                esp.healthBar.Color = Color3.new(1 - hp, hp, 0)
                esp.healthBar.Visible = true
            end
        else
            if espObjects[player] then
                removeEsp(espObjects[player])
                espObjects[player] = nil
            end
        end
    end
    for player, esp in pairs(espObjects) do
        if not seenPlayers[player] then
            removeEsp(esp)
            espObjects[player] = nil
        end
    end
end

-- FLY, AUTOCLICK, INPUT (hiç dokunmadım, aynı kaldı)
local function updateFly()
    if not flyEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root or not bodyVelocity then return end
    local cam = Camera
    local moveDir = Vector3.new(0,0,0)
    if keysPressed[Enum.KeyCode.W] then moveDir += cam.CFrame.LookVector end
    if keysPressed[Enum.KeyCode.S] then moveDir -= cam.CFrame.LookVector end
    if keysPressed[Enum.KeyCode.A] then moveDir -= cam.CFrame.RightVector end
    if keysPressed[Enum.KeyCode.D] then moveDir += cam.CFrame.RightVector end
    if keysPressed[Enum.KeyCode.Space] then moveDir += Vector3.new(0,1,0) end
    if keysPressed[Enum.KeyCode.LeftShift] then moveDir -= Vector3.new(0,1,0) end
    if moveDir.Magnitude > 0 then
        bodyVelocity.Velocity = moveDir.Unit * flySpeed
    else
        bodyVelocity.Velocity = Vector3.zero
    end
    root.CFrame = CFrame.lookAt(root.Position, root.Position + cam.CFrame.LookVector)
end

local function enableFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root
    flyConnection = RunService.RenderStepped:Connect(updateFly)
end

local function disableFly()
    flyEnabled = false
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end
end

local function tryAutoClick(fromKillAura)
    fromKillAura = fromKillAura or false
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if not tool then return end
    pcall(function()
        tool:Activate()
    end)
    local activateRemote = tool:FindFirstChild("Activate") or tool:FindFirstChildWhichIsA("RemoteEvent")
    if activateRemote and activateRemote:IsA("RemoteEvent") then
        pcall(function()
            activateRemote:FireServer()
        end)
    end
    if AUTO_BLOCK_ENABLED then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
        end)
    end
end

-- Eski autoclicker (sadece sol tık tutunca)
RunService.Stepped:Connect(function()
    if AUTOCLICK_ENABLED and isHoldingMouse1 then
        tryAutoClick(false)
        task.wait(AUTOCLICK_DELAY)
    end
end)

-- ===== YENİ: KILL AURA OTOMATİK VURMA (SAĞ TIK DEFANS YAPSA BİLE VURUR) =====
task.spawn(function()
    while true do
        if KILL_AURA_ENABLED and currentTarget then
            tryAutoClick(true) -- otomatik vuruş
        end
        task.wait(AUTOCLICK_DELAY)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isHoldingMouse1 = true
        if AUTOCLICK_ENABLED then
            tryAutoClick(false)
        end
    end
    if input.KeyCode == Enum.KeyCode.F then
        flyEnabled = not flyEnabled
        if flyEnabled then enableFly() else disableFly() end
    end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keysPressed[input.KeyCode] = true
    end
    -- ===== YENİ: INFINITE JUMP =====
    if input.KeyCode == Enum.KeyCode.Space and INFINITE_JUMP_ENABLED then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isHoldingMouse1 = false
    end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keysPressed[input.KeyCode] = nil
    end
end)

-- ===== ARAYÜZ (RAYFIELD) =====
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Bridge Duel Cheat (2026) v2",
   LoadingTitle = "Bridge Duel Stabil Cheat",
   LoadingSubtitle = "Advanced Combat + Kill Aura",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "BridgeDuelCheat"
   }
})

local ContextTab = Window:CreateTab("Context", 4483362458)
local InventoryTab = Window:CreateTab("Inventory", 4483362458)
local InsurgencyTab = Window:CreateTab("Insurgency", 4483362458)
local CalloutTab = Window:CreateTab("Callout", 4483362458)

ContextTab:CreateSection("Visuals (ESP)")
ContextTab:CreateToggle({
   Name = "ESP Aç/Kapat",
   CurrentValue = espEnabled,
   Callback = function(Value)
      espEnabled = Value
      if espEnabled then
         RunService:BindToRenderStep("ESPUpdate", Enum.RenderPriority.Camera.Value + 1, updateEsp)
      else
         RunService:UnbindFromRenderStep("ESPUpdate")
         for _, esp in pairs(espObjects) do removeEsp(esp) end
         espObjects = {}
      end
   end,
})

ContextTab:CreateSection("Movement (Fly)")
ContextTab:CreateToggle({
   Name = "Fly Aç/Kapat (F tuşu da çalışır)",
   CurrentValue = flyEnabled,
   Callback = function(Value)
      flyEnabled = Value
      if flyEnabled then enableFly() else disableFly() end
   end,
})
ContextTab:CreateSlider({
   Name = "Fly Hızı",
   Range = {10, 100},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = flySpeed,
   Callback = function(Value)
      flySpeed = Value
   end,
})
-- ===== YENİ: INFINITE JUMP TOGGLE =====
ContextTab:CreateToggle({
   Name = "Infinite Jump Aç/Kapat",
   CurrentValue = INFINITE_JUMP_ENABLED,
   Callback = function(Value)
      INFINITE_JUMP_ENABLED = Value
   end,
})

InventoryTab:CreateSection("Hitbox Tools")
InventoryTab:CreateToggle({
   Name = "Hitbox Expander (Gizli, Head 15x)",
   CurrentValue = HITBOX_EXPAND_ENABLED,
   Callback = function(Value)
      HITBOX_EXPAND_ENABLED = Value
      if not HITBOX_EXPAND_ENABLED then restoreAllHitboxes() end
   end,
})
InventoryTab:CreateButton({
   Name = "Hitbox'ları Resetle",
   Callback = function()
      restoreAllHitboxes()
      Rayfield:Notify({
         Title = "Hitbox Reset",
         Content = "Tüm hitbox'lar orijinal haline döndü.",
         Duration = 3
      })
   end,
})

InsurgencyTab:CreateSection("Combat & Kill Aura HUD")
InsurgencyTab:CreateToggle({
   Name = "Kill Aura & Target HUD (Aim Odaklı)",
   CurrentValue = false,
   Callback = function(Value)
      KILL_AURA_ENABLED = Value
   end,
})
InsurgencyTab:CreateSlider({
   Name = "Kill Aura Menzili",
   Range = {10, 50},
   Increment = 1,
   Suffix = "Studs",
   CurrentValue = KILL_AURA_RANGE,
   Callback = function(Value)
      KILL_AURA_RANGE = Value
   end,
})

InsurgencyTab:CreateSection("Advanced Combat (YENİ)")
InsurgencyTab:CreateToggle({
   Name = "Target Strafe (Hedefin etrafında dön)",
   CurrentValue = STRAFE_ENABLED,
   Callback = function(Value)
      STRAFE_ENABLED = Value
   end,
})
InsurgencyTab:CreateSlider({
   Name = "Strafe Hızı",
   Range = {1, 20},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = STRAFE_SPEED,
   Callback = function(Value)
      STRAFE_SPEED = Value
   end,
})
InsurgencyTab:CreateSlider({
   Name = "Strafe Yarıçapı (Mesafe)",
   Range = {5, 25},
   Increment = 1,
   Suffix = "Studs",
   CurrentValue = STRAFE_RADIUS,
   Callback = function(Value)
      STRAFE_RADIUS = Value
   end,
})
InsurgencyTab:CreateToggle({
   Name = "Reach (Kılıç Menzilini Büyüt)",
   CurrentValue = REACH_ENABLED,
   Callback = function(Value)
      REACH_ENABLED = Value
   end,
})
InsurgencyTab:CreateToggle({
   Name = "Auto-Block (Vururken Sağ Tık Basar)",
   CurrentValue = AUTO_BLOCK_ENABLED,
   Callback = function(Value)
      AUTO_BLOCK_ENABLED = Value
   end,
})

InsurgencyTab:CreateSection("Extras")
InsurgencyTab:CreateToggle({
   Name = "Autoclicker Aç/Kapat (Sol Tık tutunca)",
   CurrentValue = AUTOCLICK_ENABLED,
   Callback = function(Value)
      AUTOCLICK_ENABLED = Value
   end,
})
InsurgencyTab:CreateToggle({
   Name = "Yatay Kılıç Döndürme",
   CurrentValue = false,
   Callback = function(Value)
      SPIN_ENABLED = Value
   end,
})

CalloutTab:CreateSection("Kill Sayacı")
CalloutTab:CreateButton({
   Name = "Kill Sayacını Sıfırla",
   Callback = function()
      getgenv().BD_KillCount = 0
      killCount = 0
      getgenv().BD_DeadPlayers = {}
      deadPlayers = {}
      Rayfield:Notify({
         Title = "✅ Sıfırlandı!",
         Content = "Kill sayısı sıfırlandı.",
         Duration = 3
      })
   end,
})
CalloutTab:CreateParagraph({Title = "📊 Güncel Kill: " .. tostring(killCount), Content = "Gelişmiş Combat ile rakipleri darmadağın et!"})

game:BindToClose(function()
   restoreAllHitboxes()
   for _, v in pairs(TargetHUD) do v:Remove() end
end)

Rayfield:Notify({
   Title = "🚀 Yüklendi!",
   Content = "Kill Aura artık SAĞ TIK (defans) yapsan bile OTOMATİK vuruyor!",
   Duration = 6.5,
   Image = 4483362458
})

print("🔥 Bridge Duel Cheat v2 Yüklendi - Kill Aura Auto Attack Aktif!")
