local PlayerInteractor = {};

local uiManager = require(game.Players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local replicatedStorage = game:GetService("ReplicatedStorage");
local workspaceHelper = require(replicatedStorage.Common.WorkspaceHelper);
local dialogMenu = game.Players.LocalPlayer.PlayerGui:WaitForChild("Dialog GUI");
local dialogUi = require(dialogMenu.DialogBackground.DialogLabel.Dialog);
local runService = game:GetService("RunService");
local contextActionService = game:GetService("ContextActionService");
local npcs = require(replicatedStorage.Common.Data.NPCs);

local locked = false;
local interactable = nil;

local KeeperDialog = {};
local lastDialog = 1;

local playerWalkSpeed;
local playerJumpHeight;

KeeperDialog.Dialog = {
	
};

function KeeperDialog.GetNext()
	local next = KeeperDialog.Dialog[lastDialog];
	lastDialog = lastDialog + 1;

	return next;
end

function KeeperDialog.PeekNext()
	return KeeperDialog.Dialog[lastDialog];
end

function KeeperDialog.Reset()
	lastDialog = 1;
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
    if(interactable == nil) then
        return;
    end

    local dialog = npcs[interactable.Name].Dialog;
    KeeperDialog.Dialog = dialog;

    if(locked) then
        if(KeeperDialog.PeekNext() == nil) then
            local camera = workspace.CurrentCamera;
            camera.CameraType = Enum.CameraType.Custom;

            runService:UnbindFromRenderStep("CameraUpdate")
            locked = false;
            
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = playerWalkSpeed;
            game.Players.LocalPlayer.Character.Humanoid.JumpHeight = playerJumpHeight;

            uiManager.HideAllExcept({"Main GUI", "Interact GUI"});
            
            local dialogMenu = game.Players.LocalPlayer.PlayerGui["Dialog GUI"];
            dialogMenu.Enabled = false;

            KeeperDialog.Reset();
            PlayerInteractor.SetInteractable(nil);
        else
            Speak(KeeperDialog);
        end
    else
        local camera = workspace.CurrentCamera;
        local target = workspaceHelper.GetDescendantByName(interactable.Parent, "CameraPoint");
        camera.CameraType = Enum.CameraType.Scriptable;

        runService:BindToRenderStep("CameraUpdate", Enum.RenderPriority.Camera.Value + 1, function()
            camera.CFrame = camera.CFrame:Lerp(target.CFrame, .05)
        end)

        playerWalkSpeed = game.Players.LocalPlayer.Character.Humanoid.WalkSpeed;
        playerJumpHeight = game.Players.LocalPlayer.Character.Humanoid.JumpHeight;
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 0;
        game.Players.LocalPlayer.Character.Humanoid.JumpHeight = 0;

        locked = true;
        
        uiManager.HideAllExcept({"Dialog GUI"});

        Speak(KeeperDialog);
    end
end

return PlayerInteractor;