local TitleList = { };

TitleList.Titles = {
    Noob = {
        Name = "Noob",
        Requirements = nil
    },
    Pro = {
        Name = "Pro"
    },
    Collector = {
        Name = "Collector"
    },
    Millionaire = {
        Name = "Millionaire"
    }
};

function TitleList.Print()
    for index, title in pairs(TitleList.Titles) do
        print(title["Name"]);
    end
end

return TitleList;