
-- Framework detection is auto so no need to set

-- Add item to config if MapIsItem = true
-- RSG v1
-- ['mapdetails']        = {['name'] = 'mapdetails',        ['label'] = 'Map Details',    ['weight'] = 125, ['type'] = 'item', ['image'] = 'map.png',        ['unique'] = false, ['useable'] = true,  ['shouldClose'] = true, ['combinable'] = nil, ['level'] = 0, ['description'] = 'A map with shared location details', ["created"] = nil, ["decay"] = 2.0, ["delete"] = true},

-- VORP
-- Use the provided SQL


Config = {}

Config.MapIsItem = true -- Set to false if you want to just use the command system instead of item
Config.MapItemName = "mapdetails"

Config.blidata = {name = "Shared Location", hash =-185399168}
Config.commandNameShare = {name = "sharemap", text1 = "Share the current map marker"}
Config.commandNameStop = {name = "sharemapdel", text1 = "Cancel the currently set map marker"}

Config.Text = {
    ["NoMapLoc"] = "Need to mark a location on the map before sharing it.",
    ["Cancelled"] = "Cancelled map sharing.",
    ["sameID"] = "You cannot share the waypoint with yourself.",
    ["SendMapLoc"] = "The location has been shared with ID: ",
    ["GetMapLoc"] = "You have received a shared map location near %s.",
    ["ArrivedLoc"] = "You have reached the marked location!",
    ["DelLoc"] = "The shared map marker has been removed.",
    ["ReceivedMapItem"] = "You have received a map with location details.",
    ["UseMapItem"] = "You have used the map. The location near %s is now marked.",
}