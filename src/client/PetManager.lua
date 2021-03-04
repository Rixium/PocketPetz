local PetManager = {};

-- Imports
local players = game:GetService("Players");
local pathfindingService = game:GetService("PathfindingService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local petAttackingEvent = replicatedStorage.Common.Events.PetAttackingEvent;
local petGotExperience = replicatedStorage.Common.Events.PetGotExperience;
local petStopAttackingEvent = replicatedStorage.Common.Events.PetStopAttackingEvent;
local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local stopCombatButton = uiManager.GetUi("Main GUI"):WaitForChild("StopCombatButton");

-- Variables
local board = nil;
local activePet = nil;
local activePetData = nil;
local activeTarget = nil;
local runner = nil;
local toldServer = false;
local waypoints = {};

-- Functions
local function MoveTo(targetCFrame) 
    local model = activePet;

    local petCframe =  model:GetPrimaryPartCFrame().p;

    if((targetCFrame.p - petCframe).magnitude > 10 and (waypoints == nil or #waypoints == 0)) then
        local path = pathfindingService:FindPathAsync(petCframe, targetCFrame.p);
        waypoints = path:GetWaypoints()
    elseif currentWaypoint ~= nil then
        targetCframe = targetCFrame:ToWorldSpace(CFrame.new(3,1,0))
        local newCframe = model:GetPrimaryPartCFrame():Lerp(targetCframe, 0.02)
        model:SetPrimaryPartCFrame(newCframe)

        if((newCframe.p - targetCframe.p).magnitude < 5) then
            currentWaypoint = nil;
        end
    elseif waypoints ~= nil and #waypoints ~= 0 then
        currentWaypoint = waypoints[1];
        table.remove(waypoints, 1);
    end
end

local function AttackTarget()
    if(activeTarget == nil) then return end
    if(activePet == nil) then return end
    if(waypoints ~= nil and #waypoints > 0) then return end
    if(toldServer) then return end

    toldServer = true;
    stopCombatButton.Visible = true;
    petAttackingEvent:FireServer(activePet, activePetData, activeTarget);
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

    MoveTo(activeTarget.CFrame);
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
        MoveTo(players.LocalPlayer.Character:GetPrimaryPartCFrame());
    end
end

local function SetupPet(pet, petData)
    ShowXpAbove(pet, petData);

    runner = game:GetService("RunService").RenderStepped:Connect(UpdatePet);
    petGotExperience.OnClientEvent:Connect(function(pet) 
        UpdateXpBar(pet);
    end);
end

function PetManager.SetTarget(target)
    activeTarget = target;
end

function PetManager.SetActivePet(pet, petData)
    activePet = pet;
    activePetData = petData;

    print("Player is now using " .. petData.ItemData.Name);
    SetupPet(pet, petData);
end

function PetManager.GetActivePet()
    return activePet;
end

function PetManager.IsPetActive()
    return activePet ~= nil;
end

local function StopCombat()
    if(activePet == nil) then return end
    if(activeTarget == nil) then return end
    stopCombatButton.Visible = false;
    petStopAttackingEvent:FireServer(activePet, activePetData, activeTarget);
    activeTarget = nil;
    toldServer = false;
end

stopCombatButton.MouseButton1Click:Connect(StopCombat);

return PetManager;