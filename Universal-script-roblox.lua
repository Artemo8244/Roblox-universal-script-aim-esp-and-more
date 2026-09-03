local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Settings = {
    AimbotEnabled = false,
    AimbotMode = "Hold",
    AimbotKey = "MouseButton2",
    AimType = "Mouse",
    FOV = 150,
    Smoothness = 1.5,
    TargetPart = "Head",
    VisibleCheck = true,
    ShowFOV = true,
    CheckTeam = true,
    
    LegitBotEnabled = false,
    LegitBotMode = "Hold",
    LegitBotKey = "MouseButton2",
    LegitBotFOV = 80,
    LegitBotSmoothness = 0.3,
    LegitBotSpeed = 15,
    LegitBotVisibleCheck = true,
    LegitBotCheckTeam = true,
    
    SilentAimEnabled = false,
    SilentAimMode = "Hold",
    SilentAimKey = "MouseButton2",
    SilentAimHitChance = 100,
    
    FlyEnabled = false,
    FlySpeed = 30,
    NoclipEnabled = false,
    SpeedEnabled = false,
    SpeedValue = 32,
    InfJumpEnabled = false,
    AntiflingEnabled = false,
    JumpPowerEnabled = false,
    JumpPowerValue = 50,
    AutoJumpEnabled = false,
    SpinEnabled = false,
    SpinSpeed = 50,
    FullBrightEnabled = false,
    
    WallhackEnabled = false,
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local SilentTarget = nil
local AutoJumpConnection = nil
local SpinConnection = nil
local FullBrightConnection = nil
local OriginalBrightness = Lighting.Brightness
local OriginalAmbient = Lighting.Ambient
local OriginalOutdoorAmbient = Lighting.OutdoorAmbient

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

local function toggleAutoJump()
    if Settings.AutoJumpEnabled then
        if AutoJumpConnection then AutoJumpConnection:Disconnect() end
        AutoJumpConnection = RunService.RenderStepped:Connect(function()
            local hum = getHumanoid()
            if hum and hum.FloorMaterial ~= Enum.Material.Air then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if AutoJumpConnection then
            AutoJumpConnection:Disconnect()
            AutoJumpConnection = nil
        end
    end
end

local function toggleSpin()
    if Settings.SpinEnabled then
        if SpinConnection then SpinConnection:Disconnect() end
        SpinConnection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Settings.SpinSpeed) * 0.1, 0)
                end
            end
        end)
    else
        if SpinConnection then
            SpinConnection:Disconnect()
            SpinConnection = nil
        end
    end
end

local function toggleFullBright()
    if Settings.FullBrightEnabled then
        if FullBrightConnection then FullBrightConnection:Disconnect() end
        FullBrightConnection = RunService.RenderStepped:Connect(function()
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        end)
    else
        if FullBrightConnection then
            FullBrightConnection:Disconnect()
            FullBrightConnection = nil
        end
        Lighting.Brightness = OriginalBrightness
        Lighting.Ambient = OriginalAmbient
        Lighting.OutdoorAmbient = OriginalOutdoorAmbient
    end
end

local FOVCircle = nil
local LegitFOVCircle = nil

local function updateFOVCircle()
    if FOVCircle then FOVCircle:Remove() FOVCircle = nil end
    if LegitFOVCircle then LegitFOVCircle:Remove() LegitFOVCircle = nil end
    if not Drawing then return end
    if Settings.AimbotEnabled and Settings.ShowFOV then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 2
        FOVCircle.NumSides = 64
        FOVCircle.Radius = Settings.FOV
        FOVCircle.Color = Color3.fromRGB(255, 50, 50)
        FOVCircle.Filled = false
        FOVCircle.Visible = true
    end
    if Settings.LegitBotEnabled and Settings.ShowFOV then
        LegitFOVCircle = Drawing.new("Circle")
        LegitFOVCircle.Thickness = 2
        LegitFOVCircle.NumSides = 64
        LegitFOVCircle.Radius = Settings.LegitBotFOV
        LegitFOVCircle.Color = Color3.fromRGB(50, 255, 50)
        LegitFOVCircle.Filled = false
        LegitFOVCircle.Visible = true
    end
end

updateFOVCircle()

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function isTeammate(plr)
    if not Settings.CheckTeam then return false end
    if not LocalPlayer.Team or not plr.Team then return false end
    return LocalPlayer.Team == plr.Team
