local onBuyZone = false;
local locked = false;

local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local FROZEN_ACTION_KEY = "freezeMovement"

local dialogMenu = game.Players.LocalPlayer.PlayerGui:WaitForChild("Dialog GUI");
local dialogScript = require(dialogMenu.Frame.DialogLabel.Dialog);

function disableControls() 
	ContextActionService:BindActionAtPriority(
		FROZEN_ACTION_KEY,
		function() 
			return Enum.ContextActionResult.Sink
		end,
		false,
		Enum. ContextActionPriority.High.Value,
		unpack(Enum.PlayerActions:GetEnumItems())
	);
end

local player = game.Players.LocalPlayer;
local platform = nil;

repeat wait() until player.Character;
local character = player.Character;
local humanoid = character:WaitForChild("Humanoid");

if(humanoid) then
	humanoid.Touched:Connect(function(PartHit, LimbPart)
		if LimbPart == "Left Leg" or "Right Leg" then
			if(PartHit.Name == "TalkPlatform") then
				platform = PartHit;
				onBuyZone = true;
			else
				platform = nil;
				onBuyZone = false;
			end
		end
	end)
end


local ContextActionService = game:GetService("ContextActionService")

local function HideAllGUIExcept(guis)
	for index, value in ipairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
		if(value.ClassName ~= "ScreenGui") then
			continue;
		end
		
		if table.find(guis, value.Name) then
			game.Players.LocalPlayer.PlayerGui[value.Name].Enabled = true;
			continue;
		end
		
		game.Players.LocalPlayer.PlayerGui[value.Name].Enabled = false;
	end
end

local function handleAction(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		if(onBuyZone) then
			if(locked) then
				local dialog = require(platform.DialogScript);
				
				if(dialog.PeekNext() == nil) then
					local camera = workspace.CurrentCamera;
					camera.CameraType = Enum.CameraType.Custom;
					ContextActionService:UnbindAction(FROZEN_ACTION_KEY)
					RunService:UnbindFromRenderStep("CameraUpdate")
					locked = false;
					
					HideAllGUIExcept({"Main GUI"});
					
					local dialogMenu = game.Players.LocalPlayer.PlayerGui["Dialog GUI"];
					dialogMenu.Enabled = false;
				else
					HideAllGUIExcept({"Dialog GUI"});
					
					if(dialogScript.Ready()) then
						local next = dialog.GetNext();
						dialogScript.DoDialog(next);
					end
				end
			else
				local camera = workspace.CurrentCamera;
				local target = platform.CameraPoint;
				camera.CameraType = Enum.CameraType.Scriptable;

				RunService:BindToRenderStep("CameraUpdate", Enum.RenderPriority.Camera.Value + 1, function()
					camera.CFrame = camera.CFrame:Lerp(target.CFrame, .05)
				end)

				disableControls();
				locked = true;
			end
		end
	end
end

ContextActionService:BindAction("Interact", handleAction, true, Enum.KeyCode.E, Enum.KeyCode.ButtonR1);