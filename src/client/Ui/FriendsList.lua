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
local function iterPageItems(pages)
	return coroutine.wrap(function()
		local pagenum = 1
		while true do
			for _, item in ipairs(pages:GetCurrentPage()) do
				coroutine.yield(item, pagenum)
			end
			if pages.IsFinished then
				break
			end
			pages:AdvanceToNextPageAsync()
			pagenum = pagenum + 1
		end
	end)
end

local scrollingFrame = friendsListGUI.FriendsFrame.FriendsBack.InternalFriendsFrame:WaitForChild("ScrollingFrame");

local function ResetScroll()
    local uiGridLayout = scrollingFrame.UIGridLayout;
    
    local NewSize = SIZE * scrollingFrame.AbsoluteSize;
    uiGridLayout.CellSize = UDim2.new(0, NewSize.X, 0, NewSize.Y);
    
    scrollingFrame.CanvasSize = UDim2.new(0, uiGridLayout.AbsoluteContentSize.X, 0, uiGridLayout.AbsoluteContentSize.Y);
end

function pred(a, b)
    return a.IsOnline;
end

function FriendsList.ShowFriends()
    local playerFriends = players:GetFriendsAsync(players.LocalPlayer.UserId);

    local scrollingFrame = friendsListGUI.FriendsFrame.FriendsBack.InternalFriendsFrame.ScrollingFrame;

    for index, oldItem in ipairs(FriendsList.Items) do
        oldItem:Destroy();
    end

    for index, oldItem in ipairs(FriendsList.Items) do
        table.remove(FriendsList.Items, index);
    end

    local all = {};
    for player, pageNumber in iterPageItems(playerFriends) do
        table.insert(all, player);
    end

    table.sort(all, pred)

    for _, player in ipairs(all) do
        local item = friendsListItem:clone();

        spawn(function () 
            item:WaitForChild("FaceBack").FaceImage.Image = players:GetUserThumbnailAsync(player.Id, thumbType, thumbSize);
        end)
        
        item.Frame.NameLabel.Text = player.Username;

        item.Parent = scrollingFrame;
        item.FriendOffline.Visible = not player.IsOnline;

        if not player.IsOnline then
            item.Frame.Frame.PlaceLabel.Text = "Offline";
        else
            item.Frame.Frame.PlaceLabel.Text = "The Spawn";
        end

        table.insert(FriendsList.Items, item);
    end

    ResetScroll();
end

return FriendsList;