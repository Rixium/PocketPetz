
local serverScriptService = game:GetService("ServerScriptService");
local creatureService = require(serverScriptService.Server.Services.CreatureService);

creatureService.Setup();
creatureService.Run();