if CLIENT and Game.IsMultiplayer then return end

require "functions"

local wave_delay = 60*5
local last_wave = Timer.GetTime()

Hook.Add("think", "StreamWaves.wave", function()
    local allow_spawn = Game.RoundStarted and not Level.IsLoadedOutpost
    if (allow_spawn) then
        if Timer.GetTime() > last_wave + wave_delay then 
        
            last_wave = Timer.GetTime()

            Networking.HttpGet("http://localhost:51525/fetch", function(result, status, headers)
                -- if result is not nil or empty string print spawning wave
                if (result ~= nil and result ~= "" and status == 200) then
                    print("[StreamWaves] spawning wave")
                end
                for i in string.gmatch(result, "[^|]+") do
                    SpawnMonster(i)
                end
            end, nil, nil)
        end
    else
        last_wave = Timer.GetTime()
    end
end)