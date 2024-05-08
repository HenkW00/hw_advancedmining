fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'HenkW'
description 'Advanced mining script for ESX and QBCORE using Ox Lib'
version '1.0.9'

client_scripts {
    'bridge/client.lua',
    'client/*.lua',
}

server_scripts {
    'bridge/server.lua',
    'server/*.lua',
}

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',
}

dependencies {
    'ox_lib',
    'hw_utils'
}

escrow_ignore {
    'config.lua',
    'fxmanifest.lua',
    'README.MD'
}