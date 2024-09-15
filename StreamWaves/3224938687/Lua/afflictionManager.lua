if CLIENT and Game.IsMultiplayer then return end

require "functions"

local affliction_delay = 10
local last_affliction = Timer.GetTime()

local limbs_string = {"head", "leftarm", "rightarm", "leftleg", "rightleg", "torso"}

local limbs = {
    ["head"] = LimbType.Head,
    ["leftarm"] = LimbType.LeftArm,
    ["rightarm"] = LimbType.RightArm,
    ["leftleg"] = LimbType.LeftLeg,
    ["rightleg"] = LimbType.RightLeg,
    ["torso"] = LimbType.Torso
}

Hook.Add("think", "StreamWaves.affliction", function()
    local allow_spawn = Game.RoundStarted and not Level.IsLoadedOutpost
    if (allow_spawn) then
        if Timer.GetTime() > last_affliction + affliction_delay then
            last_affliction = Timer.GetTime()
            Networking.HttpGet("http://localhost:51525/fetch_affliction", function(result, status, headers)
                for i in string.gmatch(result, "[^|]+") do
                    local affliction = {}
                    for j in string.gmatch(i, "[^,]+") do
                        affliction[#affliction+1] = j
                    end
                    local affliction_name = affliction[1]
                    local affliction_part = affliction[2]
                    local part
                    if(affliction_part ~= nil) then
                        part = limbs[affliction_part]
                    end
                    if(part == nil) then
                        part = limbs[limbs_string[math.random(#limbs_string)]]
                    end
                    local victim = getRandomPlayedCharacter()
                    part = victim.AnimController.GetLimb(part)
                    local afflicationPrefab = AfflictionPrefab.Prefabs[affliction_name]
                    victim.CharacterHealth.ApplyAffliction(part, afflicationPrefab.Instantiate(math.random(0, 100)))
                end
            end, nil, nil)
        end
    else
        last_affliction = Timer.GetTime()
    end
end)