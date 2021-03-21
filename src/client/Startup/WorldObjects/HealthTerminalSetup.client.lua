local collectionService = game:GetService("CollectionService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local tweenService = game:GetService("TweenService");
local playerClickedWorldObject = replicatedStorage.Common.Events.PlayerClickedWorldObject;
local healPet = replicatedStorage.Common.Events.HealPet;
local players = game:GetService("Players");
local getItemsRequest = replicatedStorage.Common.Events.GetItemsRequest;
local healthCentrePet = replicatedStorage.HealthCentrePet;
local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);

local healthTerminals = collectionService:GetTagged("HealthTerminal");
local pets = {};

local mainGUI = uiManager.GetUi("Main GUI");
local healthTerminalFrame = mainGUI:WaitForChild("HealthTerminalFrame");

local function AddItem(itemToAdd, index)
    local isPlayerLifetimeLegend = replicatedStorage.Common.Events.IsPlayerLifetimeLegend:InvokeServer();
    local maxPets = 3;

    if(isPlayerLifetimeLegend) then
        maxPets = 5;
    end

    if(#pets >= maxPets) then return end
    
    local item = healthCentrePet:clone();
    local frame = item.Frame.ItemBack;

    item.Parent = healthTerminalFrame.ImageLabel.PetFrame;

    local health = itemToAdd.PlayerItem.Data.CurrentHealth or 1;

    frame.LevelText.Text = "Lv. " .. itemToAdd.PlayerItem.Data.CurrentLevel;

    if(health <= 0) then
        frame.Cross.Visible = true;
    end

    frame.ThumbBack1.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    frame.ThumbBack2.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    frame.ThumbBack3.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    frame.ThumbBack4.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    frame.ThumbBack5.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    frame.ThumbBack6.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    frame.ThumbBack7.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    frame.ThumbBack8.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    frame.ItemThumbnail.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";

    item.SendFrame.SendMessageButton.MouseButton1Click:Connect(function()
        healPet:FireServer(itemToAdd.PlayerItem.Id);
        item:Destroy();
        table.remove(pets, index);
        healthTerminalFrame.ImageLabel.PetsHealthy.Visible = (#pets == 0);
        replicatedStorage.PaySound:Play();
    end);
    
    table.insert(pets, item);
end

for index, healthTerminal in pairs(healthTerminals) do

    local interactGUI = replicatedStorage["Interact GUI"]:Clone();
    interactGUI.Adornee = healthTerminal.PrimaryPart;
    interactGUI.Parent = players.LocalPlayer.PlayerGui;
    local button = interactGUI:WaitForChild("ImageButton");

    button.MouseButton1Click:Connect(function ()

        local items = getItemsRequest:InvokeServer();

        -- Remove the old stuff from the friends list.
        for index, oldPet in ipairs(pets) do
            oldPet:Destroy();
        end

        pets = {};
        
        spawn(function ()
            for _, item in pairs(items) do
                if(item.ItemData.ItemType == "Pet") then
                    if(item.PlayerItem.Data.CurrentHealth ~= item.ItemData.BaseHealth) then 
                        AddItem(item, #pets + 1);
                    end
                end
            end

            healthTerminalFrame.ImageLabel.PetsHealthy.Visible = (#pets == 0);
        end);

        healthTerminalFrame.Visible = true;

        local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local tween = tweenService:Create(healthTerminalFrame, tweenInfo, {Position=UDim2.new(0.5, 0, 0.5, 0)})

        tween:Play()
    end)

    game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
        local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait();
        
        if(not character.PrimaryPart) then
            return;
        end

        local characterPosition = character:GetPrimaryPartCFrame().Position;
        local clonedPosition = healthTerminal:GetPrimaryPartCFrame().Position;

        interactGUI.Enabled = false;
        
        if (characterPosition - clonedPosition).Magnitude <= 10 then
            interactGUI.Enabled = true;
        end

    end);

end
