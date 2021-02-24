local UserProfile = {};

-- Imports
local players = game:GetService("Players");

-- Variables
local mainGUI = players.LocalPlayer.PlayerGui:WaitForChild("Main GUI");
local profileGUI = mainGUI["Profile GUI"];

-- Functions
function UserProfile.Show(character)
    local profilePlayer = players:GetPlayerFromCharacter(character);
    profileGUI.HeaderFrame.NameLabel.Text = profilePlayer.Name;

    local userId = profilePlayer.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420

    profileGUI.ProfileFrame.ProfilePicture.Image = players:GetUserThumbnailAsync(userId, thumbType, thumbSize);
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