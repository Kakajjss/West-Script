-- West Boost | Delta-safe + анимации (fix) + без ника + Remove
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

if not lp.Character then lp.CharacterAdded:Wait() end

-- === АНИМАЦИИ ===
local R15_IDS = {
    idle = "rbxassetid://507766388",
    walk = "rbxassetid://507777826",
    run  = "rbxassetid://507767714",
    jump = "rbxassetid://507765000",
    fall = "rbxassetid://507767968",
}
local R6_IDS = {
    idle = "rbxassetid://180435571",
    walk = "rbxassetid://180426354",
    run  = "rbxassetid://180426354",
    jump = "rbxassetid://125750702",
    fall = "rbxassetid://180436148",
}
-- ================

local gui = Instance.new("ScreenGui")
gui.Name = "WestBoost"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 215)
frame.Position = UDim2.new(0.5, -160, 0.5, -107)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
title.Text = "West Boost"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local box = Instance.new("TextBox")
box.Size = UDim2.new(1, -20, 0, 32)
box.Position = UDim2.new(0, 10, 0, 45)
box.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
box.TextColor3 = Color3.new(1,1,1)
box.PlaceholderText = "Введи ник Roblox..."
box.Text = ""
box.Font = Enum.Font.Gotham
box.TextSize = 14
box.Parent = frame
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -20, 0, 32)
btn.Position = UDim2.new(0, 10, 0, 85)
btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
btn.Text = "Spawn"
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.Parent = frame
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

local btnRemove = Instance.new("TextButton")
btnRemove.Size = UDim2.new(1, -20, 0, 32)
btnRemove.Position = UDim2.new(0, 10, 0, 125)
btnRemove.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btnRemove.Text = "Remove"
btnRemove.TextColor3 = Color3.new(1,1,1)
btnRemove.Font = Enum.Font.GothamBold
btnRemove.TextSize = 14
btnRemove.Parent = frame
Instance.new("UICorner", btnRemove).CornerRadius = UDim.new(0, 6)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 30)
status.Position = UDim2.new(0, 10, 0, 165)
status.BackgroundTransparency = 1
status.Text = ""
status.TextColor3 = Color3.fromRGB(255, 200, 80)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextWrapped = true
status.Parent = frame

local function log(msg)
    status.Text = msg
    print("[WestBoost]", msg)
end

local spawnedNPCs = {}

local function loadTrack(animator, id, priority)
    local anim = Instance.new("Animation")
    anim.AnimationId = id
    local ok, track = pcall(function()
        return animator:LoadAnimation(anim)
    end)
    if not ok or not track then return nil end
    track.Priority = priority
    track.Looped = true
    print("[WestBoost] track", id, "length:", track.Length)
    return track
end

