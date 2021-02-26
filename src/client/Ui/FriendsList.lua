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

local SIZE = Vector2.new(0.9, 1);

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
    
    scrollingFrame.CanvasSize = UDim2.new(0, uiGridLayout.AbsoluteContentSize.X, 0, uiGridLayout.AbsoluteContentSize.Y  + 10);
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

    for player, pageNumber in iterPageItems(playerFriends) do
        print(player);
        if not player.IsOnline then
            continue;
        end

        local item = friendsListItem:clone();

        spawn(function () 
            item:WaitForChild("FaceBack").FaceImage.Image = players:GetUserThumbnailAsync(player.Id, thumbType, thumbSize);
        end)
        
        item.Frame.NameLabel.Text = player.Username;
        item.Frame.Frame.PlaceLabel.Text = "???";

        item.Parent = scrollingFrame;

        table.insert(FriendsList.Items, item);
    end

    ResetScroll();
end

return FriendsList;