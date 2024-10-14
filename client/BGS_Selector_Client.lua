-- BASE GAME SCRIPTS *//* Wartype *//* https://discord.gg/MyCDwpHWdG

if not BGS_Selector then
    BGS_Selector = {}
else
    return 
end

BGS_Selector.Config = {
    RaycastDistance = 8.0,
    MarkerSize = vector3(1.0, 1.0, 1.0),
    MarkerType = 0x94FDAE17, --  https://github.com/femga/rdr3_discoveries/blob/master/graphics/markers/marker_types.lua
    Colors = {
        PlayerHighlight = {0, 255, 0, 50},    -- Green for players
        NPCHighlight = {255, 0, 0, 50},       -- Red for NPCs
        SelectedHighlight = {255, 165, 0, 50} -- Orange for selected player
    },
    Prompts = {
        SelectPlayer = {
            Control = 0x8AAA0AD4,  -- Left ALT key
            Text = "Select Player"
        },
        MakeSelection = {
            Control = 0xE30CD707,  -- R key
            Text = "Confirm"
        },
        Cancel = {
            Control = 0xD9D0E1C0,  -- Spacebar
            Text = "Cancel"
        }
    }
}

-- Local variables
local isSelectionActive = false
local highlightedEntity = nil
local highlightColor = BGS_Selector.Config.Colors.NPCHighlight
local isPlayerSelected = false

