---Gets all informations needed to create a new lab
---@return table | boolean
lib.callback.register('unr3al_methlab:client:getLabCreationstuff', function()
    local recipeList = {}
    local data = {
        [1] = { x = nil, y = nil, z = nil, w = nil },

        [3] = nil,
        [4] = { x = nil, y = nil, z = nil, w = nil },
        [5] = nil,
        [6] = {},
        [7] = { x = nil, y = nil, z = nil, w = nil },
    }
    local titles = {
        [1] = '',
        [2] = '',
        [3] = '',
        [4] = '',
        [5] = '',
        [6] = ''
    }
    finished = false
    for recipe in pairs(Config.Recipes) do
        table.insert(recipeList, { label = recipe, value = recipe })
    end

    local function OpenCreate()
        local canFinishDisabled = true
        if titles[1] and titles[2] and titles[3] and titles[4] and titles[5] == '[Already set] ' then
            print("Can finish now")
            canFinishDisabled = false
        end
            
        lib.registerContext({
            id = 'methlab_creator_menu',
            title = 'Methlab Creator Menu',
            onExit = function()
                return false
            end,
            options = {
                {
                    title = titles[1] .. 'Enter coords',
                    description = 'Enter the entry coords',
                    icon = 'map',
                    onSelect = function()
                        lib.showTextUI("[E] Enter coords")
                        while true do
                            Wait(0)
                            if IsControlJustPressed(0, 38) then
                                local pos = GetEntityCoords(cache.ped)
                                local heading = GetEntityHeading(cache.ped)

                                data[1] = { x = pos[1], y = pos[2], z = pos[3], w = heading }
                                titles[1] = '[Already set] '
                                lib.hideContext(false)
                                lib.hideTextUI()
                                OpenCreate()
                                break
                            end
                        end
                    end,
                    metadata = {
                        { label = 'X', value = data[1].x or "X" },
                        { label = 'Y', value = data[1].y or "X" },
                        { label = 'Z', value = data[1].z or "X" },
                        { label = 'R', value = data[1].w or "X" },
                    }
                },
                {
                    title = titles[2] .. 'Lab buy type',
                    description = 'Who should own this lab?',
                    onSelect = function()
                        local input = lib.inputDialog('Methlab creation menu', {
                            {
                                type = 'select',
                                label = 'Owner',
                                description = 'select can own the lab after purchase',
                                required = true,
                                options = {
                                    { label = 'Player owned',       value = 1 },
                                    { label = 'Society owned',      value = 2 },
                                    { label = 'Decide on purchase', value = 0 },
                                },
                                default = 0
                            },
                        }, { allowCancel = false })
                        data[2] = input[1]
                        titles[2] = '[Already set] '
                        lib.hideContext(false)
                        OpenCreate()
                    end
                },
                {
                    title = titles[3] .. 'Raid Settings',
                    description = 'General raid settings?',
                    onSelect = function()
                        data[3] = lib.inputDialog('Methlab creation menu', {
                            { type = 'checkbox', label = 'Raidable?' },
                        }, { allowCancel = false })
                        if data[3] ~= nil then
                            lib.showTextUI("[E] Enter coords")
                            while true do
                                Wait(0)
                                if IsControlJustPressed(0, 38) then
                                    local pos = GetEntityCoords(cache.ped)
                                    local heading = GetEntityHeading(cache.ped)

                                    data[4] = { x = pos[1], y = pos[2], z = pos[3], w = heading }
                                    titles[3] = '[Already set] '
                                    lib.hideContext(false)
                                    lib.hideTextUI()
                                    OpenCreate()
                                    break
                                end
                            end
                        else
                            titles[3] = '[Already set] '
                            lib.hideContext(false)
                            OpenCreate()
                        end
                    end,
                    metadata = {
                    { label = 'Raidable', value = data[3]   or "X" },
                    { label = 'X',        value = data[4].y or "X" },
                    { label = 'Y',        value = data[4].y or "X" },
                    { label = 'Z',        value = data[4].z or "X" },
                    { label = 'R',        value = data[4].w or "X" },
                    }
                },
                {
                    title = titles[4] .. 'Recipe',
                    description = 'The recipe the lab can do',
                    onSelect = function()
                        local input = lib.inputDialog('Methlab creation menu', {
                            { type = 'select', label = 'Recipe', description = 'Which recipe should the lab have, see Config.Recipes', required = true, options = recipeList },
                        }, { allowCancel = false })

                        data[5] = input[1]
                        titles[4] = '[Already set] '
                        lib.hideContext(false)
                        OpenCreate()
                    end,
                    metadata = {
                        { label = 'Recipetype', value = data[5] or "X" },
                    }
                },
                {
                    title = titles[5] .. 'Purchase price',
                    description = 'Price of the lab',
                    onSelect = function()
                        local repeatInput = true
                        while repeatInput do
                            local input = lib.inputDialog('Methlab creation menu', {
                                { type = 'input',    label = 'Itemname',          description = 'Item spawnname to have for buying the lab', required = true },
                                { type = 'number',   label = 'Item count',        description = 'Item amount requiered to buy the lab',      required = true, min = 1 },
                                { type = 'checkbox', label = 'Add another item?', description = 'Check = add another item',                  checked = true },
                            }, { allowCancel = false })
                            local item = exports.ox_inventory:Items(input[1])
                            if item then
                                repeatInput = input[3]
                                table.insert(data[6], { [input[1]] = input[2] })
                            else
                                repeatInput = true
                                qtm.Notification(nil, 'Item not found', 'error')
                            end
                        end
                        titles[5] = '[Already set] '
                        lib.hideContext(false)
                        OpenCreate()
                    end
                },
                {
                    title = titles[6] .. '[WIP] Garage coords',
                    description = 'Enter the garage coords',
                    icon = 'map',
                    onSelect = function()
                        lib.showTextUI("[E] Garage coords")
                        while true do
                            Wait(0)
                            if IsControlJustPressed(0, 38) then
                                local pos = GetEntityCoords(cache.ped)
                                local heading = GetEntityHeading(cache.ped)

                                data[7] = { x = pos[1], y = pos[2], z = pos[3], w = heading }
                                titles[6] = '[Already set] '
                                lib.hideContext(false)
                                lib.hideTextUI()
                                OpenCreate()
                                break
                            end
                        end
                    end,
                    metadata = {
                        { label = 'X', value = data[7].x or "X" },
                        { label = 'Y', value = data[7].y or "X" },
                        { label = 'Z', value = data[7].z or "X" },
                        { label = 'R', value = data[7].w or "X" },
                    }
                },
                {
                    title = 'Finish',
                    description = 'submit all informations for creation of the lab',
                    disabled = canFinishDisabled,
                    onSelect = function()
                        lib.hideContext(false)
                        finished = true
                    end
                }
            }
        })
        lib.showContext('methlab_creator_menu')
    end
    OpenCreate()

    while not finished do
        Wait(1000)
    end
    return data
end)


lib.callback.register('unr3al_methlab:client:getLabMenustuff', function(database_new)
    local methlabList = {}

    finished = false
    for methlabId_int in pairs(database_new) do
        print(methlabId_int)
        methlabId = tostring(methlabId_int)
        table.insert(methlabList, {
            {
                title = methlabId_int,
                onSelect = function()



                end,
                metadata = {
                    { label = 'Owner',  value = tostring(database_new[methlabId].Owner)     or "Unowned" },
                    { label = 'Locked', value = tostring(database_new[methlabId].Locked)    or "X" },
                }
            },
        })
    end

    lib.registerContext({
        id = 'methlab_edit_menu',
        title = 'Methlab Creator Menu',
        onExit = function()
            return false
        end,
        options = methlabList
    })
    lib.showContext('methlab_edit_menu')

    while not finished do
        Wait(1000)
    end
end)
