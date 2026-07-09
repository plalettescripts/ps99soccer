-- Pet Simulator 99 - Soccer Orb Auto Collector v1.0 | plalettescripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Config = {
    AutoCollect = false,
    AutoMove = false,
    SpeedValue = 50,
    CollectRadius = 30,
    ShowESP = true
}

local ESPDrawings = {}
local Connections = {}

local function ClearESP()
    for _, d in pairs(ESPDrawings) do pcall(function() d:Remove() end) end
    ESPDrawings = {}
end

local function AddESP(d)
    if #ESPDrawings >= 50 then table.remove(ESPDrawings, 1):Remove() end
    table.insert(ESPDrawings, d)
    return d
end

-- Soccer Orbs finden (verschiedene mögliche Namen)
local function FindSoccerOrbs()
    local orbs = {}
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            -- Mögliche Orb-Namen im Soccer Event
            if name:find("soccer") or name:find("orb") or name:find("ball") or 
               name:find("goal") or name:find("event") or name:find("collect") or
               name:find("coin") or name:find("gem") or name:find("token") then
                -- Nur Orbs die nicht in der Base sind
                if obj.Parent and obj.Parent ~= Workspace then
                    table.insert(orbs, obj)
                end
            end
        end
    end
    
    -- Wenn keine gefunden, suche nach leuchtenden/glänzenden Objekten
    if #orbs == 0 then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                if obj.BrickColor == BrickColor.new("Bright yellow") or
                   obj.BrickColor == BrickColor.new("Lime green") or
                   obj.BrickColor == BrickColor.new("New Yeller") then
                    if obj.Transparency < 0.5 and obj.Size.Magnitude < 10 then
                        table.insert(orbs, obj)
                    end
                end
            end
        end
    end
    
    return orbs
end

-- Nächsten Orb finden (nähester)
local function GetNearestOrb()
    local orbs = FindSoccerOrbs()
    local nearest = nil
    local nearestDist = math.huge
    
    if not LocalPlayer.Character then return nil end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    for _, orb in ipairs(orbs) do
        local dist = (orb.Position - hrp.Position).Magnitude
        if dist < nearestDist then
            nearestDist = dist
            nearest = orb
        end
    end
    
    return nearest, nearestDist
end

-- Orb einsammeln (durch Berührung)
local function CollectOrb(orb)
    if not orb or not LocalPlayer.Character then return false end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Teleportiere zum Orb
    hrp.CFrame = CFrame.new(orb.Position + Vector3.new(0, 2, 0))
    
    -- Warte kurz für Kollision
    task.wait(0.1)
    
    return true
end

-- GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "PS99_Soccer"
GUI.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 200, 0, 200)
Main.Position = UDim2.new(0.01, 0, 0.15, 0)
Main.BackgroundColor3 = Color3.fromRGB(18, 22, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = GUI
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Border = Instance.new("Frame")
Border.Size = UDim2.new(1, 3, 1, 3)
Border.Position = UDim2.new(0, -1.5, 0, -1.5)
Border.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
Border.BorderSizePixel = 0
Border.Parent = Main
Instance.new("UICorner", Border).CornerRadius = UDim.new(0, 9)

task.spawn(function()
    local hue = 0.25
    while GUI and GUI.Parent do
        hue = (hue + 0.005) % 0.1 + 0.25
        pcall(function() Border.BackgroundColor3 = Color3.fromHSV(hue, 1, 1) end)
        task.wait(0.04)
    end
end)

-- Minimiert
local Mini = Instance.new("Frame")
Mini.Size = UDim2.new(0, 150, 0, 28)
Mini.Position = UDim2.new(0.01, 0, 0.15, 0)
Mini.BackgroundColor3 = Color3.fromRGB(18, 22, 18)
Mini.BorderSizePixel = 0
Mini.Visible = false
Mini.Active = true
Mini.Draggable = true
Mini.Parent = GUI
Instance.new("UICorner", Mini).CornerRadius = UDim.new(0, 6)

local MiniText = Instance.new("TextLabel")
MiniText.Size = UDim2.new(1, 0, 1, 0)
MiniText.BackgroundTransparency = 1
MiniText.TextColor3 = Color3.fromRGB(50, 255, 50)
MiniText.Text = "⚽ PS99 | plalettescripts"
MiniText.Font = Enum.Font.SourceSansBold
MiniText.TextSize = 11
MiniText.Parent = Mini

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
        Mini.Visible = not Mini.Visible
    end
end)

