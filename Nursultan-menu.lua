-- Roblox Luau Script: DeepHub Fully Working
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CUSTOM_LOGO_ID = "rbxassetid://139568612294283"

-- ============================================================================
-- 1. SETTINGS & CORE LOGIC
-- ============================================================================
local Settings = {
    AimbotEnabled = false, AimbotMode = "Hold", AimbotKey = "MouseButton2", AimType = "Mouse",
    FOV = 150, Smoothness = 1.5, TargetPart = "Head", VisibleCheck = true, ShowFOV = true, CheckTeam = true,
    LegitBotEnabled = false, LegitBotMode = "Hold", LegitBotKey = "MouseButton2", LegitBotFOV = 80,
    LegitBotSmoothness = 0.3, LegitBotSpeed = 15, LegitBotVisibleCheck = true, LegitBotCheckTeam = true,
    SilentAimEnabled = false, SilentAimFOV = 150, SilentAimHitChance = 100, SilentAimVisibleCheck = true,
    SilentAimCheckTeam = true, SilentAimShowFOV = true,
    TriggerBotEnabled = false, TriggerBotDelay = 50, TriggerBotVisibleCheck = true, TriggerBotCheckTeam = true,
    FlyEnabled = false, FlySpeed = 30, NoclipEnabled = false, SpeedEnabled = false, SpeedValue = 32,
    InfJumpEnabled = false, AntiflingEnabled = false, JumpPowerEnabled = false, JumpPowerValue = 50,
    AutoJumpEnabled = false, SpinEnabled = false, SpinSpeed = 50, FullBrightEnabled = false,
    ESPEnabled = false, TracersEnabled = false, ChamsEnabled = false, ESPIgnoreWalls = false,
    NPCESPEnabled = false, NPCTracersEnabled = false, NPCChamsEnabled = false,
    AutoFarmEnabled = false, AutoFarmDelay = 5, AutoFarmTPDelay = 0.2,
}

local SilentTarget = nil
local AutoJumpConnection, SpinConnection, FullBrightConnection, TriggerBotConnection, SilentAimConnection
local AutoFarmRunning = false
local OriginalBrightness, OriginalAmbient, OriginalOutdoorAmbient = Lighting.Brightness, Lighting.Ambient, Lighting.OutdoorAmbient
local ESP_CONFIG = { TOP_OFFSET = Vector3.new(0, 3, 0), BOTTOM_OFFSET = Vector3.new(0, 3.5, 0), DISTANCE_DIVISOR = 3.5, MIN_HEIGHT = 6, MIN_WIDTH = 4 }
local ESP_Cache, ChamsObjects, Visibility_Cache, Tracked_NPCs, MM2Roles = {}, {}, {}, {}, {}

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function refreshRayFilter()
    local list = {}
    local char = LocalPlayer.Character
    if char then table.insert(list, char) end
    if Camera then table.insert(list, Camera) end
    rayParams.FilterDescendantsInstances = list
end

local function getRoot()
    local char = LocalPlayer.Character
    if char then return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") end
end
local function getHumanoid()
    local char = LocalPlayer.Character
    if char then return char:FindFirstChildOfClass("Humanoid") end
end
local function isMM2() return game.PlaceId == 142823291 end
local function isPlayerAlive(player)
    if not player or not player.Character then return false end
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

-- NPC Logic
local function IsNPC(model)
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not model:FindFirstChild("HumanoidRootPart") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    return true
end
local function CheckAndAddNPC(obj) if IsNPC(obj) then Tracked_NPCs[obj] = true end end
local function RemoveNPC(obj)
    if Tracked_NPCs[obj] then
        Tracked_NPCs[obj] = nil
        if ESP_Cache[obj] then ESP_Cache[obj].Box:Remove() ESP_Cache[obj].Text:Remove() ESP_Cache[obj].Tracer:Remove() ESP_Cache[obj] = nil end
        if ChamsObjects[obj] then for _, o in pairs(ChamsObjects[obj]) do if o then o:Destroy() end end ChamsObjects[obj] = nil end
    end
end

task.spawn(function()
    for _, obj in ipairs(workspace:GetDescendants()) do if obj:IsA("Model") then CheckAndAddNPC(obj) end end
end)
workspace.DescendantAdded:Connect(function(obj) if obj:IsA("Model") then task.delay(0.5, function() CheckAndAddNPC(obj) end) end end)
workspace.DescendantRemoving:Connect(RemoveNPC)

-- ESP Logic
local function GetVisibility(targetId, char)
    local currentTime = tick()
    if Visibility_Cache[targetId] and (currentTime - Visibility_Cache[targetId].lastUpdate) < 0.1 then return Visibility_Cache[targetId].isVisible end
    if not Camera then return false end
    local partsToCheck = { char:FindFirstChild("Head"), char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm"), char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm"), char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg"), char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg") }
    local origin, isVisible = Camera.CFrame.Position, false
    for _, part in pairs(partsToCheck) do
        if part and part:IsA("BasePart") then
            local result = workspace:Raycast(origin, part.Position - origin, rayParams)
            if result and result.Instance:IsDescendantOf(char) then isVisible = true break end
        end
    end
    Visibility_Cache[targetId] = { isVisible = isVisible, lastUpdate = currentTime }
    return isVisible
end
local function HideESP(id)
    local cached = ESP_Cache[id]
    if not cached then return end
    cached.Box.Visible, cached.Text.Visible, cached.Tracer.Visible = false, false, false
end
local function removeChams(id)
    if ChamsObjects[id] then for _, obj in pairs(ChamsObjects[id]) do if obj then obj:Destroy() end end ChamsObjects[id] = nil end
end
local function applyChams(id, char, color)
    if not ChamsObjects[id] then ChamsObjects[id] = {} end
    local existing = ChamsObjects[id][1]
    if existing and existing.Parent == char then existing.FillColor, existing.OutlineColor, existing.Enabled = color, color, true
    else
        removeChams(id)
        local hl = Instance.new("Highlight")
        hl.Name, hl.FillColor, hl.OutlineColor, hl.FillTransparency, hl.OutlineTransparency = "DeepHubChams", color, color, 0.5, 0
        hl.DepthMode, hl.Adornee, hl.Parent = Enum.HighlightDepthMode.AlwaysOnTop, char, char
        ChamsObjects[id] = {hl}
    end
end
local function getESPColor(player, isNPC, visible)
    if isNPC then return visible and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(200, 0, 255) end
    if player and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then return Color3.fromRGB(0, 255, 0) end
    if isMM2() and player and MM2Roles[player] then
        local role = MM2Roles[player]
        if role == "Murderer" then return Color3.fromRGB(255, 50, 50) end
        if role == "Sheriff" then return Color3.fromRGB(50, 150, 255) end
        if role == "Innocent" then return Color3.fromRGB(50, 255, 50) end
    end
    if player and player.Team and player.Team.TeamColor then return player.Team.TeamColor.Color end
    return visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end
local function DrawESP(id, char, hrp, name, player, isNPC)
    local showBox = isNPC and Settings.NPCESPEnabled or (not isNPC and Settings.ESPEnabled)
    local showTracer = isNPC and Settings.NPCTracersEnabled or (not isNPC and Settings.TracersEnabled)
    local showChams = isNPC and Settings.NPCChamsEnabled or (not isNPC and Settings.ChamsEnabled)
    if not showBox and not showTracer and not showChams then removeChams(id) return end
    if not Camera then return end
    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
    if dist == 0 then return end
    local rootScreen, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    local visible = GetVisibility(id, char)
    local renderColor = getESPColor(player, isNPC, visible)
    if showChams then applyChams(id, char, renderColor) else removeChams(id) end
    if not onScreen then return end
    if not ESP_Cache[id] then
        ESP_Cache[id] = { Box = Drawing.new("Square"), Text = Drawing.new("Text"), Tracer = Drawing.new("Line") }
        ESP_Cache[id].Box.Thickness, ESP_Cache[id].Box.Filled = 1.5, false
        ESP_Cache[id].Text.Size, ESP_Cache[id].Text.Center, ESP_Cache[id].Text.Outline = 14, true, true
        ESP_Cache[id].Tracer.Thickness = 1.5
    end
    local box, text, tracer = ESP_Cache[id].Box, ESP_Cache[id].Text, ESP_Cache[id].Tracer
    local topScreenPos = Camera:WorldToViewportPoint(hrp.Position + ESP_CONFIG.TOP_OFFSET)
    local bottomScreenPos = Camera:WorldToViewportPoint(hrp.Position - ESP_CONFIG.BOTTOM_OFFSET)
    local height = math.abs(bottomScreenPos.Y - topScreenPos.Y)
    local width = height / 2
    if height < ESP_CONFIG.MIN_HEIGHT then height = ESP_CONFIG.MIN_HEIGHT width = ESP_CONFIG.MIN_WIDTH end
    if showBox then
        box.Size, box.Position, box.Color, box.Visible = Vector2.new(width, height), Vector2.new(rootScreen.X - (width / 2), topScreenPos.Y), renderColor, true
        text.Text, text.Position, text.Color, text.Visible = string.format("%s%s [%dm]", isNPC and "[NPC] " or "", name, math.floor(dist / ESP_CONFIG.DISTANCE_DIVISOR)), Vector2.new(rootScreen.X, topScreenPos.Y - 18), renderColor, true
    end
    if showTracer then
        tracer.From, tracer.To, tracer.Color, tracer.Visible = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y), Vector2.new(rootScreen.X, bottomScreenPos.Y), renderColor, true
    end
