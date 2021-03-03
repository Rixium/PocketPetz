local replicatedStorage = game:GetService("ReplicatedStorage");
local Billboard = replicatedStorage.AboveHeadGUI;

local serverScriptService = game:GetService("ServerScriptService");
local titleService = require(serverScriptService.Server.Services.TitleService);
local titleList = require(serverScriptService.Server.Data.TitleList);

local dataStoreGet = require(serverScriptService.Server.DataStoreGet);
local dataStore2 = dataStoreGet.DataStore;

local activeTitleData = "ActiveTitle";

local function CharacterAdded(character)
	local board = Billboard:Clone()
	local player = game.Players:GetPlayerFromCharacter(character);
	board.Parent = character:WaitForChild("Head")

	character:WaitForChild("Humanoid").NameDisplayDistance = 0
	local playersTitles = titleService.GetPlayerTitles(player);

	local chosenTitle = playersTitles[1];

    local activeTitleStore = dataStore2(activeTitleData, player);
    local activeTitle = activeTitleStore:Get(chosenTitle.Name);
	
	board.NameField.Text = player.Name;
	board.TitleField.Text = activeTitle;
end

local function OnPlayerAdded(player)
	player.CharacterAdded:Connect(CharacterAdded);
end

game.Players.PlayerAdded:Connect(OnPlayerAdded)