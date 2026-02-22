-- Config.lua
local Config = {
    ESPEnabled = false,
    FlyEnabled = false,
    FlySpeed = 38,
    InfiniteJumpEnabled = false,
    HitboxExpandEnabled = true,
    RootSizeMultiplier = 10,
    HeadSizeMultiplier = 15,
    AutoClickEnabled = false,
    AutoClickDelay = 0.055,
    KillAuraEnabled = false,
    KillAuraRange = 20,
    StrafeEnabled = false,
    StrafeSpeed = 5,
    StrafeRadius = 10,
    ReachEnabled = false,
    ReachSize = 15,
    AutoBlockEnabled = false,
    SpinEnabled = false,
    
    -- State (Durumlar)
    IsHoldingMouse1 = false,
    KeysPressed = {},
    CurrentTarget = nil,
    SpinAngle = 0,
    StrafeAngle = 0,
    
    -- Kill Counter State
    KillCount = getgenv().BD_KillCount or 0,
    DeadPlayers = getgenv().BD_DeadPlayers or {}
}

getgenv().BDSettings = Config
return Config
