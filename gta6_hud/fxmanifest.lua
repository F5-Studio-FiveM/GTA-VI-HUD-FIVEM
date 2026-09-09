fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'F5 Studio <https://f5stud.io>'
description 'GTA VI style HUD for QBCore, Qbox and ESX'
version '1.0.0'

shared_scripts {
    'config.lua',
    'shared/locale.lua',
    'locales/*.lua',
}

client_scripts {
    'client/core.lua',
    'client/adapter_qb.lua',
    'client/adapter_qbx.lua',
    'client/adapter_esx.lua',
    'client/stress.lua',
    'client/minimap.lua',
    'client/player.lua',
    'client/voice.lua',
    'client/compass.lua',
    'client/weapon.lua',
}

server_script 'server/main.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/weapons/*.png',
    'html/fonts/*.ttf',
    'html/fonts/*.woff2',
    'html/fonts/*.woff',
}
