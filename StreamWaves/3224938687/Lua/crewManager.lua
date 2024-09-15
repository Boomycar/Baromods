if CLIENT and Game.IsMultiplayer then return end

require "functions"

local wave_delay = 15
local last_wave = Timer.GetTime()

Hook.Add("think", "StreamWaves.affliction", function()
    local allow_spawn = Game.RoundStarted
    if(not allow_spawn) then
        last_wave = Timer.GetTime()
        return true
    end
    if Timer.GetTime() < last_wave + wave_delay then 
        return true
    end

    last_wave = Timer.GetTime()
    Networking.HttpGet("http://localhost:51525/fetch_character", function(result, status, headers)
        for i in string.gmatch(result, "[^|]+") do
            local viewer = {}
            for j in string.gmatch(i, "[^,]+") do
                viewer[#viewer+1] = j
            end
            local viewer_name = viewer[1]
            local role_name = viewer[2]
            local info = CharacterInfo("human", viewer_name)
            info.Job = Job(JobPrefab.Get(role_name))

            local submarine = Submarine.MainSub
            local spawnPoint = WayPoint.SelectCrewSpawnPoints({info}, submarine)[1]

            if spawnPoint == nil then
                spawnPoint = getRandomPlayedCharacter().WorldPosition
            end

            local character = Character.Create(info, spawnPoint.WorldPosition, info.Name, 0, false, true)
            character.TeamID = CharacterTeamType.Team1
            character.GiveJobItems()
        end
    end, nil, nil)
end)