if not syn then
	error("You need Synapse X to use spectate player.")
	return
end

local cam = workspace.CurrentCamera
local ps = game:GetService("Players")
local coregui = game:GetService("CoreGui")
	local screen = coregui:WaitForChild("RobloxGui")
	local frame = screen:WaitForChild("PlayerListMaster"):WaitForChild("OffsetFrame"):WaitForChild("PlayerScrollList"):WaitForChild("SizeOffsetFrame"):WaitForChild("ScrollingFrameContainer")
	local con

local function make()
	if con then
		con:Disconnect()
		con = nil
	end

	local innerframe = frame:WaitForChild("PlayerDropDown"):WaitForChild("InnerFrame")
	local curbutton = innerframe:WaitForChild("InspectButton")
	local button = curbutton:Clone()
	local label = button.HoverBackground:FindFirstChild("Text")

	if ps:GetPlayerFromCharacter(cam.CameraSubject.Parent) == ps.LocalPlayer then
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
	else 
		label.TextColor3 = Color3.fromRGB(0, 255, 0)
	end

	syn.protect_gui(button)
	curbutton:Destroy()
	label.Text = "Spectate Player"
	button.Parent = innerframe

	button.MouseEnter:Connect(function()
	    button.HoverBackground.BackgroundTransparency = 0.9
	end)

	button.MouseLeave:Connect(function()
	    button.HoverBackground.BackgroundTransparency = 1
	end)

	button.MouseButton1Click:Connect(function()
	    local name = innerframe.PlayerHeader.Background:FindFirstChild("Text").Text
	    local specplayer = ps:FindFirstChild(name)

	    if not specplayer then
	    	return
	    end

	    if (ps:GetPlayerFromCharacter(cam.CameraSubject.Parent) == specplayer or specplayer == ps.LocalPlayer) and ps.LocalPlayer.Character and ps.LocalPlayer.Character:FindFirstChild("Humanoid") then
	    	cam.CameraSubject = ps.LocalPlayer.Character.Humanoid
	    elseif specplayer ~= ps.LocalPlayer and specplayer.Character and specplayer.Character:FindFirstChild("Humanoid") then 
	    	cam.CameraSubject = specplayer.Character.Humanoid
	    end
	end)

	con = cam:GetPropertyChangedSignal("CameraSubject"):Connect(function()
		if ps:GetPlayerFromCharacter(cam.CameraSubject.Parent) == ps.LocalPlayer then
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
		else 
			label.TextColor3 = Color3.fromRGB(0, 255, 0)
		end
	end)
end

frame.ChildRemoved:Connect(function(ch)
	if ch.Name == "PlayerDropDown" then
		make()
	end
end)

make()