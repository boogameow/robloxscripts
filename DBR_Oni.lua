-- services
local rep = game:GetService("ReplicatedStorage")
local cgui = game:GetService("CoreGui")
local cas = game:GetService("ContextActionService")
local ts = game:GetService("TweenService")
local kstuff = rep:WaitForChild("KillerStuff")
local matchpl = rep:WaitForChild("Match"):WaitForChild("Players")
local killer = matchpl:WaitForChild("Player(V)")

local ps = game:GetService("Players")
local pl = ps.LocalPlayer
	local gui = pl.PlayerGui
	local bp = pl.Backpack
	local val = bp:WaitForChild("Scripts"):WaitForChild("values")
	local char = pl.Character or pl.CharacterAdded:Wait()

-- conditionals
if killer.Value == "" then
	killer.Changed:Wait() -- wait until there is a killer
end

if killer.Value ~= pl.Name then
	warn("You must be playing Killer for The Oni to work.")
	return
elseif bp.Scripts.Killer.Character.Value ~= "HillBilly" then
	warn("You must be playing Billy for The Oni to work.")
	return
elseif cas:GetBoundActionInfo("Absorb").inputTypes then
	warn("There is an instance of Oni already running.")
	return
end

-- controlled variables
local orbdroptime = 4
local orbgrabdistance = 15
local orbgrabtime = 1.25
local orbgrabcharges = 5
local furylength = 50

-- independent variables
local visible = false
local powercharges = 0
local powerstate = ""

local orbfolder = Instance.new("Folder", workspace)

-- interface
local int = Instance.new("ScreenGui")
	syn.protect_gui(int)
	int.Name = "Caption"
	int.ResetOnSpawn = false
	int.Parent = cgui

-- sounds
local grabsound = Instance.new("Sound", int)
	grabsound.Name = "Grab Orb"
	grabsound.SoundId = "rbxassetid://5365129954"
	grabsound.Volume = 2
	grabsound.PlaybackSpeed = 0.75 / orbgrabtime

local obtainsound = Instance.new("Sound", int)
	obtainsound.Name = "Fury Ready"
	obtainsound.SoundId = "rbxassetid://6666257074"
	obtainsound.Volume = 0.85

local furysound = Instance.new("Sound", int)
	furysound.Name = "Fury Activated"
	furysound.SoundId = "rbxassetid://6666350716"
	furysound.Volume = 5
	furysound.PlaybackSpeed = 0.95

local activesound = Instance.new("Sound", int)
	activesound.Name = "Fury Active"
	activesound.SoundId = "rbxassetid://5912251061"
	activesound.Volume = 0
	activesound.Looped = true

local endsound = Instance.new("Sound", int)
	endsound.Name = "Fury Ended"
	endsound.SoundId = "rbxassetid://5591296905"
	endsound.Volume = 8

-- ability circle
local rad = Instance.new("ImageLabel", int)
	rad.Name = "Circle"
	rad.AnchorPoint = Vector2.new(0.5, 0.5)
	rad.BackgroundTransparency = 1
	rad.BorderSizePixel = 0
	rad.Position = UDim2.new(0.9, 0, 0.75, 0)
	rad.Size = UDim2.new(0.06, 0, 0.06, 0)
	rad.SizeConstraint = Enum.SizeConstraint.RelativeXX
	rad.Image = "rbxassetid://6665182126"
	rad.ImageTransparency = 1

local grad = Instance.new("UIGradient", rad)
	grad.Name = "Gradient"
	grad.Rotation = 90
	grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(0.001, Color3.new(0, 0, 0)), ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))}

local label = Instance.new("TextLabel", rad)
	label.Name = "Action"
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Position = UDim2.new(0.5, 0, 0.5, 0)
	label.Size = UDim2.new(0.75, 0, 0.15, 0)
	label.Font = Enum.Font.GothamBlack
	label.Text = ""
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.TextTransparency = 1

