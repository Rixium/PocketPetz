local Billboard = game.ServerStorage.AboveHeadGUI;
local adminList = require(game.ServerScriptService.Server.Data.AdminList);

local function OnCharacterAdded(character)
	local board = Billboard:Clone()
	board.Parent = character:WaitForChild("HumanoidRootPart")

	if(adminList.Contains(character)) then
		board.Title.Text = "Admin";
	end
end

local function OnPlayerAdded(player)
	player.CharacterAdded:Connect(OnCharacterAdded)
end

game.Players.PlayerAdded:Connect(OnPlayerAdded)