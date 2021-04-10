local cas = game:GetService("ContextActionService")
local run = game:GetService("RunService")
local cam = workspace.CurrentCamera
local folder, blacklist

if game.PlaceId == 5529195348 then -- rogue spells
    blacklist = {"Old Fragment", "Ring", "Amulet", "Sapphire"}
    folder = workspace:WaitForChild("Items")
else 
    warn("This game is not on the whitelist!")
    return
end

local trinkets = {}
local range = 500
local active = false

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
        local part2 = v.Part

        if part2:IsA("Model") then
            part2 = part2:FindFirstChildOfClass("Part")
        end

        if pos == part2.Position and part.Name == v.Part.Name then
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
    
    if table.find(blacklist, part.Name) then
        label.Color = Color3.fromRGB(0, 255, 255)
    else 
        label.Color = Color3.fromRGB(255, 0, 0)
        artifact = true
    end

    table.insert(trinkets, #trinkets + 1, {Part = part, Drawing = label, Artifact = artifact})
end

run.RenderStepped:Connect(function()
    if active == true then 
        for i, v in pairs(trinkets) do
            local part

            if v.Part:IsA("Model") then 
                part = v.Part:FindFirstChildOfClass("Part")
            else 
                part = v.Part
            end

            local pos, onscreen = cam:WorldToViewportPoint(part.Position)

            if onscreen then
                local mag = (cam.CFrame.Position - part.Position).magnitude

                if v.Artifact == true then
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