end

-- Functions Logic
local function toggleAutoJump()
    if Settings.AutoJumpEnabled then
        if AutoJumpConnection then AutoJumpConnection:Disconnect() end
        AutoJumpConnection = RunService.RenderStepped:Connect(function()
            local hum = getHumanoid()
            if hum and hum.FloorMaterial ~= Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if AutoJumpConnection then AutoJumpConnection:Disconnect() AutoJumpConnection = nil end
    end
end
local function toggleSpin()
    if Settings.SpinEnabled then
        if SpinConnection then SpinConnection:Disconnect() end
        SpinConnection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char then local root = char:FindFirstChild("HumanoidRootPart") if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Settings.SpinSpeed) * 0.1, 0) end end
        end)
    else
        if SpinConnection then SpinConnection:Disconnect() SpinConnection = nil end
    end
end
local function toggleFullBright()
    if Settings.FullBrightEnabled then
        if FullBrightConnection then FullBrightConnection:Disconnect() end
        FullBrightConnection = RunService.RenderStepped:Connect(function()
            Lighting.Brightness, Lighting.Ambient, Lighting.OutdoorAmbient = 2, Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)
        end)
    else
        if FullBrightConnection then FullBrightConnection:Disconnect() FullBrightConnection = nil end
        Lighting.Brightness, Lighting.Ambient, Lighting.OutdoorAmbient = OriginalBrightness, OriginalAmbient, OriginalOutdoorAmbient
    end
end
local function toggleTriggerBot()
    if TriggerBotConnection then TriggerBotConnection:Disconnect() TriggerBotConnection = nil end
    if not Settings.TriggerBotEnabled then return end
    TriggerBotConnection = RunService.RenderStepped:Connect(function()
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
        local mousePos = UserInputService:GetMouseLocation()
        local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)
        if result and result.Instance then
            local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
            if hitChar then
                local hitPlayer = Players:GetPlayerFromCharacter(hitChar)
                if hitPlayer and hitPlayer ~= LocalPlayer then
                    if mouse1press and mouse1release then mouse1press() task.wait() mouse1release() end
                end
            end
        end
    end)
end

local FOVCircle, LegitFOVCircle, SilentFOVCircle
local function updateFOVCircle()
    if FOVCircle then FOVCircle:Remove() FOVCircle = nil end
    if LegitFOVCircle then LegitFOVCircle:Remove() LegitFOVCircle = nil end
    if SilentFOVCircle then SilentFOVCircle:Remove() SilentFOVCircle = nil end
    if not Drawing then return end
    if Settings.AimbotEnabled and Settings.ShowFOV then FOVCircle = Drawing.new("Circle") FOVCircle.Thickness, FOVCircle.Radius, FOVCircle.Color, FOVCircle.Filled, FOVCircle.Visible = 2, Settings.FOV, Color3.fromRGB(255,50,50), false, true end
    if Settings.LegitBotEnabled and Settings.ShowFOV then LegitFOVCircle = Drawing.new("Circle") LegitFOVCircle.Thickness, LegitFOVCircle.Radius, LegitFOVCircle.Color, LegitFOVCircle.Filled, LegitFOVCircle.Visible = 2, Settings.LegitBotFOV, Color3.fromRGB(50,255,50), false, true end
    if Settings.SilentAimEnabled and Settings.SilentAimShowFOV then SilentFOVCircle = Drawing.new("Circle") SilentFOVCircle.Thickness, SilentFOVCircle.Radius, SilentFOVCircle.Color, SilentFOVCircle.Filled, SilentFOVCircle.Visible = 2, Settings.SilentAimFOV, Color3.fromRGB(255,200,0), false, true end
end
updateFOVCircle()

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function isVisible(targetCharacter)
    if not Settings.VisibleCheck then return true end
    local targetPart = targetCharacter:FindFirstChild(Settings.TargetPart)
    if not targetPart then return false end
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
    return workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), raycastParams) == nil
end
local function isSilentVisible(targetCharacter)
    if not Settings.SilentAimVisibleCheck then return true end
    local targetPart = targetCharacter:FindFirstChild(Settings.TargetPart)
    if not targetPart then return false end
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
    return workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), raycastParams) == nil
end

local function getClosestPlayer(fov)
    local closestPlayer, shortestDistance = nil, fov or Settings.FOV
    local mousePos = UserInputService:GetMouseLocation()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and isPlayerAlive(player) and not (Settings.CheckTeam and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team) then
            local targetPart = player.Character:FindFirstChild(Settings.TargetPart)
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance and isVisible(player.Character) then shortestDistance, closestPlayer = distance, player end
                end
            end
        end
    end
    return closestPlayer
end
local function getSilentTarget()
    local closestPlayer, shortestDistance = nil, Settings.SilentAimFOV
    local mousePos = UserInputService:GetMouseLocation()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and isPlayerAlive(player) and not (Settings.SilentAimCheckTeam and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team) then
            local targetPart = player.Character:FindFirstChild(Settings.TargetPart)
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance and isSilentVisible(player.Character) then shortestDistance, closestPlayer = distance, player end
                end
            end
        end
    end
    return closestPlayer
end

local function setupSilentAim()
    if SilentAimConnection then SilentAimConnection:Disconnect() SilentAimConnection = nil end
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

local flyConnection, flyBodyVelocity, noclipConnection, speedConnection, infJumpConnection, antiflingConnection, jumpPowerConnection
local originalJumpPower = 50

local function flyLoop(dt)
    if not Settings.FlyEnabled then return end
    local root = getRoot() if not root then return end
    if not flyBodyVelocity or flyBodyVelocity.Parent == nil then flyBodyVelocity = Instance.new("BodyVelocity") flyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9) flyBodyVelocity.Parent = root end
    local move = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
    if move.Magnitude > 0 then flyBodyVelocity.Velocity = move.Unit * Settings.FlySpeed * 10 else flyBodyVelocity.Velocity = Vector3.new(0, 0, 0) end
    root.Velocity = Vector3.new(0, 0, 0)
end
local function noclipLoop()
    if not Settings.NoclipEnabled then return end
    local char = LocalPlayer.Character if not char then return end
    for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
end
local function speedLoop()
    if not Settings.SpeedEnabled then return end
    local hum = getHumanoid() if hum then hum.WalkSpeed = Settings.SpeedValue end
end
local function resetSpeed() local hum = getHumanoid() if hum then hum.WalkSpeed = 16 end end
local function applyJumpPower()
    if not Settings.JumpPowerEnabled then return end
    local hum = getHumanoid() if hum then originalJumpPower = hum.JumpPower hum.JumpPower = Settings.JumpPowerValue end
end
local function resetJumpPower() local hum = getHumanoid() if hum then hum.JumpPower = originalJumpPower end end
local function infJumpLoop()
    if not Settings.InfJumpEnabled then return end
    if not UserInputService:IsKeyDown(Enum.KeyCode.Space) then return end
    local hum = getHumanoid() if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end