end

local function isLegitTeammate(plr)
    if not Settings.LegitBotCheckTeam then return false end
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

local function isLegitVisible(targetCharacter)
    if not Settings.LegitBotVisibleCheck then return true end
    local targetPart = targetCharacter:FindFirstChild(Settings.TargetPart)
    if not targetPart then return false end
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
    local camPos = Camera.CFrame.Position
    local raycastResult = workspace:Raycast(camPos, (targetPart.Position - camPos), raycastParams)
    return raycastResult == nil
end

local function getClosestPlayer(fov)
    fov = fov or Settings.FOV
    local closestPlayer = nil
    local shortestDistance = fov
    local mousePos = UserInputService:GetMouseLocation()
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        if isTeammate(player) then continue end
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        local targetPart = player.Character:FindFirstChild(Settings.TargetPart)
        if not targetPart then continue end
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if distance < shortestDistance and isVisible(player.Character) then
            shortestDistance = distance
            closestPlayer = player
        end
    end
    return closestPlayer
end

local function getLegitClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Settings.LegitBotFOV
    local mousePos = UserInputService:GetMouseLocation()
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        if isLegitTeammate(player) then continue end
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        local targetPart = player.Character:FindFirstChild(Settings.TargetPart)
        if not targetPart then continue end
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if distance < shortestDistance and isLegitVisible(player.Character) then
            shortestDistance = distance
            closestPlayer = player
        end
    end
    return closestPlayer
end

local function setupSilentAim()
    if not Settings.SilentAimEnabled then return end
    local mt = getrawmetatable and getrawmetatable(game) or debug.getmetatable(game)
    if not mt then return end
    local old_namecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod and getnamecallmethod() or "Unknown"
        if method == "Raycast" and self == workspace and Settings.SilentAimEnabled then
            if SilentTarget and SilentTarget.Character then
                local targetPart = SilentTarget.Character:FindFirstChild(Settings.TargetPart)
                if targetPart and math.random(1, 100) <= Settings.SilentAimHitChance then
                    args[2] = (targetPart.Position - args[1]).Unit * args[2].Magnitude
                    return old_namecall(self, unpack(args))
                end
            end
        end
        return old_namecall(self, ...)
    end)
    setreadonly(mt, true)
end

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

local flyConnection = nil
local flyBodyVelocity = nil

local function flyLoop(dt)
    if not Settings.FlyEnabled then return end
    local root = getRoot()
    if not root then return end
    if not flyBodyVelocity or flyBodyVelocity.Parent == nil then
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        flyBodyVelocity.Parent = root
    end
    local move = Vector3.new()
    local cam = Camera
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
    if move.Magnitude > 0 then
        flyBodyVelocity.Velocity = move.Unit * Settings.FlySpeed * 10
    else
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    end
    root.Velocity = Vector3.new(0, 0, 0)
end

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

local speedConnection = nil
local function speedLoop()
    if not Settings.SpeedEnabled then return end
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = Settings.SpeedValue end
end

local function resetSpeed()
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = 16 end
end

local jumpPowerConnection = nil
local originalJumpPower = 50

local function applyJumpPower()
    if not Settings.JumpPowerEnabled then return end
    local hum = getHumanoid()
    if hum then
        originalJumpPower = hum.JumpPower
        hum.JumpPower = Settings.JumpPowerValue
    end
end

local function resetJumpPower()
    local hum = getHumanoid()
    if hum then
        hum.JumpPower = originalJumpPower
    end
end

local infJumpConnection = nil
local function infJumpLoop()
    if not Settings.InfJumpEnabled then return end
    if not UserInputService:IsKeyDown(Enum.KeyCode.Space) then return end
    local hum = getHumanoid()
    if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

local antiflingConnection = nil
local function antiflingLoop()
    if not Settings.AntiflingEnabled then return end
    local root = getRoot()
    if root and root.Velocity.Magnitude > 100 then
        root.Velocity = Vector3.new(0, 0, 0)
    end
end

