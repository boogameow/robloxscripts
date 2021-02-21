local rep = game:GetService("ReplicatedStorage")
	local update = rep.RemoteEvents.PropertieUpdater

local serv = game:GetService("UserInputService")

local ps = game:GetService("Players")
	local pl = ps.LocalPlayer
	local char = pl.Character or pl.CharacterAdded:Wait()

local pallets = {}

if not workspace:FindFirstChild("Pallet1") then
	warn("Not Loaded. Execute this later.")
else 
	for i, v in pairs(workspace:GetChildren()) do
		if string.find(v.Name, "Pallet") then
			table.insert(pallets, #pallets + 1, v)
		end
	end

	serv.InputBegan:Connect(function(inp, proc)
		if proc then return elseif inp.KeyCode == Enum.KeyCode.F then
			for i, v in pairs(pallets) do
				local state = v.Panel.State

				if state.Value ~= 0 then
					local mag = (char.HumanoidRootPart.Position - v.Body.Position).magnitude

					if mag <= 10 then
						update:FireServer(state, 0)
					end
				end
			end
		end
	end)

	print("Loaded AMN.")
end