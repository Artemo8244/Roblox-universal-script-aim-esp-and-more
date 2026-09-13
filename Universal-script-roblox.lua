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
    SilentAimFOV = 150,
    SilentAimHitChance = 100,
    SilentAimVisibleCheck = true,
    SilentAimCheckTeam = true,
    SilentAimShowFOV = true,
    
    TriggerBotEnabled = false,
    TriggerBotDelay = 50,
    TriggerBotVisibleCheck = true,
    TriggerBotCheckTeam = true,
    
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
    
    ESPEnabled = false,
    TracersEnabled = false,
    ChamsEnabled = false,
    ESPIgnoreWalls = false,
    NPCESPEnabled = false,
    NPCTracersEnabled = false,
    NPCChamsEnabled = false,
    
    AutoFarmEnabled = false,
    AutoFarmDelay = 5,
    AutoFarmTPDelay = 0.2,
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
local TriggerBotConnection = nil
local SilentAimConnection = nil
local AutoFarmRunning = false
local OriginalBrightness = Lighting.Brightness
local OriginalAmbient = Lighting.Ambient
local OriginalOutdoorAmbient = Lighting.OutdoorAmbient

local ESP_CONFIG = {
    TOP_OFFSET = Vector3.new(0, 3, 0),
    BOTTOM_OFFSET = Vector3.new(0, 3.5, 0),
    DISTANCE_DIVISOR = 3.5,
    MIN_HEIGHT = 6,
    MIN_WIDTH = 4
}
local ESP_Cache = {}
local ChamsObjects = {}
local Visibility_Cache = {}
local Tracked_NPCs = {}

local MM2Roles = {}

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function refreshRayFilter()
    local list = {}
    local char = LocalPlayer.Character
    local cam = workspace.CurrentCamera
    if char then table.insert(list, char) end
    if cam then table.insert(list, cam) end
    rayParams.FilterDescendantsInstances = list
end

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

local function isMM2()
    return game.PlaceId == 142823291
end

local function isPlayerAlive(player)
    if not player or not player.Character then return false end
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    return hum.Health > 0
end

local function IsNPC(model)
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not model:FindFirstChild("HumanoidRootPart") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    return true
end

local function CheckAndAddNPC(obj)
    if IsNPC(obj) then Tracked_NPCs[obj] = true end
end

local function RemoveNPC(obj)
    if Tracked_NPCs[obj] then
        Tracked_NPCs[obj] = nil
        if ESP_Cache[obj] then
            ESP_Cache[obj].Box:Remove()
            ESP_Cache[obj].Text:Remove()
            ESP_Cache[obj].Tracer:Remove()
            ESP_Cache[obj] = nil
        end
        if ChamsObjects[obj] then
            for _, o in pairs(ChamsObjects[obj]) do if o then o:Destroy() end end
            ChamsObjects[obj] = nil
        end
    end
end

task.spawn(function()
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then CheckAndAddNPC(obj) end
        count = count + 1
        if count % 500 == 0 then task.wait() end
    end
end)

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") then
        task.delay(0.5, function() CheckAndAddNPC(obj) end)
    end
end)
workspace.DescendantRemoving:Connect(RemoveNPC)

local function GetVisibility(targetId, char)
    local currentTime = tick()
    if Visibility_Cache[targetId] and (currentTime - Visibility_Cache[targetId].lastUpdate) < 0.1 then
        return Visibility_Cache[targetId].isVisible
    end
    
    local cam = workspace.CurrentCamera
    if not cam then return false end
    
    local partsToCheck = {
        char:FindFirstChild("Head"),
        char:FindFirstChild("HumanoidRootPart"),
        char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm"),
        char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm"),
        char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg"),
        char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg")
    }
    
    local origin = cam.CFrame.Position
    local isVisible = false
    for _, part in pairs(partsToCheck) do
        if part and part:IsA("BasePart") then
            local result = workspace:Raycast(origin, part.Position - origin, rayParams)
            if result and result.Instance:IsDescendantOf(char) then
                isVisible = true
                break
            end
        end
    end
    
    Visibility_Cache[targetId] = { isVisible = isVisible, lastUpdate = currentTime }
    return isVisible
end

local function HideESP(id)
    local cached = ESP_Cache[id]
    if not cached then return end
    cached.Box.Visible = false
    cached.Text.Visible = false
    cached.Tracer.Visible = false
