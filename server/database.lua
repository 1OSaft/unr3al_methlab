local datastring = LoadResourceFile(GetCurrentResourceName(), "database.json")
database = json.decode(datastring)
local optionstring = LoadResourceFile(GetCurrentResourceName(), "options.json")
options = json.decode(optionstring)

---@return integer
genRoutingBucket = function()
    local routingBucket = math.random(0, 99999999)
    for _, labData in pairs(database) do
        if routingBucket == labData.routingBucket then
            return genRoutingBucket()
        end
    end
    return routingBucket
end

---@param data table
saveDatabase = function(data)
    SaveResourceFile(GetCurrentResourceName(), "database.json", json.encode(data, { indent = true }), -1)
end
---@param data table
saveOptions = function(data)
    SaveResourceFile(GetCurrentResourceName(), "options.json", json.encode(data, { indent = true }), -1)
end

---@param identifier string
---@param labId string | nil
---@return string | boolean
getLabPlayerIsIn = function(identifier, labId)
    if labId then
        if database[labId].PeopleInLab then
            if lib.table.contains(database[labId].PeopleInLab, identifier) then
                return labId
            end
        end
    else
        for labId, labData in pairs(database) do
            if labData.PeopleInLab then
                if lib.table.contains(labData.PeopleInLab, identifier) then
                    return labId
                end
            end
        end
    end

    return false
end

---@param identifier string
---@param labId string
setLabPlayerIsIn = function(identifier, labId)
    if not database[labId].PeopleInLab then
        database[labId].PeopleInLab = {}
    end
    local labTable = database[labId].PeopleInLab
    table.insert(labTable, identifier)
    database[labId].PeopleInLab = labTable
    saveDatabase(database)
end

---@param identifier string
---@param labId string
removeLabPlayerIsIn = function(identifier, labId)
    if not database[labId].PeopleInLab then
        database[labId].PeopleInLab = {}
        return
    end
    local labTable = database[labId].PeopleInLab
    for i, data in ipairs(labTable) do
        if identifier == data then
            table.remove(labTable, i)
        end
    end
    database[labId].PeopleInLab = labTable
    saveDatabase(database)
end

lib.addCommand('convertlab', {
    help = 'Converts old sql database into json',

    restricted = 'group.admin'
    }, function(source, args, raw)
    if source ~= 0 then
        print("Run the command in your txadmin console")
        return
    end
    if not Config.Methlabs then
       print("Already converted methlabs")
       return
    end
    print("Starting convertion...")
    Wait(1000)
    local response = MySQL.query.await('SELECT * FROM unr3al_methlab')
    for labid, labData in pairs(response) do
        local labidstring = tostring(labid)
        if not database[labidstring] then
            database[labidstring] = {}
        end
        local coords = Config.Methlabs[labid].Coords
        local raidcoords = Config.Methlabs[labid].Purchase.RaidCoords
        local ownerType = nil
        if Config.Methlabs[labid].Purchase.Type == 'both' then
            ownerType = 0
        elseif Config.Methlabs[labid].Purchase.Type == 'player' then
            ownerType = 1
        else
            ownerType = 2
        end
        database[labidstring] = {
            Coords = {
                x = coords.x,
                y = coords.y,
                z = coords.z,
                r = Config.Methlabs[labid].HeadingPed
            },
            Raidable = Config.Methlabs[labid].Purchase.Raidable,
            RaidCoords = {
                x = raidcoords.x,
                y = raidcoords.y,
                z = raidcoords.z,
                r = raidcoords.w,
            },
            Purchase = {
                Type = ownerType,
                Price = Config.Methlabs[labid].Purchase.Price
            },
            Upgrades = {
                Storage = labData.storage,
                Security = labData.security
            },

            Owner = labData.owner or nil,
            Owned = labData.owned or 0,
            Locked = labData.locked or 1,
            routingBucket = genRoutingBucket(),
            Recipes = Config.Methlabs[labid].Recipes,
            PeopleInLab = {}
        }
        saveDatabase(database)

        MySQL.query.await('DELETE FROM unr3al_methlab WHERE id = @id', {
            ['@id'] = labid
        })
    end

    local response = MySQL.query.await('SELECT * FROM unr3al_methlab_people')
    for id, data in pairs(response) do
        local labId = tostring(data.id)
        if not database[labId].PeopleInLab then
            database[labId].PeopleInLab = {}
        end
        local datathing = database[labId].PeopleInLab
        table.insert(datathing, data.identifier)
        database[labId].PeopleInLab = datathing
        saveDatabase(database)
    end

    MySQL.query.await('DROP TABLE unr3al_methlab')
    MySQL.query.await('DROP TABLE unr3al_methlab_people')

    print("Convertion completed, delete Config.Methlabs and follow the docs")
end)

-- lib.addCommand('getolddatabase', {
--     help = 'Converts old sql database into json',
--     restricted = 'group.admin'
-- }, function(source, args, raw)
--     local mainTableBuild = MySQL.query.await([[CREATE TABLE IF NOT EXISTS unr3al_methlab (
--         `id` int(11) NOT NULL,
--         `owned` int(11) NOT NULL DEFAULT 0,
--         `owner` varchar(46) DEFAULT NULL,
--         `locked` int(11) DEFAULT 1,
--         `storage` int(11) NOT NULL DEFAULT 1,
--         `security` int(11) NOT NULL DEFAULT 1
--         )]])
--         if mainTableBuild.warningStatus == 0 then
--             Unr3al.Logging('info', 'Database Build for Lab table complete')
--         else if mainTableBuild.warningStatus ~= 1 then
--             Unr3al.Logging('error', 'Couldnt build Lab table')
--         end end
--         local response = MySQL.query.await('SELECT * FROM unr3al_methlab')
--         for i, methlabId in ipairs(Config.Methlabs) do
--             if not response[i] then
--                 local id = MySQL.insert.await('INSERT INTO unr3al_methlab (id) VALUES (?)', {
--                     i
--                 })
--                 if id then
--                     Unr3al.Logging('debug', 'Inserted data for lab '..i..' into Database')
--                 else
--                     Unr3al.Logging('error', 'Couldnt insert data. Lab: '..i)
--                 end
--             end
--             local inventory = exports.ox_inventory:GetInventory('Methlab_Storage_'..i, false)
--             if not inventory then
--                 local methLab = MySQL.single.await('SELECT storage FROM unr3al_methlab WHERE id = ?', {i})
--                 exports.ox_inventory:RegisterStash('Methlab_Storage_'..i, 'Methlab storage', Config.Upgrades.Storage[methLab.storage].Slots, Config.Upgrades.Storage[methLab.storage].MaxWeight, false)
--                 Unr3al.Logging('debug', 'Registered stash for lab:'..i)
--             end
--         end
--         local secondaryTableBuild = MySQL.query.await([[CREATE TABLE IF NOT EXISTS unr3al_methlab_people (
--         `id` int(11) NOT NULL,
--         `identifier` varchar(46) DEFAULT NULL
--         )]])
--         if secondaryTableBuild.warningStatus == 0 then
--             Unr3al.Logging('info', 'Database Build for secondary table complete')
--         elseif secondaryTableBuild.warningStatus ~= 1 then
--             Unr3al.Logging('error', 'Couldnt build secondary table')
--         end
-- end)