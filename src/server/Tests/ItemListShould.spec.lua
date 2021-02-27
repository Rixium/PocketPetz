return function()
    local serverScriptService = game:GetService("ServerScriptService");
    local itemList = require(serverScriptService.Server.Data.ItemList);

    describe("Get Items", function()
        it("By Given Ids", function()
            local playerItems = {
                [1] = {
                    ItemId = 1
                }, 
                [2] = {
                    ItemId = 2
                }, 
                [3] = {
                    ItemId = 3
                } 
            };
            local returned = itemList.GetAllById(playerItems);
            expect(#returned).to.equal(3);
            expect(returned[1].ItemData.Name).to.equal("PixieSeed");
            expect(returned[2].ItemData.Name).to.equal("CoolSeed");
            expect(returned[3].ItemData.Name).to.equal("BruteSeed");
        end)
        it("Only By Given Ids", function()
            local playerItems = { 
                [1] = {
                    ItemId = 1
                }, 
                [2] = {
                    ItemId = 2
                }
            };
            local returned = itemList.GetAllById(playerItems);
            expect(#returned).to.equal(2);
            expect(returned[1].ItemData.Name).to.equal("PixieSeed");
            expect(returned[2].ItemData.Name).to.equal("CoolSeed");
        end)
    end)
end