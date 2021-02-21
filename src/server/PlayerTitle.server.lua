local Billboard = game.ServerStorage.AboveHeadGUI;
local adminList = require(game.ServerScriptService.Server.Data.AdminList);

local function OnCharacterAdded(character)
	local board = Billboard:Clone()
	board.Parent = character:WaitForChild("Head")

	character:WaitForChild("Humanoid").NameDisplayDistance = 0

	if(adminList.Contains(character)) then
		board.Title.Text = "Admin " .. character.Name;
	else
		board.Title.Text = "Noob " .. character.Name;
	end
end

local function OnPlayerAdded(player)
	player.CharacterAdded:Connect(OnCharacterAdded)
end

game.Players.PlayerAdded:Connect(OnPlayerAdded)