-- PS99 Soccer Orb Collector v1.5 | plalettescripts
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Config = { AutoCollect = false }

-- Orbs finden
local function FindOrbs()
    local orbs = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("orb") or n:find("ball") or n:find("token") or n:find("soccer") then
                table.insert(orbs, obj)
            end
        end
    end
    -- Fallback: gelbe Neon-Objekte
    if #orbs == 0 then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Material == Enum.Material.Neon and obj.BrickColor == BrickColor.new("Bright yellow") then
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
Main.Size = UDim2.new(0, 160, 0, 55)
Main.Position = UDim2.new(0.5, -80, 0.02, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 26, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = GUI
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local TogBtn = Instance.new("TextButton")
TogBtn.Size = UDim2.new(1, -8, 0, 30)
TogBtn.Position = UDim2.new(0, 4, 0, 4)
TogBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 40)
TogBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TogBtn.Text = "⚽ Auto Collect: OFF"
TogBtn.Font = Enum.Font.SourceSansBold
TogBtn.TextSize = 12
TogBtn.Parent = Main
Instance.new("UICorner", TogBtn).CornerRadius = UDim.new(0, 6)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -8, 0, 16)
Status.Position = UDim2.new(0, 4, 0, 37)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(150, 170, 150)
Status.Text = "plalettescripts | v1.5"
Status.Font = Enum.Font.SourceSans
Status.TextSize = 9
Status.Parent = Main

local enabled = false
TogBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    Config.AutoCollect = enabled
    TogBtn.Text = "⚽ Auto Collect: " .. (enabled and "ON" or "OFF")
    TogBtn.BackgroundColor3 = enabled and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(40, 50, 40)
end)

-- Haupt-Loop: Geht JEDEN Orb einzeln durch
task.spawn(function()
    while true do
        if enabled and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
            local orbs = FindOrbs()
            
            -- Sortiere nach Entfernung (nächster zuerst)
            table.sort(orbs, function(a, b)
                return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
            end)
            
            for _, orb in ipairs(orbs) do
                if not enabled then break end
                local dist = (orb.Position - hrp.Position).Magnitude
                
                if dist < 200 then
                    -- DIREKT zum Orb teleportieren (nicht nur ein Stück)
                    hrp.CFrame = CFrame.new(orb.Position)
                    task.wait(0.1)
                    
                    -- Einsammeln
                    firetouchinterest(hrp, orb, 0)
                    firetouchinterest(hrp, orb, 1)
                    Status.Text = "✅ Gesammelt!"
                    task.wait(0.1)
                end
            end
            Status.Text = "🔍 Suche..."
        end
        task.wait(1)
    end
end)
