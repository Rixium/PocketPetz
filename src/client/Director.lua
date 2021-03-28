local Director = {};

-- Importants
local players = game:GetService("Players");
local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local mainGUI = uiManager.GetUi("Main GUI");
local gpsButton = mainGUI:WaitForChild("ToggleGpsFrame");
local TweenService = game:GetService("TweenService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local player = players.LocalPlayer;
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart");
local playerAttachment = root:WaitForChild("RootRigAttachment");
local partAttachment = nil;
local beam = replicatedStorage.Beam:Clone();
local runner = nil;
beam.Parent = character;

gpsButton.GpsButton.MouseButton1Click:Connect(function()
    if beam.Enabled then
        Director.Hide();
    else
        Director.Show();
    end
end);

local function Shrink()
    spawn(function()
        local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local tween = TweenService:Create(gpsButton, tweenInfo, {Size=UDim2.new(0, 0, 0, 0)})
        tween:Play()
        tween.Completed:Wait();
        gpsButton.Visible = false;
    end);
end

local function Grow()
    spawn(function()
        gpsButton.Visible = true;
        local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
        local tween = TweenService:Create(gpsButton, tweenInfo, {Size=UDim2.new(0.1, 0, 0.1, 0)})
        tween:Play()
        tween.Completed:Wait();
    end);
end

local function ShowMessage(message)
    mainGUI.ImportantMessage.ImageLabel.TextLabel.Text = message;
    mainGUI.ImportantMessage.Visible = true;

    local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainGUI.ImportantMessage.ImageLabel, tweenInfo, {Size=UDim2.new(1, 0, 0.9, 0)})
    tween:Play()
end

local function ClearMessage()
    local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainGUI.ImportantMessage.ImageLabel, tweenInfo, {Size=UDim2.new(0, 0, 0, 0)})
    tween:Play()
    tween.Completed:Wait();
    mainGUI.ImportantMessage.Visible = false;
    mainGUI.ImportantMessage.ImageLabel.Size = UDim2.new(0,0,0,0);
end

function Director.SetGPS(message, part) 
    if partAttachment ~= nil then
        partAttachment:Destroy();
    end

    ShowMessage(message);
    partAttachment = Instance.new("Attachment");
    partAttachment.Parent = part;
    beam.Attachment0 = playerAttachment;
    beam.Attachment1 = partAttachment;

    if runner ~= nil then
        runner:Disconnect();
    end

    runner = game:GetService("RunService").RenderStepped:Connect(function()
        if (character:GetPrimaryPartCFrame().p - part.CFrame.p).magnitude < 20 then
            runner:Disconnect();
            beam.Attachment1 = nil
            beam.Attachment0 = nil
            Shrink();
            ClearMessage();
        end
    end);

    Grow();
end

function Director.Hide() 
    beam.Enabled = false
end

function Director.Show()
    beam.Enabled = true
end

return Director;