-- blood meter
local meterbar = Instance.new("Frame", int)
	meterbar.Name = "Meter"
	meterbar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	meterbar.BorderSizePixel = 0
	meterbar.Position = UDim2.new(0.02, 0, 0.675, 0)
	meterbar.Size = UDim2.new(0.2, 0, 0.015, 0)
	meterbar.ZIndex = 2

local fillbar = meterbar:Clone()
	fillbar.Name = "Fill"
	fillbar.Position = UDim2.new(0, 0, 0, 0)
	fillbar.ZIndex = 3
	fillbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	fillbar.Size = UDim2.new(0, 0, 1, 0)
	fillbar.Parent = meterbar

local meterlabel = Instance.new("TextLabel", meterbar)
	meterlabel.Name = "Meter Label"
	meterlabel.BackgroundTransparency = 1
	meterlabel.BorderSizePixel = 0
	meterlabel.Position = UDim2.new(0, 0, 0, 0)
	meterlabel.Size = UDim2.new(1, 0, -1.5, 0)
	meterlabel.Font = Enum.Font.GothamSemibold
	meterlabel.Text = "Blood Meter"
	meterlabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	meterlabel.TextScaled = true

-- functions
local function createOrb(cf)
	local orb = Instance.new("Part")
		orb.Name = "Orb"
		orb.CastShadow = true
		orb.Color = Color3.fromRGB(255, 0, 0)
		orb.Material = Enum.Material.Neon
		orb.Transparency = 0.75
		orb.Size = Vector3.new(0.01, 0.01, 0.01)
		orb.Anchored = true
		orb.CanCollide = false
		orb.Massless = true
		orb.Shape = Enum.PartType.Ball
		orb.CFrame = cf
		orb.Parent = orbfolder

	ts:Create(orb, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {Size = Vector3.new(2, 2, 2)}):Play()
end

local function allowAttacking(bool)
	if bool == false and val.KillerAction.Value == "Nothing" then
		val.KillerAction.Value = "Caption"
	elseif bool == true and val.KillerAction.Value == "Caption" then
		val.KillerAction.Value = "Nothing"
	end
end

local function updateBloodMeter()
	ts:Create(fillbar, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {Size = UDim2.new(powercharges / 100, 0, 1, 0)}):Play()

	if powercharges >= 100 and powerstate ~= "Ready" and powerstate ~= "Fury" then
		powerstate = "Ready"
		meterlabel.Text = "R : Activate Blood Fury"
		obtainsound:Play()
		orbfolder:ClearAllChildren()
	end
end

