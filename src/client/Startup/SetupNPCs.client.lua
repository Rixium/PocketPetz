local replicatedStorage = game:GetService("ReplicatedStorage");
local npcs = require(replicatedStorage.Common.Data.NPCs);
local animation = require(game.Players.LocalPlayer.PlayerScripts.Client.Animators.Animation);
local uiManager = require(game.Players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);

local interactGUI = uiManager.GetUi("Interact GUI");
local npcPlacements = workspace.NPCs;

local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait();

for index, placement in pairs(npcPlacements:GetChildren()) do
    local npcObject = replicatedStorage.NPCs[placement.Name];
    local npcData = npcs[placement.Name];
    local cloned = npcObject:Clone();
    local cooldown = false;
    cloned.Parent = placement;
    cloned.Name = npcData.Name;
    
    local animationTrack = animation.Animate(507766388, cloned.Humanoid, true);

    local gameStep;

    gameStep = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)

        local characterPosition = character:GetPrimaryPartCFrame().p;
        local clonedPosition = cloned:GetPrimaryPartCFrame().p;

        if (characterPosition - clonedPosition).Magnitude <= 20 and not cooldown then
            cooldown = true;
            animation.Animate(507770239, cloned.Humanoid);
            interactGUI.Enabled = true;
            interactGUI.Adornee = cloned.HumanoidRootPart;
            spawn(function()
                wait(2.5);
                cooldown = false;
            end);
        end

    end)
end