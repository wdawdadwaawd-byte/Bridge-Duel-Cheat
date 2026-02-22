-- input.lua
UserInputService.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.F then
        FLY_ENABLED = not FLY_ENABLED
        if FLY_ENABLED then EnableFly() else DisableFly() end
    end
    if i.KeyCode == Enum.KeyCode.Space and INFINITE_JUMP then
        local h = LocalPlayer.Character
            and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
