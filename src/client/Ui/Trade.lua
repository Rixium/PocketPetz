local Trade = {};

-- Imports
local players = game:GetService("Players");
local replicatedStorage = game:GetService("ReplicatedStorage");
local starterGuiService = game:GetService("StarterGui")
local tweenService = game:GetService("TweenService")
local notificationCreator = require(players.LocalPlayer.PlayerScripts.Client.Creators.NotificationCreator);
local petFaintNotification = replicatedStorage.PetFaintNotification;
local itemBack = replicatedStorage.ItemBack;

-- Events
local requestTrade = replicatedStorage.Common.Events.RequestTrade;
local acceptTrade = replicatedStorage.Common.Events.AcceptTrade;
local acceptStatusChanged = replicatedStorage.Common.Events.AcceptStatusChanged;
local declineTrade = replicatedStorage.Common.Events.DeclineTrade;
local itemOffered = replicatedStorage.Common.Events.ItemOffered;
local itemRemovedFromOffer = replicatedStorage.Common.Events.ItemRemovedFromOffer;
local offerItem = replicatedStorage.Common.Events.OfferItem;
local removeItemFromOffer = replicatedStorage.Common.Events.RemoveItemFromOffer;
local tradeFinalized = replicatedStorage.Common.Events.TradeFinalized;
local getItemsRequest = replicatedStorage.Common.Events.GetItemsRequest;
local tradeRequested = replicatedStorage.Common.Events.TradeRequested;
local tradeDeclined = replicatedStorage.Common.Events.TradeDeclined;

-- Variables
local tradeGUI = players.LocalPlayer.PlayerGui:WaitForChild("Trade GUI");
local tradeFrame = tradeGUI.TradeFrame;
local contentFrame = tradeFrame.ContentFrame;
local playersBackpack = contentFrame.TopFrame.BackpackFrame.BackpackBack.ItemGrid;
local yourOffer = contentFrame.TopFrame.OfferFrame.YourOfferFrame.ImageLabel.ItemGrid;
local theirOffer = contentFrame.TopFrame.OfferFrame.TheirOfferFrame.ImageLabel.ItemGrid;
local acceptedText = contentFrame.ButtonFrame.Message.TextLabel;
local acceptTradeButton = contentFrame.ButtonFrame.AcceptButtonBack.AcceptButton;
local declineTradeButton = contentFrame.ButtonFrame.DeclineButtonBack.DeclineButton;

-- For backpack resizing and stuff
local backPackItems = {};
local theirOffers = {};
local yourOffers = {};

local startSize = tradeFrame.Size;
local trading = false;

-- Utility function for adding an item to a given scrolling frame
local function AddItem(scrollingFrame, itemToAdd, itemSet)
    local item = itemBack:clone();
    item.Parent = scrollingFrame;

    local health = itemToAdd.PlayerItem.Data.CurrentHealth or 1;

    item.LevelText.Text = "Lv. " .. itemToAdd.PlayerItem.Data.CurrentLevel;

    if(health <= 0) then
        item.Cross.Visible = true;
    end

    item.ThumbBack1.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    item.ThumbBack2.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    item.ThumbBack3.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    item.ThumbBack4.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    item.ThumbBack5.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    item.ThumbBack6.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    item.ThumbBack7.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    item.ThumbBack8.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    item.ItemThumbnail.Image = "rbxthumb://type=Asset&id=" .. itemToAdd.ItemData.ModelId .. "&w=420&h=420";
    
    table.insert(itemSet, {
        Id = itemToAdd.PlayerItem.Id,
        Gui = item
    });

    return item;
end

-- Utility function for removing an item to a given scrolling frame
local function RemoveItem(scrollingFrame, itemToRemove, itemSet)
    local indexToRemove = 0;
    for i, v in ipairs(itemSet) do
        if(v.Id == itemToRemove.PlayerItem.Id) then
            indexToRemove = i;
            v.Gui:Destroy();
            break;
        end
    end

    if(indexToRemove == 0) then return end
    table.remove(itemSet, indexToRemove);
end

