local ActivePetService = {};

-- Imports
local replicatedStorage = game:GetService("ReplicatedStorage");
local insertService = game:GetService("InsertService");
local physicsService = game:GetService("PhysicsService");
local collectionService = game:GetService("CollectionService");
local serverScriptService = game:GetService("ServerScriptService");
local itemService = require(serverScriptService.Server.Services.ItemService);
local petService = require(serverScriptService.Server.Services.PetService);
local creatureService = require(serverScriptService.Server.Services.CreatureService);
local playerEquipped = replicatedStorage.Common.Events.PlayerEquippedItem;
local targetKilled = replicatedStorage.Common.Events.TargetKilled;

-- Variables
local activePets = {};

local attackables = {};
attackables[1] = {
	ExperienceAward = 1
}

-- Functions

local function UpdateXpBar(itemData)
    if(activePetData == nil) then return end

    local width = itemData.Data.CurrentExperience / activePetData.ItemData.ExperienceToLevel;
    
    if(width > 1) then
        width = 1;
    end

    board.C.ImageLabel.Experience.Size = UDim2.new(width, 0, 1, 0);
end

local function ShowXpAbove(model, itemData)
    local npcAboveHeadGUI = replicatedStorage.PetGUI;
    board = npcAboveHeadGUI:Clone()
    board.Parent = workspace;
    board.Adornee = model.Root;

	local offset = itemData.ItemData.GuiOffset;

	if(offset ~= nil) then
		board.StudsOffset = offset;
	end
	
    
    local currentExperience = itemData.PlayerItem.Data.CurrentExperience;
    local toLevel = itemData.ItemData.ExperienceToLevel;

    board.A.Text = itemData.ItemData.Name;

    local width = currentExperience / toLevel;
    board.C.ImageLabel.Experience.Size = UDim2.new(width,0, 1,0);

    itemData.PlayerItem.Data.CurrentExperience = itemData.PlayerItem.Data.CurrentExperience + 0.1;
end

function ActivePetService.AddActivePet(player, item)
    
	if(activePets[player.UserId] ~= nil) then
		local playersCurrentPet = activePets[player.UserId];
		playersCurrentPet.PetModel:Destroy();
	end

	local model = insertService:LoadAsset(item.ItemData.ModelId);
	
    local toSend = model:FindFirstChildWhichIsA("Model")

	toSend.PrimaryPart = toSend.Root;
	toSend.Parent = workspace;
	toSend.PrimaryPart:SetNetworkOwner(player);

	model:Destroy();

	physicsService:SetPartCollisionGroup(toSend.PrimaryPart, "Pets")
	
	activePets[player.UserId] = {
		PetModel = toSend,
		PetData = item,
		Target = nil
	};

	ShowXpAbove(toSend, item);

	playerEquipped:FireClient(player, toSend, item);
end

function ActivePetService.StopAttacking(player, petData)
	if(player == nil) then
		return
	end

    local playersActivePet = ActivePetService.GetActivePet(player);
    local pet = playersActivePet;
    local target = nil;

    if(playersActivePet ~= nil) then
	    target = playersActivePet.Target;
    end

	if(target == nil) then
		return
	end
	
	if(pet == nil) then
		return
	end

	local targetIsCreature = collectionService:HasTag(target.Parent, "Creature");
	local creature = creatureService.GetCreatureByGameObject(target.Parent);

	if(creature ~= nil) then
		creature.UnderAttack = false;
		creature.Target = nil;

		if(creature.EndAttackCallback ~= nil) then
			creature.EndAttackCallback();
		end
	end
end

function ActivePetService.GetActivePet(player)
    return activePets[player.UserId];
end

function ActivePetService.RemovePlayerPet(player)
    local playersPet = ActivePetService.GetActivePet(player);

    if(playersPet == nil) then
        return;
    end

    playersPet.PetModel:Destroy();
    activePets[player.UserId] = nil;
end

