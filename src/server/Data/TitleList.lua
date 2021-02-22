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

    for index, title in pairs(titleIndexes) do
        table.insert(titlesToReturn, TitleList.Titles[index]);
    end

    return titlesToReturn;
end

return TitleList;