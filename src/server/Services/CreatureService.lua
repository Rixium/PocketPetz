local CreatureService = {};

CreatureService.CreatureData = {
    [1] = {
        ItemId = 13,
        Drops = {
            [14] = {
                ItemId = 14,
                Chance = 20
            },
            [15] = {
                ItemId = 15,
                Chance = 1
            }
        },
        BaseExperienceAward = 20
    }
}

local creatures = {};

function CreatureService.AddCreature(creature)
    table.insert(creatures, creature);
end

function CreatureService.GetCreatureDataById(creatureId) 
    return CreatureService.CreatureData[creatureId];
end

function CreatureService.GetAll()
    return creatures;
end

function CreatureService.GetCreatureByGameObject(gameObject)
    for _, creature in pairs(creatures) do
        if(creature.GameObject == gameObject) then
            return creature;
        end
    end

    return nil;
end

return CreatureService;