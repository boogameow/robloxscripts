local run = game:GetService("RunService")
local ps = game:GetService("Players")
	local pl = ps.LocalPlayer
	local selfdata = pl:WaitForChild("TempPlayerStatsModule")

local curgui = pl.PlayerGui:WaitForChild("ScreenGui")
	curgui.ResetOnSpawn = false
	curgui.StatusBars.Visible = false
	curgui.GameInfoFrame.Visible = false

local ts = game:GetService("TweenService")
	local info = TweenInfo.new(.2, Enum.EasingStyle.Linear)

local rep = game:GetService("ReplicatedStorage")
	local beast
	local active = rep.IsGameActive
	local gens = rep.ComputersLeft
	local timeleft = rep.GameTimer
	local map = rep.CurrentMap


local inchase = false
local escaped = false
local rescuedb = false
local ongen = false
local orig = 0
local startchase = 0
local genprog = 0
local chasetick = 0
local endchasetime = 6


-- SURVIVOR:
-- objective
local computerbp = 10
local opengatebp = 1500

-- survival
local graspescapebp = 1000 -- awarded for escaping the killer
local survivedbp = 4000 -- awarded for surviving

-- boldness
local chasebp = 60 -- earned bp per second
local escapedchasebp = 300 -- bonus for winning a chase

-- altruism 
local rescuebp = 750
local saferescuebp = 250
local protectionbp = 500


local gone, fade
local queue = {}
local musics = {"rbxassetid://4743442159", "rbxassetid://4743720538", "rbxassetid://4627984150", "rbxassetid://1410762446", "rbxassetid://6154346256", "rbxassetid://6172092571"}

local categories = {
	["Survival"] = {0, "rbxassetid://6100699830"};
	["Objective"] = {0, "rbxassetid://6100699948"};
	["Boldness"] = {0, "rbxassetid://6100700044"};
	["Altruism"] = {0, "rbxassetid://6175736811"}
}

local states = {
	["Disconnect"] = "rbxassetid://6182998912";
	["Healthy"] = "rbxassetid://6182953419";
	["Captured"] = "rbxassetid://6183376914";
	["Dead"] = "rbxassetid://6183373907";
	["Knocked"] = "rbxassetid://6183370183";
	["Escaped"] = "rbxassetid://6183595110"
}


local gui = Instance.new("ScreenGui", pl.PlayerGui)
	gui.Name = "DBD"
	gui.ResetOnSpawn = false

local version = Instance.new("TextLabel", gui)
	version.Name = "Version"
	version.AnchorPoint = Vector2.new(0, 1)
	version.BackgroundTransparency = 1
	version.BorderSizePixel = 0
	version.Position = UDim2.new(0, 0, 1, 0)
	version.Size = UDim2.new(0.2, 0, 0.02, 0)
	version.Font = Enum.Font.GothamSemibold
	version.Text = "Failed to load Script. (Press F9)"
	version.TextColor3 = Color3.fromRGB(255, 0, 0)
	version.TextScaled = true
	version.TextXAlignment = Enum.TextXAlignment.Left
	version.TextYAlignment = Enum.TextYAlignment.Bottom
	version.ZIndex = 10

