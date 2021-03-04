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



local userInputService = game:GetService("UserInputService");

-- Functions
function DoInput(pos)
    local camera = workspace.CurrentCamera;
    local unitRay = camera:ScreenPointToRay(pos.X, pos.Y);
    local ray = Ray.new(unitRay.Origin, unitRay.Direction * 1000)

    local result = game.Workspace:FindPartOnRay(ray);
    if(result == nil or result.Parent == nil) then
        return;
    end

    local ancestor = result:FindFirstAncestorOfClass("Part");
    
end
 
userInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		DoInput(input.Position);
	elseif input.UserInputType == Enum.UserInputType.Touch then
		DoInput(input.Position);
    end
end);