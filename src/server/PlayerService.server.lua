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
local activePets = {};

petAttackingEvent.OnServerEvent:Connect(function(player, pet, petData, target)
	activePets[player.UserId] = {
		Player = player,
		PetModel = pet,
		PetData = petData,
		Target = target
	};
end);

local petStopAttackingEvent = replicatedStorage.Common.Events.PetStopAttackingEvent;
petStopAttackingEvent.OnServerEvent:Connect(function(player, pet, petData, target)
	activePets[player.UserId] = nil;
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

	local model = insertService:LoadAsset(item.ItemData.ModelId);
	
    local toSend = model:FindFirstChildWhichIsA("Model")

	toSend.Parent = player.Character;
	toSend.PrimaryPart:SetNetworkOwner(player);

	model:Destroy();

	physicsService:SetPartCollisionGroup(toSend.PrimaryPart, "Pets")
	
	playerEquipped:FireClient(player, toSend, item);
end);

spawn(function()
	while true do
		wait(1)
		
		for _, pet in pairs(activePets) do
			petService.AddExperience(pet.Player, pet.PetData.PlayerItem.Id, 5);
		end
	end
end);