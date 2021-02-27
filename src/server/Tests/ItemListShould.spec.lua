return function()
    local serverScriptService = game:GetService("ServerScriptService");
    local itemList = require(serverScriptService.Server.Data.ItemList);

    describe("Get Items", function()
        it("By Given Ids", function()
            local ids = { 1, 2, 3 };
            local returned = itemList.GetAllById(ids);
            expect(#returned).to.equal(3);
            expect(returned[1].Name).to.equal("PixieSeed");
            expect(returned[2].Name).to.equal("CoolSeed");
            expect(returned[3].Name).to.equal("BruteSeed");
        end)
        it("Only By Given Ids", function()
            local ids = { 1, 2 };
            local returned = itemList.GetAllById(ids);
            expect(#returned).to.equal(2);
            expect(returned[1].Name).to.equal("PixieSeed");
            expect(returned[2].Name).to.equal("CoolSeed");
        end)
    end)
end