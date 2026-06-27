--// murgichor v4.0 — The Godmode Suite
--// Aimbot • ESP • Movement • Configs • Utilities • Trolling
--// Panic: DELETE | Toggle GUI: RightShift

--=============================================
-- SERVICES & INIT
--=============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = lp:GetMouse()

local hasDrawing = pcall(function()
	local t = Drawing.new("Line")
	t:Remove()
end)

-- CLEANUP OLD
if game.CoreGui:FindFirstChild("murgichor") then
	game.CoreGui.murgichor:Destroy()
end

--=============================================
-- STATE
--=============================================
_G.Aimbot = false
_G.AimKey = "MouseButton2" 
_G.AimPart = "Head"
_G.TargetPriority = "Crosshair" -- Options: Crosshair, Distance, Health
_G.TeamCheck = false
_G.WallCheck = false
_G.Prediction = false
_G.StickyTarget = false
_G.AutoShoot = false
_G.AutoShootDelay = 0.0
_G.FOV = 400
_G.AimDistance = 250
_G.Smoothness = 1.0
_G.AimAssistStrength = 0.5
_G.DeadZone = 10
_G.HitboxExpander = false
_G.HitboxSize = 5.0

_G.SkelESP = false
_G.BoxESP = false
_G.NameESP = false
_G.HealthBars = false
_G.Tracers = false
_G.Chams = false
_G.Arrows = false
_G.FOVCircleOn = false

_G.FlyEnabled = false
_G.Noclip = false
_G.InfJump = false
_G.Bhop = false
_G.Spinbot = false
_G.ClickTP = false
_G.WalkSpeedVal = 16
_G.JumpPowerVal = 50
_G.FlySpeed = 50

_G.CrosshairOn = false
_G.AntiAFK = false
_G.FPSOn = false
_G.WatermarkOn = false
_G.Fullbright = false
_G.RainbowMode = false
_G.CamFOVOn = false
_G.CamFOV = 120
_G.TimeChangerOn = false
_G.CustomTime = 12

_G.MainColor = Color3.fromRGB(255, 0, 0)
_G.ColorR = 255
_G.ColorG = 0
_G.ColorB = 0

local lockedTarget = nil
local prevPositions = {}
local allConnections = {}
local sliders = {}
local uiUpdaters = {}
local origHitboxes = {}

local AIM_PARTS = {"Head", "UpperTorso", "HumanoidRootPart"}
local aimPartIdx = 1

local AIM_KEYS = {"MouseButton2", "MouseButton1", "C", "V", "Q", "E", "LeftAlt"}
local aimKeyIdx = 1

local TARGET_MODES = {"Crosshair", "Distance", "Health"}
local targetModeIdx = 1

local flyBV, flyBG = nil, nil
local origAmbient = Lighting.Ambient
local origOutdoor = Lighting.OutdoorAmbient

--=============================================
-- DRAWING OBJECTS
--=============================================
local espCache = {}
local fovCircle, fpsText, watermarkText = nil, nil, nil
local crossLines = {}

if hasDrawing then
	fovCircle = Drawing.new("Circle")
	fovCircle.Filled = false
	fovCircle.Thickness = 1.5
	fovCircle.NumSides = 64
	fovCircle.Transparency = 0.6
	fovCircle.Visible = false

	fpsText = Drawing.new("Text")
	fpsText.Size = 16
	fpsText.Color = Color3.new(1, 1, 1)
	fpsText.Outline = true
	fpsText.OutlineColor = Color3.new(0, 0, 0)
	fpsText.Visible = false
	fpsText.Position = Vector2.new(8, 8)

	watermarkText = Drawing.new("Text")
	watermarkText.Size = 16
	watermarkText.Color = Color3.new(1, 1, 1)
	watermarkText.Outline = true
	watermarkText.OutlineColor = Color3.new(0, 0, 0)
	watermarkText.Visible = false
	watermarkText.Position = Vector2.new(camera.ViewportSize.X - 250, 8)

	for i = 1, 4 do
		local l = Drawing.new("Line")
		l.Thickness = 1.5
		l.Color = Color3.fromRGB(0, 255, 120)
		l.Visible = false
		crossLines[i] = l
	end
end

local function newDrawLine()
	local l = Drawing.new("Line")
	l.Visible = false
	l.Thickness = 1
	return l
end

local function newDrawText()
	local t = Drawing.new("Text")
	t.Visible = false
	t.Size = 14
	t.Color = Color3.new(1, 1, 1)
	t.Center = true
	t.Outline = true
	t.OutlineColor = Color3.new(0, 0, 0)
	return t
end

local function createPlayerESP(player)
	if not hasDrawing then return end
	espCache[player] = {
		boxLines = {newDrawLine(), newDrawLine(), newDrawLine(), newDrawLine()},
		nameText = newDrawText(),
		healthBg = newDrawLine(),
		healthFill = newDrawLine(),
		tracerLine = newDrawLine()
	}
	espCache[player].healthBg.Thickness = 4
	espCache[player].healthBg.Color = Color3.fromRGB(40, 40, 40)
	espCache[player].healthFill.Thickness = 2
	espCache[player].tracerLine.Thickness = 1.5
end

local function removePlayerESP(player)
	if espCache[player] then
		for _, l in ipairs(espCache[player].boxLines) do l:Remove() end
		espCache[player].nameText:Remove()
		espCache[player].healthBg:Remove()
		espCache[player].healthFill:Remove()
		espCache[player].tracerLine:Remove()
		espCache[player] = nil
	end
end

local function hidePlayerESP(player)
	if not espCache[player] then return end
	for _, l in ipairs(espCache[player].boxLines) do l.Visible = false end
	espCache[player].nameText.Visible = false
	espCache[player].healthBg.Visible = false
	espCache[player].healthFill.Visible = false
	espCache[player].tracerLine.Visible = false
end

for _, p in ipairs(Players:GetPlayers()) do
	if p ~= lp then createPlayerESP(p) end
end

--=============================================
-- GUI CREATION (With Animations)
--=============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "murgichor"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function addCorner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = parent
end

