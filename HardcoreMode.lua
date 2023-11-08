local function formatTime(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local seconds = seconds % 60
    return string.format("%d days, %d hours, %02d min, %02d sec", days, hours, minutes, seconds)
end

local function PlayerDeath(event, killer, player)
    if player:HasItem(666, 1) then
        local playerGUID = player:GetGUIDLow()
        local playerName = player:GetName()
        local playerLevel = player:GetLevel()
        local playerRace = player:GetRace()
        local playerClass = player:GetClass()
        local currLevelPlayTime = player:GetLevelPlayedTime()
        local formattedTimeLvl = formatTime(currLevelPlayTime)

        local guild = player:GetGuild()
        if guild and guild:GetName() == "HardCore" then
            guild:DeleteMember(player, false)
            SendWorldMessage("|cFFffffffHardcore|r : |cFF007bf6" .. playerName .. " was removed from the Hardcore Guild!|r")
        end

        local players = GetPlayersInWorld()
        local killerName = killer and killer:GetName() or "Unknown"

        local survivalTime = currLevelPlayTime  -- Tiempo de supervivencia del jugador

        for _, p in ipairs(players) do
            p:SendBroadcastMessage("|cFFffffffHardcore|r : |cFFffffffUser |cFF00ff00" .. playerName .. "|r |cFFffffffwas killed by |cFF00ff00" .. killerName .. "|r  - |cFFffffffLevel " .. playerLevel .. " after surviving " .. formattedTimeLvl)
            p:SendAreaTriggerMessage("|cFFffffffHardcore|r : |cFFffffffUser |cFF00ff00" .. playerName .. "|r |cFFffffffwas killed by |cFF00ff00" .. killerName .. "|r  - |cFFffffffLevel " .. playerLevel .. " after surviving : " .. formattedTimeLvl)
        end

        local input_HC_Dead = "INSERT INTO hc_dead_log (username, level, killer, date, result, guid, survival_time) VALUES ('" .. player:GetName() .. "', '" .. player:GetLevel() .. "', '" .. killerName .. "',  NOW(), 'DEAD', '" ..playerGUID.."', '" .. survivalTime .. "')"
        AuthDBExecute(input_HC_Dead)

        player:RemoveItem(666, 1)

        -- Discord embed
                 local embed = '{"username": "Hardcore System", "avatar_url": "https://skywall.org/hclogo.png", "content": ":skull: Player **'.. playerName ..'** was killed by **' ..killerName.. '** at Level **'.. playerLevel ..' after surviving ' ..formattedTimeLvl.. ' ** ...better luck next time! Rip! :skull_crossbones:"}'
                 -- POST request to Discord Webhook
                 HttpRequest("POST", "YOUR HOOK ID",
                     embed, "application/json", function(status, body, headers)
                     print(body)
                 end)
    end
end


RegisterPlayerEvent(6, PlayerDeath)

local function OnFirstTalk(event, player, unit)
    if player:GetLevel() == 1 then
        if player:HasItem(666) then
            player:GossipMenuAddItem(0, "Thanks!", 0, 3)
            player:GossipSendMenu(6668, unit)
        else
            player:GossipMenuAddItem(0, "I am ready to try Hardcore Mode!", 0, 1)
            player:GossipSendMenu(6666, unit)
        end
    else
        player:SendBroadcastMessage("|cFFffffffHardcore|r : Your current level is too high to participate in HC mode. In order to experience the thrill of HC, it is necessary to create a new hero.")
            local function formatTime(seconds)
                local days = math.floor(seconds / 86400)
                local hours = math.floor((seconds % 86400) / 3600)
                local minutes = math.floor((seconds % 3600) / 60)
                local seconds = seconds % 60
                return string.format("%01d days, %01d hours,%02d min.%02d sec.", days, hours, minutes, seconds)
            end
            local currLevelPlayTime = player:GetLevelPlayedTime()
            local totalPlayTime = player:GetTotalPlayedTime()

            local formattedTimeLvl = formatTime(currLevelPlayTime)
            local formattedTimeTotal = formatTime(totalPlayTime)
                SendWorldMessage("Total time played: " .. formattedTimeTotal)
                SendWorldMessage("Total played this level: " .. formattedTimeLvl)
    end
end

local function OnSelect(event, player, unit, sender, intid, code)
    if intid == 1 then
        player:GossipMenuAddItem(0, "Yes, these are my last words!", 0, 2)
        player:GossipMenuAddItem(0, "No, take me back!", 0, 3)
        player:GossipSendMenu(6667, unit)
    end
    if intid == 3 then
        player:GossipComplete()

    end
end

local function OnHardCore(event, player, unit, sender, intid, code)
    if intid == 2 then
        player:AddItem(666, 1)
        player:SetCoinage(0)
        player:SendAreaTriggerMessage("|cFFffffffWelcome to Hardcore Mode,|cFF00ff00" .. player:GetName() .. ".|r |cFFffffffStay vigilant and tread carefully!|r")
        SendWorldMessage("|cFFffffffHardcore|r : |cFF00ff00".. player:GetName() .. "|r has entered Hardcore Mode! Best of luck on your journey!")

        local playerGUID = player:GetGUIDLow()

        -- Insert a record into the hc_dead_log table to mark the player's start
        local input_HC_Start = "INSERT INTO hc_dead_log (username, level, killer, date, result, guid) VALUES ('" .. player:GetName() .. "', '" .. player:GetLevel() .. "', 'STARTED', NOW(), 'BEGIN', '" ..playerGUID.."')"
        AuthDBExecute(input_HC_Start)
        
                -- Discord embed
                local embed = '{"username": "Hardcore System", "avatar_url": "https://skywall.org/hclogo.png", "content": ":tada: Player **'.. playerName ..'** started his HardCore Mode! Good luck! :saluting_face:"}'
                -- POST request to Discord Webhook
                HttpRequest("POST", "YOUR HOOK ID",
                    embed, "application/json", function(status, body, headers)
                    print(body)
                end)

        -- Add the player to the "HardCore" guild using Guild:AddMember()
        local guild = GetGuildByName("HardCore") 
        if guild then
            guild:AddMember(player, 3) -- Replace 3 with the desired rank ID
        end

        player:GossipComplete()
    end  
end


RegisterCreatureGossipEvent(666, 1, OnFirstTalk)
RegisterCreatureGossipEvent(666, 2, OnSelect)
RegisterCreatureGossipEvent(666, 2, OnHardCore)
RegisterPlayerEvent(8, PlayerDeath)
