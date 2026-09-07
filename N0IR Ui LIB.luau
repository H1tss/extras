--[[
    NØIR UI Library  ·  v2.0.0
    Clean · Minimal · Black & White
    Massively upgraded: polish, reliability, keybind system, fixed modules.

    Usage:
        local N0IR = loadstring(...)()
        local Window, Modules = N0IR:Init({ Title = "NØIR", SubTitle = "Suite" })
        -- or manual:
        local Window = N0IR:CreateWindow({ Title = "NØIR", ToggleKey = Enum.KeyCode.LeftAlt })
        N0IR:MountUtilities(Window)
]]

local N0IR = {
    Version = "2.0.0",
    Flags = {},
    _windows = {},
    _connections = {},
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- THEME (refined black & white)
-- ============================================================
local T = {
    bg0       = Color3.fromRGB(6, 6, 6),
    bg1       = Color3.fromRGB(12, 12, 12),
    bg2       = Color3.fromRGB(18, 18, 18),
    bg3       = Color3.fromRGB(26, 26, 26),
    bg4       = Color3.fromRGB(34, 34, 34),
    bg5       = Color3.fromRGB(44, 44, 44),
    border    = Color3.fromRGB(48, 48, 48),
    border2   = Color3.fromRGB(64, 64, 64),
    text      = Color3.fromRGB(248, 248, 248),
    text2     = Color3.fromRGB(190, 190, 190),
    text3     = Color3.fromRGB(120, 120, 120),
    text4     = Color3.fromRGB(80, 80, 80),
    accent    = Color3.fromRGB(255, 255, 255),
    accentDim = Color3.fromRGB(200, 200, 200),
    dim       = Color3.fromRGB(150, 150, 150),
    danger    = Color3.fromRGB(220, 70, 70),
    success   = Color3.fromRGB(70, 200, 120),
    warning   = Color3.fromRGB(220, 170, 60),
}

local function tween(obj, props, dur, style, dir)
    local info = TweenInfo.new(
        dur or 0.22,
        style or Enum.EasingStyle.Quint,
        dir or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or T.border
    s.Thickness = thickness or 1
    s.Transparency = trans or 0.3
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function padding(parent, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.Parent = parent
    return p
end

local function getHost()
    local ok, host = pcall(function()
        return CoreGui
    end)
    if ok and host then
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        return pg or host
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function safeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

local function track(conn)
    table.insert(N0IR._connections, conn)
    return conn
end

-- ============================================================
-- LOADING SCREEN
-- ============================================================
function N0IR:LoadingScreen(opts)
    opts = opts or {}
    local duration = opts.Duration or 2.2
    local title = opts.Title or "NØIR"
    local subtitle = opts.Subtitle or "initializing"

    local host = getHost()
    local old = host:FindFirstChild("N0IR_Loading")
    if old then old:Destroy() end

    local placeName = "unknown place"
    pcall(function()
        if game.PlaceId ~= 0 then
            local info = MarketplaceService:GetProductInfo(game.PlaceId)
            if info and info.Name then placeName = info.Name end
        end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "N0IR_Loading"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = host

    local veil = Instance.new("Frame")
    veil.Name = "Veil"
    veil.Size = UDim2.fromScale(1, 1)
    veil.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    veil.BackgroundTransparency = 1
    veil.BorderSizePixel = 0
    veil.Parent = gui

    local stack = Instance.new("Frame")
    stack.Name = "Stack"
    stack.AnchorPoint = Vector2.new(0.5, 0.5)
    stack.Position = UDim2.fromScale(0.5, 0.5)
    stack.Size = UDim2.fromOffset(340, 130)
    stack.BackgroundTransparency = 1
    stack.Parent = gui

    local brand = Instance.new("TextLabel")
    brand.BackgroundTransparency = 1
    brand.Size = UDim2.new(1, 0, 0, 38)
    brand.Font = Enum.Font.GothamBlack
    brand.Text = title
    brand.TextSize = 30
    brand.TextColor3 = T.text
    brand.TextTransparency = 1
    brand.Parent = stack

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.fromOffset(0, 40)
    sub.Size = UDim2.new(1, 0, 0, 18)
    sub.Font = Enum.Font.GothamMedium
    sub.Text = subtitle
    sub.TextSize = 13
    sub.TextColor3 = T.text3
    sub.TextTransparency = 1
    sub.Parent = stack

    local place = Instance.new("TextLabel")
    place.BackgroundTransparency = 1
    place.Position = UDim2.fromOffset(0, 62)
    place.Size = UDim2.new(1, 0, 0, 16)
    place.Font = Enum.Font.Code
    place.Text = placeName .. "  ·  " .. tostring(game.PlaceId)
    place.TextSize = 11
    place.TextColor3 = T.text4
    place.TextTransparency = 1
    place.TextTruncate = Enum.TextTruncate.AtEnd
    place.Parent = stack

    local track = Instance.new("Frame")
    track.Position = UDim2.fromOffset(0, 92)
    track.Size = UDim2.new(1, 0, 0, 3)
    track.BackgroundColor3 = T.bg3
    track.BackgroundTransparency = 1
    track.BorderSizePixel = 0
    track.Parent = stack
    corner(track, 2)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = T.accent
    fill.BackgroundTransparency = 1
    fill.BorderSizePixel = 0
    fill.Parent = track
    corner(fill, 2)

    local pct = Instance.new("TextLabel")
    pct.BackgroundTransparency = 1
    pct.Position = UDim2.fromOffset(0, 100)
    pct.Size = UDim2.new(1, 0, 0, 16)
    pct.Font = Enum.Font.Code
    pct.Text = "0%"
    pct.TextSize = 11
    pct.TextColor3 = T.text3
    pct.TextTransparency = 1
    pct.Parent = stack

    tween(veil, { BackgroundTransparency = 0.42 }, 0.35)
    tween(brand, { TextTransparency = 0 }, 0.4)
    tween(sub, { TextTransparency = 0 }, 0.45)
    tween(place, { TextTransparency = 0 }, 0.5)
    tween(track, { BackgroundTransparency = 0 }, 0.45)
    tween(fill, { BackgroundTransparency = 0 }, 0.45)
    tween(pct, { TextTransparency = 0 }, 0.45)

    local done = false
    local t0 = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local p = math.clamp((tick() - t0) / duration, 0, 1)
        -- smooth ease-out with tiny noise
        local eased = 1 - (1 - p) ^ 2.2
        local jagged = math.clamp(eased + math.sin(p * 11) * 0.008, 0, 1)
        fill.Size = UDim2.fromScale(jagged, 1)
        pct.Text = string.format("%d%%", math.floor(jagged * 100))
        if p >= 1 and not done then
            done = true
            conn:Disconnect()
            task.delay(0.12, function()
                tween(veil, { BackgroundTransparency = 1 }, 0.35)
                tween(brand, { TextTransparency = 1 }, 0.3)
                tween(sub, { TextTransparency = 1 }, 0.28)
                tween(place, { TextTransparency = 1 }, 0.28)
                tween(track, { BackgroundTransparency = 1 }, 0.28)
                tween(fill, { BackgroundTransparency = 1 }, 0.28)
                tween(pct, { TextTransparency = 1 }, 0.28)
                task.delay(0.4, function()
                    safeDestroy(gui)
                end)
            end)
        end
    end)

    return gui
end

-- ============================================================
-- NOTIFY (stacked, polished)
-- ============================================================
function N0IR:Notify(opts)
    if type(opts) == "string" then
        opts = { Title = opts }
    end
    opts = opts or {}
    local title = opts.Title or "NØIR"
    local content = opts.Content or opts.Description or ""
    local dur = opts.Duration or 2.6
    local kind = opts.Type or "info" -- info / success / danger / warning

    local barColor = T.accent
    if kind == "success" then barColor = T.success
    elseif kind == "danger" then barColor = T.danger
    elseif kind == "warning" then barColor = T.warning end

    local host = getHost()
    local holder = host:FindFirstChild("N0IR_Notifies")
    if not holder then
        holder = Instance.new("ScreenGui")
        holder.Name = "N0IR_Notifies"
        holder.ResetOnSpawn = false
        holder.DisplayOrder = 999998
        holder.IgnoreGuiInset = true
        holder.Parent = host
    end

    local height = content ~= "" and 58 or 42
    local n = Instance.new("Frame")
    n.Size = UDim2.fromOffset(300, height)
    n.Position = UDim2.new(1, 24, 0, 20)
    n.BackgroundColor3 = T.bg1
    n.BackgroundTransparency = 0.02
    n.BorderSizePixel = 0
    n.ClipsDescendants = true
    n.Parent = holder
    corner(n, 10)
    stroke(n, T.border, 1, 0.25)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 0.6, 0)
    bar.Position = UDim2.new(0, 0, 0.5, 0)
    bar.AnchorPoint = Vector2.new(0, 0.5)
    bar.BackgroundColor3 = barColor
    bar.BorderSizePixel = 0
    bar.Parent = n
    corner(bar, 2)

    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Position = UDim2.fromOffset(16, content ~= "" and 9 or 0)
    t.Size = UDim2.new(1, -28, 0, content ~= "" and 18 or 42)
    t.Font = Enum.Font.GothamBold
    t.Text = title
    t.TextSize = 13
    t.TextColor3 = T.text
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = n

    if content ~= "" then
        local c = Instance.new("TextLabel")
        c.BackgroundTransparency = 1
        c.Position = UDim2.fromOffset(16, 30)
        c.Size = UDim2.new(1, -28, 0, 20)
        c.Font = Enum.Font.Gotham
        c.Text = content
        c.TextSize = 11
        c.TextColor3 = T.text2
        c.TextXAlignment = Enum.TextXAlignment.Left
        c.TextTruncate = Enum.TextTruncate.AtEnd
        c.Parent = n
    end

    -- stack from top
    local yOff = 18
    for _, ch in ipairs(holder:GetChildren()) do
        if ch:IsA("Frame") and ch ~= n then
            yOff = yOff + ch.AbsoluteSize.Y + 8
        end
    end
    n.Position = UDim2.new(1, 24, 0, yOff)
    tween(n, { Position = UDim2.new(1, -316, 0, yOff) }, 0.38, Enum.EasingStyle.Quint)

    task.delay(dur, function()
        if not n or not n.Parent then return end
        tween(n, {
            Position = UDim2.new(1, 24, 0, yOff),
            BackgroundTransparency = 1,
        }, 0.28)
        for _, child in ipairs(n:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("Frame") then
                if child:IsA("TextLabel") then
                    tween(child, { TextTransparency = 1 }, 0.25)
                else
                    tween(child, { BackgroundTransparency = 1 }, 0.25)
                end
            end
        end
        task.delay(0.32, function()
            safeDestroy(n)
        end)
    end)
end

-- ============================================================
-- WINDOW
-- ============================================================
function N0IR:CreateWindow(opts)
    opts = opts or {}
    local title = opts.Title or "NØIR"
    local subTitle = opts.SubTitle or opts.Subtitle or ""
    local width = opts.Width or 540
    local height = opts.Height or 460

    -- Default toggle key: LeftAlt
    local toggleKey = opts.ToggleKey or Enum.KeyCode.LeftAlt
    if type(toggleKey) == "string" then
        pcall(function() toggleKey = Enum.KeyCode[toggleKey] end)
    end
    _G._N0IR_ToggleKey = toggleKey

    if opts.Loading ~= false then
        self:LoadingScreen({
            Title = title,
            Subtitle = opts.LoadingText or "loading modules",
            Duration = opts.LoadingDuration or 2.0,
        })
        task.wait((opts.LoadingDuration or 2.0) + 0.45)
    end

    local host = getHost()
    local old = host:FindFirstChild("N0IR_Window")
    if old then old:Destroy() end

    local screen = Instance.new("ScreenGui")
    screen.Name = "N0IR_Window"
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.IgnoreGuiInset = true
    screen.DisplayOrder = 100
    screen.Enabled = true
    screen.Parent = host

    local win = Instance.new("Frame")
    win.Name = "Main"
    win.AnchorPoint = Vector2.new(0.5, 0.5)
    win.Position = UDim2.fromScale(0.5, 0.5)
    win.Size = UDim2.fromOffset(width, height)
    win.BackgroundColor3 = T.bg0
    win.BackgroundTransparency = 0.02
    win.BorderSizePixel = 0
    win.ClipsDescendants = true
    win.Visible = true
    win.Parent = screen
    corner(win, 14)
    local winStroke = stroke(win, T.border, 1, 0.2)

    -- soft outer glow via second stroke (subtle)
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(255, 255, 255)
    glow.Thickness = 1
    glow.Transparency = 0.92
    glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    glow.Parent = win

    -- Entrance
    win.Size = UDim2.fromOffset(math.floor(width * 0.9), math.floor(height * 0.9))
    win.BackgroundTransparency = 1
    tween(win, {
        Size = UDim2.fromOffset(width, height),
        BackgroundTransparency = 0.02,
    }, 0.42, Enum.EasingStyle.Quint)

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = T.bg1
    titleBar.BackgroundTransparency = 0.1
    titleBar.BorderSizePixel = 0
    titleBar.Active = true
    titleBar.Parent = win
    corner(titleBar, 14)
    do
        local cover = Instance.new("Frame")
        cover.BackgroundColor3 = T.bg1
        cover.BackgroundTransparency = 0.1
        cover.BorderSizePixel = 0
        cover.Position = UDim2.new(0, 0, 1, -14)
        cover.Size = UDim2.new(1, 0, 0, 14)
        cover.Parent = titleBar
    end

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.fromOffset(18, 0)
    titleLbl.Size = UDim2.new(0, 140, 1, 0)
    titleLbl.Font = Enum.Font.GothamBlack
    titleLbl.Text = title
    titleLbl.TextSize = 17
    titleLbl.TextColor3 = T.text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = titleBar

    local subLbl
    if subTitle ~= "" then
        subLbl = Instance.new("TextLabel")
        subLbl.BackgroundTransparency = 1
        subLbl.Position = UDim2.fromOffset(18 + 100, 0)
        subLbl.Size = UDim2.new(0, 180, 1, 0)
        subLbl.Font = Enum.Font.GothamMedium
        subLbl.Text = subTitle
        subLbl.TextSize = 12
        subLbl.TextColor3 = T.text3
        subLbl.TextXAlignment = Enum.TextXAlignment.Left
        subLbl.Parent = titleBar
        task.defer(function()
            if titleLbl and subLbl then
                subLbl.Position = UDim2.fromOffset(18 + titleLbl.TextBounds.X + 14, 0)
            end
        end)
    end

    -- Window controls (mac-style dots)
    local closeBtn = Instance.new("TextButton")
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.Position = UDim2.new(1, -16, 0.5, 0)
    closeBtn.Size = UDim2.fromOffset(13, 13)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = ""
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = titleBar
    corner(closeBtn, 99)

    local minBtn = Instance.new("TextButton")
    minBtn.AnchorPoint = Vector2.new(1, 0.5)
    minBtn.Position = UDim2.new(1, -36, 0.5, 0)
    minBtn.Size = UDim2.fromOffset(13, 13)
    minBtn.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    minBtn.BorderSizePixel = 0
    minBtn.Text = ""
    minBtn.AutoButtonColor = false
    minBtn.Parent = titleBar
    corner(minBtn, 99)

    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, { BackgroundColor3 = T.danger }, 0.12)
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, { BackgroundColor3 = Color3.fromRGB(180, 180, 180) }, 0.12)
    end)
    minBtn.MouseEnter:Connect(function()
        tween(minBtn, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }, 0.12)
    end)
    minBtn.MouseLeave:Connect(function()
        tween(minBtn, { BackgroundColor3 = Color3.fromRGB(220, 220, 220) }, 0.12)
    end)

    local accentLine = Instance.new("Frame")
    accentLine.Size = UDim2.new(1, 0, 0, 1)
    accentLine.Position = UDim2.new(0, 0, 1, 0)
    accentLine.BackgroundColor3 = T.accent
    accentLine.BackgroundTransparency = 0.88
    accentLine.BorderSizePixel = 0
    accentLine.Parent = titleBar

    -- Drag
    do
        local dragging, startPos, dragStart
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = win.Position
            end
        end)
        track(UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                local d = input.Position - dragStart
                win.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
            end
        end))
        track(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
    end

    local isMin = false
    local fullSize = UDim2.fromOffset(width, height)

    -- Tab strip
    local tabStrip = Instance.new("ScrollingFrame")
    tabStrip.Name = "TabStrip"
    tabStrip.Position = UDim2.fromOffset(0, 50)
    tabStrip.Size = UDim2.new(1, 0, 0, 38)
    tabStrip.BackgroundColor3 = T.bg1
    tabStrip.BackgroundTransparency = 0.35
    tabStrip.BorderSizePixel = 0
    tabStrip.ScrollBarThickness = 0
    tabStrip.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabStrip.ScrollingDirection = Enum.ScrollingDirection.X
    tabStrip.Parent = win

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabStrip
    padding(tabStrip, 5, 5, 12, 12)
    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabStrip.CanvasSize = UDim2.fromOffset(tabLayout.AbsoluteContentSize.X + 24, 0)
    end)

    -- Content host
    local contentHost = Instance.new("Frame")
    contentHost.Name = "Content"
    contentHost.Position = UDim2.fromOffset(0, 88)
    contentHost.Size = UDim2.new(1, 0, 1, -88)
    contentHost.BackgroundTransparency = 1
    contentHost.ClipsDescendants = true
    contentHost.Parent = win

    closeBtn.MouseButton1Click:Connect(function()
        tween(win, {
            Size = UDim2.fromOffset(math.floor(width * 0.88), math.floor(height * 0.88)),
            BackgroundTransparency = 1,
        }, 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.3, function()
            safeDestroy(screen)
        end)
    end)

    minBtn.MouseButton1Click:Connect(function()
        isMin = not isMin
        if isMin then
            tabStrip.Visible = false
            contentHost.Visible = false
            tween(win, { Size = UDim2.fromOffset(width, 50) }, 0.32)
        else
            tween(win, { Size = fullSize }, 0.32)
            task.delay(0.18, function()
                tabStrip.Visible = true
                contentHost.Visible = true
            end)
        end
    end)

    local Window = {
        Screen = screen,
        Frame = win,
        Tabs = {},
        _current = nil,
        ToggleKey = toggleKey,
        Visible = true,
    }

    -- Robust visibility system (fixes menu not hiding)
    local function setWindowVisible(vis)
        Window.Visible = vis
        if vis then
            screen.Enabled = true
            win.Visible = true
            win.BackgroundTransparency = 1
            win.Size = UDim2.fromOffset(math.floor(width * 0.93), math.floor(height * 0.93))
            tween(win, {
                Size = UDim2.fromOffset(width, height),
                BackgroundTransparency = 0.02,
            }, 0.32, Enum.EasingStyle.Quint)
        else
            tween(win, {
                Size = UDim2.fromOffset(math.floor(width * 0.91), math.floor(height * 0.91)),
                BackgroundTransparency = 1,
            }, 0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.delay(0.28, function()
                if not Window.Visible then
                    win.Visible = false
                    -- keep screen.Enabled true so keybind still works; only hide the frame
                end
            end)
        end
    end

    Window.SetVisible = setWindowVisible
    Window.Toggle = function()
        setWindowVisible(not Window.Visible)
    end
    Window.IsVisible = function()
        return Window.Visible == true
    end

    -- Keybind toggle (works reliably)
    track(UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if UserInputService:GetFocusedTextBox() then return end
        local key = _G._N0IR_ToggleKey or Enum.KeyCode.LeftAlt
        if input.KeyCode == key then
            Window.Toggle()
        end
    end))

    function Window:CreateTab(tabOpts)
        tabOpts = tabOpts or {}
        local name = tabOpts.Name or "Tab"
        local order = tabOpts.Order or (#self.Tabs + 1)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.fromOffset(0, 28)
        btn.AutomaticSize = Enum.AutomaticSize.X
        btn.BackgroundColor3 = T.bg3
        btn.BackgroundTransparency = 1
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamMedium
        btn.Text = "  " .. name .. "  "
        btn.TextSize = 12
        btn.TextColor3 = T.text3
        btn.AutoButtonColor = false
        btn.LayoutOrder = order
        btn.Parent = tabStrip
        corner(btn, 7)

        local page = Instance.new("ScrollingFrame")
        page.Name = name
        page.Size = UDim2.fromScale(1, 1)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = T.accent
        page.ScrollBarImageTransparency = 0.55
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Visible = false
        page.Parent = contentHost

        local list = Instance.new("UIListLayout")
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Padding = UDim.new(0, 8)
        list.Parent = page
        padding(page, 14, 14, 16, 16)
        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 28)
        end)

        local Tab = {
            Name = name,
            Button = btn,
            Page = page,
            _order = 0,
        }

        local function activate()
            for _, t in ipairs(Window.Tabs) do
                t.Page.Visible = false
                t.Button.BackgroundTransparency = 1
                t.Button.TextColor3 = T.text3
            end
            page.Visible = true
            btn.BackgroundTransparency = 0.12
            btn.TextColor3 = T.text
            Window._current = Tab
        end

        btn.MouseButton1Click:Connect(activate)
        btn.MouseEnter:Connect(function()
            if Window._current ~= Tab then
                tween(btn, { TextColor3 = T.text2 }, 0.12)
            end
        end)
        btn.MouseLeave:Connect(function()
            if Window._current ~= Tab then
                tween(btn, { TextColor3 = T.text3 }, 0.12)
            end
        end)

        table.insert(self.Tabs, Tab)
        if #self.Tabs == 1 then activate() end

        -- ---- Element builders ----

        function Tab:CreateSection(secOpts)
            secOpts = type(secOpts) == "string" and { Name = secOpts } or (secOpts or {})
            self._order = self._order + 1
            local holder = Instance.new("Frame")
            holder.BackgroundTransparency = 1
            holder.Size = UDim2.new(1, 0, 0, 24)
            holder.LayoutOrder = self._order
            holder.Parent = page

            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.Font = Enum.Font.GothamBold
            lbl.Text = secOpts.Name or "Section"
            lbl.TextSize = 12
            lbl.TextColor3 = T.text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = holder

            local line = Instance.new("Frame")
            line.AnchorPoint = Vector2.new(1, 0.5)
            line.Position = UDim2.new(1, 0, 0.5, 0)
            line.Size = UDim2.new(0.55, 0, 0, 1)
            line.BackgroundColor3 = T.border
            line.BackgroundTransparency = 0.4
            line.BorderSizePixel = 0
            line.Parent = holder

            return holder
        end

        function Tab:CreateLabel(lblOpts)
            lblOpts = type(lblOpts) == "string" and { Text = lblOpts } or (lblOpts or {})
            self._order = self._order + 1
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 0, 18)
            lbl.Font = Enum.Font.Gotham
            lbl.Text = lblOpts.Text or ""
            lbl.TextSize = 11
            lbl.TextColor3 = T.text3
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextWrapped = true
            lbl.LayoutOrder = self._order
            lbl.Parent = page
            return {
                Set = function(_, text) lbl.Text = text end,
                Instance = lbl,
            }
        end

        function Tab:CreateButton(btnOpts)
            btnOpts = btnOpts or {}
            self._order = self._order + 1
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 36)
            b.BackgroundColor3 = T.bg2
            b.BorderSizePixel = 0
            b.Font = Enum.Font.GothamMedium
            b.Text = btnOpts.Name or "Button"
            b.TextSize = 12
            b.TextColor3 = T.text
            b.AutoButtonColor = false
            b.LayoutOrder = self._order
            b.Parent = page
            corner(b, 9)
            stroke(b, T.border, 1, 0.5)

            b.MouseEnter:Connect(function()
                tween(b, { BackgroundColor3 = T.bg3 }, 0.12)
            end)
            b.MouseLeave:Connect(function()
                tween(b, { BackgroundColor3 = T.bg2 }, 0.12)
            end)
            b.MouseButton1Down:Connect(function()
                tween(b, { BackgroundColor3 = T.bg4 }, 0.08)
            end)
            b.MouseButton1Up:Connect(function()
                tween(b, { BackgroundColor3 = T.bg3 }, 0.08)
            end)
            b.MouseButton1Click:Connect(function()
                if btnOpts.Callback then
                    task.spawn(btnOpts.Callback)
                end
            end)
            return b
        end

        function Tab:CreateToggle(togOpts)
            togOpts = togOpts or {}
            self._order = self._order + 1
            local flag = togOpts.Flag
            local state = togOpts.Default == true
            if flag and N0IR.Flags[flag] ~= nil then state = N0IR.Flags[flag] end

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 46)
            row.BackgroundColor3 = T.bg1
            row.BackgroundTransparency = 0.2
            row.BorderSizePixel = 0
            row.LayoutOrder = self._order
            row.Parent = page
            corner(row, 9)
            stroke(row, T.border, 1, 0.55)

            local name = Instance.new("TextLabel")
            name.BackgroundTransparency = 1
            name.Position = UDim2.fromOffset(14, 7)
            name.Size = UDim2.new(1, -72, 0, 16)
            name.Font = Enum.Font.GothamMedium
            name.Text = togOpts.Name or "Toggle"
            name.TextSize = 12
            name.TextColor3 = T.text
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Parent = row

            local desc = Instance.new("TextLabel")
            desc.BackgroundTransparency = 1
            desc.Position = UDim2.fromOffset(14, 25)
            desc.Size = UDim2.new(1, -72, 0, 14)
            desc.Font = Enum.Font.Gotham
            desc.Text = togOpts.Description or togOpts.Desc or ""
            desc.TextSize = 10
            desc.TextColor3 = T.text3
            desc.TextXAlignment = Enum.TextXAlignment.Left
            desc.TextTruncate = Enum.TextTruncate.AtEnd
            desc.Parent = row

            local track = Instance.new("Frame")
            track.AnchorPoint = Vector2.new(1, 0.5)
            track.Position = UDim2.new(1, -14, 0.5, 0)
            track.Size = UDim2.fromOffset(42, 24)
            track.BackgroundColor3 = state and T.accent or T.bg3
            track.BorderSizePixel = 0
            track.Parent = row
            corner(track, 12)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.fromOffset(18, 18)
            knob.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            knob.BackgroundColor3 = state and Color3.fromRGB(8, 8, 8) or T.text
            knob.BorderSizePixel = 0
            knob.Parent = track
            corner(knob, 9)

            local hit = Instance.new("TextButton")
            hit.Size = UDim2.fromScale(1, 1)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.Parent = row

            local function set(v, fire)
                state = v and true or false
                if flag then N0IR.Flags[flag] = state end
                tween(track, { BackgroundColor3 = state and T.accent or T.bg3 }, 0.16)
                tween(knob, {
                    Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
                    BackgroundColor3 = state and Color3.fromRGB(8, 8, 8) or T.text,
                }, 0.16)
                if fire ~= false and togOpts.Callback then
                    task.spawn(togOpts.Callback, state)
                end
            end

            hit.MouseButton1Click:Connect(function() set(not state) end)
            if togOpts.Default == true and togOpts.Callback then
                task.defer(function() togOpts.Callback(true) end)
            end

            return {
                Set = function(_, v) set(v) end,
                Get = function() return state end,
            }
        end

        function Tab:CreateSlider(slOpts)
            slOpts = slOpts or {}
            self._order = self._order + 1
            local minV = slOpts.Min or 0
            local maxV = slOpts.Max or 100
            local value = slOpts.Default or minV
            local flag = slOpts.Flag
            if flag and N0IR.Flags[flag] ~= nil then value = N0IR.Flags[flag] end

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 58)
            row.BackgroundColor3 = T.bg1
            row.BackgroundTransparency = 0.2
            row.BorderSizePixel = 0
            row.LayoutOrder = self._order
            row.Parent = page
            corner(row, 9)
            stroke(row, T.border, 1, 0.55)

            local name = Instance.new("TextLabel")
            name.BackgroundTransparency = 1
            name.Position = UDim2.fromOffset(14, 9)
            name.Size = UDim2.new(0.65, 0, 0, 14)
            name.Font = Enum.Font.GothamMedium
            name.Text = slOpts.Name or "Slider"
            name.TextSize = 12
            name.TextColor3 = T.text
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Parent = row

            local valLbl = Instance.new("TextLabel")
            valLbl.BackgroundTransparency = 1
            valLbl.Position = UDim2.new(1, -64, 0, 9)
            valLbl.Size = UDim2.fromOffset(50, 14)
            valLbl.Font = Enum.Font.Code
            valLbl.Text = tostring(value)
            valLbl.TextSize = 11
            valLbl.TextColor3 = T.text2
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = row

            local track = Instance.new("Frame")
            track.Position = UDim2.fromOffset(14, 36)
            track.Size = UDim2.new(1, -28, 0, 7)
            track.BackgroundColor3 = T.bg3
            track.BorderSizePixel = 0
            track.Parent = row
            corner(track, 4)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.fromScale(math.clamp((value - minV) / math.max(maxV - minV, 1e-4), 0, 1), 1)
            fill.BackgroundColor3 = T.accent
            fill.BorderSizePixel = 0
            fill.Parent = track
            corner(fill, 4)

            local function apply(v, fire)
                value = math.clamp(v, minV, maxV)
                if slOpts.Increment then
                    value = math.floor(value / slOpts.Increment + 0.5) * slOpts.Increment
                end
                if flag then N0IR.Flags[flag] = value end
                local pct = (value - minV) / math.max(maxV - minV, 1e-4)
                fill.Size = UDim2.fromScale(pct, 1)
                if slOpts.Increment and slOpts.Increment < 1 then
                    valLbl.Text = string.format("%.2f", value)
                else
                    valLbl.Text = string.format("%.0f", value)
                end
                if fire ~= false and slOpts.Callback then
                    task.spawn(slOpts.Callback, value)
                end
            end

            local dragging = false
            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    local pct = math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
                    apply(minV + pct * (maxV - minV))
                end
            end)
            track(UserInputService.InputChanged:Connect(function(input)
                if not dragging then return end
                if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                    local pct = math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
                    apply(minV + pct * (maxV - minV))
                end
            end))
            track(UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end))

            return {
                Set = function(_, v) apply(v) end,
                Get = function() return value end,
            }
        end

        function Tab:CreateDropdown(ddOpts)
            ddOpts = ddOpts or {}
            self._order = self._order + 1
            local options = ddOpts.Options or {}
            local current = ddOpts.Default or options[1] or ""
            local flag = ddOpts.Flag
            if flag and N0IR.Flags[flag] ~= nil then current = N0IR.Flags[flag] end
            local open = false

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 42)
            row.BackgroundColor3 = T.bg1
            row.BackgroundTransparency = 0.2
            row.BorderSizePixel = 0
            row.LayoutOrder = self._order
            row.ClipsDescendants = true
            row.Parent = page
            corner(row, 9)
            stroke(row, T.border, 1, 0.55)

            local name = Instance.new("TextLabel")
            name.BackgroundTransparency = 1
            name.Position = UDim2.fromOffset(14, 0)
            name.Size = UDim2.new(0.4, 0, 0, 42)
            name.Font = Enum.Font.GothamMedium
            name.Text = ddOpts.Name or "Dropdown"
            name.TextSize = 12
            name.TextColor3 = T.text
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Parent = row

            local val = Instance.new("TextLabel")
            val.BackgroundTransparency = 1
            val.Position = UDim2.new(0.4, 0, 0, 0)
            val.Size = UDim2.new(0.5, -12, 0, 42)
            val.Font = Enum.Font.Gotham
            val.Text = tostring(current)
            val.TextSize = 11
            val.TextColor3 = T.text2
            val.TextXAlignment = Enum.TextXAlignment.Right
            val.TextTruncate = Enum.TextTruncate.AtEnd
            val.Parent = row

            local arrow = Instance.new("TextLabel")
            arrow.BackgroundTransparency = 1
            arrow.Position = UDim2.new(1, -30, 0, 0)
            arrow.Size = UDim2.fromOffset(22, 42)
            arrow.Font = Enum.Font.GothamBold
            arrow.Text = "▾"
            arrow.TextSize = 12
            arrow.TextColor3 = T.text3
            arrow.Parent = row

            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(1, 0, 0, 42)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.Parent = row

            local listFrame = Instance.new("Frame")
            listFrame.Position = UDim2.fromOffset(10, 42)
            listFrame.Size = UDim2.new(1, -20, 0, 0)
            listFrame.BackgroundTransparency = 1
            listFrame.Parent = row

            local function rebuild()
                for _, ch in ipairs(listFrame:GetChildren()) do ch:Destroy() end
                local y = 0
                for _, opt in ipairs(options) do
                    local ob = Instance.new("TextButton")
                    ob.Position = UDim2.fromOffset(0, y)
                    ob.Size = UDim2.new(1, 0, 0, 28)
                    ob.BackgroundColor3 = T.bg2
                    ob.BorderSizePixel = 0
                    ob.Font = Enum.Font.Gotham
                    ob.Text = "  " .. tostring(opt)
                    ob.TextSize = 11
                    ob.TextColor3 = (opt == current) and T.text or T.text2
                    ob.TextXAlignment = Enum.TextXAlignment.Left
                    ob.AutoButtonColor = false
                    ob.Parent = listFrame
                    corner(ob, 6)
                    ob.MouseEnter:Connect(function()
                        tween(ob, { BackgroundColor3 = T.bg3 }, 0.1)
                    end)
                    ob.MouseLeave:Connect(function()
                        tween(ob, { BackgroundColor3 = T.bg2 }, 0.1)
                    end)
                    ob.MouseButton1Click:Connect(function()
                        current = opt
                        if flag then N0IR.Flags[flag] = current end
                        val.Text = tostring(current)
                        if ddOpts.Callback then task.spawn(ddOpts.Callback, current) end
                        open = false
                        tween(row, { Size = UDim2.new(1, 0, 0, 42) }, 0.18)
                        listFrame.Size = UDim2.new(1, -20, 0, 0)
                        arrow.Text = "▾"
                    end)
                    y = y + 30
                end
                return y
            end

            hit.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    local h = rebuild()
                    tween(row, { Size = UDim2.new(1, 0, 0, 42 + h + 10) }, 0.2)
                    listFrame.Size = UDim2.new(1, -20, 0, h)
                    arrow.Text = "▴"
                else
                    tween(row, { Size = UDim2.new(1, 0, 0, 42) }, 0.18)
                    listFrame.Size = UDim2.new(1, -20, 0, 0)
                    arrow.Text = "▾"
                end
            end)

            return {
                Set = function(_, v)
                    current = v
                    val.Text = tostring(v)
                    if flag then N0IR.Flags[flag] = v end
                end,
                Get = function() return current end,
                SetOptions = function(_, opts)
                    options = opts or {}
                end,
            }
        end

        function Tab:CreateInput(inOpts)
            inOpts = inOpts or {}
            self._order = self._order + 1
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 42)
            row.BackgroundColor3 = T.bg1
            row.BackgroundTransparency = 0.2
            row.BorderSizePixel = 0
            row.LayoutOrder = self._order
            row.Parent = page
            corner(row, 9)
            stroke(row, T.border, 1, 0.55)

            local name = Instance.new("TextLabel")
            name.BackgroundTransparency = 1
            name.Position = UDim2.fromOffset(14, 0)
            name.Size = UDim2.new(0.35, 0, 1, 0)
            name.Font = Enum.Font.GothamMedium
            name.Text = inOpts.Name or "Input"
            name.TextSize = 12
            name.TextColor3 = T.text
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Parent = row

            local box = Instance.new("TextBox")
            box.Position = UDim2.new(0.38, 0, 0.5, -13)
            box.Size = UDim2.new(0.6, -14, 0, 26)
            box.BackgroundColor3 = T.bg2
            box.BorderSizePixel = 0
            box.Font = Enum.Font.Gotham
            box.PlaceholderText = inOpts.Placeholder or "..."
            box.PlaceholderColor3 = T.text3
            box.Text = inOpts.Default or ""
            box.TextSize = 12
            box.TextColor3 = T.text
            box.ClearTextOnFocus = false
            box.Parent = row
            corner(box, 7)
            padding(box, 0, 0, 8, 8)

            box.FocusLost:Connect(function(enter)
                if inOpts.Callback then
                    task.spawn(inOpts.Callback, box.Text, enter)
                end
            end)

            return {
                Set = function(_, t) box.Text = t end,
                Get = function() return box.Text end,
            }
        end

        function Tab:CreateParagraph(pOpts)
            pOpts = type(pOpts) == "string" and { Content = pOpts } or (pOpts or {})
            self._order = self._order + 1
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundColor3 = T.bg1
            lbl.BackgroundTransparency = 0.3
            lbl.Size = UDim2.new(1, 0, 0, 0)
            lbl.AutomaticSize = Enum.AutomaticSize.Y
            lbl.Font = Enum.Font.Gotham
            lbl.Text = pOpts.Content or pOpts.Text or ""
            lbl.TextSize = 11
            lbl.TextColor3 = T.text2
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextYAlignment = Enum.TextYAlignment.Top
            lbl.TextWrapped = true
            lbl.LayoutOrder = self._order
            lbl.Parent = page
            corner(lbl, 9)
            padding(lbl, 11, 11, 14, 14)
            return lbl
        end

        function Tab:CreateKeybind(kbOpts)
            kbOpts = kbOpts or {}
            self._order = self._order + 1
            local current = kbOpts.Default or Enum.KeyCode.LeftAlt
            if type(current) == "string" then
                pcall(function() current = Enum.KeyCode[current] end)
            end
            local listening = false

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 46)
            row.BackgroundColor3 = T.bg1
            row.BackgroundTransparency = 0.2
            row.BorderSizePixel = 0
            row.LayoutOrder = self._order
            row.Parent = page
            corner(row, 9)
            stroke(row, T.border, 1, 0.55)

            local name = Instance.new("TextLabel")
            name.BackgroundTransparency = 1
            name.Position = UDim2.fromOffset(14, 7)
            name.Size = UDim2.new(1, -120, 0, 16)
            name.Font = Enum.Font.GothamMedium
            name.Text = kbOpts.Name or "Keybind"
            name.TextSize = 12
            name.TextColor3 = T.text
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Parent = row

            local desc = Instance.new("TextLabel")
            desc.BackgroundTransparency = 1
            desc.Position = UDim2.fromOffset(14, 25)
            desc.Size = UDim2.new(1, -120, 0, 14)
            desc.Font = Enum.Font.Gotham
            desc.Text = kbOpts.Description or kbOpts.Desc or "Click to change"
            desc.TextSize = 10
            desc.TextColor3 = T.text3
            desc.TextXAlignment = Enum.TextXAlignment.Left
            desc.Parent = row

            local keyBtn = Instance.new("TextButton")
            keyBtn.AnchorPoint = Vector2.new(1, 0.5)
            keyBtn.Position = UDim2.new(1, -12, 0.5, 0)
            keyBtn.Size = UDim2.fromOffset(90, 28)
            keyBtn.BackgroundColor3 = T.bg3
            keyBtn.BorderSizePixel = 0
            keyBtn.Font = Enum.Font.GothamBold
            keyBtn.Text = current.Name
            keyBtn.TextSize = 11
            keyBtn.TextColor3 = T.text
            keyBtn.AutoButtonColor = false
            keyBtn.Parent = row
            corner(keyBtn, 7)
            stroke(keyBtn, T.border, 1, 0.4)

            local function setKey(kc)
                current = kc
                keyBtn.Text = kc.Name
                if kbOpts.Flag then N0IR.Flags[kbOpts.Flag] = kc.Name end
                if kbOpts.Callback then
                    task.spawn(kbOpts.Callback, kc)
                end
            end

            keyBtn.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                keyBtn.Text = "..."
                tween(keyBtn, { BackgroundColor3 = T.bg4 }, 0.1)
                local conn
                conn = UserInputService.InputBegan:Connect(function(input, gp)
                    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    conn:Disconnect()
                    listening = false
                    tween(keyBtn, { BackgroundColor3 = T.bg3 }, 0.12)
                    if input.KeyCode == Enum.KeyCode.Escape then
                        keyBtn.Text = current.Name
                        return
                    end
                    setKey(input.KeyCode)
                end)
            end)

            return {
                Set = function(_, kc)
                    if type(kc) == "string" then
                        pcall(function() kc = Enum.KeyCode[kc] end)
                    end
                    if typeof(kc) == "EnumItem" then setKey(kc) end
                end,
                Get = function() return current end,
            }
        end

        return Tab
    end

    function Window:Destroy()
        safeDestroy(screen)
    end

    table.insert(self._windows, Window)
    return Window
