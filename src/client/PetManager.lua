local PetManager = {};

-- Imports
local players = game:GetService("Players");
local pathfindingService = game:GetService("PathfindingService");
local keyframeSequenceProvider = game:GetService("KeyframeSequenceProvider");
local replicatedStorage = game:GetService("ReplicatedStorage");
local petAttackingEvent = replicatedStorage.Common.Events.PetAttackingEvent;
local petGotExperience = replicatedStorage.Common.Events.PetGotExperience;
local petStopAttackingEvent = replicatedStorage.Common.Events.PetStopAttackingEvent;
local setPetAnimation = replicatedStorage.Common.Events.SetPetAnimation;
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
local waypoints = {};
local animationPlaying = false;
local track = nil;
local attackTrack = nil;
local targetHitAnimation = nil;

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

local function MoveTo(targetCFrame, shouldTeleport)
    local distance = (targetCFrame.p - activePet:GetPrimaryPartCFrame().p).magnitude;

    if(shouldTeleport) then
        if(distance > 30) then
            activePet:SetPrimaryPartCFrame(targetCFrame:ToWorldSpace(CFrame.new(3,1,3)));
        end
    end

    local model = activePet;
    local petCframe = activePet:GetPrimaryPartCFrame().p;

    if(distance > 5) then
        local targetCframe = targetCFrame:ToWorldSpace(CFrame.new(3,0,3))
        
        local dir = CFrame.new(model:GetPrimaryPartCFrame().Position, targetCframe.Position).lookVector;
	    local newCframe = model:GetPrimaryPartCFrame() + (dir * 0.25);
        model:SetPrimaryPartCFrame(newCframe)

        if not animationPlaying then
            animationPlaying = true;

            local animator = activePet:WaitForChild("Humanoid"):WaitForChild("Animator")
            if animator then
                track = animator:LoadAnimation(activePet.Animations.Walk)
                track:Play()
		    end

            setPetAnimation:FireServer(activePet.Animations.Walk);
        end
    elseif (track ~= nil and animationPlaying) then
        animationPlaying = false;
        track:Stop();
        setPetAnimation:FireServer(nil);
    end
end

local function AttackTarget()
    if(activeTarget == nil) then return end
    if(activePet == nil) then return end
    if(waypoints ~= nil and #waypoints > 0) then return end
    if(toldServer) then return end

    toldServer = true;
    Grow();
    petAttackingEvent:FireServer(activePet, activePetData, activeTarget);

    local animator = activeTarget.Parent:WaitForChild("Humanoid"):WaitForChild("Animator");
    if animator then
        targetHitAnimation = animator:LoadAnimation(activeTarget.Parent.Animations.Hit);
    end

    local petAnimator = activePet:WaitForChild("Humanoid"):WaitForChild("Animator")
    if petAnimator then
        local animation = Instance.new("Animation");
        animation.AnimationId = "rbxassetid://" .. 6479792403;
        attackTrack = petAnimator:LoadAnimation(animation);
        attackTrack.Looped = true;
        setPetAnimation:FireServer(animation);
        attackTrack.KeyframeReached:Connect(function(keyframeName)
            if(keyframeName == "Hit") then
                targetHitAnimation:Play();
                sound:Play();
            end
        end);
        attackTrack:Play();
    end
end

local function UpdateXpBar(itemData)
    local width = itemData.Data.CurrentExperience / activePetData.ItemData.ExperienceToLevel;
    
    if(width > 1) then
        width = 1;
    end

    board.Experience.Size = UDim2.new(width,0, 1,0);
end

local function ShowXpAbove(model, itemData)
    local npcAboveHeadGUI = replicatedStorage.ExperienceGUI;
    board = npcAboveHeadGUI:Clone()
    board.Parent = workspace;
    board.Adornee = model;
    
    local currentExperience = itemData.PlayerItem.Data.CurrentExperience;
    local toLevel = itemData.ItemData.ExperienceToLevel;

    local width = currentExperience / toLevel;
    board.Experience.Size = UDim2.new(width,0, 1,0);

    itemData.PlayerItem.Data.CurrentExperience = itemData.PlayerItem.Data.CurrentExperience + 0.1;
    UpdateXpBar(itemData.PlayerItem);
end

local function DoCombat()
    if(activeTarget == nil) then return end
    if(activePet == nil) then return end

    MoveTo(activeTarget.CFrame:ToWorldSpace(CFrame.new(0.3, 0.3, 0.3)));
    AttackTarget();
end

local function CheckForCleanup()
    if(activePet == nil) then return end

    local model = activePet;
    local playerCharacter = players.LocalPlayer.Character;

    if not model.PrimaryPart then
        runner:Disconnect();
        model:Destroy();
        return;
    end

    if not playerCharacter.PrimaryPart then
        runner:Disconnect();
        model:Destroy();
        return;
    end
end

local function UpdatePet()
    CheckForCleanup();

    if(activeTarget ~= nil) then
        DoCombat();
    else
        MoveTo(players.LocalPlayer.Character:WaitForChild("RightFoot").CFrame, true);
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

    ShowXpAbove(pet, petData);

    runner = game:GetService("RunService").RenderStepped:Connect(UpdatePet);

    petGotExperience.OnClientEvent:Connect(function(pet) 
        UpdateXpBar(pet);
    end);
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

    nextTarget = target;
    
    StopCombat();

    activeTarget = target;
    nextTarget = nil;
end

function PetManager.SetActivePet(pet, petData)
    if(runner ~= null) then
        activePet:Destroy();
        runner:Disconnect();
    end

    activePet = pet;
    activePetData = petData;

    
	physicsService:SetPartCollisionGroup(activePet.PrimaryPart, "Pets")
    activePet:SetPrimaryPartCFrame(players.LocalPlayer.Character:GetPrimaryPartCFrame():ToWorldSpace(CFrame.new(3,1,3)));

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

return PetManager;