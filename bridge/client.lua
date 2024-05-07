if Config.Framework == 'qb' then
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        TriggerServerEvent('unr3al_methlab:server:toggleLoaded', true)
    end)
    RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
        TriggerServerEvent('unr3al_methlab:server:toggleLoaded', false)
    end)
end