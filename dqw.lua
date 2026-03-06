-- Combined FAST Anti-Leave + Anti-AFK + Auto J Spam
-- Starts everything instantly / very aggressively
-- Press INSERT = toggle auto J spam
-- Press J manually = instant heavy Esc spam to interrupt leave
-- Press O = full escape (only way out)

local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local VU = game:GetService("VirtualUser")

local plr = Players.LocalPlayer
local pgui = plr:WaitForChild("PlayerGui")

-- Settings (tuned for speed)
local AUTO_J_ENABLED = true          -- starts ON
local J_PRESS_INTERVAL = 0.06        -- very fast J spam
local ANTI_AFK_ENABLED = true
local INITIAL_FREEZE_TIME = 0.25     -- almost instant lock
local ESC_SPAM_COUNT_ON_J = 12       -- more aggressive when pressing J manually
local ESC_SPAM_DELAY = 0.0006        -- tighter timing

local isTrapped = false
local autoJRunning = AUTO_J_ENABLED
local shiftSpamActive = false
local blockConn, shiftConn, clickConn = nil, nil, nil
local oldWS, oldJP = 16, 50

-- ────────────────────────────────────────
--               ANTI-AFK (instant)
-- ────────────────────────────────────────
if ANTI_AFK_ENABLED then
    print("[FAST] Anti-AFK → ACTIVE")
    
    -- Classic VirtualUser anti-idle
    plr.Idled:Connect(function()
        VU:CaptureController()
        VU:ClickButton2(Vector2.new())
    end)
    
    -- Fast backup movement simulation (~every 3 min)
    task.spawn(function()
        while ANTI_AFK_ENABLED do
            task.wait(180)
            VIM:SendKeyEvent(true, Enum.KeyCode.W, false, game)
            task.wait(0.02)
            VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            print("[Anti-AFK] Tiny W pulse")
        end
    end)
end

-- ────────────────────────────────────────
--        AUTO J SPAM (toggle with INSERT)
-- ────────────────────────────────────────
task.spawn(function()
    while true do
        task.wait(J_PRESS_INTERVAL)
        if autoJRunning then
            VIM:SendKeyEvent(true, Enum.KeyCode.J, false, game)
            task.wait(0.03)
            VIM:SendKeyEvent(false, Enum.KeyCode.J, false, game)
        end
    end
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        autoJRunning = not autoJRunning
        print("[AUTO J] " .. (autoJRunning and "ON" or "OFF"))
    end
end)

-- ────────────────────────────────────────
--           TRAP / ANTI-LEAVE LOGIC
-- ────────────────────────────────────────
local function trapPlayer()
    if isTrapped then return end
    isTrapped = true
    
    -- Black screen overlay
    local gui = Instance.new("ScreenGui", pgui)
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 9999
    
    local black = Instance.new("Frame", gui)
    black.Size = UDim2.new(1,0,1,0)
    black.BackgroundColor3 = Color3.new(0,0,0)
    black.BackgroundTransparency = 0
    
    -- Freeze character
    local char = plr.Character
    if char then
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            oldWS = hum.WalkSpeed
            oldJP = hum.JumpPower
            hum.WalkSpeed = 0
            hum.JumpPower = 0
        end
    end
    
    -- Hard lock movement
    RS:BindToRenderStep("HardLock", 2000, function()
        if not isTrapped then return end
        local hum = plr.Character and plr.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum.WalkSpeed = 0
            hum.JumpPower = 0
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        end
    end)
    
    -- Insane left-click spam at weird position
    clickConn = RS.Heartbeat:Connect(function()
        if not isTrapped then return end
        VIM:SendMouseButtonEvent(40, -25, 0, true, game)
        VIM:SendMouseButtonEvent(40, -25, 0, false, game)
    end)
    
    -- Block most inputs + Esc interrupt + Shift toggle
    blockConn = UIS.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.O then
            -- Full escape only with O
            return
        end
        
        if input.KeyCode == Enum.KeyCode.P then
            shiftSpamActive = not shiftSpamActive
            if shiftSpamActive then
                shiftConn = RS.Heartbeat:Connect(function()
                    if not isTrapped or not shiftSpamActive then return end
                    UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
                    task.wait(0.04 + math.random()*0.06)
                    UIS.MouseBehavior = Enum.MouseBehavior.Default
                    task.wait(0.03 + math.random()*0.05)
                end)
            else
                if shiftConn then shiftConn:Disconnect() shiftConn = nil end
                UIS.MouseBehavior = Enum.MouseBehavior.Default
            end
            return
        end
        
        if input.KeyCode == Enum.KeyCode.J then
            -- Aggressive Esc spam when J pressed manually
            for i = 1, ESC_SPAM_COUNT_ON_J do
                task.spawn(function()
                    task.wait(i * ESC_SPAM_DELAY)
                    VIM:SendKeyEvent(true, Enum.KeyCode.Escape, false, game)
                    task.wait(0.0003)
                    VIM:SendKeyEvent(false, Enum.KeyCode.Escape, false, game)
                end)
            end
            return
        end
        
        -- Catch Esc and re-press it instantly (interrupt leave)
        if input.KeyCode == Enum.KeyCode.Escape then
            task.delay(0.00001, function()
                VIM:SendKeyEvent(true, Enum.KeyCode.Escape, false, game)
                task.delay(0.00001, function()
                    VIM:SendKeyEvent(false, Enum.KeyCode.Escape, false, game)
                end)
            end)
        end
    end)
end

local function untrapPlayer()
    if not isTrapped then return end
    isTrapped = false
    
    if blockConn then blockConn:Disconnect() end
    if shiftConn then shiftConn:Disconnect() end
    if clickConn then clickConn:Disconnect() end
    RS:UnbindFromRenderStep("HardLock")
    
    local gui = pgui:FindFirstChildWhichIsA("ScreenGui") -- crude but works
    if gui then gui:Destroy() end
    
    local char = plr.Character
    if char then
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum.WalkSpeed = oldWS
            hum.JumpPower = oldJP
        end
    end
    
    UIS.MouseBehavior = Enum.MouseBehavior.Default
end

-- ────────────────────────────────────────
--          START SEQUENCE (very fast)
-- ────────────────────────────────────────
-- Auto trigger J once instantly to activate anti-leave logic
task.spawn(function()
    task.wait(0.08) -- tiny wait for input system
    VIM:SendKeyEvent(true, Enum.KeyCode.J, false, game)
    task.wait(0.025)
    VIM:SendKeyEvent(false, Enum.KeyCode.J, false, game)
end)

-- Lock player almost instantly
task.delay(INITIAL_FREEZE_TIME, trapPlayer)

-- O = escape
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.O then
        untrapPlayer()
        print("[ESCAPE] Player freed with O")
    end
end)

print("FAST TRAP LOADED")
print("→ Auto J spamming @ " .. J_PRESS_INTERVAL .. "s")
print("→ Anti-AFK running")
print("→ Trap active almost instantly")
print("→ J = heavy Esc spam | O = escape | INSERT = toggle J | P = shift spam")
