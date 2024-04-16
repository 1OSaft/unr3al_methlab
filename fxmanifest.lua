fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author '1OSaft'
description 'Advanced meth lab script'
version '1.0.2'

dependencies {'es_extended', 'ox_lib', 'oxmysql', 'bob74_ipl'}


server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@ox_lib/init.lua',
    'config.lua',
    'config.target.lua',
    'server/*.lua',
    'logs/config.log.lua'
}

client_scripts {
    '@ox_lib/init.lua',
    -- 'client/client.lua',
    -- 'client/marker.lua',
    'client/*.lua',
}


shared_scripts {
    'shared/common.lua',
    'locales/*.*',
}