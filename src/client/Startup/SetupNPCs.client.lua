local npcCreator = require(game.Players.LocalPlayer.PlayerScripts.Client.Creators.NpcCreator);

local npcPlacements = workspace.NPCs;

for index, placement in pairs(npcPlacements:GetChildren()) do
     spawn(function() 
        npcCreator.New(placement);
    end)
end


-- Profile
local Players = game:GetService("Players")
local mainGUI = game.Players.LocalPlayer.PlayerGui["Main GUI"];
local profileGUI = mainGUI["Profile GUI"];

profileGUI.HeaderFrame.NameLabel.Text = game.Players.LocalPlayer.Name;

local userId = game.Players.LocalPlayer.UserId
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420
profileGUI.ProfileFrame.ProfilePicture.Image = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize);

-- Click Detection

local players = game:GetService("Players")
local player = players.LocalPlayer

local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera;

UserInputService.InputBegan:connect(function(input)
	local pos = input.Position

    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local mouseLocation = pos;
        local unscaled_ray = camera:ViewportPointToRay(mouseLocation.X,mouseLocation.Y)
        local result = workspace:Raycast(unscaled_ray.Origin, unscaled_ray.Direction*1000)

        if(result == nil or result.Instance == nil) then
            return;
        end

        if result.Instance.Parent:FindFirstChild("Humanoid") then
            local humanoid = result.Instance.Parent:FindFirstChild("Humanoid");
            local character = humanoid.Parent;
            if(players[character.Name] ~= nil) then
                player.PlayerGui.UserMenu.Enabled = true;
                player.PlayerGui.UserMenu.Adornee = result.Instance.Parent.HumanoidRootPart;
            end
        end
	end
end)

player.PlayerGui.UserMenu.ProfileButton.MouseButton1Click:Connect(function ()
    profileGUI.Visible = true;
    player.PlayerGui.UserMenu.Enabled = false;
    player.PlayerGui.UserMenu.Adornee = nil;
end)