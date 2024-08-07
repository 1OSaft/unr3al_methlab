fx_version 'adamant'
game 'gta5'
lua54 'yes'

author '1OSaft'
description 'Advanced meth lab script'
version '2.0.0'

dependencies {'ox_lib', 'oxmysql', 'bob74_ipl', 'qtm-lib'}


server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@ox_lib/init.lua',
    '@qtm-lib/imports.lua',
    'config.lua',
    'config.target.lua',
    'server/*.lua',
    'config.logs.lua',
}

client_scripts {
    '@ox_lib/init.lua',
    '@qtm-lib/imports.lua',
    'client/*.lua',
}

files {
    'database.json',
    'options.json',
    'locales/*.*',
}