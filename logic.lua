local State = getgenv().BD_State
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera

if not Drawing then
    warn("Drawing API yok, ESP çalışmaz.")
    return
end

local bodyVelocity = nil
local flyConnection = nil
local spinAngle = 0
local strafeAngle = 0
local lastTargetUserId = nil
local cachedPortraitData = nil

-- ===== HUD OLUŞTURMA =====
local TargetHUD = {
    Main = Drawing.new("Square"), Portrait = Drawing.new("Image"),
    Name = Drawing.new("Text"), Kills = Drawing.new("Text"),
    HealthBarBack = Drawing.new("Square"), HealthBarMain = Drawing.new("Square")
}
TargetHUD.Main.Thickness = 1; TargetHUD.Main.Filled = true; TargetHUD.Main.Color = Color3.fromRGB(30, 30, 30)
TargetHUD.Main.Transparency = 0.8; TargetHUD.Main.Size = Vector2.new(150, 65); TargetHUD.Main.Visible = false
TargetHUD.Portrait.Size = Vector2.new(40, 40); TargetHUD.Portrait.Visible = false
TargetHUD.Name.Size = 16; TargetHUD.Name.Color = Color3.new(1, 1, 1); TargetHUD.Name.Center = false; TargetHUD.Name.Outline = true; TargetHUD.Name.Visible = false
TargetHUD.Kills.Size = 14; TargetHUD.Kills.Color = Color3.fromRGB(255, 215, 0); TargetHUD.Kills.Center = false; TargetHUD.Kills.Outline = true; TargetHUD.Kills.Visible = false
TargetHUD.HealthBarBack.Size = Vector2.new(90, 8); TargetHUD.HealthBarBack.Color = Color3.fromRGB(50, 0, 0); TargetHUD.HealthBarBack.Filled = true; TargetHUD.HealthBarBack.Visible = false
TargetHUD.HealthBarMain.Size = Vector2.new(0, 8); TargetHUD.HealthBarMain.Color = Color3.fromRGB(255, 0, 0); TargetHUD.HealthBarMain.Filled = true; TargetHUD.HealthBarMain.Visible = false

-- ===== YARDIMCI FONKSİYONLAR =====
local function isCharacterValid(character)
    return character:FindFirstChildOfClass("Humanoid") and character:FindFirstChild("HumanoidRootPart")
end

local function isEnemy(player) return player ~= LocalPlayer end

local function getClosestPlayer()
    local closestPlayer, shortestDistance = nil, State.KILL_AURA_RANGE
    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) and player.Character and isCharacterValid(player.Character) then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortestDistance then closestPlayer = player; shortestDistance = dist end
        end
    end
    return closestPlayer
end

local function expandHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        if not isEnemy(player) then continue end
        local char = player.Character
        if not char or not isCharacterValid(char) then continue end
        local root, head = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Head")
        if not root or not head then continue end
        
        if not State.originalSizes[player] then
            State.originalSizes[player] = { Root = root.Size, Head = head.Size }
        end
        pcall(function()
            if root.Size ~= State.originalSizes[player].Root * State.ROOTPART_SIZE_MULTIPLIER then root.Size = State.originalSizes[player].Root * State.ROOTPART_SIZE_MULTIPLIER end
            if head.Size ~= State.originalSizes[player].Head * State.HEAD_SIZE_MULTIPLIER then head.Size = State.originalSizes[player].Head * State.HEAD_SIZE_MULTIPLIER end
            root.Transparency, head.Transparency = 1, 1
            root.CanCollide, head.CanCollide = false, false
            root.Massless, head.Massless = true, true
        end)
    end
end

State.Functions.restoreAllHitboxes = function()
    for player, sizes in pairs(State.originalSizes) do
        local char = player.Character
        if char then
            local root, head = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Head")
            pcall(function()
                if root and sizes.Root then root.Size = sizes.Root; root.Transparency = 0; root.CanCollide = true; root.Massless = false end
                if head and sizes.Head then head.Size = sizes.Head; head.Transparency = 0; head.CanCollide = true; head.Massless = false end
            end)
        end
    end
    State.originalSizes = {}