local function updateConnections()
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    if speedConnection then speedConnection:Disconnect() speedConnection = nil end
    if infJumpConnection then infJumpConnection:Disconnect() infJumpConnection = nil end
    if antiflingConnection then antiflingConnection:Disconnect() antiflingConnection = nil end
    if jumpPowerConnection then jumpPowerConnection:Disconnect() jumpPowerConnection = nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    if Settings.FlyEnabled then flyConnection = RunService.Heartbeat:Connect(flyLoop) end
    if Settings.NoclipEnabled then noclipConnection = RunService.RenderStepped:Connect(noclipLoop) end
    if Settings.SpeedEnabled then speedConnection = RunService.RenderStepped:Connect(speedLoop) else resetSpeed() end
    if Settings.JumpPowerEnabled then
        applyJumpPower()
        jumpPowerConnection = LocalPlayer.CharacterAdded:Connect(function() wait(0.5) applyJumpPower() end)
    else
        resetJumpPower()
    end
    if Settings.InfJumpEnabled then infJumpConnection = RunService.RenderStepped:Connect(infJumpLoop) end
    if Settings.AntiflingEnabled then antiflingConnection = RunService.RenderStepped:Connect(antiflingLoop) end
    if Settings.SilentAimEnabled then setupSilentAim() end
    toggleAutoJump()
    toggleSpin()
    toggleFullBright()
end

local function toggleFeature(name, state)
    if state == nil then state = not Settings[name] end
    Settings[name] = state
    if name == "WallhackEnabled" then
        updateAllWallhack()
    elseif name == "AimbotEnabled" or name == "LegitBotEnabled" or name == "ShowFOV" then
        updateFOVCircle()
    else
        updateConnections()
    end
end

local function isKeyPressed(key)
    if key == "MouseButton1" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif key == "MouseButton2" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    else
        return UserInputService:IsKeyDown(Enum.KeyCode[key])
    end
end

local aimbotToggled = false
local legitToggled = false
local silentToggled = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Settings.AimbotMode == "Toggle" then
        local key = Settings.AimbotKey
        local pressed = false
        if key == "MouseButton1" and input.UserInputType == Enum.UserInputType.MouseButton1 then pressed = true
        elseif key == "MouseButton2" and input.UserInputType == Enum.UserInputType.MouseButton2 then pressed = true
        elseif input.KeyCode == Enum.KeyCode[key] then pressed = true end
        if pressed then aimbotToggled = not aimbotToggled end
    end
    if Settings.LegitBotMode == "Toggle" then
        local key = Settings.LegitBotKey
        local pressed = false
        if key == "MouseButton1" and input.UserInputType == Enum.UserInputType.MouseButton1 then pressed = true
        elseif key == "MouseButton2" and input.UserInputType == Enum.UserInputType.MouseButton2 then pressed = true
        elseif input.KeyCode == Enum.KeyCode[key] then pressed = true end
        if pressed then legitToggled = not legitToggled end
    end
    if Settings.SilentAimMode == "Toggle" then
        local key = Settings.SilentAimKey
        local pressed = false
        if key == "MouseButton1" and input.UserInputType == Enum.UserInputType.MouseButton1 then pressed = true
        elseif key == "MouseButton2" and input.UserInputType == Enum.UserInputType.MouseButton2 then pressed = true
        elseif input.KeyCode == Enum.KeyCode[key] then pressed = true end
        if pressed then silentToggled = not silentToggled end
    end
end)

local Window = Rayfield:CreateWindow({
    Name = "DeepHub",
    LoadingTitle = "DeepHub загружается...",
    LoadingSubtitle = "By Artemo8244 & DeepSeek",
    Theme = "Amethyst",
    ToggleUIKeybind = Enum.KeyCode.RightControl,
})

