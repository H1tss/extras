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
local SoundService = game:GetService("SoundService")

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
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        return pg or host
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- ============================================================
-- NØIR SHARED BRAND  (UI LIBRARY OWNS THIS)
-- ============================================================
local VISION_VIDEO_URL = "https://raw.githubusercontent.com/H1tss/extras/refs/heads/main/%E1%B4%A0%C9%AA%EA%9C%B1%C9%AA%E1%B4%8F%C9%B4%20(%EA%9C%B1%CA%9F%E1%B4%8F%E1%B4%A1%E1%B4%87%E1%B4%85).mp4"
local VISION_AUDIO_URL = "https://raw.githubusercontent.com/H1tss/extras/refs/heads/main/%E1%B4%A0%C9%AA%EA%9C%B1%C9%AA%E1%B4%8F%C9%B4%20(%EA%9C%B1%CA%9F%E1%B4%8F%E1%B4%A1%E1%B4%87%E1%B4%85).mp3"

_G._N0IR_Brand = {
    LogoUrl  = "https://raw.githubusercontent.com/H1tss/extras/refs/heads/main/D27xi.png",
    LogoPath = "N0IR/Logo_D27xi.png",
    LogoDir  = "N0IR",
    BgIndex  = tonumber(_G._N0IR_Brand and _G._N0IR_Brand.BgIndex) or 1,
    BgTransparency = (_G._N0IR_Brand and _G._N0IR_Brand.BgTransparency) or 0.42,
    VisionAudio = (_G._N0IR_Brand and _G._N0IR_Brand.VisionAudio) == true,
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
        {
            Name = "Vision",
            IsVideo = true,
            Url = VISION_VIDEO_URL,
            Path = "N0IR/Bg_Vision.mp4",
            AudioUrl = VISION_AUDIO_URL,
            AudioPath = "N0IR/Bg_Vision.mp3",
        },
    },
}

_G._N0IR_BgCache = _G._N0IR_BgCache or {}
_G._N0IR_BgTargets = _G._N0IR_BgTargets or {}
_G._N0IR_VideoBgTargets = _G._N0IR_VideoBgTargets or {}

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
_G._N0IR_CacheHttpAsset = _n0irCacheHttpAsset

_G._N0IR_EnsureLogoAsset = function(force)
    if force then _G._N0IR_LogoWM = nil end
    if _G._N0IR_LogoWM then return _G._N0IR_LogoWM end
    local cfg  = _G._N0IR_Brand or {}
    local url  = cfg.LogoUrl or "https://raw.githubusercontent.com/H1tss/extras/refs/heads/main/D27xi.png"
    local dir  = cfg.LogoDir or "N0IR"
    local path = cfg.LogoPath or "N0IR/Logo_D27xi.png"
    local asset = _n0irCacheHttpAsset(url, path, dir, "logo", force)
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

_G._N0IR_EnsureVisionAudioAsset = function(force)
    local cfg = _G._N0IR_Brand or {}
    local list = cfg.Backgrounds or {}
    local entry
    for _, e in ipairs(list) do
        if e and (e.Name == "Vision" or e.IsVideo) and e.AudioUrl then
            entry = e
            break
        end
    end
    if not entry then
        entry = { AudioUrl = VISION_AUDIO_URL, AudioPath = "N0IR/Bg_Vision.mp3" }
    end
    local key = "vision_audio"
    if force then _G._N0IR_BgCache[key] = nil end
    return _n0irCacheHttpAsset(entry.AudioUrl or VISION_AUDIO_URL, entry.AudioPath or "N0IR/Bg_Vision.mp3", cfg.LogoDir or "N0IR", key, force)
end

_G._N0IR_IsVisionBg = function(index)
    index = tonumber(index)
    if not index or index <= 0 then return false end
    local list = (_G._N0IR_Brand and _G._N0IR_Brand.Backgrounds) or {}
    local e = list[index]
    return e and (e.Name == "Vision" or e.IsVideo == true) and true or false
end

_G._N0IR_RegisterBgTarget = function(img)
    if not img then return end
    local alive = {}
    for _, t in ipairs(_G._N0IR_BgTargets or {}) do
        if t and t.Parent then table.insert(alive, t) end
    end
    table.insert(alive, img)
    _G._N0IR_BgTargets = alive
