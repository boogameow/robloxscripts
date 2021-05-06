syn.queue_on_teleport(readfile("twrbot.lua"))
rconsolename("TWR Hopper Bot")

repeat wait() until game:GetService("Players").LocalPlayer

local minwave = 10
local delaytime = 7.5
local webhook = "https://discord.com/api/webhooks/834168204367757412/2V3pXClK_j0QXNtGKKQ2i9MTtksBcG26EZ6OyJgY6_mL69jn-fC-AMVHgSX2m8o5NBqZ"

local tp = game:GetService("TeleportService")
local http = game:GetService("HttpService")

local ps = game:GetService("Players")
    local pl = ps.LocalPlayer
        local gui = pl:WaitForChild("PlayerGui")
        local maingui = gui:WaitForChild("Main")
        local list = maingui:WaitForChild("Player List")

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
        syn.request({
            Url = webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = http:JSONEncode({content = "```Acquiring new servers...```"})
        })

        servers = {}
        local cursor = ""

        rconsoleprint("\nGetting servers..")

        while true do
            local t = http:JSONDecode(game:HttpGet(url(cursor)))

            for i, v in ipairs(t.data) do
                if v.id ~= game.JobId then
                    table.insert(servers, v.id)
                end
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

tp.TeleportInitFailed:Connect(dotp)
rconsoleprint("\nSERVER: " .. game.JobId .. " | WAVE: " .. tostring(wave.Value) .. " | MAP: " .. map.Value)

delay(delaytime, function()
    if wave.Value >= minwave and wave.Value ~= 15 then
        local amount = 0
        local plstring = ""

        for i, v in pairs(list:GetChildren()) do
            if v:IsA("Frame") then
                local level = v:FindFirstChild("Level")
                local name = v:FindFirstChild("PlayerName")

                if name and name.Text ~= pl.Name and level then
                    plstring = plstring .. "- " .. name.Text .. " : " .. level.Text .. "\n"
                    amount += 1
                end
            end
        end

        local send = "```Map: " .. tostring(map.Value) .. "\nWave: " .. tostring(wave.Value) .. "\nID: " .. tostring(game.JobId) .. "\n\nPlayers: " .. tostring(amount) .. "\n" .. plstring .. "```"

        syn.request({
            Url = webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = http:JSONEncode({content = send})
        })

        rconsoleprint("\nSent webhook!")
    end

    dotp()
end)