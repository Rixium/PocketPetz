-- Imports
local replicatedStorage = game:GetService("ReplicatedStorage");
local players = game:GetService("Players");
local tweenService = game:GetService("TweenService");
local gotItemEvent = replicatedStorage.Common.Events.PlayerGotItemEvent;

local uiManager = require(game.Players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);

-- Variables
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420

local mainGui = uiManager.GetUi("Main GUI");
local gotItemPopup = replicatedStorage.GotItemPopup;
local bagButton = mainGui:WaitForChild("Buttons").BagButton;

-- Functions

local function OnGotItem(itemData)
    local newPopup = gotItemPopup:clone();
    newPopup.Parent = mainGui;
    newPopup.Size = UDim2.new(0, 0, 0, 0);
    
    newPopup.Award:Play();

    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false, 0);
    local tween = tweenService:Create(newPopup, tweenInfo, { Size = UDim2.new(0.5, 0, 0.5, 0) });
    tween:Play();

    newPopup.TextLabel.Text = "You got " .. itemData.Name;
    newPopup.Image.ItemImage.Image = "rbxthumb://type=Asset&id=" .. itemData.ModelId .. "&w=150&h=150";

    tween.Completed:Wait()

    local abs = bagButton.AbsolutePosition;
    local absSize = bagButton.AbsoluteSize;

    local absCenter = {
        X = abs.X + (absSize.X / 2),
        Y = abs.Y + (absSize.Y / 2)
    };    
    local toBagInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In);
    local toBag = tweenService:Create(newPopup.Image.ItemImage, toBagInfo, { Position = UDim2.new(0, absCenter.X, 0, absCenter.Y) });
    toBag:Play();
end

gotItemEvent.OnClientEvent:Connect(OnGotItem);