end

local function ClearEntityESP(id)
    if ESP_Cache[id] then
        ESP_Cache[id].Box:Remove()
        ESP_Cache[id].Text:Remove()
        ESP_Cache[id].Tracer:Remove()
        ESP_Cache[id] = nil
    end
    Visibility_Cache[id] = nil
end

local function removeChams(id)
    if ChamsObjects[id] then
        for _, obj in pairs(ChamsObjects[id]) do
            if obj then obj:Destroy() end
        end
        ChamsObjects[id] = nil
    end
end

local function applyChams(id, char, color)
    if not ChamsObjects[id] then ChamsObjects[id] = {} end
    local existing = ChamsObjects[id][1]
    if existing and existing.Parent == char then
        existing.FillColor = color
        existing.OutlineColor = color
        existing.Enabled = true
    else
        removeChams(id)
        local hl = Instance.new("Highlight")
        hl.Name = "DeepHubChams"
        hl.FillColor = color
        hl.OutlineColor = color
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = char
        hl.Parent = char
        ChamsObjects[id] = {hl}
    end
end

Players.PlayerRemoving:Connect(function(player)
    ClearEntityESP(tostring(player.UserId))
    removeChams(tostring(player.UserId))
end)


local function getESPColor(player, isNPC, visible)
  
    if isNPC then
        if Settings.ESPIgnoreWalls then
            return Color3.fromRGB(0, 200, 255) 
        end
        return visible and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(200, 0, 255)
    end
    
    local isTeammate = false
    if player and player.Team and LocalPlayer.Team then
        if player.Team == LocalPlayer.Team then
            isTeammate = true
        end
    end
    

    if isTeammate then
        return Color3.fromRGB(0, 255, 0)
    end
    

    if isMM2() and player and MM2Roles[player] then
        local role = MM2Roles[player]
        if role == "Murderer" then return Color3.fromRGB(255, 50, 50) end
        if role == "Sheriff" then return Color3.fromRGB(50, 150, 255) end
        if role == "Innocent" then return Color3.fromRGB(50, 255, 50) end
    end
    

    if Settings.ESPIgnoreWalls then
        if player and player.Team and player.Team.TeamColor then
            return player.Team.TeamColor.Color
        end
        return Color3.fromRGB(0, 255, 0)
    end
    

    if player and player.Team and player.Team.TeamColor then
        local teamColor = player.Team.TeamColor.Color
        if not visible then
            teamColor = Color3.new(teamColor.R * 0.5, teamColor.G * 0.5, teamColor.B * 0.5)
        end
        return teamColor
    end
    

    if visible then
        return Color3.fromRGB(0, 255, 0)
    else
        return Color3.fromRGB(255, 0, 0)
    end
end

