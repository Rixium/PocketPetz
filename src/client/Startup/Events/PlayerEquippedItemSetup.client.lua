-- Imports
local replicatedStorage = game:GetService("ReplicatedStorage");
local players = game:GetService("Players");
local playerEquippedItem = replicatedStorage.Common.Events.PlayerEquippedItem;
local petManager = require(players.LocalPlayer.PlayerScripts.Client.PetManager);

-- Functions
local function ShowXpAbove(model, itemData)
    local npcAboveHeadGUI = replicatedStorage.ExperienceGUI;
    local board = npcAboveHeadGUI:Clone()
    board.Parent = workspace;
    board.Adornee = model;
    
    local currentExperience = itemData.PlayerItem.Data.CurrentExperience;
    local toLevel = itemData.ItemData.ExperienceToLevel;

    local width = currentExperience / toLevel;
    board.Experience.Size = UDim2.new(width,0, 1,0);

    itemData.PlayerItem.Data.CurrentExperience = itemData.PlayerItem.Data.CurrentExperience + 0.1;

    width = itemData.PlayerItem.Data.CurrentExperience / itemData.ItemData.ExperienceToLevel;
    
    if(width > 1) then
        width = 1;
    end

    board.Experience.Size = UDim2.new(width,0, 1,0);
end

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

    ShowXpAbove(model, itemData);
end

playerEquippedItem.OnClientEvent:Connect(OnEquipped);