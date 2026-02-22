-- ===== MAIN BOOTSTRAPPER (BAŞLATICI) =====
local repo_url = "https://raw.githubusercontent.com/wdawdadwaawd-byte/Bridge-Duel-Cheat/main/"

-- Ortak Hafıza (State): logic.lua ve ui.lua bu değişkenleri ortak kullanacak
getgenv().BD_KillCount = getgenv().BD_KillCount or 0
getgenv().BD_DeadPlayers = getgenv().BD_DeadPlayers or {}
getgenv().BD_LastHealths = getgenv().BD_LastHealths or {}

getgenv().BD_State = {
    -- Temel Değişkenler
    espEnabled = false,
    flyEnabled = false,
    flySpeed = 38,
    HITBOX_EXPAND_ENABLED = true,
    ROOTPART_SIZE_MULTIPLIER = 10,
    HEAD_SIZE_MULTIPLIER = 15,
    AUTOCLICK_ENABLED = false,
    AUTOCLICK_DELAY = 0.055,
    isHoldingMouse1 = false,
    KILL_AURA_ENABLED = false,
    KILL_AURA_RANGE = 20,
    currentTarget = nil,
    
    -- Advanced Combat
    STRAFE_ENABLED = false,
    STRAFE_SPEED = 5,
    STRAFE_RADIUS = 10,
    REACH_ENABLED = false,
    REACH_SIZE = 15,
    AUTO_BLOCK_ENABLED = false,
    SPIN_ENABLED = false,
    INFINITE_JUMP_ENABLED = false,
    
    -- Tablolar
    originalSizes = {},
    keysPressed = {},
    espObjects = {},
    
    -- Sayaçlar
    killCount = getgenv().BD_KillCount,
    deadPlayers = getgenv().BD_DeadPlayers,
    
    -- Fonksiyonları UI'dan çağırmak için
    Functions = {} 
}

print("⏳ Logic (Motor) yükleniyor...")
loadstring(game:HttpGet(repo_url .. "logic.lua", true))()

print("⏳ UI (Arayüz) yükleniyor...")
loadstring(game:HttpGet(repo_url .. "ui.lua", true))()

print("🔥 Bridge Duel Cheat Başarıyla Başlatıldı!")
