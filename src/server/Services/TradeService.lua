local TradeService = {};

-- Imports
local players = game:GetService("Players");
local replicatedStorage = game:GetService("ReplicatedStorage");
local serverScriptService = game:GetService("ServerScriptService");
local playerService = require(serverScriptService.Server.Services.PlayerService);
local itemService = require(serverScriptService.Server.Services.ItemService);
local itemList = require(serverScriptService.Server.Data.ItemList);

-- Events
local requestTrade = replicatedStorage.Common.Events.RequestTrade;
local acceptTrade = replicatedStorage.Common.Events.AcceptTrade;
local declineTrade = replicatedStorage.Common.Events.DeclineTrade;
local tradeDeclined = replicatedStorage.Common.Events.TradeDeclined;
local itemOffered = replicatedStorage.Common.Events.ItemOffered;
local itemRemovedFromOffer = replicatedStorage.Common.Events.ItemRemovedFromOffer;
local acceptStatusChanged = replicatedStorage.Common.Events.AcceptStatusChanged;
local offerItem = replicatedStorage.Common.Events.OfferItem;
local removeItemFromOffer = replicatedStorage.Common.Events.RemoveItemFromOffer;
local tradeFinalized = replicatedStorage.Common.Events.TradeFinalized;
local tradeRequested = replicatedStorage.Common.Events.TradeRequested;

-- Variables
local activeTrades = {};

function TradeService.Setup()
    -- Set up all the event callbacks :)
    requestTrade.OnServerInvoke = TradeService.TradeRequested;
    offerItem.OnServerInvoke = TradeService.OfferItem;
    removeItemFromOffer.OnServerInvoke = TradeService.RemoveItemFromOffer;
    acceptTrade.OnServerEvent:Connect(TradeService.AcceptTrade);
    declineTrade.OnServerEvent:Connect(TradeService.DeclineTrade);
end

--  Called when a player requests to trade another player
-- Checks if the requestedPlayer is trading - returns false if they are
-- Checks if the requestingPlayer is a legend - returns false if not
-- Otherwise it'll return true, and the trade will be added to the active list.
function TradeService.TradeRequested(requestingPlayer, requestedPlayer)
    local requestingPlayerId = requestingPlayer.UserId;

    -- If the player requesting is not a legend
    if(not playerService.IsPlayerLegend(requestingPlayer)) then
        return {
            Success = false,
            Message = "You need to be a legend to trade!"
        };
    end

    -- If the player requesting is already trading
    if(activeTrades[requestingPlayerId] ~= nil) then
        return {
            Success = false,
            Message = "You're already trading!"
        };
    end

    -- If they've passed an unknown player
    if(requestedPlayer == nil or requestedPlayer.UserId == nil) then
        return {
            Success = false,
            Message = "That player cannot be found!"
        };
    end

    local requestedPlayerId = requestedPlayer.UserId or nil;

    -- -- If the player requested is already trading
    if(activeTrades[requestedPlayerId] ~= nil) then
        return {
            Success = false,
            Message = "The other player is already trading!"
        };
    end

    if(requestedPlayerId == requestedPlayerId) then
        return {
            Success = false,
            Message = "You can't trade yourself!"
        };
    end
    
    -- We add both the requested and the requesting to the tracked trades
    activeTrades[requestedPlayerId] = {
            Other = requestingPlayer,
            Offered = {},
            Accepted = false
    };

    activeTrades[requestingPlayerId] = {
        Other = requestedPlayer,
        Offered = {},
        Accepted = false
    };

    tradeRequested:FireClient(requestedPlayer);

    return {
        Success = true
    };
end

function TradeService.DeclineTrade(player)
    local playersTrade = activeTrades[player.UserId];

    if(playersTrade == nil) then return end

    activeTrades[player.UserId] = nil;
    activeTrades[playersTrade.Other.UserId] = nil;
    print("Player declined trade");

    tradeDeclined:FireClient(playersTrade.Other);
