local PlayerTrackSet = {};

local replicatedStorage = game:GetService("ReplicatedStorage");

local playerJoinedEvent = replicatedStorage.Common.Events.PlayerJoinedEvent;
local playerLeftEvent = replicatedStorage.Common.Events.PlayerJoinedEvent;

local dataPersistence = require(game.ServerScriptService.Server.DataPersistence.DataPersistence);
local moneyManager = require(game.ServerScriptService.Server.Statistics.MoneyManager);

local playerStatisticsDataStore = "PlayerStatistics";

local firstLoginTime = "FirstLogin";
local lastLoginData = "LastLogin";
local secondsToPassForLoginMoney = 60;
local loginRewardMoney = 100;

-- Store all of the current logged in players.
PlayerTrackSet.ActivePlayers = {
	
};

-- Store a reference to the players statistics data store.
PlayerTrackSet.ActivePlayersStatistics = {
	
};

-- Store all players local statistics, to be read on login, and saved on logout.
PlayerTrackSet.LocalStatistics = {
	
};

-- Uses the players local statistics, figures out if a player has logged in before, otherwise sets it to now.
local function GetLastLogin(player)
	local playerStatistics = PlayerTrackSet.ActivePlayersStatistics[player.UserId];
	local lastLogin = playerStatistics:GetAsync(lastLoginData) or os.time();
	return lastLogin;
end

-- Run on player login, to make sure all the statistics are ready in for the player.
function PlayerTrackSet.Login(player)
	local playerStatisticStore = dataPersistence:GetDataStoreForPlayer(player, playerStatisticsDataStore);

	PlayerTrackSet.ActivePlayersStatistics[player.UserId] = playerStatisticStore;
	PlayerTrackSet.ActivePlayers[player.UserId] = player;

	-- Create an empty table for the players locals.
	local playersLocals = {};
	
	-- Set the first login time of the locals to whatever is stored, or nil.
	playersLocals[firstLoginTime] = playerStatisticStore:GetAsync(firstLoginTime) or nil;

	-- Finally save all players locals in to local statistics
	PlayerTrackSet.LocalStatistics[player.UserId] = playersLocals;
end

-- Run on player logout, so that we can be sure we save all players statistics to the datastore.
function PlayerTrackSet.Logout(player)
	-- Get the persistant data store for statistics.
	local playerStatisticsDataStore = PlayerTrackSet.ActivePlayersStatistics[player.UserId];
	-- Get the players local statistic set.
	local playersLocals = PlayerTrackSet.LocalStatistics[player.UserId];

	-- We're gonna iterate over every statistic stored locally, and set it in the data store.
	for index, value in pairs(playersLocals) do
		playerStatisticsDataStore:UpdateAsync(index, function(oldValue)
			return value;
		end);
	end 
	
end

function AddPlayerMoneyBasedOnLastLogin(player)
	local lastLogin = GetLastLogin(player);
	local differenceFromNow = os.difftime(os.time(), lastLogin);

	if(differenceFromNow > secondsToPassForLoginMoney) then
		print("Player last logged in over " .. secondsToPassForLoginMoney .. " seconds ago, adding " .. loginRewardMoney .. " gold.");
		moneyManager.AddMoney(player, loginRewardMoney);
	end
end

function PlayerTrackSet.AddPlayer(player)
	playerJoinedEvent:Fire(player);
	AddPlayerMoneyBasedOnLastLogin(player);
end

function PlayerTrackSet.RemovePlayer(player)
	playerLeftEvent:Fire(player);
	
	local playerStatistics = PlayerTrackSet.ActivePlayersStatistics[player.UserId];
	
	playerStatistics:UpdateAsync(lastLoginData, function(oldTime)
		return os.time();
	end);
	
	PlayerTrackSet.ActivePlayers[player.UserId] = nil;
	PlayerTrackSet.ActivePlayersStatistics[player.UserId] = nil;
end

function PlayerTrackSet.FirstTime(player)
	local playerStatistics = PlayerTrackSet.ActivePlayersStatistics[player.UserId];
	local isFirstTime = PlayerTrackSet.LocalStatistics[player.UserId][firstLoginTime] == nil;

	if(isFirstTime) then
		PlayerTrackSet.LocalStatistics[player.UserId][firstLoginTime] = os.time();
	end

	return isFirstTime;
end

return PlayerTrackSet;