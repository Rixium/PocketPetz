local PlayerTrackSet = {};

local dataPersistence = require(game.ServerScriptService.Server.DataPersistence.DataPersistence);
local moneyManager = require(game.ServerScriptService.Server.Statistics.MoneyManager);

local playerStatisticsDataStore = "PlayerStatistics";
local lastLoginData = "LastLogin";
local secondsToPassForLoginMoney = 60;
local loginRewardMoney = 100;


PlayerTrackSet.ActivePlayers = {
	
};


local function GetLastLogin(player)
	local dateStore = dataPersistence:GetDataStoreForPlayer(player, playerStatisticsDataStore);
	local lastLogin = dateStore:GetAsync(lastLoginData) or os.time();
	return lastLogin;
end


function AddPlayerMoneyBasedOnLastLogin(player)
	local lastLogin = GetLastLogin(player);
	local differenceFromNow = os.difftime(os.time(), lastLogin);

	if(differenceFromNow > secondsToPassForLoginMoney) then
		print("Player last logged in over " .. secondsToPassForLoginMoney .. " seconds ago, adding " .. loginRewardMoney .. " gold.");
		moneyManager.AddMoney(player, loginRewardMoney);
	end

	local dateStore = dataPersistence:GetDataStoreForPlayer(player, playerStatisticsDataStore);
end



function PlayerTrackSet.AddPlayer(player)
	local replicatedStorage = game:GetService("ReplicatedStorage");
	local playerJoinedEvent = replicatedStorage.Common.Events.PlayerJoinedEvent;
	playerJoinedEvent:Fire(player);
	
	PlayerTrackSet.ActivePlayers[player.UserId] = player;
	
	AddPlayerMoneyBasedOnLastLogin(player);
end



function PlayerTrackSet.RemovePlayer(player)
	local replicatedStorage = game:GetService("ReplicatedStorage");
	local playerLeftEvent = replicatedStorage.Common.Events.PlayerJoinedEvent;
	playerLeftEvent:Fire(player);
	
	local dateStore = dataPersistence:GetDataStoreForPlayer(player, playerStatisticsDataStore);
	
	dateStore:UpdateAsync(lastLoginData, function(oldTime)
		return os.time();
	end);
	
	PlayerTrackSet.ActivePlayers[player.UserId] = nil;
end

return PlayerTrackSet;