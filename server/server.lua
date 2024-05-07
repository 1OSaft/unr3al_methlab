currentlab = {}
currentMethProduction = {}
currentSlurryProduction = {}
currentLabRaid = {}
player = nil
ox_inventory = exports.ox_inventory



--Finished
RegisterNetEvent('unr3al_methlab:server:enter', function(methlabId, netId, source)
	local entity = NetworkGetEntityFromNetworkId(netId)
	local src = source
	if not DoesEntityExist(entity) or currentlab[src] ~= nil then
        Unr3al.Logging('info', 'Player '..getPlayerName(src)..' tried to enter Lab'..methlabId..' without perms')
        return
    end
    local response = MySQL.single.await('SELECT locked FROM unr3al_methlab WHERE id = ?', {methlabId})
    if response.locked == 0 then
        SetPlayerRoutingBucket(src, methlabId)
        SetEntityCoords(entity, 997.24, -3200.67, -36.39, true, false, false, false)
        currentlab[src] = methlabId
    else
        Config.Notification(src, Config.Noti.error, Locales[Config.Locale]['LabLocked'])
    end
end)

--Finished
RegisterNetEvent('unr3al_methlab:server:leave', function(methlabId, netId)
	local entity = NetworkGetEntityFromNetworkId(netId)
	local src = source
	if not DoesEntityExist(entity) or currentlab[src] == nil then
        Unr3al.Logging('info', 'Player '..getPlayerName(src)..' tried to leave Lab'..methlabId..' without perms')
        return
    end
    SetPlayerRoutingBucket(src, 0)
    local coords = Config.Methlabs[currentlab[src]].Coords
    SetEntityCoords(entity, coords.x, coords.y, coords.z, true, false, false, false)
    currentlab[src] = nil
end)

--Finished
RegisterNetEvent('unr3al_methlab:server:openStorage', function(netId)
	local entity = NetworkGetEntityFromNetworkId(netId)
	local src = source
	if not DoesEntityExist(entity) or currentlab[src] == nil then
        Unr3al.Logging('info', 'Player '..getPlayerName(src)..' tried to open storage without perms')
        return
    end
    exports.ox_inventory:forceOpenInventory(src, 'stash', 'Methlab_Storage_'..currentlab[src])
end)

--Finished
RegisterNetEvent('unr3al_methlab:server:upgradeStorage', function(methlabId, netId)
	local entity = NetworkGetEntityFromNetworkId(netId)
	local src = source
	if not DoesEntityExist(entity) or currentlab[src] == nil then
        Unr3al.Logging('info', 'Player '..getPlayerName(src)..' tried to upgrade storage of Lab '..methlabId..' without perms')
        return
    end

    local storageLevel = MySQL.single.await('SELECT `storage` FROM `unr3al_methlab` WHERE `id` = ?', {methlabId}).storage
    if storageLevel == #Config.Upgrades.Storage then return end
    local canBuy = true
    local missingItems = {}
    for itenName, itemCount in pairs(Config.Upgrades.Storage[storageLevel+1].Price) do
        local item = exports.ox_inventory:GetItemCount(src, itenName, false, false)
        if item < itemCount then
            canBuy = false
            table.insert(missingItems, {itenName, itemCount - item})
        end
    end
    if canBuy then
        for itemName, itemCount in pairs(Config.Upgrades.Storage[storageLevel+1].Price) do
            exports.ox_inventory:RemoveItem(src, itemName, itemCount, false, false, true)
        end
        local updateOwner = MySQL.update.await('UPDATE unr3al_methlab SET storage = ? WHERE id = ?', {
            storageLevel+1, methlabId
        })
        if updateOwner == 1 then
            exports.ox_inventory:RegisterStash('Methlab_Storage_'..methlabId, 'Methlab storage', Config.Upgrades.Storage[storageLevel+1].Slots, Config.Upgrades.Storage[storageLevel+1].MaxWeight, false)
            Config.Notification(src, Config.Noti.success, Locales[Config.Locale]['UpgradedStorage'])
            TriggerClientEvent('unr3al_methlab:client:updateUpgradeMenu', src)
        end
    else
        local itemarray = {}
        for i, item in ipairs(missingItems) do
            local itemData = exports.ox_inventory:GetItem(src, item[1], nil, false).label
            local itemString = string.format("%sx %s", item[2], itemData)
            table.insert(itemarray, itemString)
        end
        local joinedItems = table.concat(itemarray, ", ")
        local notification = Locales[Config.Locale]['MissingResources']..joinedItems
        Config.Notification(src, Config.Noti.error, notification)
    end
end)

