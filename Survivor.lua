-- use [unbreakable, no mither, self care, dstrike] to optimally use this script.

local nick = "" -- custom name

-- vars
local hdb, hdbb, gui
local cgui = game:GetService("CoreGui")
local ps = game:GetService("Players")
    local p = ps.LocalPlayer
        local pn = p.Name
        local c = p.Character or p.CharacterAdded:Wait()

        local g = p.PlayerGui
            local ch = g.AmbientSounds.Chase1
        local ds = p.DataStorage
            local nn = ds.Stats.NickName;
            local perks = ds.LoadOut.Perks.Survivor

        local b = p.Backpack
            local bs = b.Scripts
                local main = bs.MovementSpeedScript.MainScript
                local lan = bs.MovementSpeedScript.Land
                local exh = bs.Status.Exhausted
                local bro = bs.Status.Broken
                local h = bs.GlobalSurvivor.Hook

                local pb = bs.PerksBase
                    local dsu = pb.DecisiveStrike.Used
                    local sbp = pb.SprintBurst.Playing
                    local bta = pb.BorrowedTime.Active
                    local btp = pb.BorrowedTime.Playing

                local val = bs.values
                    local bl = val.Blood
                    local hd = val.Hooked
                        local hc = hd.Count
                    local hs = val.HealthState
                    local bc = val.BeingChased

local blacklist = {"Player(V)", "Count", "PlayersScaped", pn, ""}

local perklist = {
    Unbreakable = "DeadHard",
    NoMither = "HeadOn"
}

local ids = {"rbxassetid://4743442159", "rbxassetid://4743720538", "rbxassetid://4627984150", "rbxassetid://1410762446"}
local gens = workspace.MatchValues.GeneratorsRepaired
local inps = game:GetService("UserInputService")
local r = game:GetService("ReplicatedStorage")
    local rems = r.RemoteEvents
    local kstuff = r.KillerStuff
    local upd = rems.PropertieUpdater
    local mat = r.Match

-- funcs
local function sp()
    if sbp.Value == true then return end

    upd:FireServer(sbp, true)

    delay(3, function() 
        upd:FireServer(sbp, false) 
    end)
end

local function noCD() 
	dsu.Value = false 
	exh.Value = false 
end

local function balancedlanding()
    if lan.Value == false then return end

    main.Disabled = true
    lan.Value = false
    main.Disabled = false

    sp()
end

