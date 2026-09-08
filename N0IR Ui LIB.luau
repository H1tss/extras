--[[
    NØIR UI Library
    Clean · Minimal · Black & White
    Designed to host modules (utility, cmds, reanim via loadstring, etc.)

    Usage:
        local N0IR = loadstring(game:HttpGet("..."))()  -- or readfile
        local Window = N0IR:CreateWindow({ Title = "NØIR", SubTitle = "Suite" })
        local Tab = Window:CreateTab({ Name = "Main" })
        Tab:CreateToggle({ Name = "Example", Flag = "ex", Callback = function(v) end })
]]

local N0IR = {
    Version = "1.0.0",
    Flags = {},
    _windows = {},
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- THEME
-- ============================================================
local T = {
    bg0       = Color3.fromRGB(8, 8, 8),
    bg1       = Color3.fromRGB(14, 14, 14),
    bg2       = Color3.fromRGB(20, 20, 20),
    bg3       = Color3.fromRGB(28, 28, 28),
    bg4       = Color3.fromRGB(36, 36, 36),
    border    = Color3.fromRGB(42, 42, 42),
    border2   = Color3.fromRGB(55, 55, 55),
    text      = Color3.fromRGB(245, 245, 245),
    text2     = Color3.fromRGB(180, 180, 180),
    text3     = Color3.fromRGB(110, 110, 110),
    accent    = Color3.fromRGB(255, 255, 255),
    dim       = Color3.fromRGB(160, 160, 160),
    danger    = Color3.fromRGB(200, 80, 80),
    success   = Color3.fromRGB(80, 200, 120),
}

local function tween(obj, props, dur, style, dir)
    local info = TweenInfo.new(dur or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
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
    s.Transparency = trans or 0.35
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
        -- prefer PlayerGui — CoreGui can intercept input on some executors
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        return pg or host
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- ============================================================
-- LOADING SCREEN (fullscreen, half-transparent, NØIR)
-- ============================================================
function N0IR:LoadingScreen(opts)
    opts = opts or {}
    local duration = opts.Duration or 2.4
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

    -- Fullscreen dim
    local veil = Instance.new("Frame")
    veil.Name = "Veil"
    veil.Size = UDim2.fromScale(1, 1)
    veil.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    veil.BackgroundTransparency = 1
    veil.BorderSizePixel = 0
    veil.Parent = gui

    -- Center stack
    local stack = Instance.new("Frame")
    stack.Name = "Stack"
    stack.AnchorPoint = Vector2.new(0.5, 0.5)
    stack.Position = UDim2.fromScale(0.5, 0.5)
    stack.Size = UDim2.fromOffset(320, 120)
    stack.BackgroundTransparency = 1
    stack.Parent = gui

    local brand = Instance.new("TextLabel")
    brand.BackgroundTransparency = 1
    brand.Size = UDim2.new(1, 0, 0, 36)
    brand.Font = Enum.Font.GothamBlack
    brand.Text = title
    brand.TextSize = 28
    brand.TextColor3 = T.text
    brand.TextTransparency = 1
    brand.Parent = stack

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.fromOffset(0, 38)
    sub.Size = UDim2.new(1, 0, 0, 18)
    sub.Font = Enum.Font.GothamMedium
    sub.Text = subtitle
    sub.TextSize = 13
    sub.TextColor3 = T.text3
    sub.TextTransparency = 1
    sub.Parent = stack

    local place = Instance.new("TextLabel")
    place.BackgroundTransparency = 1
    place.Position = UDim2.fromOffset(0, 58)
    place.Size = UDim2.new(1, 0, 0, 16)
    place.Font = Enum.Font.Code
    place.Text = placeName .. "  ·  " .. tostring(game.PlaceId)
    place.TextSize = 11
    place.TextColor3 = T.text3
    place.TextTransparency = 1
    place.TextTruncate = Enum.TextTruncate.AtEnd
    place.Parent = stack

    -- Progress track
    local track = Instance.new("Frame")
    track.Position = UDim2.fromOffset(0, 88)
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
    pct.Position = UDim2.fromOffset(0, 96)
    pct.Size = UDim2.new(1, 0, 0, 16)
    pct.Font = Enum.Font.Code
    pct.Text = "0%"
    pct.TextSize = 11
    pct.TextColor3 = T.text3
    pct.TextTransparency = 1
    pct.Parent = stack

    -- Fade in
    tween(veil, { BackgroundTransparency = 0.45 }, 0.4)
    tween(brand, { TextTransparency = 0 }, 0.45)
    tween(sub, { TextTransparency = 0 }, 0.5)
    tween(place, { TextTransparency = 0 }, 0.55)
    tween(track, { BackgroundTransparency = 0 }, 0.5)
    tween(fill, { BackgroundTransparency = 0 }, 0.5)
    tween(pct, { TextTransparency = 0 }, 0.5)

    local done = false
    local t0 = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local p = math.clamp((tick() - t0) / duration, 0, 1)
        local jagged = math.clamp(p + math.sin(p * 9) * 0.01, 0, 1)
        fill.Size = UDim2.fromScale(jagged, 1)
        pct.Text = string.format("%d%%", math.floor(jagged * 100))
        if p >= 1 and not done then
            done = true
            conn:Disconnect()
            task.delay(0.15, function()
                tween(veil, { BackgroundTransparency = 1 }, 0.4)
                tween(brand, { TextTransparency = 1 }, 0.35)
                tween(sub, { TextTransparency = 1 }, 0.3)
                tween(place, { TextTransparency = 1 }, 0.3)
                tween(track, { BackgroundTransparency = 1 }, 0.3)
                tween(fill, { BackgroundTransparency = 1 }, 0.3)
                tween(pct, { TextTransparency = 1 }, 0.3)
                task.delay(0.45, function()
                    if gui then gui:Destroy() end
                end)
            end)
        end
    end)

    return gui
end

-- ============================================================
-- NOTIFY
-- ============================================================
function N0IR:Notify(opts)
    if type(opts) == "string" then
        opts = { Title = opts }
    end
    opts = opts or {}
    local title = opts.Title or "NØIR"
    local content = opts.Content or opts.Description or ""
    local dur = opts.Duration or 2.5

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

    local n = Instance.new("Frame")
    n.Size = UDim2.fromOffset(280, content ~= "" and 56 or 40)
    n.Position = UDim2.new(1, 20, 0, 20)
    n.BackgroundColor3 = T.bg1
    n.BackgroundTransparency = 0.05
    n.BorderSizePixel = 0
    n.Parent = holder
    corner(n, 10)
    stroke(n, T.border, 1, 0.3)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 2, 0.55, 0)
    bar.Position = UDim2.new(0, 0, 0.5, 0)
    bar.AnchorPoint = Vector2.new(0, 0.5)
    bar.BackgroundColor3 = T.accent
    bar.BorderSizePixel = 0
    bar.Parent = n
    corner(bar, 1)

    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Position = UDim2.fromOffset(14, content ~= "" and 8 or 0)
    t.Size = UDim2.new(1, -24, 0, content ~= "" and 18 or 40)
    t.Font = Enum.Font.GothamBold
    t.Text = title
    t.TextSize = 12
    t.TextColor3 = T.text
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = n

    if content ~= "" then
        local c = Instance.new("TextLabel")
        c.BackgroundTransparency = 1
        c.Position = UDim2.fromOffset(14, 28)
        c.Size = UDim2.new(1, -24, 0, 20)
        c.Font = Enum.Font.Gotham
        c.Text = content
        c.TextSize = 11
        c.TextColor3 = T.text2
        c.TextXAlignment = Enum.TextXAlignment.Left
        c.TextTruncate = Enum.TextTruncate.AtEnd
        c.Parent = n
    end

    -- stack offset
    local yOff = 20
    for _, ch in ipairs(holder:GetChildren()) do
        if ch:IsA("Frame") and ch ~= n then
            yOff = yOff + ch.AbsoluteSize.Y + 8
        end
    end
    n.Position = UDim2.new(1, 20, 0, yOff)
    tween(n, { Position = UDim2.new(1, -300, 0, yOff) }, 0.4)

    task.delay(dur, function()
        tween(n, { Position = UDim2.new(1, 20, 0, yOff), BackgroundTransparency = 1 }, 0.3)
        task.delay(0.35, function()
            if n then n:Destroy() end
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
    local width = opts.Width or 520
    local height = opts.Height or 420

    if opts.Loading ~= false then
        self:LoadingScreen({
            Title = title,
            Subtitle = opts.LoadingText or "loading modules",
            Duration = opts.LoadingDuration or 2.2,
        })
        task.wait((opts.LoadingDuration or 2.2) + 0.5)
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
    screen.Parent = host

    local win = Instance.new("Frame")
    win.Name = "Main"
    win.AnchorPoint = Vector2.new(0.5, 0.5)
    win.Position = UDim2.fromScale(0.5, 0.5)
    win.Size = UDim2.fromOffset(width, height)
    win.BackgroundColor3 = T.bg0
    win.BackgroundTransparency = 0.04
    win.BorderSizePixel = 0
    win.ClipsDescendants = true
    win.Parent = screen
    corner(win, 12)
    stroke(win, T.border, 1, 0.25)

    -- Entrance
    win.Size = UDim2.fromOffset(math.floor(width * 0.92), math.floor(height * 0.92))
    win.BackgroundTransparency = 1
    tween(win, {
        Size = UDim2.fromOffset(width, height),
        BackgroundTransparency = 0.04,
    }, 0.45)

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 48)
    titleBar.BackgroundColor3 = T.bg1
    titleBar.BackgroundTransparency = 0.15
    titleBar.BorderSizePixel = 0
    titleBar.Active = true
    titleBar.Parent = win
    corner(titleBar, 12)
    do
        local cover = Instance.new("Frame")
        cover.BackgroundColor3 = T.bg1
        cover.BackgroundTransparency = 0.15
        cover.BorderSizePixel = 0
        cover.Position = UDim2.new(0, 0, 1, -12)
        cover.Size = UDim2.new(1, 0, 0, 12)
        cover.Parent = titleBar
    end

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.fromOffset(16, 0)
    titleLbl.Size = UDim2.new(0, 120, 1, 0)
    titleLbl.Font = Enum.Font.GothamBlack
    titleLbl.Text = title
    titleLbl.TextSize = 16
    titleLbl.TextColor3 = T.text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = titleBar

    if subTitle ~= "" then
        local subLbl = Instance.new("TextLabel")
        subLbl.BackgroundTransparency = 1
        subLbl.Position = UDim2.fromOffset(16 + titleLbl.TextBounds.X + 10, 0)
        subLbl.Size = UDim2.new(0, 160, 1, 0)
        subLbl.Font = Enum.Font.GothamMedium
        subLbl.Text = subTitle
        subLbl.TextSize = 11
        subLbl.TextColor3 = T.text3
        subLbl.TextXAlignment = Enum.TextXAlignment.Left
        subLbl.Parent = titleBar
        -- fix after render
        task.defer(function()
            subLbl.Position = UDim2.fromOffset(16 + titleLbl.TextBounds.X + 12, 0)
        end)
    end

    -- Window controls
    local closeBtn = Instance.new("TextButton")
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.Position = UDim2.new(1, -14, 0.5, 0)
    closeBtn.Size = UDim2.fromOffset(12, 12)
    closeBtn.BackgroundColor3 = Color3.fromRGB(160, 160, 160)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = ""
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = titleBar
    corner(closeBtn, 99)

    local minBtn = Instance.new("TextButton")
    minBtn.AnchorPoint = Vector2.new(1, 0.5)
    minBtn.Position = UDim2.new(1, -34, 0.5, 0)
    minBtn.Size = UDim2.fromOffset(12, 12)
    minBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    minBtn.BorderSizePixel = 0
    minBtn.Text = ""
    minBtn.AutoButtonColor = false
    minBtn.Parent = titleBar
    corner(minBtn, 99)

    -- thin accent line under title
    local accentLine = Instance.new("Frame")
    accentLine.Size = UDim2.new(1, 0, 0, 1)
    accentLine.Position = UDim2.new(0, 0, 1, 0)
    accentLine.BackgroundColor3 = T.accent
    accentLine.BackgroundTransparency = 0.85
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
        UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                local d = input.Position - dragStart
                win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    local isMin = false
    local fullSize = UDim2.fromOffset(width, height)
    local bodyVisible = true

    -- Tab strip
    local tabStrip = Instance.new("ScrollingFrame")
    tabStrip.Name = "TabStrip"
    tabStrip.Position = UDim2.fromOffset(0, 48)
    tabStrip.Size = UDim2.new(1, 0, 0, 36)
    tabStrip.BackgroundColor3 = T.bg1
    tabStrip.BackgroundTransparency = 0.4
    tabStrip.BorderSizePixel = 0
    tabStrip.ScrollBarThickness = 0
    tabStrip.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabStrip.ScrollingDirection = Enum.ScrollingDirection.X
    tabStrip.Parent = win

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = tabStrip
    padding(tabStrip, 4, 4, 10, 10)
    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabStrip.CanvasSize = UDim2.fromOffset(tabLayout.AbsoluteContentSize.X + 20, 0)
    end)

    -- Content host
    local contentHost = Instance.new("Frame")
    contentHost.Name = "Content"
    contentHost.Position = UDim2.fromOffset(0, 84)
    contentHost.Size = UDim2.new(1, 0, 1, -84)
    contentHost.BackgroundTransparency = 1
    contentHost.ClipsDescendants = true
    contentHost.Parent = win

    closeBtn.MouseButton1Click:Connect(function()
        tween(win, {
            Size = UDim2.fromOffset(math.floor(width * 0.9), math.floor(height * 0.9)),
            BackgroundTransparency = 1,
        }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.32, function()
            screen:Destroy()
        end)
    end)

    minBtn.MouseButton1Click:Connect(function()
        isMin = not isMin
        if isMin then
            tabStrip.Visible = false
            contentHost.Visible = false
            tween(win, { Size = UDim2.fromOffset(width, 48) }, 0.35)
        else
            tween(win, { Size = fullSize }, 0.35)
            task.delay(0.2, function()
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
    }

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
        corner(btn, 6)

        local page = Instance.new("ScrollingFrame")
        page.Name = name
        page.Size = UDim2.fromScale(1, 1)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = T.accent
        page.ScrollBarImageTransparency = 0.5
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Visible = false
        page.Parent = contentHost

        local list = Instance.new("UIListLayout")
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Padding = UDim.new(0, 8)
        list.Parent = page
        padding(page, 12, 12, 14, 14)
        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 24)
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
            btn.BackgroundTransparency = 0.15
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
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 0, 20)
            lbl.Font = Enum.Font.GothamBold
            lbl.Text = secOpts.Name or "Section"
            lbl.TextSize = 12
            lbl.TextColor3 = T.text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.LayoutOrder = self._order
            lbl.Parent = page
            return lbl
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
            }
        end

        function Tab:CreateButton(btnOpts)
            btnOpts = btnOpts or {}
            self._order = self._order + 1
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 34)
            b.BackgroundColor3 = T.bg2
            b.BorderSizePixel = 0
            b.Font = Enum.Font.GothamMedium
            b.Text = btnOpts.Name or "Button"
            b.TextSize = 12
            b.TextColor3 = T.text
            b.AutoButtonColor = false
            b.LayoutOrder = self._order
            b.Parent = page
            corner(b, 8)
            stroke(b, T.border, 1, 0.55)
            b.MouseEnter:Connect(function()
                tween(b, { BackgroundColor3 = T.bg3 }, 0.12)
            end)
            b.MouseLeave:Connect(function()
                tween(b, { BackgroundColor3 = T.bg2 }, 0.12)
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
            row.Size = UDim2.new(1, 0, 0, 44)
            row.BackgroundColor3 = T.bg1
            row.BackgroundTransparency = 0.25
            row.BorderSizePixel = 0
            row.LayoutOrder = self._order
            row.Parent = page
            corner(row, 8)
            stroke(row, T.border, 1, 0.65)

            local name = Instance.new("TextLabel")
            name.BackgroundTransparency = 1
            name.Position = UDim2.fromOffset(12, 6)
            name.Size = UDim2.new(1, -70, 0, 16)
            name.Font = Enum.Font.GothamMedium
            name.Text = togOpts.Name or "Toggle"
            name.TextSize = 12
            name.TextColor3 = T.text
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Parent = row

            local desc = Instance.new("TextLabel")
            desc.BackgroundTransparency = 1
            desc.Position = UDim2.fromOffset(12, 24)
            desc.Size = UDim2.new(1, -70, 0, 14)
            desc.Font = Enum.Font.Gotham
            desc.Text = togOpts.Description or togOpts.Desc or ""
            desc.TextSize = 10
            desc.TextColor3 = T.text3
            desc.TextXAlignment = Enum.TextXAlignment.Left
            desc.TextTruncate = Enum.TextTruncate.AtEnd
            desc.Parent = row

            local track = Instance.new("Frame")
            track.AnchorPoint = Vector2.new(1, 0.5)
            track.Position = UDim2.new(1, -12, 0.5, 0)
            track.Size = UDim2.fromOffset(40, 22)
            track.BackgroundColor3 = state and T.accent or T.bg3
            track.BorderSizePixel = 0
            track.Parent = row
            corner(track, 11)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.fromOffset(16, 16)
            knob.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            knob.BackgroundColor3 = state and Color3.fromRGB(10, 10, 10) or T.text
            knob.BorderSizePixel = 0
            knob.Parent = track
            corner(knob, 8)

            local hit = Instance.new("TextButton")
            hit.Size = UDim2.fromScale(1, 1)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.Parent = row

            local function set(v, fire)
                state = v and true or false
                if flag then N0IR.Flags[flag] = state end
                tween(track, { BackgroundColor3 = state and T.accent or T.bg3 }, 0.18)
                tween(knob, {
                    Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                    BackgroundColor3 = state and Color3.fromRGB(10, 10, 10) or T.text,
                }, 0.18)
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
            row.Size = UDim2.new(1, 0, 0, 56)
            row.BackgroundColor3 = T.bg1
            row.BackgroundTransparency = 0.25
            row.BorderSizePixel = 0
            row.LayoutOrder = self._order
            row.Parent = page
            corner(row, 8)
            stroke(row, T.border, 1, 0.65)

            local name = Instance.new("TextLabel")
            name.BackgroundTransparency = 1
            name.Position = UDim2.fromOffset(12, 8)
            name.Size = UDim2.new(0.7, 0, 0, 14)
            name.Font = Enum.Font.GothamMedium
            name.Text = slOpts.Name or "Slider"
            name.TextSize = 12
            name.TextColor3 = T.text
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Parent = row

            local valLbl = Instance.new("TextLabel")
            valLbl.BackgroundTransparency = 1
            valLbl.Position = UDim2.new(1, -60, 0, 8)
            valLbl.Size = UDim2.fromOffset(48, 14)
            valLbl.Font = Enum.Font.Code
            valLbl.Text = tostring(value)
            valLbl.TextSize = 11
            valLbl.TextColor3 = T.text2
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = row

            local track = Instance.new("Frame")
            track.Position = UDim2.fromOffset(12, 34)
            track.Size = UDim2.new(1, -24, 0, 6)
            track.BackgroundColor3 = T.bg3
            track.BorderSizePixel = 0
            track.Parent = row
            corner(track, 3)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.fromScale(math.clamp((value - minV) / math.max(maxV - minV, 1e-4), 0, 1), 1)
            fill.BackgroundColor3 = T.accent
            fill.BorderSizePixel = 0
            fill.Parent = track
            corner(fill, 3)

            local function apply(v, fire)
                value = math.clamp(v, minV, maxV)
                if slOpts.Increment then
                    value = math.floor(value / slOpts.Increment + 0.5) * slOpts.Increment
                end
                if flag then N0IR.Flags[flag] = value end
                local pct = (value - minV) / math.max(maxV - minV, 1e-4)
                fill.Size = UDim2.fromScale(pct, 1)
                valLbl.Text = string.format(slOpts.Increment and slOpts.Increment < 1 and "%.2f" or "%.0f", value)
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
            UserInputService.InputChanged:Connect(function(input)
                if not dragging then return end
                if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                    local pct = math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
                    apply(minV + pct * (maxV - minV))
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

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
            row.Size = UDim2.new(1, 0, 0, 40)
            row.BackgroundColor3 = T.bg1
            row.BackgroundTransparency = 0.25
            row.BorderSizePixel = 0
            row.LayoutOrder = self._order
            row.ClipsDescendants = true
            row.Parent = page
            corner(row, 8)
            stroke(row, T.border, 1, 0.65)

            local name = Instance.new("TextLabel")
            name.BackgroundTransparency = 1
            name.Position = UDim2.fromOffset(12, 0)
            name.Size = UDim2.new(0.4, 0, 0, 40)
            name.Font = Enum.Font.GothamMedium
            name.Text = ddOpts.Name or "Dropdown"
            name.TextSize = 12
            name.TextColor3 = T.text
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Parent = row

            local val = Instance.new("TextLabel")
            val.BackgroundTransparency = 1
            val.Position = UDim2.new(0.4, 0, 0, 0)
            val.Size = UDim2.new(0.5, -10, 0, 40)
            val.Font = Enum.Font.Gotham
            val.Text = tostring(current)
            val.TextSize = 11
            val.TextColor3 = T.text2
            val.TextXAlignment = Enum.TextXAlignment.Right
            val.Parent = row

            local arrow = Instance.new("TextLabel")
            arrow.BackgroundTransparency = 1
            arrow.Position = UDim2.new(1, -28, 0, 0)
            arrow.Size = UDim2.fromOffset(20, 40)
            arrow.Font = Enum.Font.GothamBold
            arrow.Text = "▾"
            arrow.TextSize = 12
            arrow.TextColor3 = T.text3
            arrow.Parent = row

            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(1, 0, 0, 40)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.Parent = row

            local listFrame = Instance.new("Frame")
            listFrame.Position = UDim2.fromOffset(8, 40)
            listFrame.Size = UDim2.new(1, -16, 0, 0)
            listFrame.BackgroundTransparency = 1
            listFrame.Parent = row

            local function rebuild()
                for _, ch in ipairs(listFrame:GetChildren()) do ch:Destroy() end
                local y = 0
                for i, opt in ipairs(options) do
                    local ob = Instance.new("TextButton")
                    ob.Position = UDim2.fromOffset(0, y)
                    ob.Size = UDim2.new(1, 0, 0, 26)
                    ob.BackgroundColor3 = T.bg2
                    ob.BorderSizePixel = 0
                    ob.Font = Enum.Font.Gotham
                    ob.Text = "  " .. tostring(opt)
                    ob.TextSize = 11
                    ob.TextColor3 = (opt == current) and T.text or T.text2
                    ob.TextXAlignment = Enum.TextXAlignment.Left
                    ob.AutoButtonColor = false
                    ob.Parent = listFrame
                    corner(ob, 5)
                    ob.MouseButton1Click:Connect(function()
                        current = opt
                        if flag then N0IR.Flags[flag] = current end
                        val.Text = tostring(current)
                        if ddOpts.Callback then task.spawn(ddOpts.Callback, current) end
                        open = false
                        tween(row, { Size = UDim2.new(1, 0, 0, 40) }, 0.2)
                        listFrame.Size = UDim2.new(1, -16, 0, 0)
                    end)
                    y = y + 28
                end
                return y
            end

            hit.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    local h = rebuild()
                    tween(row, { Size = UDim2.new(1, 0, 0, 40 + h + 8) }, 0.22)
                    listFrame.Size = UDim2.new(1, -16, 0, h)
                else
                    tween(row, { Size = UDim2.new(1, 0, 0, 40) }, 0.2)
                    listFrame.Size = UDim2.new(1, -16, 0, 0)
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
            row.Size = UDim2.new(1, 0, 0, 40)
            row.BackgroundColor3 = T.bg1
            row.BackgroundTransparency = 0.25
            row.BorderSizePixel = 0
            row.LayoutOrder = self._order
            row.Parent = page
            corner(row, 8)
            stroke(row, T.border, 1, 0.65)

            local name = Instance.new("TextLabel")
            name.BackgroundTransparency = 1
            name.Position = UDim2.fromOffset(12, 0)
            name.Size = UDim2.new(0.35, 0, 1, 0)
            name.Font = Enum.Font.GothamMedium
            name.Text = inOpts.Name or "Input"
            name.TextSize = 12
            name.TextColor3 = T.text
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Parent = row

            local box = Instance.new("TextBox")
            box.Position = UDim2.new(0.38, 0, 0.5, -12)
            box.Size = UDim2.new(0.6, -12, 0, 24)
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
            corner(box, 6)
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
            lbl.BackgroundTransparency = 0.35
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
            corner(lbl, 8)
            padding(lbl, 10, 10, 12, 12)
            return lbl
        end

        return Tab
    end

    function Window:Destroy()
        screen:Destroy()
    end

    -- Toggle keybind (default M)
    local toggleKey = opts.ToggleKey or Enum.KeyCode.M
    if type(toggleKey) == "string" then
        pcall(function() toggleKey = Enum.KeyCode[toggleKey] end)
    end
    _G._N0IR_ToggleKey = toggleKey
    Window.ToggleKey = toggleKey

    local function setWindowVisible(vis)
        if vis then
            screen.Enabled = true
            win.Visible = true
            win.BackgroundTransparency = 1
            win.Size = UDim2.fromOffset(math.floor(width * 0.94), math.floor(height * 0.94))
            tween(win, {
                Size = UDim2.fromOffset(width, height),
                BackgroundTransparency = 0.04,
            }, 0.35)
        else
            tween(win, {
                Size = UDim2.fromOffset(math.floor(width * 0.92), math.floor(height * 0.92)),
                BackgroundTransparency = 1,
            }, 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.delay(0.3, function()
                win.Visible = false
            end)
        end
    end

    Window.SetVisible = setWindowVisible
    Window.Toggle = function()
        setWindowVisible(not win.Visible)
    end

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if UserInputService:GetFocusedTextBox() then return end
        local key = _G._N0IR_ToggleKey or Enum.KeyCode.M
        if input.KeyCode == key then
            Window.Toggle()
        end
    end)

    table.insert(self._windows, Window)
    return Window
end

-- ============================================================
-- UTILITY MODULES (baseplate, cmds) — no reanim dependency
-- ============================================================
function N0IR:MountUtilities(Window)
    -- ---------- Home ----------
    local Home = Window:CreateTab({ Name = "Home" })
    Home:CreateSection("Welcome")
    Home:CreateParagraph({
        Content = "NØIR Suite  ·  v" .. N0IR.Version .. "\nClean black & white hub. Modules load from the tabs below — World, Player, Commands, Map, Social.",
    })

    Home:CreateSection("Quick actions")
    Home:CreateButton({
        Name = "Notify test",
        Callback = function()
            N0IR:Notify({ Title = "NØIR", Content = "Everything is running.", Duration = 2 })
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
            if part:IsA("BasePart") then
                pcall(function() part.Material = Enum.Material.Grass end)
            end
            N0IR:Notify({ Title = "Baseplate", Content = label or "Color applied", Duration = 1.4 })
        else
            -- terrain fallback
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

    local infConn = nil
    local infPart = nil
    World:CreateToggle({
        Name = "Auto Infinite Baseplate",
        Description = "Invisible floor that follows you (auto-runs when enabled)",
        Flag = "AutoInfBaseplate",
        Default = false,
        Callback = function(on)
            if infConn then infConn:Disconnect(); infConn = nil end
            if not on then
                if infPart then infPart:Destroy(); infPart = nil end
                N0IR:Notify({ Title = "Inf Baseplate", Content = "Off", Duration = 1.2 })
                return
            end
            local cam = workspace.CurrentCamera
            if cam:FindFirstChild("N0IR_InfBaseplate") then
                infPart = cam:FindFirstChild("N0IR_InfBaseplate")
            else
                infPart = Instance.new("Part")
                infPart.Name = "N0IR_InfBaseplate"
                infPart.Anchored = true
                infPart.CanCollide = true
                infPart.Transparency = 1
                infPart.Size = Vector3.new(2048, 1, 2048)
                infPart.Parent = cam
            end
            infConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and infPart then
                    infPart.CFrame = CFrame.new(hrp.Position.X, -0.5, hrp.Position.Z)
                end
            end)
            N0IR:Notify({ Title = "Inf Baseplate", Content = "On", Duration = 1.2 })
        end,
    })

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
            N0IR:Notify({ Title = "Anims", Content = "No character", Duration = 2 })
            return false
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local animate = char:FindFirstChild("Animate")
        if not animate then
            N0IR:Notify({ Title = "Anims", Content = "Animate script not found (need R15)", Duration = 2.5 })
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
                N0IR:Notify({ Title = "Anims", Content = "Unknown pack", Duration = 2 })
                return
            end
            if applyPackIds(ids) then
                N0IR:Notify({ Title = "Anims", Content = selectedPack .. " applied", Duration = 2 })
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
                N0IR:Notify({ Title = "Anims", Content = "Custom slots applied", Duration = 2 })
            end
        end,
    })

    Anims:CreateButton({
        Name = "Reset to default animations",
        Callback = function()
            if applyPackIds(DEFAULT_ANIMS) then
                for k, v in pairs(DEFAULT_ANIMS) do
                    customSlots[k] = v
                end
                for key, inp in pairs(slotInputs) do
                    if inp and inp.Set and DEFAULT_ANIMS[key] then
                        inp:Set(tostring(DEFAULT_ANIMS[key]))
                    end
                end
                updateSlotLabel()
                N0IR:Notify({ Title = "Anims", Content = "Reset to default", Duration = 2 })
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
                    N0IR:Notify({ Title = "Anims", Content = "Could not load bundle", Duration = 2 })
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
                N0IR:Notify({ Title = "Anims", Content = (details.name or name) .. " loaded into slots", Duration = 2 })
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
                    N0IR:Notify({ Title = "Anims", Content = "No results / request failed", Duration = 2.5 })
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
                N0IR:Notify({ Title = "Anims", Content = tostring(#resultNames) .. " packs found", Duration = 2 })
            end)
        end,
    })

    Anims:CreateButton({
        Name = "Apply selected search result",
        Callback = function()
            if applyPackIds(customSlots) then
                N0IR:Notify({ Title = "Anims", Content = "Applied custom / search slots", Duration = 2 })
            end
        end,
    })

    -- ---------- Commands tab ----------
    local Cmds = Window:CreateTab({ Name = "Commands" })
    Cmds:CreateSection("Runner")
    Cmds:CreateParagraph({
        Content = "Click Run on any command. Commands that need a value show an input. Empty required args → notification. Chat prefix and cmd-bar key are configurable in Settings.",
    })

    -- Shared config (also written from Settings)
    local prefix = tostring(_G._N0IR_CmdPrefix or ";")
    local cmdBarKey = _G._N0IR_CmdBarKey or Enum.KeyCode.Semicolon
    local menuToggleKey = _G._N0IR_ToggleKey or Enum.KeyCode.M

    local flying = false
    local flyConn = nil
    local spinConn = nil
    local orbitConn = nil
    local espFolder = nil
    local godConn = nil

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

    local function getChar()
        return LocalPlayer.Character
    end
    local function getHum()
        local c = getChar()
        return c and c:FindFirstChildOfClass("Humanoid")
    end
    local function getHRP()
        local c = getChar()
        return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
    end

    local function notify(title, content, dur)
        N0IR:Notify({ Title = title, Content = content or "", Duration = dur or 1.8 })
    end

    -- ===================== COMMAND IMPLEMENTATIONS =====================
    local function runCmd(msg)
        msg = tostring(msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
        if msg == "" then return end
        -- strip configured prefix if present
        if msg:sub(1, #prefix) == prefix:lower() then
            msg = msg:sub(#prefix + 1):gsub("^%s+", "")
        end
        local args = {}
        for w in msg:gmatch("%S+") do table.insert(args, w) end
        local cmd = args[1]
        if not cmd then return end

        local char = getChar()
        local hum = getHum()
        local hrp = getHRP()

        if cmd == "ws" or cmd == "speed" or cmd == "walkspeed" then
            local v = tonumber(args[2])
            if not v then notify("WalkSpeed", "Need a number"); return end
            if hum then hum.WalkSpeed = v; notify("WalkSpeed", tostring(v)) end

        elseif cmd == "jp" or cmd == "jumppower" or cmd == "jump" then
            local v = tonumber(args[2])
            if not v then notify("JumpPower", "Need a number"); return end
            if hum then
                pcall(function() hum.UseJumpPower = true end)
                hum.JumpPower = v
                pcall(function() hum.JumpHeight = v / 3.5 end)
                notify("JumpPower", tostring(v))
            end

        elseif cmd == "hh" or cmd == "hipheight" then
            local v = tonumber(args[2])
            if not v then notify("HipHeight", "Need a number"); return end
            if hum then hum.HipHeight = v; notify("HipHeight", tostring(v)) end

        elseif cmd == "goto" or cmd == "to" then
            local t = findPlayer(args[2])
            if not t then notify("Goto", "Player not found — set argument"); return end
            if t.Character and t.Character:FindFirstChild("HumanoidRootPart") and hrp then
                hrp.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                notify("Goto", t.Name)
            end

        elseif cmd == "bring" then
            local t = findPlayer(args[2])
            if not t then notify("Bring", "Player not found — set argument"); return end
            if t.Character and t.Character:FindFirstChild("HumanoidRootPart") and hrp then
                t.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0, 0, -3)
                notify("Bring", t.Name)
            end

        elseif cmd == "view" or cmd == "spectate" then
            local t = findPlayer(args[2])
            if not t then notify("View", "Player not found — set argument"); return end
            if t.Character and t.Character:FindFirstChildOfClass("Humanoid") then
                workspace.CurrentCamera.CameraSubject = t.Character:FindFirstChildOfClass("Humanoid")
                notify("View", t.Name)
            end

        elseif cmd == "unview" then
            if hum then
                workspace.CurrentCamera.CameraSubject = hum
                notify("View", "Reset")
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
            notify("Noclip", "ON")

        elseif cmd == "clip" then
            _G._N0IR_NoclipOn = false
            N0IR.Flags.Noclip = false
            local c = LocalPlayer.Character
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
            notify("Noclip", "OFF")

        elseif cmd == "fly" then
            if flying then notify("Fly", "Already on — use unfly"); return end
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
            notify("Fly", "ON  ·  speed " .. tostring(speed))

        elseif cmd == "unfly" then
            flying = false
            if flyConn then flyConn:Disconnect(); flyConn = nil end
            if hrp then
                local f = hrp:FindFirstChild("N0IR_FlyBV")
                if f then f:Destroy() end
            end
            notify("Fly", "OFF")

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

        elseif cmd == "reset" or cmd == "respawn" or cmd == "killme" then
            if hum then hum.Health = 0 end

        elseif cmd == "sit" then
            if hum then hum.Sit = true end
        elseif cmd == "unsit" then
            if hum then hum.Sit = false end

        elseif cmd == "fps" or cmd == "fpscap" then
            local n = tonumber(args[2])
            if not n then notify("FPS Cap", "Need a number"); return end
            pcall(function() if setfpscap then setfpscap(n) end end)
            notify("FPS Cap", tostring(n))

        elseif cmd == "fov" then
            local n = tonumber(args[2])
            if not n then notify("FOV", "Need a number"); return end
            workspace.CurrentCamera.FieldOfView = n
            notify("FOV", tostring(n))

        elseif cmd == "gravity" then
            local n = tonumber(args[2])
            if not n then notify("Gravity", "Need a number"); return end
            workspace.Gravity = n
            notify("Gravity", tostring(n))

        elseif cmd == "time" or cmd == "clocktime" then
            local n = tonumber(args[2])
            if not n then notify("Time", "Need a number 0-24"); return end
            game:GetService("Lighting").ClockTime = n
            notify("Time", tostring(n))

        elseif cmd == "day" then
            game:GetService("Lighting").ClockTime = 14
            notify("Time", "Day")
        elseif cmd == "night" then
            game:GetService("Lighting").ClockTime = 0
            notify("Time", "Night")

        elseif cmd == "fullbright" or cmd == "fb" then
            local L = game:GetService("Lighting")
            L.Brightness = 2
            L.ClockTime = 14
            L.FogEnd = 100000
            L.GlobalShadows = false
            L.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            notify("Fullbright", "ON")

        elseif cmd == "nofog" then
            game:GetService("Lighting").FogEnd = 100000
            notify("Fog", "Cleared")

        elseif cmd == "esp" then
            if espFolder then espFolder:Destroy(); espFolder = nil end
            espFolder = Instance.new("Folder")
            espFolder.Name = "N0IR_ESP"
            espFolder.Parent = getHost()
            local function addEsp(plr)
                if plr == LocalPlayer then return end
                local function attach()
                    local c = plr.Character
                    if not c then return end
                    local h = c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
                    if not h then return end
                    local bb = Instance.new("BillboardGui")
                    bb.Name = plr.Name
                    bb.AlwaysOnTop = true
                    bb.Size = UDim2.fromOffset(120, 30)
                    bb.StudsOffset = Vector3.new(0, 2.5, 0)
                    bb.Adornee = h
                    bb.Parent = espFolder
                    local tl = Instance.new("TextLabel")
                    tl.Size = UDim2.fromScale(1, 1)
                    tl.BackgroundTransparency = 1
                    tl.Text = plr.DisplayName
                    tl.TextColor3 = Color3.new(1, 1, 1)
                    tl.TextStrokeTransparency = 0.4
                    tl.Font = Enum.Font.GothamBold
                    tl.TextSize = 12
                    tl.Parent = bb
                end
                attach()
                plr.CharacterAdded:Connect(function() task.wait(0.5); attach() end)
            end
            for _, p in ipairs(Players:GetPlayers()) do addEsp(p) end
            Players.PlayerAdded:Connect(addEsp)
            notify("ESP", "ON")

        elseif cmd == "unesp" or cmd == "noesp" then
            if espFolder then espFolder:Destroy(); espFolder = nil end
            notify("ESP", "OFF")

        elseif cmd == "god" then
            if godConn then godConn:Disconnect() end
            godConn = RunService.Heartbeat:Connect(function()
                local h = getHum()
                if h then h.Health = h.MaxHealth end
            end)
            notify("God", "ON")
        elseif cmd == "ungod" then
            if godConn then godConn:Disconnect(); godConn = nil end
            notify("God", "OFF")

        elseif cmd == "invisible" or cmd == "invis" then
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") or p:IsA("Decal") then
                        p.Transparency = 1
                    elseif p:IsA("ParticleEmitter") or p:IsA("Trail") then
                        p.Enabled = false
                    end
                end
                notify("Invisible", "ON (local)")
            end
        elseif cmd == "visible" or cmd == "vis" then
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                        p.Transparency = 0
                    elseif p:IsA("Decal") then
                        p.Transparency = 0
                    end
                end
                notify("Visible", "ON")
            end

        elseif cmd == "freeze" then
            local t = findPlayer(args[2]) or LocalPlayer
            local th = t.Character and t.Character:FindFirstChild("HumanoidRootPart")
            if th then th.Anchored = true; notify("Freeze", t.Name) else notify("Freeze", "No target") end
        elseif cmd == "thaw" or cmd == "unfreeze" then
            local t = findPlayer(args[2]) or LocalPlayer
            local th = t.Character and t.Character:FindFirstChild("HumanoidRootPart")
            if th then th.Anchored = false; notify("Thaw", t.Name) end

        elseif cmd == "fling" then
            local t = findPlayer(args[2])
            if not t or not t.Character then notify("Fling", "Player not found"); return end
            local thrp = t.Character:FindFirstChild("HumanoidRootPart")
            if not thrp or not hrp then return end
            local bv = Instance.new("BodyAngularVelocity")
            bv.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            bv.AngularVelocity = Vector3.new(0, 9e4, 0)
            bv.Parent = thrp
            task.delay(0.4, function() if bv then bv:Destroy() end end)
            notify("Fling", t.Name)

        elseif cmd == "spin" then
            local spd = tonumber(args[2]) or 20
            if spinConn then spinConn:Disconnect() end
            if not hrp then return end
            local bav = Instance.new("BodyAngularVelocity")
            bav.Name = "N0IR_Spin"
            bav.MaxTorque = Vector3.new(0, math.huge, 0)
            bav.AngularVelocity = Vector3.new(0, spd, 0)
            bav.Parent = hrp
            spinConn = RunService.Heartbeat:Connect(function()
                if not hrp or not hrp.Parent then if spinConn then spinConn:Disconnect() end end
            end)
            notify("Spin", "ON · " .. tostring(spd))
        elseif cmd == "unspin" then
            if spinConn then spinConn:Disconnect(); spinConn = nil end
            if hrp then local s = hrp:FindFirstChild("N0IR_Spin"); if s then s:Destroy() end end
            notify("Spin", "OFF")

        elseif cmd == "orbit" then
            local t = findPlayer(args[2])
            if not t then notify("Orbit", "Player not found"); return end
            local rad = tonumber(args[3]) or 8
            if orbitConn then orbitConn:Disconnect() end
            local a = 0
            orbitConn = RunService.RenderStepped:Connect(function(dt)
                local thrp = t.Character and t.Character:FindFirstChild("HumanoidRootPart")
                local me = getHRP()
                if not thrp or not me then return end
                a = a + dt * 2
                me.CFrame = CFrame.new(thrp.Position + Vector3.new(math.cos(a) * rad, 2, math.sin(a) * rad))
            end)
            notify("Orbit", t.Name)
        elseif cmd == "unorbit" then
            if orbitConn then orbitConn:Disconnect(); orbitConn = nil end
            notify("Orbit", "OFF")

        elseif cmd == "tppos" or cmd == "tp" then
            local x, y, z = tonumber(args[2]), tonumber(args[3]), tonumber(args[4])
            if not (x and y and z) then notify("TP", "Need x y z"); return end
            if hrp then hrp.CFrame = CFrame.new(x, y, z); notify("TP", string.format("%.1f %.1f %.1f", x, y, z)) end

        elseif cmd == "tools" or cmd == "btools" then
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            if not backpack then return end
            for _, name in ipairs({"Move", "Clone", "Delete"}) do
                local t = Instance.new("HopperBin")
                t.BinType = Enum.BinType[name] or Enum.BinType.Script
                t.Name = name
                t.Parent = backpack
            end
            -- fallback classic handles
            pcall(function()
                local function make(n)
                    local tool = Instance.new("Tool")
                    tool.RequiresHandle = false
                    tool.Name = n
                    tool.Parent = backpack
                end
                make("N0IR_Move")
            end)
            notify("Tools", "Given")

        elseif cmd == "clear" or cmd == "clr" then
            pcall(function()
                for _, g in ipairs(getHost():GetChildren()) do
                    if g.Name:find("N0IR_") and g.Name ~= "N0IR_Window" and g.Name ~= "N0IR_CmdBar" then
                        g:Destroy()
                    end
                end
            end)
            notify("Clear", "Done")

        elseif cmd == "refresh" or cmd == "re" then
            local hum2 = getHum()
            if hum2 then hum2.Health = 0 end
            notify("Refresh", "Respawning")

        elseif cmd == "notify" or cmd == "say" then
            local text = table.concat(args, " ", 2)
            if text == "" then notify("Say", "Need text"); return end
            notify("Message", text, 3)


        elseif cmd == "infinitejump" or cmd == "infjump" then
            if _G._N0IR_InfJumpConn then _G._N0IR_InfJumpConn:Disconnect() end
            _G._N0IR_InfJumpOn = true
            _G._N0IR_InfJumpConn = UserInputService.JumpRequest:Connect(function()
                if not _G._N0IR_InfJumpOn then return end
                local h = getHum()
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
            notify("InfJump", "ON")
        elseif cmd == "uninfinitejump" or cmd == "uninfjump" then
            _G._N0IR_InfJumpOn = false
            if _G._N0IR_InfJumpConn then _G._N0IR_InfJumpConn:Disconnect(); _G._N0IR_InfJumpConn = nil end
            notify("InfJump", "OFF")

        elseif cmd == "clicktp" or cmd == "ctp" then
            if _G._N0IR_ClickTPConn then _G._N0IR_ClickTPConn:Disconnect() end
            _G._N0IR_ClickTPOn = true
            _G._N0IR_ClickTPConn = UserInputService.InputBegan:Connect(function(inp, gp)
                if gp or not _G._N0IR_ClickTPOn then return end
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    local m = LocalPlayer:GetMouse()
                    local me = getHRP()
                    if me and m.Hit then me.CFrame = CFrame.new(m.Hit.Position + Vector3.new(0, 3, 0)) end
                end
            end)
            notify("ClickTP", "ON — click to teleport")
        elseif cmd == "unclicktp" or cmd == "unctp" then
            _G._N0IR_ClickTPOn = false
            if _G._N0IR_ClickTPConn then _G._N0IR_ClickTPConn:Disconnect(); _G._N0IR_ClickTPConn = nil end
            notify("ClickTP", "OFF")

        elseif cmd == "platformstand" or cmd == "plat" then
            local h = getHum()
            if h then h.PlatformStand = true; notify("PlatformStand", "ON") end
        elseif cmd == "unplatformstand" or cmd == "unplat" then
            local h = getHum()
            if h then h.PlatformStand = false; notify("PlatformStand", "OFF") end

        elseif cmd == "xray" then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsDescendantOf(LocalPlayer.Character or workspace) then
                    pcall(function()
                        if not v:GetAttribute("N0IR_XRayOrig") then
                            v:SetAttribute("N0IR_XRayOrig", v.LocalTransparencyModifier)
                        end
                        v.LocalTransparencyModifier = 0.7
                    end)
                end
            end
            notify("XRay", "ON")
        elseif cmd == "unxray" then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v:GetAttribute("N0IR_XRayOrig") ~= nil then
                    pcall(function()
                        v.LocalTransparencyModifier = v:GetAttribute("N0IR_XRayOrig")
                        v:SetAttribute("N0IR_XRayOrig", nil)
                    end)
                end
            end
            notify("XRay", "OFF")

        elseif cmd == "brightness" then
            local n = tonumber(args[2])
            if not n then notify("Brightness", "Need a number"); return end
            game:GetService("Lighting").Brightness = n
            notify("Brightness", tostring(n))
        elseif cmd == "ambient" then
            local r,g,b = tonumber(args[2]), tonumber(args[3]), tonumber(args[4])
            if not (r and g and b) then notify("Ambient", "Need r g b 0-255"); return end
            game:GetService("Lighting").Ambient = Color3.fromRGB(r,g,b)
            notify("Ambient", string.format("%d %d %d", r,g,b))
        elseif cmd == "exposure" then
            local n = tonumber(args[2])
            if not n then notify("Exposure", "Need a number"); return end
            game:GetService("Lighting").ExposureCompensation = n
            notify("Exposure", tostring(n))

        elseif cmd == "loopws" then
            local v = tonumber(args[2])
            if not v then notify("LoopWS", "Need a number"); return end
            if _G._N0IR_LoopWS then _G._N0IR_LoopWS:Disconnect() end
            _G._N0IR_LoopWS = RunService.Heartbeat:Connect(function()
                local h = getHum(); if h then h.WalkSpeed = v end
            end)
            notify("LoopWS", tostring(v))
        elseif cmd == "unloopws" then
            if _G._N0IR_LoopWS then _G._N0IR_LoopWS:Disconnect(); _G._N0IR_LoopWS = nil end
            notify("LoopWS", "OFF")
        elseif cmd == "loopjp" then
            local v = tonumber(args[2])
            if not v then notify("LoopJP", "Need a number"); return end
            if _G._N0IR_LoopJP then _G._N0IR_LoopJP:Disconnect() end
            _G._N0IR_LoopJP = RunService.Heartbeat:Connect(function()
                local h = getHum()
                if h then pcall(function() h.UseJumpPower = true end); h.JumpPower = v end
            end)
            notify("LoopJP", tostring(v))
        elseif cmd == "unloopjp" then
            if _G._N0IR_LoopJP then _G._N0IR_LoopJP:Disconnect(); _G._N0IR_LoopJP = nil end
            notify("LoopJP", "OFF")

        elseif cmd == "copy" or cmd == "copychar" then
            local t = findPlayer(args[2])
            if not t then notify("Copy", "Player not found"); return end
            pcall(function()
                local desc = t.Character and t.Character:FindFirstChildOfClass("Humanoid") and t.Character.Humanoid:GetAppliedDescription()
                if desc and getHum() then getHum():ApplyDescription(desc) end
            end)
            notify("Copy", t and t.Name or "?")

        elseif cmd == "watch" then
            local t = findPlayer(args[2])
            if not t then notify("Watch", "Player not found"); return end
            if t.Character and t.Character:FindFirstChildOfClass("Humanoid") then
                workspace.CurrentCamera.CameraSubject = t.Character.Humanoid
                notify("Watch", t.Name)
            end

        elseif cmd == "maxzoom" then
            local n = tonumber(args[2])
            if not n then notify("MaxZoom", "Need a number"); return end
            LocalPlayer.CameraMaxZoomDistance = n
            notify("MaxZoom", tostring(n))
        elseif cmd == "minzoom" then
            local n = tonumber(args[2])
            if not n then notify("MinZoom", "Need a number"); return end
            LocalPlayer.CameraMinZoomDistance = n
            notify("MinZoom", tostring(n))

        elseif cmd == "firstperson" or cmd == "fp" then
            LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
            notify("Camera", "First person")
        elseif cmd == "thirdperson" or cmd == "tp3" then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMinZoomDistance = 0.5
            notify("Camera", "Third person")

        elseif cmd == "shiftlock" then
            LocalPlayer.DevEnableMouseLock = true
            notify("ShiftLock", "Enabled (if game allows)")
        elseif cmd == "unlock" then
            pcall(function()
                local h = getHum(); if h then h.Sit = false end
                local me = getHRP(); if me then me.Anchored = false end
            end)
            notify("Unlock", "Done")

        elseif cmd == "antiragdoll" then
            if _G._N0IR_AntiRag then _G._N0IR_AntiRag:Disconnect() end
            _G._N0IR_AntiRag = RunService.Heartbeat:Connect(function()
                local h = getHum()
                if h then
                    h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                    h:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end)
            notify("AntiRagdoll", "ON")
        elseif cmd == "unantiragdoll" then
            if _G._N0IR_AntiRag then _G._N0IR_AntiRag:Disconnect(); _G._N0IR_AntiRag = nil end
            notify("AntiRagdoll", "OFF")

        elseif cmd == "antiafk" or cmd == "anti-afk" then
            if _G._N0IR_AntiAFK then _G._N0IR_AntiAFK:Disconnect() end
            local vu = game:GetService("VirtualUser")
            _G._N0IR_AntiAFK = LocalPlayer.Idled:Connect(function()
                pcall(function()
                    vu:CaptureController()
                    vu:ClickButton2(Vector2.new())
                end)
            end)
            notify("AntiAFK", "ON")

        elseif cmd == "lowgfx" then
            local L = game:GetService("Lighting")
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            L.GlobalShadows = false
            L.FogEnd = 9e9
            for _, v in ipairs(L:GetChildren()) do
                if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") then
                    v.Enabled = false
                end
            end
            notify("GFX", "Low")
        elseif cmd == "highgfx" then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            notify("GFX", "Automatic / high")

        elseif cmd == "volume" then
            local n = tonumber(args[2])
            if not n then notify("Volume", "Need 0-10"); return end
            UserSettings():GetService("UserGameSettings").MasterVolume = math.clamp(n / 10, 0, 1)
            notify("Volume", tostring(n))

        elseif cmd == "annoy" or cmd == "spamchat" then
            local text = table.concat(args, " ", 2)
            if text == "" then notify("Spam", "Need text"); return end
            task.spawn(function()
                for i = 1, 5 do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                        -- soft attempt
                        local ev = game:GetService("TextChatService")
                        if ev and ev.ChatInputBarConfiguration then
                            -- modern chat can't easily spam; just notify
                        end
                    end)
                    task.wait(0.4)
                end
            end)
            notify("Spam", "Attempted (limited by chat API)")

        elseif cmd == "ping" then
            local ok, p = pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString() end)
            notify("Ping", ok and tostring(p) or "n/a")

        elseif cmd == "age" then
            local t = findPlayer(args[2]) or LocalPlayer
            notify("Account age", t.Name .. " · " .. tostring(t.AccountAge) .. " days")

        elseif cmd == "id" or cmd == "userid" then
            local t = findPlayer(args[2]) or LocalPlayer
            notify("UserId", t.Name .. " · " .. tostring(t.UserId))

        elseif cmd == "jobid" then
            notify("JobId", tostring(game.JobId))
        elseif cmd == "placeid" then
            notify("PlaceId", tostring(game.PlaceId))

        elseif cmd == "re" or cmd == "refreshchar" then
            local h = getHum(); if h then h.Health = 0 end

        elseif cmd == "stun" then
            local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Physics); notify("Stun", "ON") end
        elseif cmd == "unstun" then
            local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.RunningNoPhysics); notify("Stun", "OFF") end

        elseif cmd == "swim" then
            local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Swimming); notify("Swim", "state") end

        elseif cmd == "climb" then
            local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Climbing) end

        elseif cmd == "power" or cmd == "super" then
            local h = getHum()
            if h then h.WalkSpeed = 100; h.JumpPower = 120; notify("Power", "boosted") end

        elseif cmd == "normal" or cmd == "defaults" then
            local h = getHum()
            if h then
                h.WalkSpeed = 16; h.JumpPower = 50
                pcall(function() h.JumpHeight = 7.2 end)
                workspace.Gravity = 196.2
                notify("Defaults", "restored")
            end

        elseif cmd == "freezeall" then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local r = p.Character:FindFirstChild("HumanoidRootPart")
                    if r then r.Anchored = true end
                end
            end
            notify("Freeze", "all others")
        elseif cmd == "thawall" then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    local r = p.Character:FindFirstChild("HumanoidRootPart")
                    if r then r.Anchored = false end
                end
            end
            notify("Thaw", "all")

        elseif cmd == "exit" or cmd == "leave" then
            pcall(function() game:Shutdown() end)

        -- ========== ADULT / RP ANIMATION COMMANDS (need player) ==========
        elseif cmd == "headbang" or cmd == "headfuck" or cmd == "bang" or cmd == "fuck"
            or cmd == "suck" or cmd == "blowjob" or cmd == "lickbutt" or cmd == "peg" then
            local t = findPlayer(args[2])
            if not t then
                notify(cmd, "Need a username / display name")
                return
            end
            local thrp = t.Character and t.Character:FindFirstChild("HumanoidRootPart")
            local me = getHRP()
            local myHum = getHum()
            if not thrp or not me or not myHum then
                notify(cmd, "Characters not ready")
                return
            end

            -- stop previous
            if _G._N0IR_AdultConn then _G._N0IR_AdultConn:Disconnect(); _G._N0IR_AdultConn = nil end
            if _G._N0IR_AdultTrack then pcall(function() _G._N0IR_AdultTrack:Stop() end); _G._N0IR_AdultTrack = nil end

            local offsets = {
                headbang = CFrame.new(0, -0.2, -1.1) * CFrame.Angles(math.rad(-20), 0, 0),
                headfuck = CFrame.new(0, -0.2, -1.1) * CFrame.Angles(math.rad(-20), 0, 0),
                bang = CFrame.new(0, 0, -1.2) * CFrame.Angles(math.rad(10), math.rad(180), 0),
                fuck = CFrame.new(0, 0, -1.2) * CFrame.Angles(math.rad(10), math.rad(180), 0),
                suck = CFrame.new(0, -0.9, -0.9) * CFrame.Angles(math.rad(70), 0, 0),
                blowjob = CFrame.new(0, -0.9, -0.9) * CFrame.Angles(math.rad(70), 0, 0),
                lickbutt = CFrame.new(0, -0.7, 1.0) * CFrame.Angles(math.rad(40), math.rad(180), 0),
                peg = CFrame.new(0, 0, 1.15) * CFrame.Angles(0, 0, 0),
            }
            local off = offsets[cmd] or offsets.bang

            -- optional anim assets (R6-ish dance/emote fallbacks — may not load in all games)
            local animIds = {
                headbang = "rbxassetid://5918726674",
                headfuck = "rbxassetid://5918726674",
                bang = "rbxassetid://5918726674",
                fuck = "rbxassetid://5918726674",
                suck = "rbxassetid://698251653",
                blowjob = "rbxassetid://698251653",
                lickbutt = "rbxassetid://698251653",
                peg = "rbxassetid://5918726674",
            }

            pcall(function()
                local animator = myHum:FindFirstChildOfClass("Animator") or myHum
                local anim = Instance.new("Animation")
                anim.AnimationId = animIds[cmd] or animIds.bang
                local track = animator:LoadAnimation(anim)
                track.Looped = true
                track.Priority = Enum.AnimationPriority.Action
                track:Play()
                _G._N0IR_AdultTrack = track
            end)

            local t0 = tick()
            _G._N0IR_AdultConn = RunService.RenderStepped:Connect(function()
                local target = t.Character and t.Character:FindFirstChild("HumanoidRootPart")
                local selfHRP = getHRP()
                if not target or not selfHRP then return end
                -- subtle bob
                local bob = math.sin((tick() - t0) * 10) * 0.04
                selfHRP.CFrame = target.CFrame * off * CFrame.new(0, bob, 0)
            end)
            notify(cmd, "→ " .. t.DisplayName .. "  ·  ;stopadult to cancel")

        elseif cmd == "stopadult" or cmd == "unbang" or cmd == "unfuck" or cmd == "stopanim" then
            if _G._N0IR_AdultConn then _G._N0IR_AdultConn:Disconnect(); _G._N0IR_AdultConn = nil end
            if _G._N0IR_AdultTrack then pcall(function() _G._N0IR_AdultTrack:Stop() end); _G._N0IR_AdultTrack = nil end
            notify("Adult", "stopped")

        elseif cmd == "vcbypass" or cmd == "antivc" or cmd == "vc" then
            if _G._N0IR_EnableVCBypass then
                _G._N0IR_EnableVCBypass()
            else
                notify("VC", "Open VC Bypass tab first / suite not mounted")
            end

        elseif cmd == "cmds" or cmd == "commands" or cmd == "help" then
            -- open / focus Commands tab listing (already visible); also toast
            notify("Commands", "See Commands tab — every cmd has Run + arg box if needed", 3)
            -- ensure window visible
            if Window and Window.Frame then
                Window.Frame.Visible = true
            end
            -- try to activate Commands tab
            for _, t in ipairs(Window.Tabs or {}) do
                if t.Name == "Commands" and t.Button then
                    pcall(function() t.Button:Activate() end)
                    -- simulate click
                    for _, conn in pairs(getconnections and getconnections(t.Button.MouseButton1Click) or {}) do
                        pcall(function() conn:Fire() end)
                    end
                end
            end

        elseif cmd == "prefix" then
            local p = args[2]
            if not p or p == "" then notify("Prefix", "Current: " .. prefix); return end
            prefix = p
            _G._N0IR_CmdPrefix = p
            notify("Prefix", "Set to '" .. p .. "'")

        else
            notify("Unknown", cmd)
        end
    end

    -- Command catalog
    local catalog = {
        { cmd = "ws",        label = "WalkSpeed",     desc = "Set walk speed",              needsArg = true,  example = "50" },
        { cmd = "jp",        label = "JumpPower",     desc = "Set jump power",              needsArg = true,  example = "75" },
        { cmd = "hh",        label = "HipHeight",     desc = "Set hip height",              needsArg = true,  example = "2" },
        { cmd = "loopws",    label = "Loop WalkSpeed", desc = "Force WS every frame",      needsArg = true,  example = "50" },
        { cmd = "unloopws",  label = "Unloop WS",     desc = "Stop loop walkspeed",         needsArg = false },
        { cmd = "loopjp",    label = "Loop JumpPower", desc = "Force JP every frame",      needsArg = true,  example = "75" },
        { cmd = "unloopjp",  label = "Unloop JP",     desc = "Stop loop jumppower",         needsArg = false },
        { cmd = "power",     label = "Power boost",   desc = "WS 100 + JP 120",             needsArg = false },
        { cmd = "normal",    label = "Defaults",      desc = "Reset WS/JP/gravity",         needsArg = false },
        { cmd = "goto",      label = "Goto player",   desc = "Teleport to player",          needsArg = true,  example = "" },
        { cmd = "bring",     label = "Bring player",  desc = "Bring player to you",         needsArg = true,  example = "" },
        { cmd = "tppos",     label = "TP position",   desc = "Teleport to x y z",           needsArg = true,  example = "0 50 0" },
        { cmd = "view",      label = "View player",   desc = "Spectate player",             needsArg = true,  example = "" },
        { cmd = "unview",    label = "Unview",        desc = "Reset camera",                needsArg = false },
        { cmd = "watch",     label = "Watch",         desc = "Camera on player",            needsArg = true,  example = "" },
        { cmd = "noclip",    label = "Noclip",        desc = "Walk through walls",          needsArg = false },
        { cmd = "clip",      label = "Clip",          desc = "Disable noclip",              needsArg = false },
        { cmd = "fly",       label = "Fly",           desc = "Start flying (opt speed)",    needsArg = false, example = "50" },
        { cmd = "unfly",     label = "Unfly",         desc = "Stop flying",                 needsArg = false },
        { cmd = "infjump",   label = "Infinite jump", desc = "Jump mid-air forever",        needsArg = false },
        { cmd = "uninfjump", label = "Uninfjump",     desc = "Disable infinite jump",       needsArg = false },
        { cmd = "clicktp",   label = "Click TP",      desc = "Click to teleport",           needsArg = false },
        { cmd = "unclicktp", label = "Unclick TP",    desc = "Disable click teleport",      needsArg = false },
        { cmd = "rejoin",    label = "Rejoin",        desc = "Rejoin this server",          needsArg = false },
        { cmd = "hop",       label = "Server hop",    desc = "Join a different server",     needsArg = false },
        { cmd = "reset",     label = "Reset",         desc = "Kill / respawn character",    needsArg = false },
        { cmd = "re",        label = "Refresh",       desc = "Respawn character",           needsArg = false },
        { cmd = "sit",       label = "Sit",           desc = "Force sit",                   needsArg = false },
        { cmd = "unsit",     label = "Unsit",         desc = "Stand up",                    needsArg = false },
        { cmd = "plat",      label = "PlatformStand", desc = "Enable platform stand",       needsArg = false },
        { cmd = "unplat",    label = "UnplatformStand", desc = "Disable platform stand",    needsArg = false },
        { cmd = "stun",      label = "Stun",          desc = "Physics stun state",          needsArg = false },
        { cmd = "unstun",    label = "Unstun",        desc = "Clear stun",                  needsArg = false },
        { cmd = "fps",       label = "FPS cap",       desc = "Cap framerate",               needsArg = true,  example = "60" },
        { cmd = "fov",       label = "FOV",           desc = "Camera field of view",        needsArg = true,  example = "90" },
        { cmd = "gravity",   label = "Gravity",       desc = "Workspace gravity",           needsArg = true,  example = "196.2" },
        { cmd = "time",      label = "Clock time",    desc = "Lighting clock 0-24",         needsArg = true,  example = "14" },
        { cmd = "day",       label = "Day",           desc = "Set daytime",                 needsArg = false },
        { cmd = "night",     label = "Night",         desc = "Set nighttime",               needsArg = false },
        { cmd = "fullbright",label = "Fullbright",    desc = "Brighten world",              needsArg = false },
        { cmd = "nofog",     label = "No fog",        desc = "Remove fog",                  needsArg = false },
        { cmd = "brightness",label = "Brightness",    desc = "Lighting brightness",         needsArg = true,  example = "2" },
        { cmd = "ambient",   label = "Ambient",       desc = "Ambient r g b",               needsArg = true,  example = "128 128 128" },
        { cmd = "exposure",  label = "Exposure",      desc = "Exposure compensation",       needsArg = true,  example = "0" },
        { cmd = "xray",      label = "XRay",          desc = "See through parts",           needsArg = false },
        { cmd = "unxray",    label = "UnXRay",        desc = "Disable xray",                needsArg = false },
        { cmd = "lowgfx",    label = "Low GFX",       desc = "Performance graphics",        needsArg = false },
        { cmd = "highgfx",   label = "High GFX",      desc = "Restore quality",             needsArg = false },
        { cmd = "esp",       label = "ESP",           desc = "Name tags on players",        needsArg = false },
        { cmd = "unesp",     label = "No ESP",        desc = "Remove ESP",                  needsArg = false },
        { cmd = "god",       label = "God mode",      desc = "Infinite health",             needsArg = false },
        { cmd = "ungod",     label = "Ungod",         desc = "Disable god",                 needsArg = false },
        { cmd = "invis",     label = "Invisible",     desc = "Local invisibility",          needsArg = false },
        { cmd = "vis",       label = "Visible",       desc = "Restore visibility",          needsArg = false },
        { cmd = "freeze",    label = "Freeze",        desc = "Anchor player (name opt)",    needsArg = false, example = "" },
        { cmd = "thaw",      label = "Thaw",          desc = "Unanchor player",             needsArg = false },
        { cmd = "freezeall", label = "Freeze all",    desc = "Anchor every other player",   needsArg = false },
        { cmd = "thawall",   label = "Thaw all",      desc = "Unanchor everyone",           needsArg = false },
        { cmd = "fling",     label = "Fling",         desc = "Fling a player",              needsArg = true,  example = "" },
        { cmd = "spin",      label = "Spin",          desc = "Spin character (opt speed)",  needsArg = false, example = "20" },
        { cmd = "unspin",    label = "Unspin",        desc = "Stop spin",                   needsArg = false },
        { cmd = "orbit",     label = "Orbit",         desc = "Orbit player · name [r]",     needsArg = true,  example = "" },
        { cmd = "unorbit",   label = "Unorbit",       desc = "Stop orbit",                  needsArg = false },
        { cmd = "copy",      label = "Copy avatar",   desc = "Copy player appearance",      needsArg = true,  example = "" },
        { cmd = "tools",     label = "BTools",        desc = "Give building tools",         needsArg = false },
        { cmd = "clear",     label = "Clear",         desc = "Clear N0IR extras",           needsArg = false },
        { cmd = "antiragdoll", label = "Anti ragdoll", desc = "Block ragdoll states",      needsArg = false },
        { cmd = "unantiragdoll", label = "Un anti-ragdoll", desc = "Allow ragdoll",        needsArg = false },
        { cmd = "antiafk",   label = "Anti AFK",      desc = "Prevent idle kick",           needsArg = false },
        { cmd = "fp",        label = "First person",  desc = "Lock first person",           needsArg = false },
        { cmd = "tp3",       label = "Third person",  desc = "Classic camera",              needsArg = false },
        { cmd = "maxzoom",   label = "Max zoom",      desc = "Camera max zoom distance",    needsArg = true,  example = "128" },
        { cmd = "minzoom",   label = "Min zoom",      desc = "Camera min zoom distance",    needsArg = true,  example = "0.5" },
        { cmd = "shiftlock", label = "Shift lock",    desc = "Enable mouse lock",           needsArg = false },
        { cmd = "unlock",    label = "Unlock",        desc = "Unsit + unanchor self",       needsArg = false },
        { cmd = "volume",    label = "Volume",        desc = "Master volume 0-10",          needsArg = true,  example = "5" },
        { cmd = "ping",      label = "Ping",          desc = "Show data ping",              needsArg = false },
        { cmd = "age",       label = "Account age",   desc = "Days since join (opt name)",  needsArg = false, example = "" },
        { cmd = "id",        label = "UserId",        desc = "Show user id (opt name)",     needsArg = false, example = "" },
        { cmd = "jobid",     label = "JobId",         desc = "Current server job id",       needsArg = false },
        { cmd = "placeid",   label = "PlaceId",       desc = "Current place id",            needsArg = false },
        { cmd = "prefix",    label = "Set prefix",    desc = "Change chat command prefix",  needsArg = true,  example = ";" },
        { cmd = "vcbypass",  label = "VC Bypass",     desc = "Enable NØIR anti-VC",          needsArg = false },
        { cmd = "cmds",      label = "Commands list", desc = "Open / focus this menu",      needsArg = false },
        { cmd = "exit",      label = "Exit game",     desc = "Leave the experience",        needsArg = false },
        -- Adult / RP (require username or display name)
        { cmd = "headbang",  label = "Headbang",      desc = "RP · target player",          needsArg = true,  example = "username" },
        { cmd = "headfuck",  label = "Headfuck",      desc = "RP · target player",          needsArg = true,  example = "username" },
        { cmd = "bang",      label = "Bang",          desc = "RP · target player",          needsArg = true,  example = "username" },
        { cmd = "fuck",      label = "Fuck",          desc = "RP · target player",          needsArg = true,  example = "username" },
        { cmd = "suck",      label = "Suck",          desc = "RP · target player",          needsArg = true,  example = "username" },
        { cmd = "blowjob",   label = "Blowjob",       desc = "RP · target player",          needsArg = true,  example = "username" },
        { cmd = "lickbutt",  label = "Lickbutt",      desc = "RP · target player",          needsArg = true,  example = "username" },
        { cmd = "peg",       label = "Peg",           desc = "RP · target player",          needsArg = true,  example = "username" },
        { cmd = "stopadult", label = "Stop adult",    desc = "Cancel RP attach / anim",     needsArg = false },
    }

    Cmds:CreateSection("All commands")

    local function makeCmdRow(entry)
        Cmds._order = (Cmds._order or 0) + 1
        local page = Cmds.Page
        local rowH = entry.needsArg and 78 or 48
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, rowH)
        row.BackgroundColor3 = T.bg1
        row.BackgroundTransparency = 0.25
        row.BorderSizePixel = 0
        row.LayoutOrder = Cmds._order
        row.Parent = page
        corner(row, 8)
        stroke(row, T.border, 1, 0.65)

        local name = Instance.new("TextLabel")
        name.BackgroundTransparency = 1
        name.Position = UDim2.fromOffset(12, 6)
        name.Size = UDim2.new(1, -90, 0, 16)
        name.Font = Enum.Font.GothamBold
        name.Text = entry.label .. "  ·  " .. prefix .. entry.cmd
        name.TextSize = 12
        name.TextColor3 = T.text
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = row

        local desc = Instance.new("TextLabel")
        desc.BackgroundTransparency = 1
        desc.Position = UDim2.fromOffset(12, 24)
        desc.Size = UDim2.new(1, -90, 0, 16)
        desc.Font = Enum.Font.Gotham
        desc.Text = entry.desc
        desc.TextSize = 10
        desc.TextColor3 = T.text3
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextTruncate = Enum.TextTruncate.AtEnd
        desc.Parent = row

        local argBox
        if entry.needsArg then
            argBox = Instance.new("TextBox")
            argBox.Position = UDim2.fromOffset(12, 44)
            argBox.Size = UDim2.new(1, -100, 0, 24)
            argBox.BackgroundColor3 = T.bg2
            argBox.BorderSizePixel = 0
            argBox.Font = Enum.Font.Gotham
            argBox.PlaceholderText = entry.example ~= "" and ("value  e.g. " .. entry.example) or "argument required"
            argBox.PlaceholderColor3 = T.text3
            argBox.Text = ""
            argBox.TextSize = 11
            argBox.TextColor3 = T.text
            argBox.ClearTextOnFocus = false
            argBox.Parent = row
            corner(argBox, 6)
        end

        local run = Instance.new("TextButton")
        run.AnchorPoint = Vector2.new(1, 0.5)
        run.Position = UDim2.new(1, -10, 0.5, 0)
        run.Size = UDim2.fromOffset(64, 26)
        run.BackgroundColor3 = T.accent
        run.BorderSizePixel = 0
        run.Font = Enum.Font.GothamBold
        run.Text = "Run"
        run.TextSize = 11
        run.TextColor3 = Color3.fromRGB(10, 10, 10)
        run.AutoButtonColor = false
        run.Parent = row
        corner(run, 6)

        run.MouseEnter:Connect(function()
            tween(run, { BackgroundTransparency = 0.15 }, 0.12)
        end)
        run.MouseLeave:Connect(function()
            tween(run, { BackgroundTransparency = 0 }, 0.12)
        end)
        run.MouseButton1Click:Connect(function()
            local arg = ""
            if argBox then
                arg = tostring(argBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
            end
            if entry.needsArg and arg == "" then
                -- allow optional examples only for fly/spin style (needsArg=false for those)
                notify("Argument required", "Put a value in the textbox for " .. entry.label, 2.5)
                return
            end
            local line = entry.cmd
            if arg ~= "" then
                line = entry.cmd .. " " .. arg
            end
            runCmd(line)
        end)
    end

    for _, entry in ipairs(catalog) do
        makeCmdRow(entry)
    end

    -- Chat still works with configured prefix
    pcall(function()
        LocalPlayer.Chatted:Connect(function(msg)
            local low = msg:lower()
            if low:sub(1, #prefix) == prefix:lower() then
                runCmd(msg)
            end
        end)
    end)

    -- Floating command bar
    local cmdGui = Instance.new("ScreenGui")
    cmdGui.Name = "N0IR_CmdBar"
    cmdGui.ResetOnSpawn = false
    cmdGui.DisplayOrder = 200
    cmdGui.Parent = getHost()

    local bar = Instance.new("Frame")
    bar.AnchorPoint = Vector2.new(0.5, 1)
    bar.Position = UDim2.new(0.5, 0, 1, 60)
    bar.Size = UDim2.fromOffset(380, 40)
    bar.BackgroundColor3 = T.bg0
    bar.BackgroundTransparency = 0.08
    bar.BorderSizePixel = 0
    bar.Parent = cmdGui
    corner(bar, 10)
    stroke(bar, T.border, 1, 0.35)

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -24, 1, 0)
    input.Position = UDim2.fromOffset(12, 0)
    input.BackgroundTransparency = 1
    input.Font = Enum.Font.GothamMedium
    input.PlaceholderText = "command  ·  press key to open"
    input.PlaceholderColor3 = T.text3
    input.Text = ""
    input.TextSize = 13
    input.TextColor3 = T.text
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.ClearTextOnFocus = false
    input.Parent = bar

    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        local key = _G._N0IR_CmdBarKey or cmdBarKey
        if inp.KeyCode == key then
            task.defer(function()
                input:CaptureFocus()
                input.Text = ""
                tween(bar, { Position = UDim2.new(0.5, 0, 1, -18) }, 0.3)
            end)
        end
    end)

    input.FocusLost:Connect(function(enter)
        tween(bar, { Position = UDim2.new(0.5, 0, 1, 60) }, 0.3)
        if enter and input.Text ~= "" then
            local t = input.Text
            runCmd(t)
        end
        input.Text = ""
    end)

    Cmds:CreateLabel("Tip  ·  open cmd bar with your keybind (Settings) · type cmds to focus this list")

    -- ---------- VC Bypass (NØIR) ----------
    local VC = Window:CreateTab({ Name = "VC Bypass" })
    VC:CreateSection("NØIR Voice Chat Bypass")
    VC:CreateParagraph({
        Content = "Native NØIR anti-VC built from the masklol approach — cleaner path discovery, custom mic icons, auto re-hook when the topbar rebuilds. No external loaders.",
    })

    -- =========================================================
    -- CUSTOM MIC ICONS  (upload your own → paste rbxassetid here)
    -- =========================================================
    local N0IR_VC_ICONS = {
        -- muted  (shown when publish is paused / "safe" state)
        muted   = "rbxassetid://17739458468",
        -- unmuted (shown when mic is live)
        unmuted = "rbxassetid://17739459022",
        -- fallbacks if custom ids fail to load
        mutedFallback   = "rbxasset://textures/ui/VoiceChat/MicLight/Muted.png",
        unmutedFallback = "rbxasset://textures/ui/VoiceChat/MicLight/Light.png",
    }

    local VCState = {
        enabled = false,
        objs = {},
        conns = {},
        statusLbl = nil,
        watchConn = nil,
    }

    local function vcStatus(msg)
        if VCState.statusLbl and VCState.statusLbl.Set then
            VCState.statusLbl:Set("Status  ·  " .. msg)
        end
        N0IR:Notify({ Title = "NØIR VC", Content = msg, Duration = 2.2 })
    end

    local function vcDisconnectAll()
        for _, c in ipairs(VCState.conns) do
            pcall(function() c:Disconnect() end)
        end
        table.clear(VCState.conns)
        if VCState.watchConn then
            pcall(function() VCState.watchConn:Disconnect() end)
            VCState.watchConn = nil
        end
    end

    local function vcCleanupSoft()
        -- restore original button if we hid it; destroy clone
        local o = VCState.objs
        if o.cloned then pcall(function() o.cloned:Destroy() end) end
        if o.original and o.container and o.original.Parent == nil then
            pcall(function() o.original.Parent = o.container end)
        elseif o.original and o.hidden and o.original.Parent == o.hidden then
            pcall(function() o.original.Parent = o.container end)
        end
        if o.hidden then pcall(function() o.hidden:Destroy() end) end
        VCState.objs = {}
    end

    local function safeCloneRef(svc)
        if cloneref then return cloneref(svc) end
        return svc
    end

    local function findMicButton()
        local coregui = game:GetService("CoreGui")
        local candidates = {}

        local function dig(root, depth)
            if not root or depth > 8 then return end
            for _, ch in ipairs(root:GetChildren()) do
                local n = string.lower(ch.Name)
                if n:find("toggle_mic_mute", 1, true) or n == "mic" or n:find("mute", 1, true) and n:find("mic", 1, true) then
                    table.insert(candidates, ch)
                end
                dig(ch, depth + 1)
            end
        end

        -- modern topbar layouts
        pcall(function()
            local tba = coregui:FindFirstChild("TopBarApp")
            if tba then
                dig(tba, 0)
                local inner = tba:FindFirstChild("TopBarApp")
                if inner then dig(inner, 0) end
            end
        end)
        pcall(function()
            local chrome = coregui:FindFirstChild("Chrome") or coregui:FindFirstChild("Unibar")
            if chrome then dig(chrome, 0) end
        end)

        -- prefer exact name match
        for _, c in ipairs(candidates) do
            if c.Name == "toggle_mic_mute" or c.Name:lower() == "toggle_mic_mute" then
                return c, c.Parent
            end
        end
        if #candidates > 0 then
            return candidates[1], candidates[1].Parent
        end
        return nil, nil
    end

    local function getIconLabel(button)
        if not button then return nil end
        local icon = button:FindFirstChild("IntegrationIconFrame", true)
        if icon then
            local ii = icon:FindFirstChild("IntegrationIcon")
            if ii then
                local leaf = ii:FindFirstChild("1") or ii:FindFirstChildWhichIsA("ImageLabel")
                if leaf then return leaf end
            end
            local any = icon:FindFirstChildWhichIsA("ImageLabel", true)
            if any then return any end
        end
        return button:FindFirstChildWhichIsA("ImageLabel", true)
    end

    local function applyIcon(imgLabel, which)
        if not imgLabel then return end
        local primary = which == "muted" and N0IR_VC_ICONS.muted or N0IR_VC_ICONS.unmuted
        local fallback = which == "muted" and N0IR_VC_ICONS.mutedFallback or N0IR_VC_ICONS.unmutedFallback
        imgLabel.Image = primary
        -- if custom fails at runtime, ImageRect/empty — soft fallback after a beat
        task.delay(0.6, function()
            if imgLabel and imgLabel.Parent and (imgLabel.IsLoaded == false or imgLabel.Image == "") then
                imgLabel.Image = fallback
            end
        end)
    end

    local function hookMuteToggle(cloned, voiceInternal, iconLabel)
        local function toggle()
            local paused = false
            pcall(function() paused = voiceInternal:IsPublishPaused() end)
            local newState = not paused
            pcall(function() voiceInternal:PublishPause(newState) end)
            applyIcon(iconLabel, newState and "muted" or "unmuted")
        end

        local hit = cloned:FindFirstChild("IconHitArea_toggle_mic_mute", true)
            or cloned:FindFirstChildWhichIsA("TextButton", true)
            or cloned:FindFirstChildWhichIsA("ImageButton", true)
            or cloned

        if hit and hit:IsA("GuiButton") then
            table.insert(VCState.conns, hit.Activated:Connect(toggle))
            table.insert(VCState.conns, hit.MouseButton1Click:Connect(toggle))
        elseif cloned:IsA("GuiButton") then
            table.insert(VCState.conns, cloned.Activated:Connect(toggle))
            table.insert(VCState.conns, cloned.MouseButton1Click:Connect(toggle))
        end
    end

    local function tryApplyOnce()
        local voiceService = safeCloneRef(game:GetService("VoiceChatService"))
        local voiceInternal = safeCloneRef(game:GetService("VoiceChatInternal"))

        -- ensure we are in voice channel
        pcall(function() voiceService:joinVoice() end)
        task.wait(0.35)

        local micBtn, container = findMicButton()
        if not micBtn then
            return false, "mic button not found (topbar not ready)"
        end

        -- hidden stash
        local hidden = Instance.new("Folder")
        hidden.Name = "N0IR_VC_Hidden"
        hidden.Parent = game:GetService("RobloxReplicatedStorage")
        VCState.objs.hidden = hidden

        local cloned = micBtn:Clone()
        cloned.Name = "n0ir_toggle_mic_mute"
        micBtn.Parent = hidden
        cloned.Parent = container
        VCState.objs.cloned = cloned
        VCState.objs.original = micBtn
        VCState.objs.container = container

        local icon = getIconLabel(cloned)
        VCState.objs.icon = icon

        -- start muted (safer default for bypass)
        pcall(function() voiceInternal:PublishPause(true) end)
        applyIcon(icon, "muted")

        hookMuteToggle(cloned, voiceInternal, icon)

        -- silence noisy default connections on original if executor allows
        pcall(function()
            if getconnections then
                for _, c in ipairs(getconnections(micBtn.Activated)) do pcall(function() c:Disable() end) end
                for _, c in ipairs(getconnections(micBtn.MouseButton1Click)) do pcall(function() c:Disable() end) end
            end
        end)

        return true, "active"
    end

    local function enableN0IRVCBypass()
        if VCState.enabled then
            vcStatus("already active")
            return
        end
        VCState.enabled = true
        vcDisconnectAll()
        vcCleanupSoft()

        task.spawn(function()
            local ok, err = pcall(function()
                local success, msg = tryApplyOnce()
                if not success then
                    -- retry a few times — topbar often mounts late
                    for i = 1, 5 do
                        task.wait(0.8)
                        success, msg = tryApplyOnce()
                        if success then break end
                    end
                end
                if not success then
                    VCState.enabled = false
                    vcStatus("failed · " .. tostring(msg))
                    return
                end
                vcStatus("enabled · custom icons")

                -- watch for topbar rebuild (Roblox likes to refresh Unibar)
                local lastCheck = 0
                VCState.watchConn = RunService.Heartbeat:Connect(function()
                    if not VCState.enabled then return end
                    if tick() - lastCheck < 2.5 then return end
                    lastCheck = tick()
                    local clone = VCState.objs.cloned
                    if not clone or not clone.Parent then
                        -- rehook
                        vcDisconnectAll()
                        vcCleanupSoft()
                        local s, m = tryApplyOnce()
                        if s then
                            -- re-bind watch is already running
                        end
                    end
                end)
            end)
            if not ok then
                VCState.enabled = false
                vcStatus("error · " .. tostring(err))
            end
        end)
    end

    VCState.statusLbl = VC:CreateLabel("Status  ·  idle")

    VC:CreateButton({
        Name = "Enable NØIR VC Bypass",
        Callback = enableN0IRVCBypass,
    })

    VC:CreateParagraph({
        Content = "Icons: muted " .. N0IR_VC_ICONS.muted .. "  ·  unmuted " .. N0IR_VC_ICONS.unmuted .. "\nSwap the ids at the top of this module (N0IR_VC_ICONS) for your own uploads.",
    })

    -- also expose for commands
    _G._N0IR_EnableVCBypass = enableN0IRVCBypass

    -- ---------- Map / Treehouse ----------
    local Map = Window:CreateTab({ Name = "Map" })
    Map:CreateSection("Treehouse")
    Map:CreateParagraph({
        Content = "Spawn / teleport / remove the N0IR treehouse model in workspace.",
    })

    local TREEHOUSE_ASSET_ID = 7860328354
    _G._N0IRTreehouseModel = _G._N0IRTreehouseModel

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
        if _G._N0IRTreehouseModel and _G._N0IRTreehouseModel.Parent then
            N0IR:Notify({ Title = "Treehouse", Content = "Already spawned", Duration = 2 })
            return _G._N0IRTreehouseModel
        end
        local existing = workspace:FindFirstChild("N0IRTreehouse")
        if existing then
            _G._N0IRTreehouseModel = existing
            N0IR:Notify({ Title = "Treehouse", Content = "Already in workspace", Duration = 2 })
            return existing
        end
        local ok, objects = pcall(function()
            return game:GetObjects("rbxassetid://" .. tostring(TREEHOUSE_ASSET_ID))
        end)
        if not ok or not objects or #objects == 0 then
            N0IR:Notify({ Title = "Treehouse", Content = "Failed to load model", Duration = 3 })
            return nil
        end
        local model = objects[1]
        model.Name = "N0IRTreehouse"
        model.Parent = workspace
        prepareTreehouseModel(model, getTreehouseSpawnPosition())
        _G._N0IRTreehouseModel = model
        N0IR:Notify({ Title = "Treehouse", Content = "Spawned", Duration = 2.5 })
        return model
    end

    local function deleteTreehouse()
        local deleted = false
        if _G._N0IRTreehouseModel and _G._N0IRTreehouseModel.Parent then
            pcall(function() _G._N0IRTreehouseModel:Destroy() end)
            _G._N0IRTreehouseModel = nil
            deleted = true
        end
        for _, item in ipairs(workspace:GetChildren()) do
            if item.Name == "N0IRTreehouse" then
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
        local model = _G._N0IRTreehouseModel or workspace:FindFirstChild("N0IRTreehouse")
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
            N0IR:Notify({ Title = "Treehouse", Content = "Teleported", Duration = 1.5 })
        end
    end

    _G._N0IRSpawnTreehouse = spawnTreehouse
    _G._N0IRDeleteTreehouse = deleteTreehouse
    _G._N0IRTeleportToTreehouse = teleportToTreehouse

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

    local function getUserAvatarThumbnail(userId, size)
        size = size or 150
        local thumbnailUrl = string.format(
            "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%d&size=%dx%d&format=Png&isCircular=false",
            userId, size, size
        )
        if request then
            local success, response = pcall(function()
                return request({ Url = thumbnailUrl, Method = "GET" })
            end)
            if success and response and response.StatusCode == 200 then
                local ok, data = pcall(HttpService.JSONDecode, HttpService, response.Body)
                if ok and data and data.data and data.data[1] then
                    return data.data[1].imageUrl
                end
            end
        end
        return "rbxasset://textures/ui/GuiImagePlaceholder.png"
    end

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
                local icon = getUserAvatarThumbnail(userId, 150)
                N0IR:Notify({
                    Title = displayName .. " left",
                    Content = "Friend left this server",
                    Duration = 5,
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

    -- auto-start if default on
    startFriendLeft()

    -- ---------- Settings tab ----------
    local Settings = Window:CreateTab({ Name = "Settings" })
    Settings:CreateSection("About")
    Settings:CreateParagraph({
        Content = "NØIR UI Library v" .. N0IR.Version .. "\nMinimal black & white suite. Mount reanim or other modules via loadstring onto this window.",
    })
    Settings:CreateSection("Keybinds")
    local keyLbl = Settings:CreateLabel("Menu toggle  ·  " .. tostring((_G._N0IR_ToggleKey or Enum.KeyCode.M).Name))
    local cmdKeyLbl = Settings:CreateLabel("Cmd bar key  ·  " .. tostring((_G._N0IR_CmdBarKey or Enum.KeyCode.Semicolon).Name))
    local listening = false

    local function listenKey(labelObj, storeKey, pretty)
        if listening then return end
        listening = true
        labelObj:Set("Press any key...")
        N0IR:Notify({ Title = "Keybind", Content = "Press a key (Esc to cancel)", Duration = 2 })
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gp)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            conn:Disconnect()
            listening = false
            if input.KeyCode == Enum.KeyCode.Escape then
                local cur = _G[storeKey] or (storeKey == "_N0IR_ToggleKey" and Enum.KeyCode.M or Enum.KeyCode.Semicolon)
                labelObj:Set(pretty .. "  ·  " .. cur.Name)
                N0IR:Notify({ Title = "Keybind", Content = "Cancelled", Duration = 1.5 })
                return
            end
            _G[storeKey] = input.KeyCode
            labelObj:Set(pretty .. "  ·  " .. input.KeyCode.Name)
            N0IR:Notify({ Title = "Keybind", Content = pretty .. " → " .. input.KeyCode.Name, Duration = 2 })
        end)
    end

    Settings:CreateButton({
        Name = "Set menu toggle key",
        Callback = function()
            listenKey(keyLbl, "_N0IR_ToggleKey", "Menu toggle")
        end,
    })
    Settings:CreateButton({
        Name = "Set command bar key",
        Callback = function()
            listenKey(cmdKeyLbl, "_N0IR_CmdBarKey", "Cmd bar key")
        end,
    })

    Settings:CreateSection("Command prefix")
    local prefixLbl = Settings:CreateLabel("Current prefix  ·  " .. tostring(_G._N0IR_CmdPrefix or ";"))
    local prefixInput = Settings:CreateInput({
        Name = "Prefix",
        Placeholder = "e.g. ;  or  !  or  .",
        Default = tostring(_G._N0IR_CmdPrefix or ";"),
        Callback = function(text)
            text = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
            if text == "" then
                N0IR:Notify({ Title = "Prefix", Content = "Cannot be empty", Duration = 2 })
                return
            end
            _G._N0IR_CmdPrefix = text
            prefixLbl:Set("Current prefix  ·  " .. text)
            N0IR:Notify({ Title = "Prefix", Content = "Set to '" .. text .. "'", Duration = 2 })
        end,
    })
    Settings:CreateButton({
        Name = "Apply prefix from box",
        Callback = function()
            local text = prefixInput and prefixInput:Get() or ""
            text = tostring(text):gsub("^%s+", ""):gsub("%s+$", "")
            if text == "" then
                N0IR:Notify({ Title = "Prefix", Content = "Type a prefix in the box", Duration = 2 })
                return
            end
            _G._N0IR_CmdPrefix = text
            prefixLbl:Set("Current prefix  ·  " .. text)
            N0IR:Notify({ Title = "Prefix", Content = "Set to '" .. text .. "'", Duration = 2 })
        end,
    })

    Settings:CreateButton({
        Name = "Notify Test",
        Callback = function()
            N0IR:Notify({ Title = "NØIR", Content = "Library is alive.", Duration = 2 })
        end,
    })

    return {
        Home = Home,
        World = World,
        Player = Player,
        Anims = Anims,
        Cmds = Cmds,
        VC = VC,
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
        Width = opts.Width or 520,
        Height = opts.Height or 440,
        Loading = opts.Loading ~= false,
        LoadingText = opts.LoadingText or "loading modules",
        LoadingDuration = opts.LoadingDuration or 2.2,
        ToggleKey = opts.ToggleKey or Enum.KeyCode.M,
    })
    local modules = self:MountUtilities(win)
    return win, modules
end

return N0IR
