-- services
local run = game:GetService("RunService")
local cgui = game:GetService("CoreGui")
local cas = game:GetService("ContextActionService")
local ts = game:GetService("TweenService")
local lighting = game:GetService("Lighting")

local rep = game:GetService("ReplicatedStorage")
	local kstuff = rep:WaitForChild("KillerStuff")
	local matchpl = rep:WaitForChild("Match"):WaitForChild("Players")
	local killer = matchpl:WaitForChild("Player(V)")

local ps = game:GetService("Players")
local pl = ps.LocalPlayer
	local gui = pl.PlayerGui
	local bp = pl.Backpack
	local mouse = pl:GetMouse()
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

if not char:IsDescendantOf(workspace) then
	char.AncestryChanged:Wait() -- waits until they are "loaded"
end

-- controlled variables
local orbdroptime = 4
local orbgrabdistance = 15
local orbgrabtime = 1
local orbgrabcharges = 5
local furylength = 50

-- independent variables
local powercharges = 0
local furyactive = false
local powerfull = false
local bloodmode = true
local absorbing = false

local orbfolder = Instance.new("Folder", workspace)
local cor = Instance.new("ColorCorrectionEffect", lighting)

local grabanim = Instance.new("Animation")
	grabanim.AnimationId = "rbxassetid://2753391644"
	grabanim = char:WaitForChild("Humanoid"):LoadAnimation(grabanim)
	grabanim.Looped = true
	grabanim.Priority = Enum.AnimationPriority.Action

local chainsaw = char:WaitForChild("Chainsaw")

-- interface
local int = Instance.new("ScreenGui")
	syn.protect_gui(int)
	int.ResetOnSpawn = false
	int.Parent = cgui

-- sounds
local grabsound = Instance.new("Sound", int)
	grabsound.SoundId = "rbxassetid://5365129954"
	grabsound.Volume = 2

local obtainsound = Instance.new("Sound", int)
	obtainsound.SoundId = "rbxassetid://6666257074"
	obtainsound.Volume = 0.9

local furysound = Instance.new("Sound", int)
	furysound.SoundId = "rbxassetid://6666350716"
	furysound.Volume = 5.5

local activesound = Instance.new("Sound", int)
	activesound.SoundId = "rbxassetid://5912251061"
	activesound.Volume = 0
	activesound.Looped = true

local endsound = Instance.new("Sound", int)
	endsound.SoundId = "rbxassetid://5591296905"
	endsound.Volume = 7.5

-- ability circle
local rad = Instance.new("ImageLabel", int)
	rad.AnchorPoint = Vector2.new(0.5, 0.5)
	rad.BackgroundTransparency = 1
	rad.BorderSizePixel = 0
	rad.Position = UDim2.new(0.16, 0, 0.785, 0)
	rad.Size = UDim2.new(0.06, 0, 0.06, 0)
	rad.SizeConstraint = Enum.SizeConstraint.RelativeXX
	rad.Image = "rbxassetid://6665182126"
	rad.ImageTransparency = 0.4

local grad = Instance.new("UIGradient", rad)
	grad.Rotation = 90
	grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)), ColorSequenceKeypoint.new(0.001, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))}

local label = Instance.new("TextLabel", rad)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Position = UDim2.new(0.5, 0, 0.5, 0)
	label.Size = UDim2.new(0.75, 0, 0.17, 0)
	label.Font = Enum.Font.GothamBlack
	label.Text = "BLOOD"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.TextTransparency = 0.4

local keybind = Instance.new("TextLabel", int)
	keybind.AnchorPoint = Vector2.new(0.5, 1)
	keybind.BackgroundTransparency = 1
	keybind.BorderSizePixel = 0
	keybind.Position = UDim2.new(0.5, 0, 0.95, 0)
	keybind.Size = UDim2.new(0.2, 0, 0.02, 0)
	keybind.Font = Enum.Font.GothamBlack
	keybind.Text = "[ CTRL - Absorb ]"
	keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
	keybind.TextTransparency = 0.5
	keybind.TextScaled = true

-- functions
local function makeChainsawVisible(t)
	for i, v in pairs(chainsaw:WaitForChild("BodyParts"):GetChildren()) do
		if v:IsA("BasePart") then
			v.Transparency = t
		end
	end
end

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

local function absorb(_, st)
	if bloodmode == true and char then
		if st == Enum.UserInputState.Begin then
			if absorbing == false and val.KillerAction.Value == "Nothing" then
				absorbing = true
				keybind.Visible = false
				allowAttacking(false)
				grabanim:Play(0.25)
			end
		elseif st == Enum.UserInputState.End and absorbing == true then
			absorbing = false
			keybind.Visible = true
			allowAttacking(true)
			grabanim:Stop()
		end
	end
end

local function updateBloodMeter()
	ts:Create(grad, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {Offset = Vector2.new(0, powercharges / 100)}):Play()

	if powercharges >= 100 and powerfull == false then
		if absorbing == true then
			absorb(nil, Enum.UserInputState.End)
		end

		powerfull = true
		bloodmode = false
		label.Text = "READY"
		keybind.Text = " [ F - Blood Fury ]"
		obtainsound:Play()
		orbfolder:ClearAllChildren()
	end
