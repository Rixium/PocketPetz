local PetManager = {};

-- Imports
local players = game:GetService("Players");
local pathfindingService = game:GetService("PathfindingService");

-- Variables
local activePet = nil;
local activePetData = nil;
local runner = nil;
local waypoints = {};

-- Functions
local function UpdatePet()
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

    local petCframe =  model:GetPrimaryPartCFrame().p;
    local characterCframe = playerCharacter:GetPrimaryPartCFrame().p;
    
    if((petCframe - characterCframe).magnitude > 30) then
        
        model:SetPrimaryPartCFrame( playerCharacter:GetPrimaryPartCFrame():ToWorldSpace(CFrame.new(3,1,0)))
    end

    if((characterCframe - petCframe).magnitude > 10 and (waypoints == nil or #waypoints == 0)) then
        local path = pathfindingService:FindPathAsync(petCframe, characterCframe);
        waypoints = path:GetWaypoints()
    elseif currentWaypoint ~= nil then
        local targetCframe = playerCharacter:GetPrimaryPartCFrame():ToWorldSpace(CFrame.new(3,1,0))
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

local function SetupPet(pet, petData)
    runner = game:GetService("RunService").RenderStepped:Connect(UpdatePet);
end

function PetManager.SetTarget(target)
    print("Pet is now attacking " .. target.Name);
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