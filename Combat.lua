-- Combat.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera

local Config = getgenv().BDSettings
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/SENIN_KULLANICI_ADIN/SENIN_DEPON/main/src/Utils.lua"))()
local Visuals = loadstring(game:HttpGet("https://raw.githubusercontent.com/SENIN_KULLANICI_ADIN/SENIN_DEPON/main/src/Visuals.lua"))()

local originalSizes = {}
local bodyVelocity = nil
local flyConnection = nil

-- Hitbox Fonksiyonları
local function ExpandHitboxes()
    -- Eski scriptteki expandHitboxes içeriği, Config.HitboxExpandEnabled kullan.
end

local function RestoreAllHitboxes()
    -- Eski scriptteki restoreAllHitboxes içeriği
end

local function ApplyReach()
    -- Eski scriptteki applyReach içeriği
end

-- Otomatik Tıklama
local function TryAutoClick(fromKillAura)
    -- Eski scriptteki tryAutoClick içeriği (AutoBlockEnabled kontrolü Config üzerinden yapılacak)
end

-- Fly Fonksiyonları
local function UpdateFly()
    -- Eski scriptteki updateFly içeriği (Config.KeysPressed, Config.FlySpeed kullanılacak)
end

local function EnableFly()
    -- Eski scriptteki enableFly
end

local function DisableFly()
    -- Eski scriptteki disableFly
end

-- Input Yönetimi
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Config.IsHoldingMouse1 = true
    end
    
    if input.KeyCode == Enum.KeyCode.F then
        Config.FlyEnabled = not Config.FlyEnabled
        if Config.FlyEnabled then EnableFly() else DisableFly() end
    end
    
    if input.UserInputType == Enum.UserInputType.Keyboard then
        Config.KeysPressed[input.KeyCode] = true
    end
    
    if input.KeyCode == Enum.KeyCode.Space and Config.InfiniteJumpEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Config.IsHoldingMouse1 = false
    end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        Config.KeysPressed[input.KeyCode] = nil
    end
end)

-- Main Combat Loop (Hitbox, Reach, AutoClick)
task.spawn(function()
    while true do
        if Config.HitboxExpandEnabled then ExpandHitboxes() else RestoreAllHitboxes() end
        if Config.ReachEnabled then ApplyReach() end
        
        if Config.KillAuraEnabled and Config.CurrentTarget then
            TryAutoClick(true)
        end
        
        if Config.AutoClickEnabled and Config.IsHoldingMouse1 then
            TryAutoClick(false)
        end
        
        task.wait(Config.AutoClickDelay)
    end
end)

-- RenderStepped (Aura Yönelme, Spinbot, Strafe)
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        Visuals.UpdateTargetHUD(nil)
        return
    end
    
    if Config.SpinEnabled and Config.IsHoldingMouse1 then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            Config.SpinAngle = Config.SpinAngle + 0.3
            tool.Grip = CFrame.new(0, 0, 0) * CFrame.Angles(0, Config.SpinAngle, math.rad(90))
        end
    else
        Config.SpinAngle = 0
    end

    if Config.KillAuraEnabled then
        Config.CurrentTarget = Utils.GetClosestPlayer()
        if Config.CurrentTarget and Config.CurrentTarget.Character then
            local root = char:FindFirstChild("HumanoidRootPart")
            local targetRoot = Config.CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
            if root and targetRoot then
                if Config.StrafeEnabled then
                    Config.StrafeAngle = Config.StrafeAngle + math.rad(Config.StrafeSpeed)
                    local offsetX = math.cos(Config.StrafeAngle) * Config.StrafeRadius
                    local offsetZ = math.sin(Config.StrafeAngle) * Config.StrafeRadius
                    local strafePosition = targetRoot.Position + Vector3.new(offsetX, 0, offsetZ)
                    root.CFrame = CFrame.lookAt(Vector3.new(strafePosition.X, root.Position.Y, strafePosition.Z), Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z))
                else
                    root.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z))
                end
            end
        end
    else
        Config.CurrentTarget = nil
    end
    
    Visuals.UpdateTargetHUD(Config.CurrentTarget)
end)

return {}
