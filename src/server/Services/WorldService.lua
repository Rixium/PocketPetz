local WorldService = {};

-- Imports
local insertService = game:GetService("InsertService");
local serverScriptService = game:GetService("ServerScriptService");
local physicsService = game:GetService("PhysicsService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local itemService = require(serverScriptService.Server.Services.ItemService);
local itemList = require(serverScriptService.Server.Data.ItemList);
local itemDropped = replicatedStorage.Common.Events.ItemDropped;

-- Functions
function WorldService.DropItemFor(player, itemId, position)
    local item = itemList.GetById(itemId);

    if(item == nil) then return end

    local modelId = item.ModelId;
    
	local model = insertService:LoadAsset(modelId);

    local toSend = model:FindFirstChildWhichIsA("Model")
	toSend.PrimaryPart = toSend.Root;
    toSend:SetPrimaryPartCFrame(CFrame.new(position));
	toSend.Parent = workspace;
	physicsService:SetPartCollisionGroup(toSend.PrimaryPart, "Items");
    toSend.Root:SetNetworkOwner(player);

	model:Destroy();

    itemDropped:FireClient(player, toSend);
end

return WorldService;