local ItemList = {};

ItemList.Items = {
    [1] = {
        ItemId = 1,
        ItemType = "Seed",
        Name = "PixieSeed",
        MeshId = 6452611903
    },
    [2] = {
        ItemId = 2,
        ItemType = "Seed",
        Name = "CoolSeed",
        MeshId = 6452611903
    },
    [3] = {
        ItemId = 3,
        ItemType = "Seed",
        Name = "BruteSeed",
        MeshId = 6452611903
    }
};

function ItemList.GetAllById(itemIds)
    local selectedItems = {};

    for _, itemId in pairs(itemIds) do
        table.insert(selectedItems, ItemList.Items[itemId]);
    end

    return selectedItems;
end

return ItemList;