local function antiflingLoop()
    if not Settings.AntiflingEnabled then return end
    local root = getRoot() if root and root.Velocity.Magnitude > 100 then root.Velocity = Vector3.new(0, 0, 0) end
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
    if Settings.JumpPowerEnabled then applyJumpPower() jumpPowerConnection = LocalPlayer.CharacterAdded:Connect(function() wait(0.5) applyJumpPower() end) else resetJumpPower() end
    if Settings.InfJumpEnabled then infJumpConnection = RunService.RenderStepped:Connect(infJumpLoop) end
    if Settings.AntiflingEnabled then antiflingConnection = RunService.RenderStepped:Connect(antiflingLoop) end
    setupSilentAim() toggleAutoJump() toggleSpin() toggleFullBright() toggleTriggerBot()
end

local function toggleFeature(name, state)
    Settings[name] = state
    if name == "AimbotEnabled" or name == "LegitBotEnabled" or name == "ShowFOV" or name == "SilentAimEnabled" or name == "SilentAimShowFOV" or name == "SilentAimFOV" then updateFOVCircle() setupSilentAim()
    elseif name == "AutoFarmEnabled" then if state then task.spawn(function() while Settings.AutoFarmEnabled do task.wait(1) end end) end
    else updateConnections() end
end

local function isKeyPressed(key)
    if key == "MouseButton1" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif key == "MouseButton2" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    else return UserInputService:IsKeyDown(Enum.KeyCode[key]) end
end
local aimbotToggled, legitToggled = false, false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Settings.AimbotMode == "Toggle" then
        local pressed = (Settings.AimbotKey == "MouseButton1" and input.UserInputType == Enum.UserInputType.MouseButton1) or (Settings.AimbotKey == "MouseButton2" and input.UserInputType == Enum.UserInputType.MouseButton2) or (input.KeyCode == Enum.KeyCode[Settings.AimbotKey])
        if pressed then aimbotToggled = not aimbotToggled end
    end
    if Settings.LegitBotMode == "Toggle" then
        local pressed = (Settings.LegitBotKey == "MouseButton1" and input.UserInputType == Enum.UserInputType.MouseButton1) or (Settings.LegitBotKey == "MouseButton2" and input.UserInputType == Enum.UserInputType.MouseButton2) or (input.KeyCode == Enum.KeyCode[Settings.LegitBotKey])
        if pressed then legitToggled = not legitToggled end
    end
end)

RunService.RenderStepped:Connect(function()
    refreshRayFilter()
    if Settings.AimbotEnabled or Settings.LegitBotEnabled or Settings.SilentAimEnabled then
        local mousePos = UserInputService:GetMouseLocation()
        if FOVCircle then FOVCircle.Position, FOVCircle.Radius, FOVCircle.Visible = Vector2.new(mousePos.X, mousePos.Y), Settings.FOV, Settings.AimbotEnabled and Settings.ShowFOV end
        if SilentFOVCircle then SilentFOVCircle.Position, SilentFOVCircle.Radius, SilentFOVCircle.Visible = Vector2.new(mousePos.X, mousePos.Y), Settings.SilentAimFOV, Settings.SilentAimEnabled and Settings.SilentAimShowFOV end
    end
    if Settings.SilentAimEnabled then SilentTarget = getSilentTarget() else SilentTarget = nil end
    if Settings.ESPEnabled or Settings.TracersEnabled or Settings.ChamsEnabled or Settings.NPCESPEnabled or Settings.NPCTracersEnabled or Settings.NPCChamsEnabled then
        for id in pairs(ESP_Cache) do HideESP(id) end
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and isPlayerAlive(player) then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then DrawESP(tostring(player.UserId), player.Character, hrp, player.Name, player, false) end
            end
        end
        for npc in pairs(Tracked_NPCs) do
            if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                if hrp then DrawESP(npc, npc, hrp, npc.Name, nil, true) end
            end
        end
    else
        for id in pairs(ESP_Cache) do HideESP(id) end
        for id in pairs(ChamsObjects) do removeChams(id) end
    end
    if Settings.AimbotEnabled then
        local active = (Settings.AimbotMode == "Hold") and isKeyPressed(Settings.AimbotKey) or aimbotToggled
        if active then
            local target = getClosestPlayer(Settings.FOV)
            if target and target.Character and target.Character:FindFirstChild(Settings.TargetPart) then
                local part = target.Character[Settings.TargetPart]
                if Settings.AimType == "Mouse" then
                    if mousemoverel then local mp = UserInputService:GetMouseLocation() local sp = Camera:WorldToViewportPoint(part.Position) mousemoverel((sp.X - mp.X) * (Settings.Smoothness / 10), (sp.Y - mp.Y) * (Settings.Smoothness / 10)) else Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position) end
                else Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), 1 - Settings.Smoothness / 10) end
            end
        end
    end
end)

-- ============================================================================
-- 2. UI CREATION
-- ============================================================================
if CoreGui:FindFirstChild("DeepHubUI") then CoreGui.DeepHubUI:Destroy() end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name, ScreenGui.ResetOnSpawn, ScreenGui.ZIndexBehavior = "DeepHubUI", false, Enum.ZIndexBehavior.Sibling
local targetParent = (gethui and gethui()) or (run_secure and CoreGui) or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Parent = targetParent

local THEME = {
    Background = Color3.fromRGB(12, 9, 11), CardBg = Color3.fromRGB(18, 13, 16), PillBg = Color3.fromRGB(16, 12, 14),
    SidebarActive = Color3.fromRGB(27, 16, 19), Border = Color3.fromRGB(36, 24, 28), BorderActive = Color3.fromRGB(90, 36, 42),
    Accent = Color3.fromRGB(246, 92, 82), AccentSoft = Color3.fromRGB(255, 165, 155), AccentDark = Color3.fromRGB(130, 40, 42),
    TextPrimary = Color3.fromRGB(235, 235, 235), TextMuted = Color3.fromRGB(120, 110, 115), TextDim = Color3.fromRGB(72, 64, 68),
    Divider = Color3.fromRGB(48, 36, 40), BadgeBg = Color3.fromRGB(25, 18, 22), ToggleOff = Color3.fromRGB(36, 28, 32),
    KnobOff = Color3.fromRGB(78, 68, 73), KnobOn = Color3.fromRGB(255, 255, 255)
}
local ICONS = { Search="rbxassetid://7733911828", Chevron="rbxassetid://7733717447", More="rbxassetid://7734021300", Menu="rbxassetid://7733993211", Combat="rbxassetid://7734053426", Movement="rbxassetid://7733799901", Visuals="rbxassetid://7733774602", Player="rbxassetid://7733954760", Misc="rbxassetid://7734056411", Presets="rbxassetid://7733964719", AutoBuy="rbxassetid://7733942651", Accounts="rbxassetid://7733765307", User="rbxassetid://7733954760", Chart="rbxassetid://7733749837", Clock="rbxassetid://7733734762", Compass="rbxassetid://7733720755", Signal="rbxassetid://7734058495", Radar="rbxassetid://7734053426", Speed="rbxassetid://7733799901" }
local TWEEN_FAST, TWEEN_SLOW = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

