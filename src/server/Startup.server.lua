local serverScriptService = game:GetService("ServerScriptService");
local adminList = require(serverScriptService.Server.Data.AdminList);
local dataStoreService = game:GetService("DataStoreService");

local serverPropertiesDataStore = "ServerProperties";

local serverProperties = dataStoreService:GetDataStore(serverPropertiesDataStore);
local admins = serverProperties:GetAsync("Admins") or { "iRixium" };

adminList.SetAdmins(admins);