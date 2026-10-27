-- DeepHub — RightControl
local Players=game:GetService("Players") local RS=game:GetService("RunService") local UIS=game:GetService("UserInputService") local TS=game:GetService("TweenService") local Lighting=game:GetService("Lighting") local SS=game:GetService("SoundService")
local P=Players.LocalPlayer local PG=P:WaitForChild("PlayerGui")
local Camera=workspace.CurrentCamera

-- ============ CONFIGS ============
local CONFIG={MenuKey=Enum.KeyCode.RightControl,Enabled=true,ShowHighlight=true,ShowLabel=true,ShowNames=true,ShowDistance=true,ShowHealth=true,ShowTeammates=true,ShowBoxes=false,BoxFill=false,BoxThickness=1.5,ShowTracers=false,TracerOrigin="Снизу",TracerThickness=1.5,MaxDistance=1000,FillTransparency=0.7,OutlineColor=Color3.fromRGB(255,255,255),EnemyColor=Color3.fromRGB(255,60,60),TeamColor=Color3.fromRGB(60,255,60)}
local HAT={Enabled=false,Rainbow=false,Color=Color3.fromRGB(255,90,90),Radius=1.4,Height=0.9,Transparency=0.35,Glow=false,GlowStrength=2,Gap=0.3,Style="Конус",FirstPersonDistance=1.5}
local TRAIL={Enabled=false,Rainbow=false,Color=Color3.fromRGB(90,170,255),Lifetime=1.5,Height=3,Transparency=0.2,Glow=true,GlowStrength=1.5,Style="Лента",FirstPersonDistance=1.5}
local JUMP={Enabled=false,Style="Кольцо",Rainbow=false,Color=Color3.fromRGB(255,255,255),Trigger="Приземление",Radius=4,Duration=0.6,Thickness=0.2,Glow=true,GlowStrength=2}
local PARTS={Enabled=false,Rainbow=false,Color=Color3.fromRGB(255,255,255),Rate=60,Size=0.35,Range=60,Style="Искры",Glow=true,GlowStrength=1.5}
local FOG={Enabled=false,Rainbow=false,Start=0,End=200,Color=Color3.fromRGB(180,190,210),Glow=false,GlowStrength=2}
local SKY={Enabled=false,Preset="Закат"}
local CUR={Enabled=false,Style="Крестик",Rainbow=false,Color=Color3.fromRGB(255,90,90),Size=18,Thickness=2,Outline=true,Spin=false,Transparency=0}
local TESP={Enabled=false,Mode="Все в радиусе",Style="Орбиты",Radius=30,Rainbow=false,Color=Color3.fromRGB(255,90,90),Count=6,Size=0.35,Speed=2,Glow=true,ShowTeammates=true}
local AL={Enabled=true,Position="Справа сверху",Suffix=true,Background=true,Rainbow=false}
local WM={Enabled=true,ShowLogo=true,ShowFPS=true,ShowPing=true,ShowTime=true,ShowSeconds=false,Position="Слева сверху"}
local SND={Enabled=true,Style="Пинг",Volume=0.5,OnPitch=1.25,OffPitch=0.85}
local MS={Theme="Бордовый",Blur=true,AutoSave=true,Toasts=true,Glass=true,GlassLevel=0.45}
local BINDS={}
local AIM={Enabled=false,Mode="Hold",Key="MouseButton2",AimType="Mouse",FOV=150,Smoothness=1.5,TargetPart="Head",VisibleCheck=true,ShowFOV=true,CheckTeam=true}
local LEGIT={Enabled=false,Mode="Hold",Key="MouseButton2",FOV=80,Smoothness=0.3,Speed=15,VisibleCheck=true,CheckTeam=true}
local SILENT={Enabled=false,FOV=150,HitChance=100,VisibleCheck=true,CheckTeam=true,ShowFOV=true,TargetPart="Head"}
local TRIGGER={Enabled=false,Delay=50,VisibleCheck=true,CheckTeam=true,TargetPart="Head",UseMouseButton2=true}
local MOVE={FlyEnabled=false,FlySpeed=30,NoclipEnabled=false,SpeedEnabled=false,SpeedValue=32,InfJumpEnabled=false,AntiflingEnabled=false,JumpPowerEnabled=false,JumpPowerValue=50,AutoJumpEnabled=false,SpinEnabled=false,SpinSpeed=50,FullBrightEnabled=false}
local FARM={Enabled=false,Delay=5,TPDelay=0.2}
local UI={MenuColor=Color3.fromRGB(250,90,106),MenuBgColor=Color3.fromRGB(92,32,44),WmColor=Color3.fromRGB(40,34,52),HudColor=Color3.fromRGB(245,240,248),MenuTransparency=0.04}

local HAT_S={"Конус","Купол","Цилиндр","Нимб"} local TRL_S={"Лента","Крылья","Линия","Комета"} local JMP_S={"Кольцо","Двойное","Пунктир","Шестиугольник"} local JMP_T={"Приземление","Прыжок","Оба"} local PRT_S={"Искры","Снег","Огоньки","Дым"} local SKY_P={"День","Рассвет","Закат","Ночь","Космос","Фэнтези","Шторм"} local CUR_S={"Точка","Крестик","Круг","Ромб"} local TESP_M={"Все в радиусе","Ближайший"} local TESP_S={"Орбиты","Спираль"} local TRC_O={"Снизу","Центр","Курсор"} local AL_P={"Справа сверху","Слева сверху","Справа снизу","Слева снизу"} local SND_S={"Пинг","Клик","Кнопка"}
local KEY_OPTS={"MouseButton1","MouseButton2","LeftControl","LeftShift","Q","E","R","T","F","G","V","X","C"} local MODE_OPTS={"Hold","Toggle"} local AIMTYPE_OPTS={"Mouse","Camera"} local PART_OPTS={"Head","HumanoidRootPart","UpperTorso","Torso"}
local SND_ID={["Пинг"]="rbxasset://sounds/electronicpingshort.wav",["Клик"]="rbxasset://sounds/clickfast.wav",["Кнопка"]="rbxasset://sounds/button.wav"}

-- ============ HELPERS ============
local mk=function(c,p) local o=Instance.new(c) for k,v in pairs(p) do if k~="Parent" then o[k]=v end end if p.Parent then o.Parent=p.Parent end return o end
local rnd=function(o,r) return mk("UICorner",{CornerRadius=UDim.new(0,r),Parent=o}) end
local str=function(o,c,t,th) return mk("UIStroke",{Color=c,Transparency=t or 0.4,Thickness=th or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=o}) end
local tSound=Instance.new("Sound"); tSound.Parent=SS
local function playSnd(on) if not SND.Enabled then return end tSound.SoundId=SND_ID[SND.Style] or SND_ID["Пинг"] tSound.Volume=SND.Volume tSound.PlaybackSpeed=on and SND.OnPitch or SND.OffPitch tSound.TimePosition=0 tSound:Play() end
local wmClicked=Instance.new("BindableEvent")
local function getChar() return P.Character end
local function getHum() local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c=getChar(); return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")) end

local rayParams=RaycastParams.new() rayParams.FilterType=Enum.RaycastFilterType.Exclude
local function refreshRay() local l={} local c=getChar() if c then table.insert(l,c) end if Camera then table.insert(l,Camera) end rayParams.FilterDescendantsInstances=l end

local function isKeyPressed(key)
    if key=="MouseButton1" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif key=="MouseButton2" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    else return UIS:IsKeyDown(Enum.KeyCode[key]) end
end
local function isTeam(plr,checkTeam) if not checkTeam then return false end if not P.Team or not plr.Team then return false end return P.Team==plr.Team end
local function isAlive(plr) if not plr or not plr.Character then return false end local h=plr.Character:FindFirstChildOfClass("Humanoid") return h and h.Health>0 end
local function isVisible(char,targetPart,enabled)
    if not enabled then return true end
    local tp=char:FindFirstChild(targetPart) if not tp then return false end
    local mychar=getChar() if not mychar or not Camera then return false end
    rayParams.FilterDescendantsInstances={mychar,char}
    return workspace:Raycast(Camera.CFrame.Position,(tp.Position-Camera.CFrame.Position),rayParams)==nil
end
local function getClosest(fov,checkTeam,visibleCheck,targetPart)
    local best,bd=nil,fov
    local mouse=UIS:GetMouseLocation()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=P and plr.Character and isAlive(plr) and not isTeam(plr,checkTeam) then
            local tp=plr.Character:FindFirstChild(targetPart)
            if tp then
                local sp,onS=Camera:WorldToViewportPoint(tp.Position)
                if onS then
                    local d=(Vector2.new(sp.X,sp.Y)-mouse).Magnitude
                    if d<bd and isVisible(plr.Character,targetPart,visibleCheck) then bd=d best=plr end
                end
            end
        end
    end
    return best
end

-- FOV circles
local FOVCircle,LegitFOVCircle,SilentFOVCircle
local function newCircle(c) if not Drawing then return nil end local cl=Drawing.new("Circle") cl.Thickness=2 cl.NumSides=64 cl.Filled=false cl.Color=c cl.Visible=false return cl end
local function updateFOVCircles()
    if FOVCircle then FOVCircle:Remove() FOVCircle=nil end
    if LegitFOVCircle then LegitFOVCircle:Remove() LegitFOVCircle=nil end
    if SilentFOVCircle then SilentFOVCircle:Remove() SilentFOVCircle=nil end
    if AIM.Enabled and AIM.ShowFOV then FOVCircle=newCircle(Color3.fromRGB(255,50,50)) end
    if LEGIT.Enabled then LegitFOVCircle=newCircle(Color3.fromRGB(50,255,50)) end
    if SILENT.Enabled and SILENT.ShowFOV then SilentFOVCircle=newCircle(Color3.fromRGB(255,200,0)) end
end

-- Aimbot/Legit toggle state
local aimToggled=false local legitToggled=false
UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if AIM.Mode=="Toggle" then
        local key=AIM.Key local pressed=false
        if key=="MouseButton1" and input.UserInputType==Enum.UserInputType.MouseButton1 then pressed=true
        elseif key=="MouseButton2" and input.UserInputType==Enum.UserInputType.MouseButton2 then pressed=true
        elseif input.KeyCode==Enum.KeyCode[key] then pressed=true end
        if pressed then aimToggled=not aimToggled end
    end
    if LEGIT.Mode=="Toggle" then
        local key=LEGIT.Key local pressed=false
        if key=="MouseButton1" and input.UserInputType==Enum.UserInputType.MouseButton1 then pressed=true
        elseif key=="MouseButton2" and input.UserInputType==Enum.UserInputType.MouseButton2 then pressed=true
        elseif input.KeyCode==Enum.KeyCode[key] then pressed=true end
        if pressed then legitToggled=not legitToggled end
    end
end)

-- Silent aim metatable hook
local SilentTarget=nil
local silentSetup=false
local function setupSilent()
    if silentSetup then return end
    silentSetup=true
    pcall(function()
        local mt=getrawmetatable(game)
        local old=mt.__namecall
        setreadonly(mt,false)
        mt.__namecall=newcclosure(function(self,...)
            local method=getnamecallmethod()
            if method=="Raycast" and self==workspace and SILENT.Enabled then
                if SilentTarget and SilentTarget.Character then
                    local tp=SilentTarget.Character:FindFirstChild(SILENT.TargetPart)
                    if tp and math.random(1,100)<=SILENT.HitChance then
                        local args={...}
                        args[2]=(tp.Position-args[1]).Unit*args[2].Magnitude
                        return old(self,unpack(args))
                    end
                end
            end
            return old(self,...)
        end)
        setreadonly(mt,true)
    end)
end

-- Movement state
local flyBV=nil
local flyConn=nil local noclipConn=nil local speedConn=nil local infJumpConn=nil local antiflingConn=nil local autoJumpConn=nil local spinConn=nil local fullBrightConn=nil
local origBright,origAmb,origOutAmb=Lighting.Brightness,Lighting.Ambient,Lighting.OutdoorAmbient
local origJumpPower=50

