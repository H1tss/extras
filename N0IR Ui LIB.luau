--[[
    NØIR UI Library + Key System + Nametag
    Connected to: https://n0ir.pages.dev

    Usage:
        KEY = "N0IR-XXXXXXXXXXXXXXXX"
        local N0IR = loadstring(game:HttpGet("https://raw.githubusercontent.com/H1tss/extras/refs/heads/main/N0IR%20Ui%20LIB.luau"))()
        local Window = N0IR:Init({ Title = "NØIR", SubTitle = "GUI" })
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- KEY SYSTEM  (https://n0ir.pages.dev)
-- ============================================================
local API_URL = "https://n0ir.pages.dev"
local KEY_FILE = "N0IR/key.txt"

local function getHWID()
    local raw = ""
    pcall(function()
        if gethwid then
            raw = tostring(gethwid())
        elseif getexecutorname then
            raw = tostring(getexecutorname()) .. tostring(LocalPlayer.UserId)
        else
            raw = tostring(LocalPlayer.UserId) .. tostring(game.PlaceId)
        end
    end)
    local h = 0
    for i = 1, #raw do
        h = (h * 31 + string.byte(raw, i)) % 2147483647
    end
    return tostring(h) .. "_" .. tostring(LocalPlayer.UserId)
end

local function httpPost(url, bodyTable)
    local body = HttpService:JSONEncode(bodyTable)
    local ok, result = pcall(function()
        if request then
            local res = request({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body,
            })
            if res and res.Body then
                return HttpService:JSONDecode(res.Body)
            end
        elseif syn and syn.request then
            local res = syn.request({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body,
            })
            if res and res.Body then
                return HttpService:JSONDecode(res.Body)
            end
        else
            local res = game:HttpPost(url, body, false, "application/json")
            return HttpService:JSONDecode(res)
        end
        return nil
    end)
    if ok and type(result) == "table" then
        return result
    end
    return { success = false, message = "Request failed" }
end

local function saveKey(key)
    pcall(function()
        if isfolder and not isfolder("N0IR") then makefolder("N0IR") end
        if writefile then writefile(KEY_FILE, key) end
    end)
    _G._N0IR_SavedKey = key
end

local function loadSavedKey()
    local key = _G._N0IR_SavedKey
    pcall(function()
        if isfile and isfile(KEY_FILE) then
            key = readfile(KEY_FILE)
        end
    end)
    if type(key) == "string" and key ~= "" then
        return key:gsub("%s+", "")
    end
    return nil
end

local function validateKey(key)
    if not key or key == "" then
        return { success = false, message = "No key" }
    end
    return httpPost(API_URL .. "/api/validate", {
        key = key,
        hwid = getHWID(),
        userId = LocalPlayer.UserId,
    }) or { success = false, message = "Server error" }
end

-- ============================================================
-- NAMETAG SYSTEM  (multi-user)
-- On key validate the API stores userId → tag/rank/color.
-- Clients poll /api/nametags with server UserIds and only show
-- tags for real NØIR key users (each with their own custom tag).
-- ============================================================
local Nametag = {
    Folder = nil,
    Tags = {},          -- [Player] = BillboardGui
    PlayerData = {},    -- [UserId string] = style data
    MyData = nil,
    ShowSelf = true,    -- show your own tag
    ShowOthers = true,  -- show other NØIR script users' tags
    RefreshSeconds = 12,
    _refreshing = false,
    _started = false,
}

-- 1:1 with Nametag Studio (Roblox-only properties)
-- Tree: BillboardGui > Root > Pill(Frame+UIStroke+UICorner[+UIGradient]) > Icon/Dot + Tag[+UIGradient] > Name > Rank
local DEFAULT_TAG = "NØIR"
local DEFAULT_COLOR = "#FFFFFF"

local _N0IR_ImgCache = _G._N0IR_ImgCache or {}
_G._N0IR_ImgCache = _N0IR_ImgCache

local FONT_MAP = {
    Gotham = Enum.Font.Gotham, GothamMedium = Enum.Font.GothamMedium,
    GothamBold = Enum.Font.GothamBold, GothamBlack = Enum.Font.GothamBlack,
    GothamSemibold = Enum.Font.GothamSemibold,
    SourceSans = Enum.Font.SourceSans, SourceSansBold = Enum.Font.SourceSansBold,
    SourceSansSemibold = Enum.Font.SourceSansSemibold, SourceSansLight = Enum.Font.SourceSansLight,
    SourceSansItalic = Enum.Font.SourceSansItalic,
    Roboto = Enum.Font.Roboto, RobotoCondensed = Enum.Font.RobotoCondensed,
    RobotoMono = Enum.Font.RobotoMono, Arcade = Enum.Font.Arcade, Bodoni = Enum.Font.Bodoni,
    Garamond = Enum.Font.Garamond, Cartoon = Enum.Font.Cartoon, Code = Enum.Font.Code,
    Highway = Enum.Font.Highway, SciFi = Enum.Font.SciFi, Fantasy = Enum.Font.Fantasy,
    Antique = Enum.Font.Antique, Legacy = Enum.Font.Legacy, AmaticSC = Enum.Font.AmaticSC,
    Bangers = Enum.Font.Bangers, Creepster = Enum.Font.Creepster, DenkOne = Enum.Font.DenkOne,
    Fondamento = Enum.Font.Fondamento, FredokaOne = Enum.Font.FredokaOne,
    GrenzeGotisch = Enum.Font.GrenzeGotisch, IndieFlower = Enum.Font.IndieFlower,
    JosefinSans = Enum.Font.JosefinSans, Jura = Enum.Font.Jura, Kalam = Enum.Font.Kalam,
    LuckiestGuy = Enum.Font.LuckiestGuy, Merriweather = Enum.Font.Merriweather,
    Michroma = Enum.Font.Michroma, Nunito = Enum.Font.Nunito, Oswald = Enum.Font.Oswald,
    PatrickHand = Enum.Font.PatrickHand, PermanentMarker = Enum.Font.PermanentMarker,
    Sarpanch = Enum.Font.Sarpanch, SpecialElite = Enum.Font.SpecialElite,
    TitilliumWeb = Enum.Font.TitilliumWeb, Ubuntu = Enum.Font.Ubuntu,
}

local function fontOf(n, fb)
    return FONT_MAP[tostring(n or "")] or fb or Enum.Font.GothamBold
end

local function getHost()
    return LocalPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui
end

local function hexToColor3(hex)
    hex = tostring(hex or "#FFFFFF"):gsub("#", "")
    if #hex ~= 6 then return Color3.new(1, 1, 1) end
    return Color3.fromRGB(
        tonumber(hex:sub(1, 2), 16) or 255,
        tonumber(hex:sub(3, 4), 16) or 255,
        tonumber(hex:sub(5, 6), 16) or 255
    )
end

local function httpGetBinary(url)
    local data
    pcall(function()
        if request then
            local r = request({ Url = url, Method = "GET" })
            if r and r.Body and #r.Body > 32 then data = r.Body end
        elseif syn and syn.request then
            local r = syn.request({ Url = url, Method = "GET" })
            if r and r.Body and #r.Body > 32 then data = r.Body end
        end
    end)
    if not data then
        pcall(function()
            local d = game:HttpGet(url)
            if d and #d > 32 then data = d end
        end)
    end
    return data
end

local function resolveImageAsset(url, allowDisk)
    if type(url) ~= "string" or url == "" then return nil end
    url = url:gsub("^%s+", ""):gsub("%s+$", "")
    if url == "" then return nil end
    if url:find("^rbxasset") or url:find("^rbxthumb") then return url end
    if _N0IR_ImgCache[url] then return _N0IR_ImgCache[url] end
    if allowDisk then
        local h = 0
        for i = 1, #url do h = (h * 31 + string.byte(url, i)) % 2147483647 end
        local path = "N0IR/MyTagImg_" .. h .. ".img"
        local asset
        pcall(function()
            if isfolder and not isfolder("N0IR") then makefolder("N0IR") end
            local onDisk = isfile and isfile(path)
            if not onDisk then
                local bin = httpGetBinary(url)
                if bin and writefile then writefile(path, bin) onDisk = true end
            end
            if onDisk and getcustomasset then
                local ok, a = pcall(getcustomasset, path)
                if ok and type(a) == "string" and a ~= "" then asset = a end
            end
        end)
        if asset then _N0IR_ImgCache[url] = asset return asset end
    end
    _N0IR_ImgCache[url] = url
    return url
end

local function applyPfp(img, userId)
    if not img or not img.Parent then return end
    userId = tonumber(userId) or 0
    if userId <= 0 then return end
    local thumb = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", userId)
    local http = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png", userId)
    img.Image = thumb
    task.delay(0.2, function()
        if img and img.Parent then img.Image = http end
    end)
    task.spawn(function()
        local body = httpGetBinary(string.format(
            "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%d&size=150x150&format=Png&isCircular=false",
            userId
        ))
        if not body then return end
        local s = type(body) == "string" and body or tostring(body)
        local u = s:match('"imageUrl"%s*:%s*"(.-)"')
        if u and u ~= "" and img and img.Parent then
            img.Image = u:gsub("\\u0026", "&"):gsub("\\/", "/")
        end
    end)
end

local function resolveStyle(data)
    data = data or {}
    local st = type(data.style) == "table" and data.style or {}
    local function pick(k, d)
        local v = st[k]
        if v == nil then v = data[k] end
        if v == nil then return d end
        return v
    end

    local rank = tostring(data.rank or st.rank or "User")
    local tag = st.tag or data.tag
    local hasCustom = tag and tag ~= "" and tag ~= rank
    if not hasCustom then tag = DEFAULT_TAG end

    local c1 = st.tagColor or data.color or data.tagColor
    if not hasCustom then c1 = DEFAULT_COLOR
    elseif not c1 or c1 == "" then c1 = DEFAULT_COLOR end
    local c2 = st.tagColor2 or c1

    local textGradient = pick("textGradient", false) == true
    local textFade = pick("textFade", false) == true
    -- if studio saved two different colors, treat as gradient (1:1 with preview default)
    if not textGradient and tostring(c1):upper() ~= tostring(c2):upper() then
        textGradient = true
    end

    local prefix = tostring(pick("prefix", "") or "")
    local suffix = tostring(pick("suffix", "") or "")

    return {
        tag = prefix .. tag .. suffix,
        rank = rank,
        color = hexToColor3(c1),
        color2 = hexToColor3(c2),
        stroke = hexToColor3(pick("strokeColor", hasCustom and c1 or "#FFFFFF")),
        strokeThickness = tonumber(pick("strokeThickness", 1.2)) or 1.2,
        strokeTransparency = tonumber(pick("strokeTransparency", 0.05)) or 0.05,
        pillBg = hexToColor3(pick("pillBg", "#0C0C0C")),
        pillBg2 = hexToColor3(pick("pillBg2", "#1A1A1A")),
        pillTransparency = tonumber(pick("pillTransparency", 0.15)) or 0.15,
        pillHeight = tonumber(pick("pillHeight", 28)) or 28,
        cornerRadius = tonumber(pick("cornerRadius", 8)) or 8,
        paddingX = tonumber(pick("paddingX", 10)) or 10,
        paddingY = tonumber(pick("paddingY", 4)) or 4,
        gap = tonumber(pick("gap", 6)) or 6,
        textSize = tonumber(pick("textSize", 12)) or 12,
        scale = tonumber(pick("scale", 1)) or 1,
        offsetY = tonumber(pick("offsetY", 3.15)) or 3.15,
        maxDistance = tonumber(pick("maxDistance", 180)) or 180,
        showDot = pick("showDot", true) ~= false,
        showName = pick("showName", true) ~= false,
        showRank = pick("showRank", false) == true,
        glow = pick("glow", false) == true,
        glowStrength = tonumber(pick("glowStrength", 2)) or 2,
        nameColor = hexToColor3(pick("nameColor", "#DCDCDC")),
        rankColor = hexToColor3(pick("rankColor", "#8C8C8C")),
        nameSize = tonumber(pick("nameSize", 11)) or 11,
        rankSize = tonumber(pick("rankSize", 9)) or 9,
        font = fontOf(pick("font", "GothamBold"), Enum.Font.GothamBold),
        nameFont = fontOf(pick("nameFont", "GothamMedium"), Enum.Font.GothamMedium),
        textStroke = pick("textStroke", true) ~= false,
        textStrokeTransparency = tonumber(pick("textStrokeTransparency", 0.7)) or 0.7,
        textStrokeColor = hexToColor3(pick("textStrokeColor", "#000000")),
        textGradient = textGradient,
        textFade = textFade,
        gradientRotation = tonumber(pick("gradientRotation", 0)) or 0,
        fadeSpeed = tonumber(pick("fadeSpeed", 1.2)) or 1.2,
        pillGradient = pick("pillGradient", false) == true,
        iconType = tostring(pick("iconType", "none") or "none"):lower(),
        iconUrl = tostring(pick("iconUrl", "") or ""),
        iconSize = tonumber(pick("iconSize", 18)) or 18,
        pfpSize = tonumber(pick("pfpSize", 18)) or 18,
        bgImageUrl = tostring(pick("bgImageUrl", "") or ""),
        bgTransparency = tonumber(pick("bgTransparency", 0.4)) or 0.4,
        bob = pick("bob", false) == true,
        bobSpeed = tonumber(pick("bobSpeed", 1.5)) or 1.5,
        bobAmount = tonumber(pick("bobAmount", 0.12)) or 0.12,
        pulse = pick("pulse", false) == true,
        alwaysOnTop = pick("alwaysOnTop", true) ~= false,
        dotSize = tonumber(pick("dotSize", 7)) or 7,
    }
end

function Nametag:Create(player, data)
    if not player or not player.Parent then return end
    if player == LocalPlayer then
        if not self.ShowSelf then return end
    else
        if not self.ShowOthers then return end
    end
    self:Remove(player)

    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head then return end

    if not self.Folder or not self.Folder.Parent then
        self.Folder = Instance.new("Folder")
        self.Folder.Name = "N0IR_Nametags"
        self.Folder.Parent = getHost()
    end

    local S = resolveStyle(data)
    local isSelf = player == LocalPlayer
    local sc = math.clamp(S.scale, 0.7, 1.6)

    local stackH = S.pillHeight
    if S.showName then stackH = stackH + 6 + 16 end
    if S.showRank then stackH = stackH + 4 + 12 end

    local bb = Instance.new("BillboardGui")
    bb.Name = "N0IR_Tag_" .. player.Name
    bb.Adornee = head
    bb.AlwaysOnTop = S.alwaysOnTop
    bb.Size = UDim2.fromOffset(math.floor(320 * sc), math.floor((stackH + 16) * sc))
    bb.StudsOffset = Vector3.new(0, S.offsetY, 0)
    bb.MaxDistance = S.maxDistance
    bb.Parent = self.Folder

    local root = Instance.new("Frame")
    root.Name = "Root"
    root.BackgroundTransparency = 1
    root.Size = UDim2.fromScale(1, 1)
    root.Parent = bb

    local uiScale = Instance.new("UIScale")
    uiScale.Scale = sc
    uiScale.Parent = root

    local vlist = Instance.new("UIListLayout")
    vlist.FillDirection = Enum.FillDirection.Vertical
    vlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
    vlist.VerticalAlignment = Enum.VerticalAlignment.Top
    vlist.Padding = UDim.new(0, 6)
    vlist.SortOrder = Enum.SortOrder.LayoutOrder
    vlist.Parent = root

    -- optional bg image behind stack
    if S.bgImageUrl ~= "" then
        local bg = Instance.new("ImageLabel")
        bg.Name = "Bg"
        bg.BackgroundTransparency = 1
        bg.Size = UDim2.fromOffset(220, stackH + 8)
        bg.ImageTransparency = S.bgTransparency
        bg.ScaleType = Enum.ScaleType.Crop
        bg.ZIndex = 0
        bg.LayoutOrder = 0
        bg.Parent = root
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)
        bg.Image = S.bgImageUrl
        task.spawn(function()
            local a = resolveImageAsset(S.bgImageUrl, isSelf)
            if a and bg.Parent then bg.Image = a end
        end)
    end

    -- PILL
    local pill = Instance.new("Frame")
    pill.Name = "Pill"
    pill.AutomaticSize = Enum.AutomaticSize.X
    pill.Size = UDim2.fromOffset(0, S.pillHeight)
    pill.BackgroundColor3 = S.pillBg
    pill.BackgroundTransparency = S.pillTransparency
    pill.BorderSizePixel = 0
    pill.ZIndex = 2
    pill.LayoutOrder = 1
    pill.Parent = root
    Instance.new("UICorner", pill).CornerRadius = UDim.new(0, S.cornerRadius)

    if S.pillGradient then
        pill.BackgroundColor3 = Color3.new(1, 1, 1)
        local pg = Instance.new("UIGradient")
        pg.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, S.pillBg),
            ColorSequenceKeypoint.new(1, S.pillBg2),
        })
        pg.Rotation = 90
        pg.Parent = pill
    end

    local stroke = Instance.new("UIStroke")
    stroke.Color = S.stroke
    stroke.Thickness = S.strokeThickness
    stroke.Transparency = S.strokeTransparency
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = pill

    if S.glow then
        local g = Instance.new("UIStroke")
        g.Name = "Glow"
        g.Color = S.color
        g.Thickness = S.strokeThickness + S.glowStrength
        g.Transparency = 0.55
        g.Parent = pill
    end

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, S.paddingX)
    pad.PaddingRight = UDim.new(0, S.paddingX)
    pad.PaddingTop = UDim.new(0, S.paddingY)
    pad.PaddingBottom = UDim.new(0, S.paddingY)
    pad.Parent = pill

    local row = Instance.new("UIListLayout")
    row.FillDirection = Enum.FillDirection.Horizontal
    row.HorizontalAlignment = Enum.HorizontalAlignment.Center
    row.VerticalAlignment = Enum.VerticalAlignment.Center
    row.Padding = UDim.new(0, S.gap)
    row.Parent = pill

    local showMedia = false
    local mediaSize = S.iconSize
    if S.iconType == "pfp" then
        showMedia, mediaSize = true, S.pfpSize
    elseif (S.iconType == "custom" or S.iconType == "gif") and S.iconUrl ~= "" then
        showMedia, mediaSize = true, S.iconSize
    end

    if showMedia then
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.fromOffset(mediaSize, mediaSize)
        icon.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        icon.BackgroundTransparency = 0
        icon.BorderSizePixel = 0
        icon.ScaleType = Enum.ScaleType.Crop
        icon.ZIndex = 3
        icon.Parent = pill
        local ic = Instance.new("UICorner")
        ic.CornerRadius = S.iconType == "pfp" and UDim.new(1, 0) or UDim.new(0, 6)
        ic.Parent = icon
        if S.iconType == "pfp" then
            applyPfp(icon, player.UserId)
        else
            icon.Image = S.iconUrl
            task.spawn(function()
                local a = resolveImageAsset(S.iconUrl, isSelf)
                if a and icon.Parent then icon.Image = a end
            end)
        end
    elseif S.showDot then
        local dot = Instance.new("Frame")
        dot.Name = "Dot"
        dot.Size = UDim2.fromOffset(S.dotSize, S.dotSize)
        dot.BackgroundColor3 = S.color
        dot.BorderSizePixel = 0
        dot.ZIndex = 3
        dot.Parent = pill
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    end

    local label = Instance.new("TextLabel")
    label.Name = "Tag"
    label.BackgroundTransparency = 1
    label.AutomaticSize = Enum.AutomaticSize.X
    label.Size = UDim2.fromOffset(0, 20)
    label.Font = S.font
    label.TextSize = S.textSize
    label.Text = S.tag
    label.ZIndex = 3
    label.Parent = pill

    if S.textGradient or S.textFade then
        label.TextColor3 = Color3.new(1, 1, 1)
        local grad = Instance.new("UIGradient")
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, S.color),
            ColorSequenceKeypoint.new(0.5, S.color2),
            ColorSequenceKeypoint.new(1, S.color),
        })
        grad.Rotation = S.gradientRotation
        grad.Parent = label
        if S.textFade then
            task.spawn(function()
                local t0 = tick()
                while label.Parent and bb.Parent do
                    grad.Rotation = S.gradientRotation + ((tick() - t0) * S.fadeSpeed * 50) % 360
                    task.wait(0.03)
                end
            end)
        end
    else
        label.TextColor3 = S.color
    end

    if S.textStroke then
        label.TextStrokeColor3 = S.textStrokeColor
        label.TextStrokeTransparency = S.textStrokeTransparency
    else
        label.TextStrokeTransparency = 1
    end

    if S.showName then
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Name = "DisplayName"
        nameLbl.BackgroundTransparency = 1
        nameLbl.Size = UDim2.fromOffset(220, 16)
        nameLbl.Font = S.nameFont
        nameLbl.TextSize = S.nameSize
        nameLbl.TextColor3 = S.nameColor
        nameLbl.TextStrokeTransparency = 0.4
        nameLbl.Text = player.DisplayName
        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        nameLbl.ZIndex = 2
        nameLbl.LayoutOrder = 2
        nameLbl.Parent = root
    end

    if S.showRank then
        local rankLbl = Instance.new("TextLabel")
        rankLbl.Name = "Rank"
        rankLbl.BackgroundTransparency = 1
        rankLbl.Size = UDim2.fromOffset(220, 12)
        rankLbl.Font = Enum.Font.Gotham
        rankLbl.TextSize = S.rankSize
        rankLbl.TextColor3 = S.rankColor
        rankLbl.Text = S.rank
        rankLbl.ZIndex = 2
        rankLbl.LayoutOrder = 3
        rankLbl.Parent = root
    end

    if S.bob or S.pulse then
        task.spawn(function()
            local base = S.offsetY
            local t0 = tick()
            while bb.Parent do
                local t = tick() - t0
                local y = base
                if S.bob then y = base + math.sin(t * S.bobSpeed * 3) * S.bobAmount end
                bb.StudsOffset = Vector3.new(0, y, 0)
                if S.pulse then uiScale.Scale = sc * (1 + math.sin(t * 3) * 0.04) end
                task.wait(0.03)
            end
        end)
    end

    self.Tags[player] = bb

    if not player:GetAttribute("N0IR_TagHooked") then
        player:SetAttribute("N0IR_TagHooked", true)
        player.CharacterRemoving:Connect(function() self:Remove(player) end)
        player.CharacterAdded:Connect(function()
            task.wait(0.8)
            local d = self.PlayerData[tostring(player.UserId)]
            if d then self:Create(player, d) end
        end)
    end
end

function Nametag:Remove(player)
    local t = self.Tags[player]
    if t then
        pcall(function() t:Destroy() end)
        self.Tags[player] = nil
    end
end

function Nametag:SetShowSelf(on)
    self.ShowSelf = on and true or false
    if self.ShowSelf and self.MyData then
        self:ApplyPlayer(LocalPlayer, self.MyData)
    else
        self:Remove(LocalPlayer)
    end
end

function Nametag:SetShowOthers(on)
    self.ShowOthers = on and true or false
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local uid = tostring(plr.UserId)
            local d = self.PlayerData[uid]
            if self.ShowOthers and d then
                self:ApplyPlayer(plr, d)
            else
                self:Remove(plr)
            end
        end
    end
end


function Nametag:Clear()
    for plr in pairs(self.Tags) do
        self:Remove(plr)
    end
    if self.Folder then
        pcall(function() self.Folder:Destroy() end)
        self.Folder = nil
    end
end

function Nametag:ApplyPlayer(player, data)
    if not player then return end
    if not data then
        self:Remove(player)
        return
    end
    self:Create(player, data)
end

function Nametag:SyncFromMap(tagMap)
    tagMap = tagMap or {}
    -- merge into cache
    for uid, data in pairs(tagMap) do
        self.PlayerData[tostring(uid)] = {
            tag = data.tag,
            rank = data.rank,
            color = data.color or data.tagColor,
            style = data.style,
        }
    end
    -- apply / remove for everyone in server
    for _, plr in ipairs(Players:GetPlayers()) do
        local uid = tostring(plr.UserId)
        local d = self.PlayerData[uid]
        local allow = (plr == LocalPlayer and self.ShowSelf) or (plr ~= LocalPlayer and self.ShowOthers)
        if d and allow then
            task.spawn(function()
                self:ApplyPlayer(plr, d)
            end)
        else
            self:Remove(plr)
        end
    end
end

function Nametag:FetchAndSync()
    if self._refreshing then return end
    self._refreshing = true
    task.spawn(function()
        local ids = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            table.insert(ids, plr.UserId)
        end
        if #ids == 0 then
            self._refreshing = false
            return
        end

        local result = httpPost(API_URL .. "/api/nametags", { userIds = ids })
        if result and result.success and type(result.tags) == "table" then
            -- ensure we always have ourselves if MyData exists (offline edge)
            local map = {}
            for uid, d in pairs(result.tags) do
                map[tostring(uid)] = d
            end
            if self.MyData then
                local me = tostring(LocalPlayer.UserId)
                if not map[me] then
                    map[me] = self.MyData
                end
            end
            self:SyncFromMap(map)
        elseif self.MyData then
            -- API fail → at least show own tag
            self.PlayerData[tostring(LocalPlayer.UserId)] = self.MyData
            self:ApplyPlayer(LocalPlayer, self.MyData)
        end
        self._refreshing = false
    end)
end

function Nametag:SetMyData(data)
    self.MyData = data
    if data then
        self.PlayerData[tostring(LocalPlayer.UserId)] = data
    end
    self:FetchAndSync()
end

function Nametag:Start()
    if self._started then return end
    self._started = true

    Players.PlayerAdded:Connect(function(plr)
        task.delay(1.5, function()
            self:FetchAndSync()
        end)
    end)

    Players.PlayerRemoving:Connect(function(plr)
        self:Remove(plr)
        self.PlayerData[tostring(plr.UserId)] = nil
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if self.MyData and self.ShowSelf then
            self:ApplyPlayer(LocalPlayer, self.MyData)
        end
    end)

    -- periodic refresh so tag edits on the website appear in-game
    task.spawn(function()
        while self._started do
            task.wait(self.RefreshSeconds)
            if self.MyData then
                self:FetchAndSync()
            end
        end
    end)

    task.defer(function()
        self:FetchAndSync()
    end)
end

local function showKeyUI(onSuccess)
    local host = getHost()
    local old = host:FindFirstChild("N0IR_KeyUI")
    if old then old:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name = "N0IR_KeyUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999999
    gui.Parent = host
    local veil = Instance.new("Frame")
    veil.Size = UDim2.fromScale(1, 1)
    veil.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    veil.BackgroundTransparency = 0.35
    veil.BorderSizePixel = 0
    veil.Parent = gui
    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.Size = UDim2.fromOffset(340, 220)
    card.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    card.BorderSizePixel = 0
    card.Parent = gui
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)
    local s = Instance.new("UIStroke", card)
    s.Color = Color3.fromRGB(45, 45, 45)
    s.Thickness = 1
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(0, 24)
    title.Size = UDim2.new(1, 0, 0, 28)
    title.Font = Enum.Font.GothamBold
    title.Text = "NØIR"
    title.TextSize = 22
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Parent = card
    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.fromOffset(0, 54)
    sub.Size = UDim2.new(1, 0, 0, 18)
    sub.Font = Enum.Font.Gotham
    sub.Text = "Enter your key to continue"
    sub.TextSize = 12
    sub.TextColor3 = Color3.fromRGB(140, 140, 140)
    sub.Parent = card
    local box = Instance.new("TextBox")
    box.Position = UDim2.fromOffset(28, 90)
    box.Size = UDim2.new(1, -56, 0, 36)
    box.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    box.BorderSizePixel = 0
    box.Font = Enum.Font.Gotham
    box.PlaceholderText = "N0IR-XXXXXXXXXXXXXXXX"
    box.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
    box.Text = ""
    box.TextSize = 13
    box.TextColor3 = Color3.fromRGB(240, 240, 240)
    box.ClearTextOnFocus = false
    box.Parent = card
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
    local status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.Position = UDim2.fromOffset(28, 132)
    status.Size = UDim2.new(1, -56, 0, 16)
    status.Font = Enum.Font.Gotham
    status.Text = ""
    status.TextSize = 11
    status.TextColor3 = Color3.fromRGB(180, 180, 180)
    status.Parent = card
    local btn = Instance.new("TextButton")
    btn.Position = UDim2.fromOffset(28, 160)
    btn.Size = UDim2.new(1, -56, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.Text = "Unlock"
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(10, 10, 10)
    btn.AutoButtonColor = false
    btn.Parent = card
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local function setStatus(text, isError)
        status.Text = text
        status.TextColor3 = isError and Color3.fromRGB(200, 80, 80) or Color3.fromRGB(80, 200, 120)
    end
    local busy = false
    local function tryUnlock()
        if busy then return end
        local key = box.Text:gsub("%s+", "")
        if key == "" then setStatus("Enter a key", true) return end
        busy = true
        btn.Text = "Checking..."
        setStatus("Validating with server...", false)
        task.spawn(function()
            local result = validateKey(key)
            if result.success then
                saveKey(key)
                applyAuthData(result)
                setStatus("✓ Welcome · " .. (result.rank or "User"), false)
                btn.Text = "Unlocked"
                task.wait(0.55)
                gui:Destroy()
                if onSuccess then onSuccess(result) end
            else
                setStatus("✗ " .. (result.message or "Invalid key"), true)
                btn.Text = "Unlock"
                busy = false
            end
        end)
    end
    btn.MouseButton1Click:Connect(tryUnlock)
    box.FocusLost:Connect(function(enter) if enter then tryUnlock() end end)
    local saved = loadSavedKey()
    if saved then box.Text = saved end
    return gui
end


local function applyAuthData(result)
    if not result or not result.success then return end
    local rank = result.rank or "User"
    local tag = result.tag
    local color = result.tagColor or result.color
    if tag == rank or tag == "" then tag = nil end
    local data = {
        tag = tag,
        rank = rank,
        color = color,
        style = result.style,
    }
    Nametag:Start()
    Nametag:SetMyData(data)
end

local function requireKey(opts)
    opts = opts or {}

    -- 1) KEY set by user before execute:
    --    KEY = "N0IR-XXXX"
    --    local N0IR = loadstring(...)()
    --    N0IR:Init(...)
    local fromScript = rawget(_G, "KEY") or rawget(_G, "N0IR_KEY")
    if type(fromScript) == "string" and fromScript ~= "" then
        fromScript = fromScript:gsub("%s+", "")
        -- strip optional KEY:"..." / KEY = "..." leftovers
        fromScript = fromScript:gsub('^[Kk][Ee][Yy]%s*[:=]%s*"?', ""):gsub('"$', "")
        local result = validateKey(fromScript)
        if result.success then
            saveKey(fromScript)
            applyAuthData(result)
            return true, result
        else
            warn("[NØIR] KEY invalid: " .. tostring(result.message))
            -- fall through to saved / UI
        end
    end

    -- 2) previously saved key on disk
    local saved = loadSavedKey()
    if saved then
        local result = validateKey(saved)
        if result.success then
            applyAuthData(result)
            return true, result
        end
    end

    -- 3) popup UI fallback
    local done, finalResult = false, nil
    showKeyUI(function(result)
        finalResult = result
        done = true
        task.defer(function() if Nametag.MyData then Nametag:FetchAndSync() end end)
    end)
    while not done do task.wait(0.1) end
    return true, finalResult
