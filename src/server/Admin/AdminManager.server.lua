local adminSet = require(game.ServerScriptService.Server.Data.AdminList);
local moneyManager = require(game.ServerScriptService.Server.Statistics.MoneyManager);

function IsAdmin(player)
    return adminSet.Contains(player);
end

local function GetPlayer(playerName)
    for index, value in pairs(game.Players:GetChildren()) do
        if(string.lower(value.Name) == string.lower(playerName)) then
            return value;
        end
    end

    return nil;
end

game.Players.PlayerAdded:connect(function(player)
    repeat wait() until adminSet.Initialized();
    if (IsAdmin(player)) then
        player.Chatted:connect(function(message)
            local splitMessage = string.split(message, ' ');
            if(splitMessage[1] == '!tp') then
                local to = splitMessage[2];
                local toPlayer = GetPlayer(to);

                if(toPlayer == nil) then
                    return;
                end

                local toPosition = toPlayer.Character:GetPrimaryPartCFrame().p;
                player.Character:MoveTo(toPosition)
            elseif(splitMessage[1] == '!money') then
                local to = splitMessage[2];
                local toPlayer = GetPlayer(to);

                if(toPlayer == nil) then
                    return;
                end

                local amount = splitMessage[3];
                moneyManager.AddMoney(toPlayer, amount);
            end
        end)
    end
end)