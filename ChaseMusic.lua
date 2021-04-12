local pl = game:GetService("Players").LocalPlayer
	local chase = pl.PlayerGui.AmbientSounds.Chase1
	local inchase = pl.Backpack.Scripts.values.BeingChased

local prefix = "rbxassetid://"
local ids = {4743442159, 4743720538, 4627984150, 1410762446, 6172092571}

inchase.Changed:Connect(function()
    if inchase.Value == false then
        local prev = chase.SoundId

        table.remove(ids, table.find(ids, prev), prev)
        chase.SoundId = prefix .. tostring(ids[math.random(1, #ids)])
        table.insert(ids, prev)
    end
end)