
local collectionService = game:GetService("CollectionService");
local serverScriptService = game:GetService("ServerScriptService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local creatureService = require(serverScriptService.Server.Services.CreatureService);
local itemList = require(serverScriptService.Server.Data.ItemList);
local creatureMovePosition = replicatedStorage.Common.Events.CreatureMovePosition;

local creatures = collectionService:GetTagged("Creature");

for _, creature in pairs(creatures) do
    local id = creature:GetAttribute("Id");
    local creatureItem = creatureService.GetCreatureDataById(id);

    creatureService.AddCreature({
        GameObject = creature,
        StartPosition = creature.Root.Position,
        Data = creatureItem,
        Alive = true,
        NextPosition = nil,
        LastMove = 0;
    });
end

local lastUpdate = 5;
local updating = false;

local radius = 10;

while true do
    wait(1);

    for _, creature in pairs(creatureService.GetAll()) do

        creature.LastMove = creature.LastMove - 1;

        if not creature.Alive then continue end

        if(creature.LastMove <= 0) then
            local startX = creature.StartPosition.X;
            local startZ = creature.StartPosition.Z;

            local xChange = math.random(2, radius);
            local zChange = math.random(2, radius);
            local belowX = math.random(1, 2);
            local belowZ = math.random(1, 2);

            if(belowX == 1) then
                xChange = creature.StartPosition.X - xChange;
            else
                xChange = creature.StartPosition.X + xChange;
            end

            if(belowZ == 1) then
                zChange = creature.StartPosition.Z - zChange;
            else
                zChange = creature.StartPosition.Z + zChange;
            end

            local x = xChange;
            local z = zChange;

            print(x);
            print(y);

            creature.LastMove = math.random(1, 3);

            creature.NextPosition = Vector3.new(x, creature.StartPosition.Y, z);
            -- creatureMovePosition:FireAllClients(creature.GameObject, creature.NextPosition);

            local humanoid = creature.GameObject:WaitForChild("Humanoid");

            local walkAnimation = humanoid:LoadAnimation(creature.GameObject.Animations.Walk);
            
            humanoid.MoveToFinished:Connect(function ()
                walkAnimation:Stop();
            end)
            
            humanoid:MoveTo(creature.NextPosition);
            walkAnimation:Play();
        end
    end
end