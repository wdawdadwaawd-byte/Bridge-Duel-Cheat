-- Fly and Infinite Jump
local function updateFly()
    if not flyEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root or not bodyVelocity then return end
    local cam = Camera
    local moveDir = Vector3.new(0,0,0)
    if keysPressed[Enum.KeyCode.W] then moveDir += cam.CFrame.LookVector end
    if keysPressed[Enum.KeyCode.S] then moveDir -= cam.CFrame.LookVector end
    if keysPressed[Enum.KeyCode.A] then moveDir -= cam.CFrame.RightVector end
    if keysPressed[Enum.KeyCode.D] then moveDir += cam.CFrame.RightVector end
    if keysPressed[Enum.KeyCode.Space] then moveDir += Vector3.new(0,1,0) end
    if keysPressed[Enum.KeyCode.LeftShift] then moveDir -= Vector3.new(0,1,0) end
    if moveDir.Magnitude > 0 then
        bodyVelocity.Velocity = moveDir.Unit * flySpeed
    else
        bodyVelocity.Velocity = Vector3.zero
    end
    root.CFrame = CFrame.lookAt(root.Position, root.Position + cam.CFrame.LookVector)
end

local function enableFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root
    flyConnection = RunService.RenderStepped:Connect(updateFly)
end

local function disableFly()
    flyEnabled = false
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end
end
