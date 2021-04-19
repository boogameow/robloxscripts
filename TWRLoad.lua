syn.queue_on_teleport(readfile("twrauto.lua"))
rconsolename("TWR Hopper")

local minwave = 10

local tp = game:GetService("TeleportService")
local rep = game:GetService("ReplicatedStorage")
local wave = rep:WaitForChild("Game Stuff"):WaitForChild("Wave")
local http = game:GetService("HttpService")

local servers = tp:GetTeleportSetting("servers")

local function url(cursor)
    return string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100&cursor=%s", game.PlaceId, cursor)
end

local function check()
    if not servers or #servers == 0 then
        servers = {}
        local cursor = ""

        while true do
            local t = http:JSONDecode(game:HttpGet(url(cursor)))

            for i, v in ipairs(t.data) do
                table.insert(servers, v.id)
           	end

            if not t["nextPageCursor"] or t["nextPageCursor"] == cursor then
                break
            end

            cursor = t["nextPageCursor"]
        end
    end
end

local function dotp()
	check()

	local nextserver = servers[#servers]
    table.remove(servers, #servers)

	tp:SetTeleportSetting("servers", servers)
    tp:TeleportToPlaceInstance(game.PlaceId, nextserver)
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if wave.Value < minwave then
	rconsoleprint("\nWAVE: " .. tostring(wave.Value) .. " | NOT ELGIBILE")

	tp.TeleportInitFailed:Connect(dotp)
	dotp()
else 
	rconsoleprint("\nWAVE: " .. tostring(wave.Value) .. " | ELGIBILE")
end