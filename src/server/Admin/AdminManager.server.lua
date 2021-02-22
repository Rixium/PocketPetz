local adminSet = require(game.ServerScriptService.Server.Data.AdminList);
local adminCommands = require(game.ServerScriptService.Server.Data.AdminCommands);

local prefix = ':';

function IsAdmin(player)
    return adminSet.Contains(player);
end

local function ParseMessage(message)
	message = string.lower(message)
	local prefixMatch = string.match(message,"^"..prefix)
	
	if prefixMatch then
		message = string.gsub(message, prefixMatch,"",1)
		local arguments = {}
		
		for argument in string.gmatch(message,"[^%s]+") do
			table.insert(arguments, argument)
		end

        return arguments;
	end

    return nil;
end

game.Players.PlayerAdded:connect(function(player)
    repeat wait() until adminSet.Initialized();
    if (IsAdmin(player)) then
        player.Chatted:connect(function(message)

            local parsed = ParseMessage(message);
            
            if(parsed == nil) then
                return;
            end

            local commandName = parsed[1];
            table.remove(parsed, 1);
            local commandFunction = adminCommands[commandName]
            
            if commandFunction == nil then
                return;
            end
            
            commandFunction(player, parsed);
        end)
    end
end)