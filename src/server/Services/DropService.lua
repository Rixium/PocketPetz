local DropService = {};

local serverScriptService = game:GetService("ServerScriptService");
local moneyManager = require(serverScriptService.Server.Statistics.MoneyManager);
local itemService = require(serverScriptService.Server.Services.ItemService);
local itemGetFunctions = {};

-- COIN
itemGetFunctions[18] = function(player)
    moneyManager.AddMoney(player, 1);
end

-- BEEZY SEED
itemGetFunctions[17] = function(player)
    itemService.GiveItem(player, 17, true);
end

-- PIGZEE SEED
itemGetFunctions[14] = function(player)
    itemService.GiveItem(player, 14, true);
end

-- WILD SEED
itemGetFunctions[15] = function(player)
    itemService.GiveItem(player, 15, true);
end

function DropService.GetDrop(player, itemId)
    local callback = itemGetFunctions[itemId];

    if(callback == nil) then
        return false;
    end

    callback(player);
end

return DropService;