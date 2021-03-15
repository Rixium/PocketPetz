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

    playerInfo.CurrentZone = locationName;
    playerInfoStore:Set(playerInfo);

    playerSwitchedZone:FireClient(player, locationName);
end

function PlayerService.IsPlayerLegend(player) 
    local playerInfoStore = dataStore2(playerInfoData, player);
    local playerInfo = playerInfoStore:Get();

    if(playerInfo == nil) then return false end

    if(playerInfo.IsLegend == nil) then
        playerInfo.IsLegend = false;
        playerInfo.LegendExpiration = NOT_LEGEND;
    end
    
    if(playerInfo.LegendExpiration == PERMENANT_LEGEND) then
        playerInfo.IsLegend = true;
    elseif(os.time() >= playerInfo.LegendExpiration) then
        playerInfo.IsLegend = false;
        playerInfo.LegendExpiration = NOT_LEGEND;
    end

    if(playerInfo.LegendExpiration == NOT_LEGEND) then
        playerInfo.IsLegend = false;
    end

    playerInfoStore:Set(playerInfo);

    return playerInfo.IsLegend;
end

function PlayerService.MakeLegendForDays(player, days)
    local playerInfoStore = dataStore2(playerInfoData, player);
    local playerInfo = playerInfoStore:Get();

    playerInfo.LegendExpiration = os.time() + (days * 24 * 60 * 60);
    playerInfo.IsLegend = true;
    
    playerInfoStore:Set(playerInfo);
end

function PlayerService.MakePermenantLegend(player)
    local playerInfoStore = dataStore2(playerInfoData, player);
    local playerInfo = playerInfoStore:Get();

    playerInfo.IsLegend = true;
    playerInfo.LegendExpiration = PERMENANT_LEGEND;

    playerInfoStore:Set(playerInfo);
end

return PlayerService;