-- HUD
local HudContainer = Instance.new("Frame"); HudContainer.Name="HudContainer"; HudContainer.Size=UDim2.new(0,600,0,50); HudContainer.Position=UDim2.new(0,16,0,48); HudContainer.BackgroundTransparency=1; HudContainer.Parent=ScreenGui
local HudVerticalLayout = Instance.new("UIListLayout"); HudVerticalLayout.SortOrder=Enum.SortOrder.LayoutOrder; HudVerticalLayout.Padding=UDim.new(0,4); HudVerticalLayout.Parent=HudContainer
local function createHudRow(name, height, order) local row=Instance.new("Frame") row.Name=name; row.Size=UDim2.new(1,0,0,height); row.BackgroundTransparency=1; row.LayoutOrder=order; row.Parent=HudContainer; local hLayout=Instance.new("UIListLayout"); hLayout.FillDirection=Enum.FillDirection.Horizontal; hLayout.SortOrder=Enum.SortOrder.LayoutOrder; hLayout.VerticalAlignment=Enum.VerticalAlignment.Center; hLayout.Padding=UDim.new(0,5); hLayout.Parent=row; return row end
local TopHudRow, BottomHudRow = createHudRow("TopRow",22,1), createHudRow("BottomRow",22,2)
local function createHudPill(parent, order) local pill=Instance.new("Frame"); pill.AutomaticSize=Enum.AutomaticSize.X; pill.Size=UDim2.new(0,0,1,0); pill.BackgroundColor3=THEME.PillBg; pill.BorderSizePixel=0; pill.LayoutOrder=order; pill.Parent=parent; local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,5); corner.Parent=pill; local stroke=Instance.new("UIStroke"); stroke.Color=THEME.Border; stroke.Thickness=1; stroke.Parent=pill; local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,6); pad.PaddingRight=UDim.new(0,6); pad.Parent=pill; local layout=Instance.new("UIListLayout"); layout.FillDirection=Enum.FillDirection.Horizontal; layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.VerticalAlignment=Enum.VerticalAlignment.Center; layout.Padding=UDim.new(0,5); layout.Parent=pill; return pill end
local function addHudDivider(parent, order) local div=Instance.new("Frame"); div.Size=UDim2.new(0,1,0,10); div.BackgroundColor3=THEME.Divider; div.BorderSizePixel=0; div.LayoutOrder=order; div.Parent=parent end
local function addHudText(parent, text, isMuted, order) local lbl=Instance.new("TextLabel"); lbl.AutomaticSize=Enum.AutomaticSize.X; lbl.Size=UDim2.new(0,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=text; lbl.Font=Enum.Font.GothamMedium; lbl.TextSize=10.5; lbl.TextColor3=isMuted and THEME.TextMuted or THEME.TextPrimary; lbl.LayoutOrder=order; lbl.Parent=parent; return lbl end
local function addHudSmallIcon(parent, iconId, order) local icon=Instance.new("ImageLabel"); icon.Size=UDim2.new(0,11,0,11); icon.BackgroundTransparency=1; icon.Image=iconId; icon.ScaleType=Enum.ScaleType.Fit; icon.ImageColor3=THEME.Accent; icon.LayoutOrder=order; icon.Parent=parent; return icon end

local BrandPill = createHudPill(TopHudRow, 1)
local HudLogoWrap = Instance.new("Frame"); HudLogoWrap.Size=UDim2.new(0,20,0,20); HudLogoWrap.BackgroundTransparency=1; HudLogoWrap.LayoutOrder=1; HudLogoWrap.Parent=BrandPill
local HudLogoGlow = Instance.new("ImageLabel"); HudLogoGlow.Size=UDim2.new(2,0,2,0); HudLogoGlow.Position=UDim2.new(-0.5,0,-0.5,0); HudLogoGlow.BackgroundTransparency=1; HudLogoGlow.Image="rbxassetid://5028857084"; HudLogoGlow.ImageColor3=THEME.Accent; HudLogoGlow.ImageTransparency=0.65; HudLogoGlow.ZIndex=1; HudLogoGlow.Parent=HudLogoWrap
local HudBrandLogo = Instance.new("ImageLabel"); HudBrandLogo.Size=UDim2.new(1.35,0,1.35,0); HudBrandLogo.Position=UDim2.new(-0.175,0,-0.175,0); HudBrandLogo.BackgroundTransparency=1; HudBrandLogo.Image=CUSTOM_LOGO_ID; HudBrandLogo.ScaleType=Enum.ScaleType.Fit; HudBrandLogo.ImageColor3=Color3.fromRGB(255,255,255); HudBrandLogo.ZIndex=2; HudBrandLogo.Parent=HudLogoWrap
local HudLogoGrad = Instance.new("UIGradient"); HudLogoGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0.0,THEME.AccentSoft),ColorSequenceKeypoint.new(0.45,THEME.Accent),ColorSequenceKeypoint.new(1.0,Color3.fromRGB(165,32,42))}); HudLogoGrad.Rotation=-35; HudLogoGrad.Parent=HudBrandLogo
addHudDivider(BrandPill, 2)
local HudBrandText = addHudText(BrandPill, "DeepHub", false, 3)
local HudBrandGrad = Instance.new("UIGradient"); HudBrandGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0.0,THEME.AccentSoft),ColorSequenceKeypoint.new(1.0,THEME.Accent)}); HudBrandGrad.Parent=HudBrandText

local StatsPill = createHudPill(TopHudRow, 2)
addHudSmallIcon(StatsPill, ICONS.User, 1); addHudText(StatsPill, string.lower(LocalPlayer.Name), false, 2); addHudDivider(StatsPill, 3)
addHudSmallIcon(StatsPill, ICONS.Chart, 4); local FpsLabel = addHudText(StatsPill, "0 Fps", false, 5); addHudDivider(StatsPill, 6)
addHudSmallIcon(StatsPill, ICONS.Clock, 7); local TimeLabel = addHudText(StatsPill, "00:00:00", false, 8)

local PosPill = createHudPill(BottomHudRow, 1); addHudSmallIcon(PosPill, ICONS.Compass, 1); addHudDivider(PosPill, 2); local PosLabel = addHudText(PosPill, "0, 0, 0", false, 3)
local PingPill = createHudPill(BottomHudRow, 2); addHudSmallIcon(PingPill, ICONS.Signal, 1); addHudDivider(PingPill, 2); local PingLabel = addHudText(PingPill, "0 Ping", false, 3)
local TickPill = createHudPill(BottomHudRow, 3); addHudSmallIcon(TickPill, ICONS.Radar, 1); addHudDivider(TickPill, 2); local TickLabel = addHudText(TickPill, "20.0 Ticks", false, 3)
local SpeedPill = createHudPill(BottomHudRow, 4); addHudSmallIcon(SpeedPill, ICONS.Speed, 1); addHudDivider(SpeedPill, 2); local SpeedLabel = addHudText(SpeedPill, "0.0 Bps", false, 3)

local fpsCounter, lastFpsCheck = 0, os.clock()
local lastPosition = Vector3.zero
local lastPosTime = os.clock()
RunService.RenderStepped:Connect(function()
    fpsCounter = fpsCounter + 1
    local now = os.clock()
    if now - lastFpsCheck >= 1 then FpsLabel.Text = string.format("%d Fps", fpsCounter); fpsCounter = 0; lastFpsCheck = now end
    TimeLabel.Text = os.date("%H:%M:%S")
    PingLabel.Text = string.format("%d Ping", math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()))
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local currentPos = hrp.Position
        PosLabel.Text = string.format("%d, %d, %d", math.floor(currentPos.X), math.floor(currentPos.Y), math.floor(currentPos.Z))
        local deltaTime = now - lastPosTime
        if deltaTime >= 0.1 then
            local dist = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(lastPosition.X, 0, lastPosition.Z)).Magnitude
            SpeedLabel.Text = string.format("%.1f Bps", dist / deltaTime)
            lastPosition = currentPos; lastPosTime = now
        end
    else
        PosLabel.Text = "0, 0, 0"; SpeedLabel.Text = "0.0 Bps"
    end
end)

-- Main Window & UI
local Main = Instance.new("Frame"); Main.Name="MainFrame"; Main.Size=UDim2.new(0,790,0,490); Main.Position=UDim2.new(0.5,-395,0.5,-245); Main.BackgroundColor3=THEME.Background; Main.BorderSizePixel=0; Main.ClipsDescendants=false; Main.Parent=ScreenGui
local MainCorner=Instance.new("UICorner"); MainCorner.CornerRadius=UDim.new(0,12); MainCorner.Parent=Main
local MainStroke=Instance.new("UIStroke"); MainStroke.Color=THEME.Border; MainStroke.Thickness=1.2; MainStroke.Parent=Main
local GlowBackdrop=Instance.new("ImageLabel"); GlowBackdrop.Name="GlowBackdrop"; GlowBackdrop.BackgroundTransparency=1; GlowBackdrop.Position=UDim2.new(0,-45,0,-45); GlowBackdrop.Size=UDim2.new(1,90,1,90); GlowBackdrop.ZIndex=0; GlowBackdrop.Image="rbxassetid://5028857084"; GlowBackdrop.ImageColor3=THEME.AccentDark; GlowBackdrop.ImageTransparency=0.83; GlowBackdrop.ScaleType=Enum.ScaleType.Slice; GlowBackdrop.SliceCenter=Rect.new(24,24,276,276); GlowBackdrop.Parent=Main

do
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; dragStart=input.Position; startPos=Main.Position end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then local delta=input.Position-dragStart; TweenService:Create(Main,TweenInfo.new(0.04),{Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)}):Play() end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
end

