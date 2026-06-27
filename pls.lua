--// murgichor GUI + Script

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "murgichor"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 280, 0, 250)
MainFrame.Position = UDim2.new(0.4, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = MainFrame
MainStroke.Color = Color3.fromRGB(70, 70, 85)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.2

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
Title.Text = "murgichor"
Title.TextColor3 = Color3.fromRGB(245, 245, 245)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local Toggle = Instance.new("TextButton")
Toggle.Parent = MainFrame
Toggle.Size = UDim2.new(0.84, 0, 0, 34)
Toggle.Position = UDim2.new(0.08, 0, 0, 58)
Toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
Toggle.Text = "ACTIVE : OFF"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.TextScaled = true
Toggle.Font = Enum.Font.GothamBold

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = Toggle

local TeamCheckButton = Instance.new("TextButton")
TeamCheckButton.Parent = MainFrame
TeamCheckButton.Size = UDim2.new(0.84, 0, 0, 28)
TeamCheckButton.Position = UDim2.new(0.08, 0, 0, 104)
TeamCheckButton.BackgroundColor3 = Color3.fromRGB(120, 60, 0)
TeamCheckButton.Text = "TEAM CHECK : OFF"
TeamCheckButton.TextColor3 = Color3.new(1, 1, 1)
TeamCheckButton.TextScaled = true
TeamCheckButton.Font = Enum.Font.GothamBold

local TeamCorner = Instance.new("UICorner")
TeamCorner.CornerRadius = UDim.new(0, 8)
TeamCorner.Parent = TeamCheckButton

local FOVLabel = Instance.new("TextLabel")
FOVLabel.Parent = MainFrame
FOVLabel.Size = UDim2.new(0.84, 0, 0, 18)
FOVLabel.Position = UDim2.new(0.08, 0, 0, 146)
FOVLabel.BackgroundTransparency = 1
FOVLabel.TextColor3 = Color3.new(1, 1, 1)
FOVLabel.TextScaled = true
FOVLabel.Font = Enum.Font.GothamBold
FOVLabel.Text = "FOV: 400"

local FOVBar = Instance.new("Frame")
FOVBar.Parent = MainFrame
FOVBar.Size = UDim2.new(0.84, 0, 0, 12)
FOVBar.Position = UDim2.new(0.08, 0, 0, 170)
FOVBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FOVBar.BorderSizePixel = 0

local FOVBarCorner = Instance.new("UICorner")
FOVBarCorner.CornerRadius = UDim.new(0, 6)
FOVBarCorner.Parent = FOVBar

local FOVFill = Instance.new("Frame")
FOVFill.Parent = FOVBar
FOVFill.Size = UDim2.new(0.5, 0, 1, 0)
FOVFill.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
FOVFill.BorderSizePixel = 0

local FOVFillCorner = Instance.new("UICorner")
FOVFillCorner.CornerRadius = UDim.new(0, 6)
FOVFillCorner.Parent = FOVFill

local FOVButton = Instance.new("TextButton")
FOVButton.Parent = FOVBar
FOVButton.Size = UDim2.new(1, 0, 1, 0)
FOVButton.BackgroundTransparency = 1
FOVButton.Text = ""

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Parent = MainFrame
SliderLabel.Size = UDim2.new(0.84, 0, 0, 18)
SliderLabel.Position = UDim2.new(0.08, 0, 0, 192)
SliderLabel.BackgroundTransparency = 1
SliderLabel.TextColor3 = Color3.new(1, 1, 1)
SliderLabel.TextScaled = true
SliderLabel.Font = Enum.Font.GothamBold
SliderLabel.Text = "Aim Distance: 250"

local SliderBar = Instance.new("Frame")
SliderBar.Parent = MainFrame
SliderBar.Size = UDim2.new(0.84, 0, 0, 12)
SliderBar.Position = UDim2.new(0.08, 0, 0, 216)
SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SliderBar.BorderSizePixel = 0

local SliderBarCorner = Instance.new("UICorner")
SliderBarCorner.CornerRadius = UDim.new(0, 6)
SliderBarCorner.Parent = SliderBar

local SliderFill = Instance.new("Frame")
SliderFill.Parent = SliderBar
SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SliderFill.BorderSizePixel = 0

local SliderFillCorner = Instance.new("UICorner")
SliderFillCorner.CornerRadius = UDim.new(0, 6)
SliderFillCorner.Parent = SliderFill

local SliderButton = Instance.new("TextButton")
SliderButton.Parent = SliderBar
SliderButton.Size = UDim2.new(1, 0, 1, 0)
SliderButton.BackgroundTransparency = 1
SliderButton.Text = ""

-- STATE
_G.Aimbot = false
_G.TeamCheck = false
_G.SkelESP = true
_G.FOV = 400
_G.Smoothness = 1.0
_G.AimAssistStrength = 0.5
_G.AimDistance = 250
_G.MainColor = Color3.fromRGB(255, 0, 0)

-- TOGGLE BUTTON
Toggle.MouseButton1Click:Connect(function()
	_G.Aimbot = not _G.Aimbot
	
	if _G.Aimbot then
		Toggle.Text = "ACTIVE : ON"
		Toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
	else
		Toggle.Text = "ACTIVE : OFF"
		Toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
	end
end)

TeamCheckButton.MouseButton1Click:Connect(function()
	_G.TeamCheck = not _G.TeamCheck

	if _G.TeamCheck then
		TeamCheckButton.Text = "TEAM CHECK : ON"
		TeamCheckButton.BackgroundColor3 = Color3.fromRGB(0, 120, 170)
	else
		TeamCheckButton.Text = "TEAM CHECK : OFF"
		TeamCheckButton.BackgroundColor3 = Color3.fromRGB(120, 60, 0)
	end
end)

-- HELPERS
local function isAlive(p)
    return p.Character
        and p.Character:FindFirstChild("Humanoid")
        and p.Character.Humanoid.Health > 0
end

local function isEnemy(p)
    if not _G.TeamCheck then return true end
    if lp.Team and p.Team then
        return lp.Team ~= p.Team
    end
    return true
end

local function getClosestInFOV()
    local target, dist = nil, _G.FOV
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local lpChar = lp.Character
    local lpRoot = lpChar and lpChar:FindFirstChild("HumanoidRootPart")

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and isAlive(p) and isEnemy(p) then
            local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
            local root = p.Character:FindFirstChild("HumanoidRootPart")

            if head and root and lpRoot then
                local worldDist = (lpRoot.Position - root.Position).Magnitude

                if worldDist <= _G.AimDistance then
                local pos, vis = camera:WorldToViewportPoint(head.Position)

                if vis then
                    local d = (center - Vector2.new(pos.X, pos.Y)).Magnitude

                    if d < dist then
                        dist = d
                        target = p
                    end
                end
                end
            end
        end
    end

    return target
end

local sliderMin = 25
local sliderMax = 500
local draggingSlider = false
local fovMin = 50
local fovMax = 800
local draggingFOV = false

local function setAimDistanceFromX(x)
    local alpha = math.clamp((x - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
    local value = math.floor(sliderMin + (sliderMax - sliderMin) * alpha + 0.5)
    _G.AimDistance = value
    SliderLabel.Text = "Aim Distance: " .. value
    SliderFill.Size = UDim2.new(alpha, 0, 1, 0)
end

local function setFOVFromX(x)
    local alpha = math.clamp((x - FOVBar.AbsolutePosition.X) / FOVBar.AbsoluteSize.X, 0, 1)
    local value = math.floor(fovMin + (fovMax - fovMin) * alpha + 0.5)
    _G.FOV = value
    FOVLabel.Text = "FOV: " .. value
    FOVFill.Size = UDim2.new(alpha, 0, 1, 0)
end

SliderButton.MouseButton1Down:Connect(function()
    draggingSlider = true
    setAimDistanceFromX(UserInputService:GetMouseLocation().X)
end)

FOVButton.MouseButton1Down:Connect(function()
    draggingFOV = true
    setFOVFromX(UserInputService:GetMouseLocation().X)
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if draggingSlider then
            setAimDistanceFromX(UserInputService:GetMouseLocation().X)
        end

        if draggingFOV then
            setFOVFromX(UserInputService:GetMouseLocation().X)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
        draggingFOV = false
    end
end)

task.defer(function()
    setAimDistanceFromX(SliderBar.AbsolutePosition.X + SliderBar.AbsoluteSize.X * 0.5)
    setFOVFromX(FOVBar.AbsolutePosition.X + FOVBar.AbsoluteSize.X * 0.5)
end)

-- AIMBOT
RunService.RenderStepped:Connect(function()
    if _G.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestInFOV()

        if target and isAlive(target) then
            local head = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")

            if head then
                local pos, vis = camera:WorldToViewportPoint(head.Position)

                if vis then
                    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

                    local dx = pos.X - center.X
                    local dy = pos.Y - center.Y

                    local power = (_G.Smoothness ^ 1.5) * _G.AimAssistStrength * 0.4

                    if mousemoverel then
                        mousemoverel(dx * power, dy * power)
                    end
                end
            end
        end
    end
end)

-- SKELETON ESP
local function createBone(name, parent)
    local b = Instance.new("CylinderHandleAdornment")

    b.Name = name
    b.Radius = 0.15
    b.AlwaysOnTop = true
    b.ZIndex = 10
    b.Color3 = _G.MainColor
    b.Adornee = workspace.Terrain
    b.Parent = parent

    return b
end

local BONE_PAIRS = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"UpperTorso","RightUpperArm"},
    {"LowerTorso","LeftUpperLeg"},{"LowerTorso","RightUpperLeg"},
    {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"}
}

RunService.Heartbeat:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local char = p.Character

            if _G.SkelESP and isAlive(p) and isEnemy(p) then
                local f = char:FindFirstChild("VSkel") or Instance.new("Folder", char)
                f.Name = "VSkel"

                for _, pair in ipairs(BONE_PAIRS) do
                    local p1 = char:FindFirstChild(pair[1])
                    local p2 = char:FindFirstChild(pair[2])

                    if p1 and p2 then
                        local bone = f:FindFirstChild(pair[1]..pair[2]) or createBone(pair[1]..pair[2], f)

                        bone.Color3 = _G.MainColor
                        bone.Height = (p1.Position - p2.Position).Magnitude
                        bone.CFrame = CFrame.lookAt(p1.Position, p2.Position) * CFrame.new(0, 0, -bone.Height / 2)
                    end
                end
            else
                if char:FindFirstChild("VSkel") then
                    char.VSkel:Destroy()
                end
            end
        end
    end
end)
