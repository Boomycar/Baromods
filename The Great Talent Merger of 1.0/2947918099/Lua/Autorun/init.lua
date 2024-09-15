
TGTM = {} -- The Great Talent Merger of 1.0
TGTM.Name="Talent Merger NT patches"
TGTM.Version = "1.0"
TGTM.Path = table.pack(...)[1]
Timer.Wait(function() if NTC ~= nil and NTC.RegisterExpansion ~= nil then NTC.RegisterExpansion(TGTM) end end,1)

-- server-side code (also run in singleplayer)
if (Game.IsMultiplayer and SERVER) or not Game.IsMultiplayer then

    Timer.Wait(function()
        if NTC == nil then
            print("The Great Talent Merger of 1.0 - Neurotrauma compatability patch not loaded: If you're not running Neurotrauma ignore this")
            return
        end

        dofile(TGTM.Path.."/Lua/Scripts/NTCorePatch.lua")

        if NTCyb == nil then
            print("The Great Talent Merger of 1.0 - NT cybernetics compatability patch not loaded: If you're not using NT Cybernetics, ignore this")
        else
            dofile(TGTM.Path.."/Lua/Scripts/NTCybPatch.lua")
        end

        if NTP == nil then
            print("The Great Talent Merger of 1.0 - NT Pharmacy compatability patch not loaded: If you're not using NT Pharmacy, ignore this")
        else
            dofile(TGTM.Path.."/Lua/Scripts/NTPharmacyPatch.lua")
        end
    end,1)

end