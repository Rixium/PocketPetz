local DropService = {};

local serverScriptService = game:GetService("ServerScriptService");
local moneyManager = require(serverScriptService.Server.Statistics.MoneyManager);
local itemGetFunctions = {};

-- COIN
itemGetFunctions[18] = function(player)
    moneyManager.AddMoney(player, 1);
end

function DropService.GetDrop(player, itemId)
    local callback = itemGetFunctions[itemId];

    if(callback == nil) then
        return false;
    end

    callback(player);
end

return DropService;