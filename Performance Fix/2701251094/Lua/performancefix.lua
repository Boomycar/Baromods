local invertedHighPriorityItems = {}
local invertedHighPriorityCharacters = {}
local highPriorityComponents = {}

local signalComponents = {}

if SERVER then
    Game.mapEntityUpdateInterval = PerformanceFix.Config.serverMapEntityUpdateInterval
    Game.characterUpdateInterval = PerformanceFix.Config.serverCharacterUpdateInterval

    highPriorityComponents = PerformanceFix.Config.serverComponentPriority

    for key, value in pairs(PerformanceFix.Config.serverItemHighPriority) do
        invertedHighPriorityItems[value] = key
    end

    for key, value in pairs(PerformanceFix.Config.highPriorityCharacters) do
        invertedHighPriorityCharacters[value] = key
    end

    Hook.Add("item.equip", "highPriorityHands", function(item, char)
        Game.RemovePriorityItem(item)
        Game.AddPriorityItem(item)
    end)
else
    local result, error = pcall(function()
        Game.mapEntityUpdateInterval = PerformanceFix.Config.clientMapEntityUpdateInterval
        Game.characterUpdateInterval = PerformanceFix.Config.clientCharacterUpdateInterval

        if Game.IsMultiplayer then
            Game.poweredUpdateInterval = PerformanceFix.Config.poweredUpdateInterval or 1
        end

        Timer.AccumulatorMax = (PerformanceFix.Config.accumulatorMax or 50) / 1000
    end)

    if error then
        printerror("The below error most likely was thrown because of an outdated Lua client, please consider updating.")
        printerror(error)
    end

    highPriorityComponents = PerformanceFix.Config.clientComponentPriority

    for key, value in pairs(PerformanceFix.Config.clientItemHighPriority) do
        invertedHighPriorityItems[value] = key
    end

    for key, value in pairs(PerformanceFix.Config.highPriorityCharacters) do
        invertedHighPriorityCharacters[value] = key
    end

    Hook.Add("item.equip", "highPriorityHands", function(item, char)
        Game.RemovePriorityItem(item)
        Game.AddPriorityItem(item)
    end)
end


Hook.Add("think", "signalUpdatePerformanceFix", function()
    for key, value in pairs(signalComponents) do
        value.SendSignal(tostring(Game.mapEntityUpdateInterval), "signal_out")
    end
end)

local function IsPriority(item)
    if item.HasTag("highpriority") or invertedHighPriorityItems[item.Prefab.Identifier.Value] ~= nil then
        return true
    end

    for _, comp in pairs(highPriorityComponents) do
        if item.GetComponentString(comp) ~= nil then
            return true
        end
    end

    return false
end

local function SetPriority()
    if CLIENT then
        for k, v in pairs(Item.ItemList) do
            if PerformanceFix.Config.allowSingleplayerPermanentConfigs and Game.IsSingleplayer then
                break
            end

            if string.find(v.Tags, "performancefix") then
                table.insert(signalComponents, v)
            end

            local light = v.GetComponentString("LightComponent")

            if light ~= nil then
                if PerformanceFix.Config.disableShadowCastingLights then
                    light.CastShadows = false
                end
                if PerformanceFix.Config.disableDrawBehindSubsLights then
                    light.DrawBehindSubs = false
                end
            end

            if PerformanceFix.Config.hideInGameWires then
                local wire = v.GetComponentString("Wire")

                if wire and #wire.Connections ~= 0 then
                    wire.Item.HiddenInGame = true
                end
            end

            if PerformanceFix.Config.hideInGameComponents then
                if v.HasTag("logic") then
                    v.HiddenInGame = true
                end
            end
        end
    end

    Game.ClearPriorityItem()
    Game.ClearPriorityCharacter()

    for key, value in pairs(Item.ItemList) do
        if IsPriority(value) then
            Game.AddPriorityItem(value)
        end
    end

    for key, value in pairs(Character.CharacterList) do
        if invertedHighPriorityCharacters[value.SpeciesName.Value] then
            Game.AddPriorityCharacter(value)
        end

        if value.Inventory ~= nil then
            local rightItem = value.Inventory.GetItemInLimbSlot(InvSlotType.RightHand)
            local leftItem = value.Inventory.GetItemInLimbSlot(InvSlotType.LeftHand)

            if rightItem ~= nil then
                Game.AddPriorityItem(rightItem)
            end

            if leftItem ~= nil then
                Game.AddPriorityItem(leftItem)
            end
        end
    end
end

Hook.Add("roundStart", "initRoundStart", function()
    Timer.Wait(function()
        SetPriority()
    end, 1000)
end)


Hook.Add("characterCreated", "addToPriority", function(character)
    if invertedHighPriorityCharacters[character.SpeciesName.Value] then
        Game.AddPriorityCharacter(character)
    end
end)

Hook.Add("item.created", "addToPriority", function (item)
    if IsPriority(item) then
        Game.AddPriorityItem(item)
    end
end)


SetPriority()
