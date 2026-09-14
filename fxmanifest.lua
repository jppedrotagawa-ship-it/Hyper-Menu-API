fx_version 'cerulean'
game 'gta5'

author 'Hyper Development'
description 'Hyper Menu - FiveM Framework'
version '3.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/assets/**/*'
}

client_scripts {
    'config.lua',
    'client/main.lua',
    'client/peds.lua',
    'client/vehicles.lua',
    'client/pvp.lua'
}

server_scripts {
    'server/main.lua',
    'server/exploits.lua'
}
