local PlayerService = {};

-- Imports
local serverScriptService = game:GetService("ServerScriptService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local itemList = require(serverScriptService.Server.Data.ItemList);
local players = game:GetService("Players");
local gotItemEvent = replicatedStorage.Common.Events.PlayerGotItemEvent;
local playerSwitchedZone = replicatedStorage.Common.Events.PlayerSwitchedZone;
local httpService = game:GetService("HttpService");

local dataStoreGet = require(serverScriptService.Server.DataStoreGet);
local dataStore2 = dataStoreGet.DataStore;

-- Variables
local NOT_LEGEND = -1;
local PERMENANT_LEGEND = -2;

local playerInfoData = "PlayerInfo";

-- Functions
function PlayerService.CreatePlayerInfo(player)
    local playerInfoStore = dataStore2(playerInfoData, player);
    local playerInfo = playerInfoStore:Get(nil);

    if(playerInfo ~= nil) then
        return 
    end

    playerInfoStore:Set({
        CurrentZone = "The Spawn",
        IsLegend = false,
        LegendExpiration = NOT_LEGEND
    });

    return playerInfo;
end

function PlayerService.GetPlayerInfo(player)
    local playerInfoStore = dataStore2(playerInfoData, player);
    local playerInfo = playerInfoStore:Get({ 
        CurrentZone = "The Spawn",
        IsLegend = false,
        LegendExpiration = NOT_LEGEND
    });

    playerInfoStore:Set(playerInfo);

    return playerInfo;
end

function PlayerService.SetPlayerLocation(player, locationName) 
    local playerInfoStore = dataStore2(playerInfoData, player);
    local playerInfo = playerInfoStore:Get({ 
        CurrentZone = locationName
    });

    local lastZone = playerInfo.CurrentZone;

    playerInfo.CurrentZone = locationName;
    playerInfoStore:Set(playerInfo);

    if(lastZone ~= locationName) then
        playerSwitchedZone:FireClient(player, locationName);
    end
end
function PlayerService.GetPlayerLocation(player) 
    local playerInfoStore = dataStore2(playerInfoData, player);
    local playerInfo = playerInfoStore:Get({ 
        CurrentZone = "The Spawn"
    });

    return playerInfo.CurrentZone;
end

function PlayerService.IsPlayerLegend(player) 
    local playerInfoStore = dataStore2(playerInfoData, player);
    local playerInfo = playerInfoStore:Get();

    if(playerInfo == nil) then return false end

    -- If they've never become a legend before, then we can set not legend here.
    if(playerInfo.LegendExpiration == nil) then
        playerInfo.LegendExpiration = NOT_LEGEND;
        playerInfoStore:Set(playerInfo);
    end

    return (playerInfo.LegendExpiration == PERMENANT_LEGEND or playerInfo.LegendExpiration > os.time());
end

function PlayerService.IsPlayerLifetimeLegend(player) 
    local playerInfoStore = dataStore2(playerInfoData, player);
    local playerInfo = playerInfoStore:Get();

    if(playerInfo == nil) then return false end

    -- If they've never become a legend before, then we can set not legend here.
    if(playerInfo.LegendExpiration == nil) then
        playerInfo.LegendExpiration = NOT_LEGEND;
        playerInfoStore:Set(playerInfo);
    end

    return playerInfo.LegendExpiration == PERMENANT_LEGEND;
end

function PlayerService.MakeLegendForHours(player, hours)
    local playerInfoStore = dataStore2(playerInfoData, player);
    local playerInfo = playerInfoStore:Get();

    local secondsToAdd = (hours * 60 * 60);

    if(playerInfo.LegendExpiration > os.time()) then
        playerInfo.LegendExpiration = playerInfo.LegendExpiration + secondsToAdd;
    else
        playerInfo.LegendExpiration = os.time() + secondsToAdd;
    end

    playerInfoStore:Set(playerInfo);
end

function PlayerService.MakeLegendForDays(player, days)
    PlayerService.MakeLegendForHours(player, days * 24);
end

function PlayerService.MakeLegendForLife(player)
    local playerInfoStore = dataStore2(playerInfoData, player);
    local playerInfo = playerInfoStore:Get();

    playerInfo.LegendExpiration = PERMENANT_LEGEND;

    playerInfoStore:Set(playerInfo);
end

return PlayerService;