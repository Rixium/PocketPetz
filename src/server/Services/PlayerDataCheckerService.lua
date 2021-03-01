local PlayerDataCheckerService = {};

local serverScriptService = game:GetService("ServerScriptService");

local itemService = require(serverScriptService.Server.Services.ItemService);

function PlayerDataCheckerService.HasItem(player, itemId)
    local playerItems = itemService.GetPlayerItems(player);

    for _, item in pairs(playerItems) do
        if (item.ItemData.ItemId == itemId) then
            return true;
        end
    end

    return false;
end

function PlayerDataCheckerService.HasAnyItem(player, itemIds)
    local playerItems = itemService.GetPlayerItems(player);

    for _, id in pairs(itemIds) do
        if(PlayerDataCheckerService.HasItem(player, id)) then
            return true;
        end
    end

    return false;
end

return PlayerDataCheckerService;