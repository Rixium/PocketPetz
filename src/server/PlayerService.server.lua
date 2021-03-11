local serverScriptService = game:GetService("ServerScriptService");
local playerTracker = require(serverScriptService.Server.PlayerTracker);
local moneyManager = require(serverScriptService.Server.Statistics.MoneyManager);
local titleService = require(serverScriptService.Server.Services.TitleService);
local itemService = require(serverScriptService.Server.Services.ItemService);
local petService = require(serverScriptService.Server.Services.PetService);
local playerService = require(serverScriptService.Server.Services.PlayerService);
local activePetService = require(serverScriptService.Server.Services.ActivePetService);
local physicsService = game:GetService("PhysicsService");
local players = game:GetService("Players");
local collectionService  = game:GetService("CollectionService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local creatureService = require(serverScriptService.Server.Services.CreatureService);

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
petAttackingEvent.OnServerEvent:Connect(activePetService.PetAttack);

local setPetAnimation = replicatedStorage.Common.Events.SetPetAnimation;
setPetAnimation.OnServerEvent:Connect(activePetService.PetAnimation);

local petStopAttackingEvent = replicatedStorage.Common.Events.PetStopAttackingEvent;
petStopAttackingEvent.OnServerEvent:Connect(activePetService.StopAttacking);

local equipItemRequest = replicatedStorage.Common.Events.EquipItemRequest;
equipItemRequest.OnServerEvent:Connect(function(player, item)
	local playerItem = itemService.GetPlayerItemByGuid(player, item.PlayerItem.Id);

	if(playerItem == nil) then
		return;
	end

	-- TODO, use server data instead of client
	if(item.ItemData.ItemType == "Pet" or item.ItemData.ItemType == "Seed") then
		activePetService.AddActivePet(player, item);
	end
end);

local petRequestAttack = replicatedStorage.Common.Events.PetRequestAttack;
petRequestAttack.OnServerInvoke = activePetService.RequestPetAttack;