local serverScriptService = game:GetService("ServerScriptService");
local players = game:GetService("Players");
local itemTakerService = require(serverScriptService.Server.Services.ItemTakerService);
local playerDataChecker = require(serverScriptService.Server.Services.PlayerDataCheckerService);
local itemList = require(serverScriptService.Server.Data.ItemList);
local itemService = require(serverScriptService.Server.Services.ItemService);
local replicatedStorage = game:GetService("ReplicatedStorage");
local itemPickupEvent = replicatedStorage.Common.Events.ItemPickupEvent;
local itemApprovePickupEvent = replicatedStorage.Common.Events.ItemApprovePickupEvent;
local itemDeclinePickupEvent = replicatedStorage.Common.Events.ItemDeclinePickupEvent;

local itemGivers = itemTakerService.GetAll();

local itemChecks = {};
local spawned = {};
local inside = {};
local playerDebounce = {};

local inProgress = {};

itemChecks[1] = function(player)
    local hasItem = playerDataChecker.HasAnyItem(player, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 });
    
    if(hasItem) then
        return nil;
    end
    
    return {
        Body = "Are you sure? There's no turning back.",
        Item = itemList.GetById(1)
    }
end

itemChecks[2] = function(player)
    local hasItem = playerDataChecker.HasAnyItem(player, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 });

    if(hasItem) then
        return nil;
    end

    return {
        Body = "Are you sure? There's no turning back.",
        Item = itemList.GetById(2)
    }
end

itemChecks[3] = function(player)
    local hasItem = playerDataChecker.HasAnyItem(player, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 });
    
    if(hasItem) then
        return nil;
    end
    
    return {
        Body = "Are you sure? There's no turning back.",
        Item = itemList.GetById(3)
    }
end

local function RequestInProgress(player)
    return inProgress[player.UserId] ~= nil;
end

local function GetItemResponse(itemId, player)
    local check = itemChecks[itemId];
    
    if not check then
        return nil;
    end

    return check(player);
end

for _, itemGiver in pairs(itemGivers) do
    itemGiver.Touched:Connect(function(toucher)
        local primary = toucher.Parent;
        local player = players:GetPlayerFromCharacter(toucher.Parent);
        
        if player then
            if(inside[player.UserId]) then
                return;
            end
            if(RequestInProgress(player)) then
                return;
            end
            
            if(playerDebounce[player.UserId]) then
                return;
            end
            playerDebounce[player.UserId] = true;

            inside[player.UserId] = true;
            local itemId = itemGiver:GetAttribute("ItemId");
            local itemResponse = GetItemResponse(itemId, player);
            if(itemResponse ~= nil) then
                inProgress[player.UserId] = itemId;
                itemPickupEvent:FireClient(player, itemResponse);
            end
            playerDebounce[player.UserId] = nil;
        end
    end);

    itemGiver.TouchEnded:Connect(function(toucher)
        local toucherPlayer = players:GetPlayerFromCharacter(toucher.Parent);

        for _, p in pairs(itemGiver:GetTouchingParts()) do
            local player = players:GetPlayerFromCharacter(p.Parent);
            if toucherPlayer == player then
                return;
            end
        end

        if(spawned[toucherPlayer.UserId]) then 
            return;
        end

        spawn(function()
            spawned[toucherPlayer.UserId] = true;
            repeat wait(1) until (toucher.Position - itemGiver.Position).magnitude > 2;
            inside[toucherPlayer.UserId] = false;
            spawned[toucherPlayer.UserId] = nil;
        end);
    end);
end

itemApprovePickupEvent.OnServerEvent:Connect(function(player, itemId)
    local verify = inProgress[player.UserId] == itemId;
    inProgress[player.UserId] = nil;

    if(verify) then
        itemService.GiveItem(player, itemId);
    end
end)

itemDeclinePickupEvent.OnServerEvent:Connect(function(player, itemId)
    local verify = inProgress[player.UserId] == itemId;
    inProgress[player.UserId] = nil;
end)