-- ui.lua
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Win = Rayfield:CreateWindow({
    Name = "Bridge Duel Cheat (Modüler)",
    LoadingTitle = "Bridge Duel",
    LoadingSubtitle = "Loader System"
})

local Tab = Win:CreateTab("Main")

Tab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Callback = function(v) ESP_ENABLED = v end
})

Tab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Callback = function(v) KILL_AURA = v end
})
