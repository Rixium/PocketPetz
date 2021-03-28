local QuickbarMenu = {}
    
local players = game:GetService("Players");
local replicatedStorage = game:GetService("ReplicatedStorage");
local tweenService = game:GetService("TweenService");
local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local notificationCreator = require(players.LocalPlayer.PlayerScripts.Client.Creators.NotificationCreator);
local petManager = require(players.LocalPlayer.PlayerScripts.Client.PetManager);
local mainGui = uiManager.GetUi("Main GUI");
local quickBar = mainGui:WaitForChild("Quickbar");
local director = require(players.LocalPlayer.PlayerScripts.Client.Director);
local collectionService = game:GetService("CollectionService");
local tagged = collectionService:GetTagged("HealthTerminal");

local getItemsRequest = replicatedStorage.Common.Events.GetItemsRequest;
local petFaintNotification = replicatedStorage.PetFaintNotification;
local equipItemRequest = replicatedStorage.Common.Events.EquipItemRequest;
local isPlayerLifetimeLegend = replicatedStorage.Common.Events.IsPlayerLifetimeLegend;
local petFainted = replicatedStorage.Common.Events.PetFainted;
local connection;

local slots = {
    [1] = {
        Slot = quickBar:WaitForChild("Slot1"),
        Item = nil,
        Taken = false
    },
    [2] = {
        Slot = quickBar:WaitForChild("Slot2"),
        Item = nil,
        Taken = false
    },
    [3] = {
        Slot = quickBar:WaitForChild("Slot3"),
        Item = nil,
        Taken = false
    }, 
    [4] = {
        Slot = quickBar:WaitForChild("Slot4"),
        Item = nil,
        Taken = false
    }, 
    [5] = {
        Slot = quickBar:WaitForChild("Slot5"),
        Item = nil,
        Taken = false
    }
} 

local function ShowLegendsPopup()
    local toTween = mainGui.LegendFrame
    toTween.Visible = true;
    local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = tweenService:Create(toTween, tweenInfo, {Position=UDim2.new(0.5, 0, 0.5, 0)})
    tween:Play()
end

local function cleanup()
    if slots[1].Callback ~= nil then
        slots[1].Callback:Disconnect();
    end
    if slots[2].Callback ~= nil then
        slots[2].Callback:Disconnect();
    end
    if slots[3].Callback ~= nil then
        slots[3].Callback:Disconnect();
    end
    if slots[4].Callback ~= nil then
        slots[4].Callback:Disconnect();
    end
    if slots[5].Callback ~= nil then
        slots[5].Callback:Disconnect();
    end

    slots[1].Slot.ImageLabel.Image = "";
    slots[2].Slot.ImageLabel.Image = "";
    slots[3].Slot.ImageLabel.Image = "";
    slots[4].Slot.ImageLabel.Image = "";
    slots[5].Slot.ImageLabel.Image = "";

    slots[1].Slot.FaintedCover.Visible = false;
    slots[2].Slot.FaintedCover.Visible = false;
    slots[3].Slot.FaintedCover.Visible = false;
    slots[4].Slot.FaintedCover.Visible = false;
    slots[5].Slot.FaintedCover.Visible = false;
end

function QuickbarMenu.Setup()
    local items = getItemsRequest:InvokeServer();
    local curr = 1;
    local maxCurr = 3;
    local allPets = 0;
    local faintedPets = 0;

    local isLifetimeLegend = isPlayerLifetimeLegend:InvokeServer();

    if isLifetimeLegend then
        maxCurr = 5;
    end

    cleanup();

    if isLifetimeLegend then
        slots[1].Slot.Image = "rbxassetid://6545422916";
        slots[2].Slot.Image = "rbxassetid://6545422916";
        slots[3].Slot.Image = "rbxassetid://6545422916";
        slots[4].Slot.Image = "rbxassetid://6545422916";
        slots[5].Slot.Image = "rbxassetid://6545422916";
    else
        slots[1].Slot.Image = "rbxassetid://6545422916";
        slots[2].Slot.Image = "rbxassetid://6545422916";
        slots[3].Slot.Image = "rbxassetid://6545422916";
        slots[4].Slot.ImageLabel.MouseButton1Click:Connect(ShowLegendsPopup);
        slots[5].Slot.ImageLabel.MouseButton1Click:Connect(ShowLegendsPopup);
    end

    for _, item in pairs(items) do
        if item.ItemData.ItemType == "Pet" and not item.PlayerItem.Data.InStorage then
            allPets = allPets + 1;
            local currentSlot = slots[curr];
            currentSlot.Item = item;
            currentSlot.Slot.ImageLabel.Image = "rbxthumb://type=Asset&id=" .. item.ItemData.ModelId .. "&w=420&h=420";

            if item.ItemData.Type == "Pixie" then
                currentSlot.Slot.Image = "rbxassetid://6545376359";
            elseif item.ItemData.Type == "Brute" then
                currentSlot.Slot.Image = "rbxassetid://6545378437";
            else
                currentSlot.Slot.Image = "rbxassetid://6545377628";
            end

            if item.PlayerItem.Data.CurrentHealth <= 0 then
                faintedPets = faintedPets + 1;
                currentSlot.Slot.FaintedCover.Visible = true;
            end

            currentSlot.Callback = currentSlot.Slot.ImageLabel.MouseButton1Click:Connect(function() 
                local result = equipItemRequest:InvokeServer(currentSlot.Item);
                if not result.Success then
                    local messageUi = petFaintNotification:clone();
                    messageUi.MessageBack.Frame.MessageLabel.Text = result.Message;
                    notificationCreator.CreateNotification(messageUi, messageUi.MessageBack);
                else
                    
                    if result.Model == nil then 
                        petManager.SetActivePet(nil);
                        return 
                    end;

                    local playerCharacter = players.LocalPlayer.Character;

                    local startFrame = playerCharacter:GetPrimaryPartCFrame():ToWorldSpace(CFrame.new(3,1,0))

                    result.Model:SetPrimaryPartCFrame(startFrame);
                    result.Model.Name = "Pet";
                
                    petManager.SetActivePet(result.Model, result.Item);
                end
            end);

            if curr == maxCurr then
                break;
            end

            curr = curr + 1;
        end

        if connection ~= nil then
            connection:Disconnect();
        end

        connection = petFainted.OnClientEvent:Connect(QuickbarMenu.Setup);
    end
    
    if faintedPets == allPets and allPets > 0 then
        mainGui.ImportantMessage.ImageLabel.TextLabel.Text = "Go to town to heal pets";
        mainGui.ImportantMessage.Visible = true;

        director.SetGPS(tagged[1]:FindFirstChildWhichIsA("BasePart"));

        local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
        local tween = tweenService:Create(mainGui.ImportantMessage.ImageLabel, tweenInfo, {Size=UDim2.new(1, 0, 0.9, 0)})
        tween:Play()
    else 
        mainGui.ImportantMessage.Visible = false;
        mainGui.ImportantMessage.ImageLabel.Size = UDim2.new(0,0,0,0);
    end
end

return QuickbarMenu;