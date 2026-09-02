local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Settings = {
    AimbotEnabled = false,
    AimbotMode = "Hold",
    AimbotKey = "MouseButton2",
    AimType = "Mouse",
    FOV = 150,
    Smoothness = 0.5,
    WallhackEnabled = false,
    TargetPart = "Head",
    VisibleCheck = true,
    ShowFOV = true,
    FlyEnabled = false,
    FlySpeed = 30,
    NoclipEnabled = false,
    SpeedEnabled = false,
    SpeedValue = 32,
    InfJumpEnabled = false,
    AntiflingEnabled = false,
    CheckTeam = true,
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- === ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ===
local function getRoot()
    local char = LocalPlayer.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    end
    return nil
end

local function getHumanoid()
    local char = LocalPlayer.Character
    if char then return char:FindFirstChildOfClass("Humanoid") end
    return nil
end

-- === FOV CIRCLE ===
local FOVCircle = nil
local function createFOVCircle()
    if FOVCircle then FOVCircle:Remove() end
    if not Drawing then return end
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 64
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Filled = false
    FOVCircle.Visible = Settings.ShowFOV
end
createFOVCircle()

-- === RAYCAST ===
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function isTeammate(plr)
    if not Settings.CheckTeam then return false end
    if not LocalPlayer.Team or not plr.Team then return false end
    return LocalPlayer.Team == plr.Team
end

local function getTeamColor(plr)
    if not plr.Team then return Color3.fromRGB(255, 255, 255) end
    return plr.Team.TeamColor.Color
end

local function isVisible(targetCharacter)
    if not Settings.VisibleCheck then return true end
    local targetPart = targetCharacter:FindFirstChild(Settings.TargetPart)
    if not targetPart then return false end
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
    local camPos = Camera.CFrame.Position
    local raycastResult = workspace:Raycast(camPos, (targetPart.Position - camPos), raycastParams)
    return raycastResult == nil
end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Settings.FOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if isTeammate(player) then continue end
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            local targetPart = player.Character:FindFirstChild(Settings.TargetPart)
            if not targetPart then continue end
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if distance < shortestDistance and isVisible(player.Character) then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- === WALLHACK ===
local wallhackObjects = {}
local function applyWallhack(player)
    if player == LocalPlayer then return end
    local function setup(char)
        if not char then return end
        char:WaitForChild("HumanoidRootPart", 5)
        char:WaitForChild("Humanoid", 5)
        
        if wallhackObjects[player] then
            for _, obj in pairs(wallhackObjects[player]) do obj:Destroy() end
            wallhackObjects[player] = nil
        end
        
        if not Settings.WallhackEnabled then return end
        
        local objects = {}
        local teamColor = getTeamColor(player)
        
        local hl = Instance.new("Highlight")
        hl.Name = "WallhackHighlight"
        hl.FillColor = teamColor
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.3
        hl.OutlineTransparency = 0.1
        hl.Adornee = char
        hl.Parent = char
        table.insert(objects, hl)
        
        wallhackObjects[player] = objects
    end
    
    if player.Character then setup(player.Character) end
    player.CharacterAdded:Connect(setup)
end

for _, p in pairs(Players:GetPlayers()) do applyWallhack(p) end
Players.PlayerAdded:Connect(applyWallhack)

local function updateAllWallhack()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            if Settings.WallhackEnabled then applyWallhack(p)
            else
                if wallhackObjects[p] then
                    for _, obj in pairs(wallhackObjects[p]) do obj:Destroy() end
                    wallhackObjects[p] = nil
                end
            end
        end
    end
end

-- === FLY (РАБОЧАЯ ВЕРСИЯ) ===
local flyConnection = nil
local function flyLoop(dt)
    if not Settings.FlyEnabled then return end
    local root = getRoot()
    if not root then return end
    
    local move = Vector3.new()
    local cam = Camera
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
    
    if move.Magnitude > 0 then
        move = move.Unit * Settings.FlySpeed * dt * 60
        root.CFrame = root.CFrame + move
        root.Velocity = Vector3.new(0, 0, 0)
        root.RotVelocity = Vector3.new(0, 0, 0)
    end
end

-- === NOCLIP ===
local noclipConnection = nil
local function noclipLoop()
    if not Settings.NoclipEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- === SPEED ===
local speedConnection = nil
local function speedLoop()
    if not Settings.SpeedEnabled then return end
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = Settings.SpeedValue end
end

-- === INFINITE JUMP ===
local infJumpConnection = nil
local function infJumpLoop()
    if not Settings.InfJumpEnabled then return end
    if not UserInputService:IsKeyDown(Enum.KeyCode.Space) then return end
    local hum = getHumanoid()
    if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- === ANTIFLING ===
local antiflingConnection = nil
local function antiflingLoop()
    if not Settings.AntiflingEnabled then return end
    local root = getRoot()
    if root and root.Velocity.Magnitude > 100 then
        root.Velocity = Vector3.new(0, 0, 0)
    end
end

-- === ОБНОВЛЕНИЕ ПОДКЛЮЧЕНИЙ ===
local function updateConnections()
    -- Отключаем все старые
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    if speedConnection then speedConnection:Disconnect() speedConnection = nil end
    if infJumpConnection then infJumpConnection:Disconnect() infJumpConnection = nil end
    if antiflingConnection then antiflingConnection:Disconnect() antiflingConnection = nil end
    
    -- Подключаем новые
    if Settings.FlyEnabled then
        flyConnection = RunService.Heartbeat:Connect(flyLoop)
        print("FLY CONNECTED")
    end
    
    if Settings.NoclipEnabled then
        noclipConnection = RunService.RenderStepped:Connect(noclipLoop)
    end
    
    if Settings.SpeedEnabled then
        speedConnection = RunService.RenderStepped:Connect(speedLoop)
    end
    
    if Settings.InfJumpEnabled then
        infJumpConnection = RunService.RenderStepped:Connect(infJumpLoop)
    end
    
    if Settings.AntiflingEnabled then
        antiflingConnection = RunService.RenderStepped:Connect(antiflingLoop)
    end
end

-- === TOGGLE FEATURE ===
local function toggleFeature(name, state)
    if state == nil then state = not Settings[name] end
    Settings[name] = state
    
    if name == "WallhackEnabled" then
        updateAllWallhack()
    elseif name == "ShowFOV" then
        if FOVCircle then FOVCircle.Visible = Settings.ShowFOV end
    else
        updateConnections()
    end
end

-- === AIMBOT ===
local function isAimbotKeyPressed()
    local key = Settings.AimbotKey
    if key == "MouseButton1" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif key == "MouseButton2" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    else
        return UserInputService:IsKeyDown(Enum.KeyCode[key])
    end
end

local aimbotToggled = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Settings.AimbotMode == "Toggle" then
        local key = Settings.AimbotKey
        local pressed = false
        if key == "MouseButton1" and input.UserInputType == Enum.UserInputType.MouseButton1 then pressed = true
        elseif key == "MouseButton2" and input.UserInputType == Enum.UserInputType.MouseButton2 then pressed = true
        elseif input.KeyCode == Enum.KeyCode[key] then pressed = true end
        if pressed then
            aimbotToggled = not aimbotToggled
        end
    end
end)

