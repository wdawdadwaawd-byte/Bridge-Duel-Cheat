-- esp.lua
espObjects = {}

function ClearESP()
    for _, v in pairs(espObjects) do
        for _, d in pairs(v) do d:Remove() end
    end
    espObjects = {}
end
