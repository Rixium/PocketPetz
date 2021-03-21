local ActivePetService = {};

-- Imports
local replicatedStorage = game:GetService("ReplicatedStorage");
local insertService = game:GetService("InsertService");
local physicsService = game:GetService("PhysicsService");
local collectionService = game:GetService("CollectionService");
local serverScriptService = game:GetService("ServerScriptService");
local itemService = require(serverScriptService.Server.Services.ItemService);
local itemList = require(serverScriptService.Server.Data.ItemList);
local petService = require(serverScriptService.Server.Services.PetService);
local creatureService = require(serverScriptService.Server.Services.CreatureService);
local worldService = require(serverScriptService.Server.Services.WorldService);
local playerEquipped = replicatedStorage.Common.Events.PlayerEquippedItem;
local targetKilled = replicatedStorage.Common.Events.TargetKilled;
local petFainted = replicatedStorage.Common.Events.PetFainted;
local petsHealed = replicatedStorage.Common.Events.PetsHealed;
local stopAttacking = replicatedStorage.Common.Events.StopAttacking;

-- Variables
local activePets = {};

local attackables = {};
attackables[1] = {
	ExperienceAward = 1
}

local doubleCoinGamePassId = 15816140;
local doubleExperienceGamePassId = 15821713;


-- Functions

local function UpdateXpBar(pet, petData)
	if(petData == nil) then return end

	local currentExperience = petData.PlayerItem.Data.CurrentExperience or 1;
	local experienceToLevel = petData.ItemData.ExperienceToLevel or 1;

    local width = currentExperience / experienceToLevel;
    
    if(width > 1) then
        width = 1;
	elseif(width < 0) then
		width = 0;
	end

    pet.AboveHeadGUI.C.ImageLabel.Experience.Size = UDim2.new(width, 0, 1, 0);
end

local function UpdateHealthBar(pet, petData)
    if(petData == nil) then return end

	local currentHealth = petData.PlayerItem.Data.CurrentHealth or 1;
	local maxHealth = petData.ItemData.BaseHealth or 1;

    local width = currentHealth / maxHealth;
    
    if(width > 1) then
        width = 1;
	elseif(width < 0) then
		width = 0;
	end

    pet.AboveHeadGUI.B.ImageLabel.Health.Size = UDim2.new(width, 0, 1, 0);
end

local function AddAboveHeadGUI(model, itemData)
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

	return board;
end

function ActivePetService.AddActivePet(player, item)
	if(activePets[player.UserId] ~= nil) then
		local playersCurrentPet = activePets[player.UserId];
		ActivePetService.StopAttacking(player, playersCurrentPet.PetData);
		playersCurrentPet.PetModel:Destroy();
	end

	local model = insertService:LoadAsset(item.ItemData.ModelId);
	
    local toSend = model:FindFirstChildWhichIsA("Model")

	toSend.PrimaryPart = toSend.Root;
	toSend.Parent = workspace;
	toSend.PrimaryPart:SetNetworkOwner(player);

	model:Destroy();

	physicsService:SetPartCollisionGroup(toSend.PrimaryPart, "Pets")
	
	local aboveHeadGUI = AddAboveHeadGUI(toSend, item);

	local playersPet = {
		PetModel = toSend,
		PetData = item,
		Target = nil,
		AboveHeadGUI = aboveHeadGUI
	};

	activePets[player.UserId] = playersPet;

	UpdateHealthBar(playersPet, playersPet.PetData);
	UpdateXpBar(playersPet, playersPet.PetData);
	
	local deadSound = Instance.new("Sound", toSend.Root);
	deadSound.SoundId = "rbxassetid://852561358"
	deadSound.Name = "DeadSound"
	deadSound.Volume = 0.2;
	deadSound.RollOffMinDistance = 0;
	deadSound.RollOffMaxDistance = 50;
	deadSound.RollOffMode = Enum.RollOffMode.LinearSquare;

    local hitSound = Instance.new("Sound", playersPet.PetModel.Root);
    hitSound.SoundId = "rbxassetid://3748780065"
    hitSound.Name = "HitSound"
    hitSound.Volume = 0.2;
    hitSound.RollOffMinDistance = 0;
    hitSound.RollOffMaxDistance = 50;
    hitSound.RollOffMode = Enum.RollOffMode.LinearSquare;

	playerEquipped:FireClient(player, toSend, item);