-- Titel
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(22, 26, 22)
Title.TextColor3 = Color3.fromRGB(50, 255, 50)
Title.Text = "⚽ Soccer Orb Collector"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.Parent = Main

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(1, 0, 0, 12)
Sub.Position = UDim2.new(0, 0, 0, 30)
Sub.BackgroundColor3 = Color3.fromRGB(22, 26, 22)
Sub.TextColor3 = Color3.fromRGB(140, 160, 140)
Sub.Text = "v1.0 | plalettescripts"
Sub.Font = Enum.Font.SourceSans
Sub.TextSize = 9
Sub.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 20, 0, 18)
Close.Position = UDim2.new(1, -24, 0, 4)
Close.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Text = "X"
Close.Font = Enum.Font.SourceSansBold
Close.TextSize = 11
Close.Parent = Main
Close.MouseButton1Click:Connect(function() ClearESP() GUI:Destroy() end)

-- Scroll
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -6, 1, -48)
Scroll.Position = UDim2.new(0, 3, 0, 44)
Scroll.BackgroundColor3 = Color3.fromRGB(20, 24, 20)
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 2
Scroll.CanvasSize = UDim2.new(0, 0, 0, 300)
Scroll.Parent = Main

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 3)
List.FillDirection = Enum.FillDirection.Vertical
List.SortOrder = Enum.SortOrder.LayoutOrder
List.Parent = Scroll

local function Tog(name, key)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -2, 0, 26)
    f.BackgroundColor3 = Color3.fromRGB(26, 30, 26)
    f.Parent = Scroll
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.52, 0, 1, 0)
    l.Position = UDim2.new(0.03, 0, 0, 0)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(220, 240, 220)
    l.Text = name .. ": OFF"
    l.Font = Enum.Font.SourceSansSemibold
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 28, 0, 14)
    b.Position = UDim2.new(0.9, -28, 0, 6)
    b.BackgroundColor3 = Color3.fromRGB(50, 60, 50)
    b.Text = ""
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    local on = false
    b.MouseButton1Click:Connect(function()
        on = not on
        Config[key] = on
        l.Text = name .. ": " .. (on and "ON" or "OFF")
        b.BackgroundColor3 = on and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(50, 60, 50)
    end)
end

local function Sli(name, key, min, max, def)
    Config[key] = def
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -2, 0, 40)
    f.BackgroundColor3 = Color3.fromRGB(26, 30, 26)
    f.Parent = Scroll
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 15)
    l.Position = UDim2.new(0.03, 0, 0, 2)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(220, 240, 220)
    l.Text = name .. ": " .. def
    l.Font = Enum.Font.SourceSans
    l.TextSize = 10
    l.Parent = f
    local inp = Instance.new("TextBox")
    inp.Size = UDim2.new(0.3, 0, 0, 18)
    inp.Position = UDim2.new(0.35, 0, 0, 20)
    inp.BackgroundColor3 = Color3.fromRGB(40, 50, 40)
    inp.TextColor3 = Color3.fromRGB(200, 255, 200)
    inp.Text = tostring(def)
    inp.Font = Enum.Font.SourceSans
    inp.TextSize = 10
    inp.Parent = f
    Instance.new("UICorner", inp).CornerRadius = UDim.new(0, 3)
    inp.FocusLost:Connect(function()
        local v = tonumber(inp.Text)
        if v and v >= min and v <= max then
            Config[key] = v
            l.Text = name .. ": " .. v
        else
            inp.Text = tostring(Config[key])
        end
    end)
end

-- GUI Inhalt
Tog("Auto-Collect Orbs", "AutoCollect")
Tog("Auto-Move to Orbs", "AutoMove")
Sli("Collect Radius", "CollectRadius", 5, 100, 30)
Sli("Move Speed", "SpeedValue", 16, 100, 50)
Tog("Show Orb ESP", "ShowESP")

