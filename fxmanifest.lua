fx_version 'adamant'
game 'gta5'
lua54 'yes'

author '1OSaft'
description 'Advanced meth lab script'
version '1.1.0'

dependencies {'ox_lib', 'oxmysql', 'bob74_ipl'}


server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@ox_lib/init.lua',
    'config.lua',
    'config.target.lua',
    'locales/*.*',
    'bridge/server.lua',
    'server/*.lua',
    'config.logs.lua',
}

client_scripts {
    '@ox_lib/init.lua',
    'client/*.lua',
    'bridge/client.lua',
}

shared_scripts {
    'shared/*.lua',
}

files {
    'database.json',
    'options.json',
}