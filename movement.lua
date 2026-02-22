-- movement.lua
flySpeed = 38
keys = {}
bodyVelocity = nil

function EnableFly()
    local c = LocalPlayer.Character
    if not c then return end
    local root = c:FindFirstChild("HumanoidRootPart")
    bodyVelocity = Instance.new("BodyVelocity", root)
    bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
end

function DisableFly()
    if bodyVelocity then bodyVelocity:Destroy() end
end
