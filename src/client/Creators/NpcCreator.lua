local NpcCreator = {};

local replicatedStorage = game:GetService("ReplicatedStorage");
local npcAboveHeadGUI = replicatedStorage.AboveHeadGUI;

local marketplaceService = game:GetService("MarketplaceService");
local npcs = require(replicatedStorage.Common.Data.NPCs);
local animation = require(game.Players.LocalPlayer.PlayerScripts.Client.Animators.Animation);
local uiManager = require(game.Players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait();
local playerInteractor = require(game.Players.LocalPlayer.PlayerScripts.Client.PlayerInteractor);

function GiveNpcAboveHeadGUI(npc, npcData)
    local board = npcAboveHeadGUI:Clone()
	board.Parent = npc:WaitForChild("Head")
	board.NameField.Text = npcData.Name;
	board.TitleField.Text = npcData.Title or "Noob";
end

function CreateNpcBody(npc, npcData)
    local humanoid = npc:WaitForChild("Humanoid");
    local description = humanoid:GetAppliedDescription();

    description.Shirt = npcData.ShirtId;
    description.Pants = npcData.PantsId;
    description.HeadColor = npcData.SkinColor;
    description.LeftArmColor = npcData.SkinColor;
    description.LeftArm = npcData.Body.LeftArm;
    description.RightArmColor = npcData.SkinColor;
    description.RightArm = npcData.Body.RightArm;
    description.LeftLegColor = npcData.SkinColor;
    description.LeftLeg = npcData.Body.LeftLeg;
    description.RightLegColor = npcData.SkinColor;
    description.RightLeg = npcData.Body.RightLeg;
    description.TorsoColor = npcData.SkinColor;
    description.Torso = npcData.Body.Torso;
    description.HairAccessory = npcData.Hair;
    description.Face = npcData.Face;
    description.Head = npcData.Body.Head;
    
    humanoid:ApplyDescription(description);
end

function NpcCreator.New(placement)
    local npcObject = replicatedStorage.NPCs[placement.Name];
    local npcData = npcs[placement.Name];
    local cloned = npcObject:Clone();
    local cooldown = false;
    cloned.Parent = placement;
    cloned.Name = npcData.Name;

    GiveNpcAboveHeadGUI(cloned, npcData);
    CreateNpcBody(cloned, npcData);

    local interactGUI = replicatedStorage["Interact GUI"]:Clone();
    interactGUI.Adornee = cloned.HumanoidRootPart;
    interactGUI.Parent = game.Players.LocalPlayer.PlayerGui;

    interactGUI.ImageButton.MouseButton1Click:Connect(function ()
        interactGUI.Enabled = false;
        playerInteractor.SetInteractable(cloned);
        playerInteractor.Interact();
    end)

    local humanoid = cloned:WaitForChild("Humanoid");
    local vector = Vector3.new(0, humanoid.HipHeight + 0.4, 0);
    cloned:SetPrimaryPartCFrame(placement.CFrame + vector);
    
    local animationTrack = animation.Animate(507766388, cloned.Humanoid, true);

    local gameStep;

    gameStep = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)

        local characterPosition = character:GetPrimaryPartCFrame().Position;
        local clonedPosition = cloned:GetPrimaryPartCFrame().Position;

        interactGUI.Enabled = false;
        
        if (characterPosition - clonedPosition).Magnitude <= 10 then
            -- Check the player is in front of the NPC
            local npcToCharacter = (characterPosition - clonedPosition).Unit;
            local dotProduct = npcToCharacter:Dot(cloned:GetPrimaryPartCFrame().LookVector);
            if (dotProduct > .5) then

                -- Only enable the GUI if the player interactor has no interactable
                if playerInteractor.GetInteractable() == nil then
                    interactGUI.Enabled = true;
                end

                if not cooldown then
                    cooldown = true;
                    animation.Animate(npcData.SeeAnimation, cloned.Humanoid);
                    spawn(function()
                        wait(2.5);
                        cooldown = false;
                    end);
                end
            end
        end

    end);
end

return NpcCreator;