-- === RAYFIELD GUI ===
local Window = Rayfield:CreateWindow({
    Name = "DeepHub",
    LoadingTitle = "DeepHub загружается...",
    LoadingSubtitle = "By Artemo8244 & DeepSeek",
    Theme = "Amethyst",
    ToggleUIKeybind = Enum.KeyCode.RightControl,
})

-- Aimbot Tab
local AimbotTab = Window:CreateTab("Aimbot", 0)
AimbotTab:CreateSection("Настройки аимбота")
AimbotTab:CreateToggle({Name = "Aimbot", CurrentValue = Settings.AimbotEnabled, Flag = "AimbotEnabled", Callback = function(Value) Settings.AimbotEnabled = Value end})
AimbotTab:CreateDropdown({Name = "Aimbot Mode", Options = {"Hold", "Toggle"}, CurrentOption = Settings.AimbotMode, Flag = "AimbotMode", Callback = function(Option) Settings.AimbotMode = Option end})
AimbotTab:CreateDropdown({Name = "Aimbot Key", Options = {"MouseButton1", "MouseButton2", "LeftControl", "LeftShift", "Q", "E", "R", "T", "F", "G", "V", "X", "C"}, CurrentOption = Settings.AimbotKey, Flag = "AimbotKey", Callback = function(Option) Settings.AimbotKey = Option end})
AimbotTab:CreateDropdown({Name = "Aim Type", Options = {"Mouse", "Camera"}, CurrentOption = Settings.AimType, Flag = "AimType", Callback = function(Option) Settings.AimType = Option end})
AimbotTab:CreateSlider({Name = "FOV", Range = {10, 360}, Increment = 1, Suffix = "°", CurrentValue = Settings.FOV, Flag = "FOV", Callback = function(Value) Settings.FOV = Value if FOVCircle then FOVCircle.Radius = Value end end})
AimbotTab:CreateSlider({Name = "Smoothness", Range = {0, 1}, Increment = 0.05, Suffix = "", CurrentValue = Settings.Smoothness, Flag = "Smoothness", Callback = function(Value) Settings.Smoothness = Value end})
AimbotTab:CreateToggle({Name = "Show FOV Circle", CurrentValue = Settings.ShowFOV, Flag = "ShowFOV", Callback = function(Value) Settings.ShowFOV = Value if FOVCircle then FOVCircle.Visible = Value end end})
AimbotTab:CreateToggle({Name = "Visible Check", CurrentValue = Settings.VisibleCheck, Flag = "VisibleCheck", Callback = function(Value) Settings.VisibleCheck = Value end})
AimbotTab:CreateToggle({Name = "Check Team", CurrentValue = Settings.CheckTeam, Flag = "CheckTeam", Callback = function(Value) Settings.CheckTeam = Value end})