local TopBar=Instance.new("Frame"); TopBar.Size=UDim2.new(1,0,0,56); TopBar.BackgroundTransparency=1; TopBar.Parent=Main
local MainLogoHolder=Instance.new("Frame"); MainLogoHolder.Name="LogoHolder"; MainLogoHolder.Size=UDim2.new(0,64,0,64); MainLogoHolder.Position=UDim2.new(0,52,0,-4); MainLogoHolder.BackgroundTransparency=1; MainLogoHolder.Parent=TopBar
local MainLogoHalo=Instance.new("ImageLabel"); MainLogoHalo.Name="Halo"; MainLogoHalo.Size=UDim2.new(2.1,0,2.1,0); MainLogoHalo.Position=UDim2.new(-0.55,0,-0.55,0); MainLogoHalo.BackgroundTransparency=1; MainLogoHalo.Image="rbxassetid://5028857084"; MainLogoHalo.ImageColor3=THEME.Accent; MainLogoHalo.ImageTransparency=0.58; MainLogoHalo.ZIndex=1; MainLogoHalo.Parent=MainLogoHolder
local MainLogoShadow=Instance.new("ImageLabel"); MainLogoShadow.Name="LogoShadow"; MainLogoShadow.Size=UDim2.new(1,0,1,0); MainLogoShadow.Position=UDim2.new(0,2,0,2); MainLogoShadow.BackgroundTransparency=1; MainLogoShadow.Image=CUSTOM_LOGO_ID; MainLogoShadow.ScaleType=Enum.ScaleType.Fit; MainLogoShadow.ImageColor3=Color3.fromRGB(50,10,14); MainLogoShadow.ImageTransparency=0.2; MainLogoShadow.ZIndex=2; MainLogoShadow.Parent=MainLogoHolder
local MainLogoImg=Instance.new("ImageLabel"); MainLogoImg.Name="LogoMain"; MainLogoImg.Size=UDim2.new(1,0,1,0); MainLogoImg.Position=UDim2.new(0,0,0,0); MainLogoImg.BackgroundTransparency=1; MainLogoImg.Image=CUSTOM_LOGO_ID; MainLogoImg.ScaleType=Enum.ScaleType.Fit; MainLogoImg.ImageColor3=Color3.fromRGB(255,255,255); MainLogoImg.ZIndex=3; MainLogoImg.Parent=MainLogoHolder
local MainLogoGrad=Instance.new("UIGradient"); MainLogoGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0.0,Color3.fromRGB(255,175,165)),ColorSequenceKeypoint.new(0.45,Color3.fromRGB(246,92,82)),ColorSequenceKeypoint.new(1.0,Color3.fromRGB(165,32,42))}); MainLogoGrad.Rotation=-35; MainLogoGrad.Parent=MainLogoImg

local SearchBox=Instance.new("Frame"); SearchBox.Size=UDim2.new(0,250,0,26); SearchBox.Position=UDim2.new(0,185,0,15); SearchBox.BackgroundColor3=THEME.CardBg; SearchBox.BorderSizePixel=0; SearchBox.Parent=TopBar
local SearchCorner=Instance.new("UICorner"); SearchCorner.CornerRadius=UDim.new(0,6); SearchCorner.Parent=SearchBox
local SearchStroke=Instance.new("UIStroke"); SearchStroke.Color=THEME.Border; SearchStroke.Thickness=0.8; SearchStroke.Parent=SearchBox
local SearchIcon=Instance.new("ImageLabel"); SearchIcon.Size=UDim2.new(0,13,0,13); SearchIcon.Position=UDim2.new(0,9,0.5,-6.5); SearchIcon.BackgroundTransparency=1; SearchIcon.Image=ICONS.Search; SearchIcon.ImageColor3=THEME.TextMuted; SearchIcon.Parent=SearchBox
local SearchInput=Instance.new("TextBox"); SearchInput.PlaceholderText="Search something"; SearchInput.PlaceholderColor3=THEME.TextMuted; SearchInput.TextColor3=THEME.TextPrimary; SearchInput.Font=Enum.Font.Gotham; SearchInput.TextSize=11; SearchInput.Position=UDim2.new(0,30,0,0); SearchInput.Size=UDim2.new(1,-36,1,0); SearchInput.BackgroundTransparency=1; SearchInput.TextXAlignment=Enum.TextXAlignment.Left; SearchInput.Parent=SearchBox
local MenuBtn=Instance.new("ImageButton"); MenuBtn.Size=UDim2.new(0,17,0,17); MenuBtn.Position=UDim2.new(1,-32,0.5,-8.5); MenuBtn.BackgroundTransparency=1; MenuBtn.Image=ICONS.Menu; MenuBtn.ImageColor3=THEME.TextMuted; MenuBtn.Parent=TopBar
MenuBtn.MouseEnter:Connect(function() TweenService:Create(MenuBtn,TWEEN_FAST,{ImageColor3=THEME.TextPrimary}):Play() end)
MenuBtn.MouseLeave:Connect(function() TweenService:Create(MenuBtn,TWEEN_FAST,{ImageColor3=THEME.TextMuted}):Play() end)

local Sidebar=Instance.new("Frame"); Sidebar.Size=UDim2.new(0,155,1,-58); Sidebar.Position=UDim2.new(0,14,0,54); Sidebar.BackgroundTransparency=1; Sidebar.Parent=Main
local SideList=Instance.new("UIListLayout"); SideList.Padding=UDim.new(0,2); SideList.SortOrder=Enum.SortOrder.LayoutOrder; SideList.Parent=Sidebar
local activeSidebarTab=nil
local function addCategory(name,order) local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,0,20); lbl.LayoutOrder=order; lbl.BackgroundTransparency=1; lbl.Text="   "..name:upper(); lbl.Font=Enum.Font.GothamBold; lbl.TextSize=9; lbl.TextColor3=THEME.TextDim; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=Sidebar end

local ContentArea=Instance.new("Frame"); ContentArea.Size=UDim2.new(1,-195,1,-62); ContentArea.Position=UDim2.new(0,182,0,54); ContentArea.BackgroundTransparency=1; ContentArea.Parent=Main
local Col1=Instance.new("ScrollingFrame"); Col1.Size=UDim2.new(0.485,0,1,0); Col1.BackgroundTransparency=1; Col1.ScrollBarThickness=0; Col1.Parent=ContentArea
local Col2=Instance.new("ScrollingFrame"); Col2.Size=UDim2.new(0.485,0,1,0); Col2.Position=UDim2.new(0.515,0,0,0); Col2.BackgroundTransparency=1; Col2.ScrollBarThickness=0; Col2.Parent=ContentArea
for _,col in ipairs({Col1,Col2}) do local l=Instance.new("UIListLayout"); l.Padding=UDim.new(0,12); l.SortOrder=Enum.SortOrder.LayoutOrder; l.Parent=col end

local function createCard(parent,titleText,order)
    local card=Instance.new("Frame"); card.Size=UDim2.new(1,0,0,0); card.AutomaticSize=Enum.AutomaticSize.Y; card.BackgroundColor3=THEME.CardBg; card.BorderSizePixel=0; card.LayoutOrder=order; card.Parent=parent
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,8); c.Parent=card
    local s=Instance.new("UIStroke"); s.Color=THEME.Border; s.Thickness=0.8; s.Parent=card
    local p=Instance.new("UIPadding"); p.PaddingTop=UDim.new(0,11); p.PaddingBottom=UDim.new(0,13); p.PaddingLeft=UDim.new(0,12); p.PaddingRight=UDim.new(0,12); p.Parent=card
    local list=Instance.new("UIListLayout"); list.Padding=UDim.new(0,10); list.SortOrder=Enum.SortOrder.LayoutOrder; list.Parent=card
    local header=Instance.new("Frame"); header.Size=UDim2.new(1,0,0,18); header.BackgroundTransparency=1; header.LayoutOrder=0; header.Parent=card
    local title=Instance.new("TextLabel"); title.Size=UDim2.new(1,-20,1,0); title.BackgroundTransparency=1; title.Text=titleText; title.Font=Enum.Font.GothamBold; title.TextSize=12; title.TextColor3=THEME.TextPrimary; title.TextXAlignment=Enum.TextXAlignment.Left; title.Parent=header
    local icon=Instance.new("ImageLabel"); icon.Size=UDim2.new(0,12,0,12); icon.Position=UDim2.new(1,-12,0.5,-6); icon.BackgroundTransparency=1; icon.Image=ICONS.Chevron; icon.ImageColor3=THEME.Accent; icon.Parent=header
    return card