-- ============ COLOR/THEME ============
local C={bgTop=Color3.fromRGB(92,32,44),bgBot=Color3.fromRGB(38,14,20),panel=Color3.fromRGB(30,11,16),card=Color3.fromRGB(80,30,40),cardH=Color3.fromRGB(98,38,50),inner=Color3.fromRGB(52,19,27),accent=Color3.fromRGB(250,90,106),accentD=Color3.fromRGB(140,56,70),off=Color3.fromRGB(104,76,82),text=Color3.fromRGB(255,250,251),sub=Color3.fromRGB(226,204,209),line=Color3.fromRGB(160,88,100)}
local LOGO_BG=Color3.fromRGB(14,8,10) local LOGO_MARK=Color3.fromRGB(245,240,241)

-- ============ MENU ============
local menuOk,menuErr=pcall(function()
    local gui=mk("ScreenGui",{Name="DeepHub",ZIndexBehavior=Enum.ZIndexBehavior.Sibling,ResetOnSpawn=false,DisplayOrder=100,Parent=PG})
    _G.__MenuGui=gui
    local frame=mk("Frame",{Name="Window",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(700,470),BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=true,Parent=gui})
    rnd(frame,12) str(frame,C.line,0.35,1) _G.__MenuFrame=frame
    local winBg=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0.04,BorderSizePixel=0,ZIndex=0,Parent=frame})
    rnd(winBg,12) _G.__winBg=winBg
    local winGrad=mk("UIGradient",{Color=ColorSequence.new(C.bgTop,C.bgBot),Rotation=55,Parent=winBg})
    _G.__winGrad=winGrad
    local topBar=mk("Frame",{Size=UDim2.new(1,0,0,48),BackgroundTransparency=1,Parent=frame})
    mk("Frame",{Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),BackgroundColor3=C.line,BackgroundTransparency=0.6,BorderSizePixel=0,Parent=topBar})
    local logo=mk("Frame",{Position=UDim2.fromOffset(14,11),Size=UDim2.fromOffset(26,26),BackgroundColor3=LOGO_BG,BorderSizePixel=0,Parent=topBar}) rnd(logo,6) str(logo,C.line,0.5,1)
    mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(13,13),Rotation=45,BackgroundTransparency=1,Parent=logo})
    for _,p in ipairs({{0,0},{8,0},{0,8},{8,8}}) do mk("Frame",{Position=UDim2.fromOffset(p[1],p[2]),Size=UDim2.fromOffset(5,5),BackgroundColor3=LOGO_MARK,BorderSizePixel=0,Parent=logo:FindFirstChildOfClass("Frame")}) end
    mk("TextLabel",{Position=UDim2.fromOffset(48,14),Size=UDim2.fromOffset(120,20),BackgroundTransparency=1,Font=Enum.Font.GothamBlack,TextSize=16,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left,Text="DeepHub",Parent=topBar})
    mk("TextLabel",{Position=UDim2.new(1,-180,0,10),Size=UDim2.fromOffset(120,18),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Right,TextColor3=C.text,TextTruncate=Enum.TextTruncate.AtEnd,Text=P.DisplayName,Parent=topBar})
    mk("TextLabel",{Position=UDim2.new(1,-180,0,26),Size=UDim2.fromOffset(120,14),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Right,TextColor3=C.sub,TextTruncate=Enum.TextTruncate.AtEnd,Text="@"..P.Name,Parent=topBar})
    local sidebar=mk("Frame",{Position=UDim2.fromOffset(0,48),Size=UDim2.new(0,160,1,-48),BackgroundColor3=C.panel,BackgroundTransparency=0.45,BorderSizePixel=0,Parent=frame}) rnd(sidebar,12) _G.__sidebar=sidebar
    mk("Frame",{Position=UDim2.new(1,-1,0,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=C.line,BackgroundTransparency=0.6,BorderSizePixel=0,Parent=sidebar})
    local sidebarList=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=sidebar})
    mk("UIPadding",{PaddingTop=UDim.new(0,10),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,9),Parent=sidebarList})
    mk("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder,Parent=sidebarList})
    local groups={} local gOrder=0
    local function createGroup(name)
        gOrder+=1
        local hdr=mk("TextButton",{LayoutOrder=gOrder*2-1,Size=UDim2.new(1,0,0,30),BackgroundColor3=C.accentD,BackgroundTransparency=1,AutoButtonColor=false,Text="",Parent=sidebarList}) rnd(hdr,7)
        local lbl=mk("TextLabel",{Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-40,1,0),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.sub,Text=name,Parent=hdr})
        local list=mk("Frame",{LayoutOrder=gOrder*2,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=sidebarList})
        mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Parent=list}) mk("UIPadding",{PaddingBottom=UDim.new(0,8),Parent=list})
        hdr.MouseButton1Click:Connect(function() list.Visible=not list.Visible end)
        groups[name]={hdr=hdr,lbl=lbl,list=list,sections={},active=false}
    end
    createGroup("Modules") createGroup("Settings")
    local content=mk("Frame",{Position=UDim2.fromOffset(172,48),Size=UDim2.new(1,-184,1,-58),BackgroundTransparency=1,Parent=frame})
    local backBtn=mk("TextButton",{Position=UDim2.fromOffset(0,6),Size=UDim2.fromOffset(22,22),BackgroundColor3=C.card,BackgroundTransparency=0.2,AutoButtonColor=true,Text="",Visible=false,Parent=content}) rnd(backBtn,6)
    mk("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=16,TextColor3=C.text,Text="‹",Parent=backBtn})
    local breadcrumb=mk("TextLabel",{Position=UDim2.fromOffset(2,6),Size=UDim2.new(1,-2,0,22),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.sub,RichText=true,Text="",Parent=content})
    local counter=mk("TextLabel",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,6),Size=UDim2.fromOffset(170,22),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,TextColor3=C.sub,RichText=true,Text="",Parent=content})
    local function scroller(n)
        local s=mk("ScrollingFrame",{Name=n,Position=UDim2.fromOffset(0,36),Size=UDim2.new(1,0,1,-36),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=3,ScrollBarImageColor3=C.accent,BackgroundTransparency=1,BorderSizePixel=0,Visible=false,Parent=content})
        mk("UIPadding",{PaddingTop=UDim.new(0,1),PaddingLeft=UDim.new(0,1),PaddingRight=UDim.new(0,7),PaddingBottom=UDim.new(0,2),Parent=s})
        return s
    end
    local sections={} local refreshers={} local secOrder=0 local currentSection,currentModule=nil,nil
    local function updateCount()
        local sec=sections[currentSection]
        if currentModule or not sec or #sec.modules==0 then counter.Text="" return end
        local on=0 for _,d in ipairs(sec.modules) do if d.source[d.key] then on+=1 end end
        counter.Text=string.format('<font color="#FFFAFB"><b>%d</b></font> из %d',on,#sec.modules)
    end
    local function crumbs(...)
        local sec=sections[currentSection]
        local prt={sec and sec.group or "Modules"}
        for _,p in ipairs({...}) do table.insert(prt,p) end
        local lst=table.remove(prt)
        return table.concat(prt," / ")..' / <font color="#FFFAFB"><b>'..lst..'</b></font>'
    end
    local function showGrid()
        if currentModule then currentModule.page.Visible=false currentModule=nil end
        for n,sec in pairs(sections) do sec.grid.Visible=(n==currentSection) end
        backBtn.Visible=false breadcrumb.Position=UDim2.fromOffset(2,6) breadcrumb.Text=crumbs(currentSection) updateCount()
    end
    local function selectSection(name)
        currentSection=name
        for n,sec in pairs(sections) do
            local act=n==name
            sec.nav.lbl.TextColor3=act and C.text or C.sub
            sec.nav.lbl.Font=act and Enum.Font.GothamBold or Enum.Font.Gotham
            sec.nav.pill.Visible=act
        end
        for _,g in pairs(groups) do
            g.active=g.sections[name]==true
            g.hdr.BackgroundTransparency=g.active and 0.35 or 1
            g.lbl.TextColor3=g.active and C.text or C.sub
        end
        showGrid()
    end
    _G.__selectSection=selectSection
    local function openSettings(module)
        for _,sec in pairs(sections) do sec.grid.Visible=false end
        if currentModule then currentModule.page.Visible=false end
        currentModule=module
        if module.page then module.page.Visible=true end
        backBtn.Visible=true breadcrumb.Position=UDim2.fromOffset(30,6) breadcrumb.Text=crumbs(currentSection,module.name) updateCount()
    end
    _G.__openSettings=openSettings
    backBtn.MouseButton1Click:Connect(showGrid)
    local function createSection(name,groupName)
        secOrder+=1 groupName=groupName or "Modules"
        local g=groups[groupName] g.sections[name]=true
        local nav=mk("TextButton",{LayoutOrder=secOrder,Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,AutoButtonColor=false,Text="",Parent=g.list})
        local pill=mk("Frame",{Position=UDim2.fromOffset(24,3),Size=UDim2.new(1,-24,1,-6),BackgroundColor3=C.accentD,BackgroundTransparency=0.6,BorderSizePixel=0,Visible=false,Parent=nav}) rnd(pill,6)
        mk("Frame",{Position=UDim2.fromOffset(16,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=C.line,BackgroundTransparency=0.3,BorderSizePixel=0,Parent=nav})
        mk("Frame",{Position=UDim2.new(0,16,0.5,0),Size=UDim2.fromOffset(8,1),BackgroundColor3=C.line,BackgroundTransparency=0.3,BorderSizePixel=0,Parent=nav})
        local lbl=mk("TextLabel",{Position=UDim2.fromOffset(32,0),Size=UDim2.new(1,-52,1,0),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.sub,Text=name,Parent=nav})
        local grid=scroller(name.."_G")
        mk("UIGridLayout",{CellSize=UDim2.new(0.5,-5,0,66),CellPadding=UDim2.fromOffset(10,10),SortOrder=Enum.SortOrder.LayoutOrder,Parent=grid})
        sections[name]={grid=grid,cards={},modules={},group=groupName,nav={lbl=lbl,pill=pill}}
        nav.MouseEnter:Connect(function() if currentSection~=name then lbl.TextColor3=C.text end end)
        nav.MouseLeave:Connect(function() if currentSection~=name then lbl.TextColor3=C.sub end end)
        nav.MouseButton1Click:Connect(function() selectSection(name) end)
        return sections[name]
    end
    _G.__createSection=createSection _G.__sections=sections _G.__refreshers=refreshers
    local rowCount=0
    local function nextOrd() rowCount+=1 return rowCount end
    local function settingRow(page,txt,h)
        local row=mk("Frame",{LayoutOrder=nextOrd(),Size=UDim2.new(1,0,0,h),BackgroundColor3=C.card,BackgroundTransparency=0.2,BorderSizePixel=0,Parent=page})
        rnd(row,8) str(row,C.line,0.7,1)
        mk("UIGradient",{Rotation=90,Color=ColorSequence.new(Color3.fromRGB(255,255,255),Color3.fromRGB(215,215,215)),Parent=row})
        mk("TextLabel",{Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-140,0,38),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.text,Text=txt,Parent=row})
        return row
    end
    local function toggleSetting(page,label,key,src,onChange)
        local row=settingRow(page,label,38)
        local pill=mk("Frame",{Position=UDim2.new(1,-50,0.5,-9),Size=UDim2.fromOffset(36,18),BackgroundColor3=C.off,BorderSizePixel=0,Parent=row}) rnd(pill,9)
        local knob=mk("Frame",{Size=UDim2.fromOffset(14,14),BackgroundColor3=C.text,BorderSizePixel=0,Parent=pill}) rnd(knob,7)
        local btn=mk("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",Parent=row})
        local function rf() local on=src[key] pill.BackgroundColor3=on and C.accent or C.off knob.Position=on and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7) end
        btn.MouseButton1Click:Connect(function() src[key]=not src[key] rf() playSnd(src[key]) if onChange then onChange(src[key]) end end)
        rf() table.insert(refreshers,rf)
    end
    local activeSlider=nil
    UIS.InputChanged:Connect(function(i) if activeSlider and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then activeSlider(i.Position.X) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then activeSlider=nil end end)
    local function numberSetting(page,label,key,minV,maxV,src,onChange)
        local row=settingRow(page,label,56)
        local range=maxV-minV local step=range<=5 and 0.05 or (range<=50 and 0.5 or 1)
        local function fmt(v) if step>=1 then return tostring(math.floor(v+0.5)) end return (string.format("%.2f",v):gsub("0+$",""):gsub("%.$","")) end
        local box=mk("TextBox",{Position=UDim2.new(1,-70,0,8),Size=UDim2.fromOffset(58,22),BackgroundColor3=C.inner,BorderSizePixel=0,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=C.text,ClearTextOnFocus=false,Text=fmt(src[key]),Parent=row}) rnd(box,6) str(box,C.line,0.6,1)
        local trk=mk("TextButton",{Position=UDim2.new(0,12,0,40),Size=UDim2.new(1,-24,0,6),BackgroundColor3=C.inner,BorderSizePixel=0,AutoButtonColor=false,Text="",Parent=row}) rnd(trk,3)
        local fl=mk("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=C.accent,BorderSizePixel=0,Parent=trk}) rnd(fl,3)
        local kn=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0,0.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=C.text,BorderSizePixel=0,ZIndex=2,Parent=trk}) rnd(kn,7)
        local function rf() local v=math.clamp(src[key],minV,maxV) local a=range>0 and (v-minV)/range or 0 fl.Size=UDim2.fromScale(a,1) kn.Position=UDim2.fromScale(a,0.5) if not box:IsFocused() then box.Text=fmt(src[key]) end end
        local function setFromX(x) local a=math.clamp((x-trk.AbsolutePosition.X)/math.max(trk.AbsoluteSize.X,1),0,1) local v=minV+a*range v=math.floor(v/step+0.5)*step src[key]=math.clamp(v,minV,maxV) rf() if onChange then onChange(src[key]) end end
        trk.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then activeSlider=setFromX setFromX(i.Position.X) end end)
        box.FocusLost:Connect(function() local v=tonumber(box.Text) if v then src[key]=math.clamp(v,minV,maxV) end rf() if onChange then onChange(src[key]) end end)
        rf() table.insert(refreshers,rf)
    end
    local function choiceSetting(page,label,key,options,src,onChange)
        local cols=math.min(#options,3) local rows=math.ceil(#options/cols) local chH,gap=28,6
        local row=settingRow(page,label,38+rows*(chH+gap)+4)
        local grid=mk("Frame",{Position=UDim2.fromOffset(12,36),Size=UDim2.new(1,-24,0,rows*(chH+gap)),BackgroundTransparency=1,Parent=row})
        mk("UIGridLayout",{CellSize=UDim2.new(1/cols,-gap,0,chH),CellPadding=UDim2.fromOffset(gap,gap),SortOrder=Enum.SortOrder.LayoutOrder,Parent=grid})
        local chips={}
        local function rf() for opt,ch in pairs(chips) do local sel=src[key]==opt ch.btn.BackgroundColor3=sel and C.accent or C.inner ch.btn.TextColor3=sel and C.text or C.sub ch.btn.Font=sel and Enum.Font.GothamBold or Enum.Font.Gotham ch.stroke.Color=sel and C.accent or C.line end end
        for i,opt in ipairs(options) do
            local b=mk("TextButton",{LayoutOrder=i,BackgroundColor3=C.inner,BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.Gotham,TextSize=12,TextColor3=C.sub,TextTruncate=Enum.TextTruncate.AtEnd,Text=tostring(opt),Parent=grid}) rnd(b,6)
            local st=str(b,C.line,0.6,1) chips[opt]={btn=b,stroke=st}
            b.MouseButton1Click:Connect(function() if src[key]~=opt then src[key]=opt rf() playSnd(true) if onChange then onChange(opt) end end end)
        end
        rf() table.insert(refreshers,rf)
    end
    local CLRS={Color3.fromRGB(255,90,90),Color3.fromRGB(255,160,60),Color3.fromRGB(255,230,90),Color3.fromRGB(90,220,120),Color3.fromRGB(90,230,230),Color3.fromRGB(90,170,255),Color3.fromRGB(170,110,255),Color3.fromRGB(255,120,200),Color3.fromRGB(255,255,255),Color3.fromRGB(180,190,210),Color3.fromRGB(60,60,70),Color3.fromRGB(15,15,15)}
    local function colorSetting(page,label,key,src,onChange)
        local row=settingRow(page,label,94)
        local grid=mk("Frame",{Position=UDim2.fromOffset(12,36),Size=UDim2.new(1,-24,0,52),BackgroundTransparency=1,Parent=row})
        mk("UIGridLayout",{CellSize=UDim2.fromOffset(28,22),CellPadding=UDim2.fromOffset(6,6),SortOrder=Enum.SortOrder.LayoutOrder,Parent=grid})
        local function same(a,b) return typeof(a)=="Color3" and typeof(b)=="Color3" and math.abs(a.R-b.R)<0.004 and math.abs(a.G-b.G)<0.004 and math.abs(a.B-b.B)<0.004 end
        local sw={} local function rf() for _,s in ipairs(sw) do s.ring.Visible=same(src[key],s.color) end end
        for i,c in ipairs(CLRS) do
            local b=mk("TextButton",{LayoutOrder=i,AutoButtonColor=false,BackgroundColor3=c,BorderSizePixel=0,Text="",Parent=grid}) rnd(b,5)
            mk("UIStroke",{Color=Color3.fromRGB(0,0,0),Transparency=0.6,Thickness=1,Parent=b})
            local ring=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,7,1,7),BackgroundTransparency=1,Visible=false,Parent=b}) rnd(ring,8)
            mk("UIStroke",{Color=C.accent,Thickness=2,Parent=ring}) sw[i]={color=c,ring=ring} b:SetAttribute("KeepColor",true)
            b.MouseButton1Click:Connect(function() src[key]=c rf() playSnd(true) if onChange then onChange(c) end end)
        end
        rf() table.insert(refreshers,rf)
    end
    local function addModule(sec,def)
        local card=mk("TextButton",{LayoutOrder=#sec.cards+1,BackgroundColor3=C.card,BackgroundTransparency=0.05,BorderSizePixel=0,AutoButtonColor=false,Text="",Parent=sec.grid}) rnd(card,8)
        local cSt=str(card,C.line,0.65,1) local cScale=mk("UIScale",{Parent=card})
        mk("UIGradient",{Rotation=90,Color=ColorSequence.new(Color3.fromRGB(255,255,255),Color3.fromRGB(205,205,205)),Parent=card})
        local sw=mk("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,11),Size=UDim2.fromOffset(30,16),BackgroundColor3=C.off,BorderSizePixel=0,Parent=card}) rnd(sw,8)
        local swKnob=mk("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,2,0.5,0),Size=UDim2.fromOffset(12,12),BackgroundColor3=C.text,BorderSizePixel=0,Parent=sw}) rnd(swKnob,6)
        if def.configCard then sw.Visible=false end
        local icon=mk("Frame",{Position=UDim2.fromOffset(10,8),Size=UDim2.fromOffset(22,22),BackgroundColor3=C.accentD,BorderSizePixel=0,Parent=card}) rnd(icon,6)
        mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(10,10),BackgroundColor3=C.sub,BorderSizePixel=0,Parent=icon})
        mk("TextLabel",{Position=UDim2.fromOffset(40,8),Size=UDim2.new(1,def.settings and -112 or -88,0,22),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextColor3=C.text,Text=def.name,Parent=card})
        mk("TextLabel",{Position=UDim2.fromOffset(12,32),Size=UDim2.new(1,-24,0,28),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=12,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextColor3=C.sub,Text=def.desc or "",Parent=card})
        local module={name=def.name,page=nil}
        if def.settings then
            local dots=mk("TextButton",{Position=UDim2.new(1,-64,0,8),Size=UDim2.fromOffset(22,22),BackgroundTransparency=1,Text="",ZIndex=2,Parent=card})
            for i=-1,1 do local d=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,i*5),Size=UDim2.fromOffset(3,3),BackgroundColor3=C.sub,BorderSizePixel=0,Parent=dots}) rnd(d,2) end
            local page=scroller(def.name.."_S") mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,Parent=page})
            local ok,err=pcall(def.settings,page) if not ok then warn("[Settings]",def.name,err) end
            module.page=page dots.MouseButton1Click:Connect(function() openSettings(module) end)
        end
        local iconScale=mk("UIScale",{Parent=icon})
        local function rf()
            if def.configCard then
                local v=def.source[def.key]
                if typeof(v)=="Color3" then icon.BackgroundColor3=v icon.BackgroundTransparency=0 cSt.Color=v cSt.Transparency=0.3
                else icon.BackgroundColor3=C.accentD icon.BackgroundTransparency=0.25 end
                return
            end
            local on=def.source[def.key]
            icon.BackgroundColor3=on and C.accent or C.accentD icon.BackgroundTransparency=on and 0 or 0.25
            cSt.Color=on and C.accent or C.line cSt.Transparency=on and 0.3 or 0.65
            sw.BackgroundColor3=on and C.accent or C.off
            TS:Create(swKnob,TweenInfo.new(0.16,Enum.EasingStyle.Quad),{Position=on and UDim2.new(1,-14,0.5,0) or UDim2.new(0,2,0.5,0)}):Play()
        end
        local function toggle()
            if def.configCard then return end
            def.source[def.key]=not def.source[def.key] rf() updateCount()
            local on=def.source[def.key] playSnd(on)
            iconScale.Scale=1.3 TS:Create(iconScale,TweenInfo.new(0.3,Enum.EasingStyle.Back),{Scale=1}):Play()
            if def.onToggle then pcall(def.onToggle,on) end
        end
        if def.configCard then card.MouseButton1Click:Connect(function() if module.page then openSettings(module) end end)
        else card.MouseButton1Click:Connect(toggle) end
        card.MouseEnter:Connect(function() TS:Create(card,TweenInfo.new(0.12),{BackgroundColor3=C.cardH}):Play() TS:Create(cScale,TweenInfo.new(0.12),{Scale=1.025}):Play() end)
        card.MouseLeave:Connect(function() TS:Create(card,TweenInfo.new(0.12),{BackgroundColor3=C.card}):Play() TS:Create(cScale,TweenInfo.new(0.12),{Scale=1}):Play() end)
        rf() table.insert(refreshers,rf) if not def.configCard then table.insert(refreshers,updateCount) table.insert(sec.modules,def) end
        table.insert(sec.cards,{frame=card,name=def.name,desc=def.desc})
    end
    _G.__addModule=addModule
    _G.__menuApi={createSection=createSection,addModule=addModule,toggleSetting=toggleSetting,numberSetting=numberSetting,choiceSetting=choiceSetting,colorSetting=colorSetting,selectSection=selectSection,openSettings=openSettings,sections=sections,refreshers=refreshers}
