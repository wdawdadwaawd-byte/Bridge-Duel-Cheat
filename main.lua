-- main.lua (LOADER)
local BASE =
"https://raw.githubusercontent.com/wdawdadwaawd-byte/Bridge-Duel-Cheat/main/"

local files = {
    "core.lua",
    "hud.lua",
    "combat.lua",
    "esp.lua",
    "movement.lua",
    "input.lua",
    "ui.lua"
}

for _, file in ipairs(files) do
    local code = game:HttpGet(BASE .. file)
    local fn, err = loadstring(code)
    if not fn then
        warn("Yüklenemedi:", file, err)
        return
    end
    fn()
end

print("✅ Bridge Duel Cheat - Tüm modüller yüklendi")
