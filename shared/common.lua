Unr3al = {}
Unr3al.Logging = function(code, ...)
    if not Unr3al.TableContains({'error', 'debug', 'info'}, code) then
        if not Config.Debug and code == 'debug' then return end
        local action = ...
        local args = {...}
        table.remove(args, 1)

        print(Config.LoggingTypes[action], ...)
    else
        if not Config.Debug and code ~= 'error' then return end
        print(Config.LoggingTypes[code], ...)
    end
end

Unr3al.TableContains = function(table, value)
    if not table or not value then return end
    
    if type(value) == 'table' then
        for k, v in pairs(table) do
            for k2, v2 in pairs(value) do
                if v == v2 then
                    return true
                end
            end
        end
    else
        for k, v in pairs(table) do
            if v == value then
                return true
            end
        end
    end
    return false
end