end)
if not menuOk then warn("[MENU] CRITICAL:",menuErr) return end
print("[DeepHub] created OK")
local gui=_G.__MenuGui local frame=_G.__MenuFrame
frame.Visible=true local menuOpen=true
local createSection=_G.__menuApi.createSection local addModule=_G.__menuApi.addModule local toggleSetting=_G.__menuApi.toggleSetting local numberSetting=_G.__menuApi.numberSetting local choiceSetting=_G.__menuApi.choiceSetting local colorSetting=_G.__menuApi.colorSetting

local movementSection=createSection("Movement")
local aimSection=createSection("Aim")
local triggerSection=createSection("TriggerBot")
local espSection=createSection("ESP")
local visualsSection=createSection("Visuals")
local autofarmSection=createSection("MM2")
local miscSection=createSection("Misc")

-- ============ AIM FEATURES ============
pcall(function()
    RS.RenderStepped:Connect(function()
        refreshRay()
        if not Camera then return end
        local mouse=UIS:GetMouseLocation()
        -- FOV circles update
        if FOVCircle then FOVCircle.Position=Vector2.new(mouse.X,mouse.Y) FOVCircle.Radius=AIM.FOV FOVCircle.Visible=AIM.Enabled end
        if LegitFOVCircle then LegitFOVCircle.Position=Vector2.new(mouse.X,mouse.Y) LegitFOVCircle.Radius=LEGIT.FOV LegitFOVCircle.Visible=LEGIT.Enabled end
        if SilentFOVCircle then SilentFOVCircle.Position=Vector2.new(mouse.X,mouse.Y) SilentFOVCircle.Radius=SILENT.FOV SilentFOVCircle.Visible=SILENT.Enabled and SILENT.ShowFOV end
        -- Silent target
        if SILENT.Enabled then SilentTarget=getClosest(SILENT.FOV,SILENT.CheckTeam,SILENT.VisibleCheck,SILENT.TargetPart) else SilentTarget=nil end
        -- Aimbot
        if AIM.Enabled then
            local active=AIM.Mode=="Toggle" and aimToggled or isKeyPressed(AIM.Key)
            if active then
                local target=getClosest(AIM.FOV,AIM.CheckTeam,AIM.VisibleCheck,AIM.TargetPart)
                if target and target.Character then
                    local part=target.Character:FindFirstChild(AIM.TargetPart)
                    if part then
                        if AIM.AimType=="Mouse" and mousemoverel then
                            local sp=Camera:WorldToViewportPoint(part.Position)
                            mousemoverel((sp.X-mouse.X)*(AIM.Smoothness/10),(sp.Y-mouse.Y)*(AIM.Smoothness/10))
                        else
                            Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,part.Position),1-(AIM.Smoothness/10))
                        end
                    end
                end
            end
        end
        -- Legit
        if LEGIT.Enabled then
            local active=LEGIT.Mode=="Toggle" and legitToggled or isKeyPressed(LEGIT.Key)
            if active then
                local target=getClosest(LEGIT.FOV,LEGIT.CheckTeam,LEGIT.VisibleCheck,AIM.TargetPart)
                if target and target.Character then
                    local part=target.Character:FindFirstChild(AIM.TargetPart)
                    if part then
                        local sp=Camera:WorldToViewportPoint(part.Position)
                        local dx=(sp.X-mouse.X)*(LEGIT.Speed/100) local dy=(sp.Y-mouse.Y)*(LEGIT.Speed/100)
                        if mousemoverel then mousemoverel(dx,dy) else Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,part.Position),1-LEGIT.Smoothness) end
                    end
                end
            end
        end
    end)
