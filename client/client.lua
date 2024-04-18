Config, Locales = {}, {}

CreateThread(function()
    TriggerEvent('unr3al_methlab:client:getConfig')
end)

RegisterNetEvent('unr3al_methlab:client:getConfig', function()
    Config, Locales = lib.callback.await('unr3al_methlab:server:getConfig', false)
end)

--------------------------------------------------------------------------------------------------------------

currentLab = nil
local cam = nil
local objects = {}

lib.callback.register('unr3al_methlab:client:startAnimation', function(netId)
	local entity = NetworkGetEntityFromNetworkId(netId)
	if not DoesEntityExist(entity) then return end
    TriggerEvent('ox_inventory:disarm', GetPlayerServerId(cache.ped), true)
    local ped = PlayerPedId()
    SetEntityCoords(ped, 1005.773, -3200.402, -38.524, 0, 0, 0, 0)

    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 1008.0, -3199.0, -36.5, -20.0, 0.0, 120.0, 70.0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 1000, true, true)

    local anim = 'anim@amb@business@meth@meth_monitoring_cooking@cooking@'

    lib.requestAnimDict(anim)
    lib.requestModel(`bkr_prop_meth_sacid`)
    lib.requestModel(`bkr_prop_meth_ammonia`)
    lib.requestModel(`bkr_prop_fakeid_clipboard_01a`)
    lib.requestModel(`prop_pencil_01`)

    local targetPosition = GetEntityCoords(ped)
    
    local sacid = CreateObject(`bkr_prop_meth_sacid`, targetPosition.x, targetPosition.y, targetPosition.z, 0, 0, 0)
    objects[1] = sacid

    local ammonia = CreateObject(`bkr_prop_meth_ammonia`, targetPosition.x, targetPosition.y, targetPosition.z, 0, 0, 0)
    objects[2] = ammonia

    local clipboard = CreateObject(`bkr_prop_fakeid_clipboard_01a`, targetPosition.x, targetPosition.y, targetPosition.z, 0, 0, 0)
    objects[3] = clipboard

    local pencil = CreateObject(`prop_pencil_01`, targetPosition.x, targetPosition.y, targetPosition.z, 0, 0, 0)
    objects[4] = pencil

    local scenePos, sceneRot = vector3(1010.656, -3198.445, -38.925), vector3(0.0, 0.0, 0.0) -- 353200l
    local scene = CreateSynchronizedScene(scenePos.x, scenePos.y, scenePos.z, sceneRot.x, sceneRot.y, sceneRot.z, 2)
    TaskSynchronizedScene(PlayerPedId(), scene, anim, 'chemical_pour_long_cooker', 1.5, -4.0, 1, 16, 1148846080, 0)
    PlaySynchronizedEntityAnim(sacid, scene, 'chemical_pour_long_sacid', anim, 4.0, -8.0, 1, 1148846080)
    PlaySynchronizedEntityAnim(ammonia, scene, 'chemical_pour_long_ammonia', anim, 4.0, -8.0, 1, 1148846080)
    PlaySynchronizedEntityAnim(clipboard, scene, 'chemical_pour_long_clipboard', anim, 4.0, -8.0, 1, 1148846080)
    PlaySynchronizedEntityAnim(pencil, scene, 'chemical_pour_long_pencil', anim, 4.0, -8.0, 1, 1148846080)
    
    if lib.progressBar({
        duration = 150000,
        label = Locales[Config.Locale]['ChemicalPouringProgress'],
        useWhileDead = false,
        allowRagdoll = false,
        allowCuffed = false,
        allowFalling = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
            mouse = true
        }
    }) then
        for i=1, #objects do
            DeleteObject(objects[i])
        end
        objects = {}
        DetachSynchronizedScene(scene)
        ClearPedTasksImmediately(PlayerPedId())
        RenderScriptCams(false, true, 0, true, false)
        DestroyCam(cam, false)
        cam = nil
        return true
    else
        for i=1, #objects do
            DeleteObject(objects[i])
        end
        objects = {}
        DetachSynchronizedScene(scene)
        ClearPedTasksImmediately(PlayerPedId())
        RenderScriptCams(false, true, 0, true, false)
        DestroyCam(cam, false)
        cam = nil
        return false
    end
end)

lib.callback.register('unr3al_methlab:client:getMethType', function(netId, recipe)
    local recipeType = recipe
	local entity = NetworkGetEntityFromNetworkId(netId)
	if not DoesEntityExist(entity) then return end
	local options = {}
	local i = 1
	for methTypes in pairs(Config.Recipes[recipeType]) do
        options[i] = { label = methTypes, value = methTypes}
        i=i+1
	end
	local methType = lib.inputDialog(Locales[Config.Locale]['RecipeDialogHeader'], {
		{type = 'select', label = Locales[Config.Locale]['SelectRecipeDialog'], description = Locales[Config.Locale]['SelectRecipeDialogDesc'], required = true, options = options},
	})
    local returnvalv = nil
    if methType then
        returnvalv = methType[1]
    else
        returnvalv = nil
    end
	if Config.Debug and methType then print("Meth type: "..tostring(methType[1])) end
	return returnvalv
end)

