local MoneyManager = {};

local moneyPouchName = "Gold";
local STARTING_COINS = 100;

-- Store active players coins
MoneyManager.PlayerCoinPouches = {};

-- Adds money to the dictionary, this will not persist, until the user leaves.
function MoneyManager.AddMoney(player, money)
	local playerMoneyCount = MoneyManager.PlayerCoinPouches[player.UserId];
	playerMoneyCount = playerMoneyCount + money;
	MoneyManager.PlayerCoinPouches[player.UserId] = playerMoneyCount;
end

-- Gets the money from the local dictionary
function MoneyManager.GetMoney(player)
	return MoneyManager.PlayerCoinPouches[player.UserId];
end

-- Called as soon as a player joins the game, so that the money manager can keep track of their coins.
function MoneyManager.AddPlayer(player)
	local dataPersistence = require(game.ServerScriptService.Server.DataPersistence.DataPersistence);
	local moneyDataStore = dataPersistence.GetDataStoreForPlayer(player, moneyPouchName);
	local playerCoins = moneyDataStore:GetAsync(moneyPouchName) or STARTING_COINS;
	MoneyManager.PlayerCoinPouches[player.UserId] = playerCoins;
end

-- Called as soon as a player leaves the game, so that the money value in the dictionary is persisted.
function MoneyManager.RemovePlayer(player)
	local dataPersistence = require(game.ServerScriptService.Server.DataPersistence.DataPersistence);
	local playerMoneyCount = MoneyManager.PlayerCoinPouches[player.UserId];
	local moneyDataStore = dataPersistence.GetDataStoreForPlayer(player, moneyPouchName);
	
	moneyDataStore:UpdateAsync(moneyPouchName, function(oldMoneyCount)
			return playerMoneyCount;
		end);
	
	MoneyManager.PlayerCoinPouches[player.UserId] = nil;
end

return MoneyManager;