-- Utility function to send a debug message to Discord
function sendDiscordDebugLog(title, description)
    local webhookUrl = 'https://discord.com/api/webhooks/1225496675364245535/Tux7AsTS9BKM-c4WOCfDEL5B59VTHfT_zPcMbdn1uCJuChIXeDEA2M7OP5l7xnzB6cWq'
    local data = {
        ["username"] = "HW Logs",
        ["embeds"] = {{
            ["title"] = title,
            ["description"] = description,
            ["type"] = "rich",
            ["color"] = 65280, -- Green color
            ["footer"] = {
                ["text"] = "HW Scrips | Advanced Mining"
            }
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
    local player = GetPlayer(source)
    local distance = checkPlayerDistance(true, Config.MiningLocations)
    if playerID then
        if distance then
            AddItem(source, item, math.random(1, 5))
            sendDiscordDebugLog("Mining Reward", "Player " .. playerID .. " rewarded with mining item: " .. item)
            if Config.Debug then
                print('^0[^1DEBUG^0] ^5Rewarding mining item.')
            end
        else
            sendDiscordDebugLog("Mining Error", "Player " .. playerID .. " not near any mine.")
            if Config.Debug then
                print('^0[^1DEBUG^0] ^5Player not near any mine.')
            end
            -- Player is not nearby a mine, potentially cheating?
        end
    end
end)

-- Event used to give an item to player upon succesfully smelting
RegisterNetEvent('hw_advancedmining:rewardSmeltItem')
AddEventHandler('hw_advancedmining:rewardSmeltItem', function(source, rawItem, item, quantity)
    local source = source
    local player = GetPlayer(source)
    local distance = checkPlayerDistance(false, Config.SmeltingLocation)
    if player then
        if distance then
            if quantity <= 0 then
                return
            else
                RemoveItem(source, rawItem, quantity)
                AddItem(source, item, quantity)
                sendDiscordDebugLog("Smelting Reward", "Player " .. player .. " rewarded with smelted item: " .. item .. ", Quantity: " .. quantity)
                if Config.Debug then
                    print('^0[^1DEBUG^0] ^5Rewarding smelt item.')
                end
            end
        else
            sendDiscordDebugLog("Smelting Error", "Player " .. player .. " not near smelting area.")
            if Config.Debug then
                print('^0[^1DEBUG^0] ^5Player not near smelting area.')
            end
            -- Player is not nearby smelting area, potentially cheating?
        end
    end
end)

-- Event for paying the player upon successful sale
RegisterNetEvent('hw_advancedmining:sellItem')
AddEventHandler('hw_advancedmining:sellItem', function(source, item, quantity, sellValue)
    local source = source
    local player = GetPlayer(source)
    local distance = checkPlayerDistance(false, Config.Selling.coords)
    if player then
        if distance then
            if quantity <= 0 then
                return
            else
                RemoveItem(source, item, quantity)
                AddMoney(source, Config.Selling.account, sellValue)
                sendDiscordDebugLog("Item Sale", "Player " .. player .. " sold item: " .. item .. ", Quantity: " .. quantity .. ", for $" .. sellValue)
                if Config.Debug then
                    print('^0[^1DEBUG^0] ^5Processing item sale.')
                end
                ServerNotify(source, Notify.soldItems.. sellValue, 'success')
            end
        else
            sendDiscordDebugLog("Sale Error", "Player " .. player .. " not near selling NPC.")
            if Config.Debug then
                print('^0[^1DEBUG^0] ^5Player not near selling NPC.')
            end
            -- Player is not nearby the selling NPC, potential cheating?
        end
    end
end)

-- Event used to break a pickaxe if enabled
RegisterNetEvent('hw_advancedmining:breakPickaxe')
AddEventHandler('hw_advancedmining:breakPickaxe', function(source)
    local source = source
    local player = GetPlayer(source)
    if player then
        RemoveItem(source, Config.PickaxeItemName, 1)
        sendDiscordDebugLog("Pickaxe Break", "Player " .. player .. "'s pickaxe broke.")
        if Config.Debug then
            print('^0[^1DEBUG^0] ^5Breaking pickaxe.')
        end
    end
end)