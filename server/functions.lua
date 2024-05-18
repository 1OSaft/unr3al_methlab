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
    for itemName, itemCount in pairs(itemTable) do
        exports.ox_inventory:RemoveItem(src, itemName, itemCount, false, false, true)
    end
end

---@param methlabId string | integer
function NotifyPeople(methlabId)
    local methlabId = tostring(methlabId)
    local ownerType, owner = database[methlabId].Purchase.Type, database[methlabId].Owner

    if Config.Framework == 'ESX' then
        if ownerType == 2 or 0 then
            local onlinePlayersJob = ESX.GetExtendedPlayers('job', owner)
            for _, player in pairs(onlinePlayersJob) do
                Config.Notification(player.source, Config.Noti.warning, "RAID!")
                TriggerClientEvent('unr3al_methlab:client:raidBlip', player.source, methlabId)
            end
        else
            local player = ESX.GetPlayerFromIdentifier(owner)
            Config.Notification(player.source, Config.Noti.warning, "RAID!")
            TriggerClientEvent('unr3al_methlab:client:raidBlip', player.source, methlabId)
        end
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


---@param inSplitPattern string
---@param outResults string
---@return table
function string:splitToNumbers(inSplitPattern, outResults)
    if not outResults then
        outResults = { }
    end
    local theStart = 1
    local theSplitStart, theSplitEnd = string.find(self, inSplitPattern, theStart)
    while theSplitStart do
        local part = string.sub(self, theStart, theSplitStart-1)
        table.insert(outResults, tonumber(part))
        theStart = theSplitEnd + 1
        theSplitStart, theSplitEnd = string.find(self, inSplitPattern, theStart)
    end
    table.insert(outResults, tonumber(string.sub(self, theStart)))
    return outResults
end

---@param inSplitPattern string
---@param outResults string
---@return table
function string:split( inSplitPattern, outResults )
    if not outResults then
      outResults = { }
    end
    local theStart = 1
    local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
    while theSplitStart do
      table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
      theStart = theSplitEnd + 1
      theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
    end
    table.insert( outResults, string.sub( self, theStart ) )
    return outResults
end