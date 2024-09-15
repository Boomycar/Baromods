local allowFireCharacter = false
Hook.Patch(
    "Barotrauma.CrewManager",
    "RemoveCharacterInfo",
    function(instance, ptable)
        if not allowFireCharacter then
            ptable.PreventExecution = true
        end
        allowFireCharacter = false
        return nil
    end, Hook.HookMethodType.Before
)

Hook.Patch(
    "Barotrauma.CrewManager",
    "FireCharacter",
    function(instance, ptable)
        allowFireCharacter = true
    end, Hook.HookMethodType.Before
)

Clock = function()
    print("Checking for unconscious bots")
    for c in Character.CharacterList do
        if c.isBot and c.TeamID == 1 and c.isHuman then
            if c.isUnconscious or c.isDead then
                print("Reviving downed bot ", c.Name)
                c.Revive(removeAllAfflictions)
            end
        end
    end
end

Hook.Add(
    "roundStart",
    "foobar",
    function()
        print("Counting to 5")
        Timer.Wait(Clock, 5000)
    end
)