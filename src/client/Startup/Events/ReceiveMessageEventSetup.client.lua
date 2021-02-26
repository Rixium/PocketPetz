-- Imports
local replicatedStorage = game:GetService("ReplicatedStorage");
local players = game:GetService("Players");
local receiveMessageEvent = replicatedStorage.Common.Events.ReceiveMessageEvent;
local newMessage = replicatedStorage.NewMessage;
local notificationCreator = require(players.LocalPlayer.PlayerScripts.Client.Creators.NotificationCreator);

-- Variables
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420

-- Functions

local function ReceiveMessage(otherPlayerId, message)
    local messageUi = newMessage:clone();

    local otherPlayer = players:GetPlayerByUserId(otherPlayerId);

    messageUi.MessageBack.Frame.Frame.MessageText.Text = message;
    messageUi.MessageBack.Frame.NameLabel.Text = otherPlayer.Name;
    messageUi.MessageBack.FaceBack.FaceImage.Image = players:GetUserThumbnailAsync(otherPlayerId, thumbType, thumbSize);

    notificationCreator.CreateNotification(messageUi, messageUi.MessageBack);
end

receiveMessageEvent.OnClientEvent:Connect(ReceiveMessage);