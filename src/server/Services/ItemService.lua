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
    local itemStore = dataStore2(titleData, player);
    local items = itemStore:Get({});

    local items = itemList.GetAllById(items);

    return items;
end

return ItemService;