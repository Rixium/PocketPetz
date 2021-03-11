local PetManager = {};

-- Imports
local players = game:GetService("Players");
local pathfindingService = game:GetService("PathfindingService");
local keyframeSequenceProvider = game:GetService("KeyframeSequenceProvider");
local replicatedStorage = game:GetService("ReplicatedStorage");
local petAttackingEvent = replicatedStorage.Common.Events.PetAttackingEvent;
local petGotExperience = replicatedStorage.Common.Events.PetGotExperience;
local petStopAttackingEvent = replicatedStorage.Common.Events.PetStopAttackingEvent;
local petRequestAttack = replicatedStorage.Common.Events.PetRequestAttack;
local petEvolved = replicatedStorage.Common.Events.PetEvolved;
local evolutionGui = require(players.LocalPlayer.PlayerScripts.Client.Ui.EvolutionGUI);
local setPetAnimation = replicatedStorage.Common.Events.SetPetAnimation;
local targetKilled = replicatedStorage.Common.Events.TargetKilled;
local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local stopCombatFrame = uiManager.GetUi("Main GUI"):WaitForChild("StopCombatFrame");
local cancelCombatButton = uiManager.GetUi("Main GUI"):WaitForChild("StopCombatFrame").CancelButton;
local physicsService = game:GetService("PhysicsService");

-- Variables
local board = nil;
local activePet = nil;
local activePetData = nil;
local activeTarget = nil;
local nextTarget = nil;
local runner = nil;
local toldServer = false;
local animationPlaying = false;
local track = nil;
local attackTrack = nil;
local targetHitAnimation = nil;
local requesting = false;
local petSpawning = false;
local damages = {};
local RNG = Random.new()
local bodyPosition = nil
local bodyGyro = nil

local sound = nil;


-- Functions

-- UI Stuff
local TweenService = game:GetService("TweenService")
local GUI = stopCombatFrame;

local function Shrink()
	local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	local tween = TweenService:Create(GUI, tweenInfo, {Size=UDim2.new(0, 0, 0, 0)})
	tween:Play()
    tween.Completed:Wait();
    stopCombatFrame.Visible = false;
end

local function Grow()
    stopCombatFrame.Visible = true;
	local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	local tween = TweenService:Create(GUI, tweenInfo, {Size=UDim2.new(0.1, 0, 0.1, 0)})
	tween:Play()
    tween.Completed:Wait();
end

 -- End of UI Stuff

local function MoveTo(target, targetCFrame, shouldTeleport)
    if(activePet == nil) then return end
    if(nextPet ~= nil) then return end
    if(petSpawning) then return end

    if(activePet.Parent == nil) then
        activePet.AncestryChanged:wait()
    end

    local distance = (targetCFrame.p - activePet.Root.CFrame.p).magnitude;

    if(shouldTeleport) then
        if(distance > 30) then
            activePet:SetPrimaryPartCFrame(targetCFrame:ToWorldSpace(CFrame.new(3,1,3)));
        end
    end

    if(distance < 5) then
        return false;
    end 

    local model = activePet;
    local petCframe = activePet.Root.CFrame.p;

    bodyPosition.Position = activePet.Root.CFrame:Lerp(targetCFrame, 0.15).p;
    bodyGyro.CFrame = CFrame.new(model.Root.CFrame.Position, targetCFrame.Position);

    if not animationPlaying then
        animationPlaying = true;

        local animator = activePet:WaitForChild("Humanoid");
        if animator then
            track = animator:LoadAnimation(activePet.Animations.Walk)
            track:Play()
            setPetAnimation:FireServer(activePet.Animations.Walk);
        end

    end

    return (petCframe - bodyPosition.Position).magnitude > 0.001;
end

