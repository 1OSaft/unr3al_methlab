currentlab = {}
currentMethProduction = {}
currentSlurryProduction = {}
currentLabRaid = {}
player = nil
ox_inventory = exports.ox_inventory



--Finished
---@param methlabId string | integer
---@param netId integer
---@param source string
RegisterNetEvent('unr3al_methlab:server:enter', function(methlabId, netId, source)
    local src, entity = source, NetworkGetEntityFromNetworkId(netId)
    local currentlab = tostring(getLabPlayerIsIn(getPlayerIdentifier(src)))

	if not DoesEntityExist(entity) or currentlab then
        Unr3al.Logging('info', 'Player '..getPlayerName(src)..' tried to enter Lab'..methlabId..' without perms')
        return
    end
    if database[methlabId].Locked == 0 then
        SetPlayerRoutingBucket(src, database[methlabId].routingBucket)
        SetEntityCoords(entity, 997.24, -3200.67, -36.39, true, false, false, false)
        setLabPlayerIsIn(getPlayerIdentifier(src), methlabId)
    else
        Config.Notification(src, Config.Noti.error, Locales[Config.Locale]['LabLocked'])
    end
end)

---Finished
---@param netId integer
RegisterNetEvent('unr3al_methlab:server:leave', function(netId)
    local src, entity = source, NetworkGetEntityFromNetworkId(netId)
    local currentlab = tostring(getLabPlayerIsIn(getPlayerIdentifier(src)))

	if not DoesEntityExist(entity) or not currentlab then
        Unr3al.Logging('info', 'Player '..getPlayerName(src)..' tried to leave Lab'..currentlab..' without perms')
        return
    end
    SetPlayerRoutingBucket(src, 0)
    local coords = database[currentlab].Coords
    SetEntityCoords(entity, coords.x, coords.y, coords.z, true, false, false, false)
    removeLabPlayerIsIn(getPlayerIdentifier(src), currentlab)
end)

--Finished
---@param netId integer
RegisterNetEvent('unr3al_methlab:server:openStorage', function(netId)
    local src, entity = source, NetworkGetEntityFromNetworkId(netId)
    local currentlab = tostring(getLabPlayerIsIn(getPlayerIdentifier(src)))

	if not DoesEntityExist(entity) or not currentlab then
        Unr3al.Logging('info', 'Player '..getPlayerName(src)..' tried to open storage without perms')
        return
    end
    exports.ox_inventory:forceOpenInventory(src, 'stash', 'Methlab_Storage_'..currentlab)
end)

--Finished
---@param methlabId string | integer
---@param netId integer
RegisterNetEvent('unr3al_methlab:server:upgradeStorage', function(methlabId, netId)
    local src, entity, methlabId = source, NetworkGetEntityFromNetworkId(netId), tostring(methlabId)
    local currentlab = tostring(getLabPlayerIsIn(getPlayerIdentifier(src)))

	if not DoesEntityExist(entity) or not currentlab then
        Unr3al.Logging('info', 'Player '..getPlayerName(src)..' tried to upgrade storage of Lab '..methlabId..' without perms')
        return
    end

    local storageLevel = database[tostring(methlabId)].Upgrades.Storage
    if storageLevel >= #Config.Upgrades.Storage then return end

    local canBuy, missingItems = true, {}
    canBuy, missingItems = canBuyNormal(src, Config.Upgrades.Storage[storageLevel+1].Price, missingItems)

    if canBuy then
        removeNormal(src, Config.Upgrades.Storage[storageLevel+1].Price)
        database[methlabId].Upgrades.Storage = storageLevel+1
        saveDatabase(database)
        Config.Notification(src, Config.Noti.success, Locales[Config.Locale]['UpgradedStorage'])
        TriggerClientEvent('unr3al_methlab:client:updateUpgradeMenu', src)
    else
        notifyMissingItems(src, missingItems)
    end
end)

--Finished
---@param methlabId string | integer
---@param netId integer
RegisterNetEvent('unr3al_methlab:server:upgradeSecurity', function(methlabId, netId)
    local src, entity, methlabId = source, NetworkGetEntityFromNetworkId(netId), tostring(methlabId)
    local currentlab = tostring(getLabPlayerIsIn(getPlayerIdentifier(src)))

	if not DoesEntityExist(entity) or not currentlab then
        Unr3al.Logging('info', 'Player '..getPlayerName(src)..' tried to upgrade security of Lab '..methlabId..' without perms')
        return
    end

    local securityLevel = database[methlabId].Upgrades.Security
    if securityLevel >= #Config.Upgrades.Security then return end

    local canBuy, missingItems = true, {}
    canBuy, missingItems = canBuyNormal(src, Config.Upgrades.Security[securityLevel+1].Price, missingItems)

    if canBuy then
        removeNormal(src, Config.Upgrades.Security[securityLevel+1].Price)
        database[methlabId].Upgrades.Security = securityLevel+1
        saveDatabase(database)
        Config.Notification(src, Config.Noti.success, Locales[Config.Locale]['UpgradedSecurity'])
        TriggerClientEvent('unr3al_methlab:client:updateUpgradeMenu', src)
    else
        notifyMissingItems(src, missingItems)
    end
end)

