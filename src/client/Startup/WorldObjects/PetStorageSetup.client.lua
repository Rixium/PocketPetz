local collectionService = game:GetService("CollectionService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local tweenService = game:GetService("TweenService");
local playerClickedWorldObject = replicatedStorage.Common.Events.PlayerClickedWorldObject;
local itemBack = replicatedStorage.ItemBack;
local players = game:GetService("Players");
local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local getItemsRequest = replicatedStorage.Common.Events.GetItemsRequest;

local petStorages = collectionService:GetTagged("PetStorage");
local currentItems = {};

local storageGUI = uiManager.GetUi("Storage GUI");

-- local function SelectItem(selectedItem)
--     local itemData = selectedItem.ItemData;

--     local itemPopupFrame = inventoryGUI.BackpackFrame.BackpackBack.ItemPopup;
--     local itemPopup = inventoryGUI.BackpackFrame.BackpackBack.ItemPopup.ImageLabel;
--     local itemHeader = itemPopup.ItemHeader;
--     itemHeader.TextLabel.Text = itemData.Name;
    
--     local itemDescription = itemPopup.ItemDescription;
--     itemDescription.TextLabel.Text = itemData.Description or "Unknown description..";

--     local itemImage = itemPopup.ItemImage.ImageLabel.ItemImage;
    
--     itemPopup.ItemImage.ImageLabel.ThumbBack1.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
--     itemPopup.ItemImage.ImageLabel.ThumbBack2.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
--     itemPopup.ItemImage.ImageLabel.ThumbBack3.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
--     itemPopup.ItemImage.ImageLabel.ThumbBack4.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
--     itemPopup.ItemImage.ImageLabel.ThumbBack5.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
--     itemPopup.ItemImage.ImageLabel.ThumbBack6.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
--     itemPopup.ItemImage.ImageLabel.ThumbBack7.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
--     itemPopup.ItemImage.ImageLabel.ThumbBack8.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";
--     itemImage.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=420&h=420";

--     itemPopupFrame.Visible = true;
--     itemPopup.ItemContextButtons.ContextButtonBack.Visible = false;
--     itemPopup.CannotTrainContext.Visible = false;

--     local health = selectedItem.PlayerItem.Data.CurrentHealth or 1;

--     if(health > 0) then
--         local takeOutButton;
--         itemPopup.ItemContextButtons.ContextButtonBack.Visible = true;
--         takeOutButton = itemPopup.ItemContextButtons.ContextButtonBack.ContextButton.MouseButton1Click:Connect(function()
--             local result = equipItemRequest:InvokeServer(selectedItem);
--             if(result.Success) then
--                 BackpackMenu.Toggle();
--                 itemPopupFrame.Visible = false;
--                 takeOutButton:Disconnect();
--             else
--                 local messageUi = petFaintNotification:clone();
--                 messageUi.MessageBack.Frame.MessageLabel.Text = result.Message;
--                 notificationCreator.CreateNotification(messageUi, messageUi.MessageBack);
--             end
--         end);
--     end

--     if(petsCarrying == maxPetsAllowed and itemData.ItemType == "Seed") then
--         itemPopup.ItemContextButtons.ContextButtonBack.Visible = false;
--         itemPopup.CannotTrainContext.Visible = true;
--     end

--     inventoryGUI.BackpackFrame.BackpackBack.InternalBackpackFrame.ItemGrid.Visible = false;
-- end

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

        -- SelectItem(itemToAdd);

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
    
    table.insert(currentItems, item);
end

local function setupBackpack()
    local scrollingFrame = storageGUI.ImageLabel.Frame.CurrentFrame.ImageLabel.InternalBackpackFrame.ItemGrid;

    scrollingFrame.Visible = true;

    local items = getItemsRequest:InvokeServer();

    -- Remove the old stuff from the friends list.
    for index, oldItem in ipairs(currentItems) do
        oldItem:Destroy();
    end

    for index, oldItem in ipairs(currentItems) do
        table.remove(currentItems, index);
    end
    
    spawn(function ()
        for _, item in pairs(items) do
            if(item.ItemData.ItemType == "Pet" and item.PlayerItem.Data.InStorage == false) then
                AddItem(scrollingFrame, item);
            end
        end
    end);
end

for index, petStorage in pairs(petStorages) do

    local interactGUI = replicatedStorage["Interact GUI"]:Clone();
    interactGUI.Adornee = petStorage.PrimaryPart;
    interactGUI.Parent = players.LocalPlayer.PlayerGui;
    local button = interactGUI:WaitForChild("ImageButton");

    button.MouseButton1Click:Connect(function ()
        storageGUI.Enabled = true;

        setupBackpack();

        local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
        local tween = tweenService:Create(storageGUI.ImageLabel, tweenInfo, {Size=UDim2.new(0.8, 0, 0.7, 0)});
        tween:Play()
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
