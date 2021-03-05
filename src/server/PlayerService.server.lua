local serverScriptService = game:GetService("ServerScriptService");
local playerTracker = require(serverScriptService.Server.PlayerTracker);
local moneyManager = require(serverScriptService.Server.Statistics.MoneyManager);
local titleService = require(serverScriptService.Server.Services.TitleService);
local itemService = require(serverScriptService.Server.Services.ItemService);
local petService = require(serverScriptService.Server.Services.PetService);
local physicsService = game:GetService("PhysicsService");

local currentEventTitle = "AlphaStar";

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
	
	-- DATABASE CLEARUP
	-- itemService.ClearItems(player);
	-- petService.AddExperience(player, "123", 10);
end

function OnPlayerLeaving(player)
	playerTracker.Logout(player);
	playerTracker.RemovePlayer(player);
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

local petAttackingEvent = replicatedStorage.Common.Events.PetAttackingEvent;
local runService = game:GetService("RunService");
local attackingPets = {};
local activePets = {};

petAttackingEvent.OnServerEvent:Connect(function(player, pet, petData, target)
	attackingPets[player.UserId] = {
		Player = player,
		PetModel = pet,
		PetData = petData,
		Target = target
	};
end);

local setPetAnimation = replicatedStorage.Common.Events.SetPetAnimation;
setPetAnimation.OnServerEvent:Connect(function(player, animation)
	local playerPet = activePets[player.UserId];
	if(playerPet == nil) then return end
	
	if(animation == nil) then
		local humanoid = playerPet:WaitForChild("Humanoid");
		for _, a in pairs(humanoid:GetPlayingAnimationTracks()) do
			a:Stop();
		end
		return;
	end

	local animator = playerPet:WaitForChild("Humanoid"):WaitForChild("Animator")
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

	for _, child in pairs(toSend:GetChildren()) do
		if child:IsA("BasePart") then
			child:SetNetworkOwner(player);
		end
	end
	

	model:Destroy();

	local animator = Instance.new("Animator");
	animator.Parent = toSend:WaitForChild("Humanoid");

	physicsService:SetPartCollisionGroup(toSend.PrimaryPart, "Pets")
	
	activePets[player.UserId] = toSend;

	playerEquipped:FireClient(player, toSend, item);
end);

spawn(function()
	while true do
		wait(1)
		
		for _, pet in pairs(attackingPets) do
			petService.AddExperience(pet.Player, pet.PetData.PlayerItem.Id, 5);
		end
	end
end);