end)

-- ============ TRIGGER BOT (from Rayfield) ============
pcall(function()
    local triggerParams=RaycastParams.new() triggerParams.FilterType=Enum.RaycastFilterType.Exclude
    RS.RenderStepped:Connect(function()
        if not TRIGGER.Enabled then return end
        if not Camera then return end
        triggerParams.FilterDescendantsInstances={getChar()}
        local mouse=UIS:GetMouseLocation()
        local ray=Camera:ViewportPointToRay(mouse.X,mouse.Y)
        local result=workspace:Raycast(ray.Origin,ray.Direction*1000,triggerParams)
        if result and result.Instance then
            local hitChar=result.Instance:FindFirstAncestorOfClass("Model")
            if hitChar then
                local hitPlr=Players:GetPlayerFromCharacter(hitChar)
                if hitPlr and hitPlr~=P then
                    if isTeam(hitPlr,TRIGGER.CheckTeam) then return end
                    if TRIGGER.VisibleCheck and not isVisible(hitChar,TRIGGER.TargetPart,true) then return end
                    if TRIGGER.Delay>0 then task.wait(TRIGGER.Delay/1000) end
                    if mouse1press and mouse1release then
                        pcall(function() mouse1press() task.wait() mouse1release() end)
                    end
                end
            end
        end
    end)
end)

-- ============ MOVEMENT ============
pcall(function()
    local function applyJumpPower()
        local hum=getHum()
        if hum and MOVE.JumpPowerEnabled then
            if hum.UseJumpPower then hum.JumpPower=MOVE.JumpPowerValue
            else hum.JumpHeight=MOVE.JumpPowerValue end
        end
    end
    P.CharacterAdded:Connect(function() task.wait(0.5) if MOVE.JumpPowerEnabled then applyJumpPower() end end)
    RS.Heartbeat:Connect(function()
        -- Fly
        if MOVE.FlyEnabled then
            local root=getRoot()
            if root then
                if not flyBV or flyBV.Parent==nil then
                    flyBV=Instance.new("BodyVelocity") flyBV.MaxForce=Vector3.new(1e9,1e9,1e9) flyBV.Parent=root
                end
                local move=Vector3.new()
                if UIS:IsKeyDown(Enum.KeyCode.W) then move=move+Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then move=move-Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then move=move-Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then move=move+Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then move=move+Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move=move-Vector3.new(0,1,0) end
                if move.Magnitude>0 then flyBV.Velocity=move.Unit*MOVE.FlySpeed*10 else flyBV.Velocity=Vector3.new(0,0,0) end
                root.Velocity=Vector3.new(0,0,0)
            end
        elseif flyBV then flyBV:Destroy() flyBV=nil end
    end)
    RS.RenderStepped:Connect(function()
        -- Noclip
        if MOVE.NoclipEnabled then
            local c=getChar() if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
        end
        -- Speed
        if MOVE.SpeedEnabled then
            local hum=getHum() if hum then hum.WalkSpeed=MOVE.SpeedValue end
        end
        -- Inf Jump
        if MOVE.InfJumpEnabled and UIS:IsKeyDown(Enum.KeyCode.Space) then
            local hum=getHum() if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
        -- Antifling
        if MOVE.AntiflingEnabled then
            local root=getRoot() if root and root.Velocity.Magnitude>100 then root.Velocity=Vector3.new(0,0,0) end
        end
        -- Auto Jump
        if MOVE.AutoJumpEnabled then
            local hum=getHum() if hum and hum.FloorMaterial~=Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
        -- Spin
        if MOVE.SpinEnabled then
            local root=getRoot() if root then root.CFrame=root.CFrame*CFrame.Angles(0,math.rad(MOVE.SpinSpeed)*0.1,0) end
        end
        -- Full Bright
        if MOVE.FullBrightEnabled then
            Lighting.Brightness=2 Lighting.Ambient=Color3.fromRGB(255,255,255) Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
        elseif fullBrightConn then
            Lighting.Brightness=origBright Lighting.Ambient=origAmb Lighting.OutdoorAmbient=origOutAmb
            fullBrightConn=nil
        end
    end)
end)

-- ============ MM2 AUTO FARM ============
pcall(function()
    local running=false
    local function isCoin(obj)
        if not obj then return false end
        local n=obj.Name:lower()
        if n:find("coin") then
            return obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Model") or obj:IsA("UnionOperation")
        end
        return false
    end
    local function getCoinPos(c)
        if c:IsA("BasePart") or c:IsA("MeshPart") or c:IsA("UnionOperation") then return c.Position
        elseif c:IsA("Model") then local p=c.PrimaryPart or c:FindFirstChildWhichIsA("BasePart") return p and p.Position end
        return nil
    end
    local function findCoins()
        local coins={}
        local areas={}
        for _,n in ipairs({"Map","Debris","Coins"}) do local a=workspace:FindFirstChild(n) if a then table.insert(areas,a) end end
        if #areas==0 then areas={workspace} end
        for _,a in ipairs(areas) do for _,o in ipairs(a:GetDescendants()) do if isCoin(o) then table.insert(coins,o) end end end
        return coins
    end
    RS.Heartbeat:Connect(function()
        if not FARM.Enabled or running then return end
        running=true
        task.spawn(function()
            while FARM.Enabled do
                local char=getChar() local root=char and char:FindFirstChild("HumanoidRootPart")
                local hum=getHum()
                if not root or not hum or hum.Health<=0 then task.wait(1) continue end
                local coins=findCoins()
                if #coins==0 then task.wait(1) continue end
                local best,bpos,bd=nil,nil,math.huge
                for _,c in ipairs(coins) do local pos=getCoinPos(c) if pos then local d=(pos-root.Position).Magnitude if d<bd then bd=d best=c bpos=pos end end end
                if bpos then root.CFrame=CFrame.new(bpos) task.wait(FARM.TPDelay) task.wait(FARM.Delay) else task.wait(0.5) end
            end
            running=false
        end)
    end)
end)

