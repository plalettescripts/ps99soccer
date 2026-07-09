-- PS99 Soccer Orb Collector v1.1| plalettescripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Config = {
    AutoCollect = false,
    Radius = 30
}

-- Soccer Orbs finden
local function FindOrbs()
    local orbs = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            local n = obj.Name:lower()
            if n:find("soccer") or n:find("orb") or n:find("ball") or n:find("goal") or n:find("token") then
                table.insert(orbs, obj)
            end
        end
    end
    -- Fallback: gelbe/grüne Objekte
    if #orbs == 0 then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.BrickColor == BrickColor.new("Bright yellow") and obj.Transparency < 0.5 then
                table.insert(orbs, obj)
            end
        end
    end
    return orbs
end

-- GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "PS99"
GUI.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 160, 0, 80)
Main.Position = UDim2.new(0.01, 0, 0.15, 0)
Main.BackgroundColor3 = Color3.fromRGB(18, 22, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = GUI
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 22)
Title.BackgroundColor3 = Color3.fromRGB(22, 26, 22)
Title.TextColor3 = Color3.fromRGB(50, 255, 50)
Title.Text = "⚽ Soccer Collector"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 12
Title.Parent = Main

local ToggleFrame = Instance.new("Frame")
ToggleFrame.Size = UDim2.new(1, -8, 0, 30)
ToggleFrame.Position = UDim2.new(0, 4, 0, 26)
ToggleFrame.BackgroundColor3 = Color3.fromRGB(26, 30, 26)
ToggleFrame.Parent = Main
Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 4)

local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Size = UDim2.new(0.5, 0, 1, 0)
ToggleLabel.Position = UDim2.new(0.04, 0, 0, 0)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.TextColor3 = Color3.fromRGB(220, 240, 220)
ToggleLabel.Text = "Auto Collect: OFF"
ToggleLabel.Font = Enum.Font.SourceSansSemibold
ToggleLabel.TextSize = 11
ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleLabel.Parent = ToggleFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 30, 0, 16)
ToggleBtn.Position = UDim2.new(0.88, -30, 0, 7)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 50)
ToggleBtn.Text = ""
ToggleBtn.Parent = ToggleFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -8, 0, 18)
Status.Position = UDim2.new(0, 4, 0, 60)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(150, 170, 150)
Status.Text = "v1.1 | plalettescripts"
Status.Font = Enum.Font.SourceSans
Status.TextSize = 9
Status.Parent = Main

local on = false
ToggleBtn.MouseButton1Click:Connect(function()
    on = not on
    Config.AutoCollect = on
    ToggleLabel.Text = "Auto Collect: " .. (on and "ON" or "OFF")
    ToggleBtn.BackgroundColor3 = on and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(50, 60, 50)
end)

-- Auto Collect (nur diese eine Funktion, kein Lag)
task.spawn(function()
    while task.wait(0.15) do
        if Config.AutoCollect and LocalPlayer.Character then
            pcall(function()
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                local orbs = FindOrbs()
                local collected = 0
                
                for _, orb in ipairs(orbs) do
                    if (orb.Position - hrp.Position).Magnitude <= Config.Radius then
                        firetouchinterest(hrp, orb, 0)
                        firetouchinterest(hrp, orb, 1)
                        collected = collected + 1
                    end
                end
                
                if collected > 0 then
                    Status.Text = "Gesammelt: " .. collected .. " | plalettescripts"
                else
                    Status.Text = "Suche... | plalettescripts"
                end
            end)
        end
    end
end)
