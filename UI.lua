-- UI.lua
local Config = getgenv().BDSettings
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Bridge Duel Cheat (2026) v2",
   LoadingTitle = "Bridge Duel Stabil Cheat",
   LoadingSubtitle = "Modular GitHub Version",
   ConfigurationSaving = { Enabled = false }
})

local ContextTab = Window:CreateTab("Context", 4483362458)
-- Sekmeler ve sliderlar buraya (Eski Rayfield kodunu buraya taşı).
-- Callback fonksiyonlarının içinde örn: `Config.ESPEnabled = Value` yapacaksın.

ContextTab:CreateToggle({
   Name = "ESP Aç/Kapat",
   CurrentValue = Config.ESPEnabled,
   Callback = function(Value)
      Config.ESPEnabled = Value
   end,
})

-- Diğer sekmeler...

Rayfield:Notify({
   Title = "🚀 Yüklendi!",
   Content = "Modüler altyapı başarıyla başlatıldı!",
   Duration = 6.5,
   Image = 4483362458
})

return Window
