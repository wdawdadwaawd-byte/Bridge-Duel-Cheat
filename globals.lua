local Globals = {
    -- State
    espEnabled = false,
    flyEnabled = false,
    flySpeed = 38,
    HITBOX_EXPAND_ENABLED = true,
    AUTOCLICK_ENABLED = false,
    KILL_AURA_ENABLED = false,
    KILL_AURA_RANGE = 20,
    STRAFE_ENABLED = false,
    REACH_ENABLED = false,
    INFINITE_JUMP_ENABLED = false,
    
    -- Counter & Cache
    KillCount = 0,
    DeadPlayers = {},
    OriginalSizes = {},
    KeysPressed = {}
}
return Globals