-- Status Label
local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(1, -2, 0, 20)
StatusFrame.BackgroundColor3 = Color3.fromRGB(26, 30, 26)
StatusFrame.Parent = Scroll
Instance.new("UICorner", StatusFrame).CornerRadius = UDim.new(0, 4)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -8, 1, 0)
StatusLabel.Position = UDim2.new(0, 4, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(200, 220, 200)
StatusLabel.Text = "Status: Bereit"
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 9
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusFrame

-- ==================== AUTO COLLECT SYSTEM ====================

-- Auto-Move zum nächsten Orb
task.spawn(function()
    while task.wait() do
        if Config.AutoMove and Config.AutoCollect and LocalPlayer.Character then
            pcall(function()
                local nearest, dist = GetNearestOrb()
                
                if nearest and dist <= Config.CollectRadius then
                    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        -- Direkt zum Orb bewegen
                        local targetPos = nearest.Position + Vector3.new(0, 3, 0)
                        local direction = (targetPos - hrp.Position).Unit
                        
                        -- Character zum Orb bewegen
                        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum.WalkSpeed = Config.SpeedValue
                            hum:MoveTo(targetPos)
                        end
                        
                        StatusLabel.Text = "Status: Bewegt zu Orb (" .. math.floor(dist) .. "m)"
                    end
                else
                    StatusLabel.Text = "Status: Suche Orbs..."
                end
            end)
        end
        task.wait(0.05)
    end
end)

-- Auto-Collect (Teleport-Methode für schnelles Einsammeln)
task.spawn(function()
    while task.wait(0.1) do
        if Config.AutoCollect then
            pcall(function()
                local orbs = FindSoccerOrbs()
                
                if #orbs > 0 then
                    StatusLabel.Text = "Status: " .. #orbs .. " Orbs gefunden"
                    
                    for _, orb in ipairs(orbs) do
                        if LocalPlayer.Character then
                            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local dist = (orb.Position - hrp.Position).Magnitude
                                
                                if dist <= Config.CollectRadius then
                                    -- Teleportiere zum Orb
                                    hrp.CFrame = CFrame.new(orb.Position + Vector3.new(0, 2, 0))
                                    
                                    -- Feuer-Touch-Interest zum Einsammeln
                                    firetouchinterest(hrp, orb, 0)
                                    firetouchinterest(hrp, orb, 1)
                                    
                                    StatusLabel.Text = "Status: Sammle Orb ein..."
                                    task.wait(0.05)
                                end
                            end
                        end
                    end
                else
                    StatusLabel.Text = "Status: Keine Orbs in Reichweite"
                end
            end)
        end
    end
end)

-- ESP für Orbs
task.spawn(function()
    while task.wait(0.1) do
        ClearESP()
        
        if Config.ShowESP then
            local orbs = FindSoccerOrbs()
            
            for _, orb in ipairs(orbs) do
                local pos, onScreen = Camera:WorldToViewportPoint(orb.Position)
                if onScreen then
                    -- Orb Marker
                    local t = AddESP(Drawing.new("Text"))
                    t.Text = "⚽"
                    t.Color = Color3.fromRGB(255, 255, 50)
                    t.Size = 16
                    t.Position = Vector2.new(pos.X, pos.Y)
                    t.Center = true
                    t.Visible = true
                    
                    -- Distanz
                    if LocalPlayer.Character then
                        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local dist = math.floor((orb.Position - hrp.Position).Magnitude)
                            local dt = AddESP(Drawing.new("Text"))
                            dt.Text = dist .. "m"
                            dt.Color = Color3.fromRGB(200, 255, 200)
                            dt.Size = 10
                            dt.Position = Vector2.new(pos.X, pos.Y + 12)
                            dt.Center = true
                            dt.Visible = true
                        end
                    end
                end
            end
            
            -- Sammelradius anzeigen
            if Config.AutoCollect and LocalPlayer.Character then
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local circlePos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local circle = AddESP(Drawing.new("Circle"))
                        circle.Color = Color3.fromRGB(50, 255, 50)
                        circle.Thickness = 1
                        circle.Radius = Config.CollectRadius * 3
                        circle.Position = Vector2.new(circlePos.X, circlePos.Y)
                        circle.Filled = false
                        circle.Visible = true
                    end
                end
            end
        end
    end
end)

-- Speed Hack für Bewegung
RunService.Stepped:Connect(function()
    if Config.AutoMove and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Config.SpeedValue
        end
    end
end)

print("⚽ PS99 Soccer Orb Collector v1.0 | plalettescripts")
print("🎯 Auto-Collect + Auto-Move + ESP")
print("⌨️ CTRL = Minimize")
