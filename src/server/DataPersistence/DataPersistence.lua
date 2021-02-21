local DataPersistence = {};

local dataStore = game:GetService("DataStoreService");

function DataPersistence.GetDataStoreForPlayer(player, name)
	return dataStore:GetDataStore(name, player.UserId);
end

function DataPersistence.GetDataStore(name)
	return dataStore:GetDataStore(name);
end

return DataPersistence;