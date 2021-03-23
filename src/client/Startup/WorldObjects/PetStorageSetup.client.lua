local collectionService = game:GetService("CollectionService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local tweenService = game:GetService("TweenService");
local playerClickedWorldObject = replicatedStorage.Common.Events.PlayerClickedWorldObject;
local itemBack = replicatedStorage.ItemBack;
local players = game:GetService("Players");
local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local getItemsRequest = replicatedStorage.Common.Events.GetItemsRequest;
local storeItem = replicatedStorage.Common.Events.StoreItem;
local withdrawItem = replicatedStorage.Common.Events.WithdrawItem;
local quickbarMenu = require(players.LocalPlayer.PlayerScripts.Client.Ui.QuickbarMenu);

local petStorages = collectionService:GetTagged("PetStorage");
local currentItems = {};
local currentStored = {};

local SIZE = Vector2.new(0.21, 0.25);
local PADDING = Vector2.new(0.03, 0.03);

local storageGUI = uiManager.GetUi("Storage GUI");
local mainGUI = uiManager.GetUi("Main GUI");
local debounce = false;

local storeCallback;
local takeCallback;
local refresh;

local function ResetScroll(scrollingFrame)
    local uiGridLayout = scrollingFrame.UIGridLayout;

    local NewSize = SIZE * scrollingFrame.AbsoluteSize;
    uiGridLayout.CellSize = UDim2.new(0, NewSize.X, 0, NewSize.Y);

    local NewPadding = PADDING * scrollingFrame.AbsoluteSize
    uiGridLayout.CellPadding = UDim2.new(0, NewPadding.X, 0, NewPadding .Y)
    
    scrollingFrame.CanvasSize = UDim2.new(0, uiGridLayout.AbsoluteContentSize.X, 0, uiGridLayout.AbsoluteContentSize.Y);
end
    
local function SelectItem(selectedItem)
    local itemData = selectedItem.ItemData;

    local selectedFrame = storageGUI.ImageLabel.Frame.SelectedFrame;
    selectedFrame.ImageFrame.Visible = true;
    selectedFrame.StatFrame.Visible = true;
    
    local itemImage = selectedFrame.ImageFrame.ImageLabel;
    
    itemImage.ThumbBack2.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
    itemImage.ThumbBack1.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
    itemImage.ThumbBack3.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
    itemImage.ThumbBack4.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
    itemImage.ThumbBack5.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
    itemImage.ThumbBack6.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
    itemImage.ThumbBack7.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
    itemImage.ThumbBack8.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
    itemImage.ItemImage.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";

    local statFrame = selectedFrame.StatFrame.ImageLabel;
    statFrame.LevelFrame.TextLabel.Text = "Lvl. " .. selectedItem.PlayerItem.Data.CurrentLevel;
    statFrame.AttackFrame.TextLabel.Text = itemData.BaseAttack;
    statFrame.DefenceFrame.TextLabel.Text = itemData.BaseDefence;

    local storeButtonBack = storageGUI.ImageLabel.Frame.SelectedFrame.ContextButtonFrame.StoreButton;
    local storeButton = storageGUI.ImageLabel.Frame.SelectedFrame.ContextButtonFrame.StoreButton.ContextButton;
    local takeButtonBack = storageGUI.ImageLabel.Frame.SelectedFrame.ContextButtonFrame.TakeButton;
    local takeButton = storageGUI.ImageLabel.Frame.SelectedFrame.ContextButtonFrame.TakeButton.ContextButton;
    local leftArrow = storageGUI.ImageLabel.Frame.SelectedFrame.ContextButtonFrame.LeftArrow;
    local rightArrow = storageGUI.ImageLabel.Frame.SelectedFrame.ContextButtonFrame.RightArrow;

    storeButtonBack.Visible = false;
    takeButtonBack.Visible = false;
    leftArrow.Visible = false;
    rightArrow.Visible = false;

    if(not selectedItem.PlayerItem.Data.InStorage) then
        if(storeCallback ~= nil) then
            storeCallback:Disconnect();
        end

        storeButtonBack.Visible = true;
        rightArrow.Visible = true;

        storeCallback = storeButton.MouseButton1Click:Connect(function()
            storeItem:InvokeServer(selectedItem);
            refresh();
            quickbarMenu.Setup();
        end);
    else
        if(takeCallback ~= nil) then
            takeCallback:Disconnect();
        end

        takeButtonBack.Visible = true;
        leftArrow.Visible = true;

        takeCallback = takeButton.MouseButton1Click:Connect(function()
            withdrawItem:InvokeServer(selectedItem);
            refresh();
            quickbarMenu.Setup();
        end)
    end
end

local function AddItem(scrollingFrame, itemToAdd)
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

    item.ImageButton.MouseEnter:Connect(function() 
        local hoverFrame = storageGUI:WaitForChild("HoverFrame");
        local mouse = players.LocalPlayer:GetMouse();
        hoverFrame.Position = UDim2.new(0, item.AbsolutePosition.X + item.AbsoluteSize.X + 5, 0, item.AbsolutePosition.Y + item.AbsoluteSize.Y + 5);
        hoverFrame.C.TextLabel.Text = math.floor(itemToAdd.ItemData.BaseAttack);
        hoverFrame.D.TextLabel.Text =  math.floor(itemToAdd.ItemData.BaseDefence);
        hoverFrame.A.TextLabel.Text =  math.floor(itemToAdd.PlayerItem.Data.CurrentHealth) .. "/" .. math.floor(itemToAdd.ItemData.BaseHealth);
        hoverFrame.B.TextLabel.Text =  "Lvl. " .. math.floor(itemToAdd.PlayerItem.Data.CurrentLevel);
        hoverFrame.Visible = true;
    end)

    item.ImageButton.MouseLeave:Connect(function() 
        local hoverFrame = storageGUI:WaitForChild("HoverFrame");
        hoverFrame.Visible = false;
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
    
    table.insert(currentItems, item);
end

local function setupStored(items)
    local scrollingFrame = storageGUI.ImageLabel.Frame.StoredFrame.ImageLabel.InternalBackpackFrame.ItemGrid;

    scrollingFrame.Visible = true;

    -- Remove the old stuff from the friends list.
    for index, oldItem in ipairs(currentStored) do
        oldItem:Destroy();
    end

    for index, oldItem in ipairs(currentStored) do
        table.remove(currentStored, index);
    end
    
    for _, item in pairs(items) do
        if(item.ItemData.ItemType == "Pet" and item.PlayerItem.Data.InStorage) then
            AddItem(scrollingFrame, item);
            ResetScroll(scrollingFrame);
        end
    end
end

local function setupBackpack(items)
    local scrollingFrame = storageGUI.ImageLabel.Frame.CurrentFrame.ImageLabel.InternalBackpackFrame.ItemGrid;
    scrollingFrame.Visible = true;

    -- Remove the old stuff from the friends list.
    for index, oldItem in ipairs(currentItems) do
        oldItem:Destroy();
    end

    for index, oldItem in ipairs(currentItems) do
        table.remove(currentItems, index);
    end
    
    for _, item in pairs(items) do
        if(item.ItemData.ItemType == "Pet" and item.PlayerItem.Data.InStorage == false) then
            AddItem(scrollingFrame, item);
            ResetScroll(scrollingFrame);
        end
    end
end

local function show()
    local selectedFrame = storageGUI.ImageLabel.Frame.SelectedFrame;
    selectedFrame.ImageFrame.Visible = false;
    selectedFrame.StatFrame.Visible = false;

    local storeButtonBack = storageGUI.ImageLabel.Frame.SelectedFrame.ContextButtonFrame.StoreButton;
    local storeButton = storageGUI.ImageLabel.Frame.SelectedFrame.ContextButtonFrame.StoreButton.ContextButton;
    local takeButtonBack = storageGUI.ImageLabel.Frame.SelectedFrame.ContextButtonFrame.TakeButton;
    local takeButton = storageGUI.ImageLabel.Frame.SelectedFrame.ContextButtonFrame.TakeButton.ContextButton;
    local leftArrow = storageGUI.ImageLabel.Frame.SelectedFrame.ContextButtonFrame.LeftArrow;
    local rightArrow = storageGUI.ImageLabel.Frame.SelectedFrame.ContextButtonFrame.RightArrow;

    storeButtonBack.Visible = false;
    takeButtonBack.Visible = false;
    leftArrow.Visible = false;
    rightArrow.Visible = false;

    storageGUI.Enabled = true;
    selectedItem = nil;
    

    local items = getItemsRequest:InvokeServer();

    spawn(function()    
        setupBackpack(items);
        setupStored(items);
    end);

    local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = tweenService:Create(storageGUI.ImageLabel, tweenInfo, {Position=UDim2.new(0.5, 0, 0.5, 0)});
    tween:Play()
end

for index, petStorage in pairs(petStorages) do

    local interactGUI = replicatedStorage["Interact GUI"]:Clone();
    interactGUI.Adornee = petStorage.PrimaryPart;
    interactGUI.Parent = players.LocalPlayer.PlayerGui;
    local button = interactGUI:WaitForChild("ImageButton");

    button.MouseButton1Click:Connect(function ()
        show();
    end)

    game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
        local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait();
        
        if(not character.PrimaryPart) then
            return;
        end

        local characterPosition = character:GetPrimaryPartCFrame().Position;
        local clonedPosition = petStorage:GetPrimaryPartCFrame().Position;

        interactGUI.Enabled = false;
        
        if (characterPosition - clonedPosition).Magnitude <= 10 then
            interactGUI.Enabled = true;
        end

    end);

end

refresh = show;