-- ESP Tab
local ESPTab = Window:CreateTab("ESP", 1)
ESPTab:CreateSection("Настройки ESP")
ESPTab:CreateToggle({Name = "Wallhack (подсветка)", CurrentValue = Settings.WallhackEnabled, Flag = "WallhackEnabled", Callback = function(Value) Settings.WallhackEnabled = Value toggleFeature("WallhackEnabled", Value) end})

-- Movement Tab
local MovementTab = Window:CreateTab("Movement", 2)
MovementTab:CreateSection("Настройки движения")
MovementTab:CreateToggle({Name = "Fly", CurrentValue = Settings.FlyEnabled, Flag = "FlyEnabled", Callback = function(Value) 
    Settings.FlyEnabled = Value 
    toggleFeature("FlyEnabled", Value)
    print("FLY TOGGLED: " .. tostring(Value))
end})
MovementTab:CreateSlider({Name = "Fly Speed", Range = {1, 150}, Increment = 1, Suffix = " stud/s", CurrentValue = Settings.FlySpeed, Flag = "FlySpeed", Callback = function(Value) Settings.FlySpeed = Value end})
MovementTab:CreateToggle({Name = "Noclip", CurrentValue = Settings.NoclipEnabled, Flag = "NoclipEnabled", Callback = function(Value) Settings.NoclipEnabled = Value toggleFeature("NoclipEnabled", Value) end})
MovementTab:CreateToggle({Name = "Speed", CurrentValue = Settings.SpeedEnabled, Flag = "SpeedEnabled", Callback = function(Value) Settings.SpeedEnabled = Value toggleFeature("SpeedEnabled", Value) end})
MovementTab:CreateSlider({Name = "Speed Value", Range = {10, 100}, Increment = 1, Suffix = "", CurrentValue = Settings.SpeedValue, Flag = "SpeedValue", Callback = function(Value) Settings.SpeedValue = Value if Settings.SpeedEnabled then local hum = getHumanoid() if hum then hum.WalkSpeed = Value end end end})
MovementTab:CreateToggle({Name = "Infinite Jump", CurrentValue = Settings.InfJumpEnabled, Flag = "InfJumpEnabled", Callback = function(Value) Settings.InfJumpEnabled = Value toggleFeature("InfJumpEnabled", Value) end})
MovementTab:CreateToggle({Name = "Antifling", CurrentValue = Settings.AntiflingEnabled, Flag = "AntiflingEnabled", Callback = function(Value) Settings.AntiflingEnabled = Value toggleFeature("AntiflingEnabled", Value) end})

-- Info Tab
local InfoTab = Window:CreateTab("Info", 3)
InfoTab:CreateParagraph({Title = "DeepHub FULL FIX", Content = "By Artemo8244 & DeepSeek\n\nRightControl — скрыть/показать\nFly работает через Heartbeat\nSpeed регулируется плавно\nВсе функции стабильны"})

-- === ОСНОВНОЙ ЦИКЛ (Aimbot + FOV) ===
RunService.RenderStepped:Connect(function()
    if not FOVCircle then return end
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Visible = Settings.ShowFOV

    if Settings.AimbotEnabled then
        local aimActive = false
        if Settings.AimbotMode == "Hold" then
            aimActive = isAimbotKeyPressed()
        else
            aimActive = aimbotToggled
        end

        if aimActive then
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild(Settings.TargetPart) then
                local targetPart = target.Character[Settings.TargetPart]
                if Settings.AimType == "Mouse" then
                    if mousemoverel then
                        local screenPos = Camera:WorldToViewportPoint(targetPart.Position)
                        local sens = 10
                        local dx = (screenPos.X - mousePos.X) * sens / 100
                        local dy = (screenPos.Y - mousePos.Y) * sens / 100
                        mousemoverel(dx, dy)
                    else
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                    end
                else
                    local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 - Settings.Smoothness)
                end
            end
        end
    end
end)

print("DeepHub FULL FIX загружен! Fly 100% работает.")
