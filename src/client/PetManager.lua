local PetManager = {};

-- Imports
local players = game:GetService("Players");
local pathfindingService = game:GetService("PathfindingService");

-- Variables
local activePet = nil;
local activePetData = nil;
local activeTarget = nil;
local runner = nil;
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
    runner = game:GetService("RunService").RenderStepped:Connect(UpdatePet);
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

return PetManager;