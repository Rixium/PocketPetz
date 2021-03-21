local serverScriptService = game:GetService("ServerScriptService");
local playerTracker = require(serverScriptService.Server.PlayerTracker);
local moneyManager = require(serverScriptService.Server.Statistics.MoneyManager);
local titleService = require(serverScriptService.Server.Services.TitleService);
local itemService = require(serverScriptService.Server.Services.ItemService);
local itemList = require(serverScriptService.Server.Data.ItemList);
local petService = require(serverScriptService.Server.Services.PetService);
local playerService = require(serverScriptService.Server.Services.PlayerService);
local activePetService = require(serverScriptService.Server.Services.ActivePetService);
local activePetService = require(serverScriptService.Server.Services.ActivePetService);
local physicsService = game:GetService("PhysicsService");
local players = game:GetService("Players");
local collectionService  = game:GetService("CollectionService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local worldService = require(serverScriptService.Server.Services.WorldService);
local moneyManager = require(serverScriptService.Server.Statistics.MoneyManager);
local dropService = require(serverScriptService.Server.Services.DropService);
local DataStoreService = game:GetService("DataStoreService");
local logoutPositions = DataStoreService:GetDataStore("LogoutPositions");

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
	
	playerService.CreatePlayerInfo(player);
	itemService.ClearItems(player);
	itemService.GiveItem(player,1);

	player.CharacterRemoving:Connect(function(c)
		local logoutPosition= c.PrimaryPart.CFrame.p;
		logoutPositions:SetAsync(player.UserId, {
			X = logoutPosition.X,
			Y = logoutPosition.Y,
			Z = logoutPosition.Z
		});
	end);

	local lastPosition = logoutPositions:GetAsync(player.UserId);
	if(lastPosition ~= nil and lastPosition.X ~= nil) then
		local newPosition = Vector3.new(lastPosition.X, lastPosition.Y, lastPosition.Z);
		local char = player.Character or player.CharacterAdded:wait();
		char.HumanoidRootPart.CFrame = CFrame.new(newPosition);
	end
end

function OnPlayerLeaving(player)
	playerTracker.Logout(player);
	playerTracker.RemovePlayer(player);
	
	activePetService.StopAttacking(player);
	activePetService.RemovePlayerPet(player);
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
petAttackingEvent.OnServerInvoke = activePetService.PetAttack;

local setPetAnimation = replicatedStorage.Common.Events.SetPetAnimation;
setPetAnimation.OnServerEvent:Connect(activePetService.PetAnimation);

local petStopAttackingEvent = replicatedStorage.Common.Events.PetStopAttackingEvent;
petStopAttackingEvent.OnServerEvent:Connect(activePetService.StopAttacking);

local isPlayerLegend = replicatedStorage.Common.Events.IsPlayerLifetimeLegend;
isPlayerLegend.OnServerInvoke = playerService.IsPlayerLifetimeLegend;

local equipItemRequest = replicatedStorage.Common.Events.EquipItemRequest;
equipItemRequest.OnServerInvoke = function(player, item)
	local playerItem = itemService.GetPlayerItemByGuid(player, item.PlayerItem.Id);

	if(playerItem == nil) then
		return {
			Success = false,
			Message = "You don't own that item!";
		};
	end

	local playerCarrying = petService.GetPetsInBag(player);

	local itemData = itemList.GetById(playerItem.ItemId);
	local isLifetimeLegend = playerService.IsPlayerLifetimeLegend(player);
	local maxPetsAllowed = 3;

	if(isLifetimeLegend) then
		maxPetsAllowed = 5;
	end

	if(itemData.ItemType == "Seed" and #playerCarrying == maxPetsAllowed) then
		return {
			Success = false,
			Message = "You cannot train a seed when you're carrying 3 pets!"
		};
	end

	if(itemData.ItemType == "Pet" or itemData.ItemType == "Seed") then
		local health = playerItem.Data.CurrentHealth or 1;
		if(health > 0) then
			activePetService.AddActivePet(player, {
				PlayerItem = playerItem,
				ItemData = itemData
			});
		end
	end

	return {
		Success = true
	};
	
end;

local petRequestAttack = replicatedStorage.Common.Events.PetRequestAttack;
petRequestAttack.OnServerInvoke = activePetService.RequestPetAttack;

local healPet = replicatedStorage.Common.Events.HealPet;
healPet.OnServerEvent:Connect(function(player, petId)
	local didPay = moneyManager.RemoveMoney(player, 10);

	if(not didPay) then
		return;
	end

	activePetService.PetHealed(player, petId);
end);

local itemPickedUp = replicatedStorage.Common.Events.ItemPickedUp;
itemPickedUp.OnServerInvoke = function(player, itemId)
	local pickedUp = worldService.PickUp(player, itemId);

	if(not pickedUp) then
		return false;
	end

	dropService.GetDrop(player, itemId);

	return true;
end