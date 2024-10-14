local Framework = nil

-- Framework detection
if GetResourceState("vorp_core") ~= "missing" then
    Framework = "VORP"
    VORPCore = {}
    TriggerEvent("getCore", function(core)
        VORPCore = core
    end)
    VORPInv = exports.vorp_inventory:vorp_inventoryApi()
elseif GetResourceState("rsg-core") ~= "missing" then
    Framework = "RSG"
    RSGCore = exports['rsg-core']:GetCoreObject()
end

RegisterServerEvent('BGS_Mapshare:server:Handleshare')
AddEventHandler('BGS_Mapshare:server:Handleshare', function(tgt, coords, district)
    local _src = source 
    local _tgt = tonumber(tgt)

    if Config.MapIsItem then
        local info = {coords = coords, district = district}
        if Framework == "VORP" then
            VORPInv.addItem(_src, Config.MapItemName, 1, info)
            VORPCore.NotifyTip(_src, Config.Text.receivedMapItem, 4000)
        elseif Framework == "RSG" then
            local Player = RSGCore.Functions.GetPlayer(_src)
            Player.Functions.AddItem(Config.MapItemName, 1, false, info)
            TriggerClientEvent('RSGCore:Notify', _src, Config.Text.receivedMapItem, "success", 4000)
        end
    else  
        if Framework == "VORP" then
            VORPCore.NotifyTip(_src, Config.Text.sendMapLoc, 4000)
            VORPCore.NotifyTip(_tgt, string.format(Config.Text.getMapLoc, district), 4000)
        elseif Framework == "RSG" then
            TriggerClientEvent('RSGCore:Notify', _src, Config.Text.sendMapLoc, "primary", 4000)
            TriggerClientEvent('RSGCore:Notify', _tgt, string.format(Config.Text.getMapLoc, district), "primary", 4000)
        end
        
        TriggerClientEvent('BGS_Mapshare:client:Received', _tgt, coords, district)
    end
end)

if Config.MapIsItem then
    if Framework == "VORP" then
        VORPInv.RegisterUsableItem(Config.MapItemName, function(data)
            local _src = data.source
            local metadata = data.item.metadata
            if metadata and metadata.coords then
                VORPInv.subItem(_src, Config.MapItemName, 1, metadata)
                TriggerClientEvent('BGS_Mapshare:client:Received', _src, metadata.coords, metadata.district)
                VORPCore.NotifyTip(_src, string.format(Config.Text.useMapItem, metadata.district), 4000)
            end
        end)
    elseif Framework == "RSG" then
        RSGCore.Functions.CreateUseableItem(Config.MapItemName, function(source, item)
            local Player = RSGCore.Functions.GetPlayer(source)
            if item.info and item.info.coords then
                Player.Functions.RemoveItem(Config.MapItemName, 1, item.slot)
                TriggerClientEvent('BGS_Mapshare:client:Received', source, item.info.coords, item.info.district)
                TriggerClientEvent('RSGCore:Notify', source, string.format(Config.Text.useMapItem, item.info.district), "success", 4000)
            end
        end)
    end
end