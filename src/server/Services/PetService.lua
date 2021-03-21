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

local doubleRaresGamePassId = 15999413;

local Rarities = {
    [1] = {
        Name = "Bronze",
        Chance = 100 
    },
    [2] = {
        Name = "Silver",
        Chance = 40
    },
    [3] = { 
        Name = "Gold",
        Chance = 20
    },
    [4] = {
        Name = "Diamond",
        Chance = 5
    }
}

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

function PetService.GetPetsInBag(player)
    local itemStore = dataStore2(itemsStore, player);
    local items = itemStore:Get({});
    local toReturn = {};

    for _, item in pairs(items) do
        if(not item.Data.InStorage) then
            local itemData = itemList.GetById(item.ItemId);
            -- Item must be a pet
            if(itemData.ItemType == "Pet") then
                table.insert(toReturn, item);
            end
        end
    end

    return toReturn;
end

function PetService.GetPetsInStorage(player)
    local itemStore = dataStore2(itemsStore, player);
    local items = itemStore:Get({});
    local toReturn = {};

    for _, item in pairs(items) do
        if(item.Data.InStorage) then
            local itemData = itemList.GetById(item.ItemId);
            -- Item must be a pet
            if(itemData.ItemType == "Pet") then
                table.insert(toReturn, item);
            end
        end
    end

    return toReturn;
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

function PetService.GetRarity(player)
    local multiplier = 1;

    if(player ~= nil) then
        if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(player.UserId, doubleRaresGamePassId) then
            multiplier = multiplier * 2;
        end
    end
    
    local petRarity = nil;
    local randomRarity = math.random(0, 100);

    for _, rarity in ipairs(Rarities) do
        -- If we've rolled lower than the required rarity, then we got it :)
        local actualChance = rarity.Chance * multiplier;
        if(randomRarity <= actualChance) then
            petRarity = rarity;
        end
    end

    return petRarity;
end

function PetService.AddExperience(player, guid, experienceAmount)
    local itemStore = dataStore2(itemsStore, player);
    local items = itemStore:Get({});

    for _, item in pairs(items) do
        if(item.Id == guid) then
            local itemData = itemList.GetById(item.ItemId);
            if(item.Data.CurrentLevel == itemData.LevelToEvolve) then
                return;
            end
        
            item.Data.CurrentExperience = item.Data.CurrentExperience + experienceAmount;
        
            petGotExperience:FireClient(player, item);
        
            if(item.Data.CurrentExperience >= itemData.ExperienceToLevel) then
                LevelUpPet(player, item, itemData);
            end
        
            -- Evolution
            if(item.Data.CurrentLevel == itemData.LevelToEvolve) then
                
                -- Only evolving seeds get a new item rarity
                if(itemData.ItemType == "Seed") then
                    local rarity = PetService.GetRarity(player);
                    item.Data.Rarity = rarity.Name;
                end

                item.Data.CurrentExperience = 0;
        
                local nextPetId = itemData.EvolvesTo;
                local nextPet = itemList.GetById(nextPetId);
        
                item.ItemId = nextPetId;
                item.Data.CurrentHealth = nextPet.BaseHealth;
        
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