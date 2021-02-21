-- Dependencies
local replicatedStorage = game:GetService("ReplicatedStorage");
local workspaceHelper = require(replicatedStorage.Common.WorkspaceHelper);
local uiManager = require(game.Players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);

local getCoinCountRequest = replicatedStorage.Common.Events.GetCoinCountRequest;
local coinCount = getCoinCountRequest:InvokeServer();
local mainGui = uiManager.GetUi("Main GUI");

local coinLabel = workspaceHelper.GetDescendantByName(mainGui, "CoinCount");
coinLabel.Text = coinCount;