end

function ActivePetService.PetStored(player, pet)
	local playerActivePet = ActivePetService.GetActivePet(player);
	if(playerActivePet == nil) then return end;

	if(playerActivePet.PetData.PlayerItem.Id == pet.Id) then
		ActivePetService.RemovePlayerPet(player);
	end
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

function ActivePetService.CalculateDamage(level, rarity, c1, c2, divider)
	local basePetDamage = c1.BaseAttack;
	local baseCreatureDefence = c2.BaseAttack;

	-- First check the percentage of the base damage we'll do.
	basePetDamage = basePetDamage / 100 * math.random(level, 100 + level);
	
	local petRarity = rarity;

	-- Then the rarity damage to do.
	local rarityDamage = 0;
	local divisionAmount = 100;

	if(petRarity == "Silver") then
		rarityDamage = basePetDamage / 100 * 10;
	elseif(petRarity == "Gold") then
		rarityDamage = basePetDamage / 100 * 20;
	elseif(petRarity == "Diamond") then
		rarityDamage = basePetDamage / 100 * 30;
	end

	local percentageRoll = math.random(level, 100 + level); -- Offset the percentage with the pets level, so there is an actual benefit to levelling up.

	if(percentageRoll > 90) then
		divisionAmount = 50; -- This is a crit (double damage!)
	end

	local actualRarityDamage = rarityDamage / divisionAmount * percentageRoll;

	local finalDamage = basePetDamage + actualRarityDamage;
	local finalDefence = baseCreatureDefence / 100 * math.random(0, 100 - level); -- Another offset that is dependent on the attackers level

	return { FinalDamage = finalDamage / divider, FinalDefence = finalDefence};
end

