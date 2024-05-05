lib.callback.register('unr3al_methlab:server:isLabOwned', function(source, methlabId)
    local returnval = 0
    local response = MySQL.single.await('SELECT `owned` FROM `unr3al_methlab` WHERE `id` = ?', {methlabId})
    if response then
        if response.owned == 1 then
            returnval = 1
        end
    end
    return returnval
end)

function canRaidLabOwner(methlabId, secLevel)
    local returnval = false
    
    if Config.Methlabs[methlabId].Purchase.Raidable then
        local response = MySQL.single.await('SELECT `owner` FROM `unr3al_methlab` WHERE `id` = ?', {methlabId}).owner
        if Config.Methlabs[methlabId].Purchase.Type == 'society' then
            local onlinePlayersJob = #ESX.GetExtendedPlayers('job', response)
            if onlinePlayersJob >= Config.Upgrades.Security[secLevel].NeedOnline then
                returnval = true
            else
                Config.Notification(src, Config.Noti.error, Locales[Config.Locale]['CantRaid'])
                returnval = false
            end
        else
            local player = ESX.GetPlayerFromIdentifier(response)
            if player ~= nil then
                returnval = true
            else
                Config.Notification(src, Config.Noti.error, Locales[Config.Locale]['CantRaid'])
                returnval = false
            end
        end
    else
        Config.Notification(src, Config.Noti.error, Locales[Config.Locale]['CantRaid'])
        returnval = false
    end
    return returnval
end

function NotifyPeople(methlabId)
    local response = MySQL.single.await('SELECT `owner` FROM `unr3al_methlab` WHERE `id` = ?', {methlabId}).owner
    if Config.Methlabs[methlabId].Purchase.Type == 'society' then
        local onlinePlayersJob = ESX.GetExtendedPlayers('job', response)
        for _, player in pairs(onlinePlayersJob) do
            Config.Notification(player.source, Config.Noti.warning, "RAID!")
            TriggerClientEvent('unr3al_methlab:client:raidBlip', player.source, methlabId)
        end
    else
        local player = ESX.GetPlayerFromIdentifier(response)
        Config.Notification(player.source, Config.Noti.warning, "RAID!")
        TriggerClientEvent('unr3al_methlab:client:raidBlip', player.source, methlabId)
    end
end

lib.callback.register('unr3al_methlab:server:buyLab', function(source, methlabId, netId, type)
	local entity = NetworkGetEntityFromNetworkId(netId)
	local src = source
    local jobName, playerIdentifier = getPlayerJobName(src), getPlayerIdentifier(src)
	if not DoesEntityExist(entity) or currentlab[src] ~= nil or not jobName or not playerIdentifier then return end
    
    local canBuy = true
    local missingItems = {}
    for itenName, itemCount in pairs(Config.Methlabs[methlabId].Purchase.Price) do
        local item = exports.ox_inventory:GetItemCount(src, itenName, false, false)
        if item < itemCount then
            canBuy = false
            table.insert(missingItems, {itenName, itemCount - item})
        end
    end
    if canBuy then
        local response = MySQL.query.await('SELECT COUNT(id) FROM unr3al_methlab WHERE owner = ? OR owner = ?', {jobName, playerIdentifier})
        if response[1]["COUNT(id)"] < Config.MaxLabs then
            for itemName, itemCount in pairs(Config.Methlabs[methlabId].Purchase.Price) do
                exports.ox_inventory:RemoveItem(src, itemName, itemCount, false, false, true)
            end
            local newOwner
            if Config.Methlabs[methlabId].Purchase.Type == 'society' or (Config.Methlabs[methlabId].Purchase.Type == 'both' and type == 2) then
                newOwner = jobName
            elseif Config.Methlabs[methlabId].Purchase.Type == 'player' or (Config.Methlabs[methlabId].Purchase.Type == 'both' and type == 1) then
                newOwner = playerIdentifier
            end
            local updateOwner = MySQL.update.await('UPDATE unr3al_methlab SET owned = 1, locked = 0, owner = ? WHERE id = ?', {
                newOwner, methlabId
            })
            if updateOwner == 1 then
                Config.Notification(src, Config.Noti.success, Locales[Config.Locale]['BoughtLab'])
                TriggerEvent('unr3al_methlab:server:enter', methlabId, netId, src)
                lib.logger(playerIdentifier, 'Bought methlab id: '..methlabId, 'Bought for: '..newOwner)
            end
        else
            Config.Notification(src, Config.Noti.error, Locales[Config.Locale]['ToMuchLabsBought'])
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

lib.callback.register('unr3al_methlab:server:canBuyAnotherLab', function(source)
    local src = source
    local jobName, playerIdentifier = getPlayerJobName(src), getPlayerIdentifier(src)
    local response = MySQL.query.await('SELECT COUNT(id) FROM unr3al_methlab WHERE owner = ? OR owner = ?', {jobName, playerIdentifier})
    if response[1]["COUNT(id)"] < Config.MaxLabs then
        return true
    else
        return false
    end
end)

lib.callback.register('unr3al_methlab:server:getStorage', function(source, netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
	local src = source
	if not DoesEntityExist(entity) or currentlab[src] == nil then return end
    return MySQL.single.await('SELECT `storage` FROM `unr3al_methlab` WHERE `id` = ?', {currentlab[src]}).storage
end)

lib.callback.register('unr3al_methlab:server:getSecurity', function(source, netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
	local src = source
	if not DoesEntityExist(entity) or currentlab[src] == nil then return end
    return MySQL.single.await('SELECT `security` FROM `unr3al_methlab` WHERE `id` = ?', {currentlab[src]}).security
end)

lib.callback.register('unr3al_methlab:server:getConfig', function(source)
    return Config, Locales
end)