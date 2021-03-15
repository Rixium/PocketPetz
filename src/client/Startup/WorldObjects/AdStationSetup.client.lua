local collectionService = game:GetService("CollectionService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local marketplaceService = game:GetService("MarketplaceService");
local tweenService = game:GetService("TweenService");
local playerClickedWorldObject = replicatedStorage.Common.Events.PlayerClickedWorldObject;
local healPet = replicatedStorage.Common.Events.HealPet;
local players = game:GetService("Players");
local getItemsRequest = replicatedStorage.Common.Events.GetItemsRequest;
local healthCentrePet = replicatedStorage.HealthCentrePet;
local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);

local adStations = collectionService:GetTagged("AdvertisementStation");

local mainGUI = uiManager.GetUi("Main GUI");

for index, adStation in pairs(adStations) do

    local interactGUI = replicatedStorage["Interact GUI"]:Clone();
    interactGUI.Adornee = adStation.PrimaryPart;
    interactGUI.Parent = players.LocalPlayer.PlayerGui;
    local button = interactGUI:WaitForChild("ImageButton");

    button.MouseButton1Click:Connect(function ()
        marketplaceService:PromptProductPurchase(players.LocalPlayer, 1158563777);
    end)

    game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
        local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait();
        
        if(not character.PrimaryPart) then
            return;
        end

        local characterPosition = character:GetPrimaryPartCFrame().Position;
        local clonedPosition = adStation:GetPrimaryPartCFrame().Position;

        interactGUI.Enabled = false;
        
        if (characterPosition - clonedPosition).Magnitude <= 10 then
            interactGUI.Enabled = true;
        end
    end);

end