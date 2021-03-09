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

    if(pet.Data.CurrentLevel == itemData.LevelToEvolve) then
        pet.Data.CurrentExperience = 0;

        local nextPetId = itemData.EvolvesTo;
        local nextPet = itemList.GetById(nextPetId);

        pet.ItemId = nextPetId;

        petEvolved:FireClient(player, nextPet);
    end
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

            break;
        end
    end

    itemStore:Set(items);
end

return PetService;