ESX = exports["es_extended"]:getSharedObject()


--------------------------------------------------------------------------------------------------------------

local PlayerState = LocalPlayer.state
local currentLab = 0
local cam = nil
local objects = {}

RegisterNetEvent('unr3al_methlab:client:notify', function(notitype, message)
	notifications(notitype, message)
end)

for methlabID, methlabMarker in pairs(Config.Methlabs) do
    local coords = methlabMarker.Coords
    local enterMarker = lib.points.new({
        coords = coords,
        distance = 20,
        interactPoint = nil,
        nearby = function()
            local marker = Config.Marker
            DrawMarker(marker.type, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0 , 0.0, 0.0, 0.0, marker.sizeX, marker.sizeY, marker.sizeZ, marker.r, marker.b, marker.g, marker.a, false, false, 0, marker.rotate, false, false, false)
        end,
        onEnter = function(self)
            if self.interactPoint then return end
            print("showing marker")
            self.interactPoint = lib.points.new({
                coords = coords,
                distance = 3,
                nearby = function()
                    if IsControlJustReleased(0, 51) then
                        currentLab = methlabID
                        local owned = lib.callback.await('unr3al_methlab:server:isLabOwned', false, currentLab)
                        if owned == 1 then
                            lib.showContext("methlab_Menu_Enter")
                        else
                            local alert = lib.alertDialog({
                                header = 'Buy methlab',
                                content = 'do you want to buy this lab?',
                                centered = true,
                                cancel = true
                            })
                            if alert == 'confirm' then
                                local buyLab = lib.callback.await('unr3al_methlab:server:buyLab', false, currentLab, NetworkGetNetworkIdFromEntity(cache.ped))
                            end 
                            print(alert)
                        end
                    end
                end,
                onEnter = function()
                    print("Showing textUI3")
                    lib.showTextUI('[E] Open methlab menu')
                end,
                onExit = function()
                    print("Hiding textUI3")
                    lib.hideTextUI()
                end
            })
        end,
        onExit = function(self)
            if not self.interactPoint then return end
            self.interactPoint:remove()
            self.interactPoint = nil
        end,
    })
end

local exitmarker = lib.points.new({
    coords = vector3(997.24, -3200.67, -36.39),
    distance = 20,
    interactPoint = nil,
    nearby = function()
        local marker = Config.Marker
        DrawMarker(marker.type, 997.24, -3200.67, -36.39, 0.0, 0.0, 0.0 , 0.0, 0.0, 0.0, marker.sizeX, marker.sizeY, marker.sizeZ, marker.r, marker.b, marker.g, marker.a, false, false, 0, marker.rotate, false, false, false)
    end,
    onEnter = function(self)
        if self.interactPoint then return end
        self.interactPoint = lib.points.new({
            coords = vector3(997.24, -3200.67, -36.39),
            distance = 3,
            nearby = function()
                if IsControlJustReleased(0, 51) then
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
                        title = 'Upgrade menu',
                        menu = 'methlab_Menu_Leave',
                        options = {
                            {
                                title = 'Storage upgrade',
                                description = 'Current level: '..tostring(methStorage)..'/'..tostring(#Config.Upgrades.Storage),
                                icon = 'box',
                                disabled = storageMax,
                                onSelect = function()
                                    TriggerServerEvent('unr3al_methlab:server:upgradeStorage', currentLab, NetworkGetNetworkIdFromEntity(cache.ped))
                                end,
                            },
                            {
                                title = 'Security upgrade',
                                description = 'Current level: '..tostring(methSecurity)..'/'..tostring(#Config.Upgrades.Security),
                                icon = 'box',
                                disabled = securityMax,
                                onSelect = function()
                                    TriggerServerEvent('unr3al_methlab:server:upgradeSecurity', currentLab, NetworkGetNetworkIdFromEntity(cache.ped))
                                end,
                            },
                        }
                    })
                    lib.showContext("methlab_Menu_Leave")
                end
            end,
            onEnter = function()
                print("Showing textUI2")
                lib.showTextUI('[E] Open methlab menu')
            end,
            onExit = function()
                print("Hiding textUI2")
                lib.hideTextUI()
            end
        })
    end,
    onExit = function(self)
        if not self.interactPoint then return end
        self.interactPoint:remove()
        self.interactPoint = nil
    end,
})

