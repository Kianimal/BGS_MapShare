local active = false
local blip
local Framework = nil

-- Framework detection
Citizen.CreateThread(function()
    if GetResourceState("vorp_core") ~= "missing" then
        Framework = "VORP"
        TriggerEvent("getCore", function(core)
            VORPCore = core
        end)
    elseif GetResourceState("rsg-core") ~= "missing" then
        Framework = "RSG"
        RSGCore = exports['rsg-core']:GetCoreObject()
    end
end)

RegisterNetEvent('BGS_Mapshare:client:Received')
AddEventHandler('BGS_Mapshare:client:Received', function(data, district)
    if Framework == "VORP" and Config.MapIsItem == false then
        TriggerEvent("vorp:TipBottom", string.format(Config.Text["GetMapLoc"], district), 4000)
    elseif Framework == "RSG" and Config.MapIsItem == false then
        RSGCore.Functions.Notify(string.format(Config.Text["GetMapLoc"], district), "primary", 4000)
    end
    stop()
    Wait(1000)
    -- CREATE GPS
    StartGpsMultiRoute(1, true, true)
    AddPointToGpsMultiRoute(data.x, data.y, 0.0)
    SetGpsMultiRouteRender(true)
    -- CREATE BLIP
    blip = N_0x554d9d53f696d002(1664425300, data.x, data.y, 0.0)
    SetBlipSprite(blip, 1735233562, true)
    SetBlipScale(blip, 0.2)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, Config.blidata.name)
    
    active = true
    while active do
        Wait(1000)
        local pos = GetEntityCoords(PlayerPedId())
        local dist = #(vector3(pos.x, pos.y, 0.0) - vector3(data.x, data.y, 0.0))
        if dist < 20.0 then
            if Framework == "VORP" then
                TriggerEvent("vorp:TipBottom", Config.Text["ArrivedLoc"], 4000)
            elseif Framework == "RSG" then
                RSGCore.Functions.Notify(Config.Text["ArrivedLoc"], "success", 4000)
            end
            stop()
        end
    end
end)

RegisterCommand(Config.commandNameShare.name, function(source, args)
    local coords = GetWaypointCoords()
    if coords.x == 0.0 then
        if Framework == "VORP" then
            TriggerEvent("vorp:TipBottom", Config.Text["NoMapLoc"], 4000)
        elseif Framework == "RSG" then
            RSGCore.Functions.Notify(Config.Text["NoMapLoc"], "error", 4000)
        end
        return
    end
    
    local x, y, z = table.unpack(coords)
    local ZoneTypeId = 10
    local current_district = Citizen.InvokeNative(0x43AD8FC02B429D33, x, y, z, ZoneTypeId)
    local district_name = GetDistrictName(current_district)
    
    if Config.MapIsItem then
        TriggerServerEvent("BGS_Mapshare:server:Handleshare", GetPlayerServerId(PlayerId()), coords, district_name)
    else
        TriggerEvent("BGS_Selector:Start", function(targetPlayerId)
            if targetPlayerId then
                if targetPlayerId == GetPlayerServerId(PlayerId()) then
                    if Framework == "VORP" then
                        TriggerEvent("vorp:TipBottom", Config.Text["sameID"], 4000)
                    elseif Framework == "RSG" then
                        RSGCore.Functions.Notify(Config.Text["sameID"], "error", 4000)
                    end
                    return
                end
                TriggerServerEvent("BGS_Mapshare:server:Handleshare", targetPlayerId, coords, district_name)
            else
                if Framework == "VORP" then
                    TriggerEvent("vorp:TipBottom", Config.Text["Cancelled"], 4000)
                elseif Framework == "RSG" then
                    RSGCore.Functions.Notify(Config.Text["Cancelled"], "error", 4000)
                end
            end
        end)
    end
end)

function GetDistrictName(hash)
    local districts = {
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
    return districts[hash] or "Unknown District"
end

RegisterCommand(Config.commandNameStop.name, function(source, args)
    if active then
        if Framework == "VORP" then
            TriggerEvent("vorp:TipBottom", Config.Text["DelLoc"], 4000)
        elseif Framework == "RSG" then
            RSGCore.Functions.Notify(Config.Text["DelLoc"], "primary", 4000)
        end
        stop()
    end
end)

-- SUGGESTION
Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', "/"..Config.commandNameShare.name, Config.commandNameShare.text1)
    TriggerEvent('chat:addSuggestion', "/"..Config.commandNameStop.name, Config.commandNameStop.text1)
end)

function stop()
    active = false
    SetGpsMultiRouteRender(false)
    ClearGpsMultiRoute()
    RemoveBlip(blip)
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        stop()
    end
end)