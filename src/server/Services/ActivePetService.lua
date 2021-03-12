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
local playerEquipped = replicatedStorage.Common.Events.PlayerEquippedItem;
local targetKilled = replicatedStorage.Common.Events.TargetKilled;
local petFainted = replicatedStorage.Common.Events.PetFainted;

-- Variables
local activePets = {};

local attackables = {};
attackables[1] = {
	ExperienceAward = 1
}

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
		local updatedPetData = petService.AddExperience(player, petData.PlayerItem.Id, targetData.ExperienceAward);
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
	creature.Target = playersPet.PetModel;
	creature.HitTargetCallback = function()
		local petData = playersPet.PetData;
		local playerItemData = petData.PlayerItem.Data;
		local currentHealth = playerItemData.CurrentHealth or petData.ItemData.BaseHealth;
		currentHealth = currentHealth - 1;

		creature.GameObject.Root.HitSound:Play();

		playerItemData.CurrentHealth = currentHealth;
		petService.UpdatePet(player, petData.PlayerItem.Id, petData.PlayerItem.Data);
		UpdateHealthBar(playersPet, petData);

		if(currentHealth <= 0) then
			ActivePetService.StopAttacking(player, petData);
			petFainted:FireClient(player);

			playersPet.PetModel.Root.DeadSound:Play();

			local animator = playersPet.PetModel:WaitForChild("Humanoid");
			local deadAnimation = animator:LoadAnimation(playersPet.PetModel.Animations.Death);
			deadAnimation:Play();
			deadAnimation.Stopped:Wait();
			
			ActivePetService.RemovePlayerPet(player);
		end
	end

	playersPet.PetModel.Root.HitSound:Play();

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

		local updatedPetData = petService.AddExperience(player, petData.PlayerItem.Id, creature.Data.BaseExperienceAward);
		UpdateXpBar(playersPet, updatedPetData or playersPet.PetData);

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

	local petData = petService.GetPetByGuid(player, playersPet.PetData.PlayerItem.Id);

	if(petData == nil) then
		return false;
	end

	for _, obj in pairs(activePets) do
		if(obj.Target == target) then
			return false;
		end
	end

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

return ActivePetService;