lib.callback.register('unr3al_methlab:server:isLabOwned', function(source, methlabId)
    print("currentlab: "..methlabId)
    local returnval = 0
    local response = MySQL.single.await('SELECT `owned` FROM `unr3al_methlab` WHERE `id` = ?', {methlabId})
    if response then
        if response.owned == 1 then
            returnval = 1
        end
        print("Owned: "..response.owned)
    end
    return returnval
end)

lib.callback.register('unr3al_methlab:server:buyLab', function(source, methlabId, netId)
	local entity = NetworkGetEntityFromNetworkId(netId)
	local src = source
	if not DoesEntityExist(entity) or currentlab[src] ~= nil then return end
    
    local canBuy = true
    for itenName, itemCount in pairs(Config.Methlabs[methlabId].Purchase.Price) do
        if canBuy then
            local item = exports.ox_inventory:GetItemCount(src, itenName, false, false)
            if item < itemCount then
                canBuy = false
            end
        end
    end
    local owner = ESX.GetPlayerFromId(src).getJob().name
    local owner2 = ESX.GetPlayerFromId(src).getIdentifier()
    local response = MySQL.query.await('SELECT COUNT(id) FROM unr3al_methlab WHERE owner = ? OR owner = ?', {owner, owner2})
    print(response[1]["COUNT(id)"])
    if response[1]["COUNT(id)"] < Config.MaxLabs and canBuy then
        for itemName, itemCount in pairs(Config.Methlabs[methlabId].Purchase.Price) do
            exports.ox_inventory:RemoveItem(src, itemName, itemCount, false, false, true)
        end
        local newOwner
        if Config.Methlabs[methlabId].Purchase.Type == 'society' then
            newOwner = ESX.GetPlayerFromId(src).getJob().name
        else
            newOwner = ESX.GetPlayerFromId(src).getIdentifier()
        end
        local updateOwner = MySQL.update.await('UPDATE unr3al_methlab SET owned = 1, locked = 0, owner = ? WHERE id = ?', {
            newOwner, methlabId
        })
        if updateOwner == 1 then
            TriggerClientEvent('unr3al_methlab:client:notify', src, Config.Noti.success, Strings.BoughtLab)
            TriggerEvent('unr3al_methlab:server:enter', methlabId, netId, src)
        end
    else
        TriggerClientEvent('unr3al_methlab:client:notify', src, Config.Noti.error, Strings.CantBuy)
    end
end)

lib.callback.register('unr3al_methlab:server:canBuyAnotherLab', function(source)
    local src = source
    local owner = ESX.GetPlayerFromId(src).getJob().name
    local owner2 = ESX.GetPlayerFromId(src).getIdentifier()
    local response = MySQL.query.await('SELECT COUNT(id) FROM unr3al_methlab WHERE owner = ? OR owner = ?', {owner, owner2})
    print(response[1]["COUNT(id)"])
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