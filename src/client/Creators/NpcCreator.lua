local NpcCreator = {};

local replicatedStorage = game:GetService("ReplicatedStorage");
local npcs = require(replicatedStorage.Common.Data.NPCs);
local animation = require(game.Players.LocalPlayer.PlayerScripts.Client.Animators.Animation);
local uiManager = require(game.Players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait();
local playerInteractor = require(game.Players.LocalPlayer.PlayerScripts.Client.PlayerInteractor);

function NpcCreator.New(placement)
    local npcObject = replicatedStorage.NPCs[placement.Name];
    local npcData = npcs[placement.Name];
    local cloned = npcObject:Clone();
    local cooldown = false;
    cloned.Parent = placement;
    cloned.Name = npcData.Name;

    local interactGUI = replicatedStorage.Common["Interact GUI"]:Clone();
    interactGUI.Adornee = cloned.HumanoidRootPart;
    interactGUI.Parent = game.Players.LocalPlayer.PlayerGui;

    interactGUI.ImageButton.MouseButton1Click:Connect(function ()
        playerInteractor.SetInteractable(cloned);
        playerInteractor.Interact();
    end)

    local vector = Vector3.new(0, cloned.HumanoidRootPart.Size.Y, 0);
    cloned:SetPrimaryPartCFrame(placement.CFrame + vector);
    
    local animationTrack = animation.Animate(507766388, cloned.Humanoid, true);

    local gameStep;

    gameStep = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)

        local characterPosition = character:GetPrimaryPartCFrame().Position;
        local clonedPosition = cloned:GetPrimaryPartCFrame().Position;

        if (characterPosition - clonedPosition).Magnitude <= 10 then
            if not cooldown then
                local npcToCharacter = (characterPosition - clonedPosition).Unit;
                local dotProduct = npcToCharacter:Dot(cloned:GetPrimaryPartCFrame().LookVector);
                if (dotProduct > .5) then
                    cooldown = true;
                    animation.Animate(npcData.SeeAnimation, cloned.Humanoid);
                    interactGUI.Enabled = true;
                    spawn(function()
                        wait(2.5);
                        cooldown = false;
                    end);
                end
            end
        else
            interactGUI.Enabled = false;
        end

    end);
end

return NpcCreator;