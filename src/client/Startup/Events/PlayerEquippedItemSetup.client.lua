-- Imports
local replicatedStorage = game:GetService("ReplicatedStorage");
local players = game:GetService("Players");
local playerEquippedItem = replicatedStorage.Common.Events.PlayerEquippedItem;
local petManager = require(players.LocalPlayer.PlayerScripts.Client.PetManager);

-- Functions