local cas = game:GetService("ContextActionService")
local coregui = game:GetService("CoreGui")
local run = game:GetService("RunService")
local lighting = game:GetService("Lighting")

local rep = game:GetService("ReplicatedStorage")
local remote = rep:WaitForChild("RemoteEvents"):WaitForChild("TestHandler")
local matchpl = rep:WaitForChild("Match"):WaitForChild("Players")
local killer = matchpl:WaitForChild("Player(V)")

local pl = game:GetService("Players").LocalPlayer
	local char = pl.Character or pl.CharacterAdded:Wait()
	local lathandler = pl.Backpack:WaitForChild("Handlers"):WaitForChild("LatencyHandler")

if cas:GetBoundActionInfo("Phase").inputTypes then
	warn("Phase Walk is already running!")
	return
end

if killer.Value == "" then
	killer.Changed:Wait()
end

local phasing, iskiller, con = false, (killer.Value == pl.Name), nil

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
		 if phasing == false then
		 	phasing = true

		 	sound:Play()
		 	cor.Enabled = true

		 	husk.CFrame = char.HumanoidRootPart.CFrame
		 	velo.Velocity = char.Humanoid.MoveDirection * 16
		 	husk.Parent = workspace

		 	if iskiller == true then
		 		lathandler.Disabled = true
		 	end

		 	con = run.RenderStepped:Connect(function()
		 		remote:FireServer(husk.CFrame)
		 	end)
		 elseif phasing == true then
		 	if con then
		 		con:Disconnect()
		 		con = nil
		 	end

		 	if iskiller == true then
		 		lathandler.Disabled = false
		 	end

		 	sound:Stop()
		 	
		 	phasing = false
		 	cor.Enabled = false
		 	velo.Velocity = Vector3.new(0, 0, 0)
		 	husk.Parent = nil
		 end
	end
end

local GameMt = getrawmetatable(game)
local OldNameCall = GameMt.__namecall

setreadonly(GameMt, false)

GameMt.__namecall = newcclosure(function(Self, ...)
    local Args = {...}
    local NamecallMethod = getnamecallmethod()

    if not checkcaller() and NamecallMethod == "FireServer" and Self.Name == "TestHandler" and iskiller == false and phasing == true then
        return nil
    end

    return OldNameCall(Self, ...)
end)

setreadonly(GameMt, true)

cas:BindAction("Phase", togglephase, false, Enum.KeyCode.Q)