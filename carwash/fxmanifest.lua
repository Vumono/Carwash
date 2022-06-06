fx_version   'cerulean'
lua54        'yes'
game         'gta5'

name         'Carwash'
author       'Vumon'
version      '1.0.0'

--plans:
--Soap amount restock in carwash
--when no soap only clean one level lower
-- choosing program to wash car different levels of dirt

shared_script '@ox_lib/init.lua'
shared_scripts {
	'@es_extended/imports.lua',
	'config.lua'
}

server_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
    '@oxmysql/lib/MySQL.lua',
	'server.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'@PolyZone/client.lua',
	'locales/*.lua',
	'client.lua'
}
