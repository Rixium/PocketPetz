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

return TitleList;