end

local function applyReach()
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if tool and tool:FindFirstChild("Handle") then
        local handle = tool.Handle
        handle.Size = Vector3.new(State.REACH_SIZE, State.REACH_SIZE, State.REACH_SIZE)
        handle.Transparency, handle.Massless = 1, true
    end
end

-- ===== KILL SAYACI =====
local function checkForKill(target)
    if not target or not target.Character then return end
    local hum = target.Character:FindFirstChildWhichIsA("Humanoid")
    local userId = target.UserId
    if hum and hum.Health <= 0.1 then
        if not State.deadPlayers[userId] then
            getgenv().BD_KillCount = getgenv().BD_KillCount + 1
            State.killCount = getgenv().BD_KillCount
            State.deadPlayers[userId] = true
            task.delay(5, function() State.deadPlayers[userId] = nil; getgenv().BD_DeadPlayers = State.deadPlayers end)
        end
    end
end

local function updateTargetHUD(target)
    if not State.KILL_AURA_ENABLED or not target or not target.Character then
        if TargetHUD.Main.Visible then
            for _, v in pairs(TargetHUD) do v.Visible = false end
            lastTargetUserId, cachedPortraitData = nil, nil
        end
        return
    end
    local hum = target.Character:FindFirstChildWhichIsA("Humanoid")
    checkForKill(target)
    if not hum or hum.Health <= 0 then
        if TargetHUD.Main.Visible then for _, v in pairs(TargetHUD) do v.Visible = false end end
        return
    end
    
    if lastTargetUserId ~= target.UserId then
        lastTargetUserId = target.UserId
        task.spawn(function()
            local s, r = pcall(function() return game:HttpGetAsync("https://www.roblox.com/headshot-thumbnail/image?userId=" .. target.UserId .. "&width=420&height=420&format=png") end)
            if s and r and #r > 100 then cachedPortraitData = r; TargetHUD.Portrait.Data = cachedPortraitData else TargetHUD.Portrait.Data = "" end
        end)
    end
    
    local center = Camera.ViewportSize / 2
    local hudPos = center + Vector2.new(80, 80)
    TargetHUD.Main.Position = hudPos
    TargetHUD.Portrait.Position = hudPos + Vector2.new(8, 8)
    TargetHUD.Name.Position = hudPos + Vector2.new(55, 10)
    TargetHUD.Kills.Position = hudPos + Vector2.new(55, 45)
    TargetHUD.HealthBarBack.Position = hudPos + Vector2.new(55, 32)
    TargetHUD.HealthBarMain.Position = hudPos + Vector2.new(55, 32)
    
    TargetHUD.Name.Text = target.Name .. " [" .. math.floor(hum.Health) .. " HP]"
    TargetHUD.Kills.Text = "KILLS: " .. tostring(State.killCount)
    local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
    TargetHUD.HealthBarMain.Size = Vector2.new(90 * hpPercent, 10)
    TargetHUD.HealthBarMain.Color = Color3.fromHSV(0.3 * hpPercent, 0.9, 0.9)
    
    if not TargetHUD.Main.Visible then for _, v in pairs(TargetHUD) do v.Visible = true end end
end

-- ===== DÖNGÜLER =====
task.spawn(function()
    while true do
        if State.HITBOX_EXPAND_ENABLED then expandHitboxes() else State.Functions.restoreAllHitboxes() end
        if State.REACH_ENABLED then applyReach() end
        task.wait(0.05)
    end
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then updateTargetHUD(nil); return end
    
    if State.SPIN_ENABLED and State.isHoldingMouse1 then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then spinAngle += 0.3; tool.Grip = CFrame.new(0, 0, 0) * CFrame.Angles(0, spinAngle, math.rad(90)) end
    elseif not State.isHoldingMouse1 then spinAngle = 0 end
    
    if State.KILL_AURA_ENABLED then
        State.currentTarget = getClosestPlayer()
        if State.currentTarget and State.currentTarget.Character then
            local root = char:FindFirstChild("HumanoidRootPart")
            local targetRoot = State.currentTarget.Character:FindFirstChild("HumanoidRootPart")
            if root and targetRoot then
                if State.STRAFE_ENABLED then
                    strafeAngle += math.rad(State.STRAFE_SPEED)
                    local offsetX, offsetZ = math.cos(strafeAngle) * State.STRAFE_RADIUS, math.sin(strafeAngle) * State.STRAFE_RADIUS
                    local strafePosition = targetRoot.Position + Vector3.new(offsetX, 0, offsetZ)
                    root.CFrame = CFrame.lookAt(Vector3.new(strafePosition.X, root.Position.Y, strafePosition.Z), Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z))
                else
                    root.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z))
                end
            end
        end
    else
        State.currentTarget = nil
    end
    updateTargetHUD(State.currentTarget)