-- ============ ESP/HAT/TRAIL/PARTS/FOG (short copies from working version) ============
pcall(function()
    local espF=Instance.new("Folder") espF.Name="ESP_L" espF.Parent=workspace
    local espS=mk("ScreenGui",{IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=5,Parent=PG})
    local trk={}
    local function team(p) return p.Team and p.Team==P.Team end
    local function clr(p) local d=trk[p] if not d then return end d.hl:Destroy() d.bx:Destroy() d.gi:Destroy() d.bx2:Destroy() d.tr:Destroy() trk[p]=nil end
    local function build(p,ch)
        clr(p)
        local h=ch:FindFirstChild("Head") local hu=ch:FindFirstChildOfClass("Humanoid") local r=ch:FindFirstChild("HumanoidRootPart")
        if not h or not hu or not r then return end
        local hl=Instance.new("Highlight") hl.Adornee=ch hl.FillTransparency=CONFIG.FillTransparency hl.OutlineColor=CONFIG.OutlineColor hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop hl.Enabled=false hl.Parent=espF
        local bx=Instance.new("BoxHandleAdornment") bx.Adornee=r bx.Size=Vector3.new(4,5.5,2.5) bx.CFrame=CFrame.new(0,-0.3,0) bx.AlwaysOnTop=true bx.ZIndex=5 bx.Transparency=0.65 bx.Visible=false bx.Parent=espF
        local gi=Instance.new("BillboardGui") gi.Adornee=h gi.Size=UDim2.fromOffset(200,50) gi.StudsOffset=Vector3.new(0,2.5,0) gi.AlwaysOnTop=true gi.Enabled=false gi.Parent=espF
        local lb=Instance.new("TextLabel") lb.BackgroundTransparency=1 lb.Size=UDim2.new(1,0,0,22) lb.Font=Enum.Font.GothamBold lb.TextSize=14 lb.TextStrokeTransparency=0.4 lb.Parent=gi
        local bbg=Instance.new("Frame") bbg.AnchorPoint=Vector2.new(0.5,0) bbg.Position=UDim2.new(0.5,0,0,26) bbg.Size=UDim2.fromOffset(80,6) bbg.BackgroundColor3=Color3.fromRGB(20,20,20) bbg.BorderSizePixel=0 bbg.Parent=gi
        local bfl=Instance.new("Frame") bfl.Size=UDim2.fromScale(1,1) bfl.BackgroundColor3=Color3.fromRGB(60,255,60) bfl.BorderSizePixel=0 bfl.Parent=bbg
        local bx2=Instance.new("Frame") bx2.AnchorPoint=Vector2.new(0.5,0.5) bx2.BackgroundTransparency=1 bx2.BorderSizePixel=0 bx2.Visible=false bx2.Parent=espS
        local bs=Instance.new("UIStroke") bs.Thickness=CONFIG.BoxThickness bs.Parent=bx2
        local tr=Instance.new("Frame") tr.AnchorPoint=Vector2.new(0.5,0.5) tr.BorderSizePixel=0 tr.Visible=false tr.Parent=espS
        trk[p]={character=ch,head=h,humanoid=hu,root=r,hl=hl,bx=bx,gi=gi,lb=lb,bbg=bbg,bfl=bfl,bx2=bx2,bs=bs,tr=tr,distance=0}
    end
    local function refresh(p) if p==P then return end local c=p.Character if not c or not c.Parent then clr(p) return end local d=trk[p] if not d or d.character~=c then build(p,c) end end
    for _,p in ipairs(Players:GetPlayers()) do if p~=P then p.CharacterAdded:Connect(function() task.defer(refresh,p) end) p.CharacterRemoving:Connect(function() clr(p) end) refresh(p) end end
    Players.PlayerAdded:Connect(function(p) if p~=P then p.CharacterAdded:Connect(function() task.defer(refresh,p) end) p.CharacterRemoving:Connect(function() clr(p) end) end end)
    Players.PlayerRemoving:Connect(clr)
    local tacc=0
    RS.Heartbeat:Connect(function(dt) tacc+=dt if tacc<0.5 then return end tacc=0 for _,p in ipairs(Players:GetPlayers()) do refresh(p) end for p in pairs(trk) do if p.Parent~=Players then clr(p) end end end)
    local hlC={}
    RS.RenderStepped:Connect(function()
        local mc=getChar() local mr=mc and mc:FindFirstChild("HumanoidRootPart")
        local cam=Camera
        local org=(mr and mr.Position) or (cam and cam.CFrame.Position)
        table.clear(hlC)
        for p,d in pairs(trk) do
            local vis=CONFIG.Enabled and org~=nil and d.head.Parent~=nil local dist=0
            if vis then dist=(d.root.Position-org).Magnitude vis=dist<=CONFIG.MaxDistance and d.humanoid.Health>0 end
            local tm=team(p) if vis and tm and not CONFIG.ShowTeammates then vis=false end
            local col=tm and CONFIG.TeamColor or CONFIG.EnemyColor
            d.color=col d.distance=dist d.wantHL=false d.wantBX=false
            if vis and CONFIG.ShowHighlight then table.insert(hlC,d) end
            d.gi.Enabled=vis and (CONFIG.ShowLabel or CONFIG.ShowHealth)
            d.lb.Visible=CONFIG.ShowLabel d.bbg.Visible=CONFIG.ShowHealth
            if vis then
                d.lb.TextColor3=col local prt={}
                if CONFIG.ShowNames then table.insert(prt,p.DisplayName) end
                if CONFIG.ShowDistance then table.insert(prt,string.format("[%d]",math.floor(dist))) end
                if CONFIG.ShowHealth then local hp=d.humanoid.Health local mh=math.max(d.humanoid.MaxHealth,1) local rr=math.clamp(hp/mh,0,1) table.insert(prt,string.format("%d HP",math.ceil(hp))) d.bfl.Size=UDim2.fromScale(rr,1) d.bfl.BackgroundColor3=Color3.fromRGB(255,60,60):Lerp(Color3.fromRGB(60,255,60),rr) end
                d.lb.Text=table.concat(prt," ")
            end
            local sBX=vis and CONFIG.ShowBoxes and cam local sTR=vis and CONFIG.ShowTracers and cam
            local bOn,tOn=false,false
            if sBX or sTR then
                local rp=d.root.Position
                local tp=cam:WorldToViewportPoint(rp+Vector3.new(0,3,0)) local bt=cam:WorldToViewportPoint(rp-Vector3.new(0,3.5,0))
                if tp.Z>0 and bt.Z>0 then
                    if sBX then local hh=math.abs(bt.Y-tp.Y) d.bx2.Position=UDim2.fromOffset((tp.X+bt.X)/2,(tp.Y+bt.Y)/2) d.bx2.Size=UDim2.fromOffset(hh*0.6,hh) d.bs.Color=col d.bs.Thickness=CONFIG.BoxThickness d.bx2.BackgroundColor3=col d.bx2.BackgroundTransparency=CONFIG.BoxFill and 0.85 or 1 bOn=true end
                    if sTR then local vp=cam.ViewportSize local fr if CONFIG.TracerOrigin=="Центр" then fr=vp/2 elseif CONFIG.TracerOrigin=="Курсор" then fr=UIS:GetMouseLocation() else fr=Vector2.new(vp.X/2,vp.Y) end local to=Vector2.new(bt.X,bt.Y) local dl=to-fr if dl.Magnitude>1 then d.tr.Position=UDim2.fromOffset((fr.X+to.X)/2,(fr.Y+to.Y)/2) d.tr.Size=UDim2.fromOffset(dl.Magnitude,CONFIG.TracerThickness) d.tr.Rotation=math.deg(math.atan2(dl.Y,dl.X)) d.tr.BackgroundColor3=col tOn=true end end
                end
            end
            d.bx2.Visible=bOn d.tr.Visible=tOn
        end
        table.sort(hlC,function(a,b) return a.distance<b.distance end)
        for i,d in ipairs(hlC) do if i<=30 then d.wantHL=true else d.wantBX=true end end
        for _,d in pairs(trk) do d.hl.Enabled=d.wantHL d.bx.Visible=d.wantBX if d.wantHL then d.hl.FillColor=d.color end if d.wantBX then d.bx.Color3=d.color end end
    end)
end)

pcall(function()
    local hat=nil
    local function destroy() if hat then if hat.la then hat.la:Destroy() end hat.f:Destroy() hat=nil end end
    local function addP(f,p,head,part) part.Material=Enum.Material.SmoothPlastic part.CastShadow=false part.CanCollide=false part.CanQuery=false part.CanTouch=false part.Massless=true part.Transparency=1 part.Parent=f local w=Instance.new("WeldConstraint") w.Part0=head w.Part1=part w.Parent=part table.insert(p,part) end
    local function build(ch)
        destroy() local head=ch:WaitForChild("Head",5) if not head then return end
        local f=Instance.new("Folder") f.Parent=ch local p={} local by=head.Size.Y/2
        if HAT.Style=="Купол" then local d=HAT.Radius*2 local p1=Instance.new("Part") p1.Shape=Enum.PartType.Ball p1.Size=Vector3.new(d,d,d) p1.CFrame=head.CFrame*CFrame.new(0,by+d*0.3,0) addP(f,p,head,p1)
        elseif HAT.Style=="Нимб" then local cf=head.CFrame*CFrame.new(0,by+HAT.Gap+0.35,0)*CFrame.Angles(math.rad(8),0,0) for _,spec in ipairs({{HAT.Radius*0.6,0.1},{HAT.Radius*0.44,0.04}}) do local r,th=spec[1],spec[2] local len=2*math.pi*r/36*1.08 for i=1,36 do local a=(i-1)/36*math.pi*2 local pp=Instance.new("Part") pp.Size=Vector3.new(th,th,len) pp.CFrame=cf*CFrame.Angles(0,a,0)*CFrame.new(r,0,0) addP(f,p,head,pp) end end
        elseif HAT.Style=="Цилиндр" then local t=Instance.new("Part") t.Shape=Enum.PartType.Cylinder t.Size=Vector3.new(HAT.Height,HAT.Radius*1.3,HAT.Radius*1.3) t.CFrame=head.CFrame*CFrame.new(0,by+HAT.Height/2,0)*CFrame.Angles(0,0,math.pi/2) addP(f,p,head,t) local b=Instance.new("Part") b.Shape=Enum.PartType.Cylinder b.Size=Vector3.new(0.08,HAT.Radius*2.6,HAT.Radius*2.6) b.CFrame=head.CFrame*CFrame.new(0,by+0.04,0)*CFrame.Angles(0,0,math.pi/2) addP(f,p,head,b)
        else local rimY=by+HAT.Gap local tip=(head.CFrame*CFrame.new(0,rimY+HAT.Height,0)).Position for i=0,23 do local a1=(i/24)*math.pi*2 local a2=((i+1)/24)*math.pi*2 local p1=(head.CFrame*CFrame.new(math.cos(a1)*HAT.Radius,rimY,math.sin(a1)*HAT.Radius)).Position local p2=(head.CFrame*CFrame.new(math.cos(a2)*HAT.Radius,rimY,math.sin(a2)*HAT.Radius)).Position local ab,ac,bc=p2-p1,tip-p1,tip-p2 local rt=ac:Cross(ab).Unit local up=bc:Cross(rt).Unit local bk=bc.Unit local h=math.abs(ab:Dot(up)) local w1=Instance.new("WedgePart") w1.Size=Vector3.new(0.05,h,math.abs(ab:Dot(bk))) w1.CFrame=CFrame.fromMatrix((p1+p2)/2,rt,up,bk) addP(f,p,head,w1) local w2=Instance.new("WedgePart") w2.Size=Vector3.new(0.05,h,math.abs(ac:Dot(bk))) w2.CFrame=CFrame.fromMatrix((p1+tip)/2,-rt,up,-bk) addP(f,p,head,w2) end end
        local la=Instance.new("Attachment") la.Position=Vector3.new(0,by+HAT.Gap+HAT.Height/2,0) la.Parent=head
        local lt=Instance.new("PointLight") lt.Shadows=false lt.Enabled=false lt.Parent=la
        hat={f=f,p=p,head=head,la=la,lt=lt,radius=HAT.Radius,height=HAT.Height,style=HAT.Style}
    end
    P.CharacterAdded:Connect(build) if P.Character then task.spawn(build,P.Character) end
    RS.RenderStepped:Connect(function()
        if not hat or not hat.f.Parent then return end
        if hat.radius~=HAT.Radius or hat.height~=HAT.Height or hat.style~=HAT.Style then if P.Character then build(P.Character) end if not hat then return end end
        local cam=Camera local fp=cam and (cam.CFrame.Position-hat.head.Position).Magnitude<HAT.FirstPersonDistance
        local vis=HAT.Enabled and not fp local tr=vis and HAT.Transparency or 1
        local col=HAT.Rainbow and Color3.fromHSV((os.clock()*0.3)%1,0.8,1) or HAT.Color
        local mt=HAT.Glow and Enum.Material.Neon or Enum.Material.SmoothPlastic
        for _,pp in ipairs(hat.p) do pp.Transparency=tr if vis then pp.Color=col pp.Material=mt end end
        hat.lt.Enabled=vis and HAT.Glow and HAT.GlowStrength>0 hat.lt.Color=col hat.lt.Brightness=HAT.GlowStrength hat.lt.Range=4+HAT.GlowStrength*2
    end)
end)

pcall(function()
    local ST={["Лента"]={H=false,F=true,W=1,S=NumberSequence.new(1)},["Крылья"]={H=true,F=false,W=1.4,S=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0.1)})},["Линия"]={H=false,F=true,W=0.12,S=NumberSequence.new(1)},["Комета"]={H=false,F=true,W=0.6,S=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})}}
    local trD=nil
    local function rbow(o) local k={} for i=0,6 do k[#k+1]=ColorSequenceKeypoint.new(i/6,Color3.fromHSV((o+i/6)%1,0.8,1)) end return ColorSequence.new(k) end
    local function dstr() if trD then trD.t:Destroy() trD.a0:Destroy() trD.a1:Destroy() trD=nil end end
    local function build(ch) dstr() local r=ch:WaitForChild("HumanoidRootPart",5) if not r then return end local a0=Instance.new("Attachment") a0.Parent=r local a1=Instance.new("Attachment") a1.Parent=r local t=Instance.new("Trail") t.Attachment0=a0 t.Attachment1=a1 t.LightEmission=1 t.FaceCamera=true t.Enabled=TRAIL.Enabled t.Parent=r trD={t=t,a0=a0,a1=a1,head=ch:FindFirstChild("Head") or r,style=TRAIL.Style} end
    P.CharacterAdded:Connect(build) if P.Character then task.spawn(build,P.Character) end
    RS.RenderStepped:Connect(function()
        local d=trD if d and d.style~=TRAIL.Style and P.Character then build(P.Character) d=trD end
        if not d or not d.t.Parent then return end
        local cam=Camera local fp=cam and (cam.CFrame.Position-d.head.Position).Magnitude<TRAIL.FirstPersonDistance
        d.t.Enabled=TRAIL.Enabled and not fp if not TRAIL.Enabled then return end
        local st=ST[TRAIL.Style] or ST["Лента"] local h=TRAIL.Height*st.W/2
        if st.H then d.a0.Position=Vector3.new(-h,0,0) d.a1.Position=Vector3.new(h,0,0) else d.a0.Position=Vector3.new(0,h,0) d.a1.Position=Vector3.new(0,-h,0) end
        d.t.FaceCamera=st.F d.t.WidthScale=st.S d.t.Lifetime=TRAIL.Lifetime
        d.t.Transparency=fp and NumberSequence.new(1) or NumberSequence.new({NumberSequenceKeypoint.new(0,TRAIL.Transparency),NumberSequenceKeypoint.new(1,1)})
        d.t.Color=TRAIL.Rainbow and rbow(os.clock()*0.3) or ColorSequence.new(TRAIL.Color)
        d.t.LightEmission=TRAIL.Glow and 1 or 0
    end)
end)

