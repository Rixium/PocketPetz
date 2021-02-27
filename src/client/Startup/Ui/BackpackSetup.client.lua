local players = game:GetService("Players");
local backpackMenu = require(players.LocalPlayer.PlayerScripts.Client.Ui.BackpackMenu);
local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local mainGui = uiManager.GetUi("Main GUI");

mainGui.Buttons.BagButton.BagButton.MouseButton1Click:Connect(function()
    backpackMenu.Toggle();
end)

backpackMenu.SetupNavigationBar();