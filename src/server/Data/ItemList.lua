local ItemList = {};

ItemList.Items = {
    [1] = {
        ItemId = 1,
        ItemType = "Seed",
        Rarity = "Common",
        Name = "PixieSeed",
        MeshId = 6452611903
    },
    [2] = {
        ItemId = 2,
        ItemType = "Seed",
        Rarity = "Common",
        Name = "CoolSeed",
        MeshId = 6452611903
    },
    [3] = {
        ItemId = 3,
        ItemType = "Seed",
        Rarity = "Common",
        Name = "BruteSeed",
        MeshId = 6452611903
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