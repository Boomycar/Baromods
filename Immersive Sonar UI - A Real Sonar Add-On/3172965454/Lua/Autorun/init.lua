
ISUI = {} -- Immersive Sonar UI
ISUI.Name="Immersive Sonar UI"
ISUI.Version = "1.1.0.1" 
ISUI.VersionNum = 01000000 -- seperated into groups of two digits: 01020304 -> 1.2.3h4; major, minor, patch, hotfix
ISUI.Path = table.pack(...)[1]

-- server-side code (also run in singleplayer)
if (Game.IsMultiplayer and SERVER) or not Game.IsMultiplayer then

    -- Version and expansion display
    Timer.Wait(function() Timer.Wait(function()
        local runstring = "\n/// Running Immersive Sonar UI V. "..ISUI.Version.." ///\n"

        -- add dashes
        local linelength = string.len(runstring)+4
        local i = 0
        while i < linelength do runstring=runstring.."-" i=i+1 end
        print(runstring)
    end,1) end,1)
end

-- client-side code
if CLIENT then
	-- currently just do the file on next tick, otherwise it breaks item.lua onuse methods at their first line
	Timer.Wait(function()
		dofile(ISUI.Path.."/Lua/Scripts/Client/gunner_overlay.lua")--client-side
	end,1)
    print("ISUI - Gunner Overlay loaded.")
end