local function DrawESP(id, char, hrp, name, player, isNPC)
    local showBox = isNPC and Settings.NPCESPEnabled or (not isNPC and Settings.ESPEnabled)
    local showTracer = isNPC and Settings.NPCTracersEnabled or (not isNPC and Settings.TracersEnabled)
    local showChams = isNPC and Settings.NPCChamsEnabled or (not isNPC and Settings.ChamsEnabled)
    
    if not showBox and not showTracer and not showChams then 
        removeChams(id)
        return 
    end
    
    local cam = workspace.CurrentCamera
    if not cam then return end
    
    local dist = (cam.CFrame.Position - hrp.Position).Magnitude
    if dist == 0 then return end
    
    local rootScreen, onScreen = cam:WorldToViewportPoint(hrp.Position)
    
    local visible = GetVisibility(id, char)
    local renderColor = getESPColor(player, isNPC, visible)
    
    if showChams then
        applyChams(id, char, renderColor)
    else
        removeChams(id)
    end
    
    if not onScreen then return end
    
    if not ESP_Cache[id] then
        ESP_Cache[id] = { Box = Drawing.new("Square"), Text = Drawing.new("Text"), Tracer = Drawing.new("Line") }
        ESP_Cache[id].Box.Thickness = 1.5; ESP_Cache[id].Box.Filled = false
        ESP_Cache[id].Text.Size = 14; ESP_Cache[id].Text.Center = true; ESP_Cache[id].Text.Outline = true
        ESP_Cache[id].Tracer.Thickness = 1.5
    end
    
    local box, text, tracer = ESP_Cache[id].Box, ESP_Cache[id].Text, ESP_Cache[id].Tracer
    
    local topScreenPos = cam:WorldToViewportPoint(hrp.Position + ESP_CONFIG.TOP_OFFSET)
    local bottomScreenPos = cam:WorldToViewportPoint(hrp.Position - ESP_CONFIG.BOTTOM_OFFSET)
    
    local height = math.abs(bottomScreenPos.Y - topScreenPos.Y)
    local width = height / 2
    if height < ESP_CONFIG.MIN_HEIGHT then
        height = ESP_CONFIG.MIN_HEIGHT; width = ESP_CONFIG.MIN_WIDTH
    end
    
    if showBox then
        box.Size = Vector2.new(width, height)
        box.Position = Vector2.new(rootScreen.X - (width / 2), topScreenPos.Y)
        box.Color = renderColor
        box.Visible = true
        
        local prefix = isNPC and "[NPC] " or ""
        text.Text = string.format("%s%s [%dm]", prefix, name, math.floor(dist / ESP_CONFIG.DISTANCE_DIVISOR))
        text.Position = Vector2.new(rootScreen.X, topScreenPos.Y - 18)
        text.Color = renderColor
        text.Visible = true
    end
    
    if showTracer then
        tracer.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
        tracer.To = Vector2.new(rootScreen.X, bottomScreenPos.Y)
        tracer.Color = renderColor
        tracer.Visible = true
    end
end

local function updateMM2Roles()
    if not isMM2() then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        if not isPlayerAlive(player) then
            MM2Roles[player] = nil
            continue
        end
        local char = player.Character
        local equipped = char:FindFirstChildOfClass("Tool")
        if equipped then
            local tn = equipped.Name:lower()
            if tn:find("knife") or tn:find("нож") then
                MM2Roles[player] = "Murderer"
            elseif tn:find("revolver") or tn:find("gun") or tn:find("pistol") or tn:find("bow") or tn:find("лук") then
                MM2Roles[player] = "Sheriff"
            end
        end
    end
end

local function checkRoundReset()
    if not isMM2() then return end
    local char = LocalPlayer.Character
    if not char then
        MM2Roles = {}
        return
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then
        MM2Roles = {}
    end
end

local function isCoin(obj)
    if not obj then return false end
    local n = obj.Name:lower()
    if n:find("coin") then
        if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Model") or obj:IsA("UnionOperation") then
            return true
        end
    end
    return false
end

local function getCoinPosition(coin)
    if coin:IsA("BasePart") or coin:IsA("MeshPart") or coin:IsA("UnionOperation") then
        return coin.Position
    elseif coin:IsA("Model") then
        local primary = coin.PrimaryPart or coin:FindFirstChildWhichIsA("BasePart")
        if primary then return primary.Position end
    end
    return nil
end

local function findCoins()
    local coins = {}
    local searchAreas = {}
    if workspace:FindFirstChild("Map") then table.insert(searchAreas, workspace.Map) end
    if workspace:FindFirstChild("Debris") then table.insert(searchAreas, workspace.Debris) end
    if workspace:FindFirstChild("Coins") then table.insert(searchAreas, workspace.Coins) end
    if #searchAreas == 0 then searchAreas = {workspace} end
    for _, area in pairs(searchAreas) do
        for _, obj in pairs(area:GetDescendants()) do
            if isCoin(obj) then table.insert(coins, obj) end
        end
    end
    return coins
end

