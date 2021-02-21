local playerInteractor = require(game.Players.LocalPlayer.PlayerScripts.Client.PlayerInteractor);

local dialogMenu = game.Players.LocalPlayer.PlayerGui:WaitForChild("Dialog GUI");
local dialogScript = require(dialogMenu.Frame.DialogLabel.Dialog);

local player = game.Players.LocalPlayer;
local platform = nil;

repeat wait() until player.Character;
local character = player.Character;
local humanoid = character:WaitForChild("Humanoid");

ContextActionService:BindAction("Interact", handleAction, true, Enum.KeyCode.E, Enum.KeyCode.ButtonR1);