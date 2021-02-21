local adminSet = require(game.ServerScriptService.Server.Data.AdminList);
local moneyManager = require(game.ServerScriptService.Server.Statistics.MoneyManager);

function IsAdmin(player)
    return adminSet.Contains(player);
end

game.Players.PlayerAdded:connect(function(player)
    repeat wait() until adminSet.Initialized();
    if (IsAdmin(player)) then
        player.Chatted:connect(function(message)
            local splitMessage = string.split(message, ' ');
            if(splitMessage[1] == '!tp') then
                local to = splitMessage[2];
                local toPlayer = game.Players[to];
                local toPosition = toPlayer.Character:GetPrimaryPartCFrame().p;
                player.Character:MoveTo(toPosition)
            elseif(splitMessage[1] == '!money') then
                local to = splitMessage[2];
                local toPlayer = game.Players[to];
                local amount = splitMessage[3];
                moneyManager.AddMoney(toPlayer, amount);
            end
        end)
    end
end)