end)

-- ===== ESP SİSTEMİ =====
local function removeEsp(esp)
    if not esp then return end
    for _, line in ipairs(esp.lines) do if line then line:Remove() end end
    if esp.name then esp.name:Remove() end
    if esp.distance then esp.distance:Remove() end
    if esp.healthBar then esp.healthBar:Remove() end
end

State.Functions.clearEsp = function()
    for _, esp in pairs(State.espObjects) do removeEsp(esp) end
    State.espObjects = {}
end

State.Functions.updateEsp = function()
    if not State.espEnabled then State.Functions.clearEsp(); return end
    local seenPlayers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not (char and isCharacterValid(char)) then continue end
        local root, head = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Head")
        if not (root and head) then continue end
        
        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.6,0))
        
        if onScreen and headPos.Z > 0 then
            seenPlayers[player] = true
            if not State.espObjects[player] then
                local esp = { lines = {} }
                for i=1,8 do local l = Drawing.new("Line"); l.Color = Color3.new(1,0,0); l.Thickness = 2.5; l.Visible = false; esp.lines[i] = l end
                esp.name = Drawing.new("Text"); esp.name.Color = Color3.new(1,1,1); esp.name.Size = 15; esp.name.Center = true; esp.name.Outline = true; esp.name.Visible = false
                esp.distance = Drawing.new("Text"); esp.distance.Color = Color3.new(0.8,0.8,0.8); esp.distance.Size = 13; esp.distance.Center = true; esp.distance.Outline = true; esp.distance.Visible = false
                esp.healthBar = Drawing.new("Square"); esp.healthBar.Filled = true; esp.healthBar.Color = Color3.new(0,1,0); esp.healthBar.Visible = false
                State.espObjects[player] = esp
            end
            local esp = State.espObjects[player]
            local height = (rootPos.Y - headPos.Y) * 1.05; local width = height * 0.5
            local x, y = rootPos.X, rootPos.Y
            local tl, tr, bl, br = Vector2.new(x-width/2, y-height/2), Vector2.new(x+width/2, y-height/2), Vector2.new(x-width/2, y+height/2), Vector2.new(x+width/2, y+height/2)
            local seg = width / 4
            esp.lines[1].From = tl; esp.lines[1].To = tl + Vector2.new(seg, 0); esp.lines[2].From = tl; esp.lines[2].To = tl + Vector2.new(0, seg)
            esp.lines[3].From = tr; esp.lines[3].To = tr - Vector2.new(seg, 0); esp.lines[4].From = tr; esp.lines[4].To = tr + Vector2.new(0, seg)
            esp.lines[5].From = bl; esp.lines[5].To = bl + Vector2.new(seg, 0); esp.lines[6].From = bl; esp.lines[6].To = bl - Vector2.new(0, seg)
            esp.lines[7].From = br; esp.lines[7].To = br - Vector2.new(seg, 0); esp.lines[8].From = br; esp.lines[8].To = br - Vector2.new(0, seg)
            for _, line in ipairs(esp.lines) do line.Visible = true end
            esp.name.Text = player.Name; esp.name.Position = Vector2.new(x, tl.Y - 18); esp.name.Visible = true
            esp.distance.Text = math.floor((LocalPlayer.Character and (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 999) .. "m"
            esp.distance.Position = Vector2.new(x, br.Y + 4); esp.distance.Visible = true
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                esp.healthBar.Size = Vector2.new(3, height * hp); esp.healthBar.Position = Vector2.new(tl.X - 8, br.Y - height * hp)
                esp.healthBar.Color = Color3.new(1-hp, hp, 0); esp.healthBar.Visible = true
            end
        else
            if State.espObjects[player] then removeEsp(State.espObjects[player]); State.espObjects[player] = nil end
        end
    end
    for p, e in pairs(State.espObjects) do if not seenPlayers[p] then removeEsp(e); State.espObjects[p] = nil end end
end

-- ===== FLY VE INPUT SİSTEMİ =====
local function updateFly()
    if not State.flyEnabled then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not bodyVelocity then return end
    local moveDir = Vector3.new(0,0,0)
    if State.keysPressed[Enum.KeyCode.W] then moveDir += Camera.CFrame.LookVector end
    if State.keysPressed[Enum.KeyCode.S] then moveDir -= Camera.CFrame.LookVector end
    if State.keysPressed[Enum.KeyCode.A] then moveDir -= Camera.CFrame.RightVector end
    if State.keysPressed[Enum.KeyCode.D] then moveDir += Camera.CFrame.RightVector end
    if State.keysPressed[Enum.KeyCode.Space] then moveDir += Vector3.new(0,1,0) end
    if State.keysPressed[Enum.KeyCode.LeftShift] then moveDir -= Vector3.new(0,1,0) end
    if moveDir.Magnitude > 0 then bodyVelocity.Velocity = moveDir.Unit * State.flySpeed else bodyVelocity.Velocity = Vector3.zero end
    root.CFrame = CFrame.lookAt(root.Position, root.Position + Camera.CFrame.LookVector)
end

State.Functions.enableFly = function()
    local char = LocalPlayer.Character
    if not char then return end
    local root, hum = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    bodyVelocity = Instance.new("BodyVelocity"); bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyVelocity.Velocity = Vector3.zero; bodyVelocity.Parent = root
    flyConnection = RunService.RenderStepped:Connect(updateFly)
end

State.Functions.disableFly = function()
    State.flyEnabled = false
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.GettingUp) end
end

local function tryAutoClick(fromKillAura)
    local char = LocalPlayer.Character
    local tool = char and char:FindFirstChildWhichIsA("Tool")
    if not tool then return end
    pcall(function() tool:Activate() end)
    local remote = tool:FindFirstChild("Activate") or tool:FindFirstChildWhichIsA("RemoteEvent")
    if remote then pcall(function() remote:FireServer() end) end
    if State.AUTO_BLOCK_ENABLED then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
        end)
    end