--Finished, only needs raid integration
RegisterNetEvent('unr3al_methlab:server:upgradeSecurity', function(methlabId, netId)
	local entity = NetworkGetEntityFromNetworkId(netId)
	local src = source
	if not DoesEntityExist(entity) or currentlab[src] == nil then
        Unr3al.Logging('info', 'Player '..getPlayerName(src)..' tried to upgrade security of Lab '..methlabId..' without perms')
        return
    end

    local securityLevel = MySQL.single.await('SELECT `security` FROM `unr3al_methlab` WHERE `id` = ?', {methlabId}).security
    if securityLevel == #Config.Upgrades.Security then return end

    local canBuy = true
    local missingItems = {}
    for itenName, itemCount in pairs(Config.Upgrades.Security[securityLevel+1].Price) do
        local item = exports.ox_inventory:GetItemCount(src, itenName, false, false)
        if item < itemCount then
            canBuy = false
            table.insert(missingItems, {itenName, itemCount - item})
        end
    end

    if canBuy then
        for itemName, itemCount in pairs(Config.Upgrades.Security[securityLevel+1].Price) do
            exports.ox_inventory:RemoveItem(src, itemName, itemCount, false, false, true)
        end
        local updateOwner = MySQL.update.await('UPDATE unr3al_methlab SET security = ? WHERE id = ?', {
            securityLevel+1, methlabId
        })
        if updateOwner == 1 then
            Config.Notification(src, Config.Noti.success, Locales[Config.Locale]['UpgradedSecurity'])
            TriggerClientEvent('unr3al_methlab:client:updateUpgradeMenu', src)
        end
    else
        local itemarray = {}
        for i, item in ipairs(missingItems) do
            local itemData = exports.ox_inventory:GetItem(src, item[1], nil, false).label
            local itemString = string.format("%sx %s", item[2], itemData)
            table.insert(itemarray, itemString)
        end
        local joinedItems = table.concat(itemarray, ", ")
        local notification = Locales[Config.Locale]['MissingResources']..joinedItems
        Config.Notification(src, Config.Noti.error, notification)
    end
end)

--Finished
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
    local labId = methlabId
    if currentlab[src] ~= nil then
        labId = currentlab[src]
    end
    local isOwner = MySQL.single.await('SELECT owner FROM unr3al_methlab WHERE id = ?', {methlabId}).owner
    local possibleOwner, possibleOwner2 = nil, nil
    if Config.Framework == 'ESX' then
        possibleOwner = xPlayer.getJob().name
        possibleOwner2 = xPlayer.getIdentifier()
    elseif Config.Framework == 'qb' then
        possibleOwner = xPlayer.PlayerData.job.name
        possibleOwner2 = xPlayer.Functions.GetIdentifier
    end


    if isOwner == possibleOwner or isOwner == possibleOwner2 then
        local response = MySQL.single.await('SELECT locked FROM unr3al_methlab WHERE id = ?', {methlabId}).locked
        local newlocked = 1
        if response == 1 then
            newlocked = 0
            Config.Notification(src, Config.Noti.success, Locales[Config.Locale]['UnlockedLab'])

        else
            Config.Notification(src, Config.Noti.success, Locales[Config.Locale]['LockedLab'])
        end
        local updateOwner = MySQL.update.await('UPDATE unr3al_methlab SET locked = ? WHERE id = ?', {
            newlocked, labId
        })
    else
        Config.Notification(src, Config.Noti.error, Locales[Config.Locale]['CantLockLab'])

    end
