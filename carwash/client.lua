

if Config.framework == 'final' then
    ESX = nil

    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

end
Citizen.CreateThread(function()
	for k,v in pairs(Config.carwashes) do


		local blip = AddBlipForCoord(vector3(v.Washlocation.x, v.Washlocation.y, v.Washlocation.z))
		SetBlipSprite(blip, 100)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString(_U('blip_carwash'))
		EndTextCommandSetBlipName(blip)
	end
end)


RegisterNetEvent('esx:playerLoaded') -- Store the players data
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
end)

if Config.usemarkers and ESX.PlayerLoaded == true then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local canSleep = true
            if CanWashVehicle() then
                for i=1, #Config.carwashes, 1 do
                    local carWash = Config.carwashes[i]
                    local location = carWash.Washlocation
                    local distance = #(location - coords)
                    if distance < 50 then
                        DrawMarker(1, location, 0, 0, 0, 0, 0, 0, 5.0, 5.0, 2.0, 0, 157, 0, 155, false, false, 2, false, false, false, false)
                        canSleep = false
                    end
                end
                if distance < 5 then
					canSleep = false
                    ESX.ShowHelpNotification(_U('prompt_wash'))

					if IsControlJustReleased(0, 38) then
						local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                        ESX.TriggerServerCallback('carwash:getinfo', function(price)

                        end)

						--[[ if GetVehicleDirtLevel(vehicle) > 2 then
							WashVehicle()
						else
							ESX.ShowNotification(_U('wash_failed_clean'))
						end ]]


					end
				end
                if canSleep then
                    Citizen.Wait(500)
                end
            else
                Citizen.Wait(500)
            end

        end
    end)

elseif Config.useoxlib and ESX.PlayerLoaded == true   then
    local isinside = false
    Citizen.CreateThread(function()
        for i = 1, #Config.carwashes do
            local carwash = Config.carwashes[i]
            local location = Config.carwashes[i].id
            
            function onEnter(self)
                isinside = true
                if IsPedSittingInAnyVehicle(PlayerPedId()) then
                lib.showTextUI(_U('prompt_wash'), {
                position = Config.liblocation,
                icon = Config.Libicon,
                style = {
                    borderRadius = 0,
                    backgroundColor = Config.libcolor,
                    color = 'white'
                    }
                })
                end   
            end
            local pressed = false
            function inside(self)
                if isinside then
                    while true do
                        Citizen.Wait(0)
                        if IsControlJustReleased(0, 38) and IsPedSittingInAnyVehicle(PlayerPedId()) and not pressed then
                            pressed = true
                            ESX.TriggerServerCallback('carwash:getinfo', function(data)
                                for k, v in pairs(data) do
                                    local owner = v.owner
                                    local price = v.price
                                    local location = v.location
                                    ESX.TriggerServerCallback('carwash:canafford', function(data)
                                        if data then
                                            Notification('success', _U('wash_started'), _U('wash_title'))
                                            if lib.progressBar({
                                                duration = Config.washduration,
                                                label = _U('wash_inprogress'),
                                                useWhileDead = false,
                                                canCancel = false,
                                                disable = {
                                                    car = true,
                                                },

                                            }) then 
                                                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                                SetVehicleDirtLevel(vehicle, 0.1)
                                                Notification('success', _U('wash_successful'), _U('wash_title'))
                                                pressed = false
                                            end
                                        else
                                            Notification('error', _U('wash_failed'), _U('wash_title'))
                                            pressed = false
                                        end
            
                                    end, price, location)
                                end

                            end, location)
                        end
                    end
                end
            end
            function onExit(self)
                lib.hideTextUI()
                isinside = false
            end

            local sphere = lib.zones.sphere({
                coords = vector3(Config.carwashes[i].Washlocation.x, Config.carwashes[i].Washlocation.y, Config.carwashes[i].Washlocation.z),
                radius = 3.5,
                debug = Config.carwashes[i].Targetdebugpoly,
                inside = inside,
                onEnter = onEnter,
                onExit = onExit
            })

            
        end
    end)
end


