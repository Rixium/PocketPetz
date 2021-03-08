local ItemList = {};

ItemList.Items = {
    -- Starter Seeds
    [1] = {
        ItemId = 1,
        ItemType = "Seed",
        Rarity = "Common",
        Name = "Pixie Seed",
        Description = "I wonder what's inside?",
        ModelId = 6463616043,
        ThumbnailId = 6488393425,
        ExperienceToLevel = 10,
        LevelToEvolve = 2,
        EvolvesTo = 4
    },
    [2] = {
        ItemId = 2,
        ItemType = "Seed",
        Rarity = "Common",
        Name = "Cool Seed",
        Description = "I wonder what's inside?",
        ModelId = 6463613741,
        ThumbnailId = 6488394048,
        ExperienceToLevel = 10,
        LevelToEvolve = 2,
        EvolvesTo = 5
    },
    [3] = {
        ItemId = 3,
        ItemType = "Seed",
        Rarity = "Common",
        Name = "Brute Seed",
        Description = "I wonder what's inside?",
        ModelId = 6463611714,
        ThumbnailId = 6488394187,
        ExperienceToLevel = 10,
        LevelToEvolve = 2,
        EvolvesTo = 6
    },

    -- Evolution 1
    [4] = {
        ItemId = 4,
        ItemType = "Pet",
        Rarity = "Common",
        Name = "Lifadee",
        ModelId = 6487557549,
        ThumbnailId = 6488635682,
        ExperienceToLevel = 200,
        LevelToEvolve = 12,
        EvolvesTo = 7
    },
    [5] = {
        ItemId = 5,
        ItemType = "Pet",
        Rarity = "Common",
        Name = "Krocie",
        ModelId = 6485231740,
        ThumbnailId = 6488713314,
        ExperienceToLevel = 200,
        LevelToEvolve = 12,
        EvolvesTo = 8
    },
    [6] = {
        ItemId = 6,
        ItemType = "Pet",
        Rarity = "Common",
        Name = "Pebbles",
        ModelId = 6484066628,
        ThumbnailId = 6488510579,
        ExperienceToLevel = 200,
        LevelToEvolve = 12,
        EvolvesTo = 9
    },

    -- Evolution 2
    [7] = {
        ItemId = 4,
        ItemType = "Pet",
        Rarity = "Rare",
        Name = "Stempi",
        ModelId = 6463613741,
        ExperienceToLevel = 500,
        LevelToEvolve = 25,
        EvolvesTo = 10
    },
    [8] = {
        ItemId = 5,
        ItemType = "Pet",
        Rarity = "Rare",
        Name = "Aligoo",
        ModelId = 6463613741,
        ExperienceToLevel = 500,
        LevelToEvolve = 25,
        EvolvesTo = 11
    },
    [9] = {
        ItemId = 6,
        ItemType = "Pet",
        Rarity = "Rare",
        Name = "Rocklee",
        ModelId = 6463613741,
        ExperienceToLevel = 500,
        LevelToEvolve = 25,
        EvolvesTo = 12
    },

    -- Evolution 3
    [10] = {
        ItemId = 10,
        ItemType = "Pet",
        Rarity = "Legendary",
        Name = "Flutterboo",
        ModelId = 6463613741
    },
    [11] = {
        ItemId = 11,
        ItemType = "Pet",
        Rarity = "Legendary",
        Name = "Gatorain",
        ModelId = 6463613741
    },
    [12] = {
        ItemId = 12,
        ItemType = "Pet",
        Rarity = "Legendary",
        Name = "Bouldagan",
        ModelId = 6463613741
    }

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