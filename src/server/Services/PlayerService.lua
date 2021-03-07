local PlayerService = {};

-- Imports
local serverScriptService = game:GetService("ServerScriptService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local itemList = require(serverScriptService.Server.Data.ItemList);
local players = game:GetService("Players");
local gotItemEvent = replicatedStorage.Common.Events.PlayerGotItemEvent;
local httpService = game:GetService("HttpService");

local dataStoreGet = require(serverScriptService.Server.DataStoreGet);
local dataStore2 = dataStoreGet.DataStore;

-- Variables
local playerInfoData = "PlayerInfo";

-- Functions
function PlayerService.CreatePlayerInfo(player)
    local playerInfoStore = dataStore2(playerInfoData, player);
    local playerInfo = playerInfoStore:Get(nil);

    if(playerInfo ~= nil) then
        return 
    end

    playerInfoStore:Set({
        CurrentZone = "The Spawn"
    });

    return playerInfo;
end

function PlayerService.GetPlayerInfo(player)
    local playerInfoStore = dataStore2(playerInfoData, player);
    local playerInfo = playerInfoStore:Get({ 
        CurrentZone = "The Spawn"
    });

    playerInfoStore:Set(playerInfo);

    return playerInfo;
end

return PlayerService;