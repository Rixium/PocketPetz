return function()
    local serverScriptService = game:GetService("ServerScriptService");
    local petService = require(serverScriptService.Server.Services.PetService);

    describe("Get Rarity", function()
        it("Randomly", function()
            local returned = petService.GetRarity();
            expect(returned).never.to.be.equal(nil);
        end)
    end)
end