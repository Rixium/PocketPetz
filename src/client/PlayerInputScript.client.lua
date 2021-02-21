local contextActionService = game:GetService("ContextActionService");
local playerInteractor = require(game.Players.LocalPlayer.PlayerScripts.Client.PlayerInteractor);

function onInteractKeyPressed()
	playerInteractor.Interact();
end

contextActionService:BindAction("Interact", onInteractKeyPressed, true, Enum.KeyCode.E, Enum.KeyCode.ButtonR1);