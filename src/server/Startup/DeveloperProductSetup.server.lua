local MarketplaceService = game:GetService("MarketplaceService");
local DataStoreService = game:GetService("DataStoreService");
local ServerScriptService = game:GetService("ServerScriptService");
local Players = game:GetService("Players");
local purchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory");

local titleService = require(ServerScriptService.Server.Services.TitleService);
local playerService = require(ServerScriptService.Server.Services.PlayerService);

local productFunctions = {};

-- Team Grey Title
productFunctions[1156529689] = function(receipt, player)
    titleService.UnlockTitle(player, "Team Grey");
	return true;
end

-- Team Grey Title
productFunctions[1156529687] = function(receipt, player)
    titleService.UnlockTitle(player, "Team Fawn");
	return true;
end

-- Team Grey Title
productFunctions[1156529690] = function(receipt, player)
    titleService.UnlockTitle(player, "Team Melody");
	return true;
end

-- 2-Hour Legend
productFunctions[1158563777] = function(receipt, player)
	playerService.MakeLegendForHours(player, 2);
	return true;
end

-- 1-Day Legend
productFunctions[1158563847] = function(receipt, player)
	playerService.MakeLegendForDays(player, 3);
	return true;
end

-- Lifetime Legend
productFunctions[1158563952] = function(receipt, player)
	playerService.MakeLegendForLife(player);
	return true;
end

local function ProcessReceipt(receiptInfo)
	local playerProductKey = receiptInfo.PlayerId .. "_" .. receiptInfo.PurchaseId
	local purchased = false
	local success, errorMessage = pcall(function()
		purchased = purchaseHistoryStore:GetAsync(playerProductKey)
	end)

	if success and purchased then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif not success then
		error("Data store error:" .. errorMessage)
	end
 
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	local handler = productFunctions[receiptInfo.ProductId]
	
	local success, result = pcall(handler, receiptInfo, player)

	if not success or not result then
		warn("Error occurred while processing a product purchase")
		print("\nProductId:", receiptInfo.ProductId)
		print("\nPlayer:", player)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
 
	local success, errorMessage = pcall(function()
		purchaseHistoryStore:SetAsync(playerProductKey, true)
	end)
	if not success then
		error("Cannot save purchase data: " .. errorMessage)
	end
 
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

MarketplaceService.ProcessReceipt = ProcessReceipt