local UserProfile = {};

-- Imports
local players = game:GetService("Players");
local replicatedStorage = game:GetService("ReplicatedStorage");
local starterGuiService = game:GetService("StarterGui")

-- Variables
local mainGUI = players.LocalPlayer.PlayerGui:WaitForChild("Main GUI");
local profileGUI = mainGUI["Profile GUI"];

-- Functions
function UserProfile.Show(character)
    local profilePlayer = players:GetPlayerFromCharacter(character);
    profileGUI.ProfileBack.HeaderFrame.ImageLabel.NameLabel.Text = profilePlayer.Name;

    profileGUI.ProfileBack.ProfileFrame.AddFriends.Visible = profilePlayer.UserId ~= players.LocalPlayer.UserId;

    local userId = profilePlayer.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420

    
    local userTitle = character.Head.AboveHeadGUI.TitleField.Text;
    profileGUI.ProfileBack.HeaderFrame.ImageLabel.TitleLabel.Text = userTitle;


    spawn(function () 
        profileGUI.ProfileBack.ProfileFrame.ImageLabel.ProfilePicture.Image = players:GetUserThumbnailAsync(userId, thumbType, thumbSize);
    end)

    local button = profileGUI.ProfileBack.ProfileFrame.AddFriends.AddFriendsButton.MouseButton1Click:Connect(function()
        starterGuiService:SetCore("PromptSendFriendRequest", profilePlayer);
    end);

    profileGUI.Visible = true;
end

function UserProfile.Toggle(character)
    if(profileGUI.Visible) then
        profileGUI.Visible = false;
    else
        UserProfile.Show(character);
    end
end

return UserProfile;