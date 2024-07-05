-- AddEventHandler('onClientResourceStart', function (resourceName)
--     if(GetCurrentResourceName() ~= resourceName) then
--         return
--     end
--     local value = lib.waitFor(function()
--         if Config ~= nil then return true end
--     end)


-- end)


---Finished
---@return table | boolean
lib.callback.register('unr3al_methlab:client:getLabCreationstuff', function()
    local recipeList = {}
    data = {}
    finished = false
    for recipe in pairs(Config.Recipes) do
        table.insert(recipeList, {label = recipe, value = recipe})
    end








    local function OpenCreate()
      lib.registerContext({
        id = 'methlab_creator_menu',
        title = 'Methlab Creator Menu',
        options = {
          {
            title = 'Enter coords',
            description = 'Enter the entry coords',
            icon = 'map',
            onSelect = function()
              while true do
                Wait(0)
                if IsControlJustPressed(0, 38) then
                  local pos = GetEntityCoords(cache.ped)
                  local heading = GetEntityHeading(cache.ped)
    
                  data[1] = {x = pos[1], y = pos[2], z = pos[3], w = heading}
                  lib.hideContext(false)
                  OpenCreate()
                  break
                end
              end
            end,
          },
          {
            title = 'Lab buy type',
            description = 'Who should own this lab?',
            onSelect = function()
              local input = lib.inputDialog('Methlab creation menu', {
                {type = 'select', label = 'Owner', description = 'select can own the lab after purchase', required = true, options = {
                    { label = 'Player owned', value = 1},
                    { label = 'Society owned', value = 2},
                    { label = 'Decide on purchase', value = 0},
                }, default = 0},
              }, {allowCancel = false})
              data[2] = input[1]
              lib.hideContext(false)
              OpenCreate()
            end,
          },
          {
            title = 'Raid Settings',
            description = 'General raid settings?',
            onSelect = function()
              data[3] = lib.inputDialog('Methlab creation menu', {
                {type = 'checkbox', label = 'Raidable?'},
              }, {allowCancel = false})
              if data[3] ~= nil then
                while true do
                  Wait(0)
                  if IsControlJustPressed(0, 38) then
                    local pos = GetEntityCoords(cache.ped)
                    local heading = GetEntityHeading(cache.ped)
      
                    data[4] = {x = pos[1], y = pos[2], z = pos[3], w = heading}
                    lib.hideContext(false)
                    OpenCreate()
                    break
                  end
                end
              else
                data[4] = nil
                lib.hideContext(false)
                OpenCreate()
              end
            end,
          },
          {
            title = 'Recipe',
            description = 'The recipe the lab can do',
            onSelect = function()
              local input = lib.inputDialog('Methlab creation menu', {
                {type = 'select', label = 'Recipe', description = 'Which recipe should the lab have, see Config.Recipes', required = true, options = recipeList},
              }, {allowCancel = false})
    
              data[5] = input[1]
              lib.hideContext(false)
              OpenCreate()
            end
          },
          {
            title = 'Purchase price',
            description = 'Price of the lab',
            disabled = true
          },
          {
            title = 'Finish',
            description = 'Test',
            disabled = false,
            onSelect = function()
              print(json.encode(data))
            end
          },
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