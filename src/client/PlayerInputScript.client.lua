local contextActionService = game:GetService("ContextActionService");
local playerInteractor = require(game.Players.LocalPlayer.PlayerScripts.Client.PlayerInteractor);

function onInteractKeyPressed(actionName, inputState, inputObject)
    if inputState == Enum.UserInputState.Begin then
	    playerInteractor.Interact();
    end
end

local replicatedStorage = game:GetService("ReplicatedStorage");
local marketplaceService = game:GetService("MarketplaceService");
local players = game:GetService("Players");

local titleUnlocked = replicatedStorage.Common.Events:WaitForChild("TitleUnlocked");

local mainGUI = game.Players.LocalPlayer.PlayerGui:WaitForChild("Main GUI");
local titlesMenu = require(players.LocalPlayer.PlayerScripts.Client.Ui.TitlesMenu);

contextActionService:BindAction("Interact", onInteractKeyPressed, true, Enum.KeyCode.E);

local titleUnlocked = replicatedStorage.Common.Events.TitleUnlocked;
titleUnlocked.OnClientEvent:Connect(titlesMenu.SetupTitles);

local titlesButton = mainGUI.Buttons.TitleButton.TitleButton.MouseButton1Click:Connect(function() 
    titlesMenu.Toggle();
end)