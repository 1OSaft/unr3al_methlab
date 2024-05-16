---@param src string
---@param missingItems table
function notifyMissingItems(src, missingItems)
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







---@param src string
---@param itemTable table
---@param missingItems table
---@return boolean, table
function canBuyNormal(src, itemTable, missingItems)
    local canBuy = true
    for itenName, itemCount in pairs(itemTable) do
        local item = exports.ox_inventory:GetItemCount(src, itenName, false, false)
        if item < itemCount then
            canBuy = false
            table.insert(missingItems, {itenName, itemCount - item})
        end
    end
    return canBuy, missingItems
end

---@param src string
---@param itemTable table
function removeNormal(src, itemTable)
    local canBuy = true
    for itenName, itemCount in pairs(itemTable) do
        local item = exports.ox_inventory:GetItemCount(src, itenName, false, false)
        if item < itemCount then
            canBuy = false
            table.insert(missingItems, {itenName, itemCount - item})
        end
    end
end

---@param methlabId string | integer
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

---@param methlabId string | integer
---@param secLevel integer
---@return boolean
function canRaidLabOwner(methlabId, secLevel)
    local returnval = false
    
    if database[tostring(methlabId)].Raidable then
        local labOwner = database[tostring(methlabId)].owner

        if labOwner == getPlayerIdentifier(src) then
            local player = ESX.GetPlayerFromIdentifier(labOwner)
            if player ~= nil then
                returnval = true
            else
                Config.Notification(src, Config.Noti.error, Locales[Config.Locale]['CantRaid'])
                returnval = false
            end
        else
            local onlinePlayersJob = #ESX.GetExtendedPlayers('job', labOwner)
            if onlinePlayersJob >= Config.Upgrades.Security[secLevel].NeedOnline then
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