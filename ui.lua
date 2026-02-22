-- UI (Rayfield)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Bridge Duel Cheat (2026) v2",
   LoadingTitle = "Bridge Duel Stabil Cheat",
   LoadingSubtitle = "Advanced Combat + Kill Aura",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "BridgeDuelCheat"
   }
})
local ContextTab = Window:CreateTab("Context", 4483362458)
local InventoryTab = Window:CreateTab("Inventory", 4483362458)
local InsurgencyTab = Window:CreateTab("Insurgency", 4483362458)
local CalloutTab = Window:CreateTab("Callout", 4483362458)

ContextTab:CreateSection("Visuals (ESP)")
ContextTab:CreateToggle({
   Name = "ESP Aç/Kapat",
   CurrentValue = espEnabled,
   Callback = function(Value)
      espEnabled = Value
      if espEnabled then
         RunService:BindToRenderStep("ESPUpdate", Enum.RenderPriority.Camera.Value + 1, updateEsp)
      else
         RunService:UnbindFromRenderStep("ESPUpdate")
         for _, esp in pairs(espObjects) do removeEsp(esp) end
         espObjects = {}
      end
   end,
})

ContextTab:CreateSection("Movement (Fly)")
ContextTab:CreateToggle({
   Name = "Fly Aç/Kapat (F tuşu da çalışır)",
   CurrentValue = flyEnabled,
   Callback = function(Value)
      flyEnabled = Value
      if flyEnabled then enableFly() else disableFly() end
   end,
})
ContextTab:CreateSlider({
   Name = "Fly Hızı",
   Range = {10, 100},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = flySpeed,
   Callback = function(Value)
      flySpeed = Value
   end,
})

-- INFINITE JUMP
ContextTab:CreateToggle({
   Name = "Infinite Jump Aç/Kapat",
   CurrentValue = INFINITE_JUMP_ENABLED,
   Callback = function(Value)
      INFINITE_JUMP_ENABLED = Value
   end,
})

InventoryTab:CreateSection("Hitbox Tools")
InventoryTab:CreateToggle({
   Name = "Hitbox Expander (Gizli, Head 15x)",
   CurrentValue = HITBOX_EXPAND_ENABLED,
   Callback = function(Value)
      HITBOX_EXPAND_ENABLED = Value
      if not HITBOX_EXPAND_ENABLED then restoreAllHitboxes() end
   end,
})
InventoryTab:CreateButton({
   Name = "Hitbox'ları Resetle",
   Callback = function()
      restoreAllHitboxes()
      Rayfield:Notify({
         Title = "Hitbox Reset",
         Content = "Tüm hitbox'lar orijinal haline döndü.",
         Duration = 3
      })
   end,
})

InsurgencyTab:CreateSection("Combat & Kill Aura HUD")
InsurgencyTab:CreateToggle({
   Name = "Kill Aura & Target HUD (Aim Odaklı)",
   CurrentValue = false,
   Callback = function(Value)
      KILL_AURA_ENABLED = Value
   end,
})
InsurgencyTab:CreateSlider({
   Name = "Kill Aura Menzili",
   Range = {10, 50},
   Increment = 1,
   Suffix = "Studs",
   CurrentValue = KILL_AURA_RANGE,
   Callback = function(Value)
      KILL_AURA_RANGE = Value
   end,
})

InsurgencyTab:CreateSection("Advanced Combat (YENİ)")
InsurgencyTab:CreateToggle({
   Name = "Target Strafe (Hedefin etrafında dön)",
   CurrentValue = STRAFE_ENABLED,
   Callback = function(Value)
      STRAFE_ENABLED = Value
   end,
})
InsurgencyTab:CreateSlider({
   Name = "Strafe Hızı",
   Range = {1, 20},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = STRAFE_SPEED,
   Callback = function(Value)
      STRAFE_SPEED = Value
   end,
})
InsurgencyTab:CreateSlider({
   Name = "Strafe Yarıçapı (Mesafe)",
   Range = {5, 25},
   Increment = 1,
   Suffix = "Studs",
   CurrentValue = STRAFE_RADIUS,
   Callback = function(Value)
      STRAFE_RADIUS = Value
   end,
})
InsurgencyTab:CreateToggle({
   Name = "Reach (Kılıç Menzilini Büyüt)",
   CurrentValue = REACH_ENABLED,
   Callback = function(Value)
      REACH_ENABLED = Value
   end,
})
InsurgencyTab:CreateToggle({
   Name = "Auto-Block (Vururken Sağ Tık Basar)",
   CurrentValue = AUTO_BLOCK_ENABLED,
   Callback = function(Value)
      AUTO_BLOCK_ENABLED = Value
   end,
})

InsurgencyTab:CreateSection("Extras")
InsurgencyTab:CreateToggle({
   Name = "Autoclicker Aç/Kapat (Sol Tık tutunca)",
   CurrentValue = AUTOCLICK_ENABLED,
   Callback = function(Value)
      AUTOCLICK_ENABLED = Value
   end,
})
InsurgencyTab:CreateToggle({
   Name = "Yatay Kılıç Döndürme",
   CurrentValue = false,
   Callback = function(Value)
      SPIN_ENABLED = Value
   end,
})

CalloutTab:CreateSection("Kill Sayacı")
CalloutTab:CreateButton({
   Name = "Kill Sayacını Sıfırla",
   Callback = function()
      getgenv().BD_KillCount = 0
      killCount = 0
      getgenv().BD_DeadPlayers = {}
      deadPlayers = {}
      Rayfield:Notify({
         Title = "✅ Sıfırlandı!",
         Content = "Kill sayısı sıfırlandı.",
         Duration = 3
      })
   end,
})
CalloutTab:CreateParagraph({Title = "📊 Güncel Kill: " .. tostring(killCount), Content = "Gelişmiş Combat ile rakipleri darmadağın et!"})

Rayfield:Notify({
   Title = "🚀 Yüklendi!",
   Content = "Kill Aura artık SAĞ TIK (defans) yapsan bile OTOMATİK vuruyor!",
   Duration = 6.5,
   Image = 4483362458
})
