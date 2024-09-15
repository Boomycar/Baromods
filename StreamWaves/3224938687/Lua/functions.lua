function SpawnMonster(name)
    local sub_width = Submarine.MainSub.CalculateDimensions(true).Width
    local sub_height = Submarine.MainSub.CalculateDimensions(true).Height

    -- Calculate radius of the circle based on submarine size
    local radius = math.floor(math.sqrt(sub_width * sub_width + sub_height * sub_height)) * 0.75
    local posx = Submarine.MainSub.WorldPosition.X
    local posy = Submarine.MainSub.WorldPosition.Y

    -- Angle (in radians) around the circle
    local angle = math.rad(math.random(1, 360))

    -- Calculate new position
    local spawn_posx = posx + radius * math.cos(angle)
    local spawn_posy = posy + radius * math.sin(angle)

    local pos = Vector2(spawn_posx, spawn_posy)

    if(Level.Loaded.IsPositionInsideWall(pos)) then
        print("cannot spawn creature adding to queue again")
        Networking.HttpGet("http://localhost:51525/add/" .. name, function(result, status, headers) end)
    else
        Entity.Spawner.AddCharacterToSpawnQueue(name, pos)
    end
end

function getRandomPlayedCharacter()
    local allowed_spawner = {}
    for key, character in pairs(Character.CharacterList) do
        if (character.IsHuman and not character.IsDead and character.IsRemotePlayer) then
            table.insert(allowed_spawner, character)
        end
    end
    
    return allowed_spawner[math.random(#allowed_spawner)]
end
