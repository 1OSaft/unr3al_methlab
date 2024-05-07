local datastring = LoadResourceFile(GetCurrentResourceName(), "labs.json")
local database = json.decode(datastring)
local routingBuckets = {}

setRoutingBuckets = function()
    for ident, house in pairs(database) do
        for uId, v in pairs(house) do
            routingBuckets[#routingBuckets + 1] = v.routingBucket or 0
        end
    end
end

genRoutingBucket = function()
    local routingBucket = math.random(0, 999999999)

    for k, v in pairs(routingBuckets) do
        if v == routingBucket then
            return genRoutingBucket()
        end
    end

    routingBuckets[#routingBuckets + 1] = routingBucket

    return routingBucket
end

saveLabData = function(data)
    SaveResourceFile(GetCurrentResourceName(), "labs.json", json.encode(data, { indent = true }), -1)
end