-- BGS_Selector.lua *//* Wartype
local CoreObject = nil
local Config = {
    RaycastDistance = 8.0,
    MarkerSize = vector3(1.0, 1.0, 1.0),
    MarkerType = 0x94FDAE17,  -- Cylinder marker // https://github.com/femga/rdr3_discoveries/blob/master/graphics/markers/marker_types.lua
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
local highlightColor = Config.Colors.NPCHighlight
local isPlayerSelected = false

local function rotationToDirection(rotation)
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

local function rayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = rotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local _, hit, endCoords, _, entityHit = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return hit, endCoords, entityHit
end

local function HandlePrompts(entity)
    local promptGroup = GetRandomIntInRange(0, 0xffffff)

    local makeSelectionPrompt = PromptRegisterBegin()
    PromptSetControlAction(makeSelectionPrompt, Config.Prompts.MakeSelection.Control)
    PromptSetText(makeSelectionPrompt, CreateVarString(10, "LITERAL_STRING", Config.Prompts.MakeSelection.Text))
    PromptSetEnabled(makeSelectionPrompt, true)
    PromptSetVisible(makeSelectionPrompt, true)
    PromptSetHoldMode(makeSelectionPrompt, true)
    PromptSetGroup(makeSelectionPrompt, promptGroup)
    PromptRegisterEnd(makeSelectionPrompt)

    local cancelPrompt = PromptRegisterBegin()
    PromptSetControlAction(cancelPrompt, Config.Prompts.Cancel.Control)
    PromptSetText(cancelPrompt, CreateVarString(10, "LITERAL_STRING", Config.Prompts.Cancel.Text))
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

        if distance <= Config.RaycastDistance then
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
        DrawMarker(Config.MarkerType, entityCoords.x, entityCoords.y, entityCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                   Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, 
                   highlightColor[1], highlightColor[2], highlightColor[3], highlightColor[4], 
                   false, false, 2, false, nil, nil, false)
    end

    PromptDelete(makeSelectionPrompt)
    PromptDelete(cancelPrompt)
end

local function StartSelection()
    isSelectionActive = true
    isPlayerSelected = false
    
    local promptGroup = GetRandomIntInRange(0, 0xffffff)

    local selectPlayerPrompt = PromptRegisterBegin()
    PromptSetControlAction(selectPlayerPrompt, Config.Prompts.SelectPlayer.Control)
    PromptSetText(selectPlayerPrompt, CreateVarString(10, "LITERAL_STRING", Config.Prompts.SelectPlayer.Text))
    PromptSetEnabled(selectPlayerPrompt, false)  -- Start with the prompt disabled
    PromptSetVisible(selectPlayerPrompt, true)   -- Always keep the prompt visible
    PromptSetHoldMode(selectPlayerPrompt, true)
    PromptSetGroup(selectPlayerPrompt, promptGroup)
    PromptRegisterEnd(selectPlayerPrompt)
    
    local cancelPrompt = PromptRegisterBegin()
    PromptSetControlAction(cancelPrompt, Config.Prompts.Cancel.Control)
    PromptSetText(cancelPrompt, CreateVarString(10, "LITERAL_STRING", Config.Prompts.Cancel.Text))
    PromptSetEnabled(cancelPrompt, true)  -- Always enabled
    PromptSetVisible(cancelPrompt, true)
    PromptSetHoldMode(cancelPrompt, true)
    PromptSetGroup(cancelPrompt, promptGroup)
    PromptRegisterEnd(cancelPrompt)
    
    while isSelectionActive do
        Citizen.Wait(0)
        if not isPlayerSelected then
            local hit, endCoords, entityHit = rayCastGamePlayCamera(Config.RaycastDistance)
            
            local isLookingAtPlayer = false
            if hit == 1 and DoesEntityExist(entityHit) and IsEntityAPed(entityHit) and IsPedAPlayer(entityHit) then
                isLookingAtPlayer = true
                highlightColor = Config.Colors.PlayerHighlight
                highlightedEntity = entityHit
                local entityCoords = GetEntityCoords(entityHit)
                DrawMarker(Config.MarkerType, entityCoords.x, entityCoords.y, entityCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                           Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, 
                           highlightColor[1], highlightColor[2], highlightColor[3], highlightColor[4], 
                           false, false, 2, false, nil, nil, false)

                            -- Enable for NPCs 
                            --          |   
                            --          v
            -- elseif hit == 1 and DoesEntityExist(entityHit) and IsEntityAPed(entityHit) then
            --     highlightColor = Config.Colors.NPCHighlight
            --     highlightedEntity = entityHit
            --     local entityCoords = GetEntityCoords(entityHit)
            --     DrawMarker(Config.MarkerType, entityCoords.x, entityCoords.y, entityCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
            --                Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, 
            --                highlightColor[1], highlightColor[2], highlightColor[3], highlightColor[4], 
            --                false, false, 2, false, nil, nil, false)
            else
                highlightedEntity = nil
            end

            -- Enable or disable the prompt based on whether we're looking at a player
            PromptSetEnabled(selectPlayerPrompt, isLookingAtPlayer)

            -- Always display the prompt group
            local promptName = CreateVarString(10, "LITERAL_STRING", "Select Player")
            PromptSetActiveGroupThisFrame(promptGroup, promptName)

            if isLookingAtPlayer and PromptHasHoldModeCompleted(selectPlayerPrompt) then
                isPlayerSelected = true
                highlightColor = Config.Colors.SelectedHighlight
                local result = HandlePrompts(entityHit)
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

RegisterNetEvent("BGS_Selector:Start")
AddEventHandler("BGS_Selector:Start", function(cb)
    if not isSelectionActive then
        local result = StartSelection()
        cb(result)
    else
        cb(false)
    end
end)

-- Test command
RegisterCommand("testray", function(source, args, rawCommand)
    if not isSelectionActive then
        TriggerEvent('chat:addMessage', {args = {"^3BGS Selector: Please select a player."}})
        TriggerEvent("BGS_Selector:Start", function(result)
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
    else
        TriggerEvent('chat:addMessage', {args = {"^1BGS Selector: Selection is already active."}})
    end
end, false)

-- print("BGS_Selector loaded. Use /testray to test the player selection.")