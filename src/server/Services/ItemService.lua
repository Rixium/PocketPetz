local ItemService = {};

-- Imports
local serverScriptService = game:GetService("ServerScriptService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local itemList = require(serverScriptService.Server.Data.ItemList);
local players = game:GetService("Players");

local dataStoreGet = require(serverScriptService.Server.DataStoreGet);
local dataStore2 = dataStoreGet.DataStore;

-- Variables
local itemsData = "Items";

-- Functions 
function ItemService.GetPlayerItems(player)
    local itemStore = dataStore2(itemsData, player);
    local items = itemStore:Get({});

    local items = itemList.GetAllById(items);

    return items;
end

function ItemService.ClearItems(player)
    local itemStore = dataStore2(itemsData, player);
    itemStore:Set(nil);
end

function ItemService.GiveItem(player, itemId)
    local itemStore = dataStore2(itemsData, player);
    local items = itemStore:Get({});

    table.insert(items, {
        ItemId = itemId
    });
    itemStore:Set(items);
end

return ItemService;