-- core.lua
Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualInputManager = game:GetService("VirtualInputManager")
Camera = workspace.CurrentCamera

if not Drawing then
    warn("Drawing API yok")
    return
end

getgenv().BD = {
    KillCount = getgenv().BD_KillCount or 0,
    DeadPlayers = getgenv().BD_DeadPlayers or {},
    LastHealths = getgenv().BD_LastHealths or {}
}

-- Feature flags
ESP_ENABLED = false
FLY_ENABLED = false
INFINITE_JUMP = false
KILL_AURA = false
AUTOCLICK = false
