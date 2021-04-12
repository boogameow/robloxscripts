local cas = game:GetService("ContextActionService")
local coregui = game:GetService("CoreGui")
local run = game:GetService("RunService")
local lighting = game:GetService("Lighting")

local rep = game:GetService("ReplicatedStorage")
local remote = rep:WaitForChild("RemoteEvents"):WaitForChild("TestHandler")

local pl = game:GetService("Players").LocalPlayer
	local char = pl.Character or pl.CharacterAdded:Wait()
	local lathandler = pl.Backpack:WaitForChild("Handlers"):WaitForChild("LatencyHandler")

if cas:GetBoundActionInfo("Phase").inputTypes then
	warn("Phase Walk is already running!")
	return
end

local phasing, con = false, nil

local sound = Instance.new("Sound", coregui)
	sound.SoundId = "rbxassetid://362395087"
	sound.Volume = 1.25
	sound.Looped = true

local cor = Instance.new("ColorCorrectionEffect")
	cor.Enabled = false
	cor.TintColor = Color3.fromRGB(0, 255, 85)
	cor.Name = "Phase"
	cor.Parent = lighting

local husk = Instance.new("Part")
	husk.Name = "Husk"
	husk.CastShadow = false
	husk.Anchored = false
	husk.CanCollide = false
	husk.Transparency = 0.25
	husk.Massless = true
	husk.Size = Vector3.new(2, 2, 2)

local velo = Instance.new("BodyVelocity", husk)
	velo.Velocity = Vector3.new(0, 0, 0)

local bill = Instance.new("BillboardGui", husk)
	bill.AlwaysOnTop = true
	bill.LightInfluence = 0
	bill.ResetOnSpawn = false
	bill.Size = UDim2.new(0, 400, 0, 30)

local label = Instance.new("TextLabel", bill)
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Font = Enum.Font.GothamBold
	label.Text = "YOUR HUSK"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true

local function togglephase(_, st, inp)
	if st == Enum.UserInputState.Begin then
		 if inp.KeyCode == Enum.KeyCode.F1 and phasing == false then
		 	phasing = true

		 	sound:Play()
		 	cor.Enabled = true

		 	husk.CFrame = char.HumanoidRootPart.CFrame
		 	velo.Velocity = char.Humanoid.MoveDirection * 16
		 	lathandler.Disabled = true
		 	husk.Parent = workspace

		 	con = run.RenderStepped:Connect(function()
		 		remote:FireServer(husk.CFrame)
		 	end)
		 elseif inp.KeyCode == Enum.KeyCode.F2 and phasing == true then
		 	if con then
		 		con:Disconnect()
		 		con = nil
		 	end

		 	phasing = false

			sound:Stop()
		 	cor.Enabled = false
		 	lathandler.Disabled = false
		 	velo.Velocity = Vector3.new(0, 0, 0)
		 	husk.Parent = nil
		 end
	end
end

cas:BindAction("Phase", togglephase, false, Enum.KeyCode.F1, Enum.KeyCode.F2)