local function AttackTarget()
    if(activeTarget == nil) then return end
    if(activePet == nil) then return end
    if(toldServer) then return end

    if(activePet.Parent == nil) then
        activePet.AncestryChanged:wait()
    end

    toldServer = true;
    Grow();
    
    local petAnimator = activePet:WaitForChild("Humanoid");
    if petAnimator then
        attackTrack = petAnimator:LoadAnimation(activePet.Animations.Attack);
        setPetAnimation:FireServer(activePet.Animations.Attack);
        attackTrack.KeyframeReached:Connect(function(keyframeName)
            if(keyframeName == "Hit") then
                    
                local damageGUI = replicatedStorage.DamageBillboard:clone();
                damageGUI.Frame.Damage.Text = math.floor(20 * attackTrack.Length);
                damageGUI.Parent = workspace;
                damageGUI.Adornee = activeTarget.Parent;

                damageGUI.ExtentsOffset = Vector3.new(RNG:NextNumber(-1.0, 1.0), 0, RNG:NextNumber(-1.0, 1.0));

                table.insert(damages, {
                    GUI = damageGUI,
                    Time = 3
                });

                petAttackingEvent:FireServer(activePet, activePetData, activeTarget);

                sound:Play();
            end
        end);
        attackTrack:Play();
    end
end

local function UpdateXpBar(itemData)
    if(activePetData == nil) then return end

    local width = itemData.Data.CurrentExperience / activePetData.ItemData.ExperienceToLevel;
    
    if(width > 1) then
        width = 1;
    end

    board.Experience.Size = UDim2.new(width,0, 0.4,0);
end

local function ShowXpAbove(model, itemData)
    local npcAboveHeadGUI = replicatedStorage.ExperienceGUI;
    board = npcAboveHeadGUI:Clone()
    board.Parent = workspace;
    board.Adornee = model.Root;
    
    local currentExperience = itemData.PlayerItem.Data.CurrentExperience;
    local toLevel = itemData.ItemData.ExperienceToLevel;

    board.NameLabel.Text = itemData.ItemData.Name;

    local width = currentExperience / toLevel;
    board.Experience.Size = UDim2.new(width,0, 0.4,0);

    itemData.PlayerItem.Data.CurrentExperience = itemData.PlayerItem.Data.CurrentExperience + 0.1;
    UpdateXpBar(itemData.PlayerItem);
end

local function DoCombat()
    if(activeTarget == nil) then return end
    if(activePet == nil) then return end

    local targetCFrame = activeTarget.Parent.Root.CFrame:ToWorldSpace();
    local distance = (targetCFrame.p - activePet.Root.CFrame.p).magnitude;
    local moved = false;

    if(distance > 3 and distance > 4) then
        moved = MoveTo(activeTarget, targetCFrame);
    end 

    if not moved then
        if (track ~= nil and animationPlaying) then
            animationPlaying = false;
            track:Stop();
            track = nil;
            setPetAnimation:FireServer(nil);
        end

        AttackTarget();
    end
end

local function CheckForCleanup()
    if(activePet == nil) then return end

    local model = activePet;
    local playerCharacter = players.LocalPlayer.Character;

    if not model.PrimaryPart then
        model:Destroy();
        return;
    end

    if not playerCharacter.PrimaryPart then
        model:Destroy();
        return;
    end
end

local function UpdatePet(delta)
    
    for _, damageGUI in pairs(damages) do
        damageGUI.Time = damageGUI.Time - delta;
        damageGUI.GUI.ExtentsOffset = Vector3.new(damageGUI.GUI.ExtentsOffset.X, damageGUI.GUI.ExtentsOffset.Y + 2 * delta, damageGUI.GUI.ExtentsOffset.Z);
        damageGUI.GUI.Frame.ImageLabel.ImageTransparency = damageGUI.GUI.Frame.ImageLabel.ImageTransparency + delta;
        damageGUI.GUI.Frame.Damage.TextTransparency = damageGUI.GUI.Frame.Damage.TextTransparency + delta;
    end

    for i, damageGUI in pairs(damages) do
        if(damageGUI.Time <= 0) then
            damageGUI.GUI:Destroy();
            table.remove(damages, i);
        end
    end

    CheckForCleanup();

    if(activePet == nil) then
        return;
    end

    if(activeTarget ~= nil) then
        DoCombat();
    else
        local targetCFrame = players.LocalPlayer.Character:WaitForChild("RightFoot").CFrame:ToWorldSpace(CFrame.new(3,0,3));
        local distance = (targetCFrame.p - activePet.Root.CFrame.p).magnitude;
        local moved = false;

        if(distance > 4 and distance > 6) then
            moved = MoveTo(players.LocalPlayer.Character.Head, targetCFrame, true);
        end

        if not moved then
            if (track ~= nil and animationPlaying) then
                animationPlaying = false;
                track:Stop();
                track = nil;
                setPetAnimation:FireServer(nil);
            end
        end
    end
