-- Visuals.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Config = getgenv().BDSettings
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/SENIN_KULLANICI_ADIN/SENIN_DEPON/main/src/Utils.lua"))()

local Visuals = {
    EspObjects = {},
    LastTargetUserId = nil,
    CachedPortraitData = nil
}

if not Drawing then return end

-- (Buraya eski scriptindeki TargetHUD tablosunu ve ESP createEspForPlayer, removeEsp, updateEsp fonksiyonlarını doğrudan yapıştırabilirsin. 
-- Tek yapman gereken `espObjects` yerine `Visuals.EspObjects` kullanmak ve koşullarda `Config.ESPEnabled` kontrolü yapmak.)

function Visuals.UpdateESP()
    -- ESP Güncelleme kodların (eski scriptten updateEsp fonksiyonunun içi)
end

function Visuals.UpdateTargetHUD(target)
    -- Target HUD kodların (eski scriptten updateTargetHUD fonksiyonunun içi)
end

RunService.RenderStepped:Connect(function()
    if Config.ESPEnabled then
        Visuals.UpdateESP()
    else
        for _, esp in pairs(Visuals.EspObjects) do 
            -- removeEsp(esp)
        end
        Visuals.EspObjects = {}
    end
end)

return Visuals