end

RunService.Stepped:Connect(function()
    if State.AUTOCLICK_ENABLED and State.isHoldingMouse1 then tryAutoClick(false); task.wait(State.AUTOCLICK_DELAY) end
end)

task.spawn(function()
    while true do
        if State.KILL_AURA_ENABLED and State.currentTarget then tryAutoClick(true) end
        task.wait(State.AUTOCLICK_DELAY)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        State.isHoldingMouse1 = true
        if State.AUTOCLICK_ENABLED then tryAutoClick(false) end
    end
    if input.KeyCode == Enum.KeyCode.F then
        State.flyEnabled = not State.flyEnabled
        if State.flyEnabled then State.Functions.enableFly() else State.Functions.disableFly() end
    end
    if input.UserInputType == Enum.UserInputType.Keyboard then State.keysPressed[input.KeyCode] = true end
    if input.KeyCode == Enum.KeyCode.Space and State.INFINITE_JUMP_ENABLED then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then State.isHoldingMouse1 = false end
    if input.UserInputType == Enum.UserInputType.Keyboard then State.keysPressed[input.KeyCode] = nil end
end)

State.Functions.resetKills = function()
    getgenv().BD_KillCount = 0; State.killCount = 0
    getgenv().BD_DeadPlayers = {}; State.deadPlayers = {}
end

game:BindToClose(function()
    State.Functions.restoreAllHitboxes()
    for _, v in pairs(TargetHUD) do v:Remove() end
end)
