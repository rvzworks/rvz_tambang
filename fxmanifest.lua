fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Rendezvous Works - @ferdydiatmikaa'
description 'rvzworks - Disnaker Mining Job'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
}