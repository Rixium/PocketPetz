-- Imports
local replicatedStorage = game:GetService("ReplicatedStorage");
local players = game:GetService("Players");
local playerEquippedItem = replicatedStorage.Common.Events.PlayerEquippedItem;
local pathfindingService = game:GetService("PathfindingService");

-- Variables
local waypoints = nil;

-- Functions
local function ShowXpAbove(model, itemData)
    local npcAboveHeadGUI = replicatedStorage.ExperienceGUI;
    local board = npcAboveHeadGUI:Clone()
    board.Parent = workspace;
    board.Adornee = model;
    
    local currentExperience = itemData.PlayerItem.Data.CurrentExperience;
    local toLevel = itemData.ItemData.ExperienceToLevel;

    local width = currentExperience / toLevel;
    board.Experience.Size = UDim2.new(width,0, 1,0);

    game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
        itemData.PlayerItem.Data.CurrentExperience = itemData.PlayerItem.Data.CurrentExperience + 0.1;

        width = itemData.PlayerItem.Data.CurrentExperience / itemData.ItemData.ExperienceToLevel;
        
        if(width > 1) then
            width = 1;
        end

        board.Experience.Size = UDim2.new(width,0, 1,0);
    end);
end

local function OnEquipped(model, itemData)
    local playerCharacter = players.LocalPlayer.Character;

    local startFrame = playerCharacter:GetPrimaryPartCFrame():ToWorldSpace(CFrame.new(3,1,0))
    local characterCframe = playerCharacter:GetPrimaryPartCFrame()        

    model:SetPrimaryPartCFrame(startFrame);

    ShowXpAbove(model, itemData);

    local runner;
    runner = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)

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