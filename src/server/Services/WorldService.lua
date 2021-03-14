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
function WorldService.DropItemFor(player, itemId, count, position)
    local item = itemList.GetById(itemId);

    if(item == nil) then return end

    local playerDrops = playersDrops[player.UserId];
    
    if(playerDrops == nil) then
        playerDrops = {};
    end
    
    table.insert(playerDrops, {
        ItemId = itemId,
        Count = count,
        Position = position
    });

    playersDrops[player.UserId] = playerDrops;
    itemDropped:FireClient(player, itemId, count, position);
end

function WorldService.PickUp(player, itemId)
    local playerDrops = playersDrops[player.UserId];

    if(playerDrops == nil) then
        return false;
    end

    local removalIndex = -1;

    for index, drop in pairs(playerDrops) do
        if(drop.ItemId == itemId) then
            if(drop.Count > 0) then
                drop.Count = drop.Count - 1;

                if(drop.Count <= 0) then
                    playerDrops[index] = nil;   
                end
                
                playersDrops[player.UserId] = playerDrops;
                return true;
            else
                playerDrops[index] = nil;   
            end
            
            return false;
        end
    end

    return false;
end

return WorldService;