local AimbotTab = Window:CreateTab("Aimbot", 0)
AimbotTab:CreateSection("Aimbot")
AimbotTab:CreateToggle({Name = "Aimbot", CurrentValue = Settings.AimbotEnabled, Flag = "AimbotEnabled", Callback = function(Value) Settings.AimbotEnabled = Value toggleFeature("AimbotEnabled", Value) end})
AimbotTab:CreateDropdown({Name = "Mode", Options = {"Hold", "Toggle"}, CurrentOption = Settings.AimbotMode, Flag = "AimbotMode", Callback = function(Option) Settings.AimbotMode = Option end})
AimbotTab:CreateDropdown({Name = "Key", Options = {"MouseButton1", "MouseButton2", "LeftControl", "LeftShift", "Q", "E", "R", "T", "F", "G", "V", "X", "C"}, CurrentOption = Settings.AimbotKey, Flag = "AimbotKey", Callback = function(Option) Settings.AimbotKey = Option end})
AimbotTab:CreateDropdown({Name = "Aim Type", Options = {"Mouse", "Camera"}, CurrentOption = Settings.AimType, Flag = "AimType", Callback = function(Option) Settings.AimType = Option end})
AimbotTab:CreateSlider({Name = "FOV", Range = {10, 360}, Increment = 1, Suffix = "°", CurrentValue = Settings.FOV, Flag = "FOV", Callback = function(Value) Settings.FOV = Value updateFOVCircle() end})
AimbotTab:CreateSlider({Name = "Smoothness", Range = {0, 10}, Increment = 0.1, Suffix = "", CurrentValue = Settings.Smoothness, Flag = "Smoothness", Callback = function(Value) Settings.Smoothness = Value end})
AimbotTab:CreateToggle({Name = "Show FOV", CurrentValue = Settings.ShowFOV, Flag = "ShowFOV", Callback = function(Value) Settings.ShowFOV = Value updateFOVCircle() end})
AimbotTab:CreateToggle({Name = "Visible Check", CurrentValue = Settings.VisibleCheck, Flag = "VisibleCheck", Callback = function(Value) Settings.VisibleCheck = Value end})
AimbotTab:CreateToggle({Name = "Check Team", CurrentValue = Settings.CheckTeam, Flag = "CheckTeam", Callback = function(Value) Settings.CheckTeam = Value end})

AimbotTab:CreateSection("Legit")
AimbotTab:CreateToggle({Name = "Legit", CurrentValue = Settings.LegitBotEnabled, Flag = "LegitBotEnabled", Callback = function(Value) Settings.LegitBotEnabled = Value toggleFeature("LegitBotEnabled", Value) end})
AimbotTab:CreateDropdown({Name = "Mode", Options = {"Hold", "Toggle"}, CurrentOption = Settings.LegitBotMode, Flag = "LegitBotMode", Callback = function(Option) Settings.LegitBotMode = Option end})
AimbotTab:CreateDropdown({Name = "Key", Options = {"MouseButton1", "MouseButton2", "LeftControl", "LeftShift", "Q", "E", "R", "T", "F", "G", "V", "X", "C"}, CurrentOption = Settings.LegitBotKey, Flag = "LegitBotKey", Callback = function(Option) Settings.LegitBotKey = Option end})
AimbotTab:CreateSlider({Name = "FOV", Range = {10, 180}, Increment = 1, Suffix = "°", CurrentValue = Settings.LegitBotFOV, Flag = "LegitBotFOV", Callback = function(Value) Settings.LegitBotFOV = Value updateFOVCircle() end})
AimbotTab:CreateSlider({Name = "Smoothness", Range = {0, 1}, Increment = 0.05, Suffix = "", CurrentValue = Settings.LegitBotSmoothness, Flag = "LegitBotSmoothness", Callback = function(Value) Settings.LegitBotSmoothness = Value end})
AimbotTab:CreateSlider({Name = "Speed", Range = {1, 50}, Increment = 1, Suffix = "", CurrentValue = Settings.LegitBotSpeed, Flag = "LegitBotSpeed", Callback = function(Value) Settings.LegitBotSpeed = Value end})
AimbotTab:CreateToggle({Name = "Visible Check", CurrentValue = Settings.LegitBotVisibleCheck, Flag = "LegitBotVisibleCheck", Callback = function(Value) Settings.LegitBotVisibleCheck = Value end})
AimbotTab:CreateToggle({Name = "Check Team", CurrentValue = Settings.LegitBotCheckTeam, Flag = "LegitBotCheckTeam", Callback = function(Value) Settings.LegitBotCheckTeam = Value end})

