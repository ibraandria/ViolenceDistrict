--[[
    ╔══════════════════════════════════════════════════╗
    ║  EUGUNEWU://LOADER_v3.0 [VOID PREMIUM]         ║
    ║  Visible Loading • Smooth • Instant Execute     ║
    ╚══════════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local plr = Players.LocalPlayer
local gameId = game.PlaceId

local Games = {
    [83369512629707]  = { url = "https://raw.githubusercontent.com/numerouno2/gamesdump/refs/heads/main/sawahindo.lua", name = "Sawah Indo" },
    [131848958487439] = { url = "https://raw.githubusercontent.com/numerouno2/gamesdump/refs/heads/main/ruangriung.lua", name = "Ruang Riung" },
    [8356562067]      = { url = "https://raw.githubusercontent.com/numerouno2/gamesdump/refs/heads/main/indovoice.lua", name = "Indo Voice" },
    [85695526103771]  = { url = "https://raw.githubusercontent.com/numerouno2/gamesdump/refs/heads/main/danauindo.lua", name = "Danau Voice" },
    [130342654546662] = { url = "https://raw.githubusercontent.com/numerouno2/gamesdump/refs/heads/main/Sambungkata.lua", name = "Sambung Kata" },
    [93978595733734]  = { url = "https://raw.githubusercontent.com/numerouno2/gamesdump/refs/heads/main/ViolenceDistrict.lua", name = "Violence District" },
    [72774564502867]  = { url = "https://raw.githubusercontent.com/numerouno2/gamesdump/refs/heads/main/Lengkapikata.lua", name = "Lengkapi Kata" },
    [78632820802305]  = { url = "https://raw.githubusercontent.com/numerouno2/gamesdump/refs/heads/main/IndoStrike.lua", name = "Indo Strike" },
    [6911148748]  = { url = "http://raw.githubusercontent.com/numerouno2/gamesdump/refs/heads/main/CDID.lua", name = "CDID" },
}

local cur = Games[gameId]
local gameName = cur and cur.name or "Unknown"
local scriptUrl = cur and cur.url or nil

local mob = UIS.TouchEnabled and not UIS.KeyboardEnabled
if not mob and UIS.TouchEnabled then
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
    mob = math.min(vp.X, vp.Y) < 600
end

local C = {
    bg       = Color3.fromRGB(8, 5, 14),
    bgDeep   = Color3.fromRGB(4, 2, 8),
    card     = Color3.fromRGB(18, 12, 28),
    surface  = Color3.fromRGB(14, 9, 22),
    accent   = Color3.fromRGB(160, 120, 220),
    accentHi = Color3.fromRGB(200, 165, 255),
    accentLo = Color3.fromRGB(80, 55, 120),
    accentDp = Color3.fromRGB(55, 35, 95),
    cyan     = Color3.fromRGB(80, 200, 240),
    magenta  = Color3.fromRGB(220, 80, 180),
    text     = Color3.fromRGB(210, 195, 235),
    textHi   = Color3.fromRGB(242, 235, 255),
    textLo   = Color3.fromRGB(100, 80, 135),
    textDk   = Color3.fromRGB(50, 38, 68),
    border   = Color3.fromRGB(45, 32, 65),
    ok       = Color3.fromRGB(80, 220, 140),
    err      = Color3.fromRGB(220, 70, 80),
    warn     = Color3.fromRGB(220, 180, 70),
}

-- ═══════════════════════════
-- PRE-FETCH
-- ═══════════════════════════
local compiled, fetchDone, fetchErr = nil, false, nil
local fetchPhase = "idle" -- idle → connecting → downloading → compiling → done

if scriptUrl then
    task.spawn(function()
        fetchPhase = "connecting"
        task.wait(.1)
        fetchPhase = "downloading"
        local ok, e = pcall(function()
            local src = game:HttpGet(scriptUrl, true)
            if not src or #src < 10 then error("empty response") end
            fetchPhase = "compiling"
            local fn, ce = loadstring(src)
            if not fn then error(ce or "compile fail") end
            compiled = fn
        end)
        if not ok then fetchErr = tostring(e):sub(1, 60) end
        fetchPhase = "done"
        fetchDone = true
    end)
end

-- Cleanup
pcall(function()
    for _, v in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name == "EugunewuLoader" then v:Destroy() end
    end
    local pg = plr:FindFirstChild("PlayerGui")
    if pg then for _, v in ipairs(pg:GetChildren()) do
            if v.Name == "EugunewuLoader" then v:Destroy() end
        end end
end)

-- ═══════════════════════════
-- SCREENGUI
-- ═══════════════════════════
local SG = Instance.new("ScreenGui")
SG.Name = "EugunewuLoader"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.IgnoreGuiInset = true
SG.DisplayOrder = 999
pcall(function() SG.Parent = game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent = plr:WaitForChild("PlayerGui") end

local alive = true
local conns = {}

local function tw(o, p, d, s, dir)
    if mob then d = (d or .3) * .7 end
    local t = TS:Create(o, TweenInfo.new(d or .3, s or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), p)
    t:Play()
    return t
end

local function corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p
end

local function stroke(p, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or C.accent; s.Thickness = th or 1; s.Transparency = tr or .4
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = p
    return s
end

local function mkLabel(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = props.Font or Enum.Font.Code
    l.Text = props.Text or ""
    l.TextColor3 = props.Color or C.text
    l.TextSize = props.Size or 12
    l.TextStrokeTransparency = 1
    l.ZIndex = props.Z or 20
    l.TextXAlignment = props.AlignX or Enum.TextXAlignment.Center
    l.TextWrapped = props.Wrap or false
    l.RichText = props.Rich or false
    l.TextTruncate = props.Truncate or Enum.TextTruncate.None
    if props.UDim2Size then l.Size = props.UDim2Size end
    if props.UDim2Pos then l.Position = props.UDim2Pos end
    if props.Anchor then l.AnchorPoint = props.Anchor end
    l.Parent = parent
    return l
end

local W = mob and 340 or 480
local H = mob and 360 or 400

-- ═══════════════════════════
-- OVERLAY
-- ═══════════════════════════
local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = C.bgDeep
overlay.BackgroundTransparency = 1
overlay.BorderSizePixel = 0
overlay.ZIndex = 1
overlay.Parent = SG

-- ═══════════════════════════
-- MAIN FRAME
-- ═══════════════════════════
local main = Instance.new("Frame")
main.Size = UDim2.new(0, W, 0, H)
main.Position = UDim2.new(.5, 0, .5, 0)
main.AnchorPoint = Vector2.new(.5, .5)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.ZIndex = 10
main.ClipsDescendants = true
main.Visible = false
main.Parent = SG
corner(main, mob and 12 or 16)
local mainStk = stroke(main, C.accent, 2, .2)

local innerBdr = Instance.new("Frame")
innerBdr.Size = UDim2.new(1, -6, 1, -6)
innerBdr.Position = UDim2.new(.5, 0, .5, 0)
innerBdr.AnchorPoint = Vector2.new(.5, .5)
innerBdr.BackgroundTransparency = 1
innerBdr.ZIndex = 10
innerBdr.Parent = main
corner(innerBdr, mob and 10 or 14)
stroke(innerBdr, C.accentDp, 1, .55)

-- Top line
local topLine = Instance.new("Frame")
topLine.Size = UDim2.new(1, 0, 0, 3)
topLine.BackgroundColor3 = Color3.new(1, 1, 1)
topLine.BorderSizePixel = 0
topLine.ZIndex = 50
topLine.Parent = main

local topGrad = Instance.new("UIGradient")
topGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.accentDp),
    ColorSequenceKeypoint.new(.15, C.accent),
    ColorSequenceKeypoint.new(.35, C.magenta),
    ColorSequenceKeypoint.new(.5, C.cyan),
    ColorSequenceKeypoint.new(.65, C.magenta),
    ColorSequenceKeypoint.new(.85, C.accent),
    ColorSequenceKeypoint.new(1, C.accentDp),
})
topGrad.Parent = topLine

local botLine = Instance.new("Frame")
botLine.Size = UDim2.new(1, 0, 0, 2)
botLine.Position = UDim2.new(0, 0, 1, -2)
botLine.BackgroundColor3 = Color3.new(1, 1, 1)
botLine.BackgroundTransparency = .3
botLine.BorderSizePixel = 0
botLine.ZIndex = 50
botLine.Parent = main

local botGrad = Instance.new("UIGradient")
botGrad.Color = topGrad.Color
botGrad.Parent = botLine

-- ═══════════════════════════
-- HEADER
-- ═══════════════════════════
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 32)
header.Position = UDim2.new(0, 0, 0, 3)
header.BackgroundColor3 = C.surface
header.BackgroundTransparency = .25
header.BorderSizePixel = 0
header.ZIndex = 20
header.Parent = main

local badge = Instance.new("Frame")
badge.Size = UDim2.new(0, 40, 0, 16)
badge.Position = UDim2.new(0, 8, .5, -8)
badge.BackgroundColor3 = C.accent
badge.BackgroundTransparency = .78
badge.ZIndex = 21
badge.Parent = header
corner(badge, 3)

mkLabel(badge, { Text = "[SYS]", Color = C.accent, Size = 8, Z = 22, UDim2Size = UDim2.new(1, 0, 1, 0) })

mkLabel(header, {
    Text = "EUGUNEWU://LOADER_v3.0",
    Color = C.textLo, Size = mob and 9 or 11, Z = 21,
    UDim2Size = UDim2.new(1, -58, 1, 0),
    UDim2Pos = UDim2.new(0, 52, 0, 0),
    AlignX = Enum.TextXAlignment.Left,
})

local blinkLbl = mkLabel(header, {
    Text = "▌", Color = C.accent, Size = mob and 10 or 13, Z = 21,
    UDim2Size = UDim2.new(0, 10, 1, 0),
    UDim2Pos = UDim2.new(0, mob and 188 or 232, 0, 0),
})

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 8, 0, 8)
statusDot.Position = UDim2.new(1, -16, .5, -4)
statusDot.BackgroundColor3 = C.accent
statusDot.BorderSizePixel = 0
statusDot.ZIndex = 22
statusDot.Parent = header
corner(statusDot, 99)