lib.callback.register('unr3al_methlab:client:getSlurryType', function(netId, recipe)
    local recipeType = recipe
	local entity = NetworkGetEntityFromNetworkId(netId)
	if not DoesEntityExist(entity) then return end
	local options = {}
	local i = 1
	for methTypes in pairs(Config.Refinery[recipeType]) do
        options[i] = { label = methTypes, value = methTypes}
        i=i+1
	end
	local methType = lib.inputDialog(Locales[Config.Locale]['SlurryDialogHeader'], {
		{type = 'select', label = Locales[Config.Locale]['SelectSlurryRecipeDialog'], description = Locales[Config.Locale]['SelectSlurryRecipeDialogDesc'], required = true, options = options},
	})
    local returnvalv = nil
    if methType then
        returnvalv = methType[1]
    else
        returnvalv = nil
    end
	if Config.Debug and methType then print("Slurry type: "..tostring(methType[1])) end
	return returnvalv
end)

lib.callback.register('unr3al_methlab:client:startSlurryAnima', function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
	if not DoesEntityExist(entity) then return end
    TriggerEvent('ox_inventory:disarm', GetPlayerServerId(cache.ped), true)
    SetEntityCoords(cache.ped, 1006.43, -3197.65, -40.0, 0, 0, 0, 0)

    if lib.progressBar({
        duration = 30000,
        label = Locales[Config.Locale]['SlurryRefineryProgress'],
        useWhileDead = false,
        allowRagdoll = false,
        allowCuffed = false,
        allowFalling = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
            mouse = true
        },
        anim = {
            dict = 'missfam4',
            clip = 'base'
        },
        prop = {
            model = `p_amb_clipboard_01`,
            bone = 36029,
            pos = vec3(0.16, 0.08, 0.1),
            rot = vec3(-130.0, -50.0, 0.0)
        },
    }) then
        local success = lib.skillCheck({'easy','easy','easy','easy'}, {'e'})
        return success
    else
        return false
    end
end)

-- lib.callback.register('unr3al_methlab:client:startRaidAnima', function(netId, duration, coords)
--     local entity = NetworkGetEntityFromNetworkId(netId)
-- 	if not DoesEntityExist(entity) then return end
--     TriggerEvent('ox_inventory:disarm', GetPlayerServerId(cache.ped), true)

--     -- ["weld"] = {
--     --     "Scenario",
--     --     "WORLD_HUMAN_WELDING",
--     --     "Weld"
--     -- }
--     -- local anim = 'Scenario'

--     -- lib.requestAnimDict(anim)

--     -- local playerPed = PlayerPedId()

--     -- TaskPlayAnim(playerPed, 'Scenario', 'WORLD_HUMAN_WELDING', 8.0, -8.0, -1, 0, 0, false, false, false)

--     local playerPed = PlayerPedId()
--     --TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 5000, false)
--     TaskStartScenarioAtPosition(playerPed, 'WORLD_HUMAN_WELDING', coords.x, coords.y, coords.z, coords.w, duration, false, true)

--     Wait(5000)
--     ClearPedTasksImmediately(playerPed)

--     Wait(2000)
--     if lib.progressBar({
--         duration = duration,
--         label = Locales[Config.Locale]['SlurryRefineryProgress'],
--         useWhileDead = false,
--         allowRagdoll = false,
--         allowCuffed = false,
--         allowFalling = false,
--         canCancel = true,
--         disable = {
--             move = true,
--             car = true,
--             combat = true,
--             mouse = true
--         },
--         anim = {
--             dict = 'missfam4',
--             clip = 'base'
--         },
--         prop = {
--             model = `p_amb_clipboard_01`,
--             bone = 36029,
--             pos = vec3(0.16, 0.08, 0.1),
--             rot = vec3(-130.0, -50.0, 0.0)
--         },
--     }) then
--         local success = lib.skillCheck({'easy','easy','easy','easy'}, {'e'})
--         return success
--     else
--         return false
--     end
-- end)

