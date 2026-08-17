fx_version 'cerulean'
game 'gta5'

author 'RobinGCS'
description 'policevehicle Dealership'
version '1.0.0'

shared_script 'config.lua'
server_script 'server/main.lua'

client_scripts {
    'client/target.lua',
    'client/main.lua'
}

dependency 'qb-core'
dependency 'ox_lib'

-- Also requires a target resource: ox_target (https://github.com/TheOrderFivem/ox_target)
-- or qb-target. See Config.Target in config.lua.
