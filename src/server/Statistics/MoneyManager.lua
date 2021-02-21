local MoneyManager = {};

local serverScriptService = game:GetService("ServerScriptService");
local dataStoreGet = require(serverScriptService.Server.DataStoreGet);
local dataStore2 = dataStoreGet.DataStore;

local moneyPouchName = "Gold";
local STARTING_COINS = 100;

-- Adds money to the dictionary, this will not persist, until the user leaves.
function MoneyManager.AddMoney(player, money)
	local playerMoneyDataStore = dataStore2(moneyPouchName, player);
	playerMoneyDataStore:Increment(money);
end

-- Gets the money from the local dictionary
function MoneyManager.GetMoney(player)
	local playerMoneyDataStore = dataStore2(moneyPouchName, player);
	return playerMoneyDataStore:Get(STARTING_COINS);
end

return MoneyManager;