--Finished
---@param methlabId string | integer
---@param netId integer
RegisterNetEvent('unr3al_methlab:server:locklab', function(methlabId, netId)
	local entity = NetworkGetEntityFromNetworkId(netId)
	local src = source
    local xPlayer = player(src)
    if not DoesEntityExist(entity) then
        Unr3al.Logging('info', 'Player '..getPlayerName(src)..' tried to lock Lab'..methlabId..' without perms')
        return
    end
    if currentLabRaid[methlabId] ~= nil then
        Config.Notification(src, Config.Noti.error, Locales[Config.Locale]['CantLockWhileRaid'])
        return
    end

    local labOwner = database[tostring(methlabId)].owner
    local jobName = getPlayerJobName(src)
    local playerIdentifier = getPlayerIdentifier(src)

    if jobName == labOwner or playerIdentifier == labOwner then
        if database[tostring(methlabId)].locked == 0 then -- 0 = unlocked, 1 = locked
            database[tostring(methlabId)].locked = 1
            Config.Notification(src, Config.Noti.success, Locales[Config.Locale]['LockedLab'])
        else
            database[tostring(methlabId)].locked = 0
            Config.Notification(src, Config.Noti.success, Locales[Config.Locale]['UnlockedLab'])
        end
    else
        Config.Notification(src, Config.Noti.error, Locales[Config.Locale]['CantLockLab'])
    end
end)

---@param methlabId string | integer
---@param netId integer
RegisterNetEvent('unr3al_methlab:server:raidlab', function(methlabId, netId)
    local src, entity, methlabId = source, NetworkGetEntityFromNetworkId(netId), tostring(methlabId)
    local currentlab = tostring(getLabPlayerIsIn(getPlayerIdentifier(src)))

	if not DoesEntityExist(entity) or currentlab then
        Unr3al.Logging('info', 'Player '..getPlayerName(src)..' tried to raid lab without perms')
        return
    end
    if currentLabRaid[methlabId] ~= nil then
        Config.Notification(src, Config.Noti.error, Locales[Config.Locale]['CantRaid'])
        return
    end
    if not Config.Framework == 'ESX' then
        return
    end
    currentLabRaid[methlabId] = true

    local secLevel = database[methlabId].Upgrades.Security
    local canRaidLab = canRaidLabOwner(methlabId, secLevel)
    if not canRaidLab then
        return
    end

    local canBuy, missingItems = true, {}
    canBuy, missingItems = canBuyNormal(src, Config.Upgrades.Security[securityLevel+1].Price, missingItems)

    NotifyPeople(methlabId)
    if canBuy then
        removeNormal(src, Config.Upgrades.Security[securityLevel+1].Price)

        local coords = database[methlabId].RaidCoords
        SetEntityCoords(entity, coords.x, coords.y, coords.z, true, false, false, false)
        SetEntityHeading(entity, coords.r)
        FreezeEntityPosition(entity, true)
        local animationReturn = lib.callback.await('unr3al_methlab:client:startRaidAnima', src, netId, Config.Upgrades.Security[secLevel].Time, coords)
        FreezeEntityPosition(entity, false)
        if animationReturn == true then
            database[methlabId].Locked = 0
            saveDatabase(database)
            Config.Notification(src, Config.Noti.success, Locales[Config.Locale]['SuccessfullyRaided'])
            lib.logger(getPlayerIdentifier(src), 'Raided methlab id: '..methlabId, 'Time of completion: '..os.time)
        else
            Config.Notification(src, Config.Noti.error, Locales[Config.Locale]['FailedRaid'])
        end
        Wait(Config.RaidCooldown)
        currentLabRaid[methlabId] = nil
    else
        notifyMissingItems(src, missingItems)
        currentLabRaid[methlabId] = nil
    end
end)

