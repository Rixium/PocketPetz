local serverScriptService = game:GetService("ServerScriptService");
local players = game:GetService("Players");
local itemTakerService = require(serverScriptService.Server.Services.ItemTakerService);
local playerDataChecker = require(serverScriptService.Server.Services.PlayerDataCheckerService);
local itemService = require(serverScriptService.Server.Services.ItemService);

local itemGivers = itemTakerService.GetAll();

local itemChecks = {};

itemChecks[1] = function(player)
    local hasItem = playerDataChecker.HasAnyItem(player, { 1, 2, 3 });
    if hasItem then
        return;
    end

    itemService.GiveItem(player, 1);
end

itemChecks[2] = function(player)
    local hasItem = playerDataChecker.HasItem(player, { 1, 2, 3 });

end

itemChecks[3] = function(player)
    local hasItem = playerDataChecker.HasItem(player, { 1, 2, 3 });

end

local function ShouldGivePlayer(itemGiver, player)
    local itemId = itemGiver:GetAttribute("ItemId");
    local check = itemChecks[itemId];
    return check(player);
end

for _, itemGiver in pairs(itemGivers) do
    itemGiver.Touched:Connect(function(toucher)
        local player = players:GetPlayerFromCharacter(toucher.Parent);
        if player then
            if(ShouldGivePlayer(itemGiver, player)) then

            end
        end
    end);
end