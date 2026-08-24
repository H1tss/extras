-- Slate UI Library v3
-- Fully executor-compatible (Synapse X, KRNL, Fluxus, Script-Ware, etc.)
-- Enhanced animations with spring physics and staggered entrances

local Slate = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Compatibility polyfills
if not math.clamp then
    function math.clamp(n, min, max)
        return n < min and min or n > max and max or n
    end
end

-- Theme
Slate.Theme = {
    Background = Color3.fromRGB(10, 10, 10),
    Sidebar = Color3.fromRGB(8, 8, 8),
    Card = Color3.fromRGB(18, 18, 18),
    CardBorder = Color3.fromRGB(30, 30, 30),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(150, 150, 150),
    TextMuted = Color3.fromRGB(100, 100, 100),
    Accent = Color3.fromRGB(255, 255, 255),
    Success = Color3.fromRGB(100, 255, 100),
    Error = Color3.fromRGB(255, 80, 80),
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,
    CornerRadius = UDim.new(0, 8),
    SidebarWidth = 180,
    TopbarHeight = 50,
    Padding = 16,
    ElementHeight = 36
}

-- Utility
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

local function Tween(instance, properties, duration, easingStyle, easingDirection, callback)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.35, easingStyle or Enum.EasingStyle.Quart, easingDirection or Enum.EasingDirection.Out),
        properties
    )
    if callback then
        tween.Completed:Connect(callback)
    end
    tween:Play()
    return tween
end

-- Spring physics system (lightweight, no external deps)
local ActiveSprings = {}
local SpringConnection = nil

local function StartSpringEngine()
    if SpringConnection then return end
    SpringConnection = RunService.RenderStepped:Connect(function(dt)
        local i = 1
        while i <= #ActiveSprings do
            local spring = ActiveSprings[i]
            if spring._dead then
                table.remove(ActiveSprings, i)
            else
                local displacement = spring.Target - spring.Current
                local springForce = displacement * (spring.Frequency * spring.Frequency)
                local dampingForce = spring.Velocity * (2 * spring.Damping * spring.Frequency)
                local acceleration = springForce - dampingForce

                spring.Velocity = spring.Velocity + acceleration * dt
                spring.Current = spring.Current + spring.Velocity * dt

                if math.abs(spring.Velocity) < 0.001 and math.abs(displacement) < 0.001 then
                    spring.Current = spring.Target
                    spring.Velocity = 0
                    if spring.OnComplete then
                        spring.OnComplete()
                    end
                    spring._dead = true
                end

                if spring.Apply then
                    spring.Apply(spring.Current)
                end
                i = i + 1
            end
        end
    end)
end

local function Spring(instance, property, target, frequency, damping, onComplete)
    frequency = frequency or 8
    damping = damping or 1

    local currentVal = instance[property]
    local startVal = 0

    if typeof(currentVal) == "UDim2" then
        startVal = currentVal.X.Offset
        local spring = {
            Current = startVal,
            Target = target,
            Velocity = 0,
            Frequency = frequency,
            Damping = damping,
            OnComplete = onComplete,
            Apply = function(v)
                instance[property] = UDim2.new(0, v, instance[property].Y.Scale, instance[property].Y.Offset)
            end,
            _dead = false
        }
        table.insert(ActiveSprings, spring)
        return spring
    elseif typeof(currentVal) == "number" then
        startVal = currentVal
        local spring = {
            Current = startVal,
            Target = target,
            Velocity = 0,
            Frequency = frequency,
            Damping = damping,
            OnComplete = onComplete,
            Apply = function(v)
                instance[property] = v
            end,
            _dead = false
        }
        table.insert(ActiveSprings, spring)
        return spring
    end
end

-- Draggable
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            Tween(frame, {Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset - 10, frame.Size.Y.Scale, frame.Size.Y.Offset - 6)}, 0.15)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            Tween(frame, {Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset + 10, frame.Size.Y.Scale, frame.Size.Y.Offset + 6)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end)
end

