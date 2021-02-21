local replicatedStorage = game:GetService("ReplicatedStorage");
local workspaceHelper = require(replicatedStorage.Common.WorkspaceHelper);

local sally = workspaceHelper.GetDescendantByName(game, "Lab Tech Sally");
local animation = sally:WaitForChild("Animation");
local humanoid = sally:WaitForChild("Humanoid");
local sallyRoot = sally:WaitForChild("HumanoidRootPart");

local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait();

local run = humanoid:LoadAnimation(animation);
run.Looped = true;
run:Play();

while wait() do
    local characterPosition = character:GetPrimaryPartCFrame().p;
	if (characterPosition - sallyRoot.Position).Magnitude <= 10 then
		sally.BillboardGui.Enabled = true;
    else
        sally.BillboardGui.Enabled = false;
    end
end