RegisterNetEvent('unr3al_methlab:client:updateUpgradeMenu', function()
    local methStorage = lib.callback.await('unr3al_methlab:server:getStorage', false, NetworkGetNetworkIdFromEntity(cache.ped))
    local storageMax
    if methStorage == #Config.Upgrades.Storage then
        storageMax = true
    end
    local methSecurity = lib.callback.await('unr3al_methlab:server:getSecurity', false, NetworkGetNetworkIdFromEntity(cache.ped))
    local securityMax
    if methSecurity == #Config.Upgrades.Security then
        securityMax = true
    end
    lib.registerContext({
        id = 'methlab_Menu_Upgrade',
        title = Locales[Config.Locale]['UpgradeLab'],
        menu = 'methlab_Menu_Leave',
        options = {
            {
                title = Locales[Config.Locale]['UpgradeStorage'],
                description = Locales[Config.Locale]['CurrentLevel']..tostring(methStorage)..'/'..tostring(#Config.Upgrades.Storage),
                icon = 'box',
                disabled = storageMax,
                onSelect = function()
                    TriggerServerEvent('unr3al_methlab:server:upgradeStorage', currentLab, NetworkGetNetworkIdFromEntity(cache.ped))
                end,
            },
            {
                title = Locales[Config.Locale]['UpgradeSecurity'],
                description = Locales[Config.Locale]['CurrentLevel']..tostring(methSecurity)..'/'..tostring(#Config.Upgrades.Security),
                icon = 'box',
                disabled = securityMax,
                onSelect = function()
                    TriggerServerEvent('unr3al_methlab:server:upgradeSecurity', currentLab, NetworkGetNetworkIdFromEntity(cache.ped))
                end,
            },
        }
    })
    lib.showContext("methlab_Menu_Upgrade")
end)


AddEventHandler('onClientResourceStart', function (resourceName)
    if(GetCurrentResourceName() ~= resourceName) then
        return
    else
        Wait(1000)
        lib.registerContext({
            id = 'methlab_Menu_Enter',
            title = Locales[Config.Locale]['EnterContextmarker'],
            options = {
                {
                    title = Locales[Config.Locale]['EnterLabel'],
                    description = Locales[Config.Locale]['EnterLabelDesc'],
                    icon = 'door-open',
                    onSelect = function()
                        TriggerServerEvent('unr3al_methlab:server:enter', currentLab, NetworkGetNetworkIdFromEntity(PlayerPedId()), GetPlayerServerId(PlayerId()))
                    end,
                },
                {
                    title = Locales[Config.Locale]['LockLabel'],
                    description = Locales[Config.Locale]['LockLabelDesc'],
                    icon = 'key',
                    onSelect = function()
                        TriggerServerEvent('unr3al_methlab:server:locklab', currentLab, NetworkGetNetworkIdFromEntity(PlayerPedId()))
                    end
                },
                {
                    title = Locales[Config.Locale]['RaidLabel'],
                    description = Locales[Config.Locale]['RaidLabelDesc'],
                    icon = 'screwdriver-wrench',
                    onSelect = function()
                        TriggerServerEvent('unr3al_methlab:server:raidlab', currentLab, NetworkGetNetworkIdFromEntity(PlayerPedId()))
                    end,
                    disabled = true
                },
            }
        })
        lib.registerContext({
            id = 'methlab_Menu_Leave',
            title = Locales[Config.Locale]['EnterContextmarker'],
            options = {
                {
                    title = Locales[Config.Locale]['LeaveLab'],
                    description = Locales[Config.Locale]['LeaveLabDesc'],
                    icon = 'door-open',
                    onSelect = function()
                        TriggerServerEvent('unr3al_methlab:server:leave', currentLab, NetworkGetNetworkIdFromEntity(PlayerPedId()))
                        currentLab = nil
                    end
                },
                {
                    title = Locales[Config.Locale]['LockLabel'],
                    description = Locales[Config.Locale]['LockLabelDesc'],
                    icon = 'key',
                    onSelect = function()
                        TriggerServerEvent('unr3al_methlab:server:locklab', currentLab, NetworkGetNetworkIdFromEntity(PlayerPedId()))
                    end
                },
                {
                    title = Locales[Config.Locale]['UpgradeLab'],
                    description = Locales[Config.Locale]['UpgradeLabDesc'],
                    icon = 'wrench',
                    event = 'unr3al_methlab:client:updateUpgradeMenu',
                    arrow = true,
                },
            }
        })
    end
end)


Citizen.CreateThread(function()
    BikerMethLab = exports['bob74_ipl']:GetBikerMethLabObject()
    BikerMethLab.Style.Set(BikerMethLab.Style.upgrade)
    BikerMethLab.Security.Set(BikerMethLab.Security.upgrade)
    BikerMethLab.Details.Enable(BikerMethLab.Details.production, true)
    RefreshInterior(BikerMethLab.interiorId)
end)

if Config.Debug then
    Citizen.CreateThread(function()
        for k,v in pairs(Config.Methlabs) do
            local blip = AddBlipForCoord(v.Coords)
            SetBlipSprite(blip, 499)
            SetBlipScale(blip, 0.5)
            SetBlipColour(blip, 1)
            SetBlipAsShortRange(blip, false)
            AddTextEntry('MethlabDebugLOL', 'Methlab (~a~)')
            BeginTextCommandSetBlipName('MethlabDebugLOL')
            AddTextComponentSubstringPlayerName('Debug only')
            EndTextCommandSetBlipName(blip)
        end
    end)
end