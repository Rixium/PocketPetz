local serverScriptService = game:GetService("ServerScriptService");
local players = game:GetService("Players");
local collectionService = game:GetService("CollectionService");

local coins = collectionService:GetTagged("Coin");

for _, coin in pairs(coins) do

    coin.Touched:Connect(function(toucher)
        local primary = toucher.Parent;
        local player = players:GetPlayerFromCharacter(toucher.Parent);
        
        if player then
            
        end
    end);
end