pcall(function()
    local part=Instance.new("Part") part.Anchored=true part.CanCollide=false part.CanQuery=false part.CanTouch=false part.CastShadow=false part.Transparency=1 part.Size=Vector3.new(PARTS.Range,PARTS.Range/2,PARTS.Range) part.Parent=workspace
    local em=Instance.new("ParticleEmitter") em.Shape=Enum.ParticleEmitterShape.Box em.ShapeStyle=Enum.ParticleEmitterShapeStyle.Volume em.Lifetime=NumberRange.new(4,7) em.Speed=NumberRange.new(0.5,2) em.SpreadAngle=Vector2.new(180,180) em.Drag=0.5 em.Rotation=NumberRange.new(0,360) em.RotSpeed=NumberRange.new(-30,30) em.LightEmission=1 em.LightInfluence=0 em.Enabled=false em.Parent=part
    local TEX={["Искры"]="rbxasset://textures/particles/sparkles_main.dds",["Снег"]="rbxasset://textures/particles/smoke_main.dds",["Огоньки"]="rbxasset://textures/particles/fire_main.dds",["Дым"]="rbxasset://textures/particles/smoke_main.dds"}
    local function rbow(o) local k={} for i=0,6 do k[#k+1]=ColorSequenceKeypoint.new(i/6,Color3.fromHSV((o+i/6)%1,0.8,1)) end return ColorSequence.new(k) end
    RS.RenderStepped:Connect(function()
        em.Enabled=PARTS.Enabled if not em.Enabled then return end
        if Camera then part.CFrame=CFrame.new(Camera.CFrame.Position) end
        part.Size=Vector3.new(PARTS.Range,PARTS.Range/2,PARTS.Range) em.Rate=PARTS.Rate em.Size=NumberSequence.new(PARTS.Size)
        em.Color=PARTS.Rainbow and rbow(os.clock()*0.3) or ColorSequence.new(PARTS.Color)
        em.Texture=TEX[PARTS.Style] or TEX["Искры"] em.LightEmission=PARTS.Glow and 1 or 0
        em.Brightness=PARTS.Glow and math.max(PARTS.GlowStrength,0.1) or 1
    end)
end)

pcall(function()
    local bl=Instance.new("BloomEffect") bl.Size=30 bl.Threshold=0.85 bl.Enabled=false bl.Parent=Lighting
    local orig=nil
    RS.RenderStepped:Connect(function()
        if FOG.Enabled then
            if not orig then orig={s=Lighting.FogStart,e=Lighting.FogEnd,c=Lighting.FogColor,a=Lighting:FindFirstChildOfClass("Atmosphere")} if orig.a then orig.a.Parent=nil end end
            Lighting.FogStart=FOG.Start Lighting.FogEnd=math.max(FOG.End,FOG.Start+1)
            Lighting.FogColor=FOG.Rainbow and Color3.fromHSV((os.clock()*0.1)%1,0.5,1) or FOG.Color
            bl.Enabled=FOG.Glow and FOG.GlowStrength>0 bl.Intensity=FOG.GlowStrength*0.3 return
        end
        bl.Enabled=false
        if orig then Lighting.FogStart=orig.s Lighting.FogEnd=orig.e Lighting.FogColor=orig.c if orig.a then orig.a.Parent=Lighting end orig=nil end
    end)
end)

-- ============ WATERMARK ============
pcall(function()
    local gui=mk("ScreenGui",{Name="WM",ResetOnSpawn=false,DisplayOrder=90,Parent=PG})
    local bar=mk("TextButton",{AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,28),BackgroundColor3=Color3.fromRGB(22,20,30),BackgroundTransparency=0.05,BorderSizePixel=0,AutoButtonColor=false,Text="",Parent=gui})
    rnd(bar,8) str(bar,Color3.fromRGB(90,72,112),0.3,1)
    local gr=mk("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(40,34,52),Color3.fromRGB(22,20,30)),Rotation=20,Parent=bar})
    _G.__wmBar=bar _G.__wmGrad=gr
    mk("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,12),Parent=bar})
    mk("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,10),Parent=bar})
    local function item(order,txt,col)
        local h=mk("Frame",{LayoutOrder=order,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.new(0,0,1,0),BackgroundTransparency=1,Parent=bar})
        mk("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,6),Parent=h})
        return mk("TextLabel",{LayoutOrder=1,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.new(0,0,1,0),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=col or Color3.fromRGB(245,240,248),Text=txt or "",Parent=h})
    end
    local nameL=item(1,"DeepHub",C.accent) _G.__wmNameL=nameL
    local fpsL=item(2,"0 fps") local pingL=item(3,"0 ms") local timeL=item(4,"--:--")
    local fc,ft=0,0
    bar.MouseButton1Click:Connect(function() wmClicked:Fire() end)
    RS.RenderStepped:Connect(function(dt)
        gui.Enabled=WM.Enabled if not WM.Enabled then return end
        fc+=1 ft+=dt
        if ft>=0.5 then
            fpsL.Text=math.floor(fc/ft+0.5).." fps"
            local ok,ping=pcall(function() return P:GetNetworkPing() end)
            pingL.Text=(ok and math.floor(ping*1000+0.5) or 0).." ms"
            timeL.Text=os.date(WM.ShowSeconds and "%H:%M:%S" or "%H:%M")
            fc=0 ft=0
        end
    end)
end)

-- ============ CURSOR ============
pcall(function()
    local gui=mk("ScreenGui",{Name="Cursor",IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=500,Enabled=false,Parent=PG})
    local root=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,Parent=gui})
    local shapes={} local built=nil local hid=false
    local function build()
        for _,c in ipairs(root:GetChildren()) do c:Destroy() end table.clear(shapes)
        local s=CUR.Size local th=CUR.Thickness root.Size=UDim2.fromOffset(s,s)
        if CUR.Style=="Точка" then local d=math.max(th*2,math.floor(s/3)) local f=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(d,d),BackgroundColor3=CUR.Color,BorderSizePixel=0,Parent=root}) rnd(f,d/2) table.insert(shapes,{o=f})
        elseif CUR.Style=="Круг" then local f=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(s,s),BackgroundTransparency=1,Parent=root}) rnd(f,s/2) mk("UIStroke",{Thickness=th,Parent=f}) table.insert(shapes,{o=f,s=f:FindFirstChildOfClass("UIStroke")})
        elseif CUR.Style=="Ромб" then local f=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(math.floor(s*0.7),math.floor(s*0.7)),BackgroundTransparency=1,Rotation=45,Parent=root}) mk("UIStroke",{Thickness=th,Parent=f}) table.insert(shapes,{o=f,s=f:FindFirstChildOfClass("UIStroke")})
        else local gap=math.max(2,math.floor(s*0.18)) local len=math.max(2,math.floor(s/2-gap)) local off=gap+len/2 for _,spec in ipairs({{UDim2.new(0.5,0,0.5,-off),UDim2.fromOffset(th,len)},{UDim2.new(0.5,0,0.5,off),UDim2.fromOffset(th,len)},{UDim2.new(0.5,-off,0.5,0),UDim2.fromOffset(len,th)},{UDim2.new(0.5,off,0.5,0),UDim2.fromOffset(len,th)}}) do local f=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=spec[1],Size=spec[2],BorderSizePixel=0,BackgroundColor3=CUR.Color,Parent=root}) table.insert(shapes,{o=f}) end end
    end
    RS.RenderStepped:Connect(function()
        local en=CUR.Enabled and UIS.MouseEnabled
        gui.Enabled=en
        if not en then if hid then UIS.MouseIconEnabled=true hid=false end return end
        UIS.MouseIconEnabled=false hid=true
        local k=CUR.Style.."|"..CUR.Size.."|"..CUR.Thickness
        if k~=built then build() built=k end
        local m=UIS:GetMouseLocation() root.Position=UDim2.fromOffset(m.X,m.Y) root.Rotation=CUR.Spin and (os.clock()*120)%360 or 0
        local col=CUR.Rainbow and Color3.fromHSV((os.clock()*0.3)%1,0.8,1) or CUR.Color
        for _,sh in ipairs(shapes) do if sh.s then sh.s.Color=col sh.s.Transparency=CUR.Transparency else sh.o.BackgroundColor3=col sh.o.BackgroundTransparency=CUR.Transparency end end
    end)
end)

-- ============ TARGET ESP ============
pcall(function()
    local folder=Instance.new("Folder") folder.Parent=workspace
    local targets={}
    local function destroy(p) local d=targets[p] if not d then return end for _,o in ipairs(d.orbs) do o:Destroy() end targets[p]=nil end
    local function build(p) destroy(p) local d={style=TESP.Style,count=TESP.Count,orbs={}} for i=1,d.count do local o=Instance.new("Part") o.Shape=Enum.PartType.Ball o.Size=Vector3.new(TESP.Size,TESP.Size,TESP.Size) o.Anchored=true o.CanCollide=false o.CanQuery=false o.CanTouch=false o.CastShadow=false o.Parent=folder d.orbs[i]=o end targets[p]=d end
    local wanted={}
    RS.RenderStepped:Connect(function()
        table.clear(wanted)
        if TESP.Enabled then
            local mc=getChar() local mr=mc and mc:FindFirstChild("HumanoidRootPart") local org=mr and mr.Position
            if org then for _,p in ipairs(Players:GetPlayers()) do if p~=P then local c=p.Character local r=c and c:FindFirstChild("HumanoidRootPart") local h=c and c:FindFirstChildOfClass("Humanoid") if r and h and h.Health>0 then local ok=TESP.ShowTeammates or not (p.Team and p.Team==P.Team) if ok and (r.Position-org).Magnitude<=TESP.Radius then wanted[p]=r end end end end end
        end
        for p in pairs(targets) do if not wanted[p] then destroy(p) end end
        local now=os.clock() local col=TESP.Rainbow and Color3.fromHSV((now*0.3)%1,0.8,1) or TESP.Color local mt=TESP.Glow and Enum.Material.Neon or Enum.Material.SmoothPlastic
        for p,r in pairs(wanted) do local d=targets[p] if not d or d.style~=TESP.Style or d.count~=TESP.Count then build(p) d=targets[p] end local cen=r.Position local n=#d.orbs for i,o in ipairs(d.orbs) do local ph=(i-1)/n local a=now*TESP.Speed+ph*math.pi*2 local y=math.sin(now*TESP.Speed+ph*math.pi*2)*1.2 o.CFrame=CFrame.new(cen+Vector3.new(math.cos(a)*2.5,y,math.sin(a)*2.5)) o.Color=col o.Material=mt end end
    end)
    Players.PlayerRemoving:Connect(destroy)
end)

-- ============ ARRAYLIST ============
pcall(function()
    local gui=mk("ScreenGui",{Name="AL",ResetOnSpawn=false,DisplayOrder=80,Parent=PG})
    local holder=mk("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,12),Size=UDim2.fromOffset(260,600),BackgroundTransparency=1,Parent=gui})
    mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Parent=holder})
    local rows={} local last=0 _G.__hudRows=rows
    local checks={ESP=CONFIG,Hat=HAT,Trail=TRAIL,Particles=PARTS,Fog=FOG,Watermark=WM,Cursor=CUR,Target=TESP,ArrayList=AL,Aimbot=AIM,Legit=LEGIT,Silent=SILENT,TriggerBot=TRIGGER}
    local function rm(n) local r=rows[n] if r then r:Destroy() rows[n]=nil end end
    RS.RenderStepped:Connect(function()
        gui.Enabled=AL.Enabled
        if not AL.Enabled then for n in pairs(rows) do rm(n) end return end
        local now=os.clock()
        if now-last>0.2 then
            last=now local act={}
            for n,d in pairs(checks) do if d.Enabled then table.insert(act,n) end end
            table.sort(act) local want={}
            for i,n in ipairs(act) do
                want[n]=true local r=rows[n]
                if not r then local f=mk("Frame",{LayoutOrder=i,AnchorPoint=Vector2.new(1,0),Size=UDim2.fromOffset(200,20),BackgroundColor3=Color3.fromRGB(22,20,30),BackgroundTransparency=0.3,BorderSizePixel=0,Parent=holder}) rnd(f,4) mk("TextLabel",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),Size=UDim2.new(1,-16,1,0),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=13,TextColor3=UI.HudColor,TextXAlignment=Enum.TextXAlignment.Right,Text=n,Parent=f}) rows[n]=f
                else r.LayoutOrder=i end
            end
            for n in pairs(rows) do if not want[n] then rm(n) end end
        end
    end)
