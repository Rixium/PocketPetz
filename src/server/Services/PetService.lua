local PetService = {};

local serverScriptService = game:GetService("ServerScriptService");
local dataStoreGet = require(serverScriptService.Server.DataStoreGet);
local dataStore2 = dataStoreGet.DataStore;
local itemsStore = "Items";

function PetService.AddExperience(player, guid, experienceAmount)
    local itemStore = dataStore2(itemsStore, player);
    local items = itemStore:Get({});

    for _, item in pairs(items) do
        if(item.Id == guid) then
            item.Data.CurrentExperience = item.Data.CurrentExperience + experienceAmount;
            break;
        end
    end

    itemStore:Set(items);
end

return PetService;