btn.MouseButton1Click:Connect(function()
    local name = box.Text
    if name == "" then log("Введи ник!"); return end
    log("Ищу " .. name .. "...")

    local ok, uid = pcall(function()
        return Players:GetUserIdFromNameAsync(name)
    end)
    if not ok or not uid then log("Ник не найден или API заблокирован"); return end

    local ok2, desc = pcall(function()
        return Players:GetHumanoidDescriptionFromUserIdAsync(uid)
    end)
    if not ok2 or not desc then log("Не удалось получить внешность"); return end

    -- Определяем, какой риг у игрока — чтобы правильно подобрать анимации
    local okRig, userRig = pcall(function()
        return Players:GetHumanoidDescriptionFromUserIdAsync(uid)
    end)
    -- Try to figure out rig type from description
    local isR15 = true
    if userRig then
        -- If user has R15-only body parts, it's R15
        -- Fallback: assume R15
        isR15 = true
    end

    local ok3, npc = pcall(function()
        return Players:CreateHumanoidModelFromDescriptionAsync(desc, Enum.HumanoidRigType.R15)
    end)
    if not ok3 or not npc then log("Не удалось создать модель"); return end

    local char = lp.Character or lp.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 5)
    if not root then log("Нет персонажа"); return end

    local hum = npc:FindFirstChildOfClass("Humanoid")
    if not hum then log("У модели нет Humanoid"); return end

    -- Убираем ник и полоску
    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    hum.HealthDisplayDistance = 0
    hum.NameDisplayDistance = 0

    -- Ставим позицию ДО парента, чтобы при загрузке модель сразу была в нужном месте
    npc.Name = name .. "_NPC"
    npc:PivotTo(root.CFrame * CFrame.new(0, 0, -5))

    -- ВАЖНО: сначала в workspace, потом Animator и анимации
    npc.Parent = workspace
    table.insert(spawnedNPCs, npc)

    -- Даём движку кадр на инициализацию Animator
    task.wait(0.15)

    -- Проверяем, R15 или R6
    local isR15Real = npc:FindFirstChild("UpperTorso") ~= nil
    local ids = isR15Real and R15_IDS or R6_IDS
    print("[WestBoost] rig:", isR15Real and "R15" or "R6")

    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end

    -- Убираем старый Animate, если он есть — он может конфликтовать
    local oldAnimate = npc:FindFirstChild("Animate")
    if oldAnimate then oldAnimate:Destroy() end

    local idleTrack = loadTrack(animator, ids.idle, Enum.AnimationPriority.Idle)
    local walkTrack = loadTrack(animator, ids.walk, Enum.AnimationPriority.Movement)
    local runTrack  = loadTrack(animator, ids.run,  Enum.AnimationPriority.Movement)
    local jumpTrack = loadTrack(animator, ids.jump, Enum.AnimationPriority.Action)
    local fallTrack = loadTrack(animator, ids.fall, Enum.AnimationPriority.Action)

    if not idleTrack or idleTrack.Length == 0 then
        log("Анимации не загрузились. Игра может блокировать.")
        return
    end

    -- Играем idle
    idleTrack:Play(0.1)

    -- Отслеживаем состояние через Heartbeat (надёжнее, чем hum.Running)
    local current = "idle"
    local function setState(s)
        if s == current then return end
        current = s
        if s == "idle" then
            walkTrack:Stop(0.12); runTrack:Stop(0.12); jumpTrack:Stop(0.12); fallTrack:Stop(0.12)
            idleTrack:Play(0.12)
        elseif s == "walk" then
            idleTrack:Stop(0.12); runTrack:Stop(0.12); jumpTrack:Stop(0.12); fallTrack:Stop(0.12)
            walkTrack:Play(0.12)
        elseif s == "run" then
            idleTrack:Stop(0.12); walkTrack:Stop(0.12); jumpTrack:Stop(0.12); fallTrack:Stop(0.12)
            runTrack:Play(0.12)
        elseif s == "jump" then
            jumpTrack:Play(0.1)
        elseif s == "fall" then
            fallTrack:Play(0.1)
        end
    end

    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not npc.Parent or not hum.Parent then
            if conn then conn:Disconnect() end
            return
        end
        local hs = hum:GetState()
        local vel = hum.RootPart and hum.RootPart.Velocity.Magnitude or 0

        if hs == Enum.HumanoidStateType.Jumping then
            setState("jump")
        elseif hs == Enum.HumanoidStateType.Freefall then
            setState("fall")
        elseif hs == Enum.HumanoidStateType.Landed then
            setState("idle")
        elseif vel > 12 then
            setState("run")
            if runTrack.IsPlaying then
                runTrack:AdjustSpeed(math.clamp(vel / 16, 0.8, 1.4))
            end
        elseif vel > 0.4 then
            setState("walk")
            if walkTrack.IsPlaying then
                walkTrack:AdjustSpeed(math.clamp(vel / 8, 0.75, 1.3))
            end
        else
            setState("idle")
        end
    end)

    log("NPC заспавнен!")

    task.spawn(function()
        while npc.Parent do
            hum:MoveTo(root.Position + Vector3.new(math.random(-15,15),0,math.random(-15,15)))
            task.wait(math.random(3,6))
        end
    end)

    task.spawn(function()
        while npc.Parent do
            task.wait(10)
            if hum.Parent then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end)

btnRemove.MouseButton1Click:Connect(function()
    if #spawnedNPCs == 0 then log("Сначала кого-нибудь заспавни!"); return end
    local count = 0
    for _, npc in ipairs(spawnedNPCs) do
        if npc and npc.Parent then
            npc:Destroy()
            count = count + 1
        end
    end
    spawnedNPCs = {}
    log("Удалено NPC: " .. count)
end)
