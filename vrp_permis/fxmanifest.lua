fx_version 'adamant'
game 'gta5'
author 'double9'

server_scripts{
    "@vrp/lib/utils.lua",
    "server.lua"
}

client_scripts{
    "@vrp/client/Tunnel.lua",
    "@vrp/client/Proxy.lua",
    "client.lua"
}

files{
    "assets/*.png"
}