end

_G._N0IR_RegisterVideoBgTarget = function(vf)
    if not vf then return end
    local alive = {}
    for _, t in ipairs(_G._N0IR_VideoBgTargets or {}) do
        if t and t.Parent then table.insert(alive, t) end
    end
    table.insert(alive, vf)
    _G._N0IR_VideoBgTargets = alive
end

_G._N0IR_UpdateVisionAudio = function()
    local cfg = _G._N0IR_Brand or {}
    local want = _G._N0IR_IsVisionBg(cfg.BgIndex) and (cfg.VisionAudio == true)
    local snd = SoundService:FindFirstChild("N0IR_VisionAudio")
    if not want then
        if snd then
            pcall(function() snd:Stop() end)
            pcall(function() snd:Destroy() end)
        end
        return
    end
    local asset = _G._N0IR_EnsureVisionAudioAsset()
    if not asset then return end
    if not snd then
        snd = Instance.new("Sound")
        snd.Name = "N0IR_VisionAudio"
        snd.Looped = true
        snd.Volume = 0.55
        snd.Parent = SoundService
    end
    if snd.SoundId ~= asset then
        snd.SoundId = asset
    end
    if not snd.IsPlaying then
        pcall(function() snd:Play() end)
    end
end

_G._N0IR_SetVisionAudio = function(on)
    _G._N0IR_Brand = _G._N0IR_Brand or {}
    _G._N0IR_Brand.VisionAudio = on and true or false
    _G._N0IR_UpdateVisionAudio()
    if _G._N0IR_SaveSettings then task.defer(_G._N0IR_SaveSettings) end
    if _G._N0IR_OnVisionAudioChanged then
        pcall(_G._N0IR_OnVisionAudioChanged, _G._N0IR_Brand.VisionAudio)
    end
    return _G._N0IR_Brand.VisionAudio
end

-- pre-cache Vision media
task.defer(function()
    pcall(function()
        local list = (_G._N0IR_Brand and _G._N0IR_Brand.Backgrounds) or {}
        for i, e in ipairs(list) do
            if e and (e.Name == "Vision" or e.IsVideo) then
                _G._N0IR_EnsureBgAsset(i, false)
                _G._N0IR_EnsureVisionAudioAsset(false)
                break
            end
        end
    end)
end)

_G._N0IR_SetBackground = function(index)
    local cfg = _G._N0IR_Brand or {}
    index = math.floor(tonumber(index) or 0)
    local list = cfg.Backgrounds or {}
    if index < 0 then index = 0 end
    if index > #list then index = #list end
    cfg.BgIndex = index
    _G._N0IR_Brand = cfg

    local entry = (index > 0) and list[index] or nil
    local isVideo = entry and (entry.IsVideo or entry.Name == "Vision")
    local asset = (index > 0) and _G._N0IR_EnsureBgAsset(index) or nil
    local trans = tonumber(cfg.BgTransparency) or 0.42

    for _, img in ipairs(_G._N0IR_BgTargets or {}) do
        if img and img.Parent then
            if index <= 0 or not asset or isVideo then
                img.Image = ""
                img.Visible = false
            else
                img.Image = asset
                img.ImageTransparency = trans
                img.Visible = true
            end
        end
    end

    for _, vf in ipairs(_G._N0IR_VideoBgTargets or {}) do
        if vf and vf.Parent then
            if isVideo and asset then
                pcall(function()
                    vf.Video = asset
                    vf.Looped = true
                    vf.Volume = 0
                    vf.Visible = true
                    if vf.Play then vf:Play() end
                end)
            else
                pcall(function()
                    if vf.Pause then vf:Pause() end
                    vf.Video = ""
                    vf.Visible = false
                end)
            end
        end
    end

    _G._N0IR_UpdateVisionAudio()
    if _G._N0IR_OnBackgroundChanged then
        pcall(_G._N0IR_OnBackgroundChanged, index, isVideo)
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
    if i > n then i = 0 end
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

    local vbg = Instance.new("VideoFrame")
    vbg.Name = "N0IR_BgVideo"
    vbg.BackgroundTransparency = 1
    vbg.Size = UDim2.fromScale(1, 1)
    vbg.Position = UDim2.fromScale(0, 0)
    vbg.ZIndex = 0
    vbg.Visible = false
    vbg.Looped = true
    vbg.Volume = 0
    vbg.Parent = parent
    do
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius)
        c.Parent = vbg
    end

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
    _G._N0IR_RegisterVideoBgTarget(vbg)
    local idx = (_G._N0IR_Brand and tonumber(_G._N0IR_Brand.BgIndex)) or 1
    task.defer(function()
        _G._N0IR_SetBackground(idx)
    end)
    return bg
