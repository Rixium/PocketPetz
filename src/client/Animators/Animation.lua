local Animation = {};

function Animation.Animate(animationId, humanoid, looped) 
    local animation = Instance.new("Animation");
    animation.AnimationId = "rbxassetid://" .. animationId;
    local track = humanoid:LoadAnimation(animation);
    track.Looped = looped or false;
    track:Play();
    return track;
end

return Animation;