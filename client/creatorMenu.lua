-- AddEventHandler('onClientResourceStart', function (resourceName)
--     if(GetCurrentResourceName() ~= resourceName) then
--         return
--     end
--     local value = lib.waitFor(function()
--         if Config ~= nil then return true end
--     end)


-- end)



lib.callback.register('unr3al_methlab:client:getLabCreationstuff', function(netId)
    local input = lib.inputDialog('Methlab creation menu', {
        {type = 'input', label = 'Enter coords', description = 'Entry coords in vector3 format', required = true, default = 'vec3(-57.60, -1228.61, 28.79)'},
        {type = 'number', label = 'NPC heading', description = 'if you use peds, input the rotation here', required = true, icon = 'hashtag'},

        {type = 'select ', label = 'Owner', description = 'select can own the lab after purchase', required = true, options = {
            { label = 'Player owned', value = 1},
            { label = 'Society owned', value = 2},
            { label = 'Decide on purchase', value = 0}
        }},
        {type = 'checkbox', label = 'Raidable?'},
        {type = 'input', label = 'Enter raid coords', description = 'Raid coords in vector4 format', required = true, default = 'vec4(-56.61, -1229.14, 27.79, 223.43)'},
        {type = 'textarea', label = 'Enter purchase price', description = 'Please be smart enough to understand it', required = true, default = "['money'] = 100000,  \n['metal'] = 100,", min = 5},


      })
end)