end

local registeredRows, ActiveDropdown, KeybindListening = {}, nil, nil
local function openKeybindModal(targetBadge, featureName) if KeybindListening then KeybindListening:Disconnect() end targetBadge.Text="..."; targetBadge.TextColor3=THEME.Accent KeybindListening=UserInputService.InputBegan:Connect(function(input,processed) if processed then return end if input.UserInputType==Enum.UserInputType.Keyboard then local keyName=input.KeyCode.Name if keyName=="Escape" then targetBadge.Text="-" else targetBadge.Text=keyName end targetBadge.TextColor3=THEME.TextMuted KeybindListening:Disconnect() KeybindListening=nil end end) end
local function toggleDropdown(parentRow, badgeLabel, featureName) if ActiveDropdown then ActiveDropdown:Destroy() ActiveDropdown=nil return end local drop=Instance.new("Frame"); drop.Name="Dropdown"; drop.Size=UDim2.new(0,115,0,58); drop.Position=UDim2.new(1,-120,1,3); drop.BackgroundColor3=Color3.fromRGB(24,18,20); drop.ZIndex=30; drop.Parent=parentRow; local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,6); c.Parent=drop; local s=Instance.new("UIStroke"); s.Color=THEME.Border; s.Thickness=1; s.Parent=drop; local list=Instance.new("UIListLayout"); list.Padding=UDim.new(0,1); list.Parent=drop; local pad=Instance.new("UIPadding"); pad.PaddingTop=UDim.new(0,3); pad.PaddingBottom=UDim.new(0,3); pad.PaddingLeft=UDim.new(0,5); pad.PaddingRight=UDim.new(0,5); pad.Parent=drop; local function addOption(name,onClick) local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,24); btn.BackgroundTransparency=1; btn.Text=" "..name; btn.Font=Enum.Font.GothamMedium; btn.TextSize=10.5; btn.TextColor3=THEME.TextPrimary; btn.TextXAlignment=Enum.TextXAlignment.Left; btn.ZIndex=31; btn.Parent=drop; btn.MouseEnter:Connect(function() btn.TextColor3=THEME.Accent end); btn.MouseLeave:Connect(function() btn.TextColor3=THEME.TextPrimary end); btn.MouseButton1Click:Connect(function() drop:Destroy() ActiveDropdown=nil if onClick then onClick() end end) end; addOption("Bind Key",function() openKeybindModal(badgeLabel,featureName) end); addOption("Reset Value",function() badgeLabel.Text="-" end); ActiveDropdown=drop end

local function addToggle(card,name,description,defaultState,keybindDefault,callback)
    local row=Instance.new("Frame"); row.Name=name; row.Size=UDim2.new(1,0,0,description and 30 or 21); row.BackgroundTransparency=1; row.Parent=card; table.insert(registeredRows,{Frame=row,Name=name:lower()})
    local textContainer=Instance.new("Frame"); textContainer.Size=UDim2.new(1,-80,1,0); textContainer.BackgroundTransparency=1; textContainer.Parent=row
    local rowTitle=Instance.new("TextLabel"); rowTitle.Size=UDim2.new(1,0,0,14); rowTitle.BackgroundTransparency=1; rowTitle.Text=name; rowTitle.Font=Enum.Font.GothamMedium; rowTitle.TextSize=11; rowTitle.TextColor3=THEME.TextPrimary; rowTitle.TextXAlignment=Enum.TextXAlignment.Left; rowTitle.Parent=textContainer
    if description then local rowDesc=Instance.new("TextLabel"); rowDesc.Size=UDim2.new(1,0,0,12); rowDesc.Position=UDim2.new(0,0,0,14); rowDesc.BackgroundTransparency=1; rowDesc.Text=description; rowDesc.Font=Enum.Font.Gotham; rowDesc.TextSize=9; rowDesc.TextColor3=THEME.TextMuted; rowDesc.TextXAlignment=Enum.TextXAlignment.Left; rowDesc.Parent=textContainer end
    local badge=Instance.new("TextLabel"); badge.Size=UDim2.new(0,18,0,14); badge.Position=UDim2.new(1,-76,0.5,-7); badge.BackgroundColor3=THEME.BadgeBg; badge.Text=keybindDefault or ""; badge.Visible=(keybindDefault~=nil); badge.Font=Enum.Font.GothamBold; badge.TextSize=8.5; badge.TextColor3=THEME.TextMuted; badge.Parent=row; local bc=Instance.new("UICorner"); bc.CornerRadius=UDim.new(0,3); bc.Parent=badge; local bs=Instance.new("UIStroke"); bs.Color=THEME.Border; bs.Thickness=0.8; bs.Parent=badge
    local optBtn=Instance.new("ImageButton"); optBtn.Size=UDim2.new(0,13,0,13); optBtn.Position=UDim2.new(1,-52,0.5,-6.5); optBtn.BackgroundTransparency=1; optBtn.Image=ICONS.More; optBtn.ImageColor3=THEME.TextDim; optBtn.Parent=row; optBtn.MouseEnter:Connect(function() TweenService:Create(optBtn,TWEEN_FAST,{ImageColor3=THEME.TextPrimary}):Play() end); optBtn.MouseLeave:Connect(function() TweenService:Create(optBtn,TWEEN_FAST,{ImageColor3=THEME.TextDim}):Play() end); optBtn.MouseButton1Click:Connect(function() badge.Visible=true toggleDropdown(row,badge,name) end)
    local switch=Instance.new("TextButton"); switch.Size=UDim2.new(0,32,0,16); switch.Position=UDim2.new(1,-32,0.5,-8); switch.BackgroundColor3=defaultState and THEME.Accent or THEME.ToggleOff; switch.Text=""; switch.AutoButtonColor=false; switch.Parent=row; local sCorner=Instance.new("UICorner"); sCorner.CornerRadius=UDim.new(1,0); sCorner.Parent=switch
    local knob=Instance.new("Frame"); knob.Size=UDim2.new(0,12,0,12); knob.Position=defaultState and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6); knob.BackgroundColor3=defaultState and THEME.KnobOn or THEME.KnobOff; knob.BorderSizePixel=0; knob.Parent=switch; local kCorner=Instance.new("UICorner"); kCorner.CornerRadius=UDim.new(1,0); kCorner.Parent=knob
    local isToggled=defaultState; switch.MouseButton1Click:Connect(function() isToggled=not isToggled; local targetColor=isToggled and THEME.Accent or THEME.ToggleOff; local targetKnobColor=isToggled and THEME.KnobOn or THEME.KnobOff; local targetPos=isToggled and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6); TweenService:Create(switch,TWEEN_FAST,{BackgroundColor3=targetColor}):Play(); TweenService:Create(knob,TWEEN_FAST,{BackgroundColor3=targetKnobColor,Position=targetPos}):Play(); if callback then callback(isToggled) end end)
end

