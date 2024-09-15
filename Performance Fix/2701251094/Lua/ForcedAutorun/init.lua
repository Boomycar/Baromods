if CLIENT then
    PerformanceFix = {}
    PerformanceFix.Path = ...

    if not File.Exists(PerformanceFix.Path .. "/config.json") then
        File.Write(PerformanceFix.Path .. "/config.json", json.serialize(dofile(PerformanceFix.Path .. "/Lua/defaultconfig.lua")))
    end
    
    PerformanceFix.Config = json.parse(File.Read(PerformanceFix.Path .. "/config.json"))

    Game.AddCommand("performancefix_reload", "reloads config", function ()
        dofile(PerformanceFix.Path .. "/Lua/performancefix.lua")
    end)

    dofile(PerformanceFix.Path .. "/Lua/performancefix_gui.lua")
    dofile(PerformanceFix.Path .. "/Lua/performancefix.lua")
end