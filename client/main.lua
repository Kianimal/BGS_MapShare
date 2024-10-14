local active = false
local blip
local Framework = nil

if GetResourceState("vorp_core") ~= "missing" then
    Framework = "VORP"
    VORPCore = {}
    TriggerEvent("getCore", function(core)
        VORPCore = core
    end)
elseif GetResourceState("rsg-core") ~= "missing" then
    Framework = "RSG"
    RSGCore = exports['rsg-core']:GetCoreObject()
end

RegisterNetEvent('BGS_Mapshare:client:Received')
AddEventHandler('BGS_Mapshare:client:Received', function(data, district)
    if Framework == "VORP" and not Config.MapIsItem then
        TriggerEvent("vorp:TipBottom", string.format(Config.Text.getMapLoc, district), 4000)
    elseif Framework == "RSG" and not Config.MapIsItem then
        RSGCore.Functions.Notify(string.format(Config.Text.getMapLoc, district), "primary", 4000)
    end
    stop()
    Wait(1000)
    StartGpsMultiRoute(1, true, true)
    AddPointToGpsMultiRoute(data.x, data.y, 0.0)
    SetGpsMultiRouteRender(true)
    blip = N_0x554d9d53f696d002(1664425300, data.x, data.y, 0.0)
    SetBlipSprite(blip, 1735233562, true)
    SetBlipScale(blip, 0.2)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, Config.blipdata.name)
    
    active = true
    while active do
        Wait(1000)
        local pos = GetEntityCoords(PlayerPedId())
        local dist = #(vector3(pos.x, pos.y, 0.0) - vector3(data.x, data.y, 0.0))
        if dist < 20.0 then
            if Framework == "VORP" then
                TriggerEvent("vorp:TipBottom", Config.Text.arrivedLoc, 4000)
            elseif Framework == "RSG" then
                RSGCore.Functions.Notify(Config.Text.arrivedLoc, "success", 4000)
            end
            stop()
        end
    end
end)

RegisterCommand(Config.commandNameShare.name, function(source, args)
    local coords = GetWaypointCoords()
    if coords.x == 0.0 then
        if Framework == "VORP" then
            TriggerEvent("vorp:TipBottom", Config.Text.noMapLoc, 4000)
        elseif Framework == "RSG" then
            RSGCore.Functions.Notify(Config.Text.noMapLoc, "error", 4000)
        end
        return
    end
    
    local x, y, z = table.unpack(coords)
    local ZoneTypeId = 10
    local current_district = Citizen.InvokeNative(0x43AD8FC02B429D33, x, y, z, ZoneTypeId)
    local district_name = Config.Districts[current_district] or "Unknown District"
    
    if Config.MapIsItem then
        TriggerServerEvent("BGS_Mapshare:server:Handleshare", GetPlayerServerId(PlayerId()), coords, district_name)
    else
        if BGS_Selector then
            BGS_Selector.TriggerSelection(function(targetPlayerId)
                if targetPlayerId then
                    TriggerServerEvent("BGS_Mapshare:server:Handleshare", targetPlayerId, coords, district_name)
                else
                    if Framework == "VORP" then
                        TriggerEvent("vorp:TipBottom", Config.Text.cancelled, 4000)
                    elseif Framework == "RSG" then
                        RSGCore.Functions.Notify(Config.Text.cancelled, "error", 4000)
                    end
                end
            end)
        else
            if Framework == "VORP" then
                TriggerEvent("vorp:TipBottom", "Player selector is not available", 4000)
            elseif Framework == "RSG" then
                RSGCore.Functions.Notify("Player selector is not available", "error", 4000)
            end
        end
    end
end)

RegisterCommand(Config.commandNameStop.name, function(source, args)
    if active then
        if Framework == "VORP" then
            TriggerEvent("vorp:TipBottom", Config.Text.delLoc, 4000)
        elseif Framework == "RSG" then
            RSGCore.Functions.Notify(Config.Text.delLoc, "primary", 4000)
        end
        stop()
    end
end)

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', "/"..Config.commandNameShare.name, Config.commandNameShare.suggestion)
    TriggerEvent('chat:addSuggestion', "/"..Config.commandNameStop.name, Config.commandNameStop.suggestion)
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