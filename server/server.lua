-- Utility function to send a debug message to Discord
function sendDiscordDebugLog(title, description)
    local webhookUrl = 'https://discord.com/api/webhooks/1225496675364245535/Tux7AsTS9BKM-c4WOCfDEL5B59VTHfT_zPcMbdn1uCJuChIXeDEA2M7OP5l7xnzB6cWq'
    local data = {
        ["username"] = "HW Logs",
        ["embeds"] = {{
            ["title"] = title,
            ["description"] = description,
            ["type"] = "rich",
            ["color"] = 16776960,
            ["footer"] = {
                ["text"] = "HW Scripts | Advanced Mining"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    PerformHttpRequest(webhookUrl, function(err, text, headers) end, 'POST', json.encode(data), {["Content-Type"] = "application/json"})
end

local function checkPlayerDistance(mines, coords)
    local ped = GetPlayerPed(source)
    local playerPos = (GetEntityCoords(ped))
    if not mines then
        local distance = #(playerPos - coords)
        if Config.Debug then
            print('^0[^1DEBUG^0] ^5Checking distance for single location.')
        end
        if distance < 10.0 then
            return true
        end
        return false
    else
        if Config.Debug then
            print('^0[^1DEBUG^0] ^5Checking distance for multiple locations.')
        end
        for _, location in pairs(coords) do
            local distance = #(playerPos - location)
            if distance < 10.0 then
                return true
            end
        end
        return false
    end
end

-- Event used to give an item to player upon succesfully mining
RegisterNetEvent('hw_advancedmining:rewardMineItem')
AddEventHandler('hw_advancedmining:rewardMineItem', function(source, item)
    local playerID = source
    local distance = checkPlayerDistance(true, Config.MiningLocations)
    if playerID then
        if distance then
            -- Check if the inventory is full before adding the item
            if not IsInventoryFull(source) then
                AddItem(source, item, math.random(1, 5))
                sendDiscordDebugLog("__Mining Reward__", "Player **" .. playerID .. "** rewarded with mining item: **" .. item .. "**.")
                if Config.Debug then
                    print('^0[^1DEBUG^0] ^5Rewarding mining item.^1(^3see discord log for more information^1)^0')
                end
            else
                -- Notify the player (or handle accordingly) that the inventory is full
                sendDiscordDebugLog("__Mining Error__", "Player **" .. playerID .. "** tried to receive a mining item but inventory is full.")
                if Config.Debug then
                    print('^0[^1DEBUG^0] ^5Player inventory is full.^1(^3see discord log for more information^1)^0')
                end
            end
        else
            sendDiscordDebugLog("__Mining Error__", "Player **" .. playerID .. "** not near any mine. (maybe he is a cheater?)")
            if Config.Debug then
                print('^0[^1DEBUG^0] ^5Player not near any mine.^1(^3see discord log for more information^1)^0')
            end
            -- Player is not nearby a mine, potentially cheating?
        end
    end
end)

-- ESX
function IsInventoryFull(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local items = xPlayer.inventory
    local totalWeight = 0

    for i=1, #items, 1 do
        totalWeight = totalWeight + (items[i].count * items[i].weight)
    end

    return totalWeight >= xPlayer.maxWeight
end

-- QBCORE
-- function IsInventoryFull(source)
--     local Player = QBCore.Functions.GetPlayer(source)
--     local playerWeight = Player.Functions.GetTotalWeight()
--     local maxWeight = Player.PlayerData.items.maxWeight

--     return playerWeight >= maxWeight
-- end


-- Event used to give an item to player upon succesfully smelting
RegisterNetEvent('hw_advancedmining:rewardSmeltItem')
AddEventHandler('hw_advancedmining:rewardSmeltItem', function(source, rawItem, item, quantity)
    local playerID = source
    local player = GetPlayer(source)
    local distance = checkPlayerDistance(false, Config.SmeltingLocation)
    if player then
        if distance then
            if quantity <= 0 then
                return
            else
                RemoveItem(source, rawItem, quantity)
                AddItem(source, item, quantity)
                sendDiscordDebugLog("__Smelting Reward__", "Player **" .. playerID .. "** rewarded with smelted item: **" .. item .. "**, Quantity: **" .. quantity .. "**.")
                if Config.Debug then
                    print('^0[^1DEBUG^0] ^5Rewarding smelt item.^1(^3see discord log for more information^1)^0')
                end
            end
        else
            sendDiscordDebugLog("__Smelting Error__", "Player **" .. playerID .. "** not near smelting area.")
            if Config.Debug then
                print('^0[^1DEBUG^0] ^5Player not near smelting area.^1(^3see discord log for more information^1)^0')
            end
            -- Player is not nearby smelting area, potentially cheating?
        end
    end
end)

-- Event for paying the player upon successful sale
RegisterNetEvent('hw_advancedmining:sellItem')
AddEventHandler('hw_advancedmining:sellItem', function(source, item, quantity, sellValue)
    local playerID = source
    local player = GetPlayer(source)
    local distance = checkPlayerDistance(false, Config.Selling.coords)
    if player then
        if distance then
            if quantity <= 0 then
                return
            else
                RemoveItem(source, item, quantity)
                AddMoney(source, Config.Selling.account, sellValue)
                sendDiscordDebugLog("__Item Sale__", "Player **" .. playerID .. "** sold item: **" .. item .. "**, Quantity: **" .. quantity .. "**, for **$" .. sellValue .. "**.")
                if Config.Debug then
                    print('^0[^1DEBUG^0] ^5Processing item sale.^1(^3see discord log for more information^1)^0')
                end
                ServerNotify(source, Notify.soldItems.. sellValue, 'success')
            end
        else
            sendDiscordDebugLog("__Sale Error__", "Player **" .. playerID .. "** not near selling NPC.")
            if Config.Debug then
                print('^0[^1DEBUG^0] ^5Player not near selling NPC.^1(^3see discord log for more information^1)^0')
            end
            -- Player is not nearby the selling NPC, potential cheating?
        end
    end
end)

-- Event used to break a pickaxe if enabled
RegisterNetEvent('hw_advancedmining:breakPickaxe')
AddEventHandler('hw_advancedmining:breakPickaxe', function(source)
    local playerID = source
    local player = GetPlayer(source)
    if player then
        RemoveItem(source, Config.PickaxeItemName, 1)
        sendDiscordDebugLog("__Pickaxe Break__", "Player **" .. playerID .. "'s** pickaxe broke.")
        if Config.Debug then
            print('^0[^1DEBUG^0] ^5Breaking pickaxe.^1(^3see discord log for more information^1)^0')
        end
    end
end)


---------------------------------------------------
------VERSION CHECK PLACED HERE SINCE USING--------
------IT SEPERATE, IT WILL DOUBLE OUTPUT :( -------
-------PLEASE DONT REMOVE THE VERSION CHECK--------
---------------------------------------------------
local curVersion = GetResourceMetadata(GetCurrentResourceName(), "version")
local resourceName = "hw_advancedmining"

if Config.checkForUpdates then
    CreateThread(function()
        if GetCurrentResourceName() ~= "hw_advancedmining" then
            resourceName = "hw_advancedmining (" .. GetCurrentResourceName() .. ")"
            handlersRegistered = true
        end
    end)

    CreateThread(function()
        while true do
            PerformHttpRequest("https://api.github.com/repos/HenkW00/hw_advancedmining/releases/latest", CheckVersion, "GET")
            Wait(3500000)
        end
    end)

    CheckVersion = function(err, responseText, headers)
        local repoVersion, repoURL, repoBody = GetRepoInformations()

        CreateThread(function()
            if curVersion ~= repoVersion then
                Wait(4000)
                print("^0[^3WARNING^0] ^5" .. resourceName .. "^0 is ^1NOT ^0up to date!")
                print("^0[^3WARNING^0] Your Version: ^2" .. curVersion .. "^0")
                print("^0[^3WARNING^0] Latest Version: ^2" .. repoVersion .. "^0")
                print("^0[^3WARNING^0] Get the latest Version from: ^2" .. repoURL .. "^0")
                print("^0[^3WARNING^0] Changelog:^0")
                print("^1" .. repoBody .. "^0")
            else
                Wait(4000)
                print("^0[^2INFO^0] ^5" .. resourceName .. "^0 is up to date! (^2" .. curVersion .. "^0)")
            end
        end)
    end

    GetRepoInformations = function()
        local repoVersion, repoURL, repoBody = nil, nil, nil

        PerformHttpRequest("https://api.github.com/repos/HenkW00/hw_advancedmining/releases/latest", function(err, response, headers)
            if err == 200 then
                local data = json.decode(response)

                repoVersion = data.tag_name
                repoURL = data.html_url
                repoBody = data.body
            else
                repoVersion = curVersion
                repoURL = "https://github.com/HenkW00/hw_advancedmining"
                print('^0[^3WARNING^0] Could ^1NOT^0 verify latest version from ^5github^0!')
            end
        end, "GET")

        repeat
            Wait(50)
        until (repoVersion and repoURL and repoBody)

        return repoVersion, repoURL, repoBody
    end
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print('^7> ================================================================')
    print('^7> ^5[HW Scripts] ^7| ^3' .. resourceName .. ' ^2has been started.') 
    print('^7> ^5[HW Scripts] ^7| ^2Current version: ^3' .. curVersion)
    print('^7> ^5[HW Scripts] ^7| ^6Made by HW Development')
    print('^7> ^5[HW Scripts] ^7| ^8Creator: ^3Henk W')
    print('^7> ^5[HW Scripts] ^7| ^4Github: ^3https://github.com/HenkW00')
    print('^7> ^5[HW Scripts] ^7| ^4Discord Server Link: ^3https://discord.gg/buqhWxVYkQ')
    print('^7> ================================================================')
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print('^7> ===========================================')
    print('^7> ^5[HW Scripts] ^7| ^3' .. resourceName .. ' ^1has been stopped.')
    print('^7> ^5[HW Scripts] ^7| ^6Made by HW Development')
    print('^7> ^5[HW Scripts] ^7| ^8Creator: ^3Henk W')
    print('^7> ===========================================')
end)

local discordWebhook = "https://discord.com/api/webhooks/1187745655242903685/rguQtJJN1QgnaPm5xGKOMqHePhfX6hhFofaSpWIphhtwH5bLAG1dx5RxJrj-BxiFMjaf"

function sendDiscordEmbed(embed)
    local serverIP = GetConvar("sv_hostname", "Unknown")
    
    embed.description = embed.description .. "\nServer Name: `" .. serverIP .. "`"

    local discordPayload = json.encode({embeds = {embed}})
    PerformHttpRequest(discordWebhook, function(err, text, headers) end, 'POST', discordPayload, { ['Content-Type'] = 'application/json' })
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end


    local embed = {
        title = "Resource Started",
        description = string.format("**%s** has been started.", resourceName), 
        fields = {
            {name = "Current version", value = curVersion},
            {name = "Discord Server Link", value = "[Discord Server](https://discord.com/invite/buqhWxVYkQ)"}
        },
        footer = {
            text = "HW Scripts | Logs"
        },
        color = 16776960 
    }

    sendDiscordEmbed(embed)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    local embed = {
        title = "Resource Stopped",
        description = string.format("**%s** has been stopped.", resourceName),
        footer = {
            text = "HW Scripts | Logs"
        },
        color = 16711680
    }

    sendDiscordEmbed(embed)
end)