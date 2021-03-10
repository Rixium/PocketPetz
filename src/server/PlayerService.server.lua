local serverScriptService = game:GetService("ServerScriptService");
local playerTracker = require(serverScriptService.Server.PlayerTracker);
local moneyManager = require(serverScriptService.Server.Statistics.MoneyManager);
local titleService = require(serverScriptService.Server.Services.TitleService);
local itemService = require(serverScriptService.Server.Services.ItemService);
local petService = require(serverScriptService.Server.Services.PetService);
local playerService = require(serverScriptService.Server.Services.PlayerService);
local physicsService = game:GetService("PhysicsService");
local players = game:GetService("Players");
local collectionService  = game:GetService("CollectionService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local creatureService = require(serverScriptService.Server.Services.CreatureService);

local currentEventTitle = "AlphaStar";

local attackingPets = {};
local activePets = {};
local currentTargets = {};

local attackables = {};
attackables[1] = {
	ExperienceAward = 1
}

function OnPlayerJoined(player)
	playerTracker.Login(player);
	moneyManager.PlayerJoined(player);

	local isFirstTime = playerTracker.FirstTime(player);
	titleService.UnlockTitle(player, "Noob");
	titleService.UnlockTitle(player, currentEventTitle);

	local char = player.Character or player.CharacterAdded:Wait();
	for i,v in pairs(char:GetChildren()) do
		if v:IsA("BasePart") then
			physicsService:SetPartCollisionGroup(v, "Players");
		end
	end
	
	playerService.CreatePlayerInfo(player);
	
	-- DATABASE CLEARUP
	-- itemService.ClearItems(player);
	-- petService.AddExperience(player, "123", 10);
end

function OnPlayerLeaving(player)
	playerTracker.Logout(player);
	playerTracker.RemovePlayer(player);
	
	local playersActivePet = activePets[player.UserId];

	if(playersActivePet ~= nil) then
		playersActivePet.PetModel:Destroy();
	end

	attackingPets[player.UserId] = nil;
end


game.Players.PlayerAdded:Connect(OnPlayerJoined);
game.Players.PlayerRemoving:Connect(OnPlayerLeaving);


local replicatedStorage = game:GetService("ReplicatedStorage");
local getCoinCountRequest = replicatedStorage.Common.Events.GetCoinCountRequest;
getCoinCountRequest.OnServerInvoke = moneyManager.GetMoney;

local getTitlesRequest = replicatedStorage.Common.Events.GetTitlesRequest;
getTitlesRequest.OnServerInvoke = titleService.GetAllTitles;

local getActiveTitleRequest = replicatedStorage.Common.Events.GetActiveTitleRequest;
getActiveTitleRequest.OnServerInvoke = titleService.GetActiveTitle;

local setActiveTitle = replicatedStorage.Common.Events.SetActiveTitle;
setActiveTitle.OnServerInvoke = titleService.SetActiveTitle;

local getItemsRequest = replicatedStorage.Common.Events.GetItemsRequest;
getItemsRequest.OnServerInvoke = itemService.GetPlayerItems;

local getPlayerInfo = replicatedStorage.Common.Events.GetPlayerInfo;
getPlayerInfo.OnServerInvoke = function(player, otherPlayerId)
	local otherPlayer = players:GetPlayerByUserId(otherPlayerId);

	if(otherPlayer == nil) then 
		return nil;
	end

	local playersInfo = playerService.GetPlayerInfo(otherPlayer);	

	return playersInfo;
end

local petAttackingEvent = replicatedStorage.Common.Events:WaitForChild("PetAttackingEvent");
local runService = game:GetService("RunService");

petAttackingEvent.OnServerEvent:Connect(function(player, pet, petData, target)

	local playersActiveTarget = attackingPets[player.UserId];
	if(playersActiveTarget.Target ~= target) then
		return;
	end

    local animator = target.Parent:WaitForChild("Humanoid");
    if animator then
        targetHitAnimation = animator:LoadAnimation(target.Parent.Animations.Hit);
        targetHitAnimation:Play();
    end

end);

local setPetAnimation = replicatedStorage.Common.Events.SetPetAnimation;
setPetAnimation.OnServerEvent:Connect(function(player, animation)
	local playerPet = activePets[player.UserId];
	if(playerPet == nil) then return end

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
end);


local petStopAttackingEvent = replicatedStorage.Common.Events.PetStopAttackingEvent;
petStopAttackingEvent.OnServerEvent:Connect(function(player, pet, petData, target)
	attackingPets[player.UserId] = nil;
end);

local insertService = game:GetService("InsertService");
local equipItemRequest = replicatedStorage.Common.Events.EquipItemRequest;
local playerEquipped = replicatedStorage.Common.Events.PlayerEquippedItem;

local physicsService = game:GetService("PhysicsService");
equipItemRequest.OnServerEvent:Connect(function(player, item)
	local playerItem = itemService.GetPlayerItemByGuid(player, item.PlayerItem.Id);

	if(playerItem == nil) then
		return;
	end

	if(activePets[player.UserId] ~= nil) then
		local playersCurrentPet = activePets[player.UserId];
		playersCurrentPet:Destroy();
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
		PetData = item	
	};

	playerEquipped:FireClient(player, toSend, item);
end);

local petRequestAttack = replicatedStorage.Common.Events.PetRequestAttack;
petRequestAttack.OnServerInvoke = function(player, target)
	local playersPet = activePets[player.UserId]
	local petData = petService.GetPetByGuid(player, playersPet.Id);

	if(playersPet == nil) then 
		return false;
	end

	for _, obj in pairs(attackingPets) do
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

	attackingPets[player.UserId] = {
		Player = player,
		PetModel = playersPet.PetModel,
		PetData = playersPet.PetData,
		Target = target
	};

	if((player.Character:GetPrimaryPartCFrame().p - target.CFrame.p).magnitude > 40) then
		return false;
	end

	currentTargets[player.UserId] = target;

	return true;
end

spawn(function()
	while true do
		wait(1)
		
		for _, pet in pairs(attackingPets) do
			local target = currentTargets[pet.Player.UserId];
			if(target == nil) then continue end
			local targetData = attackables[target:GetAttribute("Id")];
			if(targetData == nil) then continue end
			petService.AddExperience(pet.Player, pet.PetData.PlayerItem.Id, targetData.ExperienceAward);
		end
	end
end);