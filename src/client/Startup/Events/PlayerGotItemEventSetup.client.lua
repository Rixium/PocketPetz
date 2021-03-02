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
local bagButton = mainGui:WaitForChild("Buttons").BagButton.BagButton;

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

    local abs = {
        X = bagButton.AbsolutePosition.X + bagButton.AbsoluteSize.X / 2,
        Y = bagButton.AbsolutePosition.Y + bagButton.AbsoluteSize.Y / 2
    }
    local toBagInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In);
    
    tweenService:Create(newPopup.TextLabel, toBagInfo, { 
        Size = UDim2.new(0, 0, 0, 0),
        TextTransparency = 1
    }):Play();

    newPopup.Image.ZIndex = -10;

    local toBagTween = tweenService:Create(newPopup.Image, toBagInfo, { 
        Position =  UDim2.new(0, abs.X - newPopup.Image.Parent.AbsolutePosition.X, 0, abs.Y - newPopup.Image.Parent.AbsolutePosition.Y),
        Size = UDim2.new(0.1, 0, 0.1, 0)
    });
    bagButton.Swipe:Play();
    toBagTween:Play();
    toBagTween.Completed:Wait();

    newPopup.Image:Destroy();

    bagButton.Pickup:Play();
    local bagPopInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true);
	local bagPopTween = tweenService:Create(bagButton, bagPopInfo, {Size=UDim2.new(1.2, 0, 1.2, 0)})
    bagPopTween:Play();
end

gotItemEvent.OnClientEvent:Connect(OnGotItem);