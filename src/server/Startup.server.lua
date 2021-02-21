local adminList = require(game.ServerScriptService.Server.Data.AdminList);
local dataPersistence = require(game.ServerScriptService.Server.DataPersistence.DataPersistence);

local serverProperties = dataPersistence.GetDataStore("ServerProperties");

local admins = serverProperties:GetAsync("Admins") or { "iRixium" };
adminList.SetAdmins(admins);