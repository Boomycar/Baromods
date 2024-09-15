
local ammoloaded = false

local loadeditemsquality = {}

function unloadammoquality()
    ammoloaded = false
    it = 0
    for item in loadeditemsquality do
        if item != nil then 
            qualitycomp = nil
            for subelement in item.ConfigElement.Elements() do
                if subelement.Name.ToString() == "Quality" then
                    subelement.Remove()
                    loadeditemsquality[it] = nil
                    break
                end
            end
        end
        it = it +1
    end
end

function loadammoquality()
    qualitycomp = nil
    it = 0

    for item in ItemPrefab.Prefabs do
        if item.Identifier.ToString() == "dummyammo" then
            for subelement in item.ConfigElement.Elements() do
                if subelement.Name.ToString() == "Quality" then
                    qualitycomp = subelement
                    break
                end
            end
        end
    end

    if qualitycomp != nil then
        local ammoloaded = true
        for item in ItemPrefab.Prefabs do
            local hasquality = false
            local notadd = false
            local isammo = false

            for tag in item.Tags do
                if tag == "noqualityammobox" then
                    notadd = true
                end
                if tag == "ammobox" or tag == "coilgunammo" then
                    isammo = true
                    for subelement in item.ConfigElement.Elements() do
                        if subelement.Name.ToString() == "Quality" then
                            hasquality = true
                            break
                        end
                    end
                end
            end

            if isammo == true then
                for subelement in item.ConfigElement.Elements() do
                    if subelement.Name.ToString() == "Quality" then
                        hasquality = true
                        break
                    end
                end

                if  hasquality == false and notadd == false then
                    item.ConfigElement.Add(qualitycomp)
                    loadeditemsquality[it] = item
                    it = it +1
                    --print(item)
                end

            end
            
        end
    end
end

if (SERVER and Game.IsMultiplayer == true) or Game.IsSingleplayer then
    -- When we get the quality of an ammobox, we interpret the tag as 'weapon' to get extra quality boosts from talents
    Hook.Patch(
        "Barotrauma.CharacterInfo",
        "GetSavedStatValue",
        {
        "Barotrauma.StatTypes",
        "Barotrauma.Identifier"
        },
        function(instance, ptable)
            if ptable["statType"] == 36 then
                if ptable["statIdentifier"] == "ammobox" or ptable["statIdentifier"] == "coilgunammo" then
                    ptable["statIdentifier"] = "weapon"
                end
            end
    end, Hook.HookMethodType.Before)

    -- We make sure that is an ammobox has the 'ammobox' and 'weapon' tags, we do not add more quality than necessary.
    Hook.Patch(
        "Barotrauma.Items.Components.Fabricator",
        "GetFabricatedItemQuality",
        {
            "Barotrauma.FabricationRecipe",
            "Barotrauma.Character"
        },
        function(instance, ptable)
            local userinfo = ptable["user"].info

            local weapon = false
            local ammobox = false
            local coilgunammo = false

            for tag in ptable["fabricatedItem"].TargetItem.Tags do
                if tag == "weapon" then
                    weapon = true
                end
                if tag == "ammobox" then
                    ammobox = true
                end
                if tag == "coilgunammo" then
                    coilgunammo = true
                end
            end

            if ammobox == true  then
                local boost = 0
                if weapon == true then 
                    boost = boost + userinfo.GetSavedStatValue(37, "weapon")
                end
                if coilgunammo == true then
                    boost = boost + userinfo.GetSavedStatValue(37, "weapon")
                end

                return ptable.OriginalReturnValue - boost
            end

    end, Hook.HookMethodType.After)
end

if SERVER then
    -- Load the ammo quality first
    loadammoquality()

    -- Notify all clients to do the same
    local message = Networking.Start("reloadammo")
    for cl in Client.ClientList do
        --print("Send client 1 load")
        Networking.Send(message, cl.Connection)
    end

    -- Answer client pings to enable them to load the ammo
    Networking.Receive("hasqualityammo", function(message, client)
        --print("Send client 2 load")
        local message = Networking.Start("reloadammo")
        Networking.Send(message, client.Connection)
    end)

end

if CLIENT then
    -- SP Client
    if Game.IsSingleplayer == true then
        loadammoquality()
    -- MP Client
    else
         -- Ping to check if server has loaded the ammo
        local message = Networking.Start("hasqualityammo")
        Networking.Send(message)

        -- Load the ammo once the servers asks us to do so
        Networking.Receive("reloadammo", function(message)
            --print("CLIENT LOAD")
            loadammoquality()
        end)
    end

    Hook.Add("stop", "onstop", function()
        print("Cleaning quality ammo...")
        unloadammoquality()
    end)

end