local chasemusic = Instance.new("Sound", gui)
	chasemusic.Name = "Chase"
	chasemusic.Volume = 0
	chasemusic.Looped = true
	chasemusic.Playing = true
	chasemusic.SoundId = musics[math.random(1, #musics)]

local gensound = Instance.new("Sound", gui)
	gensound.Name = "Generator"
	gensound.Volume = .8
	gensound.SoundId = "rbxassetid://6183313125"

local g1 = {Volume = .85}
local g2 = {Volume = 0}
local intw = ts:Create(chasemusic, TweenInfo.new(1, Enum.EasingStyle.Linear), g1)
local outtw = ts:Create(chasemusic, TweenInfo.new(2, Enum.EasingStyle.Linear), g2)

-- in-game awards
local award = Instance.new("ImageLabel")
	award.Name = "Award"
	award.AnchorPoint = Vector2.new(0, 0.5)
	award.BackgroundTransparency = 1
	award.BorderSizePixel = 0
	award.Position = UDim2.new(0.02, 0, 0.5, 0)
	award.Size = UDim2.new(0.05, 0, 0.05, 0)
	award.SizeConstraint = Enum.SizeConstraint.RelativeXX
	award.ZIndex = 2
	award.ImageTransparency = 1
	award.Image = "rbxassetid://6100256142"

local image = Instance.new("ImageLabel", award)
	image.Name = "Category"
	image.AnchorPoint = Vector2.new(0.5, 0.5)
	image.BackgroundTransparency = 1
	image.ImageTransparency = 1
	image.BorderSizePixel = 0
	image.Position = UDim2.new(0.5, 0, 0.5, 0)
	image.Size = UDim2.new(0.75, 0, 0.75, 0)
	image.Image = "rbxassetid://6100699948"

local action = Instance.new("TextLabel", award)
	action.Name = "Action"
	action.BackgroundTransparency = 1
	action.BorderSizePixel = 0
	action.Position = UDim2.new(1, 0, 0.25, 0)
	action.Size = UDim2.new(4, 0, 0.25, 0)
	action.Font = Enum.Font.GothamBold
	action.Text = "PLACEHOLDER TEXT"
	action.TextTransparency = 1
	action.TextColor3 = Color3.fromRGB(255, 255, 255)
	action.TextScaled = true
	action.TextXAlignment = Enum.TextXAlignment.Left

local bp = action:Clone()
	bp.Name = "BP"
	bp.Parent = award
	bp.Size = UDim2.new(4, 0, 0.2, 0)
	bp.Position = UDim2.new(1, 0, 0.5, 0)
	bp.Font = Enum.Font.GothamSemibold
	bp.Text = "+0"
	bp.TextTransparency = 1
	bp.TextColor3 = Color3.fromRGB(255, 0, 0)

local grad = Instance.new("UIGradient", award)
	grad.Name = "Grad"
	grad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	grad.Rotation = -90

-- match stuff
local status = Instance.new("TextLabel", gui)
	status.Name = "Status"
	status.AnchorPoint = Vector2.new(0.5, 0)
	status.BackgroundTransparency = 1
	status.BorderSizePixel = 0
	status.Position = UDim2.new(0.5, 0, 0.03, 0)
	status.Size = UDim2.new(0.75, 0, 0.03, 0)
	status.Font = Enum.Font.Gotham
	status.Text = ""
	status.TextScaled = true
	status.TextTransparency = 0.2
	status.TextColor3 = Color3.fromRGB(255, 255, 255)

local match = Instance.new("Frame", gui)
	match.Name = "Game"
	match.BorderSizePixel = 0
	match.BackgroundTransparency = 1
	match.Size = UDim2.new(1, 0, 1, 0)
	match.Visible = false

local matchdivider = Instance.new("Frame", match)
	matchdivider.Name = "Divider"
	matchdivider.AnchorPoint = Vector2.new(0, 1)
	matchdivider.BackgroundTransparency = 0.5
	matchdivider.BorderSizePixel = 0
	matchdivider.Position = UDim2.new(0.02, 0, 0.89, 0)
	matchdivider.Size = UDim2.new(0.165, 0, 0.005, 0)

local last = NumberSequenceKeypoint.new(1, 0.9)
local middle = NumberSequenceKeypoint.new(0.5, 0.25)
local start = NumberSequenceKeypoint.new(0, 0.9)

local dividgrad = Instance.new("UIGradient", matchdivider)
	dividgrad.Name = "Grad"
	dividgrad.Transparency = NumberSequence.new({start, middle, last})

local genimage = Instance.new("ImageLabel", matchdivider)
	genimage.Name = "Image"
	genimage.BackgroundTransparency = 1
	genimage.BorderSizePixel = 0
	genimage.Position = UDim2.new(0.12, 0, -10, 0)
	genimage.Size = UDim2.new(0.18, 0, 9, 0)
	genimage.Image = "rbxassetid://6183021590"
	genimage.ImageTransparency = 0.5

local gentext = Instance.new("TextLabel", matchdivider)
	gentext.Name = "Gens"
	gentext.BackgroundTransparency = 1
	gentext.BorderSizePixel = 0
	gentext.Position = UDim2.new(0.04, 0, -10, 0)
	gentext.Size = UDim2.new(0.1, 0, 9, 0)
	gentext.Font = Enum.Font.Gotham
	gentext.Text = "-"
	gentext.TextScaled = true
	gentext.TextTransparency = 0.5
	gentext.TextXAlignment = Enum.TextXAlignment.Left
	gentext.TextColor3 = Color3.fromRGB(255, 255, 255)

local players = Instance.new("Frame", match)
	players.Name = "Players"
	players.AnchorPoint = Vector2.new(0, 1)
	players.BackgroundTransparency = 1
	players.BorderSizePixel = 0
	players.Position = UDim2.new(0.03, 0, 0.95, 0)
	players.Size = UDim2.new(0.13, 0, 0.05, 0)

local list = Instance.new("UIListLayout", players)
	list.Name = "List"
	list.FillDirection = Enum.FillDirection.Horizontal
	list.Padding = UDim.new(0.09, 0)

local example = Instance.new("ImageLabel")
	example.Name = "User"
	example.BackgroundTransparency = 1
	example.BorderSizePixel = 0
	example.Size = UDim2.new(0.22, 0, 1, 0)
	example.ZIndex = 2
	example.Image = states["Healthy"]
	example.ImageTransparency = 0.6

local hp = Instance.new("Frame", example)
	hp.Name = "Health"
	hp.AnchorPoint = Vector2.new(0, 0)
	hp.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	hp.BackgroundTransparency = 1
	hp.BorderSizePixel = 0
	hp.Position = UDim2.new(0, 0, 1.3, 0)
	hp.Size = UDim2.new(1, 0, 0.08, 0)
	hp.Visible = false

local last = NumberSequenceKeypoint.new(1, 0)
local middle = NumberSequenceKeypoint.new(0.25, 0.45)
local start = NumberSequenceKeypoint.new(0, 0.9)

local hpgrad = Instance.new("UIGradient", hp)
	hpgrad.Name = "Grad"
	hpgrad.Transparency = NumberSequence.new({start, middle, last})

local plrname = Instance.new("TextLabel", example)
	plrname.Name = "User"
	plrname.AnchorPoint = Vector2.new(0.5, 0)
	plrname.BackgroundTransparency = 1
	plrname.BorderSizePixel = 0
	plrname.Position = UDim2.new(0.5, 0, 1, 0)
	plrname.Size = UDim2.new(1.25, 0, 0.25, 0)
	plrname.ZIndex = 2
	plrname.Font = Enum.Font.Gotham
	plrname.Text = "Username"
	plrname.TextScaled = true
	plrname.TextTransparency = 0.6
	plrname.TextColor3 = Color3.fromRGB(255, 255, 255)

-- post game
local container = Instance.new("Frame", gui)
	container.Name = "Post"
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.new(1, 0, 1, 0)
	container.Visible = false

local label = Instance.new("TextLabel", container)
	label.Name = "Label"
	label.AnchorPoint = Vector2.new(0.5, 1)
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Position = UDim2.new(0.5, 0, 0.85, 0)
	label.Size = UDim2.new(0.2, 0, 0.04, 0)
	label.Font = Enum.Font.GothamSemibold
	label.Text = "RESULTS"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true


-- template
local boldness = Instance.new("ImageLabel", container)
	boldness.Name = "Boldness"
	boldness.AnchorPoint = Vector2.new(0.5, 1)
	boldness.BackgroundTransparency = 1
	boldness.BorderSizePixel = 0
	boldness.Position = UDim2.new(0.53, 0, 0.96, 0)
	boldness.Size = UDim2.new(0.06, 0, 0.06, 0)
	boldness.SizeConstraint = Enum.SizeConstraint.RelativeXX
	boldness.ZIndex = 2
	boldness.Image = "rbxassetid://6100256142"

local amount = Instance.new("TextLabel", boldness)
	amount.Name = "Amount"
	amount.AnchorPoint = Vector2.new(0.5, 0)
	amount.BackgroundTransparency = 1
	amount.BorderSizePixel = 0
	amount.Position = UDim2.new(0.5, 0, 1, 0)
	amount.Size = UDim2.new(1, 0, 0.2, 0)
	amount.Font = Enum.Font.Gotham
	amount.Text = "+0"
	amount.TextColor3 = Color3.fromRGB(255, 0, 0)
	amount.TextScaled = true

local insideimage = Instance.new("ImageLabel", boldness)
	insideimage.Name = "Inside"
	insideimage.AnchorPoint = Vector2.new(0.5, 0.5)
	insideimage.BackgroundTransparency = 1
	insideimage.BorderSizePixel = 0
	insideimage.Position = UDim2.new(0.5, 0, 0.5, 0)
	insideimage.Size = UDim2.new(0.75, 0, 0.7, 0)
	insideimage.Image = categories["Boldness"][2]

grad:Clone().Parent = boldness
-- end of template

local objective = boldness:Clone()	
	objective.Name = "Objective"
	objective.Position = UDim2.new(0.41, 0, 0.96, 0)
	objective.Inside.Image = categories["Objective"][2]
	objective.Parent = container

local survival = boldness:Clone()
	survival.Name = "Survival"
	survival.Position = UDim2.new(0.47, 0, 0.96, 0)
	survival.Inside.Image = categories["Survival"][2]
	survival.Parent = container

local altruism = boldness:Clone()
	altruism.Name = "Altruism"
	altruism.Position = UDim2.new(0.59, 0, 0.96, 0)
	altruism.Inside.Image = categories["Altruism"][2]
	altruism.Parent = container



local posts = {
	["Boldness"] = boldness;
	["Objective"] = objective;
	["Survival"] = survival;
	["Altruism"] = altruism
}


local function tween(obj, trans)
	
	local goal = {}; goal.ImageTransparency = trans
		ts:Create(obj, info, goal):Play()
		ts:Create(obj.Category, info, goal):Play()

	local goal = {}; goal.TextTransparency = trans
		ts:Create(obj.Action, info, goal):Play()
		ts:Create(obj.BP, info, goal):Play()
	
end


local function makebold(obj)

	local info2 = TweenInfo.new(.5, Enum.EasingStyle.Linear)
	local info3 = TweenInfo.new(2, Enum.EasingStyle.Linear)

	local g = {ImageTransparency = 0}
		ts:Create(obj, info2, g):Play()

	local g = {TextTransparency = 0}
		ts:Create(obj.User, info2, g):Play()

	local g = {BackgroundTransparency = 0}
		ts:Create(obj.Health, info2, g):Play()

	delay(5, function()
		local g = {ImageTransparency = 0.6}
			ts:Create(obj, info3, g):Play()

		local g = {TextTransparency = 0.6}
			ts:Create(obj.User, info3, g):Play()

		local g = {BackgroundTransparency = 0.6}
			ts:Create(obj.Health, info3, g):Play()
	end)

end


local function add(points, cat, action)
	local points = math.clamp(points, 0, 8000)
	points = math.floor(points)

	if points <= 0 then return end

	local cl = award:Clone()
		cl.Category.Image = categories[cat][2]
		cl.Action.Text = action
	
	categories[cat][1] = math.clamp((categories[cat][1] + points), 0, 8000)
	
	if categories[cat][1] >= 8000 then
		posts[cat].Amount.Text = "+8000"
		cl.BP.Text = "MAX"
		cl.Grad.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
		posts[cat].Grad.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
	else
		posts[cat].Amount.Text = "+" .. categories[cat][1]
		cl.BP.Text = "+" .. points
		local num = 1 - (categories[cat][1] / 8000)
		
		local endred = ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
		local red = ColorSequenceKeypoint.new(num, Color3.fromRGB(255, 0, 0))
		local white = ColorSequenceKeypoint.new(num - 0.001, Color3.fromRGB(255, 255, 255))
		local startwhite = ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255))

		cl.Grad.Color = ColorSequence.new({startwhite, white, red, endred})
		posts[cat].Grad.Color = ColorSequence.new({startwhite, white, red, endred})
	end
	
	table.insert(queue, #queue + 1, cl)
	local index = table.find(queue, cl)
	local del

	for i, v in pairs(queue) do
		if i == index then
			cl.Parent = gui 

			tween(cl, 0)
		elseif i == (index - 1) then
			local g = {
				Position = UDim2.new(0.02, 0, 0.58, 0),
				Size = UDim2.new(0.04, 0, 0.04, 0),
				ImageTransparency = 0.5
			}

			ts:Create(v, info, g):Play()

			local g = {ImageTransparency = 0.5}
			ts:Create(v.Category, info, g):Play()

			local g = {TextTransparency = 0.5}
			ts:Create(v.Action, info, g):Play()
			ts:Create(v.BP, info, g):Play()
		elseif i == (index - 2) then
			local g = {Position = UDim2.new(0.02, 0, 0.65, 0)}
			ts:Create(v, info, g):Play()
		elseif i == (index - 3) then
			v:Destroy()
			del = i
		end
	end

	if del then
		table.remove(queue, del)
	end

	delay(3, function()
		local new = table.find(queue, cl)

		if new then
			table.remove(queue, new)
			tween(cl, 1)

			game.Debris:AddItem(cl, .3)
		end
	end)
	
end


local function attemptchase()
	if active.Value == true and beast.Name ~= pl.Name and pl.Character.Parent ~= nil and selfdata.Escaped.Value == false and selfdata.Captured.Value == false and selfdata.Ragdoll.Value == false and selfdata.Health.Value > 0 and ps:FindFirstChild(beast.Name) then
		local exp = CFrame.new(beast.Character.PrimaryPart.CFrame.p, pl.Character.PrimaryPart.CFrame.p)
		local delta = (exp.LookVector - beast.Character.PrimaryPart.CFrame.LookVector).magnitude

		if delta < math.rad(45) and (beast.Character.PrimaryPart.Position - pl.Character.PrimaryPart.Position).magnitude < 40 then
			local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Blacklist
				params.FilterDescendantsInstances = {beast.Character}

			local result = workspace:Raycast(beast.Character.PrimaryPart.Position, pl.Character.PrimaryPart.Position - beast.Character.PrimaryPart.Position, params) 

			if result and result.Instance then
				local chased = ps:GetPlayerFromCharacter(result.Instance.Parent)

				if chased and chased.Name == pl.Name then
					if inchase == false then
						inchase = true
						startchase = tick()
						chasetick = tick()

						if chasemusic.Volume == 0 then
							chasemusic.TimePosition = 0
						end

						intw:Play()
					elseif pl.Character.Humanoid.MoveDirection ~= Vector3.new(0, 0, 0) then
						chasetick = tick()
					end
				elseif tick() - chasetick > endchasetime and inchase == true then
					inchase = false
					outtw:Play()

					local bp = (tick() - startchase) * chasebp
					local bp = math.clamp(bp, 0, 8000)

					if selfdata.Captured.Value == false and selfdata.Ragdoll.Value == false then
						add(escapedchasebp, "Boldness", "ESCAPED CHASE")
					end

					delay(.3, function()
						add(bp, "Boldness", "CHASE")
					end)
				end
			elseif tick() - chasetick > endchasetime and inchase == true then
				inchase = false
				outtw:Play()

				local bp = (tick() - startchase) * chasebp
				local bp = math.clamp(bp, 0, 8000)

				if selfdata.Captured.Value == false and selfdata.Ragdoll.Value == false then
					add(escapedchasebp, "Boldness", "ESCAPED CHASE")
				end

				delay(.3, function()
					add(bp, "Boldness", "CHASE")
				end)
			end
		end
	-- elseif active.Value == true and beast.Name == pl.Name and pl.Character.Parent ~= nil then
		
	elseif (inchase == true and tick() - chasetick > endchasetime) or inchase == true then
		inchase = false
		outtw:Play()

		local bp = (tick() - startchase) * chasebp
		local bp = math.clamp(bp, 0, 8000)

		if selfdata.Captured.Value == false and selfdata.Ragdoll.Value == false then
			add(escapedchasebp, "Boldness", "ESCAPED CHASE")
		end

		delay(.3, function()
			add(bp, "Boldness", "CHASE")
		end)
	end
end


local function makeSurvivors()
	for i, v in pairs(players:GetChildren()) do
		if v:IsA("ImageLabel") then
			v:Destroy()
		end
	end

	gentext.Text = tostring(gens.Value)

	for i, v in pairs(curgui.StatusBars:GetChildren()) do
		if v:IsA("TextLabel") and v.Text ~= "" then
			local player = ps:FindFirstChild(v.Text)

			if player then
				local healthstate = "Healthy"

				local cl = example:Clone()
					cl.Name = player.Name
					cl.User.Text = player.Name

				cl.Parent = players 

				if player.TempPlayerStatsModule.Ragdoll.Value == true then
					healthstate = "Knocked"
					cl.Image = states["Knocked"]
				elseif player.TempPlayerStatsModule.Captured.Value == true then
					healthstate = "Captured"
					cl.Image = states["Captured"]
					cl.Health.Visible = true

					local new = player.TempPlayerStatsModule.Health.Value
					cl.Health.Size = UDim2.new(new / 100, 0, 0.08, 0)
				elseif player.TempPlayerStatsModule.Health.Value <= 0 then
					healthstate = "Dead"
					cl.Image = states["Dead"]
				elseif player.TempPlayerStatsModule.Health.Value == true then
					healthstate = "Escaped"
					cl.Image = states["Escaped"]
				end


				if healthstate ~= "Dead" and healthstate ~= "Escaped" then
					local con1, con2, con3, con4

					con1 = player.TempPlayerStatsModule.Ragdoll.Changed:Connect(function()
						if cl and cl.Parent ~= nil then
							local state = player.TempPlayerStatsModule.Ragdoll

							if state.Value == true then
								healthstate = "Knocked"
								cl.Image = states["Knocked"]
								makebold(cl)
							elseif state.Value == false and healthstate == "Knocked" then
								healthstate = "Healthy"
								cl.Image = states["Healthy"]
								makebold(cl)
							end
						end
					end)

					con2 = player.TempPlayerStatsModule.Captured.Changed:Connect(function()
						if cl and cl.Parent ~= nil then
							local state = player.TempPlayerStatsModule.Captured

							if state.Value == true then
								healthstate = "Captured"
								cl.Image = states["Captured"]
								cl.Health.Visible = true
								makebold(cl)
							elseif healthstate ~= "Dead" then
								healthstate = "Healthy"
								cl.Image = states["Healthy"]
								cl.Health.Visible = false
								makebold(cl)
							end
						end
					end)

					con3 = player.TempPlayerStatsModule.Health.Changed:Connect(function()
						if cl and cl.Parent ~= nil then 
							local new = player.TempPlayerStatsModule.Health.Value
							cl.Health.Size = UDim2.new(new / 100, 0, 0.08, 0)

							if new <= 0 and healthstate ~= "Escaped" then
								con1:Disconnect()
								con2:Disconnect()
								con3:Disconnect()
								con4:Disconnect()

								healthstate = "Dead"
								cl.Image = states["Dead"]
								cl.Health.Visible = false
								makebold(cl)
							end
						end
					end)

					con4 = player.TempPlayerStatsModule.Escaped.Changed:Connect(function()
						if cl and cl.Parent ~= nil and player.TempPlayerStatsModule.Escaped.Value == true and healthstate ~= "Dead" then
							con1:Disconnect()
							con2:Disconnect()
							con3:Disconnect()
							con4:Disconnect()

							healthstate = "Escaped"
							cl.Image = states["Escaped"]
							makebold(cl)
						end
					end)
				end

			end
		end
	end
end


run.Heartbeat:Connect(attemptchase)

if active.Value == false then
	status.Text = "Intermission"
else 
	match.Visible = true

	local sec = string.format("%.2d", tostring(timeleft.Value % 60))
	local min = tostring(math.floor(timeleft.Value % 3600 / 60))

	status.Text = tostring(min .. ":" .. sec)

	makeSurvivors()
end

active.Changed:Connect(function()
	if active.Value == false then
		status.Text = "Intermission"

		for i, v in pairs(categories) do
			categories[i][1] = 0
		end

		match.Visible = false

		delay(15, function()
			container.Visible = true

			delay(30, function()
				container.Visible = false

				for i, v in pairs(categories) do
					posts[i].Grad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
					posts[i].Amount.Text = "+0"
				end
			end)
		end)


	else 
		escaped = false
		chasemusic.SoundId = musics[math.random(1, #musics)]

		makeSurvivors()
		match.Visible = true

		if beast.Name ~= pl.Name then
			beast.Character:WaitForChild("Hammer").Handle.SoundChaseMusic:Destroy()
		end
	end
end)


ps.PlayerAdded:Connect(function(pl)
	local temp = pl:WaitForChild("TempPlayerStatsModule")

	temp.IsBeast.Changed:Connect(function()
		if temp.IsBeast.Value == true then
			beast = pl 
		else 
			beast = nil
		end
	end)
end)


ps.PlayerRemoving:Connect(function(pl)
	if beast and beast.Name == pl.Name then
		if inchase == true then
			inchase = false
			outtw:Play()

			local bp = (tick() - startchase) * chasebp
			local bp = math.clamp(bp, 0, 8000)

			add(bp, "Boldness", "CHASE")
		end

		if escaped == false then
			escaped = true
			add(survivedbp, "Survival", "ESCAPED")
		end
	elseif players:FindFirstChild(pl.Name) then
		players[pl.Name].Image = states["Disconnect"]
		players[pl.Name].Health.Visible = false
		makebold(players[pl.Name])
	end
end)


for i, v in pairs(ps:GetChildren()) do 
	local temp = v:WaitForChild("TempPlayerStatsModule")

	if temp.IsBeast.Value == true then
		beast = v
	end

	temp.IsBeast.Changed:Connect(function()
		if temp.IsBeast.Value == true then
			beast = v 
		else 
			beast = nil
		end
	end)
end


selfdata.Escaped.Changed:Connect(function()
	if selfdata.Escaped.Value == true and selfdata.Captured.Value == false and escaped == false then
		escaped = true
		add(survivedbp, "Survival", "ESCAPED")
	end
end)


selfdata.Ragdoll.Changed:Connect(function()
	delay(.1, function()
		if selfdata.Ragdoll.Value == false and selfdata.Captured.Value == false then
			add(graspescapebp, "Survival", "GRASP ESCAPE")
		elseif selfdata.Ragdoll.Value == true then
			local awarded = false

			for i, v in pairs(ps:GetChildren()) do
				if v.Name ~= pl.Name and v.Name ~= beast.Name and v.Character.Parent and awarded == false then
					local mag = (pl.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude

					if mag < 10 then
						awarded = true
						add(protectionbp, "Altruism", "PROTECTION")
					end
				end
			end
		end
	end)
end)

selfdata.ActionEvent.Changed:Connect(function()
	if selfdata.ActionEvent.Value ~= nil and selfdata.ActionEvent.Value.Parent.Parent.Name == "ComputerTable" and beast.Name ~= pl.Name then
		genprog = 0
		ongen = true
	elseif ongen == true and selfdata.ActionEvent.Value == nil and beast.Name ~= pl.Name and genprog ~= 0 then
		ongen = false
		add(genprog * computerbp, "Objective", "REPAIR")
		genprog = 0
	end
end)

selfdata.ActionProgress.Changed:Connect(function()
	if selfdata.ActionProgress.Value >= 1 and selfdata.ActionEvent.Value ~= nil and selfdata.ActionEvent.Value.Parent.Parent.Name == "ExitDoor" then
		add(opengatebp, "Objective", "OPEN GATE")
	elseif selfdata.ActionEvent.Value ~= nil and selfdata.ActionEvent.Value.Parent.Parent and selfdata.ActionEvent.Value.Parent.Parent.Name == "ComputerTable" then
		genprog = genprog + (selfdata.ActionProgress.Value - orig * 100)
	end 
end)


selfdata.ActionInput.Changed:Connect(function()
	if selfdata.ActionInput.Value == true and selfdata.ActionEvent.Value ~= nil and selfdata.ActionEvent.Value.Parent.Parent.Name == "FreezePod" and beast.Name ~= pl.Name then
		local user = selfdata.ActionEvent.Value.Parent.CapturedTorso

		if user.Value ~= nil then
			user = ps:GetPlayerFromCharacter(user.Value.Parent)

			if user and user.TempPlayerStatsModule.Captured.Value == true and con == nil then

				con = user.TempPlayerStatsModule.Captured.Changed:Connect(function()
					if user.TempPlayerStatsModule.Captured.Value == false then
						con:Disconnect()
						con = nil

						add(rescuebp, "Altruism", "RESCUE")

						delay(10, function()
							if user.TempPlayerStatsModule.Captured.Value == false and user.TempPlayerStatsModule.Ragdoll.Value == false then
								add(saferescuebp, "Altruism", "SAFE RESCUE")
							end
						end)
					end
				end)

				delay(2, function()
					if con then
						con:Disconnect()
						con = nil
					end
				end)

			end
		end
	end
end)


map.Changed:Connect(function()
	status.Text = "Match Starting - " .. tostring(map.Value)
end)


gens.Changed:Connect(function()
	if active.Value ~= true then return end

	gentext.Text = tostring(gens.Value)
	gensound:Play()

	if genimage.ImageTransparency ~= 0.5 then return end

	local info2 = TweenInfo.new(.5, Enum.EasingStyle.Linear)
	local info3 = TweenInfo.new(2, Enum.EasingStyle.Linear)

	local g = {ImageTransparency = 0}
		ts:Create(genimage, info2, g):Play()

	local g = {TextTransparency = 0}
		ts:Create(gentext, info2, g):Play()

	delay(5, function()
		local g = {ImageTransparency = 0.5}
			ts:Create(genimage, info2, g):Play()

		local g = {TextTransparency = 0.5}
			ts:Create(gentext, info2, g):Play()
	end)
end)


timeleft.Changed:Connect(function()
	if active.Value == true then
		local sec = string.format("%.2d", tostring(timeleft.Value % 60))
		local min = tostring(math.floor(timeleft.Value % 3600 / 60))

		status.Text = tostring(min .. ":" .. sec)
	end
end)


version.Text = "DBD in FTF v22"
version.TextColor3 = Color3.fromRGB(200, 200, 200)