local function toggleAutoFarm()
    if AutoFarmRunning then return end
    AutoFarmRunning = true
    task.spawn(function()
        while Settings.AutoFarmEnabled do
            local char = LocalPlayer.Character
            if not char then task.wait(1) continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then task.wait(1) continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then task.wait(1) continue end
            
            local coins = findCoins()
            if #coins == 0 then task.wait(1) continue end
            
            local closestCoin, closestPos, closestDist = nil, nil, math.huge
            for _, coin in pairs(coins) do
                local pos = getCoinPosition(coin)
                if pos then
                    local dist = (pos - root.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestCoin = coin
                        closestPos = pos
                    end
                end
            end
            
            if closestPos then
                root.CFrame = CFrame.new(closestPos)
                task.wait(Settings.AutoFarmTPDelay)
                task.wait(Settings.AutoFarmDelay)
            else
                task.wait(0.5)
            end
        end
        AutoFarmRunning = false
    end)
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
        if AutoJumpConnection then AutoJumpConnection:Disconnect() AutoJumpConnection = nil end
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
        if SpinConnection then SpinConnection:Disconnect() SpinConnection = nil end
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
        if FullBrightConnection then FullBrightConnection:Disconnect() FullBrightConnection = nil end
        Lighting.Brightness = OriginalBrightness
        Lighting.Ambient = OriginalAmbient
        Lighting.OutdoorAmbient = OriginalOutdoorAmbient
    end
end

local FOVCircle = nil
local LegitFOVCircle = nil
local SilentFOVCircle = nil

local function updateFOVCircle()
    if FOVCircle then FOVCircle:Remove() FOVCircle = nil end
    if LegitFOVCircle then LegitFOVCircle:Remove() LegitFOVCircle = nil end
    if SilentFOVCircle then SilentFOVCircle:Remove() SilentFOVCircle = nil end
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
    if Settings.SilentAimEnabled and Settings.SilentAimShowFOV then
        SilentFOVCircle = Drawing.new("Circle")
        SilentFOVCircle.Thickness = 2
        SilentFOVCircle.NumSides = 64
        SilentFOVCircle.Radius = Settings.SilentAimFOV
        SilentFOVCircle.Color = Color3.fromRGB(255, 200, 0)
        SilentFOVCircle.Filled = false
        SilentFOVCircle.Visible = true
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

local function isTriggerTeammate(plr)
    if not Settings.TriggerBotCheckTeam then return false end
    if not LocalPlayer.Team or not plr.Team then return false end
    return LocalPlayer.Team == plr.Team
end

local function isSilentTeammate(plr)
    if not Settings.SilentAimCheckTeam then return false end
    if not LocalPlayer.Team or not plr.Team then return false end
    return LocalPlayer.Team == plr.Team
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

local function isTriggerVisible(targetCharacter)
    if not Settings.TriggerBotVisibleCheck then return true end
    local targetPart = targetCharacter:FindFirstChild(Settings.TargetPart)
    if not targetPart then return false end
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
    local camPos = Camera.CFrame.Position
    local raycastResult = workspace:Raycast(camPos, (targetPart.Position - camPos), raycastParams)
    return raycastResult == nil
end

local function isSilentVisible(targetCharacter)
    if not Settings.SilentAimVisibleCheck then return true end
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

local function getSilentTarget()
    local closestPlayer = nil
    local shortestDistance = Settings.SilentAimFOV
    local mousePos = UserInputService:GetMouseLocation()
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        if isSilentTeammate(player) then continue end
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        local targetPart = player.Character:FindFirstChild(Settings.TargetPart)
        if not targetPart then continue end
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if distance < shortestDistance and isSilentVisible(player.Character) then
            shortestDistance = distance
            closestPlayer = player
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

local function toggleTriggerBot()
    if TriggerBotConnection then TriggerBotConnection:Disconnect() TriggerBotConnection = nil end
    if not Settings.TriggerBotEnabled then return end
    
    TriggerBotConnection = RunService.RenderStepped:Connect(function()
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
        local mousePos = UserInputService:GetMouseLocation()
        local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
        local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)
        if result and result.Instance then
            local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
            if hitChar then
                local hitPlayer = Players:GetPlayerFromCharacter(hitChar)
                if hitPlayer and hitPlayer ~= LocalPlayer then
                    if isTriggerTeammate(hitPlayer) then return end
                    if not isTriggerVisible(hitChar) then return end
                    if Settings.TriggerBotDelay > 0 then task.wait(Settings.TriggerBotDelay / 1000) end
                    if mouse1press and mouse1release then
                        mouse1press()
                        task.wait()
                        mouse1release()
                    end
                end
            end
        end
    end)
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
        if part:IsA("BasePart") then part.CanCollide = false end
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
    if hum then hum.JumpPower = originalJumpPower end
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
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end    if speedConnection then speedConnection:Disconnect() speedConnection = nil end
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
    setupSilentAim()
    toggleAutoJump()
    toggleSpin()
    toggleFullBright()
    toggleTriggerBot()
