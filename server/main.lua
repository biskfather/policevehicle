local QBCore = exports['qb-core']:GetCoreObject()

function generatePlate()
    local plate = "POL"
    local characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    for i = 1, 3 do
        plate = plate .. string.char(math.random(65, 90))
    end
    for i = 1, 2 do
        plate = plate .. math.random(0, 9)
    end
    return plate
end

function sendToDiscord(vehicle, price, playerName, steamName)
    print("Webhook function called")

    local embed = {
        {
            ["color"] = 3447003,
            ["title"] = "Vehicle Purchase",
            ["description"] = "**A vehicle has been purchased!**",
            ["fields"] = {
                {["name"] = "Vehicle", ["value"] = vehicle or "Onbekend", ["inline"] = true},
                {["name"] = "Price", ["value"] = "$" .. (price or "0"), ["inline"] = true},
                {["name"] = "Player", ["value"] = playerName or "Onbekend", ["inline"] = false}
             --   {["name"] = "Steam", ["value"] = steamName or "Onbekend", ["inline"] = false}  --- Not working i will fix later 
            },
            ["footer"] = {
                ["text"] = "RobinGCS Police Cars Logs",
                ["icon_url"] = "https://imgur.com/xXbcnU7.png"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    local payload = json.encode({
        username = "RobinGCS Police Cars",
        embeds = embed,
        avatar_url = "https://imgur.com/xXbcnU7.png"
    })

    print("Payload:", payload)

    PerformHttpRequest(Config.WebhookURL, function(err, text, headers)
        print("HTTP Response Code:", err)
        print("Response Text:", text)
    end, 'POST', payload, {['Content-Type'] = 'application/json'})
end

RegisterNetEvent('rs-policecars:buyVehicle', function(vehicleModel)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local grade = Player.PlayerData.job.grade.name
    local vehicles = Config.PoliceVehicles[grade]

    local query = 'SELECT * FROM player_vehicles WHERE citizenid = ? AND vehicle = ?'
    exports.oxmysql:fetch(query, {Player.PlayerData.citizenid, vehicleModel}, function(existingVehicles)
        if #existingVehicles > 0 then
            TriggerClientEvent('rs-policecars:confirmBuy', src, vehicleModel)
        else
            processVehiclePurchase(Player, vehicleModel, vehicles)
        end
    end)
end)

RegisterNetEvent('rs-policecars:buyVehicleConfirmed', function(vehicleModel)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local grade = Player.PlayerData.job.grade.name
    local vehicles = Config.PoliceVehicles[grade]

    local vehicleToBuy = nil
    for _, vehicle in pairs(vehicles) do
        if vehicle.model == vehicleModel then
            vehicleToBuy = vehicle
            break
        end
    end

    if vehicleToBuy then
        if Player.PlayerData.money.bank >= vehicleToBuy.price then
            Player.Functions.RemoveMoney('bank', vehicleToBuy.price, 'police-vehicle-purchase')

            local plate = generatePlate()

            local query = 'INSERT INTO player_vehicles (citizenid, vehicle, state, plate) VALUES (?, ?, ?, ?)'
            local parameters = {Player.PlayerData.citizenid, vehicleModel, 0, plate}
            exports.oxmysql:insert(query, parameters, function(result)
                if result then
                    local spawnCoords = Config.VehicleSpawnLocation
                    TriggerClientEvent('rs-policecars:spawnVehicle', src, vehicleModel, spawnCoords, plate)
                    TriggerClientEvent('QBCore:Notify', src, 'You got a ' .. vehicleToBuy.label .. ' purchased for $' .. vehicleToBuy.price, 'success')
                    
                    -- Sleutels genereren voor het voertuig
                    TriggerClientEvent('vehiclekeys:client:SetOwner', src, plate)

                    sendToDiscord(vehicleToBuy.label, vehicleToBuy.price, GetPlayerName(src), Player.PlayerData.steam)
                else
                    TriggerClientEvent('QBCore:Notify', src, 'Something went wrong with the purchase.', 'error')
                end
            end)
        else
            TriggerClientEvent('QBCore:Notify', src, 'You do not have enough money.', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'You cannot buy this vehicle.', 'error')
    end
end)

function processVehiclePurchase(Player, vehicleModel, vehicles)
    for _, vehicle in pairs(vehicles) do
        if vehicle.model == vehicleModel then
            if Player.PlayerData.money.bank >= vehicle.price then
                Player.Functions.RemoveMoney('bank', vehicle.price, 'police-vehicle-purchase')
                
                local plate = generatePlate()

                local query = 'INSERT INTO player_vehicles (citizenid, vehicle, state, plate) VALUES (?, ?, ?, ?)'
                local parameters = {Player.PlayerData.citizenid, vehicleModel, 0, plate}
                exports.oxmysql:insert(query, parameters, function(result)
                    if result then
                        local spawnCoords = Config.VehicleSpawnLocation
                        TriggerClientEvent('rs-policecars:spawnVehicle', Player.PlayerData.source, vehicleModel, spawnCoords, plate)
                        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, 'You got a ' .. vehicle.label .. ' purchased for $' .. vehicle.price, 'success')
                        
                        TriggerClientEvent('vehiclekeys:client:SetOwner', Player.PlayerData.source, plate)
                    else
                        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, 'Something went wrong with the purchase.', 'error')
                    end
                end)
            else
                TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, 'You do not have enough money.', 'error')
            end
        end
    end
end

QBCore.Functions.CreateCallback('rs-policecars:getAvailableVehicles', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local grade = Player.PlayerData.job.grade.name
    cb(Config.PoliceVehicles[grade] or {})
end)