end

_G.N0IR_Nametag = Nametag
_G.N0IR_RequireKey = requireKey

-- ============================================================
-- NØIR UI LIBRARY
-- ============================================================
local N0IR = {
    Version = "1.0.0",
    Flags = {},
    _windows = {},
}


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
-- NØIR SHARED BRAND  (UI LIBRARY OWNS THIS — change once, all suites follow)
-- Reanim / Animator / future modules MUST use:
--   _G._N0IR_EnsureLogoAsset()
--   _G._N0IR_Brand
-- ============================================================
_G._N0IR_Brand = {
    -- >>> CHANGE LOGO HERE ONLY <<<
    LogoUrl  = "https://raw.githubusercontent.com/H1tss/extras/refs/heads/main/D27xi.png",
    LogoPath = "N0IR/Logo_D27xi.png",
    LogoDir  = "N0IR",
    -- Background pack (owned here — reanim / animator consume via _G)
    BgIndex  = tonumber(_G._N0IR_Brand and _G._N0IR_Brand.BgIndex) or 1, -- 0 = none, 1..n = pack entry
    BgTransparency = 0.42,
    Backgrounds = {
        { Name = "Clouds With Black Sky",  Url = "https://raw.githubusercontent.com/H1tss/extras/refs/heads/main/download%20(3).jfif",  Path = "N0IR/Bg_03.jfif" },
        { Name = "Minecraft Endermen B&W",  Url = "https://raw.githubusercontent.com/H1tss/extras/refs/heads/main/download%20(4).jfif",  Path = "N0IR/Bg_04.jfif" },
        { Name = "Flowers B&W",  Url = "https://raw.githubusercontent.com/H1tss/extras/refs/heads/main/download%20(5).jfif",  Path = "N0IR/Bg_05.jfif" },
        { Name = "Attack On Titan Snake",  Url = "https://raw.githubusercontent.com/H1tss/extras/refs/heads/main/download%20(6).jfif",  Path = "N0IR/Bg_06.jfif" },
        { Name = "Creepy Girl",  Url = "https://raw.githubusercontent.com/H1tss/extras/refs/heads/main/download%20(7).jfif",  Path = "N0IR/Bg_07.jfif" },
        { Name = "DONT STOP B&W",  Url = "https://raw.githubusercontent.com/H1tss/extras/refs/heads/main/download%20(8).jfif",  Path = "N0IR/Bg_08.jfif" },
        { Name = "Above Clouds",  Url = "https://raw.githubusercontent.com/H1tss/extras/refs/heads/main/download%20(9).jfif",  Path = "N0IR/Bg_09.jfif" },
        { Name = "Above Clouds With Moon", Url = "https://raw.githubusercontent.com/H1tss/extras/refs/heads/main/download%20(10).jfif", Path = "N0IR/Bg_10.jfif" },
        { Name = "Monster Can", Url = "https://raw.githubusercontent.com/H1tss/extras/refs/heads/main/download%20(11).jfif", Path = "N0IR/Bg_11.jfif" },
    },
}

_G._N0IR_BgCache = _G._N0IR_BgCache or {}
_G._N0IR_BgTargets = _G._N0IR_BgTargets or {}

local function _n0irCacheHttpAsset(url, path, dir, cacheKey, force)
    if not force and cacheKey and _G._N0IR_BgCache[cacheKey] then
        return _G._N0IR_BgCache[cacheKey]
    end
    dir = dir or "N0IR"
    local onDisk = false
    pcall(function()
        if isfolder and not isfolder(dir) then makefolder(dir) end
        if isfile and isfile(path) then onDisk = true end
    end)
    if force or not onDisk then
        local ok, data = pcall(function() return game:HttpGet(url) end)
        if ok and data and #data > 100 then
            pcall(function()
                if isfolder and not isfolder(dir) then makefolder(dir) end
                if writefile then writefile(path, data) end
            end)
            onDisk = true
        end
    end
    if onDisk and getcustomasset then
        local ok, asset = pcall(getcustomasset, path)
        if ok and type(asset) == "string" and asset ~= "" then
            if cacheKey then _G._N0IR_BgCache[cacheKey] = asset end
            return asset
        end
    end
    if cacheKey then _G._N0IR_BgCache[cacheKey] = url end
    return url
end

_G._N0IR_EnsureLogoAsset = function(force)
    if force then
        _G._N0IR_LogoWM = nil
    end
    if _G._N0IR_LogoWM then
        return _G._N0IR_LogoWM
    end
    local cfg  = _G._N0IR_Brand or {}
    local url  = cfg.LogoUrl or "https://raw.githubusercontent.com/H1tss/extras/refs/heads/main/D27xi.png"
    local dir  = cfg.LogoDir or "N0IR"
    local path = cfg.LogoPath or "N0IR/Logo_D27xi.png"
    local asset = _n0irCacheHttpAsset(url, path, dir, nil, force)
    _G._N0IR_LogoWM = asset
    return asset
end

_G._N0IR_ForceLogo = function()
    _G._N0IR_LogoWM = nil
    pcall(function()
        local path = (_G._N0IR_Brand and _G._N0IR_Brand.LogoPath) or "N0IR/Logo_D27xi.png"
        if isfile and isfile(path) and delfile then delfile(path) end
    end)
    return _G._N0IR_EnsureLogoAsset(true)
end

-- index: 1..n from Backgrounds pack
_G._N0IR_EnsureBgAsset = function(index, force)
    local cfg = _G._N0IR_Brand or {}
    local list = cfg.Backgrounds or {}
    index = tonumber(index) or 1
    local entry = list[index]
    if not entry then return nil end
    local key = "bg_" .. tostring(index)
    if force then _G._N0IR_BgCache[key] = nil end
    return _n0irCacheHttpAsset(entry.Url, entry.Path, cfg.LogoDir or "N0IR", key, force)
end

_G._N0IR_RegisterBgTarget = function(img)
    if not img then return end
    _G._N0IR_BgTargets = _G._N0IR_BgTargets or {}
    -- prune dead refs
    local alive = {}
    for _, t in ipairs(_G._N0IR_BgTargets) do
        if t and t.Parent then table.insert(alive, t) end
    end
    table.insert(alive, img)
    _G._N0IR_BgTargets = alive
end

_G._N0IR_SetBackground = function(index)
    local cfg = _G._N0IR_Brand or {}
    index = math.floor(tonumber(index) or 0)
    local list = cfg.Backgrounds or {}
    if index < 0 then index = 0 end
    if index > #list then index = #list end
    cfg.BgIndex = index
    _G._N0IR_Brand = cfg

    local asset = nil
    if index > 0 then
        asset = _G._N0IR_EnsureBgAsset(index)
    end
    local trans = tonumber(cfg.BgTransparency) or 0.42

    for _, img in ipairs(_G._N0IR_BgTargets or {}) do
        if img and img.Parent then
            if index <= 0 or not asset then
                img.Image = ""
                img.Visible = false
            else
                img.Image = asset
                img.ImageTransparency = trans
                img.Visible = true
            end
        end
    end
    if _G._N0IR_SaveSettings then task.defer(_G._N0IR_SaveSettings) end
    return index
end

_G._N0IR_NextBackground = function()
    local cfg = _G._N0IR_Brand or {}
    local list = cfg.Backgrounds or {}
    local n = #list
    if n == 0 then return 0 end
    local i = tonumber(cfg.BgIndex) or 0
    i = i + 1
    if i > n then i = 0 end -- wraps to none
    return _G._N0IR_SetBackground(i)
end

local function ensureLogoAsset(force)
    return _G._N0IR_EnsureLogoAsset(force)
end

local function attachWindowBackground(parent, radius)
    radius = radius or 12
    local bg = Instance.new("ImageLabel")
    bg.Name = "N0IR_Bg"
    bg.BackgroundTransparency = 1
    bg.Size = UDim2.fromScale(1, 1)
    bg.Position = UDim2.fromScale(0, 0)
    bg.ScaleType = Enum.ScaleType.Crop
    bg.ImageTransparency = (_G._N0IR_Brand and _G._N0IR_Brand.BgTransparency) or 0.42
    bg.ZIndex = 0
    bg.Visible = false
    bg.Parent = parent
    do
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius)
        c.Parent = bg
    end
    -- dim overlay so controls stay readable (same rounded corners)
    local veil = Instance.new("Frame")
    veil.Name = "N0IR_BgVeil"
    veil.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    veil.BackgroundTransparency = 0.35
    veil.BorderSizePixel = 0
    veil.Size = UDim2.fromScale(1, 1)
    veil.ZIndex = 0
    veil.Parent = parent
    do
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius)
        c.Parent = veil
    end
    _G._N0IR_RegisterBgTarget(bg)
    local idx = (_G._N0IR_Brand and tonumber(_G._N0IR_Brand.BgIndex)) or 1
    task.defer(function()
        _G._N0IR_SetBackground(idx)
    end)
    return bg
end

-- ============================================================
-- SETTINGS PERSISTENCE  (N0IR/settings.json)
-- Executor-safe keycode encode/decode (no typeof EnumItem dependency)
-- ============================================================
local SETTINGS_PATH = "N0IR/settings.json"
local KEYBINDS_PATH = "N0IR/keybinds.json"

local function _n0irKeyName(k)
    if k == nil then return nil end
    if type(k) == "string" and k ~= "" then return k end
    local ok, name = pcall(function() return k.Name end)
    if ok and type(name) == "string" and name ~= "" then return name end
    local s = tostring(k)
    local m = string.match(s, "KeyCode%.(%w+)$") or string.match(s, "%.(%w+)$")
    return m
end

local function _n0irKeyFromName(name)
    if type(name) ~= "string" or name == "" then return nil end
    local ok, key = pcall(function() return Enum.KeyCode[name] end)
    if ok and key ~= nil then return key end
    return nil
end

local function _n0irSaveSettings()
    local ok, err = pcall(function()
        if makefolder and isfolder and not isfolder("N0IR") then
            makefolder("N0IR")
        elseif makefolder then
            pcall(makefolder, "N0IR")
        end
        local HttpService = game:GetService("HttpService")
        local flags = {}
        for k, v in pairs(N0IR.Flags or {}) do
            local tv = type(v)
            if tv == "boolean" or tv == "number" or tv == "string" then
                flags[tostring(k)] = v
            end
        end
        local brand = _G._N0IR_Brand or {}
        local toggleName = _n0irKeyName(_G._N0IR_ToggleKey) or "M"
        local cmdName = _n0irKeyName(_G._N0IR_CmdBarKey) or "Semicolon"
        local tpKeyName = _n0irKeyName(_G._N0IRTeleportKey) or "NONE"
        local data = {
            ToggleKey = toggleName,
            CmdBarKey = cmdName,
            CmdPrefix = tostring(_G._N0IR_CmdPrefix or ";"),
            TeleportKey = tpKeyName,
            TPKeybindEnabled = (_G._N0IR_TPKeybindEnabled ~= false),
            BgIndex = tonumber(brand.BgIndex) or 1,
            BgTransparency = tonumber(brand.BgTransparency) or 0.42,
            Flags = flags,
            DragEnabled = _G._N0IRDragEnabled,
            SmoothDrag = _G._N0IRSmoothDrag,
            TabGridMode = _G._N0IRTabGridMode,
            FriendLeftNotify = _G._N0IR_FriendLeftNotify,
            AutoExec = _G._N0IR_AutoExec or {},
        }
        local encoded = HttpService:JSONEncode(data)
        assert(writefile, "writefile missing")
        writefile(SETTINGS_PATH, encoded)
        writefile(KEYBINDS_PATH, HttpService:JSONEncode({
            ToggleKey = toggleName,
            CmdBarKey = cmdName,
            CmdPrefix = data.CmdPrefix,
        }))
        -- also stash on _G so same-session always has it even if disk fails next time
        _G._N0IR_SavedToggleKeyName = toggleName
        _G._N0IR_SavedCmdBarKeyName = cmdName
        _G._N0IR_SavedTeleportKeyName = tpKeyName
    end)
    if not ok then
        warn("[N0IR] SaveSettings failed: ", err)
    end
    return ok
end
_G._N0IR_SaveSettings = _n0irSaveSettings
_G._N0IR_SaveKeybinds = _n0irSaveSettings

local function _n0irLoadSettings()
    local ok, err = pcall(function()
        local HttpService = game:GetService("HttpService")
        local raw
        if isfile and isfile(SETTINGS_PATH) then
            raw = readfile(SETTINGS_PATH)
        elseif isfile and isfile(KEYBINDS_PATH) then
            raw = readfile(KEYBINDS_PATH)
        end
        -- fall back to in-memory names from earlier in the same session
        local toggleName, cmdName
        if raw and raw ~= "" then
            local data = HttpService:JSONDecode(raw)
            if type(data) == "table" then
                toggleName = data.ToggleKey
                cmdName = data.CmdBarKey
                if type(data.CmdPrefix) == "string" and data.CmdPrefix ~= "" then
                    _G._N0IR_CmdPrefix = data.CmdPrefix
                end
                if data.BgIndex ~= nil then
                    _G._N0IR_Brand = _G._N0IR_Brand or {}
                    _G._N0IR_Brand.BgIndex = tonumber(data.BgIndex) or 1
                end
                if data.BgTransparency ~= nil then
                    _G._N0IR_Brand = _G._N0IR_Brand or {}
                    _G._N0IR_Brand.BgTransparency = tonumber(data.BgTransparency) or 0.42
                end
                if type(data.Flags) == "table" then
                    N0IR.Flags = N0IR.Flags or {}
                    for k, v in pairs(data.Flags) do
                        N0IR.Flags[k] = v
                    end
                end
                if data.DragEnabled ~= nil then _G._N0IRDragEnabled = data.DragEnabled end
                if data.SmoothDrag ~= nil then _G._N0IRSmoothDrag = data.SmoothDrag end
                if data.TabGridMode ~= nil then _G._N0IRTabGridMode = data.TabGridMode end
                if data.FriendLeftNotify ~= nil then _G._N0IR_FriendLeftNotify = data.FriendLeftNotify end
                if type(data.AutoExec) == "table" then
                    _G._N0IR_AutoExec = data.AutoExec
                end
                if data.TPKeybindEnabled ~= nil then
                    _G._N0IR_TPKeybindEnabled = data.TPKeybindEnabled and true or false
                    N0IR.Flags = N0IR.Flags or {}
                    N0IR.Flags.TPKeybindEnabled = _G._N0IR_TPKeybindEnabled
                end
                if type(data.TeleportKey) == "string" and data.TeleportKey ~= "" then
                    if data.TeleportKey == "NONE" then
                        _G._N0IRTeleportKey = nil
                    else
                        local tpk = _n0irKeyFromName(data.TeleportKey)
                        if tpk then _G._N0IRTeleportKey = tpk end
                    end
                    _G._N0IR_SavedTeleportKeyName = data.TeleportKey
                end
            end
        end
        toggleName = toggleName or _G._N0IR_SavedToggleKeyName
        cmdName = cmdName or _G._N0IR_SavedCmdBarKeyName
        local tk = _n0irKeyFromName(toggleName)
        if tk then _G._N0IR_ToggleKey = tk end
        local ck = _n0irKeyFromName(cmdName)
        if ck then _G._N0IR_CmdBarKey = ck end
        if _G._N0IR_TPKeybindEnabled == nil then _G._N0IR_TPKeybindEnabled = true end
        if _G._N0IRTeleportKey == nil and type(_G._N0IR_SavedTeleportKeyName) == "string"
            and _G._N0IR_SavedTeleportKeyName ~= "" and _G._N0IR_SavedTeleportKeyName ~= "NONE" then
            local tpk2 = _n0irKeyFromName(_G._N0IR_SavedTeleportKeyName)
            if tpk2 then _G._N0IRTeleportKey = tpk2 end
        end
    end)
    if not ok then
        warn("[N0IR] LoadSettings failed: ", err)
    end
