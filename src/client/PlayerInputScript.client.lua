local contextActionService = game:GetService("ContextActionService");
local playerInteractor = require(game.Players.LocalPlayer.PlayerScripts.Client.PlayerInteractor);

function onInteractKeyPressed(actionName, inputState, inputObject)
    if inputState == Enum.UserInputState.Begin then
	    playerInteractor.Interact();
    end
end

local replicatedStorage = game:GetService("ReplicatedStorage")

local getTitlesRequest = replicatedStorage.Common.Events.GetTitlesRequest;
local setActiveTitle = replicatedStorage.Common.Events.SetActiveTitle;

local startMenu = game.Players.LocalPlayer.PlayerGui["Titles GUI"];

contextActionService:BindAction("Interact", onInteractKeyPressed, true, Enum.KeyCode.E);

local titleButton = replicatedStorage.TitleButton;
local titles = getTitlesRequest:InvokeServer();

for index, value in pairs(titles) do
    local ScreenGui = startMenu.BagFrame.ScrollingFrame;
    local newButton = titleButton:Clone();
    newButton.Text = value.Name;
    newButton.Parent = ScreenGui;

    newButton.MouseButton1Click:Connect(function ()
        setActiveTitle:InvokeServer(value.Name);
    end)

end 
		