local ItemList = {};

ItemList.Items = {
    [1] = {
        ItemId = 1,
        ItemType = "Seed",
        Rarity = "Common",
        Name = "PixieSeed",
        ModelId = 6453952845
    },
    [2] = {
        ItemId = 2,
        ItemType = "Seed",
        Rarity = "Common",
        Name = "CoolSeed",
        ModelId = 6453936175
    },
    [3] = {
        ItemId = 3,
        ItemType = "Seed",
        Rarity = "Common",
        Name = "BruteSeed",
        ModelId = 6453949098
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

return ItemList;