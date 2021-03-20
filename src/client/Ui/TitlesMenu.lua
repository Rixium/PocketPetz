local TitlesMenu = {};

local replicatedStorage = game:GetService("ReplicatedStorage");
local players = game:GetService("Players");
local marketplaceService = game:GetService("MarketplaceService");
local getTitlesRequest = replicatedStorage.Common.Events:WaitForChild("GetTitlesRequest");
local getActiveTitleRequest = replicatedStorage.Common.Events:WaitForChild("GetActiveTitleRequest");
local setActiveTitle = replicatedStorage.Common.Events:WaitForChild("SetActiveTitle");
local gotTitleTemplate = replicatedStorage:WaitForChild("GotTitleTemplate");
local buyTitleTemplate = replicatedStorage:WaitForChild("BuyTitleTemplate");
local tweenService = game:GetService("TweenService");
local lockedTitleTemplate = replicatedStorage:WaitForChild("LockedTitleTemplate");

local titlesGUI = game.Players.LocalPlayer.PlayerGui:WaitForChild("Titles GUI");
local mainGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("Main GUI");

local titlesScrollingFrame = titlesGUI:WaitForChild("TitlesFrame").TitlesBack.InternalTitlesFrame.ScrollingFrame;
local loadingFrame = titlesGUI:WaitForChild("TitlesFrame").TitlesBack.LoadingFrame;

local currentActive = nil;
local SIZE = Vector2.new(0.97, 1);
local PADDING = Vector2.new(0.03, 1);

local isRunning = false;

local currentElements = {};

local function ShowLegendsPopup()
    local toTween = mainGui.LegendFrame
    toTween.Visible = true;
    local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = tweenService:Create(toTween, tweenInfo, {Position=UDim2.new(0.5, 0, 0.5, 0)})
    tween:Play()
end

local function ResetScroll()
    local uiGridLayout = titlesScrollingFrame.UIGridLayout;
    
    local NewSize = SIZE * titlesScrollingFrame.AbsoluteSize;
    uiGridLayout.CellSize = UDim2.new(0, NewSize.X, 0, NewSize.Y);
    
    titlesScrollingFrame.CanvasSize = UDim2.new(0, uiGridLayout.AbsoluteContentSize.X, 0, uiGridLayout.AbsoluteContentSize.Y);
end

local function Grow(toTween)     
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
    local tween = tweenService:Create(toTween, tweenInfo, {Size=UDim2.new(0.7, 0 , 0.7, 0)})
    tween:Play();
end      
local function Shrink(toTween)     
    if(toTween == nil) then return end

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
    local tween = tweenService:Create(toTween, tweenInfo, {Size=UDim2.new(0, 0, 0, 0)})
    tween:Play();
end                                

function TitlesMenu.SetupTitles()
    repeat wait(1) until not isRunning 

    loadingFrame.Visible = true;

    isRunning = true;

    for _, element in pairs(currentElements) do
        element:Destroy();
        element.Parent = nil;
    end

    for index, element in pairs(currentElements) do
        table.remove(currentElements, index);
    end

    local activeTitle = getActiveTitleRequest:InvokeServer();
    local titles = getTitlesRequest:InvokeServer();

    table.sort(titles, function(a, b) 
        return a.Owned and not b.Owned;
    end)
    
    for index, value in pairs(titles) do
        local newTitleLayout;
    
        local purchasable = false;

        if(value.Name == "Legend") then
            purchasable = true;
        end
    
        if((value.CanPurchase or value.Name == "Legend") and not value.Owned) then
            purchasable = true;
            newTitleLayout = buyTitleTemplate:Clone();
            newTitleLayout.PriceFrame.PriceLabel.Text = value.PurchasePrice .. " R$";
            if(value.Name == "Legend") then
                newTitleLayout.PriceFrame.PriceLabel.Text = "REQUIRES LEGEND";
            end
        elseif not value.Owned then
            newTitleLayout = lockedTitleTemplate:Clone();
        else
            newTitleLayout = gotTitleTemplate:Clone();
        end
    
        if(value.Index == activeTitle.Index) then
            currentActive = newTitleLayout;
            newTitleLayout.RadioBack.RadioSelect.Visible = true;
            Grow(currentActive.RadioBack.RadioSelect);
        end
    
        newTitleLayout.Frame.TitleName.Text = value.Name;
        newTitleLayout.Frame.Frame.TitleDescription.Text = value.Description;
        newTitleLayout.Parent = titlesScrollingFrame;
        
        if not purchasable and value.Owned then
            newTitleLayout.MouseButton1Click:Connect(function ()
                setActiveTitle:InvokeServer(value.Name);
    
                if(currentActive ~= nil) then
                    currentActive.RadioBack.RadioSelect.Visible = false;
                end
    
                replicatedStorage.ClickSound:Play();

                Shrink(currentActive.RadioBack.RadioSelect);

                currentActive = newTitleLayout;
                currentActive.RadioBack.RadioSelect.Visible = true;

                Grow(currentActive.RadioBack.RadioSelect);
            end)
        elseif purchasable and not value.Owned then
            if(value.Name == "Legend") then
                newTitleLayout.MouseButton1Click:Connect(function() 
                    ShowLegendsPopup();
                    TitlesMenu.Toggle();
                end)
            else
                newTitleLayout.MouseButton1Click:Connect(function ()
                    marketplaceService:PromptProductPurchase(players.LocalPlayer, value.ProductId);
                end)
            end
        end
    
        table.insert(currentElements, newTitleLayout);
    end 
            
    ResetScroll();

    
    loadingFrame.Visible = false;

    isRunning = false;
end

function TitlesMenu.Toggle()
    if (titlesGUI.Enabled) then

        local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local tween = tweenService:Create(titlesGUI.TitlesFrame, tweenInfo, {Position=UDim2.new(0.5, 0, -0.5, 0)})
        tween:Play()
        tween.Completed:Wait();

        titlesGUI.Enabled = false;
    else
        titlesGUI.Enabled = true;

        local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local tween = tweenService:Create(titlesGUI.TitlesFrame, tweenInfo, {Position=UDim2.new(0.5, 0, 0.5, 0)})
        tween:Play()
        tween.Completed:Wait();

        TitlesMenu.SetupTitles();
    end
end

return TitlesMenu;