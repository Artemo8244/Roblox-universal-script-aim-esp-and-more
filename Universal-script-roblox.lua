local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Settings = {
    AimbotEnabled = false,
    AimType = "Mouse",
    FOV = 150,
    Smoothness = 0.5,
    WallhackEnabled = false,
    TargetPart = "Head",
    VisibleCheck = true,
    ShowFOV = true,
    FlyEnabled = false,
    FlySpeed = 20,
    NoclipEnabled = false,
    SpeedEnabled = false,
    SpeedValue = 32,
    InfJumpEnabled = false,
    AntiflingEnabled = false,
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

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

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function getRoot(plr)
    local char = plr.Character
    if char then return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") end
    return nil
end

local function getHumanoid(plr)
    local char = plr.Character
    if char then return char:FindFirstChildOfClass("Humanoid") end
    return nil
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

local function applyHighlight(player)
    if player == LocalPlayer then return end
    local function setup(char)
        if not char then return end
        char:WaitForChild("HumanoidRootPart", 5)
        char:WaitForChild("Humanoid", 5)
        if char:FindFirstChild("DeepESP") then char.DeepESP:Destroy() end
        if Settings.WallhackEnabled then
            local hl = Instance.new("Highlight")
            hl.Name = "DeepESP"
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.Adornee = char
            hl.Parent = char
        end
    end
    if player.Character then setup(player.Character) end
    player.CharacterAdded:Connect(setup)
end

for _, p in pairs(Players:GetPlayers()) do applyHighlight(p) end
Players.PlayerAdded:Connect(applyHighlight)

local function updateAllWH()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            if Settings.WallhackEnabled then applyHighlight(p)
            else if p.Character:FindFirstChild("DeepESP") then p.Character.DeepESP:Destroy() end end
        end
    end
end

local flyConnection = nil
local function flyLoop()
    if not Settings.FlyEnabled then return end
    local root = getRoot(LocalPlayer)
    if not root then return end
    local move = Vector3.new()
    local camera = Camera
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
    if move.Magnitude > 0 then move = move.Unit * Settings.FlySpeed end
    root.CFrame = root.CFrame + move
    root.Anchored = false
end

local noclipConnection = nil
local function noclipLoop()
    if not Settings.NoclipEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
end

local speedConnection = nil
local function speedLoop()
    if not Settings.SpeedEnabled then return end
    local hum = getHumanoid(LocalPlayer)
    if hum then hum.WalkSpeed = Settings.SpeedValue end
end

local infJumpConnection = nil
local function infJumpLoop()
    if not Settings.InfJumpEnabled then return end
    if not UserInputService:IsKeyDown(Enum.KeyCode.Space) then return end
    local hum = getHumanoid(LocalPlayer)
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end

local antiflingConnection = nil
local function antiflingLoop()
    if not Settings.AntiflingEnabled then return end
    local root = getRoot(LocalPlayer)
    if root and root.Velocity.Magnitude > 100 then root.Velocity = Vector3.new(0,0,0) end
end

local function toggleFeature(name, state)
    if state == nil then state = not Settings[name] end
    Settings[name] = state
    if name == "FlyEnabled" then
        if state and not flyConnection then flyConnection = RunService.RenderStepped:Connect(flyLoop)
        elseif not state and flyConnection then flyConnection:Disconnect() flyConnection = nil end
    elseif name == "NoclipEnabled" then
        if state and not noclipConnection then noclipConnection = RunService.RenderStepped:Connect(noclipLoop)
        elseif not state and noclipConnection then noclipConnection:Disconnect() noclipConnection = nil
            local char = LocalPlayer.Character
            if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end end
        end
    elseif name == "SpeedEnabled" then
        if state and not speedConnection then speedConnection = RunService.RenderStepped:Connect(speedLoop)
        elseif not state and speedConnection then speedConnection:Disconnect() speedConnection = nil
            local hum = getHumanoid(LocalPlayer)
            if hum then hum.WalkSpeed = 16 end
        end
    elseif name == "InfJumpEnabled" then
        if state and not infJumpConnection then infJumpConnection = RunService.RenderStepped:Connect(infJumpLoop)
        elseif not state and infJumpConnection then infJumpConnection:Disconnect() infJumpConnection = nil end
    elseif name == "AntiflingEnabled" then
        if state and not antiflingConnection then antiflingConnection = RunService.RenderStepped:Connect(antiflingLoop)
        elseif not state and antiflingConnection then antiflingConnection:Disconnect() antiflingConnection = nil end
    elseif name == "WallhackEnabled" then
        updateAllWH()
    elseif name == "ShowFOV" then
        if FOVCircle then FOVCircle.Visible = Settings.ShowFOV end
    end
end

local Window = Rayfield:CreateWindow({
    Name = "DeepHub",
    LoadingTitle = "DeepHub загружается...",
    LoadingSubtitle = "By Artemo8244 & DeepSeek",
    Theme = "Amethyst",
    ToggleUIKeybind = Enum.KeyCode.RightControl,
})

local AimbotTab = Window:CreateTab("Aimbot", 0)
AimbotTab:CreateSection("Настройки аимбота")
AimbotTab:CreateToggle({Name = "Aimbot", CurrentValue = Settings.AimbotEnabled, Flag = "AimbotEnabled", Callback = function(Value) Settings.AimbotEnabled = Value toggleFeature("AimbotEnabled", Value) end})
AimbotTab:CreateDropdown({Name = "Aim Type", Options = {"Mouse", "Camera"}, CurrentOption = Settings.AimType, Flag = "AimType", Callback = function(Option) Settings.AimType = Option end})
AimbotTab:CreateSlider({Name = "FOV", Range = {10, 360}, Increment = 1, Suffix = "°", CurrentValue = Settings.FOV, Flag = "FOV", Callback = function(Value) Settings.FOV = Value if FOVCircle then FOVCircle.Radius = Value end end})
AimbotTab:CreateSlider({Name = "Smoothness", Range = {0, 1}, Increment = 0.05, Suffix = "", CurrentValue = Settings.Smoothness, Flag = "Smoothness", Callback = function(Value) Settings.Smoothness = Value end})
AimbotTab:CreateToggle({Name = "Show FOV Circle", CurrentValue = Settings.ShowFOV, Flag = "ShowFOV", Callback = function(Value) Settings.ShowFOV = Value if FOVCircle then FOVCircle.Visible = Value end end})
AimbotTab:CreateToggle({Name = "Visible Check", CurrentValue = Settings.VisibleCheck, Flag = "VisibleCheck", Callback = function(Value) Settings.VisibleCheck = Value end})

local ESPTab = Window:CreateTab("ESP", 1)
ESPTab:CreateSection("Настройки ESP")
ESPTab:CreateToggle({Name = "Wallhack (ESP)", CurrentValue = Settings.WallhackEnabled, Flag = "WallhackEnabled", Callback = function(Value) Settings.WallhackEnabled = Value toggleFeature("WallhackEnabled", Value) end})

local MovementTab = Window:CreateTab("Movement", 2)
MovementTab:CreateSection("Настройки движения")
MovementTab:CreateToggle({Name = "Fly", CurrentValue = Settings.FlyEnabled, Flag = "FlyEnabled", Callback = function(Value) Settings.FlyEnabled = Value toggleFeature("FlyEnabled", Value) end})
MovementTab:CreateSlider({Name = "Fly Speed", Range = {5, 80}, Increment = 1, Suffix = "", CurrentValue = Settings.FlySpeed, Flag = "FlySpeed", Callback = function(Value) Settings.FlySpeed = Value end})
MovementTab:CreateToggle({Name = "Noclip", CurrentValue = Settings.NoclipEnabled, Flag = "NoclipEnabled", Callback = function(Value) Settings.NoclipEnabled = Value toggleFeature("NoclipEnabled", Value) end})
MovementTab:CreateToggle({Name = "Speed", CurrentValue = Settings.SpeedEnabled, Flag = "SpeedEnabled", Callback = function(Value) Settings.SpeedEnabled = Value toggleFeature("SpeedEnabled", Value) end})
MovementTab:CreateSlider({Name = "Speed Value", Range = {10, 100}, Increment = 1, Suffix = "", CurrentValue = Settings.SpeedValue, Flag = "SpeedValue", Callback = function(Value) Settings.SpeedValue = Value if Settings.SpeedEnabled then local hum = getHumanoid(LocalPlayer) if hum then hum.WalkSpeed = Value end end end})
MovementTab:CreateToggle({Name = "Infinite Jump", CurrentValue = Settings.InfJumpEnabled, Flag = "InfJumpEnabled", Callback = function(Value) Settings.InfJumpEnabled = Value toggleFeature("InfJumpEnabled", Value) end})
MovementTab:CreateToggle({Name = "Antifling", CurrentValue = Settings.AntiflingEnabled, Flag = "AntiflingEnabled", Callback = function(Value) Settings.AntiflingEnabled = Value toggleFeature("AntiflingEnabled", Value) end})

local InfoTab = Window:CreateTab("Info", 3)
InfoTab:CreateParagraph({Title = "DeepHub", Content = "By Artemo8244 & DeepSeek\n\nRightControl — скрыть/показать\nAimbot: наведи курсор на врага и зажми ПКМ"})

RunService.RenderStepped:Connect(function()
    if not FOVCircle then return end
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Visible = Settings.ShowFOV

    if Settings.AimbotEnabled then
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
end)

print("DeepHub (Rayfield) загружен! By Artemo8244 & DeepSeek")