mkLabel(header, {
    Text = string.rep("─", 120), Color = C.border, Size = 5, Z = 20,
    UDim2Size = UDim2.new(1, -12, 0, 6),
    UDim2Pos = UDim2.new(0, 6, 1, -5),
    AlignX = Enum.TextXAlignment.Left,
    Truncate = Enum.TextTruncate.AtEnd,
})

-- ═══════════════════════════
-- LOGO
-- ═══════════════════════════
local logoFrame = Instance.new("Frame")
logoFrame.Size = UDim2.new(0, 88, 0, 88)
logoFrame.Position = UDim2.new(.5, 0, 0, mob and 42 or 48)
logoFrame.AnchorPoint = Vector2.new(.5, 0)
logoFrame.BackgroundTransparency = 1
logoFrame.ZIndex = 20
logoFrame.Parent = main

local function mkRing(expand, thick, trans, z, col)
    local r = Instance.new("Frame")
    r.Size = UDim2.new(1, expand, 1, expand)
    r.Position = UDim2.new(.5, 0, .5, 0)
    r.AnchorPoint = Vector2.new(.5, .5)
    r.BackgroundTransparency = 1
    r.ZIndex = z
    r.Parent = logoFrame
    corner(r, 999)
    return r, stroke(r, col or C.accent, thick, trans)