-- Notifications
function Slate:Notify(title, message, duration, ntype)
    duration = duration or 3.5
    ntype = ntype or "info"

    local notificationGui = Create("ScreenGui", {
        Name = "SlateNotifications",
        Parent = LocalPlayer:WaitForChild("PlayerGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    local container = Create("Frame", {
        Name = "Container",
        Parent = notificationGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -340, 1, -30),
        Size = UDim2.new(0, 320, 0, 0),
        AnchorPoint = Vector2.new(0, 1)
    })

    local notif = Create("Frame", {
        Name = "Notification",
        Parent = container,
        BackgroundColor3 = self.Theme.Card,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundTransparency = 1
    })

    Create("UICorner", {CornerRadius = self.Theme.CornerRadius, Parent = notif})
    Create("UIStroke", {Color = self.Theme.CardBorder, Thickness = 1, Parent = notif})

    local accent = Create("Frame", {
        Name = "Accent",
        Parent = notif,
        BackgroundColor3 = ntype == "success" and self.Theme.Success or ntype == "error" and self.Theme.Error or self.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundTransparency = 1
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = accent})

    local titleLabel = Create("TextLabel", {
        Name = "Title",
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 12),
        Size = UDim2.new(1, -32, 0, 20),
        Font = self.Theme.FontBold,
        Text = title,
        TextColor3 = self.Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1
    })

    local msgLabel = Create("TextLabel", {
        Name = "Message",
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 34),
        Size = UDim2.new(1, -32, 0, 36),
        Font = self.Theme.Font,
        Text = message,
        TextColor3 = self.Theme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextTransparency = 1
    })

    local targetHeight = 80
    local spring = Spring(notif, "Size", UDim2.new(1, 0, 0, targetHeight), 6, 0.8)
    spring.Apply = function(v)
        notif.Size = UDim2.new(1, 0, 0, v)
        notif.Position = UDim2.new(0, 0, 1, -v - 10)
    end
    spring.Current = 0
    spring.Target = targetHeight

    Tween(notif, {BackgroundTransparency = 0}, 0.4, Enum.EasingStyle.Quart)
    Tween(accent, {BackgroundTransparency = 0}, 0.3)

    delay(0.1, function()
        Tween(titleLabel, {TextTransparency = 0}, 0.4, Enum.EasingStyle.Quart)
    end)
    delay(0.2, function()
        Tween(msgLabel, {TextTransparency = 0}, 0.4, Enum.EasingStyle.Quart)
    end)

    delay(duration, function()
        Tween(titleLabel, {TextTransparency = 1}, 0.25)
        Tween(msgLabel, {TextTransparency = 1}, 0.25)
        Tween(accent, {BackgroundTransparency = 1}, 0.25)
        Tween(notif, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In, function()
            notif:Destroy()
            if #container:GetChildren() == 0 then
                notificationGui:Destroy()
            end
        end)
    end)
end

