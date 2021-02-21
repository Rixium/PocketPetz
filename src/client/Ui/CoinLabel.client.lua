-- Dependencies
local replicatedStorage = game:GetService("ReplicatedStorage");
local workspaceHelper = require(replicatedStorage.Common.WorkspaceHelper);
local uiManager = require(game.Players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);

local function UpdateCoins(value)
    local mainGui = uiManager.GetUi("Main GUI");
    local coinLabel = workspaceHelper.GetDescendantByName(mainGui, "CoinCount");
    coinLabel.Text = value;
end

local coinAmount = replicatedStorage.Common.Events.CoinAmount;
coinAmount.OnClientEvent:Connect(UpdateCoins);