-- Utility function for removing an item to a given scrolling frame
local function RemoveItemById(scrollingFrame, idOfItem, itemSet)
    local indexToRemove = 0;
    for i, v in ipairs(itemSet) do
        if(v.Id == idOfItem) then
            indexToRemove = i;
            v.Gui:Destroy();
            break;
        end
    end

    if(indexToRemove == 0) then return end
    table.remove(itemSet, indexToRemove);
end

local function SetupOfferItem(item, itemData)
    -- When we click the item, then we want to 
    -- send this data to the server and notify other player
    local clickFunction; -- We can detach this from the item image once we've offered it
    local removeOfferFunction;
    local current;

    clickFunction = function()
        if(debounce) then
            return;
        end
        
        debounce = true;

        -- Tell the server we're offering something
        Trade.OfferItem(item, itemData);
        -- Can't offer the same item again, so disconnect
        current:Disconnect();
        current = item.ImageButton.MouseButton1Click:Connect(removeOfferFunction);

        item.Click:Play();
        local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true);
        local tween = tweenService:Create(item.ImageButton, tweenInfo, {Size=UDim2.new(0.8, 0, 0.8, 0)})
        tween:Play();

        tween.Completed:Wait();
        debounce = false;
    end

    removeOfferFunction = function()
        if(debounce) then
            return;
        end
        
        debounce = true;

        -- Tell the server we're offering something
        Trade.RemoveItemFromOffer(item, itemData);
        -- Can't remove the same item from offer until it's offered again
        current:Disconnect();
        current = item.ImageButton.MouseButton1Click:Connect(clickFunction);

        item.Click:Play();
        local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true);
        local tween = tweenService:Create(item.ImageButton, tweenInfo, {Size=UDim2.new(0.8, 0, 0.8, 0)})
        tween:Play();

        tween.Completed:Wait();
        debounce = false;
    end

    current = item.ImageButton.MouseButton1Click:Connect(clickFunction);
end

function Trade.SetupButtonBar() 
    acceptTradeButton.MouseButton1Click:Connect(Trade.AcceptTrade);
    declineTradeButton.MouseButton1Click:Connect(Trade.DeclineTrade);
end

function Trade.SetupBackpack()
    -- Get all of our items in our backpack
    local items = getItemsRequest:InvokeServer();

    -- Remove the old stuff
    for index, oldItem in ipairs(backPackItems) do
        table.remove(backPackItems, index);
    end
    
    spawn(function ()
        for _, item in pairs(items) do
            -- We don't add the stuff in storage to the backpack
            if(item.PlayerItem.Data.InStorage) then continue end;
            
            -- We're trading, so we add every item here
            local addedItem = AddItem(playersBackpack, item, backPackItems);
            SetupOfferItem(addedItem, item);
        end
    end);
end

function Trade.Setup()
    tradeRequested.OnClientEvent:Connect(Trade.Show);
    
    itemOffered.OnClientEvent:Connect(Trade.ItemOfferedByOther); -- When an item is offered by the other player
    itemRemovedFromOffer.OnClientEvent:Connect(Trade.ItemRemovedByOther); -- When an item is removed from trade by other
    tradeFinalized.OnClientEvent:Connect(Trade.CompletedTrade);
    acceptStatusChanged.OnClientEvent:Connect(Trade.AcceptStatusChanged);
    tradeDeclined.OnClientEvent:Connect(Trade.Hide);
end

function Trade.ClearAll()
    for index, oldItem in ipairs(backPackItems) do
        oldItem.Gui:Destroy();
    end
    for index, oldItem in ipairs(theirOffers) do
        oldItem.Gui:Destroy();
    end
    for index, oldItem in ipairs(yourOffers) do
        oldItem.Gui:Destroy();
    end
end

-- Functions

function Trade.Begin(otherPlayer)
    if trading then return end
    trading = true;

    local tradeRequest = requestTrade:InvokeServer(otherPlayer);
    if(tradeRequest.Success) then
        Trade.Show(otherPlayer);
    else
        trading = false;
        local messageUi = petFaintNotification:clone();
        messageUi.MessageBack.Frame.MessageLabel.Text = tradeRequest.Message;
        notificationCreator.CreateNotification(messageUi, messageUi.MessageBack);
        return;
    end
end