end

local function toggleFeature(name, state)
    if state == nil then state = not Settings[name] end
    Settings[name] = state
    if name == "AimbotEnabled" or name == "LegitBotEnabled" or name == "ShowFOV" or name == "SilentAimEnabled" or name == "SilentAimShowFOV" or name == "SilentAimFOV" then
        updateFOVCircle()
        setupSilentAim()
    elseif name == "AutoFarmEnabled" then
        if state then toggleAutoFarm() end
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

AimbotTab:CreateSection("Silent Aim (без бинда)")
AimbotTab:CreateToggle({Name = "Silent Aim", CurrentValue = Settings.SilentAimEnabled, Flag = "SilentAimEnabled", Callback = function(Value) Settings.SilentAimEnabled = Value toggleFeature("SilentAimEnabled", Value) end})
AimbotTab:CreateSlider({Name = "Silent FOV", Range = {10, 500}, Increment = 1, Suffix = "°", CurrentValue = Settings.SilentAimFOV, Flag = "SilentAimFOV", Callback = function(Value) Settings.SilentAimFOV = Value updateFOVCircle() end})
AimbotTab:CreateToggle({Name = "Show Silent FOV", CurrentValue = Settings.SilentAimShowFOV, Flag = "SilentAimShowFOV", Callback = function(Value) Settings.SilentAimShowFOV = Value updateFOVCircle() end})
AimbotTab:CreateSlider({Name = "Hit Chance", Range = {0, 100}, Increment = 1, Suffix = "%", CurrentValue = Settings.SilentAimHitChance, Flag = "SilentAimHitChance", Callback = function(Value) Settings.SilentAimHitChance = Value end})
AimbotTab:CreateToggle({Name = "Visible Check", CurrentValue = Settings.SilentAimVisibleCheck, Flag = "SilentAimVisibleCheck", Callback = function(Value) Settings.SilentAimVisibleCheck = Value end})
AimbotTab:CreateToggle({Name = "Check Team", CurrentValue = Settings.SilentAimCheckTeam, Flag = "SilentAimCheckTeam", Callback = function(Value) Settings.SilentAimCheckTeam = Value end})

AimbotTab:CreateSection("Trigger Bot")
AimbotTab:CreateToggle({Name = "Trigger Bot", CurrentValue = Settings.TriggerBotEnabled, Flag = "TriggerBotEnabled", Callback = function(Value) Settings.TriggerBotEnabled = Value toggleFeature("TriggerBotEnabled", Value) end})
AimbotTab:CreateSlider({Name = "Delay (ms)", Range = {0, 200}, Increment = 1, Suffix = "ms", CurrentValue = Settings.TriggerBotDelay, Flag = "TriggerBotDelay", Callback = function(Value) Settings.TriggerBotDelay = Value end})
AimbotTab:CreateToggle({Name = "Visible Check", CurrentValue = Settings.TriggerBotVisibleCheck, Flag = "TriggerBotVisibleCheck", Callback = function(Value) Settings.TriggerBotVisibleCheck = Value end})
AimbotTab:CreateToggle({Name = "Check Team", CurrentValue = Settings.TriggerBotCheckTeam, Flag = "TriggerBotCheckTeam", Callback = function(Value) Settings.TriggerBotCheckTeam = Value end})

local ESPTab = Window:CreateTab("ESP", 1)
ESPTab:CreateSection("Player ESP")
ESPTab:CreateToggle({Name = "Player ESP", CurrentValue = Settings.ESPEnabled, Flag = "ESPEnabled", Callback = function(Value) Settings.ESPEnabled = Value end})
ESPTab:CreateToggle({Name = "ESP Tracers", CurrentValue = Settings.TracersEnabled, Flag = "TracersEnabled", Callback = function(Value) Settings.TracersEnabled = Value end})
ESPTab:CreateToggle({Name = "Player Chams", CurrentValue = Settings.ChamsEnabled, Flag = "ChamsEnabled", Callback = function(Value) Settings.ChamsEnabled = Value end})
ESPTab:CreateToggle({Name = "Ignore Walls (не затемнять)", CurrentValue = Settings.ESPIgnoreWalls, Flag = "ESPIgnoreWalls", Callback = function(Value) Settings.ESPIgnoreWalls = Value end})
ESPTab:CreateSection("NPC ESP")
ESPTab:CreateToggle({Name = "NPC ESP", CurrentValue = Settings.NPCESPEnabled, Flag = "NPCESPEnabled", Callback = function(Value) Settings.NPCESPEnabled = Value end})
ESPTab:CreateToggle({Name = "NPC Tracers", CurrentValue = Settings.NPCTracersEnabled, Flag = "NPCTracersEnabled", Callback = function(Value) Settings.NPCTracersEnabled = Value end})
ESPTab:CreateToggle({Name = "NPC Chams", CurrentValue = Settings.NPCChamsEnabled, Flag = "NPCChamsEnabled", Callback = function(Value) Settings.NPCChamsEnabled = Value end})

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
MovementTab:CreateButton({Name = "Jerk r15", Callback = function()
    loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
end})

