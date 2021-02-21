local replicatedStorage = game:GetService("ReplicatedStorage");
local workspaceHelper = require(replicatedStorage.Common.WorkspaceHelper);
local uiManager = require(game.Players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);

local sally = workspaceHelper.GetDescendantByName(game, "Lab Tech Sally");
local animation = sally:WaitForChild("Animation");
local humanoid = sally:WaitForChild("Humanoid");
local sallyRoot = sally:WaitForChild("HumanoidRootPart");

local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait();

local run = humanoid:LoadAnimation(animation);
run.Looped = true;
run:Play();

while wait() do
    local mainGui = uiManager.GetUi("Main GUI");
    local billboard = mainGui.Interact;

    local characterPosition = character:GetPrimaryPartCFrame().p;
	if (characterPosition - sallyRoot.Position).Magnitude <= 20 then
		billboard.Enabled = true;
    else
        billboard.Enabled = false;
    end
end