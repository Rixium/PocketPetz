local ItemTakerService = {};

--Imports
local collectionService = game:GetService("CollectionService");

--Variables
local addedSignal = collectionService:GetInstanceAddedSignal("ItemGiver");

--Functions

function ItemTakerService.GetAll() 
    return collectionService:GetTagged("ItemGiver");
end

return ItemTakerService;