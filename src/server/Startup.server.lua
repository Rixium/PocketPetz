
local collectionService = game:GetService("CollectionService");
local serverScriptService = game:GetService("ServerScriptService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local healthGUI = replicatedStorage.HealthGUI;
local creatureService = require(serverScriptService.Server.Services.CreatureService);
local itemList = require(serverScriptService.Server.Data.ItemList);

local creatures = collectionService:GetTagged("Creature");

local function SetupCreature(creature)
    creature.CurrentHealth = creature.Item.BaseHealth;
    creature.MaxHealth = creature.Item.BaseHealth;
    creature.Alive = true;
    creature.NextPosition = nil;
    creature.LastMove = 0;
    creature.UnderAttack = false;
    creature.Target = nil;
    creature.DeathTimer = 15;
    
    local healthPanel = healthGUI:clone();
    healthPanel.NameLabel.Text = creature.Item.Name;
    
    local width = creature.Item.BaseHealth / creature.Item.BaseHealth;
    healthPanel.ImageLabel.Health.Size = UDim2.new(width,0, 1,0);

    healthPanel.Parent = creature.GameObject;
    healthPanel.Adornee = creature.GameObject;

    creature.HealthPanel = healthPanel;
end

for _, creature in pairs(creatures) do
    local id = creature:GetAttribute("Id");
    local creatureData = creatureService.GetCreatureDataById(id);
    local creatureItem = itemList.GetById(creatureData.ItemId);

    local newCreature = {
        GameObject = creature,
        StartPosition = creature.Root.Position,
        Data = creatureData,
        Item = creatureItem
    };
    
    SetupCreature(newCreature);

    creatureService.AddCreature(newCreature);
end


local lastUpdate = 5;
local updating = false;

local radius = 10;

while true do
    wait(1);

    for _, creature in pairs(creatureService.GetAll()) do

        creature.LastMove = creature.LastMove - 1;

        if not creature.Alive then 
            creature.DeathTimer = creature.DeathTimer - 1;

            if(creature.DeathTimer <= 0) then
                creature.DeathTimer = 15;
                SetupCreature(creature);
            end
        end

        local humanoid = creature.GameObject:WaitForChild("Humanoid");

        if creature.UnderAttack then 
            local targetPos = creature.Target:GetPrimaryPartCFrame().p;

            local distance = (targetPos - creature.GameObject.Root.Position).magnitude;

            creature.GameObject.Root.CFrame = CFrame.new(creature.GameObject.Root.Position, targetPos);

            
            if(distance > 10) then
                continue;
            end

            if(creature.EndAttackCallback == nil) then
                local attackAnimation = humanoid:LoadAnimation(creature.GameObject.Animations.Attack);
                attackAnimation:Play();
                
                creature.EndAttackCallback = function()
                    attackAnimation:Stop();
                    creature.EndAttackCallback = nil;
                end
            end
        else
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

                creature.LastMove = math.random(1, 3);

                creature.NextPosition = Vector3.new(x, creature.StartPosition.Y, z);

                local walkAnimation = humanoid:LoadAnimation(creature.GameObject.Animations.Walk);

                humanoid.MoveToFinished:Connect(function ()
                    walkAnimation:Stop();
                end)

                humanoid:MoveTo(creature.NextPosition);

                walkAnimation:Play();
            end
        end
    end
end