fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'F5 Studio <https://f5stud.io>'
description 'GTA VI style weapon and ammo HUD (standalone)'
version '1.0.0'

shared_script 'config.lua'
client_script 'client.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/icons/*.png',
    'html/fonts/*.woff',
}
