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
                pcall(function() part.Material = Enum.Material.SmoothPlastic end)
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

    -- ---------- Commands tab ----------
    local Cmds = Window:CreateTab({ Name = "Commands" })
    Cmds:CreateSection("Command Bar")
    Cmds:CreateParagraph({
        Content = "Prefix:  ;   ·   Open with semicolon or type in chat\nExamples: ;ws 50  ·  ;goto name  ·  ;noclip  ·  ;fly  ·  ;rejoin",
    })

    local prefix = ";"
    local cmdBarKey = Enum.KeyCode.Semicolon

    -- Lightweight command runner
    local function findPlayer(q)
        if not q then return nil end
        q = q:lower()
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name:lower():sub(1, #q) == q or p.DisplayName:lower():sub(1, #q) == q then
                return p
            end
        end
        return nil
    end

    local flying = false
    local flyConn = nil

    local function runCmd(msg)
        msg = msg:lower():gsub("^%s+", ""):gsub("%s+$", "")
        if msg:sub(1, 1) ~= prefix then return end
        local body = msg:sub(2)
        local args = {}
        for w in body:gmatch("%S+") do table.insert(args, w) end
        local cmd = args[1]
        if not cmd then return end

        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if cmd == "ws" or cmd == "speed" then
            if hum and tonumber(args[2]) then hum.WalkSpeed = tonumber(args[2]) end
        elseif cmd == "jp" or cmd == "jumppower" then
            if hum and tonumber(args[2]) then hum.UseJumpPower = true; hum.JumpPower = tonumber(args[2]) end
        elseif cmd == "goto" or cmd == "to" then
            local t = findPlayer(args[2])
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and hrp then
                hrp.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        elseif cmd == "view" then
            local t = findPlayer(args[2])
            if t and t.Character and t.Character:FindFirstChildOfClass("Humanoid") then
                workspace.CurrentCamera.CameraSubject = t.Character:FindFirstChildOfClass("Humanoid")
            end
        elseif cmd == "unview" then
            if hum then workspace.CurrentCamera.CameraSubject = hum end
        elseif cmd == "noclip" then
            N0IR.Flags.Noclip = true
        elseif cmd == "clip" then
            N0IR.Flags.Noclip = false
        elseif cmd == "rejoin" or cmd == "rj" then
            pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
        elseif cmd == "fly" then
            if flying then return end
            flying = true
            local speed = tonumber(args[2]) or 50
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
            flyConn = RunService.RenderStepped:Connect(function()
                if not flying or not hrp then return end
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
            N0IR:Notify({ Title = "Fly", Content = "ON", Duration = 1.2 })
        elseif cmd == "unfly" then
            flying = false
            if flyConn then flyConn:Disconnect(); flyConn = nil end
            if hrp then
                for _, x in ipairs(hrp:GetChildren()) do
                    if x:IsA("BodyVelocity") then x:Destroy() end
                end
            end
            N0IR:Notify({ Title = "Fly", Content = "OFF", Duration = 1.2 })
        elseif cmd == "cmds" or cmd == "commands" then
            N0IR:Notify({ Title = "Commands", Content = "ws jp goto view unview noclip clip fly unfly rejoin", Duration = 4 })
        end
    end

    -- Chat hook
    pcall(function()
        LocalPlayer.Chatted:Connect(function(msg)
            runCmd(msg)
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
    input.PlaceholderText = "command  ·  ;cmds"
    input.PlaceholderColor3 = T.text3
    input.Text = ""
    input.TextSize = 13
    input.TextColor3 = T.text
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.ClearTextOnFocus = false
    input.Parent = bar

    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == cmdBarKey then
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
            if t:sub(1, 1) ~= prefix then t = prefix .. t end
            runCmd(t)
        end
        input.Text = ""
    end)

    Cmds:CreateLabel("Press  ;  to open the command bar")

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
            N0IR:Notify({ Title = "Treehouse", Content = "Failed to load model", Duration = 3 })
            return nil
        end
        local model = objects[1]
        model.Name = "HaloTreehouse"
        model.Parent = workspace
        prepareTreehouseModel(model, getTreehouseSpawnPosition())
        _G._HaloTreehouseModel = model
        N0IR:Notify({ Title = "Treehouse", Content = "Spawned", Duration = 2.5 })
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
            N0IR:Notify({ Title = "Treehouse", Content = "Teleported", Duration = 1.5 })
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
        Width = opts.Width or 520,
        Height = opts.Height or 440,
        Loading = opts.Loading ~= false,
        LoadingText = opts.LoadingText or "loading modules",
        LoadingDuration = opts.LoadingDuration or 2.2,
    })
    local modules = self:MountUtilities(win)
    return win, modules
end

return N0IR
