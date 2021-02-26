local FriendsList = {};

-- Imports
local players = game:GetService("Players");
local replicatedStorage = game:GetService("ReplicatedStorage");
local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local friendsListItem = replicatedStorage.FriendBack;

-- Variables
local friendsListGUI = uiManager.GetUi("Friends GUI");
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420

local SIZE = Vector2.new(0.87, 1);

FriendsList.Items = {};

-- Functions

local scrollingFrame = friendsListGUI.FriendsFrame.FriendsBack.InternalFriendsFrame:WaitForChild("ScrollingFrame");

local function ResetScroll()
    local uiGridLayout = scrollingFrame.UIGridLayout;
    
    local NewSize = SIZE * scrollingFrame.AbsoluteSize;
    uiGridLayout.CellSize = UDim2.new(0, NewSize.X, 0, NewSize.Y);
    
    scrollingFrame.CanvasSize = UDim2.new(0, uiGridLayout.AbsoluteContentSize.X, 0, uiGridLayout.AbsoluteContentSize.Y);
end

local function AddFriendItem(userId, isOnline, userName, gameId)
    local scrollingFrame = friendsListGUI.FriendsFrame.FriendsBack.InternalFriendsFrame.ScrollingFrame;

    local item = friendsListItem:clone();

    item:WaitForChild("FaceBack").FaceImage.Image = players:GetUserThumbnailAsync(userId, thumbType, thumbSize);
    
    item.Frame.NameLabel.Text = userName;

    item.Parent = scrollingFrame;
    item.FriendOffline.Visible = not isOnline;

    local playersPlaceId = gameId;
    local gamePlaceId = game.GameId;

    if not isOnline then
        item.Frame.Frame.PlaceLabel.Text = "Offline";
    elseif (playersPlaceId == gamePlaceId) then
        item.Frame.Frame.PlaceLabel.Text = "The Spawn";
    else
        item.Frame.Frame.PlaceLabel.Text = "Somewhere Else..";
    end

    table.insert(FriendsList.Items, item);
end

function FriendsList.ShowFriends()
    scrollingFrame.Visible = false;
    
    local playerFriends = players.LocalPlayer:GetFriendsOnline();

    -- Sort the list depending on whether they're playing PocketPetz
    table.sort(playerFriends, function(a, b) 
        return a.GameId == game.GameId;
    end);

    -- Remove the old stuff from the friends list.
    for index, oldItem in ipairs(FriendsList.Items) do
        oldItem:Destroy();
    end

    for index, oldItem in ipairs(FriendsList.Items) do
        table.remove(FriendsList.Items, index);
    end

    scrollingFrame.Visible = true;

    spawn(function ()
        -- Online player friends go first.
        for _, player in ipairs(playerFriends) do
            AddFriendItem(player.VisitorId, true, player.UserName, player.GameId);
            ResetScroll();
        end
    end);

end

return FriendsList;