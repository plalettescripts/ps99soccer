-- PS99 Soccer Orb Auto-Walk Collector v1.2 | plalettescripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local PathfindingService = game:GetService("PathfindingService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Config = {
    AutoCollect = false,
    Speed = 50
}

-- Soccer Orbs finden
local function FindOrbs()
    local orbs = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            local n = obj.Name:lower()
            if n:find("soccer") or n:find("orb") or n:find("ball") or n:find("goal") or n:find("token") then
                if obj.Transparency < 0.8 and obj.Size.Magnitude < 15 then
                    table.insert(orbs, obj)
                end
            end
        end
    end
    -- Fallback: gelbe Objekte
    if #orbs == 0 then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.BrickColor == BrickColor.new("Bright yellow") and obj.Transparency < 0.5 and obj.Size.Magnitude < 10 then
                table.insert(orbs, obj)
            end
        end
    end
    return orbs
end

-- Nächsten Orb finden
local function GetNearestOrb()
    local orbs = FindOrbs()
    if #orbs == 0 then return nil, 999 end
    
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, 999 end
    
    local nearest = nil
    local nearestDist = math.huge
    
    for _, orb in ipairs(orbs) do
        local dist = (orb.Position - hrp.Position).Magnitude
        if dist < nearestDist then
            nearestDist = dist
            nearest = orb
        end
    end
    
    return nearest, nearestDist
end

-- GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "PS99"
GUI.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 170, 0, 100)
Main.Position = UDim2.new(0.01, 0, 0.15, 0)
Main.BackgroundColor3 = Color3.fromRGB(18, 22, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = GUI
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 24)
Title.BackgroundColor3 = Color3.fromRGB(22, 26, 22)
Title.TextColor3 = Color3.fromRGB(50, 255, 50)
Title.Text = "⚽ Soccer Collector v1.2"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 12
Title.Parent = Main

-- Toggle
local TogFrame = Instance.new("Frame")
TogFrame.Size = UDim2.new(1, -8, 0, 28)
TogFrame.Position = UDim2.new(0, 4, 0, 28)
TogFrame.BackgroundColor3 = Color3.fromRGB(26, 30, 26)
TogFrame.Parent = Main
Instance.new("UICorner", TogFrame).CornerRadius = UDim.new(0, 4)

local TogLabel = Instance.new("TextLabel")
TogLabel.Size = UDim2.new(0.5, 0, 1, 0)
TogLabel.Position = UDim2.new(0.04, 0, 0, 0)
TogLabel.BackgroundTransparency = 1
TogLabel.TextColor3 = Color3.fromRGB(220, 240, 220)
TogLabel.Text = "Auto Walk: OFF"
TogLabel.Font = Enum.Font.SourceSansSemibold
TogLabel.TextSize = 11
TogLabel.TextXAlignment = Enum.TextXAlignment.Left
TogLabel.Parent = TogFrame

local TogBtn = Instance.new("TextButton")
TogBtn.Size = UDim2.new(0, 30, 0, 16)
TogBtn.Position = UDim2.new(0.88, -30, 0, 6)
TogBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 50)
TogBtn.Text = ""
TogBtn.Parent = TogFrame
Instance.new("UICorner", TogBtn).CornerRadius = UDim.new(0, 8)

-- Status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -8, 0, 36)
Status.Position = UDim2.new(0, 4, 0, 60)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(180, 200, 180)
Status.Text = "Bereit\nv1.2 | plalettescripts"
Status.Font = Enum.Font.SourceSans
Status.TextSize = 10
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local on = false
TogBtn.MouseButton1Click:Connect(function()
    on = not on
    Config.AutoCollect = on
    TogLabel.Text = "Auto Walk: " .. (on and "ON" or "OFF")
    TogBtn.BackgroundColor3 = on and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(50, 60, 50)
end)

-- Auto Walk & Collect
task.spawn(function()
    while task.wait() do
        if Config.AutoCollect and LocalPlayer.Character then
            pcall(function()
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not hum or not hrp then return end
                
                -- Speed setzen
                hum.WalkSpeed = Config.Speed
                
                -- Nächsten Orb finden
                local nearest, dist = GetNearestOrb()
                
                if nearest and dist < 500 then
                    -- Zum Orb laufen
                    hum:MoveTo(nearest.Position)
                    Status.Text = "🏃 Läuft zu Orb\n" .. math.floor(dist) .. "m entfernt"
                    
                    -- Wenn nah genug, einsammeln
                    if dist < 8 then
                        firetouchinterest(hrp, nearest, 0)
                        firetouchinterest(hrp, nearest, 1)
                        Status.Text = "✅ Eingesammelt!\nSuche nächsten..."
                        task.wait(0.1)
                    end
                else
                    Status.Text = "🔍 Suche Orbs...\nKeine in Reichweite"
                    task.wait(1)
                end
            end)
        end
        task.wait(0.1)
    end
end)
