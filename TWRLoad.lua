syn.queue_on_teleport(readfile("twrauto.lua"))
rconsolename("TWR Hopper")

local minwave = 10

local tp = game:GetService("TeleportService")
local http = game:GetService("HttpService")
local rep = game:GetService("ReplicatedStorage")

local stuff = rep:WaitForChild("Game Stuff")
    local map = stuff:WaitForChild("MapName")
    local wave = stuff:WaitForChild("Wave")

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

delay(5, function()
    if wave.Value < minwave or wave.Value == 15 then
        rconsoleprint("\nWAVE: " .. tostring(wave.Value) .. " | NOT ELGIBILE")

        tp.TeleportInitFailed:Connect(dotp)
        dotp()
    else 
        rconsoleprint("\nWAVE: " .. tostring(wave.Value) .. " | MAP: " .. map.Value .. " | ELGIBILE")
    end
end)