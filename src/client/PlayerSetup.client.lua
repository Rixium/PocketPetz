local replicatedStorage = game:GetService("ReplicatedStorage");
local getPlayerInfo = replicatedStorage.Common.Events.GetPlayerInfo;
local players = game:GetService("Players");
local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local gameState = require(players.LocalPlayer.PlayerScripts.Client.GameState);
local trade = require(players.LocalPlayer.PlayerScripts.Client.Ui.Trade);
local evolutionGui = require(players.LocalPlayer.PlayerScripts.Client.Ui.EvolutionGUI);
local playerSwitchedZone = replicatedStorage.Common.Events.PlayerSwitchedZone;
local zoneIntro = uiManager.GetUi("Zone Intro");
local tweenService = game:GetService("TweenService");

local playerInfo = getPlayerInfo:InvokeServer(players.LocalPlayer.UserId);
local music = nil;
local currentZone = nil;

local function ShowZoneIntro(zoneName)
    if(zoneName == currentZone) then return end
    currentZone = zoneName;

    if(music ~= nil) then
        spawn(function()
            repeat
                music.Volume = music.Volume - 0.005
                wait(0.1);
            until music.Volume <= 0
            
            music:Stop();
            music = replicatedStorage.Music:WaitForChild(zoneName);
            music.Looped = true;
            music.Volume = 0;
            music:Play();

            repeat
                music.Volume = music.Volume + 0.005
                wait(0.1);
            until music.Volume >= 0.1
            music.Volume = 0.1;
        end);
    else
        spawn(function()
            music = replicatedStorage.Music:WaitForChild(zoneName);
            music.Looped = true;
            music.Volume = 0;
            music:Play();

            repeat
                music.Volume = music.Volume + 0.005
                wait(0.1);
            until music.Volume >= 0.1
            music.Volume = 0.1;
        end);
    end

    local zoneBack = zoneIntro.ImageLabel;
    zoneBack.TextLabel.Text = zoneName;
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
    local tween = tweenService:Create(zoneBack, tweenInfo, {Position=UDim2.new(0.5, 0, 0, 0)})
    tween:Play()
    tween.Completed:Wait();
    tween = tweenService:Create(zoneBack, tweenInfo, {Position=UDim2.new(0.5, 0, -0.5, 0)})

    wait(2);
    tween:Play();
end

playerSwitchedZone.OnClientEvent:Connect(function(zoneName)
    ShowZoneIntro(zoneName);
end);

trade.Setup();
evolutionGui.Init();