
-- Anti Kick / Cheat Bypass
local mt = getrawmetatable(game)
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    if getnamecallmethod() == "Kick" then return end
    return mt.__namecall(self, ...)
end)

-- ScreenGui Setup
local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "BrainrotUI"
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 300, 0, 460)
main.Position = UDim2.new(0.5, -150, 0.5, -230)
main.BackgroundColor3 = Color3.new(0, 0, 0)
main.BorderSizePixel = 2
main.BorderColor3 = Color3.new(1, 1, 1)
main.Active = true
main.Draggable = true

-- UIListLayout
local layout = Instance.new("UIListLayout", main)
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Close Button ❌
local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0, 260, 0, 30)
close.BackgroundColor3 = Color3.new(0.1, 0, 0)
close.TextColor3 = Color3.new(1, 1, 1)
close.Font = Enum.Font.SourceSansBold
close.TextSize = 18
close.Text = "❌ Close"
close.MouseButton1Click:Connect(function()
    sg:Destroy()
end)

-- Toggle Button Function
local function makeToggle(name, var, callback)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0, 260, 0, 30)
    btn.BackgroundColor3 = Color3.new(1, 0, 0)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    _G[var] = false
    btn.Text = name .. " [OFF]"
    btn.MouseButton1Click:Connect(function()
        _G[var] = not _G[var]
        btn.Text = name .. (_G[var] and " [ON]" or " [OFF]")
        if callback then callback(_G[var]) end
    end)
end

-- Wallhack
makeToggle("WallHack", "WallHack")
game:GetService("RunService").Stepped:Connect(function()
    if _G.WallHack then
        for _, p in pairs(workspace:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide and p.Transparency < 0.5 and p.Size.Magnitude > 4 then
                if not p:FindFirstChild("OriginalTransparency") then
                    local tag = Instance.new("NumberValue", p)
                    tag.Name = "OriginalTransparency"
                    tag.Value = p.Transparency
                end
                p.Transparency = 0.6
            elseif p:IsA("BasePart") and p:FindFirstChild("OriginalTransparency") and not _G.WallHack then
                p.Transparency = p.OriginalTransparency.Value
                p.OriginalTransparency:Destroy()
            end
        end
    end
end)

-- Speed Slider
local speed = 16
local lbl = Instance.new("TextLabel", main)
lbl.Size = UDim2.new(0, 260, 0, 20)
lbl.Text = "Speed: " .. speed
lbl.TextColor3 = Color3.new(1, 1, 1)
lbl.BackgroundTransparency = 1
lbl.Font = Enum.Font.SourceSans
lbl.TextSize = 16

local box = Instance.new("TextBox", main)
box.Size = UDim2.new(0, 260, 0, 28)
box.Text = tostring(speed)
box.BackgroundColor3 = Color3.new(1, 0, 0)
box.TextColor3 = Color3.new(1, 1, 1)
box.Font = Enum.Font.SourceSansBold
box.TextSize = 18
box.ClearTextOnFocus = false

box.FocusLost:Connect(function()
    local v = tonumber(box.Text)
    if v and v >= 1 and v <= 100 then
        speed = v
        lbl.Text = "Speed: " .. v
    else
        box.Text = tostring(speed)
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    local h = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = speed end
end)

-- Multi Jump
makeToggle("Multi Jump", "MultiJump")
game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.MultiJump then
        local h = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState("Jumping") end
    end
end)

-- Godmode
makeToggle("Godmode", "Godmode", function(state)
    local h = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if state and h then
        h:GetPropertyChangedSignal("Health"):Connect(function()
            if _G.Godmode then h.Health = h.MaxHealth end
        end)
    end
end)

-- ESP Players
makeToggle("ESP Players", "ESP", function(enabled)
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            local char = p.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if enabled and not char:FindFirstChild("ESP_HL") then
                    local hl = Instance.new("Highlight", char)
                    hl.Name = "ESP_HL"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 0, 0)
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                elseif not enabled and char:FindFirstChild("ESP_HL") then
                    char.ESP_HL:Destroy()
                end
            end
        end
    end
end)

-- Anti-Ragdoll
game:GetService("RunService").Stepped:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BallSocketConstraint") or v.Name:lower():find("ragdoll") then
                v:Destroy()
            end
        end
    end
end)

-- Auto return to base after stealing brainrot
local returned = false
game:GetService("RunService").Heartbeat:Connect(function()
    if returned then return end
    local char = game.Players.LocalPlayer.Character
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("brainrot") then
                returned = true
                task.wait(0.5)
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(Vector3.new(0, 5, 0)) -- Replace with base coords
                end
                task.wait(2)
                returned = false
            end
        end
    end
end)
