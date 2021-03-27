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

-- Functions 
function ItemService.GetPlayerItems(player)
    local itemStore = dataStore2(itemsData, player);
    local items = itemStore:Get({});

    local items = itemList.GetAllById(items);
    local itemsToSend = {};

    for _, item in pairs(items) do
        table.insert(itemsToSend, item);
    end

    return itemsToSend;
end

function ItemService.ClearItems(player)
    local itemStore = dataStore2(itemsData, player);
    itemStore:Set(nil);
end

function ItemService.StoreItem(player, guid)
    local itemStore = dataStore2(itemsData, player);
    local items = itemStore:Get({});

    for _, item in pairs(items) do
        if(item.Id == guid) then
            item.Data.InStorage = true;
            itemStore:Set(items);
            return;
        end
    end
end

function ItemService.TransferItem(player, other, guid)
    local pStore = dataStore2(itemsData, player);
    local pItems = pStore:Get({});

    local oStore = dataStore2(itemsData, other);
    local oItems = oStore:Get({});

    local toGive = nil;
    local toRemove = 0;

    for index, item in pairs(pItems) do
        if(item.Id == guid) then
            toGive = item;
            toRemove = index;
            break;
        end
    end

    if(toGive == nil) then return end

    table.insert(oItems, toGive);
    table.remove(pItems, index);

    pStore:Set(pItems);
    oStore:Set(oItems);
end

function ItemService.WithdrawItem(player, guid)
    local itemStore = dataStore2(itemsData, player);
    local items = itemStore:Get({});

    for _, item in pairs(items) do
        if(item.Id == guid) then
            item.Data.InStorage = false;
            itemStore:Set(items);
            return;
        end
    end
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

function ItemService.GiveItem(player, itemId, shouldNotify)
    local itemStore = dataStore2(itemsData, player);
    local items = itemStore:Get({});

    local guid = httpService:GenerateGUID();
    
    local newItem = {
        Id = guid,
        ItemId = itemId,
        Data = {
            InStorage = false,
            CurrentExperience = 0,
            CurrentLevel = 1,
            Nickname = ""
        }
    };
    
    spawn(function()
        local itemData = itemList.GetById(itemId);
        newItem.Data.CurrentHealth = itemData.BaseHealth;

        if(shouldNotify ~= nil and shouldNotify == true) then
            gotItemEvent:FireClient(player, itemData);
        end
        
        table.insert(items, newItem);
        itemStore:Set(items);
    end)
end

return ItemService;