


-- Framework detection is auto so no need to set

-- Add item to config if MapIsItem = true
-- RSG v1
-- ['mapdetails']        = {['name'] = 'mapdetails',        ['label'] = 'Map Details',    ['weight'] = 125, ['type'] = 'item', ['image'] = 'map.png',        ['unique'] = false, ['useable'] = true,  ['shouldClose'] = true, ['combinable'] = nil, ['level'] = 0, ['description'] = 'A map with shared location details', ["created"] = nil, ["decay"] = 2.0, ["delete"] = true},

-- VORP
-- Use the provided SQL


Config = {}
Config.MapIsItem = true -- Set to false if you want to just use the command system instead of item
Config.MapItemName = "mapdetails"

Config.blipdata = {name = "Shared Location", hash = -185399168}
Config.commandNameShare = {name = "sharemap", suggestion = "Share the current map location"}
Config.commandNameStop = {name = "sharemapdel", suggestion = "Cancel the shared map location"}

Config.Text = {
    noMapLoc = "Need to mark a location on the map before sharing it.",
    cancelled = "Cancelled map sharing.",
    sendMapLoc = "The location has been shared successfully.",
    getMapLoc = "You have received a map location near %s.",
    arrivedLoc = "You have reached the marked location!",
    delLoc = "The shared map location has been removed.",
    receivedMapItem = "You have created a map with a marked location.",
    useMapItem = "You have used the map. The location seems to be near %s.",
}

Config.Districts = {
    [2025841068] = "Bayou Nwa",
    [822658194] = "Big Valley",
    [1308232528] = "Bluewater Marsh",
    [-108848014] = "Cholla Springs",
    [1835499550] = "Cumberland",
    [426773653] = "Diez Coronas",
    [-2066240242] = "Gaptooth Ridge",
    [476637847] = "Great Plains",
    [-120156735] = "Grizzlies East",
    [1645618177] = "Grizzlies West",
    [-512529193] = "Guarma",
    [131399519] = "Heartlands",
    [892930832] = "Hennigan's Stead",
    [-1319956120] = "Perdido",
    [1453836102] = "Punta Orgullo",
    [-2145992129] = "Rio Bravo",
    [178647645] = "Roanoke Ridge",
    [-864275692] = "Scarlett Meadows",
    [1684533001] = "Tall Trees"
}