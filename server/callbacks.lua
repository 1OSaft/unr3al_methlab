---1 = owned, 0 = unowned
---@param source string
---@param methlabId string
---@return integer
lib.callback.register('unr3al_methlab:server:isLabOwned', function(source, methlabId)
    return database[methlabId].Owned
end)

---comment
---@param source string
---@param methlabId string
---@param netId integer
---@param type integer
lib.callback.register('unr3al_methlab:server:buyLab', function(source, methlabId, netId, type)
    local src, methlabId = source, tostring(methlabId)
	local entity, jobName, playerIdentifier = NetworkGetEntityFromNetworkId(netId), getPlayerJobName(src), getPlayerIdentifier(src)
    local methlabId = getLabPlayerIsIn(playerIdentifier)

	if not DoesEntityExist(entity) or not methlabId or not jobName or not playerIdentifier then return end
    
    local canBuy, missingItems = true, {}

    canBuy, missingItems = canBuyNormal(src, database[methlabId].Purchase.Price, missingItems)

    if canBuy then
        local labCount = 0
        for methlabId, labData in pairs(database) do
            if labData.Owner == jobName or labData.Owner == playerIdentifier then
                labCount = labCount +1
            end
        end
        if labCount < Config.MaxLabs then
            removeNormal(source, database[methlabId].Purchase.Price)

            local newOwner = nil
            if database[methlabId].Purchase.Type == 1 or (database[methlabId].Purchase.Type == 0 and type == 1) then
                newOwner = jobName
            elseif database[methlabId].Purchase.Type == 2 or (database[methlabId].Purchase.Type == 0 and type == 2) then
                newOwner = playerIdentifier
            else
                Config.Notification(src, Config.Noti.error, 'Error, talk to your server owner')
            end
            database[methlabId].Owned = 1
            database[methlabId].Owner = newOwner
            database[methlabId].Upgrades = {
                Storage = 1,
                Security = 1
            }
            database[methlabId].Locked = 0

            saveDatabase(database)
            Config.Notification(src, Config.Noti.success, Locales[Config.Locale]['BoughtLab'])
            TriggerEvent('unr3al_methlab:server:enter', methlabId, netId, src)
            lib.logger(playerIdentifier, 'Bought methlab id: '..methlabId, 'Bought for: '..newOwner)

        else
            Config.Notification(src, Config.Noti.error, Locales[Config.Locale]['ToMuchLabsBought'])
        end
    else
        notifyMissingItems(src, missingItems)
    end
end)

---@param source string
---@param netId integer
---@return integer | nil
lib.callback.register('unr3al_methlab:server:getStorage', function(source, netId)
    local src, entity = source, NetworkGetEntityFromNetworkId(netId)
    local currentlab = tostring(getLabPlayerIsIn(getPlayerIdentifier(src)))

	if not DoesEntityExist(entity) or not currentlab then return end
    return database[currentlab].Upgrades.Storage
end)

---@param source string
---@param netId integer
---@return integer | nil
lib.callback.register('unr3al_methlab:server:getSecurity', function(source, netId)
    local src, entity = source, NetworkGetEntityFromNetworkId(netId)
    local currentlab = tostring(getLabPlayerIsIn(getPlayerIdentifier(src)))
	if not DoesEntityExist(entity) or not currentlab then return end
    return database[currentlab].Upgrades.Security
end)

lib.callback.register('unr3al_methlab:server:getConfig', function(source)
    return Config, Locales
end)

---@param source string
---@return table
lib.callback.register('unr3al_methlab:server:getDatabase', function(source)
    return database
end)