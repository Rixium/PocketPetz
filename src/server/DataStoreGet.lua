local DataStoreGet = {};

local firstLoginTime = "FirstLogin";
local lastLoginData = "LastLogin";
local goldData = "Gold";

local serverScriptService = game:GetService("ServerScriptService");
local DataStore2 = require(serverScriptService.DataStore2);

DataStore2.Combine("DATA", firstLoginTime, lastLoginData, goldData);

DataStoreGet.DataStore = DataStore2;

return DataStoreGet;