function ActivePetService.PetAttack(player, pet, petData, target)
    local playersPet = ActivePetService.GetActivePet(player);

	local damageAmount;
	local defenceAmount;

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
		local expectedExperience = targetData.ExperienceAward;

		if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(player.UserId, doubleExperienceGamePassId) then
			expectedExperience = expectedExperience * 2;
		end

		local updatedPetData = petService.AddExperience(player, petData.PlayerItem.Id, expectedExperience);
		UpdateXpBar(playersPet, updatedPetData or playersPet.PetData);
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

	if(creature.HitTargetCallback == nil or creature.Target ~= playersPet.PetModel) then
		creature.HitTargetCallback = function()
			local petData = playersPet.PetData;
			local playerItemData = petData.PlayerItem.Data;
			local currentHealth = playerItemData.CurrentHealth or petData.ItemData.BaseHealth;
			local resultingDamages = ActivePetService.CalculateDamage(1, "Bronze", creature.Item, petData.ItemData, 3);
			local actualDamage = math.clamp(resultingDamages.FinalDamage - resultingDamages.FinalDefence, 0, resultingDamages.FinalDamage);
			
			currentHealth = currentHealth - actualDamage;
			
			creature.GameObject.Root.HitSound:Play();

			playerItemData.CurrentHealth = currentHealth;
			petService.UpdatePet(player, petData.PlayerItem.Id, petData.PlayerItem.Data);
			UpdateHealthBar(playersPet, petData);

			if(currentHealth <= 0) then
				ActivePetService.StopAttacking(player, petData);
				petFainted:FireClient(player);

				local success = pcall(function()
					if(playersPet.PetModel.Root ~= nil) then
						playersPet.PetModel.Root.DeadSound:Play()
					end
					
					local animator = playersPet.PetModel:WaitForChild("Humanoid", 1000);
	
					if(animator ~= nil) then
						if(playersPet.PetModel.Animations.Death ~= nil) then
							local deadAnimation = animator:LoadAnimation(playersPet.PetModel.Animations.Death);
							deadAnimation:Play();
							deadAnimation.Stopped:Wait();
						end
					end
					ActivePetService.RemovePlayerPet(player);
					return true;
				end);
				
				if not success then
					ActivePetService.RemovePlayerPet(player);
				end
			end
		end
	end

	creature.Target = playersPet.PetModel;

	playersPet.PetModel.Root.HitSound:Play();

	-- Do damage
	local resultingDamages = ActivePetService.CalculateDamage(
		playersPet.PetData.PlayerItem.Data.CurrentLevel, -- Current Level of Pet
		playersPet.PetData.PlayerItem.Data.Rarity,       -- The Pets Rarity
		playersPet.PetData.ItemData,                     -- The Pet's Item (Holds important base stats)
		creature.Item, 1);                                  -- The opponents item (Holds important base stats)

	local actualDamage = math.clamp(resultingDamages.FinalDamage - resultingDamages.FinalDefence, 1, resultingDamages.FinalDamage);

	damageAmount = actualDamage;
	defenceAmount = resultingDamages.FinalDefence;

	creature.CurrentHealth = creature.CurrentHealth - actualDamage;
    
    local width = creature.CurrentHealth / creature.MaxHealth;
    creature.HealthPanel.ImageLabel.Health.Size = UDim2.new(width,0, 1,0);

	if(creature.CurrentHealth < 0 and creature.Alive) then
		creature.Alive = false;
		creature.UnderAttack = false;
		creature.Target = nil;

		ActivePetService.StopAttacking(player, playersPet.PetData);
		stopAttacking:FireClient(player);

		local animator = target.Parent:WaitForChild("Humanoid");
		
		targetHitAnimation = animator:LoadAnimation(target.Parent.Animations.Death);
		targetHitAnimation:Play();
		targetHitAnimation.Stopped:Wait();
		
		local deathPoint = creature.GameObject.Root.CFrame.p + Vector3.new(0, 0.5, 0);
		
		local ran = math.random(0, 100);

		local drops = creature.Data.Drops;
		local expectedDrop = nil;

		for _, drop in pairs(drops) do
			if(ran > drop.Chance) then
				continue;
			end

			expectedDrop = drop;
		end

		if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(player.UserId, doubleCoinGamePassId) then
			worldService.DropItemFor(player, 18, 10, deathPoint);
		else
			worldService.DropItemFor(player, 18, 5, deathPoint);
		end
		
	
		if(expectedDrop ~= nil) then
			worldService.DropItemFor(player, expectedDrop.ItemId, 1, deathPoint);
		end
		
		creature.GameObject:Destroy();
		creature.GameObject = nil;

		local expectedExperience = creature.Data.BaseExperienceAward;
		
		if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(player.UserId, doubleExperienceGamePassId) then
			expectedExperience = expectedExperience * 2;
		end
		
		local updatedPetData = petService.AddExperience(player, petData.PlayerItem.Id, expectedExperience);
		UpdateXpBar(playersPet, updatedPetData or playersPet.PetData);

		targetKilled:FireClient(player);
	end

	return {
		Damage = damageAmount,
		Defended = defenceAmount
	};

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

	local petData = petService.GetPetByGuid(player, playersPet.PetData.PlayerItem.Id);

	if(petData == nil) then
		return false;
	end

	for _, obj in pairs(activePets) do
		if(obj.Target == target) then
			return false;
		end
	end

	ActivePetService.StopAttacking(player, playersPet.PetData);

	local currentHealth = petData.Data.CurrentHealth or 1;
	if(currentHealth <= 0) then
		return false;
	end

	local itemData = itemList.GetById(petData.ItemId);

	local attackableId = target:GetAttribute("Id");

	local targetIsCreature = collectionService:HasTag(target.Parent, "Creature");

	if(itemData.ItemType == "Seed") then
		if(targetIsCreature) then
			return false;
		end
	elseif(itemData.ItemType == "Pet") then
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

function ActivePetService.PetHealed(player, petId) 
	petService.HealPet(player, petId);

	local playersActivePet = ActivePetService.GetActivePet(player);
	if(playersActivePet == nil) then
		return;
	end
	
	if(playersActivePet.PetData.PlayerItem.Id ~= petId) then
		return;
	end

	playersActivePet.PetData.PlayerItem.Data.CurrentHealth = playersActivePet.PetData.ItemData.BaseHealth;

	UpdateHealthBar(playersActivePet, playersActivePet.PetData);
end

return ActivePetService;