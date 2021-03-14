-- Imports
local replicatedStorage = game:GetService("ReplicatedStorage");
local players = game:GetService("Players");
local tweenService = game:GetService("TweenService");
local physicsService = game:GetService("PhysicsService");
local itemDropped = replicatedStorage.Common.Events.ItemDropped;
local itemPickedUp = replicatedStorage.Common.Events.ItemPickedUp;

-- Functions
local pickingUpDebounce = false;

local function ItemDropped(itemId, position)
    local itemToDrop = replicatedStorage.Drops[itemId];

    if(itemToDrop == nil) then return end
    
    local cloned = itemToDrop:clone();
    cloned.PrimaryPart = cloned.Root;
    cloned.Parent = workspace;
    cloned:SetPrimaryPartCFrame(CFrame.new(position));

    local item = cloned;
    local itemRunService = nil;
    local touchEvent = nil;
    local bf;
    
	physicsService:SetPartCollisionGroup(item.PrimaryPart, "Items");

    bf = Instance.new("BodyVelocity", item.PrimaryPart);
    bf.Velocity = Vector3.new(math.random(-100, 100), 0, math.random(-100, 100));

    itemRunService = game:GetService("RunService").RenderStepped:Connect(function()
        bf.Velocity = Vector3.new(bf.Velocity.X * 0.9, bf.Velocity.Y, bf.Velocity.Z * 0.9);
        item.Root.CFrame = item.Root.CFrame * CFrame.Angles(0, math.rad(1), 0);
    end); 

    touchEvent = item.PrimaryPart.Touched:Connect(function(toucher)
        local primary = toucher.Parent;
        local player = players:GetPlayerFromCharacter(toucher.Parent);
        
        if player then
            if(pickingUpDebounce) then
                return;
            end
            pickingUpDebounce = true;
            touchEvent:Disconnect();
            local pickedUp = itemPickedUp:InvokeServer(itemId);
            itemRunService:Disconnect();
            pickingUpDebounce = false;
            
            local sound;
            if(item:FindFirstChild("Pickup")) then
                sound = item.Pickup;
                sound:Play();
            end

            itemPosition = item:GetPrimaryPartCFrame().p;
            local x, y, z = item:GetPrimaryPartCFrame():ToEulerAnglesYXZ();

            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0);
            local targetCFrame = CFrame.new(Vector3.new(itemPosition.X, itemPosition.Y + 10, itemPosition.Z), Vector3.new(x, math.rad(y + 180), z));
            local tween = tweenService:Create(item.Root, tweenInfo, { CFrame = targetCFrame });
            
            for _, child in pairs(item.PrimaryPart:GetChildren()) do
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
end

itemDropped.OnClientEvent:Connect(ItemDropped);