local function addStroke(parent, col, th)
	local s = Instance.new("UIStroke")
	s.Color = col or Color3.fromRGB(60, 60, 75)
	s.Thickness = th or 1
	s.Transparency = 0.3
	s.Parent = parent
end

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 360, 0, 460)
MainFrame.Position = UDim2.new(0.35, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
addCorner(MainFrame, 12)
addStroke(MainFrame, Color3.fromRGB(55, 55, 70), 1.5)

local showPos = MainFrame.Position
local hidePos = UDim2.new(showPos.X.Scale, showPos.X.Offset, 1.5, 0)
local isMenuVisible = true

local fullSize = MainFrame.Size

-- TITLE BAR
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
TitleBar.BorderSizePixel = 0
addCorner(TitleBar, 12)

local TitleFix = Instance.new("Frame")
TitleFix.Parent = TitleBar
TitleFix.Size = UDim2.new(1, 0, 0, 14)
TitleFix.Position = UDim2.new(0, 0, 1, -14)
TitleFix.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
TitleFix.BorderSizePixel = 0

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.Size = UDim2.new(0.65, 0, 1, 0)
TitleText.Position = UDim2.new(0.04, 0, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "murgichor v4.0"
TitleText.TextColor3 = Color3.fromRGB(245, 245, 255)
TitleText.TextScaled = true
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton")
MinBtn.Parent = TitleBar
MinBtn.Size = UDim2.new(0, 28, 0, 22)
MinBtn.Position = UDim2.new(1, -36, 0, 8)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
MinBtn.Text = "–"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.TextScaled = true
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
addCorner(MinBtn, 4)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = minimized and UDim2.new(0, 360, 0, 38) or fullSize
	}):Play()
	MinBtn.Text = minimized and "+" or "–"
end)

-- TAB BAR
local TabBar = Instance.new("Frame")
TabBar.Parent = MainFrame
TabBar.Size = UDim2.new(1, 0, 0, 26)
TabBar.Position = UDim2.new(0, 0, 0, 38)
TabBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
TabBar.BorderSizePixel = 0

local TAB_ON = Color3.fromRGB(45, 45, 58)
local TAB_OFF = Color3.fromRGB(28, 28, 35)
local tabNames = {"AIM", "ESP", "MOVE", "MISC", "CFG"}
local tabButtons = {}
local tabPages = {}

