local Billboard = game.ServerStorage.AboveHeadGUI;
local adminList = require(game.ServerScriptService.Server.Data.AdminList);
local titleService = require(game.ServerScriptService.Server.Services.TitleService);
local titleList = require(game.ServerScriptService.Server.Data.TitleList);

local function OnPlayerAdded(player)
	local character = player.Character or player.CharacterAdded:wait();

	local board = Billboard:Clone()
	board.Parent = character:WaitForChild("Head")

	character:WaitForChild("Humanoid").NameDisplayDistance = 0
	local playersTitles = titleService.GetPlayerTitles(player);
	local first = playersTitles[1];
	local chosenTitle = titleList.GetTitleDataByIndex(first);

	board.NameField.Text = player.Name;
	board.TitleField.Text = chosenTitle.Title.Name;
end

game.Players.PlayerAdded:Connect(OnPlayerAdded)