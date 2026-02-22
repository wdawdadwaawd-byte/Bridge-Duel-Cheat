-- main.lua
local repoURL = "https://github.com/wdawdadwaawd-byte/Bridge-Duel-Cheat/edit/main/"

local function loadModule(moduleName)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(repoURL .. moduleName .. ".lua"))()
    end)
    
    if not success then
        warn("Modül yüklenemedi: " .. moduleName .. " | Hata: " .. tostring(result))
    end
    return result
end

print("🔥 Bridge Duel Cheat Modüler Sistem Yükleniyor...")

-- Modülleri sırasıyla yükle
loadModule("Config")
loadModule("Utils")
loadModule("Visuals")
loadModule("Combat")
loadModule("UI")

print("✅ Tüm modüller başarıyla yüklendi!")
