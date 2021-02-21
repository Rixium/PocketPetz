local replicatedStorage = game:GetService("ReplicatedStorage");
local workspaceHelper = require(replicatedStorage.Common.WorkspaceHelper);

local getCoinCountRequest = replicatedStorage:WaitForChild("GetCoinCountRequest", 5);
local coinCount = getCoinCountRequest:InvokeServer();
local uiManager = require(game.Players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local mainGui = uiManager.GetUi("Main GUI");

local coinLabel = workspaceHelper.GetDescendantByName(mainGui, "CoinCount");
coinLabel.Text = coinCount;