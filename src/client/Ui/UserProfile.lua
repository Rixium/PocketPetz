local UserProfile = {};

-- Imports
local players = game:GetService("Players");
local replicatedStorage = game:GetService("ReplicatedStorage");
local starterGuiService = game:GetService("StarterGui")
local tweenService = game:GetService("TweenService")

-- Variables
local mainGUI = players.LocalPlayer.PlayerGui:WaitForChild("Main GUI");
local profileGUI = mainGUI["Profile GUI"];

-- Functions
function UserProfile.Show(player, character)
    profileGUI.ProfileBack.HeaderFrame.ImageLabel.ImageLabel.NameLabel.Text = player.Name;

    profileGUI.ProfileBack.ProfileFrame.AddFriends.Visible = player.UserId ~= players.LocalPlayer.UserId;

    local userId = player.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420

    
    local userTitle = character.Head.AboveHeadGUI.TitleField.Text;
    profileGUI.ProfileBack.HeaderFrame.ImageLabel.ImageLabel.TitleLabel.Text = userTitle;


    spawn(function () 
        profileGUI.ProfileBack.ProfileFrame.ImageLabel.ProfilePicture.Image = players:GetUserThumbnailAsync(userId, thumbType, thumbSize);
    end)

    local button = profileGUI.ProfileBack.ProfileFrame.AddFriends.AddFriendsButton.MouseButton1Click:Connect(function()
        starterGuiService:SetCore("PromptSendFriendRequest", player);
    end);

    profileGUI.Visible = true;

    replicatedStorage.ClickSound:Play();
    
    local toTween = profileGUI.ProfileBack;
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
    local tween = tweenService:Create(toTween, tweenInfo, {Size=UDim2.new(0.628, 0 , 0.5, 0)})
    tween:Play()
end

function UserProfile.Toggle(character)
    if(profileGUI.Visible) then
        local toTween = profileGUI.ProfileBack;
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local tween = tweenService:Create(toTween, tweenInfo, {Size=UDim2.new(0, 0, 0, 0)})
        tween:Play();
        tween.Completed:Wait();
        profileGUI.Visible = false;
    end
end

return UserProfile;