local function addSlider(card,name,min,max,default,isFloat,callback)
    local row=Instance.new("Frame"); row.Name=name; row.Size=UDim2.new(1,0,0,40); row.BackgroundTransparency=1; row.Parent=card; table.insert(registeredRows,{Frame=row,Name=name:lower()})
    local title=Instance.new("TextLabel"); title.Size=UDim2.new(1,-40,0,14); title.BackgroundTransparency=1; title.Text=name; title.Font=Enum.Font.GothamMedium; title.TextSize=11; title.TextColor3=THEME.TextPrimary; title.TextXAlignment=Enum.TextXAlignment.Left; title.Parent=row
    local valueLbl=Instance.new("TextLabel"); valueLbl.Size=UDim2.new(0,40,0,14); valueLbl.Position=UDim2.new(1,-40,0,0); valueLbl.BackgroundTransparency=1; valueLbl.Text=tostring(default); valueLbl.Font=Enum.Font.GothamBold; valueLbl.TextSize=11; valueLbl.TextColor3=THEME.Accent; valueLbl.TextXAlignment=Enum.TextXAlignment.Right; valueLbl.Parent=row
    local bar=Instance.new("Frame"); bar.Size=UDim2.new(1,0,0,4); bar.Position=UDim2.new(0,0,0,24); bar.BackgroundColor3=THEME.ToggleOff; bar.Parent=row; local barCorner=Instance.new("UICorner"); barCorner.CornerRadius=UDim.new(1,0); barCorner.Parent=bar
    local fill=Instance.new("Frame"); fill.Size=UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3=THEME.Accent; fill.Parent=bar; local fillCorner=Instance.new("UICorner"); fillCorner.CornerRadius=UDim.new(1,0); fillCorner.Parent=fill
    local draggingSlider=false; local function updateSlider(input) local pos=math.clamp((input.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); local val=min+(max-min)*pos; if isFloat then val=math.floor(val*10)/10 else val=math.floor(val) end; fill.Size=UDim2.new(pos,0,1,0); valueLbl.Text=tostring(val); if callback then callback(val) end end
    bar.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then draggingSlider=true updateSlider(input) end end)
    UserInputService.InputChanged:Connect(function(input) if draggingSlider and input.UserInputType==Enum.UserInputType.MouseMovement then updateSlider(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then draggingSlider=false end end)
end

local function addDropdown(card,name,options,default,callback)
    local row=Instance.new("Frame"); row.Name=name; row.Size=UDim2.new(1,0,0,26); row.BackgroundTransparency=1; row.Parent=card; table.insert(registeredRows,{Frame=row,Name=name:lower()})
    local title=Instance.new("TextLabel"); title.Size=UDim2.new(1,-120,1,0); title.BackgroundTransparency=1; title.Text=name; title.Font=Enum.Font.GothamMedium; title.TextSize=11; title.TextColor3=THEME.TextPrimary; title.TextXAlignment=Enum.TextXAlignment.Left; title.Parent=row
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0,110,0,20); btn.Position=UDim2.new(1,-110,0.5,-10); btn.BackgroundColor3=THEME.BadgeBg; btn.Text=default; btn.Font=Enum.Font.GothamMedium; btn.TextSize=10.5; btn.TextColor3=THEME.TextMuted; btn.Parent=row; local bc=Instance.new("UICorner"); bc.CornerRadius=UDim.new(0,4); bc.Parent=btn; local bs=Instance.new("UIStroke"); bs.Color=THEME.Border; bs.Thickness=0.8; bs.Parent=btn
    local function buildDrop(btn) if ActiveDropdown then ActiveDropdown:Destroy() ActiveDropdown=nil return end local drop=Instance.new("Frame"); drop.Size=UDim2.new(0,110,0,math.min(#options*22+6,100)); drop.Position=UDim2.new(0,0,1,2); drop.BackgroundColor3=Color3.fromRGB(24,18,20); drop.ZIndex=30; drop.Parent=btn; local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,6); c.Parent=drop; local s=Instance.new("UIStroke"); s.Color=THEME.Border; s.Thickness=1; s.Parent=drop; local list=Instance.new("UIListLayout"); list.Padding=UDim.new(0,1); list.Parent=drop; local pad=Instance.new("UIPadding"); pad.PaddingTop=UDim.new(0,3); pad.PaddingBottom=UDim.new(0,3); pad.PaddingLeft=UDim.new(0,5); pad.PaddingRight=UDim.new(0,5); pad.Parent=drop; local scroll=Instance.new("ScrollingFrame"); scroll.Size=UDim2.new(1,0,1,0); scroll.BackgroundTransparency=1; scroll.ScrollBarThickness=2; scroll.Parent=drop; local slist=Instance.new("UIListLayout"); slist.Parent=scroll; for _,opt in ipairs(options) do local ob=Instance.new("TextButton"); ob.Size=UDim2.new(1,0,0,20); ob.BackgroundTransparency=1; ob.Text=" "..tostring(opt); ob.Font=Enum.Font.GothamMedium; ob.TextSize=10.5; ob.TextColor3=THEME.TextPrimary; ob.TextXAlignment=Enum.TextXAlignment.Left; ob.ZIndex=31; ob.Parent=scroll; ob.MouseEnter:Connect(function() ob.TextColor3=THEME.Accent end); ob.MouseLeave:Connect(function() ob.TextColor3=THEME.TextPrimary end); ob.MouseButton1Click:Connect(function() btn.Text=tostring(opt); drop:Destroy(); ActiveDropdown=nil; if callback then callback(opt) end end) end; ActiveDropdown=drop end; btn.MouseButton1Click:Connect(function() buildDrop(btn) end)
end

SearchInput:GetPropertyChangedSignal("Text"):Connect(function() local query=SearchInput.Text:lower(); for _,item in ipairs(registeredRows) do if query=="" or string.find(item.Name,query,1,true) then item.Frame.Visible=true else item.Frame.Visible=false end end end)

local function clearTabs() for _,child in ipairs(ContentArea:GetChildren()) do if child:IsA("ScrollingFrame") then for _,obj in ipairs(child:GetChildren()) do if not obj:IsA("UIListLayout") then obj:Destroy() end end end end table.clear(registeredRows) end

-- Tab Builders
local function buildAimbotTab()
    clearTabs()
    local c1=createCard(Col1,"Main Aimbot",1); addToggle(c1,"Enabled","Toggle Aimbot",Settings.AimbotEnabled,nil,function(v) toggleFeature("AimbotEnabled",v) end); addDropdown(c1,"Mode",{"Hold","Toggle"},Settings.AimbotMode,function(v) Settings.AimbotMode=v end); addDropdown(c1,"Key",{"MouseButton1","MouseButton2","LeftControl","LeftShift","Q","E","R","T","F","G","V","X","C"},Settings.AimbotKey,function(v) Settings.AimbotKey=v end); addDropdown(c1,"Aim Type",{"Mouse","Camera"},Settings.AimType,function(v) Settings.AimType=v end); addSlider(c1,"FOV",10,360,Settings.FOV,false,function(v) Settings.FOV=v end); addSlider(c1,"Smoothness",0,10,Settings.Smoothness,true,function(v) Settings.Smoothness=v end)
    local c2=createCard(Col2,"Aimbot Checks",1); addToggle(c2,"Show FOV","Draw FOV Circle",Settings.ShowFOV,nil,function(v) Settings.ShowFOV=v end); addToggle(c2,"Visible Check","Check for walls",Settings.VisibleCheck,nil,function(v) Settings.VisibleCheck=v end); addToggle(c2,"Check Team","Ignore teammates",Settings.CheckTeam,nil,function(v) Settings.CheckTeam=v end)
end

local function buildSilentTab()
    clearTabs()
    local c1=createCard(Col1,"Silent Aim",1); addToggle(c1,"Enabled","Silent Aim",Settings.SilentAimEnabled,nil,function(v) toggleFeature("SilentAimEnabled",v) end); addSlider(c1,"FOV",10,500,Settings.SilentAimFOV,false,function(v) Settings.SilentAimFOV=v end); addToggle(c1,"Show FOV",nil,Settings.SilentAimShowFOV,nil,function(v) Settings.SilentAimShowFOV=v end); addSlider(c1,"Hit Chance (%)",0,100,Settings.SilentAimHitChance,false,function(v) Settings.SilentAimHitChance=v end); addToggle(c1,"Visible Check",nil,Settings.SilentAimVisibleCheck,nil,function(v) Settings.SilentAimVisibleCheck=v end); addToggle(c1,"Check Team",nil,Settings.SilentAimCheckTeam,nil,function(v) Settings.SilentAimCheckTeam=v end)
    local c2=createCard(Col2,"Trigger Bot",1); addToggle(c2,"Enabled","Trigger Bot",Settings.TriggerBotEnabled,nil,function(v) toggleFeature("TriggerBotEnabled",v) end); addSlider(c2,"Delay (ms)",0,200,Settings.TriggerBotDelay,false,function(v) Settings.TriggerBotDelay=v end); addToggle(c2,"Visible Check",nil,Settings.TriggerBotVisibleCheck,nil,function(v) Settings.TriggerBotVisibleCheck=v end); addToggle(c2,"Check Team",nil,Settings.TriggerBotCheckTeam,nil,function(v) Settings.TriggerBotCheckTeam=v end)
end

local function buildEspTab()
    clearTabs()
    local c1=createCard(Col1,"Player ESP",1); addToggle(c1,"Boxes","Draw player boxes",Settings.ESPEnabled,nil,function(v) Settings.ESPEnabled=v end); addToggle(c1,"Tracers","Draw lines to players",Settings.TracersEnabled,nil,function(v) Settings.TracersEnabled=v end); addToggle(c1,"Chams","Highlight players",Settings.ChamsEnabled,nil,function(v) Settings.ChamsEnabled=v end); addToggle(c1,"Ignore Walls","Don't darken through walls",Settings.ESPIgnoreWalls,nil,function(v) Settings.ESPIgnoreWalls=v end)
    local c2=createCard(Col2,"NPC ESP",1); addToggle(c2,"Boxes","Draw NPC boxes",Settings.NPCESPEnabled,nil,function(v) Settings.NPCESPEnabled=v end); addToggle(c2,"Tracers","Draw NPC tracers",Settings.NPCTracersEnabled,nil,function(v) Settings.NPCTracersEnabled=v end); addToggle(c2,"Chams","Highlight NPCs",Settings.NPCChamsEnabled,nil,function(v) Settings.NPCChamsEnabled=v end)
end

local function buildMovementTab()
    clearTabs()
    local c1=createCard(Col1,"Movement",1); addToggle(c1,"Fly","Toggle flying",Settings.FlyEnabled,nil,function(v) toggleFeature("FlyEnabled",v) end); addSlider(c1,"Fly Speed",1,150,Settings.FlySpeed,false,function(v) Settings.FlySpeed=v end); addToggle(c1,"Noclip","Walk through walls",Settings.NoclipEnabled,nil,function(v) toggleFeature("NoclipEnabled",v) end); addToggle(c1,"Speed","Modify walkspeed",Settings.SpeedEnabled,nil,function(v) toggleFeature("SpeedEnabled",v) end); addSlider(c1,"Speed Value",10,100,Settings.SpeedValue,false,function(v) Settings.SpeedValue=v end); addToggle(c1,"Jump Power","Modify jump",Settings.JumpPowerEnabled,nil,function(v) toggleFeature("JumpPowerEnabled",v) end); addSlider(c1,"Jump Power Value",20,200,Settings.JumpPowerValue,false,function(v) Settings.JumpPowerValue=v end)
    local c2=createCard(Col2,"Extra Movement",1); addToggle(c2,"Infinite Jump","Jump forever",Settings.InfJumpEnabled,nil,function(v) toggleFeature("InfJumpEnabled",v) end); addToggle(c2,"Anti-Fling","Stop flinging",Settings.AntiflingEnabled,nil,function(v) toggleFeature("AntiflingEnabled",v) end); addToggle(c2,"Auto Jump","Jump automatically",Settings.AutoJumpEnabled,nil,function(v) toggleFeature("AutoJumpEnabled",v) end); addToggle(c2,"Spin","Spin character",Settings.SpinEnabled,nil,function(v) toggleFeature("SpinEnabled",v) end); addSlider(c2,"Spin Speed",1,100,Settings.SpinSpeed,false,function(v) Settings.SpinSpeed=v end); addToggle(c2,"Full Bright","Light up the map",Settings.FullBrightEnabled,nil,function(v) toggleFeature("FullBrightEnabled",v) end)
end

local function buildFarmTab()
    clearTabs()
    local c1=createCard(Col1,"AutoFarm Coins",1); addToggle(c1,"Enabled","Auto-collect coins",Settings.AutoFarmEnabled,nil,function(v) toggleFeature("AutoFarmEnabled",v) end); addSlider(c1,"Delay (sec)",1,30,Settings.AutoFarmDelay,false,function(v) Settings.AutoFarmDelay=v end); addSlider(c1,"TP Delay",0.1,2,Settings.AutoFarmTPDelay,true,function(v) Settings.AutoFarmTPDelay=v end)
end

local tabButtons = {}
local function resetSidebarVisuals() for _,btnObj in pairs(tabButtons) do TweenService:Create(btnObj.Btn,TWEEN_FAST,{BackgroundTransparency=1}):Play(); TweenService:Create(btnObj.Stroke,TWEEN_FAST,{Transparency=1}):Play(); TweenService:Create(btnObj.Icon,TWEEN_FAST,{ImageColor3=THEME.TextMuted}):Play(); TweenService:Create(btnObj.Title,TWEEN_FAST,{TextColor3=THEME.TextMuted}):Play() end end
local function activateTab(btnObj,buildFunc) resetSidebarVisuals(); TweenService:Create(btnObj.Btn,TWEEN_FAST,{BackgroundTransparency=0,BackgroundColor3=THEME.SidebarActive}):Play(); TweenService:Create(btnObj.Stroke,TWEEN_FAST,{Transparency=0,Color=THEME.BorderActive}):Play(); TweenService:Create(btnObj.Icon,TWEEN_FAST,{ImageColor3=THEME.Accent}):Play(); TweenService:Create(btnObj.Title,TWEEN_FAST,{TextColor3=THEME.TextPrimary}):Play(); buildFunc() end

local function addSidebarItem(name,iconId,order,buildFunc)
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,-4,0,29); btn.LayoutOrder=order; btn.BackgroundColor3=THEME.Background; btn.BackgroundTransparency=1; btn.Text=""; btn.AutoButtonColor=false; btn.Parent=Sidebar; local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,6); c.Parent=btn; local stroke=Instance.new("UIStroke"); stroke.Color=THEME.BorderActive; stroke.Transparency=1; stroke.Thickness=1; stroke.Parent=btn; local icon=Instance.new("ImageLabel"); icon.Size=UDim2.new(0,14,0,14); icon.Position=UDim2.new(0,9,0.5,-7); icon.BackgroundTransparency=1; icon.Image=iconId; icon.ImageColor3=THEME.TextMuted; icon.Parent=btn; local title=Instance.new("TextLabel"); title.Size=UDim2.new(1,-32,1,0); title.Position=UDim2.new(0,30,0,0); title.BackgroundTransparency=1; title.Text=name; title.Font=Enum.Font.GothamMedium; title.TextSize=11; title.TextColor3=THEME.TextMuted; title.TextXAlignment=Enum.TextXAlignment.Left; title.Parent=btn; local btnObj={Btn=btn,Icon=icon,Title=title,Stroke=stroke}; table.insert(tabButtons,btnObj)
    btn.MouseEnter:Connect(function() if activeSidebarTab~=btnObj then TweenService:Create(title,TWEEN_FAST,{TextColor3=THEME.TextPrimary}):Play(); TweenService:Create(icon,TWEEN_FAST,{ImageColor3=THEME.TextPrimary}):Play() end end)
    btn.MouseLeave:Connect(function() if activeSidebarTab~=btnObj then TweenService:Create(title,TWEEN_FAST,{TextColor3=THEME.TextMuted}):Play(); TweenService:Create(icon,TWEEN_FAST,{ImageColor3=THEME.TextMuted}):Play() end end)
    btn.MouseButton1Click:Connect(function() activeSidebarTab=btnObj; activateTab(btnObj,buildFunc) end)
    return btnObj
