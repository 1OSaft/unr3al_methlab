fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author '1OSaft'
description 'Advanced meth lab script'
version '1.0.0'

dependencies {'es_extended', 'ox_lib', 'oxmysql', 'bob74_ipl'}

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua',
    'shared/common.lua',
    'locales/*.*',
}
client_scripts {
    'client/*.lua',
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
    'logs/config.log.lua'
}