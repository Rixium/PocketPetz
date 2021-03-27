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
local declineTrade = replicatedStorage.Common.Events.DeclineTrade;
local itemOffered = replicatedStorage.Common.Events.ItemOffered;
local itemRemovedFromOffer = replicatedStorage.Common.Events.ItemRemovedFromOffer;
local offerItem = replicatedStorage.Common.Events.OfferItem;
local removeItemFromOffer = replicatedStorage.Common.Events.RemoveItemFromOffer;
local tradeFinalized = replicatedStorage.Common.Events.TradeFinalized;
local getItemsRequest = replicatedStorage.Common.Events.GetItemsRequest;

-- Variables
local tradeGUI = players.LocalPlayer.PlayerGui:WaitForChild("Trade GUI");
local tradeFrame = tradeGUI.TradeFrame;
local contentFrame = tradeFrame.ContentFrame;
local playersBackpack = contentFrame.TopFrame.BackpackFrame.BackpackBack.ItemGrid;
local yourOffer = contentFrame.TopFrame.OfferFrame.YourOfferFrame.ImageLabel.ItemGrid;
local theirOffer = contentFrame.TopFrame.OfferFrame.TheirOfferFrame.ImageLabel.ItemGrid;
local acceptTradeButton = contentFrame.ButtonFrame.AcceptButtonBack.AcceptButton;
local declineTradeButton = contentFrame.ButtonFrame.DeclineButtonBack.DeclineButton;

-- For backpack resizing and stuff
local backPackItems = {};

local startSize = tradeFrame.Size;
local trading = false;

-- Utility function for adding an item to a given scrolling frame
local function AddItem(scrollingFrame, itemToAdd)
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
    
    table.insert(backPackItems, item);

    return item;
end

local function SetupOfferItem(item, itemData)
    -- When we click the item, then we want to 
    -- send this data to the server and notify other player
    local clickFunction; -- We can detach this from the item image once we've offered it
    clickFunction = item.ImageButton.MouseButton1Click:Connect(function()
        if(debounce) then
            return;
        end
        
        debounce = true;

        -- Tell the server we're offering something
        offerItem:InvokeServer(itemData);
        -- Can't offer the same item again, so disconnect
        clickFunction:Disconnect();

        item.Click:Play();
        local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true);
        local tween = tweenService:Create(item.ImageButton, tweenInfo, {Size=UDim2.new(0.8, 0, 0.8, 0)})
        tween:Play();

        tween.Completed:Wait();
        debounce = false;
    end)
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
        oldItem:Destroy();
    end

    for index, oldItem in ipairs(backPackItems) do
        table.remove(backPackItems, index);
    end
    
    spawn(function ()
        for _, item in pairs(items) do
            -- We don't add the stuff in storage to the backpack
            if(item.PlayerItem.Data.InStorage) then continue end;
            
            -- We're trading, so we add every item here
            local addedItem = AddItem(playersBackpack, item);
            SetupOfferItem(addedItem, item);
        end
    end);
end

-- Functions
function Trade.Show(player, character)
    -- We can't initialize trades if we're already trading.
    if trading then return end
    trading = true;

    local tradeRequest = requestTrade:InvokeServer();

    if not tradeRequest.Success then
        trading = false;
        local messageUi = petFaintNotification:clone();
        messageUi.MessageBack.Frame.MessageLabel.Text = tradeRequest.Message;
        notificationCreator.CreateNotification(messageUi, messageUi.MessageBack);
        return;
    end

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
    if not trading then return end -- We cant end trading if we're not trading already
    
    replicatedStorage.ClickSound:Play();
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = tweenService:Create(tradeFrame, tweenInfo, {Size=UDim2.new(0, 0, 0, 0)})
    tween:Play()
end

function Trade.OfferItem()
    -- THIS WILL SEND SOMETHING TO THE SERVER TO SAY WHAT YOURE OFFERING,
    -- SERVER WILL REPLY WHETHER IT IS A VALID OFFERING,
    -- THEN WE ADD IT TO OUR OFFER LIST.
end

function Trade.RemoveItemFromOffer()
    -- THIS WILL TELL THE SERVER YOURE REMOVING FROM OFFER
    -- THEN WE REMOVE IT FROM OUR OFFER LIST.
end

function Trade.ItemOfferedByOther()
    -- TODO WHEN PLAYER OFFERS ITEM, THIS IS GOING TO ADD IT TO THEIR OFFER LIST.
    -- IT WILL ALSO CANCEL YOUR ACCEPT SO YOU CAN DOUBLE CHECK OFFER
end

function Trade.ItemRemovedByOther()
    -- TODO WHEN PLAYER OFFERS ITEM, THIS IS GOING TO REMOVE IT FROM THEIR OFFER LIST.
    -- IT WILL ALSO CANCEL YOUR ACCEPT SO YOU CAN DOUBLE CHECK OFFER
end

function Trade.AcceptTrade()
    -- TODO TELL SERVER YOU ACCEPTED, SO OTHER PLAYER CAN BE NOTIFIED, 
    -- OR THE TRADE CAN BE FINALIZED DEPENDING ON BOTH PLAYERS ACCEPT STATE
end

function Trade.DeclineTrade()
    -- TODO TELL SERVER YOU CANCELLED, SO OTHER PLAYER TRADE WINDOW CAN CLOSE TOO
    -- ALSO LINK THIS UP WITH A SERVER EVENT FOR TRADE CANCELLED :)
    Trade.Hide();
    trading = false;
end

function Trade.CompletedTrade()
    -- THIS WILL BE CALLED BY THE SERVER WHEN A TRADE HAS BEEN ACCEPTED ON BOTH SIDES
    -- AND ITEMS HAVE ACTUALLY BEEN TRANSFERED (We need to update our local UI to reflect these changes).
end

return Trade;