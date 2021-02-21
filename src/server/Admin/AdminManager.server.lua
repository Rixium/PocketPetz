local adminSet = require(game.ServerScriptService.Server.Data.AdminList);

function IsAdmin(player) 
    for index, adminName in ipairs(adminSet) do
        if player.Name:lower() == adminName:lower() then 
            return true;
        end
    end

    return false;
end

Game.Players.PlayerAdded:connect(function(player)
    if (IsAdmin(player)) then
        player.Chatted:connect(function(message)
            local splitMessage = string.split(message, ' ');
            if(splitMessage[1] == '!tp') then
                local to = splitMessage[2];
                local toPlayer = game.Players[to];
                local toPosition = toPlayer.Character:GetPrimaryPartCFrame().p;
                player.Character:MoveTo(toPosition)
            end
        end)
    end
end)