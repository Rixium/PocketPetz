local npcCreator = require(game.Players.LocalPlayer.PlayerScripts.Client.Creators.NpcCreator);

local npcPlacements = workspace.NPCs;

for index, placement in pairs(npcPlacements:GetChildren()) do
    npcCreator.New(placement);
end