-- Imports
local replicatedStorage = game:GetService("ReplicatedStorage");
local players = game:GetService("Players");
local physicsService = game:GetService("PhysicsService");
local itemDropped = replicatedStorage.Common.Events.ItemDropped;

-- Functions

local function ItemDropped(item)
	physicsService:SetPartCollisionGroup(item.PrimaryPart, "Items");
    spawn(function()
        local bf = Instance.new("BodyVelocity", item.PrimaryPart);
        bf.Velocity = Vector3.new(math.random(-100, 100), 0, math.random(-100, 100));
        game:GetService("RunService").RenderStepped:Connect(function()
            bf.Velocity = Vector3.new(bf.Velocity.X * 0.9, bf.Velocity.Y, bf.Velocity.Z * 0.9);
            item.PrimaryPart.CFrame = item.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(1), 0)
        end); 
    end)
    
end

itemDropped.OnClientEvent:Connect(ItemDropped);