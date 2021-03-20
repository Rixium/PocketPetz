local collectionService = game:GetService("CollectionService");
local serverScriptService = game:GetService("ServerScriptService");
local playerService = require(serverScriptService.Server.Services.PlayerService);

local tagged = collectionService:GetTagged("ZoneTransition");

for _, zoneTransition in pairs(tagged) do
    zoneTransition.Touched:Connect(function(toucher)
        if toucher.Parent:FindFirstChild("Humanoid") then
            local toucherName = toucher.Parent.Name or nil;
            if(toucherName == nil) then return end

            local player = game.Players:FindFirstChild(toucherName);
            if(player == nil) then return end

            local zoneName = zoneTransition:GetAttribute("ZoneName");
            playerService.SetPlayerLocation(player, zoneName);
        end
    end);
end