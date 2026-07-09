-- PS99 Soccer Orb Auto Collector v1.3 | plalettescripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Config = {
    AutoCollect = false,
    Speed = 50,
    CollectRange = 6
}

-- Soccer Orbs NUR innerhalb des Feldes finden
local function FindOrbsOnField()
    local orbs = {}
    
    -- Zuerst das Soccer-Feld finden (große flache Plattform)
    local field = nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            -- Soccer-Feld erkennung
            if n:find("field") or n:find("soccer") or n:find("arena") or n:find("court") or n:find("pitch") then
                if obj.Size.X > 50 and obj.Size.Z > 50 and obj.Size.Y < 5 then
                    field = obj
                    break
                end
            end
        end
    end
    
    -- Wenn kein Feld gefunden, suche nach großer grüner Fläche
    if not field then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.BrickColor == BrickColor.new("Dark green") then
                if obj.Size.X > 80 and obj.Size.Z > 50 then
                    field = obj
                    break
                end
            end
        end
    end
    
    -- Orbs finden, die auf dem Feld liegen
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            local n = obj.Name:lower()
            local isOrb = false
            
            -- Orb-Namen
            if n:find("soccer") or n:find("orb") or n:find("ball") or n:find("goal") or n:find("token") then
                isOrb = true
            end
            
            -- Gelbe/grüne leuchtende Objekte
            if obj.BrickColor == BrickColor.new("Bright yellow") or 
               obj.BrickColor == BrickColor.new("Lime green") or
               obj.BrickColor == BrickColor.new("New Yeller") then
                if obj.Transparency < 0.6 and obj.Material == Enum.Material.Neon then
                    isOrb = true
                end
            end
            
            -- Nur wenn auf dem Feld (oder kein Feld definiert)
            if isOrb then
                if field then
                    -- Prüfe ob Orb innerhalb der Feld-Grenzen liegt
                    local fx = field.Position.X
                    local fz = field.Position.Z
                    local hsx = field.Size.X / 2
                    local hsz = field.Size.Z / 2
                    
                    if obj.Position.X > fx - hsx and obj.Position.X < fx + hsx and
                       obj.Position.Z > fz - hsz and obj.Position.Z < fz + hsz then
                        table.insert(orbs, obj)
                    end
                else
                    table.insert(orbs, obj)
                end
            end
        end
    end
    
    return orbs
end

-- Nächsten Orb auf dem Feld finden
local function GetNearestOrbOnField()
    local orbs = FindOrbsOnField()
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
Main.Size = UDim2.new(0, 175, 0, 105)
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
Title.Text = "⚽ Soccer v1.3"
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
TogLabel.Text = "Auto Collect: OFF"
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
Status.Size = UDim2.new(1, -8, 0, 40)
Status.Position = UDim2.new(0, 4, 0, 60)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(180, 200, 180)
Status.Text = "Bereit | v1.3\nplalettescripts"
Status.Font = Enum.Font.SourceSans
Status.TextSize = 10
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local on = false
TogBtn.MouseButton1Click:Connect(function()
    on = not on
    Config.AutoCollect = on
    TogLabel.Text = "Auto Collect: " .. (on and "ON" or "OFF")
    TogBtn.BackgroundColor3 = on and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(50, 60, 50)
end)

-- Auto Collect (optimiert, kein Lag)
local lastOrbPos = nil
local sameOrbCount = 0

task.spawn(function()
    while task.wait(0.3) do
        if Config.AutoCollect and LocalPlayer.Character then
            pcall(function()
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not hum or not hrp then return end
                
                hum.WalkSpeed = Config.Speed
                
                local nearest, dist = GetNearestOrbOnField()
                
                if nearest and dist < 500 then
                    -- Prüfe ob wir zum gleichen Orb laufen (feststecken)
                    if lastOrbPos and (nearest.Position - lastOrbPos).Magnitude < 2 then
                        sameOrbCount = sameOrbCount + 1
                    else
                        sameOrbCount = 0
                    end
                    lastOrbPos = nearest.Position
                    
                    -- Wenn wir feststecken, überspringen
                    if sameOrbCount > 5 then
                        Status.Text = "⏭ Überspringe\nfeststeckenden Orb"
                        sameOrbCount = 0
                        task.wait(0.5)
                        return
                    end
                    
                    -- Zum Orb laufen
                    hum:MoveTo(nearest.Position)
                    Status.Text = "🏃 Läuft zu Orb\n" .. math.floor(dist) .. "m"
                    
                    -- Einsammeln wenn nah genug
                    if dist < Config.CollectRange then
                        firetouchinterest(hrp, nearest, 0)
                        firetouchinterest(hrp, nearest, 1)
                        Status.Text = "✅ Gesammelt!\nNächster Orb..."
                        lastOrbPos = nil
                        sameOrbCount = 0
                    end
                else
                    Status.Text = "🔍 Warte auf\nSpawn..."
                end
            end)
        end
    end
end)