local function customchase()
    if bc.Value == true then return end

    local cach = ch.SoundId
    
    table.remove(ids, table.find(ids, cach), cach)
    ch.SoundId = ids[math.random(1, #ids)]
    table.insert(ids, cach)
end

local function adrenaline()
    if gens.Value ~= 5 then return end

    if hs.Value ~= 2 then 
        upd:FireServer(hs, hs.Value + 1) 
    end

    upd:FireServer(btp, false)
    sp()
end

gens.Changed:Connect(adrenaline)
bc.Changed:Connect(customchase)
lan.Changed:Connect(balancedlanding)
dsu.Changed:Connect(noCD)
exh.Changed:Connect(noCD)

bro.Value = false
loadstring(game:HttpGet(('https://pastebin.com/raw/z7QBADVb'),true))() -- esp

if nick ~= "" then 
    upd:FireServer(nn, nick) 
end

for i, q in pairs(perks:GetChildren()) do 
    if perklist[q.Value] then 
        q.Value = perklist[q.Value] 
    end 
end

-- gui stuff
local gui = Instance.new("ScreenGui")
    gui.Name = "Ultimate"
    gui.ResetOnSpawn = false
local first = Instance.new("TextLabel", gui)
    first.Name = "Main"
    first.BackgroundTransparency = 1
    first.BorderSizePixel = 0
    first.TextXAlignment = Enum.TextXAlignment.Left
    first.Font = Enum.Font.SourceSansSemibold
    first.TextSize = 25
    first.Text = "Ultimate Survivor"
    first.TextColor3 = Color3.fromRGB(235, 238, 9)
    first.Position = UDim2.new(0, 0, 0.35, 0)
    first.Size = UDim2.new(0.15, 0, 0.05, 0)

local prev = first.Position

-- keycodes
local codes = {
    [Enum.KeyCode.M] = {function()
        gui.Enabled = not gui.Enabled
    end, "Toggle Gui."};
    [Enum.KeyCode.H] = {function()
        local k = mat.Players["Player(V)"]
        local kpl = ps:FindFirstChild(k.Value)

        if not kpl then
            return
        else 
            upd:FireServer(kpl.Backpack.Scripts.values.Stunned, true)
        end
    end, "Stun the killer."};
    [Enum.KeyCode.V] = {function()
        if gens.Value < 5 then 
            upd:FireServer(gens, gens.Value + 1) 
        end
    end, "Pop one gen."};
    [Enum.KeyCode.Z] = {function()
        if btp.Value == true and hs.Value == 1 then 
            upd:FireServer(btp, false) 
            upd:FireServer(bta, false) 
        else 
            upd:FireServer(bta, true)
        end
    end, "Activate styptic."};
    [Enum.KeyCode.G] = {function() 
        if hs.Value ~= 2 then
            upd:FireServer(bta, false)
            upd:FireServer(btp, false) 
            upd:FireServer(hs, hs.Value + 1)
        end
    end, "Heal a state."};
    [Enum.KeyCode.J] = {function()
        if hd.Value == true then 
            upd:FireServer(hd, false)
            upd:FireServer(hc, 0)
            upd:FireServer(bl, 100) 
            upd:FireServer(hs, 1)
            upd:FireServer(h.Value.Panel.Player, "Nobody")
            upd:FireServer(h.Value.Panel.Ocuped, false)
        end
    end, "Unhook yourself."};
    [Enum.KeyCode.K] = {function()
        if hdb then return end

        hdb = true 

        if gens.Value < 2 then 
            upd:FireServer(gens, 2) 
        end 

        local thingy = {}

        for i, q in pairs(mat.Players:GetChildren()) do 
            if not table.find(blacklist, q.Value) and not table.find(blacklist, q.Name) then 
                upd:FireServer(q.Connected, false)
                table.insert(thingy, #thingy + 1, q) 
            end 
        end

        delay(1.25, function()
            c.HumanoidRootPart.CFrame = workspace.Hatch.HumanoidRootPart.CFrame
        end)
    end, "Open hatch."};
    [Enum.KeyCode.X] = {function()
        if hdbb then return end

        hdbb = true

        for i, v in pairs(workspace:GetChildren()) do 
            if string.match(v.Name, "Hook") and v:FindFirstChild("Panel") then 
                upd:FireServer(v.Panel.Used, true) 
            end 
        end
    end, "Break all hooks."};
    [Enum.KeyCode.B] = {function()
        for i, v in pairs(workspace:GetChildren()) do 
            if string.match(v.Name, "Pallet") then 
                upd:FireServer(v.Panel.State, 0) 
            end 
        end
    end, "Reset all pallets."};
    [Enum.KeyCode.Y] = {function()
        local ismyers = c:FindFirstChild("Shape")

        if not ismyers then
            kstuff.Shape:Clone().Parent = c 
        else 
            ismyers:Destroy()
        end
    end, "Toggle myers."};
}

-- create guis
for i, v in pairs(codes) do
    local letter = string.split(tostring(i), ".")[3]

    local text = first:Clone()
        text.Name = letter
        text.Font = Enum.Font.SourceSans
        text.TextSize = 20
        text.Text = letter .. " - " .. v[2]
        text.Position = UDim2.new(0, 0, prev.Y.Scale + 0.02, 0)
        text.Parent = gui
    prev = text.Position
end

syn.protect_gui(gui)
gui.Parent = cgui

-- handle input
inps.InputBegan:Connect(function(inp, proc)
    if proc or not codes[inp.KeyCode] then return end
    codes[inp.KeyCode][1]()
end)