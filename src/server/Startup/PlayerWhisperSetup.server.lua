local replicatedStorage = game:GetService("ReplicatedStorage");
local players = game:GetService("Players");

local messagePlayerEvent = replicatedStorage.Common.Events.MessagePlayerEvent;
local receiveMessageEvent = replicatedStorage.Common.Events.ReceiveMessageEvent;

local function SendPlayerMessage(player, otherPlayerId, message)
    local otherPlayer = players:GetPlayerByUserId(otherPlayerId);

    if(otherPlayer == nil) then
        return;
    end

    receiveMessageEvent:FireClient(otherPlayer, player.UserId, message);
end

messagePlayerEvent.OnServerEvent:Connect(SendPlayerMessage);