end)

RegisterNetEvent('unr3al_methlab:server:raidlab', function(methlabId, netId)
	local entity = NetworkGetEntityFromNetworkId(netId)
	local src = source
	if not DoesEntityExist(entity) or currentlab[src] ~= nil then
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

    local secLevel = MySQL.single.await('SELECT security FROM unr3al_methlab WHERE id = @methlabId', {
        ['@methlabId'] = methlabId
    }).security
    local canRaidLab = canRaidLabOwner(methlabId, secLevel)
    if not canRaidLab then
        return
    end

    local canBuy = true
    local missingItems = {}
    for itenName, itemData in pairs(Config.Upgrades.Security[secLevel].RaidGear) do
        local item = exports.ox_inventory:GetItemCount(src, itenName, false, false)
        if item < itemData.Amount then
            canBuy = false
            table.insert(missingItems, {itenName, itemData.Amount - item})
        end
    end
    NotifyPeople(methlabId)
    if canBuy then
        for itemName, itemData in pairs(Config.Upgrades.Security[1].RaidGear) do
            if Config.Upgrades.Security[1].RaidGear[itemName].Remove then
                exports.ox_inventory:RemoveItem(src, itemName, itemData.Amount, false, false, true)
            end
        end
        local coords = Config.Methlabs[methlabId].Purchase.RaidCoords
        SetEntityCoords(entity, coords.x, coords.y, coords.z, true, false, false, false)
        SetEntityHeading(entity, coords.w)
        FreezeEntityPosition(entity, true)
        local animationReturn = lib.callback.await('unr3al_methlab:client:startRaidAnima', src, netId, Config.Upgrades.Security[secLevel].Time, coords)
        FreezeEntityPosition(entity, false)
        if animationReturn == true then
            local updateOwner = MySQL.update.await('UPDATE unr3al_methlab SET locked = 0 WHERE id = @methlabId', {['@methlabId'] = methlabId})
            Config.Notification(src, Config.Noti.success, Locales[Config.Locale]['SuccessfullyRaided'])
            lib.logger(getPlayerIdentifier(src), 'Raided methlab id: '..methlabId, 'Time of complete: '..os.time)
        else
            Config.Notification(src, Config.Noti.error, Locales[Config.Locale]['FailedRaid'])
        end
        Wait(Config.RaidCooldown)
        currentLabRaid[methlabId] = nil
    else
        local itemarray = {}
        for i, item in ipairs(missingItems) do
            local itemData = exports.ox_inventory:GetItem(src, item[1], nil, false).label
            local itemString = string.format("%sx %s", item[2], itemData)
            table.insert(itemarray, itemString)
        end
        local joinedItems = table.concat(itemarray, ", ")
        local notification = Locales[Config.Locale]['MissingResources']..joinedItems
        Config.Notification(src, Config.Noti.error, notification)
        currentLabRaid[methlabId] = nil
    end
end)

--Finished
RegisterNetEvent('unr3al_methlab:server:startprod', function(netId)
	local entity = NetworkGetEntityFromNetworkId(netId)
	local src = source
	if not DoesEntityExist(entity) or currentlab[src] == nil or currentMethProduction[currentlab[src]] ~= nil then return end

    
    local lab = currentlab[src]
    local recipe = Config.Methlabs[lab].Recipes
    currentMethProduction[lab] = true

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
            local itemarray = {}
            for i, item in ipairs(missingItems) do
                local itemData = exports.ox_inventory:GetItem(src, item[1], nil, false).label
                local itemString = string.format("%sx %s", item[2], itemData)
                table.insert(itemarray, itemString)
            end
            local joinedItems = table.concat(itemarray, ", ")
            local notification = Locales[Config.Locale]['MissingResources']..joinedItems
            Config.Notification(src, Config.Noti.error, notification)
        end
    end
    currentMethProduction[currentlab[src]] = nil
end)

