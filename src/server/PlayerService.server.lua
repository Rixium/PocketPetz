local serverScriptService = game:GetService("ServerScriptService");
local playerTracker = require(serverScriptService.Server.PlayerTracker);
local moneyManager = require(serverScriptService.Server.Statistics.MoneyManager);
local titleService = require(serverScriptService.Server.Services.TitleService);
local itemService = require(serverScriptService.Server.Services.ItemService);

local currentEventTitle = "AlphaStar";

function OnPlayerJoined(player)
	playerTracker.Login(player);
	moneyManager.PlayerJoined(player);

	local isFirstTime = playerTracker.FirstTime(player);
	titleService.UnlockTitle(player, "Noob");
	titleService.UnlockTitle(player, currentEventTitle);


	-- DATABASE CLEARUP
	-- itemService.ClearItems(player);
end

function OnPlayerLeaving(player)
	playerTracker.Logout(player);
	playerTracker.RemovePlayer(player);
end


game.Players.PlayerAdded:Connect(OnPlayerJoined);
game.Players.PlayerRemoving:Connect(OnPlayerLeaving);


local replicatedStorage = game:GetService("ReplicatedStorage");
local getCoinCountRequest = replicatedStorage.Common.Events.GetCoinCountRequest;
getCoinCountRequest.OnServerInvoke = moneyManager.GetMoney;

local getTitlesRequest = replicatedStorage.Common.Events.GetTitlesRequest;
getTitlesRequest.OnServerInvoke = titleService.GetAllTitles;

local getActiveTitleRequest = replicatedStorage.Common.Events.GetActiveTitleRequest;
getActiveTitleRequest.OnServerInvoke = titleService.GetActiveTitle;

local setActiveTitle = replicatedStorage.Common.Events.SetActiveTitle;
setActiveTitle.OnServerInvoke = titleService.SetActiveTitle;

local getItemsRequest = replicatedStorage.Common.Events.GetItemsRequest;
getItemsRequest.OnServerInvoke = itemService.GetPlayerItems;