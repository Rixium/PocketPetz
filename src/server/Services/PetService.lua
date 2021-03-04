local PetService = {};

local serverScriptService = game:GetService("ServerScriptService");
local dataStoreGet = require(serverScriptService.Server.DataStoreGet);
local dataStore2 = dataStoreGet.DataStore;
local itemsStore = "Items";
local itemList = require(serverScriptService.Server.Data.ItemList);
local replicatedStorage = game:GetService("ReplicatedStorage");
local petGotExperience = replicatedStorage.Common.Events.PetGotExperience;

local function LevelUpPet(player, pet, itemData)
    local remaining = pet.Data.CurrentExperience - itemData.ExperienceToLevel;
    pet.Data.CurrentExperience = remaining;
end

function PetService.AddExperience(player, guid, experienceAmount)
    local itemStore = dataStore2(itemsStore, player);
    local items = itemStore:Get({});

    for _, item in pairs(items) do
        if(item.Id == guid) then
            item.Data.CurrentExperience = item.Data.CurrentExperience + experienceAmount;

            local itemData = itemList.GetById(item.ItemId);

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