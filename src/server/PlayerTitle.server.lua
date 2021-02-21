local Billboard = game.ServerStorage.AboveHeadGUI;

local function OnCharacterAdded(character)
	local board = Billboard:Clone()
	board.Parent = character:WaitForChild("HumanoidRootPart")
end

local function OnPlayerAdded(player)
	player.CharacterAdded:Connect(OnCharacterAdded)
end

game.Players.PlayerAdded:Connect(OnPlayerAdded)