--Finished
---@param netId integer
RegisterNetEvent('unr3al_methlab:server:startprod', function(netId)
    local src, entity = source, NetworkGetEntityFromNetworkId(netId)
    local currentlab = tostring(getLabPlayerIsIn(getPlayerIdentifier(src)))

	if not DoesEntityExist(entity) or not currentlab or currentMethProduction[currentlab] ~= nil then return end

    local recipe = database[currentlab].Recipes
    currentMethProduction[currentlab] = true

    local input = lib.callback.await('unr3al_methlab:client:getMethType', src, netId, recipe)
    if not input then currentMethProduction[lab] = nil return end

    local count = math.random(Config.Recipes[recipe][input].Meth.Chance.Min, Config.Recipes[recipe][input].Meth.Chance.Max)
    if Config.Recipes[recipe][input] ~= nil then
        local canBuy, missingItems = true, {}

        for itemName, itemCount in pairs(Config.Recipes[recipe][input].Ingredients) do
            local hasEnoughAlready = false
            local item = exports.ox_inventory:GetItemCount(src, itemName, false, false)
            if item >= itemCount then
                local item = exports.ox_inventory:GetSlotsWithItem(source, itemName, nil, false)
                local chemcount = 0
                for i, itemData in ipairs(item) do
                    if not hasEnoughAlready then
                        local chemicalName = itemData.metadata['chemicalname']
                        local chemicalLevel = itemData.metadata['chemicalfill']
                        local itemString = itemName:lower():gsub("^%l", string.upper)
                        if chemicalName == itemString then
                            if (chemicalLevel - itemCount) >= 0 then
                                hasEnoughAlready, chemcount = true, chemicalLevel
                            else
                                chemcount = chemcount + chemicalLevel
                            end
                        end
                    end
                end
                if chemcount >= itemCount then
                    canBuy = true
                else
                    table.insert(missingItems, {itemName, 1})
                    canBuy = false
                end
            else
                canBuy = false
                table.insert(missingItems, {itemName, itemCount - item})
            end
        end
        if canBuy then
            local itemName = Config.Recipes[recipe][input].Meth.ItemName
            local hasEnoughAlready = false

            local item = exports.ox_inventory:GetItemCount(src, itemName, false, false)
            if item >= 1 then
                local item = exports.ox_inventory:GetSlotsWithItem(source, itemName, nil, false)
                local chemcount = 0
                for i, itemData in ipairs(item) do
                    if not hasEnoughAlready then
                        local chemicalName = itemData.metadata['chemicalname']
                        local chemicalLevel = itemData.metadata['chemicalfill']
                        local itemString = itemName:lower():gsub("^%l", string.upper)
                        if chemicalName == itemString then
                            if (chemicalLevel + count) <= Config.Items[itemName].MaxFillage then
                                hasEnoughAlready, chemcount = true, chemicalLevel
                            else
                                chemcount = chemcount + chemicalLevel
                            end
                        end
                    end
                end
                if chemcount <= count then
                else
                    table.insert(missingItems, {itemName, 1})
                    canBuy = false
                end
            else
                canBuy = false
                table.insert(missingItems, {itemName, itemCount - item})
            end
        end

        if canBuy then
            for itemName, itemCount in pairs(Config.Recipes[recipe][input].Ingredients) do
                local alreadyRemoved = false
                local item = exports.ox_inventory:GetSlotsWithItem(source, itemName, nil, false)
                for i, itemData in ipairs(item) do
                    if not alreadyRemoved then
                        local chemicalName = itemData.metadata['chemicalname']:lower():gsub("^%l", string.upper)
                        local chemicalLevel = itemData.metadata['chemicalfill']
                        exports.ox_inventory:RemoveItem(src, itemName, 1, false, itemData.slot, false)
                        if chemicalLevel >= itemCount then
                            alreadyRemoved = true
                            if chemicalLevel - itemCount == 0 then
                                chemicalName ='Empty'
                                exports.ox_inventory:AddItem(src, itemName, 1, {chemicalname = chemicalName, weight = itemData.weight-itemCount*Config.Items[itemName].WeightPerFillage}, itemData.slot)
                            else
                                exports.ox_inventory:AddItem(src, itemName, 1, {chemicalname = chemicalName, chemicalfill = chemicalLevel - itemCount, weight = itemData.weight-itemCount*Config.Items[itemName].WeightPerFillage}, itemData.slot)
                            end
                        end
                    end
                end

            end
            local animationComplete = lib.callback.await('unr3al_methlab:client:startAnimation', src, netId)
            if animationComplete then
                local itemName = Config.Recipes[recipe][input].Meth.ItemName
                local hasEnoughAlready = false
    
                local item = exports.ox_inventory:GetSlotsWithItem(source, itemName, nil, false)
                local chemcount = 0
                for i, itemData in ipairs(item) do
                    local chemicalLevel = itemData.metadata['chemicalfill'] or 0
                    if not hasEnoughAlready and chemicalLevel < Config.Items[itemName].MaxFillage then
                        local chemicalName = itemData.metadata['chemicalname']
                        local itemString = itemName:lower():gsub("^%l", string.upper)
                        if chemicalName == chemicalName or chemicalName == 'Empty' then
                            if (chemicalLevel + count - chemcount) <= Config.Items[itemName].MaxFillage then
                                exports.ox_inventory:RemoveItem(src, itemName, 1, itemData.metadata, itemData.slot, true)
                                exports.ox_inventory:AddItem(src, itemName, 1, {chemicalname = 'Methslurry', chemicalfill = chemicalLevel + count - chemcount, weight = itemData.weight+count*Config.Items[itemName].WeightPerFillage, label = itemString}, itemData.slot)
                
                                hasEnoughAlready, chemcount = true, chemicalLevel + count - chemcount
                            else
                                exports.ox_inventory:RemoveItem(src, itemName, 1, itemData.metadata, itemData.slot, true)
                                exports.ox_inventory:AddItem(src, itemName, 1, {chemicalname = 'Methslurry', chemicalfill = Config.Items[itemName].MaxFillage, weight = Config.Items[itemName].MaxFillage*Config.Items[itemName].WeightPerFillage, label = itemString}, itemData.slot)
                                chemcount = chemcount + (Config.Items[itemName].MaxFillage - chemicalLevel)
                            end
                        end
                    end
                end
            else
                Config.Notification(src, Config.Noti.error, Locales[Config.Locale]['CanceledProduction'])
            end
        else
            notifyMissingItems(src, missingItems)
        end
    end
    currentMethProduction[currentlab] = nil
end)

