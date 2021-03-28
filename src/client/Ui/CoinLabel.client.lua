-- Dependencies
local replicatedStorage = game:GetService("ReplicatedStorage");
local workspaceHelper = require(replicatedStorage.Common.WorkspaceHelper);
local tweenService = game:GetService("TweenService");
local uiManager = require(game.Players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);

local function UpdateCoins(value)
    local mainGui = uiManager.GetUi("Main GUI");
    local coinBackground = mainGui.CurrencyFrame.CoinBackground;
    local coinCountFront = coinBackground.CoinCountFront;
    local coinCountBack = coinBackground.CoinCountBack;
    coinCountBack.Text = value;
    coinCountFront.Text = value;
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local tween = tweenService:Create(coinBackground, tweenInfo, {Size=UDim2.new(1.1, 0, 1.1, 0)})
	tween:Play()

    tween.Completed:Wait();

    tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	tween = tweenService:Create(coinBackground, tweenInfo, {Size=UDim2.new(1, 0, 1, 0)})
	tween:Play()
end

local coinAmount = replicatedStorage.Common.Events.CoinAmount;
coinAmount.OnClientEvent:Connect(UpdateCoins);
