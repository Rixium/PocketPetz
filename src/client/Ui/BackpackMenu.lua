local BackpackMenu = {};

-- Imports
local players = game:GetService("Players");
local replicatedStorage = game:GetService("ReplicatedStorage");
local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local itemBack = replicatedStorage.ItemBack;
local getItemsRequest = replicatedStorage.Common.Events.GetItemsRequest;
local tweenService = game:GetService("TweenService");
local equipItemRequest = replicatedStorage.Common.Events.EquipItemRequest;


-- Variables
local inventoryGUI = uiManager.GetUi("Inventory GUI");
local messageGUI = uiManager.GetUi("Main GUI"):WaitForChild("Message GUI");

local SIZE = Vector2.new(0.21, 0.25);
local PADDING = Vector2.new(0.03, 0.03);
local activeTab = "Seed";
local debounce = false;

BackpackMenu.Items = {};

-- Functions

local scrollingFrame = inventoryGUI.BackpackFrame.BackpackBack.InternalBackpackFrame:WaitForChild("ItemGrid");

local function ResetScroll()
    local uiGridLayout = scrollingFrame.UIGridLayout;

    local NewSize = SIZE * scrollingFrame.AbsoluteSize;
    uiGridLayout.CellSize = UDim2.new(0, NewSize.X, 0, NewSize.Y);

    local NewPadding = PADDING * scrollingFrame.AbsoluteSize
    uiGridLayout.CellPadding = UDim2.new(0, NewPadding .X, 0, NewPadding .Y)
    
    scrollingFrame.CanvasSize = UDim2.new(0, uiGridLayout.AbsoluteContentSize.X, 0, uiGridLayout.AbsoluteContentSize.Y);
end

local function SelectItem(selectedItem)
    print("Player has selected " .. selectedItem.ItemData.Name);
    local itemData = selectedItem.ItemData;

    local itemPopupFrame = inventoryGUI.BackpackFrame.BackpackBack.ItemPopup;
    local itemPopup = inventoryGUI.BackpackFrame.BackpackBack.ItemPopup.ImageLabel;
    local itemHeader = itemPopup.ItemHeader;
    itemHeader.TextLabel.Text = itemData.Name;
    
    local itemDescription = itemPopup.ItemDescription;
    itemDescription = itemData.Description or "Unknown description..";

    local itemImage = itemPopup.ItemImage.ImageLabel.ItemImage;
    itemImage.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
    
    itemPopupFrame.Visible = true;
    
    local takeOutButton;
    takeOutButton = itemPopup.ItemContextButtons.ContextButtonBack.ContextButton.MouseButton1Click:Connect(function()
        equipItemRequest:FireServer(selectedItem);
        BackpackMenu.Toggle();
        itemPopupFrame.Visible = false;
        takeOutButton:Disconnect();
    end);
end

local function AddItem(itemToAdd)
    local item = itemBack:clone();
    item.Parent = scrollingFrame;

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
    
    item.ThumbBack.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    item.ItemThumbnail.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    
    table.insert(BackpackMenu.Items, item);
end

function BackpackMenu.ShowInventory()
    scrollingFrame.Visible = false;

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
            
            if(item.ItemData.ItemType == "Pet") then
                item.ItemData.ItemType = "Seed";
            end

            if(item.ItemData.ItemType == activeTab) then
                AddItem(item);
                ResetScroll();
            end
        end
    end);

    scrollingFrame.Visible = true;
end

function BackpackMenu.Toggle()
    if (inventoryGUI.Enabled) then
        local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local tween = tweenService:Create(inventoryGUI.BackpackFrame, tweenInfo, {Position=UDim2.new(-0.5, 0, 0.5, 0)})
        tween:Play()
        tween.Completed:Wait();
        inventoryGUI.Enabled = false;
    else
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