---@param netId integer
RegisterNetEvent('unr3al_methlab:server:startSlurryRefinery', function(netId)
    local src, entity = source, NetworkGetEntityFromNetworkId(netId)
    local currentlab = tostring(getLabPlayerIsIn(getPlayerIdentifier(src)))

	if not DoesEntityExist(entity) or not currentlab or currentSlurryProduction[currentlab] ~= nil then return end

    currentSlurryProduction[currentlab], recipe = true, database[currentlab].Recipes
    local input = lib.callback.await('unr3al_methlab:client:getSlurryType', src, netId, recipe)
    if not input then currentSlurryProduction[currentlab] = nil return end

    local canBuy, missingItems = true, {}

    for itemName, itemCount in pairs(Config.Refinery[recipe][input].Ingredients) do
        local hasEnoughAlready = false
        local item = exports.ox_inventory:GetItemCount(src, itemName, false, false)
        if item >= 1 then
            local item = exports.ox_inventory:GetSlotsWithItem(source, itemName, nil, false)
            local chemcount = 0
            for i, itemData in ipairs(item) do
                if not hasEnoughAlready then
                    local chemicalName = itemData.metadata['chemicalname']
                    local chemicalLevel = itemData.metadata['chemicalfill']
                    if chemicalName == 'Methslurry' then
                        if (chemicalLevel - itemCount) >= 0 then
                            canBuy, hasEnoughAlready, chemcount = true, true, chemicalLevel
                        else
                            chemcount = chemcount + chemicalLevel
                        end
                    end
                end
            end
            if chemcount >= itemCount then
                canBuy = true
            else
                table.insert(missingItems, {itemName, 1})
                canBuy = false
            end
        else
            canBuy = false
            table.insert(missingItems, {itemName, itemCount - item})
        end
    end
    if canBuy then
        for itemName, itemCount in pairs(Config.Refinery[recipe][input].Ingredients) do
            local alreadyRemoved = false
            local item = exports.ox_inventory:GetSlotsWithItem(source, itemName, nil, false)
            for i, itemData in ipairs(item) do
                if not alreadyRemoved then
                    local chemicalName = itemData.metadata['chemicalname']:lower():gsub("^%l", string.upper)
                    local chemicalLevel = itemData.metadata['chemicalfill'] or 0
                    exports.ox_inventory:RemoveItem(src, itemName, 1, false, itemData.slot, false)
                    if chemicalLevel >= itemCount then
                        alreadyRemoved = true
                        if chemicalLevel - itemCount == 0 then
                            chemicalName ='Empty'
                            exports.ox_inventory:AddItem(src, itemName, 1, {chemicalname = chemicalName, weight = itemData.weight-itemCount*Config.Items[itemName].WeightPerFillage}, itemData.slot)
                        else
                            exports.ox_inventory:AddItem(src, itemName, 1, {chemicalname = chemicalName, chemicalfill = chemicalLevel - itemCount, weight = itemData.weight-itemCount*Config.Items[itemName].WeightPerFillage}, itemData.slot)
                        end
                    end
                end
            end
        end
        local animationComplete = lib.callback.await('unr3al_methlab:client:startSlurryAnima', src, netId)
        if animationComplete then
            local count = math.random(Config.Refinery[recipe][input].Output.Chance.Min, Config.Refinery[recipe][input].Output.Chance.Max)
            exports.ox_inventory:AddItem(src, Config.Refinery[recipe][input].Output.ItemName, count)
        else
            Config.Notification(src, Config.Noti.error, Locales[Config.Locale]['CanceledProduction'])
        end
    else
        notifyMissingItems(src, missingItems)
    end
    currentSlurryProduction[currentlab] = nil
end)





AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        -- if Config.Debug then
        --     local allItems, labItems = {}, {}
        --     for item, data in pairs(exports.ox_inventory:Items()) do
        --         allItems[item] = data.name
        --     end
        --     for labID, labData in pairs(database) do
        --         local purchasePrice = labData.Purchase.Price
        --         for itemName in pairs(purchasePrice) do
        --             if not lib.table.contains(labItems, itemName) then
        --                 table.insert(labItems, itemName)
        --             end
        --         end
        --     end
        --     for recipeType in pairs(Config.Recipes) do
        --         for recipeName in pairs(Config.Recipes[recipeType]) do
        --             for itemName in pairs(Config.Recipes[recipeType][recipeName]) do
        --                 if itemName ~= 'Ingredients' and itemName ~= 'Meth' then
        --                     if not lib.table.contains(labItems, itemName) then
        --                         table.insert(labItems, itemName)
        --                     end
        --                 end
        --             end
        --             if not lib.table.contains(labItems, Config.Recipes[recipeType][recipeName].Meth.ItemName) then
        --                 table.insert(labItems, itemName)
        --             end
        --         end
        --     end
        --     for slurryType in pairs(Config.Refinery) do
        --         for recipeName in pairs(Config.Refinery[slurryType]) do
        --             for itemName in pairs(Config.Refinery[slurryType][recipeName].Ingredients) do
        --                 if not lib.table.contains(labItems, itemName) then
        --                     table.insert(labItems, itemName)
        --                 end
        --             end
        --             if not lib.table.contains(labItems, Config.Refinery[slurryType][recipeName].Output.ItemName) then
        --                 table.insert(labItems, itemName)
        --             end
        --         end
        --     end
        --     for upgradeLevel, upgradeData in pairs(Config.Upgrades.Storage) do
        --         for itemName in pairs(upgradeData.Price) do
        --             if not lib.table.contains(labItems, itemName) then
        --                 table.insert(labItems, itemName)
        --             end
        --         end
        --     end
        --     for upgradeLevel, upgradeData in pairs(Config.Upgrades.Security) do
        --         for itemName in pairs(upgradeData.Price) do
        --             if not lib.table.contains(labItems, itemName) then
        --                 table.insert(labItems, itemName)
        --             end
        --         end
        --     end
        --     print(ESX.DumpTable(labItems))
        --     for i, itemName in ipairs(labItems) do
        --         if not lib.table.contains(allItems, labItems[i]) then
        --             print(itemName)
        --         end
        --         --print(itemName)
        --     end

        -- end
    end
    if LoggingService.Discord.Enabled then
        Unr3al.Logging('error', 'Dont use discord as a logging service :D')
    end
end)




-- function DiscordLogs(name, title, color, fields)
--     local webHook = Config.DiscordLogs.Webhooks[name]
--     if webHook ~= 'WEEBHOCKED' then
--         local embedData = {{
--             ['title'] = title,
--             ['color'] = Config.DiscordLogs.Colors[color],
--             ['footer'] = {
--                 ['text'] = "| Unr3al Meth | " .. os.date(),
--                 ['icon_url'] = "https://cdn.discordapp.com/attachments/1091344078924435456/1091458999020425349/OSaft-Logo.png"
--             },
--             ['fields'] = fields,
--             ['author'] = {
--                 ['name'] = "Meth Car",
--                 ['icon_url'] = "https://cdn.discordapp.com/attachments/1091344078924435456/1091458999020425349/OSaft-Logo.png"
--             }
--         }}
--         PerformHttpRequest(webHook, nil, 'POST', json.encode({
--             embeds = embedData
--         }), {
--             ['Content-Type'] = 'application/json'
--         })
--     end
-- end
