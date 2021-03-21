local collectionService = game:GetService("CollectionService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local tweenService = game:GetService("TweenService");
local playerClickedWorldObject = replicatedStorage.Common.Events.PlayerClickedWorldObject;
local players = game:GetService("Players");
local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);

local petStorages = collectionService:GetTagged("PetStorage");
local pets = {};

local storageGUI = uiManager.GetUi("Storage GUI");

for index, petStorage in pairs(petStorages) do

    local interactGUI = replicatedStorage["Interact GUI"]:Clone();
    interactGUI.Adornee = petStorage.PrimaryPart;
    interactGUI.Parent = players.LocalPlayer.PlayerGui;
    local button = interactGUI:WaitForChild("ImageButton");

    button.MouseButton1Click:Connect(function ()
        storageGUI.Enabled = true;

        local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
        local tween = tweenService:Create(storageGUI.ImageLabel, tweenInfo, {Size=UDim2.new(0.8, 0, 0.7, 0)});
        tween:Play()
    end)

    game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
        local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait();
        
        if(not character.PrimaryPart) then
            return;
        end

        local characterPosition = character:GetPrimaryPartCFrame().Position;
        local clonedPosition = petStorage:GetPrimaryPartCFrame().Position;

        interactGUI.Enabled = false;
        
        if (characterPosition - clonedPosition).Magnitude <= 10 then
            interactGUI.Enabled = true;
        end

    end);

end
