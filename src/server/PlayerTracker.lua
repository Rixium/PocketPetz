local PlayerTrackSet = {};

local serverScriptService = game:GetService("ServerScriptService");
local replicatedStorage = game:GetService("ReplicatedStorage");

local dataStoreGet = require(serverScriptService.Server.DataStoreGet);
local dataStore2 = dataStoreGet.DataStore;

local playerJoinedEvent = replicatedStorage.Common.Events.PlayerJoinedEvent;
local playerLeftEvent = replicatedStorage.Common.Events.PlayerJoinedEvent;

local moneyManager = require(serverScriptService.Server.Statistics.MoneyManager);

local firstLoginTime = "FirstLogin";
local lastLoginData = "LastLogin";

local secondsToPassForLoginMoney = 60;
local loginRewardMoney = 100;

-- Store all of the current logged in players.
PlayerTrackSet.ActivePlayers = {
	
};

local function GetLastLogin(player)
	local lastLoginStore = dataStore2(lastLoginData, player);
	return lastLoginStore:Get(os.time());
end

local function SetLastLogin(player, time)
	local lastLoginStore = dataStore2(lastLoginData, player);
	lastLoginStore:Set(time);
end

function PlayerTrackSet.Login(player)
	PlayerTrackSet.ActivePlayers[player.UserId] = player;

	playerJoinedEvent:Fire(player);
	AddPlayerMoneyBasedOnLastLogin(player);

	SetLastLogin(player, os.time());
end

function PlayerTrackSet.Logout(player)

end

function AddPlayerMoneyBasedOnLastLogin(player)
	local lastLogin = GetLastLogin(player);
	local differenceFromNow = os.difftime(os.time(), lastLogin);

	if(differenceFromNow > secondsToPassForLoginMoney) then
		print("Player last logged in over " .. secondsToPassForLoginMoney .. " seconds ago, adding " .. loginRewardMoney .. " gold.");
		moneyManager.AddMoney(player, loginRewardMoney);
	end
end

function PlayerTrackSet.RemovePlayer(player)
	playerLeftEvent:Fire(player);
	PlayerTrackSet.ActivePlayers[player.UserId] = nil;
end

function PlayerTrackSet.FirstTime(player)
	local playerLoginDataStore = dataStore2(firstLoginTime, player);

	local isFirstTime = playerLoginDataStore:Get(nil) == nil;

	if(isFirstTime) then
		playerLoginDataStore:Set(os.time());
	end

	return isFirstTime;
end

return PlayerTrackSet;