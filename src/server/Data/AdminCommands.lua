local moneyManager = require(game.ServerScriptService.Server.Statistics.MoneyManager);

local AdminCommands = { };

local function GetPlayer(playerName)
    for index, value in pairs(game.Players:GetChildren()) do
        if(string.lower(value.Name) == string.lower(playerName)) then
            return value;
        end
    end

    return nil;
end

AdminCommands["money"] = function(player, params)
    local playerName = params[1];
    local toPlayer = GetPlayer(playerName);

    if(toPlayer == nil) then
        return;
    end

    local amount = params[2];
    moneyManager.AddMoney(toPlayer, amount);
end

AdminCommands["tp"] = function(player, params)
    local playerName = params[1];
    local toPlayer = GetPlayer(playerName);

    if(toPlayer == nil) then
        return;
    end

    local toPosition = toPlayer.Character:GetPrimaryPartCFrame().p;
    player.Character:MoveTo(toPosition)
end

return AdminCommands;