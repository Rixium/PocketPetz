-- Imports
local replicatedStorage = game:GetService("ReplicatedStorage");
local players = game:GetService("Players");
local itemDropped = replicatedStorage.Common.Events.ItemDropped;

-- Functions

local function ItemDropped(item)
    spawn(function()
        local bf = Instance.new("BodyVelocity", item.PrimaryPart);
        bf.Velocity = Vector3.new(math.random(-10, 10), math.random(-20, 20), math.random(-10, 10));
        game:GetService("RunService").RenderStepped:Connect(function()
            bf.Velocity = bf.Velocity - Vector3.new(0, 10, 0);
            bf.Velocity = Vector3.new(bf.Velocity.X * 0.99, bf.Velocity.Y, bf.Velocity.Z * 0.99);
            item.PrimaryPart.CFrame = item.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(1), 0)
        end); 
    end)
    
end

itemDropped.OnClientEvent:Connect(ItemDropped);