local TitleService = {};

local serverScriptService = game:GetService("ServerScriptService");
local titleList = require(serverScriptService.Server.Data.TitleList);
local players = game:GetService("Players");

local dataStoreGet = require(serverScriptService.Server.DataStoreGet);

local dataStore2 = dataStoreGet.DataStore;

local titleData = "Titles";

function IsInTable(tableValue, toFind)
    print(tableValue);
	local found = false
	for index, value in pairs(tableValue) do
		if index==toFind then
			return true;
		end
	end
	return false;
end

function TitleService.UnlockTitle(player, titleName)
    local titleStore = dataStore2(titleData, player);
    local titles = titleStore:Get({});
    local titleToUnlock = titleList.GetTitleDataByName(titleName);

    if(titleToUnlock == nil) then
        return;
    end
    
    if(IsInTable(titles, titleToUnlock.Index)) then
        return;
    end
    
    table.insert(titles, titleToUnlock.Index);
    titleStore:Set(titles);
end

function TitleService.GetPlayerTitles(player)
    local titleStore = dataStore2(titleData, player);
    local titleIndexes = titleStore:Get({});
    return titleList.GetAll(titleIndexes);
end

function TitleService.PlayerHasTitle(player, titleName)
    local playerTitles = TitleService.GetPlayerTitles(player);
    local title = titleList.GetTitleDataByName(titleName);
    return IsInTable(playerTitles, title.Index);
end

function TitleService.SetActiveTitle(player, titleName)
    local playerHasTitle = TitleService.PlayerHasTitle(player, titleName);
    
    if(playerHasTitle) then
        local title = titleList.GetTitleDataByName(titleName);
        local character = player.Character or player.CharacterAdded:wait();
        local head = character:WaitForChild("Head");
        local board = head.AboveHeadGUI;
        board.TitleField.Text = title.Title.Name;
    end
end

return TitleService;