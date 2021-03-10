local GameState = {};

function GameState.SetReady()
    GameState.Ready = true;
end

function GameState.GetReady()
    return GameState.Ready;
end

return GameState;