AimbotTab:CreateSection("Silent Aim")
AimbotTab:CreateToggle({Name = "Silent Aim", CurrentValue = Settings.SilentAimEnabled, Flag = "SilentAimEnabled", Callback = function(Value) Settings.SilentAimEnabled = Value toggleFeature("SilentAimEnabled", Value) end})
AimbotTab:CreateDropdown({Name = "Mode", Options = {"Hold", "Toggle"}, CurrentOption = Settings.SilentAimMode, Flag = "SilentAimMode", Callback = function(Option) Settings.SilentAimMode = Option end})
AimbotTab:CreateDropdown({Name = "Key", Options = {"MouseButton1", "MouseButton2", "LeftControl", "LeftShift", "Q", "E", "R", "T", "F", "G", "V", "X", "C"}, CurrentOption = Settings.SilentAimKey, Flag = "SilentAimKey", Callback = function(Option) Settings.SilentAimKey = Option end})
AimbotTab:CreateSlider({Name = "Hit Chance", Range = {0, 100}, Increment = 1, Suffix = "%", CurrentValue = Settings.SilentAimHitChance, Flag = "SilentAimHitChance", Callback = function(Value) Settings.SilentAimHitChance = Value end})

local ESPTab = Window:CreateTab("ESP", 1)
ESPTab:CreateSection("ESP")
ESPTab:CreateToggle({Name = "Wallhack", CurrentValue = Settings.WallhackEnabled, Flag = "WallhackEnabled", Callback = function(Value) Settings.WallhackEnabled = Value toggleFeature("WallhackEnabled", Value) end})

local MovementTab = Window:CreateTab("Movement", 2)
MovementTab:CreateSection("Movement")
MovementTab:CreateToggle({Name = "Fly", CurrentValue = Settings.FlyEnabled, Flag = "FlyEnabled", Callback = function(Value) Settings.FlyEnabled = Value toggleFeature("FlyEnabled", Value) end})
MovementTab:CreateSlider({Name = "Fly Speed", Range = {1, 150}, Increment = 1, Suffix = "", CurrentValue = Settings.FlySpeed, Flag = "FlySpeed", Callback = function(Value) Settings.FlySpeed = Value end})
MovementTab:CreateToggle({Name = "Noclip", CurrentValue = Settings.NoclipEnabled, Flag = "NoclipEnabled", Callback = function(Value) Settings.NoclipEnabled = Value toggleFeature("NoclipEnabled", Value) end})
MovementTab:CreateToggle({Name = "Speed", CurrentValue = Settings.SpeedEnabled, Flag = "SpeedEnabled", Callback = function(Value) Settings.SpeedEnabled = Value toggleFeature("SpeedEnabled", Value) end})
MovementTab:CreateSlider({Name = "Speed Value", Range = {10, 100}, Increment = 1, Suffix = "", CurrentValue = Settings.SpeedValue, Flag = "SpeedValue", Callback = function(Value) Settings.SpeedValue = Value if Settings.SpeedEnabled then local hum = getHumanoid() if hum then hum.WalkSpeed = Value end end end})
MovementTab:CreateToggle({Name = "Jump Power", CurrentValue = Settings.JumpPowerEnabled, Flag = "JumpPowerEnabled", Callback = function(Value) Settings.JumpPowerEnabled = Value toggleFeature("JumpPowerEnabled", Value) end})
MovementTab:CreateSlider({Name = "Jump Power Value", Range = {20, 200}, Increment = 1, Suffix = "", CurrentValue = Settings.JumpPowerValue, Flag = "JumpPowerValue", Callback = function(Value) Settings.JumpPowerValue = Value if Settings.JumpPowerEnabled then local hum = getHumanoid() if hum then hum.JumpPower = Value end end end})
MovementTab:CreateToggle({Name = "Infinite Jump", CurrentValue = Settings.InfJumpEnabled, Flag = "InfJumpEnabled", Callback = function(Value) Settings.InfJumpEnabled = Value toggleFeature("InfJumpEnabled", Value) end})
MovementTab:CreateToggle({Name = "Antifling", CurrentValue = Settings.AntiflingEnabled, Flag = "AntiflingEnabled", Callback = function(Value) Settings.AntiflingEnabled = Value toggleFeature("AntiflingEnabled", Value) end})
MovementTab:CreateToggle({Name = "Auto Jump", CurrentValue = Settings.AutoJumpEnabled, Flag = "AutoJumpEnabled", Callback = function(Value) Settings.AutoJumpEnabled = Value toggleFeature("AutoJumpEnabled", Value) end})
MovementTab:CreateToggle({Name = "Spin", CurrentValue = Settings.SpinEnabled, Flag = "SpinEnabled", Callback = function(Value) Settings.SpinEnabled = Value toggleFeature("SpinEnabled", Value) end})
MovementTab:CreateSlider({Name = "Spin Speed", Range = {1, 100}, Increment = 1, Suffix = "", CurrentValue = Settings.SpinSpeed, Flag = "SpinSpeed", Callback = function(Value) Settings.SpinSpeed = Value if Settings.SpinEnabled then toggleSpin() end end})
MovementTab:CreateToggle({Name = "Full Bright", CurrentValue = Settings.FullBrightEnabled, Flag = "FullBrightEnabled", Callback = function(Value) Settings.FullBrightEnabled = Value toggleFeature("FullBrightEnabled", Value) end})