local function findNearbyOrbs(dist)
	local pos = char.HumanoidRootPart.Position
	local result = {}

	for i, v in pairs(orbfolder:GetChildren()) do
		local mag = (pos - v.Position).magnitude

		if mag < dist then
			table.insert(result, #result + 1, v)
		end
	end

	return result
end

local function abilityCircle(length, activity)
	if visible == false then
		visible = true

		label.Text = activity
		grad.Offset = Vector2.new(0, 0)

		local info = TweenInfo.new(0.5, Enum.EasingStyle.Linear)

		ts:Create(rad, info, {ImageTransparency = 0}):Play()
		ts:Create(label, info, {TextTransparency = 0}):Play()
		ts:Create(grad, TweenInfo.new(length, Enum.EasingStyle.Linear), {Offset = Vector2.new(0, 1)}):Play()

		delay(length, function()
			ts:Create(rad, info, {ImageTransparency = 1}):Play()

			local tw = ts:Create(label, info, {TextTransparency = 1})
			tw:Play()
			tw.Completed:Wait()

			visible = false
		end)
	end
end

local function absorb(_, st)
	if powerstate == "" and st == Enum.UserInputState.Begin and char and visible == false and val.KillerAction.Value == "Nothing" then
		local orbs = findNearbyOrbs(orbgrabdistance)

		if #orbs > 0 and powerstate == "" then
			powerstate = "Absorption"

			local pos = char.HumanoidRootPart.Position

			for i, v in pairs(orbs) do
				coroutine.wrap(function()
					for i = 0, 1, .01 do
						v.CFrame = v.CFrame:Lerp(char.HumanoidRootPart.CFrame, i)
						wait(orbgrabtime / 100)
					end
				end)()

				ts:Create(v, TweenInfo.new(orbgrabtime, Enum.EasingStyle.Linear), {Transparency = 1}):Play()
				powercharges = math.clamp(powercharges + orbgrabcharges, 0, 100)
				game.Debris:AddItem(v, orbgrabtime)
			end

			grabsound:Play()
			abilityCircle(orbgrabtime, "Absorb")
			allowAttacking(false)
			char.Humanoid.WalkSpeed = 8

			delay(orbgrabtime, function()
				updateBloodMeter()
				allowAttacking(true)
				char.Humanoid.WalkSpeed = 18

				delay(1, function()
					if powerstate == "Absorption" then
						powerstate = ""
					end
				end)
			end)
		end
	end
end

local function activatePower(_, st)
	if powerstate == "Ready" and visible == false and st == Enum.UserInputState.Begin and char and val.KillerAction.Value == "Nothing" then
		powerstate = "Fury"

		char.Humanoid.WalkSpeed = 3
		allowAttacking(false)
		meterlabel.Text = "Activating Fury"

		activesound.Volume = 0
		activesound:Play()

		ts:Create(fillbar, TweenInfo.new(2, Enum.EasingStyle.Linear), {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}):Play()
		ts:Create(activesound, TweenInfo.new(5, Enum.EasingStyle.Linear), {Volume = 0.85}):Play()

		furysound:Play()
		furysound.Ended:Wait()

		meterlabel.Text = "Fury Active"
		meterlabel.Font = Enum.Font.GothamBold
		char.Humanoid.WalkSpeed = 18
		allowAttacking(true)

		ts:Create(fillbar, TweenInfo.new(furylength, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()

		delay(furylength - 1, function()
			ts:Create(activesound, TweenInfo.new(1, Enum.EasingStyle.Linear), {Volume = 0}):Play()

			delay(1, function()
				activesound:Stop()

				endsound:Play()
				powercharges = 0
				meterlabel.Text = "Blood Meter"
				meterlabel.Font = Enum.Font.GothamSemibold
				powerstate = ""
			end)
		end)
	end
end

local function setupPlayer(pl)
	coroutine.wrap(function()
		local hs = pl.Backpack:WaitForChild("Scripts"):WaitForChild("values"):WaitForChild("HealthState")
		local char = pl.Character or pl.CharacterAdded:Wait()

		while wait(orbdroptime) do
			if not char or not hs or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
				break
			elseif hs.Value == 1 and powerstate ~= "Ready" and powerstate ~= "Fury" then
				createOrb(char.HumanoidRootPart.CFrame)
			end
		end
	end)()
end

ps.PlayerAdded:Connect(setupPlayer)

for i, v in pairs(ps:GetChildren()) do
	if v.UserId ~= pl.UserId then
		setupPlayer(v)
	end
end

-- the actual oni turning

local mt = getrawmetatable(game)
local oldcall = mt.__namecall

setreadonly(mt, false)

mt.__namecall = newcclosure(function(Self, ...)
    local Args = {...}
    local NamecallMethod = getnamecallmethod()

    if not checkcaller() and NamecallMethod == "FindFirstChild" and Self.Name == "Chainsaw" and Args[1] == "Activated" and powerstate == "Fury" then
        return nil
    end

    return oldcall(Self, ...)
end)

setreadonly(mt, true)

-- keybinds

cas:BindAction("Absorb", absorb, false, Enum.KeyCode.LeftControl)
cas:BindAction("Fury", activatePower, false, Enum.KeyCode.R)

-- misc
gui.AmbientSounds.Chase1.SoundId = "rbxassetid://4627984150"