function ActivePetService.PetAttack(player, pet, petData, target)
    local playersPet = ActivePetService.GetActivePet(player);

    -- The player apparently doesn't have a pet out, therefore, hacking :(
    if(playersPet == nil) then
        return;
    end

	local playersActiveTarget = playersPet.Target;

    -- The players target isn't known, must be hacker :(
	if(playersActiveTarget == nil) then
		return;
	end

    -- The players target is not the same as the one we know about, so, they hacking :(
	if(playersActiveTarget ~= target) then
		return;
	end

    target = playersActiveTarget;
	
	local creature = creatureService.GetCreatureByGameObject(playersActiveTarget.Parent);

	local targetData = attackables[target:GetAttribute("Id")];
	if(targetData ~= nil) then 
		petService.AddExperience(player, petData.PlayerItem.Id, targetData.ExperienceAward);
	end

	if(creature == nil) then 
		local animator = target.Parent:WaitForChild("Humanoid");
		if animator then
			targetHitAnimation = animator:LoadAnimation(target.Parent.Animations.Hit);
			targetHitAnimation:Play();
		end

		return;
	end

	if(creature.Alive == false) then
		return;
	end

	creature.UnderAttack = true;
	creature.Target = playersPet.PetModel;

	-- Do damage
	creature.CurrentHealth = creature.CurrentHealth - 1;
    
    local width = creature.CurrentHealth / creature.MaxHealth;
    creature.HealthPanel.ImageLabel.Health.Size = UDim2.new(width,0, 1,0);

	if(creature.CurrentHealth < 0) then
		local animator = target.Parent:WaitForChild("Humanoid");
		
		targetHitAnimation = animator:LoadAnimation(target.Parent.Animations.Death);
		targetHitAnimation:Play();
		targetHitAnimation.Stopped:Wait();
		
		creature.GameObject:Destroy();
		creature.GameObject = nil;

		creature.Alive = false;
		creature.UnderAttack = false;
		creature.Target = nil;

		petService.AddExperience(player, petData.PlayerItem.Id, creature.Data.BaseExperienceAward);

		local ran = math.random(0, 100);

		local drops = creature.Data.Drops;
		local expectedDrop = nil;

		for _, drop in pairs(drops) do
			if(ran > drop.Chance) then
				continue;
			end

			expectedDrop = drop;
		end

		if(expectedDrop ~= nil) then
			itemService.GiveItem(player, expectedDrop.ItemId);
		end

		targetKilled:FireClient(player);
	end
end

function ActivePetService.PetAnimation(player, animation)
	local playerPet = ActivePetService.GetActivePet(player);

	if(playerPet == nil) then 
        return;
    end

	playerPet = playerPet.PetModel;
	
	if(animation == nil) then
		local humanoid = playerPet:WaitForChild("Humanoid", 1000);
		for _, a in pairs(humanoid:GetPlayingAnimationTracks()) do
			a:Stop();
		end
		return;
	end

	local animator = playerPet:WaitForChild("Humanoid", 1000);
	if animator then
		track = animator:LoadAnimation(animation)
		track:Play()
	end
end

function ActivePetService.RequestPetAttack(player, target)
	local playersPet = ActivePetService.GetActivePet(player);

    if(playersPet == nil) then 
		return false;
	end

	local petData = petService.GetPetByGuid(player, playersPet.Id);

	for _, obj in pairs(activePets) do
		if(obj.Target == target) then
			return false;
		end
	end

	local attackableId = target:GetAttribute("Id");

	local targetIsCreature = collectionService:HasTag(target.Parent, "Creature");

	if(playersPet.PetData.ItemData.ItemType == "Seed") then
		if(targetIsCreature) then
			return false;
		end
	elseif(playersPet.PetData.ItemData.ItemType == "Pet") then
		if(not targetIsCreature) then
			return false;
		end
	end

	if((player.Character:GetPrimaryPartCFrame().p - target.CFrame.p).magnitude > 40) then
		return false;
	end

	playersPet.Target = target;

	return true;
end

return ActivePetService;