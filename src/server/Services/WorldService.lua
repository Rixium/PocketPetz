local WorldService = {};

-- Imports
local insertService = game:GetService("InsertService");
local serverScriptService = game:GetService("ServerScriptService");
local physicsService = game:GetService("PhysicsService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local itemService = require(serverScriptService.Server.Services.ItemService);
local itemList = require(serverScriptService.Server.Data.ItemList);
local itemDropped = replicatedStorage.Common.Events.ItemDropped;

local playersDrops = {};

-- Functions
function WorldService.DropItemFor(player, itemId, position)
    local item = itemList.GetById(itemId);

    if(item == nil) then return end

    local playerDrops = playersDrops[player.UserId];
    
    if(playerDrops == nil) then
        playerDrops = {};
    end
    
    table.insert(playerDrops, {
        ItemId = itemId,
        Position = position
    });

    playersDrops[player.UserId] = playerDrops;
    itemDropped:FireClient(player, itemId, position);
end

function WorldService.PickUp(player, itemId)
    local playerDrops = playersDrops[player.UserId];

    if(playerDrops == nil) then
        return false;
    end

    local removalIndex = -1;

    for index, drop in pairs(playerDrops) do
        if(drop.ItemId == itemId) then
            playerDrops[index] = nil;    
            playersDrops[player.UserId] = playerDrops;
            return true;
        end
    end

    return false;
end

return WorldService;