local AutoFarmTab = Window:CreateTab("AutoFarm", 3)
AutoFarmTab:CreateSection("AutoFarm (MM2 Coins)")
AutoFarmTab:CreateToggle({Name = "Auto Farm Coins", CurrentValue = Settings.AutoFarmEnabled, Flag = "AutoFarmEnabled", Callback = function(Value) Settings.AutoFarmEnabled = Value toggleFeature("AutoFarmEnabled", Value) end})
AutoFarmTab:CreateSlider({Name = "Задержка перед след. монетой (сек)", Range = {1, 30}, Increment = 1, Suffix = " сек", CurrentValue = Settings.AutoFarmDelay, Flag = "AutoFarmDelay", Callback = function(Value) Settings.AutoFarmDelay = Value end})
AutoFarmTab:CreateSlider({Name = "Задержка телепорта", Range = {0.1, 2}, Increment = 0.1, Suffix = " сек", CurrentValue = Settings.AutoFarmTPDelay, Flag = "AutoFarmTPDelay", Callback = function(Value) Settings.AutoFarmTPDelay = Value end})

local InfoTab = Window:CreateTab("Info", 4)
local infoText = [[
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

AUTO FARM:
  • Задержка: 5 сек (защита от кика!)

ESP:
  • Ignore Walls — не затемняет за стенами
  • Тиммейт — зелёный
  • Враг — цвет команды
  • MM2: 🔴 Маньяк, 🔵 Шериф, 🟢 Невинный

Discord: artemo8244
Telegram: artemo8244
Tiktok: artemo8244
Roblox: Artemo8244
]]
InfoTab:CreateParagraph({Title = "DeepHub", Content = infoText})

RunService.RenderStepped:Connect(function()
    refreshRayFilter()
    
    if isMM2() then
        updateMM2Roles()
        checkRoundReset()
    end
    
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

    if Settings.SilentAimEnabled and Settings.SilentAimShowFOV then
        if not SilentFOVCircle then updateFOVCircle() end
        if SilentFOVCircle then
            local mousePos = UserInputService:GetMouseLocation()
            SilentFOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
            SilentFOVCircle.Radius = Settings.SilentAimFOV
            SilentFOVCircle.Visible = true
        end
    else
        if SilentFOVCircle then SilentFOVCircle:Remove() SilentFOVCircle = nil end
    end

    if Settings.SilentAimEnabled then
        SilentTarget = getSilentTarget()
    else
        SilentTarget = nil
    end

    if Settings.ESPEnabled or Settings.TracersEnabled or Settings.ChamsEnabled or Settings.NPCESPEnabled or Settings.NPCTracersEnabled or Settings.NPCChamsEnabled then
        for id in pairs(ESP_Cache) do HideESP(id) end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and isPlayerAlive(player) then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    DrawESP(tostring(player.UserId), player.Character, hrp, player.Name, player, false)
                end
            end
        end
        
        for npc in pairs(Tracked_NPCs) do
            if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                if hrp then
                    DrawESP(npc, npc, hrp, npc.Name, nil, true)
                end
            end
        end
    else
        for id in pairs(ESP_Cache) do HideESP(id) end
        for id in pairs(ChamsObjects) do removeChams(id) end
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

LocalPlayer.CharacterAdded:Connect(function()
    MM2Roles = {}
end)

Players.PlayerRemoving:Connect(function(player)
    MM2Roles[player] = nil
end)

print("DeepHub Loaded")
