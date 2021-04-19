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
local count = tp:GetTeleportSetting("tpcount")

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

    if not count then
        count = 0
    else
        count += 1
    end
end

local function dotp()
	check()

	local nextserver = servers[#servers]
    table.remove(servers, #servers)

	tp:SetTeleportSetting("servers", servers)
    tp:SetTeleportSetting("tpcount", count)
    tp:TeleportToPlaceInstance(game.PlaceId, nextserver)
end

tp.TeleportInitFailed:Connect(dotp)

if wave.Value < minwave or wave.Value == 15 then
    rconsoleprint("\nWAVE: " .. tostring(wave.Value) .. " | MAP: " .. map.Value .. " | SERVER: " .. game.JobId .. " | NOT ELIGIBILE | COUNT: " .. count)
    delay(5, dotp)
else 
    rconsoleprint("\nWAVE: " .. tostring(wave.Value) .. " | MAP: " .. map.Value .. " | SERVER: " .. game.JobId .. " | ELIGIBILE")

    delay(10, function()
        rconsoleprint("\nPress any key to continue..")
        rconsoleinput()

        servers = nil
        count = nil
        rconsoleclear()
        dotp()
    end)
end