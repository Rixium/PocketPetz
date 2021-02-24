-- Imports
local players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local userMenu = require(players.LocalPlayer.PlayerScripts.Client.Ui.UserMenu);

-- Variables
local player = players.LocalPlayer
local camera = workspace.CurrentCamera;

-- Functions
function DoInput(pos)
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