local DataStoreGet = {};

local firstLoginTime = "FirstLogin";
local lastLoginData = "LastLogin";
local goldData = "Gold";
local titleData = "Titles";
local activeTitleData = "ActiveTitle";
local permissionsData = "Permissions";
local itemsData = "Items";

local serverScriptService = game:GetService("ServerScriptService");
local DataStore2 = require(serverScriptService.DataStore2);

DataStore2.Combine("DATA6", firstLoginTime, lastLoginData, goldData, titleData, activeTitleData, permissionsData, itemsData);

DataStoreGet.DataStore = DataStore2;

return DataStoreGet;