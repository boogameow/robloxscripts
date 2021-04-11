local cas = game:GetService("ContextActionService")
local run = game:GetService("RunService")
local cam = workspace.CurrentCamera
local folder, trinketlist

if not syn then
    warn("Trinket ESP requires Synapse.")
    return
end

if game.PlaceId == 5529195348 then -- rogue spells
    trinketlist = {"Old Fragment", "Ring", "Amulet", "Sapphire"}
    folder = workspace:WaitForChild("Items")
else 
    warn("This game is not on the whitelist!")
    return
end

local trinkets = {}
local range = 500
local active = true

local function toggle(n, st)
    if st == Enum.UserInputState.Begin then
        active = not active 

        for i, v in pairs(trinkets) do 
            v.Drawing.Visible = active
        end
    end
end

local function destroy(part)
    local pos

    if part:IsA("Model") then
        pos = part:FindFirstChildOfClass("Part").Position
    else 
        pos = part.Position
    end

    for i, v in pairs(trinkets) do
        if pos == v.Part.Position and part.Name == v.Part.Name then
            v.Drawing:Remove()
            trinkets[i] = nil
            return
        end
    end
end

local function create(part)
    if string.find(part.Name, "Spawn") then
        return
    end

    local artifact = false

    local label = Drawing.new("Text")
        label.Visible = active
        label.Size = 20
        label.Font = 3
        label.Text = part.Name
        label.Position = Vector2.new(0, 0)
        label.Transparency = 0
    
    if table.find(trinketlist, part.Name) then
        label.Color = Color3.fromRGB(0, 255, 255)
    else 
        label.Color = Color3.fromRGB(255, 0, 0)
        artifact = true
    end

    if part:IsA("Model") then 
        part = part:FindFirstChildOfClass("Part")
    end

    table.insert(trinkets, #trinkets + 1, {Part = part, Drawing = label, Unique = artifact})
end

run.RenderStepped:Connect(function()
    if active == true then 
        for i, v in pairs(trinkets) do
            local pos, onscreen = cam:WorldToViewportPoint(v.Part.Position)

            if onscreen then
                local mag = (cam.CFrame.Position - v.Part.Position).magnitude

                if v.Unique == true then
                    v.Drawing.Position = Vector2.new(pos.X, pos.Y)
                    v.Drawing.Text = v.Part.Name .. " (" .. tostring(math.floor(mag + 0.5)) .. ")"
                    v.Drawing.Transparency = 1
                else
                    if mag < range then
                        v.Drawing.Position = Vector2.new(pos.X, pos.Y)
                        v.Drawing.Text = v.Part.Name .. " (" .. tostring(math.floor(mag + 0.5)) .. ")"
                        v.Drawing.Transparency = 1
                    else 
                        v.Drawing.Transparency = 0
                    end
                end
            else
                v.Drawing.Transparency = 0
            end
        end
    end
end)

for i, v in pairs(folder:GetChildren()) do
    create(v)
end

folder.ChildAdded:Connect(create)
folder.ChildRemoved:Connect(destroy)
cas:BindAction("Caption", toggle, false, Enum.KeyCode.F1)

print("Trinket ESP has been initialized.")