function Trade.Show(otherPlayer)
    Trade.ClearAll();
    backPackItems = {};
    theirOffers = {};
    yourOffers = {};

    -- We can't initialize trades if we're already trading.

    tradeFrame.Size = UDim2.new(0, 0, 0, 0);
    tradeGUI.Enabled = true;

    replicatedStorage.ClickSound:Play();
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
    local tween = tweenService:Create(tradeFrame, tweenInfo, {Size=startSize})
    tween:Play()

    Trade.SetupButtonBar();
    Trade.SetupBackpack();
end

function Trade.Hide()
    replicatedStorage.ClickSound:Play();
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = tweenService:Create(tradeFrame, tweenInfo, {Size=UDim2.new(0, 0, 0, 0)})
    tween:Play()
end

function Trade.OfferItem(itemBack, itemOffered)
    -- THIS WILL SEND SOMETHING TO THE SERVER TO SAY WHAT YOURE OFFERING,
    -- SERVER WILL REPLY WHETHER IT IS A VALID OFFERING,
    -- THEN WE ADD IT TO OUR OFFER LIST.
    offerItem:InvokeServer(itemOffered);
    AddItem(yourOffer, itemOffered, yourOffers);

    local tick = replicatedStorage.ItemOfferedTick:clone();
    tick.Parent = itemBack;
    Trade.AcceptStatusChanged(false, yourOffer);
end

function Trade.RemoveItemFromOffer(itemBack, itemToRemove)
    -- THIS WILL TELL THE SERVER YOURE REMOVING FROM OFFER
    -- THEN WE REMOVE IT FROM OUR OFFER LIST.    
    local removed = removeItemFromOffer:InvokeServer(itemToRemove);
    RemoveItem(yourOffer, itemToRemove, yourOffers);

    itemBack.ItemOfferedTick:Destroy();
    Trade.AcceptStatusChanged(false, yourOffer);
end

function Trade.ItemOfferedByOther(itemOffered)
    -- TODO WHEN PLAYER OFFERS ITEM, THIS IS GOING TO ADD IT TO THEIR OFFER LIST.
    -- IT WILL ALSO CANCEL YOUR ACCEPT SO YOU CAN DOUBLE CHECK OFFER
    AddItem(theirOffer, itemOffered, theirOffers);
    Trade.AcceptStatusChanged(false);
end

function Trade.ItemRemovedByOther(itemToRemove)
    -- TODO WHEN PLAYER OFFERS ITEM, THIS IS GOING TO REMOVE IT FROM THEIR OFFER LIST.
    -- IT WILL ALSO CANCEL YOUR ACCEPT SO YOU CAN DOUBLE CHECK OFFER
    RemoveItemById(theirOffer, itemToRemove, theirOffers);
    Trade.AcceptStatusChanged(false);
end

function Trade.AcceptTrade()
    -- TODO TELL SERVER YOU ACCEPTED, SO OTHER PLAYER CAN BE NOTIFIED, 
    -- OR THE TRADE CAN BE FINALIZED DEPENDING ON BOTH PLAYERS ACCEPT STATE
    acceptTrade:FireServer();
    Trade.AcceptStatusChanged(true, yourOffer);
end

function Trade.DeclineTrade()
    -- TODO TELL SERVER YOU CANCELLED, SO OTHER PLAYER TRADE WINDOW CAN CLOSE TOO
    -- ALSO LINK THIS UP WITH A SERVER EVENT FOR TRADE CANCELLED :)
    declineTrade:FireServer();
    Trade.Hide();
    trading = false;
end

function Trade.CompletedTrade()
    -- THIS WILL BE CALLED BY THE SERVER WHEN A TRADE HAS BEEN ACCEPTED ON BOTH SIDES
    -- AND ITEMS HAVE ACTUALLY BEEN TRANSFERED (We need to update our local UI to reflect these changes).
    Trade.Hide();
    trading = false;
end

function Trade.AcceptStatusChanged(newStatus, frame)
    if(frame == nil) then
        frame = theirOffer;
    end

    if(frame == theirOffer) then
        if(newStatus) then
            acceptedText.Text = "They accepted!"
        else
            acceptedText.Text = ""
        end
    else
        if(newStatus) then
            acceptedText.Text = "You accepted!"
        else
            acceptedText.Text = ""
        end
    end
end

return Trade;