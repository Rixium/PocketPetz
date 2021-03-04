-- Imports
local replicatedStorage = game:GetService("ReplicatedStorage");
local players = game:GetService("Players");
local playerEquippedItem = replicatedStorage.Common.Events.PlayerEquippedItem;
local petManager = require(players.LocalPlayer.PlayerScripts.Client.PetManager);

-- Functions

local function OnEquipped(model, itemData)
    local playerCharacter = players.LocalPlayer.Character;

    if(playerCharacter:FindFirstChild("Pet")) then
        playerCharacter.Pet:Destroy();

        if(runner ~= nil) then 
            runner:Disconnect();
            runner = nil;
        end
    end

    local startFrame = playerCharacter:GetPrimaryPartCFrame():ToWorldSpace(CFrame.new(3,1,0))
    local characterCframe = playerCharacter:GetPrimaryPartCFrame()        

    model:SetPrimaryPartCFrame(startFrame);
    model.Name = "Pet";

    petManager.SetActivePet(model, itemData);
end

playerEquippedItem.OnClientEvent:Connect(OnEquipped);