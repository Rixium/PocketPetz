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

local getTitlesRequest = replicatedStorage.Common.Events:WaitForChild("GetTitlesRequest");
local getActiveTitleRequest = replicatedStorage.Common.Events:WaitForChild("GetActiveTitleRequest");
local setActiveTitle = replicatedStorage.Common.Events:WaitForChild("SetActiveTitle");

local gotTitleTemplate = replicatedStorage:WaitForChild("GotTitleTemplate");
local buyTitleTemplate = replicatedStorage:WaitForChild("BuyTitleTemplate");
local lockedTitleTemplate = replicatedStorage:WaitForChild("LockedTitleTemplate");

local titlesGUI = game.Players.LocalPlayer.PlayerGui:WaitForChild("Titles GUI");
local currentActive = nil;
local SIZE = Vector2.new(0.87, 1);

contextActionService:BindAction("Interact", onInteractKeyPressed, true, Enum.KeyCode.E);

local activeTitle = getActiveTitleRequest:InvokeServer();

local titles = getTitlesRequest:InvokeServer();
local titlesScrollingFrame = titlesGUI:WaitForChild("TitlesFrame").TitlesBack.InternalTitlesFrame.ScrollingFrame;

local function ResetScroll()
    local uiGridLayout = titlesScrollingFrame.UIGridLayout;
    
    local NewSize = SIZE * titlesScrollingFrame.AbsoluteSize;
    uiGridLayout.CellSize = UDim2.new(0, NewSize.X, 0, NewSize.Y);
    
    titlesScrollingFrame.CanvasSize = UDim2.new(0, uiGridLayout.AbsoluteContentSize.X, 0, uiGridLayout.AbsoluteContentSize.Y);
end

table.sort(titles, function(a, b) 
    return a.Owned;
end)

for index, value in pairs(titles) do
    local newTitleLayout;

    local purchasable = false;

    if(value.CanPurchase and not value.Owned) then
        purchasable = true;
        newTitleLayout = buyTitleTemplate:Clone();
        newTitleLayout.PriceFrame.PriceLabel.Text = value.PurchasePrice .. " R$";

    elseif not value.Owned then
        newTitleLayout = lockedTitleTemplate:Clone();
    else
        newTitleLayout = gotTitleTemplate:Clone();
    end

    if(value.Index == activeTitle.Index) then
        currentActive = newTitleLayout;
        newTitleLayout.RadioSelect.Visible = true;
    end

    newTitleLayout.Frame.TitleName.Text = value.Name;
    newTitleLayout.Frame.Frame.TitleDescription.Text = value.Description;
    newTitleLayout.Parent = titlesScrollingFrame;

    if not purchasable and value.Owned then
        newTitleLayout.MouseButton1Click:Connect(function ()
            setActiveTitle:InvokeServer(value.Name);

            if(currentActive ~= nil) then
                currentActive.RadioSelect.Visible = false;
            end

            currentActive = newTitleLayout;
            currentActive.RadioSelect.Visible = true;
        end)
    elseif purchasable and not value.Owned then
        newTitleLayout.MouseButton1Click:Connect(function ()
            marketplaceService:PromptProductPurchase(players.LocalPlayer, value.ProductId);
        end)
    end

end 

ResetScroll();