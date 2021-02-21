local DataStoreGet = {};

local firstLoginTime = "FirstLogin";
local lastLoginData = "LastLogin";
local goldData = "Gold";
local titleData = "Titles";

local serverScriptService = game:GetService("ServerScriptService");
local DataStore2 = require(serverScriptService.DataStore2);

DataStore2.Combine("DATA2", firstLoginTime, lastLoginData, goldData, titleData);

DataStoreGet.DataStore = DataStore2;

return DataStoreGet;