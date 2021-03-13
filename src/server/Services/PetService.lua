local PetService = {};

local serverScriptService = game:GetService("ServerScriptService");
local dataStoreGet = require(serverScriptService.Server.DataStoreGet);
local dataStore2 = dataStoreGet.DataStore;
local itemsStore = "Items";
local itemList = require(serverScriptService.Server.Data.ItemList);
local insertService = game:GetService("InsertService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local petGotExperience = replicatedStorage.Common.Events.PetGotExperience;
local petEvolved = replicatedStorage.Common.Events.PetEvolved;

local function LevelUpPet(player, pet, itemData)
    local remaining = pet.Data.CurrentExperience - itemData.ExperienceToLevel;
    pet.Data.CurrentExperience = remaining;
    pet.Data.CurrentLevel = pet.Data.CurrentLevel + 1;
end

function PetService.GetPetByGuid(player, guid)
    local itemStore = dataStore2(itemsStore, player);
    local items = itemStore:Get({});

    for _, item in pairs(items) do
        if(item.Id == guid) then
            return item;
        end
    end

    return nil;
end

function PetService.UpdatePet(player, guid, data)
    local itemStore = dataStore2(itemsStore, player);
    local items = itemStore:Get({});

    for _, item in pairs(items) do
        if(item.Id == guid) then
            item.Data = data;
            break;
        end
    end

    itemStore:Set(items);
end

function PetService.HealAll(player)
    local itemStore = dataStore2(itemsStore, player);
    local items = itemStore:Get({});

    for _, item in pairs(items) do
        local health = item.Data.CurrentHealth or nil;
        if(health ~= nil) then
            local itemData = itemList.GetById(item.ItemId);
            item.Data.CurrentHealth = itemData.BaseHealth;
        end
    end

    itemStore:Set(items);
end

function PetService.HealPet(player, guid)
    local itemStore = dataStore2(itemsStore, player);
    local items = itemStore:Get({});

    for _, item in pairs(items) do
        if(item.Id == guid) then
            local health = item.Data.CurrentHealth or nil;
            if(health ~= nil) then
                local itemData = itemList.GetById(item.ItemId);
                item.Data.CurrentHealth = itemData.BaseHealth;
            end
            break;
        end
    end

    itemStore:Set(items);
end

function PetService.AddExperience(player, guid, experienceAmount)
    local itemStore = dataStore2(itemsStore, player);
    local items = itemStore:Get({});

    for _, item in pairs(items) do
        if(item.Id == guid) then
            local pet = item;

            local itemData = itemList.GetById(item.ItemId);
            if(item.Data.CurrentLevel == itemData.LevelToEvolve) then
                return;
            end
        
            item.Data.CurrentExperience = item.Data.CurrentExperience + experienceAmount;
        
            petGotExperience:FireClient(player, item);
        
            if(item.Data.CurrentExperience >= itemData.ExperienceToLevel) then
                LevelUpPet(player, item, itemData);
            end
        
            
            if(pet.Data.CurrentLevel == itemData.LevelToEvolve) then
                pet.Data.CurrentExperience = 0;
        
                local nextPetId = itemData.EvolvesTo;
                local nextPet = itemList.GetById(nextPetId);
        
                pet.ItemId = nextPetId;
                pet.Data.CurrentHealth = nextPet.BaseHealth;
        
                petEvolved:FireClient(player, nextPet);
            end
            
            itemStore:Set(items);

            return {
                PlayerItem = item,
                ItemData = itemData
            };
        end
    end

    return nil;    
end

return PetService;