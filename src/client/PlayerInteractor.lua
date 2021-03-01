local PlayerInteractor = {};

local uiManager = require(game.Players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local replicatedStorage = game:GetService("ReplicatedStorage");
local workspaceHelper = require(replicatedStorage.Common.WorkspaceHelper);
local dialogMenu = game.Players.LocalPlayer.PlayerGui:WaitForChild("Dialog GUI");
local dialogUi = require(dialogMenu.Frame.DialogBackground.DialogLabel.Dialog);
local runService = game:GetService("RunService");
local contextActionService = game:GetService("ContextActionService");
local npcs = require(replicatedStorage.Common.Data.NPCs);
local players = game:GetService("Players");
local userMenu = require(players.LocalPlayer.PlayerScripts.Client.Ui.UserMenu);

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

function PlayerInteractor.GetInteractable()
    return interactable;
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
            
            players.LocalPlayer.Character.Humanoid.WalkSpeed = playerWalkSpeed;
            players.LocalPlayer.Character.Humanoid.JumpHeight = playerJumpHeight;

            uiManager.HideAllExcept({"Main GUI", "Interact GUI"});

            local dialogMenu = players.LocalPlayer.PlayerGui:WaitForChild("Dialog GUI");
            dialogMenu.Enabled = false;

            KeeperDialog.Reset();
            PlayerInteractor.SetInteractable(nil);
        else
            Speak(KeeperDialog);
        end
    else
        local camera = workspace.CurrentCamera;
        local target = interactable:GetPrimaryPartCFrame(); -- workspaceHelper.GetDescendantByName(interactable.Parent, "CameraPoint");
        camera.CameraType = Enum.CameraType.Scriptable;

        local startPos = camera.CFrame;
        local startY = math.deg(math.pi);

        runService:BindToRenderStep("CameraUpdate", Enum.RenderPriority.Camera.Value + 1, function()
            local start = target;
            local rotation = CFrame.Angles(0, math.rad(startY), 0);
            startY = startY + 0.1;
            local distance = 15 -- studs (you can change to something dynamic)
            local cf = start * rotation
            cf = cf - (cf.lookVector * distance)
            camera.CFrame = cf
        end)

        playerWalkSpeed = players.LocalPlayer.Character.Humanoid.WalkSpeed;
        playerJumpHeight = players.LocalPlayer.Character.Humanoid.JumpHeight;
        players.LocalPlayer.Character.Humanoid.WalkSpeed = 0;
        players.LocalPlayer.Character.Humanoid.JumpHeight = 0;

        locked = true;

        uiManager.HideAllExcept({"Dialog GUI"});
        userMenu.Hide();

        Speak(KeeperDialog);
    end
end

return PlayerInteractor;