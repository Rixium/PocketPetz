local TitleService = {};

local serverScriptService = game:GetService("ServerScriptService");
local titleList = require(serverScriptService.Server.Data.TitleList);
local players = game:GetService("Players");

local dataStoreGet = require(serverScriptService.Server.DataStoreGet);

local dataStore2 = dataStoreGet.DataStore;

local titleData = "Titles";
local activeTitleData = "ActiveTitle";

function IsInTable(tableValue, toFind)
	local found = false
	for _, value in pairs(tableValue) do
		if value == toFind then
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

function TitleService.GetPlayerTitleIndexes(player)
    local titleStore = dataStore2(titleData, player);
    return titleStore:Get({});
end

function TitleService.GetPlayerTitles(player)
    local titleStore = dataStore2(titleData, player);
    local titleIndexes = titleStore:Get({});
    return titleList.GetAll(titleIndexes);
end

function TitleService.GetAllTitles(player)
    local titles = {};
    local allTitles = titleList.GetAll();

    for _, title in ipairs(allTitles) do
        local playerHasTitle = TitleService.PlayerHasTitle(player, title.Name);

        local transformed = {
            Index = title.Index,
            Name = title.Name,
            Description = title.Description,
            CanPurchase = title.PurchasePrice ~= nil,
            PurchasePrice = title.PurchasePrice or 0,
            Owned = playerHasTitle,
            ProductId = title.ProductId or -1
        }

        table.insert(titles, transformed);
    end

    return titles;
end

function TitleService.PlayerHasTitle(player, titleName)
    local playerTitles = TitleService.GetPlayerTitleIndexes(player);
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

        local activeTitleStore = dataStore2(activeTitleData, player);
        activeTitleStore:Set(title.Title.Name);
        
        board.TitleField.Text = title.Title.Name;
    end
end

function TitleService.GetActiveTitle(player)
    local activeTitleStore = dataStore2(activeTitleData, player);
    local activeTitle = activeTitleStore:Get("Noob");
    return titleList.GetTitleDataByName(activeTitle);
end

return TitleService;