end

local ring3, ring3s = mkRing(30, 1, .8, 17, C.accentDp)
local ring2, ring2s = mkRing(18, 1.5, .6, 18, C.accentLo)
local ring1, ring1s = mkRing(8, 2.5, .15, 19)

local circle = Instance.new("Frame")
circle.Size = UDim2.new(0, 66, 0, 66)
circle.Position = UDim2.new(.5, 0, .5, 0)
circle.AnchorPoint = Vector2.new(.5, .5)
circle.BackgroundColor3 = C.card
circle.BorderSizePixel = 0
circle.ZIndex = 22
circle.Parent = logoFrame
corner(circle, 999)
local circleS = stroke(circle, C.accent, 1.5, .25)

local innerGlow = Instance.new("Frame")
innerGlow.Size = UDim2.new(1, -10, 1, -10)
innerGlow.Position = UDim2.new(.5, 0, .5, 0)
innerGlow.AnchorPoint = Vector2.new(.5, .5)
innerGlow.BackgroundColor3 = C.accent
innerGlow.BackgroundTransparency = .9
innerGlow.BorderSizePixel = 0
innerGlow.ZIndex = 23
innerGlow.Parent = circle
corner(innerGlow, 999)

local logoE = mkLabel(circle, {
    Text = "E", Color = C.accentHi,
    Size = mob and 28 or 32, Z = 25,
    UDim2Size = UDim2.new(1, 0, 1, 0),
    Font = Enum.Font.GothamBold,
})

