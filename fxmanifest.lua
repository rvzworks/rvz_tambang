fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'rvzworks @ferdydiatmikaa'
description 'rvzworks - Disnaker Pilot Job'
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