local BackpackMenu = {};

-- Imports
local players = game:GetService("Players");
local replicatedStorage = game:GetService("ReplicatedStorage");
local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local itemBack = replicatedStorage.ItemBack;
local getItemsRequest = replicatedStorage.Common.Events.GetItemsRequest;
local tweenService = game:GetService("TweenService");
local equipItemRequest = replicatedStorage.Common.Events.EquipItemRequest;
local notificationCreator = require(players.LocalPlayer.PlayerScripts.Client.Creators.NotificationCreator);
local petManager = require(players.LocalPlayer.PlayerScripts.Client.PetManager);
local petFaintNotification = replicatedStorage.PetFaintNotification;


-- Variables
local inventoryGUI = uiManager.GetUi("Inventory GUI");
local messageGUI = uiManager.GetUi("Main GUI"):WaitForChild("Message GUI");

local SIZE = Vector2.new(0.21, 0.25);
local PADDING = Vector2.new(0.03, 0.03);
local activeTab = "Seed";
local debounce = false;
local petsCarrying = 0;
local maxPetsAllowed = 3;

BackpackMenu.Items = {};

-- Functions

local scrollingFrame = inventoryGUI.BackpackFrame.BackpackBack.InternalBackpackFrame:WaitForChild("ItemGrid");

local function ResetScroll()
    local uiGridLayout = scrollingFrame.UIGridLayout;

    local NewSize = SIZE * scrollingFrame.AbsoluteSize;
    uiGridLayout.CellSize = UDim2.new(0, NewSize.X, 0, NewSize.Y);

    local NewPadding = PADDING * scrollingFrame.AbsoluteSize
    uiGridLayout.CellPadding = UDim2.new(0, NewPadding.X, 0, NewPadding .Y)
    
    scrollingFrame.CanvasSize = UDim2.new(0, uiGridLayout.AbsoluteContentSize.X, 0, uiGridLayout.AbsoluteContentSize.Y);
end

local function SelectItem(selectedItem)
    local itemData = selectedItem.ItemData;

    local itemPopupFrame = inventoryGUI.BackpackFrame.BackpackBack.ItemPopup;
    local itemPopup = inventoryGUI.BackpackFrame.BackpackBack.ItemPopup.ImageLabel;
    local itemHeader = itemPopup.ItemHeader;
    itemHeader.TextLabel.Text = itemData.Name;
    
    local itemDescription = itemPopup.ItemDescription;
    itemDescription.TextLabel.Text = itemData.Description or "Unknown description..";

    local itemImage = itemPopup.ItemImage.ImageLabel.ItemImage;
    
    itemPopup.ItemImage.ImageLabel.ThumbBack1.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
    itemPopup.ItemImage.ImageLabel.ThumbBack2.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
    itemPopup.ItemImage.ImageLabel.ThumbBack3.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
    itemPopup.ItemImage.ImageLabel.ThumbBack4.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
    itemPopup.ItemImage.ImageLabel.ThumbBack5.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
    itemPopup.ItemImage.ImageLabel.ThumbBack6.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
    itemPopup.ItemImage.ImageLabel.ThumbBack7.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
    itemPopup.ItemImage.ImageLabel.ThumbBack8.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
    itemImage.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";

    itemPopupFrame.Visible = true;
    itemPopup.ItemContextButtons.ContextButtonBack.Visible = false;
    itemPopup.CannotTrainContext.Visible = false;

    local health = selectedItem.PlayerItem.Data.CurrentHealth or 1;

    if(health > 0) then
        local takeOutButton;
        itemPopup.ItemContextButtons.ContextButtonBack.Visible = true;
        takeOutButton = itemPopup.ItemContextButtons.ContextButtonBack.ContextButton.MouseButton1Click:Connect(function()
            local result = equipItemRequest:InvokeServer(selectedItem);
            if(result.Success) then
                BackpackMenu.Toggle();
                itemPopupFrame.Visible = false;
                takeOutButton:Disconnect();

                local playerCharacter = players.LocalPlayer.Character;

                local startFrame = playerCharacter:GetPrimaryPartCFrame():ToWorldSpace(CFrame.new(3,1,0))
                local characterCframe = playerCharacter:GetPrimaryPartCFrame()        
            
                result.Model:SetPrimaryPartCFrame(startFrame);
                result.Model.Name = "Pet";
            
                petManager.SetActivePet(result.Model, result.Item);
            else
                local messageUi = petFaintNotification:clone();
                messageUi.MessageBack.Frame.MessageLabel.Text = result.Message;
                notificationCreator.CreateNotification(messageUi, messageUi.MessageBack);
            end
        end);
    end

    if(petsCarrying == maxPetsAllowed and itemData.ItemType == "Seed") then
        itemPopup.ItemContextButtons.ContextButtonBack.Visible = false;
        itemPopup.CannotTrainContext.Visible = true;
    end

    inventoryGUI.BackpackFrame.BackpackBack.InternalBackpackFrame.ItemGrid.Visible = false;
end