end
_G._N0IR_LoadSettings = _n0irLoadSettings
_n0irLoadSettings()

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
    stack.Size = UDim2.fromOffset(320, 200)
    stack.BackgroundTransparency = 1
    stack.Parent = gui

    -- Logo only (wordmark already says NØIR — no title text)
    local logo = Instance.new("ImageLabel")
    logo.Name = "Logo"
    logo.AnchorPoint = Vector2.new(0.5, 0)
    logo.Position = UDim2.new(0.5, 0, 0, 0)
    logo.Size = UDim2.fromOffset(120, 120)
    logo.BackgroundTransparency = 1
    logo.Image = ensureLogoAsset()
    logo.ImageTransparency = 1
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Parent = stack

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.fromOffset(0, 118)
    sub.Size = UDim2.new(1, 0, 0, 18)
    sub.Font = Enum.Font.GothamMedium
    sub.Text = subtitle
    sub.TextSize = 13
    sub.TextColor3 = T.text3
    sub.TextTransparency = 1
    sub.Parent = stack

    local place = Instance.new("TextLabel")
    place.BackgroundTransparency = 1
    place.Position = UDim2.fromOffset(0, 138)
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
    track.Position = UDim2.fromOffset(0, 164)
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
    pct.Position = UDim2.fromOffset(0, 172)
    pct.Size = UDim2.new(1, 0, 0, 16)
    pct.Font = Enum.Font.Code
    pct.Text = "0%"
    pct.TextSize = 11
    pct.TextColor3 = T.text3
    pct.TextTransparency = 1
    pct.Parent = stack

    -- Fade in
    tween(veil, { BackgroundTransparency = 0.45 }, 0.4)
    tween(logo, { ImageTransparency = 0 }, 0.4)
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
                tween(logo, { ImageTransparency = 1 }, 0.35)
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
    attachWindowBackground(win, 12)

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

    -- Title bar logo only (wordmark already says NØIR)
    local titleLogo = Instance.new("ImageLabel")
    titleLogo.Name = "Logo"
    titleLogo.AnchorPoint = Vector2.new(0, 0.5)
    titleLogo.Position = UDim2.new(0, 12, 0.5, 0)
    titleLogo.Size = UDim2.fromOffset(42, 42)
    titleLogo.BackgroundTransparency = 1
    titleLogo.Image = ensureLogoAsset()
    titleLogo.ScaleType = Enum.ScaleType.Fit
    titleLogo.Parent = titleBar

    -- Optional subtitle only (never repeat NØIR / N0IR brand text)
    if subTitle ~= "" then
        local subLbl = Instance.new("TextLabel")
        subLbl.BackgroundTransparency = 1
        subLbl.Position = UDim2.fromOffset(58, 0)
        subLbl.Size = UDim2.new(0, 200, 1, 0)
        subLbl.Font = Enum.Font.GothamMedium
        subLbl.Text = subTitle
        subLbl.TextSize = 11
        subLbl.TextColor3 = T.text3
        subLbl.TextXAlignment = Enum.TextXAlignment.Left
        subLbl.Parent = titleBar
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
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.Parent = tabStrip
    padding(tabStrip, 4, 4, 6, 6)
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

    local function setTabOutline(btn, on, soft)
        local box = btn and btn:FindFirstChild("OutlineBox")
        if not box then return end
        local s = box:FindFirstChild("Stroke") or box:FindFirstChildOfClass("UIStroke")
        if not s then return end
        local goal = on and (soft and 0.55 or 0) or 1
        TweenService:Create(s, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Transparency = goal,
        }):Play()
    end

    function Window:CreateTab(tabOpts)
        tabOpts = tabOpts or {}
        local name = tabOpts.Name or "Tab"
        local order = tabOpts.Order or (#self.Tabs + 1)

        -- Match reanim tab style: transparent fill + rounded outline + text color tween
        local inactiveCol = Color3.fromRGB(100, 100, 108)
        local hoverCol = Color3.fromRGB(180, 180, 185)
        local activeCol = Color3.fromRGB(235, 235, 240)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.fromOffset(0, 22)
        btn.AutomaticSize = Enum.AutomaticSize.X
        btn.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
        btn.BackgroundTransparency = 1
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamBold
        btn.Text = "  " .. name .. "  "
        btn.TextSize = 11
        btn.TextColor3 = inactiveCol
        btn.AutoButtonColor = false
        btn.LayoutOrder = order
        btn.Parent = tabStrip
        do
            local box = Instance.new("Frame")
            box.Name = "OutlineBox"
            box.Parent = btn
            box.BackgroundTransparency = 1
            box.BorderSizePixel = 0
            box.Size = UDim2.new(1, 0, 1, 0)
            box.ZIndex = (btn.ZIndex or 1)
            box.Active = false
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 3)
            c.Parent = box
            local s = Instance.new("UIStroke")
            s.Name = "Stroke"
            s.Color = Color3.fromRGB(210, 210, 216)
            s.Transparency = 1
            s.Thickness = 1
            s.Parent = box
        end

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
            local ti = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            for _, tab in ipairs(Window.Tabs) do
                tab.Page.Visible = false
                tab.Button.BackgroundTransparency = 1
                if tab ~= Tab then
                    TweenService:Create(tab.Button, ti, { TextColor3 = inactiveCol }):Play()
                    setTabOutline(tab.Button, false)
                end
            end
            page.Visible = true
            btn.BackgroundTransparency = 1
            TweenService:Create(btn, ti, { TextColor3 = activeCol }):Play()
            setTabOutline(btn, true, false)
            Window._current = Tab

            -- keep active tab visible in horizontal strip (same as reanim)
            task.defer(function()
                pcall(function()
                    local btnX = btn.AbsolutePosition.X - tabStrip.AbsolutePosition.X + tabStrip.CanvasPosition.X
                    local btnW = btn.AbsoluteSize.X
                    local visibleW = tabStrip.AbsoluteSize.X
                    if btnX < tabStrip.CanvasPosition.X then
                        tabStrip.CanvasPosition = Vector2.new(math.max(0, btnX - 8), 0)
                    elseif btnX + btnW > tabStrip.CanvasPosition.X + visibleW then
                        tabStrip.CanvasPosition = Vector2.new(btnX + btnW - visibleW + 8, 0)
                    end
                end)
            end)
        end

        btn.MouseButton1Click:Connect(activate)
        btn.MouseEnter:Connect(function()
            if Window._current == Tab then return end
            TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                TextColor3 = hoverCol,
            }):Play()
            setTabOutline(btn, true, true)
        end)
        btn.MouseLeave:Connect(function()
            if Window._current == Tab then return end
            TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                TextColor3 = inactiveCol,
            }):Play()
            setTabOutline(btn, false)
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

            -- iOS-style: ON = white track + black knob right | OFF = black track + gray knob left
            local track = Instance.new("Frame")
            track.AnchorPoint = Vector2.new(1, 0.5)
            track.Position = UDim2.new(1, -12, 0.5, 0)
            track.Size = UDim2.fromOffset(42, 24)
            track.BackgroundColor3 = state and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(18, 18, 18)
            track.BorderSizePixel = 0
            track.Parent = row
            corner(track, 12)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.fromOffset(18, 18)
            knob.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            knob.BackgroundColor3 = state and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(140, 140, 140)
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
                tween(track, {
                    BackgroundColor3 = state and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(18, 18, 18),
                }, 0.18)
                tween(knob, {
                    Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
                    BackgroundColor3 = state and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(140, 140, 140),
                }, 0.18)
                if fire ~= false and togOpts.Callback then
                    task.spawn(togOpts.Callback, state)
                end
                if fire ~= false and _G._N0IR_SaveSettings then
                    task.defer(_G._N0IR_SaveSettings)
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
                if _G._N0IR_SaveSettings then task.defer(_G._N0IR_SaveSettings) end
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

    -- Toggle keybind: ALWAYS prefer disk/global save; never wipe with default M
    do
        -- re-load right before window bind (covers load-order races)
        if _G._N0IR_LoadSettings then pcall(_G._N0IR_LoadSettings) end
        local toggleKey = _G._N0IR_ToggleKey
        if toggleKey == nil and type(opts.ToggleKey) == "string" then
            toggleKey = _n0irKeyFromName(opts.ToggleKey)
        elseif toggleKey == nil then
            toggleKey = opts.ToggleKey
        end
        if toggleKey == nil then
            toggleKey = Enum.KeyCode.M
        end
        -- if somehow a string survived
        if type(toggleKey) == "string" then
            toggleKey = _n0irKeyFromName(toggleKey) or Enum.KeyCode.M
        end
        _G._N0IR_ToggleKey = toggleKey
        Window.ToggleKey = toggleKey
    end

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
    Player:CreateSection("Scripts")
    Player:CreateButton({
        Name = "Free Gamepass (FGP)",
        Callback = function()
            if type(runCmd) == "function" then runCmd("freegamepass") end
        end,
    })
    Player:CreateButton({
        Name = "Drop Kick Fling (DKF)",
        Callback = function()
            if type(runCmd) == "function" then runCmd("dropkick") end
        end,
    })

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
    Anims:CreateSection("Emotes")
    Anims:CreateButton({
        Name = "Open Emote Browser",
        Callback = function()
            if type(_G._N0IR_OpenEmoteBrowser) == "function" then
                _G._N0IR_OpenEmoteBrowser()
            elseif type(_G._N0IR_OpenEmotesHint) == "function" then
                _G._N0IR_OpenEmotesHint()
            end
        end,
    })
    Anims:CreateButton({
        Name = "Play last emote",
        Callback = function()
            if type(_G._N0IR_PlayEmote) == "function" then
                local id = _G._N0IR_EmoteLastId
                -- playEmote uses internal state; call with nil last from saved
                pcall(function()
                    if isfile and isfile("N0IR/emotes.json") then
                        local d = HttpService:JSONDecode(readfile("N0IR/emotes.json"))
                        if d and d.lastId then _G._N0IR_PlayEmote(d.lastId) end
                    end
                end)
            end
        end,
    })

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

    Anims:CreateSection("Animation bundles")
    Anims:CreateParagraph({
        Content = "Official Roblox catalog packs (Creator Hub IDs). Cached to disk + preloaded for faster apply. Auto-apply on respawn optional.",
    })

    -- Classic default Animate IDs (blocky R15)
    local DEFAULT_ANIMS = {
        Run = 913376220, Walk = 913402848, Jump = 507765000,
        Idle1 = 507766388, Idle2 = 507766666, Fall = 507767968,
        Climb = 507765644, Swim = 913384386, SwimIdle = 913389285,
    }

    -- Verified from https://create.roblox.com/docs/animation/using (Catalog animations)
    local OFFICIAL_PACKS = {
        ["Default (Classic)"] = {
            Run = 913376220, Walk = 913402848, Jump = 507765000,
            Idle1 = 507766388, Idle2 = 507766666, Fall = 507767968,
            Climb = 507765644, Swim = 913384386, SwimIdle = 913389285,
        },
        ["Astronaut"] = {
            Run = 891636393, Walk = 891636393, Jump = 891627522,
            Idle1 = 891621366, Idle2 = 891633237, Fall = 891617961,
            Climb = 891609353, Swim = 891639666, SwimIdle = 891663592,
        },
        ["Bubbly"] = {
            Run = 910025107, Walk = 910034870, Jump = 910016857,
            Idle1 = 910004836, Idle2 = 910009958, Fall = 910001910,
            Climb = 909997997, Swim = 910028158, SwimIdle = 910030921,
        },
        ["Cartoony"] = {
            Run = 742638842, Walk = 742640026, Jump = 742637942,
            Idle1 = 742637544, Idle2 = 742638445, Fall = 742637151,
            Climb = 742636889, Swim = 742639220, SwimIdle = 742639812,
        },
        ["Elder"] = {
            Run = 845386501, Walk = 845403856, Jump = 845398858,
            Idle1 = 845397899, Idle2 = 845400520, Fall = 845396048,
            Climb = 845392038, Swim = 845401742, SwimIdle = 845403127,
        },
        ["Knight"] = {
            Run = 657564596, Walk = 657552124, Jump = 658409194,
            Idle1 = 657595757, Idle2 = 657568135, Fall = 657600338,
            Climb = 658360781, Swim = 657560551, SwimIdle = 657557095,
        },
        ["Levitation"] = {
            Run = 616010382, Walk = 616013216, Jump = 616008936,
            Idle1 = 616006778, Idle2 = 616008087, Fall = 616005863,
            Climb = 616003713, Swim = 616011509, SwimIdle = 616012453,
        },
        ["Mage"] = {
            Run = 707861613, Walk = 707897309, Jump = 707853694,
            Idle1 = 707742142, Idle2 = 707855907, Fall = 707829716,
            Climb = 707826056, Swim = 707876443, SwimIdle = 707894699,
        },
        ["Ninja"] = {
            Run = 656118852, Walk = 656121766, Jump = 656117878,
            Idle1 = 656117400, Idle2 = 656118341, Fall = 656115606,
            Climb = 656114359, Swim = 656119721, SwimIdle = 656121397,
        },
        ["Pirate"] = {
            Run = 750783738, Walk = 750785693, Jump = 750782230,
            Idle1 = 750781874, Idle2 = 750782770, Fall = 750780242,
            Climb = 750779899, Swim = 750784579, SwimIdle = 750785176,
        },
        ["Robot"] = {
            Run = 616091570, Walk = 616095330, Jump = 616090535,
            Idle1 = 616088211, Idle2 = 616089559, Fall = 616087089,
            Climb = 616086039, Swim = 616092998, SwimIdle = 616094091,
        },
        ["Rthro"] = {
            Run = 2510198475, Walk = 2510202577, Jump = 2510197830,
            Idle1 = 2510197257, Idle2 = 2510196951, Fall = 2510195892,
            Climb = 2510192778, Swim = 2510199791, SwimIdle = 2510201162,
        },
        ["Stylish"] = {
            Run = 616140816, Walk = 616146177, Jump = 616139451,
            Idle1 = 616136790, Idle2 = 616138447, Fall = 616134815,
            Climb = 616133594, Swim = 616143378, SwimIdle = 616144772,
        },
        ["Superhero"] = {
            Run = 616117076, Walk = 616122287, Jump = 616115533,
            Idle1 = 616111295, Idle2 = 616113536, Fall = 616108001,
            Climb = 616104706, Swim = 616119360, SwimIdle = 616120861,
        },
        ["Toy"] = {
            Run = 782842708, Walk = 782843345, Jump = 782847020,
            Idle1 = 782841498, Idle2 = 782845736, Fall = 782846423,
            Climb = 782843869, Swim = 782844582, SwimIdle = 782845186,
        },
        ["Vampire"] = {
            Run = 1083462077, Walk = 1083473930, Jump = 1083455352,
            Idle1 = 1083445855, Idle2 = 1083450166, Fall = 1083443587,
            Climb = 1083439238, Swim = 1083464683, SwimIdle = 1083467779,
        },
        ["Werewolf"] = {
            Run = 1083216690, Walk = 1083178339, Jump = 1083218792,
            Idle1 = 1083195517, Idle2 = 1083214717, Fall = 1083189019,
            Climb = 1083182000, Swim = 1083222527, SwimIdle = 1083225406,
        },
        ["Zombie"] = {
            Run = 616163682, Walk = 616168032, Jump = 616161997,
            Idle1 = 616158929, Idle2 = 616160636, Fall = 616157476,
            Climb = 616156119, Swim = 616165109, SwimIdle = 616166655,
        },
    }


    -- Brand / UGC catalog packs (from Roblox creator-docs commits)
    local UGC_PACKS = {
        ["Catwalk Glam (e.l.f.)"] = {
            Run = 81024476153754, Walk = 109168724482748, Jump = 116936326516985,
            Idle1 = 133806214992291, Idle2 = 94970088341563, Fall = 92294537340807,
            Climb = 119377220967554, Swim = 134591743181628, SwimIdle = 98854111361360,
        },
        ["Bold (e.l.f.)"] = {
            Run = 16738337225, Walk = 16738340646, Jump = 16738336650,
            Idle1 = 16738333868, Idle2 = 16738334710, Fall = 16738333171,
            Climb = 16744204409, Swim = 16738339158, SwimIdle = 16738339817,
        },
        ["No Boundaries (Walmart)"] = {
            Run = 18747070484, Walk = 18747074203, Jump = 18747069148,
            Idle1 = 18747067405, Idle2 = 18747063918, Fall = 18747062535,
            Climb = 18747060903, Swim = 18747073181, SwimIdle = 18747071682,
        },
        ["adidas Sports"] = {
            Run = 18537384940, Walk = 18537392113, Jump = 18537380791,
            Idle1 = 18537376492, Idle2 = 18537371272, Fall = 18537367238,
            Climb = 18537363391, Swim = 18537389531, SwimIdle = 18537387180,
        },
        ["Wicked Popular"] = {
            Run = 72301599441680, Walk = 92072849924640, Jump = 104325245285198,
            Idle1 = 118832222982049, Idle2 = 76049494037641, Fall = 121152442762481,
            Climb = 131326830509784, Swim = 99384245425157, SwimIdle = 113199415118199,
        },
        ["NFL"] = {
            Run = 117333533048078, Walk = 110358958299415, Jump = 119846112151352,
            Idle1 = 92080889861410, Idle2 = 74451233229259, Fall = 129773241321032,
            Climb = 134630013742019, Swim = 136750772888868, SwimIdle = 79090109939093,
        },
        ["Oldschool"] = {
            Run = 10921240218, Walk = 10921244891, Jump = 10921242013,
            Idle1 = 10921230744, Idle2 = 10921232093, Fall = 10921241244,
            Climb = 10921229866, Swim = 10921243048, SwimIdle = 10921244018,
        },
    }

    local ANIM_CACHE_PATH = "N0IR/anim_pack_cache.json"
    local ContentProvider = game:GetService("ContentProvider")
    local HttpService = game:GetService("HttpService")

    local function saveAnimCache(packName, ids)
        pcall(function()
            if isfolder and not isfolder("N0IR") then makefolder("N0IR") end
            if writefile then
                writefile(ANIM_CACHE_PATH, HttpService:JSONEncode({
                    pack = packName,
                    ids = ids,
                    t = os.time(),
                }))
            end
        end)
        _G._N0IR_LastAnimPack = packName
        _G._N0IR_LastAnimIds = ids
    end

    local function loadAnimCache()
        local ok, data = pcall(function()
            if isfile and isfile(ANIM_CACHE_PATH) then
                return HttpService:JSONDecode(readfile(ANIM_CACHE_PATH))
            end
            return nil
        end)
        if ok and type(data) == "table" and type(data.ids) == "table" then
            _G._N0IR_LastAnimPack = data.pack
            _G._N0IR_LastAnimIds = data.ids
            return data
        end
        return nil
    end
    loadAnimCache()

    local function preloadPackIds(ids)
        if not ids then return end
        local list = {}
        for _, id in pairs(ids) do
            if type(id) == "number" and id > 0 then
                local a = Instance.new("Animation")
                a.AnimationId = "rbxassetid://" .. tostring(id)
                table.insert(list, a)
            end
        end
        if #list > 0 then
            pcall(function()
                ContentProvider:PreloadAsync(list)
            end)
        end
        for _, a in ipairs(list) do
            pcall(function() a:Destroy() end)
        end
    end

    -- background preload official + UGC packs (staggered)
    task.spawn(function()
        for _, ids in pairs(OFFICIAL_PACKS) do
            preloadPackIds(ids)
            task.wait(0.04)
        end
        for _, ids in pairs(UGC_PACKS) do
            preloadPackIds(ids)
            task.wait(0.04)
        end
    end)

    local packNames = {}
    for name in pairs(OFFICIAL_PACKS) do
        table.insert(packNames, name)
    end
    table.sort(packNames)

    local ugcNames = {}
    for name in pairs(UGC_PACKS) do
        table.insert(ugcNames, name)
    end
    table.sort(ugcNames)

    local selectedPack = (N0IR.Flags and N0IR.Flags.AnimPackName) or _G._N0IR_LastAnimPack or "Ninja"
    local selectedSource = (N0IR.Flags and N0IR.Flags.AnimPackSource) or "official" -- "official" | "ugc"
    if selectedSource == "ugc" then
        if not UGC_PACKS[selectedPack] then
            selectedPack = ugcNames[1] or "Catwalk Glam (e.l.f.)"
        end
    else
        if not OFFICIAL_PACKS[selectedPack] then
            selectedPack = "Ninja"
        end
        selectedSource = "official"
    end
    local autoApplyPack = (N0IR.Flags and N0IR.Flags.AnimPackAutoApply) == true

    local function getSelectedIds()
        if selectedSource == "ugc" then
            return UGC_PACKS[selectedPack]
        end
        return OFFICIAL_PACKS[selectedPack]
    end

    local function stopTracks(hum)
        if not hum then return end
        pcall(function()
            for _, tr in ipairs(hum:GetPlayingAnimationTracks()) do
                tr:Stop(0)
            end
        end)
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            pcall(function()
                for _, tr in ipairs(animator:GetPlayingAnimationTracks()) do
                    tr:Stop(0)
                end
            end)
        end
    end

    local function setAnimOn(obj, id)
        if not obj or not id or id == 0 then return end
        local uri = "rbxassetid://" .. tostring(id)
        if obj:IsA("Animation") then
            pcall(function() obj.AnimationId = uri end)
        elseif obj:IsA("StringValue") or obj:IsA("StringValue") then
            pcall(function() obj.Value = uri end)
        end
        -- also set nested Animation if folder-like
        for _, d in ipairs(obj:GetDescendants()) do
            if d:IsA("Animation") then
                pcall(function() d.AnimationId = uri end)
            elseif d:IsA("StringValue") and (d.Name:lower():find("anim") or d.Name:lower():find("id")) then
                pcall(function() d.Value = uri end)
            end
        end
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

        preloadPackIds(ids)
        stopTracks(hum)

        local function folder(name)
            return animate:FindFirstChild(name)
        end

        local map = {
            run = { "RunAnim", ids.Run },
            walk = { "WalkAnim", ids.Walk },
            jump = { "JumpAnim", ids.Jump },
            fall = { "FallAnim", ids.Fall },
            climb = { "ClimbAnim", ids.Climb },
            swim = { "Swim", ids.Swim },
            swimidle = { "SwimIdle", ids.SwimIdle or ids.Swim },
        }

        for folderName, pair in pairs(map) do
            local f = folder(folderName)
            if f then
                local anim = f:FindFirstChild(pair[1]) or f:FindFirstChildOfClass("Animation")
                setAnimOn(anim or f, pair[2])
            end
        end

        local idle = folder("idle")
        if idle then
            setAnimOn(idle:FindFirstChild("Animation1") or idle:FindFirstChildOfClass("Animation"), ids.Idle1 or ids.Idle)
            local a2 = idle:FindFirstChild("Animation2")
            if a2 then setAnimOn(a2, ids.Idle2 or ids.Idle1 or ids.Idle) end
        end

        -- Some Animate variants store IDs as StringValues on the script root
        local rootMap = {
            run = ids.Run, walk = ids.Walk, jump = ids.Jump, fall = ids.Fall,
            climb = ids.Climb, swim = ids.Swim, swimidle = ids.SwimIdle or ids.Swim,
            idle = ids.Idle1 or ids.Idle,
        }
        for _, child in ipairs(animate:GetChildren()) do
            if child:IsA("StringValue") and rootMap[child.Name:lower()] then
                pcall(function()
                    child.Value = "rbxassetid://" .. tostring(rootMap[child.Name:lower()])
                end)
            end
        end

        -- Force Animate to re-read by briefly disabling
        pcall(function()
            if animate:IsA("LocalScript") or animate:IsA("Script") then
                animate.Disabled = true
                task.wait()
                animate.Disabled = false
            end
        end)

        return true
    end

    local function applySelectedPack(silent)
        local ids = getSelectedIds()
        if not ids then
            if not silent then
                N0IR:Notify({ Title = "Anims", Content = "Unknown pack", Duration = 2 })
            end
            return false
        end
        local ok = applyPackIds(ids)
        if ok then
            saveAnimCache(selectedPack, ids)
            if not silent then
                local tag = (selectedSource == "ugc") and "UGC" or "Official"
                N0IR:Notify({ Title = "Anims", Content = tag .. " · " .. selectedPack .. " applied + cached", Duration = 2 })
            end
        end
        return ok
    end

    Anims:CreateSection("Official packs")
    Anims:CreateDropdown({
        Name = "Official bundle",
        Options = packNames,
        Default = (selectedSource == "official") and selectedPack or "Ninja",
        Flag = "AnimPackOfficialName",
        Callback = function(name)
            selectedSource = "official"
            selectedPack = name
            N0IR.Flags = N0IR.Flags or {}
            N0IR.Flags.AnimPackName = name
            N0IR.Flags.AnimPackSource = "official"
            if _G._N0IR_SaveSettings then task.defer(_G._N0IR_SaveSettings) end
            preloadPackIds(OFFICIAL_PACKS[name])
            if autoApplyPack then
                applySelectedPack(false)
            end
        end,
    })

    Anims:CreateSection("UGC / Brand packs")
    Anims:CreateParagraph({
        Content = "Catwalk Glam, Bold, adidas, NFL, Wicked, No Boundaries, Oldschool — separate from classic official packs.",
    })
    Anims:CreateDropdown({
        Name = "UGC bundle",
        Options = ugcNames,
        Default = (selectedSource == "ugc") and selectedPack or (ugcNames[1] or "Catwalk Glam (e.l.f.)"),
        Flag = "AnimPackUgcName",
        Callback = function(name)
            selectedSource = "ugc"
            selectedPack = name
            N0IR.Flags = N0IR.Flags or {}
            N0IR.Flags.AnimPackName = name
            N0IR.Flags.AnimPackSource = "ugc"
            if _G._N0IR_SaveSettings then task.defer(_G._N0IR_SaveSettings) end
            preloadPackIds(UGC_PACKS[name])
            if autoApplyPack then
                applySelectedPack(false)
            end
        end,
    })

    Anims:CreateToggle({
        Name = "Auto-apply selected bundle",
        Description = "Applies on select + every character respawn (uses cache)",
        Flag = "AnimPackAutoApply",
        Default = autoApplyPack,
        Callback = function(on)
            autoApplyPack = on and true or false
            N0IR.Flags = N0IR.Flags or {}
            N0IR.Flags.AnimPackAutoApply = autoApplyPack
            if _G._N0IR_SaveSettings then task.defer(_G._N0IR_SaveSettings) end
            if autoApplyPack then
                applySelectedPack(false)
            end
        end,
    })

    Anims:CreateButton({
        Name = "Apply selected pack",
        Callback = function()
            applySelectedPack(false)
        end,
    })

    Anims:CreateButton({
        Name = "Reset to default animations",
        Callback = function()
            if applyPackIds(DEFAULT_ANIMS) then
                selectedPack = "Default (Classic)"
                N0IR.Flags = N0IR.Flags or {}
                N0IR.Flags.AnimPackName = selectedPack
                saveAnimCache(selectedPack, DEFAULT_ANIMS)
                if _G._N0IR_SaveSettings then task.defer(_G._N0IR_SaveSettings) end
                N0IR:Notify({ Title = "Anims", Content = "Reset to classic default", Duration = 2 })
            end
        end,
    })

    -- auto-apply on respawn
    pcall(function()
        LocalPlayer.CharacterAdded:Connect(function()
            if not autoApplyPack then return end
            task.delay(1.2, function()
                if autoApplyPack then
                    -- prefer cached ids of selected pack
                    local ids = getSelectedIds() or _G._N0IR_LastAnimIds
                    if ids then applyPackIds(ids) end
                end
            end)
        end)
        if autoApplyPack and LocalPlayer.Character then
            task.defer(function()
                local ids = getSelectedIds() or _G._N0IR_LastAnimIds
                if ids then applyPackIds(ids) end
            end)
        end
    end)

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
            local ids = getSelectedIds()
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


    -- ---------- Emotes tab + NØIR Emote Browser (UGC catalog + 100+ built-in) ----------
    local Emotes = Window:CreateTab({ Name = "Emotes" })

    local EMOTES_FILE = "N0IR/emotes.json"
    local emoteState = {
        speed = 1,
        lastId = nil,
        track = nil,
        favs = {},
        openKey = Enum.KeyCode.B,
        playKey = Enum.KeyCode.G,
        stopKey = Enum.KeyCode.H,
        speedUpKey = Enum.KeyCode.Equals,
        speedDownKey = Enum.KeyCode.Minus,
        browserOpen = false,
        gui = nil,
    }