RegisterNetEvent('unr3al_methlab:server:startSlurryRefinery', function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
	local src = source
	if not DoesEntityExist(entity) or currentlab[src] == nil or currentSlurryProduction[currentlab[src]] ~= nil then return end

    currentSlurryProduction[currentlab[src]] = true
    local recipe = Config.Methlabs[currentlab[src]].Recipes
    local input = lib.callback.await('unr3al_methlab:client:getSlurryType', src, netId, recipe)
    if not input then
        currentSlurryProduction[currentlab[src]] = nil
        return
    end
    local canBuy = true
    local missingItems = {}

    for itemName, itemCount in pairs(Config.Refinery[recipe][input].Ingredients) do
        local hasEnoughAlready = false
        local item = exports.ox_inventory:GetItemCount(src, itemName, false, false)
        if item >= 1 then
            local item = exports.ox_inventory:GetSlotsWithItem(source, itemName, nil, false)
            local chemcount = 0
            for i, itemData in ipairs(item) do
                if not hasEnoughAlready then
                    local chemicalName = itemData.metadata['chemicalname']
                    print(chemicalName)
                    local chemicalLevel = itemData.metadata['chemicalfill']
                    print(chemicalLevel)
                    --local itemString = itemName:lower():gsub("^%l", string.upper)
                    if chemicalName == 'Methslurry' then
                        print("Opfer")
                        if (chemicalLevel - itemCount) >= 0 then
                            print('Opfer 2')
                            canBuy, hasEnoughAlready, chemcount = true, true, chemicalLevel
                        else
                            print('Opfer 3')
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
        local itemarray = {}
        for i, item in ipairs(missingItems) do
            local itemData = exports.ox_inventory:GetItem(src, item[1], nil, false).label
            local itemString = string.format("%sx %s", item[2], itemData)
            table.insert(itemarray, itemString)
        end
        local joinedItems = table.concat(itemarray, ", ")
        local notification = Locales[Config.Locale]['MissingResources']..joinedItems
        Config.Notification(src, Config.Noti.error, notification)
    end
    currentSlurryProduction[currentlab[src]] = nil
end)


