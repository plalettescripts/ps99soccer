-- PS99 Soccer Field Walker v2.5 | plalettescripts
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Config = { AutoWalk = false }

-- Feld finden und Bahnen berechnen
local function GetFieldPath()
    local field = nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Size.X > 80 and obj.Size.Z > 40 and obj.Size.Y < 10 then
            field = obj
            break
        end
    end
    if not field then return {} end
    
    local path = {}
    local fx = field.Position.X
    local fz = field.Position.Z
    local hx = math.floor(field.Size.X / 2) - 15
    local hz = math.floor(field.Size.Z / 2) - 15
    local y = field.Position.Y + 5
    
    local goRight = true
    for z = -hz, hz, 15 do
        if goRight then
            for x = -hx, hx, 15 do
                table.insert(path, Vector3.new(fx + x, y, fz + z))
            end
        else
            for x = hx, -hx, -15 do
                table.insert(path, Vector3.new(fx + x, y, fz + z))
            end
        end
        goRight = not goRight
    end
    
    return path
end

-- GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "PS99_plalette"
GUI.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 170, 0, 80)
Main.Position = UDim2.new(0.5, -85, 0.02, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 26, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = true
Main.Parent = GUI
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Border = Instance.new("Frame")
Border.Size = UDim2.new(1, 3, 1, 3)
Border.Position = UDim2.new(0, -1.5, 0, -1.5)
Border.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
Border.BorderSizePixel = 0
Border.Parent = Main
Instance.new("UICorner", Border).CornerRadius = UDim.new(0, 9)

-- Minimiert
local Mini = Instance.new("Frame")
Mini.Size = UDim2.new(0, 160, 0, 28)
Mini.Position = UDim2.new(0.5, -80, 0.02, 0)
Mini.BackgroundColor3 = Color3.fromRGB(20, 26, 20)
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

-- CTRL Toggle
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
        Mini.Visible = not Mini.Visible
    end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 22)
Title.BackgroundColor3 = Color3.fromRGB(24, 30, 24)
Title.TextColor3 = Color3.fromRGB(50, 255, 50)
Title.Text = "⚽ Soccer Walker v2.5"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 12
Title.Parent = Main

local TogFrame = Instance.new("Frame")
TogFrame.Size = UDim2.new(1, -8, 0, 28)
TogFrame.Position = UDim2.new(0, 4, 0, 26)
TogFrame.BackgroundColor3 = Color3.fromRGB(28, 34, 28)
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

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -8, 0, 18)
Status.Position = UDim2.new(0, 4, 0, 58)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(150, 170, 150)
Status.Text = "plalettescripts | v2.5"
Status.Font = Enum.Font.SourceSans
Status.TextSize = 9
Status.Parent = Main

local enabled = false
TogBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    Config.AutoWalk = enabled
    TogLabel.Text = "Auto Walk: " .. (enabled and "ON" or "OFF")
    TogBtn.BackgroundColor3 = enabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(50, 60, 50)
end)

-- Haupt-Loop
task.spawn(function()
    local pathIndex = 1
    local path = {}
    
    while true do
        if enabled and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then continue end
            
            path = GetFieldPath()
            
            if #path == 0 then
                Status.Text = "Kein Feld"
                task.wait(2)
                continue
            end
            
            hum.WalkSpeed = 120
            
            local target = path[pathIndex]
            hum:MoveTo(target)
            Status.Text = "🚶 " .. pathIndex .. "/" .. #path
            
            repeat
                task.wait(0.05)
                if not enabled then break end
            until (hrp.Position - target).Magnitude < 10
            
            pathIndex = pathIndex + 1
            if pathIndex > #path then
                pathIndex = 1
                Status.Text = "✅ Neustart"
                task.wait(0.2)
            end
        end
        task.wait(0.05)
    end
end)
