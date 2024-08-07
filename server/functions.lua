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
    local notification = locale('MissingResources')..joinedItems
    qtm.Notification(src, locale('NotifyTitle'), 'error', notification)
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

    if not owner then return end

    if qtm.Framework.GetJob.exists(owner) then
        local players = qtm.Framework.GetPlayers()
        for playerID, _ in pairs(players) do
            if qtm.Framework.GetJob(playerID) == owner then
                qtm.Notification(playerID, 'warning', "RAID!")
                TriggerClientEvent('unr3al_methlab:client:raidBlip', playerID, methlabId)
            end
        end
    else
        local player = qtm.Framework.GetIdentifierID(owner)
        qtm.Notification(player, 'warning', "RAID!")
        TriggerClientEvent('unr3al_methlab:client:raidBlip', player, methlabId)
    end
end

---@param methlabId string | integer
---@param secLevel integer
---@return boolean
function canRaidLabOwner(methlabId, secLevel)
    local returnval = false
    
    if database[tostring(methlabId)].Raidable then
        local labOwner = database[tostring(methlabId)].owner
        if qtm.Framework.GetJob.exists(labOwner) then
            if qtm.Framework.GetJobOnlineMembers(labOwner) >= Config.Upgrades.Security[secLevel].NeedOnline then
                returnval = true
            else
                qtm.Notification(src, locale('NotifyTitle'), 'error', locale('CantRaid'))
            end
        else
            if not qtm.Framework.GetIdentifierID(labOwner) then
                qtm.Notification(src, locale('NotifyTitle'), 'error', locale('CantRaid'))
            else
                returnval = true
            end
        end
    else
        qtm.Notification(src, locale('NotifyTitle'), 'error', locale('CantRaid'))
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