end

local function findNearbyOrbs(dist)
	local pos = char.HumanoidRootPart.Position
	local result = {}

	for i, v in pairs(orbfolder:GetChildren()) do
		local mag = (pos - v.Position).magnitude

		if mag < dist and not v:FindFirstChild("Grabbing") then
			table.insert(result, #result + 1, v)
		end
	end

	return result
end

local function activatePower(_, st)
	if powerfull == true and furyactive == false and st == Enum.UserInputState.Begin and char and val.KillerAction.Value == "Nothing" then
		furyactive = true
		keybind.Visible = false

		char.Humanoid.WalkSpeed = 3
		label.Text = "FURY"
		allowAttacking(false)

		ts:Create(label, TweenInfo.new(2, Enum.EasingStyle.Linear), {TextColor3 = Color3.fromRGB(255, 0, 0)}):Play()
		ts:Create(cor, TweenInfo.new(2, Enum.EasingStyle.Linear), {TintColor = Color3.fromRGB(255, 0, 0)}):Play()

		furysound:Play()
		furysound.Ended:Wait()
		
		char.Humanoid.WalkSpeed = 18
		allowAttacking(true)
		chainsaw:WaitForChild("ActionScript").Disabled = false
		activesound:Play()

		ts:Create(grad, TweenInfo.new(furylength, Enum.EasingStyle.Linear), {Offset = Vector2.new(0, 0)}):Play()
		ts:Create(activesound, TweenInfo.new(2, Enum.EasingStyle.Linear), {Volume = 0.9}):Play()

		delay(furylength - 1, function()
			ts:Create(activesound, TweenInfo.new(1, Enum.EasingStyle.Linear), {Volume = 0}):Play()
			ts:Create(label, TweenInfo.new(1, Enum.EasingStyle.Linear), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			ts:Create(cor, TweenInfo.new(1, Enum.EasingStyle.Linear), {TintColor = Color3.fromRGB(255, 255, 255)}):Play()

			delay(1, function()
				activesound:Stop()
				endsound:Play()
				powercharges = 0
				label.Text = "BLOOD"
				keybind.Text = "[ CTRL - Absorb ]"
				keybind.Visible = true
				powerfull = false
				furyactive = false
				bloodmode = true

				if chainsaw.Activated.Value == true or chainsaw.Activating.Value == true then
					for i, v in pairs(getconnections(mouse.Button2Down)) do
						v:Disable()
					end

					firesignal(mouse.Button2Up, nil)

					con = chainsaw.KeepProgress.Changed:Connect(function()
						if chainsaw.KeepProgress.Value <= 0 then
							con:Disconnect()
							chainsaw:WaitForChild("ActionScript").Disabled = true
						end
					end)
				end
			end)
		end)
	end
end

local function setupPlayer(pl)
	coroutine.wrap(function()
		local hs = pl.Backpack:WaitForChild("Scripts"):WaitForChild("values"):WaitForChild("HealthState")
		local char2 = pl.Character or pl.CharacterAdded:Wait()

		while wait(orbdroptime) do
			if not char2 or not hs or not char2:FindFirstChild("HumanoidRootPart") or not char2:FindFirstChild("Humanoid") or char2.Humanoid.Health <= 0 then
				break
			elseif hs.Value == 1 and bloodmode == true then
				createOrb(char2.HumanoidRootPart.CFrame)
			end
		end
	end)()
end

run.RenderStepped:Connect(function()
	if absorbing == true and bloodmode == true and powerfull == false then
		local orbs = findNearbyOrbs(orbgrabdistance)

		if #orbs > 0 and powerfull == false then
			local pos = char.HumanoidRootPart.Position

			for i, v in pairs(orbs) do
				Instance.new("BoolValue", v).Name = "Grabbing"

				coroutine.wrap(function()
					for i = 0, 1, .01 do
						v.CFrame = v.CFrame:Lerp(char.HumanoidRootPart.CFrame, i)
						wait(orbgrabtime / 100)
					end
				end)()

				ts:Create(v, TweenInfo.new(orbgrabtime, Enum.EasingStyle.Linear), {Transparency = 1}):Play()

				delay(orbgrabtime, function()
					v:Destroy()

					if powerfull == false then
						powercharges = math.clamp(powercharges + orbgrabcharges, 0, 100)
						updateBloodMeter()
					end
				end)
			end

			local sound = grabsound:Clone()
			sound.Parent = int 
			sound:Play()
		end
	end
end)

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

    if not checkcaller() and NamecallMethod == "FindFirstChild" and Self.Name == "Chainsaw" and Args[1] == "Activated" then
        return nil
    end

    return oldcall(Self, ...)
end)

setreadonly(mt, true)

-- keybinds

cas:BindAction("Absorb", absorb, false, Enum.KeyCode.LeftControl)
cas:BindAction("Fury", activatePower, false, Enum.KeyCode.F)

-- misc
gui.AmbientSounds.Chase1.SoundId = "rbxassetid://4627984150"
gui.MatchGUI.KillerPowers.HillBilly:Destroy()
makeChainsawVisible(1)
chainsaw:WaitForChild("ActionScript").Disabled = true