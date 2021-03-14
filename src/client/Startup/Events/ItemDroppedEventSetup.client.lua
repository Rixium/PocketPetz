-- Imports
local replicatedStorage = game:GetService("ReplicatedStorage");
local players = game:GetService("Players");
local tweenService = game:GetService("TweenService");
local physicsService = game:GetService("PhysicsService");
local itemDropped = replicatedStorage.Common.Events.ItemDropped;
local itemPickedUp = replicatedStorage.Common.Events.ItemPickedUp;

-- Functions
local pickingUpDebounce = false;
local drops = {};

local function ItemDropped(itemId, count, position)
    local itemToDrop = replicatedStorage.Drops[itemId];
    if(itemToDrop == nil) then return end

    for num = 1, count do
        wait(0.1);
        spawn(function()
            local cloned = itemToDrop:Clone();

            cloned.PrimaryPart = cloned.Root;
            cloned.Parent = workspace;

            local actualPosition = position + Vector3.new(math.random(-200, 200) / 100, 0, math.random(-200, 200) / 100);
            cloned:SetPrimaryPartCFrame(CFrame.new(actualPosition));

            local item = cloned;
            local sound = replicatedStorage.Bubble:clone();
            sound.PlaybackSpeed = 1 + (num / count);
            sound.Volume = 0.8;
            sound.RollOffMinDistance = 0;
            sound.RollOffMaxDistance = 50;
            sound.RollOffMode = Enum.RollOffMode.LinearSquare;
            sound.Parent = item.Root;
            sound:Play();

            local touchEvent = nil;
            local bf = Instance.new("BodyVelocity", item.PrimaryPart);
            bf.Velocity = Vector3.new(math.random(-50, 50), 0, math.random(-50, 50));

            drops[item] = item;

            while bf.Velocity.magnitude > -0.01 and bf.Velocity.magnitude < 0.01 do wait(0.1) end

            touchEvent = item.Part.Touched:Connect(function(toucher)
                local primary = toucher.Parent;
                local player = players:GetPlayerFromCharacter(toucher.Parent);
                
                if player then
                    if(pickingUpDebounce) then
                        return;
                    end
                    pickingUpDebounce = true;
                    touchEvent:Disconnect();
                    local pickedUp = itemPickedUp:InvokeServer(itemId);
                    drops[item] = nil;
                    pickingUpDebounce = false;
                    
                    local sound;
                    if(item:FindFirstChild("Pickup")) then
                        sound = item.Pickup;
                        sound:Play();
                    end

                    itemPosition = item:GetPrimaryPartCFrame().p;
                    local x, y, z = item:GetPrimaryPartCFrame():ToEulerAnglesYXZ();

                    item.Root.Massless = false;

                    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0);
                    local targetCFrame = CFrame.new(Vector3.new(itemPosition.X, itemPosition.Y + 10, itemPosition.Z), Vector3.new(x, math.rad(y + 180), z));
                    local tween = tweenService:Create(item.Root, tweenInfo, { CFrame = targetCFrame });
                    
                    for _, child in pairs(item:GetChildren()) do
                        if child:IsA('BasePart') then
                            tweenService:Create(child, tweenInfo, { Transparency = 1 }):Play();
                        end
                    end

                    tween:Play();

                    if(sound ~= nil) then
                        sound.Ended:Wait();
                    end

                    item:Destroy();

                end
            end)
        end)
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    wait(0.1);
    for _, item in pairs(drops) do
        if(item == nil) then continue end
        local bf = item.PrimaryPart.BodyVelocity;
        if(bf == nil) then continue end
        bf.Velocity = Vector3.new(bf.Velocity.X * 0.9, bf.Velocity.Y, bf.Velocity.Z * 0.9);
        item.Root.CFrame = item.Root.CFrame * CFrame.Angles(0, math.rad(2), 0);
    end
end);

itemDropped.OnClientEvent:Connect(ItemDropped);