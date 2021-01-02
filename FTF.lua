local run = game:GetService("RunService")
local ps = game:GetService("Players")
	local pl = ps.LocalPlayer
	local selfdata = pl:WaitForChild("TempPlayerStatsModule")

local ts = game:GetService("TweenService")
	local info = TweenInfo.new(.2, Enum.EasingStyle.Linear)

local rep = game:GetService("ReplicatedStorage")
	local beast
	local active = rep.IsGameActive


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

local bloodpoints = {
	["Survival"] = 0;
	["Objective"] = 0;
	["Boldness"] = 0;
	["Altruism"] = 0
}

local ids = {
	["Survival"] = "rbxassetid://6100699830";
	["Objective"] = "rbxassetid://6100699948";
	["Boldness"] = "rbxassetid://6100700044";
	["Altruism"] = "rbxassetid://6175736811"
}


local gui = Instance.new("ScreenGui", pl.PlayerGui)
	gui.Name = "DBD"
	gui.ResetOnSpawn = false

local version = Instance.new("TextLabel", gui)
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
	chasemusic.Volume = 0
	chasemusic.Looped = true
	chasemusic.Playing = true
	chasemusic.SoundId = musics[math.random(1, #musics)]

local g1 = {Volume = .8}
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
	insideimage.Image = ids["Boldness"]

grad:Clone().Parent = boldness
-- end of template

local objective = boldness:Clone()	
	objective.Name = "Objective"
	objective.Position = UDim2.new(0.41, 0, 0.96, 0)
	objective.Inside.Image = ids["Objective"]
	objective.Parent = container

local survival = boldness:Clone()
	survival.Name = "Survival"
	survival.Position = UDim2.new(0.47, 0, 0.96, 0)
	survival.Inside.Image = ids["Survival"]
	survival.Parent = container

local altruism = boldness:Clone()
	altruism.Name = "Altruism"
	altruism.Position = UDim2.new(0.59, 0, 0.96, 0)
	altruism.Inside.Image = ids["Altruism"]
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


local function add(points, cat, action)
	local points = math.clamp(points, 0, 8000)
	points = math.floor(points)

	if points <= 0 then return end

	local cl = award:Clone()
		cl.Category.Image = ids[cat]
		cl.Action.Text = action
	
	bloodpoints[cat] = math.clamp((bloodpoints[cat] + points), 0, 8000)
	
	if bloodpoints[cat] >= 8000 then
		posts[cat].Amount.Text = "+8000"
		cl.BP.Text = "MAX"
		cl.Grad.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
		posts[cat].Grad.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
	else
		posts[cat].Amount.Text = "+" .. bloodpoints[cat]
		cl.BP.Text = "+" .. points
		local num = 1 - (bloodpoints[cat] / 8000)
		
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

run.Heartbeat:Connect(function()
	local params

	if inchase == true and beast and beast.Name ~= pl.Name and ps:FindFirstChild(beast.Name) and beast.Character.Parent then
		params = RaycastParams.new()
			params.FilterDescendantsInstances = {pl.Character}
			params.FilterType = Enum.RaycastFilterType.Whitelist

		local cast = workspace:Raycast(beast.Character.HumanoidRootPart.Position, beast.Character.HumanoidRootPart.CFrame.LookVector * 35, params)

		if cast and pl.Character.Humanoid.MoveDirection ~= Vector3.new(0, 0, 0)  then
			chasetick = tick()
		else 
			if tick() - chasetick > endchasetime or selfdata.Captured.Value == true or selfdata.Ragdoll.Value == true or selfdata.Escaped.Value == true or selfdata.Health.Value <= 0 then
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
	elseif selfdata.Captured.Value == false and selfdata.Ragdoll.Value == false and selfdata.Escaped.Value == false and selfdata.Health.Value ~= 0 and beast and ps:FindFirstChild(beast.Name) and beast.Name ~= pl.Name and beast.Character.Parent and active.Value == true then
		params = RaycastParams.new()
			params.FilterDescendantsInstances = {beast.Character}
			params.FilterType = Enum.RaycastFilterType.Blacklist

		local cast = workspace:Raycast(beast.Character.HumanoidRootPart.Position, beast.Character.HumanoidRootPart.CFrame.LookVector * 45, params)

		if cast and cast.Instance.Parent.Name == pl.Name and pl.Character.Humanoid.MoveDirection ~= Vector3.new(0, 0, 0) then
			startchase = tick()
			chasetick = tick()
			inchase = true

			if chasemusic.Volume == 0 then
				chasemusic.TimePosition = 0
			end
			
			intw:Play()
		end
	end
end)


active.Changed:Connect(function()
	if active.Value == false then
		for i, v in pairs(bloodpoints) do
			bloodpoints[i] = 0
		end

		container.Visible = true

		delay(45, function()
			container.Visible = false

			for i, v in pairs(bloodpoints) do
				posts[i].Grad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
				posts[i].Amount.Text = "+0"
			end
		end)
	else 
		escaped = false
		chasemusic.SoundId = musics[math.random(1, #musics)]

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


version.Text = "DBD in FTF v19"
version.TextColor3 = Color3.fromRGB(200, 200, 200)