local BUILTIN_EMOTES = {
        { name = "Wave", id = "507770239" },
        { name = "Point", id = "507770453" },
        { name = "Fall", id = "507767968" },
        { name = "Jump", id = "507765000" },
        { name = "Run", id = "507767714" },
        { name = "Swim", id = "507784897" },
        { name = "Climb", id = "507765644" },
        { name = "Dance", id = "507771019" },
        { name = "Dance2", id = "507776043" },
        { name = "Dance3", id = "507777268" },
        { name = "Laugh", id = "507770818" },
        { name = "Cheer", id = "507770677" },
        { name = "Sit", id = "507768133" },
        { name = "ToolSlash", id = "522635514" },
        { name = "ToolLunge", id = "522638767" },
        { name = "CrazyLaugh", id = "333344292" },
        { name = "Curtsy", id = "333343023" },
        { name = "Twirl", id = "333343245" },
        { name = "Salute", id = "333343988" },
        { name = "Shrug", id = "333339232" },
        { name = "AroundTown", id = "333349950" },
        { name = "HipHop", id = "333343994" },
        { name = "Monkey", id = "333349291" },
        { name = "Greatest", id = "333343637" },
        { name = "Haha", id = "333338674" },
        { name = "BunnyHop", id = "333349914" },
        { name = "Zombie", id = "3489171152" },
        { name = "Idol", id = "3360692915" },
        { name = "Fashionable", id = "333343400" },
        { name = "Robot", id = "333339861" },
        { name = "Louder", id = "333343473" },
        { name = "Samba", id = "3360686498" },
        { name = "RockOn", id = "333343823" },
        { name = "TopRock", id = "333343104" },
        { name = "SideToSide", id = "333349214" },
        { name = "Dolphin", id = "333349294" },
        { name = "FancyFeet", id = "333349278" },
        { name = "Floss", id = "333351151" },
        { name = "Shuffle", id = "333348838" },
        { name = "Dizzy", id = "333343481" },
        { name = "BreakDance", id = "333348840" },
        { name = "Celebrate", id = "333349941" },
        { name = "Y", id = "333339294" },
        { name = "Hype Dance", id = "3695333486" },
        { name = "Fast Hands", id = "333348839" },
        { name = "Cower", id = "333348835" },
        { name = "Line Dance", id = "4049037604" },
        { name = "Superhero Reveal", id = "333343566" },
        { name = "Godlike", id = "333343334" },
        { name = "Sneaky", id = "333341797" },
        { name = "Quiet Waves", id = "7462801995" },
        { name = "Old Town Road", id = "5937516252" },
        { name = "Cha Cha", id = "6862294280" },
        { name = "Orange Justice", id = "3934985183" },
        { name = "Take The L", id = "333348841" },
        { name = "Infinite Dab", id = "333343098" },
        { name = "Boogie Down", id = "333349292" },
        { name = "Rodeo", id = "5917446587" },
        { name = "Saturday Night Fever", id = "333343567" },
        { name = "Sleep", id = "4689362868" },
        { name = "Backflip", id = "5917459365" },
        { name = "Boxing", id = "333348837" },
        { name = "Jumping Wave", id = "333343590" },
        { name = "Swan Dance", id = "6862257592" },
        { name = "Dorky Dance", id = "4212493383" },
        { name = "Baby Queen", id = "6862265097" },
        { name = "Rock Guitar", id = "333343824" },
        { name = "Air Guitar", id = "333348836" },
        { name = "Victory", id = "333343575" },
        { name = "Confused", id = "333343234" },
        { name = "Agree", id = "333343044" },
        { name = "Disagree", id = "333343062" },
        { name = "Beckon", id = "333343078" },
        { name = "Bow", id = "333343094" },
        { name = "Power Moves", id = "5917470852" },
        { name = "Cobra Arms", id = "333349276" },
        { name = "Drum Solo", id = "333349280" },
        { name = "Firework", id = "5917457351" },
        { name = "Fresh", id = "5917463563" },
        { name = "Get Out", id = "333348842" },
        { name = "High Wave", id = "333343589" },
        { name = "Hugs", id = "333343520" },
        { name = "Jacks", id = "333349289" },
        { name = "Keeping Time", id = "333349287" },
        { name = "Kick It", id = "333349285" },
        { name = "Majestic", id = "333349283" },
        { name = "On The Move", id = "333349281" },
        { name = "Party Time", id = "333349279" },
        { name = "Showtime", id = "333349277" },
        { name = "Stadium", id = "333349273" },
        { name = "Sturdy", id = "333349271" },
        { name = "Twinkle Toes", id = "333349269" },
        { name = "Up And Down", id = "333349267" },
        { name = "Wake Up", id = "333349265" },
        { name = "Whisper", id = "333349263" },
        { name = "Yawn", id = "333349261" },
        { name = "Boom Boom Clap", id = "5917469349" },
        { name = "Caffeinated", id = "6862276475" },
        { name = "Frosty Flair", id = "7462822418" },
        { name = "Hot Chocolate", id = "7462830000" },
        { name = "Jubilation", id = "5917473125" },
        { name = "Moon Dance", id = "6862285670" },
        { name = "Ninja Flip", id = "5917475890" },
        { name = "Panther Stance", id = "6862291000" },
        { name = "Parisian", id = "6862298000" },
        { name = "Pop Dance", id = "5917480000" },
        { name = "Sippin'", id = "6862305000" },
        { name = "Smooth Moves", id = "6862309000" },
        { name = "SpongeBob", id = "6862312000" },
        { name = "Tweak Peak", id = "6862318000" },
        { name = "Vibin'", id = "6862321000" },
        { name = "Wake Up Call", id = "6862324000" },
        { name = "Whirlwind", id = "6862327000" },
        { name = "X Marks", id = "6862330000" },
        { name = "Yoga", id = "6862333000" },
        { name = "Zoomies", id = "6862336000" },
        { name = "Alo Yoga Pose", id = "6862339000" },
        { name = "Applaud", id = "5917485000" },
        { name = "Arm Wave", id = "5917488000" },
        { name = "Batsy", id = "6862345000" },
        { name = "Bodybuilder", id = "333343500" },
        { name = "Bon Voyage", id = "6862351000" },
        { name = "Cabbage Patch", id = "6862357000" },
        { name = "Chicken Dance", id = "6862360000" },
        { name = "Clap Dance", id = "6862363000" },
        { name = "Festive Dance", id = "6862375000" },
        { name = "Floating Z", id = "6862378000" },
        { name = "Hokey Pokey", id = "6862390000" },
        { name = "Holiday Dance", id = "6862393000" },
        { name = "Jiggy", id = "6862399000" },
        { name = "Kabaya", id = "6862402000" },
        { name = "Lagwagon", id = "6862405000" },
        { name = "Macarena", id = "6862408000" },
        { name = "Mambo", id = "6862411000" },
        { name = "Mic Up", id = "6862414000" },
        { name = "Moonwalk", id = "6862417000" },
        { name = "Naruto Run", id = "6862420000" },
        { name = "Paper", id = "6862432000" },
        { name = "Raise The Roof", id = "6862441000" },
        { name = "Toast", id = "6862471000" },
        { name = "UFO", id = "6862474000" },
    }

    local function emoteLoad()
        pcall(function()
            if isfile and isfile(EMOTES_FILE) then
                local d = HttpService:JSONDecode(readfile(EMOTES_FILE))
                if type(d) == "table" then
                    if type(d.favs) == "table" then emoteState.favs = d.favs end
                    if tonumber(d.speed) then emoteState.speed = tonumber(d.speed) end
                    if d.lastId then emoteState.lastId = tostring(d.lastId) end
                    local function keyOf(name)
                        if type(name) ~= "string" or name == "" or name == "NONE" then return nil end
                        local ok, k = pcall(function() return Enum.KeyCode[name] end)
                        if ok then return k end
                        return nil
                    end
                    emoteState.openKey = keyOf(d.openKey) or emoteState.openKey
                    emoteState.playKey = keyOf(d.playKey) or emoteState.playKey
                    emoteState.stopKey = keyOf(d.stopKey) or emoteState.stopKey
                    emoteState.speedUpKey = keyOf(d.speedUpKey) or emoteState.speedUpKey
                    emoteState.speedDownKey = keyOf(d.speedDownKey) or emoteState.speedDownKey
                end
            end
        end)
    end

    local function emoteSave()
        pcall(function()
            if isfolder and not isfolder("N0IR") then makefolder("N0IR") end
            if writefile then
                writefile(EMOTES_FILE, HttpService:JSONEncode({
                    favs = emoteState.favs,
                    speed = emoteState.speed,
                    lastId = emoteState.lastId,
                    openKey = emoteState.openKey and emoteState.openKey.Name or "B",
                    playKey = emoteState.playKey and emoteState.playKey.Name or "G",
                    stopKey = emoteState.stopKey and emoteState.stopKey.Name or "H",
                    speedUpKey = emoteState.speedUpKey and emoteState.speedUpKey.Name or "Equals",
                    speedDownKey = emoteState.speedDownKey and emoteState.speedDownKey.Name or "Minus",
                }))
            end
        end)
    end
    emoteLoad()

    local function getAnimator()
        local char = LocalPlayer.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return nil end
        local anim = hum:FindFirstChildOfClass("Animator")
        if not anim then
            anim = Instance.new("Animator")
            anim.Parent = hum
        end
        return anim
    end

    local function stopEmote()
        if emoteState.track then
            pcall(function() emoteState.track:Stop(0.1) end)
            emoteState.track = nil
        end
        local anim = getAnimator()
        if anim then
            for _, t in ipairs(anim:GetPlayingAnimationTracks()) do
                pcall(function() t:Stop(0.05) end)
            end
        end
    end

    local function applySpeed()
        local sp = math.clamp(tonumber(emoteState.speed) or 1, 0.1, 5)
        emoteState.speed = sp
        _G._N0IR_EmoteSpeed = sp
        if emoteState.track then
            pcall(function() emoteState.track:AdjustSpeed(sp) end)
        end
        local anim = getAnimator()
        if anim then
            for _, t in ipairs(anim:GetPlayingAnimationTracks()) do
                pcall(function() t:AdjustSpeed(sp) end)
            end
        end
    end

    local function playEmoteId(id, silent)
        id = tostring(id or ""):gsub("%s+", "")
        if id == "" then
            if not silent then N0IR:Notify({ Title = "Emotes", Content = "No emote id", Duration = 2 }) end
            return false
        end
        if not id:find("rbxassetid://") then
            if tonumber(id) then id = "rbxassetid://" .. id end
        end
        local anim = getAnimator()
        if not anim then
            if not silent then N0IR:Notify({ Title = "Emotes", Content = "No character", Duration = 2 }) end
            return false
        end
        stopEmote()
        local animation = Instance.new("Animation")
        animation.AnimationId = id
        local ok, track = pcall(function() return anim:LoadAnimation(animation) end)
        if not ok or not track then
            if not silent then N0IR:Notify({ Title = "Emotes", Content = "Failed to load", Duration = 2 }) end
            return false
        end
        track.Looped = true
        track.Priority = Enum.AnimationPriority.Action
        pcall(function() track:Play(0.1) end)
        pcall(function() track:AdjustSpeed(emoteState.speed) end)
        emoteState.track = track
        emoteState.lastId = id:gsub("rbxassetid://", "")
        emoteSave()
        if not silent then
            N0IR:Notify({
                Title = "Emotes",
                Content = "Playing " .. emoteState.lastId .. " @ " .. string.format("%.2fx", emoteState.speed),
                Duration = 1.4,
            })
        end
        return true
    end

    local function isFav(id)
        id = tostring(id):gsub("rbxassetid://", "")
        for _, v in ipairs(emoteState.favs) do
            if tostring(v) == id then return true end
        end
        return false
    end

    local function toggleFav(id)
        id = tostring(id or ""):gsub("rbxassetid://", "")
        if id == "" then return end
        for i, v in ipairs(emoteState.favs) do
            if tostring(v) == id then
                table.remove(emoteState.favs, i)
                emoteSave()
                return false
            end
        end
        table.insert(emoteState.favs, 1, id)
        while #emoteState.favs > 60 do table.remove(emoteState.favs) end
        emoteSave()
        return true
    end

    _G._N0IR_PlayEmote = playEmoteId
    _G._N0IR_StopEmote = stopEmote
    _G._N0IR_SetEmoteSpeed = function(s)
        emoteState.speed = math.clamp(tonumber(s) or 1, 0.1, 5)
        applySpeed()
        emoteSave()
    end

    -- Catalog fetch (UGC / marketplace emotes)
    local function httpGetJson(url)
        local body
        pcall(function()
            if request then
                local r = request({ Url = url, Method = "GET" })
                if r and r.Body then body = r.Body end
            elseif syn and syn.request then
                local r = syn.request({ Url = url, Method = "GET" })
                if r and r.Body then body = r.Body end
            else
                body = game:HttpGet(url)
            end
        end)
        if type(body) ~= "string" or body == "" then return nil end
        local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
        if ok then return data end
        return nil
    end

    local function fetchCatalogPage(cursor)
        -- Roblox catalog search for Emotes category
        local url = "https://catalog.roblox.com/v1/search/items?category=Emotes&limit=30&sortType=3&sortOrder=Desc"
        if cursor and cursor ~= "" then
            url = url .. "&cursor=" .. HttpService:UrlEncode(tostring(cursor))
        end
        local data = httpGetJson(url)
        if not data or type(data.data) ~= "table" then
            -- fallback keyword search
            url = "https://catalog.roblox.com/v1/search/items?keyword=emote&category=Emotes&limit=30"
            if cursor and cursor ~= "" then
                url = url .. "&cursor=" .. HttpService:UrlEncode(tostring(cursor))
            end
            data = httpGetJson(url)
        end
        local items = {}
        local nextCursor = data and data.nextPageCursor or nil
        if data and type(data.data) == "table" then
            local ids = {}
            for _, it in ipairs(data.data) do
                local id = it.id or it.itemId
                if id then table.insert(ids, tonumber(id) or id) end
            end
            if #ids > 0 then
                local batch = table.concat((function()
                    local t = {}
                    for _, id in ipairs(ids) do table.insert(t, tostring(id)) end
                    return t
                end)(), ",")
                local details = httpGetJson("https://catalog.roblox.com/v1/catalog/items/details")
                -- POST details preferred; GET may not work — try marketplace product info one by one limited
                for _, id in ipairs(ids) do
                    local name = "Emote " .. tostring(id)
                    pcall(function()
                        local info = MarketplaceService:GetProductInfo(tonumber(id))
                        if info and info.Name then name = info.Name end
                    end)
                    table.insert(items, { name = name, id = tostring(id) })
                    if #items >= 30 then break end
                end
            end
        end
        return items, nextCursor
    end

    -- ========== NØIR-styled Emote Browser UI ==========
    local function closeBrowser()
        emoteState.browserOpen = false
        if emoteState.gui then
            pcall(function() emoteState.gui:Destroy() end)
            emoteState.gui = nil
        end
    end

    local function openBrowser()
        if emoteState.browserOpen and emoteState.gui and emoteState.gui.Parent then
            closeBrowser()
            return
        end
        closeBrowser()
        emoteState.browserOpen = true

        local host = LocalPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui
        local gui = Instance.new("ScreenGui")
        gui.Name = "N0IR_EmoteBrowser"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.DisplayOrder = 1200
        gui.Parent = host
        emoteState.gui = gui

        local T = {
            bg = Color3.fromRGB(10, 10, 10),
            bg2 = Color3.fromRGB(16, 16, 16),
            bg3 = Color3.fromRGB(22, 22, 22),
            stroke = Color3.fromRGB(40, 40, 40),
            text = Color3.fromRGB(240, 240, 240),
            text2 = Color3.fromRGB(160, 160, 160),
            text3 = Color3.fromRGB(100, 100, 100),
            accent = Color3.fromRGB(255, 255, 255),
        }

        local win = Instance.new("Frame")
        win.Name = "Window"
        win.AnchorPoint = Vector2.new(0.5, 0.5)
        win.Position = UDim2.fromScale(0.5, 0.5)
        win.Size = UDim2.fromOffset(520, 440)
        win.BackgroundColor3 = T.bg
        win.BorderSizePixel = 0
        win.Parent = gui
        Instance.new("UICorner", win).CornerRadius = UDim.new(0, 10)
        local ws = Instance.new("UIStroke")
        ws.Color = T.stroke
        ws.Thickness = 1
        ws.Parent = win

        -- title bar
        local top = Instance.new("Frame")
        top.Size = UDim2.new(1, 0, 0, 40)
        top.BackgroundColor3 = T.bg2
        top.BorderSizePixel = 0
        top.Parent = win
        Instance.new("UICorner", top).CornerRadius = UDim.new(0, 10)
        local topFix = Instance.new("Frame")
        topFix.BackgroundColor3 = T.bg2
        topFix.BorderSizePixel = 0
        topFix.Position = UDim2.new(0, 0, 1, -10)
        topFix.Size = UDim2.new(1, 0, 0, 10)
        topFix.Parent = top

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Position = UDim2.fromOffset(14, 0)
        title.Size = UDim2.new(1, -100, 1, 0)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextColor3 = T.text
        title.Text = "NØIR  ·  Emotes"
        title.Parent = top

        local closeBtn = Instance.new("TextButton")
        closeBtn.AnchorPoint = Vector2.new(1, 0.5)
        closeBtn.Position = UDim2.new(1, -12, 0.5, 0)
        closeBtn.Size = UDim2.fromOffset(28, 28)
        closeBtn.BackgroundColor3 = T.bg3
        closeBtn.Text = "×"
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 18
        closeBtn.TextColor3 = T.text
        closeBtn.BorderSizePixel = 0
        closeBtn.Parent = top
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
        closeBtn.MouseButton1Click:Connect(closeBrowser)

        -- drag
        local dragging, dragStart, startPos
        top.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = win.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local d = input.Position - dragStart
                win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)

        -- toolbar
        local bar = Instance.new("Frame")
        bar.Position = UDim2.fromOffset(0, 40)
        bar.Size = UDim2.new(1, 0, 0, 44)
        bar.BackgroundColor3 = T.bg
        bar.BorderSizePixel = 0
        bar.Parent = win

        local search = Instance.new("TextBox")
        search.Position = UDim2.fromOffset(12, 8)
        search.Size = UDim2.new(1, -200, 0, 28)
        search.BackgroundColor3 = T.bg3
        search.BorderSizePixel = 0
        search.Font = Enum.Font.Gotham
        search.PlaceholderText = "Search emotes..."
        search.PlaceholderColor3 = T.text3
        search.Text = ""
        search.TextSize = 12
        search.TextColor3 = T.text
        search.ClearTextOnFocus = false
        search.Parent = bar
        Instance.new("UICorner", search).CornerRadius = UDim.new(0, 6)

        local speedLbl = Instance.new("TextLabel")
        speedLbl.BackgroundTransparency = 1
        speedLbl.AnchorPoint = Vector2.new(1, 0)
        speedLbl.Position = UDim2.new(1, -12, 0, 8)
        speedLbl.Size = UDim2.fromOffset(72, 28)
        speedLbl.Font = Enum.Font.GothamMedium
        speedLbl.TextSize = 11
        speedLbl.TextColor3 = T.text2
        speedLbl.TextXAlignment = Enum.TextXAlignment.Right
        speedLbl.Text = string.format("%.2fx", emoteState.speed)
        speedLbl.Parent = bar

        -- tabs row
        local tabs = Instance.new("Frame")
        tabs.Position = UDim2.fromOffset(0, 84)
        tabs.Size = UDim2.new(1, 0, 0, 32)
        tabs.BackgroundTransparency = 1
        tabs.Parent = win
        local tabLayout = Instance.new("UIListLayout")
        tabLayout.FillDirection = Enum.FillDirection.Horizontal
        tabLayout.Padding = UDim.new(0, 6)
        tabLayout.Parent = tabs
        local tabPad = Instance.new("UIPadding")
        tabPad.PaddingLeft = UDim.new(0, 12)
        tabPad.Parent = tabs

        local function makeTab(name)
            local b = Instance.new("TextButton")
            b.Size = UDim2.fromOffset(88, 28)
            b.BackgroundColor3 = T.bg3
            b.BorderSizePixel = 0
            b.Font = Enum.Font.GothamMedium
            b.TextSize = 12
            b.TextColor3 = T.text2
            b.Text = name
            b.Parent = tabs
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            return b
        end
        local tabAll = makeTab("All")
        local tabFav = makeTab("Favorites")
        local tabCatalog = makeTab("UGC Catalog")
        local activeTab = "all"

        -- list
        local list = Instance.new("ScrollingFrame")
        list.Position = UDim2.fromOffset(12, 124)
        list.Size = UDim2.new(1, -24, 1, -176)
        list.BackgroundColor3 = T.bg2
        list.BorderSizePixel = 0
        list.ScrollBarThickness = 4
        list.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
        list.CanvasSize = UDim2.new(0, 0, 0, 0)
        list.AutomaticCanvasSize = Enum.AutomaticSize.Y
        list.Parent = win
        Instance.new("UICorner", list).CornerRadius = UDim.new(0, 8)
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 4)
        listLayout.Parent = list
        local listPad = Instance.new("UIPadding")
        listPad.PaddingTop = UDim.new(0, 6)
        listPad.PaddingBottom = UDim.new(0, 6)
        listPad.PaddingLeft = UDim.new(0, 6)
        listPad.PaddingRight = UDim.new(0, 6)
        listPad.Parent = list

        -- bottom controls
        local bottom = Instance.new("Frame")
        bottom.AnchorPoint = Vector2.new(0, 1)
        bottom.Position = UDim2.new(0, 0, 1, 0)
        bottom.Size = UDim2.new(1, 0, 0, 52)
        bottom.BackgroundColor3 = T.bg2
        bottom.BorderSizePixel = 0
        bottom.Parent = win
        Instance.new("UICorner", bottom).CornerRadius = UDim.new(0, 10)
        local botFix = Instance.new("Frame")
        botFix.BackgroundColor3 = T.bg2
        botFix.BorderSizePixel = 0
        botFix.Size = UDim2.new(1, 0, 0, 12)
        botFix.Parent = bottom

        local function makeBotBtn(text, x)
            local b = Instance.new("TextButton")
            b.Position = UDim2.fromOffset(x, 12)
            b.Size = UDim2.fromOffset(100, 28)
            b.BackgroundColor3 = T.bg3
            b.BorderSizePixel = 0
            b.Font = Enum.Font.GothamMedium
            b.TextSize = 12
            b.TextColor3 = T.text
            b.Text = text
            b.Parent = bottom
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            return b
        end
        local playBtn = makeBotBtn("Play last", 12)
        local stopBtn = makeBotBtn("Stop", 120)
        local slowBtn = makeBotBtn("Speed −", 228)
        local fastBtn = makeBotBtn("Speed +", 336)

        playBtn.MouseButton1Click:Connect(function()
            if emoteState.lastId then playEmoteId(emoteState.lastId) end
        end)
        stopBtn.MouseButton1Click:Connect(function()
            stopEmote()
        end)
        slowBtn.MouseButton1Click:Connect(function()
            emoteState.speed = math.clamp(emoteState.speed - 0.1, 0.1, 5)
            applySpeed()
            emoteSave()
            speedLbl.Text = string.format("%.2fx", emoteState.speed)
        end)
        fastBtn.MouseButton1Click:Connect(function()
            emoteState.speed = math.clamp(emoteState.speed + 0.1, 0.1, 5)
            applySpeed()
            emoteSave()
            speedLbl.Text = string.format("%.2fx", emoteState.speed)
        end)

        local catalogItems = {}
        local catalogCursor = nil
        local loadingCatalog = false

        local function clearList()
            for _, c in ipairs(list:GetChildren()) do
                if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
            end
        end

        local function addRow(entry)
            local id = tostring(entry.id)
            local name = tostring(entry.name or id)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -4, 0, 40)
            row.BackgroundColor3 = T.bg3
            row.BorderSizePixel = 0
            row.Parent = list
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

            local nm = Instance.new("TextLabel")
            nm.BackgroundTransparency = 1
            nm.Position = UDim2.fromOffset(10, 4)
            nm.Size = UDim2.new(1, -150, 0, 18)
            nm.Font = Enum.Font.GothamMedium
            nm.TextSize = 12
            nm.TextColor3 = T.text
            nm.TextXAlignment = Enum.TextXAlignment.Left
            nm.TextTruncate = Enum.TextTruncate.AtEnd
            nm.Text = name
            nm.Parent = row

            local idl = Instance.new("TextLabel")
            idl.BackgroundTransparency = 1
            idl.Position = UDim2.fromOffset(10, 22)
            idl.Size = UDim2.new(1, -150, 0, 14)
            idl.Font = Enum.Font.Code
            idl.TextSize = 10
            idl.TextColor3 = T.text3
            idl.TextXAlignment = Enum.TextXAlignment.Left
            idl.Text = id
            idl.Parent = row

            local favBtn = Instance.new("TextButton")
            favBtn.AnchorPoint = Vector2.new(1, 0.5)
            favBtn.Position = UDim2.new(1, -88, 0.5, 0)
            favBtn.Size = UDim2.fromOffset(36, 26)
            favBtn.BackgroundColor3 = T.bg2
            favBtn.BorderSizePixel = 0
            favBtn.Font = Enum.Font.GothamBold
            favBtn.TextSize = 12
            favBtn.TextColor3 = isFav(id) and T.accent or T.text3
            favBtn.Text = isFav(id) and "★" or "☆"
            favBtn.Parent = row
            Instance.new("UICorner", favBtn).CornerRadius = UDim.new(0, 5)
            favBtn.MouseButton1Click:Connect(function()
                local on = toggleFav(id)
                favBtn.Text = on and "★" or "☆"
                favBtn.TextColor3 = on and T.accent or T.text3
            end)

            local go = Instance.new("TextButton")
            go.AnchorPoint = Vector2.new(1, 0.5)
            go.Position = UDim2.new(1, -10, 0.5, 0)
            go.Size = UDim2.fromOffset(70, 26)
            go.BackgroundColor3 = T.accent
            go.BorderSizePixel = 0
            go.Font = Enum.Font.GothamBold
            go.TextSize = 12
            go.TextColor3 = Color3.fromRGB(10, 10, 10)
            go.Text = "Play"
            go.Parent = row
            Instance.new("UICorner", go).CornerRadius = UDim.new(0, 5)
            go.MouseButton1Click:Connect(function()
                playEmoteId(id)
            end)
        end

        local function sourceList()
            if activeTab == "fav" then
                local out = {}
                for _, id in ipairs(emoteState.favs) do
                    local name = id
                    for _, e in ipairs(BUILTIN_EMOTES) do
                        if e.id == tostring(id) then name = e.name break end
                    end
                    for _, e in ipairs(catalogItems) do
                        if e.id == tostring(id) then name = e.name break end
                    end
                    table.insert(out, { name = name, id = tostring(id) })
                end
                return out
            elseif activeTab == "catalog" then
                return catalogItems
            else
                local out = {}
                for _, e in ipairs(BUILTIN_EMOTES) do table.insert(out, e) end
                for _, e in ipairs(catalogItems) do table.insert(out, e) end
                return out
            end
        end

        local function render()
            clearList()
            local q = string.lower(search.Text or "")
            local n = 0
            for _, e in ipairs(sourceList()) do
                if q == "" or string.find(string.lower(e.name), q, 1, true) or string.find(tostring(e.id), q, 1, true) then
                    addRow(e)
                    n = n + 1
                end
            end
            if n == 0 then
                local empty = Instance.new("TextLabel")
                empty.Size = UDim2.new(1, 0, 0, 40)
                empty.BackgroundTransparency = 1
                empty.Font = Enum.Font.Gotham
                empty.TextSize = 12
                empty.TextColor3 = T.text3
                empty.Text = activeTab == "catalog" and "Loading catalog…" or "No emotes"
                empty.Parent = list
            end
        end

        local function setTab(which, btn)
            activeTab = which
            for _, b in ipairs({ tabAll, tabFav, tabCatalog }) do
                b.BackgroundColor3 = T.bg3
                b.TextColor3 = T.text2
            end
            btn.BackgroundColor3 = T.accent
            btn.TextColor3 = Color3.fromRGB(10, 10, 10)
            render()
        end
        tabAll.MouseButton1Click:Connect(function() setTab("all", tabAll) end)
        tabFav.MouseButton1Click:Connect(function() setTab("fav", tabFav) end)
        tabCatalog.MouseButton1Click:Connect(function()
            setTab("catalog", tabCatalog)
            if #catalogItems == 0 and not loadingCatalog then
                loadingCatalog = true
                task.spawn(function()
                    local pages = 0
                    local cursor = nil
                    while pages < 8 do -- up to ~240 catalog items
                        local items, nextC = fetchCatalogPage(cursor)
                        for _, it in ipairs(items) do
                            table.insert(catalogItems, it)
                        end
                        pages = pages + 1
                        cursor = nextC
                        if activeTab == "catalog" then render() end
                        if not nextC or nextC == "" or #items == 0 then break end
                        task.wait(0.15)
                    end
                    loadingCatalog = false
                    if activeTab == "catalog" then render() end
                    N0IR:Notify({
                        Title = "Emotes",
                        Content = "Catalog loaded · " .. tostring(#catalogItems) .. " UGC items",
                        Duration = 2,
                    })
                end)
            end
        end)

        search:GetPropertyChangedSignal("Text"):Connect(function()
            render()
        end)

        setTab("all", tabAll)

        -- preload a few catalog pages in background for All tab
        task.spawn(function()
            if loadingCatalog then return end
            loadingCatalog = true
            local cursor = nil
            for _ = 1, 5 do
                local items, nextC = fetchCatalogPage(cursor)
                for _, it in ipairs(items) do table.insert(catalogItems, it) end
                cursor = nextC
                if not nextC or #items == 0 then break end
                task.wait(0.12)
            end
            loadingCatalog = false
            if activeTab == "all" and emoteState.gui then render() end
        end)
    end

    _G._N0IR_OpenEmoteBrowser = openBrowser
    _G._N0IR_CloseEmoteBrowser = closeBrowser
    _G._N0IR_OpenEmotesHint = openBrowser

    Emotes:CreateSection("Browser")
    Emotes:CreateParagraph({
        Content = "Standalone NØIR emote browser — built-in library (100+) plus live UGC catalog. No animation packs.",
    })
    Emotes:CreateButton({
        Name = "Open Emote Browser",
        Callback = function()
            openBrowser()
        end,
    })
    Emotes:CreateButton({
        Name = "Close Emote Browser",
        Callback = function()
            closeBrowser()
        end,
    })

    Emotes:CreateSection("Quick play")
    local emoteIdInput = Emotes:CreateInput({
        Name = "Animation / Emote ID",
        Placeholder = "e.g. 507770239",
        Default = tostring(emoteState.lastId or ""),
        Callback = function(text)
            emoteState.lastId = tostring(text or ""):gsub("%s+", "")
        end,
    })
    Emotes:CreateButton({
        Name = "Play emote",
        Callback = function()
            local id = emoteIdInput and emoteIdInput:Get() or emoteState.lastId
            playEmoteId(id)
        end,
    })
    Emotes:CreateButton({
        Name = "Stop emote",
        Callback = function()
            stopEmote()
        end,
    })

    Emotes:CreateSection("Speed")
    local speedLbl2 = Emotes:CreateLabel("Speed  ·  " .. string.format("%.2fx", emoteState.speed))
    Emotes:CreateSlider({
        Name = "Emote speed",
        Min = 0.1,
        Max = 3,
        Default = emoteState.speed,
        Increment = 0.05,
        Callback = function(v)
            emoteState.speed = tonumber(v) or 1
            applySpeed()
            speedLbl2:Set("Speed  ·  " .. string.format("%.2fx", emoteState.speed))
            emoteSave()
        end,
    })

    Emotes:CreateSection("Keybinds")
    local function bindLabel(title, key)
        return title .. "  ·  " .. (key and key.Name or "None")
    end
    local openKeyLbl = Emotes:CreateLabel(bindLabel("Open browser", emoteState.openKey))
    local playKeyLbl = Emotes:CreateLabel(bindLabel("Play last", emoteState.playKey))
    local stopKeyLbl = Emotes:CreateLabel(bindLabel("Stop", emoteState.stopKey))
    local listeningEmote = false
    local function listenEmoteKey(labelObj, field, pretty)
        if listeningEmote then return end
        listeningEmote = true
        labelObj:Set("Press any key...")
        task.delay(0.15, function()
            local conn
            conn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                if not conn then return end
                conn:Disconnect()
                listeningEmote = false
                if input.KeyCode == Enum.KeyCode.Escape then
                    labelObj:Set(bindLabel(pretty, emoteState[field]))
                    return
                end
                emoteState[field] = input.KeyCode
                labelObj:Set(bindLabel(pretty, input.KeyCode))
                emoteSave()
            end)
        end)
    end
    Emotes:CreateButton({ Name = "Set open key", Callback = function() listenEmoteKey(openKeyLbl, "openKey", "Open browser") end })
    Emotes:CreateButton({ Name = "Set play key", Callback = function() listenEmoteKey(playKeyLbl, "playKey", "Play last") end })
    Emotes:CreateButton({ Name = "Set stop key", Callback = function() listenEmoteKey(stopKeyLbl, "stopKey", "Stop") end })

    if not _G._N0IR_EmoteKeysInstalled then
        _G._N0IR_EmoteKeysInstalled = true
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if UserInputService:GetFocusedTextBox() then return end
            local k = input.KeyCode
            if emoteState.openKey and k == emoteState.openKey then
                openBrowser()
            elseif emoteState.playKey and k == emoteState.playKey then
                if emoteState.lastId then playEmoteId(emoteState.lastId, true) end
            elseif emoteState.stopKey and k == emoteState.stopKey then
                stopEmote()
            elseif emoteState.speedUpKey and k == emoteState.speedUpKey then
                emoteState.speed = math.clamp(emoteState.speed + 0.1, 0.1, 5)
                applySpeed()
                emoteSave()
            elseif emoteState.speedDownKey and k == emoteState.speedDownKey then
                emoteState.speed = math.clamp(emoteState.speed - 0.1, 0.1, 5)
                applySpeed()
                emoteSave()
            end
        end)
    end

    local Cmds = Window:CreateTab({ Name = "Commands" })
    Cmds:CreateSection("Runner")
    Cmds:CreateParagraph({
        Content = "Click Run on any command. Commands that need a value show an input. Empty required args → notification. Chat prefix and cmd-bar key are configurable in Settings.",
    })

    -- Shared config (also written from Settings)
    local prefix = tostring(_G._N0IR_CmdPrefix or ";")
    local cmdBarKey = _G._N0IR_CmdBarKey or Enum.KeyCode.Semicolon
    local menuToggleKey = _G._N0IR_ToggleKey or Enum.KeyCode.M

    -- ============================================================
    -- OWNER IDS  ·  edit this list to unlock owner-only commands
    -- Put your Roblox UserId(s) here (numbers). Multiple allowed.
    -- Example: { 123456789, 987654321 }
    -- ============================================================
    local OWNER_IDS = {
        -- YOUR_USER_ID_HERE,
    }
    -- Also accept runtime override: _G._N0IR_OwnerIds = { 123 }
    local function isOwner()
        local uid = LocalPlayer and LocalPlayer.UserId
        if not uid then return false end
        local list = (type(_G._N0IR_OwnerIds) == "table" and _G._N0IR_OwnerIds) or OWNER_IDS
        for _, id in ipairs(list) do
            if tonumber(id) == tonumber(uid) then return true end
        end
        return false
    end
    _G._N0IR_IsOwner = isOwner

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



        if cmd == "freegamepass" or cmd == "fgp" then
            if _G._N0IR_FreeGamepassLoaded then
                notify("FGP", "Already loaded")
                return
            end
            notify("FGP", "Loading free gamepass…")
            task.spawn(function()
                local src
                if type(_G._N0IR_FreeGamepassSource) == "string" and #_G._N0IR_FreeGamepassSource > 500 then
                    src = _G._N0IR_FreeGamepassSource
                end
                if not src then
                    pcall(function()
                        if isfile and isfile("N0IR/freegamepass.luau") then
                            src = readfile("N0IR/freegamepass.luau")
                        elseif isfile and isfile("freegamepass.luau") then
                            src = readfile("freegamepass.luau")
                        end
                    end)
                end
                if not src then
                    local urls = {
                        "https://raw.githubusercontent.com/H1tss/extras/refs/heads/main/freegamepass.luau",
                        "https://raw.githubusercontent.com/H1tss/extras/main/freegamepass.luau",
                    }
                    for _, u in ipairs(urls) do
                        local ok, body = pcall(function() return game:HttpGet(u) end)
                        if ok and type(body) == "string" and #body > 500 and not body:find("^404") then
                            src = body
                            break
                        end
                    end
                end
                if not src then
                    notify("FGP", "Host freegamepass.luau or set _G._N0IR_FreeGamepassSource")
                    return
                end
                pcall(function()
                    if getgenv then
                        getgenv().Settings = getgenv().Settings or {
                            CopyButton = false,
                            AutoButton = false,
                            AutoInterval = 0.3,
                            InstantPurchase = false,
                            AutoMassPurchase = false,
                            Debug = false,
                        }
                    end
                end)
                local ok, err = pcall(function()
                    local fn = loadstring(src)
                    if not fn then error("loadstring failed") end
                    fn()
                end)
                if ok then
                    _G._N0IR_FreeGamepassLoaded = true
                    notify("FGP", "Loaded — open a gamepass prompt for Free button")
                else
                    notify("FGP", "Error: " .. tostring(err):sub(1, 80))
                end
            end)
            return
        elseif cmd == "dropkick" or cmd == "dkf" then
            if _G._N0IR_DropkickLoaded then
                notify("DropKick", "Already loaded")
                return
            end
            notify("DropKick", "Loading NØIR Drop Kick…")
            task.spawn(function()
                local src = _G._N0IR_DropkickSource
                if type(src) ~= "string" or #src < 500 then
                    pcall(function()
                        if isfile and isfile("N0IR/dropkick.luau") then
                            src = readfile("N0IR/dropkick.luau")
                        end
                    end)
                end
                if type(src) ~= "string" or #src < 500 then
                    notify("DropKick", "Missing source")
                    return
                end
                local ok, err = pcall(function()
                    local fn = loadstring(src)
                    if not fn then error("loadstring failed") end
                    fn()
                end)
                if ok then
                    _G._N0IR_DropkickLoaded = true
                    notify("DropKick", "Ready · gear menu / Left Ctrl")
                else
                    notify("DropKick", "Error: " .. tostring(err):sub(1, 90))
                end
            end)
            return
        end

        -- bulk alias / shortcut router (300+ catalog support)
        do
            local aliasMap = {
                speed="ws", walkspeed="ws", setws="ws", setspeed="ws", runspeed="ws",
                jumppower="jp", setjp="jp", setjump="jp", hipheight="hh", sethh="hh",
                loopspeed="loopws", loopjump="loopjp", super="power", boost="power",
                defaults="normal", default="normal", resetstats="normal", form="normal", stats="normal", unpower="normal",
                to="goto", tp="goto", teleport="goto", gotoplayer="goto", tpto="goto",
                spectate="view", watch="view", cam="view", unspectate="unview", spectateoff="unview", uncam="unview",
                noclipon="noclip", walkthrough="noclip", nclip="noclip", phaser="noclip",
                clipon="clip", solid="clip",
                flyon="fly", jetpack="fly", flyoff="unfly", land="unfly", unflyme="unfly",
                infinitejump="infjump", uninfinitejump="uninfjump",
                ctp="clicktp", clickteleport="clicktp", blink="clicktp", unctp="unclicktp", unblink="unclicktp",
                rj="rejoin", rejoinserver="rejoin", rejoinplace="rejoin", rejoinhop="rejoin",
                serverhop="hop", serverswitch="hop", hopserver="hop",
                killme="reset", die="reset", respawn="re", refresh="re", refreshchar="re",
                stand="unsit", sitdown="sit", standup="unsit",
                platformstand="plat", unplatformstand="unplat",
                fpscap="fps", setfps="fps", fieldofview="fov", setfov="fov",
                setgravity="gravity", clocktime="time", settime="time", daytime="day", nighttime="night",
                fb="fullbright", bright="fullbright", fullbrighton="fullbright",
                removefog="nofog", clearfog="nofog", fogoff="nofog",
                setbrightness="brightness", setambient="ambient", setexposure="exposure",
                wallhack="xray", xrayon="xray", unwallhack="unxray", xrayoff="unxray",
                perf="lowgfx", performance="lowgfx", gfxlow="lowgfx", quality="highgfx", gfxhigh="highgfx",
                boxes="esp", espall="esp", espnames="esp", nameesp="esp", noesp="unesp", hideesp="unesp",
                godmode="god", godon="god", immortal="god", ungodmode="ungod", godoff="ungod", mortal="ungod",
                invisible="invis", hide="invis", ghost="invis", visible="vis", showself="vis", show="vis", unghost="vis",
                anchor="freeze", unanchor="thaw", unfreeze="thaw",
                spinme="spin", stopspin="unspin", stoporbit="unorbit", uncircle="unorbit", circle="orbit",
                copychar="copy", copyavatar="copy", clone="copy", stealavatar="copy",
                btools="tools", buildingtools="tools", hammer="tools", f3x="tools", toolsget="tools",
                clr="clear", cleanup="clear", clearall="clear",
                noragdoll="antiragdoll", norag="antiragdoll", ragdolloff="antiragdoll", ragdollblock="antiragdoll",
                allowragdoll="unantiragdoll", yesrag="unantiragdoll", ragdollon="unantiragdoll", ragdollallow="unantiragdoll",
                ["anti-afk"]="antiafk", noafk="antiafk", afkoff="antiafk", idlekick="antiafk", afkprotect="antiafk",
                firstperson="fp", fpk="fp", lockcam="fp", thirdperson="tp3", tpk="tp3", freecam3="tp3",
                setmaxzoom="maxzoom", setminzoom="minzoom", mouselock="shiftlock", shift="shiftlock", shiftlockon="shiftlock", lockmouse="shiftlock",
                setvolume="volume", vol="volume", getping="ping", pingms="ping", latency="ping", ms="ping",
                accountage="age", days="age", userid="id", uid="id", useridof="id",
                getjobid="jobid", jid="jobid", serverid="jobid", getplaceid="placeid", pid="placeid", gameid="placeid",
                setprefix="prefix", pre="prefix", changeprefix="prefix",
                vc="vcbypass", antivc="vcbypass", vcon="vcbypass", bypassvc="vcbypass", voicebypass="vcbypass",
                playemote="emote", playanim="emote", emotestop="stopemote", stopanim="stopemote", stopemotes="stopemote", emotestopall="stopemote", stopdance="stopemote",
                espeed="emotespeed", animspeed="emotespeed",
                emotebrowser="afem", fgp="freegamepass", dkf="dropkick", openemotes="afem", browseemotes="afem", emotelib="afem", elist="afem", emotegui="afem", emotemenu="afem",
                commands="cmds", help="cmds", cmd="cmds", ["?"]="cmds", cmdlist="cmds", commandlist="cmds", helpcmds="cmds",
                leave="exit", quit="exit", leavegame="exit", exitgame="exit", disconnect="exit", ragequit="exit",
                unbang="stopadult", unfuck="stopadult", rpstop="stopadult", stoprp="stopadult", adultstop="stopadult", rpend="stopadult", stopallrp="stopadult", stopadult2="stopadult", headbangstop="stopadult",
                pull="bring", summon="bring", setpos="tppos", move="tppos",
                anchorall="freezeall", unanchorall="thawall", yeet="fling", launch="fling",
            }
            if aliasMap[cmd] then
                cmd = aliasMap[cmd]
            end
        end

        -- preset shortcuts
        if cmd == "run" then cmd = "ws"; args = {"24"}
        elseif cmd == "sprint" then cmd = "ws"; args = {"32"}
        elseif cmd == "slow" then cmd = "ws"; args = {"8"}
        elseif cmd == "turtle" then cmd = "ws"; args = {"4"}
        elseif cmd == "fast" then cmd = "ws"; args = {"50"}
        elseif cmd == "sonic" then cmd = "ws"; args = {"100"}
        elseif cmd == "ws16" then cmd = "ws"; args = {"16"}
        elseif cmd == "ws20" then cmd = "ws"; args = {"20"}
        elseif cmd == "ws50" then cmd = "ws"; args = {"50"}
        elseif cmd == "ws100" then cmd = "ws"; args = {"100"}
        elseif cmd == "walk" then cmd = "normal"; args = {}
        elseif cmd == "highjump" then cmd = "jp"; args = {"100"}
        elseif cmd == "superjump" then cmd = "jp"; args = {"200"}
        elseif cmd == "jumpreset" or cmd == "jp50" then cmd = "jp"; args = {"50"}
        elseif cmd == "jp100" then cmd = "jp"; args = {"100"}
        elseif cmd == "moonwalk" or cmd == "g50" then cmd = "gravity"; args = {"50"}
        elseif cmd == "earth" or cmd == "g196" then cmd = "gravity"; args = {"196.2"}
        elseif cmd == "space" then cmd = "gravity"; args = {"20"}
        elseif cmd == "nograv" or cmd == "g0" then cmd = "gravity"; args = {"0"}
        elseif cmd == "hipreset" then cmd = "hh"; args = {"0"}
        elseif cmd == "tall" then cmd = "hh"; args = {"5"}
        elseif cmd == "short" then cmd = "hh"; args = {"-1"}
        elseif cmd == "float" then cmd = "hh"; args = {"10"}
        elseif cmd == "freezepos" then cmd = "freeze"; args = {LocalPlayer.Name}
        elseif cmd == "thawself" then cmd = "thaw"; args = {LocalPlayer.Name}
        elseif cmd == "spinfast" then cmd = "spin"; args = {"50"}
        elseif cmd == "spinslow" then cmd = "spin"; args = {"5"}
        elseif cmd == "flyfast" then cmd = "fly"; args = {"100"}
        elseif cmd == "flyslow" then cmd = "fly"; args = {"25"}
        elseif cmd == "fovreset" then cmd = "fov"; args = {"70"}
        elseif cmd == "fovwide" then cmd = "fov"; args = {"100"}
        elseif cmd == "fovzoom" then cmd = "fov"; args = {"40"}
        elseif cmd == "fps30" then cmd = "fps"; args = {"30"}
        elseif cmd == "fps60" then cmd = "fps"; args = {"60"}
        elseif cmd == "fps120" then cmd = "fps"; args = {"120"}
        elseif cmd == "fpsunlock" then cmd = "fps"; args = {"999"}
        elseif cmd == "noon" or cmd == "time12" then cmd = "time"; args = {"12"}
        elseif cmd == "midnight" or cmd == "time0" then cmd = "time"; args = {"0"}
        elseif cmd == "sunrise" or cmd == "time6" then cmd = "time"; args = {"6"}
        elseif cmd == "sunset" or cmd == "time18" then cmd = "time"; args = {"18"}
        elseif cmd == "time21" then cmd = "time"; args = {"21"}
        elseif cmd == "pitchblack" then cmd = "brightness"; args = {"0"}
        elseif cmd == "overbright" or cmd == "brightmax" then cmd = "brightness"; args = {"5"}
        elseif cmd == "ambientwhite" then cmd = "ambient"; args = {"1","1","1"}
        elseif cmd == "ambientblack" then cmd = "ambient"; args = {"0","0","0"}
        elseif cmd == "exposure0" then cmd = "exposure"; args = {"0"}
        elseif cmd == "exposure2" then cmd = "exposure"; args = {"2"}
        elseif cmd == "zoommax" or cmd == "zoomout" then cmd = "maxzoom"; args = {"200"}
        elseif cmd == "zoommin" or cmd == "zoomin" then cmd = "minzoom"; args = {"0.5"}
        elseif cmd == "vol0" or cmd == "mute" then cmd = "volume"; args = {"0"}
        elseif cmd == "vol5" or cmd == "unmute" then cmd = "volume"; args = {"5"}
        elseif cmd == "vol10" or cmd == "loud" then cmd = "volume"; args = {"10"}
        elseif cmd == "quiet" then cmd = "volume"; args = {"2"}
        elseif cmd == "prefixsemi" then cmd = "prefix"; args = {";"}
        elseif cmd == "prefixdot" then cmd = "prefix"; args = {"."}
        elseif cmd == "prefixbang" then cmd = "prefix"; args = {"!"}
        elseif cmd == "loopwalk" then cmd = "loopws"; args = {"16"}
        elseif cmd == "unloopwalk" then cmd = "unloopws"; args = {}
        elseif cmd == "loopj" then cmd = "loopjp"; args = {"50"}
        elseif cmd == "unloopj" then cmd = "unloopjp"; args = {}
        elseif cmd == "emotewave" or cmd == "wave" then cmd = "emote"; args = {"507770239"}
        elseif cmd == "emotedance" or cmd == "dance" then cmd = "emote"; args = {"507771019"}
        elseif cmd == "emotelaugh" or cmd == "laugh" then cmd = "emote"; args = {"507770818"}
        elseif cmd == "emotepoint" or cmd == "point" then cmd = "emote"; args = {"507770453"}
        elseif cmd == "emotecheer" or cmd == "cheer" then cmd = "emote"; args = {"507770677"}
        elseif cmd == "emotesit" or cmd == "sitanim" then cmd = "emote"; args = {"507768133"}
        elseif cmd == "speed1" then cmd = "emotespeed"; args = {"1"}
        elseif cmd == "speed2" then cmd = "emotespeed"; args = {"2"}
        elseif cmd == "speed05" then cmd = "emotespeed"; args = {"0.5"}
        elseif cmd == "safe" then
            -- chain handled below as multi
        end

        if cmd == "safe" then
            pcall(function() runCmd("normal") end)
            pcall(function() runCmd("clip") end)
            pcall(function() runCmd("unfly") end)
            pcall(function() runCmd("ungod") end)
            notify("Safe", "Defaults restored")
            return
        elseif cmd == "pvp" then
            pcall(function() runCmd("ws 20") end)
            pcall(function() runCmd("jp 50") end)
            pcall(function() runCmd("ungod") end)
            notify("PVP", "WS 20 · JP 50 · god off")
            return
        elseif cmd == "explore" then
            pcall(function() runCmd("ws 30") end)
            notify("Explore", "WS 30 — use ;fly when needed")
            return
        elseif cmd == "camreset" then
            pcall(function() runCmd("unview") end)
            pcall(function() runCmd("tp3") end)
            notify("Camera", "Reset")
            return
        elseif cmd == "tpzero" then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(0, 10, 0) end
            notify("TP", "Origin")
            return
        elseif cmd == "tpup" or cmd == "tpdown" or cmd == "tpfwd" or cmd == "tpback" then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local o = hrp.CFrame
                if cmd == "tpup" then hrp.CFrame = o + Vector3.new(0, 50, 0)
                elseif cmd == "tpdown" then hrp.CFrame = o + Vector3.new(0, -20, 0)
                elseif cmd == "tpfwd" then hrp.CFrame = o + o.LookVector * 20
                else hrp.CFrame = o - o.LookVector * 20 end
            end
            notify("TP", cmd)
            return
        elseif cmd == "coords" or cmd == "pos" or cmd == "where" then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local p = hrp.Position
                notify("Pos", string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z))
            end
            return
        elseif cmd == "health" or cmd == "hp" then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then notify("HP", string.format("%.0f / %.0f", hum.Health, hum.MaxHealth)) end
            return
        elseif cmd == "maxhp" then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then notify("MaxHP", tostring(hum.MaxHealth)) end
            return
        elseif cmd == "team" then
            notify("Team", LocalPlayer.Team and LocalPlayer.Team.Name or "None")
            return
        elseif cmd == "displayname" then
            notify("Display", LocalPlayer.DisplayName)
            return
        elseif cmd == "username" then
            notify("User", LocalPlayer.Name)
            return
        elseif cmd == "myid" then
            notify("UserId", tostring(LocalPlayer.UserId))
            return
        elseif cmd == "myage" then
            notify("Age", tostring(LocalPlayer.AccountAge) .. " days")
            return
        elseif cmd == "playercount" or cmd == "players" or cmd == "plrs" then
            local names = {}
            for _, pl in ipairs(Players:GetPlayers()) do table.insert(names, pl.Name) end
            notify("Players (" .. #names .. ")", table.concat(names, ", "):sub(1, 120))
            return
        elseif cmd == "nearest" or cmd == "farthest" then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local best, bestD = nil, cmd == "nearest" and math.huge or -1
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (pl.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if cmd == "nearest" and d < bestD then best, bestD = pl, d
                    elseif cmd == "farthest" and d > bestD then best, bestD = pl, d end
                end
            end
            if best then notify(cmd, best.Name .. string.format(" (%.0f studs)", bestD)) else notify(cmd, "None") end
            return
        elseif cmd == "serverinfo" then
            notify("Server", "Place " .. tostring(game.PlaceId) .. " · Job " .. tostring(game.JobId):sub(1, 12) .. " · " .. #Players:GetPlayers() .. " plrs")
            return
        elseif cmd == "notifytest" then
            notify("NØIR", "Notify OK")
            return
        elseif cmd == "sayhi" then
            pcall(function() Players:Chat("hi") end)
            return
        elseif cmd == "version" or cmd == "ver" then
            notify("NØIR", "v" .. tostring(N0IR.Version or "?"))
            return
        elseif cmd == "credits" then
            notify("Credits", "NØIR · key system · nametags · suite")
            return
        elseif cmd == "discord" or cmd == "support" then
            notify("Discord", "discord.gg/JGDAWjhWzp")
            return
        elseif cmd == "site" or cmd == "website" then
            notify("Site", "https://n0ir.pages.dev")
            return
        elseif cmd == "nametag" or cmd == "rank" or cmd == "keyinfo" then
            local d = Nametag and Nametag.MyData
            if d then
                notify("Key", "Rank " .. tostring(d.rank or "?") .. " · Tag " .. tostring(d.tag or "NØIR"))
            else
                notify("Key", "No data yet")
            end
            return
        elseif cmd == "menu" or cmd == "uishow" then
            notify("Menu", "Toggle key · check Settings")
            return
        elseif cmd == "admin" or cmd == "owner" then
            notify("Owner", "Some cmds require owner rank")
            return
        elseif cmd == "heal" then
            notify("Heal", "Use ;god for infinite HP")
            return
        elseif cmd == "fullbrightoff" or cmd == "fogon" then
            notify("Lighting", "Rejoin to fully restore default lighting")
            return
        elseif cmd == "bringme" then
            notify("Bring", "Owner: ;bring name")
            return
        elseif cmd == "annoy" then
            notify("Annoy", "Try ;fling name or ;spin")
            return
        elseif cmd == "say" or cmd == "spamchat" or cmd == "notify" then
            local msg = table.concat(args, " ")
            if cmd == "notify" then notify("NØIR", msg ~= "" and msg or "...")
            else pcall(function() Players:Chat(msg) end) end
            return
        end


        if cmd == "emote" or cmd == "playemote" then
            local id = args[1]
            if type(_G._N0IR_PlayEmote) == "function" then
                _G._N0IR_PlayEmote(id)
            else
                notify("Emotes", "Emotes module not ready")
            end
            return
        elseif cmd == "emotes" then
            if type(_G._N0IR_OpenEmotesHint) == "function" then _G._N0IR_OpenEmotesHint() end
            notify("Emotes", "Open the Emotes tab")
            return
        elseif cmd == "stopemote" or cmd == "emotestop" then
            if type(_G._N0IR_StopEmote) == "function" then _G._N0IR_StopEmote() end
            notify("Emotes", "Stopped")
            return
        elseif cmd == "emotespeed" or cmd == "espeed" then
            local sp = tonumber(args[1])
            if sp and type(_G._N0IR_SetEmoteSpeed) == "function" then
                _G._N0IR_SetEmoteSpeed(sp)
                notify("Emotes", "Speed " .. string.format("%.2fx", sp))
            else
                notify("Emotes", "Usage: emotespeed 1.5")
            end
            return
        elseif cmd == "afem" or cmd == "emotebrowser" then
            if type(_G._N0IR_OpenEmoteBrowser) == "function" then
                _G._N0IR_OpenEmoteBrowser()
            end
            return
        end
        if not cmd then return end

        -- Owner-only command set (must match catalog ownerOnly flags)
        local OWNER_CMDS = {
            bring = true,
            -- add more restricted cmd names here (lowercase):
            -- kill = true,
        }
        if OWNER_CMDS[cmd] and not isOwner() then
            notify("Commands", "Owner only")
            return
        end

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

            local function resolveMyRoot()
                -- Prefer reanim clone root when present
                local clone
                pcall(function()
                    if ReanimateAPI and ReanimateAPI.get_clone then
                        clone = ReanimateAPI.get_clone(LocalPlayer)
                    elseif _G.ReanimateAPI and _G.ReanimateAPI.get_clone then
                        clone = _G.ReanimateAPI.get_clone(LocalPlayer)
                    end
                end)
                if clone then
                    local r = clone:FindFirstChild("HumanoidRootPart")
                    if r then return r end
                end
                return getHRP()
            end

            local thrp = t.Character and t.Character:FindFirstChild("HumanoidRootPart")
            local me = resolveMyRoot()
            local myHum = getHum()
            if not thrp or not me then
                notify(cmd, "Characters not ready")
                return
            end

            -- stop previous
            if _G._N0IR_AdultConn then _G._N0IR_AdultConn:Disconnect(); _G._N0IR_AdultConn = nil end
            if _G._N0IR_AdultTrack then pcall(function() _G._N0IR_AdultTrack:Stop() end); _G._N0IR_AdultTrack = nil end

            local offsets = {
                headbang = CFrame.new(0, -0.15, -1.05) * CFrame.Angles(math.rad(-25), 0, 0),
                headfuck = CFrame.new(0, -0.15, -1.05) * CFrame.Angles(math.rad(-25), 0, 0),
                bang = CFrame.new(0, 0, -1.15) * CFrame.Angles(math.rad(8), math.rad(180), 0),
                fuck = CFrame.new(0, 0, -1.15) * CFrame.Angles(math.rad(8), math.rad(180), 0),
                suck = CFrame.new(0, -0.95, -0.85) * CFrame.Angles(math.rad(75), 0, 0),
                blowjob = CFrame.new(0, -0.95, -0.85) * CFrame.Angles(math.rad(75), 0, 0),
                lickbutt = CFrame.new(0, -0.65, 1.05) * CFrame.Angles(math.rad(35), math.rad(180), 0),
                peg = CFrame.new(0, 0, 1.2) * CFrame.Angles(math.rad(5), 0, 0),
            }
            local off = offsets[cmd] or offsets.bang
            local bobAmp = (cmd == "headbang" or cmd == "headfuck") and 0.08 or 0.06
            local bobSpd = (cmd == "headbang" or cmd == "headfuck") and 14 or 11

            -- Try animator on real humanoid (may fail under reanim — OK)
            pcall(function()
                if not myHum then return end
                local animator = myHum:FindFirstChildOfClass("Animator")
                if not animator then
                    animator = Instance.new("Animator")
                    animator.Parent = myHum
                end
                local anim = Instance.new("Animation")
                -- use built-in emote-style ids as soft fallback
                anim.AnimationId = (cmd == "suck" or cmd == "blowjob" or cmd == "lickbutt")
                    and "rbxassetid://698251653"
                    or "rbxassetid://5918726674"
                local track = animator:LoadAnimation(anim)
                track.Looped = true
                track.Priority = Enum.AnimationPriority.Action4
                track:Play(0.1, 1, 1.1)
                _G._N0IR_AdultTrack = track
            end)

            -- Always drive position procedurally (works with reanim + normal)
            local t0 = tick()
            _G._N0IR_AdultConn = RunService.Heartbeat:Connect(function()
                local target = t.Character and t.Character:FindFirstChild("HumanoidRootPart")
                local selfHRP = resolveMyRoot()
                if not target or not selfHRP then return end
                local bob = math.sin((tick() - t0) * bobSpd) * bobAmp
                local thrust = math.sin((tick() - t0) * bobSpd) * 0.05
                local cf = target.CFrame * off * CFrame.new(0, bob, thrust)
                selfHRP.CFrame = cf
                selfHRP.AssemblyLinearVelocity = Vector3.zero
                selfHRP.AssemblyAngularVelocity = Vector3.zero
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
        { cmd = "bring",     label = "Bring player",  desc = "Bring player to you (owner)", needsArg = true,  example = "", ownerOnly = true },
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
        
        { cmd = "emote",     label = "Play emote",      desc = "Play animation id", needsArg = true, example = "507770239" },
        { cmd = "emotes",    label = "Emotes menu",     desc = "Hint Emotes tab", needsArg = false },
        { cmd = "stopemote", label = "Stop emote",      desc = "Stop playing emote", needsArg = false },
        { cmd = "emotespeed",label = "Emote speed",     desc = "Set emote speed", needsArg = true, example = "1.5" },
        { cmd = "afem",      label = "Load AFEM",       desc = "Load AFEM from saved URL", needsArg = false },

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
    
        { cmd = "freegamepass", label = "Free Gamepass", desc = "Load free gamepass helper", needsArg = false },
        { cmd = "fgp", label = "FGP", desc = "Alias freegamepass", needsArg = false },
        { cmd = "dropkick", label = "Drop Kick Fling", desc = "Load dropkick fling (NØIR UI)", needsArg = false },
        { cmd = "dkf", label = "DKF", desc = "Alias dropkick", needsArg = false },
        -- expanded command catalog (300+ with aliases)
        { cmd = "speed", label = "WalkSpeed alias", desc = "Alias of ws", needsArg = true, example = "50" },
        { cmd = "walkspeed", label = "WalkSpeed alias", desc = "Alias of ws", needsArg = true, example = "50" },
        { cmd = "setws", label = "Set WalkSpeed", desc = "Alias of ws", needsArg = true, example = "50" },
        { cmd = "setspeed", label = "Set speed", desc = "Alias of ws", needsArg = true, example = "50" },
        { cmd = "runspeed", label = "Run speed", desc = "Alias of ws", needsArg = true, example = "50" },
        { cmd = "jumppower", label = "JumpPower alias", desc = "Alias of jp", needsArg = true, example = "50" },
        { cmd = "setjp", label = "Set JumpPower", desc = "Alias of jp", needsArg = true, example = "50" },
        { cmd = "setjump", label = "Set jump", desc = "Alias of jp", needsArg = true, example = "50" },
        { cmd = "hipheight", label = "HipHeight alias", desc = "Alias of hh", needsArg = true, example = "2" },
        { cmd = "sethh", label = "Set hip height", desc = "Alias of hh", needsArg = true, example = "2" },
        { cmd = "loopspeed", label = "Loop speed", desc = "Alias of loopws", needsArg = true, example = "50" },
        { cmd = "loopjump", label = "Loop jump", desc = "Alias of loopjp", needsArg = true, example = "50" },
        { cmd = "super", label = "Power boost alias", desc = "Alias of power", needsArg = false },
        { cmd = "boost", label = "Power boost", desc = "Alias of power", needsArg = false },
        { cmd = "defaults", label = "Reset defaults", desc = "Alias of normal", needsArg = false },
        { cmd = "default", label = "Reset defaults", desc = "Alias of normal", needsArg = false },
        { cmd = "resetstats", label = "Reset stats", desc = "Alias of normal", needsArg = false },
        { cmd = "to", label = "Goto alias", desc = "Alias of goto", needsArg = true, example = "name" },
        { cmd = "tp", label = "TP player", desc = "Alias of goto", needsArg = true, example = "name" },
        { cmd = "teleport", label = "Teleport to player", desc = "Alias of goto", needsArg = true, example = "name" },
        { cmd = "spectate", label = "Spectate", desc = "Alias of view", needsArg = true, example = "name" },
        { cmd = "unspectate", label = "Unspectate", desc = "Alias of unview", needsArg = false },
        { cmd = "noclipon", label = "Noclip on", desc = "Alias of noclip", needsArg = false },
        { cmd = "clipon", label = "Clip on", desc = "Alias of clip", needsArg = false },
        { cmd = "walkthrough", label = "Walk through walls", desc = "Alias of noclip", needsArg = false },
        { cmd = "flyon", label = "Fly on", desc = "Alias of fly", needsArg = true, example = "50" },
        { cmd = "flyoff", label = "Fly off", desc = "Alias of unfly", needsArg = false },
        { cmd = "infinitejump", label = "Inf jump alias", desc = "Alias of infjump", needsArg = false },
        { cmd = "uninfinitejump", label = "Uninfjump alias", desc = "Alias of uninfjump", needsArg = false },
        { cmd = "ctp", label = "Click TP alias", desc = "Alias of clicktp", needsArg = false },
        { cmd = "unctp", label = "Unclick TP alias", desc = "Alias of unclicktp", needsArg = false },
        { cmd = "clickteleport", label = "Click teleport", desc = "Alias of clicktp", needsArg = false },
        { cmd = "rj", label = "Rejoin alias", desc = "Alias of rejoin", needsArg = false },
        { cmd = "rejoinserver", label = "Rejoin server", desc = "Alias of rejoin", needsArg = false },
        { cmd = "serverhop", label = "Server hop alias", desc = "Alias of hop", needsArg = false },
        { cmd = "serverswitch", label = "Switch server", desc = "Alias of hop", needsArg = false },
        { cmd = "killme", label = "Kill self", desc = "Alias of reset", needsArg = false },
        { cmd = "die", label = "Die", desc = "Alias of reset", needsArg = false },
        { cmd = "respawn", label = "Respawn", desc = "Alias of re", needsArg = false },
        { cmd = "refresh", label = "Refresh char", desc = "Alias of re", needsArg = false },
        { cmd = "refreshchar", label = "Refresh character", desc = "Alias of re", needsArg = false },
        { cmd = "stand", label = "Unsit alias", desc = "Alias of unsit", needsArg = false },
        { cmd = "platformstand", label = "Platform stand", desc = "Alias of plat", needsArg = false },
        { cmd = "unplatformstand", label = "Un platform stand", desc = "Alias of unplat", needsArg = false },
        { cmd = "fpscap", label = "FPS cap alias", desc = "Alias of fps", needsArg = true, example = "60" },
        { cmd = "setfps", label = "Set FPS", desc = "Alias of fps", needsArg = true, example = "60" },
        { cmd = "fieldofview", label = "FOV alias", desc = "Alias of fov", needsArg = true, example = "70" },
        { cmd = "setfov", label = "Set FOV", desc = "Alias of fov", needsArg = true, example = "70" },
        { cmd = "setgravity", label = "Set gravity", desc = "Alias of gravity", needsArg = true, example = "196" },
        { cmd = "clocktime", label = "Clock time", desc = "Alias of time", needsArg = true, example = "12" },
        { cmd = "settime", label = "Set time", desc = "Alias of time", needsArg = true, example = "12" },
        { cmd = "daytime", label = "Daytime", desc = "Alias of day", needsArg = false },
        { cmd = "nighttime", label = "Nighttime", desc = "Alias of night", needsArg = false },
        { cmd = "fb", label = "Fullbright alias", desc = "Alias of fullbright", needsArg = false },
        { cmd = "bright", label = "Fullbright", desc = "Alias of fullbright", needsArg = false },
        { cmd = "removefog", label = "Remove fog", desc = "Alias of nofog", needsArg = false },
        { cmd = "setbrightness", label = "Set brightness", desc = "Alias of brightness", needsArg = true, example = "2" },
        { cmd = "setambient", label = "Set ambient", desc = "Alias of ambient", needsArg = true, example = "1 1 1" },
        { cmd = "setexposure", label = "Set exposure", desc = "Alias of exposure", needsArg = true, example = "0" },
        { cmd = "wallhack", label = "XRay alias", desc = "Alias of xray", needsArg = false },
        { cmd = "unwallhack", label = "Un XRay", desc = "Alias of unxray", needsArg = false },
        { cmd = "perf", label = "Low GFX", desc = "Alias of lowgfx", needsArg = false },
        { cmd = "performance", label = "Low GFX", desc = "Alias of lowgfx", needsArg = false },
        { cmd = "quality", label = "High GFX", desc = "Alias of highgfx", needsArg = false },
        { cmd = "boxes", label = "ESP alias", desc = "Alias of esp", needsArg = false },
        { cmd = "noesp", label = "No ESP", desc = "Alias of unesp", needsArg = false },
        { cmd = "godmode", label = "God mode alias", desc = "Alias of god", needsArg = false },
        { cmd = "ungodmode", label = "Ungod alias", desc = "Alias of ungod", needsArg = false },
        { cmd = "invisible", label = "Invisible alias", desc = "Alias of invis", needsArg = false },
        { cmd = "visible", label = "Visible alias", desc = "Alias of vis", needsArg = false },
        { cmd = "showself", label = "Visible", desc = "Alias of vis", needsArg = false },
        { cmd = "anchor", label = "Freeze alias", desc = "Alias of freeze", needsArg = true, example = "name" },
        { cmd = "unanchor", label = "Thaw alias", desc = "Alias of thaw", needsArg = true, example = "name" },
        { cmd = "unfreeze", label = "Unfreeze", desc = "Alias of thaw", needsArg = true, example = "name" },
        { cmd = "spinme", label = "Spin self", desc = "Alias of spin", needsArg = true, example = "10" },
        { cmd = "stopspin", label = "Stop spin", desc = "Alias of unspin", needsArg = false },
        { cmd = "stoporbit", label = "Stop orbit", desc = "Alias of unorbit", needsArg = false },
        { cmd = "copychar", label = "Copy character", desc = "Alias of copy", needsArg = true, example = "name" },
        { cmd = "copyavatar", label = "Copy avatar", desc = "Alias of copy", needsArg = true, example = "name" },
        { cmd = "btools", label = "BTools alias", desc = "Alias of tools", needsArg = false },
        { cmd = "buildingtools", label = "Building tools", desc = "Alias of tools", needsArg = false },
        { cmd = "clr", label = "Clear alias", desc = "Alias of clear", needsArg = false },
        { cmd = "cleanup", label = "Clear extras", desc = "Alias of clear", needsArg = false },
        { cmd = "noragdoll", label = "Anti ragdoll", desc = "Alias of antiragdoll", needsArg = false },
        { cmd = "allowragdoll", label = "Allow ragdoll", desc = "Alias of unantiragdoll", needsArg = false },
        { cmd = "anti-afk", label = "Anti AFK alias", desc = "Alias of antiafk", needsArg = false },
        { cmd = "noafk", label = "Anti AFK", desc = "Alias of antiafk", needsArg = false },
        { cmd = "firstperson", label = "First person", desc = "Alias of fp", needsArg = false },
        { cmd = "thirdperson", label = "Third person", desc = "Alias of tp3", needsArg = false },
        { cmd = "setmaxzoom", label = "Max zoom", desc = "Alias of maxzoom", needsArg = true, example = "128" },
        { cmd = "setminzoom", label = "Min zoom", desc = "Alias of minzoom", needsArg = true, example = "0.5" },
        { cmd = "mouselock", label = "Shift lock", desc = "Alias of shiftlock", needsArg = false },
        { cmd = "setvolume", label = "Set volume", desc = "Alias of volume", needsArg = true, example = "5" },
        { cmd = "getping", label = "Get ping", desc = "Alias of ping", needsArg = false },
        { cmd = "accountage", label = "Account age", desc = "Alias of age", needsArg = true, example = "name" },
        { cmd = "userid", label = "User id", desc = "Alias of id", needsArg = true, example = "name" },
        { cmd = "getjobid", label = "Get JobId", desc = "Alias of jobid", needsArg = false },
        { cmd = "getplaceid", label = "Get PlaceId", desc = "Alias of placeid", needsArg = false },
        { cmd = "setprefix", label = "Set prefix", desc = "Alias of prefix", needsArg = true, example = "!" },
        { cmd = "vc", label = "VC bypass", desc = "Alias of vcbypass", needsArg = false },
        { cmd = "antivc", label = "Anti VC", desc = "Alias of vcbypass", needsArg = false },
        { cmd = "playemote", label = "Play emote", desc = "Alias of emote", needsArg = true, example = "507770239" },
        { cmd = "emotestop", label = "Stop emote", desc = "Alias of stopemote", needsArg = false },
        { cmd = "stopanim", label = "Stop anim", desc = "Alias of stopemote", needsArg = false },
        { cmd = "espeed", label = "Emote speed", desc = "Alias of emotespeed", needsArg = true, example = "1.5" },
        { cmd = "emotebrowser", label = "Emote browser", desc = "Alias of afem", needsArg = false },
        { cmd = "commands", label = "Commands", desc = "Alias of cmds", needsArg = false },
        { cmd = "help", label = "Help", desc = "Alias of cmds", needsArg = false },
        { cmd = "leave", label = "Leave game", desc = "Alias of exit", needsArg = false },
        { cmd = "unbang", label = "Stop adult", desc = "Alias of stopadult", needsArg = false },
        { cmd = "unfuck", label = "Stop adult", desc = "Alias of stopadult", needsArg = false },
        { cmd = "walk", label = "Walk pose", desc = "Reset to walking defaults", needsArg = false },
        { cmd = "run", label = "Run speed 24", desc = "Set WS to 24", needsArg = false },
        { cmd = "sprint", label = "Sprint 32", desc = "Set WS to 32", needsArg = false },
        { cmd = "slow", label = "Slow 8", desc = "Set WS to 8", needsArg = false },
        { cmd = "turtle", label = "Turtle 4", desc = "Set WS to 4", needsArg = false },
        { cmd = "fast", label = "Fast 50", desc = "Set WS to 50", needsArg = false },
        { cmd = "sonic", label = "Sonic 100", desc = "Set WS to 100", needsArg = false },
        { cmd = "moonwalk", label = "Low gravity", desc = "Gravity 50", needsArg = false },
        { cmd = "earth", label = "Normal gravity", desc = "Gravity 196.2", needsArg = false },
        { cmd = "space", label = "Space gravity", desc = "Gravity 20", needsArg = false },
        { cmd = "nograv", label = "No gravity", desc = "Gravity 0", needsArg = false },
        { cmd = "highjump", label = "High jump", desc = "JP 100", needsArg = false },
        { cmd = "superjump", label = "Super jump", desc = "JP 200", needsArg = false },
        { cmd = "jumpreset", label = "Jump reset", desc = "JP 50", needsArg = false },
        { cmd = "hipreset", label = "Hip reset", desc = "HH default 0", needsArg = false },
        { cmd = "tall", label = "Tall hip", desc = "HipHeight 5", needsArg = false },
        { cmd = "short", label = "Short hip", desc = "HipHeight -1", needsArg = false },
        { cmd = "float", label = "Float hip", desc = "HipHeight 10", needsArg = false },
        { cmd = "freezepos", label = "Freeze in place", desc = "Anchor self", needsArg = false },
        { cmd = "thawself", label = "Thaw self", desc = "Unanchor self", needsArg = false },
        { cmd = "spinfast", label = "Spin fast", desc = "Spin at 50", needsArg = false },
        { cmd = "spinslow", label = "Spin slow", desc = "Spin at 5", needsArg = false },
        { cmd = "flyfast", label = "Fly fast", desc = "Fly speed 100", needsArg = false },
        { cmd = "flyslow", label = "Fly slow", desc = "Fly speed 25", needsArg = false },
        { cmd = "camreset", label = "Camera reset", desc = "Unview + third person", needsArg = false },
        { cmd = "zoommax", label = "Zoom max 500", desc = "Max zoom 500", needsArg = false },
        { cmd = "zoommin", label = "Zoom min 0", desc = "Min zoom 0", needsArg = false },
        { cmd = "fovreset", label = "FOV reset", desc = "FOV 70", needsArg = false },
        { cmd = "fovwide", label = "FOV wide", desc = "FOV 100", needsArg = false },
        { cmd = "fovzoom", label = "FOV zoom", desc = "FOV 40", needsArg = false },
        { cmd = "fps30", label = "FPS 30", desc = "Cap 30", needsArg = false },
        { cmd = "fps60", label = "FPS 60", desc = "Cap 60", needsArg = false },
        { cmd = "fps120", label = "FPS 120", desc = "Cap 120", needsArg = false },
        { cmd = "fpsunlock", label = "FPS unlock", desc = "Cap 999", needsArg = false },
        { cmd = "noon", label = "Noon", desc = "Time 12", needsArg = false },
        { cmd = "midnight", label = "Midnight", desc = "Time 0", needsArg = false },
        { cmd = "sunrise", label = "Sunrise", desc = "Time 6", needsArg = false },
        { cmd = "sunset", label = "Sunset", desc = "Time 18", needsArg = false },
        { cmd = "pitchblack", label = "Pitch black", desc = "Brightness 0", needsArg = false },
        { cmd = "overbright", label = "Overbright", desc = "Brightness 10", needsArg = false },
        { cmd = "foggy", label = "Foggy", desc = "Add mild fog via lighting", needsArg = false },
        { cmd = "clearfog", label = "Clear fog", desc = "Alias nofog", needsArg = false },
        { cmd = "espall", label = "ESP all", desc = "Enable ESP", needsArg = false },
        { cmd = "hideesp", label = "Hide ESP", desc = "Disable ESP", needsArg = false },
        { cmd = "godon", label = "God on", desc = "Enable god", needsArg = false },
        { cmd = "godoff", label = "God off", desc = "Disable god", needsArg = false },
        { cmd = "hide", label = "Hide self", desc = "Invisible", needsArg = false },
        { cmd = "show", label = "Show self", desc = "Visible", needsArg = false },
        { cmd = "bringme", label = "Info bring", desc = "Owner bring only — use bring name", needsArg = false },
        { cmd = "tpzero", label = "TP origin", desc = "Teleport to 0,10,0", needsArg = false },
        { cmd = "tpup", label = "TP up", desc = "Teleport +50 studs Y", needsArg = false },
        { cmd = "tpdown", label = "TP down", desc = "Teleport -20 studs Y", needsArg = false },
        { cmd = "tpfwd", label = "TP forward", desc = "Teleport forward 20", needsArg = false },
        { cmd = "tpback", label = "TP back", desc = "Teleport backward 20", needsArg = false },
        { cmd = "rejoinplace", label = "Rejoin place", desc = "Rejoin", needsArg = false },
        { cmd = "hopserver", label = "Hop server", desc = "Server hop", needsArg = false },
        { cmd = "pingms", label = "Ping ms", desc = "Show ping", needsArg = false },
        { cmd = "myid", label = "My user id", desc = "Show your UserId", needsArg = false },
        { cmd = "myage", label = "My age", desc = "Show your account age", needsArg = false },
        { cmd = "serverinfo", label = "Server info", desc = "JobId + PlaceId + players", needsArg = false },
        { cmd = "playercount", label = "Player count", desc = "Players in server", needsArg = false },
        { cmd = "notifytest", label = "Notify test", desc = "Test notification", needsArg = false },
        { cmd = "sayhi", label = "Say hi", desc = "Chat hello", needsArg = false },
        { cmd = "vol0", label = "Mute", desc = "Volume 0", needsArg = false },
        { cmd = "vol5", label = "Volume mid", desc = "Volume 5", needsArg = false },
        { cmd = "vol10", label = "Volume max", desc = "Volume 10", needsArg = false },
        { cmd = "prefixsemi", label = "Prefix ;", desc = "Set prefix to ;", needsArg = false },
        { cmd = "prefixdot", label = "Prefix .", desc = "Set prefix to .", needsArg = false },
        { cmd = "prefixbang", label = "Prefix !", desc = "Set prefix to !", needsArg = false },
        { cmd = "emotewave", label = "Emote wave", desc = "Play wave", needsArg = false },
        { cmd = "emotedance", label = "Emote dance", desc = "Play dance", needsArg = false },
        { cmd = "emotelaugh", label = "Emote laugh", desc = "Play laugh", needsArg = false },
        { cmd = "emotepoint", label = "Emote point", desc = "Play point", needsArg = false },
        { cmd = "emotecheer", label = "Emote cheer", desc = "Play cheer", needsArg = false },
        { cmd = "emotesit", label = "Emote sit", desc = "Play sit", needsArg = false },
        { cmd = "emotestopall", label = "Stop emotes", desc = "Stop emote", needsArg = false },
        { cmd = "speed1", label = "Emote speed 1x", desc = "Emote speed 1", needsArg = false },
        { cmd = "speed2", label = "Emote speed 2x", desc = "Emote speed 2", needsArg = false },
        { cmd = "speed05", label = "Emote speed 0.5x", desc = "Emote speed 0.5", needsArg = false },
        { cmd = "openemotes", label = "Open emotes", desc = "Open emote browser", needsArg = false },
        { cmd = "browseemotes", label = "Browse emotes", desc = "Open emote browser", needsArg = false },
        { cmd = "shiftlockon", label = "Shift lock on", desc = "Enable shift lock", needsArg = false },
        { cmd = "toolsget", label = "Get tools", desc = "Give btools", needsArg = false },
        { cmd = "ragdolloff", label = "Ragdoll off", desc = "Anti ragdoll", needsArg = false },
        { cmd = "ragdollon", label = "Ragdoll on", desc = "Allow ragdoll", needsArg = false },
        { cmd = "afkoff", label = "AFK off", desc = "Anti AFK", needsArg = false },
        { cmd = "vcon", label = "VC on", desc = "VC bypass", needsArg = false },
        { cmd = "xrayon", label = "XRay on", desc = "Enable xray", needsArg = false },
        { cmd = "xrayoff", label = "XRay off", desc = "Disable xray", needsArg = false },
        { cmd = "fullbrighton", label = "Fullbright on", desc = "Fullbright", needsArg = false },
        { cmd = "nclip", label = "Noclip short", desc = "Noclip", needsArg = false },
        { cmd = "unflyme", label = "Unfly me", desc = "Unfly", needsArg = false },
        { cmd = "loopwalk", label = "Loop walk", desc = "Loop WS 16", needsArg = false },
        { cmd = "unloopwalk", label = "Unloop walk", desc = "Unloop WS", needsArg = false },
        { cmd = "loopj", label = "Loop jump short", desc = "Loop JP 50", needsArg = false },
        { cmd = "unloopj", label = "Unloop jump", desc = "Unloop JP", needsArg = false },
        { cmd = "coords", label = "Print coords", desc = "Notify your position", needsArg = false },
        { cmd = "pos", label = "Position", desc = "Notify your position", needsArg = false },
        { cmd = "where", label = "Where am I", desc = "Notify your position", needsArg = false },
        { cmd = "health", label = "Health", desc = "Show your health", needsArg = false },
        { cmd = "hp", label = "HP", desc = "Show your health", needsArg = false },
        { cmd = "maxhp", label = "Max HP", desc = "Show max health", needsArg = false },
        { cmd = "team", label = "Team name", desc = "Show your team", needsArg = false },
        { cmd = "displayname", label = "Display name", desc = "Show display name", needsArg = false },
        { cmd = "username", label = "Username", desc = "Show username", needsArg = false },
        { cmd = "players", label = "List players", desc = "Notify player list", needsArg = false },
        { cmd = "plrs", label = "List players", desc = "Notify player list", needsArg = false },
        { cmd = "nearest", label = "Nearest player", desc = "Notify nearest player", needsArg = false },
        { cmd = "farthest", label = "Farthest player", desc = "Notify farthest player", needsArg = false },
        { cmd = "rejoinhop", label = "Rejoin or hop", desc = "Rejoin current", needsArg = false },
        { cmd = "quit", label = "Quit", desc = "Leave game", needsArg = false },
        { cmd = "cmdlist", label = "Cmd list", desc = "Open commands", needsArg = false },
        { cmd = "menu", label = "Menu hint", desc = "Toggle menu with keybind", needsArg = false },
        { cmd = "uishow", label = "UI show", desc = "Menu keybind reminder", needsArg = false },
        { cmd = "nametag", label = "Nametag info", desc = "Show your nametag data", needsArg = false },
        { cmd = "rank", label = "Key rank", desc = "Show key rank", needsArg = false },
        { cmd = "keyinfo", label = "Key info", desc = "Show key rank/tag", needsArg = false },
        { cmd = "version", label = "Version", desc = "Show NØIR version", needsArg = false },
        { cmd = "ver", label = "Version short", desc = "Show NØIR version", needsArg = false },
        { cmd = "credits", label = "Credits", desc = "NØIR credits", needsArg = false },
        { cmd = "discord", label = "Discord", desc = "Discord invite hint", needsArg = false },
        { cmd = "site", label = "Website", desc = "n0ir.pages.dev", needsArg = false },
        { cmd = "website", label = "Website", desc = "n0ir.pages.dev", needsArg = false },
        { cmd = "support", label = "Support", desc = "Discord support", needsArg = false },
        { cmd = "freezeesp", label = "Freeze + ESP", desc = "ESP then note freeze", needsArg = false },
        { cmd = "safe", label = "Safe defaults", desc = "Normal + clip + unfly", needsArg = false },
        { cmd = "pvp", label = "PVP prep", desc = "WS 20 JP 50 god off", needsArg = false },
        { cmd = "explore", label = "Explore", desc = "WS 30 fly ready", needsArg = false },
        { cmd = "admin", label = "Admin note", desc = "Owner tools need rank", needsArg = false },
        { cmd = "owner", label = "Owner note", desc = "Owner-only cmds", needsArg = false },
        { cmd = "heal", label = "Heal note", desc = "God for infinite HP", needsArg = false },
        { cmd = "immortal", label = "Immortal", desc = "Alias god", needsArg = false },
        { cmd = "mortal", label = "Mortal", desc = "Alias ungod", needsArg = false },
        { cmd = "ghost", label = "Ghost", desc = "Alias invis", needsArg = false },
        { cmd = "unghost", label = "Unghost", desc = "Alias vis", needsArg = false },
        { cmd = "phaser", label = "Phaser", desc = "Alias noclip", needsArg = false },
        { cmd = "solid", label = "Solid", desc = "Alias clip", needsArg = false },
        { cmd = "jetpack", label = "Jetpack", desc = "Alias fly", needsArg = true, example = "60" },
        { cmd = "land", label = "Land", desc = "Alias unfly", needsArg = false },
        { cmd = "blink", label = "Blink TP", desc = "Alias clicktp", needsArg = false },
        { cmd = "unblink", label = "Unblink", desc = "Alias unclicktp", needsArg = false },
        { cmd = "spectateoff", label = "Spectate off", desc = "Alias unview", needsArg = false },
        { cmd = "cam", label = "Camera view", desc = "Alias view", needsArg = true, example = "name" },
        { cmd = "uncam", label = "Uncamera", desc = "Alias unview", needsArg = false },
        { cmd = "pull", label = "Bring alias", desc = "Alias bring (owner)", needsArg = true, example = "name" },
        { cmd = "summon", label = "Summon", desc = "Alias bring (owner)", needsArg = true, example = "name" },
        { cmd = "gotoplayer", label = "Goto player", desc = "Alias goto", needsArg = true, example = "name" },
        { cmd = "tpto", label = "TP to", desc = "Alias goto", needsArg = true, example = "name" },
        { cmd = "setpos", label = "Set pos", desc = "Alias tppos", needsArg = true, example = "0 10 0" },
        { cmd = "move", label = "Move pos", desc = "Alias tppos", needsArg = true, example = "0 10 0" },
        { cmd = "anchorall", label = "Anchor all", desc = "Alias freezeall", needsArg = false },
        { cmd = "unanchorall", label = "Unanchor all", desc = "Alias thawall", needsArg = false },
        { cmd = "yeet", label = "Yeet", desc = "Alias fling", needsArg = true, example = "name" },
        { cmd = "launch", label = "Launch", desc = "Alias fling", needsArg = true, example = "name" },
        { cmd = "circle", label = "Orbit circle", desc = "Alias orbit", needsArg = true, example = "name" },
        { cmd = "uncircle", label = "Uncircle", desc = "Alias unorbit", needsArg = false },
        { cmd = "clone", label = "Copy look", desc = "Alias copy", needsArg = true, example = "name" },
        { cmd = "stealavatar", label = "Steal avatar", desc = "Alias copy", needsArg = true, example = "name" },
        { cmd = "hammer", label = "BTools", desc = "Alias tools", needsArg = false },
        { cmd = "f3x", label = "BTools", desc = "Alias tools", needsArg = false },
        { cmd = "norag", label = "No ragdoll", desc = "Alias antiragdoll", needsArg = false },
        { cmd = "yesrag", label = "Yes ragdoll", desc = "Alias unantiragdoll", needsArg = false },
        { cmd = "idlekick", label = "Anti idle kick", desc = "Alias antiafk", needsArg = false },
        { cmd = "fpk", label = "First person lock", desc = "Alias fp", needsArg = false },
        { cmd = "tpk", label = "Third person", desc = "Alias tp3", needsArg = false },
        { cmd = "lockmouse", label = "Lock mouse", desc = "Alias shiftlock", needsArg = false },
        { cmd = "vol", label = "Volume short", desc = "Alias volume", needsArg = true, example = "5" },
        { cmd = "ms", label = "Ping ms", desc = "Alias ping", needsArg = false },
        { cmd = "uid", label = "UID", desc = "Alias id", needsArg = true, example = "name" },
        { cmd = "jid", label = "Job id", desc = "Alias jobid", needsArg = false },
        { cmd = "pid", label = "Place id", desc = "Alias placeid", needsArg = false },
        { cmd = "pre", label = "Prefix short", desc = "Alias prefix", needsArg = true, example = ";" },
        { cmd = "bypassvc", label = "Bypass VC", desc = "Alias vcbypass", needsArg = false },
        { cmd = "dance", label = "Dance emote", desc = "Play dance emote", needsArg = false },
        { cmd = "wave", label = "Wave emote", desc = "Play wave emote", needsArg = false },
        { cmd = "laugh", label = "Laugh emote", desc = "Play laugh emote", needsArg = false },
        { cmd = "cheer", label = "Cheer emote", desc = "Play cheer emote", needsArg = false },
        { cmd = "point", label = "Point emote", desc = "Play point emote", needsArg = false },
        { cmd = "sitanim", label = "Sit emote", desc = "Play sit emote", needsArg = false },
        { cmd = "stopdance", label = "Stop dance", desc = "Stop emote", needsArg = false },
        { cmd = "emotelib", label = "Emote library", desc = "Open browser", needsArg = false },
        { cmd = "elist", label = "Emote list", desc = "Open browser", needsArg = false },
        { cmd = "cmd", label = "Commands", desc = "Alias cmds", needsArg = false },
        { cmd = "?", label = "Help", desc = "Alias cmds", needsArg = false },
        { cmd = "leavegame", label = "Leave game", desc = "Alias exit", needsArg = false },
        { cmd = "ragequit", label = "Rage quit", desc = "Alias exit", needsArg = false },
        { cmd = "rpstop", label = "RP stop", desc = "Alias stopadult", needsArg = false },
        { cmd = "stoprp", label = "Stop RP", desc = "Alias stopadult", needsArg = false },
        { cmd = "adultstop", label = "Adult stop", desc = "Alias stopadult", needsArg = false },
        { cmd = "ws16", label = "WS 16", desc = "Default walkspeed", needsArg = false },
        { cmd = "ws20", label = "WS 20", desc = "Walkspeed 20", needsArg = false },
        { cmd = "ws50", label = "WS 50", desc = "Walkspeed 50", needsArg = false },
        { cmd = "ws100", label = "WS 100", desc = "Walkspeed 100", needsArg = false },
        { cmd = "jp50", label = "JP 50", desc = "Jump 50", needsArg = false },
        { cmd = "jp100", label = "JP 100", desc = "Jump 100", needsArg = false },
        { cmd = "g196", label = "Gravity normal", desc = "Gravity 196", needsArg = false },
        { cmd = "g50", label = "Gravity 50", desc = "Gravity 50", needsArg = false },
        { cmd = "g0", label = "Gravity 0", desc = "Gravity 0", needsArg = false },
        { cmd = "annoy", label = "Annoy note", desc = "Use fling / spin creatively", needsArg = true, example = "name" },
        { cmd = "spamchat", label = "Spam chat note", desc = "Use carefully", needsArg = true, example = "text" },
        { cmd = "say", label = "Say chat", desc = "Send chat message", needsArg = true, example = "hello" },
        { cmd = "notify", label = "Notify", desc = "Show notification", needsArg = true, example = "text" },
        { cmd = "stopadult2", label = "Stop adult 2", desc = "Alias stopadult", needsArg = false },
        { cmd = "headbangstop", label = "Stop headbang", desc = "Alias stopadult", needsArg = false },
        { cmd = "clearall", label = "Clear all", desc = "Alias clear", needsArg = false },
        { cmd = "fix", label = "Reset form", desc = "Alias normal", needsArg = false },
        { cmd = "stats", label = "Reset stats", desc = "Alias normal", needsArg = false },
        { cmd = "unpower", label = "Unpower", desc = "Alias normal", needsArg = false },
        { cmd = "ungodall", label = "Note", desc = "Use ungod on self", needsArg = false },
        { cmd = "espnames", label = "ESP names", desc = "Alias esp", needsArg = false },
        { cmd = "nameesp", label = "Name ESP", desc = "Alias esp", needsArg = false },
        { cmd = "fullbrightoff", label = "Fullbright off", desc = "Restore via highgfx", needsArg = false },
        { cmd = "gfxlow", label = "GFX low", desc = "Alias lowgfx", needsArg = false },
        { cmd = "gfxhigh", label = "GFX high", desc = "Alias highgfx", needsArg = false },
        { cmd = "fogoff", label = "Fog off", desc = "Alias nofog", needsArg = false },
        { cmd = "fogon", label = "Fog note", desc = "Rejoin to restore fog", needsArg = false },
        { cmd = "brightmax", label = "Brightness max", desc = "Brightness 5", needsArg = false },
        { cmd = "ambientwhite", label = "Ambient white", desc = "Ambient 1 1 1", needsArg = false },
        { cmd = "ambientblack", label = "Ambient black", desc = "Ambient 0 0 0", needsArg = false },
        { cmd = "exposure0", label = "Exposure 0", desc = "Exposure 0", needsArg = false },
        { cmd = "exposure2", label = "Exposure 2", desc = "Exposure 2", needsArg = false },
        { cmd = "time0", label = "Time 0", desc = "Midnight", needsArg = false },
        { cmd = "time6", label = "Time 6", desc = "Sunrise", needsArg = false },
        { cmd = "time12", label = "Time 12", desc = "Noon", needsArg = false },
        { cmd = "time18", label = "Time 18", desc = "Sunset", needsArg = false },
        { cmd = "time21", label = "Time 21", desc = "Night", needsArg = false },
        { cmd = "sitdown", label = "Sit down", desc = "Alias sit", needsArg = false },
        { cmd = "standup", label = "Stand up", desc = "Alias unsit", needsArg = false },
        { cmd = "ragdollblock", label = "Block ragdoll", desc = "Alias antiragdoll", needsArg = false },
        { cmd = "ragdollallow", label = "Allow ragdoll", desc = "Alias unantiragdoll", needsArg = false },
        { cmd = "afkprotect", label = "AFK protect", desc = "Alias antiafk", needsArg = false },
        { cmd = "zoomout", label = "Zoom out max", desc = "Max zoom 200", needsArg = false },
        { cmd = "zoomin", label = "Zoom in min", desc = "Min zoom 0.5", needsArg = false },
        { cmd = "lockcam", label = "First person", desc = "Alias fp", needsArg = false },
        { cmd = "freecam3", label = "Third person", desc = "Alias tp3", needsArg = false },
        { cmd = "shift", label = "Shift lock", desc = "Alias shiftlock", needsArg = false },
        { cmd = "mute", label = "Mute", desc = "Volume 0", needsArg = false },
        { cmd = "unmute", label = "Unmute", desc = "Volume 5", needsArg = false },
        { cmd = "loud", label = "Loud", desc = "Volume 10", needsArg = false },
        { cmd = "quiet", label = "Quiet", desc = "Volume 2", needsArg = false },
        { cmd = "latency", label = "Latency", desc = "Alias ping", needsArg = false },
        { cmd = "days", label = "Account days", desc = "Alias age", needsArg = true, example = "name" },
        { cmd = "useridof", label = "UserId of", desc = "Alias id", needsArg = true, example = "name" },
        { cmd = "serverid", label = "Server id", desc = "Alias jobid", needsArg = false },
        { cmd = "gameid", label = "Game place id", desc = "Alias placeid", needsArg = false },
        { cmd = "changeprefix", label = "Change prefix", desc = "Alias prefix", needsArg = true, example = "!" },
        { cmd = "voicebypass", label = "Voice bypass", desc = "Alias vcbypass", needsArg = false },
        { cmd = "playanim", label = "Play anim", desc = "Alias emote", needsArg = true, example = "507770239" },
        { cmd = "stopemotes", label = "Stop emotes", desc = "Alias stopemote", needsArg = false },
        { cmd = "animspeed", label = "Anim speed", desc = "Alias emotespeed", needsArg = true, example = "1.25" },
        { cmd = "emotegui", label = "Emote GUI", desc = "Open browser", needsArg = false },
        { cmd = "emotemenu", label = "Emote menu", desc = "Open browser", needsArg = false },
        { cmd = "commandlist", label = "Command list", desc = "Alias cmds", needsArg = false },
        { cmd = "helpcmds", label = "Help cmds", desc = "Alias cmds", needsArg = false },
        { cmd = "exitgame", label = "Exit game", desc = "Alias exit", needsArg = false },
        { cmd = "disconnect", label = "Disconnect", desc = "Alias exit", needsArg = false },
        { cmd = "rpend", label = "RP end", desc = "Alias stopadult", needsArg = false },
        { cmd = "stopallrp", label = "Stop all RP", desc = "Alias stopadult", needsArg = false },
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
        if entry.ownerOnly and not isOwner() then
            -- hide owner-only commands from the Commands tab
        else
            makeCmdRow(entry)
        end
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

    -- Open cmd bar on KEY RELEASE so the open-key never types into the box
    local _cmdPendingOpen = false
    local _cmdOpenKey = nil
    UserInputService.InputBegan:Connect(function(inp, gp)
        local key = _G._N0IR_CmdBarKey or cmdBarKey
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if inp.KeyCode ~= key then return end
        -- close if already focused
        if UserInputService:GetFocusedTextBox() == input then
            input:ReleaseFocus()
            _cmdPendingOpen = false
            return
        end
        if UserInputService:GetFocusedTextBox() then return end
        _cmdPendingOpen = true
        _cmdOpenKey = key
        input.Text = ""
        tween(bar, { Position = UDim2.new(0.5, 0, 1, -18) }, 0.25)
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if not _cmdPendingOpen then return end
        local key = _cmdOpenKey or _G._N0IR_CmdBarKey or cmdBarKey
        if inp.KeyCode ~= key then return end
        _cmdPendingOpen = false
        input.Text = ""
        input:CaptureFocus()
        -- hard clear once more after focus (safety)
        task.defer(function()
            input.Text = ""
        end)
    end)

    input.FocusLost:Connect(function(enter)
        tween(bar, { Position = UDim2.new(0.5, 0, 1, 60) }, 0.3)
        _cmdPendingOpen = false
        if enter and input.Text ~= "" then
            local txt = input.Text
            -- strip accidental open-key character at start if it slipped in
            local key = _G._N0IR_CmdBarKey or cmdBarKey
            local ch = ""
            pcall(function() ch = UserInputService:GetStringForKeyCode(key) end)
            if ch ~= "" and txt:sub(1, #ch) == ch then
                txt = txt:sub(#ch + 1)
            end
            if txt ~= "" then runCmd(txt) end
        end
        input.Text = ""
    end)

    Cmds:CreateLabel("Tip  ·  open cmd bar with your keybind (Settings) · type cmds to focus this list")

    -- ---------- VC Bypass (NØIR) ----------
    local VC = Window:CreateTab({ Name = "VC Bypass" })
    VC:CreateSection("NØIR Voice Chat Bypass")
    VC:CreateParagraph({
        Content = "Native NØIR anti-VC protection. Unmute your mic when prompted, then the bypass hooks the topbar mute button. Muted uses the stock MicLight icon (darkened); unmuted is captured live from the real button and faded for a cleaner look.",
    })

    local VCState = {
        enabled = false,
        statusLbl = nil,
    }

    local function vcStatus(msg)
        if VCState.statusLbl and VCState.statusLbl.Set then
            VCState.statusLbl:Set("Status  ·  " .. msg)
        end
        N0IR:Notify({ Title = "NØIR VC", Content = msg, Duration = 2.5 })
    end

    local function enableN0IRVCBypass()
        if VCState.enabled then
            vcStatus("already active")
            return
        end
        VCState.enabled = true
        vcStatus("starting — unmute your mic when ready")

        task.spawn(function()
            local ok, err = pcall(function()
                local clonereference = cloneref or function(...) return ... end
                local clonefunction = clonefunction or function(...) return ... end

                local voicechatservice = clonereference(game:GetService("VoiceChatService"))
                local voicechatinternal = clonereference(game:GetService("VoiceChatInternal"))
                local coregui = game:GetService("CoreGui")
                local getconnectionsfunc = clonefunction(getconnections)

                local mutedimage = "rbxasset://textures/ui/VoiceChat/MicLight/Muted.png"
                local hiddenfolder = Instance.new("Folder")
                hiddenfolder.Name = "N0IR_VCHidden"
                hiddenfolder.Parent = game:GetService("RobloxReplicatedStorage")

                local topbarapp = coregui:WaitForChild("TopBarApp", 15):WaitForChild("TopBarApp", 15)
                local unibarleft = topbarapp:WaitForChild("UnibarLeftFrame", 15)
                local unibarmenu = unibarleft:WaitForChild("UnibarMenu", 15) or unibarleft:WaitForChild("ChromeMenu", 15)
                local unibarcontainer

                pcall(function()
                    unibarcontainer = unibarmenu:WaitForChild("2", 15):WaitForChild("3", 15)
                end)

                local micmutebutton = unibarcontainer and unibarcontainer:FindFirstChild("toggle_mic_mute", true)

                local function geticonlabel(button)
                    button = button or micmutebutton
                    return button:WaitForChild("IntegrationIconFrame", 15):WaitForChild("IntegrationIcon", 15)["1"]
                end

                local function getcurrentmutestate()
                    return voicechatinternal:IsPublishPaused()
                end

                local function setmutestate(state)
                    voicechatinternal:PublishPause(state)
                end

                if not micmutebutton then
                    pcall(function() voicechatservice:joinVoice() end)
                    pcall(function()
                        unibarcontainer = unibarmenu:WaitForChild("2", 15):WaitForChild("3", 15)
                        micmutebutton = unibarcontainer:WaitForChild("toggle_mic_mute", 15)
                    end)
                end

                if not micmutebutton then
                    error("Mic button not found — open voice settings / unmute once")
                end

                -- Wait until user unmutes (icon changes). No Roblox SetCore notification.
                vcStatus("unmute your mic to continue")
                local waited = 0
                while waited < 60 do
                    local iconOk, icon = pcall(geticonlabel)
                    if iconOk and icon and icon.Image ~= mutedimage then
                        break
                    end
                    task.wait(1)
                    waited = waited + 1
                end
                if waited >= 60 then
                    error("Timed out waiting for unmute")
                end

                voicechatservice:leaveVoice()
                task.wait(2)

                local connections = getconnectionsfunc(voicechatinternal.StateChanged)
                for i = 7, #connections do
                    if connections[i] then
                        pcall(function() connections[i]:Disable() end)
                    end
                end

                task.wait(2)
                voicechatservice:joinVoice()

                pcall(function()
                    unibarcontainer = unibarmenu:WaitForChild("2", 15):WaitForChild("3", 15)
                    micmutebutton = unibarcontainer:WaitForChild("toggle_mic_mute", 15)
                end)

                if not (micmutebutton and unibarcontainer) then
                    error("Mic button lost after rejoin")
                end

                local clonedmutebutton = micmutebutton:Clone()
                micmutebutton.Parent = hiddenfolder
                clonedmutebutton.Name = "toggle_mic_mute_new"
                clonedmutebutton.Parent = unibarcontainer

                local clonedicon = geticonlabel(clonedmutebutton)
                local originalicon = geticonlabel(micmutebutton)

                -- Diagonal fade on cloned icon
                local gradient = Instance.new("UIGradient")
                gradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 100)),
                })
                gradient.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 0.5),
                })
                gradient.Rotation = 45
                gradient.Parent = clonedicon

                -- Soft fade on original icon reference
                local originalGradient = Instance.new("UIGradient")
                originalGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 100)),
                })
                originalGradient.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 0.3),
                })
                originalGradient.Rotation = 45
                originalGradient.Parent = originalicon

                setmutestate(true)
                clonedicon.Image = mutedimage

                local hit = clonedmutebutton:WaitForChild("IconHitArea_toggle_mic_mute", 15)
                hit.Activated:Connect(function()
                    local newstate = not getcurrentmutestate()
                    setmutestate(newstate)
                    if newstate then
                        clonedicon.Image = mutedimage
                    else
                        clonedicon.Image = originalicon.Image
                    end
                end)

                vcStatus("active")
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

    VC:CreateButton({
        Name = "N0IR Bypass (speaking fill — coming soon)",
        Callback = function()
            N0IR:Notify({
                Title = "NØIR VC",
                Content = "Buggy speaking-fill variant — not ready yet. Coming soon.",
                Duration = 2.5,
            })
            if VCState.statusLbl and VCState.statusLbl.Set then
                VCState.statusLbl:Set("Status  ·  speaking fill — coming soon")
            end
        end,
    })

    VC:CreateParagraph({
        Content = "Muted / unmuted icons use a diagonal gradient overlay: darker bottom-left → brighter top-right (UIGradient).\nUnmuted art is captured live after you unmute. No custom asset ids required.",
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

    -- ---------- AutoExec ----------
    local AutoExec = Window:CreateTab({ Name = "AutoExec" })
    AutoExec:CreateSection("Auto-execute on load / respawn")
    AutoExec:CreateParagraph({
        Content = "Toggle commands to run automatically when the suite loads and after you respawn. Values save to N0IR/settings.json.",
    })

    _G._N0IR_AutoExec = type(_G._N0IR_AutoExec) == "table" and _G._N0IR_AutoExec or {}

    local autoExecDefs = {
        { cmd = "ws",        label = "WalkSpeed",      needsArg = true,  example = "50" },
        { cmd = "jp",        label = "JumpPower",      needsArg = true,  example = "75" },
        { cmd = "hh",        label = "HipHeight",      needsArg = true,  example = "2" },
        { cmd = "loopws",    label = "Loop WalkSpeed", needsArg = true,  example = "50" },
        { cmd = "loopjp",    label = "Loop JumpPower", needsArg = true,  example = "75" },
        { cmd = "power",     label = "Power boost",    needsArg = false },
        { cmd = "noclip",    label = "Noclip",         needsArg = false },
        { cmd = "fly",       label = "Fly",            needsArg = true,  example = "50" },
        { cmd = "infjump",   label = "Infinite jump",  needsArg = false },
        { cmd = "god",       label = "God mode",       needsArg = false },
        { cmd = "antiafk",   label = "Anti AFK",       needsArg = false },
        { cmd = "antiragdoll", label = "Anti ragdoll", needsArg = false },
        { cmd = "esp",       label = "ESP",            needsArg = false },
        { cmd = "fullbright",label = "Fullbright",     needsArg = false },
        { cmd = "nofog",     label = "No fog",         needsArg = false },
        { cmd = "fps",       label = "FPS cap",        needsArg = true,  example = "60" },
        { cmd = "fov",       label = "FOV",            needsArg = true,  example = "90" },
        { cmd = "gravity",   label = "Gravity",        needsArg = true,  example = "196.2" },
        { cmd = "shiftlock", label = "Shift lock",     needsArg = false },
        { cmd = "vcbypass",  label = "VC Bypass",      needsArg = false },
    }

    local function autoExecSave()
        if _G._N0IR_SaveSettings then task.defer(_G._N0IR_SaveSettings) end
    end

    local function autoExecGet(cmd)
        local e = _G._N0IR_AutoExec[cmd]
        if type(e) ~= "table" then
            e = { enabled = false, value = "" }
            _G._N0IR_AutoExec[cmd] = e
        end
        if e.enabled == nil then e.enabled = false end
        if e.value == nil then e.value = "" end
        return e
    end

    local function autoExecRunOne(def, silent)
        local e = autoExecGet(def.cmd)
        if not e.enabled then return false end
        local line = def.cmd
        local val = tostring(e.value or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if def.needsArg then
            if val == "" and def.example and def.example ~= "" then
                val = def.example
            end
            if val == "" then
                return false
            end
            line = def.cmd .. " " .. val
        elseif val ~= "" then
            line = def.cmd .. " " .. val
        end
        pcall(function() runCmd(line) end)
        return true
    end

    local function autoExecApplyAll(silent)
        local n = 0
        for _, def in ipairs(autoExecDefs) do
            if autoExecRunOne(def, true) then
                n = n + 1
            end
        end
        return n
    end
    _G._N0IR_AutoExecApply = autoExecApplyAll

    local autoRowUpdaters = {}

    local function makeAutoRow(def)
        AutoExec._order = (AutoExec._order or 0) + 1
        local page = AutoExec.Page
        local rowH = def.needsArg and 72 or 44
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, rowH)
        row.BackgroundColor3 = T.bg1
        row.BackgroundTransparency = 0.25
        row.BorderSizePixel = 0
        row.LayoutOrder = AutoExec._order
        row.Parent = page
        corner(row, 8)
        stroke(row, T.border, 1, 0.65)

        local entry = autoExecGet(def.cmd)
        if entry.value == "" and def.example then
            entry.value = def.example
        end

        local name = Instance.new("TextLabel")
        name.BackgroundTransparency = 1
        name.Position = UDim2.fromOffset(12, 6)
        name.Size = UDim2.new(1, -70, 0, 16)
        name.Font = Enum.Font.GothamMedium
        name.Text = def.label .. "  ·  " .. def.cmd
        name.TextSize = 12
        name.TextColor3 = T.text
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = row

        local hint = Instance.new("TextLabel")
        hint.BackgroundTransparency = 1
        hint.Position = UDim2.fromOffset(12, 24)
        hint.Size = UDim2.new(1, -70, 0, 12)
        hint.Font = Enum.Font.Gotham
        hint.Text = def.needsArg and ("value e.g. " .. (def.example or "")) or "no argument"
        hint.TextSize = 10
        hint.TextColor3 = T.text3
        hint.TextXAlignment = Enum.TextXAlignment.Left
        hint.Parent = row

        -- toggle track (right)
        local state = entry.enabled == true
        local track = Instance.new("Frame")
        track.AnchorPoint = Vector2.new(1, 0)
        track.Position = UDim2.new(1, -12, 0, 10)
        track.Size = UDim2.fromOffset(42, 24)
        track.BackgroundColor3 = state and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(18, 18, 18)
        track.BorderSizePixel = 0
        track.Parent = row
        corner(track, 12)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(18, 18)
        knob.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        knob.BackgroundColor3 = state and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(140, 140, 140)
        knob.BorderSizePixel = 0
        knob.Parent = track
        corner(knob, 9)

        local hit = Instance.new("TextButton")
        hit.Size = UDim2.new(1, 0, 0, 40)
        hit.BackgroundTransparency = 1
        hit.Text = ""
        hit.ZIndex = 2
        hit.Parent = row

        local argBox
        if def.needsArg then
            argBox = Instance.new("TextBox")
            argBox.Position = UDim2.fromOffset(12, 42)
            argBox.Size = UDim2.new(1, -24, 0, 24)
            argBox.BackgroundColor3 = T.bg2
            argBox.BorderSizePixel = 0
            argBox.Font = Enum.Font.Gotham
            argBox.PlaceholderText = def.example ~= "" and ("value  e.g. " .. def.example) or "value"
            argBox.PlaceholderColor3 = T.text3
            argBox.Text = tostring(entry.value or "")
            argBox.TextSize = 11
            argBox.TextColor3 = T.text
            argBox.ClearTextOnFocus = false
            argBox.ZIndex = 3
            argBox.Parent = row
            corner(argBox, 6)
            argBox.FocusLost:Connect(function()
                local e = autoExecGet(def.cmd)
                e.value = tostring(argBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
                autoExecSave()
            end)
        end

        local function setEnabled(v, fire)
            state = v and true or false
            local e = autoExecGet(def.cmd)
            e.enabled = state
            if argBox then
                e.value = tostring(argBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
            end
            tween(track, {
                BackgroundColor3 = state and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(18, 18, 18),
            }, 0.18)
            tween(knob, {
                Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
                BackgroundColor3 = state and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(140, 140, 140),
            }, 0.18)
            autoExecSave()
            if fire and state then
                task.defer(function() autoExecRunOne(def, false) end)
            end
        end

        hit.MouseButton1Click:Connect(function()
            setEnabled(not state, true)
        end)

        autoRowUpdaters[def.cmd] = function(en)
            setEnabled(en, false)
        end
    end

    for _, def in ipairs(autoExecDefs) do
        makeAutoRow(def)
    end

    AutoExec:CreateSection("Actions")
    AutoExec:CreateButton({
        Name = "Run all enabled now",
        Callback = function()
            autoExecApplyAll(false)
        end,
    })
    AutoExec:CreateButton({
        Name = "Disable all",
        Callback = function()
            for _, def in ipairs(autoExecDefs) do
                local upd = autoRowUpdaters[def.cmd]
                if upd then
                    upd(false)
                else
                    local e = autoExecGet(def.cmd)
                    e.enabled = false
                end
            end
            autoExecSave()
        end,
    })
    AutoExec:CreateButton({
        Name = "Save AutoExec now",
        Callback = function()
            autoExecSave()
        end,
    })

    -- apply after mount + on respawn
    task.defer(function()
        task.wait(0.6)
        autoExecApplyAll(true)
    end)
    if not _G._N0IR_AutoExecCharConn then
        _G._N0IR_AutoExecCharConn = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.8)
            if type(_G._N0IR_AutoExecApply) == "function" then
                pcall(_G._N0IR_AutoExecApply, true)
            end
        end)
    end

    -- ---------- Settings tab ----------
    local Settings = Window:CreateTab({ Name = "Settings" })
    Settings:CreateSection("About")
    Settings:CreateParagraph({
        Content = "NØIR UI Library v" .. N0IR.Version .. "\nMinimal black & white suite. Mount reanim or other modules via loadstring onto this window.",
    })
    Settings:CreateSection("Background")
    local bgNames = { "None" }
    do
        local list = (_G._N0IR_Brand and _G._N0IR_Brand.Backgrounds) or {}
        for i, e in ipairs(list) do
            table.insert(bgNames, (e.Name or ("BG " .. i)))
        end
    end
    local curBg = tonumber(_G._N0IR_Brand and _G._N0IR_Brand.BgIndex) or 1
    local curBgName = (curBg <= 0) and "None" or (bgNames[curBg + 1] or "None")
    local bgLbl = Settings:CreateLabel("Active  ·  " .. curBgName)
    Settings:CreateDropdown({
        Name = "Wallpaper",
        Options = bgNames,
        Default = curBgName,
        Callback = function(name)
            local idx = 0
            for i, n in ipairs(bgNames) do
                if n == name then
                    idx = i - 1 -- None=0, first bg=1
                    break
                end
            end
            if _G._N0IR_SetBackground then
                _G._N0IR_SetBackground(idx)
            end
            bgLbl:Set("Active  ·  " .. name)
            N0IR:Notify({ Title = "Background", Content = name, Duration = 1.5 })
        end,
    })
    Settings:CreateButton({
        Name = "Next background",
        Callback = function()
            local i = _G._N0IR_NextBackground and _G._N0IR_NextBackground() or 0
            local name = (i <= 0) and "None" or (bgNames[i + 1] or ("BG " .. i))
            bgLbl:Set("Active  ·  " .. name)
            N0IR:Notify({ Title = "Background", Content = name, Duration = 1.2 })
        end,
    })
    Settings:CreateButton({
        Name = "No background",
        Callback = function()
            if _G._N0IR_SetBackground then _G._N0IR_SetBackground(0) end
            bgLbl:Set("Active  ·  None")
        end,
    })
    Settings:CreateSection("Nametags")
    Settings:CreateToggle({
        Name = "Show my tag",
        Description = "Display your own NØIR nametag above your head",
        Flag = "NametagShowSelf",
        Default = true,
        Callback = function(on)
            if Nametag and Nametag.SetShowSelf then
                Nametag:SetShowSelf(on)
            else
                Nametag.ShowSelf = on and true or false
            end
        end,
    })
    Settings:CreateToggle({
        Name = "Show other users",
        Description = "Display nametags for other players running NØIR with a valid key",
        Flag = "NametagShowOthers",
        Default = true,
        Callback = function(on)
            if Nametag and Nametag.SetShowOthers then
                Nametag:SetShowOthers(on)
            else
                Nametag.ShowOthers = on and true or false
            end
        end,
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
        -- delay so the mouse/key that clicked the button isn't captured
        task.delay(0.15, function()
            local conn
            conn = UserInputService.InputBegan:Connect(function(input, gp)
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                if not conn then return end
                conn:Disconnect()
                conn = nil
                listening = false
                if input.KeyCode == Enum.KeyCode.Escape then
                    local cur = _G[storeKey] or (storeKey == "_N0IR_ToggleKey" and Enum.KeyCode.M or Enum.KeyCode.Semicolon)
                    labelObj:Set(pretty .. "  ·  " .. (typeof(cur) == "EnumItem" and cur.Name or tostring(cur)))
                    N0IR:Notify({ Title = "Keybind", Content = "Cancelled", Duration = 1.5 })
                    return
                end
                if storeKey == "_N0IR_ToggleKey" then
                    _G._N0IR_ToggleKey = input.KeyCode
                    _G._N0IR_SavedToggleKeyName = input.KeyCode.Name
                elseif storeKey == "_N0IR_CmdBarKey" then
                    _G._N0IR_CmdBarKey = input.KeyCode
                    _G._N0IR_SavedCmdBarKeyName = input.KeyCode.Name
                else
                    _G[storeKey] = input.KeyCode
                end
                labelObj:Set(pretty .. "  ·  " .. input.KeyCode.Name)
                local saved = false
                if _G._N0IR_SaveSettings then
                    saved = _G._N0IR_SaveSettings() and true or false
                end
                N0IR:Notify({
                    Title = "Keybind",
                    Content = pretty .. " → " .. input.KeyCode.Name .. (saved and "  ·  saved" or "  ·  SAVE FAILED"),
                    Duration = 2.5,
                })
            end)
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

    Settings:CreateSection("Mouse Teleport")
    Settings:CreateToggle({
        Name = "TP Keybind",
        Description = "Enable mouse-cursor teleport on key press",
        Flag = "TPKeybindEnabled",
        Default = (_G._N0IR_TPKeybindEnabled ~= false),
        Callback = function(on)
            _G._N0IR_TPKeybindEnabled = on and true or false
            if _G._N0IR_SaveSettings then task.defer(_G._N0IR_SaveSettings) end
            if _G._UniUpdateTpBtnText then pcall(_G._UniUpdateTpBtnText) end
        end,
    })
    local tpKeyLbl = Settings:CreateLabel(
        "TP key  ·  " .. tostring((_G._N0IRTeleportKey and _G._N0IRTeleportKey.Name) or "None")
    )
    Settings:CreateButton({
        Name = "Set teleport key",
        Callback = function()
            if listening then return end
            listening = true
            tpKeyLbl:Set("Press any key...")
            N0IR:Notify({ Title = "TP Keybind", Content = "Press a key (Esc to clear)", Duration = 2 })
            task.delay(0.15, function()
                local conn
                conn = UserInputService.InputBegan:Connect(function(input, gp)
                    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if not conn then return end
                    conn:Disconnect()
                    conn = nil
                    listening = false
                    if input.KeyCode == Enum.KeyCode.Escape then
                        _G._N0IRTeleportKey = nil
                        _G._N0IR_SavedTeleportKeyName = "NONE"
                        tpKeyLbl:Set("TP key  ·  None")
                        if _G._N0IR_SaveSettings then _G._N0IR_SaveSettings() end
                        if _G._UniUpdateTpBtnText then pcall(_G._UniUpdateTpBtnText) end
                        N0IR:Notify({ Title = "TP Keybind", Content = "Cleared", Duration = 1.5 })
                        return
                    end
                    _G._N0IRTeleportKey = input.KeyCode
                    _G._N0IR_SavedTeleportKeyName = input.KeyCode.Name
                    tpKeyLbl:Set("TP key  ·  " .. input.KeyCode.Name)
                    if _G._N0IR_SaveSettings then _G._N0IR_SaveSettings() end
                    if _G._UniUpdateTpBtnText then pcall(_G._UniUpdateTpBtnText) end
                    N0IR:Notify({
                        Title = "TP Keybind",
                        Content = "Teleport → " .. input.KeyCode.Name,
                        Duration = 2,
                    })
                end)
            end)
        end,
    })
    Settings:CreateButton({
        Name = "Clear teleport key",
        Callback = function()
            _G._N0IRTeleportKey = nil
            _G._N0IR_SavedTeleportKeyName = "NONE"
            tpKeyLbl:Set("TP key  ·  None")
            if _G._N0IR_SaveSettings then _G._N0IR_SaveSettings() end
            if _G._UniUpdateTpBtnText then pcall(_G._UniUpdateTpBtnText) end
            N0IR:Notify({ Title = "TP Keybind", Content = "Cleared", Duration = 1.5 })
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
            if _G._N0IR_SaveKeybinds then _G._N0IR_SaveKeybinds() end
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
        Name = "Save settings now",
        Callback = function()
            if _G._N0IR_SaveSettings then _G._N0IR_SaveSettings() end
            N0IR:Notify({ Title = "Settings", Content = "Saved to N0IR/settings.json", Duration = 2 })
        end,
    })
    Settings:CreateButton({
        Name = "Notify Test",
        Callback = function()
            N0IR:Notify({ Title = "NØIR", Content = "Library is alive.", Duration = 2 })
        end,
    })

    -- ---------- Mouse TP keybind runtime (shared with reanim via _G) ----------
    if not _G._N0IR_UI_TPRuntimeInstalled then
        _G._N0IR_UI_TPRuntimeInstalled = true
        if _G._N0IR_TPKeybindEnabled == nil then
            _G._N0IR_TPKeybindEnabled = true
        end
        local VERTICAL_OFFSET = 3
        local function isValidTeleportPosition(targetPart, targetPosition)
            if not targetPart then return false end
            if targetPart.Transparency >= 1 and targetPart.CanCollide then return false end
            if targetPosition.Y < -100 then return false end
            return true
        end
        local function doLocalMouseTeleport()
            if type(_G._N0IRDoMouseTeleport) == "function" then
                pcall(_G._N0IRDoMouseTeleport)
                return
            end
            local character = LocalPlayer.Character
            if not character then return end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoid or humanoid.Health <= 0 or not rootPart then return end
            local mouse = LocalPlayer:GetMouse()
            if not mouse or not mouse.Hit then return end
            if not isValidTeleportPosition(mouse.Target, mouse.Hit.Position) then return end
            local teleportPosition = mouse.Hit.Position + Vector3.new(0, VERTICAL_OFFSET, 0)
            rootPart.CFrame = rootPart.CFrame + (teleportPosition - rootPart.Position)
        end
        _G._N0IR_UI_DoMouseTeleport = doLocalMouseTeleport
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if _G._N0IR_TPKeybindEnabled == false then return end
            if not _G._N0IRTeleportKey then return end
            if input.KeyCode ~= _G._N0IRTeleportKey then return end
            if UserInputService:GetFocusedTextBox() then return end
            -- Prefer reanim listener when it is installed (clone-aware)
            if _G._N0IRReanimConns and _G._N0IRReanimConns.KeybindInputBegan then
                return
            end
            pcall(doLocalMouseTeleport)
        end)
    end

    return {
        Home = Home,
        World = World,
        Player = Player,
        Anims = Anims,
        Emotes = Emotes,
        Cmds = Cmds,
        VC = VC,
        Map = Map,
        Social = Social,
        AutoExec = AutoExec,
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

    -- Key gate (https://n0ir.pages.dev)
    local ok, keyData = requireKey()
    if not ok then
        warn("[NØIR] Key validation failed")
        return nil, nil
    end

    local sub = opts.SubTitle or "Suite"
    if keyData and keyData.rank then
        sub = sub .. " · " .. keyData.rank
    end

    local win = self:CreateWindow({
        Title = opts.Title or "NØIR",
        SubTitle = sub,
        Width = opts.Width or 520,
        Height = opts.Height or 440,
        Loading = opts.Loading ~= false,
        LoadingText = opts.LoadingText or "loading modules",
        LoadingDuration = opts.LoadingDuration or 2.2,
        ToggleKey = opts.ToggleKey,
    })
    local modules = self:MountUtilities(win)

    -- Show rank on Home if available
    if modules and modules.Home and keyData then
        pcall(function()
            modules.Home:CreateLabel("Key Rank  ·  " .. (keyData.rank or "User"))
            modules.Home:CreateLabel("Nametag  ·  " .. (keyData.tag or "NØIR"))
        end)
    end

    return win, modules
end


-- NØIR Drop Kick source (NØIR UI)
_G._N0IR_DropkickSource = [====[
-- NØIR Drop Kick (based on yes.dev dropkick)
local utility = {
    dropkick = Instance.new("Animation"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    Debris = game:GetService("Debris"),
    HttpService = game:GetService("HttpService"),
    StarterGui = game:GetService("StarterGui"),
    conns = {}
}

utility.dropkick.AnimationId = "rbxassetid://133566007754001"

-- NØIR palette
local N = {
    bg = Color3.fromRGB(10, 10, 10),
    bg2 = Color3.fromRGB(16, 16, 16),
    bg3 = Color3.fromRGB(22, 22, 22),
    bg4 = Color3.fromRGB(30, 30, 30),
    stroke = Color3.fromRGB(48, 48, 48),
    text = Color3.fromRGB(245, 245, 245),
    text2 = Color3.fromRGB(160, 160, 160),
    text3 = Color3.fromRGB(110, 110, 110),
    white = Color3.fromRGB(255, 255, 255),
    active = Color3.fromRGB(255, 255, 255),
    activeText = Color3.fromRGB(10, 10, 10),
}

task.spawn(function()
    local instancesToLoad = { utility.dropkick }
    local gearPreload = Instance.new("ImageLabel")
    gearPreload.Image = "rbxthumb://type=Asset&id=7059346386&w=420&h=420"
    table.insert(instancesToLoad, gearPreload)
    pcall(function()
        game:GetService("ContentProvider"):PreloadAsync(instancesToLoad)
    end)
end)

utility.selectedMethod = "Click"
utility.selectedKey = Enum.KeyCode.F
utility.flingForce = 5000
utility.keyListening = false
utility.recordingKey = false
utility.actionRunning = false
utility.menuOpen = false
utility.uiReady = false
utility.actionId = 0
utility.currentTrack = nil
utility.AnimationCutTime = 0.3
utility.savedWalkSpeed = nil
utility.savedAutoRotate = true
utility.walkflinging = false
utility.cacheFolder = "N0IR"
utility.cacheFile = utility.cacheFolder .. "/dropkick.json"
utility.noClipConnections = {}
utility.noClipNotificationSent = false
utility.noCollisionConstraints = {}

function utility:CheckValidRigType(h)
    local s, r = pcall(function()
        return h.RigType == Enum.HumanoidRigType.R15
    end)
    return s and r
end

function utility:LoadSettings()
    local success, content = pcall(function()
        return readfile(self.cacheFile)
    end)
    if success and content then
        local ok, data = pcall(function()
            return self.HttpService:JSONDecode(content)
        end)
        if ok and data then
            if data.selectedMethod then self.selectedMethod = data.selectedMethod end
            if data.selectedKey then
                local key = Enum.KeyCode[data.selectedKey]
                if key then self.selectedKey = key end
            end
            if data.flingForce then
                self.flingForce = math.clamp(tonumber(data.flingForce) or 5000, 500, 25000)
            end
        end
    end
end

function utility:SaveSettings()
    local data = {
        selectedMethod = self.selectedMethod,
        selectedKey = self.selectedKey.Name,
        flingForce = self.flingForce
    }
    pcall(function()
        if isfolder and not isfolder(self.cacheFolder) then makefolder(self.cacheFolder) end
        writefile(self.cacheFile, self.HttpService:JSONEncode(data))
    end)
end

function utility:Notify(title, text)
    pcall(function()
        self.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 4
        })
    end)
end

function utility:CleanupPlayerNoCollision(player)
    local data = self.noCollisionConstraints[player]
    if not data then return end
    for _, connection in pairs(data.connections or {}) do
        pcall(function() connection:Disconnect() end)
    end
    for _, constraint in pairs(data.constraints or {}) do
        pcall(function() constraint:Destroy() end)
    end
    self.noCollisionConstraints[player] = nil
end

function utility:SetupPlayerNoCollision(player)
    if not player or player == self.LocalPlayer then return end
    self:CleanupPlayerNoCollision(player)
    local localCharacter = self.LocalPlayer.Character
    local targetCharacter = player.Character
    if not localCharacter or not targetCharacter then return end
    local data = { constraints = {}, connections = {} }
    self.noCollisionConstraints[player] = data
    local function createConstraint(localPart, targetPart)
        if not localPart:IsA("BasePart") or not targetPart:IsA("BasePart") then return end
        if not localPart.Parent or not targetPart.Parent then return end
        local constraint = Instance.new("NoCollisionConstraint")
        constraint.Part0 = localPart
        constraint.Part1 = targetPart
        constraint.Parent = localCharacter
        table.insert(data.constraints, constraint)
    end
    local localParts = {}
    for _, part in ipairs(localCharacter:GetDescendants()) do
        if part:IsA("BasePart") then table.insert(localParts, part) end
    end
    local function addTargetPart(targetPart)
        if not targetPart:IsA("BasePart") then return end
        for _, localPart in ipairs(localParts) do
            createConstraint(localPart, targetPart)
        end
    end
    for _, targetPart in ipairs(targetCharacter:GetDescendants()) do
        addTargetPart(targetPart)
    end
    data.connections.targetAdded = targetCharacter.DescendantAdded:Connect(function(descendant)
        addTargetPart(descendant)
    end)
    data.connections.localAdded = localCharacter.DescendantAdded:Connect(function(descendant)
        if not descendant:IsA("BasePart") then return end
        for _, targetPart in ipairs(targetCharacter:GetDescendants()) do
            createConstraint(descendant, targetPart)
        end
    end)
end

function utility:SetupGlobalNoClip()
    local function setupPlayer(player)
        if player == self.LocalPlayer then return end
        local function setupCharacter(character)
            task.defer(function()
                if player ~= self.LocalPlayer and character == player.Character then
                    self:SetupPlayerNoCollision(player)
                end
            end)
        end
        if player.Character then setupCharacter(player.Character) end
        self.noClipConnections[player] = self.noClipConnections[player] or {}
        if self.noClipConnections[player].characterAdded then
            self.noClipConnections[player].characterAdded:Disconnect()
        end
        self.noClipConnections[player].characterAdded = player.CharacterAdded:Connect(setupCharacter)
        if self.noClipConnections[player].characterRemoving then
            self.noClipConnections[player].characterRemoving:Disconnect()
        end
        self.noClipConnections[player].characterRemoving = player.CharacterRemoving:Connect(function()
            self:CleanupPlayerNoCollision(player)
        end)
    end
    for _, player in ipairs(self.Players:GetPlayers()) do setupPlayer(player) end
    if self.noClipPlayerAdded then self.noClipPlayerAdded:Disconnect() end
    self.noClipPlayerAdded = self.Players.PlayerAdded:Connect(setupPlayer)
    if self.noClipPlayerRemoving then self.noClipPlayerRemoving:Disconnect() end
    self.noClipPlayerRemoving = self.Players.PlayerRemoving:Connect(function(player)
        self:CleanupPlayerNoCollision(player)
        local connections = self.noClipConnections[player]
        if connections then
            for _, connection in pairs(connections) do
                pcall(function() connection:Disconnect() end)
            end
            self.noClipConnections[player] = nil
        end
    end)
    if self.noClipLocalCharacterAdded then self.noClipLocalCharacterAdded:Disconnect() end
    self.noClipLocalCharacterAdded = self.LocalPlayer.CharacterAdded:Connect(function()
        task.defer(function()
            for _, player in ipairs(self.Players:GetPlayers()) do
                if player ~= self.LocalPlayer and player.Character then
                    self:SetupPlayerNoCollision(player)
                end
            end
        end)
    end)
end

function utility:ShowStartup()
    local playerGui = self.LocalPlayer:WaitForChild("PlayerGui")
    local gui = Instance.new("ScreenGui")
    gui.Name = "N0IR_DropkickStartup"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999999
    gui.Parent = playerGui

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = N.bg
    overlay.BackgroundTransparency = 0.35
    overlay.BorderSizePixel = 0
    overlay.Parent = gui

    local container = Instance.new("Frame")
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.Position = UDim2.fromScale(0.5, 0.5)
    container.Size = UDim2.fromOffset(190, 88)
    container.BackgroundColor3 = N.bg
    container.BackgroundTransparency = 0.02
    container.BorderSizePixel = 0
    container.Parent = overlay
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke")
    stroke.Color = N.stroke
    stroke.Thickness = 1
    stroke.Parent = container

    local title = Instance.new("TextLabel")
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.Position = UDim2.new(0.5, 0, 0.38, 0)
    title.Size = UDim2.new(1, -16, 0, 28)
    title.BackgroundTransparency = 1
    title.Text = "NØIR  ·  Drop Kick"
    title.TextColor3 = N.text
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = container

    local credit = Instance.new("TextLabel")
    credit.AnchorPoint = Vector2.new(0.5, 0.5)
    credit.Position = UDim2.new(0.5, 0, 0.68, 0)
    credit.Size = UDim2.new(1, -16, 0, 18)
    credit.BackgroundTransparency = 1
    credit.Text = "ready"
    credit.TextColor3 = N.text3
    credit.TextSize = 12
    credit.Font = Enum.Font.GothamMedium
    credit.Parent = container

    container.BackgroundTransparency = 1
    stroke.Transparency = 1
    title.TextTransparency = 1
    credit.TextTransparency = 1
    self.TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { BackgroundTransparency = 0.02 }):Play()
    self.TweenService:Create(stroke, TweenInfo.new(0.3), { Transparency = 0 }):Play()
    self.TweenService:Create(title, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
    self.TweenService:Create(credit, TweenInfo.new(0.35), { TextTransparency = 0 }):Play()
    task.wait(2.2)
    local fadeInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    self.TweenService:Create(overlay, fadeInfo, { BackgroundTransparency = 1 }):Play()
    self.TweenService:Create(container, fadeInfo, { BackgroundTransparency = 1 }):Play()
    self.TweenService:Create(stroke, fadeInfo, { Transparency = 1 }):Play()
    self.TweenService:Create(title, fadeInfo, { TextTransparency = 1 }):Play()
    self.TweenService:Create(credit, fadeInfo, { TextTransparency = 1 }):Play()
    task.wait(0.45)
    gui:Destroy()
end

function utility:StartWalkFling(character)
    if self.walkflinging then return end
    local root = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    humanoid.BreakJointsOnDeath = false
    self.walkflinging = true
    task.spawn(function()
        while self.walkflinging and root and root.Parent do
            self.RunService.Heartbeat:Wait()
            if not self.walkflinging then break end
            local originalVel = root.Velocity
            root.Velocity = originalVel * 999999 + Vector3.new(0, 999999, 0)
            self.RunService.RenderStepped:Wait()
            if not self.walkflinging then break end
            root.Velocity = originalVel
            self.RunService.Stepped:Wait()
            if not self.walkflinging then break end
            root.Velocity = originalVel + Vector3.new(0, 0.1, 0)
        end
    end)
end

function utility:StopWalkFling()
    self.walkflinging = false
    local character = self.LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        humanoid.BreakJointsOnDeath = true
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            root.Velocity = Vector3.zero
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
        humanoid.PlatformStand = false
    end
end

function utility:FlingNearbyPlayers(userRoot, radius)
    local camera = workspace.CurrentCamera
    if not camera then return end
    local userLook = camera.CFrame.LookVector
    userLook = Vector3.new(userLook.X, 0, userLook.Z).Unit
    local flingDir = (userLook * 3 + Vector3.new(0, 0.4, 0)).Unit
    local force = self.flingForce
    local upForce = force * 0.0833
    for _, player in ipairs(self.Players:GetPlayers()) do
        if player ~= self.LocalPlayer and player.Character then
            local targetChar = player.Character
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            local targetHum = targetChar:FindFirstChild("Humanoid")
            if targetRoot and targetHum and targetHum.Health > 0 then
                local distance = (targetRoot.Position - userRoot.Position).Magnitude
                if distance <= radius then
                    pcall(function()
                        targetHum:ChangeState(Enum.HumanoidStateType.Physics)
                        targetHum.PlatformStand = true
                        for _ = 1, 5 do
                            targetRoot:RequestNetworkOwnership()
                            task.wait(0.01)
                        end
                        local finalVel = flingDir * force + Vector3.new(0, upForce, 0)
                        for _, part in ipairs(targetChar:GetDescendants()) do
                            if part:IsA("BasePart") and part.AssemblyLinearVelocity then
                                part.AssemblyLinearVelocity = finalVel
                            end
                        end
                        local bv = Instance.new("BodyVelocity")
                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bv.Velocity = finalVel
                        bv.Parent = targetRoot
                        self.Debris:AddItem(bv, 0.5)
                        targetRoot.AssemblyAngularVelocity = Vector3.new(
                            math.random(-20, 20), math.random(-20, 20), math.random(-20, 20)
                        )
                    end)
                end
            end
        end
    end
end

function utility:PerformDropkick()
    if self.keyListening or self.recordingKey then return end
    if self.selectedMethod == "None" then return end
    local character = self.LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChild("Animator")
    if not animator then return end
    local leg = character:FindFirstChild("LeftLowerLeg")
    if not leg then return end
    self.actionId += 1
    local thisActionId = self.actionId
    if self.currentTrack then
        pcall(function() self.currentTrack:Stop(0); self.currentTrack:Destroy() end)
        self.currentTrack = nil
    end
    self.actionRunning = true
    local originalWalkSpeed = humanoid.WalkSpeed
    local originalAutoRotate = humanoid.AutoRotate
    self.savedWalkSpeed = originalWalkSpeed
    self.savedAutoRotate = originalAutoRotate
    humanoid.AutoRotate = true
    humanoid.WalkSpeed = originalWalkSpeed
    local track
    local success = pcall(function() track = animator:LoadAnimation(self.dropkick) end)
    if not success or not track then
        if self.actionId == thisActionId then
            humanoid.WalkSpeed = originalWalkSpeed
            humanoid.AutoRotate = originalAutoRotate
            self.actionRunning = false
        end
        return
    end
    if self.actionId ~= thisActionId then
        pcall(function() track:Stop(0); track:Destroy() end)
        return
    end
    self.currentTrack = track
    track.Priority = Enum.AnimationPriority.Action
    track:Play(0)
    self:StartWalkFling(character)
    task.wait()
    if self.actionId ~= thisActionId then
        pcall(function() track:Stop(0); track:Destroy() end)
        self:StopWalkFling()
        return
    end
    local animationLength = track.Length
    if animationLength <= 0 then animationLength = 1 end
    local playTime = math.max(0.05, animationLength - self.AnimationCutTime)
    local startTime = os.clock()
    while track.IsPlaying and os.clock() - startTime < playTime do
        if self.actionId ~= thisActionId then
            if leg and leg.Parent then
                leg.AssemblyLinearVelocity = Vector3.zero
                leg.AssemblyAngularVelocity = Vector3.zero
            end
            pcall(function() track:Stop(0); track:Destroy() end)
            self:StopWalkFling()
            return
        end
        if not character.Parent then break end
        if humanoid and humanoid.Parent then
            humanoid.WalkSpeed = originalWalkSpeed
            humanoid.AutoRotate = true
        end
        self.RunService.Heartbeat:Wait()
        if self.actionId ~= thisActionId then
            if leg and leg.Parent then
                leg.AssemblyLinearVelocity = Vector3.zero
                leg.AssemblyAngularVelocity = Vector3.zero
            end
            self:StopWalkFling()
            return
        end
        leg = character:FindFirstChild("LeftLowerLeg")
        if not leg then break end
        local moveDirection = humanoid.MoveDirection
        local currentY = leg.AssemblyLinearVelocity.Y
        if moveDirection.Magnitude > 0.001 then
            local desiredHorizontal = moveDirection.Unit * originalWalkSpeed
            leg.AssemblyLinearVelocity = Vector3.new(desiredHorizontal.X, currentY, desiredHorizontal.Z)
        else
            leg.AssemblyLinearVelocity = Vector3.new(0, currentY, 0)
        end
        leg.AssemblyAngularVelocity = Vector3.zero
        self:FlingNearbyPlayers(character.HumanoidRootPart, 10)
        self.RunService.RenderStepped:Wait()
        if self.actionId ~= thisActionId then
            if leg and leg.Parent then
                leg.AssemblyLinearVelocity = Vector3.zero
                leg.AssemblyAngularVelocity = Vector3.zero
            end
            self:StopWalkFling()
            return
        end
        if leg and leg.Parent then
            local direction = humanoid.MoveDirection
            if direction.Magnitude > 0.001 then
                local desiredHorizontal = direction.Unit * originalWalkSpeed
                leg.AssemblyLinearVelocity = Vector3.new(desiredHorizontal.X, leg.AssemblyLinearVelocity.Y, desiredHorizontal.Z)
            else
                leg.AssemblyLinearVelocity = Vector3.new(0, leg.AssemblyLinearVelocity.Y, 0)
            end
            leg.AssemblyAngularVelocity = Vector3.zero
        end
        self.RunService.Stepped:Wait()
        if self.actionId ~= thisActionId then
            if leg and leg.Parent then
                leg.AssemblyLinearVelocity = Vector3.zero
                leg.AssemblyAngularVelocity = Vector3.zero
            end
            self:StopWalkFling()
            return
        end
        if humanoid and humanoid.Parent then
            humanoid.WalkSpeed = originalWalkSpeed
            humanoid.AutoRotate = true
        end
    end
    if self.actionId ~= thisActionId then
        pcall(function() track:Stop(0); track:Destroy() end)
        self:StopWalkFling()
        return
    end
    if track.IsPlaying then track:Stop(0) end
    if humanoid and humanoid.Parent then
        humanoid.WalkSpeed = originalWalkSpeed
        humanoid.AutoRotate = originalAutoRotate
    end
    leg = character:FindFirstChild("LeftLowerLeg")
    if leg and leg.Parent then
        leg.AssemblyLinearVelocity = Vector3.zero
        leg.AssemblyAngularVelocity = Vector3.zero
    end
    if self.currentTrack == track then self.currentTrack = nil end
    self.actionRunning = false
    self:StopWalkFling()
    pcall(function() track:Destroy() end)
end

function utility:MouseDetection()
    local mouse = self.LocalPlayer:GetMouse()
    if self.conns.mouse then self.conns.mouse:Disconnect() end
    self.conns.mouse = mouse.Button1Down:Connect(function()
        if self.selectedMethod ~= "Click" then return end
        if self.keyListening or self.recordingKey then return end
        local position = self.UserInputService:GetMouseLocation()
        local objects = self.LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(position.X, position.Y)
        for _, object in ipairs(objects) do
            if object:IsDescendantOf(self.MainUI) then return end
        end
        self:PerformDropkick()
    end)
end

function utility:StartKeyDetection()
    if self.conns.key then self.conns.key:Disconnect() end
    self.conns.key = self.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if self.keyListening or self.recordingKey then return end
        if self.selectedMethod ~= "Key" then return end
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == self.selectedKey then
            self:PerformDropkick()
        end
    end)
end

function utility:CreateButton(parent, text)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 34)
    button.BackgroundColor3 = N.bg3
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = N.text
    button.TextSize = 13
    button.Font = Enum.Font.GothamMedium
    button.AutoButtonColor = false
    button.Parent = parent
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)
    return button
end

function utility:UpdateUI()
    local idle, active = N.bg3, N.active
    local idleT, activeT = N.text, N.activeText
    self.ClickButton.BackgroundColor3 = self.selectedMethod == "Click" and active or idle
    self.ClickButton.TextColor3 = self.selectedMethod == "Click" and activeT or idleT
    self.KeyButton.BackgroundColor3 = self.selectedMethod == "Key" and active or idle
    self.KeyButton.TextColor3 = self.selectedMethod == "Key" and activeT or idleT
    self.UIButton.BackgroundColor3 = self.selectedMethod == "UI Button" and active or idle
    self.UIButton.TextColor3 = self.selectedMethod == "UI Button" and activeT or idleT
    self.KeyConfig.Visible = self.selectedMethod == "Key"
    self.ActionButton.Visible = self.uiReady and self.selectedMethod == "UI Button"
    if self.selectedMethod == "Key" and not self.keyListening then
        self.KeyBox.Text = self.selectedKey.Name
    end
    self:ResizePanel()
end

function utility:ResizePanel()
    if not self.menuOpen then return end
    local height = 158
    if self.selectedMethod == "Key" then height += 40 end
    self.Panel:TweenSize(UDim2.fromOffset(188, height), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
end

function utility:CreateUI()
    local playerGui = self.LocalPlayer:WaitForChild("PlayerGui")
    pcall(function()
        local old = playerGui:FindFirstChild("N0IR_Dropkick")
        if old then old:Destroy() end
        old = playerGui:FindFirstChild("DropkickController")
        if old then old:Destroy() end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "N0IR_Dropkick"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 50
    gui.Parent = playerGui
    self.MainUI = gui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.fromOffset(48, 48)
    main.Position = UDim2.new(0.28, 0, 0.35, 0)
    main.BackgroundTransparency = 1
    main.Parent = gui
    self.Main = main

    local gear = Instance.new("ImageButton")
    gear.Name = "Gear"
    gear.Size = UDim2.fromOffset(48, 48)
    gear.BackgroundColor3 = N.bg
    gear.BorderSizePixel = 0
    gear.Image = ""
    gear.AutoButtonColor = false
    gear.Parent = main
    Instance.new("UICorner", gear).CornerRadius = UDim.new(0, 10)
    local gearStroke = Instance.new("UIStroke")
    gearStroke.Color = N.stroke
    gearStroke.Parent = gear
    local gearImage = Instance.new("ImageLabel")
    gearImage.Size = UDim2.fromOffset(28, 28)
    gearImage.AnchorPoint = Vector2.new(0.5, 0.5)
    gearImage.Position = UDim2.fromScale(0.5, 0.5)
    gearImage.BackgroundTransparency = 1
    gearImage.Image = "rbxthumb://type=Asset&id=7059346386&w=420&h=420"
    gearImage.ImageColor3 = N.white
    gearImage.ScaleType = Enum.ScaleType.Fit
    gearImage.Parent = gear
    self.GearButton = gear

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.Size = UDim2.fromOffset(188, 0)
    panel.Position = UDim2.new(0, 0, 1, 8)
    panel.BackgroundColor3 = N.bg
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Visible = false
    panel.Parent = main
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
    local panelStroke = Instance.new("UIStroke")
    panelStroke.Color = N.stroke
    panelStroke.Parent = panel
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.Parent = panel
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = panel
    self.Panel = panel

    local hdr = Instance.new("TextLabel")
    hdr.Size = UDim2.new(1, 0, 0, 16)
    hdr.BackgroundTransparency = 1
    hdr.Text = "NØIR  ·  DROP KICK"
    hdr.TextColor3 = N.text2
    hdr.TextSize = 11
    hdr.Font = Enum.Font.GothamBold
    hdr.LayoutOrder = 0
    hdr.Parent = panel

    local click = self:CreateButton(panel, "Click")
    click.LayoutOrder = 1
    local key = self:CreateButton(panel, "Key")
    key.LayoutOrder = 2
    local uiButton = self:CreateButton(panel, "UI Button")
    uiButton.LayoutOrder = 3
    self.ClickButton = click
    self.KeyButton = key
    self.UIButton = uiButton

    local keyConfig = Instance.new("Frame")
    keyConfig.Name = "KeyConfig"
    keyConfig.Size = UDim2.new(1, 0, 0, 34)
    keyConfig.BackgroundColor3 = N.bg2
    keyConfig.BorderSizePixel = 0
    keyConfig.Visible = false
    keyConfig.LayoutOrder = 4
    keyConfig.Parent = panel
    Instance.new("UICorner", keyConfig).CornerRadius = UDim.new(0, 7)
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(0.4, 0, 1, 0)
    keyLabel.BackgroundTransparency = 1
    keyLabel.Text = "  Key"
    keyLabel.TextColor3 = N.text2
    keyLabel.TextSize = 12
    keyLabel.Font = Enum.Font.GothamMedium
    keyLabel.TextXAlignment = Enum.TextXAlignment.Left
    keyLabel.Parent = keyConfig
    local keyBox = Instance.new("TextButton")
    keyBox.Size = UDim2.new(0.52, 0, 0, 24)
    keyBox.Position = UDim2.new(0.44, 0, 0.5, -12)
    keyBox.BackgroundColor3 = N.bg4
    keyBox.BorderSizePixel = 0
    keyBox.Text = self.selectedKey.Name
    keyBox.TextColor3 = N.text
    keyBox.TextSize = 12
    keyBox.Font = Enum.Font.GothamMedium
    keyBox.AutoButtonColor = false
    keyBox.Parent = keyConfig
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 6)
    self.KeyConfig = keyConfig
    self.KeyBox = keyBox

    local separator = Instance.new("Frame")
    separator.Size = UDim2.new(1, 0, 0, 1)
    separator.BackgroundColor3 = N.stroke
    separator.BorderSizePixel = 0
    separator.LayoutOrder = 100
    separator.Parent = panel

    local credit = Instance.new("TextLabel")
    credit.Size = UDim2.new(1, 0, 0, 14)
    credit.BackgroundTransparency = 1
    credit.Text = "NØIR suite"
    credit.TextColor3 = N.text3
    credit.TextSize = 10
    credit.Font = Enum.Font.GothamMedium
    credit.LayoutOrder = 101
    credit.Parent = panel

    local action = Instance.new("TextButton")
    action.Name = "ActionButton"
    action.AnchorPoint = Vector2.new(0.5, 1)
    action.Size = UDim2.fromOffset(128, 40)
    action.Position = UDim2.new(0.5, 0, 1, -28)
    action.BackgroundColor3 = N.bg
    action.BorderSizePixel = 0
    action.Text = "Drop Kick"
    action.TextColor3 = N.text
    action.TextSize = 13
    action.Font = Enum.Font.GothamBold
    action.AutoButtonColor = false
    action.Visible = false
    action.Parent = gui
    Instance.new("UICorner", action).CornerRadius = UDim.new(0, 9)
    local actionStroke = Instance.new("UIStroke")
    actionStroke.Color = N.stroke
    actionStroke.Parent = action
    self.ActionButton = action

    local gearDragging, gearDragStart, gearStartPosition, gearDragDistance = false, nil, nil, 0
    gear.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        gearDragging = true
        gearDragStart = input.Position
        gearStartPosition = main.Position
        gearDragDistance = 0
    end)
    self.conns.gearMove = self.UserInputService.InputChanged:Connect(function(input)
        if not gearDragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - gearDragStart
        gearDragDistance = math.max(gearDragDistance, math.abs(delta.X) + math.abs(delta.Y))
        main.Position = UDim2.new(gearStartPosition.X.Scale, gearStartPosition.X.Offset + delta.X, gearStartPosition.Y.Scale, gearStartPosition.Y.Offset + delta.Y)
    end)
    self.UserInputService.InputEnded:Connect(function(input)
        if not gearDragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        gearDragging = false
        if gearDragDistance >= 8 then return end
        self.menuOpen = not self.menuOpen
        if self.menuOpen then
            panel.Visible = true
            panel.Size = UDim2.fromOffset(188, 0)
            self:ResizePanel()
        else
            panel:TweenSize(UDim2.fromOffset(188, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.15, true)
            task.delay(0.16, function()
                if not self.menuOpen then panel.Visible = false end
            end)
        end
    end)

    click.MouseButton1Click:Connect(function()
        self.selectedMethod = (self.selectedMethod == "Click") and "None" or "Click"
        self:UpdateUI(); self:SaveSettings()
    end)
    key.MouseButton1Click:Connect(function()
        if self.selectedMethod == "Key" then
            self.selectedMethod = "None"
            self.keyListening = false
            self.recordingKey = false
            if self.conns.keyRecord then self.conns.keyRecord:Disconnect(); self.conns.keyRecord = nil end
        else
            self.selectedMethod = "Key"
        end
        self:UpdateUI(); self:SaveSettings()
    end)
    uiButton.MouseButton1Click:Connect(function()
        self.selectedMethod = (self.selectedMethod == "UI Button") and "None" or "UI Button"
        self:UpdateUI(); self:SaveSettings()
    end)
    keyBox.MouseButton1Click:Connect(function()
        if self.selectedMethod ~= "Key" then return end
        if self.keyListening or self.recordingKey then return end
        self.keyListening = true
        self.recordingKey = true
        keyBox.Text = "..."
        if self.conns.keyRecord then self.conns.keyRecord:Disconnect(); self.conns.keyRecord = nil end
        self.conns.keyRecord = self.UserInputService.InputBegan:Connect(function(input)
            if not self.keyListening then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if input.KeyCode == Enum.KeyCode.Unknown then return end
            self.selectedKey = input.KeyCode
            self.keyListening = false
            keyBox.Text = self.selectedKey.Name
            if self.conns.keyRecord then self.conns.keyRecord:Disconnect(); self.conns.keyRecord = nil end
            task.delay(0.1, function() self.recordingKey = false end)
            self:SaveSettings()
        end)
    end)

    local dragging, dragStart, startPosition, dragDistance = false, nil, nil, 0
    action.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = true
        dragStart = input.Position
        startPosition = action.Position
        dragDistance = 0
        local changed
        changed = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                if changed then changed:Disconnect() end
                if dragDistance < 8 and self.selectedMethod == "UI Button" and not self.keyListening and not self.recordingKey then
                    self:PerformDropkick()
                end
            end
        end)
    end)
    self.conns.actionMove = self.UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - dragStart
        dragDistance = math.max(dragDistance, math.abs(delta.X) + math.abs(delta.Y))
        action.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end)

    self.uiReady = true
    self:UpdateUI()
    self.conns.toggleMenu = self.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.LeftControl then
            if not self.keyListening and not self.recordingKey then
                self.menuOpen = not self.menuOpen
                if self.menuOpen then
                    panel.Visible = true
                    panel.Size = UDim2.fromOffset(188, 0)
                    self:ResizePanel()
                else
                    panel:TweenSize(UDim2.fromOffset(188, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.15, true)
                    task.delay(0.16, function()
                        if not self.menuOpen then panel.Visible = false end
                    end)
                end
            end
        end
    end)
end

function utility:BeginDropkickHook(char)
    if not char then return warn("[NØIR DK] no character") end
    local hum = char:WaitForChild("Humanoid", 1)
    if not hum then return warn("[NØIR DK] no humanoid") end
    if not self:CheckValidRigType(hum) then
        self:Notify("NØIR Drop Kick", "R15 required")
        return
    end
    if not hum:WaitForChild("Animator", 1) then return warn("[NØIR DK] no animator") end
    return "success"
end

function utility:Initialize()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then return warn("[NØIR DK] no localplayer") end
    pcall(function()
        if isfolder and not isfolder(self.cacheFolder) then makefolder(self.cacheFolder) end
    end)
    self:LoadSettings()
    self.character = self.LocalPlayer.Character or self.LocalPlayer.CharacterAdded:Wait()
    self:ShowStartup()
    if self:BeginDropkickHook(self.character) ~= "success" then return end
    self.charadded = self.LocalPlayer.CharacterAdded:Connect(function(character)
        self:BeginDropkickHook(character)
    end)
    self:CreateUI()
    self:MouseDetection()
    self:StartKeyDetection()
    task.defer(function() self:SetupGlobalNoClip() end)
    return true
end

return utility:Initialize()

]====]

return N0IR
