-- ESP
local function createEspForPlayer(player)
    local esp = { lines = {} }
    for i = 1, 8 do
        local line = Drawing.new("Line")
        line.Color = Color3.new(1, 0, 0)
        line.Thickness = 2.5
        line.Transparency = 1
        line.Visible = false
        esp.lines[i] = line
    end
    esp.name = Drawing.new("Text")
    esp.name.Color = Color3.new(1,1,1)
    esp.name.Size = 15
    esp.name.Center = true
    esp.name.Outline = true
    esp.name.Font = 2
    esp.name.Visible = false
    esp.distance = Drawing.new("Text")
    esp.distance.Color = Color3.new(0.8,0.8,0.8)
    esp.distance.Size = 13
    esp.distance.Center = true
    esp.distance.Outline = true
    esp.distance.Font = 2
    esp.distance.Visible = false
    esp.healthBar = Drawing.new("Square")
    esp.healthBar.Filled = true
    esp.healthBar.Transparency = 1
    esp.healthBar.Color = Color3.new(0,1,0)
    esp.healthBar.Visible = false
    return esp
end

local function removeEsp(esp)
    if not esp then return end
    for _, line in ipairs(esp.lines) do if line then line:Remove() end end
    if esp.name then esp.name:Remove() end
    if esp.distance then esp.distance:Remove() end
    if esp.healthBar then esp.healthBar:Remove() end
end

local function updateEsp()
    if not espEnabled then
        for _, esp in pairs(espObjects) do removeEsp(esp) end
        espObjects = {}
        return
    end
    local seenPlayers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not (char and isCharacterValid(char)) then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not (root and head) then continue end
        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.6,0))
        if onScreen and headPos.Z > 0 then
            seenPlayers[player] = true
            if not espObjects[player] then espObjects[player] = createEspForPlayer(player) end
            local esp = espObjects[player]
            local height = (rootPos.Y - headPos.Y) * 1.05
            local width = height * 0.5
            local x, y = rootPos.X, rootPos.Y
            local tl = Vector2.new(x - width/2, y - height/2)
            local tr = Vector2.new(x + width/2, y - height/2)
            local bl = Vector2.new(x - width/2, y + height/2)
            local br = Vector2.new(x + width/2, y + height/2)
            local seg = width / 4
            esp.lines[1].From = tl; esp.lines[1].To = tl + Vector2.new(seg, 0)
            esp.lines[2].From = tl; esp.lines[2].To = tl + Vector2.new(0, seg)
            esp.lines[3].From = tr; esp.lines[3].To = tr - Vector2.new(seg, 0)
            esp.lines[4].From = tr; esp.lines[4].To = tr + Vector2.new(0, seg)
            esp.lines[5].From = bl; esp.lines[5].To = bl + Vector2.new(seg, 0)
            esp.lines[6].From = bl; esp.lines[6].To = bl - Vector2.new(0, seg)
            esp.lines[7].From = br; esp.lines[7].To = br - Vector2.new(seg, 0)
            esp.lines[8].From = br; esp.lines[8].To = br - Vector2.new(0, seg)
            for _, line in ipairs(esp.lines) do line.Visible = true end
            esp.name.Text = player.Name
            esp.name.Position = Vector2.new(x, tl.Y - 18)
            esp.name.Visible = true
            local dist = (LocalPlayer.Character and (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 999
            esp.distance.Text = math.floor(dist) .. "m"
            esp.distance.Position = Vector2.new(x, br.Y + 4)
            esp.distance.Visible = true
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                esp.healthBar.Size = Vector2.new(3, height * hp)
                esp.healthBar.Position = Vector2.new(tl.X - 8, br.Y - height * hp)
                esp.healthBar.Color = Color3.new(1 - hp, hp, 0)
                esp.healthBar.Visible = true
            end
        else
            if espObjects[player] then
                removeEsp(espObjects[player])
                espObjects[player] = nil
            end
        end
    end
    for player, esp in pairs(espObjects) do
        if not seenPlayers[player] then
            removeEsp(esp)
            espObjects[player] = nil
        end
    end
end
