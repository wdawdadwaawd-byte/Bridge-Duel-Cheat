-- Variables and HUD
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera

-- KILL SAYACI
getgenv().BD_KillCount = getgenv().BD_KillCount or 0
getgenv().BD_DeadPlayers = getgenv().BD_DeadPlayers or {}
getgenv().BD_LastHealths = getgenv().BD_LastHealths or {}

if not Drawing then
    warn("Drawing API yok, ESP çalışmaz.")
    return
end

-- TEMEL DEĞİŞKENLER
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

-- ADVANCED COMBAT
local STRAFE_ENABLED = false
local STRAFE_SPEED = 5
local STRAFE_RADIUS = 10
local strafeAngle = 0
local REACH_ENABLED = false
local REACH_SIZE = 15
local AUTO_BLOCK_ENABLED = false

-- KILL SAYACI
local killCount = getgenv().BD_KillCount
local deadPlayers = getgenv().BD_DeadPlayers
local lastHealths = getgenv().BD_LastHealths

-- HUD
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

-- INFINITE JUMP
local INFINITE_JUMP_ENABLED = false
