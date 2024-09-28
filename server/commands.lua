<<<<<<< Updated upstream
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
        setLabPlayerIsIn(qtm.Framework.GetIdentifier(src), tostring(args.methlabId))
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

lib.addCommand('methlab:create', {
    help = 'Creates a new lab',
    restricted = 'group.admin'
}, function(source, args, raw)
    local src = source
    local data = lib.callback.await('unr3al_methlab:client:getLabCreationstuff', src)
    if data then
        local routingBucket = genRoutingBucket()
        local labidstring = "lab_"..tostring(genRoutingBucket())
    
        --[[
            data 1 entry        F
            data 2 owner type   F
            data 3 raidable     F
            data 4 raidcoords   F
            data 5 recipe       F
            data 6 price        F
            data 7 garage

        ]]

        database[labidstring] = {
            Coords = {
                x = data[1].x,
                y = data[1].y,
                z = data[1].z,
                r = data[1].w
            },
            Purchase = {
                Type = data[2],
                Price = data[6]
            },
            Raidable = data[3],
            RaidCoords = {
                x = data[4].x,
                y = data[4].y,
                z = data[4].z,
                r = data[4].w,
            },
            Recipes = data[5],
            GarageCoords = {
                x = data[7].x,
                y = data[7].y,
                z = data[7].z,
                r = data[7].w,
            },
            Upgrades = {
                Storage = 1,
                Security = 1
            },
            Owner = nil,
            Owned = 0,
            Locked = 1,
            routingBucket = routingBucket
        }
        saveDatabase(database)
        qtm.Notification(src, locale('NotifyTitle'), 'success', 'Successfully created a new lab, please restart the script')
        TriggerClientEvent('unr3al_methlab:client:refreshEnterMarker', -1)
    else
        qtm.Notification(src, locale('NotifyTitle'), 'error', 'Error, couldnt generate a new lab')
    end
end)

lib.addCommand('methlab:edit', {
    help = 'Resets a lab back to its orgininal state',
    restricted = 'group.admin'
}, function(source, args, raw)
    local src = source
    local data = lib.callback.await('unr3al_methlab:client:getLabMenustuff', src, database)
    if data then
        
    end
=======
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
        setLabPlayerIsIn(qtm.Framework.GetIdentifier(src), tostring(args.methlabId))
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

lib.addCommand('methlab:create', {
    help = 'Creates a new lab',
    restricted = 'group.admin'
}, function(source, args, raw)
    local src = source
    local data = lib.callback.await('unr3al_methlab:client:getLabCreationstuff', src)
    if data then
        local routingBucket = genRoutingBucket()
        local labidstring = "lab_"..tostring(genRoutingBucket())
    
        --[[
            data 1 entry        F
            data 2 owner type   F
            data 3 raidable     F
            data 4 raidcoords   F
            data 5 recipe       F
            data 6 price        F
            data 7 garage

        ]]

        database[labidstring] = {
            Coords = {
                x = data[1].x,
                y = data[1].y,
                z = data[1].z,
                r = data[1].w
            },
            Purchase = {
                Type = data[2],
                Price = data[6]
            },
            Raidable = data[3],
            RaidCoords = {
                x = data[4].x,
                y = data[4].y,
                z = data[4].z,
                r = data[4].w,
            },
            Recipes = data[5],
            GarageCoords = {
                x = data[7].x,
                y = data[7].y,
                z = data[7].z,
                r = data[7].w,
            },
            Upgrades = {
                Storage = 1,
                Security = 1
            },
            Owner = nil,
            Owned = 0,
            Locked = 1,
            routingBucket = routingBucket
        }
        saveDatabase(database)
        qtm.Notification(src, locale('NotifyTitle'), 'success', 'Successfully created a new lab, please restart the script')
        TriggerClientEvent('unr3al_methlab:client:refreshEnterMarker', -1)
    else
        qtm.Notification(src, locale('NotifyTitle'), 'error', 'Error, couldnt generate a new lab')
    end
end)

lib.addCommand('methlab:edit', {
    help = 'Edit a methlab',
    restricted = 'group.admin'
}, function(source, args, raw)
    local src = source
    local methlabId, data = lib.callback.await('unr3al_methlab:client:getLabMenustuff', src, database)
    if methlabId and data then
        database[methlabId].Coords = {
            x = data[1].x,
            y = data[1].y,
            z = data[1].z,
            r = data[1].w
        }
        database[methlabId].Purchase = {
            Type = data[2],
            Price = data[6]
        }
        database[methlabId].Raidable = data[3]
        database[methlabId].RaidCoords = {
            x = data[4].x,
            y = data[4].y,
            z = data[4].z,
            r = data[4].w,
        }
        database[methlabId].Recipes = data[5]
        database[methlabId].GarageCoords = {
            x = data[7].x,
            y = data[7].y,
            z = data[7].z,
            r = data[7].w,
        }
        saveDatabase(database)
    end
>>>>>>> Stashed changes
end)