lib.addCommand('setlab', {
    help = 'Sets you in a specific lab',
    params = {
        {
            name = 'methlabId',
            type = 'number',
            help = 'Target id of the lab',
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    if args.methlabId then
        currentlab[source] = 1
    end
end)

lib.addCommand('resetlab', {
    help = 'Resets a lab back to its orgininal state',
    params = {
        {
            name = 'methlabId',
            type = 'number',
            help = 'Target id of the lab',
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    if args.methlabId then
        local updateOwner = MySQL.update.await('UPDATE unr3al_methlab SET locked = 1, security = 1, storage = 1, owned = 0, owner = NULL WHERE id = @methlabId', {['@methlabId'] = args.methlabId})
    end
end)

lib.addCommand('createlab', {
    help = 'Creates a new lab',
    restricted = 'group.admin'
}, function(source, args, raw)
    local src = source
    local data = lib.callback.await('unr3al_methlab:client:getLabCreationstuff', src)
    

end)




AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        local mainTableBuild = MySQL.query.await([[CREATE TABLE IF NOT EXISTS unr3al_methlab (
        `id` int(11) NOT NULL,
        `owned` int(11) NOT NULL DEFAULT 0,
        `owner` varchar(46) DEFAULT NULL,
        `locked` int(11) DEFAULT 1,
        `storage` int(11) NOT NULL DEFAULT 1,
        `security` int(11) NOT NULL DEFAULT 1
        )]])
        if mainTableBuild.warningStatus == 0 then
            Unr3al.Logging('info', 'Database Build for Lab table complete')
        else if mainTableBuild.warningStatus ~= 1 then
            Unr3al.Logging('error', 'Couldnt build Lab table')
        end end
        local response = MySQL.query.await('SELECT * FROM unr3al_methlab')
        for i, methlabId in ipairs(Config.Methlabs) do
            if not response[i] then
                local id = MySQL.insert.await('INSERT INTO unr3al_methlab (id) VALUES (?)', {
                    i
                })
                if id then
                    Unr3al.Logging('debug', 'Inserted data for lab '..i..' into Database')
                else
                    Unr3al.Logging('error', 'Couldnt insert data. Lab: '..i)
                end
            end
            local inventory = exports.ox_inventory:GetInventory('Methlab_Storage_'..i, false)
            if not inventory then
                local methLab = MySQL.single.await('SELECT storage FROM unr3al_methlab WHERE id = ?', {i})
                exports.ox_inventory:RegisterStash('Methlab_Storage_'..i, 'Methlab storage', Config.Upgrades.Storage[methLab.storage].Slots, Config.Upgrades.Storage[methLab.storage].MaxWeight, false)
                Unr3al.Logging('debug', 'Registered stash for lab:'..i)
            end
        end
        local secondaryTableBuild = MySQL.query.await([[CREATE TABLE IF NOT EXISTS unr3al_methlab_people (
        `id` int(11) NOT NULL,
        `identifier` varchar(46) DEFAULT NULL
        )]])
        if secondaryTableBuild.warningStatus == 0 then
            Unr3al.Logging('info', 'Database Build for secondary table complete')
        elseif secondaryTableBuild.warningStatus ~= 1 then
            Unr3al.Logging('error', 'Couldnt build secondary table')
        end

        if Config.Debug then
            local allItems = {}
            for item, data in pairs(exports.ox_inventory:Items()) do
                allItems[item] = data.name
            end
            for labID, labData in pairs(Config.Methlabs) do
                local purchasePrice = labData.Purchase and labData.Purchase.Price or {}
                for itemName in pairs(purchasePrice) do
                    if not lib.table.contains(allItems, itemName) then
                        Unr3al.Logging('error', 'Purchase item (' .. itemName .. ') for lab: ' .. labID .. ' doesn\'t exist!')
                    end
                end
            end

            for recipeType in pairs(Config.Recipes) do
                for recipeName in pairs(Config.Recipes[recipeType]) do
                    for itemName in pairs(Config.Recipes[recipeType][recipeName]) do
                        if itemName ~= 'Ingredients' and itemName ~= 'Meth' then
                            if not lib.table.contains(allItems, itemName) then
                                Unr3al.Logging('error', 'Ingredient item ('..itemName..') for recipe: '..recipeName..' doesnt exist!')
                            end
                        end
                    end
                    local itemexists = lib.table.contains(allItems, Config.Recipes[recipeType][recipeName].Meth.ItemName)
                    if not itemexists then
                        Unr3al.Logging('error', 'Product item ('..Config.Recipes[recipeType][recipeName].Meth.ItemName..') for recipe: '..recipeName..' doesnt exist!')
                    end
                end
            end
            
            for slurryType in pairs(Config.Refinery) do
                for recipeName in pairs(Config.Refinery[slurryType]) do
                    for itemName in pairs(Config.Refinery[slurryType][recipeName].Ingredients) do
                        if not lib.table.contains(allItems, itemName) then
                            Unr3al.Logging('error', 'Ingredient item ('..itemName..') for slurry recipe: '..recipeName..' doesnt exist!')
                        end
                    end
                    local itemexists = lib.table.contains(allItems, Config.Refinery[slurryType][recipeName].Output.ItemName)
                    if not itemexists then
                        Unr3al.Logging('error', 'Product item ('..Config.Refinery[slurryType][recipeName].Output.ItemName..') for slurry recipe: '..recipeName..' doesnt exist!')
                    end
                end
            end

            for upgradeLevel, upgradeData in pairs(Config.Upgrades.Storage) do
                for itemName in pairs(upgradeData.Price) do
                    if not lib.table.contains(allItems, itemName) then
                        Unr3al.Logging('error', 'Purchase item (' .. itemName .. ') for storage upgrade: ' .. upgradeLevel .. ' doesn\'t exist!')
                    end
                end
            end
            for upgradeLevel, upgradeData in pairs(Config.Upgrades.Security) do
                for itemName in pairs(upgradeData.Price) do
                    if not lib.table.contains(allItems, itemName) then
                        Unr3al.Logging('error', 'Purchase item (' .. itemName .. ') for security upgrade: ' .. upgradeLevel .. ' doesn\'t exist!')
                    end
                end
            end

        end
        if LoggingService.Discord.Enabled then
            Unr3al.Logging('error', 'Dont use discord as a logging service :D')
        end
    end
end)



-- lib.addCommand('testoutput', {
--     help = 'nono',
--     restricted = 'group.admin',
--     params = {
--         {
--             name = 'count',
--             type = 'number',
--             help = 'Amount of slurry',
--         },
--     },
-- }, function(source, args, raw)
--     local src = source
--     local count = args.count or 3
--     local itemName = Config.Recipes['standard']['Ammonia and sodium'].Meth.ItemName
--     local hasEnoughAlready = false
    
--     local item = exports.ox_inventory:GetSlotsWithItem(source, itemName, nil, false)
--     local chemcount = 0
--     for i, itemData in ipairs(item) do
--         local chemicalLevel = itemData.metadata['chemicalfill'] or 0
--         if not hasEnoughAlready and chemicalLevel < Config.Items[itemName].MaxFillage then
--             local chemicalName = itemData.metadata['chemicalname']
--             local itemString = itemName:lower():gsub("^%l", string.upper)
--             if chemicalName == chemicalName or chemicalName == 'Empty' then
--                 if (chemicalLevel + count - chemcount) <= Config.Items[itemName].MaxFillage then
--                     exports.ox_inventory:RemoveItem(src, itemName, 1, itemData.metadata, itemData.slot, true)
--                     exports.ox_inventory:AddItem(src, itemName, 1, {chemicalname = 'Methslurry', chemicalfill = itemData.metadata.chemicalfill + count - chemcount, weight = itemData.weight+count*Config.Items[itemName].WeightPerFillage, label = itemString}, itemData.slot)
    
--                     hasEnoughAlready, chemcount = true, chemicalLevel + count - chemcount
--                 else
--                     exports.ox_inventory:RemoveItem(src, itemName, 1, itemData.metadata, itemData.slot, true)
--                     exports.ox_inventory:AddItem(src, itemName, 1, {chemicalname = 'Methslurry', chemicalfill = Config.Items[itemName].MaxFillage, weight = Config.Items[itemName].MaxFillage*Config.Items[itemName].WeightPerFillage, label = itemString}, itemData.slot)
--                     chemcount = chemcount + (Config.Items[itemName].MaxFillage - chemicalLevel)
--                 end
--             end
--         end
--     end
--     if chemcount >= count then
--         print('yay enough')
--     else
--         print('nope not enough')
--     end
-- end)



function DiscordLogs(name, title, color, fields)
    local webHook = Config.DiscordLogs.Webhooks[name]
    if webHook ~= 'WEEBHOCKED' then
        local embedData = {{
            ['title'] = title,
            ['color'] = Config.DiscordLogs.Colors[color],
            ['footer'] = {
                ['text'] = "| Unr3al Meth | " .. os.date(),
                ['icon_url'] = "https://cdn.discordapp.com/attachments/1091344078924435456/1091458999020425349/OSaft-Logo.png"
            },
            ['fields'] = fields,
            ['author'] = {
                ['name'] = "Meth Car",
                ['icon_url'] = "https://cdn.discordapp.com/attachments/1091344078924435456/1091458999020425349/OSaft-Logo.png"
            }
        }}
        PerformHttpRequest(webHook, nil, 'POST', json.encode({
            embeds = embedData
        }), {
            ['Content-Type'] = 'application/json'
        })
    end
end
