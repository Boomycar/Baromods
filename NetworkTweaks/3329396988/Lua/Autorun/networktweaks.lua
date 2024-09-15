if CLIENT then return end

NetConfig.MaxHealthUpdateInterval = 0
NetConfig.LowPrioCharacterPositionUpdateInterval = 0
NetConfig.MaxEventPacketsPerUpdate = 8
NetConfig.RoundStartSyncDuration = 120
NetConfig.EventRemovalTime = 50
NetConfig.OldReceivedEventKickTime = 30
NetConfig.OldEventKickTime = 50
NetConfig.SparseHullUpdateInterval = 0.5
NetConfig.HullUpdateInterval = 0.1

LuaUserData.MakePropertyAccessible(Descriptors["Barotrauma.Networking.ServerSettings"], "MinimumMidRoundSyncTimeout")

if Game.ServerSettings and Game.ServerSettings.MinimumMidRoundSyncTimeout == 10 then
    Game.ServerSettings.MinimumMidRoundSyncTimeout = 100
end