end

-- ============================================================
-- UTILITY MODULES
-- ============================================================
function N0IR:MountUtilities(Window)
    -- ---------- Home ----------
    local Home = Window:CreateTab({ Name = "Home" })
    Home:CreateSection("Welcome")
    Home:CreateParagraph({
        Content = "NØIR Suite  ·  v" .. N0IR.Version .. "\nClean black & white hub. Modules live in the tabs — World, Player, Animations, Commands, Map, Social, Settings.",
    })

    Home:CreateSection("Quick actions")
    Home:CreateButton({
        Name = "Notify test",
        Callback = function()
            N0IR:Notify({ Title = "NØIR", Content = "Everything is running.", Duration = 2, Type = "success" })
        end,
    })
    Home:CreateButton({
        Name = "Rejoin server",
        Callback = function()
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end)
        end,
    })
    Home:CreateButton({
        Name = "Server hop",
        Callback = function()
            pcall(function()
                local servers = HttpService:JSONDecode(game:HttpGet(
                    "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=50"
                ))
                if servers and servers.data then
                    for _, s in ipairs(servers.data) do
                        if s.playing < s.maxPlayers and s.id ~= game.JobId then
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                            return
                        end
                    end
                end
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
        end,
    })

    Home:CreateSection("Session")
    local placeName = "unknown"
    pcall(function()
        if game.PlaceId ~= 0 then
            local info = MarketplaceService:GetProductInfo(game.PlaceId)
            if info and info.Name then placeName = info.Name end
        end
    end)
    Home:CreateLabel("Place  ·  " .. placeName)
    Home:CreateLabel("PlaceId  ·  " .. tostring(game.PlaceId))
    Home:CreateLabel("Players  ·  " .. tostring(#Players:GetPlayers()))
    Home:CreateLabel("Toggle key  ·  " .. tostring((_G._N0IR_ToggleKey or Enum.KeyCode.LeftAlt).Name))

    -- ---------- World tab ----------
    local World = Window:CreateTab({ Name = "World" })
    World:CreateSection("Baseplate")

    local function findBaseplate()
        local names = { "Baseplate", "baseplate", "BasePlate", "Floor", "Ground" }
        for _, n in ipairs(names) do
            local p = workspace:FindFirstChild(n)
            if p and p:IsA("BasePart") then return p end
        end
        for _, p in ipairs(workspace:GetDescendants()) do
            if p:IsA("BasePart") and p.Name:lower():find("baseplate") then
                return p
            end
        end
        return nil
    end

    local function setBaseplateColor(col, label)
        local part = findBaseplate()
        if part then
            part.Color = col
            pcall(function() part.Material = Enum.Material.Grass end)
            N0IR:Notify({ Title = "Baseplate", Content = label or "Color applied", Duration = 1.4 })
        else
            pcall(function()
                workspace.Terrain:SetMaterialColor(Enum.Material.Asphalt, col)
            end)
            N0IR:Notify({ Title = "Baseplate", Content = "Terrain color set", Duration = 1.4 })
        end
    end

    local colors = {
        { "Black",  Color3.fromRGB(20, 20, 20) },
        { "Gray",   Color3.fromRGB(90, 90, 90) },
        { "White",  Color3.fromRGB(230, 230, 230) },
        { "Blue",   Color3.fromRGB(60, 100, 180) },
        { "Red",    Color3.fromRGB(160, 50, 50) },
        { "Green",  Color3.fromRGB(50, 140, 80) },
        { "Purple", Color3.fromRGB(110, 60, 160) },
        { "Sand",   Color3.fromRGB(190, 170, 130) },
    }

    for _, entry in ipairs(colors) do
        World:CreateButton({
            Name = "Baseplate · " .. entry[1],
            Callback = function()
                setBaseplateColor(entry[2], entry[1])
            end,
        })
    end

    World:CreateSection("Infinite Baseplate")

    -- Fixed Auto Infinite Baseplate
    local infConn = nil
    local infPart = nil
    local infEnabled = false

    local function destroyInfBaseplate()
        if infConn then
            infConn:Disconnect()
            infConn = nil
        end
        if infPart then
            pcall(function() infPart:Destroy() end)
            infPart = nil
        end
        -- also clean any leftover
        local existing = workspace:FindFirstChild("N0IR_InfBaseplate")
        if existing then pcall(function() existing:Destroy() end) end
    end

    local function createInfBaseplate()
        destroyInfBaseplate()
        infPart = Instance.new("Part")
        infPart.Name = "N0IR_InfBaseplate"
        infPart.Anchored = true
        infPart.CanCollide = true
        infPart.CanQuery = false
        infPart.CanTouch = false
        infPart.Transparency = 1
        infPart.Material = Enum.Material.SmoothPlastic
        infPart.Size = Vector3.new(4096, 2, 4096)
        infPart.Parent = workspace

        infConn = RunService.Heartbeat:Connect(function()
            if not infEnabled or not infPart or not infPart.Parent then return end
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- keep under the player, slight offset so feet land cleanly
                local y = hrp.Position.Y - 3.2
                -- clamp y so it doesn't float too high if player falls
                if y > hrp.Position.Y - 1 then y = hrp.Position.Y - 3.2 end
                infPart.CFrame = CFrame.new(hrp.Position.X, math.min(y, hrp.Position.Y - 2.8), hrp.Position.Z)
            end
        end)
    end

    World:CreateToggle({
        Name = "Auto Infinite Baseplate",
        Description = "Invisible floor that follows you (works on void / no floor)",
        Flag = "AutoInfBaseplate",
        Default = false,
        Callback = function(on)
            infEnabled = on
            if not on then
                destroyInfBaseplate()
                N0IR:Notify({ Title = "Inf Baseplate", Content = "Off", Duration = 1.2 })
                return
            end
            createInfBaseplate()
            N0IR:Notify({ Title = "Inf Baseplate", Content = "On", Duration = 1.2, Type = "success" })
        end,
    })

    -- re-create on character respawn if still enabled
    track(LocalPlayer.CharacterAdded:Connect(function()
        if infEnabled then
            task.wait(0.4)
            createInfBaseplate()
        end
    end))

    -- ---------- Player tab ----------
    local Player = Window:CreateTab({ Name = "Player" })
    Player:CreateSection("Movement")

    Player:CreateSlider({
        Name = "WalkSpeed",
        Min = 0, Max = 200, Default = 16, Increment = 1,
        Flag = "WalkSpeed",
        Callback = function(v)
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end,
    })

    Player:CreateSlider({
        Name = "JumpPower",
        Min = 0, Max = 200, Default = 50, Increment = 1,
        Flag = "JumpPower",
        Callback = function(v)
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = v
            end
        end,
    })

    local noclipOn = false
    local noclipConn = nil
    Player:CreateToggle({
        Name = "Noclip",
        Flag = "Noclip",
        Callback = function(on)
            noclipOn = on
            if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
            if not on then
                local char = LocalPlayer.Character
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = true end
                    end
                end
                return
            end
            noclipConn = RunService.Stepped:Connect(function()
                if not noclipOn then return end
                local char = LocalPlayer.Character
                if not char then return end
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)
        end,
    })

    Player:CreateButton({
        Name = "Rejoin",
        Callback = function()
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end)
        end,
    })

    Player:CreateButton({
        Name = "Server Hop",
        Callback = function()
            pcall(function()
                local servers = HttpService:JSONDecode(game:HttpGet(
                    "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=50"
                ))
                if servers and servers.data then
                    for _, s in ipairs(servers.data) do
                        if s.playing < s.maxPlayers and s.id ~= game.JobId then
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                            return
                        end
                    end
                end
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
        end,
    })

    -- ---------- Animations tab ----------
    local Anims = Window:CreateTab({ Name = "Animations" })
    Anims:CreateSection("Reanimation")
    Anims:CreateButton({
        Name = "Load Reanimation",
        Callback = function()
            local ok = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/H1tss/extras/refs/heads/main/Reanimation.luau"))()
            end)
            N0IR:Notify({
                Title = "Reanim",
                Content = ok and "Loaded" or "Failed to load",
                Duration = 2,
                Type = ok and "success" or "danger",
            })
        end,
    })

    Anims:CreateSection("Official packs")
    Anims:CreateParagraph({
        Content = "Select a Roblox animation pack, then Apply. Works on R15 Animate script.",
    })

    local DEFAULT_ANIMS = {
        Run = 913376220,
        Walk = 913402848,
        Jump = 507765000,
        Idle1 = 507766388,
        Idle2 = 507766666,
        Fall = 507767968,
        Climb = 507765644,
        Swim = 913384386,
        SwimIdle = 913389285,
    }

    -- Store the character's original animation IDs on first use
    local ORIGINAL_ANIMS = nil
    local function captureOriginalAnims()
        if ORIGINAL_ANIMS then return ORIGINAL_ANIMS end
        local char = LocalPlayer.Character
        if not char then return nil end
        local animate = char:FindFirstChild("Animate")
        if not animate then return nil end

        local function getId(folderName, animName)
            local folder = animate:FindFirstChild(folderName)
            if not folder then return 0 end
            local anim = folder:FindFirstChild(animName) or folder:FindFirstChildOfClass("Animation")
            if anim and anim:IsA("Animation") then
                local id = anim.AnimationId:match("%d+")
                return tonumber(id) or 0
            end
            return 0
        end

        ORIGINAL_ANIMS = {
            Run = getId("run", "RunAnim"),
            Walk = getId("walk", "WalkAnim"),
            Jump = getId("jump", "JumpAnim"),
            Fall = getId("fall", "FallAnim"),
            Climb = getId("climb", "ClimbAnim"),
            Swim = getId("swim", "Swim"),
            SwimIdle = getId("swimidle", "SwimIdle"),
            Idle1 = 0,
            Idle2 = 0,
        }
        local idle = animate:FindFirstChild("idle")
        if idle then
            local a1 = idle:FindFirstChild("Animation1")
            local a2 = idle:FindFirstChild("Animation2")
            if a1 and a1:IsA("Animation") then
                ORIGINAL_ANIMS.Idle1 = tonumber(a1.AnimationId:match("%d+")) or 0
            end
            if a2 and a2:IsA("Animation") then
                ORIGINAL_ANIMS.Idle2 = tonumber(a2.AnimationId:match("%d+")) or 0
            end
        end
        return ORIGINAL_ANIMS
    end

    -- capture as soon as character exists
    task.spawn(function()
        if LocalPlayer.Character then
            captureOriginalAnims()
        end
        LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            ORIGINAL_ANIMS = nil -- re-capture on new character
            captureOriginalAnims()
        end)
    end)

    local OFFICIAL_PACKS = {
        ["Zombie"] = {
            Run = 616163682, Walk = 616168032, Jump = 616161997,
            Idle1 = 616158929, Idle2 = 616160636, Fall = 616157476,
            Swim = 616165109, SwimIdle = 616166655, Climb = 616156119,
        },
        ["Ninja"] = {
            Run = 656118852, Walk = 656121766, Jump = 656117878,
            Idle1 = 656117400, Idle2 = 656118341, Fall = 656115606,
            Swim = 656119721, SwimIdle = 656121397, Climb = 656114359,
        },
        ["Cartoony"] = {
            Run = 742638842, Walk = 742640026, Jump = 742637942,
            Idle1 = 742637544, Idle2 = 742638445, Fall = 742637151,
            Swim = 742639220, SwimIdle = 742639812, Climb = 742636889,
        },
        ["Superhero"] = {
            Run = 619528716, Walk = 619529601, Jump = 619528412,
            Idle1 = 619528125, Idle2 = 619528125, Fall = 619527817,
            Swim = 619529095, SwimIdle = 619529095, Climb = 619527470,
        },
        ["Stylish"] = {
            Run = 619512153, Walk = 619512767, Jump = 619511974,
            Idle1 = 619511648, Idle2 = 619511648, Fall = 619511417,
            Swim = 619512450, SwimIdle = 619512450, Climb = 619509955,
        },
        ["Elder"] = {
            Run = 845386501, Walk = 845403856, Jump = 845398858,
            Idle1 = 845397899, Idle2 = 845400520, Fall = 845396048,
            Swim = 845401742, SwimIdle = 845403127, Climb = 845392038,
        },
        ["Toy"] = {
            Run = 973766674, Walk = 973767371, Jump = 973770652,
            Idle1 = 973771666, Idle2 = 973771666, Fall = 973768058,
            Swim = 973772659, SwimIdle = 973772659, Climb = 973773170,
        },
        ["Bubbly"] = {
            Run = 910025107, Walk = 910034870, Jump = 910016857,
            Idle1 = 910004836, Idle2 = 910009958, Fall = 910001910,
            Swim = 910028158, SwimIdle = 910030921, Climb = 909997997,
        },
        ["Astronaut"] = {
            Run = 891636393, Walk = 891636393, Jump = 891627522,
            Idle1 = 891621366, Idle2 = 891633237, Fall = 891617961,
            Swim = 891639666, SwimIdle = 891663592, Climb = 891609353,
        },
        ["Vampire"] = {
            Run = 1113740510, Walk = 1113741192, Jump = 1113742359,
            Idle1 = 1113742618, Idle2 = 1113742618, Fall = 1113742092,
            Swim = 1113742944, SwimIdle = 1113742944, Climb = 1113743239,
        },
        ["Werewolf"] = {
            Run = 619535616, Walk = 619537468, Jump = 619536283,
            Idle1 = 619535834, Idle2 = 619535834, Fall = 619535616,
            Swim = 619537096, SwimIdle = 619537096, Climb = 619535091,
        },
        ["Levitation"] = {
            Run = 619543231, Walk = 619544080, Jump = 619542888,
            Idle1 = 619542203, Idle2 = 619542203, Fall = 619541867,
            Swim = 619543721, SwimIdle = 619543721, Climb = 619541458,
        },
        ["Mage"] = {
            Run = 707861613, Walk = 707897309, Jump = 707853694,
            Idle1 = 707742142, Idle2 = 707855907, Fall = 707829716,
            Swim = 707876443, SwimIdle = 707894699, Climb = 707826056,
        },
        ["Robot"] = {
            Run = 619522386, Walk = 619522849, Jump = 619522088,
            Idle1 = 619521748, Idle2 = 619521748, Fall = 619521521,
            Swim = 619522642, SwimIdle = 619522642, Climb = 619521311,
        },
    }

    local packNames = {}
    for name in pairs(OFFICIAL_PACKS) do
        table.insert(packNames, name)
    end
    table.sort(packNames)

    local selectedPack = packNames[1] or "Zombie"
    Anims:CreateDropdown({
        Name = "Pack",
        Options = packNames,
        Default = selectedPack,
        Callback = function(v)
            selectedPack = v
        end,
    })

    local function stopTracks(hum)
        if not hum then return end
        pcall(function()
            for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
                t:Stop(0)
            end
            local animator = hum:FindFirstChildOfClass("Animator")
            if animator then
                for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
                    t:Stop(0)
                end
            end
        end)
    end

    local function setAnimId(obj, id)
        if not obj or not id or id == 0 then return end
        pcall(function()
            obj.AnimationId = "rbxassetid://" .. tostring(id)
        end)
    end

    local function applyPackIds(ids)
        local char = LocalPlayer.Character
        if not char then
            N0IR:Notify({ Title = "Anims", Content = "No character", Duration = 2, Type = "danger" })
            return false
        end
        captureOriginalAnims() -- ensure we have originals before changing
        local hum = char:FindFirstChildOfClass("Humanoid")
        local animate = char:FindFirstChild("Animate")
        if not animate then
            N0IR:Notify({ Title = "Anims", Content = "Animate script not found (need R15)", Duration = 2.5, Type = "warning" })
            return false
        end
        stopTracks(hum)

        local function childAnim(folderName, animName)
            local folder = animate:FindFirstChild(folderName)
            if not folder then return nil end
            return folder:FindFirstChild(animName) or folder:FindFirstChildOfClass("Animation")
        end

        setAnimId(childAnim("run", "RunAnim"), ids.Run)
        setAnimId(childAnim("walk", "WalkAnim"), ids.Walk)
        setAnimId(childAnim("jump", "JumpAnim"), ids.Jump)
        setAnimId(childAnim("fall", "FallAnim"), ids.Fall)
        setAnimId(childAnim("climb", "ClimbAnim"), ids.Climb)
        setAnimId(childAnim("swim", "Swim"), ids.Swim)
        setAnimId(childAnim("swimidle", "SwimIdle"), ids.SwimIdle or ids.Swim)

        local idle = animate:FindFirstChild("idle")
        if idle then
            setAnimId(idle:FindFirstChild("Animation1"), ids.Idle1 or ids.Idle)
            setAnimId(idle:FindFirstChild("Animation2"), ids.Idle2 or ids.Idle1 or ids.Idle)
        end
        return true
    end

    Anims:CreateButton({
        Name = "Apply selected pack",
        Callback = function()
            local ids = OFFICIAL_PACKS[selectedPack]
            if not ids then
                N0IR:Notify({ Title = "Anims", Content = "Unknown pack", Duration = 2, Type = "danger" })
                return
            end
            if applyPackIds(ids) then
                N0IR:Notify({ Title = "Anims", Content = selectedPack .. " applied", Duration = 2, Type = "success" })
            end
        end,
    })

    -- Reset to the animations the character originally had
    Anims:CreateButton({
        Name = "Reset to original animations",
        Callback = function()
            local orig = captureOriginalAnims()
            if not orig then
                -- fallback to Roblox defaults
                if applyPackIds(DEFAULT_ANIMS) then
                    N0IR:Notify({ Title = "Anims", Content = "Reset to default (no original captured)", Duration = 2 })
                end
                return
            end
            if applyPackIds(orig) then
                N0IR:Notify({ Title = "Anims", Content = "Reset to your original animations", Duration = 2, Type = "success" })
            end
        end,
    })

    Anims:CreateButton({
        Name = "Reset to Roblox defaults",
        Callback = function()
            if applyPackIds(DEFAULT_ANIMS) then
                N0IR:Notify({ Title = "Anims", Content = "Reset to Roblox defaults", Duration = 2 })
            end
        end,
    })

    local customSlots = {
        Run = 0, Walk = 0, Jump = 0, Idle1 = 0, Idle2 = 0,
        Fall = 0, Climb = 0, Swim = 0, SwimIdle = 0,
    }

    Anims:CreateSection("Custom slots")
    Anims:CreateParagraph({
        Content = "Pick a pack above or search below, then tweak individual slots and Apply custom.",
    })

    local slotLabel = Anims:CreateLabel("Slots  ·  none loaded yet")
    local function updateSlotLabel()
        local parts = {}
        for _, key in ipairs({ "Run", "Walk", "Jump", "Fall", "Climb" }) do
            local v = customSlots[key]
            if v and v ~= 0 then
                table.insert(parts, key .. "=" .. tostring(v))
            end
        end
        slotLabel:Set(#parts > 0 and ("Slots  ·  " .. table.concat(parts, "  ")) or "Slots  ·  none loaded yet")
    end

    local slotOrder = { "Run", "Walk", "Jump", "Idle1", "Idle2", "Fall", "Climb", "Swim", "SwimIdle" }
    local slotInputs = {}

    Anims:CreateButton({
        Name = "Load pack into custom slots",
        Callback = function()
            local ids = OFFICIAL_PACKS[selectedPack]
            if not ids then return end
            for k, v in pairs(ids) do
                customSlots[k] = v
            end
            for key, inp in pairs(slotInputs) do
                if inp and inp.Set and customSlots[key] and customSlots[key] ~= 0 then
                    inp:Set(tostring(customSlots[key]))
                end
            end
            updateSlotLabel()
            N0IR:Notify({ Title = "Anims", Content = selectedPack .. " → custom slots", Duration = 1.5 })
        end,
    })

    for _, key in ipairs(slotOrder) do
        slotInputs[key] = Anims:CreateInput({
            Name = key,
            Placeholder = "animation asset id",
            Default = "",
            Callback = function(text)
                local n = tonumber(text)
                if n then customSlots[key] = n end
                updateSlotLabel()
            end,
        })
    end

    Anims:CreateButton({
        Name = "Apply custom slots",
        Callback = function()
            for key, inp in pairs(slotInputs) do
                if inp and inp.Get then
                    local n = tonumber(inp:Get())
                    if n then customSlots[key] = n end
                end
            end
            if applyPackIds(customSlots) then
                N0IR:Notify({ Title = "Anims", Content = "Custom slots applied", Duration = 2, Type = "success" })
            end
        end,
    })

    Anims:CreateSection("Search bundles")
    Anims:CreateParagraph({
        Content = "Search Roblox catalog animation packs (e.g. zombie). Select a result to fill custom slots.",
    })

    local searchInput = Anims:CreateInput({
        Name = "Search",
        Placeholder = "zombie, ninja, anime...",
        Default = "",
    })

    local searchResults = {}
    local resultNames = { "(search first)" }
    local resultDropdown = Anims:CreateDropdown({
        Name = "Results",
        Options = resultNames,
        Default = resultNames[1],
        Callback = function(name)
            local entry = searchResults[name]
            if not entry then return end
            task.spawn(function()
                N0IR:Notify({ Title = "Anims", Content = "Loading bundle details...", Duration = 1.5 })
                local ok, details = pcall(function()
                    local body = game:HttpGet("https://catalog.roblox.com/v1/bundles/" .. tostring(entry.id) .. "/details")
                    return HttpService:JSONDecode(body)
                end)
                if not ok or not details or not details.items then
                    ok, details = pcall(function()
                        local body = game:HttpGet("https://catalog.roproxy.com/v1/bundles/" .. tostring(entry.id) .. "/details")
                        return HttpService:JSONDecode(body)
                    end)
                end
                if not ok or not details or type(details.items) ~= "table" then
                    N0IR:Notify({ Title = "Anims", Content = "Could not load bundle", Duration = 2, Type = "danger" })
                    return
                end
                local map = {
                    run = "Run", walk = "Walk", jump = "Jump", fall = "Fall",
                    climb = "Climb", swim = "Swim", idle = "Idle1",
                }
                local filled = {}
                for _, item in ipairs(details.items) do
                    if item.type == "Asset" and item.id then
                        local n = string.lower(item.name or "")
                        for needle, slot in pairs(map) do
                            if n:find(needle) then
                                if slot == "Idle1" and filled.Idle1 then
                                    customSlots.Idle2 = item.id
                                else
                                    customSlots[slot] = item.id
                                    filled[slot] = true
                                end
                                if slot == "Swim" and not filled.SwimIdle then
                                    customSlots.SwimIdle = item.id
                                end
                            end
                        end
                    end
                end
                for key, inp in pairs(slotInputs) do
                    if inp and inp.Set and customSlots[key] and customSlots[key] ~= 0 then
                        inp:Set(tostring(customSlots[key]))
                    end
                end
                updateSlotLabel()
                N0IR:Notify({ Title = "Anims", Content = (details.name or name) .. " loaded into slots", Duration = 2, Type = "success" })
            end)
        end,
    })

    Anims:CreateButton({
        Name = "Search animation packs",
        Callback = function()
            local q = ""
            if searchInput and searchInput.Get then
                q = tostring(searchInput:Get() or ""):gsub("^%s+", ""):gsub("%s+$", "")
            end
            if q == "" then
                N0IR:Notify({ Title = "Anims", Content = "Type a search term", Duration = 2 })
                return
            end
            N0IR:Notify({ Title = "Anims", Content = "Searching...", Duration = 1.2 })
            task.spawn(function()
                local encoded = HttpService:UrlEncode(q)
                local urls = {
                    "https://catalog.roblox.com/v1/search/items/details?Category=12&Subcategory=38&Keyword=" .. encoded .. "&Limit=30&SortType=0",
                    "https://catalog.roblox.com/v1/search/items/details?Category=12&Subcategory=27&Keyword=" .. encoded .. "&Limit=30&SortType=0",
                    "https://catalog.roproxy.com/v1/search/items/details?Category=12&Subcategory=38&Keyword=" .. encoded .. "&Limit=30&SortType=0",
                }
                local data
                for _, url in ipairs(urls) do
                    local ok, decoded = pcall(function()
                        return HttpService:JSONDecode(game:HttpGet(url))
                    end)
                    if ok and decoded and type(decoded.data) == "table" and #decoded.data > 0 then
                        data = decoded
                        break
                    end
                end
                if not data then
                    N0IR:Notify({ Title = "Anims", Content = "No results / request failed", Duration = 2.5, Type = "danger" })
                    return
                end
                searchResults = {}
                resultNames = {}
                for _, item in ipairs(data.data) do
                    local name = item.name or ("Bundle " .. tostring(item.id))
                    local label = name .. "  ·  " .. tostring(item.id)
                    searchResults[label] = item
                    table.insert(resultNames, label)
                end
                if resultDropdown and resultDropdown.SetOptions then
                    resultDropdown:SetOptions(resultNames)
                end
                if #resultNames > 0 and resultDropdown and resultDropdown.Set then
                    resultDropdown:Set(resultNames[1])
                end
                N0IR:Notify({ Title = "Anims", Content = tostring(#resultNames) .. " packs found", Duration = 2, Type = "success" })
            end)
        end,
    })

    Anims:CreateButton({
        Name = "Apply selected search result",
        Callback = function()
            if applyPackIds(customSlots) then
                N0IR:Notify({ Title = "Anims", Content = "Applied custom / search slots", Duration = 2, Type = "success" })
            end
        end,
    })

    -- ---------- Commands tab ----------
    local Cmds = Window:CreateTab({ Name = "Commands" })
    Cmds:CreateSection("Runner")
    Cmds:CreateParagraph({
        Content = "Click Run on any command. Put numbers / player names in the argument box when needed.",
    })

    local argBox = Cmds:CreateInput({
        Name = "Argument",
        Placeholder = "e.g. 50  or  playerName",
        Default = "",
    })

    local prefix = ";"
    local flying = false
    local flyConn = nil

    local function findPlayer(q)
        if not q or q == "" then return nil end
        q = q:lower()
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name:lower():sub(1, #q) == q or p.DisplayName:lower():sub(1, #q) == q then
                return p
            end
        end
        return nil
    end

    local function runCmd(msg)
        msg = tostring(msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
        if msg == "" then return end
        if msg:sub(1, 1) ~= prefix then
            msg = prefix .. msg
        end
        local body = msg:sub(2)
        local args = {}
        for w in body:gmatch("%S+") do table.insert(args, w) end
        local cmd = args[1]
        if not cmd then return end

        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if cmd == "ws" or cmd == "speed" then
            local v = tonumber(args[2])
            if hum and v then
                hum.WalkSpeed = v
                N0IR:Notify({ Title = "WalkSpeed", Content = tostring(v), Duration = 1.5 })
            else
                N0IR:Notify({ Title = "WalkSpeed", Content = "Need a number in Argument", Duration = 2 })
            end
        elseif cmd == "jp" or cmd == "jumppower" then
            local v = tonumber(args[2])
            if hum and v then
                hum.UseJumpPower = true
                hum.JumpPower = v
                N0IR:Notify({ Title = "JumpPower", Content = tostring(v), Duration = 1.5 })
            else
                N0IR:Notify({ Title = "JumpPower", Content = "Need a number in Argument", Duration = 2 })
            end
        elseif cmd == "goto" or cmd == "to" then
            local t = findPlayer(args[2])
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and hrp then
                hrp.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                N0IR:Notify({ Title = "Goto", Content = t.Name, Duration = 1.5 })
            else
                N0IR:Notify({ Title = "Goto", Content = "Player not found — set Argument", Duration = 2 })
            end
        elseif cmd == "view" then
            local t = findPlayer(args[2])
            if t and t.Character and t.Character:FindFirstChildOfClass("Humanoid") then
                workspace.CurrentCamera.CameraSubject = t.Character:FindFirstChildOfClass("Humanoid")
                N0IR:Notify({ Title = "View", Content = t.Name, Duration = 1.5 })
            else
                N0IR:Notify({ Title = "View", Content = "Player not found — set Argument", Duration = 2 })
            end
        elseif cmd == "unview" then
            if hum then
                workspace.CurrentCamera.CameraSubject = hum
                N0IR:Notify({ Title = "View", Content = "Reset", Duration = 1.2 })
            end
        elseif cmd == "noclip" then
            N0IR.Flags.Noclip = true
            if not _G._N0IR_NoclipConn then
                _G._N0IR_NoclipOn = true
                _G._N0IR_NoclipConn = RunService.Stepped:Connect(function()
                    if not _G._N0IR_NoclipOn then return end
                    local c = LocalPlayer.Character
                    if not c then return end
                    for _, p in ipairs(c:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end)
            else
                _G._N0IR_NoclipOn = true
            end
            N0IR:Notify({ Title = "Noclip", Content = "ON", Duration = 1.2 })
        elseif cmd == "clip" then
            _G._N0IR_NoclipOn = false
            N0IR.Flags.Noclip = false
            local c = LocalPlayer.Character
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
            N0IR:Notify({ Title = "Noclip", Content = "OFF", Duration = 1.2 })
        elseif cmd == "rejoin" or cmd == "rj" then
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end)
        elseif cmd == "hop" or cmd == "serverhop" then
            pcall(function()
                local servers = HttpService:JSONDecode(game:HttpGet(
                    "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=50"
                ))
                if servers and servers.data then
                    for _, s in ipairs(servers.data) do
                        if s.playing < s.maxPlayers and s.id ~= game.JobId then
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                            return
                        end
                    end
                end
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
        elseif cmd == "fly" then
            if flying then
                N0IR:Notify({ Title = "Fly", Content = "Already on — use Unfly", Duration = 1.5 })
                return
            end
            if not hrp then return end
            flying = true
            local speed = tonumber(args[2]) or 50
            local bv = Instance.new("BodyVelocity")
            bv.Name = "N0IR_FlyBV"
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
            flyConn = RunService.RenderStepped:Connect(function()
                if not flying or not hrp or not hrp.Parent then return end
                local dir = Vector3.zero
                local cam = workspace.CurrentCamera
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                bv.Velocity = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero
            end)
            N0IR:Notify({ Title = "Fly", Content = "ON  ·  speed " .. tostring(speed), Duration = 1.5 })
        elseif cmd == "unfly" then
            flying = false
            if flyConn then flyConn:Disconnect(); flyConn = nil end
            if hrp then
                local f = hrp:FindFirstChild("N0IR_FlyBV")
                if f then f:Destroy() end
            end
            N0IR:Notify({ Title = "Fly", Content = "OFF", Duration = 1.2 })
        elseif cmd == "reset" or cmd == "respawn" then
            if hum then hum.Health = 0 end
        elseif cmd == "sit" then
            if hum then hum.Sit = true end
        elseif cmd == "unsit" then
            if hum then hum.Sit = false end
        elseif cmd == "fps" then
            local n = tonumber(args[2]) or 0
            pcall(function()
                if setfpscap then setfpscap(n) end
            end)
            N0IR:Notify({ Title = "FPS Cap", Content = tostring(n), Duration = 1.5 })
        elseif cmd == "cmds" or cmd == "commands" then
            N0IR:Notify({ Title = "Commands", Content = "See the Commands tab list", Duration = 2 })
        else
            N0IR:Notify({ Title = "Unknown", Content = cmd, Duration = 1.5 })
        end
    end

    local catalog = {
        { cmd = "ws",        label = "WalkSpeed",     desc = "Set walk speed  ·  arg: number",        needsArg = true,  example = "50" },
        { cmd = "jp",        label = "JumpPower",     desc = "Set jump power  ·  arg: number",        needsArg = true,  example = "75" },
        { cmd = "goto",      label = "Goto player",   desc = "Teleport to player  ·  arg: name",      needsArg = true,  example = "" },
        { cmd = "view",      label = "View player",   desc = "Spectate player  ·  arg: name",         needsArg = true,  example = "" },
        { cmd = "unview",    label = "Unview",        desc = "Reset camera to yourself",              needsArg = false },
        { cmd = "noclip",    label = "Noclip",        desc = "Walk through walls",                   needsArg = false },
        { cmd = "clip",      label = "Clip",          desc = "Disable noclip",                       needsArg = false },
        { cmd = "fly",       label = "Fly",           desc = "Start flying  ·  arg: speed (optional)", needsArg = false, example = "50" },
        { cmd = "unfly",     label = "Unfly",         desc = "Stop flying",                          needsArg = false },
        { cmd = "rejoin",    label = "Rejoin",        desc = "Rejoin this server",                   needsArg = false },
        { cmd = "hop",       label = "Server hop",    desc = "Join a different server",              needsArg = false },
        { cmd = "reset",     label = "Reset",         desc = "Kill / respawn character",             needsArg = false },
        { cmd = "sit",       label = "Sit",           desc = "Force sit",                            needsArg = false },
        { cmd = "unsit",     label = "Unsit",         desc = "Stand up",                             needsArg = false },
        { cmd = "fps",       label = "FPS cap",       desc = "Cap framerate  ·  arg: number",        needsArg = true,  example = "60" },
    }

    Cmds:CreateSection("All commands")

    local function makeCmdRow(entry)
        Cmds._order = (Cmds._order or 0) + 1
        local page = Cmds.Page
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 50)
        row.BackgroundColor3 = T.bg1
        row.BackgroundTransparency = 0.2
        row.BorderSizePixel = 0
        row.LayoutOrder = Cmds._order
        row.Parent = page
        corner(row, 9)
        stroke(row, T.border, 1, 0.55)

        local name = Instance.new("TextLabel")
        name.BackgroundTransparency = 1
        name.Position = UDim2.fromOffset(14, 7)
        name.Size = UDim2.new(1, -96, 0, 16)
        name.Font = Enum.Font.GothamBold
        name.Text = entry.label .. "  ·  ;" .. entry.cmd
        name.TextSize = 12
        name.TextColor3 = T.text
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = row

        local desc = Instance.new("TextLabel")
        desc.BackgroundTransparency = 1
        desc.Position = UDim2.fromOffset(14, 26)
        desc.Size = UDim2.new(1, -96, 0, 16)
        desc.Font = Enum.Font.Gotham
        desc.Text = entry.desc
        desc.TextSize = 10
        desc.TextColor3 = T.text3
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextTruncate = Enum.TextTruncate.AtEnd
        desc.Parent = row

        local run = Instance.new("TextButton")
        run.AnchorPoint = Vector2.new(1, 0.5)
        run.Position = UDim2.new(1, -12, 0.5, 0)
        run.Size = UDim2.fromOffset(68, 28)
        run.BackgroundColor3 = T.accent
        run.BorderSizePixel = 0
        run.Font = Enum.Font.GothamBold
        run.Text = "Run"
        run.TextSize = 11
        run.TextColor3 = Color3.fromRGB(8, 8, 8)
        run.AutoButtonColor = false
        run.Parent = row
        corner(run, 7)

        run.MouseEnter:Connect(function()
            tween(run, { BackgroundTransparency = 0.12 }, 0.1)
        end)
        run.MouseLeave:Connect(function()
            tween(run, { BackgroundTransparency = 0 }, 0.1)
        end)
        run.MouseButton1Click:Connect(function()
            local arg = ""
            if argBox and argBox.Get then
                arg = tostring(argBox:Get() or ""):gsub("^%s+", ""):gsub("%s+$", "")
            end
            local line = entry.cmd
            if arg ~= "" then
                line = entry.cmd .. " " .. arg
            elseif entry.example and entry.example ~= "" and entry.cmd == "fly" then
                line = entry.cmd .. " " .. entry.example
            end
            runCmd(line)
        end)
    end

    for _, entry in ipairs(catalog) do
        makeCmdRow(entry)
    end

    pcall(function()
        LocalPlayer.Chatted:Connect(function(msg)
            runCmd(msg)
        end)
    end)

    -- Floating command bar ( ; key )
    local cmdBarKey = Enum.KeyCode.Semicolon
    local cmdGui = Instance.new("ScreenGui")
    cmdGui.Name = "N0IR_CmdBar"
    cmdGui.ResetOnSpawn = false
    cmdGui.DisplayOrder = 200
    cmdGui.Parent = getHost()

    local bar = Instance.new("Frame")
    bar.AnchorPoint = Vector2.new(0.5, 1)
    bar.Position = UDim2.new(0.5, 0, 1, 70)
    bar.Size = UDim2.fromOffset(400, 42)
    bar.BackgroundColor3 = T.bg0
    bar.BackgroundTransparency = 0.06
    bar.BorderSizePixel = 0
    bar.Parent = cmdGui
    corner(bar, 11)
    stroke(bar, T.border, 1, 0.3)

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -28, 1, 0)
    input.Position = UDim2.fromOffset(14, 0)
    input.BackgroundTransparency = 1
    input.Font = Enum.Font.GothamMedium
    input.PlaceholderText = "command  ·  press ; to open"
    input.PlaceholderColor3 = T.text3
    input.Text = ""
    input.TextSize = 13
    input.TextColor3 = T.text
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.ClearTextOnFocus = false
    input.Parent = bar

    track(UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == cmdBarKey then
            task.defer(function()
                input:CaptureFocus()
                input.Text = ""
                tween(bar, { Position = UDim2.new(0.5, 0, 1, -20) }, 0.28)
            end)
        end
    end))

    input.FocusLost:Connect(function(enter)
        tween(bar, { Position = UDim2.new(0.5, 0, 1, 70) }, 0.28)
        if enter and input.Text ~= "" then
            local t = input.Text
            if t:sub(1, 1) ~= prefix then t = prefix .. t end
            runCmd(t)
        end
        input.Text = ""
    end)

    Cmds:CreateLabel("Tip  ·  press  ;  for the quick command bar")

    -- ---------- Map / Treehouse ----------
    local Map = Window:CreateTab({ Name = "Map" })
    Map:CreateSection("Treehouse")
    Map:CreateParagraph({
        Content = "Spawn / teleport / remove the Halo treehouse model in workspace.",
    })

    local TREEHOUSE_ASSET_ID = 7860328354
    _G._HaloTreehouseModel = _G._HaloTreehouseModel

    local function getTreehouseSpawnPosition()
        local spawnPart = workspace:FindFirstChild("ModelSpawn")
        if spawnPart and spawnPart:IsA("BasePart") then
            return spawnPart.Position
        end
        return Vector3.new(-410.25, 100.5, -75.46)
    end

    local function prepareTreehouseModel(model, position)
        for _, v in pairs(model:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Anchored = true
                v.CanCollide = true
            end
        end
        if model:IsA("Model") then
            local spawnPart = workspace:FindFirstChild("ModelSpawn")
            if spawnPart and spawnPart:IsA("BasePart") then
                model:PivotTo(spawnPart.CFrame)
            else
                model:PivotTo(CFrame.new(position))
            end
        end
    end

    local function spawnTreehouse()
        if _G._HaloTreehouseModel and _G._HaloTreehouseModel.Parent then
            N0IR:Notify({ Title = "Treehouse", Content = "Already spawned", Duration = 2 })
            return _G._HaloTreehouseModel
        end
        local existing = workspace:FindFirstChild("HaloTreehouse")
        if existing then
            _G._HaloTreehouseModel = existing
            N0IR:Notify({ Title = "Treehouse", Content = "Already in workspace", Duration = 2 })
            return existing
        end
        local ok, objects = pcall(function()
            return game:GetObjects("rbxassetid://" .. tostring(TREEHOUSE_ASSET_ID))
        end)
        if not ok or not objects or #objects == 0 then
            N0IR:Notify({ Title = "Treehouse", Content = "Failed to load model", Duration = 3, Type = "danger" })
            return nil
        end
        local model = objects[1]
        model.Name = "HaloTreehouse"
        model.Parent = workspace
        prepareTreehouseModel(model, getTreehouseSpawnPosition())
        _G._HaloTreehouseModel = model
        N0IR:Notify({ Title = "Treehouse", Content = "Spawned", Duration = 2.5, Type = "success" })
        return model
    end

    local function deleteTreehouse()
        local deleted = false
        if _G._HaloTreehouseModel and _G._HaloTreehouseModel.Parent then
            pcall(function() _G._HaloTreehouseModel:Destroy() end)
            _G._HaloTreehouseModel = nil
            deleted = true
        end
        for _, item in ipairs(workspace:GetChildren()) do
            if item.Name == "HaloTreehouse" then
                pcall(function() item:Destroy() end)
                deleted = true
            end
        end
        N0IR:Notify({
            Title = "Treehouse",
            Content = deleted and "Removed" or "Nothing to remove",
            Duration = 2,
        })
    end

    local function teleportToTreehouse()
        local model = _G._HaloTreehouseModel or workspace:FindFirstChild("HaloTreehouse")
        if not model or not model.Parent then
            model = spawnTreehouse()
            if not model then return end
            task.wait(0.25)
        end
        local targetPart = nil
        for _, v in pairs(model:GetDescendants()) do
            if v:IsA("BasePart") and string.find(string.lower(v.Name), "spawn") then
                targetPart = v
                break
            end
        end
        if not targetPart then
            local parts = {}
            for _, v in pairs(model:GetDescendants()) do
                if v:IsA("BasePart") then table.insert(parts, v) end
            end
            if #parts > 0 then
                local total = Vector3.zero
                for _, p in pairs(parts) do total = total + p.Position end
                local center = total / #parts
                local closest, minDist = parts[1], math.huge
                for _, p in pairs(parts) do
                    local d = (p.Position - center).Magnitude
                    if d < minDist then closest, minDist = p, d end
                end
                targetPart = closest
            end
        end
        if not targetPart then
            N0IR:Notify({ Title = "Treehouse", Content = "No part to teleport to", Duration = 2 })
            return
        end
        local char = LocalPlayer.Character
        local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
        if hrp then
            hrp.CFrame = targetPart.CFrame + Vector3.new(0, 6, 0)
            N0IR:Notify({ Title = "Treehouse", Content = "Teleported", Duration = 1.5, Type = "success" })
        end
    end

    _G._HaloSpawnTreehouse = spawnTreehouse
    _G._HaloDeleteTreehouse = deleteTreehouse
    _G._HaloTeleportToTreehouse = teleportToTreehouse

    Map:CreateButton({ Name = "Spawn Treehouse", Callback = spawnTreehouse })
    Map:CreateButton({ Name = "Teleport to Treehouse", Callback = teleportToTreehouse })
    Map:CreateButton({ Name = "Delete Treehouse", Callback = deleteTreehouse })

    -- ---------- Social ----------
    local Social = Window:CreateTab({ Name = "Social" })
    Social:CreateSection("Friends")
    Social:CreateParagraph({
        Content = "Notify when a Roblox friend leaves your server.",
    })

    local friendLeftOn = (_G._N0IR_FriendLeftNotify ~= false)
    local friendLeftConn = nil

    local function isFriend(userId)
        local ok, res = pcall(function()
            if LocalPlayer.IsFriendsWith then
                return LocalPlayer:IsFriendsWith(userId)
            end
            return false
        end)
        return ok and res or false
    end

    local function startFriendLeft()
        if friendLeftConn then return end
        friendLeftConn = Players.PlayerRemoving:Connect(function(player)
            if not friendLeftOn then return end
            local displayName = player.DisplayName
            local userId = player.UserId
            task.spawn(function()
                if not isFriend(userId) then return end
                N0IR:Notify({
                    Title = displayName .. " left",
                    Content = "Friend left this server",
                    Duration = 5,
                    Type = "warning",
                })
            end)
        end)
    end

    local function stopFriendLeft()
        if friendLeftConn then
            friendLeftConn:Disconnect()
            friendLeftConn = nil
        end
    end

    Social:CreateToggle({
        Name = "Friend Left Notify",
        Description = "Toast when a friend leaves the server",
        Flag = "FriendLeftNotify",
        Default = true,
        Callback = function(on)
            friendLeftOn = on
            _G._N0IR_FriendLeftNotify = on
            if on then startFriendLeft() else stopFriendLeft() end
        end,
    })

    startFriendLeft()

    -- ---------- Settings tab ----------
    local Settings = Window:CreateTab({ Name = "Settings" })
    Settings:CreateSection("About")
    Settings:CreateParagraph({
        Content = "NØIR UI Library v" .. N0IR.Version .. "\nMinimal black & white suite. Mount reanim or other modules via loadstring onto this window.",
    })

    Settings:CreateSection("Menu Keybind")
    Settings:CreateParagraph({
        Content = "Default is Left Alt. Click the keybind button, then press any key. Esc cancels.",
    })

    -- Proper keybind selector (default LeftAlt)
    local keybindControl = Settings:CreateKeybind({
        Name = "Menu toggle",
        Description = "Show / hide the entire menu",
        Default = _G._N0IR_ToggleKey or Enum.KeyCode.LeftAlt,
        Flag = "MenuToggleKey",
        Callback = function(kc)
            _G._N0IR_ToggleKey = kc
            Window.ToggleKey = kc
            N0IR:Notify({
                Title = "Keybind",
                Content = "Menu toggle set to " .. kc.Name,
                Duration = 2,
                Type = "success",
            })
        end,
    })

    Settings:CreateButton({
        Name = "Reset keybind to Left Alt",
        Callback = function()
            local kc = Enum.KeyCode.LeftAlt
            _G._N0IR_ToggleKey = kc
            Window.ToggleKey = kc
            if keybindControl and keybindControl.Set then
                keybindControl:Set(kc)
            end
            N0IR:Notify({ Title = "Keybind", Content = "Reset to LeftAlt", Duration = 1.8 })
        end,
    })

    Settings:CreateSection("Tests")
    Settings:CreateButton({
        Name = "Notify Test",
        Callback = function()
            N0IR:Notify({ Title = "NØIR", Content = "Library is alive.", Duration = 2, Type = "success" })
        end,
    })

    Settings:CreateButton({
        Name = "Toggle menu (test)",
        Callback = function()
            Window.Toggle()
        end,
    })

    return {
        Home = Home,
        World = World,
        Player = Player,
        Anims = Anims,
        Cmds = Cmds,
        Map = Map,
        Social = Social,
        Settings = Settings,
        RunCommand = runCmd,
        SpawnTreehouse = spawnTreehouse,
        DeleteTreehouse = deleteTreehouse,
        TeleportToTreehouse = teleportToTreehouse,
    }
end

-- ============================================================
-- QUICK START HELPER
-- ============================================================
function N0IR:Init(opts)
    opts = opts or {}
    local win = self:CreateWindow({
        Title = opts.Title or "NØIR",
        SubTitle = opts.SubTitle or "Suite",
        Width = opts.Width or 540,
        Height = opts.Height or 460,
        Loading = opts.Loading ~= false,
        LoadingText = opts.LoadingText or "loading modules",
        LoadingDuration = opts.LoadingDuration or 2.0,
        ToggleKey = opts.ToggleKey or Enum.KeyCode.LeftAlt,
    })
    local modules = self:MountUtilities(win)
    return win, modules
end

return N0IR