-- Create Window
function Slate:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Slate"
    local subtitle = config.Subtitle or ""

    StartSpringEngine()

    local screenGui = Create("ScreenGui", {
        Name = "SlateUI",
        Parent = LocalPlayer:WaitForChild("PlayerGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    local mainFrame = Create("Frame", {
        Name = "Main",
        Parent = screenGui,
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -350, 0.5, -225),
        Size = UDim2.new(0, 0, 0, 0),
        ClipsDescendants = true,
        BackgroundTransparency = 1
    })

    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = mainFrame})

    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -20, 0, -20),
        Size = UDim2.new(1, 40, 1, 40),
        ZIndex = 0,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277)
    })

    -- Sidebar
    local sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = mainFrame,
        BackgroundColor3 = self.Theme.Sidebar,
        BorderSizePixel = 0,
        Size = UDim2.new(0, self.Theme.SidebarWidth, 1, 0),
        BackgroundTransparency = 1
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = sidebar})

    local sidebarFix = Create("Frame", {
        Parent = sidebar,
        BackgroundColor3 = self.Theme.Sidebar,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -10, 0, 0),
        Size = UDim2.new(0, 10, 1, 0),
        BackgroundTransparency = 1
    })

    -- Logo
    local logoFrame = Create("Frame", {
        Name = "Logo",
        Parent = sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0, 0, 0, 10)
    })

    local logoIcon = Create("ImageLabel", {
        Name = "Icon",
        Parent = logoFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Image = "rbxassetid://7733960983",
        ImageColor3 = self.Theme.TextPrimary,
        ImageTransparency = 1
    })

    local logoText = Create("TextLabel", {
        Name = "Text",
        Parent = logoFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 48, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = self.Theme.FontBold,
        Text = title,
        TextColor3 = self.Theme.TextPrimary,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1
    })

    -- Tab container
    local tabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 70),
        Size = UDim2.new(1, 0, 1, -80)
    })

    Create("UIListLayout", {
        Parent = tabContainer,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Create("UIPadding", {
        Parent = tabContainer,
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 8)
    })

    -- Content
    local contentFrame = Create("Frame", {
        Name = "Content",
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, self.Theme.SidebarWidth, 0, 0),
        Size = UDim2.new(1, -self.Theme.SidebarWidth, 1, 0)
    })

    -- Header
    local header = Create("Frame", {
        Name = "Header",
        Parent = contentFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0, 0, 0, 0)
    })

    local welcomeText = Create("TextLabel", {
        Name = "Welcome",
        Parent = header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 24, 0, 20),
        Size = UDim2.new(1, -48, 0, 28),
        Font = self.Theme.FontBold,
        Text = "Welcome, " .. (subtitle ~= "" and subtitle or LocalPlayer.Name),
        TextColor3 = self.Theme.TextPrimary,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1
    })

    local closeBtn = Create("TextButton", {
        Name = "Close",
        Parent = header,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -40, 0, 15),
        Size = UDim2.new(0, 30, 0, 30),
        Font = self.Theme.Font,
        Text = "X",
        TextColor3 = self.Theme.TextMuted,
        TextSize = 16,
        TextTransparency = 1
    })

    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, {TextColor3 = self.Theme.Error}, 0.2)
    end)

    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, {TextColor3 = self.Theme.TextMuted}, 0.2)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        for _, child in pairs(contentFrame:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                Tween(child, {TextTransparency = 1}, 0.2)
            elseif child:IsA("Frame") and child.Name ~= "Content" and child.Name ~= "Pages" then
                Tween(child, {BackgroundTransparency = 1}, 0.2)
            elseif child:IsA("ImageLabel") then
                Tween(child, {ImageTransparency = 1}, 0.2)
            end
        end
        Tween(mainFrame, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        Tween(shadow, {ImageTransparency = 1}, 0.3)
        Tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In, function()
            screenGui:Destroy()
        end)
    end)

    -- Pages (using regular Frame instead of CanvasGroup for compatibility)
    local pages = Create("Frame", {
        Name = "Pages",
        Parent = contentFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 60),
        Size = UDim2.new(1, 0, 1, -60)
    })

    local window = {
        ScreenGui = screenGui,
        Main = mainFrame,
        Sidebar = sidebar,
        TabContainer = tabContainer,
        Content = contentFrame,
        Pages = pages,
        Tabs = {},
        CurrentTab = nil,
        Theme = self.Theme
    }

    -- Entrance animation
    mainFrame.Size = UDim2.new(0, 700, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)

    Tween(mainFrame, {BackgroundTransparency = 0}, 0.5, Enum.EasingStyle.Quart)
    Tween(shadow, {ImageTransparency = 0.6}, 0.6, Enum.EasingStyle.Quint)

    delay(0.1, function()
        Tween(sidebar, {BackgroundTransparency = 0}, 0.4)
        Tween(sidebarFix, {BackgroundTransparency = 0}, 0.4)
    end)

    delay(0.2, function()
        Tween(logoIcon, {ImageTransparency = 0}, 0.4, Enum.EasingStyle.Quart)
        Tween(logoText, {TextTransparency = 0}, 0.4, Enum.EasingStyle.Quart)
    end)

    delay(0.3, function()
        Tween(welcomeText, {TextTransparency = 0}, 0.5, Enum.EasingStyle.Quart)
        Tween(closeBtn, {TextTransparency = 0}, 0.4)
    end)

    MakeDraggable(mainFrame, header)

    -- Tab creation
    function window:CreateTab(name, iconId)
        local tabBtn = Create("TextButton", {
            Name = name .. "Tab",
            Parent = self.TabContainer,
            BackgroundColor3 = Slate.Theme.Sidebar,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 38),
            Font = Slate.Theme.Font,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = #self.Tabs
        })

        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = tabBtn})

        local tabIcon = Create("ImageLabel", {
            Name = "Icon",
            Parent = tabBtn,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0.5, -9),
            Size = UDim2.new(0, 18, 0, 18),
            Image = iconId or "rbxassetid://7733960983",
            ImageColor3 = Slate.Theme.TextMuted,
            ImageTransparency = 1
        })

        local tabLabel = Create("TextLabel", {
            Name = "Label",
            Parent = tabBtn,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 38, 0, 0),
            Size = UDim2.new(1, -50, 1, 0),
            Font = Slate.Theme.Font,
            Text = name,
            TextColor3 = Slate.Theme.TextMuted,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 1
        })

        local indicator = Create("Frame", {
            Name = "Indicator",
            Parent = tabBtn,
            BackgroundColor3 = Slate.Theme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.5, -8),
            Size = UDim2.new(0, 3, 0, 16),
            BackgroundTransparency = 1
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = indicator})

        -- Page (regular ScrollingFrame for max compatibility)
        local page = Create("ScrollingFrame", {
            Name = name .. "Page",
            Parent = self.Pages,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Slate.Theme.CardBorder,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            BackgroundTransparency = 1
        })

        local pageLayout = Create("UIListLayout", {
            Parent = page,
            Padding = UDim.new(0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Create("UIPadding", {
            Parent = page,
            PaddingLeft = UDim.new(0, 24),
            PaddingRight = UDim.new(0, 24),
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 24)
        })

        local tab = {
            Button = tabBtn,
            Page = page,
            Name = name,
            Elements = {}
        }

        -- Tab switch
        local function SelectTab()
            if self.CurrentTab == tab then return end

            if self.CurrentTab then
                Tween(self.CurrentTab.Page, {BackgroundTransparency = 1}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
                Tween(self.CurrentTab.Button, {BackgroundTransparency = 1}, 0.2)
                Tween(self.CurrentTab.Button.Icon, {ImageColor3 = Slate.Theme.TextMuted, ImageTransparency = 0.2}, 0.25)
                Tween(self.CurrentTab.Button.Label, {TextColor3 = Slate.Theme.TextMuted, TextTransparency = 0.2}, 0.25)
                Tween(self.CurrentTab.Button.Indicator, {BackgroundTransparency = 1}, 0.2)

                delay(0.2, function()
                    self.CurrentTab.Page.Visible = false
                end)
            end

            self.CurrentTab = tab
            tab.Page.Visible = true
            tab.Page.CanvasPosition = Vector2.new(0, 0)

            Tween(tabBtn, {BackgroundTransparency = 0.92}, 0.25)
            Tween(tabIcon, {ImageColor3 = Slate.Theme.TextPrimary, ImageTransparency = 0}, 0.3)
            Tween(tabLabel, {TextColor3 = Slate.Theme.TextPrimary, TextTransparency = 0}, 0.3)
            Tween(indicator, {BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            Tween(page, {BackgroundTransparency = 1}, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

            -- Staggered element entrance
            delay(0.1, function()
                local children = page:GetChildren()
                local validChildren = {}
                for _, child in pairs(children) do
                    if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then
                        table.insert(validChildren, child)
                    end
                end

                for i, child in ipairs(validChildren) do
                    if child:IsA("Frame") then
                        child.BackgroundTransparency = 1
                        local stroke = child:FindFirstChildOfClass("UIStroke")
                        if stroke then stroke.Transparency = 1 end
                    end
                    if child:FindFirstChild("Title") and child.Title:IsA("TextLabel") then
                        child.Title.TextTransparency = 1
                    end
                    if child:FindFirstChild("Label") and child.Label:IsA("TextLabel") then
                        child.Label.TextTransparency = 1
                    end

                    delay((i - 1) * 0.04, function()
                        if child:IsA("Frame") then
                            Tween(child, {BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Quart)
                            local stroke = child:FindFirstChildOfClass("UIStroke")
                            if stroke then
                                Tween(stroke, {Transparency = 0}, 0.3)
                            end
                        end
                        if child:FindFirstChild("Title") and child.Title:IsA("TextLabel") then
                            Tween(child.Title, {TextTransparency = 0}, 0.25)
                        end
                        if child:FindFirstChild("Label") and child.Label:IsA("TextLabel") then
                            Tween(child.Label, {TextTransparency = 0}, 0.25)
                        end
                    end)
                end
            end)
        end

        tabBtn.MouseButton1Click:Connect(SelectTab)

        tabBtn.MouseEnter:Connect(function()
            if self.CurrentTab ~= tab then
                Tween(tabBtn, {BackgroundTransparency = 0.96}, 0.15)
                Tween(tabIcon, {ImageTransparency = 0.5}, 0.15)
                Tween(tabLabel, {TextTransparency = 0.5}, 0.15)
            end
        end)

        tabBtn.MouseLeave:Connect(function()
            if self.CurrentTab ~= tab then
                Tween(tabBtn, {BackgroundTransparency = 1}, 0.2)
                Tween(tabIcon, {ImageTransparency = 0.2}, 0.2)
                Tween(tabLabel, {TextTransparency = 0.2}, 0.2)
            end
        end)

        table.insert(self.Tabs, tab)

        if #self.Tabs == 1 then
            delay(0.5, function()
                SelectTab()
            end)
        end

        -- Elements
        function tab:CreateSection(title)
            local section = Create("Frame", {
                Name = title,
                Parent = self.Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30),
                LayoutOrder = #self.Elements
            })

            local label = Create("TextLabel", {
                Parent = section,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Slate.Theme.FontBold,
                Text = title,
                TextColor3 = Slate.Theme.TextSecondary,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTransparency = 1
            })

            table.insert(self.Elements, section)
            return section
        end

        function tab:CreateButton(config)
            config = config or {}
            local text = config.Text or "Button"
            local callback = config.Callback or function() end

            local btn = Create("TextButton", {
                Parent = self.Page,
                BackgroundColor3 = Slate.Theme.Card,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, Slate.Theme.ElementHeight),
                Font = Slate.Theme.Font,
                Text = text,
                TextColor3 = Slate.Theme.TextPrimary,
                TextSize = 13,
                AutoButtonColor = false,
                LayoutOrder = #self.Elements,
                BackgroundTransparency = 1,
                TextTransparency = 1
            })

            Create("UICorner", {CornerRadius = Slate.Theme.CornerRadius, Parent = btn})

            local stroke = Create("UIStroke", {
                Color = Slate.Theme.CardBorder,
                Thickness = 1,
                Parent = btn,
                Transparency = 1
            })

            btn.MouseEnter:Connect(function()
                Tween(btn, {BackgroundColor3 = Color3.fromRGB(28, 28, 28)}, 0.2)
            end)

            btn.MouseLeave:Connect(function()
                Tween(btn, {BackgroundColor3 = Slate.Theme.Card}, 0.25)
            end)

            btn.MouseButton1Down:Connect(function()
                Tween(btn, {Size = UDim2.new(0.985, 0, 0, Slate.Theme.ElementHeight - 1)}, 0.1)
            end)

            btn.MouseButton1Up:Connect(function()
                Tween(btn, {Size = UDim2.new(1, 0, 0, Slate.Theme.ElementHeight)}, 0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            end)

            btn.MouseButton1Click:Connect(function()
                callback()
            end)

            table.insert(self.Elements, btn)
            return btn
        end

        function tab:CreateToggle(config)
            config = config or {}
            local text = config.Text or "Toggle"
            local default = config.Default or false
            local callback = config.Callback or function() end

            local toggleFrame = Create("Frame", {
                Parent = self.Page,
                BackgroundColor3 = Slate.Theme.Card,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, Slate.Theme.ElementHeight),
                LayoutOrder = #self.Elements,
                BackgroundTransparency = 1
            })

            Create("UICorner", {CornerRadius = Slate.Theme.CornerRadius, Parent = toggleFrame})
            Create("UIStroke", {Color = Slate.Theme.CardBorder, Thickness = 1, Parent = toggleFrame})

            local label = Create("TextLabel", {
                Parent = toggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(1, -70, 1, 0),
                Font = Slate.Theme.Font,
                Text = text,
                TextColor3 = Slate.Theme.TextPrimary,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local switch = Create("Frame", {
                Parent = toggleFrame,
                BackgroundColor3 = Slate.Theme.CardBorder,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -50, 0.5, -10),
                Size = UDim2.new(0, 36, 0, 20)
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = switch})

            local knob = Create("Frame", {
                Parent = switch,
                BackgroundColor3 = Slate.Theme.TextSecondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 2, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16)
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})

            local enabled = default
            local knobSpring = nil

            local function UpdateToggle(animate)
                if animate == nil then animate = true end
                if enabled then
                    Tween(switch, {BackgroundColor3 = Slate.Theme.Accent}, animate and 0.25 or 0)
                    Tween(knob, {BackgroundColor3 = Slate.Theme.Background}, animate and 0.2 or 0)

                    if animate then
                        if knobSpring then knobSpring._dead = true end
                        knobSpring = Spring(knob, "Position", UDim2.new(0, 18, 0.5, -8), 12, 0.8)
                        knobSpring.Current = knob.Position.X.Offset
                        knobSpring.Target = 18
                        knobSpring.Apply = function(v)
                            knob.Position = UDim2.new(0, v, 0.5, -8)
                        end
                    else
                        knob.Position = UDim2.new(0, 18, 0.5, -8)
                    end
                else
                    Tween(switch, {BackgroundColor3 = Slate.Theme.CardBorder}, animate and 0.25 or 0)
                    Tween(knob, {BackgroundColor3 = Slate.Theme.TextSecondary}, animate and 0.2 or 0)

                    if animate then
                        if knobSpring then knobSpring._dead = true end
                        knobSpring = Spring(knob, "Position", UDim2.new(0, 2, 0.5, -8), 12, 0.8)
                        knobSpring.Current = knob.Position.X.Offset
                        knobSpring.Target = 2
                        knobSpring.Apply = function(v)
                            knob.Position = UDim2.new(0, v, 0.5, -8)
                        end
                    else
                        knob.Position = UDim2.new(0, 2, 0.5, -8)
                    end
                end
                callback(enabled)
            end

            if default then
                switch.BackgroundColor3 = Slate.Theme.Accent
                knob.Position = UDim2.new(0, 18, 0.5, -8)
                knob.BackgroundColor3 = Slate.Theme.Background
            end

            local clickArea = Create("TextButton", {
                Parent = toggleFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })

            clickArea.MouseButton1Click:Connect(function()
                enabled = not enabled
                UpdateToggle(true)
            end)

            table.insert(self.Elements, toggleFrame)

            return {
                Frame = toggleFrame,
                Set = function(value)
                    enabled = value
                    UpdateToggle(true)
                end,
                Get = function() return enabled end
            }
        end

        function tab:CreateSlider(config)
            config = config or {}
            local text = config.Text or "Slider"
            local min = config.Min or 0
            local max = config.Max or 100
            local default = config.Default or min
            local increment = config.Increment or 1
            local callback = config.Callback or function() end

            local sliderFrame = Create("Frame", {
                Parent = self.Page,
                BackgroundColor3 = Slate.Theme.Card,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 50),
                LayoutOrder = #self.Elements,
                BackgroundTransparency = 1
            })

            Create("UICorner", {CornerRadius = Slate.Theme.CornerRadius, Parent = sliderFrame})
            Create("UIStroke", {Color = Slate.Theme.CardBorder, Thickness = 1, Parent = sliderFrame})

            local label = Create("TextLabel", {
                Parent = sliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 8),
                Size = UDim2.new(0.5, 0, 0, 18),
                Font = Slate.Theme.Font,
                Text = text,
                TextColor3 = Slate.Theme.TextPrimary,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local valueLabel = Create("TextLabel", {
                Parent = sliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0, 8),
                Size = UDim2.new(0.5, -14, 0, 18),
                Font = Slate.Theme.FontMedium,
                Text = tostring(default),
                TextColor3 = Slate.Theme.TextSecondary,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local track = Create("Frame", {
                Parent = sliderFrame,
                BackgroundColor3 = Slate.Theme.CardBorder,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 14, 0, 34),
                Size = UDim2.new(1, -28, 0, 4)
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = track})

            local fill = Create("Frame", {
                Parent = track,
                BackgroundColor3 = Slate.Theme.Accent,
                BorderSizePixel = 0,
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})

            local knob = Create("Frame", {
                Parent = track,
                BackgroundColor3 = Slate.Theme.TextPrimary,
                BorderSizePixel = 0,
                Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
                Size = UDim2.new(0, 12, 0, 12)
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})

            local dragging = false
            local currentValue = default
            local knobSpring = nil
            local fillSpring = nil

            local function UpdateSlider(input, animate)
                local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local val = min + (max - min) * pos
                val = math.floor(val / increment + 0.5) * increment
                val = math.clamp(val, min, max)
                currentValue = val

                local scale = (val - min) / (max - min)

                if animate then
                    if knobSpring then knobSpring._dead = true end
                    if fillSpring then fillSpring._dead = true end

                    knobSpring = Spring(knob, "Position", UDim2.new(scale, -6, 0.5, -6), 14, 0.7)
                    knobSpring.Current = knob.Position.X.Offset
                    knobSpring.Target = scale * track.AbsoluteSize.X - 6
                    knobSpring.Apply = function(v)
                        knob.Position = UDim2.new(0, v, 0.5, -6)
                    end

                    fillSpring = Spring(fill, "Size", UDim2.new(scale, 0, 1, 0), 14, 0.7)
                    fillSpring.Current = fill.Size.X.Scale * track.AbsoluteSize.X
                    fillSpring.Target = scale * track.AbsoluteSize.X
                    fillSpring.Apply = function(v)
                        fill.Size = UDim2.new(0, v, 1, 0)
                    end
                else
                    fill.Size = UDim2.new(scale, 0, 1, 0)
                    knob.Position = UDim2.new(scale, -6, 0.5, -6)
                end

                valueLabel.Text = tostring(val)
                callback(val)
            end

            knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    Tween(knob, {Size = UDim2.new(0, 16, 0, 16)}, 0.1)
                end
            end)

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    UpdateSlider(input, true)
                    dragging = true
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input, true)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
                    dragging = false
                    Tween(knob, {Size = UDim2.new(0, 12, 0, 12)}, 0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                end
            end)

            table.insert(self.Elements, sliderFrame)

            return {
                Frame = sliderFrame,
                Set = function(value)
                    value = math.clamp(value, min, max)
                    currentValue = value
                    local scale = (value - min) / (max - min)

                    if knobSpring then knobSpring._dead = true end
                    if fillSpring then fillSpring._dead = true end

                    knobSpring = Spring(knob, "Position", UDim2.new(scale, -6, 0.5, -6), 14, 0.7)
                    knobSpring.Current = knob.Position.X.Offset
                    knobSpring.Target = scale * track.AbsoluteSize.X - 6
                    knobSpring.Apply = function(v)
                        knob.Position = UDim2.new(0, v, 0.5, -6)
                    end

                    fillSpring = Spring(fill, "Size", UDim2.new(scale, 0, 1, 0), 14, 0.7)
                    fillSpring.Current = fill.Size.X.Scale * track.AbsoluteSize.X
                    fillSpring.Target = scale * track.AbsoluteSize.X
                    fillSpring.Apply = function(v)
                        fill.Size = UDim2.new(0, v, 1, 0)
                    end

                    valueLabel.Text = tostring(value)
                    callback(value)
                end,
                Get = function() return currentValue end
            }
        end

        function tab:CreateDropdown(config)
            config = config or {}
            local text = config.Text or "Dropdown"
            local options = config.Options or {}
            local default = config.Default or options[1] or ""
            local callback = config.Callback or function() end

            local dropdownFrame = Create("Frame", {
                Parent = self.Page,
                BackgroundColor3 = Slate.Theme.Card,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, Slate.Theme.ElementHeight),
                ClipsDescendants = true,
                LayoutOrder = #self.Elements,
                BackgroundTransparency = 1
            })

            Create("UICorner", {CornerRadius = Slate.Theme.CornerRadius, Parent = dropdownFrame})
            Create("UIStroke", {Color = Slate.Theme.CardBorder, Thickness = 1, Parent = dropdownFrame})

            local label = Create("TextLabel", {
                Parent = dropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(0.5, 0, 0, Slate.Theme.ElementHeight),
                Font = Slate.Theme.Font,
                Text = text,
                TextColor3 = Slate.Theme.TextPrimary,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local selected = Create("TextLabel", {
                Parent = dropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0, 0),
                Size = UDim2.new(0.5, -40, 0, Slate.Theme.ElementHeight),
                Font = Slate.Theme.FontMedium,
                Text = default,
                TextColor3 = Slate.Theme.TextSecondary,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local arrow = Create("ImageLabel", {
                Parent = dropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -28, 0.5, -6),
                Size = UDim2.new(0, 12, 0, 12),
                Image = "rbxassetid://7733717447",
                ImageColor3 = Slate.Theme.TextMuted,
                Rotation = 0
            })

            local optionContainer = Create("Frame", {
                Parent = dropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, Slate.Theme.ElementHeight),
                Size = UDim2.new(1, 0, 0, 0)
            })

            Create("UIListLayout", {
                Parent = optionContainer,
                Padding = UDim.new(0, 2)
            })

            local isOpen = false
            local currentSelection = default
            local heightSpring = nil

            for i, option in ipairs(options) do
                local optBtn = Create("TextButton", {
                    Parent = optionContainer,
                    BackgroundColor3 = Slate.Theme.Card,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Slate.Theme.Font,
                    Text = option,
                    TextColor3 = Slate.Theme.TextSecondary,
                    TextSize = 12,
                    TextTransparency = 1
                })

                optBtn.MouseEnter:Connect(function()
                    Tween(optBtn, {BackgroundTransparency = 0.2, TextColor3 = Slate.Theme.TextPrimary}, 0.15)
                end)

                optBtn.MouseLeave:Connect(function()
                    Tween(optBtn, {BackgroundTransparency = 0.5, TextColor3 = Slate.Theme.TextSecondary}, 0.15)
                end)

                optBtn.MouseButton1Click:Connect(function()
                    currentSelection = option
                    selected.Text = option
                    callback(option)

                    isOpen = false
                    if heightSpring then heightSpring._dead = true end
                    heightSpring = Spring(dropdownFrame, "Size", UDim2.new(1, 0, 0, Slate.Theme.ElementHeight), 10, 0.9)
                    heightSpring.Current = dropdownFrame.AbsoluteSize.Y
                    heightSpring.Target = Slate.Theme.ElementHeight
                    heightSpring.Apply = function(v)
                        dropdownFrame.Size = UDim2.new(1, 0, 0, v)
                    end

                    Tween(arrow, {Rotation = 0}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

                    for _, child in pairs(optionContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            Tween(child, {TextTransparency = 1}, 0.15)
                        end
                    end
                end)
            end

            local clickArea = Create("TextButton", {
                Parent = dropdownFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, Slate.Theme.ElementHeight),
                Text = "",
                ZIndex = 2
            })

            clickArea.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                local targetHeight = Slate.Theme.ElementHeight + (#options * 32) + 4

                if heightSpring then heightSpring._dead = true end
                heightSpring = Spring(dropdownFrame, "Size", UDim2.new(1, 0, 0, isOpen and targetHeight or Slate.Theme.ElementHeight), 10, 0.9)
                heightSpring.Current = dropdownFrame.AbsoluteSize.Y
                heightSpring.Target = isOpen and targetHeight or Slate.Theme.ElementHeight
                heightSpring.Apply = function(v)
                    dropdownFrame.Size = UDim2.new(1, 0, 0, v)
                end

                Tween(arrow, {Rotation = isOpen and 180 or 0}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

                if isOpen then
                    delay(0.1, function()
                        local opts = optionContainer:GetChildren()
                        local validOpts = {}
                        for _, child in pairs(opts) do
                            if child:IsA("TextButton") then
                                table.insert(validOpts, child)
                            end
                        end
                        for i, child in ipairs(validOpts) do
                            delay((i - 1) * 0.02, function()
                                Tween(child, {TextTransparency = 0}, 0.2)
                            end)
                        end
                    end)
                else
                    for _, child in pairs(optionContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            Tween(child, {TextTransparency = 1}, 0.15)
                        end
                    end
                end
            end)

            table.insert(self.Elements, dropdownFrame)

            return {
                Frame = dropdownFrame,
                Set = function(value)
                    if table.find(options, value) then
                        currentSelection = value
                        selected.Text = value
                        callback(value)
                    end
                end,
                Get = function() return currentSelection end,
                Refresh = function(newOptions)
                    for _, child in pairs(optionContainer:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    options = newOptions
                    for i, option in ipairs(options) do
                        local optBtn = Create("TextButton", {
                            Parent = optionContainer,
                            BackgroundColor3 = Slate.Theme.Card,
                            BackgroundTransparency = 0.5,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 30),
                            Font = Slate.Theme.Font,
                            Text = option,
                            TextColor3 = Slate.Theme.TextSecondary,
                            TextSize = 12
                        })

                        optBtn.MouseEnter:Connect(function()
                            Tween(optBtn, {BackgroundTransparency = 0.2, TextColor3 = Slate.Theme.TextPrimary}, 0.15)
                        end)

                        optBtn.MouseLeave:Connect(function()
                            Tween(optBtn, {BackgroundTransparency = 0.5, TextColor3 = Slate.Theme.TextSecondary}, 0.15)
                        end)

                        optBtn.MouseButton1Click:Connect(function()
                            currentSelection = option
                            selected.Text = option
                            callback(option)
                            isOpen = false
                            if heightSpring then heightSpring._dead = true end
                            heightSpring = Spring(dropdownFrame, "Size", UDim2.new(1, 0, 0, Slate.Theme.ElementHeight), 10, 0.9)
                            heightSpring.Current = dropdownFrame.AbsoluteSize.Y
                            heightSpring.Target = Slate.Theme.ElementHeight
                            heightSpring.Apply = function(v)
                                dropdownFrame.Size = UDim2.new(1, 0, 0, v)
                            end
                            Tween(arrow, {Rotation = 0}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                        end)
                    end
                end
            }
        end

        function tab:CreateInput(config)
            config = config or {}
            local text = config.Text or "Input"
            local placeholder = config.Placeholder or "Enter text..."
            local default = config.Default or ""
            local callback = config.Callback or function() end

            local inputFrame = Create("Frame", {
                Parent = self.Page,
                BackgroundColor3 = Slate.Theme.Card,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, Slate.Theme.ElementHeight),
                LayoutOrder = #self.Elements,
                BackgroundTransparency = 1
            })

            Create("UICorner", {CornerRadius = Slate.Theme.CornerRadius, Parent = inputFrame})
            Create("UIStroke", {Color = Slate.Theme.CardBorder, Thickness = 1, Parent = inputFrame})

            local label = Create("TextLabel", {
                Parent = inputFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(0.35, 0, 1, 0),
                Font = Slate.Theme.Font,
                Text = text,
                TextColor3 = Slate.Theme.TextPrimary,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local textBox = Create("TextBox", {
                Parent = inputFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.35, 0, 0, 0),
                Size = UDim2.new(0.65, -14, 1, 0),
                Font = Slate.Theme.FontMedium,
                Text = default,
                PlaceholderText = placeholder,
                TextColor3 = Slate.Theme.TextSecondary,
                PlaceholderColor3 = Slate.Theme.TextMuted,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false
            })

            local focusStroke = Create("UIStroke", {
                Color = Slate.Theme.Accent,
                Thickness = 1.5,
                Parent = inputFrame,
                Transparency = 1
            })

            textBox.Focused:Connect(function()
                Tween(inputFrame, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}, 0.2)
                Tween(focusStroke, {Transparency = 0}, 0.25)
            end)

            textBox.FocusLost:Connect(function(enterPressed)
                Tween(inputFrame, {BackgroundColor3 = Slate.Theme.Card}, 0.2)
                Tween(focusStroke, {Transparency = 1}, 0.2)
                callback(textBox.Text, enterPressed)
            end)

            table.insert(self.Elements, inputFrame)

            return {
                Frame = inputFrame,
                Set = function(value)
                    textBox.Text = value
                    callback(value, false)
                end,
                Get = function() return textBox.Text end
            }
        end

        function tab:CreateLabel(config)
            config = config or {}
            local text = config.Text or "Label"

            local label = Create("TextLabel", {
                Parent = self.Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
                Font = Slate.Theme.Font,
                Text = text,
                TextColor3 = Slate.Theme.TextSecondary,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                LayoutOrder = #self.Elements,
                TextTransparency = 1
            })

            table.insert(self.Elements, label)
            return label
        end

        function tab:CreateCard(config)
            config = config or {}
            local title = config.Title or "Card"
            local subtitle = config.Subtitle or ""

            local card = Create("Frame", {
                Parent = self.Page,
                BackgroundColor3 = Slate.Theme.Card,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 100),
                LayoutOrder = #self.Elements,
                BackgroundTransparency = 1
            })

            Create("UICorner", {CornerRadius = Slate.Theme.CornerRadius, Parent = card})
            Create("UIStroke", {Color = Slate.Theme.CardBorder, Thickness = 1, Parent = card})

            local titleLabel = Create("TextLabel", {
                Parent = card,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 12),
                Size = UDim2.new(1, -32, 0, 22),
                Font = Slate.Theme.FontBold,
                Text = title,
                TextColor3 = Slate.Theme.TextPrimary,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTransparency = 1
            })

            if subtitle ~= "" then
                local subLabel = Create("TextLabel", {
                    Parent = card,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 16, 0, 36),
                    Size = UDim2.new(1, -32, 0, 18),
                    Font = Slate.Theme.Font,
                    Text = subtitle,
                    TextColor3 = Slate.Theme.TextMuted,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTransparency = 1
                })
            end

            card.MouseEnter:Connect(function()
                Tween(card, {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}, 0.2)
            end)

            card.MouseLeave:Connect(function()
                Tween(card, {BackgroundColor3 = Slate.Theme.Card}, 0.25)
            end)

            table.insert(self.Elements, card)
            return card
        end

        -- Update canvas size
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 40)
        end)

        return tab
    end

    return window
end

-- Keybind
function Slate:BindKey(key, callback)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == key then
            callback()
        end
    end)
end

return Slate