-- ═══════════════════════════
-- TITLE
-- ═══════════════════════════
local tY = mob and 138 or 148

local titleLbl = mkLabel(main, {
    Text = "EUGUNEWU HUB", Color = C.textHi,
    Size = mob and 20 or 26, Z = 20,
    UDim2Size = UDim2.new(1, 0, 0, 30),
    UDim2Pos = UDim2.new(0, 0, 0, tY),
    Font = Enum.Font.GothamBold,
})

local titGrad = Instance.new("UIGradient")
titGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.accent),
    ColorSequenceKeypoint.new(.3, C.textHi),
    ColorSequenceKeypoint.new(.7, C.textHi),
    ColorSequenceKeypoint.new(1, C.cyan),
})
titGrad.Parent = titleLbl

mkLabel(main, {
    Text = "[ PREMIUM VOID EDITION ]", Color = C.textLo,
    Size = mob and 8 or 10, Z = 20,
    UDim2Size = UDim2.new(1, 0, 0, 14),
    UDim2Pos = UDim2.new(0, 0, 0, tY + 30),
})

-- ═══════════════════════════
-- TERMINAL LOG
-- ═══════════════════════════
local logY = mob and 180 or 198

local logBg = Instance.new("Frame")
logBg.Size = UDim2.new(1, -36, 0, mob and 55 or 65)
logBg.Position = UDim2.new(.5, 0, 0, logY)
logBg.AnchorPoint = Vector2.new(.5, 0)
logBg.BackgroundColor3 = C.bgDeep
logBg.BorderSizePixel = 0
logBg.ZIndex = 20
logBg.ClipsDescendants = true
logBg.Parent = main
corner(logBg, 6)
stroke(logBg, C.border, 1, .45)

local logHdr = Instance.new("Frame")
logHdr.Size = UDim2.new(1, 0, 0, 14)
logHdr.BackgroundColor3 = C.surface
logHdr.BackgroundTransparency = .4
logHdr.BorderSizePixel = 0
logHdr.ZIndex = 21
logHdr.Parent = logBg

mkLabel(logHdr, {
    Text = " ▸ SYSTEM LOG", Color = C.accentLo, Size = 7, Z = 22,
    UDim2Size = UDim2.new(1, 0, 1, 0),
    AlignX = Enum.TextXAlignment.Left,
})

local logLbl = mkLabel(logBg, {
    Text = "", Color = C.textLo, Size = mob and 7 or 8, Z = 21,
    UDim2Size = UDim2.new(1, -10, 1, -18),
    UDim2Pos = UDim2.new(0, 5, 0, 16),
    AlignX = Enum.TextXAlignment.Left,
    Wrap = true, Rich = true,
})
logLbl.TextYAlignment = Enum.TextYAlignment.Bottom

local logArr = {}
local maxL = mob and 4 or 5

local function addLog(txt, col)
    local hex = (col or C.textLo):ToHex()
    table.insert(logArr, '<font color="#' .. hex .. '">' .. txt .. '</font>')
    if #logArr > maxL then table.remove(logArr, 1) end
    logLbl.Text = table.concat(logArr, "\n")
end

-- ═══════════════════════════
-- STATUS
-- ═══════════════════════════
local sY = mob and 242 or 272

