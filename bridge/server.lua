if Config.Framework == 'ESX' then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
end

function player(src)
    if Config.Framework == 'ESX' then
        return ESX.GetPlayerFromId(src)
    elseif Config.Framework == 'qb' then
        return QBCore.Functions.GetPlayer(src)
    end
end

function getPlayerName(src)
    if Config.Framework == 'ESX' then
        return ESX.GetPlayerFromId(src).getName()
    elseif Config.Framework == 'qb' then
        return QBCore.Functions.GetPlayer(src).PlayerData.name
    end
end

function getPlayerIdentifier(src)
    if Config.Framework == 'ESX' then
        return ESX.GetPlayerFromId(src).getIdentifier()
    elseif Config.Framework == 'qb' then
        return QBCore.Functions.GetPlayer(src).Functions.GetIdentifier
    end
end

function getPlayerJobName(src)
    if Config.Framework == 'ESX' then
        return ESX.GetPlayerFromId(src).getJob().name
    elseif Config.Framework == 'qb' then
        return QBCore.Functions.GetPlayer(src).PlayerData.job.name
    end
end


RegisterNetEvent('unr3al_methlab:server:toggleLoaded', function(source, connect)
	local src = source
    if connect and not currentlab[src] then
        local response = MySQL.single.await('SELECT id FROM unr3al_methlab_people WHERE identifier = @identifier', {
            ['@identifier'] = getPlayerIdentifier(src)
        })
        if response ~= nil then
            currentlab[src] = response.id
            MySQL.query.await('DELETE FROM unr3al_methlab_people WHERE identifier = @identifier', {
                ['@identifier'] = getPlayerIdentifier(src)
            })
            print('Connected')
        end
    end
    if not connect and currentlab[src] ~= nil then
        local id = MySQL.insert.await('INSERT INTO unr3al_methlab_people (id, identifier) VALUES (?, ?)', {
            currentlab[src], getPlayerIdentifier(src),
        })
        currentlab[src] = nil
        print('Disconnected')
    end
end)

if Config.Framework == 'ESX' then
    --Finished
    AddEventHandler('esx:playerLoaded',function(source, xPlayer, isNew)
        local src = source
        print(cache.ped)
        if xPlayer and not isNew then
            TriggerEvent('unr3al_methlab:server:toggleLoaded', src, true)
        end
    end)

    --Finished
    RegisterNetEvent('esx:playerDropped', function(playerId, reason)
        local src = playerId
        if currentlab[src] ~= nil then
            TriggerEvent('unr3al_methlab:server:toggleLoaded', src, false)
        end
    end)
end