local PetService = {};

local serverScriptService = game:GetService("ServerScriptService");
local dataStoreGet = require(serverScriptService.Server.DataStoreGet);
local dataStore2 = dataStoreGet.DataStore;
local itemsStore = "Items";

local function LevelUpPet(player, pet) 
    local remaining = pet.Data.CurrentExperience - pet.ExperienceToLevel;
    pet.Data.CurrentExperience = remaining;
end

function PetService.AddExperience(player, guid, experienceAmount)
    local itemStore = dataStore2(itemsStore, player);
    local items = itemStore:Get({});

    for _, item in pairs(items) do
        if(item.Id == guid) then
            item.Data.CurrentExperience = item.Data.CurrentExperience + experienceAmount;

            if(item.Data.CurrentExperience >= item.ExperienceToLevel) then
                LevelUpPet(player, item);
            end

            break;
        end
    end

    itemStore:Set(items);
end

return PetService;