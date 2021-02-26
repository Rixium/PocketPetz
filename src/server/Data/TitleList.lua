local TitleList = { };

TitleList.Titles = {
    {
        Index = 1,
        Name = "Noob",
        Description = "We all start off somewhere"
    },
    {
        Index = 2,
        Name = "Pro",
        Description = "You raised a pet to its final form"
    },
    {
        Index = 3,
        Name = "Collector",
        Description = "You have one of each pet"
    },
    {
        Index = 4,
        Name = "Millionaire",
        Description = "You made a million coins"
    },
    {
        Index = 5,
        Name = "AlphaStar",
        Description = "Awarded for participating in the alpha"
    },
    {
        Index = 6,
        Name = "Team Grey",
        Description = "Show your support for Legend Grey",
        PurchasePrice = 50
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

    if(titlesIndexes == nil) then
        return TitleList.Titles;
    end
    
    for _, titleIndex in pairs(titleIndexes) do
        table.insert(titlesToReturn, TitleList.Titles[titleIndex]);
    end

    return titlesToReturn;
end

return TitleList;