local InfoTab = Window:CreateTab("Info", 3)

local function getRecommendations()
    return [[
РЕКОМЕНДУЕМЫЕ НАСТРОЙКИ:

AIMBOT:
  • FOV: 120-200
  • Smoothness: 1.0-3.0

LEGIT:
  • FOV: 30-60
  • Smoothness: 0.2-0.4
  • Speed: 8-15

SILENT AIM:
  • Hit Chance: 85-100%

MOVEMENT:
  • Speed Value: 25-32 (не выше!)
  • Jump Power: 50-80
  • Spin Speed: 30-70
    
Discord: artemo8244
Telegram: artemo8244
Tiktok: artemo8244
Roblox: Artemo8244
]]
end

InfoTab:CreateParagraph({Title = "DeepHub", Content = getRecommendations()})

RunService.RenderStepped:Connect(function()
    if (Settings.AimbotEnabled or Settings.LegitBotEnabled) and Settings.ShowFOV then
        if not FOVCircle then updateFOVCircle() end
        if FOVCircle then
            local mousePos = UserInputService:GetMouseLocation()
            FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
            FOVCircle.Radius = Settings.FOV
            FOVCircle.Visible = Settings.AimbotEnabled
        end
        if LegitFOVCircle then
            local mousePos = UserInputService:GetMouseLocation()
            LegitFOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
            LegitFOVCircle.Radius = Settings.LegitBotFOV
            LegitFOVCircle.Visible = Settings.LegitBotEnabled
        end
    else
        if FOVCircle then FOVCircle:Remove() FOVCircle = nil end
        if LegitFOVCircle then LegitFOVCircle:Remove() LegitFOVCircle = nil end
    end

    SilentTarget = nil
    if Settings.SilentAimEnabled then
        local target = getLegitClosestPlayer()
        if target then SilentTarget = target end
    end

    if Settings.AimbotEnabled then
        local active = false
        if Settings.AimbotMode == "Hold" then
            active = isKeyPressed(Settings.AimbotKey)
        else
            active = aimbotToggled
        end
        if active then
            local target = getClosestPlayer(Settings.FOV)
            if target and target.Character and target.Character:FindFirstChild(Settings.TargetPart) then
                local part = target.Character[Settings.TargetPart]
                if Settings.AimType == "Mouse" then
                    if mousemoverel then
                        local mp = UserInputService:GetMouseLocation()
                        local sp = Camera:WorldToViewportPoint(part.Position)
                        mousemoverel((sp.X - mp.X) * (Settings.Smoothness / 10), (sp.Y - mp.Y) * (Settings.Smoothness / 10))
                    else
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                    end
                else
                    local cf = CFrame.new(Camera.CFrame.Position, part.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(cf, 1 - Settings.Smoothness / 10)
                end
            end
        end
    end
    
    if Settings.LegitBotEnabled then
        local active = false
        if Settings.LegitBotMode == "Hold" then
            active = isKeyPressed(Settings.LegitBotKey)
        else
            active = legitToggled
        end
        if active then
            local target = getLegitClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild(Settings.TargetPart) then
                local part = target.Character[Settings.TargetPart]
                local mp = UserInputService:GetMouseLocation()
                local sp = Camera:WorldToViewportPoint(part.Position)
                local dx = (sp.X - mp.X) * (Settings.LegitBotSpeed / 100)
                local dy = (sp.Y - mp.Y) * (Settings.LegitBotSpeed / 100)
                if Settings.AimType == "Mouse" then
                    if mousemoverel then
                        mousemoverel(dx, dy)
                    else
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                    end
                else
                    local cf = CFrame.new(Camera.CFrame.Position, part.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(cf, 1 - Settings.LegitBotSmoothness)
                end
            end
        end
    end
end)

print("DeepHub Loaded")