local statusLbl = mkLabel(main, {
    Text = "", Color = C.text,
    Size = mob and 10 or 12, Z = 20,
    UDim2Size = UDim2.new(1, -36, 0, 18),
    UDim2Pos = UDim2.new(.5, 0, 0, sY),
    Anchor = Vector2.new(.5, 0),
})

-- ═══════════════════════════
-- PROGRESS BAR
-- ═══════════════════════════
local bY = mob and 264 or 296

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(1, -36, 0, mob and 8 or 10)
barBg.Position = UDim2.new(.5, 0, 0, bY)
barBg.AnchorPoint = Vector2.new(.5, 0)
barBg.BackgroundColor3 = C.surface
barBg.BorderSizePixel = 0
barBg.ZIndex = 20
barBg.Parent = main
corner(barBg, 999)
stroke(barBg, C.border, 1, .45)

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = C.accent
barFill.BorderSizePixel = 0
barFill.ZIndex = 22
barFill.ClipsDescendants = true
barFill.Parent = barBg
corner(barFill, 999)

local barGrad = Instance.new("UIGradient")
barGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.accentLo),
    ColorSequenceKeypoint.new(.35, C.accent),
    ColorSequenceKeypoint.new(.65, C.magenta),
    ColorSequenceKeypoint.new(1, C.cyan),
})
barGrad.Parent = barFill

local barHl = Instance.new("Frame")
barHl.Size = UDim2.new(1, 0, .35, 0)
barHl.BackgroundColor3 = Color3.new(1, 1, 1)
barHl.BackgroundTransparency = .78
barHl.BorderSizePixel = 0
barHl.ZIndex = 23
barHl.Parent = barFill
corner(barHl, 999)

local shimmer = Instance.new("Frame")
shimmer.Size = UDim2.new(.12, 0, 1, 0)
shimmer.Position = UDim2.new(-.15, 0, 0, 0)
shimmer.BackgroundColor3 = Color3.new(1, 1, 1)
shimmer.BackgroundTransparency = .7
shimmer.BorderSizePixel = 0
shimmer.ZIndex = 24
shimmer.Parent = barFill
corner(shimmer, 999)

local pctLbl = mkLabel(main, {
    Text = "0%", Color = C.accent,
    Size = mob and 8 or 9, Z = 20,
    UDim2Size = UDim2.new(1, -36, 0, 14),
    UDim2Pos = UDim2.new(.5, 0, 0, bY + (mob and 10 or 12)),
    Anchor = Vector2.new(.5, 0),
    AlignX = Enum.TextXAlignment.Right,
})

-- ═══════════════════════════
-- FOOTER
-- ═══════════════════════════
local sepY = mob and 290 or 322

local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, -56, 0, 1)
sep.Position = UDim2.new(.5, 0, 0, sepY)
sep.AnchorPoint = Vector2.new(.5, 0)
sep.BackgroundColor3 = C.border
sep.BackgroundTransparency = .35
sep.BorderSizePixel = 0
sep.ZIndex = 20
sep.Parent = main

local sepG = Instance.new("UIGradient")
sepG.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(.15, .25),
    NumberSequenceKeypoint.new(.85, .25),
    NumberSequenceKeypoint.new(1, 1),
})
sepG.Parent = sep

local fY = mob and 296 or 330

mkLabel(main, {
    Text = "▸ " .. plr.Name, Color = C.textDk,
    Size = mob and 7 or 9, Z = 20,
    UDim2Size = UDim2.new(.5, -20, 0, 14),
    UDim2Pos = UDim2.new(0, 18, 0, fY),
    AlignX = Enum.TextXAlignment.Left,
    Truncate = Enum.TextTruncate.AtEnd,
})

mkLabel(main, {
    Text = "◂ " .. gameName, Color = C.textDk,
    Size = mob and 7 or 9, Z = 20,
    UDim2Size = UDim2.new(.5, -20, 0, 14),
    UDim2Pos = UDim2.new(1, -18, 0, fY),
    Anchor = Vector2.new(1, 0),
    AlignX = Enum.TextXAlignment.Right,
    Truncate = Enum.TextTruncate.AtEnd,
})

