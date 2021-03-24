local EvolutionGUI = {};

local players = game:GetService("Players");
local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local quickbarMenu = require(players.LocalPlayer.PlayerScripts.Client.Ui.QuickbarMenu);
local evolutionGui = uiManager.GetUi("Evolution GUI");
local TweenService = game:GetService("TweenService")
local connect;
local image;
local clicks = 0;
local nextPet;
local speed = 0.2;
local nextModelId;

local uiManager = require(players.LocalPlayer.PlayerScripts.Client.Ui.UiManager);
local mainGui = uiManager.GetUi("Main GUI");
local bagButton = mainGui:WaitForChild("Buttons").BagButton.BagButton;
local spinner = evolutionGui.Spinner;

local function Transition()

    local frame = evolutionGui:WaitForChild("EvolveFrame");
    image = frame:WaitForChild("Frame"):WaitForChild("Image");
    local text = frame:WaitForChild("TextFrame"):WaitForChild("TextLabel");
    local color;

    if(nextPet.ItemData.Type == "Brute") then
        color = "#c6fb64"; -- Green
    elseif(nextPet.ItemData.Type == "Pixie") then
        color = "#ff5ca8"; -- Pink
    else 
        color = "#2dc8ed"; -- Blue
    end

    text.Text = "It evolved in to <font color=\"" .. color .. "\">" .. nextPet.ItemData.Name .. "</font>!"

    local tweenInfo = TweenInfo.new(speed, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
    local tween = TweenService:Create(image, tweenInfo, {Size = UDim2.new(0, 0, 0, 0), Rotation = 0})

    image.Success:Play();
    tween:Play()
    tween.Completed:Wait();

    spinner.Visible = true;
    local spinnerInfo = TweenInfo.new(speed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    local spinnerTween = TweenService:Create(spinner, spinnerInfo, {ImageTransparency = 0.3})
    spinnerTween:Play();

    image.Image = "rbxthumb://type=Asset&id=" .. nextModelId .. "&w=420&h=420";
    
    tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
    tween = TweenService:Create(image, tweenInfo, {Size = UDim2.new(0.8, 0, 0.8, 0), Rotation = 0})

    local textTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local textTween = TweenService:Create(text, textTweenInfo, {Size = UDim2.new(0.8, 0, 0.5, 0), TextTransparency = 0, TextStrokeTransparency = 0})

    local spinnerRenderStep;
    spinnerRenderStep = game:GetService("RunService").RenderStepped:Connect(function()
        spinner.Rotation = spinner.Rotation + 1;
    end)
    
    tween:Play()
    textTween:Play();

    wait(3);

    quickbarMenu.Setup();
    spinnerInfo = TweenInfo.new(speed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    spinnerTween = TweenService:Create(spinner, spinnerInfo, {ImageTransparency = 1})
    spinnerTween:Play();

    local abs = {
        X = bagButton.AbsolutePosition.X + bagButton.AbsoluteSize.X / 2,
        Y = bagButton.AbsolutePosition.Y + bagButton.AbsoluteSize.Y / 2
    }
    local toBagInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In);

    local toBagTween = TweenService:Create(image, toBagInfo, { 
        Position =  UDim2.new(0, abs.X - image.Parent.AbsolutePosition.X, 0, abs.Y - image.Parent.AbsolutePosition.Y),
        Size = UDim2.new(0, 0, 0, 0)
    });
    toBagTween:Play();
    toBagTween.Completed:Wait();
    bagButton.Pickup:Play();
    local bagPopInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true);
	local bagPopTween = TweenService:Create(bagButton, bagPopInfo, {Size=UDim2.new(1.2, 0, 1.2, 0)})
    bagPopTween:Play();
    
    textTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    textTween = TweenService:Create(text, textTweenInfo, {Size = UDim2.new(0.8, 0, 0, 0), TextTransparency = 1, TextStrokeTransparency = 1})
    textTween:Play();

    image.Position = UDim2.new(0.5, 0, 0.5, 0);
    image.Size = UDim2.new(0,0,0,0);
    
    clicks = 0;
    
    textTween.Completed:Wait();
    spinnerTween.Completed:Wait();
    spinnerRenderStep:Disconnect();
    spinner.Visible = false;

    evolutionGui.Enabled = false;
end

local function Grow()
    connect:Disconnect();
    local tweenInfo = TweenInfo.new(speed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(image, tweenInfo, {Rotation=20})
    image.Tap1:Play();
    tween:Play()
    tween.Completed:Wait();
    tween = TweenService:Create(image, tweenInfo, {Rotation=0})
    tween:Play()

    image.Size = UDim2.new(image.Size.X.Scale + 0.1, 0, image.Size.Y.Scale + 0.1, 0);
    
    clicks = clicks + 1;

    if(clicks == 5) then
        Transition();
    else
        connect = image.MouseButton1Click:Connect(Grow);
    end
end

function EvolutionGUI.Setup(current, next)
    evolutionGui.Enabled = true;
    nextPet = next;
    nextModelId = next.ItemData.ModelId;
    
    local frame = evolutionGui:WaitForChild("EvolveFrame");
    image = frame:WaitForChild("Frame"):WaitForChild("Image");
    image.Image = "rbxthumb://type=Asset&id=" .. current.ItemData.ModelId .. "&w=420&h=420";

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    local tween = TweenService:Create(image, tweenInfo, {Size=UDim2.new(0.8, 0,0.8, 0)})
    tween:Play()
    tween.Completed:Wait();

    connect = image.MouseButton1Click:Connect(Grow);
end


return EvolutionGUI;