local TitleList = { };

TitleList.Titles = {
    {
        Name = "Noob"
    },
    {
        Name = "Pro"
    },
    {
        Name = "Collector"
    },
    {
        Name = "Millionaire"
    },
    {
        Name = "AlphaStar"
    }
};

function TitleList.GetTitleDataByName(titleName)
    for index, title in pairs(TitleList.Titles) do
        if(title["Name"] == titleName) then
            return 
            { 
                Index = index, 
                Title = title 
            };
        end
    end

    return nil;
end

function TitleList.GetTitleDataByIndex(titleIndex)
    for index, title in pairs(TitleList.Titles) do
        if(index == titleIndex) then
            return 
            {
                Index = index,
                Title = title
            };
        end
    end

    return nil;
end

function TitleList.GetAll(titleIndexes)
    local titlesToReturn = {};

    for _, titleIndex in pairs(titleIndexes) do
        table.insert(titlesToReturn, TitleList.Titles[titleIndex]);
    end

    return titlesToReturn;
end

return TitleList;