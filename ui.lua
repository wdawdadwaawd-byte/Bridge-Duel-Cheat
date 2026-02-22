local State = getgenv().BD_State
local RunService = game:GetService("RunService")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Bridge Duel Cheat (2026) v2",
   LoadingTitle = "Bridge Duel Stabil Cheat",
   LoadingSubtitle = "Advanced Combat + Kill Aura",
   ConfigurationSaving = { Enabled = false, FolderName = nil, FileName = "BridgeDuelCheat" }
})

local ContextTab = Window:CreateTab("Context", 4483362458)
local InventoryTab = Window:CreateTab("Inventory", 4483362458)
local InsurgencyTab = Window:CreateTab("Insurgency", 4483362458)
local CalloutTab = Window:CreateTab("Callout", 4483362458)

ContextTab:CreateSection("Visuals (ESP)")
ContextTab:CreateToggle({
   Name = "ESP Aç/Kapat",
   CurrentValue = State.espEnabled,
   Callback = function(Value)
      State.espEnabled = Value
      if State.espEnabled then
         RunService:BindToRenderStep("ESPUpdate", Enum.RenderPriority.Camera.Value + 1, State.Functions.updateEsp)
      else
         RunService:UnbindFromRenderStep("ESPUpdate")
         State.Functions.clearEsp()
      end
   end,
})

ContextTab:CreateSection("Movement (Fly)")
ContextTab:CreateToggle({
   Name = "Fly Aç/Kapat (F tuşu da çalışır)",
   CurrentValue = State.flyEnabled,
   Callback = function(Value)
      State.flyEnabled = Value
      if State.flyEnabled then State.Functions.enableFly() else State.Functions.disableFly() end
   end,
})
ContextTab:CreateSlider({
   Name = "Fly Hızı", Range = {10, 100}, Increment = 1, Suffix = "Speed", CurrentValue = State.flySpeed,
   Callback = function(Value) State.flySpeed = Value end,
})
ContextTab:CreateToggle({
   Name = "Infinite Jump Aç/Kapat",
   CurrentValue = State.INFINITE_JUMP_ENABLED,
   Callback = function(Value) State.INFINITE_JUMP_ENABLED = Value end,
})

InventoryTab:CreateSection("Hitbox Tools")
InventoryTab:CreateToggle({
   Name = "Hitbox Expander (Gizli, Head 15x)",
   CurrentValue = State.HITBOX_EXPAND_ENABLED,
   Callback = function(Value)
      State.HITBOX_EXPAND_ENABLED = Value
      if not State.HITBOX_EXPAND_ENABLED then State.Functions.restoreAllHitboxes() end
   end,
})
InventoryTab:CreateButton({
   Name = "Hitbox'ları Resetle",
   Callback = function()
      State.Functions.restoreAllHitboxes()
      Rayfield:Notify({Title = "Hitbox Reset", Content = "Tüm hitbox'lar orijinal haline döndü.", Duration = 3})
   end,
})

InsurgencyTab:CreateSection("Combat & Kill Aura HUD")
InsurgencyTab:CreateToggle({
   Name = "Kill Aura & Target HUD (Aim Odaklı)", CurrentValue = State.KILL_AURA_ENABLED,
   Callback = function(Value) State.KILL_AURA_ENABLED = Value end,
})
InsurgencyTab:CreateSlider({
   Name = "Kill Aura Menzili", Range = {10, 50}, Increment = 1, Suffix = "Studs", CurrentValue = State.KILL_AURA_RANGE,
   Callback = function(Value) State.KILL_AURA_RANGE = Value end,
})

InsurgencyTab:CreateSection("Advanced Combat (YENİ)")
InsurgencyTab:CreateToggle({
   Name = "Target Strafe (Hedefin etrafında dön)", CurrentValue = State.STRAFE_ENABLED,
   Callback = function(Value) State.STRAFE_ENABLED = Value end,
})
InsurgencyTab:CreateSlider({
   Name = "Strafe Hızı", Range = {1, 20}, Increment = 1, Suffix = "Speed", CurrentValue = State.STRAFE_SPEED,
   Callback = function(Value) State.STRAFE_SPEED = Value end,
})
InsurgencyTab:CreateSlider({
   Name = "Strafe Yarıçapı (Mesafe)", Range = {5, 25}, Increment = 1, Suffix = "Studs", CurrentValue = State.STRAFE_RADIUS,
   Callback = function(Value) State.STRAFE_RADIUS = Value end,
})
InsurgencyTab:CreateToggle({
   Name = "Reach (Kılıç Menzilini Büyüt)", CurrentValue = State.REACH_ENABLED,
   Callback = function(Value) State.REACH_ENABLED = Value end,
})
InsurgencyTab:CreateToggle({
   Name = "Auto-Block (Vururken Sağ Tık Basar)", CurrentValue = State.AUTO_BLOCK_ENABLED,
   Callback = function(Value) State.AUTO_BLOCK_ENABLED = Value end,
})

InsurgencyTab:CreateSection("Extras")
InsurgencyTab:CreateToggle({
   Name = "Autoclicker Aç/Kapat (Sol Tık tutunca)", CurrentValue = State.AUTOCLICK_ENABLED,
   Callback = function(Value) State.AUTOCLICK_ENABLED = Value end,
})
InsurgencyTab:CreateToggle({
   Name = "Yatay Kılıç Döndürme", CurrentValue = State.SPIN_ENABLED,
   Callback = function(Value) State.SPIN_ENABLED = Value end,
})

CalloutTab:CreateSection("Kill Sayacı")
CalloutTab:CreateButton({
   Name = "Kill Sayacını Sıfırla",
   Callback = function()
      State.Functions.resetKills()
      Rayfield:Notify({Title = "✅ Sıfırlandı!", Content = "Kill sayısı sıfırlandı.", Duration = 3})
   end,
})

Rayfield:Notify({
   Title = "🚀 Yüklendi!",
   Content = "Kill Aura artık SAĞ TIK (defans) yapsan bile OTOMATİK vuruyor!",
   Duration = 6.5, Image = 4483362458
})