if Config.usetarget and ESX.PlayerLoaded == true then
    for k, v in pairs(Config.carwashes) do

        local location = v.id
        local model = Config.bossoptionprop
        local prop = CreateObject(model, vector3(v.Bosslocation.x, v.Bosslocation.y, v.Bosslocation.z), true, true, true)
        SetEntityRotation(prop, v.pitch, v.roll, v.yaw, 1, true)
        FreezeEntityPosition(prop,true)
        ESX.TriggerServerCallback('carwash:getowner', function(bool)
            if bool == true then
                if Config.target == 'fivem-target' then
                    exports['fivem-target']:RemoveTargetPoint('Check price', 'Buy property')
                else
                    exports[Config.target]:RemoveTargetEntity(prop, {
                        'Check price', 'Buy property'
                    })
                end
                if Config.target == 'fivem-target' then
                    exports["fivem-target"]:AddTargetEntity({
                        name = "CarwashBossactions",
                        label = "Carwash Bossactions",
                        icon = "far fa-comment",
                        netId = NetworkGetNetworkIdFromEntity(prop),
                        interactDist = 3.0,
                        onInteract = function(targetName,optionName,vars,entityHit)
                            if optionName == "bossactions" then
                                bosscontext(location)
                            end
                        end,
                        options = {
                          {
                            name = "bossactions",
                            label = "Boss actions"
                          }
                        }
                      })
                else
                
                exports[Config.target]:AddTargetEntity(prop, { -- werkt
                        options = {
                            {
                            icon = "far fa-comment",
                            label = "Boss actions",
                            action = function()
                                bosscontext(location)
                            end
                            },
                            
                        },
                        distance = 3.0
                })
                end
            elseif bool == false then
                if Config.target == 'fivem-target' then
                    exports["fivem-target"]:AddTargetEntity({
                        name = "Carwashpriceactions",
                        label = "Carwash actions",
                        icon = Config.targeticonbuysign,
                        netId = NetworkGetNetworkIdFromEntity(prop),
                        interactDist = 3.0,
                        onInteract = function(targetName,optionName,vars,entityHit) --only for fivem-target
                            if optionName == "checkprice" then
                                ESX.TriggerServerCallback('carwash:getinfo', function(data)
                                    for k, v in pairs(data) do
                
                                        Notification('inform', _U('buy_wash')..ESX.Math.GroupDigits(v.buyprice), _U('wash_title'))
                                    end
                                end,location)
                            elseif optionName == "buyproperty" then
                                location = v.id
                                    ESX.TriggerServerCallback('carwash:buyWash', function(data)
                                        if data == true then
                                            PlaySoundFrontend(-1, "Apt_Style_Purchase", "DLC_APT_Apartment_SoundSet", 1)
                                            Notification('success', _U('buy_washdone'), _U('wash_title'))
                                            firstbossmenu()
                                            if Config.target == 'fivem-target' then
                                                exports['fivem-target']:RemoveTargetPoint('Check price', 'Buy property')
                                            else
                                                exports[Config.target]:RemoveTargetEntity(prop, {
                                                    'Check price', 'Buy property'
                                                })
                                            end
                                        else
                                            Notification('error', _U('buy_washfail'), _U('wash_title'))
                                        end  
                
                                    end, location)
                            end
                        end,
                        options = {
                          {
                            name = "checkprice",
                            label = "Check Price"
                          },
                          {
                            name = "buyproperty",
                            label = "Buy property"
                          }
                        }
                      })
                else
                    exports[Config.target]:AddTargetEntity(prop, { -- werkt
                            options = {
                                {
                                icon = Config.targeticonbuysign,
                                label = "Check price",
                                action = function()
                                    ESX.TriggerServerCallback('carwash:getinfo', function(data)
                                        for k, v in pairs(data) do
        
                                            Notification('inform', _U('buy_wash')..ESX.Math.GroupDigits(v.buyprice), _U('wash_title'))
                                        end
                                    end,location)
                                end
                                },
                                {
                                icon = Config.targeticonbuysign,
                                label = "Buy property",
                                action = function()
                                    location = v.id
                                    ESX.TriggerServerCallback('carwash:buyWash', function(data)
                                        if data == true then
                                            PlaySoundFrontend(-1, "Apt_Style_Purchase", "DLC_APT_Apartment_SoundSet", 1)
                                            Notification('success', _U('buy_washdone'), _U('wash_title'))
                                            firstbossmenu()
                                            if Config.target == 'fivem-target' then
                                                exports['fivem-target']:RemoveTargetPoint('Check price', 'Buy property')
                                            else
                                                exports[Config.target]:RemoveTargetEntity(prop, {
                                                    'Check price', 'Buy property'
                                                })
                                            end
                                        else
                                            Notification('error', _U('buy_washfail'), _U('wash_title'))
                                        end  
        
                                    end, location)
                                end
                                },
                                
                            },
                            distance = 3.0
                    })
                end
            end
        end,location)
        function firstbossmenu()
            exports[Config.target]:AddTargetEntity(prop, { -- werkt
            options = {
                {
                icon = "far fa-comment",
                label = "Boss actions",
                action = function()
                    bosscontext(location)
                end
                },
                
            },
            distance = 3.0
        })
        end
        
        
        function bosscontext(location)
            ESX.TriggerServerCallback('carwash:getinfo', function(data)
                for k,v in pairs(data) do
                        lib.registerContext({
                            id = k..'kcarwashbossmenu',
                            title = _U('bossmenu'),
                            options = {
                                {
                                    title = _U('manageprice'),
                                    description = _U('washprice')..v.price,
                                    arrow = true,
                                    event = 'carwash:setprice',
                                },
                                {
                                    title = _U('sellstation'),
                                    menu = 'sellsure',
                                    description = _U('carwashworth')..Config.resellprice,
                                    metadata = {_U('loseshit')}
                                },
                                {
                                    title = _U('moneymanagement'),
                                    description = _U('currentbalance')..v.balance,
                                    menu = k..'moneymanagement',
                                    arrow = true,
                                    event = 'some_event',
                                }
                            },
                            {
                                id = k..'moneymanagement',
                                title = _U('bossmenu'),
                                menu = k..'kcarwashbossmenu',
                                options = {
                                    {
                                        title = _U('moneymanagement'),
                                        description = _U('currentbalance')..v.balance,
                                    },
                                    {
                                        title = _U('deposit'),
                                        --description = 'Takes you to another menu!',

                                        event = 'carwash:deposit', 
                                        arrow = false
                                    },
                                    {
                                        title = _U('withdraw'),
                                        --description = 'Takes you to another menu!',
                                        event = 'carwash:withdraw',
                                        arrow = false
                                    }
                                }
                            },
                            {
                                id = 'sellsure',
                                title = _U('bossmenu'),
                                menu = k..'kcarwashbossmenu',
                                options = {
                                    {
                                        title = _U('sellstationsure'),
                                    },
                                    {
                                        title = _U('yes'),
                                        --description = 'Takes you to another menu!',

                                        event = '', --sell event fixen serverside
                                        arrow = false
                                    },
                                    {
                                        title = _U('no'),
                                        menu = k..'kcarwashbossmenu',
                                        arrow = false
                                    }
                                }
                            }
                        })
                        lib.showContext(k..'kcarwashbossmenu')
                end
            end,location)

        end
        RegisterNetEvent('carwash:deposit', function()
            local input = lib.inputDialog(_U('moneymanagementdeposit'), {
                { type = "input", label = _U('depositamount'), icon = 'fa-money-bill-transfer' },
                { type = "checkbox", label = _U('confirmprice') },
            })
            if input then
                
                local deposit = tonumber(input[1])
                if checknumber(deposit) then -- returns true if number
                    local checkbox = input[2]
                    if checkbox == nil then
                        Notification('error', _U('forgotconfirmdeposit'), _U('moneymanagementdeposit'))
                    end
                    if checkbox ~= nil and deposit then
                        --
                        ESX.TriggerServerCallback('carwash:deposit', function(data)
                            if data == true then
                                Notification('success', _U('depositsuccessfull'), _U('moneymanagementdeposit'))
                            else
                                Notification('error', _U('notenoughdeposit'), _U('moneymanagementdeposit'))
                            end
                        end, deposit)
                    end
                else
                    Notification('error', _U('invalidprice'), _U('moneymanagementdeposit'))
                end 
            end
        end)
        RegisterNetEvent('carwash:withdraw', function()
            local input = lib.inputDialog(_U('moneymanagementwithdraw'), {
                { type = "input", label = _U('depositamount'), icon = 'fa-money-bill-transfer' },
                { type = "checkbox", label = _U('confirmprice') },
            })
            if input then
                
                local withdraw = tonumber(input[1])
                if checknumber(withdraw) then -- returns true if number
                    local checkbox = input[2]
                    if checkbox == nil then
                        Notification('error', _U('forgotconfirmwithdraw'), _U('moneymanagementwithdraw'))
                    end
                    if checkbox ~= nil and withdraw then
                        --
                        ESX.TriggerServerCallback('carwash:withdraw', function(data)
                            if data == true then
                                Notification('success', _U('withdrawsuccessfull'), _U('moneymanagementwithdraw'))
                            else
                                Notification('error', _U('notenoughwithdraw'), _U('moneymanagementwithdraw'))
                            end 
                        end, withdraw)
                    end
                else
                    Notification('error', _U('invalidprice'), _U('moneymanagementwithdraw'))
                end 
            end
        end)
        RegisterNetEvent('carwash:setprice', function()
            local input = lib.inputDialog(_U('pricemenu'), {
                { type = "input", label = _U('newprice'), icon = 'fa-money-bill-transfer' },
                { type = "checkbox", label = _U('confirmprice') },
            })
            if input then
                
                local newprice = tonumber(input[1])
                if checknumber(newprice) then -- returns true if number
                    local checkbox = input[2]
                    if checkbox == nil then
                        Notification('error', _U('forgotconfirmprice'), _U('wash_title'))
                    end
                    if checkbox ~= nil and newprice then
                        Notification('success', _U('confirmpricesuccessfull'), _U('wash_title'))
                        TriggerServerEvent('carwash:setprice', newprice)
                    end
                else
                    Notification('error', _U('invalidprice'), _U('wash_title'))
                end 
            end
        end)
        AddEventHandler('onResourceStop', function(resourceName)
            if DoesEntityExist(prop) then
                DeleteEntity(prop) 
                DeleteObject(prop)
            end
        end)
    end
end

function checknumber(num)
    if type(num) == "number" then
        return true
    else
        return false
    end
end
