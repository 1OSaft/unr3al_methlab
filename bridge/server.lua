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