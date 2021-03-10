local replicatedStorage = game:GetService("ReplicatedStorage");
local getPlayerInfo = replicatedStorage.Common.Events.GetPlayerInfo;
local players = game:GetService("Players");
local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local gameState = require(players.LocalPlayer.PlayerScripts.Client.GameState);
local zoneIntro = uiManager.GetUi("Zone Intro");
local tweenService = game:GetService("TweenService");

local playerInfo = getPlayerInfo:InvokeServer(players.LocalPlayer.UserId);

while not gameState.GetReady() do wait(0.1) end

-- Zone switch transition text
local zoneBack = zoneIntro.ImageLabel;
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
local tween = tweenService:Create(zoneBack, tweenInfo, {Position=UDim2.new(0.5, 0, 1, 0)})
tween:Play()
tween.Completed:Wait();
tween = tweenService:Create(zoneBack, tweenInfo, {Position=UDim2.new(0.5, 0, 1.5, 0)})
wait(2);
tween:Play();