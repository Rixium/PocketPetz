local ItemList = {};

ItemList.Items = {
    -- Starter Seeds
    [1] = {
        ItemId = 1,
        ItemType = "Seed",
        Name = "Lifadee Seed",
        Type = "Pixie",
        Description = "I wonder what's inside?",
        ModelId = 6492030424,
        ThumbnailId = 6488393425,
        ExperienceToLevel = 10,
        LevelToEvolve = 2,
        EvolvesTo = 4
    },
    [2] = {
        ItemId = 2,
        ItemType = "Seed",
        Name = "Krocie Seed",
        Description = "I wonder what's inside?",
        ModelId = 6492032325,
        ThumbnailId = 6488394048,
        ExperienceToLevel = 10,
        LevelToEvolve = 2,
        EvolvesTo = 5
    },
    [3] = {
        ItemId = 3,
        ItemType = "Seed",
        Name = "Pebbles Seed",
        Description = "I wonder what's inside?",
        ModelId = 6492034287,
        ThumbnailId = 6488394187,
        ExperienceToLevel = 10,
        LevelToEvolve = 2,
        EvolvesTo = 6
    },

    -- Evolution 1
    [4] = {
        ItemId = 4,
        ItemType = "Pet",
        Name = "Lifadee",
        Type = "Pixie",
        Description = "She's humming...",
        ModelId = 6492026121,
        ThumbnailId = 6488635682,
        ExperienceToLevel = 200,
        LevelToEvolve = 12,
        EvolvesTo = 7,
        BaseHealth = 45,
        BaseAttack = 49,
        BaseDefence = 49
    },
    [5] = {
        ItemId = 5,
        ItemType = "Pet",
        Name = "Krocie",
        Type = "Cool",
        Description = "Cool as a ice, baby!",
        ModelId = 6492024166,
        ThumbnailId = 6488713314,
        ExperienceToLevel = 200,
        LevelToEvolve = 12,
        EvolvesTo = 8,
        BaseHealth = 45,
        BaseAttack = 49,
        BaseDefence = 49
    },
    [6] = {
        ItemId = 6,
        ItemType = "Pet",
        Name = "Pebbles",
        Type = "Brute",
        Description = "It's a mean looking fella'",
        ModelId = 6492028403,
        ThumbnailId = 6488510579,
        ExperienceToLevel = 200,
        LevelToEvolve = 12,
        EvolvesTo = 9,
        BaseHealth = 45,
        BaseAttack = 49,
        BaseDefence = 49
    },

    -- Evolution 2
    [7] = {
        ItemId = 4,
        ItemType = "Pet",
        Name = "Stempi",
        Type = "Pixie",
        ModelId = 6463613741,
        ExperienceToLevel = 500,
        LevelToEvolve = 25,
        EvolvesTo = 10,
        BaseHealth = 60,
        BaseAttack = 62,
        BaseDefence = 63
    },
    [8] = {
        ItemId = 5,
        ItemType = "Pet",
        Name = "Aligoo",
        Type = "Cool",
        ModelId = 6463613741,
        ExperienceToLevel = 500,
        LevelToEvolve = 25,
        EvolvesTo = 11,
        BaseHealth = 60,
        BaseAttack = 62,
        BaseDefence = 63
    },
    [9] = {
        ItemId = 6,
        ItemType = "Pet",
        Name = "Rocklee",
        Type = "Brute",
        ModelId = 6463613741,
        ExperienceToLevel = 500,
        LevelToEvolve = 25,
        EvolvesTo = 12,
        BaseHealth = 60,
        BaseAttack = 62,
        BaseDefence = 63
    },

    -- Evolution 3
    [10] = {
        ItemId = 10,
        ItemType = "Pet",
        Name = "Flutterboo",
        Type = "Pixie",
        ModelId = 6463613741,
        BaseHealth = 80,
        BaseAttack = 82,
        BaseDefence = 83
    },
    [11] = {
        ItemId = 11,
        ItemType = "Pet",
        Name = "Gatorain",
        Type = "Cool",
        ModelId = 6463613741,
        BaseHealth = 80,
        BaseAttack = 82,
        BaseDefence = 83
    },
    [12] = {
        ItemId = 12,
        ItemType = "Pet",
        Name = "Bouldagan",
        Type = "Brute",
        ModelId = 6463613741,
        BaseHealth = 80,
        BaseAttack = 82,
        BaseDefence = 83
    },
    [13] = {
        ItemId = 13,
        ItemType = "Pet",
        Name = "Pigzee",
        Type = "Brute",
        Description = "Oink!",
        ModelId = 6500864818,
        BaseHealth = 30,
        ExperienceToLevel = 200,
        LevelToEvolve = 3,
        EvolvesTo = 19, --Bawful
        BaseAttack = 36,
        BaseDefence = 35
    },
    [14] = {
        ItemId = 14,
        ItemType = "Seed",
        Name = "Pigzee Seed",
        Type = "Brute",
        Description = "It smells funny!",
        ModelId = 6504277287,
        ExperienceToLevel = 10,
        LevelToEvolve = 2,
        EvolvesTo = 13, --Pigzee
        Value = 10
    },
    [15] = {
        ItemId = 15,
        ItemType = "Seed",
        Name = "Wild Seed",
        Description = "A strange looking seed.",
        ModelId = 6504279569,
        ExperienceToLevel = 100,
        Value = 100
    },
    [16] = {
        ItemId = 16,
        ItemType = "Pet",
        Name = "Beezy",
        Type = "Pixie",
        Description = "Loves bee-ing around you.",
        ModelId = 6504764631,
        BaseHealth = 40,
        BaseAttack = 45,
        BaseDefence = 40,
        ExperienceToLevel = 200,
        GuiOffset = Vector3.new(0, 8, 0)
    },
    [17] = {
        ItemId = 17,
        ItemType = "Seed",
        Name = "Beezy Seed",
        Type = "Pixie",
        Description = "I can hear it buzzing..",
        ModelId = 6505008452,
        ExperienceToLevel = 10,
        LevelToEvolve = 2,
        EvolvesTo = 16,
        Value = 50
    },
    [18] = {
        ItemId = 18,
        ItemType = "Coin",
        Name = "Coin",
        Description = "I can hear it buzzing..",
        ModelId = 6514406633,
        Value = 10
    },
    [19] = {
        ItemId = 19,
        ItemType = "Pet",
        Name = "Bawful",
        Type = "Brute",
        Description = "Not so cute no more..",
        ModelId = 6551640772,
        BaseHealth = 60,
        ExperienceToLevel = 300,
        BaseAttack = 90,
        BaseDefence = 55,
        GuiOffset = Vector3.new(0, 8, 0)
    },
};

function ItemList.GetAllById(playerItems)
    local selectedItems = {};

    for _, playerItem in ipairs(playerItems) do
        table.insert(selectedItems, {
            PlayerItem = playerItem,
            ItemData = ItemList.Items[playerItem.ItemId]
        });
    end

    return selectedItems;
end

function ItemList.GetById(itemId)
    return ItemList.Items[itemId];
end

return ItemList;