local QBCore = exports['qb-core']:GetCoreObject()
local lib = exports.ox_lib  

CreateThread(function()
    local npc = Config.NPC
    RequestModel(npc.model)
    while not HasModelLoaded(npc.model) do
        Wait(10)
    end

    local ped = CreatePed(4, npc.model, npc.coords.x, npc.coords.y, npc.coords.z - 1, npc.coords.w, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                event = 'rs-policecars:openMenu',
                icon = 'fa-solid fa-car',
                label = npc.label,
                canInteract = function()
                    QBCore.Functions.TriggerCallback('rs-policecars:getAvailableVehicles', function(vehicles)
                        TriggerEvent('rs-policecars:openMenu', vehicles)
                    end)
                    return true
                end
            }
        },
        distance = 2.0
    })
end)

RegisterNetEvent('rs-policecars:confirmBuy', function(vehicleModel)
    exports.ox_lib:registerContext({
        id = "vehicle_purchase_confirm",
        title = "Confirm Purchase",
        options = {
            {
                title = "Yes, buy the vehicle again",
                description = "You already have this vehicle, are you sure?",
                event = "rs-policecars:buyVehicleConfirmed",
                args = vehicleModel
            },
            {
                title = "No, cancel",
                description = "You already have this vehicle.",
                event = "rs-policecars:cancelPurchase"
            }
        }
    })

    exports.ox_lib:showContext("vehicle_purchase_confirm")
end)

RegisterNetEvent('rs-policecars:buyVehicleConfirmed', function(vehicleModel)
    TriggerServerEvent('rs-policecars:buyVehicleConfirmed', vehicleModel)
end)

RegisterNetEvent('rs-policecars:cancelPurchase', function()
    TriggerEvent('QBCore:Notify', 'Purchase canceled.', 'error')
end)


RegisterNetEvent('rs-policecars:buyVehicle', function(vehicleModel)
    


    if vehicleModel then
        TriggerServerEvent('rs-policecars:buyVehicle', vehicleModel)
    else
        print("No vehicle model provided!")
    end
end)

RegisterNetEvent('rs-policecars:spawnVehicle', function(vehicleModel, spawnCoords, plate)
    print("Try to spawn vehicle: " .. vehicleModel)

    local playerPed = PlayerPedId()

    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Wait(500)
    end

   

    
    local vehicle = CreateVehicle(vehicleModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w, true, false)

    if vehicle and DoesEntityExist(vehicle) then
        

        SetVehicleFuelLevel(vehicle, 100.0)

        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

        SetVehicleNumberPlateText(vehicle, plate)
        

    else
        print("Something went wrong when spawning the vehicle!")
    end
end)

RegisterNetEvent('rs-policecars:openMenu', function(vehicles)
    local options = {}

    for _, vehicle in pairs(vehicles) do
        table.insert(options, {
            title = vehicle.label,
            description = "Price: $" .. vehicle.price,
            event = "rs-policecars:buyVehicle",
            args = vehicle.model
        })
    end

    if #options > 0 then
        exports.ox_lib:registerContext({
            id = "police_vehicle_menu",
            title = "Police Vehicles",
            options = options
        })

        exports.ox_lib:showContext("police_vehicle_menu")
    else
        TriggerEvent('QBCore:Notify', 'No vehicles available for your rank.', 'error')
    end
end)
