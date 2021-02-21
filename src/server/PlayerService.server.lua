local playerTracker = require(game.ServerScriptService.Server.PlayerTracker);
local moneyManager = require(game.ServerScriptService.Server.Statistics.MoneyManager);

function OnPlayerJoined(player)
	playerTracker.Login(player);
	moneyManager.AddPlayer(player);
	playerTracker.AddPlayer(player);

	local isFirstTime = playerTracker.FirstTime(player);

	if(isFirstTime) then
		print("First time")
	end
end

function OnPlayerLeaving(player)
	playerTracker.Logout(player);
	moneyManager.RemovePlayer(player);
	playerTracker.RemovePlayer(player);
end


game.Players.PlayerAdded:Connect(OnPlayerJoined);
game.Players.PlayerRemoving:Connect(OnPlayerLeaving);


local replicatedStorage = game:GetService("ReplicatedStorage");
local getCoinCountRequest = replicatedStorage.Common.Events.GetCoinCountRequest;
getCoinCountRequest.OnServerInvoke = moneyManager.GetMoney;

local titleList = require(game.ServerScriptService.Server.Data.TitleList);

titleList.Print();