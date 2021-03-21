local QuickbarMenu = {}
    
local players = game:GetService("Players");
local replicatedStorage = game:GetService("ReplicatedStorage");
local tweenService = game:GetService("TweenService");
local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local notificationCreator = require(players.LocalPlayer.PlayerScripts.Client.Creators.NotificationCreator);
local mainGui = uiManager.GetUi("Main GUI");
local quickBar = mainGui:WaitForChild("Quickbar");

local getItemsRequest = replicatedStorage.Common.Events.GetItemsRequest;
local petFaintNotification = replicatedStorage.PetFaintNotification;
local equipItemRequest = replicatedStorage.Common.Events.EquipItemRequest;
local isPlayerLifetimeLegend = replicatedStorage.Common.Events.IsPlayerLifetimeLegend;

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

function QuickbarMenu.Setup()
    local items = getItemsRequest:InvokeServer();
    local curr = 1;
    local maxCurr = 3;

    local isLifetimeLegend = isPlayerLifetimeLegend:InvokeServer();

    if(isLifetimeLegend) then
        maxCurr = 5;
    end

    if(isLifetimeLegend) then
        slots[1].Slot.Image = "rbxassetid://6545422916";
        slots[2].Slot.Image = "rbxassetid://6545422916";
        slots[3].Slot.Image = "rbxassetid://6545422916";
        slots[4].Slot.Image = "rbxassetid://6545422916";
        slots[5].Slot.Image = "rbxassetid://6545422916";
    else
        slots[4].Slot.ImageLabel.MouseButton1Click:Connect(ShowLegendsPopup);
        slots[5].Slot.ImageLabel.MouseButton1Click:Connect(ShowLegendsPopup);
    end

    for _, item in pairs(items) do
        if(item.ItemData.ItemType == "Pet") then
            local currentSlot = slots[curr];
            currentSlot.Item = item;
            currentSlot.Slot.ImageLabel.Image = "rbxthumb://type=Asset&id=" .. item.ItemData.ModelId .. "&w=420&h=420";

            if(item.ItemData.Type == "Pixie") then
                currentSlot.Slot.Image = "rbxassetid://6545376359";
            elseif(item.ItemData.Type == "Brute") then
                currentSlot.Slot.Image = "rbxassetid://6545378437";
            else
                currentSlot.Slot.Image = "rbxassetid://6545377628";
            end

            currentSlot.Slot.ImageLabel.MouseButton1Click:Connect(function() 
                local result = equipItemRequest:InvokeServer(currentSlot.Item);
                if(not result.Success) then
                    local messageUi = petFaintNotification:clone();
                    messageUi.MessageBack.Frame.MessageLabel.Text = result.Message;
                    notificationCreator.CreateNotification(messageUi, messageUi.MessageBack);
                end
            end);

            if(curr == maxCurr) then
                break;
            end

            curr = curr + 1;
        end
    end
end

return QuickbarMenu;