end

-- ============================================================
-- SETTINGS PERSISTENCE  (N0IR/settings.json)
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
            VisionAudio = brand.VisionAudio == true,
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
        local raw
        if isfile and isfile(SETTINGS_PATH) then
            raw = readfile(SETTINGS_PATH)
        elseif isfile and isfile(KEYBINDS_PATH) then
            raw = readfile(KEYBINDS_PATH)
        end
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
                if data.VisionAudio ~= nil then
                    _G._N0IR_Brand = _G._N0IR_Brand or {}
                    _G._N0IR_Brand.VisionAudio = data.VisionAudio and true or false
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
-- LOADING SCREEN
-- ============================================================
function N0IR:LoadingScreen(opts)
    opts = opts or {}
    local duration = opts.Duration or 2.4
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
    stack.Size = UDim2.fromOffset(320, 200)
    stack.BackgroundTransparency = 1
    stack.Parent = gui

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

    win.Size = UDim2.fromOffset(math.floor(width * 0.92), math.floor(height * 0.92))
    win.BackgroundTransparency = 1
    tween(win, {
        Size = UDim2.fromOffset(width, height),
        BackgroundTransparency = 0.04,
    }, 0.45)

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

    local titleLogo = Instance.new("ImageLabel")
    titleLogo.Name = "Logo"
    titleLogo.AnchorPoint = Vector2.new(0, 0.5)
    titleLogo.Position = UDim2.new(0, 12, 0.5, 0)
    titleLogo.Size = UDim2.fromOffset(42, 42)
    titleLogo.BackgroundTransparency = 1
    titleLogo.Image = ensureLogoAsset()
    titleLogo.ScaleType = Enum.ScaleType.Fit
    titleLogo.Parent = titleBar

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

    local accentLine = Instance.new("Frame")
    accentLine.Size = UDim2.new(1, 0, 0, 1)
    accentLine.Position = UDim2.new(0, 0, 1, 0)
    accentLine.BackgroundColor3 = T.accent
    accentLine.BackgroundTransparency = 0.85
    accentLine.BorderSizePixel = 0
    accentLine.Parent = titleBar

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

    -- menu toggle key
    local toggleKey = opts.ToggleKey or _G._N0IR_ToggleKey or Enum.KeyCode.M
    _G._N0IR_ToggleKey = toggleKey
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if input.KeyCode ~= (_G._N0IR_ToggleKey or toggleKey) then return end
        if UserInputService:GetFocusedTextBox() then return end
        screen.Enabled = not screen.Enabled
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

        function Tab:CreateParagraph(pOpts)
            pOpts = type(pOpts) == "string" and { Content = pOpts } or (pOpts or {})
            self._order = self._order + 1
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 0, 0)
            lbl.AutomaticSize = Enum.AutomaticSize.Y
            lbl.Font = Enum.Font.Gotham
            lbl.Text = pOpts.Content or pOpts.Text or ""
            lbl.TextSize = 11
            lbl.TextColor3 = T.text3
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextYAlignment = Enum.TextYAlignment.Top
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
                Instance = row,
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
            row.ClipsDescendants = false
            row.Parent = page
            corner(row, 8)
            stroke(row, T.border, 1, 0.65)

            local name = Instance.new("TextLabel")
            name.BackgroundTransparency = 1
            name.Position = UDim2.fromOffset(12, 0)
            name.Size = UDim2.new(0.45, 0, 1, 0)
            name.Font = Enum.Font.GothamMedium
            name.Text = ddOpts.Name or "Dropdown"
            name.TextSize = 12
            name.TextColor3 = T.text
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Parent = row

            local valBtn = Instance.new("TextButton")
            valBtn.AnchorPoint = Vector2.new(1, 0.5)
            valBtn.Position = UDim2.new(1, -12, 0.5, 0)
            valBtn.Size = UDim2.fromOffset(140, 26)
            valBtn.BackgroundColor3 = T.bg2
            valBtn.BorderSizePixel = 0
            valBtn.Font = Enum.Font.Gotham
            valBtn.Text = "  " .. tostring(current)
            valBtn.TextSize = 11
            valBtn.TextColor3 = T.text2
            valBtn.TextXAlignment = Enum.TextXAlignment.Left
            valBtn.AutoButtonColor = false
            valBtn.Parent = row
            corner(valBtn, 6)

            local drop = Instance.new("Frame")
            drop.Name = "Drop"
            drop.Visible = false
            drop.BackgroundColor3 = T.bg2
            drop.BorderSizePixel = 0
            drop.Position = UDim2.new(1, -152, 1, 4)
            drop.Size = UDim2.fromOffset(140, 0)
            drop.ZIndex = 50
            drop.Parent = row
            corner(drop, 6)
            stroke(drop, T.border, 1, 0.4)

            local dropList = Instance.new("UIListLayout")
            dropList.SortOrder = Enum.SortOrder.LayoutOrder
            dropList.Parent = drop

            local function setCurrent(v, fire)
                current = v
                if flag then N0IR.Flags[flag] = current end
                valBtn.Text = "  " .. tostring(current)
                if fire ~= false and ddOpts.Callback then
                    task.spawn(ddOpts.Callback, current)
                end
                if fire ~= false and _G._N0IR_SaveSettings then
                    task.defer(_G._N0IR_SaveSettings)
                end
            end

            local function rebuild()
                for _, ch in ipairs(drop:GetChildren()) do
                    if ch:IsA("TextButton") then ch:Destroy() end
                end
                for i, opt in ipairs(options) do
                    local ob = Instance.new("TextButton")
                    ob.Size = UDim2.new(1, 0, 0, 26)
                    ob.BackgroundColor3 = T.bg2
                    ob.BorderSizePixel = 0
                    ob.Font = Enum.Font.Gotham
                    ob.Text = "  " .. tostring(opt)
                    ob.TextSize = 11
                    ob.TextColor3 = T.text2
                    ob.TextXAlignment = Enum.TextXAlignment.Left
                    ob.AutoButtonColor = false
                    ob.LayoutOrder = i
                    ob.ZIndex = 51
                    ob.Parent = drop
                    ob.MouseEnter:Connect(function()
                        ob.BackgroundColor3 = T.bg3
                    end)
                    ob.MouseLeave:Connect(function()
                        ob.BackgroundColor3 = T.bg2
                    end)
                    ob.MouseButton1Click:Connect(function()
                        setCurrent(opt)
                        open = false
                        drop.Visible = false
                    end)
                end
                drop.Size = UDim2.fromOffset(140, math.max(1, #options) * 26)
            end
            rebuild()

            valBtn.MouseButton1Click:Connect(function()
                open = not open
                drop.Visible = open
            end)

            return {
                Set = function(_, v) setCurrent(v) end,
                Get = function() return current end,
                SetOptions = function(_, opts2)
                    options = opts2 or {}
                    rebuild()
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
            box.AnchorPoint = Vector2.new(1, 0.5)
            box.Position = UDim2.new(1, -12, 0.5, 0)
            box.Size = UDim2.new(0.55, 0, 0, 26)
            box.BackgroundColor3 = T.bg2
            box.BorderSizePixel = 0
            box.Font = Enum.Font.Gotham
            box.PlaceholderText = inOpts.Placeholder or ""
            box.PlaceholderColor3 = T.text3
            box.Text = tostring(inOpts.Default or "")
            box.TextSize = 11
            box.TextColor3 = T.text
            box.ClearTextOnFocus = false
            box.Parent = row
            corner(box, 6)

            box.FocusLost:Connect(function(enter)
                if inOpts.Callback then
                    task.spawn(inOpts.Callback, box.Text)
                end
            end)

            return {
                Set = function(_, t) box.Text = tostring(t or "") end,
                Get = function() return box.Text end,
            }
        end

        return Tab
    end

    table.insert(N0IR._windows, Window)
    return Window
end

-- ============================================================
-- QUICK START (minimal — host modules separately)
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
        ToggleKey = opts.ToggleKey,
    })
    -- Built-in Settings tab with wallpaper + Vision audio
    local Settings = win:CreateTab({ Name = "Settings" })
    Settings:CreateSection("About")
    Settings:CreateParagraph({
        Content = "NØIR UI Library v" .. N0IR.Version .. "\nMinimal black & white suite. Mount modules via loadstring onto this window.",
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

    -- Vision audio toggle — only visible when Vision is active
    local visionToggle
    local function refreshVisionToggle()
        local show = _G._N0IR_IsVisionBg and _G._N0IR_IsVisionBg(_G._N0IR_Brand and _G._N0IR_Brand.BgIndex)
        if visionToggle and visionToggle.Instance then
            visionToggle.Instance.Visible = show and true or false
        end
    end

    visionToggle = Settings:CreateToggle({
        Name = "Play Vision audio",
        Description = "Loops the Vision MP3 while this wallpaper is active",
        Flag = "VisionAudio",
        Default = (_G._N0IR_Brand and _G._N0IR_Brand.VisionAudio) == true,
        Callback = function(on)
            if _G._N0IR_SetVisionAudio then
                _G._N0IR_SetVisionAudio(on)
            end
        end,
    })
    if visionToggle and visionToggle.Instance then
        visionToggle.Instance.Visible = false
    end

    Settings:CreateDropdown({
        Name = "Wallpaper",
        Options = bgNames,
        Default = curBgName,
        Callback = function(name)
            local idx = 0
            for i, n in ipairs(bgNames) do
                if n == name then
                    idx = i - 1
                    break
                end
            end
            if _G._N0IR_SetBackground then
                _G._N0IR_SetBackground(idx)
            end
            bgLbl:Set("Active  ·  " .. name)
            refreshVisionToggle()
            N0IR:Notify({ Title = "Background", Content = name, Duration = 1.5 })
        end,
    })
    Settings:CreateButton({
        Name = "Next background",
        Callback = function()
            local i = _G._N0IR_NextBackground and _G._N0IR_NextBackground() or 0
            local name = (i <= 0) and "None" or (bgNames[i + 1] or ("BG " .. i))
            bgLbl:Set("Active  ·  " .. name)
            refreshVisionToggle()
            N0IR:Notify({ Title = "Background", Content = name, Duration = 1.2 })
        end,
    })
    Settings:CreateButton({
        Name = "No background",
        Callback = function()
            if _G._N0IR_SetBackground then _G._N0IR_SetBackground(0) end
            bgLbl:Set("Active  ·  None")
            refreshVisionToggle()
        end,
    })

    _G._N0IR_OnBackgroundChanged = function(idx)
        local name = (idx <= 0) and "None" or (bgNames[idx + 1] or ("BG " .. idx))
        bgLbl:Set("Active  ·  " .. name)
        refreshVisionToggle()
    end
    refreshVisionToggle()

    Settings:CreateSection("Keybinds")
    local keyLbl = Settings:CreateLabel("Menu toggle  ·  " .. tostring((_G._N0IR_ToggleKey or Enum.KeyCode.M).Name))
    local listening = false
    Settings:CreateButton({
        Name = "Set menu toggle key",
        Callback = function()
            if listening then return end
            listening = true
            keyLbl:Set("Press any key...")
            N0IR:Notify({ Title = "Keybind", Content = "Press a key (Esc to cancel)", Duration = 2 })
            task.delay(0.15, function()
                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if not conn then return end
                    conn:Disconnect()
                    conn = nil
                    listening = false
                    if input.KeyCode == Enum.KeyCode.Escape then
                        local cur = _G._N0IR_ToggleKey or Enum.KeyCode.M
                        keyLbl:Set("Menu toggle  ·  " .. cur.Name)
                        return
                    end
                    _G._N0IR_ToggleKey = input.KeyCode
                    keyLbl:Set("Menu toggle  ·  " .. input.KeyCode.Name)
                    if _G._N0IR_SaveSettings then _G._N0IR_SaveSettings() end
                    N0IR:Notify({ Title = "Keybind", Content = "Menu toggle → " .. input.KeyCode.Name, Duration = 2 })
                end)
            end)
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

    return win
end

return N0IR
