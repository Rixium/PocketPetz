local serverScriptService = game:GetService("ServerScriptService");
local TestEZ = require(serverScriptService.Server.TestEZ);

TestEZ.TestBootstrap:run({
    serverScriptService.Server.Tests
});