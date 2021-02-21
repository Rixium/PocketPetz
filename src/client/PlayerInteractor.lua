local PlayerInteractor = {};

local uiManager = require(game.Players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local replicatedStorage = game:GetService("ReplicatedStorage");
local workspaceHelper = require(replicatedStorage.Common.WorkspaceHelper);
local dialogMenu = game.Players.LocalPlayer.PlayerGui:WaitForChild("Dialog GUI");
local dialogUi = require(dialogMenu.Frame.DialogLabel.Dialog);
local runService = game:GetService("RunService");
local contextActionService = game:GetService("ContextActionService");

local locked = false;
local interactable = nil;
local FROZEN_ACTION_KEY = "freezeMovement"

function disableControls() 
	contextActionService:BindActionAtPriority(
		FROZEN_ACTION_KEY,
		function() 
			return Enum.ContextActionResult.Sink
		end,
		false,
		Enum. ContextActionPriority.High.Value,
		unpack(Enum.PlayerActions:GetEnumItems())
	);
end

function Speak(dialog)
    if(dialogUi.Ready()) then
        local next = dialog.GetNext();
        dialogUi.DoDialog(next);
    end
end

function PlayerInteractor.SetInteractable(obj)
    interactable = obj;
end

function PlayerInteractor.Interact()
    print("INTREACT")
    if(interactable == nil) then
        return;
    end

    local dialog = require(interactable.Parent.DialogScript);

    if(locked) then
        if(dialog.PeekNext() == nil) then
            local camera = workspace.CurrentCamera;
            camera.CameraType = Enum.CameraType.Custom;
            contextActionService:UnbindAction(FROZEN_ACTION_KEY)
            runService:UnbindFromRenderStep("CameraUpdate")
            locked = false;
            
            uiManager.HideAllExcept({"Main GUI"});
            
            local dialogMenu = game.Players.LocalPlayer.PlayerGui["Dialog GUI"];
            dialogMenu.Enabled = false;

            dialog.Reset();
        else
            Speak(dialog);
        end
    else
        local camera = workspace.CurrentCamera;
        local target = workspaceHelper.GetDescendantByName(interactable.Parent, "CameraPoint");
        camera.CameraType = Enum.CameraType.Scriptable;

        runService:BindToRenderStep("CameraUpdate", Enum.RenderPriority.Camera.Value + 1, function()
            camera.CFrame = camera.CFrame:Lerp(target.CFrame, .05)
        end)

        disableControls();
        locked = true;
        
        uiManager.HideAllExcept({"Dialog GUI"});

        Speak(dialog);
    end
end

return PlayerInteractor;