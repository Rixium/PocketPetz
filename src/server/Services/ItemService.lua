local ItemService = {};

-- Imports
local serverScriptService = game:GetService("ServerScriptService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local itemList = require(serverScriptService.Server.Data.ItemList);
local players = game:GetService("Players");
local gotItemEvent = replicatedStorage.Common.Events.PlayerGotItemEvent;
local httpService = game:GetService("HttpService");

local dataStoreGet = require(serverScriptService.Server.DataStoreGet);
local dataStore2 = dataStoreGet.DataStore;

-- Variables
local itemsData = "Items";

local ItemPlayerData = {
    [1] = {
        CurrentExperience = 0
    },
    [2] = {
        CurrentExperience = 0
    },
    [3] = {
        CurrentExperience = 0
    }
}

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

function ItemService.GetPlayerItemByGuid(player, guid) 
    local itemStore = dataStore2(itemsData, player);
    local items = itemStore:Get({});

    for _, item in pairs(items) do
        if(item.Id == guid) then
            return item;
        end
    end

    return nil;
end

function ItemService.GiveItem(player, itemId)
    local itemStore = dataStore2(itemsData, player);
    local items = itemStore:Get({});

    local guid = httpService:GenerateGUID();
    
    table.insert(items, {
        Id = guid,
        ItemId = itemId,
        Data = ItemPlayerData[itemId]
    });

    itemStore:Set(items);

    spawn(function()
        local itemData = itemList.GetById(itemId);        
        gotItemEvent:FireClient(player, itemData);
    end)
end

return ItemService;