Config, Locales = {}, {}
----------------------------------------------------------------
Config.Locale = 'en' --choices: en - English; cs - Czech; de - German; fr - French; pl - Polish; sk - Slovakia;
Config.checkForUpdates = true
Config.Debug = true
Config.Framework = 'ESX' --Currently only ESX and qb
----------------------------------------------------------------
Config.LoggingTypes = {
    ['info'] = '[^4Info^0]',
    ['debug'] = '[^3DEBUG^0]',
    ['error'] = '[^1ERROR^0]',
}
----------------------------------------------------------------

Config.MaxLabs = 2

Config.RaidCooldown = 100000 -- in ms

Config.Recipes = {
    ['standard'] = {
        ['Ammonia and sodium (simple)'] = { --Needs to be unique, is also the label shown ingame
            Ingredients = {
                ["ammonia"] = 1,
                ["sodium"] = 1,
            },
            Meth = {
                ItemName = 'chemicalbarrel',
                Chance = {
                    Min = 2,
                    Max = 4
                },
            }
        },
        ['Ammonia and sodium (5x)'] = {
            Ingredients = {
                ["ammonia"] = 5,
                ["sodium"] = 5,
            },
            Meth = {
                ItemName = 'chemicalbarrel',
                Chance = {
                    Min = 5,
                    Max = 10
                },
            }
        },
        ['Ammonia and sodium (10x)'] = {
            Ingredients = {
                ["ammonia"] = 10,
                ["sodium"] = 10,
            },
            Meth = {
                ItemName = 'chemicalbarrel',
                Chance = {
                    Min = 10,
                    Max = 20
                },
            }
        },
    },
    ['special'] = {
        ['example'] = {
            Ingredients = {
                ["acetone"] = 10,
                ["lithium"] = 10,
            },
            Meth = {
                ItemName = 'meth',
                Chance = {
                    Min = 10,
                    Max = 20
                },
            }
        },
    }
}

Config.Refinery = {
    ['standard'] = {
        ['Refine 5l of slurry'] = { --label
            Ingredients = {
                ["chemicalbarrel"] = 5, --input item
            },
            Output = {
                ItemName = 'meth',
                Chance = {
                    Min = 2,
                    Max = 4
                },
            }
        }
    }
}

Config.Items = {
    ['chemicalbarrel'] = {
        MaxFillage = 50, --How much the barrel can hold in liters
        WeightPerFillage = 500 --In gramms
    },

    ['ammonia'] = {
        MaxFillage = 10, --How much the barrel can hold in liters
        WeightPerFillage = 200 --In gramms
    },
    ['sodium'] = {
        MaxFillage = 5, --How much the barrel can hold in liters
        WeightPerFillage = 200 --In gramms
    },
}

Config.Upgrades = {
    Storage = {
        [1] = {
            Slots = 10,
            MaxWeight = 20000,
            Price = {} --Dont touch this or everything is broken :)
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

    -- Doesnt do anything at the moment!
    Security = {
        [1] = {
            NeedOnline = 0, --Players that own this lab needed online for raiding, only works if society owned
            Time = 5000, --In ms
            Price = {}, --Dont touch this or everything is broken :)
            
            RaidGear = {
                ['lockpick'] = {
                    Remove = true,
                    Amount = 1
                },
            },
            Skillcheck = {
                Difficulty = {'easy', 'easy', 'easy', 'easy'}, --to disable it, do Difficulty = nil
                Keys = {'e'}
            }
        },
        [2] = {
            NeedOnline = 2,
            Time = 10000,
            Price = {
                ['money'] = 10000
            },

            RaidGear = {
                ['weldtool'] = {
                    Remove = true,
                    Amount = 1
                },
            },
            Skillcheck = {
                Difficulty = {'easy', 'easy', 'medium', 'medium'}, --to disable it, do Difficulty = nil
                Keys = {'e'}
            }
        },
        [3] = {
            NeedOnline = 2,
            Time = 20000,
            Price = {
                ['money'] = 10000
            },

            RaidGear = {
                ['weldtool'] = {
                    Remove = true,
                    Amount = 2
                },
            },
            Skillcheck = {
                Difficulty = {'easy', 'medium', 'medium', 'hard'}, --to disable it, do Difficulty = nil
                Keys = {'e'}
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

Config.Notification = function(source, notitype, message)
    if IsDuplicityVersion() then -- serverside
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Meth lab',
            description = message,
            type = notitype,
            duration = 5000
        })
    else -- clientside
        lib.notify({
            title = 'Meth lab',
            description = message,
            type = notitype,
            duration = 5000
        })
    end
end