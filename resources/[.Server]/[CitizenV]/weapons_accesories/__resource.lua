resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX Basic Needs'

server_scripts {
	'@es_extended/locale.lua',
	'locales/fr.lua',
	'config.lua',
	'server/main.lua',
	'@mysql-async/lib/MySQL.lua',
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'config.lua',
	'client/main.lua'
}