end

-- A player will offer an item. We need to make sure that item is VALID, AND IN THEIR INVENTORY.
function TradeService.OfferItem(player, itemToOffer)
    local playersTrade = activeTrades[player.UserId];

    if(playersTrade == nil) then return end -- Player isn't actually trading ??

    -- An item needs all these to actually exist, instead of a pcall?
    if(itemToOffer == nil) then return end
    if(itemToOffer.PlayerItem == nil) then return end
    if(itemToOffer.PlayerItem.Id == nil) then return end

    -- Get both actual database stored items, so they can't hack it
    local actualPlayerItem = itemService.GetPlayerItemByGuid(player, itemToOffer.PlayerItem.Id);

    -- It doesn't exist :o
    if(actualPlayerItem == nil) then return end
    -- You can't trade an item in storage
    if(actualPlayerItem.Data.InStorage) then return end

    local actualItem = itemList.GetById(actualPlayerItem.ItemId);

    -- Checking if they're already offered it
    for _, v in pairs(playersTrade) do
        if v == actualPlayerItem.Id then 
            return false; 
        end
    end

    print("Player offered: " .. actualPlayerItem.Id);

    -- We add it to the current trade for that player!
    table.insert(playersTrade.Offered, actualPlayerItem.Id);

    itemOffered:FireClient(playersTrade.Other, {
        PlayerItem = actualPlayerItem,
        ItemData = actualItem
    });

    -- Accepted status changes when the trade changes
    playersTrade.Accepted = false;
    activeTrades[playersTrade.Other.UserId].Accepted = false;
    activeTrades[player.UserId] = playersTrade;

    return true;
end

function TradeService.RemoveItemFromOffer(player, itemToRemove)
    local playersTrade = activeTrades[player.UserId];

    if(playersTrade == nil) then return end -- Player isn't actually trading ??

    -- An item needs all these to actually exist, instead of a pcall?
    if(itemToRemove == nil) then return end
    if(itemToRemove.PlayerItem == nil) then return end
    if(itemToRemove.PlayerItem.Id == nil) then return end

    local id = itemToRemove.PlayerItem.Id;
    local indexToRemove = 0;

    for i, v in ipairs(playersTrade.Offered) do
        if(v == id) then
            indexToRemove = i;
            break;
        end
    end

    if indexToRemove ~= 0 then
        table.remove(playersTrade.Offered, indexToRemove);
        -- Accepted changes when trade changes
        playersTrade.Accepted = false;
        activeTrades[player.UserId] = playersTrade;
        itemRemovedFromOffer:FireClient(playersTrade.Other, id);

        -- TODO Notify player that item was removed!!
        activeTrades[playersTrade.Other.UserId].Accepted = false;

        return true;
    end

    return false;
end

function TradeService.AcceptTrade(player)
    local playersTrade = activeTrades[player.UserId];
    playersTrade.Accepted = true;

    activeTrades[player.UserId] = playersTrade;

    -- TODO Notify other player that they accepted! OR FINALISE TRADE

    local otherPlayer = activeTrades[playersTrade.Other.UserId];

    if(otherPlayer.Accepted and playersTrade.Accepted) then
        -- TODO ITEM TRANSFER
        local others = otherPlayer.Offered;
        local yours = playersTrade.Offered;
        
        for _, v in pairs(others) do
           itemService.TransferItem(playersTrade.Other, player, v); 
        end

        for _, v in pairs(yours) do
           itemService.TransferItem(player, playersTrade.Other, v); 
        end

        -- Tell they the trade is over
        tradeFinalized:FireClient(player);
        tradeFinalized:FireClient(playersTrade.Other);

        -- Remove the trading state
        activeTrades[player.UserId] = nil;
        activeTrades[playersTrade.Other.UserId] = nil;
    else
        acceptStatusChanged:FireClient(playersTrade.Other, true);
    end
end

return TradeService;