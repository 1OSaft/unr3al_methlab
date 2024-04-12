Config, Locales = {}, {}
----------------------------------------------------------------
Config.Locale = 'en'
Config.checkForUpdates = true
Config.Debug = true
----------------------------------------------------------------
Config.LoggingTypes = {
    ['info'] = '[^4Info^0]',
    ['debug'] = '[^3DEBUG^0]',
    ['error'] = '[^1ERROR^0]',
}
----------------------------------------------------------------

Config.Marker = {
    type = 20,
    sizeX = 1.0,
    sizeY = 1.0,
    sizeZ = 1.0,
    r = 255,
    g = 255,
    b = 255,
    a = 100,
    rotate = true,
    distance = 2
}

Config.MaxLabs = 4

Config.Methlabs = {
    [1] = { --Routingbucket id, standart Routingbucket is 0, so dont use it. first lab is 1, second 2, third 3 and so on!
        Coords = vector3(-57.60, -1228.61, 28.79),
        Purchase = {
            Type = 'society', --society owned or player owned
            Price = {
                ['money'] = 1,
                ['bread'] = 1
            },
            Raidable = true
        },
        Recipes = 'standard' -- standard for Config.Recipes or custom for custom recipes for this exact lab
    },
    [2] = { --Routingbucket id, standart Routingbucket is 0, so dont use it
        Coords = vector3(-65.40, -1226.72, 28.79),
        Purchase = {
            Type = 'society', --society owned or player owned
            Price = {
                ['money'] = 1,
                ['bread'] = 1
            },
            Raidable = true
        },
        Recipes = 'standard' -- standard for Config.Recipes or custom for custom recipes for this exact lab
    },
    [3] = { --Routingbucket id, standart Routingbucket is 0, so dont use it
    Coords = vector3(-61.07, -1233.11, 28.79),
    Purchase = {
        Type = 'society', --society owned or player owned
        Price = {
            ['money'] = 1,
            ['bread'] = 1
        },
        Raidable = true
    },
    Recipes = 'standard' -- standard for Config.Recipes or custom for custom recipes for this exact lab
    },
    [4] = { --Routingbucket id, standart Routingbucket is 0, so dont use it
    Coords = vector3(-66.53, -1239.11, 28.79),
    Purchase = {
        Type = 'society', --society owned or player owned
        Price = {
            ['money'] = 1,
            ['bread'] = 1
        },
        Raidable = true
    },
    Recipes = 'standard' -- standard for Config.Recipes or custom for custom recipes for this exact lab
    },
}

Config.Recipes = {
    ['standard'] = {
        ['easy'] = { --Needs to be unique, is also the label shown ingame
            ['acetone'] = 1,
            ['lithium'] = 1
        },
        ['medium'] = {
            ['acetone'] = 5,
            ['lithium'] = 5
        },
        ['hard'] = {
            ['acetone'] = 10,
            ['lithium'] = 10
        },
    },
    ['special'] = {
        ['easy'] = {
            ['acetone'] = 1,
            ['lithium'] = 1
        },
    }
}

Config.Upgrades = {
    Storage = {
        [1] = {
            Slots = 10,
            MaxWeight = 20000
        },
        [2] = {
            Slots = 20,
            MaxWeight = 30000,
            Price = {
                ['money'] = 10000
            }
        },
        [3] = {
            Slots = 30,
            MaxWeight = 60000,
            Price = {
                ['money'] = 10000
            }
        },
        [4] = {
            Slots = 40,
            MaxWeight = 80000,
            Price = {
                ['money'] = 10000
            }
        },
        [5] = {
            Slots = 50,
            MaxWeight = 100000,
            Price = {
                ['money'] = 10000
            }
        },
    },
    Security = {
        [1] = {
            NeedOnline = 2, --Players that own this lab needed online for raiding, only works if society owned
            Time = 5000 --In ms
        },
        [2] = {
            NeedOnline = 2,
            Time = 10000,
            Price = {
                ['money'] = 10000
            }
        },
        [3] = {
            NeedOnline = 2,
            Time = 20000,
            Price = {
                ['money'] = 10000
            }
        },
    }
}

Config.Noti = {
    --Notifications types:
    success = 'success',
    error = 'error',
    info = 'inform',
    warning = 'warning',
}

function notifications(notitype, message)
    --Change this trigger for your notification system keeping the variables
    lib.notify({
        title = 'Meth lab',
        description = message,
        type = notitype,
        duration = 5000
    })
end