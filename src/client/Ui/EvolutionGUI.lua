local EvolutionGUI = {};

local players = game:GetService("Players");
local replicatedStorage = game:GetService("ReplicatedStorage");
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

local petEvolved = replicatedStorage.Common.Events.PetEvolved;
local callback;

function EvolutionGUI.Init()
    callback = petEvolved.OnClientEvent:Connect(EvolutionGUI.Setup);
end
local function Transition()

    local frame = evolutionGui:WaitForChild("EvolveFrame");
    image = frame:WaitForChild("ImageLabel"):WaitForChild("Frame").Image;
    local color;

    if(nextPet.ItemData.Type == "Brute") then
        color = "#c6fb64"; -- Green
    elseif(nextPet.ItemData.Type == "Pixie") then
        color = "#ff5ca8"; -- Pink
    else 
        color = "#2dc8ed"; -- Blue
    end

    local textFrame = frame.ImageLabel.Frame.TextFrame;

    for _, t in pairs(textFrame:GetChildren()) do

        if(t.Name == "Front") then
            t.Text = "<font color=\"" .. color .. "\">" .. nextPet.ItemData.Name .. "</font>";
            continue;
        end

        t.Text = nextPet.ItemData.Name;
    end

    local tweenInfo = TweenInfo.new(speed, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)

    local tweenInfo = TweenInfo.new(speed, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
    local tween = TweenService:Create(image, tweenInfo, {Size = UDim2.new(0, 0, 0, 0), Rotation = 0})

    image.Success:Play();
    tween:Play()
    tween.Completed:Wait();

    local tweenInfoEvolveText = TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
    local evolveIn = frame.ImageLabel.Frame.Frame.evolveIn;
    local bronze = frame.ImageLabel.Frame.Frame.bronze;
    local silver = frame.ImageLabel.Frame.Frame.silver;
    local gold = frame.ImageLabel.Frame.Frame.gold;
    local diamond = frame.ImageLabel.Frame.Frame.diamond;

    -- It evolved in to a..
    local evolveTween = TweenService:Create(evolveIn, tweenInfoEvolveText, {Size = UDim2.new(1.5, 0, 0.5, 0), Rotation = 0});
    evolveTween:Play();
    evolveTween.Completed:Wait();

    local selected = diamond;

    if(nextPet.PlayerItem.Rarity == "Bronze") then
        selected = bronze;
    elseif(nextPet.PlayerItem.Rarity == "Silver") then
        selected = silver;
    elseif(nextPet.PlayerItem.Rarity == "Gold") then
        selected = gold;
    end

    -- Rarity!!
    TweenService:Create(selected, tweenInfoEvolveText, {Size = UDim2.new(0.5, 0, 1, 0), Rotation = 0}):Play();

    image.Image = "rbxthumb://type=Asset&id=" .. nextModelId .. "&w=420&h=420";
    
    -- Make the image bigger!
    tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
    tween = TweenService:Create(image, tweenInfo, { Size = UDim2.new(0.5, 0, 0.5, 0) })

    -- Make the text BIGGER
    local textTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local textTween = TweenService:Create(textFrame, textTweenInfo, { Size = UDim2.new(1, 0, 0.2, 0) })

    tween:Play()
    textTween:Play();

    spawn(function()
        for _, t in pairs(textFrame:GetChildren()) do
            -- Make the text visible
            TweenService:Create(t, textTweenInfo, { TextTransparency = 0, TextStrokeTransparency = 0 }):Play();
        end
    end)
    
    wait(3);

    quickbarMenu.Setup();

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
    
    local text = TweenService:Create(textFrame, textTweenInfo, { Size = UDim2.new(0.8, 0, 0, 0) });
    tweenInfoEvolveText = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(evolveIn, tweenInfoEvolveText, {Size = UDim2.new(0, 0, 0, 0)}):Play();
    TweenService:Create(selected, tweenInfoEvolveText, {Size = UDim2.new(0, 0, 0, 0)}):Play();

    text:Play();

    toBagTween.Completed:Wait();
    bagButton.Pickup:Play();
    local bagPopInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true);
	local bagPopTween = TweenService:Create(bagButton, bagPopInfo, {Size=UDim2.new(1.2, 0, 1.2, 0)})
    bagPopTween:Play();
    
    textTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    -- Make our text small now!
    clicks = 0;

    -- Reset our image position to the center of  the screen for later
    image.Position = UDim2.new(0.5, 0, 0.35, 0);
    image.Size = UDim2.new(0,0,0,0);

    bagPopTween.Completed:Wait();

    evolutionGui.Enabled = false;
end

local function Grow()
    connect:Disconnect(); -- Disconnect so that we can't click until we've finished animating. :)
    local tweenInfo = TweenInfo.new(speed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(image, tweenInfo, { Rotation=20 })
    image.Tap1:Play();
    tween:Play()
    tween.Completed:Wait();
    tween = TweenService:Create(image, tweenInfo, { Rotation=0 })
    tween:Play()

    image.Size = UDim2.new(image.Size.X.Scale + 0.1, 0, image.Size.Y.Scale + 0.1, 0);
    
    clicks = clicks + 1;

    if(clicks == 5) then
        -- Once we reach 5 clicks, we can transition it to the next pet!
        Transition();
    else
        connect = image.MouseButton1Click:Connect(Grow);
    end
end

function EvolutionGUI.Setup(data)
    evolutionGui.Enabled = true;
    
    local current = data.Current;
    local next = data.Next;

    nextPet = next;
    nextModelId = next.ItemData.ModelId;
    
    local frame = evolutionGui:WaitForChild("EvolveFrame");
    image = frame:WaitForChild("ImageLabel"):WaitForChild("Frame").Image;
    image.Image = "rbxthumb://type=Asset&id=" .. current.ItemData.ModelId .. "&w=420&h=420";

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    -- Make the image bigger so we can click it!
    local tween = TweenService:Create(image, tweenInfo, { Size=UDim2.new(0.5, 0, 0.5, 0) })
    tween:Play()
    tween.Completed:Wait();

    -- Clicking on the image to grow it
    connect = image.MouseButton1Click:Connect(Grow);
end


return EvolutionGUI;