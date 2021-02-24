local UserMenu = {};

-- Imports

local players = game:GetService("Players");
local userProfile = require(players.LocalPlayer.PlayerScripts.Client.Ui.UserProfile);

-- Variables

local clickedPlayer = nil;

-- Functions

function UserMenu.Show(player, adornee)
    clickedPlayer = player;
    players.LocalPlayer.PlayerGui.UserMenu.Enabled = true;
    players.LocalPlayer.PlayerGui.UserMenu.Adornee = adornee.HumanoidRootPart;
end

function UserMenu.Hide()
    players.LocalPlayer.PlayerGui.UserMenu.Enabled = false;
    players.LocalPlayer.PlayerGui.UserMenu.Adornee = nil;
end

players.LocalPlayer.PlayerGui.UserMenu.ProfileButton.MouseButton1Click:Connect(function ()
    userProfile.Show(clickedPlayer);
    UserMenu.Hide();
    clickedPlayer = nil;
end)


return UserMenu;