-- Imports
local replicatedStorage = game:GetService("ReplicatedStorage");
local players = game:GetService("Players");
local playerEquippedItem = replicatedStorage.Common.Events.PlayerEquippedItem;
local pathfindingService = game:GetService("PathfindingService");

-- Variables
local waypoints = nil;

-- Functions

local function OnEquipped(model)
    local playerCharacter = players.LocalPlayer.Character;

    local characterCframe = playerCharacter:GetPrimaryPartCFrame()        

    model:SetPrimaryPartCFrame(characterCframe);

    game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
        local petCframe =  model:GetPrimaryPartCFrame().p;
        characterCframe = playerCharacter:GetPrimaryPartCFrame().p;
        
        if((petCframe - characterCframe).magnitude > 30) then
            model:SetPrimaryPartCFrame(playerCharacter:GetPrimaryPartCFrame())
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
    end);
end

playerEquippedItem.OnClientEvent:Connect(OnEquipped);