for i, name in ipairs(tabNames) do
	local btn = Instance.new("TextButton")
	btn.Parent = TabBar
	btn.Size = UDim2.new(1 / #tabNames, 0, 1, 0)
	btn.Position = UDim2.new((i - 1) / #tabNames, 0, 0, 0)
	btn.BackgroundColor3 = i == 1 and TAB_ON or TAB_OFF
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(210, 210, 225)
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	tabButtons[i] = btn
end

-- CONTENT
local ContentFrame = Instance.new("Frame")
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, 0, 0, 364)
ContentFrame.Position = UDim2.new(0, 0, 0, 64)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ClipsDescendants = true

local function makePage(canvasH)
	local p = Instance.new("ScrollingFrame")
	p.Parent = ContentFrame
	p.Size = UDim2.new(1, 0, 1, 0)
	p.CanvasSize = UDim2.new(0, 0, 0, canvasH)
	p.BackgroundTransparency = 1
	p.BorderSizePixel = 0
	p.ScrollBarThickness = 4
	p.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
	p.Visible = false
	return p
end

local AimPage = makePage(640)
local ESPPage = makePage(280)
local MovePage = makePage(380)
local MiscPage = makePage(620)
local CfgPage = makePage(120)
tabPages = {AimPage, ESPPage, MovePage, MiscPage, CfgPage}
AimPage.Visible = true

local function switchTab(idx)
	for i, page in ipairs(tabPages) do
		page.Visible = (i == idx)
		tabButtons[i].BackgroundColor3 = (i == idx) and TAB_ON or TAB_OFF
	end
end
for i, btn in ipairs(tabButtons) do
	btn.MouseButton1Click:Connect(function() switchTab(i) end)
end

-- STATUS BAR
local StatusBar = Instance.new("Frame")
StatusBar.Parent = MainFrame
StatusBar.Size = UDim2.new(1, 0, 0, 32)
StatusBar.Position = UDim2.new(0, 0, 1, -32)
StatusBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
StatusBar.BorderSizePixel = 0

local StatusText = Instance.new("TextLabel")
StatusText.Parent = StatusBar
StatusText.Size = UDim2.new(0.94, 0, 1, 0)
StatusText.Position = UDim2.new(0.03, 0, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.TextColor3 = Color3.fromRGB(150, 150, 165)
StatusText.TextScaled = true
StatusText.Font = Enum.Font.Gotham
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Text = "No target"

--=============================================
-- GUI ELEMENT HELPERS
--=============================================
local GREEN_ON  = Color3.fromRGB(0, 140, 60)
local GREEN_OFF = Color3.fromRGB(50, 50, 55)
local RED_ON    = Color3.fromRGB(170, 0, 0)
local BLUE_ON   = Color3.fromRGB(0, 100, 170)
local ORANGE_ON = Color3.fromRGB(170, 95, 0)

local function makeToggle(parent, name, y, configKey, cOn, cOff, onChange)
	local btn = Instance.new("TextButton")
	btn.Parent = parent
	btn.Size = UDim2.new(0.88, 0, 0, 24)
	btn.Position = UDim2.new(0.06, 0, 0, y)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BorderSizePixel = 0
	addCorner(btn, 6)

	local function refresh(val)
		_G[configKey] = val
		btn.BackgroundColor3 = val and cOn or cOff
		btn.Text = name .. (val and " : ON" or " : OFF")
		if onChange then onChange(val) end
	end
	
	uiUpdaters[configKey] = refresh
	refresh(_G[configKey])

	btn.MouseButton1Click:Connect(function()
		refresh(not _G[configKey])
	end)
	return btn
end

local function makeDropdown(parent, prefix, optionsArray, y, configKey)
	local btn = Instance.new("TextButton")
	btn.Parent = parent
	btn.Size = UDim2.new(0.88, 0, 0, 24)
	btn.Position = UDim2.new(0.06, 0, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	addCorner(btn, 6)
	
	local currentIdx = 1
	
	local function refresh(val)
		_G[configKey] = val
		btn.Text = prefix .. " : " .. val
		for i, v in ipairs(optionsArray) do
			if v == val then currentIdx = i end
		end
	end
	
	uiUpdaters[configKey] = refresh
	refresh(_G[configKey])

	btn.MouseButton1Click:Connect(function()
		currentIdx = currentIdx % #optionsArray + 1
		refresh(optionsArray[currentIdx])
	end)
	return btn
end

local function makeSlider(parent, name, y, configKey, min, max, fillCol, isFloat, onChange)
	local label = Instance.new("TextLabel")
	label.Parent = parent
	label.Size = UDim2.new(0.88, 0, 0, 14)
	label.Position = UDim2.new(0.06, 0, 0, y)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(195, 195, 210)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left

	local bar = Instance.new("Frame")
	bar.Parent = parent
	bar.Size = UDim2.new(0.88, 0, 0, 10)
	bar.Position = UDim2.new(0.06, 0, 0, y + 16)
	bar.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
	bar.BorderSizePixel = 0
	addCorner(bar, 5)

	local fill = Instance.new("Frame")
	fill.Parent = bar
	fill.BackgroundColor3 = fillCol
	fill.BorderSizePixel = 0
	addCorner(fill, 5)

	local hit = Instance.new("TextButton")
	hit.Parent = bar
	hit.Size = UDim2.new(1, 0, 1, 0)
	hit.BackgroundTransparency = 1
	hit.Text = ""

	local function fmt(v)
		return isFloat and string.format("%.2f", v) or tostring(math.floor(v))
	end

	local function refresh(val)
		_G[configKey] = val
		local a = math.clamp((val - min) / (max - min), 0, 1)
		fill.Size = UDim2.new(a, 0, 1, 0)
		label.Text = name .. ": " .. fmt(val)
		if onChange then onChange(val) end
	end
	
	uiUpdaters[configKey] = refresh
	refresh(_G[configKey])

	local data = {
		bar = bar, fill = fill, dragging = false,
		setFromX = function(x)
			local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			local v = isFloat and (math.floor((min + (max - min) * a) * 100 + 0.5) / 100) or math.floor(min + (max - min) * a + 0.5)
			refresh(v)
		end
	}

	hit.MouseButton1Down:Connect(function()
		data.dragging = true
		data.setFromX(UserInputService:GetMouseLocation().X)
	end)

	table.insert(sliders, data)
	return data
end

--=============================================
-- AIM TAB
--=============================================
local AimToggle = Instance.new("TextButton")
AimToggle.Parent = AimPage
AimToggle.Size = UDim2.new(0.88, 0, 0, 30)
AimToggle.Position = UDim2.new(0.06, 0, 0, 6)
AimToggle.Font = Enum.Font.GothamBold
AimToggle.TextScaled = true
AimToggle.TextColor3 = Color3.new(1, 1, 1)
AimToggle.BorderSizePixel = 0
addCorner(AimToggle, 6)

uiUpdaters["Aimbot"] = function(val)
	_G.Aimbot = val
	AimToggle.Text = "AIMBOT : " .. (val and "ON" or "OFF")
	AimToggle.BackgroundColor3 = val and RED_ON or GREEN_ON
end
uiUpdaters["Aimbot"](_G.Aimbot)
AimToggle.MouseButton1Click:Connect(function() uiUpdaters["Aimbot"](not _G.Aimbot) end)

makeDropdown(AimPage, "AIM KEY", AIM_KEYS, 42, "AimKey")
makeDropdown(AimPage, "AIM PART", AIM_PARTS, 72, "AimPart")
makeDropdown(AimPage, "PRIORITY", TARGET_MODES, 102, "TargetPriority")

makeToggle(AimPage, "TEAM CHECK",    132, "TeamCheck",   BLUE_ON,   GREEN_OFF)
makeToggle(AimPage, "WALL CHECK",    162, "WallCheck",   BLUE_ON,   GREEN_OFF)
makeToggle(AimPage, "PREDICTION",    192, "Prediction",  ORANGE_ON, GREEN_OFF)
makeToggle(AimPage, "STICKY TARGET", 222, "StickyTarget",ORANGE_ON, GREEN_OFF, function(v)
	if not v then lockedTarget = nil end
end)
makeToggle(AimPage, "AUTO SHOOT",    252, "AutoShoot",   RED_ON,    GREEN_OFF)
makeSlider(AimPage, "AutoShoot Delay", 282, "AutoShootDelay", 0.0, 1.0, Color3.fromRGB(255, 50, 50), true)

makeToggle(AimPage, "HITBOX EXPANDER", 316, "HitboxExpander", BLUE_ON, GREEN_OFF, function(v)
	if not v then
		-- revert sizes
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp and p.Character then
				local part = p.Character:FindFirstChild(_G.AimPart) or p.Character:FindFirstChild("Head")
				if part and origHitboxes[p.UserId] then
					part.Size = origHitboxes[p.UserId]
					part.Transparency = 0
					part.Material = Enum.Material.Plastic
					part.CanCollide = true
				end
			end
		end
	end
end)
makeSlider(AimPage, "Hitbox Size",   346, "HitboxSize", 2, 20, Color3.fromRGB(0, 170, 255), false)

makeSlider(AimPage, "FOV",           380, "FOV", 50,  800, Color3.fromRGB(255, 170, 0),  false)
makeSlider(AimPage, "Aim Distance",  414, "AimDistance", 25,  1000, Color3.fromRGB(0, 170, 255),  false)
makeSlider(AimPage, "Smoothness",    448, "Smoothness", 0.1, 2.0, Color3.fromRGB(170, 0, 255),  true)
makeSlider(AimPage, "Assist Strength",482, "AimAssistStrength", 0.1, 2.0, Color3.fromRGB(200, 50, 150),  true)
makeSlider(AimPage, "Dead Zone",     516, "DeadZone", 0, 50, Color3.fromRGB(255, 50, 50), false)

--=============================================
-- ESP TAB
--=============================================
makeToggle(ESPPage, "SKELETON ESP",  6,   "SkelESP", GREEN_ON, GREEN_OFF)
makeToggle(ESPPage, "BOX ESP",       36,  "BoxESP", GREEN_ON, GREEN_OFF)
makeToggle(ESPPage, "NAME ESP",      66,  "NameESP", GREEN_ON, GREEN_OFF)
makeToggle(ESPPage, "HEALTH BARS",   96,  "HealthBars", GREEN_ON, GREEN_OFF)
makeToggle(ESPPage, "TRACERS",       126, "Tracers", GREEN_ON, GREEN_OFF)
makeToggle(ESPPage, "CHAMS",         156, "Chams", GREEN_ON, GREEN_OFF)
makeToggle(ESPPage, "FOV CIRCLE",    186, "FOVCircleOn", GREEN_ON, GREEN_OFF)

--=============================================
-- MOVE TAB
--=============================================
makeToggle(MovePage, "NOCLIP",       6,   "Noclip", BLUE_ON, GREEN_OFF)
makeToggle(MovePage, "INFINITE JUMP",36,  "InfJump", BLUE_ON, GREEN_OFF)
makeToggle(MovePage, "BUNNY HOP",    66,  "Bhop", BLUE_ON, GREEN_OFF)
makeToggle(MovePage, "SPINBOT",      96,  "Spinbot", BLUE_ON, GREEN_OFF)
makeToggle(MovePage, "CLICK TP (LAlt)",126, "ClickTP", BLUE_ON, GREEN_OFF)

makeToggle(MovePage, "FLY", 156, "FlyEnabled", BLUE_ON, GREEN_OFF, function(v)
	if v then
		local char = lp.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")
		if root and hum then
			flyBV = Instance.new("BodyVelocity")
			flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
			flyBV.Velocity = Vector3.new(0, 0, 0)
			flyBV.Parent = root
			flyBG = Instance.new("BodyGyro")
			flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
			flyBG.D = 0
			flyBG.Parent = root
			hum.PlatformStand = true
		end
	else
		if flyBV then flyBV:Destroy(); flyBV = nil end
		if flyBG then flyBG:Destroy(); flyBG = nil end
		local char = lp.Character
		if char then
			local hum = char:FindFirstChild("Humanoid")
			if hum then hum.PlatformStand = false end
		end
	end
end)

makeSlider(MovePage, "WalkSpeed",   192, "WalkSpeedVal", 16,  200, Color3.fromRGB(0, 190, 120), false, function(v)
	local char = lp.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.WalkSpeed = v
	end
end)
makeSlider(MovePage, "JumpPower",   226, "JumpPowerVal", 50,  350, Color3.fromRGB(0, 190, 120), false, function(v)
	local char = lp.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.JumpPower = v
	end
end)
makeSlider(MovePage, "Fly Speed",   260, "FlySpeed", 10,  300, Color3.fromRGB(0, 190, 120), false)

--=============================================
-- MISC TAB
--=============================================
makeToggle(MiscPage, "CROSSHAIR",  6,  "CrosshairOn", GREEN_ON, GREEN_OFF)
makeToggle(MiscPage, "ANTI-AFK",   36, "AntiAFK", GREEN_ON, GREEN_OFF)
makeToggle(MiscPage, "FPS COUNTER",66, "FPSOn", GREEN_ON, GREEN_OFF)
makeToggle(MiscPage, "WATERMARK",  96, "WatermarkOn", GREEN_ON, GREEN_OFF)
makeToggle(MiscPage, "FULLBRIGHT", 126, "Fullbright", GREEN_ON, GREEN_OFF)
makeToggle(MiscPage, "RAINBOW GUI",156, "RainbowMode", GREEN_ON, GREEN_OFF)

makeToggle(MiscPage, "CAMERA FOV", 186, "CamFOVOn", GREEN_ON, GREEN_OFF)
makeSlider(MiscPage, "FOV Value",  216, "CamFOV", 70, 120, Color3.fromRGB(0, 190, 120), false)

makeToggle(MiscPage, "TIME CHANGER",250, "TimeChangerOn", GREEN_ON, GREEN_OFF)
makeSlider(MiscPage, "Time",       280, "CustomTime", 0, 24, Color3.fromRGB(0, 190, 120), true)

local ColHead = Instance.new("TextLabel")
ColHead.Parent = MiscPage
ColHead.Size = UDim2.new(0.88, 0, 0, 16)
ColHead.Position = UDim2.new(0.06, 0, 0, 314)
ColHead.BackgroundTransparency = 1
ColHead.Text = "— MAIN COLOR —"
ColHead.TextColor3 = Color3.fromRGB(130, 130, 150)
ColHead.TextScaled = true
ColHead.Font = Enum.Font.GothamBold

local ColorPreview = Instance.new("Frame")
ColorPreview.Parent = MiscPage
ColorPreview.Size = UDim2.new(0.88, 0, 0, 14)
ColorPreview.Position = UDim2.new(0.06, 0, 0, 436)
ColorPreview.BackgroundColor3 = _G.MainColor
ColorPreview.BorderSizePixel = 0
addCorner(ColorPreview, 4)
addStroke(ColorPreview, Color3.fromRGB(80, 80, 100), 1)

local function updateColor()
	_G.MainColor = Color3.fromRGB(_G.ColorR, _G.ColorG, _G.ColorB)
	ColorPreview.BackgroundColor3 = _G.MainColor
end

makeSlider(MiscPage, "R", 336, "ColorR", 0, 255, Color3.fromRGB(255, 80, 80),  false, updateColor)
makeSlider(MiscPage, "G", 368, "ColorG", 0, 255, Color3.fromRGB(80, 255, 80),  false, updateColor)
makeSlider(MiscPage, "B", 400, "ColorB", 0, 255, Color3.fromRGB(80, 120, 255), false, updateColor)

local KeyLabel = Instance.new("TextLabel")
KeyLabel.Parent = MiscPage
KeyLabel.Size = UDim2.new(0.88, 0, 0, 18)
KeyLabel.Position = UDim2.new(0.06, 0, 0, 468)
KeyLabel.BackgroundTransparency = 1
KeyLabel.Text = "PANIC: Del  |  HIDE GUI: RShift"
KeyLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
KeyLabel.TextScaled = true
KeyLabel.Font = Enum.Font.GothamBold

--=============================================
-- CONFIG TAB
--=============================================
local SaveBtn = Instance.new("TextButton")
SaveBtn.Parent = CfgPage
SaveBtn.Size = UDim2.new(0.88, 0, 0, 30)
SaveBtn.Position = UDim2.new(0.06, 0, 0, 10)
SaveBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
SaveBtn.TextColor3 = Color3.new(1, 1, 1)
SaveBtn.Text = "SAVE CONFIG"
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.TextScaled = true
addCorner(SaveBtn)

local LoadBtn = Instance.new("TextButton")
LoadBtn.Parent = CfgPage
LoadBtn.Size = UDim2.new(0.88, 0, 0, 30)
LoadBtn.Position = UDim2.new(0.06, 0, 0, 50)
LoadBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
LoadBtn.TextColor3 = Color3.new(1, 1, 1)
LoadBtn.Text = "LOAD CONFIG"
LoadBtn.Font = Enum.Font.GothamBold
LoadBtn.TextScaled = true
addCorner(LoadBtn)

local configName = "murgichor_cfg.json"

SaveBtn.MouseButton1Click:Connect(function()
	local cfg = {}
	for k, _ in pairs(uiUpdaters) do cfg[k] = _G[k] end
	if writefile then
		pcall(function() writefile(configName, HttpService:JSONEncode(cfg)) end)
		SaveBtn.Text = "SAVED!"
		task.delay(1, function() SaveBtn.Text = "SAVE CONFIG" end)
	end
end)

LoadBtn.MouseButton1Click:Connect(function()
	if readfile and isfile and isfile(configName) then
		local s, cfg = pcall(function() return HttpService:JSONDecode(readfile(configName)) end)
		if s and type(cfg) == "table" then
			for k, v in pairs(cfg) do if uiUpdaters[k] then uiUpdaters[k](v) end end
			LoadBtn.Text = "LOADED!"
			task.delay(1, function() LoadBtn.Text = "LOAD CONFIG" end)
		end
	end
end)

--=============================================
-- SLIDER DRAG SYSTEM
--=============================================
allConnections[#allConnections + 1] = UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		for _, s in ipairs(sliders) do
			if s.dragging then s.setFromX(UserInputService:GetMouseLocation().X) end
		end
	end
end)

allConnections[#allConnections + 1] = UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		for _, s in ipairs(sliders) do s.dragging = false end
	end
end)

--=============================================
-- CORE HELPERS
--=============================================
local function isAlive(p)
	return p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0
end

local function isEnemy(p)
	if not _G.TeamCheck then return true end
	
	-- Method 1: Compare Team objects directly
	if lp.Team ~= nil and p.Team ~= nil then
		return lp.Team ~= p.Team
	end
	
	-- Method 2: Compare Team name strings (works even if Team objects differ)
	local myTeamName = lp.Team and lp.Team.Name
	local theirTeamName = p.Team and p.Team.Name
	if myTeamName and theirTeamName then
		return myTeamName ~= theirTeamName
	end
	
	-- Method 3: Compare TeamColor as last resort
	if lp.TeamColor ~= nil and p.TeamColor ~= nil then
		return lp.TeamColor ~= p.TeamColor
	end
	
	-- If none of the checks work, treat as enemy
	return true
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function canSee(targetPart, targetChar)
	if not _G.WallCheck then return true end
	local origin = camera.CFrame.Position
	local dir = targetPart.Position - origin
	rayParams.FilterDescendantsInstances = lp.Character and {lp.Character} or {}
	local result = workspace:Raycast(origin, dir, rayParams)
	return result == nil or result.Instance:IsDescendantOf(targetChar)
end

local function getPredictedPos(player, part)
	if not _G.Prediction then return part.Position end
	local now = tick()
	local key = player.UserId
	local prev = prevPositions[key]
	local pos = part.Position

	if prev then
		local dt = now - prev.time
		if dt > 0 and dt < 0.5 then
			local vel = (pos - prev.pos) / dt
			prevPositions[key] = {pos = pos, time = now}
			return pos + vel * 0.06
		end
	end
	prevPositions[key] = {pos = pos, time = now}
	return pos
end

local function getAimPart(char)
	return char:FindFirstChild(_G.AimPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function getClosestTarget()
	if _G.StickyTarget and lockedTarget and isAlive(lockedTarget) and isEnemy(lockedTarget) then
		local part = getAimPart(lockedTarget.Character)
		local root = lockedTarget.Character:FindFirstChild("HumanoidRootPart")
		local lpRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
		if part and root and lpRoot then
			if (lpRoot.Position - root.Position).Magnitude <= _G.AimDistance and canSee(part, lockedTarget.Character) then
				local pos, vis = camera:WorldToViewportPoint(part.Position)
				if vis then
					local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
					local distToCenter = (center - Vector2.new(pos.X, pos.Y)).Magnitude
					if distToCenter <= _G.FOV then
						return lockedTarget
					end
				end
			end
		end
		lockedTarget = nil
	end

	local target, bestVal = nil, math.huge
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local lpRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp and isAlive(p) and isEnemy(p) then
			local part = getAimPart(p.Character)
			local root = p.Character:FindFirstChild("HumanoidRootPart")
			if part and root and lpRoot then
				local worldDist = (lpRoot.Position - root.Position).Magnitude
				if worldDist <= _G.AimDistance and canSee(part, p.Character) then
					local pos, vis = camera:WorldToViewportPoint(part.Position)
					if vis then
						local distToCenter = (center - Vector2.new(pos.X, pos.Y)).Magnitude
						if distToCenter <= _G.FOV then
							local val = math.huge
							if _G.TargetPriority == "Crosshair" then val = distToCenter
							elseif _G.TargetPriority == "Distance" then val = worldDist
							elseif _G.TargetPriority == "Health" then val = p.Character.Humanoid.Health end

							if val < bestVal then
								bestVal = val
								target = p
							end
						end
					end
				end
			end
		end
	end

	if _G.StickyTarget then lockedTarget = target end
	return target
end

local function isAimKeyDown()
	if _G.AimKey == "MouseButton1" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end
	if _G.AimKey == "MouseButton2" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
	local s, e = pcall(function() return UserInputService:IsKeyDown(Enum.KeyCode[_G.AimKey]) end)
	return s and e
end

--=============================================
-- MAIN LOOP (Aim, Movement, Misc)
--=============================================
local currentTargetName = ""
local currentTargetDist = 0
local autoShootTick = 0

allConnections[#allConnections + 1] = RunService.RenderStepped:Connect(function()
	-- RAINBOW MODE
	if _G.RainbowMode then
		local hue = tick() % 5 / 5
		_G.MainColor = Color3.fromHSV(hue, 1, 1)
		ColorPreview.BackgroundColor3 = _G.MainColor
	end

	-- CAMERA FOV
	if _G.CamFOVOn then camera.FieldOfView = _G.CamFOV end
	if _G.CamFOVOn then 
		camera.FieldOfView = _G.CamFOV 
	end

	-- TIME CHANGER
	if _G.TimeChangerOn then Lighting.ClockTime = _G.CustomTime end

	-- FULLBRIGHT
	if _G.Fullbright then
		Lighting.Ambient = Color3.new(1, 1, 1)
		Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
	else
		Lighting.Ambient = origAmbient
		Lighting.OutdoorAmbient = origOutdoor
	end

	-- AIMBOT
	if _G.Aimbot then
		local target = getClosestTarget()
		if target and isAlive(target) then
			local part = getAimPart(target.Character)
			if part then
				local aimPos = getPredictedPos(target, part)
				local pos, vis = camera:WorldToViewportPoint(aimPos)
				
				local root = target.Character:FindFirstChild("HumanoidRootPart")
				local lpRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
				if root and lpRoot then
					currentTargetName = target.DisplayName or target.Name
					currentTargetDist = math.floor((lpRoot.Position - root.Position).Magnitude)
					local keyStatus = isAimKeyDown() and "[LOCKED]" or "[SEARCHING]"
					StatusText.Text = keyStatus .. " Target: " .. currentTargetName .. " | " .. currentTargetDist .. " studs"
				end

				if vis then
					local cx = camera.ViewportSize.X / 2
					local cy = camera.ViewportSize.Y / 2
					local dx = pos.X - cx
					local dy = pos.Y - cy
					
					local distToCenter = math.sqrt(dx*dx + dy*dy)
					
					if isAimKeyDown() then
						if distToCenter > _G.DeadZone then
							local power = (_G.Smoothness ^ 1.5) * _G.AimAssistStrength * 0.4
							if mousemoverel then
								mousemoverel(dx * power, dy * power)
							end
						end
					end
					
					if _G.AutoShoot and distToCenter <= _G.DeadZone + 15 and tick() - autoShootTick > _G.AutoShootDelay then
						if mouse1click then mouse1click(); autoShootTick = tick() end
					end
				end
			end
		else
			StatusText.Text = "No target in FOV"
		end
	else
		StatusText.Text = "Aimbot OFF"
	end

	-- FLY
	if _G.FlyEnabled and flyBV then
		local dir = Vector3.new(0, 0, 0)
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
		flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * _G.FlySpeed or Vector3.new(0, 0, 0)
		flyBG.CFrame = camera.CFrame
	end

	-- FOV CIRCLE
	if hasDrawing and fovCircle then
		fovCircle.Visible = _G.FOVCircleOn
		fovCircle.Radius = _G.FOV
		fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
		fovCircle.Color = _G.MainColor
	end

	-- CROSSHAIR
	if hasDrawing and #crossLines == 4 then
		local show = _G.CrosshairOn
		local cx = camera.ViewportSize.X / 2
		local cy = camera.ViewportSize.Y / 2
		local gap, len = 5, 12
		crossLines[1].Visible = show
		crossLines[1].From = Vector2.new(cx - gap - len, cy)
		crossLines[1].To   = Vector2.new(cx - gap, cy)
		crossLines[2].Visible = show
		crossLines[2].From = Vector2.new(cx + gap, cy)
		crossLines[2].To   = Vector2.new(cx + gap + len, cy)
		crossLines[3].Visible = show
		crossLines[3].From = Vector2.new(cx, cy - gap - len)
		crossLines[3].To   = Vector2.new(cx, cy - gap)
		crossLines[4].Visible = show
		crossLines[4].From = Vector2.new(cx, cy + gap)
		crossLines[4].To   = Vector2.new(cx, cy + gap + len)
	end
end)

--=============================================
-- FPS / PING / WATERMARK
--=============================================
local frameCount = 0
local lastFPSTick = tick()
local currentFPS = 0

allConnections[#allConnections + 1] = RunService.RenderStepped:Connect(function()
	frameCount = frameCount + 1
	if tick() - lastFPSTick >= 1 then
		currentFPS = frameCount
		frameCount = 0
		lastFPSTick = tick()
	end
	
	if hasDrawing then
		if fpsText then
			fpsText.Visible = _G.FPSOn
			fpsText.Text = "FPS: " .. currentFPS
		end
		
		if watermarkText then
			watermarkText.Visible = _G.WatermarkOn
			if _G.WatermarkOn then
				local ping = "0"
				pcall(function() ping = string.split(Stats.Network.ServerStatsItem["Data Ping"]:GetValueString(), " ")[1] end)
				watermarkText.Text = "murgichor v4 | FPS: " .. currentFPS .. " | Ping: " .. ping .. "ms | " .. os.date("%X")
				watermarkText.Color = _G.MainColor
			end
		end
	end
end)

--=============================================
-- NOCLIP / SPINBOT / HITBOX EXPANDER / BHOP
--=============================================
allConnections[#allConnections + 1] = RunService.Stepped:Connect(function()
	local char = lp.Character
	if not char then return end

	-- NOCLIP
	if _G.Noclip then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				part.CanCollide = false
			end
		end
	end

	-- SPINBOT (works in first person by restoring camera after spin)
	if _G.Spinbot then
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			local savedCam = camera.CFrame
			root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(50), 0)
			camera.CFrame = savedCam
		end
	end
end)

allConnections[#allConnections + 1] = RunService.Heartbeat:Connect(function()
	-- HITBOX EXPANDER
	if _G.HitboxExpander then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp and isAlive(p) and isEnemy(p) then
				local part = p.Character:FindFirstChild(_G.AimPart) or p.Character:FindFirstChild("Head")
				if part then
					if not origHitboxes[p.UserId] then origHitboxes[p.UserId] = part.Size end
					part.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
					part.Transparency = 0.5
					part.BrickColor = BrickColor.new("Bright blue")
					part.Material = Enum.Material.Neon
					part.CanCollide = false
				end
			end
		end
	end

	-- BUNNY HOP
	if _G.Bhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		local char = lp.Character
		if char then
			local hum = char:FindFirstChild("Humanoid")
			if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end
end)

--=============================================
-- CLICK TELEPORT
--=============================================
allConnections[#allConnections + 1] = UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) and _G.ClickTP then
		local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
		if root and mouse.Hit then
			root.CFrame = mouse.Hit + Vector3.new(0, 3, 0)
		end
	end
end)

--=============================================
-- INFINITE JUMP
--=============================================
allConnections[#allConnections + 1] = UserInputService.JumpRequest:Connect(function()
	if _G.InfJump and lp.Character then
		local hum = lp.Character:FindFirstChild("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

--=============================================
-- DRAWING ESP RENDER
--=============================================
local function rotateVector2(v, center, angle)
	local c, s = math.cos(angle), math.sin(angle)
	local dx, dy = v.X - center.X, v.Y - center.Y
	return Vector2.new(center.X + (dx * c - dy * s), center.Y + (dx * s + dy * c))
end

if hasDrawing then
	allConnections[#allConnections + 1] = RunService.RenderStepped:Connect(function()
		local anyESP = _G.BoxESP or _G.NameESP or _G.HealthBars or _G.Tracers
		local cx = camera.ViewportSize.X / 2
		local cy = camera.ViewportSize.Y / 2

		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp then
				if not espCache[p] then createPlayerESP(p) end
				local data = espCache[p]
				if not data then continue end

				local show = anyESP and isAlive(p) and isEnemy(p)
				if not show then hidePlayerESP(p); continue end

				local char = p.Character
				local head = char:FindFirstChild("Head")
				local root = char:FindFirstChild("HumanoidRootPart")
				local hum  = char:FindFirstChild("Humanoid")

				if not (head and root and hum) then hidePlayerESP(p); continue end

				local topWorld = head.Position + Vector3.new(0, 0.8, 0)
				local botWorld = root.Position - Vector3.new(0, 2.8, 0)
				local topPos, topVis = camera:WorldToViewportPoint(topWorld)
				local botPos, botVis = camera:WorldToViewportPoint(botWorld)

				if not (topVis and botVis) then
					for _, l in ipairs(data.boxLines) do l.Visible = false end
					data.nameText.Visible = false
					data.healthBg.Visible = false
					data.healthFill.Visible = false
					data.tracerLine.Visible = false
					continue
				end

				local h = math.abs(botPos.Y - topPos.Y)
				local w = h * 0.55
				local mcx = (topPos.X + botPos.X) / 2
				local top = topPos.Y
				local bot = botPos.Y
				local left = mcx - w / 2
				local right = mcx + w / 2

				-- BOX ESP
				for i, l in ipairs(data.boxLines) do
					l.Visible = _G.BoxESP
					l.Color = _G.MainColor
					l.Thickness = 1.5
				end
				if _G.BoxESP then
					data.boxLines[1].From, data.boxLines[1].To = Vector2.new(left, top), Vector2.new(right, top)
					data.boxLines[2].From, data.boxLines[2].To = Vector2.new(right, top), Vector2.new(right, bot)
					data.boxLines[3].From, data.boxLines[3].To = Vector2.new(right, bot), Vector2.new(left, bot)
					data.boxLines[4].From, data.boxLines[4].To = Vector2.new(left, bot), Vector2.new(left, top)
				end

				-- NAME ESP
				data.nameText.Visible = _G.NameESP
				if _G.NameESP then
					local lpRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
					local dist = lpRoot and math.floor((lpRoot.Position - root.Position).Magnitude) or 0
					data.nameText.Text = (p.DisplayName or p.Name) .. " [" .. dist .. "]"
					data.nameText.Position = Vector2.new(mcx, top - 18)
					data.nameText.Color = _G.MainColor
				end

				-- HEALTH BARS
				data.healthBg.Visible, data.healthFill.Visible = _G.HealthBars, _G.HealthBars
				if _G.HealthBars then
					local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
					local barX = left - 6
					data.healthBg.From, data.healthBg.To = Vector2.new(barX, top), Vector2.new(barX, bot)
					local fillBot = bot - (bot - top) * hp
					data.healthFill.From, data.healthFill.To = Vector2.new(barX, bot), Vector2.new(barX, fillBot)
					data.healthFill.Color = Color3.new(hp < 0.5 and 1 or (1 - (hp - 0.5) * 2), hp > 0.5 and 1 or (hp * 2), 0)
				end

				-- TRACERS
				data.tracerLine.Visible = _G.Tracers
				if _G.Tracers then
					data.tracerLine.From = Vector2.new(cx, cy * 2)
					data.tracerLine.To   = Vector2.new(mcx, bot)
					data.tracerLine.Color = _G.MainColor
				end
			end
		end
	end)
end

--=============================================
-- SKELETON & CHAMS
--=============================================
local BONE_PAIRS = {
	{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
	{"UpperTorso","LeftUpperArm"},{"UpperTorso","RightUpperArm"},
	{"LowerTorso","LeftUpperLeg"},{"LowerTorso","RightUpperLeg"},
	{"LeftUpperArm","LeftLowerArm"},{"RightUpperArm","RightLowerArm"},
	{"LeftUpperLeg","LeftLowerLeg"},{"RightUpperLeg","RightLowerLeg"},
	{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
	{"Torso","Left Leg"},{"Torso","Right Leg"},
}

local function createBone(name, parent)
	local b = Instance.new("CylinderHandleAdornment")
	b.Name = name; b.Radius = 0.15; b.AlwaysOnTop = true; b.ZIndex = 10
	b.Color3 = _G.MainColor; b.Adornee = workspace.Terrain; b.Parent = parent
	return b
end

allConnections[#allConnections + 1] = RunService.Heartbeat:Connect(function()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp and p.Character then
			local char = p.Character
			-- SKELETON
			if _G.SkelESP and isAlive(p) and isEnemy(p) then
				local f = char:FindFirstChild("VSkel") or Instance.new("Folder", char)
				f.Name = "VSkel"
				for _, pair in ipairs(BONE_PAIRS) do
					local p1, p2 = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2])
					if p1 and p2 then
						local bone = f:FindFirstChild(pair[1]..pair[2]) or createBone(pair[1]..pair[2], f)
						bone.Color3 = _G.MainColor
						bone.Height = (p1.Position - p2.Position).Magnitude
						bone.CFrame = CFrame.lookAt(p1.Position, p2.Position) * CFrame.new(0, 0, -bone.Height / 2)
					end
				end
			else
				local sk = char:FindFirstChild("VSkel")
				if sk then sk:Destroy() end
			end
			
			-- CHAMS
			if _G.Chams and isAlive(p) and isEnemy(p) then
				local h = char:FindFirstChild("VChams") or Instance.new("Highlight", char)
				h.Name = "VChams"
				h.FillTransparency = 0.4
				h.OutlineTransparency = 0
				h.FillColor = _G.MainColor
				h.OutlineColor = _G.MainColor
			else
				local h = char:FindFirstChild("VChams")
				if h then h:Destroy() end
			end
		end
	end
end)

-- Anti-AFK logic removed due to VirtualUser restrictions on some executors

--=============================================
-- CHARACTER RESPAWN
--=============================================
allConnections[#allConnections + 1] = lp.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	local hum = char:WaitForChild("Humanoid", 5)
	if hum then
		hum.WalkSpeed = _G.WalkSpeedVal
		hum.JumpPower = _G.JumpPowerVal
	end
	if _G.FlyEnabled then
		local root = char:FindFirstChild("HumanoidRootPart")
		if root and hum then
			flyBV = Instance.new("BodyVelocity")
			flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
			flyBV.Velocity = Vector3.new(0, 0, 0)
			flyBV.Parent = root
			flyBG = Instance.new("BodyGyro")
			flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
			flyBG.D = 0
			flyBG.Parent = root
			hum.PlatformStand = true
		end
	end
end)

--=============================================
-- PLAYER JOIN / LEAVE
--=============================================
allConnections[#allConnections + 1] = Players.PlayerAdded:Connect(function(p) createPlayerESP(p) end)
allConnections[#allConnections + 1] = Players.PlayerRemoving:Connect(function(p)
	removePlayerESP(p)
	prevPositions[p.UserId] = nil
	if lockedTarget == p then lockedTarget = nil end
end)

--=============================================
-- KEYBINDS: PANIC (Delete) + TOGGLE GUI (RShift)
--=============================================
allConnections[#allConnections + 1] = UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end

	if input.KeyCode == Enum.KeyCode.RightShift then
		isMenuVisible = not isMenuVisible
		TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = isMenuVisible and showPos or hidePos
		}):Play()
		
		if isMenuVisible then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		end
	end

	if input.KeyCode == Enum.KeyCode.Delete then
		if hasDrawing then
			for _, data in pairs(espCache) do
				pcall(function()
					for _, l in ipairs(data.boxLines) do l:Remove() end
					data.nameText:Remove(); data.healthBg:Remove(); data.healthFill:Remove(); data.tracerLine:Remove()
				end)
			end
			if fovCircle then pcall(function() fovCircle:Remove() end) end
			if fpsText  then pcall(function() fpsText:Remove() end) end
			if watermarkText then pcall(function() watermarkText:Remove() end) end
			for _, l in ipairs(crossLines) do pcall(function() l:Remove() end) end
		end
		espCache = {}

		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character then
				local h = p.Character:FindFirstChild("VChams")
				if h then h:Destroy() end
				local s = p.Character:FindFirstChild("VSkel")
				if s then s:Destroy() end
				if origHitboxes[p.UserId] then
					local part = p.Character:FindFirstChild(_G.AimPart) or p.Character:FindFirstChild("Head")
					if part then
						part.Size = origHitboxes[p.UserId]
						part.Transparency = 0
						part.Material = Enum.Material.Plastic
						part.CanCollide = true
					end
				end
			end
		end

		if flyBV then flyBV:Destroy(); flyBV = nil end
		if flyBG then flyBG:Destroy(); flyBG = nil end
		local char = lp.Character
		if char then
			local hum = char:FindFirstChild("Humanoid")
			if hum then hum.PlatformStand = false; hum.WalkSpeed = 16; hum.JumpPower = 50 end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = true end
			end
		end
		
		Lighting.Ambient = origAmbient
		Lighting.OutdoorAmbient = origOutdoor

		for _, c in ipairs(allConnections) do pcall(function() c:Disconnect() end) end
		allConnections = {}
		ScreenGui:Destroy()
	end
end)


print("[murgichor v4.0] Loaded — Delete = panic | RShift = toggle GUI")
