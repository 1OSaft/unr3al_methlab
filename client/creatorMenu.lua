-- AddEventHandler('onClientResourceStart', function (resourceName)
--     if(GetCurrentResourceName() ~= resourceName) then
--         return
--     end
--     local value = lib.waitFor(function()
--         if Config ~= nil then return true end
--     end)


-- end)


---Finished
---@param netId integer
---@return boolean
lib.callback.register('unr3al_methlab:client:getLabCreationstuff', function(netId)
    local recipeList = {}
    for recipe in pairs(Config.Recipes) do
        table.insert(recipeList, {label = recipe, value = recipe})
    end
    local input = lib.inputDialog('Methlab creation menu', {
        {type = 'input', label = 'Enter coords', description = 'Entry coords always needs to be 3 coords, (x, y, z)', required = true, default = '-57.60, -1228.61, 28.79'},

        {type = 'number', label = 'NPC heading', description = 'if you use peds, input the rotation here', required = true, default = 123.0},

        {type = 'select', label = 'Owner', description = 'select can own the lab after purchase', required = true, options = {
            { label = 'Player owned', value = 1},
            { label = 'Society owned', value = 2},
            { label = 'Decide on purchase', value = 0},
        }, default = 0},

        {type = 'checkbox', label = 'Raidable?'},
        {type = 'input', label = 'Enter raid coords', description = 'Raid coords need to be 4 coords, (x, y, z, rotation)', required = true, default = '-56.61, -1229.14, 27.79, 223.43'},
        {type = 'textarea', label = 'Enter purchase price', description = 'Please be smart enough to understand it, itemspawnname = itemcount the latest count cant have a ,', required = true, default = "money = 100000, metal = 100", min = 5},

        {type = 'select', label = 'Recipe', description = 'Which recipe should the lab have, see Config.Recipes', required = true, options = recipeList},

      })
      if input == nil then
        return false
      end
      return input
end)