end

local function SetupPet(pet, petData)
    sound = Instance.new("Sound", pet.Root);
    sound.SoundId = "rbxassetid://3748780065"
    sound.Name = "TestSound"
    sound.Volume = 0.2;
    sound.RollOffMinDistance = 0;
    sound.RollOffMaxDistance = 50;
    sound.RollOffMode = Enum.RollOffMode.LinearSquare;

    bodyPosition = Instance.new("BodyPosition", pet.Root);
    bodyPosition.D = 700;

    bodyGyro = Instance.new("BodyGyro", pet.Root);

    bodyPosition.MaxForce = Vector3.new(math.huge, 50, math.huge);
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge);
    bodyGyro.D = 10;

    ShowXpAbove(pet, petData);

    petGotExperience.OnClientEvent:Connect(function(pet) 
        UpdateXpBar(pet);
    end);
    
    
    activePetData = petData;
    activePet = pet;
    
	physicsService:SetPartCollisionGroup(activePet.PrimaryPart, "Pets")
    bodyPosition.Position = players.LocalPlayer.Character:GetPrimaryPartCFrame():ToWorldSpace(CFrame.new(3,1,3)).p;

    petSpawning = false;
end

local function StopCombat()
    if(activePet == nil) then return end
    if(activeTarget == nil) then return end

    if(attackTrack ~= nil) then
        attackTrack:Stop();
    end

    if(targetHitAnimation ~= nil) then
        targetHitAnimation:Stop();
    end

    Shrink();
    petStopAttackingEvent:FireServer(activePet, activePetData, activeTarget);
    activeTarget = nil;

    toldServer = false;

    setPetAnimation:FireServer(nil);
end

function PetManager.SetTarget(target)
    if(activeTarget == target) then return end
    if(nextTarget == target) then return end
    if(requesting) then return end

    -- Make sure that the player is trying to attack a valid target, also stores this data
    -- server side for subsequent requests :)
    requesting = true;
    local targetIsValid = petRequestAttack:InvokeServer(target);
    requesting = false;
    
    if not targetIsValid then return end

    nextTarget = target;

    StopCombat();
    activeTarget = target;
    nextTarget = nil;

    local targetKilledEvent;

     targetKilledEvent = targetKilled.OnClientEvent:Connect(function()
        targetKilledEvent:Disconnect();
        StopCombat();
    end);
end

function PetManager.SetActivePet(pet, petData)
    petSpawning = true;

    if(activePet ~= null) then
        activePet:Destroy();
        activePet = nil;
    end

    if(pet == nil or petData == nil) then 
        petSpawning = false;    
        return 
    end

    print("Player is now using " .. petData.ItemData.Name);

    SetupPet(pet, petData);
end

function PetManager.GetActivePet()
    return activePet;
end

function PetManager.IsPetActive()
    return activePet ~= nil;
end


cancelCombatButton.MouseButton1Click:Connect(StopCombat);

petEvolved.OnClientEvent:Connect(function(next)
    replicatedStorage.LevelUp:Play();

    StopCombat();
    
    evolutionGui.Setup(activePetData, next);
    
    PetManager.SetTarget(nil);
    PetManager.SetActivePet(nil, nil);
end);

game:GetService("RunService").RenderStepped:Connect(UpdatePet);

return PetManager;