local storageMarker = lib.points.new({
    coords = vector3(1016.56, -3200.13, -38.99),
    distance = 20,
    interactPoint = nil,
    nearby = function()
        local marker = Config.Marker
        DrawMarker(marker.type, 1016.56, -3200.13, -38.99, 0.0, 0.0, 0.0 , 0.0, 0.0, 0.0, marker.sizeX, marker.sizeY, marker.sizeZ, marker.r, marker.b, marker.g, marker.a, false, false, 0, marker.rotate, false, false, false)
    end,
    onEnter = function(self)
        if self.interactPoint then return end
        self.interactPoint = lib.points.new({
            coords = vector3(1016.56, -3200.13, -38.99),
            distance = 3,
            nearby = function()
                if IsControlJustReleased(0, 51) then
                    print("Test")
                    TriggerServerEvent('unr3al_methlab:server:openStorage', NetworkGetNetworkIdFromEntity(cache.ped))
                end
            end,
            onEnter = function()
                print("Showing textUI")
                lib.showTextUI('[E] Open methlab storage')
            end,
            onExit = function()
                print("Hiding textUI")
                lib.hideTextUI()
            end
        })
    end,
    onExit = function(self)
        if not self.interactPoint then return end
        self.interactPoint:remove()
        self.interactPoint = nil
    end,
})

local methMarker = lib.points.new({
    coords = vector3(1005.77, -3200.40, -38.52),
    distance = 20,
    interactPoint = nil,
    nearby = function()
        local marker = Config.Marker
        -- if not cam then
        --     DrawMarker(marker.type, 1005.77, -3200.40, -38.52, 0.0, 0.0, 0.0 , 0.0, 0.0, 0.0, marker.sizeX, marker.sizeY, marker.sizeZ, marker.r, marker.b, marker.g, marker.a, false, false, 0, marker.rotate, false, false, false)
        -- end
    end,
    onEnter = function(self)
        if self.interactPoint then return end
        self.interactPoint = lib.points.new({
            coords = vector3(1005.77, -3200.40, -38.52),
            distance = 3,
            nearby = function()
                if IsControlJustReleased(0, 51) then
                    lib.hideTextUI()
                    TriggerServerEvent('unr3al_methlab:server:startprod', NetworkGetNetworkIdFromEntity(cache.ped))

                    -- local ped = PlayerPedId()
                    -- SetEntityCoords(ped, 1005.773, -3200.402, -38.524, 0, 0, 0, 0)
                    

                    -- --cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 1008.0, -3199.0, -36.5, -20.0, 0.0, 120.0, 70.0)
                    -- cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 561.3, 301.3, 63.0, 0.0, 0.0, 0.0, 90.0)


                    -- SetCamActive(cam, true)
                    -- RenderScriptCams(true, true, 1000, true, true)

                    -- local anim = 'anim@amb@business@meth@meth_monitoring_cooking@cooking@'
                
                    -- lib.requestAnimDict(anim)
                    -- lib.requestModel(`bkr_prop_meth_sacid`)
                    -- lib.requestModel(`bkr_prop_meth_ammonia`)
                    -- lib.requestModel(`bkr_prop_fakeid_clipboard_01a`)
                    -- lib.requestModel(`prop_pencil_01`)
                
                    -- local targetPosition = GetEntityCoords(ped)
                    
                    -- local sacid = CreateObject(`bkr_prop_meth_sacid`, targetPosition.x, targetPosition.y, targetPosition.z, 0, 0, 0)
                    -- objects[1] = sacid
                
                    -- local ammonia = CreateObject(`bkr_prop_meth_ammonia`, targetPosition.x, targetPosition.y, targetPosition.z, 0, 0, 0)
                    -- objects[2] = ammonia
                
                    -- local clipboard = CreateObject(`bkr_prop_fakeid_clipboard_01a`, targetPosition.x, targetPosition.y, targetPosition.z, 0, 0, 0)
                    -- objects[3] = clipboard
                
                    -- local pencil = CreateObject(`prop_pencil_01`, targetPosition.x, targetPosition.y, targetPosition.z, 0, 0, 0)
                    -- objects[4] = pencil
                
                    -- local scenePos, sceneRot = vector3(1010.656, -3198.445, -38.925), vector3(0.0, 0.0, 0.0) -- 353200l
                    -- local scene = CreateSynchronizedScene(scenePos.x, scenePos.y, scenePos.z, sceneRot.x, sceneRot.y, sceneRot.z, 2)
                    -- TaskSynchronizedScene(PlayerPedId(), scene, anim, 'chemical_pour_long_cooker', 1.5, -4.0, 1, 16, 1148846080, 0)
                    -- PlaySynchronizedEntityAnim(sacid, scene, 'chemical_pour_long_sacid', anim, 4.0, -8.0, 1, 1148846080)
                    -- PlaySynchronizedEntityAnim(ammonia, scene, 'chemical_pour_long_ammonia', anim, 4.0, -8.0, 1, 1148846080)
                    -- PlaySynchronizedEntityAnim(clipboard, scene, 'chemical_pour_long_clipboard', anim, 4.0, -8.0, 1, 1148846080)
                    -- PlaySynchronizedEntityAnim(pencil, scene, 'chemical_pour_long_pencil', anim, 4.0, -8.0, 1, 1148846080)
                    -- DetachSynchronizedScene(scene)

                    -- RenderScriptCams(false, true, 0, true, false)
                    -- DestroyCam(cam, false)
                    -- cam = nil
                end
            end,
            onEnter = function()
                print("Showing textUI")
                lib.showTextUI('[E] Open methlab storage')
            end,
            onExit = function()
                print("Hiding textUI")
                lib.hideTextUI()
            end
        })
    end,
    onExit = function(self)
        if not self.interactPoint then return end
        self.interactPoint:remove()
        self.interactPoint = nil
    end,
})

