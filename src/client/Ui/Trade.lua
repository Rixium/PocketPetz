local Trade = {};

-- Imports
local players = game:GetService("Players");
local replicatedStorage = game:GetService("ReplicatedStorage");
local starterGuiService = game:GetService("StarterGui")
local tweenService = game:GetService("TweenService")

-- Variables
local tradeGUI = players.LocalPlayer.PlayerGui:WaitForChild("Trade GUI");
local tradeFrame = tradeGUI.TradeFrame;
local contentFrame = tradeFrame.ContentFrame;
local playersBackpack = contentFrame.TopFrame.BackpackFrame.BackpackBack.ItemGrid;
local yourOffer = contentFrame.TopFrame.OfferFrame.YourOfferFrame.ImageLabel.ItemGrid;
local theirOffer = contentFrame.TopFrame.OfferFrame.TheirOfferFrame.ImageLabel.ItemGrid;
local acceptTradeButton = contentFrame.ButtonFrame.AcceptButtonBack.AcceptButton;
local declineTradeButton = contentFrame.ButtonFrame.DeclineButtonBack.DeclineButton;

local startSize = tradeFrame.Size;

local function Setup() 
    acceptTradeButton.MouseButton1Click:Connect(Trade.AcceptTrade);
    declineTradeButton.MouseButton1Click:Connect(Trade.DeclineTrade);
end

-- Functions
function Trade.Show(player, character)
    -- TODO CONFIRM THEY CAN TRADE WITH SERVER REQUIRES LEGEND
    tradeFrame.Size = UDim2.new(0, 0, 0, 0);
    tradeGUI.Enabled = true;

    replicatedStorage.ClickSound:Play();
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
    local tween = tweenService:Create(tradeFrame, tweenInfo, {Size=startSize})
    tween:Play()

    Trade.SetupButtonBar();
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
end

function Trade.CompletedTrade()
    -- THIS WILL BE CALLED BY THE SERVER WHEN A TRADE HAS BEEN ACCEPTED ON BOTH SIDES
    -- AND ITEMS HAVE ACTUALLY BEEN TRANSFERED (We need to update our local UI to reflect these changes).
end

return Trade;