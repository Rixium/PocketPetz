local contextActionService = game:GetService("ContextActionService");
local playerInteractor = require(game.Players.LocalPlayer.PlayerScripts.Client.PlayerInteractor);

function onInteractKeyPressed(actionName, inputState, inputObject)
    if inputState == Enum.UserInputState.Begin then
	    playerInteractor.Interact();
    end
end

local replicatedStorage = game:GetService("ReplicatedStorage")

local getTitlesRequest = replicatedStorage.Common.Events.GetTitlesRequest;
local getActiveTitleRequest = replicatedStorage.Common.Events.GetActiveTitleRequest;
local setActiveTitle = replicatedStorage.Common.Events.SetActiveTitle;

local gotTitleTemplate = replicatedStorage.GotTitleTemplate;
local buyTitleTemplate = replicatedStorage.BuyTitleTemplate;

local titlesGUI = game.Players.LocalPlayer.PlayerGui:WaitForChild("Titles GUI");
local currentActive = nil;

contextActionService:BindAction("Interact", onInteractKeyPressed, true, Enum.KeyCode.E);

local activeTitle = getActiveTitleRequest:InvokeServer();

local titles = getTitlesRequest:InvokeServer();
local titlesScrollingFrame = titlesGUI:WaitForChild("TitlesFrame").TitlesBack.InternalTitlesFrame.ScrollingFrame;

for index, value in pairs(titles) do
    local newTitleLayout = gotTitleTemplate:Clone();
    newTitleLayout.Frame.TitleName.Text = value.Name;
    newTitleLayout.Frame.Frame.TitleDescription.Text = value.Description;
    newTitleLayout.Parent = titlesScrollingFrame;
    
    if(value.Index == activeTitle.Index) then
        currentActive = newTitleLayout;
        newTitleLayout.RadioSelect.Visible = true;
    end

    newTitleLayout.MouseButton1Click:Connect(function ()
        setActiveTitle:InvokeServer(value.Name);

        if(currentActive ~= nil) then
            currentActive.RadioSelect.Visible = false;
        end

        currentActive = newTitleLayout;
        currentActive.RadioSelect.Visible = true;
    end)
end 