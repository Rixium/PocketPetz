-- Imports
local replicatedStorage = game:GetService("ReplicatedStorage");
local players = game:GetService("Players");
local itemPickupEvent = replicatedStorage.Common.Events.ItemPickupEvent;
local itemApprovePickupEvent = replicatedStorage.Common.Events.ItemApprovePickupEvent;
local itemDeclinePickupEvent = replicatedStorage.Common.Events.ItemDeclinePickupEvent;

local uiManager = require(game.Players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);

-- Variables
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420

local getItemPopup = uiManager.GetUi("Main GUI"):WaitForChild("GetItemPopup");

-- Functions

local function ReceiveItemPickupEvent(itemPickupData)
    if(getItemPopup.Visible) then
        return;
    end

    getItemPopup.Visible = true;
    getItemPopup.MessageFrame.MessageBack.Frame.NameLabel.Text = itemPickupData.Item.Name;
    getItemPopup.MessageFrame.MessageBack.Frame.Frame.MessageText.Text = itemPickupData.Body;
    getItemPopup.MessageFrame.MessageBack.FaceBack.FaceImage.Image = "rbxthumb://type=Asset&id=" .. itemPickupData.Item.ModelId .. "&w=150&h=150";
    
    getItemPopup.Frame.AcceptFrame.YesButton.MouseButton1Click:Connect(function()
        itemApprovePickupEvent:FireServer(itemPickupData.Item.ItemId);
        getItemPopup.Visible = false;
    end)
    getItemPopup.Frame.CancelFrame.NoButton.MouseButton1Click:Connect(function()
        itemDeclinePickupEvent:FireServer(itemPickupData.Item.ItemId);
        getItemPopup.Visible = false;
    end)
end

itemPickupEvent.OnClientEvent:Connect(ReceiveItemPickupEvent);