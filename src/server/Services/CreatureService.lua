local CreatureService = {};

-- Imports

local serverScriptService = game:GetService("ServerScriptService");
local physicsService = game:GetService("PhysicsService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local collectionService = game:GetService("CollectionService");
local itemList = require(serverScriptService.Server.Data.ItemList);
local healthGUI = replicatedStorage.HealthGUI;

-- Variables
CreatureService.CreatureData = {
    [1] = {
        ItemId = 13,
        Drops = {
            [14] = {
                ItemId = 14,
                Chance = 5
            },
            [15] = {
                ItemId = 15,
                Chance = 1
            }
        },
        BaseExperienceAward = 20
    },
    [2] = {
        ItemId = 16,
        Drops = {
            [17] = {
                ItemId = 17,
                Chance = 5
            },
            [15] = {
                ItemId = 15,
                Chance = 1
            }
        },
        BaseExperienceAward = 20
    }
}

local creatures = {};

local lastUpdate = 5;
local updating = false;
local radius = 10;

-- Functions

function CreatureService.AddCreature(creature)
    table.insert(creatures, creature);
end

function CreatureService.GetCreatureDataById(creatureId) 
    return CreatureService.CreatureData[creatureId];
end

function CreatureService.GetAll()
    return creatures;
end

function CreatureService.GetCreatureByGameObject(gameObject)
    for _, creature in pairs(creatures) do
        if(creature.GameObject == gameObject) then
            return creature;
        end
    end

    return nil;
end

function CreatureService.SetupCreature(creature) 
    creature.CurrentHealth = creature.Item.BaseHealth;
    creature.MaxHealth = creature.Item.BaseHealth;
    creature.Alive = true;
    creature.NextPosition = nil;
    creature.LastMove = 0;
    creature.UnderAttack = false;
    creature.Target = nil;
    creature.DeathTimer = 15;
    creature.HitTargetCallback = nil;

    if(creature.GameObject == nil) then
        creature.GameObject = creature.GameObjectTemplate:clone();
        creature.GameObject.Parent = workspace;
    end
    
	physicsService:SetPartCollisionGroup(creature.GameObject.Root, "Pets");

    local sound = Instance.new("Sound", creature.GameObject.Root);
    sound.SoundId = "rbxassetid://2331617000"
    sound.Name = "HitSound"
    sound.Volume = 0.2;
    sound.RollOffMinDistance = 0;
    sound.RollOffMaxDistance = 50;
    sound.RollOffMode = Enum.RollOffMode.LinearSquare;
    
    local healthPanel = healthGUI:clone();
    healthPanel.NameLabel.Text = creature.Item.Name;
    
    local width = creature.Item.BaseHealth / creature.Item.BaseHealth;
    healthPanel.ImageLabel.Health.Size = UDim2.new(width,0, 1,0);

    healthPanel.Parent = creature.GameObject;
    healthPanel.Adornee = creature.GameObject;

    creature.HealthPanel = healthPanel;
end

function CreatureService.Setup() 
    local creatures = collectionService:GetTagged("Creature");
    for _, creature in pairs(creatures) do
        local id = creature:GetAttribute("Id");
        local creatureData = CreatureService.GetCreatureDataById(id);
        local creatureItem = itemList.GetById(creatureData.ItemId);
    
        local newCreature = {
            GameObjectTemplate = creature:clone(),
            StartPosition = creature.Root.Position,
            Data = creatureData,
            Item = creatureItem
        };
        
        CreatureService.SetupCreature(newCreature);
    
        creature:Destroy();
        
        CreatureService.AddCreature(newCreature);
    end
end

function CreatureService.HandleDeath(creature)
    if creature.Alive then return end

    creature.DeathTimer = creature.DeathTimer - 1;

    if(creature.DeathTimer <= 0) then
        CreatureService.SetupCreature(creature);
    end
end

function CreatureService.HandleAttack(creature)
    if not creature.Alive then return end
    if not creature.UnderAttack then return end

    local humanoid = creature.GameObject:WaitForChild("Humanoid");
    local targetPos = creature.Target:GetPrimaryPartCFrame().p;
    local distance = (targetPos - creature.GameObject.Root.Position).magnitude;

    creature.GameObject.Root.CFrame = CFrame.new(creature.GameObject.Root.Position, targetPos);

    if(distance > 10) then return end

    if(creature.EndAttackCallback == nil) then
        local attackAnimation = humanoid:LoadAnimation(creature.GameObject.Animations.Attack);
        attackAnimation:Play();
        
        creature.EndAttackCallback = function()
            attackAnimation:Stop();
            creature.EndAttackCallback = nil;
        end

        attackAnimation.KeyframeReached:Connect(function(keyframeName)
            if(keyframeName == "Hit") then
                if(creature.HitTargetCallback ~= nil) then
                    creature.HitTargetCallback();
                end
            end
        end);
    end
end

function CreatureService.HandleMovement(creature)
    if not creature.Alive then return end
    if creature.UnderAttack then return end

    creature.LastMove = creature.LastMove - 1;

    if(creature.LastMove > 0) then return end

    local humanoid = creature.GameObject:WaitForChild("Humanoid");

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

    creature.LastMove = math.random(1, 3);

    creature.NextPosition = Vector3.new(x, creature.StartPosition.Y, z);

    local walkAnimation = humanoid:LoadAnimation(creature.GameObject.Animations.Walk);

    humanoid.MoveToFinished:Connect(function ()
        walkAnimation:Stop();
    end)

    humanoid:MoveTo(creature.NextPosition);

    walkAnimation:Play();
end

function CreatureService.Run() 
    while true do
        wait(1);

        for _, creature in pairs(CreatureService.GetAll()) do
            CreatureService.HandleDeath(creature);
            CreatureService.HandleAttack(creature);
            CreatureService.HandleMovement(creature);
        end
    end
end

return CreatureService;