function BGS_Selector.rotationToDirection(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

function BGS_Selector.rayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = BGS_Selector.rotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local _, hit, endCoords, _, entityHit = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return hit, endCoords, entityHit
end

function BGS_Selector.HandlePrompts(entity)
    local promptGroup = GetRandomIntInRange(0, 0xffffff)

    local makeSelectionPrompt = PromptRegisterBegin()
    PromptSetControlAction(makeSelectionPrompt, BGS_Selector.Config.Prompts.MakeSelection.Control)
    PromptSetText(makeSelectionPrompt, CreateVarString(10, "LITERAL_STRING", BGS_Selector.Config.Prompts.MakeSelection.Text))
    PromptSetEnabled(makeSelectionPrompt, true)
    PromptSetVisible(makeSelectionPrompt, true)
    PromptSetHoldMode(makeSelectionPrompt, true)
    PromptSetGroup(makeSelectionPrompt, promptGroup)
    PromptRegisterEnd(makeSelectionPrompt)

    local cancelPrompt = PromptRegisterBegin()
    PromptSetControlAction(cancelPrompt, BGS_Selector.Config.Prompts.Cancel.Control)
    PromptSetText(cancelPrompt, CreateVarString(10, "LITERAL_STRING", BGS_Selector.Config.Prompts.Cancel.Text))
    PromptSetEnabled(cancelPrompt, true)
    PromptSetVisible(cancelPrompt, true)
    PromptSetHoldMode(cancelPrompt, true)
    PromptSetGroup(cancelPrompt, promptGroup)
    PromptRegisterEnd(cancelPrompt)

    while isPlayerSelected do
        Citizen.Wait(0)
        
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local targetCoords = GetEntityCoords(entity)
        local distance = #(playerCoords - targetCoords)

        if distance <= BGS_Selector.Config.RaycastDistance then
            local promptName = CreateVarString(10, "LITERAL_STRING", "Player Actions")
            PromptSetActiveGroupThisFrame(promptGroup, promptName)

            if PromptHasHoldModeCompleted(makeSelectionPrompt) then
                local serverId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                isPlayerSelected = false
                isSelectionActive = false
                PromptDelete(makeSelectionPrompt)
                PromptDelete(cancelPrompt)
                return serverId
            elseif PromptHasHoldModeCompleted(cancelPrompt) then
                isPlayerSelected = false
                isSelectionActive = false
                PromptDelete(makeSelectionPrompt)
                PromptDelete(cancelPrompt)
                return nil
            end
        end

        local entityCoords = GetEntityCoords(entity)
        DrawMarker(BGS_Selector.Config.MarkerType, entityCoords.x, entityCoords.y, entityCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                   BGS_Selector.Config.MarkerSize.x, BGS_Selector.Config.MarkerSize.y, BGS_Selector.Config.MarkerSize.z, 
                   highlightColor[1], highlightColor[2], highlightColor[3], highlightColor[4], 
                   false, false, 2, false, nil, nil, false)
    end

    PromptDelete(makeSelectionPrompt)
    PromptDelete(cancelPrompt)
end

function BGS_Selector.StartSelection()
    isSelectionActive = true
    isPlayerSelected = false
    
    local promptGroup = GetRandomIntInRange(0, 0xffffff)

    local selectPlayerPrompt = PromptRegisterBegin()
    PromptSetControlAction(selectPlayerPrompt, BGS_Selector.Config.Prompts.SelectPlayer.Control)
    PromptSetText(selectPlayerPrompt, CreateVarString(10, "LITERAL_STRING", BGS_Selector.Config.Prompts.SelectPlayer.Text))
    PromptSetEnabled(selectPlayerPrompt, false) 
    PromptSetVisible(selectPlayerPrompt, true)
    PromptSetHoldMode(selectPlayerPrompt, true)
    PromptSetGroup(selectPlayerPrompt, promptGroup)
    PromptRegisterEnd(selectPlayerPrompt)
    
    local cancelPrompt = PromptRegisterBegin()
    PromptSetControlAction(cancelPrompt, BGS_Selector.Config.Prompts.Cancel.Control)
    PromptSetText(cancelPrompt, CreateVarString(10, "LITERAL_STRING", BGS_Selector.Config.Prompts.Cancel.Text))
    PromptSetEnabled(cancelPrompt, true)
    PromptSetVisible(cancelPrompt, true)
    PromptSetHoldMode(cancelPrompt, true)
    PromptSetGroup(cancelPrompt, promptGroup)
    PromptRegisterEnd(cancelPrompt)
    
    while isSelectionActive do
        Citizen.Wait(0)
        if not isPlayerSelected then
            local hit, endCoords, entityHit = BGS_Selector.rayCastGamePlayCamera(BGS_Selector.Config.RaycastDistance)
            
            local isLookingAtPlayer = false
            if hit == 1 and DoesEntityExist(entityHit) and IsEntityAPed(entityHit) and IsPedAPlayer(entityHit) then
                isLookingAtPlayer = true
                highlightColor = BGS_Selector.Config.Colors.PlayerHighlight
                highlightedEntity = entityHit
                local entityCoords = GetEntityCoords(entityHit)
                DrawMarker(BGS_Selector.Config.MarkerType, entityCoords.x, entityCoords.y, entityCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                           BGS_Selector.Config.MarkerSize.x, BGS_Selector.Config.MarkerSize.y, BGS_Selector.Config.MarkerSize.z, 
                           highlightColor[1], highlightColor[2], highlightColor[3], highlightColor[4], 
                           false, false, 2, false, nil, nil, false)
            else
                highlightedEntity = nil
            end

            PromptSetEnabled(selectPlayerPrompt, isLookingAtPlayer)
            local promptName = CreateVarString(10, "LITERAL_STRING", "Select Player")
            PromptSetActiveGroupThisFrame(promptGroup, promptName)

            if isLookingAtPlayer and PromptHasHoldModeCompleted(selectPlayerPrompt) then
                isPlayerSelected = true
                highlightColor = BGS_Selector.Config.Colors.SelectedHighlight
                local result = BGS_Selector.HandlePrompts(entityHit)
                PromptDelete(selectPlayerPrompt)
                PromptDelete(cancelPrompt)
                return result
            elseif PromptHasHoldModeCompleted(cancelPrompt) then
                isSelectionActive = false
                PromptDelete(selectPlayerPrompt)
                PromptDelete(cancelPrompt)
                return nil
            end
        end
    end
    
    PromptDelete(selectPlayerPrompt)
    PromptDelete(cancelPrompt)
    return nil
end

BGS_Selector.TriggerSelection = function(callback)
    if not isSelectionActive then
        local result = BGS_Selector.StartSelection()
        if callback then
            callback(result)
        end
        return result
    else
        if callback then
            callback(false)
        end
        return false
    end
end

-- Test command
--[[
RegisterCommand("testray", function(source, args, rawCommand)
    BGS_Selector.TriggerSelection(function(result)
        if result then
            if type(result) == "number" then
                TriggerEvent('chat:addMessage', {args = {"^2BGS Selector: Selected player's Server ID: " .. result}})
            else
                TriggerEvent('chat:addMessage', {args = {"^1BGS Selector: Selection failed."}})
            end
        else
            TriggerEvent('chat:addMessage', {args = {"^1BGS Selector: Selection cancelled or no player selected."}})
        end
    end)
end, false)
--]]