lib.callback.register('unr3al_methlab:client:getMethType', function(netId, recipe)
    local recipeType = recipe
	local entity = NetworkGetEntityFromNetworkId(netId)
	if not DoesEntityExist(entity) then return end
	local options = {}
	local i = 1
    print(recipeType)
	for methTypes in pairs(Config.Recipes[recipeType]) do
        options[i] = { label = methTypes, value = methTypes}
        i=i+1
	end
	local methType = lib.inputDialog('Meth', {
		{type = 'select', label = 'Select meth recipe', description = 'Some input description', required = true, options = options},
	})
	if Config.Debug and methType then print("Meth type: "..tostring(methType[1])) end
	return methType[1] or 0
end)





AddEventHandler('onClientResourceStart', function (resourceName)
    if(GetCurrentResourceName() ~= resourceName) then
        return
    else
        lib.registerContext({
            id = 'methlab_Menu_Enter',
            title = 'Methlab menu',
            onExit = print("lol"),
            options = {
                {
                    title = "Enter lab",
                    description = 'Enter your meth lab',
                    icon = 'key',
                    onSelect = function()
                        TriggerServerEvent('unr3al_methlab:server:enter', currentLab, NetworkGetNetworkIdFromEntity(PlayerPedId()), GetPlayerServerId(PlayerId()))
                    end,
                },
                {
                    title = "Lock lab",
                    description = 'Lock your meth lab',
                    icon = 'key',
                    onSelect = function()
                        TriggerServerEvent('unr3al_methlab:server:locklab', currentLab, NetworkGetNetworkIdFromEntity(PlayerPedId()))
                    end
                },
                {
                    title = "Raid lab",
                    description = 'Raid this meth lab',
                    icon = 'key',
                    onSelect = function()
                        TriggerServerEvent('unr3al_methlab:server:locklab', currentLab, NetworkGetNetworkIdFromEntity(PlayerPedId()))
                    end,
                    disabled = true
                },
            }
        })
        lib.registerContext({
            id = 'methlab_Menu_Leave',
            title = 'Methlab menu',
            onExit = print("lol"),
            options = {
                {
                    title = "Leave lab",
                    description = 'Leave your meth lab',
                    icon = 'key',
                    onSelect = function()
                        TriggerServerEvent('unr3al_methlab:server:leave', currentLab, NetworkGetNetworkIdFromEntity(PlayerPedId()))
                        currentLab = nil
                    end
                },
                {
                    title = "Lock lab",
                    description = 'Lock your meth lab',
                    icon = 'key',
                    onSelect = function()
                        TriggerServerEvent('unr3al_methlab:server:locklab', currentLab, NetworkGetNetworkIdFromEntity(PlayerPedId()))
                    end
                },
                {
                    title = "Upgrade lab",
                    description = 'Lock your meth lab',
                    icon = 'wrench',
                    menu = 'methlab_Menu_Upgrade',
                    arrow = true,
                },
            }
        })
    end
end)


Citizen.CreateThread(function()
    BikerMethLab = exports['bob74_ipl']:GetBikerMethLabObject()
    BikerMethLab.Style.Set(BikerMethLab.Style.basic)
    BikerMethLab.Security.Set(BikerMethLab.Security.upgrade)
    BikerMethLab.Details.Enable(BikerMethLab.Details.production, true)
    RefreshInterior(BikerMethLab.interiorId)
end)


RegisterCommand('meth1', function()
    local ped = PlayerPedId()
    SetEntityCoords(ped, 1005.773, -3200.402, -38.524, 0, 0, 0, 0)
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
    DetachSynchronizedScene(scene)
end, false)
RegisterCommand('stopmeth1', function()
    for i=1, #objects do
        DeleteObject(objects[i])
    end
    objects = {}
    ClearPedTasksImmediately(PlayerPedId())
end, false)


-- RegisterCommand('togglecam', function(source, args)
--     if args[1] then
--         toggleCam(true)
--     else
--         toggleCam(false)
--     end
-- end, false)
