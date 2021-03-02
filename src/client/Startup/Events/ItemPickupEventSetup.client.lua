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

    currentItemPickupData = itemPickupData;

    getItemPopup.Visible = true;

    getItemPopup:TweenPosition(
		UDim2.new(0.5, 0, 0.5, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Sine,
		0.5,
		true
	);

    getItemPopup.MessageFrame.MessageBack.Frame.NameLabel.Text = itemPickupData.Item.Name;
    getItemPopup.MessageFrame.MessageBack.Frame.Frame.MessageText.Text = itemPickupData.Body;
    getItemPopup.MessageFrame.MessageBack.FaceBack.FaceImage.Image = "rbxthumb://type=Asset&id=" .. itemPickupData.Item.ModelId .. "&w=150&h=150";
end

getItemPopup.Frame.AcceptFrame.YesButton.MouseButton1Click:Connect(function()
    if(currentItemPickupData == nil) then
        return;
    end

    getItemPopup:TweenPosition(
        UDim2.new(0.5, 0, 1.5, 0),
        Enum.EasingDirection.In,
        Enum.EasingStyle.Sine,
        0.5,
        true,
        function()
            getItemPopup.Visible = false;
        end
    );
    itemApprovePickupEvent:FireServer(currentItemPickupData.Item.ItemId);
    
    currentItemPickupData = nil;
end)

getItemPopup.Frame.CancelFrame.NoButton.MouseButton1Click:Connect(function()
    if(currentItemPickupData == nil) then
        return;
    end
    
    getItemPopup:TweenPosition(
        UDim2.new(0.5, 0, 1.5, 0),
        Enum.EasingDirection.In,
        Enum.EasingStyle.Sine,
        0.5,
        true,
        function()
            getItemPopup.Visible = false;
        end
    );
    itemDeclinePickupEvent:FireServer(currentItemPickupData.Item.ItemId);

    currentItemPickupData = nil;
end)

itemPickupEvent.OnClientEvent:Connect(ReceiveItemPickupEvent);