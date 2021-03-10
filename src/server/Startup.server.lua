
local collectionService = game:GetService("CollectionService");



local creatures = collectionService:GetTagged("Creature");

for _, creature in pairs(creatures) do
    print(creature.Name);
end