local function AddItem(itemToAdd)
    local item = itemBack:clone();
    item.Parent = scrollingFrame;

    local health = itemToAdd.PlayerItem.Data.CurrentHealth or 1;

    item.LevelText.Text = "Lv. " .. itemToAdd.PlayerItem.Data.CurrentLevel;

    if(health <= 0) then
        item.Cross.Visible = true;
    end

    item.ImageButton.MouseButton1Click:Connect(function()
        if(debounce) then
            return;
        end

        SelectItem(itemToAdd);

        debounce = true;
        item.Click:Play();
        local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true);
        local tween = tweenService:Create(item.ImageButton, tweenInfo, {Size=UDim2.new(0.8, 0, 0.8, 0)})
        tween:Play();

        tween.Completed:Wait();
        debounce = false;
    end)
    
    item.ThumbBack1.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    item.ThumbBack2.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    item.ThumbBack3.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    item.ThumbBack4.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    item.ThumbBack5.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    item.ThumbBack6.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    item.ThumbBack7.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    item.ThumbBack8.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    item.ItemThumbnail.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    
    table.insert(BackpackMenu.Items, item);
end

function BackpackMenu.Refresh()
    local items = getItemsRequest:InvokeServer();

    -- Remove the old stuff from the friends list.
    for index, oldItem in ipairs(BackpackMenu.Items) do
        oldItem:Destroy();
    end

    for index, oldItem in ipairs(BackpackMenu.Items) do
        table.remove(BackpackMenu.Items, index);
    end
    
    spawn(function ()
        for _, item in pairs(items) do
            if(item.PlayerItem.Data.InStorage) then continue end;
            
            if(activeTab == "Seed") then
                if(item.ItemData.ItemType == "Seed" or item.ItemData.ItemType == "Pet") then
                    AddItem(item);
                    ResetScroll();
                end

                if(item.ItemData.ItemType == "Pet") then
                    petsCarrying = petsCarrying + 1; 
                end

                continue;
            end
            
            if(item.ItemData.ItemType == activeTab) then
                AddItem(item);
                ResetScroll();
            end
        end
    end);
end

function BackpackMenu.ShowInventory()
    if(replicatedStorage.Common.Events.IsPlayerLifetimeLegend:InvokeServer() == true) then
        maxPetsAllowed = 5;
    else
        maxPetsAllowed = 3;
    end

    petsCarrying = 0;
    scrollingFrame.Visible = false;

    BackpackMenu.Refresh();

    scrollingFrame.Visible = true;
end

function BackpackMenu.Toggle()
    if (inventoryGUI.Enabled) then
        local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local tween = tweenService:Create(inventoryGUI.BackpackFrame, tweenInfo, {Position=UDim2.new(-0.5, 0, 0.5, 0)})
        tween:Play()
        tween.Completed:Wait();
        inventoryGUI.BackpackFrame.BackpackBack.ItemPopup.Visible = false;
        inventoryGUI.Enabled = false;
    else
        inventoryGUI.BackpackFrame.BackpackBack.ItemPopup.Visible = false;
        BackpackMenu.ShowInventory();
        inventoryGUI.Enabled = true;
        local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local tween = tweenService:Create(inventoryGUI.BackpackFrame, tweenInfo, {Position=UDim2.new(0, 0, 0.5, 0)})
        tween:Play()
    end
end

function BackpackMenu.SetupNavigationBar()
    local seedNavigationButton = inventoryGUI.BackpackFrame.BackpackBack.BackpackNavigationBar.Internal.SeedButton;
    local seedSelector = inventoryGUI.BackpackFrame.BackpackBack.BackpackNavigationBar.Selectors.SeedSelector;

    local foodNavigationButton = inventoryGUI.BackpackFrame.BackpackBack.BackpackNavigationBar.Internal.FoodButton;
    local foodSelector = inventoryGUI.BackpackFrame.BackpackBack.BackpackNavigationBar.Selectors.FoodSelector;
    
    local chestNavigationButton = inventoryGUI.BackpackFrame.BackpackBack.BackpackNavigationBar.Internal.TreasureButton;
    local chestSelector = inventoryGUI.BackpackFrame.BackpackBack.BackpackNavigationBar.Selectors.ChestSelector;

    seedNavigationButton.MouseButton1Click:Connect(function()
        activeTab = "Seed";
        seedSelector.ImageTransparency = 0;
        foodSelector.ImageTransparency = 1;
        chestSelector.ImageTransparency = 1;
        BackpackMenu.ShowInventory();
    end)

    foodNavigationButton.MouseButton1Click:Connect(function()
        activeTab = "Food";
        foodSelector.ImageTransparency = 0;
        seedSelector.ImageTransparency = 1;
        chestSelector.ImageTransparency = 1;
        BackpackMenu.ShowInventory();
    end)

    chestNavigationButton.MouseButton1Click:Connect(function()
        activeTab = "Treasure";
        chestSelector.ImageTransparency = 0;
        foodSelector.ImageTransparency = 1;
        seedSelector.ImageTransparency = 1;
        BackpackMenu.ShowInventory();
    end)
end

return BackpackMenu;