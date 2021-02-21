local TitleService = {};

local serverScriptService = game:GetService("ServerScriptService");
local titleList = require(serverScriptService.Server.Data.TitleList);
local dataStoreGet = require(serverScriptService.Server.DataStoreGet);

local dataStore2 = dataStoreGet.DataStore;

local titleData = "Titles";

function IsInTable(tableValue, toFind)
	local found = false
	for _,v in pairs(tableValue) do
		if v==toFind then
			found = true
            break;
		end
	end
	return found
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
    return titleStore:Get({});
end

return TitleService;