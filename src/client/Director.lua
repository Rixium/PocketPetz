local Director = {};

-- Importants
local players = game:GetService("Players");
local replicatedStorage = game:GetService("ReplicatedStorage");
local player = players.LocalPlayer;
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart");
local playerAttachment = root:WaitForChild("RootRigAttachment");
local partAttachment = nil;
local beam = replicatedStorage.Beam:Clone();
local runner = nil;
beam.Parent = character;

function Director.SetGPS(part) 
    if partAttachment ~= nil then
        partAttachment:Destroy();
    end

    partAttachment = Instance.new("Attachment");
    partAttachment.Parent = part;
    beam.Attachment0 = playerAttachment;
    beam.Attachment1 = partAttachment;

    if runner ~= nil then
        runner:Disconnect();
    end

    runner = game:GetService("RunService").RenderStepped:Connect(function()
        if (character:GetPrimaryPartCFrame().p - part.CFrame.p).magnitude < 20 then
            beam.Attachment1 = nil
            beam.Attachment0 = nil
            runner:Disconnect();
        end
    end);
end

return Director;