local NotificationCreator = {};

local players = game:GetService("Players");
local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local notificationsUi = uiManager.GetUi("Notifications GUI");
local replicatedStorage = game:GetService("ReplicatedStorage");

local function TweenAway(element)
	element:TweenPosition(
		UDim2.new(-10, 0, 0.99, 0),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Sine,
		3,
		true,
        function()
            element:Destroy();
            element.Parent = nil;
            element = nil;
        end
	);
end

function NotificationCreator.CreateNotification(notificationElement, dismissButton)
    notificationElement.Parent = notificationsUi;

    replicatedStorage.NotifySound:Play();
    
    dismissButton.MouseButton1Click:Connect(function() 
        TweenAway(notificationElement);
    end);

    wait(5);

    TweenAway(notificationElement);
end

return NotificationCreator;