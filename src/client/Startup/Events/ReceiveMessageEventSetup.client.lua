local replicatedStorage = game:GetService("ReplicatedStorage");
local receiveMessageEvent = replicatedStorage.Common.Events.ReceiveMessageEvent;

local function ReceiveMessage(otherPlayerId, message)
    print(otherPlayerId);
    print("Received Message: " .. message);
end

receiveMessageEvent.OnClientEvent:Connect(ReceiveMessage);