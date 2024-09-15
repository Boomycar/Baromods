Game.DisableDisconnectCharacter(true)
--if SERVER then return end  用这个会失效。
Hook.Add('think', 'disconnection unkillable-cloud', function()
updaterate = 1 -- seconds
time = Timer.GetTime() / updaterate
integer, decimal = math.modf(time)
if decimal < 0.02 / updaterate then
ok, res = pcall(function()
----------------------------------------------------------------
characterlist = Character.CharacterList
for i, char in ipairs(characterlist) do


    for i1, v in ipairs(characterlist) do
    count = 0
    chars = {}
    for i2, v1 in ipairs(characterlist) do
        if v1 == v then
            count = count + 1
            table.insert(chars, v1)
        end
    end

    if char.ClientDisconnected and count == 1 then  -- 掉线就恢复状态。
        char.Revive()
        char.PressureProtection = 1  -- 不一直设置为1就会设置为0。
        char.CharacterHealth.Unkillable = true  -- 开一次就一直生效。
        if not char.IsInPlayerSub then  -- 如果不在船里就传送到船里的制氧机旁边。
            for i2, item in ipairs(Item.ItemList) do
                if string.find(item.Tags, "oxygengenerator") then
                    char.TeleportTo(Vector2(item.WorldPosition["X"], item.WorldPosition["Y"]))
                    break
                end
            end
        end
    else
        char.CharacterHealth.Unkillable = false
    end

    if count == 2 then  -- 如果新建角色后有两个相同的角色，都不无敌。如果其中一个死了（一般是旧角色），那么新角色没死时掉线就会无敌。
        if not chars[1].IsDead and not chars[2].IsDead then
            char.CharacterHealth.Unkillable = false

        elseif not chars[1].IsDead and chars[1].ClientDisconnected and chars[2].IsDead then
            char.Revive()
            char.PressureProtection = 1  -- 不一直设置为1就会设置为0。
            char.CharacterHealth.Unkillable = true  -- 开一次就一直生效。
            if not char.IsInPlayerSub then  -- 如果不在船里就传送到船里的制氧机旁边。
                for i2, item in ipairs(Item.ItemList) do
                    if string.find(item.Tags, "oxygengenerator") then
                        char.TeleportTo(Vector2(item.WorldPosition["X"], item.WorldPosition["Y"]))
                        break
                    end
                end
            end
        end

        elseif chars[1].ClientDisconnected and chars[2].ClientDisconnected then  -- 如果两个角色都掉线了，都掉线无敌。
            char.Revive()
            char.PressureProtection = 1  -- 不一直设置为1就会设置为0。
            char.CharacterHealth.Unkillable = true  -- 开一次就一直生效。
            if not char.IsInPlayerSub then  -- 如果不在船里就传送到船里的制氧机旁边。
                for i2, item in ipairs(Item.ItemList) do
                    if string.find(item.Tags, "oxygengenerator") then
                        char.TeleportTo(Vector2(item.WorldPosition["X"], item.WorldPosition["Y"]))
                        break
                    end
                end
            end
    end

    end


end
-----------------------------------------------
end)
end
end)