-- Imports
local players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local userMenu = require(players.LocalPlayer.PlayerScripts.Client.Ui.UserMenu);
local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local userProfile = require(players.LocalPlayer.PlayerScripts.Client.Ui.UserProfile);
local friendsList = require(players.LocalPlayer.PlayerScripts.Client.Ui.FriendsList);
local interactor = require(players.LocalPlayer.PlayerScripts.Client.PlayerInteractor);
local tweenService = game:GetService("TweenService");
local replicatedStorage = game:GetService("ReplicatedStorage");

-- Variables
local player = players.LocalPlayer
local camera = workspace.CurrentCamera;
local mainGui = uiManager.GetUi("Main GUI");
local friendsListGUI = uiManager.GetUi("Friends GUI");
local currentCharacter = nil;

-- Functions
function DoInput(pos)
    if(interactor.GetInteractable() ~= nil) then
        return;
    end

    local unitRay = camera:ScreenPointToRay(pos.X, pos.Y);
    local ray = Ray.new(unitRay.Origin, unitRay.Direction * 1000)

    local result = game.Workspace:FindPartOnRay(ray);
    if(result == nil or result.Parent == nil) then
        userMenu.Hide();
        return;
    end

    local ancestor = result:FindFirstAncestorOfClass("Model");

    if(ancestor == nil) then
        userMenu.Hide();
        return;
    end

    local humanoid = ancestor:FindFirstChild("Humanoid");

    if humanoid then
        local character = humanoid.Parent;
        if character ~= nil and players:FindFirstChild(character.Name) then
            if(character == currentCharacter) then
                currentCharacter = nil;
                userMenu.Hide();
                return;
            end

            currentCharacter = character;
            userMenu.Show(character, ancestor);
            return;
        end
    end
    
    userMenu.Hide();
end
 
userInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		DoInput(input.Position);
	elseif input.UserInputType == Enum.UserInputType.Touch then
		DoInput(input.Position);
    end
end);

mainGui.Buttons.FriendsButton.FriendsButton.MouseButton1Click:Connect(function()

    if(friendsListGUI.Enabled) then
        local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local tween = tweenService:Create(friendsListGUI.FriendsFrame, tweenInfo, {Position=UDim2.new(0.5, 0, 1.5, 0)})
        tween:Play()
        tween.Completed:Wait();
        friendsListGUI.Enabled = false;
    else
        friendsListGUI.Enabled = true;
        
        local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local tween = tweenService:Create(friendsListGUI.FriendsFrame, tweenInfo, {Position=UDim2.new(0.5, 0, 0.5, 0)})
        tween:Play()
        tween.Completed:Wait();

        friendsList.ShowFriends();
    end
end);