local playerTracker = require(game.ServerScriptService.Server.PlayerTracker);
local moneyManager = require(game.ServerScriptService.Server.Statistics.MoneyManager);

function OnPlayerJoined(player)
	moneyManager.AddPlayer(player);
	playerTracker.AddPlayer(player);
	
	print(player.UserId .. " joined.");
end

function OnPlayerLeaving(player)
	moneyManager.RemovePlayer(player);
	playerTracker.RemovePlayer(player);
	
	print(player.UserId .. " left.");
end


game.Players.PlayerAdded:Connect(OnPlayerJoined);
game.Players.PlayerRemoving:Connect(OnPlayerLeaving);


local replicatedStorage = game:GetService("ReplicatedStorage");
local getCoinCountRequest = replicatedStorage.Common.Events.GetCoinCountRequest;
getCoinCountRequest.OnServerInvoke = moneyManager.GetMoney;