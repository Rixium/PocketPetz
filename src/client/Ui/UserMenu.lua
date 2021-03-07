local UserMenu = {};

-- Imports

local players = game:GetService("Players");
local userProfile = require(players.LocalPlayer.PlayerScripts.Client.Ui.UserProfile);
local tweenService = game:GetService("TweenService");
local replicatedStorage = game:GetService("ReplicatedStorage");

-- Variables

local clickedPlayer = nil;

-- Functions

function UserMenu.Show(character, adornee)
    local player = players:GetPlayerFromCharacter(character);

    if(player.UserId == players.LocalPlayer.UserId) then
        return
    end

    clickedPlayer = player;

    local menu = players.LocalPlayer.PlayerGui:WaitForChild("Main GUI").UserMenu;
    menu.Adornee = adornee.HumanoidRootPart;
    menu.Enabled = true;

    replicatedStorage.ClickSound:Play();

    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
    local tween = tweenService:Create(menu.ProfileButton, tweenInfo, {Size=UDim2.new(0.4, 0,0.2, 0)})
    local tween2 = tweenService:Create(menu.TradeButton, tweenInfo, {Size=UDim2.new(0.4, 0,0.2, 0)})
    tween:Play()
    tween2:Play()
end

function UserMenu.Hide()
    
    local menu = players.LocalPlayer.PlayerGui:WaitForChild("Main GUI").UserMenu;

    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = tweenService:Create(menu.ProfileButton, tweenInfo, {Size=UDim2.new(0,0,0,0)})
    local tween2 = tweenService:Create(menu.TradeButton, tweenInfo, {Size=UDim2.new(0,0,0,0)})
    tween:Play()
    tween2:Play()
    tween.Completed:Wait();

    menu.Enabled = false;
    menu.Adornee = nil;
end

players.LocalPlayer.PlayerGui:WaitForChild("Main GUI").UserMenu.ProfileButton.MouseButton1Click:Connect(function ()
    userProfile.Show(clickedPlayer);
    UserMenu.Hide();
    clickedPlayer = nil;
end)


return UserMenu;