Config = {}


Config.WebhookURL = "Url"
Config.WebhookAvatar = "https://imgur.com/xXbcnU7.png" 
Config.ScriptName = "RobinGCS Police Cars"
Config.ScriptAuthor = "RobinGCS"


Config.NPC = {
    model = "s_m_y_cop_01", 
    coords = vector4(442.78, -1021.5, 28.55, 58.55), 
    targetName = "police_car_dealer", 
    label = "Police Vehicle Dealership"
}

Config.VehicleSpawnLocation = vector4(444.52, -1017.97, 28.64, 80.29)


Config.PoliceVehicles = {
    ["Officer"] = {
        {model = "polgauntlet", label = "zieke auto", price = 1000},
        {model = "police2", label = "Police Buffalo", price = 2000}
    },
    ["sergeant"] = {
        {model = "police3", label = "Police Interceptor", price = 3000},
        {model = "fbi", label = "FBI SUV", price = 5000}
    },
    ["lieutenant"] = {
        {model = "fbi2", label = "FBI Rancher", price = 7000}
    }
}