mkLabel(main, {
    Text = "EUGUNEWU://v3.0 • VOID PREMIUM", Color = C.textDk,
    Size = mob and 6 or 7, Z = 20,
    UDim2Size = UDim2.new(1, -36, 0, 12),
    UDim2Pos = UDim2.new(.5, 0, 0, fY + 16),
    Anchor = Vector2.new(.5, 0),
})

-- ═══════════════════════════
-- ANIMATIONS
-- ═══════════════════════════
local gradR = 0
table.insert(conns, RS.Heartbeat:Connect(function(dt)
    if not alive then return end
    gradR = (gradR + dt * 55) % 360
    ring1.Rotation = gradR
    ring2.Rotation = -gradR * .65
    ring3.Rotation = gradR * .35
    topGrad.Rotation = gradR
    botGrad.Rotation = (gradR + 180) % 360
    barGrad.Rotation = (gradR * .4) % 360
end))

task.spawn(function()
    while alive do
        if blinkLbl.Parent then blinkLbl.Visible = not blinkLbl.Visible end
        task.wait(.5)
    end
end)

task.spawn(function()
    while alive do
        if not statusDot.Parent then break end
        tw(statusDot, {BackgroundTransparency = .6}, .6)
        task.wait(.6)
        tw(statusDot, {BackgroundTransparency = 0}, .6)
        task.wait(.6)
    end
end)

