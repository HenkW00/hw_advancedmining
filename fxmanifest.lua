fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'HenkW'
description 'Advanced mining script for ESX and QBCORE using Ox Lib'
version '1.0.1'

client_scripts {
    'bridge/client.lua',
    'client/*.lua',
}

server_scripts {
    'bridge/server.lua',
    'server/*.lua',
    'server/version.lua',
}

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',
}

dependency 'ox_lib'