end)

-- ============ RECOLOR ============
local function applyMenuColor(newColor)
    local oldA=C.accent local oldD=C.accentD
    local newD=newColor:Lerp(Color3.fromRGB(0,0,0),0.44)
    C.accent=newColor C.accentD=newD
    local g=_G.__MenuGui if not g then return end
    local function m(c) if c==oldA then return newColor elseif c==oldD then return newD end return nil end
    for _,obj in ipairs(g:GetDescendants()) do
        if obj:IsA("GuiObject") then local nc=m(obj.BackgroundColor3) if nc then obj.BackgroundColor3=nc end if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then local tc=m(obj.TextColor3) if tc then obj.TextColor3=tc end end end
        if obj:IsA("UIStroke") then local sc=m(obj.Color) if sc then obj.Color=sc end end
    end
    if _G.__wmNameL then _G.__wmNameL.TextColor3=newColor end
end
local function applyMenuBg(c) if _G.__winGrad then _G.__winGrad.Color=ColorSequence.new(c,c:Lerp(Color3.fromRGB(10,8,12),0.85)) end end
local function applyWmColor(c) if _G.__wmGrad then _G.__wmGrad.Color=ColorSequence.new(c,c:Lerp(Color3.fromRGB(10,8,15),0.7)) end end
local function applyHudColor(c) if _G.__hudRows then for _,f in pairs(_G.__hudRows) do if f.Parent then local l=f:FindFirstChildOfClass("TextLabel") if l then l.TextColor3=c end end end end end
local function applyMenuTransparency(v) if _G.__winBg then _G.__winBg.BackgroundTransparency=v end if _G.__sidebar then _G.__sidebar.BackgroundTransparency=math.min(0.45+v*0.5,0.92) end end
local function uiRefresh() applyMenuColor(UI.MenuColor) applyMenuBg(UI.MenuBgColor) applyWmColor(UI.WmColor) applyHudColor(UI.HudColor) applyMenuTransparency(UI.MenuTransparency) end
table.insert(_G.__refreshers,uiRefresh)

-- ============ MAIN ============
local mainSection=createSection("Main","Settings")
addModule(mainSection,{name="Menu Accent",desc="Цвет кнопок и выделения.",source=UI,key="MenuColor",configCard=true,settings=function(p) colorSetting(p,"Цвет акцента","MenuColor",UI,uiRefresh) end})
addModule(mainSection,{name="Menu Background",desc="Цвет фона меню.",source=UI,key="MenuBgColor",configCard=true,settings=function(p) colorSetting(p,"Цвет фона","MenuBgColor",UI,uiRefresh) end})
addModule(mainSection,{name="Watermark Color",desc="Цвет фона watermarks.",source=UI,key="WmColor",configCard=true,settings=function(p) colorSetting(p,"Цвет","WmColor",UI,uiRefresh) end})
addModule(mainSection,{name="HUD Color",desc="Цвет текста HUD.",source=UI,key="HudColor",configCard=true,settings=function(p) colorSetting(p,"Цвет","HudColor",UI,uiRefresh) end})
addModule(mainSection,{name="Menu Transparency",desc="Прозрачность окна.",source=UI,key="MenuTransparency",configCard=true,settings=function(p) numberSetting(p,"Прозрачность","MenuTransparency",0,0.9,UI,uiRefresh) end})

-- ============ AIM MODULES ============
addModule(aimSection,{name="Aimbot",desc="Автоматическое наведение.",source=AIM,key="Enabled",onToggle=updateFOVCircles,settings=function(p)
    choiceSetting(p,"Mode","Mode",MODE_OPTS,AIM) choiceSetting(p,"Key","Key",KEY_OPTS,AIM) choiceSetting(p,"Aim Type","AimType",AIMTYPE_OPTS,AIM) choiceSetting(p,"Target Part","TargetPart",PART_OPTS,AIM)
    numberSetting(p,"FOV","FOV",10,360,AIM,updateFOVCircles) numberSetting(p,"Smoothness","Smoothness",0,10,AIM)
    toggleSetting(p,"Show FOV","ShowFOV",AIM,updateFOVCircles) toggleSetting(p,"Visible Check","VisibleCheck",AIM) toggleSetting(p,"Check Team","CheckTeam",AIM)
end})
addModule(aimSection,{name="Legit",desc="Плавное наведение (легит).",source=LEGIT,key="Enabled",onToggle=updateFOVCircles,settings=function(p)
    choiceSetting(p,"Mode","Mode",MODE_OPTS,LEGIT) choiceSetting(p,"Key","Key",KEY_OPTS,LEGIT)
    numberSetting(p,"FOV","FOV",10,180,LEGIT,updateFOVCircles) numberSetting(p,"Smoothness","Smoothness",0,1,LEGIT) numberSetting(p,"Speed","Speed",1,50,LEGIT)
    toggleSetting(p,"Visible Check","VisibleCheck",LEGIT) toggleSetting(p,"Check Team","CheckTeam",LEGIT)
end})
addModule(aimSection,{name="Silent Aim",desc="Невидимое наведение.",source=SILENT,key="Enabled",onToggle=function() setupSilent() updateFOVCircles() end,settings=function(p)
    numberSetting(p,"FOV","FOV",10,500,SILENT,updateFOVCircles) numberSetting(p,"Hit Chance","HitChance",0,100,SILENT) choiceSetting(p,"Target Part","TargetPart",PART_OPTS,SILENT)
    toggleSetting(p,"Show FOV","ShowFOV",SILENT,updateFOVCircles) toggleSetting(p,"Visible Check","VisibleCheck",SILENT) toggleSetting(p,"Check Team","CheckTeam",SILENT)
end})

-- ============ TRIGGER BOT ============
addModule(triggerSection,{name="TriggerBot",desc="Стреляет при прицеле на враге.",source=TRIGGER,key="Enabled",settings=function(p)
    numberSetting(p,"Delay (ms)","Delay",0,200,TRIGGER) choiceSetting(p,"Target Part","TargetPart",PART_OPTS,TRIGGER)
    toggleSetting(p,"Visible Check","VisibleCheck",TRIGGER) toggleSetting(p,"Check Team","CheckTeam",TRIGGER)
end})

-- ============ MOVEMENT MODULES ============
addModule(movementSection,{name="Fly",desc="Полёт.",source=MOVE,key="FlyEnabled",settings=function(p) numberSetting(p,"Fly Speed","FlySpeed",1,150,MOVE) end})
addModule(movementSection,{name="Noclip",desc="Прохождение сквозь стены.",source=MOVE,key="NoclipEnabled"})
addModule(movementSection,{name="Speed",desc="Ускорение.",source=MOVE,key="SpeedEnabled",settings=function(p) numberSetting(p,"Speed Value","SpeedValue",10,100,MOVE) end})
addModule(movementSection,{name="Jump Power",desc="Сила прыжка.",source=MOVE,key="JumpPowerEnabled",settings=function(p) numberSetting(p,"Jump Value","JumpPowerValue",20,200,MOVE) end})
addModule(movementSection,{name="Infinite Jump",desc="Бесконечный прыжок.",source=MOVE,key="InfJumpEnabled"})
addModule(movementSection,{name="Antifling",desc="Защита от флинга.",source=MOVE,key="AntiflingEnabled"})
addModule(movementSection,{name="Auto Jump",desc="Авто-прыжок.",source=MOVE,key="AutoJumpEnabled"})
addModule(movementSection,{name="Spin",desc="Вращение.",source=MOVE,key="SpinEnabled",settings=function(p) numberSetting(p,"Spin Speed","SpinSpeed",1,100,MOVE) end})
addModule(movementSection,{name="Full Bright",desc="Полная яркость.",source=MOVE,key="FullBrightEnabled"})

-- ============ MM2 AUTOFARM ============
addModule(autofarmSection,{name="MM2 Auto Farm",desc="Собирает монеты (MM2).",source=FARM,key="Enabled",settings=function(p)
    numberSetting(p,"Delay (сек)","Delay",1,30,FARM) numberSetting(p,"TP Delay","TPDelay",0.1,2,FARM)
end})

-- ============ ESP MODULES ============
addModule(espSection,{name="ESP",desc="Игроки сквозь стены.",source=CONFIG,key="Enabled",settings=function(p) numberSetting(p,"Max Distance","MaxDistance",50,5000,CONFIG) end})
addModule(espSection,{name="Highlight",desc="Подсветка силуэта.",source=CONFIG,key="ShowHighlight"})
addModule(espSection,{name="Labels",desc="Подпись.",source=CONFIG,key="ShowLabel"})
addModule(espSection,{name="Names",desc="Имя игрока.",source=CONFIG,key="ShowNames"})
addModule(espSection,{name="Distance",desc="Расстояние.",source=CONFIG,key="ShowDistance"})
addModule(espSection,{name="Health",desc="HP.",source=CONFIG,key="ShowHealth"})
addModule(espSection,{name="Boxes",desc="2D-рамка.",source=CONFIG,key="ShowBoxes",settings=function(p) toggleSetting(p,"Fill","BoxFill",CONFIG) numberSetting(p,"Thickness","BoxThickness",1,5,CONFIG) end})
addModule(espSection,{name="Tracers",desc="Линии.",source=CONFIG,key="ShowTracers",settings=function(p) choiceSetting(p,"From","TracerOrigin",TRC_O,CONFIG) numberSetting(p,"Thickness","TracerThickness",1,5,CONFIG) end})
addModule(espSection,{name="Teammates",desc="Показывать союзников.",source=CONFIG,key="ShowTeammates"})

-- ============ VISUALS ============
addModule(visualsSection,{name="Hat",desc="Шляпа.",source=HAT,key="Enabled",settings=function(p) choiceSetting(p,"Style","Style",HAT_S,HAT) toggleSetting(p,"Rainbow","Rainbow",HAT) colorSetting(p,"Color","Color",HAT) toggleSetting(p,"Glow","Glow",HAT) numberSetting(p,"Glow Strength","GlowStrength",0,5,HAT) numberSetting(p,"Radius","Radius",0.5,4,HAT) numberSetting(p,"Height","Height",0.3,3,HAT) numberSetting(p,"Gap","Gap",0,2,HAT) numberSetting(p,"Transparency","Transparency",0,1,HAT) end})
addModule(visualsSection,{name="Trail",desc="След.",source=TRAIL,key="Enabled",settings=function(p) choiceSetting(p,"Style","Style",TRL_S,TRAIL) toggleSetting(p,"Rainbow","Rainbow",TRAIL) colorSetting(p,"Color","Color",TRAIL) toggleSetting(p,"Glow","Glow",TRAIL) numberSetting(p,"Glow Strength","GlowStrength",0,5,TRAIL) numberSetting(p,"Lifetime","Lifetime",0.2,5,TRAIL) numberSetting(p,"Height","Height",0.5,4,TRAIL) numberSetting(p,"Transparency","Transparency",0,1,TRAIL) end})
addModule(visualsSection,{name="Particles",desc="Частицы.",source=PARTS,key="Enabled",settings=function(p) choiceSetting(p,"Style","Style",PRT_S,PARTS) toggleSetting(p,"Rainbow","Rainbow",PARTS) colorSetting(p,"Color","Color",PARTS) toggleSetting(p,"Glow","Glow",PARTS) numberSetting(p,"Glow Strength","GlowStrength",0,5,PARTS) numberSetting(p,"Rate","Rate",5,500,PARTS) numberSetting(p,"Size","Size",0.1,2,PARTS) numberSetting(p,"Range","Range",20,200,PARTS) end})
addModule(visualsSection,{name="Fog",desc="Туман.",source=FOG,key="Enabled",settings=function(p) toggleSetting(p,"Rainbow","Rainbow",FOG) colorSetting(p,"Color","Color",FOG) toggleSetting(p,"Glow","Glow",FOG) numberSetting(p,"Glow Strength","GlowStrength",0,5,FOG) numberSetting(p,"Start","Start",0,2000,FOG) numberSetting(p,"End","End",10,5000,FOG) end})
addModule(visualsSection,{name="Custom Sky",desc="Своё небо.",source=SKY,key="Enabled",settings=function(p) choiceSetting(p,"Preset","Preset",SKY_P,SKY) end})

