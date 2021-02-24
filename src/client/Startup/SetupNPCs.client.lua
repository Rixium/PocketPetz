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

function ResetUserMenu() 
    player.PlayerGui.UserMenu.Enabled = false;
    player.PlayerGui.UserMenu.Adornee = nil;
end

function DoInput(pos)
    local unitRay = camera:ScreenPointToRay(pos.X, pos.Y);
    local ray = Ray.new(unitRay.Origin, unitRay.Direction * 1000)

    local result = game.Workspace:FindPartOnRay(ray);
    if(result == nil or result.Parent == nil) then
        ResetUserMenu();
        return;
    end

    local ancestor = result:FindFirstAncestorOfClass("Model");

    if(ancestor == nil) then
        ResetUserMenu();
        return;
    end

    local humanoid = ancestor:FindFirstChild("Humanoid");

    if humanoid then
        local character = humanoid.Parent;
        if character ~= nil and players:FindFirstChild(character.Name) then
            clickedPlayer = character;
            player.PlayerGui.UserMenu.Enabled = true;
            player.PlayerGui.UserMenu.Adornee = ancestor.HumanoidRootPart;
            return;
        end
    end
    
    clickedPlayer = nil;
    ResetUserMenu();
    
end

local UserInputService = game:GetService("UserInputService")
 
-- A sample function providing multiple usage cases for various types of user input
UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		DoInput(input.Position);
	elseif input.UserInputType == Enum.UserInputType.Touch then
		DoInput(input.Position);
    end
end);

function SetUserProfile(playerCharacter)
    local profilePlayer = game.Players:GetPlayerFromCharacter(playerCharacter);
    profileGUI.HeaderFrame.NameLabel.Text = profilePlayer.Name;

    local userId = profilePlayer.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    profileGUI.ProfileFrame.ProfilePicture.Image = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize);
end

player.PlayerGui.UserMenu.ProfileButton.MouseButton1Click:Connect(function ()
    SetUserProfile(clickedPlayer);
    profileGUI.Visible = true;
    player.PlayerGui.UserMenu.Enabled = false;
    player.PlayerGui.UserMenu.Adornee = nil;
    clickedPlayer = nil;
end)