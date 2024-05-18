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
        setLabPlayerIsIn(getPlayerIdentifier(src), tostring(args.methlabId))
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
        local methlabId = tostring(args.methlabId)
        database[methlabId].owner = nil
        database[methlabId].owned = 0
        database[methlabId].Upgrades.Storage = 1
        database[methlabId].Upgrades.Security = 1
        database[methlabId].Locked = 1
    end
end)

lib.addCommand('createlab', {
    help = 'Creates a new lab',
    restricted = 'group.admin'
}, function(source, args, raw)
    local src = source
    local data = lib.callback.await('unr3al_methlab:client:getLabCreationstuff', src)

    local routingBucket = genRoutingBucket()
    local labidstring = "lab_"..tostring(genRoutingBucket())

    if not database[labidstring] then
        database[labidstring] = {}
    end

    local labCoords = data[1]:splitToNumbers(", ")
    local labRaidCoords = data[5]:splitToNumbers(", ")

    database[labidstring] = {
        Coords = {
            x = labCoords[1],
            y = labCoords[2],
            z = labCoords[3],
            r = data[2]
        },
        Raidable = data[4],
        RaidCoords = {
            x = labRaidCoords[1],
            y = labRaidCoords[2],
            z = labRaidCoords[3],
            r = labRaidCoords[4],
        },
        Purchase = {
            Type = data[3],
            Price = finaltable
        },
        Upgrades = {
            Storage = 1,
            Security = 1
        },

        Owner = 0,
        Owned = 0,
        Locked = 1,
        routingBucket = routingBucket,
        Recipes = data[7]
    }
    saveDatabase(database)
end)


lib.addCommand('savelabdata', {
    help = 'saves the current database',
    restricted = 'group.admin'
}, function(source, args, raw)
    saveDatabase(database)
end)