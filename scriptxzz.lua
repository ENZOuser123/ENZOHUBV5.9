--[[
    ENZICKS HUB V5.9
    tiktok: @enzoxd_244  (segue la!)
    Feito para Delta (mobile/PC) - tudo em um unico arquivo
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local genv = (getgenv and getgenv()) or _G

if genv.ENZICKS_CLOSE then pcall(genv.ENZICKS_CLOSE) end

local function guiParent()
    local ok, r = pcall(function() return gethui and gethui() end)
    if ok and r then return r end
    ok, r = pcall(function() return game:GetService("CoreGui") end)
    if ok and r then return r end
    return LP:WaitForChild("PlayerGui")
end
local Parent = guiParent()

--------------------------------------------------------------------
-- ESTADO / CONFIG
--------------------------------------------------------------------
local S = {
    theme = "Roxo",
    minAnim = "Mac (Genie)",
    uiScale = 1,
    aim = { on = false, part = "Cabeça", grude = 35, fov = 150, showFov = true, team = false, wall = false },
    esp = { on = false, names = true, health = true, dist = true, team = false, teamColor = false },
    spd = { on = false, mode = "Humanoid", val = 50 },
    jmp = { on = false, mode = "Humanoid", val = 100 },
    noclip = false,
    fly = { on = false, speed = 60 },
    freecam = false,
    freecamSpeed = 60,
    fling = false,
    music = { on = true, vol = 0.5, id = "rbxassetid://1837879082" },
}

local Conns = {}
local function Connect(sig, fn)
    local c = sig:Connect(fn)
    Conns[#Conns + 1] = c
    return c
end

Connect(Workspace:GetPropertyChangedSignal("CurrentCamera"), function()
    Camera = Workspace.CurrentCamera
end)

--------------------------------------------------------------------
-- TEMAS
--------------------------------------------------------------------
local W = Color3.fromRGB
local function mk(bg, panel, elem, off, text, sub, accent, onAccent)
    return { bg = bg, panel = panel, elem = elem, off = off, text = text, sub = sub, accent = accent, onAccent = onAccent }
end
local Themes = {
    Vermelho = mk(W(22,11,12), W(33,17,18), W(48,25,26), W(74,42,44), W(245,240,240), W(195,150,150), W(235,60,60),  W(255,255,255)),
    Amarelo  = mk(W(24,21,10), W(36,31,14), W(52,45,20), W(80,70,34), W(250,246,230), W(200,188,140), W(250,200,30), W(30,25,5)),
    Verde    = mk(W(10,22,14), W(15,34,21), W(23,50,31), W(38,74,48), W(236,248,240), W(150,195,162), W(45,205,100), W(255,255,255)),
    Azul     = mk(W(10,16,28), W(15,24,42), W(22,36,62), W(38,58,92), W(236,242,252), W(150,172,208), W(55,140,255), W(255,255,255)),
    Roxo     = mk(W(18,11,28), W(27,17,42), W(40,25,62), W(64,44,94), W(244,238,252), W(178,156,208), W(160,90,255), W(255,255,255)),
    Escuro   = mk(W(14,14,16), W(22,22,25), W(33,33,37), W(58,58,64), W(240,240,242), W(150,150,158), W(205,205,215), W(20,20,22)),
    Branco   = mk(W(244,244,247), W(255,255,255), W(232,232,238), W(200,200,212), W(25,25,30), W(110,110,125), W(0,122,255), W(255,255,255)),
}
local ThemeOrder = { "Vermelho", "Amarelo", "Verde", "Azul", "Roxo", "Escuro", "Branco" }

local Reg = {}
local function resolve(k, t)
    if type(k) == "function" then return k(t) end
    return t[k]
end
local function tw(inst, time, props, style, dir)
    local t = TweenService:Create(inst, TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end
local function Themed(inst, prop, key)
    local e = { inst, prop, key }
    Reg[#Reg + 1] = e
    inst[prop] = resolve(key, Themes[S.theme])
    return e
end
local function Refresh(e)
    if e[1] and e[1].Parent then tw(e[1], 0.2, { [e[2]] = resolve(e[3], Themes[S.theme]) }) end
end
local function Retheme()
    local t = Themes[S.theme]
    for _, e in ipairs(Reg) do
        if e[1] and e[1].Parent then tw(e[1], 0.35, { [e[2]] = resolve(e[3], t) }) end
    end
end

--------------------------------------------------------------------
-- HELPERS DE UI
--------------------------------------------------------------------
local function New(class, props, children)
    local i = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then i[k] = v end
    end
    for _, c in ipairs(children or {}) do c.Parent = i end
    if props and props.Parent then i.Parent = props.Parent end
    return i
end
local function Corner(r) return New("UICorner", { CornerRadius = UDim.new(0, r) }) end
local F = Enum.Font

local Gui = New("ScreenGui", {
    Name = "ENZICKS_HUB", ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
})
pcall(function() if syn and syn.protect_gui then syn.protect_gui(Gui) end end)
Gui.Parent = Parent

local ESPFolder = New("Folder", { Name = "ENZICKS_ESP", Parent = Parent })

local function Text(parent, txt, size, font, colorKey, props)
    local l = New("TextLabel", {
        BackgroundTransparency = 1, Text = txt, TextSize = size, Font = font,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = parent,
    })
    for k, v in pairs(props or {}) do l[k] = v end
    Themed(l, "TextColor3", colorKey)
    return l
end

--------------------------------------------------------------------
-- PERSONAGEM / DEFAULTS
--------------------------------------------------------------------
local function chr()
    local c = LP.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local r = c and c:FindFirstChild("HumanoidRootPart")
    return c, h, r
end

local D = {}
local function saveDefaults(h)
    if D.hum ~= h then
        D.hum = h
        D.ws, D.jp, D.jh, D.use = h.WalkSpeed, h.JumpPower, h.JumpHeight, h.UseJumpPower
    end
end
local function restoreSpeed()
    local _, h = chr()
    if h and D.hum == h and D.ws then h.WalkSpeed = D.ws end
end
local function restoreJump()
    local _, h = chr()
    if h and D.hum == h then
        h.UseJumpPower = D.use
        h.JumpPower = D.jp
        h.JumpHeight = D.jh
    end
end

local function camDir(cf, md)
    if md.Magnitude < 0.05 then return Vector3.zero end
    local fl = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
    local fr = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z)
    if fl.Magnitude < 0.01 or fr.Magnitude < 0.01 then return md end
    local d = cf.LookVector * md:Dot(fl.Unit) + cf.RightVector * md:Dot(fr.Unit)
    if d.Magnitude > 0.01 then return d.Unit end
    return Vector3.zero
end

--------------------------------------------------------------------
-- FUNCOES: FLY / FREECAM
--------------------------------------------------------------------
local UI = {}

local function setFly(v)
    S.fly.on = v
    local _, h, r = chr()
    if not h then return end
    h.PlatformStand = v
    if not v then
        h:ChangeState(Enum.HumanoidStateType.GettingUp)
        if r then r.AssemblyLinearVelocity = Vector3.zero end
    end
end

local fc = { yaw = 0, pitch = 0, pos = Vector3.zero }
local function setFreecam(v)
    S.freecam = v
    local _, h, r = chr()
    if v then
        local x, y = Camera.CFrame:ToOrientation()
        fc.pitch, fc.yaw, fc.pos = x, y, Camera.CFrame.Position
        Camera.CameraType = Enum.CameraType.Scriptable
        if r then r.Anchored = true end
    else
        if r then r.Anchored = false end
        Camera.CameraType = Enum.CameraType.Custom
        if h then Camera.CameraSubject = h end
    end
end

Connect(UIS.InputChanged, function(i, gp)
    if not S.freecam or gp then return end
    local d
    if i.UserInputType == Enum.UserInputType.Touch then
        d = i.Delta * 0.25
    elseif i.UserInputType == Enum.UserInputType.MouseMovement and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        d = i.Delta * 0.2
    end
    if d then
        fc.yaw = fc.yaw - math.rad(d.X)
        fc.pitch = math.clamp(fc.pitch - math.rad(d.Y), -1.45, 1.45)
    end
end)

--------------------------------------------------------------------
-- AIMBOT
--------------------------------------------------------------------
local PartMap = {
    ["Cabeça"]          = { "Head" },
    ["Torso"]           = { "UpperTorso", "Torso", "HumanoidRootPart" },
    ["Braço Direito"]   = { "RightUpperArm", "Right Arm" },
    ["Braço Esquerdo"]  = { "LeftUpperArm", "Left Arm" },
    ["Perna Direita"]   = { "RightUpperLeg", "Right Leg" },
    ["Perna Esquerda"]  = { "LeftUpperLeg", "Left Leg" },
}
local PartNames = { "Cabeça", "Torso", "Braço Direito", "Braço Esquerdo", "Perna Direita", "Perna Esquerda" }

local function getPart(char)
    for _, n in ipairs(PartMap[S.aim.part]) do
        local p = char:FindFirstChild(n)
        if p then return p end
    end
end

local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Exclude
local function visible(part)
    rp.FilterDescendantsInstances = { LP.Character, part.Parent }
    return Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, rp) == nil
end

local FOV = New("Frame", {
    AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
    Size = UDim2.fromOffset(S.aim.fov * 2, S.aim.fov * 2),
    BackgroundTransparency = 1, Visible = false, Parent = Gui,
}, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
local fovStroke = New("UIStroke", { Thickness = 1.5, Transparency = .25, Parent = FOV })
Themed(fovStroke, "Color", "accent")

local function getTarget()
    local best, bd = nil, S.aim.fov
    local center = Camera.ViewportSize / 2
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local sameTeam = p.Team ~= nil and p.Team == LP.Team
            if hum and hum.Health > 0 and not (S.aim.team and sameTeam) then
                local part = getPart(p.Character)
                if part then
                    local sp, on = Camera:WorldToViewportPoint(part.Position)
                    if on then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if d < bd and (not S.aim.wall or visible(part)) then
                            best, bd = part, d
                        end
                    end
                end
            end
        end
    end
    return best
end

pcall(function() RunService:UnbindFromRenderStep("ENZICKS_AIM") end)
RunService:BindToRenderStep("ENZICKS_AIM", Enum.RenderPriority.Camera.Value + 1, function()
    FOV.Visible = S.aim.on and S.aim.showFov
    if not S.aim.on or S.freecam then return end
    local part = getTarget()
    if not part then return end
    local cf = Camera.CFrame
    local alpha = math.clamp(S.aim.grude / 100, 0.02, 1)
    Camera.CFrame = cf:Lerp(CFrame.lookAt(cf.Position, part.Position), alpha)
end)

-- Freecam update
Connect(RunService.RenderStepped, function(dt)
    if S.freecam then
        local _, h = chr()
        local md = h and h.MoveDirection or Vector3.zero
        local cf = CFrame.new(fc.pos) * CFrame.fromOrientation(fc.pitch, fc.yaw, 0)
        fc.pos = fc.pos + camDir(cf, md) * S.freecamSpeed * dt
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = CFrame.new(fc.pos) * CFrame.fromOrientation(fc.pitch, fc.yaw, 0)
    end
end)

--------------------------------------------------------------------
-- ESP
--------------------------------------------------------------------
local esp = {}
local function clearESP(p)
    local o = esp[p]
    if o then
        pcall(function() o.hl:Destroy() end)
        pcall(function() o.bb:Destroy() end)
        esp[p] = nil
    end
end
Connect(Players.PlayerRemoving, clearESP)

local espAcc = 0
local function updateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local c = p.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            local head = c and (c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart"))
            local sameTeam = p.Team ~= nil and p.Team == LP.Team
            if S.esp.on and h and head and h.Health > 0 and not (S.esp.team and sameTeam) then
                local o = esp[p]
                if not o or o.char ~= c then
                    clearESP(p)
                    local hl = New("Highlight", {
                        Adornee = c, FillTransparency = .65, OutlineTransparency = 0,
                        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Parent = ESPFolder,
                    })
                    local lbl = New("TextLabel", {
                        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, TextSize = 13,
                        Font = F.GothamBold, TextStrokeTransparency = 0, Text = "",
                    })
                    local bb = New("BillboardGui", {
                        Adornee = head, Size = UDim2.fromOffset(180, 44), StudsOffset = Vector3.new(0, 2.6, 0),
                        AlwaysOnTop = true, Parent = ESPFolder,
                    }, { lbl })
                    o = { hl = hl, bb = bb, lbl = lbl, char = c }
                    esp[p] = o
                end
                local col = S.esp.teamColor and p.TeamColor.Color or Themes[S.theme].accent
                o.hl.FillColor, o.hl.OutlineColor = col, col
                o.lbl.TextColor3 = col
                local lines = {}
                if S.esp.names then lines[#lines + 1] = p.DisplayName end
                local info = {}
                if S.esp.health then info[#info + 1] = math.floor(h.Health) .. " HP" end
                if S.esp.dist then info[#info + 1] = math.floor((Camera.CFrame.Position - head.Position).Magnitude) .. "m" end
                if #info > 0 then lines[#lines + 1] = table.concat(info, " • ") end
                o.lbl.Text = table.concat(lines, "\n")
            else
                clearESP(p)
            end
        end
    end
end

--------------------------------------------------------------------
-- LOOPS DE MOVIMENTO
--------------------------------------------------------------------
local fv = Vector3.zero

Connect(RunService.Heartbeat, function(dt)
    espAcc = espAcc + dt
    if espAcc > 0.1 then
        espAcc = 0
        updateESP()
    end

    local _, h, r = chr()
    if not (h and r) then return end
    saveDefaults(h)

    -- Velocidade
    if S.spd.on then
        if S.spd.mode == "Humanoid" then
            h.WalkSpeed = S.spd.val
        elseif not S.fly.on and not S.freecam then
            local md = h.MoveDirection
            if md.Magnitude > 0 then
                r.CFrame = r.CFrame + md * math.max(S.spd.val - 16, 0) * dt
            end
        end
    end

    -- Pulo (modo Humanoid)
    if S.jmp.on and S.jmp.mode == "Humanoid" then
        h.UseJumpPower = true
        h.JumpPower = S.jmp.val
    end

    -- Fly (camera livre, sem botoes: joystick + direcao da camera)
    if S.fly.on and not S.freecam then
        h.PlatformStand = true
        local cf = Camera.CFrame
        r.AssemblyLinearVelocity = camDir(cf, h.MoveDirection) * S.fly.speed
        local look = cf.LookVector
        local flat = Vector3.new(look.X, 0, look.Z)
        if flat.Magnitude > 0.01 then
            r.CFrame = CFrame.lookAt(r.Position, r.Position + flat)
        end
    end

    -- Fling (velocity trick)
    if S.fling then
        fv = r.AssemblyLinearVelocity
        r.AssemblyLinearVelocity = fv * 1e4 + Vector3.new(0, 1e4, 0)
    end
end)

Connect(RunService.RenderStepped, function()
    if S.fling then
        local _, _, r = chr()
        if r then r.AssemblyLinearVelocity = fv end
    end
end)

Connect(RunService.Stepped, function()
    if S.noclip then
        local c = LP.Character
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

-- Pulo em modo CFrame
Connect(UIS.JumpRequest, function()
    if S.jmp.on and S.jmp.mode == "CFrame" then
        local _, h, r = chr()
        if h and r and h.FloorMaterial ~= Enum.Material.Air then
            task.spawn(function()
                RunService.Stepped:Wait()
                local v = r.AssemblyLinearVelocity
                r.AssemblyLinearVelocity = Vector3.new(v.X, S.jmp.val, v.Z)
            end)
        end
    end
end)

-- Fling no jogador mais proximo
local flinging = false
local function flingNearest()
    if flinging then return end
    local _, _, r = chr()
    if not r then return end
    local best, bd
    for _, p in ipairs(Players:GetPlayers()) do
        local tr = p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if tr then
            local d = (tr.Position - r.Position).Magnitude
            if not bd or d < bd then best, bd = p, d end
        end
    end
    if not best then return end
    flinging = true
    local orig = r.CFrame
    local t0 = tick()
    task.spawn(function()
        while tick() - t0 < 2.2 and r.Parent do
            local tr = best.Character and best.Character:FindFirstChild("HumanoidRootPart")
            if not tr then break end
            r.CFrame = tr.CFrame * CFrame.new(math.random(-5, 5) / 10, 0, math.random(-5, 5) / 10)
            r.AssemblyAngularVelocity = Vector3.new(0, 1e5, 0)
            r.AssemblyLinearVelocity = Vector3.new(math.random(-1e4, 1e4), 1e4, math.random(-1e4, 1e4))
            RunService.Heartbeat:Wait()
        end
        r.AssemblyAngularVelocity = Vector3.zero
        r.AssemblyLinearVelocity = Vector3.zero
        r.CFrame = orig
        flinging = false
    end)
end

-- Respawn
Connect(LP.CharacterAdded, function()
    if S.freecam then
        S.freecam = false
        Camera.CameraType = Enum.CameraType.Custom
        if UI.freecam then UI.freecam(false, true) end
    end
    if S.fly.on then
        S.fly.on = false
        if UI.fly then UI.fly(false, true) end
    end
end)

--------------------------------------------------------------------
-- MUSICA
--------------------------------------------------------------------
local function normId(t)
    t = tostring(t or "")
    if tonumber(t) then return "rbxassetid://" .. t end
    return t
end
local Music = New("Sound", {
    Name = "ENZICKS_MUSIC", Looped = true, Volume = S.music.vol,
    SoundId = normId(S.music.id), Parent = Gui,
})
local function setMusic(on)
    S.music.on = on
    pcall(function()
        if on then Music:Play() else Music:Pause() end
    end)
end

--------------------------------------------------------------------
-- JANELA PRINCIPAL
--------------------------------------------------------------------
local vp = Camera.ViewportSize
local normalSize = UDim2.fromOffset(math.min(500, vp.X - 20), math.min(320, vp.Y - 20))

local Win = New("CanvasGroup", {
    Name = "Win", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromOffset(vp.X / 2, vp.Y / 2),
    Size = normalSize, Visible = false, Active = true, BorderSizePixel = 0, GroupTransparency = 1, Parent = Gui,
}, { Corner(14) })
Themed(Win, "BackgroundColor3", "bg")
local WinScale = New("UIScale", { Scale = S.uiScale, Parent = Win })
local winStroke = New("UIStroke", { Thickness = 1.5, Transparency = .35, Parent = Win })
Themed(winStroke, "Color", "accent")

-- Barra de titulo
local Top = New("Frame", { Size = UDim2.new(1, 0, 0, 38), BorderSizePixel = 0, Parent = Win })
Themed(Top, "BackgroundColor3", "panel")

-- Orbe (bolinha com raio)
local Orb = New("TextButton", {
    Name = "Orb", Text = "", AutoButtonColor = false, AnchorPoint = Vector2.new(.5, .5),
    Position = UDim2.fromOffset(42, vp.Y * 0.35), Size = UDim2.fromOffset(54, 54), ZIndex = 5, Parent = Gui,
}, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
Themed(Orb, "BackgroundColor3", "accent")
local OrbScale = New("UIScale", { Scale = 0, Parent = Orb })
local orbStroke = New("UIStroke", { Thickness = 2, Color = Color3.new(1, 1, 1), Transparency = .3, Parent = Orb })
local orbGlow = New("Frame", {
    AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = .6, ZIndex = 4, Parent = Orb,
}, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
Themed(orbGlow, "BackgroundColor3", "accent")
local orbBolt = New("TextLabel", {
    Text = "⚡", TextSize = 28, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 6, Parent = Orb,
})
Themed(orbBolt, "TextColor3", "onAccent")
TweenService:Create(orbGlow, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    { Size = UDim2.fromScale(1.55, 1.55), BackgroundTransparency = 1 }):Play()

-- Draggable (janela e orbe)
local function Draggable(handle, target, onTap)
    local drag, sp, so, moved
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag, sp, moved = i, i.Position, false
            so = target.AbsolutePosition + target.AbsoluteSize / 2
        end
    end)
    Connect(UIS.InputChanged, function(i)
        if drag and (i == drag or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = i.Position - sp
            if d.Magnitude > 5 then moved = true end
            if moved then
                local v = Camera.ViewportSize
                target.Position = UDim2.fromOffset(
                    math.clamp(so.X + d.X, 20, v.X - 20),
                    math.clamp(so.Y + d.Y, 20, v.Y - 20))
            end
        end
    end)
    Connect(UIS.InputEnded, function(i)
        if drag and (i == drag or (i.UserInputType == Enum.UserInputType.MouseButton1 and drag.UserInputType == Enum.UserInputType.MouseButton1)) then
            local was = moved
            drag = nil
            if not was and onTap then onTap() end
        end
    end)
end

-- Estado da janela + animacoes
local mem = { size = normalSize, pos = Win.Position }
local visibleWin, busy, lastHide, maxed = false, false, "close", false

local function popParams()
    if S.minAnim == "Leve" then return .92, .16 end
    return .78, .26
end

local function showWin()
    if visibleWin or busy then return end
    visibleWin, busy = true, true
    Win.Visible = true
    local m = S.minAnim
    if m == "Sem animação" then
        Win.Size, Win.Position, Win.GroupTransparency, WinScale.Scale = mem.size, mem.pos, 0, S.uiScale
        busy = false
        return
    end
    if lastHide == "min" and m == "Mac (Genie)" then
        Win.Size = UDim2.fromOffset(40, 40)
        Win.Position = Orb.Position
        Win.GroupTransparency = 1
        WinScale.Scale = S.uiScale
        tw(Win, .2, { GroupTransparency = 0 }, Enum.EasingStyle.Quad)
        tw(Win, .45, { Size = mem.size, Position = mem.pos }, Enum.EasingStyle.Quint)
        task.delay(.46, function() busy = false end)
    else
        local s, t = popParams()
        Win.Size, Win.Position, Win.GroupTransparency = mem.size, mem.pos, 1
        WinScale.Scale = S.uiScale * s
        tw(WinScale, t + .1, { Scale = S.uiScale }, Enum.EasingStyle.Back)
        tw(Win, t, { GroupTransparency = 0 }, Enum.EasingStyle.Quad)
        task.delay(t + .11, function() busy = false end)
    end
end

local function hideWin(kind)
    if not visibleWin or busy then return end
    busy, visibleWin, lastHide = true, false, kind
    mem.size, mem.pos = Win.Size, Win.Position
    local m = S.minAnim
    local function fin()
        Win.Visible = false
        Win.Size, Win.Position = mem.size, mem.pos
        WinScale.Scale = S.uiScale
        busy = false
    end
    if m == "Sem animação" then
        fin()
    elseif kind == "min" and m == "Mac (Genie)" then
        local w, h = mem.size.X.Offset, mem.size.Y.Offset
        tw(Win, .26, {
            Size = UDim2.fromOffset(w * .62, h * .55),
            Position = mem.pos:Lerp(Orb.Position, .35),
        }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.delay(.24, function()
            tw(Win, .26, {
                Size = UDim2.fromOffset(40, 40), Position = Orb.Position, GroupTransparency = 1,
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        end)
        task.delay(.52, fin)
    else
        local s, t = popParams()
        tw(WinScale, t, { Scale = S.uiScale * s }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        tw(Win, t, { GroupTransparency = 1 }, Enum.EasingStyle.Quad)
        task.delay(t + .02, fin)
    end
end

local function toggleWin()
    if visibleWin then hideWin("min") else showWin() end
end

local function toggleMax()
    if not visibleWin or busy then return end
    maxed = not maxed
    local v = Camera.ViewportSize
    local sc = S.uiScale
    local size = normalSize
    if maxed then
        size = UDim2.fromOffset(math.min(720, v.X / sc - 30), math.min(480, v.Y / sc - 30))
    end
    tw(Win, .4, { Size = size, Position = UDim2.fromOffset(v.X / 2, v.Y / 2) })
    mem.size = size
end

Draggable(Top, Win)
Draggable(Orb, Orb, toggleWin)
Connect(UIS.InputBegan, function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.RightShift then toggleWin() end
end)

-- Botoes estilo macOS
local function Light(x, color, cb)
    local b = New("TextButton", {
        Text = "", AutoButtonColor = false, BackgroundColor3 = color, Size = UDim2.fromOffset(13, 13),
        AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, x, .5, 0), Parent = Top,
    }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    b.MouseEnter:Connect(function() tw(b, .12, { Size = UDim2.fromOffset(16, 16) }) end)
    b.MouseLeave:Connect(function() tw(b, .12, { Size = UDim2.fromOffset(13, 13) }) end)
    b.Activated:Connect(cb)
    return b
end
Light(14, W(255, 95, 87), function() hideWin("close") end)  -- fechar (volta pela bolinha)
Light(34, W(254, 188, 46), function() hideWin("min") end)   -- minimizar
Light(54, W(40, 200, 64), toggleMax)                         -- maximizar

local Title = Text(Top, "ENZICKS HUB V5.9", 14, F.GothamBlack, "accent", {
    Position = UDim2.fromOffset(80, 0), Size = UDim2.new(0, 150, 1, 0),
})
local Sub = Text(Top, "tiktok: @enzoxd_244 • segue lá", 11, F.GothamMedium, "sub", {
    AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 0), Size = UDim2.new(1, -250, 1, 0),
    TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd,
})

-- Sidebar + conteudo
local Side = New("Frame", {
    Position = UDim2.fromOffset(0, 38), Size = UDim2.new(0, 112, 1, -38), BorderSizePixel = 0, Parent = Win,
}, {
    New("UIListLayout", { Padding = UDim.new(0, 4) }),
    New("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
})
Themed(Side, "BackgroundColor3", "panel")

local Holder = New("Frame", {
    Position = UDim2.fromOffset(112, 38), Size = UDim2.new(1, -112, 1, -38), BackgroundTransparency = 1, ClipsDescendants = true, Parent = Win,
})

local Pages, tabEntries, currentTab = {}, {}, nil
local function SelectTab(name)
    currentTab = name
    for n, pg in pairs(Pages) do
        local on = n == name
        pg.Visible = on
        if on then
            pg.Position = UDim2.fromOffset(0, 12)
            tw(pg, .3, { Position = UDim2.fromOffset(0, 0) })
        end
    end
    for _, e in ipairs(tabEntries) do Refresh(e) end
end

local function AddTab(name, label)
    local btn = New("TextButton", {
        Text = label, Font = F.GothamBold, TextSize = 12, AutoButtonColor = false,
        Size = UDim2.new(1, 0, 0, 32), TextXAlignment = Enum.TextXAlignment.Left, Parent = Side,
    }, { Corner(8), New("UIPadding", { PaddingLeft = UDim.new(0, 10) }) })
    tabEntries[#tabEntries + 1] = Themed(btn, "BackgroundColor3", function(t) return currentTab == name and t.accent or t.panel end)
    tabEntries[#tabEntries + 1] = Themed(btn, "TextColor3", function(t) return currentTab == name and t.onAccent or t.sub end)
    btn.Activated:Connect(function() SelectTab(name) end)

    local page = New("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
        AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ScrollBarThickness = 3, Parent = Holder,
    }, {
        New("UIListLayout", { Padding = UDim.new(0, 6) }),
        New("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }),
    })
    Themed(page, "ScrollBarImageColor3", "accent")
    Pages[name] = page
    return page
end

-- Componentes
local function Row(page, h, plain)
    local r = New("Frame", { Size = UDim2.new(1, 0, 0, h), BackgroundTransparency = plain and 1 or 0, BorderSizePixel = 0, Parent = page }, { Corner(8) })
    if not plain then Themed(r, "BackgroundColor3", "elem") end
    return r
end

local function Section(page, txt)
    local r = Row(page, 20, true)
    Text(r, string.upper(txt), 11, F.GothamBlack, "accent", { Size = UDim2.fromScale(1, 1), Position = UDim2.fromOffset(4, 0) })
end

local function Toggle(page, txt, default, cb)
    local state = default
    local row = Row(page, 34)
    Text(row, txt, 13, F.GothamMedium, "text", { Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -60, 1, 0) })
    local track = New("TextButton", {
        Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(40, 20), AnchorPoint = Vector2.new(1, .5),
        Position = UDim2.new(1, -10, .5, 0), Parent = row,
    }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    local e = Themed(track, "BackgroundColor3", function(t) return state and t.accent or t.off end)
    local knob = New("Frame", {
        Size = UDim2.fromOffset(16, 16), AnchorPoint = Vector2.new(0, .5), BackgroundColor3 = Color3.new(1, 1, 1),
        Position = state and UDim2.new(1, -18, .5, 0) or UDim2.new(0, 2, .5, 0), Parent = track,
    }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    local function set(v, silent)
        state = v
        tw(knob, .22, { Position = v and UDim2.new(1, -18, .5, 0) or UDim2.new(0, 2, .5, 0) }, Enum.EasingStyle.Back)
        Refresh(e)
        if not silent then cb(v) end
    end
    track.Activated:Connect(function() set(not state) end)
    return set
end

local function Slider(page, txt, min, max, default, cb)
    local row = Row(page, 48)
    Text(row, txt, 13, F.GothamMedium, "text", { Position = UDim2.fromOffset(10, 4), Size = UDim2.new(.7, 0, 0, 18) })
    local valLbl = Text(row, tostring(default), 12, F.GothamBold, "accent", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 4), Size = UDim2.new(.3, 0, 0, 18), TextXAlignment = Enum.TextXAlignment.Right,
    })
    local bar = New("Frame", { Position = UDim2.new(0, 10, 0, 33), Size = UDim2.new(1, -20, 0, 6), BorderSizePixel = 0, Parent = row }, { Corner(3) })
    Themed(bar, "BackgroundColor3", "off")
    local ratio = (default - min) / (max - min)
    local fill = New("Frame", { Size = UDim2.new(ratio, 0, 1, 0), BorderSizePixel = 0, Parent = bar }, { Corner(3) })
    Themed(fill, "BackgroundColor3", "accent")
    local knob = New("Frame", {
        Size = UDim2.fromOffset(16, 16), AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(ratio, 0, .5, 0),
        BackgroundColor3 = Color3.new(1, 1, 1), Parent = bar,
    }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    local hit = New("TextButton", {
        Text = "", BackgroundTransparency = 1, Position = UDim2.new(0, 4, 0, 22), Size = UDim2.new(1, -8, 0, 26), Parent = row,
    })
    local dragging = false
    local function upd(x)
        local r = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
        local v = math.floor(min + r * (max - min) + .5)
        fill.Size = UDim2.new(r, 0, 1, 0)
        knob.Position = UDim2.new(r, 0, .5, 0)
        valLbl.Text = tostring(v)
        cb(v)
    end
    hit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            page.ScrollingEnabled = false
            tw(knob, .12, { Size = UDim2.fromOffset(20, 20) })
            upd(i.Position.X)
        end
    end)
    Connect(UIS.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            upd(i.Position.X)
        end
    end)
    Connect(UIS.InputEnded, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            page.ScrollingEnabled = true
            tw(knob, .12, { Size = UDim2.fromOffset(16, 16) })
        end
    end)
end

local function Selector(page, txt, opts, default, cb)
    local cur = default
    local rows = math.ceil(#opts / 3)
    local row = Row(page, 30 + rows * 30)
    Text(row, txt, 13, F.GothamMedium, "text", { Position = UDim2.fromOffset(10, 4), Size = UDim2.new(1, -20, 0, 20) })
    local grid = New("Frame", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 28), Size = UDim2.new(1, -16, 0, rows * 30), Parent = row,
    }, { New("UIGridLayout", { CellSize = UDim2.new(1 / 3, -5, 0, 26), CellPadding = UDim2.fromOffset(6, 4) }) })
    local ents = {}
    for _, o in ipairs(opts) do
        local b = New("TextButton", {
            Text = o, Font = F.GothamBold, TextSize = 11, AutoButtonColor = false, TextTruncate = Enum.TextTruncate.AtEnd, Parent = grid,
        }, { Corner(6) })
        ents[#ents + 1] = Themed(b, "BackgroundColor3", function(t) return cur == o and t.accent or t.off end)
        ents[#ents + 1] = Themed(b, "TextColor3", function(t) return cur == o and t.onAccent or t.text end)
        b.Activated:Connect(function()
            cur = o
            for _, e in ipairs(ents) do Refresh(e) end
            cb(o)
        end)
    end
end

local function Button(page, txt, cb)
    local row = Row(page, 34, true)
    local b = New("TextButton", {
        Text = txt, Font = F.GothamBold, TextSize = 13, AutoButtonColor = false, Size = UDim2.fromScale(1, 1), Parent = row,
    }, { Corner(8) })
    Themed(b, "BackgroundColor3", "accent")
    Themed(b, "TextColor3", "onAccent")
    b.Activated:Connect(function()
        tw(b, .08, { Size = UDim2.fromScale(.96, .9) })
        task.delay(.08, function() tw(b, .2, { Size = UDim2.fromScale(1, 1) }, Enum.EasingStyle.Back) end)
        cb()
    end)
end

local function Input(page, txt, default, cb)
    local row = Row(page, 34)
    Text(row, txt, 13, F.GothamMedium, "text", { Position = UDim2.fromOffset(10, 0), Size = UDim2.new(.4, 0, 1, 0) })
    local tb = New("TextBox", {
        AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -8, .5, 0), Size = UDim2.new(.56, 0, 0, 24),
        Text = default, PlaceholderText = "ID do áudio...", ClearTextOnFocus = false, Font = F.Gotham, TextSize = 12,
        BorderSizePixel = 0, Parent = row,
    }, { Corner(6) })
    Themed(tb, "BackgroundColor3", "off")
    Themed(tb, "TextColor3", "text")
    Themed(tb, "PlaceholderColor3", "sub")
    tb.FocusLost:Connect(function() cb(tb.Text) end)
end

local function Info(page, txt, h)
    local row = Row(page, h or 24)
    Text(row, txt, 12, F.GothamMedium, "text", {
        Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0), TextWrapped = true,
    })
end

--------------------------------------------------------------------
-- ABAS
--------------------------------------------------------------------
-- COMBATE
local pCombat = AddTab("Combate", "🎯  Combate")
Section(pCombat, "Aimbot")
Toggle(pCombat, "Aimbot", false, function(v) S.aim.on = v end)
Selector(pCombat, "Mirar em", PartNames, S.aim.part, function(v) S.aim.part = v end)
Slider(pCombat, "Grude (força da mira)", 1, 100, S.aim.grude, function(v) S.aim.grude = v end)
Slider(pCombat, "Tamanho do FOV", 30, 400, S.aim.fov, function(v)
    S.aim.fov = v
    FOV.Size = UDim2.fromOffset(v * 2, v * 2)
end)
Toggle(pCombat, "Mostrar círculo do FOV", true, function(v) S.aim.showFov = v end)
Toggle(pCombat, "Ignorar meu time", false, function(v) S.aim.team = v end)
Toggle(pCombat, "Checar parede", false, function(v) S.aim.wall = v end)

-- VISUAL
local pVisual = AddTab("Visual", "👁  Visual")
Section(pVisual, "ESP")
Toggle(pVisual, "ESP", false, function(v) S.esp.on = v end)
Toggle(pVisual, "Mostrar nome", true, function(v) S.esp.names = v end)
Toggle(pVisual, "Mostrar vida", true, function(v) S.esp.health = v end)
Toggle(pVisual, "Mostrar distância", true, function(v) S.esp.dist = v end)
Toggle(pVisual, "Ignorar meu time", false, function(v) S.esp.team = v end)
Toggle(pVisual, "Usar cor do time", false, function(v) S.esp.teamColor = v end)

-- PLAYER
local pPlayer = AddTab("Player", "🏃  Player")
Section(pPlayer, "Velocidade")
Toggle(pPlayer, "WalkSpeed", false, function(v)
    S.spd.on = v
    if not v then restoreSpeed() end
end)
Selector(pPlayer, "Modo do WalkSpeed", { "Humanoid", "CFrame" }, S.spd.mode, function(v)
    S.spd.mode = v
    restoreSpeed()
end)
Slider(pPlayer, "Valor do WalkSpeed", 16, 300, S.spd.val, function(v) S.spd.val = v end)

Section(pPlayer, "Pulo")
Toggle(pPlayer, "JumpPower", false, function(v)
    S.jmp.on = v
    if not v then restoreJump() end
end)
Selector(pPlayer, "Modo do JumpPower", { "Humanoid", "CFrame" }, S.jmp.mode, function(v)
    S.jmp.mode = v
    restoreJump()
end)
Slider(pPlayer, "Valor do JumpPower", 50, 300, S.jmp.val, function(v) S.jmp.val = v end)

Section(pPlayer, "Movimento")
Toggle(pPlayer, "Noclip", false, function(v) S.noclip = v end)
UI.fly = Toggle(pPlayer, "Fly (câmera livre, sem botões)", false, function(v) setFly(v) end)
Slider(pPlayer, "Velocidade do Fly", 10, 300, S.fly.speed, function(v) S.fly.speed = v end)
UI.freecam = Toggle(pPlayer, "Câmera livre (Freecam)", false, function(v) setFreecam(v) end)
Slider(pPlayer, "Velocidade da Freecam", 10, 300, S.freecamSpeed, function(v) S.freecamSpeed = v end)

Section(pPlayer, "Fling")
Toggle(pPlayer, "Fling (encostar nos outros)", false, function(v) S.fling = v end)
Button(pPlayer, "Fling no jogador mais próximo", flingNearest)

-- CONFIG
local pConfig = AddTab("Config", "⚙  Config")
Section(pConfig, "Tema")
Selector(pConfig, "Cor do tema", ThemeOrder, S.theme, function(v)
    S.theme = v
    Retheme()
end)
Section(pConfig, "Animações")
Selector(pConfig, "Animação de minimizar", { "Mac (Genie)", "Leve", "Sem animação" }, S.minAnim, function(v) S.minAnim = v end)
Slider(pConfig, "Tamanho da UI (%)", 60, 130, 100, function(v)
    S.uiScale = v / 100
    if visibleWin and not busy then WinScale.Scale = S.uiScale end
end)
Section(pConfig, "Música de fundo")
Toggle(pConfig, "Tocar música", S.music.on, setMusic)
Slider(pConfig, "Volume", 0, 100, math.floor(S.music.vol * 100), function(v)
    S.music.vol = v / 100
    Music.Volume = S.music.vol
end)
Input(pConfig, "ID da música", "", function(txt)
    if txt ~= "" then
        S.music.id = normId(txt)
        Music.SoundId = S.music.id
        if S.music.on then pcall(function() Music:Play() end) end
    end
end)
Section(pConfig, "Script")
Button(pConfig, "Resetar posição da UI e da bolinha", function()
    local v = Camera.ViewportSize
    Win.Position = UDim2.fromOffset(v.X / 2, v.Y / 2)
    mem.pos = Win.Position
    Orb.Position = UDim2.fromOffset(42, v.Y * .35)
end)

-- INFO
local pInfo = AddTab("Info", "ℹ  Info")
Section(pInfo, "ENZICKS HUB V5.9")
Info(pInfo, "Criador: tiktok @enzoxd_244 — segue lá!", 28)
Info(pInfo, "Vermelho = fechar (volta pela bolinha ⚡) • Amarelo = minimizar • Verde = maximizar.", 44)
Info(pInfo, "Arraste a bolinha ⚡ para mover; toque nela para abrir/fechar. No PC: RightShift.", 44)
Info(pInfo, "Fly e Freecam: joystick move na direção da câmera, arraste a tela para olhar.", 44)
Button(pInfo, "Copiar @enzoxd_244", function()
    pcall(function() if setclipboard then setclipboard("@enzoxd_244") end end)
end)

--------------------------------------------------------------------
-- DESCARREGAR
--------------------------------------------------------------------
local function Unload()
    S.aim.on, S.esp.on, S.noclip, S.fling, S.spd.on, S.jmp.on = false, false, false, false, false, false
    pcall(function() setFly(false) end)
    pcall(function() setFreecam(false) end)
    pcall(restoreSpeed)
    pcall(restoreJump)
    pcall(function() RunService:UnbindFromRenderStep("ENZICKS_AIM") end)
    for _, c in ipairs(Conns) do pcall(function() c:Disconnect() end) end
    for p in pairs(esp) do clearESP(p) end
    pcall(function() ESPFolder:Destroy() end)
    pcall(function() Gui:Destroy() end)
    genv.ENZICKS_CLOSE = nil
end
genv.ENZICKS_CLOSE = Unload
Button(pConfig, "Descarregar script (fechar tudo)", Unload)

SelectTab("Combate")

--------------------------------------------------------------------
-- INTRO ANIMADA
--------------------------------------------------------------------
local function Intro(done)
    local T = Themes[S.theme]
    local sp = New("CanvasGroup", {
        AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(330, 200),
        BackgroundColor3 = T.bg, GroupTransparency = 1, Parent = Gui,
    }, { Corner(20) })
    New("UIStroke", { Color = T.accent, Thickness = 2, Parent = sp })
    local sc = New("UIScale", { Scale = .6, Parent = sp })
    local bolt = New("TextLabel", {
        Text = "⚡", TextSize = 56, BackgroundTransparency = 1, TextTransparency = 1, Rotation = -25,
        AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(.5, 0, 0, 16), Size = UDim2.fromOffset(80, 70), Parent = sp,
    })
    local title = New("TextLabel", {
        Text = "", Font = F.GothamBlack, TextSize = 24, TextColor3 = T.accent, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30), Position = UDim2.fromOffset(0, 92), Parent = sp,
    })
    local sub = New("TextLabel", {
        Text = "tiktok: @enzoxd_244 • segue lá!", Font = F.GothamMedium, TextSize = 13, TextColor3 = T.sub,
        BackgroundTransparency = 1, TextTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromOffset(0, 126), Parent = sp,
    })
    local barBG = New("Frame", {
        AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(.5, 0, 0, 166), Size = UDim2.new(1, -70, 0, 6),
        BackgroundColor3 = T.off, BorderSizePixel = 0, Parent = sp,
    }, { Corner(3) })
    local barFill = New("Frame", {
        Size = UDim2.fromScale(0, 1), BackgroundColor3 = T.accent, BorderSizePixel = 0, Parent = barBG,
    }, { Corner(3) })

    task.spawn(function()
        tw(sp, .35, { GroupTransparency = 0 })
        tw(sc, .55, { Scale = 1 }, Enum.EasingStyle.Back)
        task.wait(.3)
        tw(bolt, .45, { TextTransparency = 0, Rotation = 0 }, Enum.EasingStyle.Back)
        task.wait(.3)
        local full = "ENZICKS HUB V5.9"
        for i = 1, #full do
            title.Text = full:sub(1, i)
            task.wait(.045)
        end
        tw(sub, .4, { TextTransparency = 0 })
        tw(barFill, .9, { Size = UDim2.fromScale(1, 1) }, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        task.wait(1)
        tw(sc, .35, { Scale = 1.15 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tw(sp, .35, { GroupTransparency = 1 })
        task.wait(.38)
        sp:Destroy()
        done()
    end)
end

Intro(function()
    tw(OrbScale, .5, { Scale = 1 }, Enum.EasingStyle.Back)
    showWin()
    if S.music.on then pcall(function() Music:Play() end) end
end)
