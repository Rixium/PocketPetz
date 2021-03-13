local MoneyManager = {};

local serverScriptService = game:GetService("ServerScriptService");
local replicatedStorage = game:GetService("ReplicatedStorage");

local dataStoreGet = require(serverScriptService.Server.DataStoreGet);
local dataStore2 = dataStoreGet.DataStore;

local moneyPouchName = "Gold";
local STARTING_COINS = 100;

function MoneyManager.AddMoney(player, money)
	local playerMoneyDataStore = dataStore2(moneyPouchName, player);
	playerMoneyDataStore:Increment(money);
end

function MoneyManager.RemoveMoney(player, money)
	local playerMoneyDataStore = dataStore2(moneyPouchName, player);
	local value = playerMoneyDataStore:Get();

	if(value > money) then
		playerMoneyDataStore:Increment(-money);
		return true;
	end
	
	return false;
end


function MoneyManager.PlayerJoined(player)
	local playerMoneyDataStore = dataStore2(moneyPouchName, player);

	local function OnCoinsUpdated(value)
		replicatedStorage.Common.Events.CoinAmount:FireClient(player, value);
	end

	playerMoneyDataStore:OnUpdate(OnCoinsUpdated);
	local currentCoins = playerMoneyDataStore:Get(STARTING_COINS);
	OnCoinsUpdated(currentCoins);
end

return MoneyManager;