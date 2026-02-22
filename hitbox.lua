-- Hitbox
local function expandHitboxes()
    if not HITBOX_EXPAND_ENABLED then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if not isEnemy(player) then continue end
        local char = player.Character
        if not char or not isCharacterValid(char) then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not root or not head then continue end
        if not originalSizes[player] then
            originalSizes[player] = { Root = root.Size, Head = head.Size }
        end
        pcall(function()
            if root.Size ~= originalSizes[player].Root * ROOTPART_SIZE_MULTIPLIER then
                root.Size = originalSizes[player].Root * ROOTPART_SIZE_MULTIPLIER
            end
            if head.Size ~= originalSizes[player].Head * HEAD_SIZE_MULTIPLIER then
                head.Size = originalSizes[player].Head * HEAD_SIZE_MULTIPLIER
            end
            root.Transparency = 1
            head.Transparency = 1
            root.CanCollide = false
            head.CanCollide = false
            root.Massless = true
            head.Massless = true
        end)
    end
end

local function restoreHitboxesForPlayer(player)
    local sizes = originalSizes[player]
    if not sizes then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    pcall(function()
        if root and sizes.Root then
            root.Size = sizes.Root
            root.Transparency = 0
            root.CanCollide = true
            root.Massless = false
        end
        if head and sizes.Head then
            head.Size = sizes.Head
            head.Transparency = 0
            head.CanCollide = true
            head.Massless = false
        end
    end)
    originalSizes[player] = nil
end

local function restoreAllHitboxes()
    for player in pairs(originalSizes) do
        restoreHitboxesForPlayer(player)
    end
    originalSizes = {}
end

local function applyReach()
    if not REACH_ENABLED then return end
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if tool then
        local handle = tool:FindFirstChild("Handle")
        if handle then
            handle.Size = Vector3.new(REACH_SIZE, REACH_SIZE, REACH_SIZE)
            handle.Transparency = 1
            handle.Massless = true
        end
    end
end
