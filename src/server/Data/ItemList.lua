local ItemList = {};

ItemList.Items = {
    [1] = {
        ItemId = 1,
        ItemType = "Seed",
        Rarity = "Common",
        Name = "PixieSeed",
        ModelId = 6463616043
    },
    [2] = {
        ItemId = 2,
        ItemType = "Seed",
        Rarity = "Common",
        Name = "CoolSeed",
        ModelId = 6463613741
    },
    [3] = {
        ItemId = 3,
        ItemType = "Seed",
        Rarity = "Common",
        Name = "BruteSeed",
        ModelId = 6463611714
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