task.spawn(function()
    while alive do
        if not circle.Parent then break end
        tw(circle, {Size = UDim2.new(0, 70, 0, 70)}, .8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(.8)
        tw(circle, {Size = UDim2.new(0, 62, 0, 62)}, .8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(.8)
    end
end)

task.spawn(function()
    while alive do
        if not shimmer.Parent then break end
        shimmer.Position = UDim2.new(-.15, 0, 0, 0)
        tw(shimmer, {Position = UDim2.new(1.1, 0, 0, 0)}, .65, Enum.EasingStyle.Linear)
        task.wait(1.8)
    end
end)

task.spawn(function()
    while alive do
        task.wait(mob and .55 or .4)
        if not alive or not main.Parent then break end
        pcall(function()
            local s = math.random(2, 4)
            local p = Instance.new("Frame")
            p.Size = UDim2.new(0, s, 0, s)
            p.Position = UDim2.new(math.random(5, 95) / 100, 0, 1.05, 0)
            p.BackgroundColor3 = ({C.accent, C.cyan, C.magenta})[math.random(1, 3)]
            p.BackgroundTransparency = .45
            p.BorderSizePixel = 0
            p.ZIndex = 15
            p.Parent = main
            corner(p, 999)
            local t2 = tw(p, {
                Position = UDim2.new(p.Position.X.Scale + math.random(-12, 12) / 100, 0, -.08, 0),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 1, 0, 1),
            }, math.random(25, 45) / 10, Enum.EasingStyle.Linear)
            t2.Completed:Connect(function() pcall(function() p:Destroy() end) end)
        end)
    end
end)

-- ═══════════════════════════
-- GLITCH TEXT
-- ═══════════════════════════
local glyphs = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%&*<>{}[]|"

local function glitch(lbl, target, dur)
    dur = dur or .35
    local len = #target
    local steps = math.max(5, math.floor(dur / .025))
    task.spawn(function()
        for i = 1, steps do
            if not alive then break end
            local rev = math.floor(len * (i / steps))
            local t = ""
            for j = 1, len do
                if j <= rev then
                    t = t .. target:sub(j, j)
                else
                    local ri = math.random(1, #glyphs)
                    t = t .. glyphs:sub(ri, ri)
                end
            end
            lbl.Text = t
            task.wait(.025)
        end
        lbl.Text = target
    end)
end

-- ═══════════════════════════
-- SETTERS
-- ═══════════════════════════
local function setP(v, s)
    if s then statusLbl.Text = s end
    pctLbl.Text = math.floor(v) .. "%"
    tw(barFill, {Size = UDim2.new(math.clamp(v / 100, 0, 1), 0, 1, 0)}, .25, Enum.EasingStyle.Quart)
end

local function showOk(name)
    tw(barFill, {BackgroundColor3 = C.ok}, .25)
    tw(ring1s, {Color = C.ok, Transparency = .1}, .25)
    tw(circleS, {Color = C.ok, Transparency = .15}, .25)
    tw(circle, {BackgroundColor3 = Color3.fromRGB(12, 28, 18)}, .25)
    tw(innerGlow, {BackgroundColor3 = C.ok, BackgroundTransparency = .85}, .25)
    tw(statusDot, {BackgroundColor3 = C.ok}, .2)
    logoE.Text = "✓"
    logoE.TextSize = mob and 30 or 34
    tw(logoE, {TextColor3 = C.ok}, .2)
    statusLbl.TextColor3 = C.ok
    glitch(statusLbl, "█ " .. name:upper() .. " ── LOADED █", .3)
    addLog("[OK] script loaded ─── DONE", C.ok)
end

local function showErr(msg)
    tw(barFill, {BackgroundColor3 = C.err}, .25)
    tw(ring1s, {Color = C.err, Transparency = .1}, .25)
    tw(circleS, {Color = C.err, Transparency = .15}, .25)
    tw(circle, {BackgroundColor3 = Color3.fromRGB(28, 10, 10)}, .25)
    tw(innerGlow, {BackgroundColor3 = C.err, BackgroundTransparency = .85}, .25)
    tw(statusDot, {BackgroundColor3 = C.err}, .2)
    logoE.Text = "✕"
    logoE.TextSize = mob and 30 or 34
    tw(logoE, {TextColor3 = C.err}, .2)
    statusLbl.TextColor3 = C.err
    glitch(statusLbl, "█ " .. msg:upper():sub(1, 24) .. " █", .3)
    addLog("[ERR] " .. msg, C.err)
end

-- ═══════════════════════════
-- EXIT
-- ═══════════════════════════
local function doExit(cb)
    alive = false
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end

    for _, o in pairs(main:GetDescendants()) do
        pcall(function()
            if o:IsA("TextLabel") then tw(o, {TextTransparency = 1}, .15) end
            if o:IsA("Frame") and o ~= main then tw(o, {BackgroundTransparency = 1}, .15) end
            if o:IsA("UIStroke") then tw(o, {Transparency = 1}, .15) end
        end)
    end
    task.wait(.12)

    tw(main, {Size = UDim2.new(0, W, 0, 0), BackgroundTransparency = 1}, .25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    tw(mainStk, {Transparency = 1}, .18)
    tw(overlay, {BackgroundTransparency = 1}, .3)
    task.wait(.3)

    pcall(function() SG:Destroy() end)
    if cb then cb() end
end

-- ═══════════════════════════════════════
-- INTRO ANIMATION
-- ═══════════════════════════════════════
main.Visible = true
main.Size = UDim2.new(0, W, 0, 0)
main.BackgroundTransparency = 1

tw(overlay, {BackgroundTransparency = .5}, .3, Enum.EasingStyle.Quad)
task.wait(.08)

tw(main, {Size = UDim2.new(0, W, 0, H), BackgroundTransparency = 0}, .4, Enum.EasingStyle.Back)
task.wait(.35)

glitch(titleLbl, "EUGUNEWU HUB", .35)
task.wait(.2)

-- ═══════════════════════════════════════════════════════
-- LOADING SEQUENCE
--
-- Alur:
-- 1. Tampilkan log satu-satu (bisa dibaca)
-- 2. Progress bar jalan smooth ngikutin download
-- 3. Begitu download SELESAI → compile → success → exit
-- 4. Script LANGSUNG jalan setelah exit
-- ═══════════════════════════════════════════════════════

if scriptUrl then

    -- ── Step 1: Boot ──
    addLog("[BOOT] eugunewu://loader_v3.0", C.textLo)
    setP(3, "▸ BOOTING SYSTEM...")
    task.wait(.35)

    -- ── Step 2: Device scan ──
    addLog("[SCAN] detecting device...", C.textLo)
    setP(8, "▸ SCANNING DEVICE...")
    task.wait(.3)

    addLog("[SCAN] device: " .. (mob and "MOBILE" or "DESKTOP") .. " ─── OK", C.ok)
    setP(12)
    task.wait(.25)

    -- ── Step 3: Game detection ──
    addLog("[FIND] searching database...", C.textLo)
    setP(18, "▸ SEARCHING DATABASE...")
    task.wait(.3)

    addLog("[LOCK] target: " .. gameName:lower():gsub(" ", "_") .. " ─── FOUND", C.accent)
    glitch(statusLbl, "▸ TARGET: " .. gameName:upper(), .25)
    setP(25)
    task.wait(.35)

    -- ── Step 4: Download (ikutin real fetch) ──
    addLog("[NET] connecting to server...", C.textLo)
    setP(30, "▸ CONNECTING...")
    task.wait(.25)

    local lastPhase = ""
    local currentP = 30
    local dlStarted = false

    while not fetchDone do
        task.wait(.06)

        -- Phase-based log updates (cuma muncul sekali per phase)
        if fetchPhase ~= lastPhase then
            lastPhase = fetchPhase
            if fetchPhase == "connecting" then
                addLog("[NET] handshake...", C.textLo)
                statusLbl.Text = "▸ ESTABLISHING CONNECTION..."
            elseif fetchPhase == "downloading" then
                addLog("[AUTH] connection ─── OK", C.ok)
                task.wait(.15)
                addLog("[PULL] downloading payload...", C.textLo)
                statusLbl.Text = "▸ DOWNLOADING..."
                dlStarted = true
            elseif fetchPhase == "compiling" then
                addLog("[RECV] payload received ─── OK", C.ok)
                statusLbl.Text = "▸ COMPILING..."
            end
        end

        -- Progress naik pelan, makin pelan mendekati 85%
        local target = 85
        local remaining = target - currentP
        local speed = remaining * .015
        speed = math.max(speed, .1)
        currentP = math.min(currentP + speed, target)
        setP(currentP)

        -- Update persen di status
        if dlStarted and math.floor(currentP) % 8 == 0 then
            pctLbl.Text = math.floor(currentP) .. "%"
        end
    end

    -- ── Download selesai ──
    if fetchErr then
        addLog("[FAIL] " .. fetchErr, C.err)
        setP(100)
        task.wait(.15)
        showErr(fetchErr)
        task.wait(2)
        doExit()
        return
    end

    -- ── Step 5: Post-download ──
    addLog("[COMP] bytecode compile ─── OK", C.ok)
    setP(90, "▸ COMPILING BYTECODE...")
    task.wait(.3)

    addLog("[VRFY] integrity check ─── PASS", C.ok)
    setP(95, "▸ VERIFYING INTEGRITY...")
    task.wait(.25)

    addLog("[PREP] sandbox ready ─── OK", C.ok)
    setP(100, "▸ READY TO LAUNCH")
    task.wait(.2)

    -- ── Step 6: Success ──
    showOk(gameName)
    task.wait(.7)

    -- ── Exit → Script langsung jalan ──
    doExit(function()
        local ok2, e = pcall(compiled)
        if not ok2 then warn("[EUGUNEWU] " .. tostring(e)) end
    end)

else
    -- ── Game not supported ──
    addLog("[BOOT] eugunewu://loader_v3.0", C.textLo)
    setP(8, "▸ BOOTING...")
    task.wait(.35)

    addLog("[SCAN] game_id: " .. tostring(gameId), C.textLo)
    setP(25, "▸ SCANNING GAME...")
    task.wait(.3)

    addLog("[SRCH] searching registry...", C.textLo)
    setP(50, "▸ SEARCHING DATABASE...")
    task.wait(.3)

    addLog("[SRCH] matching entries...", C.textLo)
    setP(75, "▸ MATCHING...")
    task.wait(.25)

    addLog("[FAIL] game not in registry", C.err)
    setP(100)
    task.wait(.15)

    showErr("GAME NOT SUPPORTED")
    task.wait(.4)

    addLog("[INFO] id " .. tostring(gameId) .. " ── no match", C.warn)
    glitch(statusLbl, "█ ID " .. tostring(gameId) .. " NOT IN DB █", .3)

    task.wait(2.5)
    doExit()
end