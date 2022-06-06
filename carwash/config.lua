Config = {}
Config.Locale = 'en' -- change locale in locales/en.lua
Config.framework = 'legacy' -- legacy / final / qb in future

Config.useoxlib = true -- cannot be true when usemarkers is true
Config.useoxlibnotify = true
Config.usemarkers =  false -- still WIP dont use yet!!!!
Config.usetarget = true --cannot be true when usemarkers is true
Config.target = 'qtarget' -- or bt-target or fivem-target
Config.bossoptionprop = `prop_byard_elecbox04`
Config.Blipsize =  0.6
Config.washduration = 5000
Config.resellprice = 75000

Config.carwashes = {
    {
        id = 1, --make sure the id's matches the ones in the database
        Washlocation = vector3(26.5906, -1392.0261, 27.3634),
        Bosslocation = vector3(45.9986, -1398.1335, 29.0412), --when using qtarget set this as the boxzone location 
        Targetdebugpoly = false,
        pitch = 0, -- These 3 are used for rotating the bossactions/managing prop. When at 0 nothing will change
        roll = 0,
        yaw = 0,

    },
    {
        id = 2, -- little seoul
        Washlocation = vector3(-699.6325, -932.7043, 17.0139),
        Bosslocation = vector3(-704.8091, -916.9355, 19.2142), --when using qtarget set this as the boxzone location 
        Targetdebugpoly = false,
        pitch = 0, -- These 3 are used for rotating the bossactions/managing prop
        roll = 0,
        yaw = 0,

    },
    {
        id = 3, -- grovestreet
        Washlocation = vector3(167.1034, -1719.4704, 27.2916),
        Bosslocation = vector3(162.3520, -1716.1521, 28.8917), --when using qtarget set this as the boxzone location 
        Targetdebugpoly = false,
        pitch = 0, -- These 3 are used for rotating the bossactions/managing prop
        roll = 0,
        yaw = 0,

    },
}
Config.Libicon = 'soap' -- fontawesome 6 for drawtext
Config.libcolor = '#107dac' --for drawtext
Config.liblocation = "right-center" -- "right-center" or "left-center" or "top-center" for drawtext
Config.targeticonbuysign = 'fas fa-money-bill-wave' --dependent of your version of qtarget, my version uses fontawesome v5 instead of v6

function Notification(type, message, title)
    if Config.useoxlibnotify then
        if type == 'error' then
            lib.notify({
                --id = 'some_identifier',
                title = title,
                description = message,
                type = type -- remove type when using the custom
                --position = 'top',
                --style = {
                --    backgroundColor = '#141517',
                --    color = '#909296'
                --},
                --icon = 'ban',
                --iconColor = '#C53030'
            })
        elseif type == 'success' then
            lib.notify({
                title = title,
                description = message,
                type = type -- remove type when using the custom
            })
        elseif type == 'inform' then
            lib.notify({
                title = title,
                description = message,
                type = type -- remove type when using the custom
            })
        end
    else        --Put your notification system here.
        if type == 'error' then
        ------------------------------------
        elseif type == 'success' then
        ------------------------------------
        elseif type == 'inform' then
        ------------------------------------
        end
    end
end
