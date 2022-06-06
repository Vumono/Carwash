if Config.framework == 'final' then
    ESX = nil

    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

end

ESX.RegisterServerCallback('carwash:canafford', function(source, cb, price, location)
	local xPlayer = ESX.GetPlayerFromId(source)
    local cash = xPlayer.getAccount('money').money
    local location = location
    local price = tonumber(price)
    if price > cash then
        cb(false)
    else
        cb(true)
        xPlayer.removeAccountMoney('money', price)
        MySQL.query('SELECT balance FROM owned_carwash WHERE location = ?', {location}, function(result)
            if result then
                for k, v in pairs(result) do
                        local balance = v.balance
                        local newbalance = balance + price
                        MySQL.update("UPDATE `owned_carwash` SET `balance` = ? WHERE `location` = ?", {newbalance, location}, function(id)
                    end)
                end
            end
        end)
        
    end
end)

ESX.RegisterServerCallback('carwash:getinfo', function(source, cb, location)
	local xPlayer = ESX.GetPlayerFromId(source)
    local location = location


	MySQL.query('SELECT * FROM owned_carwash WHERE location = ?', {location}, function(result)
        if result then
            for _, v in pairs(result) do
                --print(v.owner, v.location, v.price, v.balance, v.buyprice)
            end 
            cb(result)
        end
    end)
end)

ESX.RegisterServerCallback('carwash:getowner', function(source, cb, location)
	local xPlayer = ESX.GetPlayerFromId(source)
    local location = location


	MySQL.query('SELECT * FROM owned_carwash WHERE location = ?', {location}, function(result)
        if result then
            for _, v in pairs(result) do
                if v.owner == xPlayer.getIdentifier() then
                    cb(true)
                else
                    cb(false)
                end
                --print(v.owner, v.location, v.price, v.balance)
            end 
        end
    end)
end)

ESX.RegisterServerCallback('carwash:buyWash', function(source, cb, location)
	local xPlayer = ESX.GetPlayerFromId(source)
    local bank = xPlayer.getAccount('bank').money
    local location = location
    local identifier = xPlayer.getIdentifier()
    MySQL.query('SELECT buyprice FROM owned_carwash WHERE location = ?', {location}, function(data)
        for k,v in pairs(data) do
            
            if bank > tonumber(v.buyprice) then
                xPlayer.removeAccountMoney('bank', tonumber(v.buyprice))
                MySQL.update('UPDATE owned_carwash SET owner = ?, balance = ? WHERE location = ?', {identifier, 0, location})
                cb(true)
            end
        end
    end)
   

end)

RegisterNetEvent('carwash:setprice', function(price)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    MySQL.update('UPDATE owned_carwash SET price = ? WHERE owner = ?', {price, identifier})
end)



ESX.RegisterServerCallback('carwash:deposit', function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local cash = xPlayer.getAccount('money').money
    if amount <= cash then
        MySQL.query('SELECT balance, owner, location FROM owned_carwash WHERE owner = ?', {identifier}, function(data)
            for k,v in pairs(data) do
                local newbalance = tonumber(v.balance) + amount
                    xPlayer.removeAccountMoney('money', amount)
                    MySQL.update('UPDATE owned_carwash SET balance = ? WHERE location = ? and owner = ?', {newbalance, v.location, identifier})
                    cb(true)
            end
        end)
    else
        cb(false)
    end
end)


ESX.RegisterServerCallback('carwash:withdraw', function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
        MySQL.query('SELECT balance, owner, location FROM owned_carwash WHERE owner = ?', {identifier}, function(data)
            for k,v in pairs(data) do
                if amount <= tonumber(v.balance) then
                    
                    local newbalance = tonumber(v.balance) - amount
                    MySQL.update('UPDATE owned_carwash SET balance = ? WHERE location = ? and owner = ?', {newbalance, v.location, identifier})
                    xPlayer.addAccountMoney('money', amount)
                    cb(true)
                else
                    cb(false)
                end
            end
        end)

end)