end

addCategory("Combat",1); local tabAim=addSidebarItem("Aimbot",ICONS.Combat,2,buildAimbotTab); local tabSilent=addSidebarItem("Silent Aim",ICONS.Combat,3,buildSilentTab)
addCategory("Visuals",4); local tabEsp=addSidebarItem("ESP",ICONS.Visuals,5,buildEspTab)
addCategory("Player",6); local tabMove=addSidebarItem("Movement",ICONS.Movement,7,buildMovementTab)
addCategory("Farming",8); local tabFarm=addSidebarItem("AutoFarm",ICONS.AutoBuy,9,buildFarmTab)

activeSidebarTab=tabAim; activateTab(tabAim,buildAimbotTab)

-- Toggle Visibility via RightShift (LeftControl conflicts with Roblox crouch)
local isUIVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        isUIVisible = not isUIVisible
        if isUIVisible then Main.Visible=true; TweenService:Create(Main,TWEEN_SLOW,{Position=UDim2.new(0.5,-395,0.5,-245),BackgroundTransparency=0}):Play(); TweenService:Create(GlowBackdrop,TWEEN_SLOW,{ImageTransparency=0.83}):Play()
        else local hideTween=TweenService:Create(Main,TWEEN_SLOW,{Position=UDim2.new(0.5,-395,0.5,-215),BackgroundTransparency=1}); TweenService:Create(GlowBackdrop,TWEEN_SLOW,{ImageTransparency=1}):Play(); hideTween:Play(); hideTween.Completed:Connect(function() if not isUIVisible then Main.Visible=false end end) end
    end
end)