-- ============ MISC ============
addModule(miscSection,{name="ArrayList",desc="Список функций.",source=AL,key="Enabled",settings=function(p) choiceSetting(p,"Position","Position",AL_P,AL) end})
addModule(miscSection,{name="Watermark",desc="FPS / ping / time.",source=WM,key="Enabled",settings=function(p) toggleSetting(p,"FPS","ShowFPS",WM) toggleSetting(p,"Ping","ShowPing",WM) toggleSetting(p,"Time","ShowTime",WM) toggleSetting(p,"Seconds","ShowSeconds",WM) end})
addModule(miscSection,{name="Custom Cursor",desc="Свой курсор.",source=CUR,key="Enabled",settings=function(p) choiceSetting(p,"Style","Style",CUR_S,CUR) toggleSetting(p,"Rainbow","Rainbow",CUR) colorSetting(p,"Color","Color",CUR) numberSetting(p,"Size","Size",6,48,CUR) numberSetting(p,"Thickness","Thickness",1,6,CUR) toggleSetting(p,"Outline","Outline",CUR) toggleSetting(p,"Spin","Spin",CUR) numberSetting(p,"Transparency","Transparency",0,0.9,CUR) end})
addModule(miscSection,{name="Target ESP",desc="Частицы вокруг игроков.",source=TESP,key="Enabled",settings=function(p) choiceSetting(p,"Mode","Mode",TESP_M,TESP) choiceSetting(p,"Style","Style",TESP_S,TESP) numberSetting(p,"Radius","Radius",5,300,TESP) toggleSetting(p,"Rainbow","Rainbow",TESP) colorSetting(p,"Color","Color",TESP) toggleSetting(p,"Glow","Glow",TESP) numberSetting(p,"Count","Count",1,16,TESP) numberSetting(p,"Size","Size",0.1,1.5,TESP) numberSetting(p,"Speed","Speed",0.2,8,TESP) toggleSetting(p,"Teammates","ShowTeammates",TESP) end})

-- ============ CONFIG ============
do
    local TABLES={ESP=CONFIG,Hat=HAT,Trail=TRAIL,Particles=PARTS,Fog=FOG,Sky=SKY,Cursor=CUR,TargetESP=TESP,ArrayList=AL,Watermark=WM,Sounds=SND,Menu=MS,Binds=BINDS,UI=UI,Aim=AIM,Legit=LEGIT,Silent=SILENT,TriggerBot=TRIGGER,Movement=MOVE,AutoFarm=FARM}
    local function serialize() local data={} for g,src in pairs(TABLES) do local t={} for k,v in pairs(src) do local ty=typeof(v) if ty=="boolean" or ty=="number" or ty=="string" then t[k]=v elseif ty=="Color3" then t[k]={__c=true,r=math.floor(v.R*255+0.5),g=math.floor(v.G*255+0.5),b=math.floor(v.B*255+0.5)} end end data[g]=t end return data end
    local function apply(data)
        if type(data.Binds)=="table" then table.clear(BINDS) for n,k in pairs(data.Binds) do if type(n)=="string" and type(k)=="string" then BINDS[n]=k end end end
        for g,t in pairs(data) do local src=g~="Binds" and TABLES[g] if src and type(t)=="table" then for k,v in pairs(t) do local cur=src[k] if cur~=nil then if typeof(cur)=="Color3" and type(v)=="table" and v.__c then src[k]=Color3.fromRGB(v.r,v.g,v.b) elseif typeof(cur)==typeof(v) then src[k]=v end end end end end
        for _,rf in ipairs(_G.__refreshers) do pcall(rf) end
        updateFOVCircles()
    end
    local saved={} local autoloadName=nil local MAX_NAME=30 local MAX_CFG=30
    local cfgSection=createSection("Config","Settings")
    local createCard=mk("Frame",{LayoutOrder=0,Size=UDim2.new(1,-5,0,66),BackgroundColor3=C.card,BackgroundTransparency=0.15,BorderSizePixel=0,Parent=cfgSection.grid}) rnd(createCard,8) str(createCard,C.accent,0.55,1)
    local createTitle=mk("TextLabel",{Position=UDim2.fromOffset(12,6),Size=UDim2.new(1,-24,0,20),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.text,Text="Новый конфиг",Parent=createCard})
    local nameBox=mk("TextBox",{Position=UDim2.fromOffset(12,32),Size=UDim2.new(1,-58,0,24),BackgroundColor3=C.inner,BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=12,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left,PlaceholderText="Название...",PlaceholderColor3=C.sub,ClearTextOnFocus=false,Text="",Parent=createCard}) rnd(nameBox,6)
    local saveBtn=mk("TextButton",{Position=UDim2.new(1,-40,0,32),Size=UDim2.fromOffset(28,24),BackgroundColor3=C.accent,BorderSizePixel=0,AutoButtonColor=true,Font=Enum.Font.GothamBold,TextSize=16,TextColor3=C.text,Text="+",Parent=createCard}) rnd(saveBtn,6)
    local flashId=0
    local function flash(t,col) flashId+=1 local id=flashId createTitle.Text=t createTitle.TextColor3=col or C.text task.delay(1.6,function() if flashId==id then createTitle.Text="Новый конфиг" createTitle.TextColor3=C.text end end) end
    local countCfg=function() local n=0 for _ in pairs(saved) do n+=1 end return n end
    local cards={} local rebuild
    local function doSave() local name=nameBox.Text:gsub("^%s+",""):gsub("%s+$","") if name=="" then flash("Введите название",C.accent) return end if #name>MAX_NAME then flash("Слишком длинное",C.accent) return end if not saved[name] and countCfg()>=MAX_CFG then flash("Максимум "..MAX_CFG,C.accent) return end local existed=saved[name]~=nil saved[name]={data=serialize(),savedAt=os.time()} nameBox.Text="" rebuild() playSnd(true) flash(existed and "Перезаписан" or "Сохранён") end
    saveBtn.MouseButton1Click:Connect(doSave) nameBox.FocusLost:Connect(function(enter) if enter then doSave() end end)
    rebuild=function()
        for _,c in ipairs(cards) do c:Destroy() end table.clear(cards)
        local names={} for n in pairs(saved) do table.insert(names,n) end table.sort(names,function(a,b) return a:lower()<b:lower() end)
        for i,name in ipairs(names) do
            local entry=saved[name] local isAuto=autoloadName==name local sub=os.date("%d.%m %H:%M",entry.savedAt or os.time())..(isAuto and "  ·  авто" or "")
            local card=mk("Frame",{LayoutOrder=i,Size=UDim2.new(1,-5,0,66),BackgroundColor3=C.card,BackgroundTransparency=0.15,BorderSizePixel=0,Parent=cfgSection.grid}) rnd(card,8)
            str(card,isAuto and C.accent or C.line,isAuto and 0.4 or 0.65,1)
            local ico=mk("Frame",{Position=UDim2.fromOffset(12,13),Size=UDim2.fromOffset(10,10),BackgroundColor3=isAuto and C.accent or C.accentD,BorderSizePixel=0,Parent=card}) rnd(ico,3)
            mk("TextLabel",{Position=UDim2.fromOffset(30,6),Size=UDim2.new(1,-100,0,20),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.text,TextTruncate=Enum.TextTruncate.AtEnd,Text=name,Parent=card})
            mk("TextLabel",{Position=UDim2.fromOffset(12,30),Size=UDim2.new(1,-24,0,20),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.sub,Text=sub,Parent=card})
            local loadBtn=mk("TextButton",{Position=UDim2.fromOffset(12,46),Size=UDim2.fromOffset(58,18),BackgroundColor3=C.accent,BorderSizePixel=0,AutoButtonColor=true,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.text,Text="Load",Parent=card}) rnd(loadBtn,5)
            local overBtn=mk("TextButton",{Position=UDim2.fromOffset(76,46),Size=UDim2.fromOffset(58,18),BackgroundColor3=C.inner,BorderSizePixel=0,AutoButtonColor=true,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.text,Text="Save",Parent=card}) rnd(overBtn,5)
            local autoBtn=mk("TextButton",{Position=UDim2.fromOffset(140,46),Size=UDim2.fromOffset(72,18),BackgroundColor3=isAuto and C.accent or C.inner,BorderSizePixel=0,AutoButtonColor=true,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.text,Text=isAuto and "Auto ✓" or "Auto",Parent=card}) rnd(autoBtn,5)
            local delBtn=mk("TextButton",{Position=UDim2.new(1,-32,0,10),Size=UDim2.fromOffset(22,22),BackgroundColor3=C.cardH,BorderSizePixel=0,AutoButtonColor=true,Font=Enum.Font.GothamBold,TextSize=14,TextColor3=C.text,Text="×",Parent=card}) rnd(delBtn,5)
            loadBtn.MouseButton1Click:Connect(function() apply(entry.data) playSnd(true) end)
            overBtn.MouseButton1Click:Connect(function() saved[name]={data=serialize(),savedAt=os.time()} playSnd(true) rebuild() end)
            autoBtn.MouseButton1Click:Connect(function() autoloadName=(autoloadName==name) and nil or name playSnd(autoloadName==name) rebuild() end)
            delBtn.MouseButton1Click:Connect(function() saved[name]=nil if autoloadName==name then autoloadName=nil end playSnd(false) rebuild() end)
            table.insert(cards,card) table.insert(cfgSection.cards,{frame=card,name=name,desc=sub})
        end
    end
    rebuild()
end

-- INFO
local infoSection=createSection("Info")
do
    local old=infoSection.grid:FindFirstChildOfClass("UIGridLayout") if old then old:Destroy() end
    mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,Parent=infoSection.grid})
    local info={{ "Script","DeepHub" },{ "Toggle key","RightControl" },{ "Aim","Aimbot, Legit, Silent Aim" },{ "TriggerBot","Стреляет при прицеле на враге" },{ "Movement","Fly, Noclip, Speed, Jump, Spin, Fullbright" },{ "MM2","Auto Farm монет для Murder Mystery 2" },{ "Settings → Main","Цвета меню/watermark/HUD" },{ "Settings → Config","Сохранение / загрузка" }}
    for i,e in ipairs(info) do
        local c=mk("Frame",{LayoutOrder=i,Size=UDim2.new(1,0,0,46),BackgroundColor3=C.card,BackgroundTransparency=0.15,BorderSizePixel=0,Parent=infoSection.grid}) rnd(c,10) str(c,C.line,0.7,1)
        mk("TextLabel",{Position=UDim2.fromOffset(14,8),Size=UDim2.new(1,-28,0,16),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.accent,Text=e[1],Parent=c})
        mk("TextLabel",{Position=UDim2.fromOffset(14,26),Size=UDim2.new(1,-28,0,18),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=11,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextColor3=C.text,Text=e[2],Parent=c})
    end
end

_G.__menuApi.selectSection("Aim")

-- OPEN/CLOSE
local function openMenu() menuOpen=true frame.Visible=true end
local function closeMenu() menuOpen=false frame.Visible=false end
local function toggleMenu() if menuOpen then closeMenu() else openMenu() end end
UIS.InputBegan:Connect(function(i,gp) if gp then return end if i.KeyCode==CONFIG.MenuKey then toggleMenu() end end)
wmClicked.Event:Connect(toggleMenu)
local topBar=frame:FindFirstChildOfClass("Frame")
local dragging,dragStart,startPos=false,nil,nil
topBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true dragStart=i.Position startPos=frame.Position i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end) end end)
UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-dragStart frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end)

updateFOVCircles()
print("[DeepHub] DONE. RightControl to toggle.")
