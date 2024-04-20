Citizen.CreateThread(function()
    Wait(5000)
    local value = lib.waitFor(function()
        if Config ~= nil then return true end
    end)
    if not Config.OXTarget and value then
        for methlabID, methlabMarker in pairs(Config.Methlabs) do
            local coords = methlabMarker.Coords
            local enterMarker = lib.points.new({
                coords = coords,
                distance = 20,
                interactPoint = nil,
                nearby = function()
                    if not Config.UsePed.Enabled then
                        local marker = Config.Marker
                        DrawMarker(marker.type, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0 , 0.0, 0.0, 0.0, marker.sizeX, marker.sizeY, marker.sizeZ, marker.r, marker.b, marker.g, marker.a, false, false, 0, marker.rotate, false, false, false)
                    end
                end,
                onEnter = function(self)
                    if self.interactPoint then return end
                    if Config.UsePed.Enabled then
                        lib.requestModel(Config.UsePed.Model)
                        local ped = CreatePed(CIVMALE, GetHashKey(Config.UsePed.Model), coords.x, coords.y, coords.z - 1, methlabMarker.HeadingPed, false, true)
                        FreezeEntityPosition(ped, true)
                        SetEntityInvincible(ped, true)
                        SetBlockingOfNonTemporaryEvents(ped, true)
                    end
                    self.interactPoint = lib.points.new({
                        coords = coords,
                        distance = 1,
                        nearby = function()
                            if IsControlJustReleased(0, 51) then
                                TriggerEvent('unr3al_methlab:client:doEnterStuff', methlabID)
                            end
                        end,
                        onEnter = function()
                            lib.showTextUI(Locales[Config.Locale]['NormalMenuTextUI'])
                        end,
                        onExit = function()
                            lib.hideTextUI()
                        end
                    })
                end,
                onExit = function(self)
                    if not self.interactPoint then return end
                    if Config.UsePed.Enabled then
                        DeletePed(ped)
                    end
                    self.interactPoint:remove()
                    self.interactPoint = nil
                end,
            })
        end

        local exitCoords = vector3(997.24, -3200.67, -36.39)
        local exitmarker = lib.points.new({
            coords = exitCoords,
            distance = 20,
            interactPoint = nil,
            nearby = function()
                local marker = Config.Marker
                DrawMarker(marker.type, exitCoords.x, exitCoords.y, exitCoords.z, 0.0, 0.0, 0.0 , 0.0, 0.0, 0.0, marker.sizeX, marker.sizeY, marker.sizeZ, marker.r, marker.b, marker.g, marker.a, false, false, 0, marker.rotate, false, false, false)
            end,
            onEnter = function(self)
                if self.interactPoint then return end
                self.interactPoint = lib.points.new({
                    coords = exitCoords,
                    distance = 2,
                    nearby = function()
                        if IsControlJustReleased(0, 51) then
                            lib.showContext("methlab_Menu_Leave")
                        end
                    end,
                    onEnter = function()
                        lib.showTextUI(Locales[Config.Locale]['NormalMenuTextUI'])
                    end,
                    onExit = function()
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
        
        local storageCoords = vector3(1016.56, -3200.13, -38.99)
        local storageMarker = lib.points.new({
            coords = storageCoords,
            distance = 20,
            interactPoint = nil,
            nearby = function()
                local marker = Config.Marker
                DrawMarker(marker.type, storageCoords.x, storageCoords.y, storageCoords.z, 0.0, 0.0, 0.0 , 0.0, 0.0, 0.0, marker.sizeX, marker.sizeY, marker.sizeZ, marker.r, marker.b, marker.g, marker.a, false, false, 0, marker.rotate, false, false, false)
            end,
            onEnter = function(self)
                if self.interactPoint then return end
                self.interactPoint = lib.points.new({
                    coords = storageCoords,
                    distance = 1,
                    nearby = function()
                        if IsControlJustReleased(0, 51) then
                            TriggerServerEvent('unr3al_methlab:server:openStorage', NetworkGetNetworkIdFromEntity(cache.ped))
                        end
                    end,
                    onEnter = function()
                        lib.showTextUI(Locales[Config.Locale]['StorageTextUI'])
                    end,
                    onExit = function()
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
        
        local methCoords = vector3(1005.77, -3200.40, -38.52)
        local methMarker = lib.points.new({
            coords = methCoords,
            distance = 20,
            interactPoint = nil,
            nearby = function()
                if not cam then
                    local marker = Config.Marker
                    DrawMarker(marker.type, methCoords.x, methCoords.y, methCoords.z, 0.0, 0.0, 0.0 , 0.0, 0.0, 0.0, marker.sizeX, marker.sizeY, marker.sizeZ, marker.r, marker.b, marker.g, marker.a, false, false, 0, marker.rotate, false, false, false)
                end
            end,
            onEnter = function(self)
                if self.interactPoint then return end
                self.interactPoint = lib.points.new({
                    coords = methCoords,
                    distance = 1,
                    nearby = function()
                        if IsControlJustReleased(0, 51) then
                            lib.hideTextUI()
                            TriggerServerEvent('unr3al_methlab:server:startprod', NetworkGetNetworkIdFromEntity(cache.ped))
                        end
                    end,
                    onEnter = function()
                        lib.showTextUI(Locales[Config.Locale]['PouringTextUI'])
                    end,
                    onExit = function()
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
        
        local refineryCoords = vector3(1006.43, -3197.65, -39.0)
        local methRefinery1 = lib.points.new({
            coords = refineryCoords,
            distance = 20,
            interactPoint = nil,
            nearby = function()
                local marker = Config.Marker
                if not cam then
                    DrawMarker(marker.type, refineryCoords.x, refineryCoords.y, refineryCoords.z, 0.0, 0.0, 0.0 , 0.0, 0.0, 0.0, marker.sizeX, marker.sizeY, marker.sizeZ, marker.r, marker.b, marker.g, marker.a, false, false, 0, marker.rotate, false, false, false)
                end
            end,
            onEnter = function(self)
                if self.interactPoint then return end
                self.interactPoint = lib.points.new({
                    coords = refineryCoords,
                    distance = 1,
                    nearby = function()
                        if IsControlJustReleased(0, 51) then
                            lib.hideTextUI()
                            TriggerServerEvent('unr3al_methlab:server:startSlurryRefinery', NetworkGetNetworkIdFromEntity(cache.ped))
                        end
                    end,
                    onEnter = function()
                        lib.showTextUI(Locales[Config.Locale]['RefineryTextUI'])
                    end,
                    onExit = function()
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
    else
        for methlabID, methlabMarker in pairs(Config.Methlabs) do
            exports.ox_target:addSphereZone({
                coords = methlabMarker.Coords,
                radius = Config.Target.EnterPoint.TargetSize,
                debug = Config.Debug,
                drawSprite = Config.Debug,
                options = {
                    {
                        name = 'methLabEnterPoint'..methlabID,
                        label = Locales[Config.Locale]['NormalMenuTextUI'],
                        distance = Config.Target.EnterPoint.InteractDistance,
                        onSelect = function(data)
                            TriggerEvent('unr3al_methlab:client:doEnterStuff', methlabID)
                        end,
                    }
                }
            })
        end
        exports.ox_target:addBoxZone({
            coords = vector3(996.5, -3200.67, -36.39),
            size = vec3(1.2, 1.2, 2.5),
            debug = Config.Debug,
            drawSprite = Config.Debug,
            options = {
                {
                    name = 'methExitPoint',
                    label = Locales[Config.Locale]['NormalMenuTextUI'],
                    distance = Config.Target.ExitPoint.InteractDistance,
                    onSelect = function(data)
                        lib.showContext("methlab_Menu_Leave")
                    end,
                }
            }
        })
        exports.ox_target:addSphereZone({
            coords = vector3(1005.80, -3201.60, -38.57),
            radius = Config.Target.MethPoint.TargetSize,
            debug = Config.Debug,
            drawSprite = Config.Debug,
            options = {
                {
                    name = 'methMakerPoint',
                    label = Locales[Config.Locale]['PouringTextUI'],
                    distance = Config.Target.MethPoint.InteractDistance,

                    onSelect = function(data)
                        TriggerServerEvent('unr3al_methlab:server:startprod', NetworkGetNetworkIdFromEntity(cache.ped))
                    end,
                }
            }
        })
        exports.ox_target:addBoxZone({
            coords = vector3(1007, -3197.7, -39.0),
            size = vec3(1.2, 0.5, 2.5),
            rotation = 263.5,
            debug = Config.Debug,
            drawSprite = Config.Debug,
            options = {
                {
                    name = 'methSlurryPoint',
                    label = Locales[Config.Locale]['RefineryTextUI'],
                    distance = Config.Target.SlurryPoint.InteractDistance,

                    onSelect = function(data)
                        TriggerServerEvent('unr3al_methlab:server:startSlurryRefinery', NetworkGetNetworkIdFromEntity(cache.ped))
                    end,
                }
            }
        })
        exports.ox_target:addBoxZone({
            coords = vector3(1017, -3200, -38.5),
            size = vec3(2, 2, 2),
            debug = Config.Debug,
            drawSprite = Config.Debug,
            options = {
                {
                    name = 'methStoragePoint',
                    label = Locales[Config.Locale]['StorageTextUI'],
                    distance = Config.Target.StoragePoint.InteractDistance,

                    onSelect = function(data)
                        TriggerServerEvent('unr3al_methlab:server:openStorage', NetworkGetNetworkIdFromEntity(cache.ped))
                    end,
                }
            }
        })
    end
end)



RegisterNetEvent('unr3al_methlab:client:doEnterStuff', function(methlabID)
    currentLab = methlabID
    local owned = lib.callback.await('unr3al_methlab:server:isLabOwned', false, currentLab)
    if owned == 1 then
        lib.showContext("methlab_Menu_Enter")
    else
        local alert = lib.alertDialog({
            header = Locales[Config.Locale]['AlertDialogHeader'],
            content = Locales[Config.Locale]['AlertDialogHeaderDesc'],
            centered = true,
            cancel = true
        })
        if alert == 'confirm' then
            local buyLab = lib.callback.await('unr3al_methlab:server:buyLab', false, currentLab, NetworkGetNetworkIdFromEntity(cache.ped))
        end
    end
end)