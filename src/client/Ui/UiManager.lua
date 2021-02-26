local UiManager = {};

UiManager.Uis = {
    "Main GUI",
    "Inventory GUI",
    "Dialog GUI",
    "Start Menu GUI",
    "Interact GUI",
    "Titles GUI"
}

function UiManager.GetUi(name)
    return game.Players.LocalPlayer.PlayerGui:WaitForChild(name);
end

function UiManager.HideAllExcept(guiTable)
    for index, value in ipairs(UiManager.Uis) do
		if table.find(guiTable, value) then
			game.Players.LocalPlayer.PlayerGui:WaitForChild(value).Enabled = true;
			continue;
		end
		
		game.Players.LocalPlayer.PlayerGui:WaitForChild(value).Enabled = false;
	end 
end

return UiManager;