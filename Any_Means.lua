if not game:IsLoaded() then
    game.Loaded:Wait()
end

local rep = game:GetService("ReplicatedStorage")
local update = rep:WaitForChild("RemoteEvents"):WaitForChild("PropertieUpdater")
local cas = game:GetService("ContextActionService")
local pl = game:GetService("Players").LocalPlayer

if cas:GetBoundActionInfo("AMN").inputTypes then
	warn("Any Means is already running!")
	return
end

local pallets = {}

for i, v in pairs(workspace:GetChildren()) do
	if string.find(v.Name, "Pallet") then
		table.insert(pallets, #pallets + 1, v)
	end
end

local function action(n, st)
	if st == Enum.UserInputState.Begin and pl.Character then
		local pos = pl.Character.HumanoidRootPart.Position

		for i, v in pairs(pallets) do
			local state = v.Panel.State

			if state.Value ~= 0 then
				local mag = (pos - v.Body.Position).magnitude

				if mag <= 10 then
					update:FireServer(state, 0)
				end
			end
		end
	end
end

cas:BindAction("AMN", action, false, Enum.KeyCode.F)
print("Loaded AMN.")
