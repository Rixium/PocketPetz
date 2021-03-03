-- Imports
local replicatedStorage = game:GetService("ReplicatedStorage");
local players = game:GetService("Players");
local playerEquippedItem = replicatedStorage.Common.Events.PlayerEquippedItem;

-- Variables

-- Functions

local function OnEquipped(player, model)
    model.PrimaryPart = model:FindFirstChildWhichIsA("MeshPart");

    local playerCharacter = player.Character;

    game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
        local petCframe =  model["Meshes/base_seed"].CFrame;
        local characterCframe = playerCharacter:GetPrimaryPartCFrame()
        
        local targetCframe = characterCframe:ToWorldSpace(CFrame.new(3,1,0))
        local newCframe = petCframe:Lerp(targetCframe, 0.02)
        model:SetPrimaryPartCFrame(newCframe)
    end);
end

playerEquippedItem.OnClientEvent:Connect(OnEquipped);