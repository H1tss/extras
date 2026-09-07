pcall(function()
	if queue_on_teleport then
		local ok, src = pcall(readfile, "TheMagicalUnicorn.lua")
		if ok and src then
			queue_on_teleport(src)
		end
	end
end)


do
	local MarketplaceService = game:GetService("MarketplaceService")
	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")

	local FALLBACK_NAME = "unknown place"
	local LOADING_DURATION = 2.6
	local POST_LOAD_DELAY = 0.35
	local _lsComplete = false

	local function getRealGameName()
		if game.GameId == 0 or game.PlaceId == 0 then return FALLBACK_NAME end
		local ok, info = pcall(function()
			return MarketplaceService:GetProductInfo(game.PlaceId)
		end)
		if ok and info and info.Name then return info.Name end
		return game.Name
	end

	local function showLoadingScreen()
		local player = game.Players.LocalPlayer
		local playerGui = player:WaitForChild("PlayerGui")
		local old = playerGui:FindFirstChild("MagicalLoadingScreen")
		if old then old:Destroy() end

		local placeName = getRealGameName()
		local placeId = tostring(game.PlaceId or 0)

		local gui = Instance.new("ScreenGui")
		gui.Name = "MagicalLoadingScreen"
		gui.IgnoreGuiInset = true
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.DisplayOrder = 999999
		gui.Parent = playerGui

		-- no full-screen background — only the card is visible over the game

		local card = Instance.new("Frame")
		card.Size = UDim2.fromOffset(320, 148)
		card.Position = UDim2.new(0, 28, 1, -176)
		card.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
		card.BackgroundTransparency = 0.05
		card.BorderSizePixel = 0
		card.Parent = gui
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(40, 40, 40)
		stroke.Thickness = 1
		stroke.Transparency = 0.2
		stroke.Parent = card

		local brand = Instance.new("TextLabel")
		brand.BackgroundTransparency = 1
		brand.Position = UDim2.fromOffset(14, 12)
		brand.Size = UDim2.new(1, -28, 0, 16)
		brand.Font = Enum.Font.GothamBlack
		brand.TextSize = 13
		brand.TextXAlignment = Enum.TextXAlignment.Left
		brand.TextColor3 = Color3.fromRGB(230, 230, 230)
		brand.Text = "NØIR Reanim"
		brand.Parent = card

		local placeLbl = Instance.new("TextLabel")
		placeLbl.BackgroundTransparency = 1
		placeLbl.Position = UDim2.fromOffset(14, 32)
		placeLbl.Size = UDim2.new(1, -28, 0, 14)
		placeLbl.Font = Enum.Font.Code
		placeLbl.TextSize = 11
		placeLbl.TextXAlignment = Enum.TextXAlignment.Left
		placeLbl.TextColor3 = Color3.fromRGB(120, 120, 120)
		placeLbl.Text = "place  " .. placeName
		placeLbl.TextTruncate = Enum.TextTruncate.AtEnd
		placeLbl.Parent = card

		local idLbl = Instance.new("TextLabel")
		idLbl.BackgroundTransparency = 1
		idLbl.Position = UDim2.fromOffset(14, 48)
		idLbl.Size = UDim2.new(1, -28, 0, 14)
		idLbl.Font = Enum.Font.Code
		idLbl.TextSize = 11
		idLbl.TextXAlignment = Enum.TextXAlignment.Left
		idLbl.TextColor3 = Color3.fromRGB(90, 90, 90)
		idLbl.Text = "id     " .. placeId
		idLbl.Parent = card

		local log = Instance.new("TextLabel")
		log.BackgroundTransparency = 1
		log.Position = UDim2.fromOffset(14, 72)
		log.Size = UDim2.new(1, -28, 0, 14)
		log.Font = Enum.Font.Code
		log.TextSize = 11
		log.TextXAlignment = Enum.TextXAlignment.Left
		log.TextColor3 = Color3.fromRGB(160, 160, 160)
		log.Text = "> boot"
		log.Parent = card

		local track = Instance.new("Frame")
		track.Size = UDim2.new(1, -28, 0, 6)
		track.Position = UDim2.fromOffset(14, 100)
		track.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
		track.BorderSizePixel = 0
		track.Parent = card
		Instance.new("UICorner", track).CornerRadius = UDim.new(0, 3)

		local fill = Instance.new("Frame")
		fill.Size = UDim2.fromScale(0, 1)
		fill.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		fill.BorderSizePixel = 0
		fill.Parent = track
		Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

		local pct = Instance.new("TextLabel")
		pct.BackgroundTransparency = 1
		pct.Position = UDim2.fromOffset(14, 114)
		pct.Size = UDim2.new(1, -28, 0, 14)
		pct.Font = Enum.Font.Code
		pct.TextSize = 11
		pct.TextXAlignment = Enum.TextXAlignment.Left
		pct.TextColor3 = Color3.fromRGB(140, 140, 140)
		pct.Text = "0%"
		pct.Parent = card

		local stamp = Instance.new("TextLabel")
		stamp.BackgroundTransparency = 1
		stamp.AnchorPoint = Vector2.new(1, 0)
		stamp.Position = UDim2.new(1, -24, 0, 20)
		stamp.Size = UDim2.fromOffset(200, 14)
		stamp.Font = Enum.Font.GothamBlack
		stamp.TextSize = 11
		stamp.TextXAlignment = Enum.TextXAlignment.Right
		stamp.TextColor3 = Color3.fromRGB(70, 70, 70)
		stamp.Text = "NØIR"
		stamp.Parent = gui

		card.BackgroundTransparency = 1
		for _, t in ipairs({brand, placeLbl, idLbl, log, pct, stamp}) do
			t.TextTransparency = 1
		end
		stroke.Transparency = 1
		track.BackgroundTransparency = 1
		fill.BackgroundTransparency = 1
		task.defer(function()
			TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.05}):Play()
			TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 0.2}):Play()
			TweenService:Create(track, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
			TweenService:Create(fill, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
			for _, t in ipairs({brand, placeLbl, idLbl, log, pct, stamp}) do
				TweenService:Create(t, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
			end
		end)

		local steps = {
			{0.00, "> boot"},
			{0.18, "> load modules"},
			{0.40, "> bind input"},
			{0.62, "> mount ui"},
			{0.82, "> ready"},
			{1.00, "> done"},
		}

		local conn
		local t0 = tick()
		local phase = "load"
		local phaseT = 0

		conn = RunService.Heartbeat:Connect(function()
			if phase == "load" then
				local p = math.min((tick() - t0) / LOADING_DURATION, 1)
				local jagged = math.clamp(p + math.sin(p * 11) * 0.012, 0, 1)
				fill.Size = UDim2.fromScale(jagged, 1)
				pct.Text = string.format("%d%%", math.floor(jagged * 100))
				local line = steps[1][2]
				for i = #steps, 1, -1 do
					if p >= steps[i][1] then
						line = steps[i][2]
						break
					end
				end
				log.Text = line
				if p >= 1 then
					-- hit 100% — start fading out immediately
					phase = "out"
					phaseT = tick()
					pct.Text = "100%"
					log.Text = "> done"
				end
			elseif phase == "out" then
				local p = math.min((tick() - phaseT) / 0.45, 1)
				card.BackgroundTransparency = 0.05 + p * 0.95
				stroke.Transparency = 0.2 + p * 0.8
				for _, t in ipairs({brand, placeLbl, idLbl, log, pct, stamp}) do
					t.TextTransparency = p
				end
				track.BackgroundTransparency = p
				fill.BackgroundTransparency = p
				if p >= 1 then
					conn:Disconnect()
					gui:Destroy()
					_lsComplete = true
				end
			end
		end)
	end

	showLoadingScreen()
	repeat task.wait() until _lsComplete
end




-- ============================================================
-- SHADERS & LIGHTING MODULE (From Pastebin k8ifajfk)
-- ============================================================
task.spawn(function()
    if not _G._HaloShadersEnabled then return end
    local Lighting = game:GetService("Lighting")
    local SoundService = game:GetService("SoundService")

    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Atmosphere")
        or v:IsA("Sky")
        or v:IsA("BloomEffect")
        or v:IsA("ColorCorrectionEffect")
        or v:IsA("SunRaysEffect")
        or v:IsA("DepthOfFieldEffect") then
            v:Destroy()
        end
    end

    local oldMusic = SoundService:FindFirstChild("CustomMusic")
    if oldMusic then
        oldMusic:Destroy()
    end

    Lighting.ExposureCompensation = 0
    Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
    Lighting.FogColor = Color3.fromRGB(192, 192, 192)
    Lighting.FogEnd = 1000
    Lighting.TimeOfDay = "06:49:30"
    Lighting.Technology = Enum.Technology.ShadowMap
    Lighting.EnvironmentDiffuseScale = 0.1
    Lighting.EnvironmentSpecularScale = 0.5
    Lighting.ShadowSoftness = 0.4
    Lighting.FogStart = 0
    Lighting.Ambient = Color3.fromRGB(60, 60, 60)
    Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
    Lighting.GeographicLatitude = 0
    Lighting.Brightness = 1.2
    Lighting.ColorShift_Top = Color3.fromRGB(200, 200, 200)
    Lighting.ClockTime = 6.825

    local Atmosphere = Instance.new("Atmosphere")
    Atmosphere.Density = 0.419
    Atmosphere.Offset = 0
    Atmosphere.Color = Color3.fromRGB(60, 60, 60)
    Atmosphere.Glare = 1
    Atmosphere.Haze = 0
    Atmosphere.Decay = Color3.fromRGB(0, 0, 0)
    Atmosphere.Parent = Lighting

    local Sky = Instance.new("Sky")
    Sky.StarCount = 3000
    Sky.SkyboxUp = "rbxassetid://600835177"
    Sky.MoonTextureId = "rbxassetid://102013024637283"
    Sky.SkyboxBk = "rbxassetid://600830446"
    Sky.CelestialBodiesShown = true
    Sky.SkyboxDn = "rbxassetid://600831635"
    Sky.SkyboxLf = "rbxassetid://600886090"
    Sky.SunTextureId = "rbxasset://sky/sun.jpg"
    Sky.SunAngularSize = 11
    Sky.SkyboxFt = "rbxassetid://600832720"
    Sky.SkyboxRt = "rbxassetid://600833862"
    Sky.MoonAngularSize = 11
    Sky.Parent = Lighting

    local sound = Instance.new("Sound")
    sound.Name = "CustomMusic"
    sound.SoundId = "rbxassetid://140449815647953"
    sound.Volume = 0.5
    sound.Looped = true
    sound.Parent = SoundService

    task.spawn(function()
        local success = pcall(function()
            sound.Loaded:Wait()
        end)

        if success then
            sound:Play()
        else
            warn("Sound failed to load.")
        end
    end)

    local Players = game:GetService("Players")
    local TeleportService = game:GetService("TeleportService")
    local Workspace = game:GetService("Workspace")

    local player = Players.LocalPlayer
    local camera = Workspace.CurrentCamera

    local noclip = false
    local viewTarget

    local function findPlayer(name)
        name = name:lower()

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Name:lower():sub(1,#name) == name then
                return plr
            end

            if plr.DisplayName:lower():sub(1,#name) == name then
                return plr
            end
        end
    end

    local function giveTPTool()
        local backpack = player:WaitForChild("Backpack")

        local old = backpack:FindFirstChild("TP Tool")
        if old then
            old:Destroy()
        end

        local tool = Instance.new("Tool")
        tool.Name = "TP Tool"
        tool.RequiresHandle = false
        tool.Parent = backpack

        tool.Activated:Connect(function()
            local mouse = player:GetMouse()

            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame =
                    CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0))
            end
        end)
    end

    game:GetService("RunService").Stepped:Connect(function()
        if noclip and player.Character then
            for _, v in ipairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end)

    player.Chatted:Connect(function(msg)
        local args = string.split(msg, " ")
        local cmd = args[1]:lower()

        if cmd == ";rs" then
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = 0
            end

        elseif cmd == ";tp" then
            giveTPTool()

        elseif cmd == ";goto" then
            local target = findPlayer(args[2] or "")

            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

                if hrp then
                    hrp.CFrame =
                        target.Character.HumanoidRootPart.CFrame
                        + Vector3.new(0,3,0)
                end
            end

        elseif cmd == ";ws" then
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

            if hum and tonumber(args[2]) then
                hum.WalkSpeed = tonumber(args[2])
            end

        elseif cmd == ";jp" then
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

            if hum and tonumber(args[2]) then
                hum.JumpPower = tonumber(args[2])
            end

        elseif cmd == ";sit" then
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

            if hum then
                hum.Sit = true
            end

        elseif cmd == ";rejoin" then
            TeleportService:Teleport(game.PlaceId, player)

        elseif cmd == ";fov" then
            if tonumber(args[2]) then
                camera.FieldOfView = tonumber(args[2])
            end

        elseif cmd == ";gravity" then
            if tonumber(args[2]) then
                Workspace.Gravity = tonumber(args[2])
            end

        elseif cmd == ";noclip" then
            noclip = true

        elseif cmd == ";clip" then
            noclip = false

            if player.Character then
                for _, v in ipairs(player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = true
                    end
                end
            end

        elseif cmd == ";view" then
            local target = findPlayer(args[2] or "")

            if target and target.Character and target.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = target.Character.Humanoid
                viewTarget = target
            end

        elseif cmd == ";unview" then
            local hum = player.Character and player.Character:FindFirstChild("Humanoid")

            if hum then
                camera.CameraSubject = hum
                viewTarget = nil
            end
        end
    end)
end)

pcall(function() game:GetService("CoreGui").RobloxGui["CoreScripts/NetworkPause"]:Destroy() end)

pcall(function() loadstring("if getgenv().LPH_NO_VIRTUALIZE == nil then getgenv().LPH_NO_VIRTUALIZE = function(f) return f end end")() end)
pcall(function() loadstring("if getgenv().LPH_JIT == nil then getgenv().LPH_JIT = function(f) return f end end")() end)
pcall(function() loadstring("if getgenv().LPH_JIT_MAX == nil then getgenv().LPH_JIT_MAX = function(f) return f end end")() end)

-- ============================================================
-- RE-EXECUTION CLEANUP: Reset all persistent flags and destroy old UI
-- This ensures the script works cleanly every time you rejoin or re-execute
-- ============================================================
_G._HaloInfBaseplateApplied = nil
if _G._HaloInfBPConn then _G._HaloInfBPConn:Disconnect() _G._HaloInfBPConn = nil end
_G._HaloResetLastTick = nil
_G._HaloAnimCopierActive = nil

-- Reset Action Toggles
_G._HaloRightArmPointerEnabled = false
_G._HaloLeftArmPointerEnabled = false
_G._HaloRightArmStretching = false
_G._HaloLeftArmStretching = false
_G._HaloTorsoStretcherEnabled = false
_G._HaloLimbsTorsoCamControl = false
_G._HaloHeadTrackerEnabled = false
_G._HaloTrackerEnabled = false
_G._FortniteWheelEnabled = false
_G._HaloGhostBodyEnabled = false
_G._HaloNoClipActive = false
_G._HaloShadersEnabled = false

_G._HaloTeleportKey = nil
_G._UniCmdBarKey = nil

-- Destroy old ScreenGui if it exists
pcall(function()
    local PlayerGui = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if PlayerGui then
        local oldGui = PlayerGui:FindFirstChild("ReanimHaloMenu")
        if oldGui then oldGui:Destroy() end
    end
end)

-- Destroy old mobile wheel button if it exists
pcall(function()
    local CoreGui = game:GetService("CoreGui")
    local oldBtn = CoreGui:FindFirstChild("HaloMobileWheelBtn")
    if oldBtn then oldBtn:Destroy() end
end)

-- Clean up old connections if stored
pcall(function()
    if _G._HaloReanimConns then
        for k, conn in pairs(_G._HaloReanimConns) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
        _G._HaloReanimConns = {}
    end
end)


-- Ensure these are always defined locally if still nil
pcall(function() loadstring("if getgenv().LPH_NO_VIRTUALIZE == nil then getgenv().LPH_NO_VIRTUALIZE = function(f) return f end end")() end)
pcall(function() loadstring("if getgenv().LPH_JIT == nil then getgenv().LPH_JIT = function(f) return f end end")() end)
pcall(function() loadstring("if getgenv().LPH_JIT_MAX == nil then getgenv().LPH_JIT_MAX = function(f) return f end end")() end)

if _G._HaloReanimConns then
    for k, conn in pairs(_G._HaloReanimConns) do
        if conn then
            pcall(function() conn:Disconnect() end)
            _G._HaloReanimConns[k] = nil
        end
    end
else
    _G._HaloReanimConns = {}
end
if _G._ReanimRawConn then
    pcall(function() _G._ReanimRawConn:Disconnect() end)
    _G._ReanimRawConn = nil
end

pcall(function()
    settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
end)
pcall(function()
    settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnvironmentalPhysicsThrottle.Disabled
end)

pcall(function()
    for _, child in ipairs(game:GetService("SoundService"):GetChildren()) do
        if child.Name == "HaloEmoteSound" or child.Name == "HaloClickSound" then
            child:Stop()
            child:Destroy()
        end
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

-- The default camera keyboard zoom action is bound asynchronously 
-- by the PlayerModule, so we wait for it to exist before unbinding.
task.spawn(function()
    while true do
        local info = ContextActionService:GetBoundActionInfo("RbxCameraKeypress")
        if info and info.inputTypes then
            ContextActionService:UnbindAction("RbxCameraKeypress")
            break
        end
        task.wait()
    end
end)

local plr       = Players.LocalPlayer
local PlayerGui = plr:WaitForChild("PlayerGui")
local Mouse     = plr:GetMouse()
local RebuildVisible = nil

-- Helper functions for parsing JSON and table animations
function toCFrame(val)
    if typeof(val) == "CFrame" then
        return val
    elseif type(val) == "table" then
        if #val == 12 then
            return CFrame.new(table.unpack(val))
        elseif #val == 7 then
            return CFrame.new(val[1], val[2], val[3], val[4], val[5], val[6], val[7])
        elseif val.Position or val.position or val.pos or val.Orientation or val.orientation or val.rotation or val.angles or val.CFrame then
            -- Handle {CFrame: {Position: [], Orientation: []}} nested structure
            local cfData = val.CFrame or val
            local pos = cfData.Position or cfData.position or cfData.pos or val.Position or val.position or val.pos or {0,0,0}
            local ori = cfData.Orientation or cfData.orientation or cfData.rotation or cfData.angles or val.Orientation or val.orientation or val.rotation or val.angles or {0,0,0}
            
            local px, py, pz = 0, 0, 0
            if typeof(pos) == "Vector3" then
                px, py, pz = pos.X, pos.Y, pos.Z
            elseif type(pos) == "table" then
                px, py, pz = pos[1] or 0, pos[2] or 0, pos[3] or 0
            end
            
            local rx, ry, rz = 0, 0, 0
            if typeof(ori) == "Vector3" then
                rx, ry, rz = ori.X, ori.Y, ori.Z
            elseif type(ori) == "table" then
                rx, ry, rz = ori[1] or 0, ori[2] or 0, ori[3] or 0
            end
            
            return CFrame.new(px, py, pz) * CFrame.fromEulerAnglesXYZ(rx, ry, rz)
        else
            local ok, cf = pcall(function() return CFrame.new(table.unpack(val)) end)
            if ok then return cf end
        end
    end
    return nil
end

function parseTableAnimation(raw)
    if type(raw) ~= "table" then return nil end
    -- Unwrap root-object formats: {keyframes=[...]}, {Keyframes=[...]}, etc.
    local arrayRoot = raw
    if type(raw[1]) ~= "table" then
        for _, key in ipairs({"keyframes","Keyframes","animations","frames","data","Frames","KeyframeSequence","animData"}) do
            if type(raw[key]) == "table" then 
                local sub = raw[key]
                if key == "animData" and type(sub.KeyframeSequence) == "table" then
                    arrayRoot = sub.KeyframeSequence
                else
                    arrayRoot = sub
                end
                break 
            end
        end
    end
    local keyframes = {}

    -- Helper: extract bone CFrame data from a single keyframe entry
    local function extractSingleFrame(frame, key)
        if type(frame) ~= "table" then return end
        local t = frame.Time or frame.time or frame.timestamp or frame.t
        if t == nil and key then
            t = tonumber(key)
        end
        -- Look for poses/bones in multiple property names
        local posesRaw = frame.Poses or frame.poses or frame.joints or frame.bones or frame.Joints or frame.Data or frame.data
        if not posesRaw then posesRaw = frame end
        if t ~= nil and type(posesRaw) == "table" then
            local kf = {Time = tonumber(t) or 0, Data = {}}
            for boneName, boneData in pairs(posesRaw) do
                local function _processBone()
                    if type(boneName) == "string" and (boneName:lower() == "time" or boneName:lower() == "t") then return end
                    if type(boneData) ~= "table" and typeof(boneData) ~= "CFrame" then return end
                    -- If boneData is already a CFrame, use it directly — DO NOT index it with .CFrame
                    -- (that throws "CFrame is not a valid member of CFrame")
                    local rawVal
                    if typeof(boneData) == "CFrame" then
                        rawVal = boneData
                    else
                        -- Try to get CFrame from various property names
                        rawVal = boneData.CFrame or boneData.cframe or boneData.transform or boneData
                    end
                    local cf = toCFrame(rawVal)
                    if cf then
                        kf.Data[boneName] = cf
                    end
                end
                _processBone()
            end
            if next(kf.Data) then
                table.insert(keyframes, kf)
            end
        end
    end

    -- Yield every 50 keyframes so the game scheduler can breathe on large animations
    local processed = 0
    for key, frame in pairs(arrayRoot) do
        local function _processFrame()
            if type(frame) ~= "table" then return end
            -- Format-2 support: if this value is an array of keyframe objects (named sequence),
            -- iterate through the sub-array instead of treating it as a single frame
            if type(frame[1]) == "table" then
                for subIdx, subFrame in ipairs(frame) do
                    extractSingleFrame(subFrame, subIdx)
                    processed = processed + 1
                    if processed % 50 == 0 then task.wait() end
                end
            else
                extractSingleFrame(frame, key)
                processed = processed + 1
                if processed % 50 == 0 then task.wait() end
            end
        end
        _processFrame()
    end
    if #keyframes == 0 then 
        warn("[AnimEditor] parseTableAnimation produced 0 keyframes from", #arrayRoot or 0, "input frames")
        return nil 
    end
    table.sort(keyframes, function(a, b) return a.Time < b.Time end)
    return keyframes
end

function parseJsonAnimation(content)
    local ok, raw = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok then 
        warn("[AnimEditor] JSON decode failed:", raw)
        return nil 
    end
    local result = parseTableAnimation(raw)
    if not result then
        warn("[AnimEditor] parseTableAnimation failed for JSON data. Raw structure:", typeof(raw), type(raw))
        if type(raw) == "table" then
            local keys = {}
            for k, v in pairs(raw) do table.insert(keys, tostring(k)) end
            warn("[AnimEditor] Keys in JSON:", table.concat(keys, ", "))
            if raw[1] then
                warn("[AnimEditor] First element type:", type(raw[1]))
                if type(raw[1]) == "table" then
                    local firstKeys = {}
                    for k, v in pairs(raw[1]) do table.insert(firstKeys, tostring(k)) end
                    warn("[AnimEditor] First element keys:", table.concat(firstKeys, ", "))
                end
            end
        end
    end
    return result
end

-- Load API (embedded)
local ReanimateAPI
do
    local halo = {
        services = {
            players = game:GetService("Players");
            workspace = game:GetService("Workspace");
            replicated = game:GetService("ReplicatedStorage");
            run_service = game:GetService("RunService");
            http_service = game:GetService("HttpService");
        };
        flags = {
            reanimated = false;
            switching = false;
        };
        clones = {};
        connections = {
            hb = nil;
            died = nil;
            real_char_child_removed = nil;
            character_removing = nil;
            clone_died = nil;
            clone_char_child_removed = nil;
            animation_hb = nil;
            zero_delay = nil;
            zero_delay_hrp_sync = nil;
            shiftlock_hb = nil;
        };
        real_chars = {};
        callbacks = {
            on_play = nil;
            on_stop = nil;
        };
        animation = {
            cache = {};
            constraints_cache = nil;
            state = {
                is_playing = false;
                current_url = nil;
                speed = 1.0;
                keyframes = nil;
                total_duration = 0;
                elapsed_time = 0;
            };
            original_transforms = {};
            constraints = {};
        };
    };

    local API = {};

    local get_local_player = function()
        local player = halo.services.players.LocalPlayer;
        if not player then
            return "bad argument to 'get_local_player' (LocalPlayer not found; must run in a LocalScript)";
        end;
        return player;
    end;

    local get_char = function(player)
        if typeof(player) ~= "Instance" or not player:IsA("Player") then
            return ("bad argument #1 to 'get_char' (Player expected, got %s)"):format(typeof(player));
        end;
        local character = player.Character;
        if not character or not character.Parent then
            return ("Player %s has no active character."):format(player.Name);
        end;
        return character;
    end;

    local get_animator = function(character)
        local humanoid = character:FindFirstChildOfClass("Humanoid");
        if not humanoid then return nil end;
        return humanoid:FindFirstChildOfClass("Animator");
    end;

    API.play_raw_animation = function(name, script_content, speed, force_reload)
        local player = get_local_player();
        if typeof(player) == "string" then return player end;

        local clone = API.get_clone(player);
        if not clone then
            return "Cannot play animation, character not found.";
        end;

        if halo.animation.state.is_playing and halo.animation.state.current_url == name then
            API.stop_animation();
            return;
        end;

        API.stop_animation();

        local clone_humanoid = clone:FindFirstChildWhichIsA("Humanoid");
        local clone_animate = clone:FindFirstChild("Animate");
        if clone_humanoid and clone_animate and (clone_humanoid.MoveDirection.Magnitude > 0 or clone_humanoid:GetState() == Enum.HumanoidStateType.Running) then
            clone_animate.Disabled = true;
            for _, track in ipairs(clone_humanoid:GetPlayingAnimationTracks()) do
                pcall(function() track:Stop(0) end);
            end;
        end;

        for _, child in ipairs(clone:GetChildren()) do
            if child:IsA("LocalScript") and child.Enabled and child ~= clone_animate then
                child.Enabled = false;
            end;
        end;

        local anim = halo.animation;
        anim.state.speed = tonumber(speed) or 1.0;

        -- Check cache first to avoid loadstring lag
        local keyframe_data = (not force_reload) and anim.cache[name] or nil;
        
        if not keyframe_data then
            -- Not in cache, need to compile
            local cleaned_content = script_content:gsub("^\xEF\xBB\xBF", ""):gsub("\r\n", "\n"):gsub("\r", "\n")
            if cleaned_content:match("^%s*return%s*{%s*local") then
                cleaned_content = cleaned_content:gsub("^%s*return%s*{%s*local", "local")
                local varName = cleaned_content:match("^%s*local%s+([%w_]+)%s*=")
                if varName then
                    cleaned_content = cleaned_content .. "\nreturn " .. varName
                end
            end
            local loaded_fn, err = loadstring(cleaned_content);
            if not loaded_fn then 
                return "Animation Error: Invalid script content. " .. tostring(err);
            end;

            local ok, data = pcall(function() return loaded_fn() end);
            if not ok then 
                return "Animation Error: Script failed to execute. " .. tostring(data);
            end;

            if typeof(data) ~= "table" then 
                return "Animation Error: Script did not return a table.";
            end;
            
            keyframe_data = data;
            anim.cache[name] = keyframe_data;
        end;

        local keyframes = nil
        if type(keyframe_data) == "table" then
            if keyframe_data[1] and type(keyframe_data[1]) == "table" and (keyframe_data[1].Time ~= nil or keyframe_data[1].time ~= nil or keyframe_data[1].Data ~= nil) then
                keyframes = keyframe_data
            else
                for _, v in pairs(keyframe_data) do
                    if type(v) == "table" and v[1] and type(v[1]) == "table" and (v[1].Time ~= nil or v[1].time ~= nil or v[1].Data ~= nil) then
                        keyframes = v
                        break
                    end
                end
                if not keyframes then
                    local first_key = next(keyframe_data)
                    if first_key and type(keyframe_data[first_key]) == "table" then
                        keyframes = keyframe_data[first_key]
                    end
                end
            end
        end

        if not keyframes or type(keyframes) ~= "table" or #keyframes == 0 then
            return "No valid keyframes array found for animation: " .. name;
        end

        anim.state.keyframes = keyframes;

        table.clear(anim.constraints);
        table.clear(anim.original_transforms);

        local constraints = {};
        local orig_transforms = {};
        for _, desc in ipairs(clone:GetDescendants()) do
            if desc:IsA("AnimationConstraint") then
                local att = desc.Attachment1;
                if att and att.Parent then
                    constraints[att.Parent.Name] = desc;
                    orig_transforms[desc] = desc.Transform;
                end;
                constraints[desc.Name] = desc;
                orig_transforms[desc] = desc.Transform;
            elseif desc:IsA("Motor6D") or desc:IsA("Motor") then
                if desc.Part1 then
                    constraints[desc.Part1.Name] = desc;
                end;
                constraints[desc.Name] = desc;
                orig_transforms[desc] = desc.Transform;
            end;
        end;

        if constraints["LowerTorso"] and not constraints["Torso"] then
            constraints["Torso"] = constraints["LowerTorso"];
        elseif constraints["Torso"] and not constraints["LowerTorso"] then
            constraints["LowerTorso"] = constraints["Torso"];
        end;

        anim.constraints = constraints;
        anim.original_transforms = orig_transforms;

        local fakeBaseParts = {};
        for _, part in ipairs(clone:GetDescendants()) do
            if part:IsA("BasePart") then
                table.insert(fakeBaseParts, part);
            end;
        end;

        anim.state.is_playing = true;
        anim.state.current_url = name;
        anim.state.total_duration = keyframes[#keyframes].Time;
        if anim.state.total_duration <= 0 then 
            API.stop_animation(); 
            return;
        end;

        anim.state.elapsed_time = 0;

        if halo.callbacks.on_play then
            pcall(halo.callbacks.on_play, anim.state.current_url);
        end;

        halo.connections.animation_hb = halo.services.run_service.PreSimulation:Connect(LPH_NO_VIRTUALIZE(function(deltaTime)
            if not (anim.state.is_playing and clone and clone.Parent) then
                API.stop_animation();
                return;
            end;

            for i = 1, #fakeBaseParts do
                if fakeBaseParts[i] and fakeBaseParts[i].Parent then
                    fakeBaseParts[i].CanCollide = false;
                end;
            end;

            if not anim.state.keyframes then return end;

            anim.state.elapsed_time = anim.state.elapsed_time + deltaTime * anim.state.speed;
            if anim.state.total_duration > 0 then
                anim.state.elapsed_time = anim.state.elapsed_time % anim.state.total_duration;
            end;

            local keyframes = anim.state.keyframes;
            local elapsed = anim.state.elapsed_time;
            local num_keyframes = #keyframes;
            local current_frame = nil;
            local next_frame = nil;

            for i = 1, num_keyframes - 1 do
                if elapsed >= keyframes[i].Time and elapsed < keyframes[i + 1].Time then
                    current_frame = keyframes[i];
                    next_frame = keyframes[i + 1];
                    break;
                end;
            end;

            if not current_frame then
                current_frame = keyframes[num_keyframes];
                next_frame = keyframes[1];
            end;

            local frame_duration = next_frame.Time - current_frame.Time;
            if frame_duration <= 0 then
                frame_duration = anim.state.total_duration;
            end;

            local time_in_frame = elapsed - current_frame.Time;
            local alpha = math.clamp(frame_duration > 0 and time_in_frame / frame_duration or 0, 0, 1);

            if current_frame.Data then
                for partName, pose_cframe in pairs(current_frame.Data) do
                    local constraint = constraints[partName];
                    if constraint and constraint.Parent then
                        local next_pose = next_frame.Data and next_frame.Data[partName];
                        local targetCF = next_pose and pose_cframe:Lerp(next_pose, alpha) or pose_cframe;
                        pcall(function()
                            constraint.Transform = targetCF;
                        end);
                    end;
                end;
            end;

            -- Fun head modes (spin / stare) take priority over camera head tracker
            if _G._HaloSpinHeadEnabled or _G._HaloStareEnabled or _G._HaloLookBehindEnabled
                or _G._HaloNodLoopEnabled or _G._HaloHeadTiltEnabled or _G._HaloCraneNeckEnabled then
                -- handled by fun tracking PreSimulation loop
            elseif _G._HaloHeadTrackerEnabled then
                local headConstraint = anim.constraints["Head"];
                if headConstraint then
                    local camera = workspace.CurrentCamera;
                    if camera then
                        local parentWorldCF = nil;
                        if headConstraint:IsA("Motor6D") and headConstraint.Part0 then
                            parentWorldCF = headConstraint.Part0.CFrame * headConstraint.C0;
                        else
                            local att0 = headConstraint.Attachment0;
                            if att0 and att0.Parent then
                                parentWorldCF = att0.WorldCFrame;
                            end;
                        end;
                        if parentWorldCF then
                            local bindTransform = anim.original_transforms[headConstraint];
                            if bindTransform then
                                local camLook = camera.CFrame.LookVector;
                                local localLookDir = parentWorldCF.Rotation:Inverse() * camLook;

                                -- Extract yaw & pitch and clamp to realistic neck limits
                                local yaw = math.atan2(localLookDir.X, -localLookDir.Z);
                                local pitch = math.asin(math.clamp(localLookDir.Y, -1, 1));
                                if not _G._HaloHeadTracker360 then
                                    local maxYaw = math.rad(75);
                                    local maxPitch = math.rad(55);
                                    yaw = math.clamp(yaw, -maxYaw, maxYaw);
                                    pitch = math.clamp(pitch, -maxPitch, maxPitch);
                                end

                                -- Rebuild clamped local look direction
                                local clampedDir = Vector3.new(
                                    math.sin(yaw) * math.cos(pitch),
                                    math.sin(pitch),
                                    -math.cos(yaw) * math.cos(pitch)
                                ).Unit;

                                -- Compute target rotation from bind pose to clamped direction
                                local bindDir = bindTransform.LookVector;
                                local rotAxis = bindDir:Cross(clampedDir);
                                local targetTransform;
                                if rotAxis.Magnitude > 0.001 then
                                    rotAxis = rotAxis.Unit;
                                    local angle = math.acos(math.clamp(bindDir:Dot(clampedDir), -1, 1));
                                    targetTransform = CFrame.fromAxisAngle(rotAxis, angle) * bindTransform;
                                elseif bindDir:Dot(clampedDir) < 0 then
                                    local perp = bindDir:Cross(Vector3.new(0, 1, 0));
                                    if perp.Magnitude < 0.001 then
                                        perp = bindDir:Cross(Vector3.new(1, 0, 0));
                                    end;
                                    targetTransform = CFrame.fromAxisAngle(perp.Unit, math.pi) * bindTransform;
                                else
                                    targetTransform = bindTransform;
                                end;

                                -- Smooth interpolation so it feels like a real neck turning
                                local smoothed = _G._HaloHeadTrackerSmoothedCF or bindTransform;
                                smoothed = smoothed:Lerp(targetTransform, 0.15);
                                _G._HaloHeadTrackerSmoothedCF = smoothed;
                                headConstraint.Transform = smoothed;
                            end;
                        end;
                    end;
                end;
            end;

            -- Arm Pointer: straight arm pointing at mouse target
            -- When enabled: shoulder rotates toward cursor, elbow/wrist are locked
            -- ============================================
            -- LIMBS: Arm Pointer, Arm Stretching & Reach
            -- ============================================
            local stretchAmt = _G._HaloArmStretchAmount or 2.5
            local function stretchArmOnly(lowerName, handName, stretchMult)
                if not stretchMult or stretchMult == 1.0 then return end
                local lower = anim.constraints[lowerName]
                local offset = CFrame.new(0, -(stretchMult - 1.0) * 1.2, 0)
                if lower then lower.Transform = offset * lower.Transform end
            end

            local function pointArm(upperName, lowerName, handName, stretchMult, customTargetPos)
                local shoulderConstraint = anim.constraints[upperName]
                if not shoulderConstraint then return end

                local isLeft = upperName:find("Left") ~= nil
                local resetFlag = isLeft and _G._HaloLeftArmPointerNeedsReset or _G._HaloRightArmPointerNeedsReset
                if resetFlag then
                    local orig = anim.original_transforms[shoulderConstraint]
                    if orig then shoulderConstraint.Transform = orig end
                    local elbowConstraint = anim.constraints[lowerName]
                    if elbowConstraint then elbowConstraint.Transform = CFrame.new() end
                    local wristConstraint = anim.constraints[handName]
                    if wristConstraint then wristConstraint.Transform = CFrame.new() end
                    if isLeft then _G._HaloLeftArmPointerNeedsReset = false
                    else _G._HaloRightArmPointerNeedsReset = false end
                end

                local shoulderWorldCF = nil
                if shoulderConstraint:IsA("Motor6D") and shoulderConstraint.Part0 then
                    shoulderWorldCF = shoulderConstraint.Part0.CFrame * shoulderConstraint.C0
                else
                    local att0 = shoulderConstraint.Attachment0
                    if att0 and att0.Parent then
                        shoulderWorldCF = att0.WorldCFrame
                    end
                end
                if not shoulderWorldCF then return end

                local shoulderPos = shoulderWorldCF.Position
                local aimTarget = customTargetPos
                if not aimTarget then
                    local camera = workspace.CurrentCamera
                    local mouse = plr:GetMouse()
                    if camera and mouse then
                        local unitRay = camera:ViewportPointToRay(mouse.X, mouse.Y)
                        local rayParams = RaycastParams.new()
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                        local filterList = {}
                        pcall(function()
                            if ReanimateAPI.get_clone then
                                local clone = ReanimateAPI.get_clone(plr)
                                if clone then table.insert(filterList, clone) end
                            end
                            if ReanimateAPI.get_real_character then
                                local real = ReanimateAPI.get_real_character(plr)
                                if real then table.insert(filterList, real) end
                            end
                        end)
                        rayParams.FilterDescendantsInstances = filterList
                        local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, rayParams)
                        aimTarget = result and result.Position or (unitRay.Origin + unitRay.Direction * 1000)
                    end
                end
                if not aimTarget then return end

                local aimDir = (aimTarget - shoulderPos)
                if aimDir.Magnitude <= 0.001 then return end
                aimDir = aimDir.Unit

                local bindTransform = shoulderConstraint.Transform
                if not bindTransform then return end

                local childBoneDir = Vector3.new(0, -1, 0)
                local bindBoneDir = (bindTransform.Rotation * childBoneDir).Unit
                local localAimDir = shoulderWorldCF.Rotation:Inverse() * aimDir

                local rotAxis = bindBoneDir:Cross(localAimDir)
                local shoulderResult
                if rotAxis.Magnitude > 0.001 then
                    rotAxis = rotAxis.Unit
                    local angle = math.acos(math.clamp(bindBoneDir:Dot(localAimDir), -1, 1))
                    local rotationCF = CFrame.fromAxisAngle(rotAxis, angle)
                    shoulderResult = rotationCF * bindTransform
                elseif bindBoneDir:Dot(localAimDir) < 0 then
                    local perp = bindBoneDir:Cross(Vector3.new(0, 1, 0))
                    if perp.Magnitude < 0.001 then perp = bindBoneDir:Cross(Vector3.new(1, 0, 0)) end
                    shoulderResult = CFrame.fromAxisAngle(perp.Unit, math.pi) * bindTransform
                else
                    shoulderResult = bindTransform
                end

                shoulderConstraint.Transform = shoulderResult

                local elbowConstraint = anim.constraints[lowerName]
                if elbowConstraint then elbowConstraint.Transform = CFrame.new() end
                local wristConstraint = anim.constraints[handName]
                if wristConstraint then wristConstraint.Transform = CFrame.new() end

                stretchMult = stretchMult or 1.0
                if stretchMult ~= 1.0 then
                    local c = anim.constraints[lowerName]
                    if c then
                        local baseLen = anim.bind_lengths and anim.bind_lengths[c]
                        if not baseLen or baseLen < 0.001 then
                            if c:IsA("Motor6D") and c.Part1 and c.Part1:IsA("BasePart") then
                                baseLen = c.Part1.Size.Y
                            else
                                local att1 = c and c.Attachment1
                                if att1 and att1.Parent and att1.Parent:IsA("BasePart") then
                                    baseLen = att1.Parent.Size.Y
                                else
                                    baseLen = 1.2
                                end
                            end
                        end
                        local boneDir = Vector3.new(0, -1, 0)
                        local stretchOffset = boneDir * baseLen * (stretchMult - 1.0)
                        c.Transform = CFrame.new(stretchOffset)
                    end
                end
            end

            -- 1. Arm Pointers
            if _G._HaloRightArmPointerEnabled then
                local isStretching = _G._HaloRightArmStretching or false
                pointArm("RightUpperArm", "RightLowerArm", "RightHand", isStretching and stretchAmt or 1.0)
            elseif not _G._HaloLeftArmPointerEnabled and not _G._HaloRightArmPointerEnabled and _G._HaloRightArmStretching and stretchAmt ~= 1.0 then
                stretchArmOnly("RightLowerArm", "RightHand", stretchAmt)
            end

            if _G._HaloLeftArmPointerEnabled then
                local isStretching = _G._HaloLeftArmStretching or false
                pointArm("LeftUpperArm", "LeftLowerArm", "LeftHand", isStretching and stretchAmt or 1.0)
            elseif not _G._HaloRightArmPointerEnabled and not _G._HaloLeftArmPointerEnabled and _G._HaloLeftArmStretching and stretchAmt ~= 1.0 then
                stretchArmOnly("LeftLowerArm", "LeftHand", stretchAmt)
            end

            -- ============================================
            -- ARM SLIDER: Upper arm welded to hip, stretch controls angle
            -- ============================================
            -- Unweld / restore original transforms when toggled off
            if not _G._HaloArmSliderEnabled and _G._HaloArmSliderPrevEnabled then
                _G._HaloArmSliderPrevEnabled = false
                for constraint, orig in pairs(_G._HaloArmSliderOriginalTransforms) do
                    if constraint and constraint.Parent then
                        pcall(function() constraint.Transform = orig end)
                    end
                end
                _G._HaloArmSliderOriginalTransforms = {}
            end
            if _G._HaloArmSliderEnabled then
                _G._HaloArmSliderPrevEnabled = true
                local offsetX = _G._HaloArmSliderOffsetX or 0
                local offsetY = _G._HaloArmSliderOffsetY or 0
                local stretch = _G._HaloArmSliderStretch or 1.0
                local rotEnabled = _G._HaloArmSliderRotationEnabled or false
                local rotDeg = _G._HaloArmSliderRotation or 0

                local rUpper = anim.constraints["RightUpperArm"] or _HaloFindConstraintOnClone(clone, "RightUpperArm")
                local rLower = anim.constraints["RightLowerArm"] or _HaloFindConstraintOnClone(clone, "RightLowerArm")
                local rHand = anim.constraints["RightHand"] or _HaloFindConstraintOnClone(clone, "RightHand")
                local hipJoint = anim.constraints["LowerTorso"] or anim.constraints["Waist"] or anim.constraints["Torso"]
                    or _HaloFindConstraintOnClone(clone, "LowerTorso") or _HaloFindConstraintOnClone(clone, "Waist")
                    or _HaloFindConstraintOnClone(clone, "Root") or _HaloFindConstraintOnClone(clone, "Torso")

                if rUpper and hipJoint then
                    -- Get the hip's live world CFrame (position + rotation)
                    local hipWorldCF
                    if hipJoint:IsA("Motor6D") then
                        if hipJoint.Part0 then
                            hipWorldCF = hipJoint.Part0.CFrame * hipJoint.C0
                        elseif hipJoint.Part1 then
                            hipWorldCF = hipJoint.Part1.CFrame * hipJoint.C1
                        end
                    else
                        local att0 = hipJoint.Attachment0
                        if att0 and att0.Parent then
                            hipWorldCF = att0.WorldCFrame
                        end
                    end

                    if hipWorldCF then
                        -- Target position: offset from hip in hip-local space
                        local targetPos = hipWorldCF.Position 
                            + hipWorldCF.RightVector * (0.3 + offsetX)
                            + hipWorldCF.UpVector * (0.2 + offsetY)
                            + hipWorldCF.LookVector * 0.25

                        -- Stretch controls base angle:
                        -- stretch 1.0 = -45 deg (pointing down)
                        -- stretch 10.0 = +85 deg (pointing up, capped)
                        local stretchAngleDeg = -45 + (stretch - 1) * (130 / 9)
                        stretchAngleDeg = math.clamp(stretchAngleDeg, -45, 85)

                        -- Rotation slider adds independent tilt
                        local totalAngleDeg = stretchAngleDeg
                        if rotEnabled then
                            totalAngleDeg = totalAngleDeg + rotDeg
                        end
                        local totalAngleRad = math.rad(totalAngleDeg)

                        -- Swing arm around shoulder (RightVector axis)
                        -- stretch 1.0 = down/back (image 1), stretch 10.0 = forward/up (image 2)
                        local t = math.clamp((stretch - 1) / 9, 0, 1)
                        local minAngle = math.rad(-15)     -- down/back
                        local maxAngle = math.rad(-135)    -- forward/up
                        local swingAngle = minAngle + t * (maxAngle - minAngle)

                        local armDir = (
                            -hipWorldCF.UpVector * math.cos(swingAngle)
                            - hipWorldCF.LookVector * math.sin(swingAngle)
                            + hipWorldCF.RightVector * 0.15
                        ).Unit

                        -- Build desired upper-arm world CFrame
                        -- RightVector = shoulder hinge axis (prevents twist/spin)
                        local yAxis = -armDir
                        local xAxis = hipWorldCF.RightVector
                        local zAxis = xAxis:Cross(yAxis).Unit
                        local desiredCF = CFrame.fromMatrix(targetPos, xAxis, yAxis)

                        -- Save original transforms before modifying (for unweld on toggle off)
                        if not _G._HaloArmSliderOriginalTransforms[rUpper] then
                            pcall(function()
                                _G._HaloArmSliderOriginalTransforms[rUpper] = rUpper.Transform
                            end)
                        end
                        if rLower and not _G._HaloArmSliderOriginalTransforms[rLower] then
                            pcall(function()
                                _G._HaloArmSliderOriginalTransforms[rLower] = rLower.Transform
                            end)
                        end
                        if rHand and not _G._HaloArmSliderOriginalTransforms[rHand] then
                            pcall(function()
                                _G._HaloArmSliderOriginalTransforms[rHand] = rHand.Transform
                            end)
                        end

                        -- Convert desired world CFrame into shoulder Transform
                        if rUpper:IsA("Motor6D") and rUpper.Part0 and rUpper.Part1 then
                            local part0CF = rUpper.Part0.CFrame
                            local c0 = rUpper.C0
                            local c1 = rUpper.C1
                            rUpper.Transform = c0:Inverse() * part0CF:Inverse() * desiredCF * c1
                        else
                            local att0 = rUpper.Attachment0
                            local att1 = rUpper.Attachment1
                            if att0 and att1 then
                                local desiredAtt1World = desiredCF * att1.CFrame
                                rUpper.Transform = att0.WorldCFrame:Inverse() * desiredAtt1World
                            end
                        end
                    end
                end

                if rLower then
                    local baseLen = anim.bind_lengths and anim.bind_lengths[rLower]
                    if not baseLen or baseLen < 0.001 then
                        if rLower:IsA("Motor6D") and rLower.Part1 and rLower.Part1:IsA("BasePart") then
                            baseLen = rLower.Part1.Size.Y
                        else
                            local att1 = rLower and rLower.Attachment1
                            if att1 and att1.Parent and att1.Parent:IsA("BasePart") then
                                baseLen = att1.Parent.Size.Y
                            else
                                baseLen = 1.2
                            end
                        end
                    end
                    if stretch ~= 1.0 then
                        local stretchOffset = Vector3.new(0, -baseLen * (stretch - 1.0), 0)
                        rLower.Transform = CFrame.new(stretchOffset)
                    else
                        rLower.Transform = CFrame.new()
                    end
                end

                if rHand then
                    rHand.Transform = CFrame.new()
                end
            end

            -- ============================================
            -- LIMBS: UpperTorso Height + Torso Camera
            -- ============================================
            if _G._HaloLimbsTorsoCamControl or _G._HaloTorsoStretcherEnabled then
                local waistConstraint = anim.constraints["Waist"] or anim.constraints["UpperTorso"]
                if waistConstraint then
                    local baseRot = waistConstraint.Transform.Rotation

                    -- Torso Camera Control: lean and turn with camera look direction
                    if _G._HaloLimbsTorsoCamControl then
                        local camera = workspace.CurrentCamera
                        if camera then
                            local parentWorldCF = nil
                            if waistConstraint:IsA("Motor6D") and waistConstraint.Part0 then
                                parentWorldCF = waistConstraint.Part0.CFrame * waistConstraint.C0
                            else
                                local att0 = waistConstraint.Attachment0
                                if att0 and att0.Parent then
                                    parentWorldCF = att0.WorldCFrame
                                end
                            end

                            if parentWorldCF then
                                local camLook = camera.CFrame.LookVector
                                local localLookDir = parentWorldCF.Rotation:Inverse() * camLook
                                local yaw = math.atan2(localLookDir.X, -localLookDir.Z)
                                local pitch = math.asin(math.clamp(localLookDir.Y, -1, 1))

                                local camMode = _G._HaloLimbsTorsoCamMode or "360"
                                local camRotCF
                                if camMode == "Locked" then
                                    yaw = math.clamp(yaw, -math.rad(45), math.rad(45))
                                    pitch = math.clamp(pitch, -math.rad(30), math.rad(30))
                                    camRotCF = CFrame.fromEulerAnglesYXZ(pitch, -yaw, 0)
                                elseif camMode == "Free" then
                                    camRotCF = parentWorldCF.Rotation:Inverse() * camera.CFrame.Rotation
                                else
                                    local fullPitch = pitch * 2.25
                                    camRotCF = CFrame.fromEulerAnglesYXZ(fullPitch, -yaw, 0)
                                end

                                local smoothed = _G._HaloTorsoCamSmoothedCF or camRotCF
                                smoothed = smoothed:Lerp(camRotCF, 0.25)
                                _G._HaloTorsoCamSmoothedCF = smoothed
                                baseRot = smoothed * baseRot
                            end
                        end
                    else
                        _G._HaloTorsoCamSmoothedCF = nil
                    end

                    -- UpperTorso Height offset (Torso Stretcher)
                    local utHeight = _G._HaloLimbsUpperTorsoHeight or 1.0
                    local stretchY = _G._HaloTorsoStretcherEnabled and ((utHeight - 1.0) * 2.5) or 0
                    if stretchY ~= 0 then
                        waistConstraint.Transform = CFrame.new(0, stretchY, 0) * baseRot
                    else
                        waistConstraint.Transform = baseRot
                    end
                end
            end

            -- ============================================
            -- LIMBS: Leg Stretcher
            -- ============================================
            if _G._HaloLegStretcherEnabled then
                local legScale = math.clamp(_G._HaloLimbsLegHeight or 1.0, 0.4, 100.0)
                if legScale ~= 1.0 then
                    local kneeOffset = CFrame.new(0, -(legScale - 1.0) * 1.5, 0)
                    local rll = anim.constraints["RightLowerLeg"]
                    local lll = anim.constraints["LeftLowerLeg"]
                    if rll then rll.Transform = kneeOffset * rll.Transform end
                    if lll then lll.Transform = kneeOffset * lll.Transform end
                end
                local h = anim.humanoid or (anim.rig and anim.rig:FindFirstChildOfClass("Humanoid"))
                if h then
                    local defHip = h:GetAttribute("HaloDefaultHipHeight")
                    if not defHip then
                        defHip = (h.HipHeight > 0) and h.HipHeight or 2.0
                        h:SetAttribute("HaloDefaultHipHeight", defHip)
                    end
                    h.HipHeight = defHip + math.max(0, (legScale - 1.0) * 1.5)
                end
            end
        end))
    end;

    API.stop_animation = function()
        if not halo.animation.state.is_playing then return end;

        local stopped_url = halo.animation.state.current_url;

        if halo.connections.animation_hb then
            halo.connections.animation_hb:Disconnect();
            halo.connections.animation_hb = nil;
        end;

        local player = get_local_player();
        if typeof(player) == "string" then return player end;

        local real_char = halo.real_chars[player];
        if real_char then
            for _, part in ipairs(real_char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        part.Velocity = Vector3.zero;
                        part.RotVelocity = Vector3.zero;
                        part.AssemblyLinearVelocity = Vector3.zero;
                        part.AssemblyAngularVelocity = Vector3.zero;
                    end);
                end;
            end;
        end;

        local clone = API.get_clone(player);
        if clone then
            for _, part in ipairs(clone:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        part.Velocity = Vector3.zero;
                        part.RotVelocity = Vector3.zero;
                        part.AssemblyLinearVelocity = Vector3.zero;
                        part.AssemblyAngularVelocity = Vector3.zero;
                    end);
                end;
            end;
            for constraint, orig_transform in pairs(halo.animation.original_transforms) do
                if constraint and constraint.Parent then
                    constraint.Transform = orig_transform;
                end;
            end;
            local clone_animate = clone:FindFirstChild("Animate");
            for _, child in ipairs(clone:GetChildren()) do
                if child:IsA("LocalScript") and (not child.Enabled and child ~= clone_animate) then
                    child.Enabled = true;
                end;
            end;
            if clone_animate then
                clone_animate.Disabled = false;
            end;
        end;

        table.clear(halo.animation.original_transforms);
        table.clear(halo.animation.constraints);
        halo.animation.state = {
            is_playing = false;
            current_url = nil;
            speed = 1.0;
            keyframes = nil;
            total_duration = 0;
            elapsed_time = 0;
        };

        if halo.callbacks.on_stop then
            pcall(halo.callbacks.on_stop, stopped_url);
        end;
    end;

    -- Lightweight stop used between state transitions — disconnects the animation
    -- heartbeat and clears state WITHOUT snapping bones back to bind pose.
    -- The next animation will overwrite the constraint transforms on its first tick.
    API.stop_animation_for_transition = function()
        if not halo.animation.state.is_playing then return end;
        local stopped_url = halo.animation.state.current_url;
        if halo.connections.animation_hb then
            halo.connections.animation_hb:Disconnect();
            halo.connections.animation_hb = nil;
        end;
        -- Restore original transforms so the next animation starts from bind pose.
        -- Without this, the new animation captures stale pose data as "original",
        -- causing arms to glitch when state animations transition (e.g. Idle->Walk).
        for constraint, orig_transform in pairs(halo.animation.original_transforms) do
            if constraint and constraint.Parent then
                constraint.Transform = orig_transform;
            end;
        end;
        table.clear(halo.animation.original_transforms);
        table.clear(halo.animation.constraints);
        halo.animation.state = {
            is_playing = false;
            current_url = nil;
            speed = 1.0;
            keyframes = nil;
            total_duration = 0;
            elapsed_time = 0;
        };
        if halo.callbacks.on_stop then
            pcall(halo.callbacks.on_stop, stopped_url);
        end;
    end;

    local partNames = {
        "Head",
        "UpperTorso",
        "LowerTorso",
        "LeftUpperArm",
        "LeftLowerArm",
        "LeftHand",
        "RightUpperArm",
        "RightLowerArm",
        "RightHand",
        "LeftUpperLeg",
        "LeftLowerLeg",
        "LeftFoot",
        "RightUpperLeg",
        "RightLowerLeg",
        "RightFoot",
        "Torso",
        "Left Arm",
        "Right Arm",
        "Left Leg",
        "Right Leg",
        "HumanoidRootPart"
    };

    local NETLESS_VELOCITY = Vector3.new(0, -26.1, 0);
    local ZERO_VECTOR = Vector3.zero;

    API.reanimate = function(enable)
        local player = get_local_player()
        if typeof(player) == "string" then return player end

        if enable then
            if halo.flags.reanimated then
                return "Already reanimated."
            end

            local real_char = player.Character
            if not real_char or not real_char.Parent then
                return "No active character."
            end

            local real_humanoid = real_char:FindFirstChildOfClass("Humanoid")
            local real_hrp = real_char:FindFirstChild("HumanoidRootPart")
            if not real_humanoid or not real_hrp then
                return "Missing Humanoid or HumanoidRootPart."
            end

            pcall(function()
                real_humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                real_humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                real_humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                real_humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
                real_humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
                real_humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
                real_humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
                real_humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
                real_humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
                real_humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
                real_humanoid.AutoRotate = false
                real_humanoid.PlatformStand = true
                real_humanoid.RequiresNeck = false
                real_humanoid.BreakJointsOnDeath = false
                real_humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            end)

            halo.real_chars[player] = real_char

            real_char.Archivable = true
            local fake_char = real_char:Clone()
            real_char.Archivable = false
            fake_char.Name = real_char.Name .. "Celeste"

            local fake_humanoid = fake_char:FindFirstChildWhichIsA("Humanoid")
            if fake_humanoid then
                fake_humanoid.DisplayName = real_char.Name .. "Celeste"
                fake_humanoid.WalkSpeed = real_humanoid.WalkSpeed
                fake_humanoid.JumpPower = real_humanoid.JumpPower
                fake_humanoid.AutoRotate = true
            end
            if not fake_char.PrimaryPart and fake_char:FindFirstChild("HumanoidRootPart") then
                fake_char.PrimaryPart = fake_char:FindFirstChild("HumanoidRootPart")
            end

            for _, desc in ipairs(fake_char:GetDescendants()) do
                if desc:IsA("BasePart") then
                    desc.Transparency = 1
                elseif desc:IsA("Decal") then
                    desc.Transparency = 1
                end
            end

            local zeroPhys = PhysicalProperties.new(0.001, 0, 0, 0, 0)
            for _, desc in ipairs(real_char:GetDescendants()) do
                if desc:IsA("BasePart") then
                    pcall(function()
                        desc.CanCollide = false
                        desc.CanTouch = false
                        desc.CanQuery = false
                        desc.Massless = true
                        desc.CustomPhysicalProperties = zeroPhys
                    end)
                end
            end

            local real_animate = real_char:FindFirstChild("Animate")
            local fake_animate = nil
            if real_animate then
                fake_animate = real_animate:Clone()
                fake_animate.Parent = fake_char
                fake_animate.Disabled = true
            end

            local savedResetOnSpawns = {}
            local player_gui = player:FindFirstChildWhichIsA("PlayerGui")
            if player_gui then
                for _, gui in ipairs(player_gui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.ResetOnSpawn then
                        table.insert(savedResetOnSpawns, gui)
                        gui.ResetOnSpawn = false
                    end
                end
            end

            fake_char.Parent = halo.services.workspace
            player.Character = fake_char
            halo.clones[player] = fake_char

            local partMap = {}
            for _, name in ipairs(partNames) do
                local rP = real_char:FindFirstChild(name)
                local fP = fake_char:FindFirstChild(name)
                if rP and fP then
                    table.insert(partMap, { name = name, real = rP, fake = fP })
                end
            end
            for _, rDesc in ipairs(real_char:GetDescendants()) do
                if rDesc:IsA("Accessory") then
                    local rHandle = rDesc:FindFirstChild("Handle")
                    local fAcc = fake_char:FindFirstChild(rDesc.Name)
                    local fHandle = fAcc and fAcc:FindFirstChild("Handle")
                    if rHandle and fHandle and rHandle:IsA("BasePart") and fHandle:IsA("BasePart") then
                        for _, w in ipairs(rDesc:GetDescendants()) do
                            if w:IsA("Weld") or w:IsA("WeldConstraint") or w:IsA("Motor6D") then
                                w.Enabled = false
                            end
                        end
                        table.insert(partMap, { name = rDesc.Name, real = rHandle, fake = fHandle })
                    end
                end
            end

            local camera = halo.services.workspace.CurrentCamera
            if fake_humanoid and camera then
                camera.CameraSubject = fake_humanoid
            end

            for _, gui in ipairs(savedResetOnSpawns) do
                if gui and gui.Parent then
                    gui.ResetOnSpawn = true
                end
            end

            if fake_animate then fake_animate.Disabled = false end
            if fake_humanoid then fake_humanoid:ChangeState(Enum.HumanoidStateType.Running) end

            task.spawn(function()
                local event_rag = halo.services.replicated:FindFirstChild("event_rag")
                local ragdoll_remote = halo.services.replicated:FindFirstChild("Ragdoll")
                if event_rag then
                    pcall(function()
                        if real_humanoid and fake_humanoid then
                            fake_humanoid.HipHeight = real_humanoid.HipHeight
                        end
                        event_rag:FireServer("Hinge")
                    end)
                elseif ragdoll_remote then
                    pcall(function()
                        ragdoll_remote:FireServer("Ball")
                    end)
                else
                    pcall(function()
                        if real_char then
                            for _, v in ipairs(real_char:GetDescendants()) do
                                if v:IsA("Motor6D") then
                                    v.Enabled = false
                                end
                            end
                        end
                    end)
                end
            end)

            for i = 1, #partMap do
                local rP = partMap[i].real
                local fP = partMap[i].fake
                if rP and fP then
                    pcall(function()
                        local ncc = Instance.new("NoCollisionConstraint")
                        ncc.Part0 = rP
                        ncc.Part1 = fP
                        ncc.Parent = rP
                    end)
                end
            end
            for i = 1, math.min(#partMap, 25) do
                for j = i + 1, math.min(#partMap, 25) do
                    local p1 = partMap[i].real
                    local p2 = partMap[j].real
                    if p1 and p2 then
                        pcall(function()
                            local ncc = Instance.new("NoCollisionConstraint")
                            ncc.Part0 = p1
                            ncc.Part1 = p2
                            ncc.Parent = p1
                        end)
                    end
                end
            end

            for k, conn in pairs(halo.connections) do
                if conn then conn:Disconnect(); halo.connections[k] = nil; end
            end

            -- 1. Stepped (PreSimulation): Maintain noclip and neutral humanoid state before physics step
            halo.connections.stepped = halo.services.run_service.Stepped:Connect(LPH_NO_VIRTUALIZE(function()
                if not (real_char and real_char.Parent and fake_char and fake_char.Parent) then return end
                if real_humanoid and real_humanoid.Parent then
                    pcall(function() real_humanoid:ChangeState(Enum.HumanoidStateType.Physics) end)
                end
                for i = 1, #partMap do
                    local entry = partMap[i]
                    local rP = entry.real
                    local fP = entry.fake
                    if rP and fP and rP.Parent and fP.Parent then
                        rP.CanCollide = false
                        rP.CFrame = fP.CFrame
                    end
                end
            end))

            -- 2. Heartbeat (PostSimulation): Apply CFrame alignment and velocity after physics simulation
            halo.connections.hb = halo.services.run_service.Heartbeat:Connect(LPH_JIT_MAX(function()
                if not (real_char and real_char.Parent and fake_char and fake_char.Parent) then
                    API.reanimate(false)
                    return
                end

                local fakeHRP = fake_char:FindFirstChild("HumanoidRootPart")
                local fHrpVel = fakeHRP and fakeHRP.AssemblyLinearVelocity or Vector3.zero
                local fHrpAngVel = fakeHRP and fakeHRP.AssemblyAngularVelocity or Vector3.zero

                for i = 1, #partMap do
                    local entry = partMap[i]
                    local pName = entry.name
                    local rP = entry.real
                    local fP = entry.fake
                    if rP and fP and rP.Parent and fP.Parent then
                        rP.Anchored = false
                        rP.CanCollide = false
                        rP.CFrame = fP.CFrame
                        local pVel = fP.AssemblyLinearVelocity or fHrpVel
                        local pAngVel = fP.AssemblyAngularVelocity or fHrpAngVel
                        local smoothVel = (pVel.Magnitude > 0.05) and pVel or Vector3.new(0, -0.01, 0)
                        rP.AssemblyLinearVelocity = smoothVel
                        rP.AssemblyAngularVelocity = pAngVel
                    end
                end
            end))

            -- 3. RenderStepped (PreRender): Synchronize local CFrame right before rendering to eliminate 100% of shift-lock and camera spin visual jitter
            halo.connections.render = halo.services.run_service.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
                if not (real_char and real_char.Parent and fake_char and fake_char.Parent) then return end
                for i = 1, #partMap do
                    local entry = partMap[i]
                    local rP = entry.real
                    local fP = entry.fake
                    if rP and fP and rP.Parent and fP.Parent then
                        rP.CFrame = fP.CFrame
                    end
                end
            end))

            halo.connections.died = real_humanoid.Died:Connect(function()
                API.reanimate(false)
            end)
            if fake_humanoid then
                halo.connections.clone_died = fake_humanoid.Died:Connect(function()
                    API.reanimate(false)
                end)
            end
            halo.connections.character_removing = player.CharacterRemoving:Connect(function()
                API.reanimate(false)
            end)

            halo.flags.reanimated = true
            return true
        else
            if not halo.flags.reanimated then return end

            for k, conn in pairs(halo.connections) do
                if conn then conn:Disconnect(); halo.connections[k] = nil; end
            end

            local fake_char = halo.clones[player]
            local real_char = halo.real_chars[player]

            -- 1. Restore joints, collision constraints, and basepart collision properties
            if real_char and real_char.Parent then
                for _, v in ipairs(real_char:GetDescendants()) do
                    if v:IsA("NoCollisionConstraint") then
                        pcall(function() v:Destroy() end)
                    elseif v:IsA("Motor6D") or v:IsA("Weld") or v:IsA("WeldConstraint") then
                        pcall(function() v.Enabled = true end)
                    elseif v:IsA("BasePart") then
                        pcall(function()
                            v.Massless = false
                            v.CanTouch = true
                            v.CanQuery = true
                            v.CustomPhysicalProperties = nil
                            v.AssemblyLinearVelocity = Vector3.zero
                            v.AssemblyAngularVelocity = Vector3.zero
                            local n = v.Name
                            if n == "HumanoidRootPart" or n == "UpperTorso" or n == "LowerTorso" or n == "Torso" or n:find("Leg") or n:find("Foot") or n == "Head" then
                                v.CanCollide = true
                            else
                                v.CanCollide = false
                            end
                        end)
                    end
                end
            end

            -- 2. Unragdoll signals to server
            local event_rag = halo.services.replicated:FindFirstChild("event_rag")
            local unragdoll_remote = halo.services.replicated:FindFirstChild("Unragdoll")
            for _ = 1, 3 do
                pcall(function()
                    if event_rag then
                        event_rag:FireServer("Hinge")
                    end
                    if unragdoll_remote then
                        unragdoll_remote:FireServer()
                    end
                end)
                task.wait(0.05)
            end

            -- 3. Restore character, humanoid state, camera subject, and position
            if real_char and real_char.Parent then
                local real_hum = real_char:FindFirstChildWhichIsA("Humanoid")
                local real_hrp = real_char:FindFirstChild("HumanoidRootPart")
                local fake_hrp = fake_char and fake_char:FindFirstChild("HumanoidRootPart")

                if real_hrp and fake_hrp then
                    real_hrp.CFrame = fake_hrp.CFrame + Vector3.new(0, 1.5, 0)
                    real_hrp.AssemblyLinearVelocity = Vector3.zero
                    real_hrp.AssemblyAngularVelocity = Vector3.zero
                end

                if real_hum then
                    pcall(function()
                        real_hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                        real_hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                        real_hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                        real_hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
                        real_hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                        real_hum:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
                        real_hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
                        real_hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
                        real_hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
                        real_hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
                        real_hum.AutoRotate = true
                        real_hum.PlatformStand = false
                        real_hum.Sit = false
                        real_hum.RequiresNeck = true
                        local defHip = real_hum:GetAttribute("HaloDefaultHipHeight")
                        real_hum.HipHeight = (defHip and defHip > 0 and defHip <= 3.5) and defHip or 2.0
                        real_hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                        real_hum:ChangeState(Enum.HumanoidStateType.Landed)
                        real_hum:ChangeState(Enum.HumanoidStateType.Running)
                    end)
                end

                local fake_animate = fake_char and fake_char:FindFirstChild("Animate")
                local real_animate = real_char:FindFirstChild("Animate")
                if fake_animate then
                    fake_animate:Destroy()
                end

                local savedResetOnSpawns = {}
                local player_gui = player:FindFirstChildWhichIsA("PlayerGui")
                if player_gui then
                    for _, gui in ipairs(player_gui:GetChildren()) do
                        if gui:IsA("ScreenGui") and gui.ResetOnSpawn then
                            table.insert(savedResetOnSpawns, gui)
                            gui.ResetOnSpawn = false
                        end
                    end
                end

                player.Character = real_char
                local camera = halo.services.workspace.CurrentCamera
                if real_hum and camera then
                    camera.CameraSubject = real_hum
                end

                for _, gui in ipairs(savedResetOnSpawns) do
                    if gui and gui.Parent then
                        gui.ResetOnSpawn = true
                    end
                end

                if real_animate then
                    task.wait(0.1)
                    real_animate.Disabled = false
                end
            end

            if fake_char and fake_char.Parent then
                fake_char:Destroy()
            end
            halo.clones[player] = nil
            halo.real_chars[player] = nil
            halo.flags.reanimated = false

            -- Clean up all action states, persistent toggles and tools
            _G._HaloRightArmPointerEnabled = false
            _G._HaloLeftArmPointerEnabled = false
            _G._HaloRightArmStretching = false
            _G._HaloLeftArmStretching = false
            _G._HaloTorsoStretcherEnabled = false
            _G._HaloLimbsTorsoCamControl = false
            _G._HaloHeadTrackerEnabled = false
            _G._HaloTrackerEnabled = false
            _G._FortniteWheelEnabled = false
            _G._HaloGhostBodyEnabled = false
            _G._HaloNoClipActive = false

            pcall(function()
                local backpack = player:FindFirstChild("Backpack")
                if backpack then
                    for _, n in ipairs({"Pole Tool", "Reach Tool", "Target Tool"}) do
                        local t = backpack:FindFirstChild(n)
                        if t then t:Destroy() end
                    end
                end
                if real_char then
                    for _, n in ipairs({"Pole Tool", "Reach Tool", "Target Tool"}) do
                        local t = real_char:FindFirstChild(n)
                        if t then t:Destroy() end
                    end
                end
            end)

            return true
        end
    end;

    API.play_animation = function(url, speed)
        local player = get_local_player();
        if typeof(player) == "string" then return player end;

        local clone = API.get_clone(player);
        if not clone then
            return "Cannot play animation, character not found.";
        end;

        if halo.animation.state.is_playing and halo.animation.state.current_url == url then
            API.stop_animation();
            return;
        end;

        API.stop_animation();

        local clone_humanoid = clone:FindFirstChildOfClass("Humanoid");
        if clone_humanoid then
            local animator = clone_humanoid:FindFirstChildOfClass("Animator");
            if animator then
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    track:Stop();
                end;
            end;
        end;

        local clone_animate_script = clone:FindFirstChild("Animate");
        if clone_animate_script then
            clone_animate_script.Enabled = false;
        end;

        local anim = halo.animation;
        anim.state.speed = tonumber(speed) or 1.0;

        local keyframe_data = anim.cache[url];
        if not keyframe_data then
            local success, response = pcall(game.HttpGet, game, url);
            if not success then return "Animation Error: Failed to fetch URL." end;

            local loaded_fn, err = loadstring(response);
            if not loaded_fn then return "Animation Error: Invalid script from URL. " .. tostring(err) end;

            local ok, data = pcall(function() return loaded_fn() end);
            if not ok then return "Animation Error: Script from URL failed to execute. " .. tostring(data) end;
            keyframe_data = data;

            if typeof(keyframe_data) ~= "table" then return "Animation Error: Script from URL did not return a table." end;

            anim.cache[url] = keyframe_data;
        end;

        local keyframes = keyframe_data[next(keyframe_data)];
        if not keyframes or #keyframes == 0 then
            return "No keyframes array found for animation URL: " .. url;
        end;

        anim.state.keyframes = keyframes;

        table.clear(anim.constraints);
        table.clear(anim.original_transforms);

        -- Build constraint lookup once per clone; reuse on every subsequent play
        if not anim.constraints_cache then
            anim.constraints_cache = {};
            anim.bind_lengths = {};
            anim.bind_transforms = {};
            for _, descendant in ipairs(clone:GetDescendants()) do
                if descendant:IsA("AnimationConstraint") then
                    local attachment = descendant.Attachment1;
                    if attachment and attachment.Parent then
                        anim.constraints_cache[attachment.Parent.Name] = descendant;
                        anim.bind_transforms[descendant] = descendant.Transform;
                        local att0 = descendant.Attachment0;
                        local att1 = descendant.Attachment1;
                        if att0 and att1 and att0.Parent and att1.Parent then
                            local len = (att1.WorldCFrame.Position - att0.WorldCFrame.Position).Magnitude;
                            if len > 0.001 then
                                anim.bind_lengths[descendant] = len;
                            end;
                        end;
                    end;
                elseif descendant:IsA("Motor6D") then
                    local childPart = descendant.Part1;
                    if childPart and childPart.Parent and not anim.constraints_cache[childPart.Name] then
                        anim.constraints_cache[childPart.Name] = descendant;
                        anim.bind_transforms[descendant] = descendant.Transform;
                    end;
                end;
            end;
        end;
        for partName, constraint in pairs(anim.constraints_cache) do
            if constraint and constraint.Parent then
                anim.constraints[partName] = constraint;
                anim.original_transforms[constraint] = anim.bind_transforms[constraint] or constraint.Transform;
            end;
        end;

        anim.state.is_playing = true;
        anim.state.current_url = url;
        anim.state.total_duration = keyframes[#keyframes].Time;
        if anim.state.total_duration <= 0 then API.stop_animation(); return end;

        anim.state.elapsed_time = 0;

        if halo.callbacks.on_play then
            pcall(halo.callbacks.on_play, anim.state.current_url);
        end;

        local last_index = 1
        halo.connections.animation_hb = halo.services.run_service.PreSimulation:Connect(LPH_NO_VIRTUALIZE(function(deltaTime)
            if not anim.state.is_playing then return end;

            local animator = get_animator(clone);
            if animator and animator.EvaluationThrottled then return end;

            anim.state.elapsed_time = (anim.state.elapsed_time + (deltaTime * anim.state.speed)) % anim.state.total_duration;

            local keyframes = anim.state.keyframes
            local elapsed = anim.state.elapsed_time
            local num_keyframes = #keyframes
            local current_frame, next_frame;

            if not last_index or last_index >= num_keyframes then
                last_index = 1
            end

            if elapsed >= keyframes[last_index].Time and (last_index == num_keyframes or elapsed < keyframes[last_index + 1].Time) then
                current_frame = keyframes[last_index]
                next_frame = keyframes[last_index == num_keyframes and 1 or last_index + 1]
            elseif last_index < num_keyframes and elapsed >= keyframes[last_index + 1].Time and (last_index + 1 == num_keyframes or elapsed < keyframes[last_index + 2].Time) then
                last_index = last_index + 1
                current_frame = keyframes[last_index]
                next_frame = keyframes[last_index == num_keyframes and 1 or last_index + 1]
            else
                local low = 1
                local high = num_keyframes - 1
                local found = 1
                while low <= high do
                    local mid = math.floor((low + high) / 2)
                    if elapsed >= keyframes[mid].Time then
                        found = mid
                        low = mid + 1
                    else
                        high = mid - 1
                    end
                end
                last_index = found
                current_frame = keyframes[last_index]
                next_frame = keyframes[last_index == num_keyframes and 1 or last_index + 1]
            end

            if not current_frame then
                current_frame = keyframes[num_keyframes];
                next_frame = keyframes[1];
            end;

            local frame_duration = next_frame.Time - current_frame.Time;
            if frame_duration <= 0 then frame_duration = anim.state.total_duration end;

            local alpha = (frame_duration > 0) and (anim.state.elapsed_time - current_frame.Time) / frame_duration or 0;
            alpha = math.clamp(alpha, 0, 1);

            for partName, pose_cframe in pairs(current_frame.Data) do
                local constraint = anim.constraints[partName];
                if constraint and constraint.Parent and anim.original_transforms[constraint] then
                    local next_pose_cframe = next_frame.Data and next_frame.Data[partName];
                    local interpolated_transform;
                    if next_pose_cframe then
                        interpolated_transform = pose_cframe:Lerp(next_pose_cframe, alpha);
                    else
                        interpolated_transform = pose_cframe;
                    end;
                    constraint.Transform = interpolated_transform;
                end;
            end;

            -- Fun head modes (spin / stare) take priority over camera head tracker
            if _G._HaloSpinHeadEnabled or _G._HaloStareEnabled or _G._HaloLookBehindEnabled
                or _G._HaloNodLoopEnabled or _G._HaloHeadTiltEnabled or _G._HaloCraneNeckEnabled then
                -- handled by fun tracking PreSimulation loop
            elseif _G._HaloHeadTrackerEnabled then
                local headConstraint = anim.constraints["Head"];
                if headConstraint then
                    local camera = workspace.CurrentCamera;
                    if camera then
                        local parentWorldCF = nil;
                        if headConstraint:IsA("Motor6D") and headConstraint.Part0 then
                            parentWorldCF = headConstraint.Part0.CFrame * headConstraint.C0;
                        else
                            local att0 = headConstraint.Attachment0;
                            if att0 and att0.Parent then
                                parentWorldCF = att0.WorldCFrame;
                            end;
                        end;
                        if parentWorldCF then
                            local bindTransform = anim.original_transforms[headConstraint];
                            if bindTransform then
                                local camLook = camera.CFrame.LookVector;
                                local localLookDir = parentWorldCF.Rotation:Inverse() * camLook;

                                -- Extract yaw & pitch and clamp to realistic neck limits
                                local yaw = math.atan2(localLookDir.X, -localLookDir.Z);
                                local pitch = math.asin(math.clamp(localLookDir.Y, -1, 1));
                                if not _G._HaloHeadTracker360 then
                                    local maxYaw = math.rad(75);
                                    local maxPitch = math.rad(55);
                                    yaw = math.clamp(yaw, -maxYaw, maxYaw);
                                    pitch = math.clamp(pitch, -maxPitch, maxPitch);
                                end

                                -- Rebuild clamped local look direction
                                local clampedDir = Vector3.new(
                                    math.sin(yaw) * math.cos(pitch),
                                    math.sin(pitch),
                                    -math.cos(yaw) * math.cos(pitch)
                                ).Unit;

                                -- Compute target rotation from bind pose to clamped direction
                                local bindDir = bindTransform.LookVector;
                                local rotAxis = bindDir:Cross(clampedDir);
                                local targetTransform;
                                if rotAxis.Magnitude > 0.001 then
                                    rotAxis = rotAxis.Unit;
                                    local angle = math.acos(math.clamp(bindDir:Dot(clampedDir), -1, 1));
                                    targetTransform = CFrame.fromAxisAngle(rotAxis, angle) * bindTransform;
                                elseif bindDir:Dot(clampedDir) < 0 then
                                    local perp = bindDir:Cross(Vector3.new(0, 1, 0));
                                    if perp.Magnitude < 0.001 then
                                        perp = bindDir:Cross(Vector3.new(1, 0, 0));
                                    end;
                                    targetTransform = CFrame.fromAxisAngle(perp.Unit, math.pi) * bindTransform;
                                else
                                    targetTransform = bindTransform;
                                end;

                                -- Smooth interpolation so it feels like a real neck turning
                                local smoothed = _G._HaloHeadTrackerSmoothedCF or bindTransform;
                                smoothed = smoothed:Lerp(targetTransform, 0.15);
                                _G._HaloHeadTrackerSmoothedCF = smoothed;
                                headConstraint.Transform = smoothed;
                            end;
                        end;
                    end;
                end;
            end;

            -- Arm Pointer: straight arm pointing at mouse target
            -- When enabled: shoulder rotates toward cursor, elbow/wrist are locked
            -- ============================================
            -- LIMBS: Arm Pointer, Arm Stretching & Reach
            -- ============================================
            local stretchAmt = _G._HaloArmStretchAmount or 2.5
            local function stretchArmOnly(lowerName, handName, stretchMult)
                if not stretchMult or stretchMult == 1.0 then return end
                local lower = anim.constraints[lowerName]
                local offset = CFrame.new(0, -(stretchMult - 1.0) * 1.2, 0)
                if lower then lower.Transform = offset * lower.Transform end
            end

            local function pointArm(upperName, lowerName, handName, stretchMult, customTargetPos)
                local shoulderConstraint = anim.constraints[upperName]
                if not shoulderConstraint then return end

                local isLeft = upperName:find("Left") ~= nil
                local resetFlag = isLeft and _G._HaloLeftArmPointerNeedsReset or _G._HaloRightArmPointerNeedsReset
                if resetFlag then
                    local orig = anim.original_transforms[shoulderConstraint]
                    if orig then shoulderConstraint.Transform = orig end
                    local elbowConstraint = anim.constraints[lowerName]
                    if elbowConstraint then elbowConstraint.Transform = CFrame.new() end
                    local wristConstraint = anim.constraints[handName]
                    if wristConstraint then wristConstraint.Transform = CFrame.new() end
                    if isLeft then _G._HaloLeftArmPointerNeedsReset = false
                    else _G._HaloRightArmPointerNeedsReset = false end
                end

                local shoulderWorldCF = nil
                if shoulderConstraint:IsA("Motor6D") and shoulderConstraint.Part0 then
                    shoulderWorldCF = shoulderConstraint.Part0.CFrame * shoulderConstraint.C0
                else
                    local att0 = shoulderConstraint.Attachment0
                    if att0 and att0.Parent then
                        shoulderWorldCF = att0.WorldCFrame
                    end
                end
                if not shoulderWorldCF then return end

                local shoulderPos = shoulderWorldCF.Position
                local aimTarget = customTargetPos
                if not aimTarget then
                    local camera = workspace.CurrentCamera
                    local mouse = plr:GetMouse()
                    if camera and mouse then
                        local unitRay = camera:ViewportPointToRay(mouse.X, mouse.Y)
                        local rayParams = RaycastParams.new()
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                        local filterList = {}
                        pcall(function()
                            if ReanimateAPI.get_clone then
                                local clone = ReanimateAPI.get_clone(plr)
                                if clone then table.insert(filterList, clone) end
                            end
                            if ReanimateAPI.get_real_character then
                                local real = ReanimateAPI.get_real_character(plr)
                                if real then table.insert(filterList, real) end
                            end
                        end)
                        rayParams.FilterDescendantsInstances = filterList
                        local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, rayParams)
                        aimTarget = result and result.Position or (unitRay.Origin + unitRay.Direction * 1000)
                    end
                end
                if not aimTarget then return end

                local aimDir = (aimTarget - shoulderPos)
                if aimDir.Magnitude <= 0.001 then return end
                aimDir = aimDir.Unit

                local bindTransform = shoulderConstraint.Transform
                if not bindTransform then return end

                local childBoneDir = Vector3.new(0, -1, 0)
                local bindBoneDir = (bindTransform.Rotation * childBoneDir).Unit
                local localAimDir = shoulderWorldCF.Rotation:Inverse() * aimDir

                local rotAxis = bindBoneDir:Cross(localAimDir)
                local shoulderResult
                if rotAxis.Magnitude > 0.001 then
                    rotAxis = rotAxis.Unit
                    local angle = math.acos(math.clamp(bindBoneDir:Dot(localAimDir), -1, 1))
                    local rotationCF = CFrame.fromAxisAngle(rotAxis, angle)
                    shoulderResult = rotationCF * bindTransform
                elseif bindBoneDir:Dot(localAimDir) < 0 then
                    local perp = bindBoneDir:Cross(Vector3.new(0, 1, 0))
                    if perp.Magnitude < 0.001 then perp = bindBoneDir:Cross(Vector3.new(1, 0, 0)) end
                    shoulderResult = CFrame.fromAxisAngle(perp.Unit, math.pi) * bindTransform
                else
                    shoulderResult = bindTransform
                end

                shoulderConstraint.Transform = shoulderResult

                local elbowConstraint = anim.constraints[lowerName]
                if elbowConstraint then elbowConstraint.Transform = CFrame.new() end
                local wristConstraint = anim.constraints[handName]
                if wristConstraint then wristConstraint.Transform = CFrame.new() end

                stretchMult = stretchMult or 1.0
                if stretchMult ~= 1.0 then
                    local c = anim.constraints[lowerName]
                    if c then
                        local baseLen = anim.bind_lengths and anim.bind_lengths[c]
                        if not baseLen or baseLen < 0.001 then
                            if c:IsA("Motor6D") and c.Part1 and c.Part1:IsA("BasePart") then
                                baseLen = c.Part1.Size.Y
                            else
                                local att1 = c and c.Attachment1
                                if att1 and att1.Parent and att1.Parent:IsA("BasePart") then
                                    baseLen = att1.Parent.Size.Y
                                else
                                    baseLen = 1.2
                                end
                            end
                        end
                        local boneDir = Vector3.new(0, -1, 0)
                        local stretchOffset = boneDir * baseLen * (stretchMult - 1.0)
                        c.Transform = CFrame.new(stretchOffset)
                    end
                end
            end

            -- 1. Arm Pointers
            if _G._HaloRightArmPointerEnabled then
                local isStretching = _G._HaloRightArmStretching or false
                pointArm("RightUpperArm", "RightLowerArm", "RightHand", isStretching and stretchAmt or 1.0)
            elseif not _G._HaloLeftArmPointerEnabled and not _G._HaloRightArmPointerEnabled and _G._HaloRightArmStretching and stretchAmt ~= 1.0 then
                stretchArmOnly("RightLowerArm", "RightHand", stretchAmt)
            end

            if _G._HaloLeftArmPointerEnabled then
                local isStretching = _G._HaloLeftArmStretching or false
                pointArm("LeftUpperArm", "LeftLowerArm", "LeftHand", isStretching and stretchAmt or 1.0)
            elseif not _G._HaloRightArmPointerEnabled and not _G._HaloLeftArmPointerEnabled and _G._HaloLeftArmStretching and stretchAmt ~= 1.0 then
                stretchArmOnly("LeftLowerArm", "LeftHand", stretchAmt)
            end

            -- ============================================
            -- ARM SLIDER: Upper arm welded to hip, stretch controls angle
            -- ============================================
            -- Unweld / restore original transforms when toggled off
            if not _G._HaloArmSliderEnabled and _G._HaloArmSliderPrevEnabled then
                _G._HaloArmSliderPrevEnabled = false
                for constraint, orig in pairs(_G._HaloArmSliderOriginalTransforms) do
                    if constraint and constraint.Parent then
                        pcall(function() constraint.Transform = orig end)
                    end
                end
                _G._HaloArmSliderOriginalTransforms = {}
            end
            if _G._HaloArmSliderEnabled then
                _G._HaloArmSliderPrevEnabled = true
                local offsetX = _G._HaloArmSliderOffsetX or 0
                local offsetY = _G._HaloArmSliderOffsetY or 0
                local stretch = _G._HaloArmSliderStretch or 1.0
                local rotEnabled = _G._HaloArmSliderRotationEnabled or false
                local rotDeg = _G._HaloArmSliderRotation or 0

                local rUpper = anim.constraints["RightUpperArm"] or _HaloFindConstraintOnClone(clone, "RightUpperArm")
                local rLower = anim.constraints["RightLowerArm"] or _HaloFindConstraintOnClone(clone, "RightLowerArm")
                local rHand = anim.constraints["RightHand"] or _HaloFindConstraintOnClone(clone, "RightHand")
                local hipJoint = anim.constraints["LowerTorso"] or anim.constraints["Waist"] or anim.constraints["Torso"]
                    or _HaloFindConstraintOnClone(clone, "LowerTorso") or _HaloFindConstraintOnClone(clone, "Waist")
                    or _HaloFindConstraintOnClone(clone, "Root") or _HaloFindConstraintOnClone(clone, "Torso")

                if rUpper and hipJoint then
                    -- Get the hip's live world CFrame (position + rotation)
                    local hipWorldCF
                    if hipJoint:IsA("Motor6D") then
                        if hipJoint.Part0 then
                            hipWorldCF = hipJoint.Part0.CFrame * hipJoint.C0
                        elseif hipJoint.Part1 then
                            hipWorldCF = hipJoint.Part1.CFrame * hipJoint.C1
                        end
                    else
                        local att0 = hipJoint.Attachment0
                        if att0 and att0.Parent then
                            hipWorldCF = att0.WorldCFrame
                        end
                    end

                    if hipWorldCF then
                        -- Target position: offset from hip in hip-local space
                        local targetPos = hipWorldCF.Position 
                            + hipWorldCF.RightVector * (0.3 + offsetX)
                            + hipWorldCF.UpVector * (0.2 + offsetY)
                            + hipWorldCF.LookVector * 0.25

                        -- Stretch controls base angle:
                        -- stretch 1.0 = -45 deg (pointing down)
                        -- stretch 10.0 = +85 deg (pointing up, capped)
                        local stretchAngleDeg = -45 + (stretch - 1) * (130 / 9)
                        stretchAngleDeg = math.clamp(stretchAngleDeg, -45, 85)

                        -- Rotation slider adds independent tilt
                        local totalAngleDeg = stretchAngleDeg
                        if rotEnabled then
                            totalAngleDeg = totalAngleDeg + rotDeg
                        end
                        local totalAngleRad = math.rad(totalAngleDeg)

                        -- Swing arm around shoulder (RightVector axis)
                        -- stretch 1.0 = down/back (image 1), stretch 10.0 = forward/up (image 2)
                        local t = math.clamp((stretch - 1) / 9, 0, 1)
                        local minAngle = math.rad(-15)     -- down/back
                        local maxAngle = math.rad(-135)    -- forward/up
                        local swingAngle = minAngle + t * (maxAngle - minAngle)

                        local armDir = (
                            -hipWorldCF.UpVector * math.cos(swingAngle)
                            - hipWorldCF.LookVector * math.sin(swingAngle)
                            + hipWorldCF.RightVector * 0.15
                        ).Unit

                        -- Build desired upper-arm world CFrame
                        -- RightVector = shoulder hinge axis (prevents twist/spin)
                        local yAxis = -armDir
                        local xAxis = hipWorldCF.RightVector
                        local zAxis = xAxis:Cross(yAxis).Unit
                        local desiredCF = CFrame.fromMatrix(targetPos, xAxis, yAxis)

                        -- Save original transforms before modifying (for unweld on toggle off)
                        if not _G._HaloArmSliderOriginalTransforms[rUpper] then
                            pcall(function()
                                _G._HaloArmSliderOriginalTransforms[rUpper] = rUpper.Transform
                            end)
                        end
                        if rLower and not _G._HaloArmSliderOriginalTransforms[rLower] then
                            pcall(function()
                                _G._HaloArmSliderOriginalTransforms[rLower] = rLower.Transform
                            end)
                        end
                        if rHand and not _G._HaloArmSliderOriginalTransforms[rHand] then
                            pcall(function()
                                _G._HaloArmSliderOriginalTransforms[rHand] = rHand.Transform
                            end)
                        end

                        -- Convert desired world CFrame into shoulder Transform
                        if rUpper:IsA("Motor6D") and rUpper.Part0 and rUpper.Part1 then
                            local part0CF = rUpper.Part0.CFrame
                            local c0 = rUpper.C0
                            local c1 = rUpper.C1
                            rUpper.Transform = c0:Inverse() * part0CF:Inverse() * desiredCF * c1
                        else
                            local att0 = rUpper.Attachment0
                            local att1 = rUpper.Attachment1
                            if att0 and att1 then
                                local desiredAtt1World = desiredCF * att1.CFrame
                                rUpper.Transform = att0.WorldCFrame:Inverse() * desiredAtt1World
                            end
                        end
                    end
                end

                if rLower then
                    local baseLen = anim.bind_lengths and anim.bind_lengths[rLower]
                    if not baseLen or baseLen < 0.001 then
                        if rLower:IsA("Motor6D") and rLower.Part1 and rLower.Part1:IsA("BasePart") then
                            baseLen = rLower.Part1.Size.Y
                        else
                            local att1 = rLower and rLower.Attachment1
                            if att1 and att1.Parent and att1.Parent:IsA("BasePart") then
                                baseLen = att1.Parent.Size.Y
                            else
                                baseLen = 1.2
                            end
                        end
                    end
                    if stretch ~= 1.0 then
                        local stretchOffset = Vector3.new(0, -baseLen * (stretch - 1.0), 0)
                        rLower.Transform = CFrame.new(stretchOffset)
                    else
                        rLower.Transform = CFrame.new()
                    end
                end

                if rHand then
                    rHand.Transform = CFrame.new()
                end
            end

            -- ============================================
            -- LIMBS: UpperTorso Height + Torso Camera
            -- ============================================
            if _G._HaloLimbsTorsoCamControl or _G._HaloTorsoStretcherEnabled then
                local waistConstraint = anim.constraints["Waist"] or anim.constraints["UpperTorso"]
                if waistConstraint then
                    local baseRot = waistConstraint.Transform.Rotation

                    -- Torso Camera Control: lean and turn with camera look direction
                    if _G._HaloLimbsTorsoCamControl then
                        local camera = workspace.CurrentCamera
                        if camera then
                            local parentWorldCF = nil
                            if waistConstraint:IsA("Motor6D") and waistConstraint.Part0 then
                                parentWorldCF = waistConstraint.Part0.CFrame * waistConstraint.C0
                            else
                                local att0 = waistConstraint.Attachment0
                                if att0 and att0.Parent then
                                    parentWorldCF = att0.WorldCFrame
                                end
                            end

                            if parentWorldCF then
                                local camLook = camera.CFrame.LookVector
                                local localLookDir = parentWorldCF.Rotation:Inverse() * camLook
                                local yaw = math.atan2(localLookDir.X, -localLookDir.Z)
                                local pitch = math.asin(math.clamp(localLookDir.Y, -1, 1))

                                local camMode = _G._HaloLimbsTorsoCamMode or "360"
                                local camRotCF
                                if camMode == "Locked" then
                                    yaw = math.clamp(yaw, -math.rad(45), math.rad(45))
                                    pitch = math.clamp(pitch, -math.rad(30), math.rad(30))
                                    camRotCF = CFrame.fromEulerAnglesYXZ(pitch, -yaw, 0)
                                elseif camMode == "Free" then
                                    camRotCF = parentWorldCF.Rotation:Inverse() * camera.CFrame.Rotation
                                else
                                    local fullPitch = pitch * 2.25
                                    camRotCF = CFrame.fromEulerAnglesYXZ(fullPitch, -yaw, 0)
                                end

                                local smoothed = _G._HaloTorsoCamSmoothedCF or camRotCF
                                smoothed = smoothed:Lerp(camRotCF, 0.25)
                                _G._HaloTorsoCamSmoothedCF = smoothed
                                baseRot = smoothed * baseRot
                            end
                        end
                    else
                        _G._HaloTorsoCamSmoothedCF = nil
                    end

                    -- UpperTorso Height offset (Torso Stretcher)
                    local utHeight = _G._HaloLimbsUpperTorsoHeight or 1.0
                    local stretchY = _G._HaloTorsoStretcherEnabled and ((utHeight - 1.0) * 2.5) or 0
                    if stretchY ~= 0 then
                        waistConstraint.Transform = CFrame.new(0, stretchY, 0) * baseRot
                    else
                        waistConstraint.Transform = baseRot
                    end
                end
            end

            -- ============================================
            -- LIMBS: Leg Stretcher
            -- ============================================
            if _G._HaloLegStretcherEnabled then
                local legScale = math.clamp(_G._HaloLimbsLegHeight or 1.0, 0.4, 100.0)
                if legScale ~= 1.0 then
                    local kneeOffset = CFrame.new(0, -(legScale - 1.0) * 1.5, 0)
                    local rll = anim.constraints["RightLowerLeg"]
                    local lll = anim.constraints["LeftLowerLeg"]
                    if rll then rll.Transform = kneeOffset * rll.Transform end
                    if lll then lll.Transform = kneeOffset * lll.Transform end
                end
                local h = anim.humanoid or (anim.rig and anim.rig:FindFirstChildOfClass("Humanoid"))
                if h then
                    local defHip = h:GetAttribute("HaloDefaultHipHeight")
                    if not defHip then
                        defHip = (h.HipHeight > 0) and h.HipHeight or 2.0
                        h:SetAttribute("HaloDefaultHipHeight", defHip)
                    end
                    h.HipHeight = defHip + math.max(0, (legScale - 1.0) * 1.5)
                end
            end
        end))
    end;

    API.set_animation_speed = function(speed)
        halo.animation.state.speed = tonumber(speed) or 1.0;
    end;

    API.on_animation_play = function(callback)
        if type(callback) == "function" then
            halo.callbacks.on_play = callback;
        end;
    end;

    API.on_animation_stop = function(callback)
        if type(callback) == "function" then
            halo.callbacks.on_stop = callback;
        end;
    end;

    API.is_animation_playing = function()
        return halo.animation.state.is_playing, halo.animation.state.current_url;
    end;

    API.is_reanimated = function()
        return halo.flags.reanimated;
    end;

    API.get_clone = function(player)
        player = player or get_local_player();
        if typeof(player) == "string" then return nil end;
        return halo.clones[player] or player.Character;
    end;

    API.get_real_character = function(player)
        player = player or get_local_player();
        if typeof(player) == "string" then return nil end;
        return halo.real_chars[player] or player.Character;
    end;

    API.get_animation_data = function()
        return halo.animation;
    end;

    API.seed_animation_cache = function(name, keyframe_data)
        if name then
            halo.animation.cache[name] = keyframe_data;
        end;
    end;

    API.get_animation_cache = function(name)
        return name and halo.animation.cache[name] or nil;
    end;

    API.invalidate_constraint_cache = function()
        halo.animation.constraints_cache = nil;
        halo.animation.bind_transforms = nil;
        table.clear(halo.animation.constraints);
        table.clear(halo.animation.original_transforms);
    end;

    API.rebuild_clone = function()
        API.stop_animation();
        halo.animation.constraints_cache = nil;
        halo.animation.bind_transforms = nil;
        table.clear(halo.animation.constraints);
        table.clear(halo.animation.original_transforms);
    end;

    ReanimateAPI = API;
    _G._HaloReanimateAPI = API;
end
_reanimAPIReady = true

-- Helper: find a constraint directly from a character rig when the animation
-- cache hasn't been populated yet (e.g. no custom emote is playing).
local function _HaloFindConstraintOnClone(clone, partName)
    if not clone then return nil end
    -- Fast path: direct descendant search by name
    local fast = clone:FindFirstChild(partName, true)
    if fast and (fast:IsA("Motor6D") or fast:IsA("AnimationConstraint") or fast:IsA("Motor")) then
        return fast
    end
    -- Deep scan for joints whose Part1 or Attachment1.Parent matches partName
    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("Motor6D") or d:IsA("Motor") then
            if d.Name == partName then return d end
            if d.Part1 and d.Part1.Name == partName then return d end
        elseif d:IsA("AnimationConstraint") then
            if d.Name == partName then return d end
            local att1 = d.Attachment1
            if att1 and att1.Parent and att1.Parent.Name == partName then return d end
        end
    end
    return nil
end



local CONFIG = {
    -- Basic Settings
    TITLE          = "NØIR Reanim",
    VERSION        = "1.0.0",
    ANIMATIONS_URL = "",
    FOLDER         = "ReanimData",
    CACHE_FOLDER   = "ReanimData/cache",
    
    -- Icon Asset IDs (Easy to change!)
    ICONS = {
        STAR_FILLED    = "rbxthumb://type=Asset&id=127142872239507&w=150&h=150",  -- Favorited star icon
        STAR_OUTLINE   = "rbxthumb://type=Asset&id=76957491777613&w=150&h=150",   -- Not favorited star icon
        KEYBOARD       = "rbxthumb://type=Asset&id=78118938629142&w=150&h=150",   -- Keyboard icon for unbound keys
        RESIZE_HANDLE  = "rbxassetid://90832689936120",
    },
    
    -- UI Customization (Optional - you can also edit these!)
    UI = {
        DEFAULT_WIDTH  = 380,   -- Default window width (new unified layout)
        DEFAULT_HEIGHT = 540,   -- Default window height
        MIN_WIDTH      = 300,   -- Minimum window width when resizing
        MIN_HEIGHT     = 360,   -- Minimum window height when resizing
    }
}


-- Compatibility helpers for executor environments missing these globals
local function getSafeScrollingDirection(dir)
    local ok, result = pcall(function() return Enum.ScrollingDirection[dir] end)
    if ok then return result end
    return Enum.ScrollingDirection.Y
end

local function getSafeAutomaticSize()
    local ok, result = pcall(function() return Enum.AutomaticSize.Y end)
    if ok then return result end
    return nil
end


-- Clear reanimation cache on startup
pcall(function()
    local deleteFunc = delfile or delete_file
    local listFilesFunc = listfiles or list_files
    
    if deleteFunc and listFilesFunc then
        -- Clear the cache folder completely
        local okCache, cacheFiles = pcall(function()
            if listFilesFunc then return listFilesFunc("ReanimData/cache") end
            return {}
        end)
        
        if okCache and cacheFiles then
            for _, filePath in ipairs(cacheFiles) do
                pcall(deleteFunc, filePath)
            end
        end
    end
end)

pcall(function() makefolder(CONFIG.FOLDER) end)
pcall(function() makefolder(CONFIG.CACHE_FOLDER) end)

function GetCachePath(animName)
    local safeName = animName:gsub("[^%%w%%-_%%. ]", "_")
    return CONFIG.CACHE_FOLDER .. "/" .. safeName .. ".cache"
end

local SoundService = game:GetService("SoundService")

local State = {
    isReanimated   = false,
    currentSpeed   = 1.0,
    stateSpeed     = 1.0,
    selectedAnim   = nil,
    rawAnimPlaying = false,
    currentTab     = "All",
}

local rawAnimCache = _G._HaloRawAnimCache or {}
_G._HaloRawAnimCache = rawAnimCache
_G._ReanimRawAnimCache = rawAnimCache

local serializeAnimData = LPH_NO_VIRTUALIZE(function(data)
    local out = {}
    for animKey, frames in pairs(data) do
        local frameArr = {}
        for i, frame in ipairs(frames) do
            local boneData = {}
            for boneName, cf in pairs(frame.Data) do
                boneData[boneName] = {cf:GetComponents()}
            end
            frameArr[i] = { Time = frame.Time, Data = boneData }
        end
        out[animKey] = frameArr
    end
    return out
end)

local deserializeAnimData = LPH_NO_VIRTUALIZE(function(jsonData)
    local out = {}
    for animKey, frames in pairs(jsonData) do
        local frameArr = {}
        for i, frame in ipairs(frames) do
            local boneData = {}
            for boneName, nums in pairs(frame.Data) do
                boneData[boneName] = CFrame.new(table.unpack(nums))
            end
            frameArr[i] = { Time = frame.Time, Data = boneData }
        end
        out[animKey] = frameArr
    end
    return out
end)
_G._ReanimDeserializeAnimData = deserializeAnimData

local _customAnimsLoaded = false
local presetList = {}

local AnimationList = {}
local animationListCacheFile = CONFIG.FOLDER .. "/animation_list_cache.json"

-- Load cached animations if available
pcall(function()
    if isfile and isfile(animationListCacheFile) then
        local data = readfile(animationListCacheFile)
        local decoded = HttpService:JSONDecode(data)
        if decoded and type(decoded.animations) == "table" then
            for name, url in pairs(decoded.animations) do
                local cleanName = name:gsub("%.lua$", "")
                AnimationList[cleanName] = url
                AnimationList[name] = url
            end
        end
    end
end)
_G._ReanimAnimationList = AnimationList

-- Fetch animation list from onyxv2.lol in background
local _fetchingOnlineAnims = false
local function fetchOnlineAnimations()
    if _fetchingOnlineAnims then return end
    _fetchingOnlineAnims = true
    task.spawn(function()
        local ok, res = pcall(game.HttpGet, game, "https://onyxv2.lol/Animations.lua", true)
        if ok and res and res ~= "" then
            local loadOk, animTable = pcall(loadstring(res))
            if loadOk and type(animTable) == "table" then
                for name, url in pairs(animTable) do
                    local cleanName = name:gsub("%.lua$", "")
                    AnimationList[cleanName] = url
                    AnimationList[name] = url
                end
                _G._ReanimAnimationList = AnimationList
                pcall(function()
                    writefile(animationListCacheFile, HttpService:JSONEncode({
                        animations = animTable,
                        timestamp = os.time()
                    }))
                end)
                if RebuildVisible then
                    pcall(RebuildVisible)
                elseif _G._HaloRebuildVisible then
                    pcall(_G._HaloRebuildVisible)
                end
            end
        end
        _fetchingOnlineAnims = false
    end)
end
task.spawn(fetchOnlineAnimations)
local Favorites          = {}
local Keybinds           = {}
local SpeedKeybinds      = {}
local ReverseSpeedKeybinds = {}
_G._HaloListeningSpeedIdx  = nil
_G._HaloListeningRevSpeedIdx = nil
local speedKeyWidgets    = {}
local revSpeedKeyWidgets = {}
local linkRevToNormal    = false
local CustomAnims        = {}
_G._ReanimCustomAnims = CustomAnims
local CustomAnimations     = {}
_G._ReanimCustomAnimations = CustomAnimations
local AnimationCache       = {}
local StateAnims         = {}

function request_get(url)
    local req = (type(request) == "function" and request) or (type(http_request) == "function" and http_request) or (type(syn) == "table" and type(syn.request) == "function" and syn.request) or (type(http) == "table" and type(http.request) == "function" and http.request)
    if req then
        local ok, res = pcall(req, {
            Url = url,
            Method = "GET",
            Headers = {
                ["User-Agent"] = "Roblox"
            },
            Timeout = 4
        })
        if ok and res and res.StatusCode == 200 then
            return res.Body
        end
    end
    local ok, res = pcall(function()
        return game:HttpGet(url, true)
    end)
    if ok and res and res ~= "" then
        return res
    end
    return nil
end

local FOLDER = "ReanimData"
pcall(function() makefolder(FOLDER) end)

function fpath(name) return FOLDER .. "/" .. name end

function parseLargeCustomFile(content)
    local anims = {}
    local pos = 1
    local len = #content
    while pos <= len do
        local entryPos = content:find("{%s*name%s*=", pos)
        if not entryPos then break end
        local advanced = false
        repeat
            local _, nameEnd, name = content:find('name%s*=%s*"(.-)"', entryPos)
            if not name then advanced = true; break end
            local _, _, rawStr = content:find('raw%s*=%s*(true)', nameEnd)
            local isRaw = rawStr == "true"
            local urlPos = content:find("url%s*=%s*%[", nameEnd)
            if not urlPos then advanced = true; break end
            local bracketOpen = content:find("%[", urlPos)
            if not bracketOpen then advanced = true; break end
            local eqCount = 0
            local p = bracketOpen + 1
            while content:sub(p, p) == "=" do eqCount = eqCount + 1; p = p + 1 end
            local urlStart = p + 1
            local closePattern = "%]" .. string.rep("=", eqCount) .. "%]"
            local closeS, closeE = content:find(closePattern, urlStart, true)
            if not closeS then advanced = true; break end
            local url = content:sub(urlStart, closeS - 1)
            table.insert(anims, { name = name, url = url, raw = isRaw })
            pos = closeE + 1; advanced = true
        until true
        if not advanced or pos <= entryPos then pos = entryPos + 1 end
    end
    return anims
end

local _SAVE_INLINE_MAX = 4000 -- animations larger than this are stored in their own .dat file (keeps the JSON index tiny so saving never freezes)
local _saveCustomAnimsPending = false
function SaveCustomAnims()
    _G._ReanimSaveCustomAnims = SaveCustomAnims
    if not _customAnimsLoaded then return end
    _G._ReanimCustomAnims = CustomAnims
    -- Debounce: if a save is already queued, don't queue another
    if _saveCustomAnimsPending then return end
    _saveCustomAnimsPending = true
    task.delay(0.5, function()
        _saveCustomAnimsPending = false
        task.spawn(function()
            pcall(function()
                local dataToSave = {}
                local _saveFrameStart = os.clock()
                for i, ca in ipairs(CustomAnims) do
                    local content = ca.url or ""
                    -- Already stored in one of our .dat files? Just reference it.
                    -- Never re-read or re-write it — doing that on every save (and
                    -- delete triggers a save) was the freeze.
                    local isOurFile = type(content) == "string"
                        and not content:match("^https?://")
                        and content:match("%.dat$") ~= nil
                    if isOurFile then
                        table.insert(dataToSave, {
                            name = ca.name, file = content,
                            raw = ca.raw ~= false, isJson = ca.isJson or nil
                        })
                    elseif type(content) == "string" and #content > _SAVE_INLINE_MAX then
                        -- Large inline content: externalize ONCE to a .dat file and
                        -- switch the live entry to the file ref so future saves are
                        -- cheap and never JSON-encode the big string again.
                        local safeFileName = fpath("custom_" .. ca.name:gsub("[^%w_%-]", "_") .. ".dat")
                        pcall(function() writefile(safeFileName, content) end)
                        ca.url = safeFileName
                        CustomAnimations[ca.name] = safeFileName
                        table.insert(dataToSave, {
                            name = ca.name, file = safeFileName,
                            raw = ca.raw ~= false, isJson = ca.isJson or nil
                        })
                    else
                        table.insert(dataToSave, {
                            name = ca.name, url = content,
                            raw = ca.raw ~= false, isJson = ca.isJson or nil
                        })
                    end
                    -- Yield periodically so externalizing many large animations
                    -- (e.g. a big AK import) never blocks a frame.
                    if os.clock() - _saveFrameStart >= 0.004 then
                        task.wait()
                        _saveFrameStart = os.clock()
                    end
                end
                writefile(fpath("ReanimCustomAnims.json"), HttpService:JSONEncode(dataToSave))
            end)
        end)
    end)
end

-- Helper functions for parsing JSON and table animations are defined at the top of the file.

local function autoImportAKFiles()
    if not readfile then return end
    
    -- Check if auto-import has already been done
    local autoImportFlag = fpath("ReanimAutoImportDone.txt")
    local hasAutoImported = false
    pcall(function()
        if isfile and isfile(autoImportFlag) then
            hasAutoImported = true
        elseif not isfile then
            local ok, content = pcall(readfile, autoImportFlag)
            if ok then hasAutoImported = true end
        end
    end)
    
    -- Skip auto-import if already done once
    if hasAutoImported then
        return
    end
    
    pcall(function()
        local pathsToCheck = {
            " custom_animations.json",
            "custom_animations.json",
            "workspace/ custom_animations.json",
            "workspace/custom_animations.json",
            "ak/custom_animations.json",
            "ak/ custom_animations.json",
            "../workspace/ custom_animations.json",
            "../workspace/custom_animations.json"
        }
        local raw = nil
        for _, path in ipairs(pathsToCheck) do
            local ok, content
            if isfile then
                local isF = false
                pcall(function() isF = isfile(path) end)
                if isF then ok, content = pcall(readfile, path) end
            else
                ok, content = pcall(readfile, path)
            end
            if ok and content and content ~= "" then
                raw = content
                break
            end
        end
        
        if raw then
            local cleaned = raw:gsub("^\xEF\xBB\xBF", ""):gsub("\r\n", "\n"):gsub("\r", "\n")
            local ok2, data = pcall(function() return HttpService:JSONDecode(cleaned) end)
            if ok2 and type(data) == "table" then
                local kbData = {}
                local kbPaths = {
                    "animation_keybinds.json",
                    "workspace/animation_keybinds.json",
                    "ak/animation_keybinds.json",
                    "../workspace/animation_keybinds.json"
                }
                for _, path in ipairs(kbPaths) do
                    local ok, content
                    if isfile then
                        local isF = false
                        pcall(function() isF = isfile(path) end)
                        if isF then ok, content = pcall(readfile, path) end
                    else
                        ok, content = pcall(readfile, path)
                    end
                    if ok and content and content ~= "" then
                        local kbCleaned = content:gsub("^\xEF\xBB\xBF", ""):gsub("\r\n", "\n"):gsub("\r", "\n")
                        local ok3, parsedKb = pcall(function() return HttpService:JSONDecode(kbCleaned) end)
                        if ok3 and type(parsedKb) == "table" then
                            kbData = parsedKb
                            break
                        end
                    end
                end

                -- Read existing custom anims from ReanimCustomAnims.json first to know what exists
                local existingAnims = {}
                local okC, rawC = pcall(readfile, fpath("ReanimCustomAnims.json"))
                local currentList = {}
                if okC and type(rawC) == "string" and rawC ~= "" then
                    local okJ, decoded = pcall(function() return HttpService:JSONDecode(rawC) end)
                    if okJ and type(decoded) == "table" then
                        currentList = decoded
                        for _, entry in ipairs(decoded) do
                            existingAnims[entry.name] = true
                        end
                    end
                end

                -- Also load existing keybinds so we don't overwrite user custom Halo binds
                local currentKeybinds = {}
                local okK, rawK = pcall(readfile, fpath("ReanimKeybinds.json"))
                if okK and type(rawK) == "string" and rawK ~= "" then
                    local okJ, decoded = pcall(function() return HttpService:JSONDecode(rawK) end)
                    if okJ and type(decoded) == "table" then
                        currentKeybinds = decoded
                    end
                end

                local didImportNew = false
                for key, val in pairs(data) do
                    local animName, animScript
                    if type(key) == "string" and type(val) == "string" then
                        animName, animScript = key, val
                    elseif type(val) == "table" then
                        animName = val.name or val.Name or val.title or val.Title or val.key or val.Key
                        animScript = val.script or val.Script or val.content or val.Content or val.code or val.Code or val.data or val.Data
                    end

                    if animName and animScript and animName ~= "" and animScript ~= "" then
                        local sanitizedName = animName:gsub("[^%w%s%-_]",""):match("^%s*(.-)%s*$")
                        if sanitizedName ~= "" and not existingAnims[sanitizedName] then
                            -- Auto-import animation
                            pcall(function() ReanimateAPI.seed_animation_cache(sanitizedName, nil) end)
                            table.insert(currentList, { name = sanitizedName, url = animScript, raw = true })
                            CustomAnimations[sanitizedName] = animScript
                            didImportNew = true

                            -- Auto-import keybind
                            local kbKey = kbData[animName] or kbData[sanitizedName]
                            if type(kbKey) == "string" then
                                local keyName = kbKey
                                if #keyName == 1 then keyName = keyName:upper() end
                                local kc = Enum.KeyCode[keyName]
                                if kc then
                                    local keybindName = "[Custom] " .. sanitizedName
                                    currentKeybinds[keybindName] = kc.Name
                                    Keybinds[keybindName] = { key = kc, btn = nil }
                                end
                            end
                        end
                    end
                end

                if didImportNew then
                    -- Save synced files to disk immediately
                    pcall(function() writefile(fpath("ReanimCustomAnims.json"), HttpService:JSONEncode(currentList)) end)
                    pcall(function() writefile(fpath("ReanimKeybinds.json"), HttpService:JSONEncode(currentKeybinds)) end)
                    -- Mark that auto-import has been completed
                    pcall(function() writefile(fpath("ReanimAutoImportDone.txt"), "1") end)
                end
            end
        end
    end)
end

function LoadCustomAnims()
    _customAnimsLoaded = true
    local anims = {}

    local function isRealAnimName(name)
        if not name or type(name) ~= "string" or name == "" then return false end
        local lower = name:lower()
        if lower:find("^reanim") or lower:find("stretcher") or lower:find("limbs") or lower:find("teleport") or lower:find("pointer") or lower:find("tracker") or lower:find("key") or lower:find("setting") or lower:find("config") or lower:find("reverse") then
            return false
        end
        return true
    end

    -- 1. Load unified JSON file ReanimCustomAnims.json first
    local okC, rawC = pcall(readfile, fpath("ReanimCustomAnims.json"))
    local hadFiltered = false
    if okC and type(rawC) == "string" and rawC ~= "" then
        local okJ, decoded = pcall(function() return HttpService:JSONDecode(rawC) end)
        if okJ and type(decoded) == "table" then
            for _, entry in ipairs(decoded) do
                if isRealAnimName(entry.name) then
                    local entryUrl = entry.url
                    if not entryUrl and entry.file then
                        local exists = false
                        pcall(function() exists = isfile and isfile(entry.file) end)
                        if exists then
                            entryUrl = entry.file
                        else
                            local okF, fileContent = pcall(readfile, entry.file)
                            if okF and type(fileContent) == "string" and fileContent ~= "" then
                                entryUrl = fileContent
                            end
                        end
                    end
                    local animEntry = { name = entry.name, url = entryUrl or "", raw = entry.raw ~= false, isJson = entry.isJson }
                    if entry.format == 2 and entry.animData then
                        animEntry.format = 2
                        animEntry.animData = entry.animData
                    end
                    table.insert(anims, animEntry)
                else
                    hadFiltered = true
                end
            end
        end
    end
    if hadFiltered then
        task.spawn(function()
            CustomAnims = anims
            SaveCustomAnims()
        end)
    end

    -- 2. Scan folder for manually placed files (skip files already loaded from ReanimCustomAnims.json)
    local listFilesFunc = listfiles or list_files
    local ok, files = pcall(function()
        if listFilesFunc then
            return listFilesFunc(FOLDER)
        end
        return {}
    end)
    if ok and type(files) == "table" then
        local ignored = {
            reanimfavorites = true,
            reanimkeybinds = true,
            reanimspeedkeys = true,
            reanimstates = true,
            onlineanimationscache = true,
            online_animations_cache = true,
            animation_list_cache = true,
            animationlistcache = true,
            index = true,
            reanimreversekey = true,
            reanimreversespeed = true,
            reanimrevspeedkeys = true,
            reanimfortnitewheelkey = true,
            reanimmobilewheelbtn = true,
            reanimcustomanims = true
        }
        for _, f in ipairs(files) do
            local isLua  = f:match("%.lua$")
            local isJson = f:match("%.json$")
            if (isLua or isJson) and not f:match("[Ss]ettings") and not f:match("[Cc]onfig") and not f:match("%.txt$") and not f:match("%.dat$") then
                local n = f:match("([^/\\]+)%.[%w]+$")
                if n and isRealAnimName(n) then
                    local lowerName = n:lower()
                    if not lowerName:match("^anim_%d+$") and not ignored[lowerName] and not lowerName:find("cache") and not lowerName:find("animation_list") then
                        -- Check for duplicate already loaded from ReanimCustomAnims.json
                        local alreadyLoaded = false
                        for _, existing in ipairs(anims) do
                            if existing.name == n then
                                alreadyLoaded = true
                                break
                            end
                        end
                        if not alreadyLoaded then
                            table.insert(anims, { name = n, url = f, raw = true, isJson = isJson })
                        end
                    end
                end
            end
        end
    end

    if #anims == 0 then
        local okR, raw = pcall(readfile, "ReanimCustom.lua")
        if okR and type(raw) == "string" and #raw > 20 and raw ~= "return {}" then
            print("[Reanim] Migrating from ReanimCustom.lua...")
            local data = parseLargeCustomFile(raw)
            if #data > 0 then
                anims = data
                task.spawn(function()
                    _customAnimsLoaded = true
                    CustomAnims = anims
                    SaveCustomAnims()
                    pcall(function() writefile("ReanimCustom.lua", "return {}") end)
                end)
            end
        end
    end

    if #anims > 0 then
        print("[Reanim] Loaded " .. #anims .. " animations.")
        return anims
    end
    if type(_G._ReanimCustomAnims) == "table" then
        return _G._ReanimCustomAnims
    end
    return {}
end

function LoadData()
    local function safeRead(fname, default)
        local ok, v = pcall(function()
            local okR, raw = pcall(readfile, fpath(fname))
            if not okR or type(raw) ~= "string" or raw == "" then
                okR, raw = pcall(readfile, fname)
            end
            if not okR or type(raw) ~= "string" or raw == "" then return default end
            return HttpService:JSONDecode(raw)
        end)
        return (ok and type(v) == "table") and v or default
    end
    local rawFavs = safeRead("ReanimFavorites.json", {})
    Favorites = {}
    for name, _ in pairs(rawFavs) do
        Favorites[name] = true
    end
    
    CustomAnims = LoadCustomAnims()
    _G._ReanimCustomAnims = CustomAnims
    for _, ca in ipairs(CustomAnims) do
        CustomAnimations[ca.name] = ca.url
    end
    
    -- Update Custom tab count after loading animations
    task.defer(function()
        if UpdateCustomTabCount then
            UpdateCustomTabCount()
        end
    end)
    StateAnims  = safeRead("ReanimStates.json", {})
    for k, v in pairs(StateAnims) do
        if type(v) == "string" then StateAnims[k] = { url = v, raw = false } end
    end
    local rawBinds = safeRead("ReanimKeybinds.json", {})
    Keybinds = {}
    for name, keyData in pairs(rawBinds) do
        local keyName
        if type(keyData) == "table" and keyData.key then
            keyName = keyData.key
        elseif type(keyData) == "string" then
            keyName = keyData
        end
        if keyName then
            local ok, kc = pcall(function() return Enum.KeyCode[keyName] end)
            if ok and kc then Keybinds[name] = { key = kc, btn = nil } end
        end
    end
    -- Try to load from old reanimation location if no keybinds found
    if next(Keybinds) == nil then
        local okOld, oldBinds = pcall(readfile, "keybinds.json")
        if okOld and type(oldBinds) == "string" and oldBinds ~= "" then
            local okDecode, decoded = pcall(function() return HttpService:JSONDecode(oldBinds) end)
            if okDecode and type(decoded) == "table" then
                for name, keyName in pairs(decoded) do
                    local ok, kc = pcall(function() return Enum.KeyCode[keyName] end)
                    if ok and kc then Keybinds[name] = { key = kc, btn = nil } end
                end
            end
        end
    end
    pcall(function()
        local ok, keyName = pcall(readfile, fpath("ReanimReverseKey.txt"))
        if not ok or not keyName or keyName == "" then
            ok, keyName = pcall(readfile, "ReanimReverseKey.txt")
        end
        if ok and keyName and keyName ~= "" then
            keyName = keyName:match("^%s*(.-)%s*$")
            if keyName == "NONE" then
                GlobalReverseKeybind = nil
            elseif keyName and keyName ~= "" then
                local ok4, kc = pcall(function() return Enum.KeyCode[keyName] end)
                if ok4 and kc then GlobalReverseKeybind = kc end
            end
        end

        local ok2, speedVal = pcall(readfile, fpath("ReanimReverseSpeed.txt"))
        if not ok2 or not speedVal or speedVal == "" then
            ok2, speedVal = pcall(readfile, "ReanimReverseSpeed.txt")
        end
        if ok2 and speedVal and speedVal ~= "" then
            GlobalReverseSpeed = tonumber((speedVal:match("^%s*(.-)%s*$"))) or GlobalReverseSpeed or 1.0
        end

        local ok5, irKeyName = pcall(readfile, fpath("ReanimInstantResetKey.txt"))
        if not ok5 or not irKeyName or irKeyName == "" then
            ok5, irKeyName = pcall(readfile, "ReanimInstantResetKey.txt")
        end
        if ok5 and irKeyName and irKeyName ~= "" then
            irKeyName = irKeyName:match("^%s*(.-)%s*$")
            if irKeyName == "NONE" then
                _G._HaloInstantResetKey = nil
            elseif irKeyName and irKeyName ~= "" then
                local ok6, kc = pcall(function() return Enum.KeyCode[irKeyName] end)
                if ok6 and kc then _G._HaloInstantResetKey = kc end
            end
        end

        -- Left Arm Pointer Key
        local okLa, laKeyName = pcall(readfile, fpath("ReanimLeftArmKey.txt"))
        if not okLa or not laKeyName or laKeyName == "" then
            okLa, laKeyName = pcall(readfile, "ReanimLeftArmKey.txt")
        end
        if okLa and laKeyName and laKeyName ~= "" then
            laKeyName = laKeyName:match("^%s*(.-)%s*$")
            if laKeyName == "NONE" then
                _G._HaloLeftArmKey = nil
            elseif laKeyName and laKeyName ~= "" then
                local okLa2, kc = pcall(function() return Enum.KeyCode[laKeyName] end)
                if okLa2 and kc then _G._HaloLeftArmKey = kc end
            end
        end

        -- Right Arm Pointer Key
        local okRa, raKeyName = pcall(readfile, fpath("ReanimRightArmKey.txt"))
        if not okRa or not raKeyName or raKeyName == "" then
            okRa, raKeyName = pcall(readfile, "ReanimRightArmKey.txt")
        end
        if okRa and raKeyName and raKeyName ~= "" then
            raKeyName = raKeyName:match("^%s*(.-)%s*$")
            if raKeyName == "NONE" then
                _G._HaloRightArmKey = nil
            elseif raKeyName and raKeyName ~= "" then
                local okRa2, kc = pcall(function() return Enum.KeyCode[raKeyName] end)
                if okRa2 and kc then _G._HaloRightArmKey = kc end
            end
        end

        -- Player Tracker Key
        local okTr, trKeyName = pcall(readfile, fpath("ReanimTrackerKey.txt"))
        if not okTr or not trKeyName or trKeyName == "" then
            okTr, trKeyName = pcall(readfile, "ReanimTrackerKey.txt")
        end
        if okTr and trKeyName and trKeyName ~= "" then
            trKeyName = trKeyName:match("^%s*(.-)%s*$")
            if trKeyName == "NONE" then
                _G._HaloTrackerKey = nil
            elseif trKeyName and trKeyName ~= "" then
                local okTr2, kc = pcall(function() return Enum.KeyCode[trKeyName] end)
                if okTr2 and kc then _G._HaloTrackerKey = kc end
            end
        end

        -- Head Tracker Key
        local okHt, htKeyName = pcall(readfile, fpath("ReanimHeadTrackerKey.txt"))
        if not okHt or not htKeyName or htKeyName == "" then
            okHt, htKeyName = pcall(readfile, "ReanimHeadTrackerKey.txt")
        end
        if okHt and htKeyName and htKeyName ~= "" then
            htKeyName = htKeyName:match("^%s*(.-)%s*$")
            if htKeyName == "NONE" or htKeyName == "Unknown" then
                _G._HaloHeadTrackerKey = nil
            elseif htKeyName and htKeyName ~= "" then
                local okHt2, kc = pcall(function() return Enum.KeyCode[htKeyName] end)
                if okHt2 and kc and kc ~= Enum.KeyCode.Unknown then _G._HaloHeadTrackerKey = kc end
            end
        end

        -- Teleport Key
        local okTp, tpKeyName = pcall(readfile, fpath("ReanimTeleportKey.txt"))
        if not okTp or not tpKeyName or tpKeyName == "" then
            okTp, tpKeyName = pcall(readfile, "ReanimTeleportKey.txt")
        end
        if okTp and tpKeyName and tpKeyName ~= "" then
            tpKeyName = tpKeyName:match("^%s*(.-)%s*$")
            if tpKeyName == "NONE" then
                _G._HaloTeleportKey = nil
            elseif tpKeyName and tpKeyName ~= "" then
                local okTp2, kc = pcall(function() return Enum.KeyCode[tpKeyName] end)
                if okTp2 and kc then _G._HaloTeleportKey = kc end
            end
        else
            _G._HaloTeleportKey = Enum.KeyCode.R
        end

        -- Command Bar Key
        local okCb, cbKeyName = pcall(readfile, fpath("ReanimCmdBarKey.txt"))
        if not okCb or not cbKeyName or cbKeyName == "" then
            okCb, cbKeyName = pcall(readfile, "ReanimCmdBarKey.txt")
        end
        if okCb and cbKeyName and cbKeyName ~= "" then
            cbKeyName = cbKeyName:match("^%s*(.-)%s*$")
            if cbKeyName == "NONE" then
                _G._UniCmdBarKey = nil
            elseif cbKeyName and cbKeyName ~= "" then
                local okCb2, kc = pcall(function() return Enum.KeyCode[cbKeyName] end)
                if okCb2 and kc then _G._UniCmdBarKey = kc end
            end
        else
            _G._UniCmdBarKey = Enum.KeyCode.Semicolon
        end
        if getgenv().ScopersCMD then
            getgenv().ScopersCMD.Keybind = _G._UniCmdBarKey
        end

        local ok3, rawWheel = pcall(readfile, fpath("ReanimFortniteWheelKey.json"))
        if not ok3 or not rawWheel or rawWheel == "" then
            ok3, rawWheel = pcall(readfile, "ReanimFortniteWheelKey.json")
        end
        if ok3 and rawWheel and rawWheel ~= "" then
            local data = HttpService:JSONDecode(rawWheel)
            if data and data.key then
                if data.key == "NONE" then
                    _G._FortniteWheelKey = nil
                else
                    pcall(function() _G._FortniteWheelKey = Enum.KeyCode[data.key] end)
                end
            end
        end
    end)
    local rawSK = safeRead("ReanimSpeedKeys.json", {})
    for i = 1, 6 do
        local s = rawSK[i] or {}
        local kc = nil
        if s.key then pcall(function() kc = Enum.KeyCode[s.key] end) end
        SpeedKeybinds[i] = { speed = tonumber(s.speed) or (i * 0.5), key = kc, btn = nil }
    end
    local rawRSK = safeRead("ReanimRevSpeedKeys.json", {})
    for i = 1, 6 do
        local s = rawRSK[i] or {}
        local kc = nil
        if s.key then pcall(function() kc = Enum.KeyCode[s.key] end) end
        ReverseSpeedKeybinds[i] = { speed = tonumber(s.speed) or (i * 0.5), key = kc, btn = nil }
    end
    if rawRSK.linkToNormal ~= nil then linkRevToNormal = rawRSK.linkToNormal == true end
end

local function _safeWriteFile(relPath, content)
    pcall(function()
        if makefolder and not (isfolder and isfolder(FOLDER)) then
            makefolder(FOLDER)
        end
    end)
    local ok = pcall(writefile, fpath(relPath), content)
    if not ok then
        pcall(writefile, relPath, content)
    end
end

function _rawSaveFavorites()
    local toSave = {}
    for name, _ in pairs(Favorites) do toSave[name] = true end
    pcall(function() _safeWriteFile("ReanimFavorites.json", HttpService:JSONEncode(toSave)) end)
end

local _saveFavPending = false
function SaveFavoritesOnly()
    if _saveFavPending then return end
    _saveFavPending = true
    task.delay(0.3, function()
        _saveFavPending = false
        _rawSaveFavorites()
    end)
end

function _rawSaveKeybinds()
    local toSave = {}
    for name, data in pairs(Keybinds) do
        if data.key then toSave[name] = data.key.Name end
    end
    pcall(function() _safeWriteFile("ReanimKeybinds.json", HttpService:JSONEncode(toSave)) end)
end

local _saveKbPending = false
function SaveKeybindsOnly()
    if _saveKbPending then return end
    _saveKbPending = true
    task.delay(0.3, function()
        _saveKbPending = false
        _rawSaveKeybinds()
    end)
end

local _saveDataPending = false
function SaveData()
    _rawSaveFavorites()
    _rawSaveKeybinds()
    -- Run all writefile calls safely
    task.spawn(function()
        pcall(function() _safeWriteFile("ReanimStates.json", HttpService:JSONEncode(StateAnims)) end)
        local skSave = {}
        for i = 1, 6 do
            local s = SpeedKeybinds[i] or {}
            skSave[i] = { speed = s.speed, key = s.key and s.key.Name or nil }
        end
        pcall(function() _safeWriteFile("ReanimSpeedKeys.json", HttpService:JSONEncode(skSave)) end)
        local rskSave = { linkToNormal = linkRevToNormal }
        for i = 1, 6 do
            local s = ReverseSpeedKeybinds[i] or {}
            rskSave[i] = { speed = s.speed, key = s.key and s.key.Name or nil }
        end
        pcall(function() _safeWriteFile("ReanimRevSpeedKeys.json", HttpService:JSONEncode(rskSave)) end)
        pcall(function()
            if GlobalReverseKeybind then
                _safeWriteFile("ReanimReverseKey.txt", GlobalReverseKeybind.Name)
            else
                _safeWriteFile("ReanimReverseKey.txt", "NONE")
            end
            _safeWriteFile("ReanimReverseSpeed.txt", tostring(GlobalReverseSpeed or 1.0))
            if _G._HaloInstantResetKey then
                _safeWriteFile("ReanimInstantResetKey.txt", _G._HaloInstantResetKey.Name)
            else
                _safeWriteFile("ReanimInstantResetKey.txt", "NONE")
            end
            if _G._HaloTeleportKey then
                _safeWriteFile("ReanimTeleportKey.txt", _G._HaloTeleportKey.Name)
            else
                _safeWriteFile("ReanimTeleportKey.txt", "NONE")
            end
            if _G._UniCmdBarKey then
                _safeWriteFile("ReanimCmdBarKey.txt", _G._UniCmdBarKey.Name)
            else
                _safeWriteFile("ReanimCmdBarKey.txt", "NONE")
            end
            if _G._HaloLeftArmKey then
                _safeWriteFile("ReanimLeftArmKey.txt", _G._HaloLeftArmKey.Name)
            else
                _safeWriteFile("ReanimLeftArmKey.txt", "NONE")
            end
            if _G._HaloRightArmKey then
                _safeWriteFile("ReanimRightArmKey.txt", _G._HaloRightArmKey.Name)
            else
                _safeWriteFile("ReanimRightArmKey.txt", "NONE")
            end
            if _G._HaloTrackerKey then
                _safeWriteFile("ReanimTrackerKey.txt", _G._HaloTrackerKey.Name)
            else
                _safeWriteFile("ReanimTrackerKey.txt", "NONE")
            end
            if _G._HaloHeadTrackerKey then
                _safeWriteFile("ReanimHeadTrackerKey.txt", _G._HaloHeadTrackerKey.Name)
            else
                _safeWriteFile("ReanimHeadTrackerKey.txt", "NONE")
            end
            if _G._FortniteWheelKey then
                _safeWriteFile("ReanimFortniteWheelKey.json", HttpService:JSONEncode({key = _G._FortniteWheelKey.Name}))
            else
                _safeWriteFile("ReanimFortniteWheelKey.json", HttpService:JSONEncode({key = "NONE"}))
            end
        end)
    end)
end

LoadData()

-- Load VC Bypass saved state
-- ============================================
-- ARM SLIDER CONFIG SAVE/LOAD
-- ============================================
local ARM_SLIDER_CONFIG_FILE = fpath("ReanimArmSlider.json")

function SaveArmSliderConfig()
    pcall(function()
        local data = {
            offsetX = _G._HaloArmSliderOffsetX or 0,
            offsetY = _G._HaloArmSliderOffsetY or 0,
            stretch = _G._HaloArmSliderStretch or 1.0,
            rotationEnabled = _G._HaloArmSliderRotationEnabled or false,
            rotation = _G._HaloArmSliderRotation or 0,
        }
        _safeWriteFile("ReanimArmSlider.json", HttpService:JSONEncode(data))
    end)
end

function LoadArmSliderConfig()
    pcall(function()
        local ok, raw = pcall(readfile, ARM_SLIDER_CONFIG_FILE)
        if not ok or not raw or raw == "" then
            ok, raw = pcall(readfile, "ReanimArmSlider.json")
        end
        if ok and raw and raw ~= "" then
            local data = HttpService:JSONDecode(raw)
            if type(data) == "table" then
                _G._HaloArmSliderOffsetX = tonumber(data.offsetX) or 0
                _G._HaloArmSliderOffsetY = tonumber(data.offsetY) or 0
                _G._HaloArmSliderStretch = tonumber(data.stretch) or 1.0
                _G._HaloArmSliderRotationEnabled = data.rotationEnabled == true
                _G._HaloArmSliderRotation = tonumber(data.rotation) or 0
            end
        end
    end)
end

LoadArmSliderConfig()

-- Shaders toggle config
function SaveShadersConfig()
    pcall(function()
        _safeWriteFile("ReanimShaders.json", HttpService:JSONEncode({enabled = _G._HaloShadersEnabled == true}))
    end)
end

function LoadShadersConfig()
    pcall(function()
        local ok, raw = pcall(readfile, fpath("ReanimShaders.json"))
        if not ok or not raw or raw == "" then
            ok, raw = pcall(readfile, "ReanimShaders.json")
        end
        if ok and raw and raw ~= "" then
            local data = HttpService:JSONDecode(raw)
            if type(data) == "table" then
                _G._HaloShadersEnabled = data.enabled == true
            end
        end
    end)
end

LoadShadersConfig()

pcall(function()
    local raw = readfile(fpath("ReanimVCBypass.json"))
    if raw then
        local data = HttpService:JSONDecode(raw)
        if data and data.enabled then
            applyVCBypass()
        end
    end
end)
_customAnimsLoaded = true

function prefetchCustomAnim(ca)
    if not ca then return end
    local src = ca.url
    if not src or src == "" then return end
    if rawAnimCache[src] then return end

    -- Format-2 entries carry pre-serialized animData; deserialize lazily here
    -- (this was previously done eagerly in LoadCustomAnims and froze the game on open)
    if ca.format == 2 and ca.animData then
        task.spawn(function()
            local okD, deserialized = pcall(deserializeAnimData, ca.animData)
            if okD and type(deserialized) == "table" then
                rawAnimCache[src] = { src = src, data = deserialized }
                ca.format = nil
                ca.animData = nil
            end
        end)
        return
    end

    if not ca.raw then return end
    task.spawn(function()
        local cleaned = src:gsub("^\xEF\xBB\xBF", ""):gsub("\r\n", "\n"):gsub("\r", "\n")
        local firstChar = cleaned:match("^%s*(.)")
        -- Try JSON parsing first
        if firstChar == "{" or firstChar == "[" then
            local parsed = parseJsonAnimation(cleaned)
            if parsed then
                rawAnimCache[src] = { src = src, data = parsed, isJson = true }
                return
            end
        end
        local fn = loadstring(cleaned)
        if not fn then return end
        local ok, data = pcall(fn)
        if not ok or type(data) ~= "table" then return end
        rawAnimCache[src] = { src = src, data = data }
        ca.format = nil
    end)
end

function prefetchAllCustomAnims()
    task.spawn(function()
        for _, ca in ipairs(CustomAnims) do
            prefetchCustomAnim(ca)
            task.wait()
        end
    end)
end

-- Disabled automatic prefetching to reduce lag on startup
-- task.delay(0.5, prefetchAllCustomAnims)

local stopStateSystem
local startStateSystem
local prefetchStateAnim
local prefetchAllStates
local stateSystemActive = false
_G._HaloListeningKeyBtn = nil
_G._HaloListenTarget    = nil
local isDraggingSpeed   = false
function new(cls, parent, props)
    local obj = Instance.new(cls)
    if parent then obj.Parent = parent end
    if props then
        for k, v in pairs(props) do
            pcall(function() obj[k] = v end)
        end
    end
    return obj
end

function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = parent
    return c
end

function stroke(parent, col, thick, trans)
    local ok, s = pcall(function() return Instance.new("UIStroke") end)
    if not ok then return nil end
    s.Color = col or Color3.fromRGB(80, 80, 80)
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.Parent = parent
    return s
end

function tw(obj, t, props, style, dir)
    local filteredProps = {}
    for k, v in pairs(props) do
        local ok = pcall(function() return obj[k] end)
        if ok then
            filteredProps[k] = v
        end
    end
    return game:GetService("TweenService"):Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), filteredProps)
end

local C = {
    bg0         = Color3.fromRGB(10, 10, 10),
    bg1         = Color3.fromRGB(16, 16, 16),
    bg2         = Color3.fromRGB(22, 22, 22),
    bg3         = Color3.fromRGB(32, 32, 32),
    bg4         = Color3.fromRGB(18, 18, 18),
    border      = Color3.fromRGB(42, 42, 42),
    glassBorder = Color3.fromRGB(255, 255, 255),
    text        = Color3.fromRGB(250, 250, 250),
    text2       = Color3.fromRGB(180, 180, 180),
    text3       = Color3.fromRGB(120, 120, 120),
    accent      = Color3.fromRGB(255, 255, 255),
    red         = Color3.fromRGB(140, 140, 140),
    yellow      = Color3.fromRGB(200, 200, 200),
    green       = Color3.fromRGB(255, 255, 255),
    white       = Color3.fromRGB(255, 255, 255),
}

local ScreenGui, Menu, body, NowPlayingLabel, StopBtn, TabButtons, SearchBox, hintLbl, AnimListFrame, StatesPanel, CustomPanel, customSearchBox, customOpenModalBtn, customListFrame, SettingsPanel, SpeedPanel, StretchingPanel, SetTabActive, updateFnWheelBtnText, updateRevBtnText, revFill, revHandle, revSpdLbl, Notify, _screenGuiTarget, spawnTreehouse, deleteTreehouse, teleportToTreehouse, deleteWorkspaceModels, promptTreehouseOnLoad, promptCmdBarOnLoad, promptDiscordOnLoad
do
ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name           = "ReanimHaloMenu"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

_screenGuiTarget = nil
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local PlayerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui")
do
    -- Use PlayerGui instead of CoreGui — CoreGui ScreenGuis intercept all input
    -- before the game world even when no Active=true is set on child frames.
    _screenGuiTarget = PlayerGui
end

Notify = function(msg, dur, extra)
    _G._ReanimNotify = Notify
    local realMsg = msg
    local realDur = dur
    if type(dur) == "string" then
        realMsg = msg .. ": " .. dur
        realDur = extra
    end
    realDur = tonumber(realDur) or 2.5

    local n = Instance.new("Frame")
    n.Parent = ScreenGui
    n.Size   = UDim2.new(0, 300, 0, 44)
    n.Position = UDim2.new(1, 24, 0, 24)
    n.BackgroundColor3 = C.bg1
    n.BackgroundTransparency = 0.02
    n.BorderSizePixel = 0
    n.ZIndex = 1000
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = n
        local s = Instance.new("UIStroke"); s.Color = C.border
        s.Transparency = 0.25; s.Thickness = 1; s.Parent = n
        local bar = Instance.new("Frame"); bar.Parent = n
        bar.BackgroundColor3 = C.white; bar.BackgroundTransparency = 0
        bar.BorderSizePixel = 0; bar.Size = UDim2.new(0, 2, 0.55, 0)
        bar.Position = UDim2.new(0, 0, 0.5, 0); bar.AnchorPoint = Vector2.new(0, 0.5)
        bar.ZIndex = 1001
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    end
    local t = Instance.new("TextLabel"); t.Parent = n
    t.BackgroundTransparency = 1; t.Position = UDim2.new(0, 14, 0, 0)
    t.Size = UDim2.new(1, -24, 1, 0); t.Font = Enum.Font.GothamMedium
    t.Text = realMsg; t.TextColor3 = C.text
    t.TextSize = 12; t.TextWrapped = true; t.ZIndex = 1001
    t.TextXAlignment = Enum.TextXAlignment.Left
    TweenService:Create(n, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -324, 0, 24)}):Play()
    task.delay(realDur, function()
        TweenService:Create(n, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(1, 24, 0, 24), BackgroundTransparency = 1}):Play()
        game:GetService("Debris"):AddItem(n, 0.32)
    end)
end

-- ==========================================
-- TREEHOUSE & MAP MANAGEMENT
-- ==========================================
local TREEHOUSE_ASSET_ID = 7860328354
_G._HaloTreehouseModel = nil

local function getTreehouseSpawnPosition()
    local spawnPart = workspace:FindFirstChild("ModelSpawn")
    if spawnPart and spawnPart:IsA("BasePart") then
        return spawnPart.Position
    end
    return Vector3.new(-410.25, 100.5, -75.46) -- fallback position
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

spawnTreehouse = function()
    if _G._HaloTreehouseModel and _G._HaloTreehouseModel.Parent then
        Notify("Treehouse", "Treehouse is already spawned!", 2.5)
        return _G._HaloTreehouseModel
    end

    local existing = workspace:FindFirstChild("HaloTreehouse")
    if existing then
        _G._HaloTreehouseModel = existing
        Notify("Treehouse", "Treehouse already exists in workspace!", 2.5)
        return existing
    end

    local success, objects = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(TREEHOUSE_ASSET_ID))
    end)

    if not success or not objects or #objects == 0 then
        Notify("Treehouse Error", "Failed to load treehouse model.", 3.5)
        return nil
    end

    local model = objects[1]
    model.Name = "HaloTreehouse"
    model.Parent = workspace
    prepareTreehouseModel(model, getTreehouseSpawnPosition())
    _G._HaloTreehouseModel = model
    Notify("Treehouse", "Treehouse spawned successfully!", 3)
    return model
end

deleteTreehouse = function()
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

    if deleted then
        Notify("Treehouse", "Treehouse removed from workspace.", 2.5)
    else
        Notify("Treehouse", "No Treehouse found to remove.", 2.5)
    end
end

deleteWorkspaceModels = function()
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        playerNames[player.Name] = true
        playerNames[player.Name .. "Celeste"] = true
    end

    local count = 0
    for _, item in ipairs(workspace:GetChildren()) do
        if item:IsA("Model") and not playerNames[item.Name] and item ~= workspace.CurrentCamera then
            pcall(function() item:Destroy() end)
            count = count + 1
        end
    end
    _G._HaloTreehouseModel = nil
    Notify("Map Cleanup", "Deleted " .. tostring(count) .. " map models.", 3)
end

teleportToTreehouse = function()
    local model = _G._HaloTreehouseModel or workspace:FindFirstChild("HaloTreehouse")
    if not model or not model.Parent then
        Notify("Teleport Error", "Treehouse is not spawned! Spawning it now...", 2)
        model = spawnTreehouse()
        if not model then return end
        task.wait(0.3)
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
            local closest = parts[1]
            local minDist = (closest.Position - center).Magnitude
            for _, p in pairs(parts) do
                local d = (p.Position - center).Magnitude
                if d < minDist then
                    closest = p
                    minDist = d
                end
            end
            targetPart = closest
        end
    end

    if not targetPart then
        Notify("Teleport Error", "No suitable part found in Treehouse.", 3)
        return
    end

    local tpCFrame = targetPart.CFrame + Vector3.new(0, 6, 0)
    local modelsToTeleport = {}
    if plr.Character then table.insert(modelsToTeleport, plr.Character) end
    if ReanimateAPI and ReanimateAPI.get_clone then
        local okC, clone = pcall(ReanimateAPI.get_clone, plr)
        if okC and clone and clone ~= plr.Character then table.insert(modelsToTeleport, clone) end
    end
    if ReanimateAPI and ReanimateAPI.get_real_character then
        local okR, realChar = pcall(ReanimateAPI.get_real_character, plr)
        if okR and realChar and realChar ~= plr.Character then table.insert(modelsToTeleport, realChar) end
    end

    for _, charModel in ipairs(modelsToTeleport) do
        local hrp = charModel:FindFirstChild("HumanoidRootPart") or charModel:FindFirstChild("Torso") or charModel:FindFirstChild("UpperTorso") or charModel.PrimaryPart
        if hrp then
            hrp.CFrame = tpCFrame
            pcall(function()
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end

    Notify("Treehouse", "Teleported to Treehouse!", 2.5)
end

_G._HaloSpawnTreehouse = spawnTreehouse
_G._HaloDeleteTreehouse = deleteTreehouse
_G._HaloTeleportToTreehouse = teleportToTreehouse
_G._HaloDeleteWorkspaceModels = deleteWorkspaceModels

local _activePrompts = {}

local function _repositionPrompts()
    local currentY = -106
    for i = 1, #_activePrompts do
        local p = _activePrompts[i]
        if p and p.Parent then
            local pHeight = p.Size.Y.Offset
            TweenService:Create(p, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(0, 20, 1, currentY)}):Play()
            currentY = currentY - pHeight - 10
        end
    end
end

local function _createPromptFrame(name, titleText, subText, height, onDismiss)
    height = height or 86
    local promptFrame = Instance.new("Frame")
    promptFrame.Name = name
    promptFrame.Parent = ScreenGui
    promptFrame.Size = UDim2.new(0, 310, 0, height)
    promptFrame.Position = UDim2.new(0, -340, 1, -106)
    promptFrame.BackgroundColor3 = C.bg1
    promptFrame.BackgroundTransparency = 0.05
    promptFrame.BorderSizePixel = 0
    promptFrame.ZIndex = 1200

    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = promptFrame
    local s = Instance.new("UIStroke"); s.Color = C.accent; s.Transparency = 0.25; s.Thickness = 1.2; s.Parent = promptFrame

    local bar = Instance.new("Frame"); bar.Parent = promptFrame
    bar.BackgroundColor3 = C.accent; bar.BackgroundTransparency = 0
    bar.BorderSizePixel = 0; bar.Size = UDim2.new(0, 3, 0.6, 0)
    bar.Position = UDim2.new(0, 0, 0.5, 0); bar.AnchorPoint = Vector2.new(0, 0.5)
    bar.ZIndex = 1201
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)

    local title = Instance.new("TextLabel"); title.Parent = promptFrame
    title.BackgroundTransparency = 1; title.Position = UDim2.new(0, 14, 0, 8)
    title.Size = UDim2.new(1, -45, 0, 18); title.Font = Enum.Font.GothamBold
    title.Text = titleText; title.TextColor3 = C.accent
    title.TextSize = 13; title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 1201

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Parent = promptFrame
    closeBtn.Size = UDim2.new(0, 18, 0, 18)
    closeBtn.Position = UDim2.new(1, -25, 0, 8)
    closeBtn.BackgroundColor3 = C.bg2
    closeBtn.BackgroundTransparency = 0.35
    closeBtn.BorderSizePixel = 0
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "x"
    closeBtn.TextColor3 = C.text3
    closeBtn.TextSize = 9
    closeBtn.ZIndex = 1202
    closeBtn.AutoButtonColor = false

    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(1, 0); cc.Parent = closeBtn
    local cs = Instance.new("UIStroke"); cs.Color = C.border; cs.Transparency = 0.6; cs.Thickness = 1; cs.Parent = closeBtn

    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(150, 150, 150),
            BackgroundTransparency = 0.1,
            TextColor3 = C.white
        }):Play()
        TweenService:Create(cs, TweenInfo.new(0.15), {
            Color = Color3.fromRGB(160, 160, 160),
            Transparency = 0.3
        }):Play()
    end)

    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = C.bg2,
            BackgroundTransparency = 0.35,
            TextColor3 = C.text3
        }):Play()
        TweenService:Create(cs, TweenInfo.new(0.15), {
            Color = C.border,
            Transparency = 0.6
        }):Play()
    end)

    local sub = Instance.new("TextLabel"); sub.Parent = promptFrame
    sub.BackgroundTransparency = 1; sub.Position = UDim2.new(0, 14, 0, 27)
    sub.Size = UDim2.new(1, -28, 0, 16); sub.Font = Enum.Font.Gotham
    sub.Text = subText; sub.TextColor3 = C.text
    sub.TextSize = 10; sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.ZIndex = 1201

    table.insert(_activePrompts, promptFrame)
    _repositionPrompts()

    local closed = false
    local function dismiss()
        if closed then return end
        closed = true
        if onDismiss then pcall(onDismiss) end
        for idx, p in ipairs(_activePrompts) do
            if p == promptFrame then
                table.remove(_activePrompts, idx)
                break
            end
        end
        TweenService:Create(promptFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(0, -340, 1, promptFrame.Position.Y.Offset)}):Play()
        task.delay(0.4, function()
            if promptFrame and promptFrame.Parent then promptFrame:Destroy() end
        end)
        _repositionPrompts()
    end

    closeBtn.MouseButton1Click:Connect(dismiss)

    task.delay(300, function()
        if not closed then dismiss() end
    end)

    return promptFrame, dismiss
end

promptTreehouseOnLoad = function() end -- moved to N0IR UI lib

promptCmdBarOnLoad = function()
    task.spawn(function()
        task.wait(1.8)
        if not ScreenGui or not ScreenGui.Parent then return end

        local isDone = false
        pcall(function()
            local ok, raw = pcall(readfile, fpath("ReanimCmdBarPromptDone.txt"))
            if not ok or not raw or raw == "" then
                ok, raw = pcall(readfile, "ReanimCmdBarPromptDone.txt")
            end
            if ok and raw and raw ~= "" then isDone = true end
        end)
        if isDone then return end

        local function markDone()
            pcall(function()
                _safeWriteFile("ReanimCmdBarPromptDone.txt", "1")
            end)
        end

        local promptFrame, dismiss = _createPromptFrame("CmdBarPrompt", "Command Bar Key", "Click button to set activation key:", 86, markDone)

        -- Keybind button
        local keyBtn = Instance.new("TextButton"); keyBtn.Parent = promptFrame
        keyBtn.Size = UDim2.new(0.6, -14, 0, 26); keyBtn.Position = UDim2.new(0, 14, 0, 48)
        keyBtn.BackgroundColor3 = C.bg2; keyBtn.BackgroundTransparency = 0.2
        keyBtn.BorderSizePixel = 0; keyBtn.Font = Enum.Font.GothamBold
        local currentKeyName = _G._UniCmdBarKey and _G._UniCmdBarKey.Name or "Semicolon"
        keyBtn.Text = "Key: " .. currentKeyName; keyBtn.TextColor3 = C.accent
        keyBtn.TextSize = 10; keyBtn.ZIndex = 1202; keyBtn.AutoButtonColor = false
        local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(0, 6); kc.Parent = keyBtn
        local ks = Instance.new("UIStroke"); ks.Color = C.border; ks.Transparency = 0.7; ks.Thickness = 1; ks.Parent = keyBtn

        -- Done button
        local doneBtn = Instance.new("TextButton"); doneBtn.Parent = promptFrame
        doneBtn.Size = UDim2.new(0.4, -18, 0, 26); doneBtn.Position = UDim2.new(0.6, 4, 0, 48)
        doneBtn.BackgroundColor3 = C.accent; doneBtn.BackgroundTransparency = 0.05
        doneBtn.BorderSizePixel = 0; doneBtn.Font = Enum.Font.GothamBold
        doneBtn.Text = "Done"; doneBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
        doneBtn.TextSize = 11; doneBtn.ZIndex = 1202; doneBtn.AutoButtonColor = false
        local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(0, 6); dc.Parent = doneBtn

        doneBtn.MouseEnter:Connect(function()
            TweenService:Create(doneBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(180, 180, 180) }):Play()
        end)
        doneBtn.MouseLeave:Connect(function()
            TweenService:Create(doneBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0.05, BackgroundColor3 = C.accent }):Play()
        end)

        local settingKey = false
        keyBtn.MouseButton1Click:Connect(function()
            if settingKey then return end
            settingKey = true
            keyBtn.Text = "Listening..."
            keyBtn.BackgroundColor3 = C.yellow
            keyBtn.TextColor3 = Color3.fromRGB(15, 15, 15)

            local keyConn
            keyConn = UserInputService.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(i, gp)
                if gp then return end
                keyConn:Disconnect()
                settingKey = false
                keyBtn.BackgroundColor3 = C.bg2
                keyBtn.TextColor3 = C.accent
                if i.KeyCode == Enum.KeyCode.Escape then
                    local kName = _G._UniCmdBarKey and _G._UniCmdBarKey.Name or "Semicolon"
                    keyBtn.Text = "Key: " .. kName
                    return
                end
                _G._UniCmdBarKey = i.KeyCode
                if getgenv().ScopersCMD then getgenv().ScopersCMD.Keybind = i.KeyCode end
                SaveData()
                markDone()
                keyBtn.Text = "Key: " .. i.KeyCode.Name
                if _G._UniUpdateCmdBarBtnText then pcall(_G._UniUpdateCmdBarBtnText) end
                Notify("CMD Bar Key", "Keybind set to " .. i.KeyCode.Name, 2.5)
            end))
        end)

        doneBtn.MouseButton1Click:Connect(function()
            markDone()
            dismiss()
        end)
    end)
end

promptDiscordOnLoad = function()
    task.spawn(function()
        task.wait(2.1)
        if not ScreenGui or not ScreenGui.Parent then return end

        local isDone = false
        pcall(function()
            local ok, raw = pcall(readfile, fpath("ReanimDiscordPromptDone.txt"))
            if not ok or not raw or raw == "" then
                ok, raw = pcall(readfile, "ReanimDiscordPromptDone.txt")
            end
            if ok and raw and raw ~= "" then isDone = true end
        end)
        if isDone then return end

        local function markDone()
            pcall(function()
                _safeWriteFile("ReanimDiscordPromptDone.txt", "1")
            end)
        end

        local promptFrame, dismiss = _createPromptFrame("DiscordPrompt", "Discord Server", "Join our community for updates & scripts!", 86, markDone)

        -- Join button
        local joinBtn = Instance.new("TextButton"); joinBtn.Parent = promptFrame
        joinBtn.Size = UDim2.new(0.6, -14, 0, 26); joinBtn.Position = UDim2.new(0, 14, 0, 48)
        joinBtn.BackgroundColor3 = C.accent; joinBtn.BackgroundTransparency = 0.05
        joinBtn.BorderSizePixel = 0; joinBtn.Font = Enum.Font.GothamBold
        joinBtn.Text = "Join Discord"; joinBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
        joinBtn.TextSize = 11; joinBtn.ZIndex = 1202; joinBtn.AutoButtonColor = false
        local jc = Instance.new("UICorner"); jc.CornerRadius = UDim.new(0, 6); jc.Parent = joinBtn

        joinBtn.MouseEnter:Connect(function()
            TweenService:Create(joinBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(180, 180, 180) }):Play()
        end)
        joinBtn.MouseLeave:Connect(function()
            TweenService:Create(joinBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0.05, BackgroundColor3 = C.accent }):Play()
        end)

        -- Later / Dismiss button
        local laterBtn = Instance.new("TextButton"); laterBtn.Parent = promptFrame
        laterBtn.Size = UDim2.new(0.4, -18, 0, 26); laterBtn.Position = UDim2.new(0.6, 4, 0, 48)
        laterBtn.BackgroundColor3 = C.bg2; laterBtn.BackgroundTransparency = 0.2
        laterBtn.BorderSizePixel = 0; laterBtn.Font = Enum.Font.GothamBold
        laterBtn.Text = "Later"; laterBtn.TextColor3 = C.text3
        laterBtn.TextSize = 11; laterBtn.ZIndex = 1202; laterBtn.AutoButtonColor = false
        local lc = Instance.new("UICorner"); lc.CornerRadius = UDim.new(0, 6); lc.Parent = laterBtn
        local ls = Instance.new("UIStroke"); ls.Color = C.border; ls.Transparency = 0.7; ls.Thickness = 1; ls.Parent = laterBtn

        laterBtn.MouseEnter:Connect(function()
            TweenService:Create(laterBtn, TweenInfo.new(0.12), { BackgroundColor3 = C.bg3, TextColor3 = C.white }):Play()
        end)
        laterBtn.MouseLeave:Connect(function()
            TweenService:Create(laterBtn, TweenInfo.new(0.12), { BackgroundColor3 = C.bg2, TextColor3 = C.text3 }):Play()
        end)

        joinBtn.MouseButton1Click:Connect(function()
            markDone()
            dismiss()
            local discordLink = "https://discord.gg/mFSNVgrqF"
            pcall(function()
                local setcb = setclipboard or toclipboard or set_clipboard or (syn and syn.write_clipboard)
                if setcb then setcb(discordLink) end
            end)
            pcall(function()
                local req = request or (http and http.request) or http_request or (fluxus and fluxus.request)
                if req then
                    req({
                        Url = "http://127.0.0.1:6463/rpc?v=1",
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json", ["Origin"] = "https://discord.com"},
                        Body = game:GetService("HttpService"):JSONEncode({
                            cmd = "INVITE_BROWSER",
                            args = {code = "mFSNVgrqF"},
                            nonce = game:GetService("HttpService"):GenerateGUID(false)
                        })
                    })
                end
            end)
            Notify("Discord Invite", "Copied https://discord.gg/mFSNVgrqF to clipboard!", 3.5)
        end)

        laterBtn.MouseButton1Click:Connect(function()
            markDone()
            dismiss()
        end)
    end)
end

Menu = Instance.new("Frame")
Menu.Name               = "ReanimMenu"
Menu.Parent             = ScreenGui
Menu.BackgroundColor3   = C.bg0
Menu.BackgroundTransparency = 0.08
Menu.BorderSizePixel    = 0
Menu.AnchorPoint        = Vector2.new(0.5, 0.5)
Menu.Position           = UDim2.new(0.5, 0, 0.5, 0)
Menu.Size               = UDim2.new(0, 0, 0, 0)
Menu.Visible            = true
Menu.Active             = false
Menu.ZIndex             = 30
Menu.ClipsDescendants   = true
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 14); c.Parent = Menu
    local s = Instance.new("UIStroke"); s.Color = C.border
    s.Transparency = 0.15; s.Thickness = 1; s.Parent = Menu
    local shadow = Instance.new("ImageLabel"); shadow.Name = "Shadow"
    shadow.Parent = Menu; shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://131604521937076"
    shadow.ImageColor3 = Color3.fromRGB(0,0,0)
    shadow.ImageTransparency = 0.45
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(50,50,50,50)
    shadow.Size = UDim2.new(1, 48, 1, 48)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.ZIndex = 29
end

-- Resize Handle (curved grip bottom-right)
local ResizeGrip = Instance.new("Frame")
ResizeGrip.Name = "ResizeGrip"
ResizeGrip.Parent = Menu
ResizeGrip.BackgroundColor3 = C.border
ResizeGrip.BackgroundTransparency = 0.35
ResizeGrip.BorderSizePixel = 0
ResizeGrip.Size = UDim2.new(0, 18, 0, 18)
ResizeGrip.Position = UDim2.new(1, -18, 1, -18)
ResizeGrip.ZIndex = 35
ResizeGrip.Active = true
local gripCorner = Instance.new("UICorner", ResizeGrip)
gripCorner.CornerRadius = UDim.new(0, 6)
local gripStroke = Instance.new("UIStroke", ResizeGrip)
gripStroke.Color = C.glassBorder
gripStroke.Thickness = 1.5
gripStroke.Transparency = 0.3

-- Curved diagonal lines on grip for visual flair
for i = 0, 2 do
    local line = Instance.new("Frame", ResizeGrip)
    line.BackgroundColor3 = C.text
    line.BackgroundTransparency = 0.4
    line.BorderSizePixel = 0
    line.Size = UDim2.new(0, 8, 0, 1.5)
    line.Position = UDim2.new(0, 3 + i*2.5, 0, 12 - i*2.5)
    line.Rotation = -45
    line.ZIndex = 36
end

-- Resize logic
local resizing = false
local resizeStartPos
local resizeStartSize

ResizeGrip.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        resizeStartPos = input.Position
        resizeStartSize = Menu.AbsoluteSize
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                resizing = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - resizeStartPos
        local newW = math.clamp(resizeStartSize.X + delta.X, CONFIG.UI.MIN_WIDTH, 700)
        local newH = math.clamp(resizeStartSize.Y + delta.Y, CONFIG.UI.MIN_HEIGHT, 800)
        Menu.Size = UDim2.new(0, newW, 0, newH)
        FULL_SIZE = UDim2.new(0, newW, 0, newH)
        if not isMinimized then
            MINI_SIZE = UDim2.new(0, newW, 0, 40)
        end
    end
end)

ResizeGrip.MouseEnter:Connect(function()
    TweenService:Create(ResizeGrip, TweenInfo.new(0.15), {BackgroundTransparency = 0.3}):Play()
end)
ResizeGrip.MouseLeave:Connect(function()
    TweenService:Create(ResizeGrip, TweenInfo.new(0.15), {BackgroundTransparency = 0.6}):Play()
end)


-- Entrance animation (scale + fade)
do
    local targetW = CONFIG.UI.DEFAULT_WIDTH
    local targetH = CONFIG.UI.DEFAULT_HEIGHT
    Menu.Size = UDim2.new(0, math.floor(targetW * 0.92), 0, math.floor(targetH * 0.92))
    Menu.BackgroundTransparency = 1
    Menu.Visible = true
    pcall(function()
        local openInfo = TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        TweenService:Create(Menu, openInfo, {
            Size = UDim2.new(0, targetW, 0, targetH),
            BackgroundTransparency = 0.08,
        }):Play()
        local stroke = Menu:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Transparency = 1
            TweenService:Create(stroke, openInfo, {Transparency = 0.15}):Play()
        end
        local shadow = Menu:FindFirstChild("Shadow")
        if shadow and shadow:IsA("ImageLabel") then
            shadow.ImageTransparency = 1
            TweenService:Create(shadow, openInfo, {ImageTransparency = 0.45}):Play()
        end
    end)
end

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"; TitleBar.Parent = Menu
TitleBar.BackgroundColor3 = C.bg1
TitleBar.BackgroundTransparency = 0.05; TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1,0,0,48); TitleBar.ZIndex = 31; TitleBar.Active = false
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,14); c.Parent = TitleBar
    -- cover bottom corners so only top is rounded visually with body
    local cover = Instance.new("Frame"); cover.Parent = TitleBar
    cover.BackgroundColor3 = C.bg1; cover.BackgroundTransparency = 0.05
    cover.BorderSizePixel = 0; cover.Position = UDim2.new(0,0,1,-10)
    cover.Size = UDim2.new(1,0,0,10); cover.ZIndex = 31
    local t = Instance.new("TextLabel"); t.Parent = TitleBar
    t.BackgroundTransparency = 1; t.Position = UDim2.new(0,16,0,0)
    t.Size = UDim2.new(1,-200,1,0); t.Font = Enum.Font.GothamBlack
    t.Text = "NØIR"; t.TextColor3 = C.text
    t.TextSize = 18; t.TextXAlignment = Enum.TextXAlignment.Left; t.ZIndex = 32
    local sub = Instance.new("TextLabel"); sub.Parent = TitleBar
    sub.BackgroundTransparency = 1; sub.Position = UDim2.new(0, 64, 0, 0)
    sub.Size = UDim2.new(0, 80, 1, 0); sub.Font = Enum.Font.GothamMedium
    sub.Text = "Reanim"; sub.TextColor3 = C.text3
    sub.TextSize = 10; sub.TextXAlignment = Enum.TextXAlignment.Left; sub.ZIndex = 32
    local div = Instance.new("Frame"); div.Parent = TitleBar
    div.BackgroundColor3 = C.border; div.BackgroundTransparency = 0.2
    div.BorderSizePixel = 0; div.Position = UDim2.new(0,0,1,-1)
    div.Size = UDim2.new(1,0,0,1); div.ZIndex = 33
end

local minimizeBtn = Instance.new("TextButton"); minimizeBtn.Parent = TitleBar
minimizeBtn.Name = "MinimizeBtn"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
minimizeBtn.BackgroundTransparency = 0.15
minimizeBtn.BorderSizePixel = 0; minimizeBtn.AnchorPoint = Vector2.new(1,0.5)
minimizeBtn.Position = UDim2.new(1,-32,0.5,0); minimizeBtn.Size = UDim2.new(0,13,0,13)
minimizeBtn.Font = Enum.Font.GothamBold; minimizeBtn.Text = ""
minimizeBtn.TextColor3 = Color3.fromRGB(255,255,255); minimizeBtn.TextSize = 18
minimizeBtn.ZIndex = 32; minimizeBtn.AutoButtonColor = false
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = minimizeBtn end

local closeBtn = Instance.new("TextButton"); closeBtn.Parent = TitleBar
closeBtn.Name = "CloseBtn"
closeBtn.BackgroundColor3 = Color3.fromRGB(160, 160, 160)
closeBtn.BackgroundTransparency = 0.05
closeBtn.BorderSizePixel = 0; closeBtn.AnchorPoint = Vector2.new(1,0.5)
closeBtn.Position = UDim2.new(1,-12,0.5,0); closeBtn.Size = UDim2.new(0,13,0,13)
closeBtn.Font = Enum.Font.GothamBold; closeBtn.Text = ""
closeBtn.TextColor3 = Color3.fromRGB(255,255,255); closeBtn.TextSize = 18
closeBtn.ZIndex = 32; closeBtn.AutoButtonColor = false
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = closeBtn end

-- Clean hover / press feedback for traffic-light buttons
do
    local function bindTrafficHover(btn, baseColor, hoverColor)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = hoverColor,
                BackgroundTransparency = 0,
                Size = UDim2.new(0, 14, 0, 14),
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = baseColor,
                BackgroundTransparency = 0.08,
                Size = UDim2.new(0, 13, 0, 13),
            }):Play()
        end)
        btn.MouseButton1Down:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.08), {
                Size = UDim2.new(0, 11, 0, 11),
                BackgroundTransparency = 0.2,
            }):Play()
        end)
        btn.MouseButton1Up:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 14, 0, 14),
                BackgroundTransparency = 0,
            }):Play()
        end)
    end
    bindTrafficHover(minimizeBtn, Color3.fromRGB(210, 210, 210), Color3.fromRGB(240, 240, 240))
    bindTrafficHover(closeBtn, Color3.fromRGB(160, 160, 160), Color3.fromRGB(230, 230, 230))
end

-- Reanimate toggle lives in the title bar so it's always visible even when minimized
local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Parent = TitleBar
ToggleBtn.Name = "ReanimToggleBtn"
ToggleBtn.AnchorPoint = Vector2.new(1, 0.5)
ToggleBtn.Position = UDim2.new(1, -54, 0.5, 0)
ToggleBtn.Size = UDim2.new(0, 52, 0, 24)
ToggleBtn.BackgroundColor3 = C.bg3; ToggleBtn.BackgroundTransparency = 0.05
ToggleBtn.BorderSizePixel = 0; ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "OFF"; ToggleBtn.TextColor3 = C.text2
ToggleBtn.TextSize = 11; ToggleBtn.ZIndex = 33; ToggleBtn.AutoButtonColor = false
ToggleBtn.Visible = true
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = ToggleBtn end

-- AnimRecorder Button (right side of title bar)
local AnimRecorderBtn = Instance.new("TextButton"); AnimRecorderBtn.Parent = TitleBar
AnimRecorderBtn.Name = "AnimRecorderBtn"
AnimRecorderBtn.AnchorPoint = Vector2.new(1, 0.5)
AnimRecorderBtn.Position = UDim2.new(1, -114, 0.5, 0)
AnimRecorderBtn.Size = UDim2.new(0, 72, 0, 24)
AnimRecorderBtn.BackgroundColor3 = C.bg3; AnimRecorderBtn.BackgroundTransparency = 0.05
AnimRecorderBtn.BorderSizePixel = 0; AnimRecorderBtn.Font = Enum.Font.GothamBold
AnimRecorderBtn.Text = "REC"; AnimRecorderBtn.TextColor3 = C.text2
AnimRecorderBtn.TextSize = 10; AnimRecorderBtn.ZIndex = 33; AnimRecorderBtn.AutoButtonColor = false
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,7); c.Parent = AnimRecorderBtn end
do
    AnimRecorderBtn.MouseEnter:Connect(function()
        TweenService:Create(AnimRecorderBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = C.bg2,
            BackgroundTransparency = 0,
        }):Play()
    end)
    AnimRecorderBtn.MouseLeave:Connect(function()
        TweenService:Create(AnimRecorderBtn, TweenInfo.new(0.18), {
            BackgroundColor3 = C.bg3,
            BackgroundTransparency = 0.05,
        }):Play()
    end)
end

-- AnimRecorder System
local AnimRecorder = {
    isRecording = false,
    recordedFrames = {},
    startTime = 0,
    recordingConn = nil,
    lastRecordedTime = 0,
    frameInterval = 1/30, -- 30 FPS recording
}

local function getCloneConstraints()
    local clone = ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
    if not clone then return nil end

    local constraints = {}
    for _, descendant in ipairs(clone:GetDescendants()) do
        if descendant:IsA("AnimationConstraint") then
            local attachment = descendant.Attachment1
            if attachment and attachment.Parent then
                constraints[attachment.Parent.Name] = descendant
            end
        elseif descendant:IsA("Motor6D") then
            local childPart = descendant.Part1
            if childPart and childPart.Parent and not constraints[childPart.Name] then
                constraints[childPart.Name] = descendant
            end
        end
    end
    return constraints
end

-- When the AnimCopier is active we set CFrames directly, so constraint.Transform is stale.
-- This helper computes the transform from current part CFrames so recording still works.
local function getConstraintTransformFromParts(constraint)
    if constraint:IsA("Motor6D") then
        local part0 = constraint.Part0
        local part1 = constraint.Part1
        if not part0 or not part1 or not part0.Parent or not part1.Parent then
            return constraint.Transform
        end
        return part0.CFrame * constraint.C0:Inverse() * constraint.C1:Inverse() * part1.CFrame
    else
        local att0 = constraint.Attachment0
        local att1 = constraint.Attachment1
        if not att0 or not att1 or not att0.Parent or not att1.Parent then
            return constraint.Transform
        end
        local world0 = att0.Parent.CFrame * att0.CFrame
        local world1 = att1.Parent.CFrame * att1.CFrame
        return world0:Inverse() * world1
    end
end

local function startRecording()
    if AnimRecorder.isRecording then return end
    if not ReanimateAPI or not ReanimateAPI.is_reanimated() then
        Notify("Recorder", "Please reanimate first!", 3)
        return
    end

    AnimRecorder.isRecording = true
    AnimRecorder.recordedFrames = {}
    AnimRecorder.startTime = tick()
    AnimRecorder.lastRecordedTime = 0

    AnimRecorderBtn.Text = "Stop"
    TweenService:Create(AnimRecorderBtn, TweenInfo.new(0.25), {
        BackgroundColor3 = C.red,
        TextColor3 = C.white
    }):Play()
    Notify("Recorder", "Recording started! Perform your animation.", 3)

    AnimRecorder.recordingConn = RunService.Heartbeat:Connect(function()
        if not AnimRecorder.isRecording then return end

        local elapsed = tick() - AnimRecorder.startTime
        if elapsed - AnimRecorder.lastRecordedTime < AnimRecorder.frameInterval then return end
        AnimRecorder.lastRecordedTime = elapsed

        local constraints = getCloneConstraints()
        if not constraints then return end

        local isCopierActive = _G._HaloAnimCopierActive or false
        local frameData = {}
        for boneName, constraint in pairs(constraints) do
            if constraint and constraint.Parent then
                if isCopierActive then
                    frameData[boneName] = getConstraintTransformFromParts(constraint)
                else
                    frameData[boneName] = constraint.Transform
                end
            end
        end

        table.insert(AnimRecorder.recordedFrames, {
            Time = elapsed,
            Data = frameData
        })
    end)
end

local function stopRecording()
    if not AnimRecorder.isRecording then return end

    AnimRecorder.isRecording = false
    if AnimRecorder.recordingConn then
        AnimRecorder.recordingConn:Disconnect()
        AnimRecorder.recordingConn = nil
    end

    AnimRecorderBtn.Text = "Record"
    TweenService:Create(AnimRecorderBtn, TweenInfo.new(0.25), {
        BackgroundColor3 = C.bg2,
        TextColor3 = C.accent
    }):Play()

    local frameCount = #AnimRecorder.recordedFrames
    if frameCount == 0 then
        Notify("Recorder", "No frames recorded.", 2)
        return
    end

    Notify("Recorder", "Processing " .. tostring(frameCount) .. " frames...", 2)

    -- Anti-crash: wrap everything in pcall so a memory blowup never kills the script
    local success, err = pcall(function()
        local recordedFrames = AnimRecorder.recordedFrames
        local totalDuration = recordedFrames[#recordedFrames].Time
        local SAFE_FRAME_LIMIT = 4000   -- above this we shard into cache files
        local CHUNK_FRAMES = 2000       -- frames per cache shard

        local folder = "ReanimData"
        pcall(function() makefolder(folder) end)
        local stamp = tostring(math.floor(tick()))

        if frameCount > SAFE_FRAME_LIMIT then
            -- CACHE MODE: shard into multiple JSON files so no single table/string ever gets huge
            local shardCount = math.ceil(frameCount / CHUNK_FRAMES)
            local manifest = {
                type = "recorded_cache",
                totalFrames = frameCount,
                duration = totalDuration,
                stamp = stamp,
                parts = {}
            }

            for s = 1, shardCount do
                local startIdx = (s - 1) * CHUNK_FRAMES + 1
                local endIdx = math.min(s * CHUNK_FRAMES, frameCount)
                local partData = {}

                for i = startIdx, endIdx do
                    local frame = recordedFrames[i]
                    local d = {}
                    for boneName, cf in pairs(frame.Data) do
                        d[boneName] = {cf:GetComponents()}
                    end
                    partData[i - startIdx + 1] = {Time = frame.Time, Data = d}
                end

                local partName = folder .. "/RecordedAnim_" .. stamp .. "_part" .. s .. ".json"
                local okWrite, writeErr = pcall(function()
                    writefile(partName, HttpService:JSONEncode(partData))
                end)
                if not okWrite then
                    error("Failed to write cache shard " .. s .. ": " .. tostring(writeErr))
                end
                table.insert(manifest.parts, partName)
                task.wait() -- yield between shards so the scheduler breathes
            end

            local manifestName = folder .. "/RecordedAnim_" .. stamp .. "_manifest.json"
            pcall(function()
                writefile(manifestName, HttpService:JSONEncode(manifest))
            end)

            Notify("Recorder", "Large recording cached! " .. frameCount .. " frames across " .. shardCount .. " files.", 5)
        else
            -- NORMAL MODE: compact Lua return table (original behaviour, but with chunk safety)
            local outputParts = {}
            table.insert(outputParts, "-- " .. tostring(frameCount) .. " keyframes\n")
            table.insert(outputParts, "-- " .. string.format("%.3f", totalDuration) .. " seconds\n")
            table.insert(outputParts, "return {\n")
            table.insert(outputParts, '  ["Animation"] = {\n')

            local yieldEvery = 50
            for i, frame in ipairs(recordedFrames) do
                local frameStr = "    {Time = " .. string.format("%.3f", frame.Time) .. ", Data = {\n"
                for boneName, cf in pairs(frame.Data) do
                    local comps = {cf:GetComponents()}
                    local compStrs = {}
                    for j = 1, 12 do
                        compStrs[j] = string.format("%.6f", comps[j])
                    end
                    frameStr = frameStr .. '      ["' .. boneName .. '"] = CFrame.new(' .. table.concat(compStrs, ", ") .. '),\n'
                end
                frameStr = frameStr .. "    }},\n"
                table.insert(outputParts, frameStr)

                if i % yieldEvery == 0 then
                    task.wait()
                end
            end

            table.insert(outputParts, "  }\n")
            table.insert(outputParts, "}\n")
            local output = table.concat(outputParts)
            outputParts = nil

            local filename = folder .. "/RecordedAnim_" .. stamp .. ".lua"
            pcall(function() writefile(filename, output) end)

            pcall(function()
                if setclipboard then setclipboard(output) end
            end)

            Notify("Recorder", "Saved " .. tostring(frameCount) .. " frames! Copied to clipboard.", 4)
        end
    end)

    if not success then
        warn("[AnimRecorder] Anti-crash triggered:", err)
        -- EMERGENCY FALLBACK: derender into workspace cache no matter what
        task.spawn(function()
            local ok, emergencyErr = pcall(function()
                local folder = "ReanimData"
                pcall(function() makefolder(folder) end)
                local stamp = tostring(math.floor(tick()))
                local shard = 1
                local partData = {}
                local chunkSize = 1000

                for i, frame in ipairs(AnimRecorder.recordedFrames) do
                    local d = {}
                    for boneName, cf in pairs(frame.Data) do
                        d[boneName] = {cf:GetComponents()}
                    end
                    table.insert(partData, {Time = frame.Time, Data = d})

                    if #partData >= chunkSize then
                        local partName = folder .. "/RecordedAnim_Emergency_" .. stamp .. "_part" .. shard .. ".json"
                        pcall(function() writefile(partName, HttpService:JSONEncode(partData)) end)
                        partData = {}
                        shard = shard + 1
                        task.wait()
                    end
                end

                if #partData > 0 then
                    local partName = folder .. "/RecordedAnim_Emergency_" .. stamp .. "_part" .. shard .. ".json"
                    pcall(function() writefile(partName, HttpService:JSONEncode(partData)) end)
                end

                local manifestName = folder .. "/RecordedAnim_Emergency_" .. stamp .. "_manifest.json"
                local manifest = {
                    type = "recorded_cache",
                    totalFrames = #AnimRecorder.recordedFrames,
                    parts = shard,
                    stamp = stamp
                }
                pcall(function() writefile(manifestName, HttpService:JSONEncode(manifest)) end)

                Notify("Recorder", "Emergency cache saved! Check ReanimData folder.", 5)
            end)
            if not ok then
                warn("[AnimRecorder] Emergency fallback ALSO failed:", emergencyErr)
                Notify("Recorder", "CRITICAL: Could not save recording. Data lost.", 5)
            end
        end)
    end
end

AnimRecorderBtn.MouseButton1Click:Connect(function()
    if AnimRecorder.isRecording then
        stopRecording()
    else
        startRecording()
    end
end)

AnimRecorderBtn.MouseEnter:Connect(function()
    if not AnimRecorder.isRecording then
        TweenService:Create(AnimRecorderBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
    end
end)
AnimRecorderBtn.MouseLeave:Connect(function()
    if not AnimRecorder.isRecording then
        TweenService:Create(AnimRecorderBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.1}):Play()
    end
end)

function UpdateToggleBtn()
    if State.isReanimated then
        TweenService:Create(ToggleBtn, TweenInfo.new(0.25), {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0,
            TextColor3 = Color3.fromRGB(0, 0, 0)
        }):Play()
        ToggleBtn.Text = "ON"
    else
        TweenService:Create(ToggleBtn, TweenInfo.new(0.25), {
            BackgroundColor3 = C.bg2,
            BackgroundTransparency = 0.1,
            TextColor3 = C.text2
        }):Play()
        ToggleBtn.Text = "OFF"
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    if type(_G._HaloDoReanimToggle) == "function" then
        _G._HaloDoReanimToggle()
    end
end)
ToggleBtn.MouseEnter:Connect(function()
    if not State.isReanimated then
        pcall(function()
            TweenService:Create(ToggleBtn, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
        end)
    end
end)
ToggleBtn.MouseLeave:Connect(function()
    if not State.isReanimated then
        pcall(function()
            TweenService:Create(ToggleBtn, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.1}):Play()
        end)
    end
end)

local function _HaloTopFixedPos(gui, newHeight)
    local parent = gui.Parent
    if not parent then return gui.Position end
    local pap = parent.AbsolutePosition
    local pas = parent.AbsoluteSize
    local anchor = gui.AnchorPoint
    local pos = gui.Position
    local absY = pap.Y + pos.Y.Scale * pas.Y + pos.Y.Offset
    local minY = pap.Y + anchor.Y * newHeight
    local maxY = pap.Y + pas.Y - (1 - anchor.Y) * newHeight
    local clampedY = math.clamp(absY, minY, maxY)
    return UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, clampedY - pap.Y - pos.Y.Scale * pas.Y)
end

local isMinimized = false
local FULL_SIZE   = UDim2.new(0, CONFIG.UI.DEFAULT_WIDTH, 0, CONFIG.UI.DEFAULT_HEIGHT)
local MINI_SIZE   = UDim2.new(0, CONFIG.UI.DEFAULT_WIDTH, 0, 40)
-- Do not force Menu.Size here — entrance tween owns the initial size
-- Close/open anims stored on _G to avoid burning main-chunk local registers

_G._HaloReanimCloseMenu = function()
    if _G._HaloMenuClosing then return end
    _G._HaloMenuClosing = true
    local curSize = Menu.AbsoluteSize
    local closeInfo = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    pcall(function()
        local stroke = Menu:FindFirstChildOfClass("UIStroke")
        if stroke then
            TweenService:Create(stroke, closeInfo, {Transparency = 1}):Play()
        end
        local shadow = Menu:FindFirstChild("Shadow")
        if shadow and shadow:IsA("ImageLabel") then
            TweenService:Create(shadow, closeInfo, {ImageTransparency = 1}):Play()
        end
        TweenService:Create(Menu, closeInfo, {
            Size = UDim2.new(0, math.floor(curSize.X * 0.88), 0, math.floor(curSize.Y * 0.88)),
            BackgroundTransparency = 1,
        }):Play()
    end)
    task.delay(0.34, function()
        Menu.Visible = false
        ScreenGui.Enabled = false
        _G._HaloMenuClosing = false
        Menu.Size = FULL_SIZE
        Menu.BackgroundTransparency = 0.08
        local stroke = Menu:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Transparency = 0.15 end
        local shadow = Menu:FindFirstChild("Shadow")
        if shadow and shadow:IsA("ImageLabel") then shadow.ImageTransparency = 0.45 end
    end)
end

_G._HaloReanimOpenMenu = function()
    if _G._HaloMenuClosing then return end
    ScreenGui.Enabled = true
    Menu.Visible = true
    isMinimized = false
    if body then body.Visible = true end
    local targetW = FULL_SIZE.X.Offset
    local targetH = FULL_SIZE.Y.Offset
    Menu.Size = UDim2.new(0, math.floor(targetW * 0.90), 0, math.floor(targetH * 0.90))
    Menu.BackgroundTransparency = 1
    local openInfo = TweenInfo.new(0.40, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    pcall(function()
        local stroke = Menu:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Transparency = 1
            TweenService:Create(stroke, openInfo, {Transparency = 0.15}):Play()
        end
        local shadow = Menu:FindFirstChild("Shadow")
        if shadow and shadow:IsA("ImageLabel") then
            shadow.ImageTransparency = 1
            TweenService:Create(shadow, openInfo, {ImageTransparency = 0.45}):Play()
        end
        TweenService:Create(Menu, openInfo, {
            Size = FULL_SIZE,
            BackgroundTransparency = 0.08,
        }):Play()
    end)
end

closeBtn.MouseButton1Click:Connect(_G._HaloReanimCloseMenu)

do
    -- DRAG SYSTEM (improved)
    -- - Reliable release via UserInputService.InputEnded (fixes accidental de-drag)
    -- - Optional smooth drag (lerp) controlled from Settings
    -- - Can be fully disabled from Settings for laggy devices
    _G._HaloDragEnabled = (_G._HaloDragEnabled == nil) and true or _G._HaloDragEnabled
    _G._HaloSmoothDrag  = (_G._HaloSmoothDrag == nil) and true or _G._HaloSmoothDrag

    local dragging = false
    local dragInputStart
    local startAnchorAbsPos
    local targetAbsX, targetAbsY
    local smoothConn

    local function getAnchorAbsPosition()
        local parent = Menu.Parent
        if not parent then return Vector2.zero end
        local parentAbsPos = parent.AbsolutePosition
        local parentAbsSize = parent.AbsoluteSize
        local pos = Menu.Position
        local x = parentAbsPos.X + pos.X.Scale * parentAbsSize.X + pos.X.Offset
        local y = parentAbsPos.Y + pos.Y.Scale * parentAbsSize.Y + pos.Y.Offset
        return Vector2.new(x, y)
    end

    local function setClampedPosition(absX, absY, instant)
        local parent = Menu.Parent
        if not parent then return end
        local parentAbsPos = parent.AbsolutePosition
        local parentAbsSize = parent.AbsoluteSize
        local absSize = Menu.AbsoluteSize
        local anchor = Menu.AnchorPoint
        local minX = parentAbsPos.X + anchor.X * absSize.X
        local maxX = parentAbsPos.X + parentAbsSize.X - (1 - anchor.X) * absSize.X
        local minY = parentAbsPos.Y + anchor.Y * absSize.Y
        local maxY = parentAbsPos.Y + parentAbsSize.Y - (1 - anchor.Y) * absSize.Y
        local x = math.clamp(absX, minX, maxX)
        local y = math.clamp(absY, minY, maxY)

        if instant or not _G._HaloSmoothDrag then
            Menu.Position = UDim2.new(0, x - parentAbsPos.X, 0, y - parentAbsPos.Y)
        else
            targetAbsX, targetAbsY = x, y
        end
    end

    local function stopSmooth()
        if smoothConn then
            smoothConn:Disconnect()
            smoothConn = nil
        end
    end

    local function startSmooth()
        stopSmooth()
        if not _G._HaloSmoothDrag then return end
        smoothConn = RunService.RenderStepped:Connect(function(dt)
            if not dragging and not targetAbsX then
                stopSmooth()
                return
            end
            if not targetAbsX then return end
            local parent = Menu.Parent
            if not parent then return end
            local parentAbsPos = parent.AbsolutePosition
            local cur = getAnchorAbsPosition()
            local alpha = math.clamp(dt * 18, 0, 1) -- snappy but smooth
            local nx = cur.X + (targetAbsX - cur.X) * alpha
            local ny = cur.Y + (targetAbsY - cur.Y) * alpha
            Menu.Position = UDim2.new(0, nx - parentAbsPos.X, 0, ny - parentAbsPos.Y)
            if (math.abs(targetAbsX - nx) < 0.4 and math.abs(targetAbsY - ny) < 0.4) and not dragging then
                Menu.Position = UDim2.new(0, targetAbsX - parentAbsPos.X, 0, targetAbsY - parentAbsPos.Y)
                targetAbsX, targetAbsY = nil, nil
                stopSmooth()
            end
        end)
    end

    TitleBar.InputBegan:Connect(function(input)
        if not _G._HaloDragEnabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInputStart = input.Position
            startAnchorAbsPos = getAnchorAbsPosition()
            targetAbsX, targetAbsY = startAnchorAbsPos.X, startAnchorAbsPos.Y
            if _G._HaloSmoothDrag then startSmooth() end
        end
    end)

    -- Global release — more reliable than input.Changed alone (fixes de-drag while still holding)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                -- let smooth settle to final target
                if not _G._HaloSmoothDrag then
                    targetAbsX, targetAbsY = nil, nil
                    stopSmooth()
                end
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or not _G._HaloDragEnabled then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragInputStart
            setClampedPosition(startAnchorAbsPos.X + delta.X, startAnchorAbsPos.Y + delta.Y, false)
        end
    end)
end

body = Instance.new("Frame"); body.Parent = Menu
body.BackgroundTransparency = 1; body.Position = UDim2.new(0,0,0,48)
body.Size = UDim2.new(1,0,1,-56); body.ZIndex = 31

minimizeBtn.MouseButton1Click:Connect(function()
    if _G._HaloMenuClosing then return end
    isMinimized = not isMinimized
    local ti = TweenInfo.new(0.36, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    if isMinimized then
        body.Visible = false
        TweenService:Create(Menu, ti, {
            Size = MINI_SIZE,
            Position = _HaloTopFixedPos(Menu, MINI_SIZE.Y.Offset),
        }):Play()
    else
        TweenService:Create(Menu, ti, {
            Size = FULL_SIZE,
            Position = _HaloTopFixedPos(Menu, FULL_SIZE.Y.Offset),
        }):Play()
        task.delay(0.22, function()
            if not isMinimized then
                body.Visible = true
            end
        end)
    end
end)

local toggleBar = Instance.new("Frame"); toggleBar.Parent = body
toggleBar.BackgroundColor3 = C.bg1; toggleBar.BackgroundTransparency = 0.4
toggleBar.BorderSizePixel = 0; toggleBar.Size = UDim2.new(1,-20,0,30)
toggleBar.Position = UDim2.new(0,10,0,6); toggleBar.ZIndex = 32
do 
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,8); c.Parent = toggleBar
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.6; s.Thickness = 1; s.Parent = toggleBar
end

local reanimLabel = Instance.new("TextLabel"); reanimLabel.Parent = toggleBar
reanimLabel.BackgroundTransparency = 1; reanimLabel.Position = UDim2.new(0,12,0,0)
reanimLabel.Size = UDim2.new(0.55,0,1,0); reanimLabel.Font = Enum.Font.GothamBold
reanimLabel.Text = "Reanimation"; reanimLabel.TextColor3 = C.text
reanimLabel.TextSize = 12; reanimLabel.TextXAlignment = Enum.TextXAlignment.Left; reanimLabel.ZIndex = 33

-- ToggleBtn is now in the TitleBar (always visible). The toggleBar in the body
-- keeps its label for context but no longer holds a second button.

function _attachPlayRawAnimation()
    -- disabled
end

local _activating = false
local _lastToggleAt = 0

function _smoothToggle(callFn)
    local cam = workspace.CurrentCamera
    local char = plr.Character
    local savedHRP, savedCam

    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then savedHRP = hrp.CFrame end
    end
    if cam then savedCam = cam.CFrame end

    callFn()

    local frames = 0
    local conn
    conn = RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
        frames = frames + 1
        local c2 = plr.Character
        local hrp2 = c2 and c2:FindFirstChild("HumanoidRootPart")
        if hrp2 and savedHRP then
            hrp2.CFrame = savedHRP
        end
        local cam2 = workspace.CurrentCamera
        if cam2 and savedCam then
            cam2.CFrame = savedCam
        end
        if frames >= 6 then
            conn:Disconnect()
        end
    end))
end

-- Shared reanimate toggle logic — called by ToggleBtn in TitleBar
local _activating = false
local _lastToggleAt = 0

local function doReanimToggle()
    if _activating then return end
    if tick() - _lastToggleAt < 0.75 then return end
    _lastToggleAt = tick()

    if State.isReanimated then
        _activating = true
        task.spawn(function()
            if stopStateSystem then pcall(stopStateSystem) end
            ReanimateAPI.reanimate(false)
            State.isReanimated = false
            State.selectedAnim = nil
            _activating = false
            UpdateToggleBtn()
            Notify("Reanimation disabled")
        end)
        return
    end

    _activating = true
    task.spawn(function()
        local res = ReanimateAPI.reanimate(true)
        State.isReanimated = ReanimateAPI.is_reanimated()
        UpdateToggleBtn()

        if not State.isReanimated then
            _activating = false
            Notify("Reanimation failed: " .. tostring(res or "Unknown error"), 4)
            return
        end

        task.spawn(function()
            if prefetchAllStates then pcall(prefetchAllStates) end
            if StateAnims and next(StateAnims) and startStateSystem then
                pcall(startStateSystem)
            end
        end)
        _activating = false
        Notify("Reanimation enabled!", 2)
    end)
end

-- Expose for the title-bar toggle button
_G._HaloDoReanimToggle = doReanimToggle

-- GrabStatus click fix: when reanimated, your own clone/real character can
-- block the game's click raycast. We do our OWN raycast from the camera through
-- the mouse position, explicitly excluding both your clone and real character,
-- then fire GrabStatus:InvokeServer(userId) for whichever player we hit.
do
    local _grabRemote = nil

    local function _getGrabRemote()
        if _grabRemote and _grabRemote.Parent then return _grabRemote end
        local ok, r = pcall(function()
            return game:GetService("ReplicatedStorage"):FindFirstChild("GrabStatus")
        end)
        if ok and r then _grabRemote = r end
        return _grabRemote
    end

    -- Find which player owns the model that contains `inst`
    local function _getPlayerFromInstance(inst)
        local Players = game:GetService("Players")
        local model = inst and inst:FindFirstAncestorOfClass("Model")
        while model do
            local p = Players:GetPlayerFromCharacter(model)
            if p and p ~= plr then return p end
            model = model:FindFirstAncestorOfClass("Model")
        end
        -- Fallback: descendant check
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= plr and p.Character and inst and inst:IsDescendantOf(p.Character) then
                return p
            end
        end
        return nil
    end

    local _mouse = plr:GetMouse()
    _mouse.Button1Down:Connect(function()
        if not State.isReanimated then return end
        local remote = _getGrabRemote()
        if not remote then return end

        local cam = workspace.CurrentCamera
        if not cam then return end

        -- Build exclusion list: our clone + real char (and current Character)
        local exclude = {}
        pcall(function()
            if _G._HaloReanimateAPI then
                local clone = _G._HaloReanimateAPI.get_clone and _G._HaloReanimateAPI.get_clone(plr)
                local realc = _G._HaloReanimateAPI.get_real_character and _G._HaloReanimateAPI.get_real_character(plr)
                if clone then table.insert(exclude, clone) end
                if realc then table.insert(exclude, realc) end
            end
        end)
        if plr.Character then table.insert(exclude, plr.Character) end

        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = exclude
        rayParams.IgnoreWater = true

        local unitRay = cam:ViewportPointToRay(_mouse.X, _mouse.Y)
        local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 5000, rayParams)

        local targetPlayer = nil
        if result and result.Instance then
            targetPlayer = _getPlayerFromInstance(result.Instance)
        end
        -- Fallback to Mouse.Target if raycast missed
        if not targetPlayer and _mouse.Target then
            targetPlayer = _getPlayerFromInstance(_mouse.Target)
        end

        if targetPlayer then
            pcall(function() remote:InvokeServer(targetPlayer.UserId) end)
        end
    end)
end

local npBar = Instance.new("Frame"); npBar.Parent = body
npBar.BackgroundColor3 = C.bg1; npBar.BackgroundTransparency = 0.2
npBar.BorderSizePixel = 0; npBar.Size = UDim2.new(1,-20,0,28)
npBar.Position = UDim2.new(0,10,0,42); npBar.ZIndex = 32
do 
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,8); c.Parent = npBar
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.55; s.Thickness = 1; s.Parent = npBar
end

NowPlayingLabel = Instance.new("TextLabel"); NowPlayingLabel.Parent = npBar
NowPlayingLabel.BackgroundTransparency = 1; NowPlayingLabel.Position = UDim2.new(0,10,0,0)
NowPlayingLabel.Size = UDim2.new(1,-78,1,0); NowPlayingLabel.Font = Enum.Font.GothamMedium
NowPlayingLabel.Text = "Nothing playing"
NowPlayingLabel.TextColor3 = C.text3
NowPlayingLabel.TextSize = 11; NowPlayingLabel.TextXAlignment = Enum.TextXAlignment.Left
NowPlayingLabel.TextTruncate = Enum.TextTruncate.AtEnd; NowPlayingLabel.ZIndex = 33

StopBtn = Instance.new("TextButton"); StopBtn.Parent = npBar
StopBtn.AnchorPoint = Vector2.new(1,0.5); StopBtn.BackgroundColor3 = C.bg3
StopBtn.BackgroundTransparency = 0.1; StopBtn.BorderSizePixel = 0
StopBtn.Position = UDim2.new(1,-6,0.5,0); StopBtn.Size = UDim2.new(0,52,0,20)
StopBtn.Font = Enum.Font.GothamBold; StopBtn.Text = "STOP"
StopBtn.TextColor3 = C.text2; StopBtn.TextSize = 10
StopBtn.ZIndex = 33; StopBtn.AutoButtonColor = false
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = StopBtn end

local tabRow = Instance.new("ScrollingFrame"); tabRow.Parent = body
tabRow.Name = "TabRow"
tabRow.BackgroundTransparency = 1
tabRow.BorderSizePixel = 0
tabRow.Size = UDim2.new(1,-20,0,26)
tabRow.Position = UDim2.new(0,10,0,74); tabRow.ZIndex = 32
tabRow.ScrollingDirection = Enum.ScrollingDirection.X
tabRow.ScrollBarThickness = 0
tabRow.CanvasSize = UDim2.new(0,0,0,0)
tabRow.ClipsDescendants = true
tabRow.ElasticBehavior = Enum.ElasticBehavior.Always

local tabLayout = Instance.new("UIListLayout"); tabLayout.Parent = tabRow
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0,4)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

local tabPadding = Instance.new("UIPadding"); tabPadding.Parent = tabRow
tabPadding.PaddingLeft = UDim.new(0,2)
tabPadding.PaddingRight = UDim.new(0,2)

tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    tabRow.CanvasSize = UDim2.new(0, tabLayout.AbsoluteContentSize.X + 8, 0, 0)
end)

local TAB_DEFS = { "All", "Favs", "Custom", "Binds", "States", "Speed", "Copier", "Tracking", "Stretching", "Settings" }
TabButtons = {}
local activeTab = nil

SetTabActive = function(btn)
    if not btn then return end
    if activeTab and activeTab ~= btn then
        local oldLine = activeTab:FindFirstChild("Underline")
        TweenService:Create(activeTab, TweenInfo.new(0.2), {TextColor3 = C.text3, BackgroundTransparency = 1}):Play()
        if oldLine then
            TweenService:Create(oldLine, TweenInfo.new(0.2), {BackgroundTransparency = 1, Size = UDim2.new(0,0,0,2)}):Play()
        end
    end
    activeTab = btn
    local newLine = btn:FindFirstChild("Underline")
    TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {TextColor3 = C.white, BackgroundTransparency = 0.72}):Play()
    if newLine then
        TweenService:Create(newLine, TweenInfo.new(0.28, Enum.EasingStyle.Quint), {BackgroundTransparency = 0, Size = UDim2.new(0.65,0,0,2)}):Play()
    end
    
    -- Auto-scroll tabRow to ensure active tab is in view
    task.defer(function()
        pcall(function()
            local btnX = btn.AbsolutePosition.X - tabRow.AbsolutePosition.X + tabRow.CanvasPosition.X
            local btnW = btn.AbsoluteSize.X
            local visibleW = tabRow.AbsoluteSize.X
            if btnX < tabRow.CanvasPosition.X then
                tabRow.CanvasPosition = Vector2.new(math.max(0, btnX - 10), 0)
            elseif btnX + btnW > tabRow.CanvasPosition.X + visibleW then
                tabRow.CanvasPosition = Vector2.new(btnX + btnW - visibleW + 10, 0)
            end
        end)
    end)
end

for idx, tname in ipairs(TAB_DEFS) do
    local tb = Instance.new("TextButton"); tb.Parent = tabRow
    tb.BackgroundColor3 = C.bg2; tb.BackgroundTransparency = 1
    tb.BorderSizePixel = 0
    tb.Size = UDim2.new(0, math.max(48, #tname * 7 + 18), 0, 24)
    tb.LayoutOrder = idx
    tb.Font = Enum.Font.GothamMedium; tb.Text = tname:upper()
    tb.TextColor3 = C.text3; tb.TextSize = 10
    tb.ZIndex = 33; tb.AutoButtonColor = false
    do 
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 7); c.Parent = tb
    end
    local underline = Instance.new("Frame"); underline.Name = "Underline"
    underline.Parent = tb; underline.BackgroundColor3 = C.white
    underline.BackgroundTransparency = 1; underline.BorderSizePixel = 0
    underline.Position = UDim2.new(0.5,0,1,-1); underline.AnchorPoint = Vector2.new(0.5,0)
    underline.Size = UDim2.new(0,0,0,2); underline.ZIndex = 34
    do local uc = Instance.new("UICorner"); uc.CornerRadius = UDim.new(1,0); uc.Parent = underline end
    tb.MouseEnter:Connect(function()
        if activeTab ~= tb then
            TweenService:Create(tb, TweenInfo.new(0.14, Enum.EasingStyle.Quint), {TextColor3 = C.text, BackgroundTransparency = 0.82}):Play()
            TweenService:Create(underline, TweenInfo.new(0.14, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.45, Size = UDim2.new(0.55,0,0,2)}):Play()
        end
    end)
    tb.MouseLeave:Connect(function()
        if activeTab ~= tb then
            TweenService:Create(tb, TweenInfo.new(0.14, Enum.EasingStyle.Quint), {TextColor3 = C.text3, BackgroundTransparency = 1}):Play()
            TweenService:Create(underline, TweenInfo.new(0.14, Enum.EasingStyle.Quint), {BackgroundTransparency = 1, Size = UDim2.new(0,0,0,2)}):Play()
        end
    end)
    TabButtons[tname] = tb
end

tabRow.CanvasSize = UDim2.new(0, tabLayout.AbsoluteContentSize.X + 8, 0, 0)

-- Function to update Custom tab text with animation count
local function UpdateCustomTabCount()
    local customBtn = TabButtons["Custom"]
    if customBtn then
        customBtn.Text = "CUSTOM"
    end
end

-- ============================================
-- TAB GRID MODE (jump to any tab without scrolling)
-- Toggle from Settings. When ON, horizontal TabRow is hidden
-- and a compact grid of all tabs is shown instead.
-- ============================================
_G._HaloTabGridMode = (_G._HaloTabGridMode == nil) and false or _G._HaloTabGridMode

local TabGrid = Instance.new("Frame")
TabGrid.Name = "TabGrid"
TabGrid.Parent = body
TabGrid.BackgroundColor3 = C.bg1
TabGrid.BackgroundTransparency = 0.12
TabGrid.BorderSizePixel = 0
TabGrid.Size = UDim2.new(1, -20, 0, 0) -- height set dynamically
TabGrid.Position = UDim2.new(0, 10, 0, 74)
TabGrid.ZIndex = 32
TabGrid.Visible = false
TabGrid.ClipsDescendants = true
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 8); c.Parent = TabGrid
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.65; s.Thickness = 1; s.Parent = TabGrid
end

local gridLayout = Instance.new("UIGridLayout")
gridLayout.Parent = TabGrid
gridLayout.CellSize = UDim2.new(0, 80, 0, 28)
gridLayout.CellPadding = UDim2.new(0, 4, 0, 4)
gridLayout.FillDirectionMaxCells = 4
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.FillDirection = Enum.FillDirection.Horizontal

local gridPad = Instance.new("UIPadding")
gridPad.Parent = TabGrid
gridPad.PaddingTop = UDim.new(0, 6)
gridPad.PaddingBottom = UDim.new(0, 6)
gridPad.PaddingLeft = UDim.new(0, 6)
gridPad.PaddingRight = UDim.new(0, 6)

local GridButtons = {}
for idx, tname in ipairs(TAB_DEFS) do
    local gb = Instance.new("TextButton")
    gb.Parent = TabGrid
    gb.BackgroundColor3 = C.bg2
    gb.BackgroundTransparency = 0.55
    gb.BorderSizePixel = 0
    gb.LayoutOrder = idx
    gb.Font = Enum.Font.GothamBold
    gb.Text = tname:upper()
    gb.TextColor3 = C.text3
    gb.TextSize = 10
    gb.ZIndex = 33
    gb.AutoButtonColor = false
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = gb
        local st = Instance.new("UIStroke"); st.Name = "Stroke"; st.Color = C.border; st.Transparency = 0.7; st.Thickness = 1; st.Parent = gb
    end
    gb.MouseEnter:Connect(function()
        if GridButtons._active ~= gb then
            TweenService:Create(gb, TweenInfo.new(0.15), {BackgroundTransparency = 0.35, TextColor3 = C.text}):Play()
        end
    end)
    gb.MouseLeave:Connect(function()
        if GridButtons._active ~= gb then
            TweenService:Create(gb, TweenInfo.new(0.15), {BackgroundTransparency = 0.55, TextColor3 = C.text3}):Play()
        end
    end)
    GridButtons[tname] = gb
end

local function refreshTabGridHeight()
    local rows = math.ceil(#TAB_DEFS / 4)
    local h = rows * 26 + (rows - 1) * 4 + 12
    TabGrid.Size = UDim2.new(1, -20, 0, h)
end
refreshTabGridHeight()

local function setTabGridMode(on)
    _G._HaloTabGridMode = on and true or false
    tabRow.Visible = not _G._HaloTabGridMode
    TabGrid.Visible = _G._HaloTabGridMode
    -- push content below tabs
    local tabBottom = _G._HaloTabGridMode and (74 + TabGrid.Size.Y.Offset + 6) or 104
    -- SearchBox / hint default positions will be adjusted in SwitchTab via noSearch logic;
    -- also nudge SearchBox base Y when grid is open
    if SearchBox then
        SearchBox.Position = UDim2.new(0, 10, 0, tabBottom)
    end
    if hintLbl then
        hintLbl.Position = UDim2.new(0, 10, 0, tabBottom + 30)
    end
end

local function setGridActive(tname)
    for name, gb in pairs(GridButtons) do
        if type(gb) == "Instance" then
            local st = gb:FindFirstChild("Stroke")
            if name == tname then
                GridButtons._active = gb
                TweenService:Create(gb, TweenInfo.new(0.2), {BackgroundTransparency = 0.15, TextColor3 = C.accent}):Play()
                if st then TweenService:Create(st, TweenInfo.new(0.2), {Color = C.accent, Transparency = 0.3}):Play() end
            else
                TweenService:Create(gb, TweenInfo.new(0.2), {BackgroundTransparency = 0.55, TextColor3 = C.text3}):Play()
                if st then TweenService:Create(st, TweenInfo.new(0.2), {Color = C.border, Transparency = 0.7}):Play() end
            end
        end
    end
end

-- Apply initial mode
task.defer(function()
    setTabGridMode(_G._HaloTabGridMode)
end)

_G._HaloSetTabGridMode = setTabGridMode
_G._HaloSetGridActive = setGridActive

SearchBox = Instance.new("TextBox"); SearchBox.Parent = body
SearchBox.BackgroundColor3 = C.bg1; SearchBox.BackgroundTransparency = 0.15
SearchBox.BorderSizePixel = 0; SearchBox.Size = UDim2.new(1,-20,0,28)
SearchBox.Position = UDim2.new(0,10,0,104); SearchBox.ZIndex = 32
SearchBox.Font = Enum.Font.GothamMedium; SearchBox.PlaceholderText = "Search animations..."
SearchBox.PlaceholderColor3 = C.text3; SearchBox.Text = ""
SearchBox.TextColor3 = C.text; SearchBox.TextSize = 12
SearchBox.ClearTextOnFocus = false
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,8); c.Parent = SearchBox
    local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0,12); p.Parent = SearchBox
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.45; s.Thickness = 1; s.Parent = SearchBox
end

hintLbl = Instance.new("TextLabel"); hintLbl.Parent = body
hintLbl.BackgroundTransparency = 1; hintLbl.Size = UDim2.new(1,-20,0,12)
hintLbl.Position = UDim2.new(0,10,0,134); hintLbl.ZIndex = 32; hintLbl.Font = Enum.Font.Gotham
hintLbl.Text = "Click [+] to bind key  |  Click bound key to unbind"
hintLbl.TextColor3 = C.text3; hintLbl.TextSize = 9
hintLbl.TextXAlignment = Enum.TextXAlignment.Left

AnimListFrame = Instance.new("ScrollingFrame"); AnimListFrame.Parent = body
AnimListFrame.BackgroundColor3 = C.bg0; AnimListFrame.BackgroundTransparency = 0.15
AnimListFrame.BorderSizePixel = 0
AnimListFrame.Size = UDim2.new(1,-20,1,-236)
AnimListFrame.Position = UDim2.new(0,10,0,148)
AnimListFrame.ScrollBarThickness = 3; AnimListFrame.ScrollBarImageColor3 = C.white
AnimListFrame.ScrollBarImageTransparency = 0.55; AnimListFrame.ZIndex = 32
AnimListFrame.CanvasSize = UDim2.new(0,0,0,0)
AnimListFrame.ScrollingDirection = getSafeScrollingDirection("Y")
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,10); c.Parent = AnimListFrame end

-- States panel stays inside the main reanim UI and expands inline pickers.
StatesPanel = Instance.new("ScrollingFrame"); StatesPanel.Name = "StatesSection"
StatesPanel.BackgroundTransparency = 1; StatesPanel.BorderSizePixel = 0
StatesPanel.Size = UDim2.new(1,0,0,0); StatesPanel.AutomaticSize = getSafeAutomaticSize()
StatesPanel.ZIndex = 32; StatesPanel.LayoutOrder = 100
StatesPanel.ScrollBarThickness = 4; StatesPanel.ScrollBarImageColor3 = C.accent
StatesPanel.ScrollBarImageTransparency = 0.5; StatesPanel.CanvasSize = UDim2.new(0,0,0,0)
do
    local l = Instance.new("UIListLayout"); l.Parent = StatesPanel
    l.Padding = UDim.new(0,4); l.SortOrder = Enum.SortOrder.LayoutOrder
    local p = Instance.new("UIPadding"); p.Parent = StatesPanel
    p.PaddingTop = UDim.new(0,4); p.PaddingLeft = UDim.new(0,2); p.PaddingRight = UDim.new(0,2); p.PaddingBottom = UDim.new(0,8)
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        StatesPanel.CanvasSize = UDim2.new(0,0,0,l.AbsoluteContentSize.Y+16)
    end)
end

CustomPanel = Instance.new("Frame"); CustomPanel.Parent = body
CustomPanel.BackgroundTransparency = 1
CustomPanel.Size = UDim2.new(1,-20,1,-236)
CustomPanel.Position = UDim2.new(0,10,0,148)
CustomPanel.ZIndex = 32; CustomPanel.Visible = false

-- BindsPanel: shows all animations with keybinds set
BindsPanel = Instance.new("ScrollingFrame"); BindsPanel.Parent = body
BindsPanel.Name = "BindsPanel"
BindsPanel.BackgroundColor3 = C.bg0; BindsPanel.BackgroundTransparency = 0.15
BindsPanel.BorderSizePixel = 0
BindsPanel.Size = UDim2.new(1,-20,1,-156)
BindsPanel.Position = UDim2.new(0,10,0,148)
BindsPanel.ScrollBarThickness = 4; BindsPanel.ScrollBarImageColor3 = C.accent
BindsPanel.ScrollBarImageTransparency = 0.5; BindsPanel.ZIndex = 32
BindsPanel.CanvasSize = UDim2.new(0,0,0,0); BindsPanel.Visible = false
BindsPanel.ScrollingDirection = getSafeScrollingDirection("Y")
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,7); c.Parent = BindsPanel end

customSearchBox = Instance.new("TextBox"); customSearchBox.Parent = CustomPanel
customSearchBox.BackgroundColor3 = C.bg1; customSearchBox.BackgroundTransparency = 0.4
customSearchBox.BorderSizePixel = 0; customSearchBox.Size = UDim2.new(1,0,0,26)
customSearchBox.Position = UDim2.new(0,0,0,0); customSearchBox.ZIndex = 32
customSearchBox.Font = Enum.Font.GothamMedium; customSearchBox.PlaceholderText = "Search custom animations..."
customSearchBox.PlaceholderColor3 = C.text3; customSearchBox.Text = ""
customSearchBox.TextColor3 = C.text; customSearchBox.TextSize = 11
customSearchBox.ClearTextOnFocus = false
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = customSearchBox
    local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0,10); p.Parent = customSearchBox
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = customSearchBox
end

customOpenModalBtn = Instance.new("TextButton"); customOpenModalBtn.Parent = CustomPanel
customOpenModalBtn.BackgroundColor3 = C.bg2
customOpenModalBtn.BackgroundTransparency = 0.3; customOpenModalBtn.BorderSizePixel = 0
customOpenModalBtn.Size = UDim2.new(1,-92,0,36); customOpenModalBtn.Position = UDim2.new(0,0,0,30)
customOpenModalBtn.Font = Enum.Font.GothamBold; customOpenModalBtn.Text = "+  Add Custom Animation"
customOpenModalBtn.TextColor3 = C.accent; customOpenModalBtn.TextSize = 12
customOpenModalBtn.ZIndex = 33; customOpenModalBtn.AutoButtonColor = false
do 
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,8); c.Parent = customOpenModalBtn
    local s = Instance.new("UIStroke"); s.Color = C.accent; s.Transparency = 0.7; s.Thickness = 1; s.Parent = customOpenModalBtn
end
customOpenModalBtn.MouseEnter:Connect(function()
    TweenService:Create(customOpenModalBtn, TweenInfo.new(0.12), {BackgroundColor3 = C.accent, BackgroundTransparency = 0.2, TextColor3 = Color3.fromRGB(10,10,10)}):Play()
    TweenService:Create(customOpenModalBtn:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.12), {Transparency = 0}):Play()
end)
customOpenModalBtn.MouseLeave:Connect(function()
    TweenService:Create(customOpenModalBtn, TweenInfo.new(0.12), {BackgroundColor3 = C.bg2, BackgroundTransparency = 0.3, TextColor3 = C.accent}):Play()
    TweenService:Create(customOpenModalBtn:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.12), {Transparency = 0.7}):Play()
end)

-- Refresh button: re-scan the ReanimData folder for newly added custom animations
local customRefreshBtn = Instance.new("TextButton"); customRefreshBtn.Parent = CustomPanel
customRefreshBtn.BackgroundColor3 = C.bg2
customRefreshBtn.BackgroundTransparency = 0.3; customRefreshBtn.BorderSizePixel = 0
customRefreshBtn.Size = UDim2.new(0,84,0,36); customRefreshBtn.Position = UDim2.new(1,-84,0,30)
customRefreshBtn.Font = Enum.Font.GothamBold; customRefreshBtn.Text = "Refresh"
customRefreshBtn.TextColor3 = C.accent; customRefreshBtn.TextSize = 11
customRefreshBtn.ZIndex = 33; customRefreshBtn.AutoButtonColor = false
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,8); c.Parent = customRefreshBtn
    local s = Instance.new("UIStroke"); s.Color = C.accent; s.Transparency = 0.7; s.Thickness = 1; s.Parent = customRefreshBtn
end
customRefreshBtn.MouseEnter:Connect(function()
    TweenService:Create(customRefreshBtn, TweenInfo.new(0.12), {BackgroundColor3 = C.accent, BackgroundTransparency = 0.2, TextColor3 = Color3.fromRGB(10,10,10)}):Play()
    TweenService:Create(customRefreshBtn:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.12), {Transparency = 0}):Play()
end)
customRefreshBtn.MouseLeave:Connect(function()
    TweenService:Create(customRefreshBtn, TweenInfo.new(0.12), {BackgroundColor3 = C.bg2, BackgroundTransparency = 0.3, TextColor3 = C.accent}):Play()
    TweenService:Create(customRefreshBtn:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.12), {Transparency = 0.7}):Play()
end)
customRefreshBtn.MouseButton1Click:Connect(function()
    customRefreshBtn.Text = "..."
    task.spawn(function()
        local prevCount = #CustomAnims
        -- Re-run the loader: it rescans the ReanimData folder for new .lua/.json
        -- files (plus the saved list) and returns the merged set.
        local ok, result = pcall(LoadCustomAnims)
        if ok and type(result) == "table" then
            CustomAnims = result
            table.clear(CustomAnimations)
            for _, ca in ipairs(CustomAnims) do
                CustomAnimations[ca.name] = ca.url
            end
            pcall(SaveCustomAnims)
            -- Update Custom tab count after rescanning
            if UpdateCustomTabCount then
                UpdateCustomTabCount()
            end
        end
        if RebuildCustomList then pcall(RebuildCustomList) end
        local added = #CustomAnims - prevCount
        customRefreshBtn.Text = "Refresh"
        if Notify then
            if added > 0 then
                Notify("Found " .. added .. " new animation" .. (added == 1 and "" or "s"), 2.5)
            else
                Notify("No new animations found", 2)
            end
        end
    end)
end)

customListFrame = Instance.new("ScrollingFrame"); customListFrame.Parent = CustomPanel
customListFrame.BackgroundColor3 = C.bg0; customListFrame.BackgroundTransparency = 0.5
customListFrame.BorderSizePixel = 0; customListFrame.Position = UDim2.new(0,0,0,70)
customListFrame.Size = UDim2.new(1,0,1,-74)
customListFrame.ScrollBarThickness = 4; customListFrame.ScrollBarImageColor3 = C.accent
customListFrame.ScrollBarImageTransparency = 0.5; customListFrame.ZIndex = 33
customListFrame.CanvasSize = UDim2.new(0,0,0,0)
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,7); c.Parent = customListFrame
    -- No UIListLayout: rows are positioned absolutely so the custom list can be
    -- virtualized (only visible rows exist). CanvasSize is managed manually in
    -- RebuildCustomList.
end

SettingsPanel = Instance.new("ScrollingFrame"); SettingsPanel.Parent = body
SettingsPanel.Name = "SettingsPanel"
SettingsPanel.BackgroundColor3 = C.bg0; SettingsPanel.BackgroundTransparency = 0.15
SettingsPanel.BorderSizePixel = 0
SettingsPanel.Size = UDim2.new(1,-20,1,-236)
SettingsPanel.Position = UDim2.new(0,10,0,148)
SettingsPanel.ScrollBarThickness = 4; SettingsPanel.ScrollBarImageColor3 = C.accent
SettingsPanel.ScrollBarImageTransparency = 0.5; SettingsPanel.ZIndex = 32
SettingsPanel.CanvasSize = UDim2.new(0,0,0,0); SettingsPanel.Visible = false
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,7); c.Parent = SettingsPanel
    local l = Instance.new("UIListLayout"); l.Parent = SettingsPanel
    l.Padding = UDim.new(0,8); l.SortOrder = Enum.SortOrder.LayoutOrder
    local p = Instance.new("UIPadding"); p.Parent = SettingsPanel
    p.PaddingTop = UDim.new(0,8); p.PaddingLeft = UDim.new(0,8); p.PaddingRight = UDim.new(0,8)
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SettingsPanel.CanvasSize = UDim2.new(0,0,0,l.AbsoluteContentSize.Y+16)
    end)
end

SpeedPanel = Instance.new("ScrollingFrame"); SpeedPanel.Parent = body
SpeedPanel.Name = "SpeedPanel"
SpeedPanel.BackgroundColor3 = C.bg0; SpeedPanel.BackgroundTransparency = 0.15
SpeedPanel.BorderSizePixel = 0
SpeedPanel.Size = UDim2.new(1,-20,1,-112)
SpeedPanel.Position = UDim2.new(0,10,0,104)
SpeedPanel.ScrollBarThickness = 4; SpeedPanel.ScrollBarImageColor3 = C.accent
SpeedPanel.ScrollBarImageTransparency = 0.5; SpeedPanel.ZIndex = 32
SpeedPanel.CanvasSize = UDim2.new(0,0,0,0); SpeedPanel.Visible = false
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,7); c.Parent = SpeedPanel
    local l = Instance.new("UIListLayout"); l.Parent = SpeedPanel
    l.Padding = UDim.new(0,8); l.SortOrder = Enum.SortOrder.LayoutOrder
    local p = Instance.new("UIPadding"); p.Parent = SpeedPanel
    p.PaddingTop = UDim.new(0,8); p.PaddingLeft = UDim.new(0,8); p.PaddingRight = UDim.new(0,8); p.PaddingBottom = UDim.new(0,8)
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SpeedPanel.CanvasSize = UDim2.new(0,0,0,l.AbsoluteContentSize.Y+16)
    end)
end

-- States panel as a separate panel (not embedded in Settings)

-- Testing Panel (diagnostics & debug)
TestingPanel = Instance.new("ScrollingFrame"); TestingPanel.Parent = body
TestingPanel.Name = "TestingPanel"
TestingPanel.BackgroundColor3 = C.bg0; TestingPanel.BackgroundTransparency = 0.15
TestingPanel.BorderSizePixel = 0
TestingPanel.Size = UDim2.new(1,-20,1,-112)
TestingPanel.Position = UDim2.new(0,10,0,104)
TestingPanel.ScrollBarThickness = 4; TestingPanel.ScrollBarImageColor3 = C.accent
TestingPanel.ScrollBarImageTransparency = 0.5; TestingPanel.ZIndex = 32
TestingPanel.CanvasSize = UDim2.new(0,0,0,0); TestingPanel.Visible = false
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,7); c.Parent = TestingPanel
    local l = Instance.new("UIListLayout"); l.Parent = TestingPanel
    l.Padding = UDim.new(0,8); l.SortOrder = Enum.SortOrder.LayoutOrder
    local p = Instance.new("UIPadding"); p.Parent = TestingPanel
    p.PaddingTop = UDim.new(0,8); p.PaddingLeft = UDim.new(0,8); p.PaddingRight = UDim.new(0,8); p.PaddingBottom = UDim.new(0,8)
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TestingPanel.CanvasSize = UDim2.new(0,0,0,l.AbsoluteContentSize.Y+16)
    end)
end


-- ============================================
-- ANIMATION COPIER (Testing Tab)
-- ============================================
do
local animCopierFrame = Instance.new("Frame"); animCopierFrame.Parent = TestingPanel
animCopierFrame.Size = UDim2.new(1,0,0,310)
animCopierFrame.BackgroundColor3 = C.bg1
animCopierFrame.BackgroundTransparency = 0.4
animCopierFrame.BorderSizePixel = 0
animCopierFrame.LayoutOrder = 6
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,7); c.Parent = animCopierFrame
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = animCopierFrame
end

local acLbl = Instance.new("TextLabel", animCopierFrame)
acLbl.BackgroundTransparency = 1; acLbl.Position = UDim2.new(0,10,0,6)
acLbl.Size = UDim2.new(1,-120,0,16); acLbl.Font = Enum.Font.GothamBold
acLbl.Text = "Animation Copier"; acLbl.TextColor3 = C.accent; acLbl.TextSize = 11
acLbl.TextXAlignment = Enum.TextXAlignment.Left; acLbl.ZIndex = 33

local acSub = Instance.new("TextLabel", animCopierFrame)
acSub.BackgroundTransparency = 1; acSub.Position = UDim2.new(0,10,0,22)
acSub.Size = UDim2.new(1,-120,0,24); acSub.Font = Enum.Font.Gotham
acSub.Text = "Mirror target player\'s exact pose & position"; acSub.TextColor3 = C.text3
acSub.TextSize = 9; acSub.TextXAlignment = Enum.TextXAlignment.Left; acSub.TextWrapped = true; acSub.ZIndex = 33

local acToggleBg = Instance.new("Frame", animCopierFrame)
acToggleBg.Size = UDim2.new(0,44,0,22); acToggleBg.Position = UDim2.new(1,-54,0,12)
acToggleBg.BackgroundColor3 = C.bg4; acToggleBg.BorderSizePixel = 0; acToggleBg.ZIndex = 33
local acc = Instance.new("UICorner", acToggleBg); acc.CornerRadius = UDim.new(0,11)
local acKnob = Instance.new("Frame", acToggleBg)
acKnob.Size = UDim2.new(0,16,0,16); acKnob.Position = UDim2.new(0,3,0,3)
acKnob.BackgroundColor3 = C.white; acKnob.BorderSizePixel = 0; acKnob.ZIndex = 34
local acck = Instance.new("UICorner", acKnob); acck.CornerRadius = UDim.new(0,8)
local acToggleBtn = Instance.new("TextButton", acToggleBg)
acToggleBtn.Size = UDim2.new(1,0,1,0); acToggleBtn.BackgroundTransparency = 1; acToggleBtn.Text = ""; acToggleBtn.ZIndex = 35

-- Search box
local acSearchBox = Instance.new("TextBox", animCopierFrame)
acSearchBox.BackgroundColor3 = C.bg2; acSearchBox.BackgroundTransparency = 0.3
acSearchBox.BorderSizePixel = 0; acSearchBox.Position = UDim2.new(0,10,0,50)
acSearchBox.Size = UDim2.new(1,-20,0,26); acSearchBox.ZIndex = 33
acSearchBox.Font = Enum.Font.GothamMedium; acSearchBox.PlaceholderText = "Search player..."
acSearchBox.PlaceholderColor3 = C.text3; acSearchBox.Text = ""
acSearchBox.TextColor3 = C.text; acSearchBox.TextSize = 11
acSearchBox.ClearTextOnFocus = false
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = acSearchBox
    local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0,10); p.Parent = acSearchBox
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = acSearchBox
end

-- Player list
local acPlayerList = Instance.new("ScrollingFrame", animCopierFrame)
acPlayerList.BackgroundColor3 = C.bg0; acPlayerList.BackgroundTransparency = 0.5
acPlayerList.BorderSizePixel = 0; acPlayerList.Position = UDim2.new(0,10,0,80)
acPlayerList.Size = UDim2.new(1,-20,0,80); acPlayerList.ZIndex = 33
acPlayerList.ScrollBarThickness = 3; acPlayerList.ScrollBarImageColor3 = C.accent
acPlayerList.ScrollBarImageTransparency = 0.5; acPlayerList.CanvasSize = UDim2.new(0,0,0,0)
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = acPlayerList end
local acListLayout = Instance.new("UIListLayout", acPlayerList)
acListLayout.Padding = UDim.new(0,3); acListLayout.SortOrder = Enum.SortOrder.LayoutOrder
acListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    acPlayerList.CanvasSize = UDim2.new(0,0,0,acListLayout.AbsoluteContentSize.Y+6)
end)

-- Distance slider
local acDistLbl = Instance.new("TextLabel", animCopierFrame)
acDistLbl.BackgroundTransparency = 1; acDistLbl.Position = UDim2.new(0,10,0,166)
acDistLbl.Size = UDim2.new(0,180,0,16); acDistLbl.Font = Enum.Font.GothamBold
acDistLbl.Text = "Distance: 2.0 studs"; acDistLbl.TextColor3 = C.text2
acDistLbl.TextSize = 9; acDistLbl.TextXAlignment = Enum.TextXAlignment.Left; acDistLbl.ZIndex = 33

local acDistTrack = Instance.new("Frame", animCopierFrame)
acDistTrack.BackgroundColor3 = C.bg2; acDistTrack.BackgroundTransparency = 0.3
acDistTrack.BorderSizePixel = 0; acDistTrack.Position = UDim2.new(0,10,0,184)
acDistTrack.Size = UDim2.new(1,-20,0,8); acDistTrack.ZIndex = 33
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = acDistTrack
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = acDistTrack
end

local acDistFill = Instance.new("Frame", acDistTrack)
acDistFill.BackgroundColor3 = C.accent; acDistFill.BackgroundTransparency = 0.1
acDistFill.BorderSizePixel = 0; acDistFill.Size = UDim2.new(0.345,0,1,0)
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = acDistFill end

local acDistHandle = Instance.new("Frame", acDistTrack)
acDistHandle.AnchorPoint = Vector2.new(0.5,0.5)
acDistHandle.BackgroundColor3 = C.accent; acDistHandle.BackgroundTransparency = 0
acDistHandle.BorderSizePixel = 0; acDistHandle.Position = UDim2.new(0.345,0,0.5,0)
acDistHandle.Size = UDim2.new(0,12,0,12)
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = acDistHandle
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.4; s.Thickness = 1; s.Parent = acDistHandle
end

-- Side selector
local acSideLbl = Instance.new("TextLabel", animCopierFrame)
acSideLbl.BackgroundTransparency = 1; acSideLbl.Position = UDim2.new(0,10,0,200)
acSideLbl.Size = UDim2.new(0,40,0,14); acSideLbl.Font = Enum.Font.Gotham
acSideLbl.Text = "Side:"; acSideLbl.TextColor3 = C.text3
acSideLbl.TextSize = 9; acSideLbl.TextXAlignment = Enum.TextXAlignment.Left; acSideLbl.ZIndex = 33

local acSideLeft = Instance.new("TextButton", animCopierFrame)
acSideLeft.Position = UDim2.new(0,45,0,200); acSideLeft.Size = UDim2.new(0,40,0,16)
acSideLeft.BackgroundColor3 = C.accent; acSideLeft.BackgroundTransparency = 0.1
acSideLeft.BorderSizePixel = 0; acSideLeft.Font = Enum.Font.GothamBold
acSideLeft.Text = "Left"; acSideLeft.TextColor3 = Color3.fromRGB(0,0,0)
acSideLeft.TextSize = 8; acSideLeft.ZIndex = 33; acSideLeft.AutoButtonColor = false
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,4); c.Parent = acSideLeft end

local acSideRight = Instance.new("TextButton", animCopierFrame)
acSideRight.Position = UDim2.new(0,89,0,200); acSideRight.Size = UDim2.new(0,40,0,16)
acSideRight.BackgroundColor3 = C.bg2; acSideRight.BackgroundTransparency = 0.3
acSideRight.BorderSizePixel = 0; acSideRight.Font = Enum.Font.GothamBold
acSideRight.Text = "Right"; acSideRight.TextColor3 = C.text2
acSideRight.TextSize = 8; acSideRight.ZIndex = 33; acSideRight.AutoButtonColor = false
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,4); c.Parent = acSideRight end

-- Match Facing toggle (TikTok-friendly: rotate body to their look dir, keep side offset)
local acFaceLbl = Instance.new("TextLabel", animCopierFrame)
acFaceLbl.BackgroundTransparency = 1; acFaceLbl.Position = UDim2.new(0,140,0,200)
acFaceLbl.Size = UDim2.new(0,70,0,14); acFaceLbl.Font = Enum.Font.Gotham
acFaceLbl.Text = "Face only:"; acFaceLbl.TextColor3 = C.text3
acFaceLbl.TextSize = 9; acFaceLbl.TextXAlignment = Enum.TextXAlignment.Left; acFaceLbl.ZIndex = 33

local acFaceBg = Instance.new("Frame", animCopierFrame)
acFaceBg.Size = UDim2.new(0, 36, 0, 18)
acFaceBg.Position = UDim2.new(0, 210, 0, 198)
acFaceBg.BackgroundColor3 = C.green
acFaceBg.BorderSizePixel = 0
acFaceBg.ZIndex = 33
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = acFaceBg end
local acFaceKnob = Instance.new("Frame", acFaceBg)
acFaceKnob.Size = UDim2.new(0, 14, 0, 14)
acFaceKnob.Position = UDim2.new(1, -16, 0.5, -7)
acFaceKnob.BackgroundColor3 = C.white
acFaceKnob.BorderSizePixel = 0
acFaceKnob.ZIndex = 34
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = acFaceKnob end
local acFaceBtn = Instance.new("TextButton", acFaceBg)
acFaceBtn.Size = UDim2.new(1, 0, 1, 0)
acFaceBtn.BackgroundTransparency = 1
acFaceBtn.Text = ""
acFaceBtn.ZIndex = 35

-- Status label
local acStatus = Instance.new("TextLabel", animCopierFrame)
acStatus.BackgroundTransparency = 1; acStatus.Position = UDim2.new(0,10,0,228)
acStatus.Size = UDim2.new(1,-20,0,28); acStatus.Font = Enum.Font.Gotham
acStatus.Text = "OFF - Select a player and toggle ON"; acStatus.TextColor3 = C.text3
acStatus.TextSize = 9; acStatus.TextXAlignment = Enum.TextXAlignment.Left
acStatus.TextWrapped = true; acStatus.ZIndex = 33

local acNoclipLbl = Instance.new("TextLabel", animCopierFrame)
acNoclipLbl.BackgroundTransparency = 1; acNoclipLbl.Position = UDim2.new(0,10,0,260)
acNoclipLbl.Size = UDim2.new(1,-20,0,14); acNoclipLbl.Font = Enum.Font.Gotham
acNoclipLbl.Text = "Noclip: Auto-enabled when copying"; acNoclipLbl.TextColor3 = C.green
acNoclipLbl.TextSize = 9; acNoclipLbl.TextXAlignment = Enum.TextXAlignment.Left; acNoclipLbl.ZIndex = 33

-- ============================================
-- ANIMATION COPIER LOGIC
-- ============================================
local acEnabled = false
local acSelectedPlayer = nil
local acDistance = 2.0
local acSide = 1
local acMatchFacing = true
local acFaceSmooth = nil
local acLockedPos = nil
local acConn = nil
local acDragging = false
local acSavedStates = {}

local function acUpdateFaceToggle()
    if acMatchFacing then
        TweenService:Create(acFaceBg, TweenInfo.new(0.15), {BackgroundColor3 = C.green}):Play()
        TweenService:Create(acFaceKnob, TweenInfo.new(0.15), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
    else
        TweenService:Create(acFaceBg, TweenInfo.new(0.15), {BackgroundColor3 = C.bg3}):Play()
        TweenService:Create(acFaceKnob, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
    end
end
acFaceBtn.MouseButton1Click:Connect(function()
    acMatchFacing = not acMatchFacing
    acFaceSmooth = nil
    acLockedPos = nil -- re-capture beside slot next frame
    acUpdateFaceToggle()
    if Notify then Notify("Face Only", acMatchFacing and "ON (follow + yaw)" or "OFF", 1.5) end
end)

local function acUpdatePlayerList(term)
    for _, c in ipairs(acPlayerList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    term = (term or ""):lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then
            local name = p.Name .. " (@" .. p.DisplayName .. ")"
            if term == "" or name:lower():find(term, 1, true) then
                local btn = Instance.new("TextButton"); btn.Parent = acPlayerList
                btn.BackgroundColor3 = C.bg2; btn.BackgroundTransparency = 0.5
                btn.BorderSizePixel = 0; btn.Size = UDim2.new(1,0,0,26); btn.ZIndex = 34
                btn.Font = Enum.Font.GothamMedium; btn.Text = name
                btn.TextColor3 = C.text2; btn.TextSize = 10
                btn.TextXAlignment = Enum.TextXAlignment.Left; btn.AutoButtonColor = false
                btn.TextTruncate = Enum.TextTruncate.AtEnd
                do
                    local c2 = Instance.new("UICorner"); c2.CornerRadius = UDim.new(0,5); c2.Parent = btn
                    local p2 = Instance.new("UIPadding"); p2.PaddingLeft = UDim.new(0,8); p2.Parent = btn
                end
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.3}):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.5}):Play()
                end)
                btn.MouseButton1Click:Connect(function()
                    acSelectedPlayer = p
                    acStatus.Text = "Selected: " .. p.Name .. " | Dist: " .. string.format("%.1f", acDistance) .. " studs"
                    acStatus.TextColor3 = C.accent
                    for _, c2 in ipairs(acPlayerList:GetChildren()) do
                        if c2:IsA("TextButton") then
                            c2.BackgroundColor3 = (c2 == btn) and C.accent or C.bg2
                            c2.TextColor3 = (c2 == btn) and Color3.fromRGB(0,0,0) or C.text2
                        end
                    end
                    if acEnabled then
                        acStatus.Text = "COPYING " .. p.Name .. " | Dist: " .. string.format("%.1f", acDistance) .. " studs"
                        acStatus.TextColor3 = C.green
                    end
                end)
            end
        end
    end
end

local function acSetDistance(val)
    acDistance = math.clamp(math.floor(val * 10 + 0.5) / 10, 0.1, 200.0)
    local pct = (acDistance - 0.1) / 200
    acDistFill.Size = UDim2.new(pct, 0, 1, 0)
    acDistHandle.Position = UDim2.new(pct, 0, 0.5, 0)
    acDistLbl.Text = "Distance: " .. string.format("%.1f", acDistance) .. " studs"
    if acEnabled and acSelectedPlayer then
        acStatus.Text = "COPYING " .. acSelectedPlayer.Name .. " | Dist: " .. string.format("%.1f", acDistance) .. " studs"
    end
end
acSetDistance(2.0)

acSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    acUpdatePlayerList(acSearchBox.Text)
end)
Players.PlayerAdded:Connect(function() task.wait(0.1); acUpdatePlayerList(acSearchBox.Text) end)
Players.PlayerRemoving:Connect(function() task.wait(0.1); acUpdatePlayerList(acSearchBox.Text) end)

acDistTrack.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        acDragging = true
        local pct = math.clamp((inp.Position.X - acDistTrack.AbsolutePosition.X) / acDistTrack.AbsoluteSize.X, 0, 1)
        acSetDistance(0.1 + pct * 200)
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 and acDragging then acDragging = false end
end)
UserInputService.InputChanged:Connect(function(inp)
    if acDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local pct = math.clamp((inp.Position.X - acDistTrack.AbsolutePosition.X) / acDistTrack.AbsoluteSize.X, 0, 1)
        acSetDistance(0.1 + pct * 200)
    end
end)

acSideLeft.MouseButton1Click:Connect(function()
    acSide = -1
    acSideLeft.BackgroundColor3 = C.accent; acSideLeft.TextColor3 = Color3.fromRGB(0,0,0)
    acSideRight.BackgroundColor3 = C.bg2; acSideRight.TextColor3 = C.text2
end)
acSideRight.MouseButton1Click:Connect(function()
    acSide = 1
    acSideRight.BackgroundColor3 = C.accent; acSideRight.TextColor3 = Color3.fromRGB(0,0,0)
    acSideLeft.BackgroundColor3 = C.bg2; acSideLeft.TextColor3 = C.text2
end)

local function acFreezeClone(clone)
    if not clone then return end
    acSavedStates = {}
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            local isAccessory = part:FindFirstAncestorOfClass("Accessory") ~= nil
            if isAccessory then
                -- Hair / accessories: keep welds active, don't anchor.
                -- They'll follow their parent body part naturally.
                acSavedStates[part] = {
                    CanCollide = part.CanCollide,
                    CanQuery = part.CanQuery,
                }
                part.CanCollide = false
                part.CanQuery = false
            else
                -- Body parts: anchor and disable physics so CFrame copy works cleanly
                acSavedStates[part] = {
                    Anchored = part.Anchored,
                    CanCollide = part.CanCollide,
                    CanQuery = part.CanQuery,
                }
                part.Anchored = true
                part.CanCollide = false
                part.CanQuery = false
            end
        end
    end
    local hum = clone:FindFirstChildOfClass("Humanoid")
    if hum then
        acSavedStates.Humanoid = {
            WalkSpeed = hum.WalkSpeed,
            JumpPower = hum.JumpPower,
            AutoRotate = hum.AutoRotate,
        }
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        hum.AutoRotate = false
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                pcall(function() track:Stop(0) end)
            end
        end
    end
    local animate = clone:FindFirstChild("Animate")
    if animate then
        acSavedStates.Animate = { Enabled = animate.Enabled }
        animate.Enabled = false
    end
    pcall(function() ReanimateAPI.stop_animation() end)
end

local function acUnfreezeClone(clone)
    if not clone then return end
    for part, state in pairs(acSavedStates) do
        if typeof(part) == "Instance" and part.Parent then
            if part:IsA("BasePart") then
                if state.Anchored ~= nil then
                    pcall(function() part.Anchored = state.Anchored end)
                end
                pcall(function() part.CanCollide = state.CanCollide end)
                pcall(function() part.CanQuery = state.CanQuery end)
            end
        end
    end
    local hum = clone:FindFirstChildOfClass("Humanoid")
    if hum and acSavedStates.Humanoid then
        pcall(function() hum.WalkSpeed = acSavedStates.Humanoid.WalkSpeed end)
        pcall(function() hum.JumpPower = acSavedStates.Humanoid.JumpPower end)
        pcall(function() hum.AutoRotate = acSavedStates.Humanoid.AutoRotate end)
    end
    local animate = clone:FindFirstChild("Animate")
    if animate and acSavedStates.Animate then
        pcall(function() animate.Enabled = acSavedStates.Animate.Enabled end)
    end
    acSavedStates = {}
end

local function acStartCopying()
    if acConn then acConn:Disconnect(); acConn = nil end

    local clone = ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
    acFreezeClone(clone)

    -- Joint-transform copy: keeps YOUR limb lengths, mirrors THEIR joint rotations.
    -- Avoids floating/disconnected parts from absolute CFrame cloning across body types.
    local PART_ALIASES = {
        Torso = {"UpperTorso", "LowerTorso", "Torso"},
        UpperTorso = {"UpperTorso", "Torso"},
        LowerTorso = {"LowerTorso", "Torso"},
        Head = {"Head"},
        HumanoidRootPart = {"HumanoidRootPart"},
        LeftUpperArm = {"LeftUpperArm", "Left Arm"},
        LeftLowerArm = {"LeftLowerArm", "Left Arm"},
        LeftHand = {"LeftHand", "Left Arm"},
        RightUpperArm = {"RightUpperArm", "Right Arm"},
        RightLowerArm = {"RightLowerArm", "Right Arm"},
        RightHand = {"RightHand", "Right Arm"},
        LeftUpperLeg = {"LeftUpperLeg", "Left Leg"},
        LeftLowerLeg = {"LeftLowerLeg", "Left Leg"},
        LeftFoot = {"LeftFoot", "Left Leg"},
        RightUpperLeg = {"RightUpperLeg", "Right Leg"},
        RightLowerLeg = {"RightLowerLeg", "Right Leg"},
        RightFoot = {"RightFoot", "Right Leg"},
        ["Left Arm"] = {"LeftUpperArm", "Left Arm"},
        ["Right Arm"] = {"RightUpperArm", "Right Arm"},
        ["Left Leg"] = {"LeftUpperLeg", "Left Leg"},
        ["Right Leg"] = {"RightUpperLeg", "Right Leg"},
    }

    local function partKey(constraint)
        if constraint:IsA("Motor6D") and constraint.Part1 then
            return constraint.Part1.Name
        end
        if constraint:IsA("AnimationConstraint") then
            local att = constraint.Attachment1
            if att and att.Parent then return att.Parent.Name end
        end
        return nil
    end

    local function buildJointMap(char)
        local map = {} -- name -> constraint
        if not char then return map end
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("Motor6D") or d:IsA("AnimationConstraint") then
                local key = partKey(d)
                if key and not map[key] then
                    map[key] = d
                end
            end
        end
        return map
    end

    local function resolveJoint(map, name)
        if map[name] and map[name].Parent then return map[name] end
        local aliases = PART_ALIASES[name]
        if aliases then
            for _, a in ipairs(aliases) do
                if map[a] and map[a].Parent then return map[a] end
            end
        end
        return nil
    end

    -- Extract rotation-only from a CFrame (drop translation for safer cross-rig paste)
    local function rotOnly(cf)
        local _, _, _, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
        return CFrame.new(0, 0, 0, r00, r01, r02, r10, r11, r12, r20, r21, r22)
    end

    local cloneJointMap = buildJointMap(clone)

    acConn = RunService.Stepped:Connect(function()
        if not acEnabled then return end
        if not acSelectedPlayer then return end

        if not State.isReanimated then
            pcall(function() _G._HaloDoReanimToggle() end)
            return
        end

        local targetChar = acSelectedPlayer.Character
        clone = ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
        if not targetChar or not clone then
            acStatus.Text = "Target or clone missing..."
            acStatus.TextColor3 = C.yellow
            return
        end

        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        local cloneHRP = clone:FindFirstChild("HumanoidRootPart")
        if not targetHRP or not cloneHRP then
            acStatus.Text = "Missing HRP..."
            acStatus.TextColor3 = C.yellow
            return
        end

        if not next(cloneJointMap) then
            cloneJointMap = buildJointMap(clone)
        end
        local targetJointMap = buildJointMap(targetChar)

        -- Hard side-slot follow (no position lerp = no sliding). Stay glued beside them.
        local rightVec = targetHRP.CFrame.RightVector
        if rightVec.Magnitude > 0.001 then rightVec = rightVec.Unit end
        local offsetVec = rightVec * (acDistance * acSide)
        local pos = targetHRP.Position + offsetVec

        -- Yaw-only facing from target
        local targetLook = targetHRP.CFrame.LookVector
        local flatLook = Vector3.new(targetLook.X, 0, targetLook.Z)
        if flatLook.Magnitude < 0.05 then
            flatLook = Vector3.new(0, 0, -1)
        else
            flatLook = flatLook.Unit
        end

        local yawCF
        if acMatchFacing then
            -- Move with them (exact pos each frame), only ROTATE yaw to match face.
            -- No position smoothing → no slide.
            local desiredLook = flatLook
            if acFaceSmooth then
                local prevLook = Vector3.new(acFaceSmooth.LookVector.X, 0, acFaceSmooth.LookVector.Z)
                if prevLook.Magnitude > 0.05 then
                    prevLook = prevLook.Unit
                    desiredLook = prevLook:Lerp(flatLook, 0.28)
                    if desiredLook.Magnitude < 0.05 then
                        desiredLook = flatLook
                    else
                        desiredLook = desiredLook.Unit
                    end
                end
            end
            yawCF = CFrame.lookAt(pos, pos + desiredLook)
            acFaceSmooth = yawCF
        else
            local curLook = cloneHRP.CFrame.LookVector
            local flatCur = Vector3.new(curLook.X, 0, curLook.Z)
            if flatCur.Magnitude < 0.05 then
                flatCur = flatLook
            else
                flatCur = flatCur.Unit
            end
            yawCF = CFrame.lookAt(pos, pos + flatCur)
            acFaceSmooth = nil
        end
        cloneHRP.CFrame = yawCF
        acLockedPos = nil

        -- Parent-before-child order keeps the skeleton connected
        local coreNames = {
            "UpperTorso", "LowerTorso", "Torso", "Head",
            "LeftUpperArm", "LeftLowerArm", "LeftHand", "Left Arm",
            "RightUpperArm", "RightLowerArm", "RightHand", "Right Arm",
            "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Left Leg",
            "RightUpperLeg", "RightLowerLeg", "RightFoot", "Right Leg",
        }

        -- Two passes so children see updated parent CFrames
        for _pass = 1, 2 do
            local applied = {}
            for _, name in ipairs(coreNames) do
                local tJoint = resolveJoint(targetJointMap, name)
                local cJoint = resolveJoint(cloneJointMap, name)
                if tJoint and cJoint and not applied[cJoint] then
                    applied[cJoint] = true
                    -- Prefer full Transform from target (includes slight offsets anims need)
                    local tf = tJoint.Transform
                    pcall(function()
                        cJoint.Transform = tf
                    end)

                    if cJoint:IsA("Motor6D") and cJoint.Part0 and cJoint.Part1 then
                        local p0, p1 = cJoint.Part0, cJoint.Part1
                        if p0.Parent and p1.Parent then
                            -- Place child using CLONE joint offsets + TARGET rotation
                            pcall(function()
                                p1.CFrame = p0.CFrame * cJoint.C0 * rotOnly(tf) * cJoint.C1:Inverse()
                            end)
                        end
                    elseif cJoint:IsA("AnimationConstraint") then
                        local att0 = cJoint.Attachment0
                        local att1 = cJoint.Attachment1
                        if att0 and att1 and att0.Parent and att1.Parent
                            and att0.Parent:IsA("BasePart") and att1.Parent:IsA("BasePart") then
                            pcall(function()
                                -- Standard constraint pose: parentAtt * Transform = childAtt world
                                local desiredChildAttWorld = att0.WorldCFrame * rotOnly(tf)
                                local childPart = att1.Parent
                                childPart.CFrame = desiredChildAttWorld * att1.CFrame:Inverse()
                            end)
                        end
                    end
                end
            end
        end
    end)
end

local function acStopCopying()
    if acConn then acConn:Disconnect(); acConn = nil end
    local clone = ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
    acUnfreezeClone(clone)
    acStatus.Text = "OFF - Select a player and toggle ON"
    acStatus.TextColor3 = C.text3
end

local function acUpdateToggle()
    if acEnabled then
        TweenService:Create(acToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = C.green}):Play()
        TweenService:Create(acKnob, TweenInfo.new(0.2), {Position = UDim2.new(1,-19,0,3)}):Play()
        if acSelectedPlayer then
            acStatus.Text = "COPYING " .. acSelectedPlayer.Name .. " | Dist: " .. string.format("%.1f", acDistance) .. " studs"
            acStatus.TextColor3 = C.green
            acStartCopying()
        else
            acStatus.Text = "ON - Select a player from the list above"
            acStatus.TextColor3 = C.yellow
        end
    else
        TweenService:Create(acToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = C.bg4}):Play()
        TweenService:Create(acKnob, TweenInfo.new(0.2), {Position = UDim2.new(0,3,0,3)}):Play()
        acStopCopying()
    end
    _G._HaloAnimCopierActive = acEnabled
end

acToggleBtn.MouseButton1Click:Connect(function()
    acEnabled = not acEnabled
    acUpdateToggle()
end)

-- Refresh player list on startup
acUpdatePlayerList("")
end


-- ============================================
-- LIMBS PANEL
-- ============================================
do
LimbsPanel = Instance.new("ScrollingFrame"); LimbsPanel.Parent = body
LimbsPanel.Name = "LimbsPanel"
LimbsPanel.BackgroundColor3 = C.bg0; LimbsPanel.BackgroundTransparency = 0.15
LimbsPanel.BorderSizePixel = 0
LimbsPanel.Size = UDim2.new(1,-20,1,-112)
LimbsPanel.Position = UDim2.new(0,10,0,104)
LimbsPanel.ScrollBarThickness = 4; LimbsPanel.ScrollBarImageColor3 = C.accent
LimbsPanel.ScrollBarImageTransparency = 0.5; LimbsPanel.ZIndex = 32
LimbsPanel.CanvasSize = UDim2.new(0,0,0,0); LimbsPanel.Visible = false
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,7); c.Parent = LimbsPanel
    local l = Instance.new("UIListLayout"); l.Parent = LimbsPanel
    l.Padding = UDim.new(0,8); l.SortOrder = Enum.SortOrder.LayoutOrder
    local p = Instance.new("UIPadding"); p.Parent = LimbsPanel
    p.PaddingTop = UDim.new(0,8); p.PaddingLeft = UDim.new(0,8); p.PaddingRight = UDim.new(0,8); p.PaddingBottom = UDim.new(0,8)
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        LimbsPanel.CanvasSize = UDim2.new(0,0,0,l.AbsoluteContentSize.Y+16)
    end)
end

StretchingPanel = Instance.new("ScrollingFrame"); StretchingPanel.Parent = body
StretchingPanel.Name = "StretchingPanel"
StretchingPanel.BackgroundColor3 = C.bg0; StretchingPanel.BackgroundTransparency = 0.15
StretchingPanel.BorderSizePixel = 0
StretchingPanel.Size = UDim2.new(1,-20,1,-112)
StretchingPanel.Position = UDim2.new(0,10,0,104)
StretchingPanel.ScrollBarThickness = 4; StretchingPanel.ScrollBarImageColor3 = C.accent
StretchingPanel.ScrollBarImageTransparency = 0.5; StretchingPanel.ZIndex = 32
StretchingPanel.CanvasSize = UDim2.new(0,0,0,0); StretchingPanel.Visible = false
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,7); c.Parent = StretchingPanel
    local l = Instance.new("UIListLayout"); l.Parent = StretchingPanel
    l.Padding = UDim.new(0,8); l.SortOrder = Enum.SortOrder.LayoutOrder
    local p = Instance.new("UIPadding"); p.Parent = StretchingPanel
    p.PaddingTop = UDim.new(0,8); p.PaddingLeft = UDim.new(0,8); p.PaddingRight = UDim.new(0,8); p.PaddingBottom = UDim.new(0,8)
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        StretchingPanel.CanvasSize = UDim2.new(0,0,0,l.AbsoluteContentSize.Y+16)
    end)
end

-- Limbs state
_G._HaloLimbsUpperTorsoHeight = _G._HaloLimbsUpperTorsoHeight or 1.0
_G._HaloLimbsLegHeight = _G._HaloLimbsLegHeight or 1.0
_G._HaloTorsoStretcherEnabled = _G._HaloTorsoStretcherEnabled or false
_G._HaloLegStretcherEnabled = _G._HaloLegStretcherEnabled or false
_G._HaloLimbsTorsoCamMode = _G._HaloLimbsTorsoCamMode or "360"

-- Build a slider frame
local function buildSlider(parent, title, minVal, maxVal, defaultVal, layoutOrder, onChange, color)
    color = color or C.accent
    local frame = Instance.new("Frame"); frame.Parent = parent
    frame.Size = UDim2.new(1,0,0,54)
    frame.BackgroundColor3 = C.bg1; frame.BackgroundTransparency = 0.12; frame.BorderSizePixel = 0
    frame.LayoutOrder = layoutOrder
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,7); c.Parent = frame
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = frame
    end
    local lbl = Instance.new("TextLabel"); lbl.Parent = frame
    lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0,10,0,6)
    lbl.Size = UDim2.new(1,-20,0,16); lbl.Font = Enum.Font.GothamBold
    lbl.Text = title .. ": " .. string.format("%.2f", defaultVal) .. "x"; lbl.TextColor3 = C.text
    lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 33
    local track = Instance.new("Frame"); track.Parent = frame
    track.BackgroundColor3 = C.bg2; track.BackgroundTransparency = 0.3; track.BorderSizePixel = 0
    track.Position = UDim2.new(0,10,0,28); track.Size = UDim2.new(1,-20,0,8); track.ZIndex = 33
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = track
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = track
    end
    local fill = Instance.new("Frame"); fill.Parent = track
    fill.BackgroundColor3 = color; fill.BackgroundTransparency = 0.1; fill.BorderSizePixel = 0
    local pct = (defaultVal - minVal) / (maxVal - minVal)
    fill.Size = UDim2.new(math.clamp(pct,0,1),0,1,0); fill.ZIndex = 34
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = fill end
    local handle = Instance.new("Frame"); handle.Parent = track
    handle.AnchorPoint = Vector2.new(0.5,0.5); handle.BackgroundColor3 = color
    handle.BackgroundTransparency = 0; handle.BorderSizePixel = 0
    handle.Position = UDim2.new(math.clamp(pct,0,1),0,0.5,0); handle.Size = UDim2.new(0,12,0,12); handle.ZIndex = 35
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = handle
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.4; s.Thickness = 1; s.Parent = handle
    end

    -- Invisible drag capture button over the whole slider area
    local dragBtn = Instance.new("TextButton"); dragBtn.Parent = frame
    dragBtn.BackgroundTransparency = 1; dragBtn.Text = ""; dragBtn.ZIndex = 36
    dragBtn.Position = UDim2.new(0,0,0,22); dragBtn.Size = UDim2.new(1,0,1,-22)
    dragBtn.AutoButtonColor = false

    local dragging = false
    local function setValFromMouse(mx)
        local p = math.clamp((mx - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        local val = minVal + p * (maxVal - minVal)
        val = math.floor(val * 100 + 0.5) / 100
        fill.Size = UDim2.new(p,0,1,0); handle.Position = UDim2.new(p,0,0.5,0)
        lbl.Text = title .. ": " .. string.format("%.2f", val) .. "x"
        onChange(val)
    end

    dragBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setValFromMouse(inp.Position.X)
        end
    end)
    dragBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    dragBtn.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            setValFromMouse(inp.Position.X)
        end
    end)

    -- Also wire handle directly so it feels responsive
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setValFromMouse(inp.Position.X)
        end
    end)

    local widget = {frame=frame, lbl=lbl, fill=fill, handle=handle}
    widget.setValue = function(val)
        val = math.clamp(val, minVal, maxVal)
        local p = (val - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(p,0,1,0); handle.Position = UDim2.new(p,0,0.5,0)
        lbl.Text = title .. ": " .. string.format("%.2f", val) .. "x"
        onChange(val)
    end
    return widget
end

-- Build a toggle row
local function buildToggle(parent, title, subText, layoutOrder, defaultState, onChange)
    local frame = Instance.new("Frame"); frame.Parent = parent
    frame.Size = UDim2.new(1, 0, 0, 56)
    frame.BackgroundColor3 = C.bg1
    frame.BackgroundTransparency = 0.12
    frame.BorderSizePixel = 0
    frame.LayoutOrder = layoutOrder
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = frame
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.4; s.Thickness = 1; s.Parent = frame
    end
    local lbl = Instance.new("TextLabel"); lbl.Parent = frame
    lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 14, 0, 8)
    lbl.Size = UDim2.new(1, -76, 0, 16); lbl.Font = Enum.Font.GothamMedium
    lbl.Text = title; lbl.TextColor3 = C.text; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 33
    local sub = Instance.new("TextLabel"); sub.Parent = frame
    sub.BackgroundTransparency = 1; sub.Position = UDim2.new(0, 14, 0, 26)
    sub.Size = UDim2.new(1, -76, 0, 22); sub.Font = Enum.Font.Gotham
    sub.Text = subText; sub.TextColor3 = C.text3; sub.TextSize = 10
    sub.TextXAlignment = Enum.TextXAlignment.Left; sub.TextWrapped = true; sub.ZIndex = 33
    local bg = Instance.new("Frame"); bg.Parent = frame
    bg.Size = UDim2.new(0, 42, 0, 24); bg.Position = UDim2.new(1, -54, 0.5, -12)
    bg.BackgroundColor3 = defaultState and C.green or C.bg3; bg.BorderSizePixel = 0; bg.ZIndex = 33
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = bg
    local knob = Instance.new("Frame"); knob.Parent = bg
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = defaultState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = defaultState and C.white or C.white
    knob.BorderSizePixel = 0; knob.ZIndex = 34
    local ck = Instance.new("UICorner"); ck.CornerRadius = UDim.new(1, 0); ck.Parent = knob
    local btn = Instance.new("TextButton"); btn.Parent = bg
    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 35
    local state = defaultState
    local function setVisualState(newState)
        state = newState
        if state then
            TweenService:Create(bg, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundColor3 = C.green}):Play()
            TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
                Position = UDim2.new(1, -21, 0.5, -9),
                BackgroundColor3 = C.white
            }):Play()
        else
            TweenService:Create(bg, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundColor3 = C.bg3}):Play()
            TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
                Position = UDim2.new(0, 3, 0.5, -9),
                BackgroundColor3 = C.white
            }):Play()
        end
    end
    btn.MouseButton1Click:Connect(function()
        if not State.isReanimated then
            Notify("Turn on Reanimation first!", 2)
            return
        end
        state = not state
        setVisualState(state)
        onChange(state)
    end)
    return {frame = frame, btn = btn, setVisualState = setVisualState}
end

local function buildToggleSliderCard(parent, title, subText, minVal, maxVal, defaultVal, layoutOrder, defaultState, onToggle, onSlider, valuePrefix)
    valuePrefix = valuePrefix or ""
    local currentVal = defaultVal

    local frame = Instance.new("Frame"); frame.Parent = parent
    frame.Size = UDim2.new(1, 0, 0, 96)
    frame.BackgroundColor3 = C.bg1
    frame.BackgroundTransparency = 0.12
    frame.BorderSizePixel = 0
    frame.LayoutOrder = layoutOrder
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = frame
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.4; s.Thickness = 1; s.Parent = frame
    end

    local titleLbl = Instance.new("TextLabel"); titleLbl.Parent = frame
    titleLbl.BackgroundTransparency = 1; titleLbl.Position = UDim2.new(0, 14, 0, 8)
    titleLbl.Size = UDim2.new(1, -76, 0, 15); titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.Text = title; titleLbl.TextColor3 = C.text; titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.ZIndex = 33

    local subLbl = Instance.new("TextLabel"); subLbl.Parent = frame
    subLbl.BackgroundTransparency = 1; subLbl.Position = UDim2.new(0, 14, 0, 24)
    subLbl.Size = UDim2.new(1, -76, 0, 14); subLbl.Font = Enum.Font.Gotham
    subLbl.Text = subText; subLbl.TextColor3 = C.text3; subLbl.TextSize = 10
    subLbl.TextXAlignment = Enum.TextXAlignment.Left; subLbl.ZIndex = 33

    local toggleBg = Instance.new("Frame"); toggleBg.Parent = frame
    toggleBg.Size = UDim2.new(0, 42, 0, 24); toggleBg.Position = UDim2.new(1, -54, 0, 10)
    toggleBg.BackgroundColor3 = defaultState and C.green or C.bg3; toggleBg.BorderSizePixel = 0; toggleBg.ZIndex = 33
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = toggleBg end

    local toggleKnob = Instance.new("Frame", toggleBg)
    toggleKnob.Size = UDim2.new(0, 18, 0, 18)
    toggleKnob.Position = defaultState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    toggleKnob.BackgroundColor3 = C.white
    toggleKnob.BorderSizePixel = 0; toggleKnob.ZIndex = 34
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = toggleKnob end

    local toggleBtn = Instance.new("TextButton", toggleBg)
    toggleBtn.Size = UDim2.new(1, 0, 1, 0); toggleBtn.BackgroundTransparency = 1; toggleBtn.Text = ""; toggleBtn.ZIndex = 35

    -- number input
    local numBox = Instance.new("TextBox"); numBox.Parent = frame
    numBox.Size = UDim2.new(0, 64, 0, 22)
    numBox.Position = UDim2.new(0, 14, 0, 44)
    numBox.BackgroundColor3 = C.bg3
    numBox.BackgroundTransparency = 0.05
    numBox.BorderSizePixel = 0
    numBox.Font = Enum.Font.GothamMedium
    numBox.Text = string.format("%.2f", defaultVal)
    numBox.TextColor3 = C.text
    numBox.TextSize = 11
    numBox.ClearTextOnFocus = false
    numBox.ZIndex = 34
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = numBox
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.45; s.Thickness = 1; s.Parent = numBox
    end

    local unitLbl = Instance.new("TextLabel"); unitLbl.Parent = frame
    unitLbl.BackgroundTransparency = 1
    unitLbl.Position = UDim2.new(0, 82, 0, 44)
    unitLbl.Size = UDim2.new(0, 24, 0, 22)
    unitLbl.Font = Enum.Font.Gotham
    unitLbl.Text = "x"
    unitLbl.TextColor3 = C.text3
    unitLbl.TextSize = 11
    unitLbl.TextXAlignment = Enum.TextXAlignment.Left
    unitLbl.ZIndex = 33

    -- reset button
    local resetBtn = Instance.new("TextButton"); resetBtn.Parent = frame
    resetBtn.Size = UDim2.new(0, 52, 0, 22)
    resetBtn.Position = UDim2.new(1, -66, 0, 44)
    resetBtn.BackgroundColor3 = C.bg3
    resetBtn.BackgroundTransparency = 0.05
    resetBtn.BorderSizePixel = 0
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.Text = "Reset"
    resetBtn.TextColor3 = C.text2
    resetBtn.TextSize = 10
    resetBtn.AutoButtonColor = false
    resetBtn.ZIndex = 34
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = resetBtn
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.45; s.Thickness = 1; s.Parent = resetBtn
    end

    local track = Instance.new("Frame"); track.Parent = frame
    track.BackgroundColor3 = C.bg3; track.BackgroundTransparency = 0.15; track.BorderSizePixel = 0
    track.Position = UDim2.new(0, 14, 0, 76); track.Size = UDim2.new(1, -28, 0, 6); track.ZIndex = 33
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = track end

    local p0 = math.clamp((defaultVal - minVal) / math.max(maxVal - minVal, 0.001), 0, 1)
    local fill = Instance.new("Frame"); fill.Parent = track
    fill.BackgroundColor3 = C.white; fill.BackgroundTransparency = 0.05; fill.BorderSizePixel = 0
    fill.Size = UDim2.new(p0, 0, 1, 0); fill.ZIndex = 34
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = fill end

    local handle = Instance.new("Frame"); handle.Parent = track
    handle.Size = UDim2.new(0, 12, 0, 12); handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.Position = UDim2.new(p0, 0, 0.5, 0); handle.BackgroundColor3 = C.white; handle.ZIndex = 35
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = handle end

    local function applyValue(val, fromInput)
        val = math.clamp(tonumber(val) or currentVal, minVal, maxVal)
        currentVal = val
        local pct = math.clamp((val - minVal) / math.max(maxVal - minVal, 0.001), 0, 1)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        handle.Position = UDim2.new(pct, 0, 0.5, 0)
        if not fromInput then
            numBox.Text = string.format("%.2f", val)
        end
        if onSlider then onSlider(val) end
    end

    local state = defaultState
    local function setToggleVisual(s)
        state = s
        if state then
            TweenService:Create(toggleBg, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundColor3 = C.green}):Play()
            TweenService:Create(toggleKnob, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
                Position = UDim2.new(1, -21, 0.5, -9), BackgroundColor3 = C.white
            }):Play()
        else
            TweenService:Create(toggleBg, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundColor3 = C.bg3}):Play()
            TweenService:Create(toggleKnob, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
                Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = C.white
            }):Play()
        end
    end

    toggleBtn.MouseButton1Click:Connect(function()
        if not State.isReanimated then
            Notify("Turn on Reanimation first!", 2)
            return
        end
        state = not state
        setToggleVisual(state)
        if onToggle then onToggle(state) end
    end)

    local dragging = false
    local function setFromX(mx)
        local pct = math.clamp((mx - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        local val = minVal + pct * (maxVal - minVal)
        applyValue(val, false)
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    numBox.FocusLost:Connect(function(enter)
        local v = tonumber(numBox.Text)
        if v then
            applyValue(v, false)
        else
            numBox.Text = string.format("%.2f", currentVal)
        end
    end)

    resetBtn.MouseButton1Click:Connect(function()
        applyValue(defaultVal, false)
        if Notify then Notify(title .. " reset", 1.2) end
    end)
    resetBtn.MouseEnter:Connect(function()
        TweenService:Create(resetBtn, TweenInfo.new(0.12), {BackgroundColor3 = C.bg2, TextColor3 = C.text}):Play()
    end)
    resetBtn.MouseLeave:Connect(function()
        TweenService:Create(resetBtn, TweenInfo.new(0.12), {BackgroundColor3 = C.bg3, TextColor3 = C.text2}):Play()
    end)

    return {
        frame = frame,
        setVisualState = setToggleVisual,
        setValue = function(val)
            applyValue(val, false)
        end,
        getValue = function()
            return currentVal
        end,
    }
end

local function buildToggleWithKey(parent, title, subText, layoutOrder, defaultState, keybindRef, onStateChange, onKeyChange)
    local frame = Instance.new("Frame"); frame.Parent = parent
    frame.Size = UDim2.new(1, 0, 0, 56)
    frame.BackgroundColor3 = C.bg1
    frame.BackgroundTransparency = 0.12
    frame.BorderSizePixel = 0
    frame.LayoutOrder = layoutOrder
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = frame
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.4; s.Thickness = 1; s.Parent = frame
    end
    local lbl = Instance.new("TextLabel"); lbl.Parent = frame
    lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 14, 0, 8)
    lbl.Size = UDim2.new(1, -150, 0, 16); lbl.Font = Enum.Font.GothamMedium
    lbl.Text = title; lbl.TextColor3 = C.text; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 33
    local sub = Instance.new("TextLabel"); sub.Parent = frame
    sub.BackgroundTransparency = 1; sub.Position = UDim2.new(0, 14, 0, 26)
    sub.Size = UDim2.new(1, -150, 0, 22); sub.Font = Enum.Font.Gotham
    sub.Text = subText; sub.TextColor3 = C.text3; sub.TextSize = 10
    sub.TextXAlignment = Enum.TextXAlignment.Left; sub.TextWrapped = true; sub.ZIndex = 33

    local keyBtn = Instance.new("TextButton"); keyBtn.Parent = frame
    keyBtn.Size = UDim2.new(0, 52, 0, 22); keyBtn.Position = UDim2.new(1, -108, 0.5, -11)
    keyBtn.BackgroundColor3 = C.bg3; keyBtn.BackgroundTransparency = 0.05
    keyBtn.BorderSizePixel = 0; keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextColor3 = C.text3; keyBtn.TextSize = 10; keyBtn.ZIndex = 34; keyBtn.AutoButtonColor = false
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 7); c.Parent = keyBtn end

    local function updateKeyText()
        local k = nil
        if type(keybindRef) == "function" then
            k = keybindRef()
        else
            k = keybindRef
        end
        if typeof(k) == "EnumItem" then
            keyBtn.Text = k.Name
        elseif type(k) == "string" and k ~= "" then
            keyBtn.Text = k
        else
            keyBtn.Text = "KEY"
        end
    end
    updateKeyText()

    local listening = false
    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "..."
        keyBtn.TextColor3 = C.white
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                if conn then conn:Disconnect() end
                keyBtn.TextColor3 = C.text3
                if onKeyChange then onKeyChange(input.KeyCode) end
                updateKeyText()
            end
        end)
    end)

    local bg = Instance.new("Frame"); bg.Parent = frame
    bg.Size = UDim2.new(0, 42, 0, 24); bg.Position = UDim2.new(1, -50, 0.5, -12)
    bg.BackgroundColor3 = defaultState and C.green or C.bg3; bg.BorderSizePixel = 0; bg.ZIndex = 33
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = bg end
    local knob = Instance.new("Frame"); knob.Parent = bg
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = defaultState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = defaultState and C.white or C.white
    knob.BorderSizePixel = 0; knob.ZIndex = 34
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = knob end
    local btn = Instance.new("TextButton"); btn.Parent = bg
    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 35
    local state = defaultState
    local function setVisualState(newState)
        state = newState
        if state then
            TweenService:Create(bg, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundColor3 = C.green}):Play()
            TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
                Position = UDim2.new(1, -21, 0.5, -9), BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            }):Play()
        else
            TweenService:Create(bg, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundColor3 = C.bg3}):Play()
            TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
                Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = C.white
            }):Play()
        end
    end
    btn.MouseButton1Click:Connect(function()
        if not State.isReanimated then
            Notify("Turn on Reanimation first!", 2)
            return
        end
        state = not state
        setVisualState(state)
        if onStateChange then onStateChange(state) end
    end)
    return {frame = frame, setVisualState = setVisualState, updateKeyText = updateKeyText}
end


local function applyLegHipHeight(clone, legScale, enabled)
    local hums = {}
    if clone then
        local h = clone:FindFirstChildOfClass("Humanoid")
        if h then table.insert(hums, h) end
    end
    if plr.Character and plr.Character ~= clone then
        local h = plr.Character:FindFirstChildOfClass("Humanoid")
        if h then table.insert(hums, h) end
    end
    if ReanimateAPI and ReanimateAPI.get_real_character then
        local rc = ReanimateAPI.get_real_character(plr)
        if rc and rc ~= clone and rc ~= plr.Character then
            local h = rc:FindFirstChildOfClass("Humanoid")
            if h then table.insert(hums, h) end
        end
    end
    for _, hum in ipairs(hums) do
        local defHip = hum:GetAttribute("HaloDefaultHipHeight")
        if not defHip or defHip > 3.5 then
            defHip = (hum.HipHeight > 0 and hum.HipHeight <= 3.5) and hum.HipHeight or 2.0
            hum:SetAttribute("HaloDefaultHipHeight", defHip)
        end
        if enabled then
            local extra = math.max(0, (legScale - 1.0) * 1.5)
            hum.HipHeight = defHip + extra
        else
            hum.HipHeight = defHip
        end
    end
end

-- UpperTorso Height Slider

_G._HaloTorsoStretcherEnabled = false
_G._HaloLegStretcherEnabled = false
_G._HaloLimbsUpperTorsoHeight = 1.0
_G._HaloLimbsLegHeight = 1.0

-- Torso Stretcher (Toggle + Slider in matching card design)
local torsoStretcherToggle = buildToggleSliderCard(StretchingPanel, "Torso Stretcher", "Enable UpperTorso height stretching", 0.4, 100.0, 1.0, 1, false, function(state)
    _G._HaloTorsoStretcherEnabled = state
end, function(v)
    _G._HaloLimbsUpperTorsoHeight = v
end, "Amount: ")

local utSlider = {
    setValue = function(v)
        if torsoStretcherToggle and torsoStretcherToggle.setValue then
            torsoStretcherToggle.setValue(v)
        end
    end
}

-- Leg Stretcher (Toggle + Slider in matching card design)
local legStretcherToggle = buildToggleSliderCard(StretchingPanel, "Leg Stretcher", "Enable leg height stretching", 0.4, 100.0, 1.0, 2, false, function(state)
    _G._HaloLegStretcherEnabled = state
    local clone = (ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)) or plr.Character
    applyLegHipHeight(clone, _G._HaloLimbsLegHeight or 1.0, state)
    if startLimbsSystem then startLimbsSystem() end
    if startStandalonePointers then startStandalonePointers() end
end, function(v)
    _G._HaloLimbsLegHeight = v
    if _G._HaloLegStretcherEnabled then
        local clone = (ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)) or plr.Character
        applyLegHipHeight(clone, v, true)
    end
end, "Amount: ")

local legSlider = {
    setValue = function(v)
        if legStretcherToggle and legStretcherToggle.setValue then
            legStretcherToggle.setValue(v)
        end
    end
}

-- Torso Camera Control: Toggle + Mode Dropdown
_G._HaloLimbsTorsoCamControl = _G._HaloLimbsTorsoCamControl or false
_G._HaloLimbsTorsoCamMode = _G._HaloLimbsTorsoCamMode or "360"

-- Toggle row
local camToggleFrame = Instance.new("Frame"); camToggleFrame.Parent = LimbsPanel
camToggleFrame.Size = UDim2.new(1,0,0,54)
camToggleFrame.BackgroundColor3 = C.bg1; camToggleFrame.BackgroundTransparency = 0.4; camToggleFrame.BorderSizePixel = 0
camToggleFrame.LayoutOrder = 1
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,7); c.Parent = camToggleFrame
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = camToggleFrame
end

local camToggleLbl = Instance.new("TextLabel"); camToggleLbl.Parent = camToggleFrame
camToggleLbl.BackgroundTransparency = 1; camToggleLbl.Position = UDim2.new(0,10,0,6)
camToggleLbl.Size = UDim2.new(1,-70,0,16); camToggleLbl.Font = Enum.Font.GothamBold
camToggleLbl.Text = "Torso Camera Control"; camToggleLbl.TextColor3 = C.text
camToggleLbl.TextSize = 10; camToggleLbl.TextXAlignment = Enum.TextXAlignment.Left; camToggleLbl.ZIndex = 33

local camToggleSub = Instance.new("TextLabel"); camToggleSub.Parent = camToggleFrame
camToggleSub.BackgroundTransparency = 1; camToggleSub.Position = UDim2.new(0,10,0,24)
camToggleSub.Size = UDim2.new(1,-70,0,24); camToggleSub.Font = Enum.Font.Gotham
camToggleSub.Text = "Lean and turn body with camera look direction"; camToggleSub.TextColor3 = C.text3
camToggleSub.TextSize = 9; camToggleSub.TextXAlignment = Enum.TextXAlignment.Left; camToggleSub.TextWrapped = true; camToggleSub.ZIndex = 33

local camToggleBg = Instance.new("Frame"); camToggleBg.Parent = camToggleFrame
camToggleBg.Size = UDim2.new(0,44,0,22); camToggleBg.Position = UDim2.new(1,-54,0,16)
camToggleBg.BackgroundColor3 = _G._HaloLimbsTorsoCamControl and C.green or C.bg4; camToggleBg.BorderSizePixel = 0; camToggleBg.ZIndex = 33
local camToggleCorner = Instance.new("UICorner", camToggleBg); camToggleCorner.CornerRadius = UDim.new(0,11)
local camToggleKnob = Instance.new("Frame", camToggleBg)
camToggleKnob.Size = UDim2.new(0,16,0,16); camToggleKnob.Position = _G._HaloLimbsTorsoCamControl and UDim2.new(1,-19,0,3) or UDim2.new(0,3,0,3)
camToggleKnob.BackgroundColor3 = C.white; camToggleKnob.BorderSizePixel = 0; camToggleKnob.ZIndex = 34
local camToggleKnobCorner = Instance.new("UICorner", camToggleKnob); camToggleKnobCorner.CornerRadius = UDim.new(0,8)
local camToggleBtn = Instance.new("TextButton", camToggleBg)
camToggleBtn.Size = UDim2.new(1,0,1,0); camToggleBtn.BackgroundTransparency = 1; camToggleBtn.Text = ""; camToggleBtn.ZIndex = 35

local function updateCamToggleState(state)
    _G._HaloLimbsTorsoCamControl = state
    _G._HaloTorsoCamSmoothedCF = nil
    if state then
        TweenService:Create(camToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = C.green}):Play()
        TweenService:Create(camToggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(1,-19,0,3)}):Play()
        if startLimbsSystem then startLimbsSystem() end
    else
        TweenService:Create(camToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = C.bg4}):Play()
        TweenService:Create(camToggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(0,3,0,3)}):Play()
    end
end
_G._HaloUpdateCamToggleState = updateCamToggleState

camToggleBtn.MouseButton1Click:Connect(function()
    if not State.isReanimated then
        Notify("Turn on Reanimation first!", 2)
        return
    end
    updateCamToggleState(not _G._HaloLimbsTorsoCamControl)
end)

-- Mode dropdown row
local camModeFrame = Instance.new("Frame"); camModeFrame.Parent = LimbsPanel
camModeFrame.Size = UDim2.new(1,0,0,54)
camModeFrame.BackgroundColor3 = C.bg1; camModeFrame.BackgroundTransparency = 0.4; camModeFrame.BorderSizePixel = 0
camModeFrame.LayoutOrder = 2
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,7); c.Parent = camModeFrame
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = camModeFrame
end

local camModeLbl = Instance.new("TextLabel"); camModeLbl.Parent = camModeFrame
camModeLbl.BackgroundTransparency = 1; camModeLbl.Position = UDim2.new(0,10,0,6)
camModeLbl.Size = UDim2.new(1,-20,0,16); camModeLbl.Font = Enum.Font.GothamBold
camModeLbl.Text = "Camera Mode"; camModeLbl.TextColor3 = C.text
camModeLbl.TextSize = 10; camModeLbl.TextXAlignment = Enum.TextXAlignment.Left; camModeLbl.ZIndex = 33

local camModeSub = Instance.new("TextLabel"); camModeSub.Parent = camModeFrame
camModeSub.BackgroundTransparency = 1; camModeSub.Position = UDim2.new(0,10,0,22)
camModeSub.Size = UDim2.new(1,-20,0,14); camModeSub.Font = Enum.Font.Gotham
camModeSub.Text = "Choose how the torso follows your camera"; camModeSub.TextColor3 = C.text3
camModeSub.TextSize = 9; camModeSub.TextXAlignment = Enum.TextXAlignment.Left; camModeSub.ZIndex = 33

local camModeDropdown = Instance.new("TextButton"); camModeDropdown.Parent = camModeFrame
camModeDropdown.Position = UDim2.new(0,10,0,38); camModeDropdown.Size = UDim2.new(1,-20,0,24)
camModeDropdown.BackgroundColor3 = C.bg2; camModeDropdown.BackgroundTransparency = 0.3
camModeDropdown.BorderSizePixel = 0; camModeDropdown.ZIndex = 33
camModeDropdown.Font = Enum.Font.GothamBold; camModeDropdown.Text = _G._HaloLimbsTorsoCamMode
camModeDropdown.TextColor3 = C.accent; camModeDropdown.TextSize = 10
camModeDropdown.AutoButtonColor = false
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = camModeDropdown
    local chev = Instance.new("ImageLabel"); chev.Parent = camModeDropdown
    chev.BackgroundTransparency = 1; chev.AnchorPoint = Vector2.new(1,0.5)
    chev.Position = UDim2.new(1,-6,0.5,0); chev.Size = UDim2.new(0,12,0,12)
    chev.Image = "rbxassetid://6034818372"; chev.ImageColor3 = C.text3; chev.ZIndex = 34
end

local camModeOptions = {"360", "Locked", "Free"}
local camModeMenu = Instance.new("Frame"); camModeMenu.Parent = camModeFrame
camModeMenu.BackgroundColor3 = C.bg0; camModeMenu.BackgroundTransparency = 0.05
camModeMenu.BorderSizePixel = 0; camModeMenu.Size = UDim2.new(1,-20,0,0)
camModeMenu.Position = UDim2.new(0,10,0,64); camModeMenu.ZIndex = 100
camModeMenu.Visible = false; camModeMenu.ClipsDescendants = true
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = camModeMenu
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.5; s.Thickness = 1; s.Parent = camModeMenu
end

local camModeMenuLayout = Instance.new("UIListLayout"); camModeMenuLayout.Parent = camModeMenu
camModeMenuLayout.Padding = UDim.new(0,2); camModeMenuLayout.SortOrder = Enum.SortOrder.LayoutOrder

for _, opt in ipairs(camModeOptions) do
    local optBtn = Instance.new("TextButton"); optBtn.Parent = camModeMenu
    optBtn.BackgroundColor3 = C.bg2; optBtn.BackgroundTransparency = 0.5
    optBtn.BorderSizePixel = 0; optBtn.Size = UDim2.new(1,0,0,22); optBtn.ZIndex = 101
    optBtn.Font = Enum.Font.GothamMedium; optBtn.Text = opt
    optBtn.TextColor3 = C.text2; optBtn.TextSize = 10; optBtn.AutoButtonColor = false
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,4); c.Parent = optBtn end
    optBtn.MouseEnter:Connect(function()
        TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0.2}):Play()
    end)
    optBtn.MouseLeave:Connect(function()
        TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0.5}):Play()
    end)
    optBtn.MouseButton1Click:Connect(function()
        _G._HaloLimbsTorsoCamMode = opt
        camModeDropdown.Text = opt
        camModeMenu.Visible = false
        TweenService:Create(camModeMenu, TweenInfo.new(0.15), {Size = UDim2.new(1,-20,0,0)}):Play()
    end)
end

camModeDropdown.MouseButton1Click:Connect(function()
    if camModeMenu.Visible then
        camModeMenu.Visible = false
        TweenService:Create(camModeMenu, TweenInfo.new(0.15), {Size = UDim2.new(1,-20,0,0)}):Play()
        TweenService:Create(camModeFrame, TweenInfo.new(0.15), {Size = UDim2.new(1,0,0,54)}):Play()
    else
        camModeMenu.Visible = true
        TweenService:Create(camModeMenu, TweenInfo.new(0.15), {Size = UDim2.new(1,-20,0,#camModeOptions * 24 + 4)}):Play()
        TweenService:Create(camModeFrame, TweenInfo.new(0.15), {Size = UDim2.new(1,0,0,54 + #camModeOptions * 24 + 4 + 10)}):Play()
    end
end)
-- 360 Head Movement
_G._HaloHeadTracker360 = _G._HaloHeadTracker360 or false
local head360Widget = buildToggle(LimbsPanel, "360 Head Movement", "Allow head to rotate full 360 degrees without clamping.", 3, _G._HaloHeadTracker360, function(state)
    _G._HaloHeadTracker360 = state
end)

_G._HaloHeadTrackerEnabled = false
local htWidget = buildToggleWithKey(LimbsPanel, "Head Tracker", "Head follows camera via constraint transform.", 4, false, function()
    return _G._HaloHeadTrackerKey
end, function(state)
    _G._HaloHeadTrackerEnabled = state
end, function(key)
    _G._HaloHeadTrackerKey = key
end)
_G._HaloUpdateHeadTrackerUI = function()
    if htWidget and htWidget.setVisualState then
        htWidget.setVisualState(_G._HaloHeadTrackerEnabled or false)
    end
    if htWidget and htWidget.updateKeyText then
        htWidget.updateKeyText()
    end
end

-- Left Arm Pointer
_G._HaloLeftArmPointerEnabled = false
local laWidget = buildToggleWithKey(LimbsPanel, "Left Arm Pointer", "Left arm points straight at mouse. Overrides left arm", 5, false, function()
    return _G._HaloLeftArmKey
end, function(state)
    _G._HaloLeftArmPointerEnabled = state
    if state then _G._HaloLeftArmPointerNeedsReset = true end
end, function(key)
    _G._HaloLeftArmKey = key
end)
_G._HaloUpdateLeftArmPointerUI = function()
    if laWidget and laWidget.setVisualState then
        laWidget.setVisualState(_G._HaloLeftArmPointerEnabled or false)
    end
    if laWidget and laWidget.updateKeyText then
        laWidget.updateKeyText()
    end
end

-- Right Arm Pointer
_G._HaloRightArmPointerEnabled = false
local raWidget = buildToggleWithKey(LimbsPanel, "Right Arm Pointer", "Right arm points straight at mouse. Overrides right arm", 6, false, function()
    return _G._HaloRightArmKey
end, function(state)
    _G._HaloRightArmPointerEnabled = state
    if state then _G._HaloRightArmPointerNeedsReset = true end
end, function(key)
    _G._HaloRightArmKey = key
end)
_G._HaloUpdateRightArmPointerUI = function()
    if raWidget and raWidget.setVisualState then
        raWidget.setVisualState(_G._HaloRightArmPointerEnabled or false)
    end
    if raWidget and raWidget.updateKeyText then
        raWidget.updateKeyText()
    end
end

-- ============================================
-- FUN TRACKING: Stare / Wobble / Spin Head / T-Pose
-- ============================================
_G._HaloStareEnabled = _G._HaloStareEnabled or false
_G._HaloIdleWobbleEnabled = _G._HaloIdleWobbleEnabled or false
_G._HaloSpinHeadEnabled = _G._HaloSpinHeadEnabled or false
_G._HaloSpinHeadSpeed = _G._HaloSpinHeadSpeed or 1.5
_G._HaloTPoseEnabled = _G._HaloTPoseEnabled or false

local funHeader = Instance.new("TextLabel")
funHeader.Parent = LimbsPanel
funHeader.BackgroundTransparency = 1
funHeader.Size = UDim2.new(1, 0, 0, 16)
funHeader.LayoutOrder = 20
funHeader.Font = Enum.Font.GothamBold
funHeader.TextSize = 11
funHeader.Text = "Fun Tracking"
funHeader.TextColor3 = C.text
funHeader.TextXAlignment = Enum.TextXAlignment.Left
funHeader.ZIndex = 33

buildToggle(LimbsPanel, "Stare Mode", "Head locks onto the nearest other player (creep mode).", 21, _G._HaloStareEnabled, function(state)
    _G._HaloStareEnabled = state
    if state then
        _G._HaloSpinHeadEnabled = false
        if Notify then Notify("Stare Mode ON", 1.5) end
    else
        if Notify then Notify("Stare Mode OFF", 1.5) end
    end
end)

buildToggle(LimbsPanel, "Idle Wobble", "Soft jiggle on head + arms while idle. Cursed idle energy.", 22, _G._HaloIdleWobbleEnabled, function(state)
    _G._HaloIdleWobbleEnabled = state
    if Notify then Notify("Idle Wobble: " .. (state and "ON" or "OFF"), 1.5) end
end)

buildToggle(LimbsPanel, "Spin Head", "Head continuously spins (exorcist mode). Overrides stare/head tracker.", 23, _G._HaloSpinHeadEnabled, function(state)
    _G._HaloSpinHeadEnabled = state
    if state then
        _G._HaloStareEnabled = false
        if Notify then Notify("Spin Head ON", 1.5) end
    else
        if Notify then Notify("Spin Head OFF", 1.5) end
    end
end)

-- Spin speed mini slider card
do
    local frame = Instance.new("Frame"); frame.Parent = LimbsPanel
    frame.Size = UDim2.new(1, 0, 0, 48)
    frame.BackgroundColor3 = C.bg1; frame.BackgroundTransparency = 0.12; frame.BorderSizePixel = 0
    frame.LayoutOrder = 24
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 7); c.Parent = frame
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = frame
    end
    local lbl = Instance.new("TextLabel"); lbl.Parent = frame
    lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 10, 0, 6)
    lbl.Size = UDim2.new(1, -20, 0, 14); lbl.Font = Enum.Font.GothamBold
    lbl.Text = "Spin Speed: " .. string.format("%.1f", _G._HaloSpinHeadSpeed) .. "x"
    lbl.TextColor3 = C.text; lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 33

    local track = Instance.new("Frame"); track.Parent = frame
    track.BackgroundColor3 = C.bg2; track.BackgroundTransparency = 0.3; track.BorderSizePixel = 0
    track.Position = UDim2.new(0, 10, 0, 28); track.Size = UDim2.new(1, -20, 0, 8); track.ZIndex = 33
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = track end
    local minV, maxV = 0.2, 6.0
    local p0 = math.clamp((_G._HaloSpinHeadSpeed - minV) / (maxV - minV), 0, 1)
    local fill = Instance.new("Frame"); fill.Parent = track
    fill.BackgroundColor3 = C.accent; fill.BackgroundTransparency = 0.15; fill.BorderSizePixel = 0
    fill.Size = UDim2.new(p0, 0, 1, 0); fill.ZIndex = 34
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = fill end
    local handle = Instance.new("Frame"); handle.Parent = track
    handle.Size = UDim2.new(0, 12, 0, 12); handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.Position = UDim2.new(p0, 0, 0.5, 0); handle.BackgroundColor3 = C.text; handle.ZIndex = 35
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = handle end

    local dragging = false
    local function setFromX(mx)
        local pct = math.clamp((mx - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        local val = minV + pct * (maxV - minV)
        val = math.floor(val * 10 + 0.5) / 10
        _G._HaloSpinHeadSpeed = val
        fill.Size = UDim2.new(pct, 0, 1, 0)
        handle.Position = UDim2.new(pct, 0, 0.5, 0)
        lbl.Text = "Spin Speed: " .. string.format("%.1f", val) .. "x"
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

buildToggle(LimbsPanel, "T-Pose", "Force a full T-pose on the clone. Instant meme mode.", 25, _G._HaloTPoseEnabled, function(state)
    _G._HaloTPoseEnabled = state
    if Notify then Notify("T-Pose: " .. (state and "ON" or "OFF"), 1.5) end
end)

-- More fun tracking
_G._HaloLookBehindEnabled = _G._HaloLookBehindEnabled or false
_G._HaloHeadTiltEnabled = _G._HaloHeadTiltEnabled or false
_G._HaloNodLoopEnabled = _G._HaloNodLoopEnabled or false
_G._HaloCraneNeckEnabled = _G._HaloCraneNeckEnabled or false
_G._HaloHandsUpEnabled = _G._HaloHandsUpEnabled or false
_G._HaloCrossArmsEnabled = _G._HaloCrossArmsEnabled or false
_G._HaloTorsoFaceNearest = _G._HaloTorsoFaceNearest or false
_G._HaloDrunkSwayEnabled = _G._HaloDrunkSwayEnabled or false
_G._HaloTwitchEnabled = _G._HaloTwitchEnabled or false
_G._HaloHeliArmsEnabled = _G._HaloHeliArmsEnabled or false
_G._HaloLeanBackEnabled = _G._HaloLeanBackEnabled or false
_G._HaloShrugEnabled = _G._HaloShrugEnabled or false

local funHeader2 = Instance.new("TextLabel")
funHeader2.Parent = LimbsPanel
funHeader2.BackgroundTransparency = 1
funHeader2.Size = UDim2.new(1, 0, 0, 16)
funHeader2.LayoutOrder = 30
funHeader2.Font = Enum.Font.GothamBold
funHeader2.TextSize = 11
funHeader2.Text = "More Tracking"
funHeader2.TextColor3 = C.text
funHeader2.TextXAlignment = Enum.TextXAlignment.Left
funHeader2.ZIndex = 33

local function funTog(title, sub, order, flag, onMsg)
    buildToggle(LimbsPanel, title, sub, order, _G[flag] or false, function(state)
        _G[flag] = state
        if Notify then Notify(onMsg or title, state and "ON" or "OFF", 1.4) end
    end)
end

funTog("Look Behind", "Head snaps 180 when someone is behind you.", 31, "_HaloLookBehindEnabled", "Look Behind")
funTog("Head Tilt", "Permanent curious head tilt.", 32, "_HaloHeadTiltEnabled", "Head Tilt")
funTog("Nod Loop", "Head slowly nods yes on a loop.", 33, "_HaloNodLoopEnabled", "Nod Loop")
funTog("Crane Neck", "Neck stretches upward (tall creep).", 34, "_HaloCraneNeckEnabled", "Crane Neck")
funTog("Hands Up", "Both arms raised overhead.", 35, "_HaloHandsUpEnabled", "Hands Up")
funTog("Cross Arms", "Arms crossed over chest.", 36, "_HaloCrossArmsEnabled", "Cross Arms")
funTog("Torso Face Nearest", "Upper body turns toward nearest player.", 37, "_HaloTorsoFaceNearest", "Torso Face")
funTog("Drunk Sway", "Loose upper-body sway like drunk cam.", 38, "_HaloDrunkSwayEnabled", "Drunk Sway")
funTog("Twitch", "Random micro-twitches on head and arms.", 39, "_HaloTwitchEnabled", "Twitch")
funTog("Helicopter Arms", "Arms spin like a helicopter. Pure chaos.", 40, "_HaloHeliArmsEnabled", "Heli Arms")
funTog("Lean Back", "Torso leans backward.", 41, "_HaloLeanBackEnabled", "Lean Back")
funTog("Shrug Hold", "Both shoulders held in a shrug.", 42, "_HaloShrugEnabled", "Shrug")

-- Extra limb tools (new)
_G._HaloDualArmPointerEnabled = _G._HaloDualArmPointerEnabled or false
_G._HaloGunAimEnabled = _G._HaloGunAimEnabled or false
_G._HaloWaveArmEnabled = _G._HaloWaveArmEnabled or false
_G._HaloHeadbangEnabled = _G._HaloHeadbangEnabled or false
_G._HaloFloppyArmsEnabled = _G._HaloFloppyArmsEnabled or false
_G._HaloReachMouseEnabled = _G._HaloReachMouseEnabled or false
_G._HaloWaveArmSide = _G._HaloWaveArmSide or "Right"
_G._HaloHeadbangSpeed = _G._HaloHeadbangSpeed or 1.4

do
    local extraHeader = Instance.new("TextLabel")
    extraHeader.Parent = LimbsPanel
    extraHeader.BackgroundTransparency = 1
    extraHeader.Size = UDim2.new(1, 0, 0, 16)
    extraHeader.LayoutOrder = 50
    extraHeader.Font = Enum.Font.GothamBold
    extraHeader.TextSize = 11
    extraHeader.Text = "Extra Limb Tools"
    extraHeader.TextColor3 = C.text
    extraHeader.TextXAlignment = Enum.TextXAlignment.Left
    extraHeader.ZIndex = 33
end

buildToggle(LimbsPanel, "Both Arms Pointer", "Left + right arm pointer at the same time.", 51, _G._HaloDualArmPointerEnabled, function(state)
    _G._HaloDualArmPointerEnabled = state
    _G._HaloLeftArmPointerEnabled = state
    _G._HaloRightArmPointerEnabled = state
    if not state then
        _G._HaloLeftArmPointerNeedsReset = true
        _G._HaloRightArmPointerNeedsReset = true
    end
    if Notify then Notify("Both Arms Pointer: " .. (state and "ON" or "OFF"), 1.4) end
end)

buildToggle(LimbsPanel, "Gun Aim", "Right arm aims at mouse like holding a gun.", 52, _G._HaloGunAimEnabled, function(state)
    _G._HaloGunAimEnabled = state
    if state then
        _G._HaloRightArmPointerEnabled = false
        _G._HaloHeliArmsEnabled = false
        _G._HaloHandsUpEnabled = false
    end
    if Notify then Notify("Gun Aim: " .. (state and "ON" or "OFF"), 1.4) end
end)

buildToggle(LimbsPanel, "Wave Arm", "Looping friendly wave with one arm.", 53, _G._HaloWaveArmEnabled, function(state)
    _G._HaloWaveArmEnabled = state
    if Notify then Notify("Wave Arm: " .. (state and "ON" or "OFF"), 1.4) end
end)

buildToggle(LimbsPanel, "Headbang", "Aggressive headbang loop. Party mode.", 54, _G._HaloHeadbangEnabled, function(state)
    _G._HaloHeadbangEnabled = state
    if state then
        _G._HaloSpinHeadEnabled = false
        _G._HaloNodLoopEnabled = false
        _G._HaloStareEnabled = false
    end
    if Notify then Notify("Headbang: " .. (state and "ON" or "OFF"), 1.4) end
end)

buildToggle(LimbsPanel, "Floppy Arms", "Arms hang limp and sway. Dead-arm energy.", 55, _G._HaloFloppyArmsEnabled, function(state)
    _G._HaloFloppyArmsEnabled = state
    if state then
        _G._HaloHandsUpEnabled = false
        _G._HaloCrossArmsEnabled = false
        _G._HaloHeliArmsEnabled = false
        _G._HaloTPoseEnabled = false
    end
    if Notify then Notify("Floppy Arms: " .. (state and "ON" or "OFF"), 1.4) end
end)

buildToggle(LimbsPanel, "Reach Mouse", "Both arms stretch and point toward the mouse.", 56, _G._HaloReachMouseEnabled, function(state)
    _G._HaloReachMouseEnabled = state
    if state then
        _G._HaloLeftArmPointerEnabled = true
        _G._HaloRightArmPointerEnabled = true
        _G._HaloLeftArmStretching = true
        _G._HaloRightArmStretching = true
        _G._HaloArmStretchAmount = math.max(_G._HaloArmStretchAmount or 2.5, 2.2)
    else
        _G._HaloLeftArmPointerEnabled = false
        _G._HaloRightArmPointerEnabled = false
        _G._HaloLeftArmStretching = false
        _G._HaloRightArmStretching = false
        _G._HaloLeftArmPointerNeedsReset = true
        _G._HaloRightArmPointerNeedsReset = true
    end
    if Notify then Notify("Reach Mouse: " .. (state and "ON" or "OFF"), 1.4) end
end)

-- Arm Slider (Upper arm welded to hip, stretch controls angle)
_G._HaloArmSliderEnabled = false
_G._HaloArmSliderOffsetX = 0
_G._HaloArmSliderOffsetY = 0
_G._HaloArmSliderStretch = 1.0
_G._HaloArmSliderRotationEnabled = false
_G._HaloArmSliderRotation = 0
_G._HaloArmSliderPrevEnabled = false
_G._HaloArmSliderOriginalTransforms = {}

do
    local frame = Instance.new("Frame"); frame.Parent = LimbsPanel
    frame.Size = UDim2.new(1, 0, 0, 210)
    frame.BackgroundColor3 = C.bg1; frame.BackgroundTransparency = 0.12; frame.BorderSizePixel = 0
    frame.LayoutOrder = 7
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 7); c.Parent = frame
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = frame
    end
    local lbl = Instance.new("TextLabel"); lbl.Parent = frame
    lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 10, 0, 6)
    lbl.Size = UDim2.new(0.45, -10, 0, 16); lbl.Font = Enum.Font.GothamBold
    lbl.Text = "Arm Slider"; lbl.TextColor3 = C.text
    lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 33
    local sub = Instance.new("TextLabel"); sub.Parent = frame
    sub.BackgroundTransparency = 1; sub.Position = UDim2.new(0, 10, 0, 22)
    sub.Size = UDim2.new(0.45, -10, 0, 12); sub.Font = Enum.Font.Gotham
    sub.Text = "Upper arm welded to hip, stretch controls angle"; sub.TextColor3 = C.text3
    sub.TextSize = 8; sub.TextXAlignment = Enum.TextXAlignment.Left; sub.ZIndex = 33
    local toggleBtn = Instance.new("TextButton"); toggleBtn.Parent = frame
    toggleBtn.Size = UDim2.new(0, 40, 0, 18); toggleBtn.Position = UDim2.new(1, -50, 0, 8)
    toggleBtn.BackgroundColor3 = C.bg2; toggleBtn.BorderSizePixel = 0; toggleBtn.ZIndex = 33; toggleBtn.AutoButtonColor = false
    toggleBtn.Font = Enum.Font.GothamBold; toggleBtn.TextSize = 9
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = toggleBtn
    end
    local function setVisualState(on)
        if on then
            toggleBtn.BackgroundColor3 = C.accent; toggleBtn.TextColor3 = Color3.new(1,1,1); toggleBtn.Text = "ON"
        else
            toggleBtn.BackgroundColor3 = C.bg2; toggleBtn.TextColor3 = C.text3; toggleBtn.Text = "OFF"
        end
    end
    setVisualState(false)

    -- Helper to build a mini slider
    local function buildMiniSlider(parent, title, minVal, maxVal, defaultVal, yPos, onChange)
        local lbl = Instance.new("TextLabel"); lbl.Parent = parent
        lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 10, 0, yPos)
        lbl.Size = UDim2.new(0.35, -10, 0, 14); lbl.Font = Enum.Font.GothamBold
        lbl.Text = title .. ": " .. string.format("%.2f", defaultVal); lbl.TextColor3 = C.accent
        lbl.TextSize = 9; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 33

        local track = Instance.new("Frame"); track.Parent = parent
        track.BackgroundColor3 = C.bg2; track.BackgroundTransparency = 0.3; track.BorderSizePixel = 0
        track.Position = UDim2.new(0.38, 0, 0, yPos + 2); track.Size = UDim2.new(0.58, -15, 0, 6); track.ZIndex = 33
        do
            local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 3); c.Parent = track
        end
        local fill = Instance.new("Frame"); fill.Parent = track
        fill.BackgroundColor3 = C.accent; fill.BackgroundTransparency = 0.2; fill.BorderSizePixel = 0
        local p = (defaultVal - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(math.clamp(p, 0, 1), 0, 1, 0); fill.ZIndex = 34
        do
            local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 3); c.Parent = fill
        end
        local handle = Instance.new("Frame"); handle.Parent = track
        handle.Size = UDim2.new(0, 10, 0, 10); handle.AnchorPoint = Vector2.new(0.5, 0.5)
        handle.Position = UDim2.new(math.clamp(p, 0, 1), 0, 0.5, 0); handle.BackgroundColor3 = C.text; handle.ZIndex = 35
        do
            local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = handle
        end

        local dragging = false
        local function setFromMouse(mx)
            local pct = math.clamp((mx - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
            local val = minVal + pct * (maxVal - minVal)
            val = math.floor(val * 100 + 0.5) / 100
            fill.Size = UDim2.new(pct, 0, 1, 0)
            handle.Position = UDim2.new(pct, 0, 0.5, 0)
            lbl.Text = title .. ": " .. string.format("%.2f", val)
            onChange(val)
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                setFromMouse(input.Position.X)
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                setFromMouse(input.Position.X)
            end
        end)
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        return {
            setValue = function(val)
                val = math.clamp(val, minVal, maxVal)
                local pct = (val - minVal) / (maxVal - minVal)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                handle.Position = UDim2.new(pct, 0, 0.5, 0)
                lbl.Text = title .. ": " .. string.format("%.2f", val)
                onChange(val)
            end
        }
    end

    local xSlider = buildMiniSlider(frame, "Left/Right", -2.0, 2.0, 0, 40, function(v)
        _G._HaloArmSliderOffsetX = v
        SaveArmSliderConfig()
    end)
    local ySlider = buildMiniSlider(frame, "Up/Down", -2.0, 2.0, 0, 68, function(v)
        _G._HaloArmSliderOffsetY = v
        SaveArmSliderConfig()
    end)
    local stretchSlider = buildMiniSlider(frame, "Stretch", 1.0, 10.0, 1.0, 96, function(v)
        _G._HaloArmSliderStretch = v
        SaveArmSliderConfig()
    end)

    -- Rotation toggle + slider
    local rotLbl = Instance.new("TextLabel"); rotLbl.Parent = frame
    rotLbl.BackgroundTransparency = 1; rotLbl.Position = UDim2.new(0, 10, 0, 124)
    rotLbl.Size = UDim2.new(0.45, -10, 0, 14); rotLbl.Font = Enum.Font.GothamBold
    rotLbl.Text = "Arm Rotation"; rotLbl.TextColor3 = C.text
    rotLbl.TextSize = 9; rotLbl.TextXAlignment = Enum.TextXAlignment.Left; rotLbl.ZIndex = 33

    local rotToggleBtn = Instance.new("TextButton"); rotToggleBtn.Parent = frame
    rotToggleBtn.Size = UDim2.new(0, 40, 0, 18); rotToggleBtn.Position = UDim2.new(1, -50, 0, 122)
    rotToggleBtn.BackgroundColor3 = C.bg2; rotToggleBtn.BorderSizePixel = 0; rotToggleBtn.ZIndex = 33; rotToggleBtn.AutoButtonColor = false
    rotToggleBtn.Font = Enum.Font.GothamBold; rotToggleBtn.TextSize = 9
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = rotToggleBtn
    end
    local function setRotVisualState(on)
        if on then
            rotToggleBtn.BackgroundColor3 = C.accent; rotToggleBtn.TextColor3 = Color3.new(1,1,1); rotToggleBtn.Text = "ON"
        else
            rotToggleBtn.BackgroundColor3 = C.bg2; rotToggleBtn.TextColor3 = C.text3; rotToggleBtn.Text = "OFF"
        end
    end
    setRotVisualState(false)

    local rotSlider = buildMiniSlider(frame, "Tilt", -85.0, 85.0, 0, 146, function(v)
        _G._HaloArmSliderRotation = v
        SaveArmSliderConfig()
    end)

    -- Apply loaded config to UI sliders
    xSlider.setValue(_G._HaloArmSliderOffsetX or 0)
    ySlider.setValue(_G._HaloArmSliderOffsetY or 0)
    stretchSlider.setValue(_G._HaloArmSliderStretch or 1.0)
    rotSlider.setValue(_G._HaloArmSliderRotation or 0)
    setVisualState(_G._HaloArmSliderEnabled or false)
    setRotVisualState(_G._HaloArmSliderRotationEnabled or false)

    _G._HaloArmSliderSetVisual = setVisualState
    _G._HaloArmSliderSetRotVisual = setRotVisualState
    _G._HaloArmSliderReset = function()
        _G._HaloArmSliderEnabled = false
        _G._HaloArmSliderOffsetX = 0
        _G._HaloArmSliderOffsetY = 0
        _G._HaloArmSliderStretch = 1.0
        _G._HaloArmSliderRotationEnabled = false
        _G._HaloArmSliderRotation = 0
        _G._HaloArmSliderPrevEnabled = false
        setVisualState(false)
        setRotVisualState(false)
        xSlider.setValue(0)
        ySlider.setValue(0)
        stretchSlider.setValue(1.0)
        rotSlider.setValue(0)
        SaveArmSliderConfig()
    end

    toggleBtn.MouseButton1Click:Connect(function()
        _G._HaloArmSliderEnabled = not _G._HaloArmSliderEnabled
        setVisualState(_G._HaloArmSliderEnabled)
        SaveArmSliderConfig()
    end)
    rotToggleBtn.MouseButton1Click:Connect(function()
        _G._HaloArmSliderRotationEnabled = not _G._HaloArmSliderRotationEnabled
        setRotVisualState(_G._HaloArmSliderRotationEnabled)
        SaveArmSliderConfig()
    end)
end
-- Arm Stretch (matched to Torso/Leg stretcher card layout)
local armStretchFrame = Instance.new("Frame"); armStretchFrame.Parent = StretchingPanel
armStretchFrame.Size = UDim2.new(1, 0, 0, 96)
armStretchFrame.BackgroundColor3 = C.bg1
armStretchFrame.BackgroundTransparency = 0.12
armStretchFrame.BorderSizePixel = 0
armStretchFrame.LayoutOrder = 3
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = armStretchFrame
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.4; s.Thickness = 1; s.Parent = armStretchFrame
end

local stTitle = Instance.new("TextLabel"); stTitle.Parent = armStretchFrame
stTitle.BackgroundTransparency = 1; stTitle.Position = UDim2.new(0, 14, 0, 8)
stTitle.Size = UDim2.new(1, -76, 0, 15); stTitle.Font = Enum.Font.GothamMedium
stTitle.Text = "Arm Stretch"; stTitle.TextColor3 = C.text; stTitle.TextSize = 12
stTitle.TextXAlignment = Enum.TextXAlignment.Left; stTitle.ZIndex = 33

local stSub = Instance.new("TextLabel"); stSub.Parent = armStretchFrame
stSub.BackgroundTransparency = 1; stSub.Position = UDim2.new(0, 14, 0, 24)
stSub.Size = UDim2.new(1, -76, 0, 14); stSub.Font = Enum.Font.Gotham
stSub.Text = "Scale arm bone length toward the cursor."; stSub.TextColor3 = C.text3; stSub.TextSize = 10
stSub.TextXAlignment = Enum.TextXAlignment.Left; stSub.ZIndex = 33

local stToggleBg = Instance.new("Frame"); stToggleBg.Parent = armStretchFrame
stToggleBg.Size = UDim2.new(0, 42, 0, 24); stToggleBg.Position = UDim2.new(1, -54, 0, 10)
stToggleBg.BackgroundColor3 = (_G._HaloLeftArmStretching or _G._HaloRightArmStretching) and C.green or C.bg3
stToggleBg.BorderSizePixel = 0; stToggleBg.ZIndex = 33
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = stToggleBg end

local stToggleKnob = Instance.new("Frame", stToggleBg)
stToggleKnob.Size = UDim2.new(0, 18, 0, 18)
stToggleKnob.Position = (_G._HaloLeftArmStretching or _G._HaloRightArmStretching) and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
stToggleKnob.BackgroundColor3 = C.white; stToggleKnob.BorderSizePixel = 0; stToggleKnob.ZIndex = 34
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = stToggleKnob end

local stToggleBtn = Instance.new("TextButton", stToggleBg)
stToggleBtn.Size = UDim2.new(1, 0, 1, 0); stToggleBtn.BackgroundTransparency = 1; stToggleBtn.Text = ""; stToggleBtn.ZIndex = 35

local stNumBox = Instance.new("TextBox"); stNumBox.Parent = armStretchFrame
stNumBox.Size = UDim2.new(0, 64, 0, 22)
stNumBox.Position = UDim2.new(0, 14, 0, 44)
stNumBox.BackgroundColor3 = C.bg3
stNumBox.BackgroundTransparency = 0.05
stNumBox.BorderSizePixel = 0
stNumBox.Font = Enum.Font.GothamMedium
stNumBox.Text = string.format("%.2f", _G._HaloArmStretchAmount or 2.5)
stNumBox.TextColor3 = C.text
stNumBox.TextSize = 11
stNumBox.ClearTextOnFocus = false
stNumBox.ZIndex = 34
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = stNumBox
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.45; s.Thickness = 1; s.Parent = stNumBox
end

local stUnit = Instance.new("TextLabel"); stUnit.Parent = armStretchFrame
stUnit.BackgroundTransparency = 1
stUnit.Position = UDim2.new(0, 82, 0, 44)
stUnit.Size = UDim2.new(0, 24, 0, 22)
stUnit.Font = Enum.Font.Gotham
stUnit.Text = "x"
stUnit.TextColor3 = C.text3
stUnit.TextSize = 11
stUnit.TextXAlignment = Enum.TextXAlignment.Left
stUnit.ZIndex = 33

local stResetBtn = Instance.new("TextButton"); stResetBtn.Parent = armStretchFrame
stResetBtn.Size = UDim2.new(0, 52, 0, 22)
stResetBtn.Position = UDim2.new(1, -66, 0, 44)
stResetBtn.BackgroundColor3 = C.bg3
stResetBtn.BackgroundTransparency = 0.05
stResetBtn.BorderSizePixel = 0
stResetBtn.Font = Enum.Font.GothamBold
stResetBtn.Text = "Reset"
stResetBtn.TextColor3 = C.text2
stResetBtn.TextSize = 10
stResetBtn.AutoButtonColor = false
stResetBtn.ZIndex = 34
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = stResetBtn
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.45; s.Thickness = 1; s.Parent = stResetBtn
end

local stTrack = Instance.new("Frame"); stTrack.Parent = armStretchFrame
stTrack.BackgroundColor3 = C.bg3; stTrack.BackgroundTransparency = 0.15; stTrack.BorderSizePixel = 0
stTrack.Position = UDim2.new(0, 14, 0, 76); stTrack.Size = UDim2.new(1, -28, 0, 6); stTrack.ZIndex = 33
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = stTrack end

local curAmt = _G._HaloArmStretchAmount or 2.5
local stMin, stMax = 0.5, 1000
local stPct = math.clamp((curAmt - stMin) / (stMax - stMin), 0, 1)

local stFill = Instance.new("Frame"); stFill.Parent = stTrack
stFill.BackgroundColor3 = C.white; stFill.BackgroundTransparency = 0.05; stFill.BorderSizePixel = 0
stFill.Size = UDim2.new(stPct, 0, 1, 0); stFill.ZIndex = 34
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = stFill end

local stHandle = Instance.new("Frame"); stHandle.Parent = stTrack
stHandle.Size = UDim2.new(0, 12, 0, 12); stHandle.AnchorPoint = Vector2.new(0.5, 0.5)
stHandle.Position = UDim2.new(stPct, 0, 0.5, 0); stHandle.BackgroundColor3 = C.white; stHandle.ZIndex = 35
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = stHandle end

local stDragBtn = Instance.new("TextButton"); stDragBtn.Parent = stTrack
stDragBtn.Size = UDim2.new(1, 0, 1, 0); stDragBtn.BackgroundTransparency = 1; stDragBtn.Text = ""; stDragBtn.ZIndex = 36

local ArmStretchEnabled = _G._HaloLeftArmStretching or _G._HaloRightArmStretching or false

local function updateStretchState()
    if ArmStretchEnabled then
        TweenService:Create(stToggleBg, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundColor3 = C.green}):Play()
        TweenService:Create(stToggleKnob, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
            Position = UDim2.new(1, -21, 0.5, -9), BackgroundColor3 = C.white
        }):Play()
        _G._HaloLeftArmStretching = true
        _G._HaloRightArmStretching = true
    else
        TweenService:Create(stToggleBg, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundColor3 = C.bg3}):Play()
        TweenService:Create(stToggleKnob, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
            Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = C.white
        }):Play()
        _G._HaloLeftArmStretching = false
        _G._HaloRightArmStretching = false
    end
end

local function applyArmStretchAmount(val)
    val = math.clamp(tonumber(val) or (_G._HaloArmStretchAmount or 2.5), stMin, stMax)
    val = math.floor(val * 100 + 0.5) / 100
    _G._HaloArmStretchAmount = val
    local pct = math.clamp((val - stMin) / (stMax - stMin), 0, 1)
    stFill.Size = UDim2.new(pct, 0, 1, 0)
    stHandle.Position = UDim2.new(pct, 0, 0.5, 0)
    stNumBox.Text = string.format("%.2f", val)
end

_G._HaloResetArmStretch = function()
    applyArmStretchAmount(2.5)
end

stToggleBtn.MouseButton1Click:Connect(function()
    if not State.isReanimated then
        Notify("Turn on Reanimation first!", 2)
        return
    end
    ArmStretchEnabled = not ArmStretchEnabled
    updateStretchState()
end)

local stDragging = false
local function setStretchFromMouse(mx)
    local pct = math.clamp((mx - stTrack.AbsolutePosition.X) / math.max(stTrack.AbsoluteSize.X, 1), 0, 1)
    local amt = stMin + pct * (stMax - stMin)
    applyArmStretchAmount(amt)
end

stDragBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        stDragging = true
        setStretchFromMouse(inp.Position.X)
    end
end)
stDragBtn.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        stDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if stDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        setStretchFromMouse(inp.Position.X)
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        stDragging = false
    end
end)

stNumBox.FocusLost:Connect(function()
    local cleaned = stNumBox.Text:gsub("[^%d%.%-]", "")
    local val = tonumber(cleaned)
    if val then
        applyArmStretchAmount(val)
    else
        stNumBox.Text = string.format("%.2f", _G._HaloArmStretchAmount or 2.5)
    end
end)

stResetBtn.MouseEnter:Connect(function()
    TweenService:Create(stResetBtn, TweenInfo.new(0.12), {BackgroundColor3 = C.bg2, TextColor3 = C.text}):Play()
end)
stResetBtn.MouseLeave:Connect(function()
    TweenService:Create(stResetBtn, TweenInfo.new(0.12), {BackgroundColor3 = C.bg3, TextColor3 = C.text2}):Play()
end)
stResetBtn.MouseButton1Click:Connect(function()
    applyArmStretchAmount(2.5)
    if Notify then Notify("Arm Stretch reset", 1.2) end
end)

-- Ctrl + MouseWheel stretch control
_G._HaloReanimConns = _G._HaloReanimConns or {}
_G._HaloCtrlHeld = false

local function _haloStretchWheelAction(actionName, inputState, inputObj)
    if inputState == Enum.UserInputState.Change then
        if not _G._HaloRightArmStretching or not _G._HaloLeftArmStretching then
            ArmStretchEnabled = true
            updateStretchState()
        end
        local current = _G._HaloArmStretchAmount or 2.5
        local delta = (inputObj.Position.Z > 0) and 2.5 or -2.5
        local newAmt = math.clamp(current + delta, 0.5, 1000.0)
        _G._HaloArmStretchAmount = newAmt
        local newPct = (newAmt - 0.5) / 1000
        stFill.Size = UDim2.new(newPct, 0, 1, 0)
        stHandle.Position = UDim2.new(newPct, 0, 0.5, 0)
        stAmtLbl.Text = "Amount: " .. string.format("%.1f", newAmt) .. "x"
        if stNumBox then stNumBox.Text = string.format("%.1f", newAmt) end
    end
    return Enum.ContextActionResult.Sink
end

_G._HaloReanimConns.StretchCtrlBegan = UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.LeftControl or inp.KeyCode == Enum.KeyCode.RightControl then
        if not _G._HaloCtrlHeld then
            _G._HaloCtrlHeld = true
            pcall(function()
                ContextActionService:BindAction("HaloStretchWheel", _haloStretchWheelAction, false, Enum.UserInputType.MouseWheel)
            end)
        end
    end
end)

_G._HaloReanimConns.StretchCtrlEnded = UserInputService.InputEnded:Connect(function(inp, gp)
    if inp.KeyCode == Enum.KeyCode.LeftControl or inp.KeyCode == Enum.KeyCode.RightControl then
        local stillHeld = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        if not stillHeld then
            _G._HaloCtrlHeld = false
            pcall(function()
                ContextActionService:UnbindAction("HaloStretchWheel")
            end)
        end
    end
end)

-- ============================================
-- LIMBS CONTROL LOGIC  (Optimized v2)
-- ============================================
local limbsConn = nil

-- Fast O(1) limb cache: direct child lookup, no descendant scans
local limbsCache = nil
local limbsOrig = nil

-- Change-detection state so we never burn CPU rewriting unchanged CFrames
local limbsState = {
    lastUTHeight = -1,
    lastLegScale = -1,
    lastCamEnabled = false,
    lastCamMode = "",
    lastCamLook = Vector3.new(),
    smoothYaw = 0,
    smoothPitch = 0,
    wasTorsoOn = false,
    torsoCleanup = 0,
    wasLegOn = false,
    legCleanup = 0,
}

local function cacheLimbsFast(clone)
    if not clone then return end
    if limbsCache and limbsCache.clone == clone and limbsCache.ut and limbsCache.ut.Parent then return end
    local ut  = clone:FindFirstChild("UpperTorso") or clone:FindFirstChild("Torso")
    local lt  = clone:FindFirstChild("LowerTorso") or clone:FindFirstChild("HumanoidRootPart")
    local head = clone:FindFirstChild("Head")
    local lua = clone:FindFirstChild("LeftUpperArm") or clone:FindFirstChild("Left Arm")
    local rua = clone:FindFirstChild("RightUpperArm") or clone:FindFirstChild("Right Arm")
    local lul = clone:FindFirstChild("LeftUpperLeg") or clone:FindFirstChild("Left Leg")
    local rul = clone:FindFirstChild("RightUpperLeg") or clone:FindFirstChild("Right Leg")
    local lll = clone:FindFirstChild("LeftLowerLeg")
    local rll = clone:FindFirstChild("RightLowerLeg")
    local lf  = clone:FindFirstChild("LeftFoot")
    local rf  = clone:FindFirstChild("RightFoot")

    local waist = (lt and lt:FindFirstChild("Waist")) or (ut and ut:FindFirstChild("Waist")) or (lt and lt:FindFirstChild("RootJoint")) or (ut and ut:FindFirstChild("RootJoint"))
    local neck  = (ut and ut:FindFirstChild("Neck")) or (head and head:FindFirstChild("Neck"))
    local ls    = (ut and ut:FindFirstChild("LeftShoulder")) or (ut and ut:FindFirstChild("Left Shoulder"))
    local rs    = (ut and ut:FindFirstChild("RightShoulder")) or (ut and ut:FindFirstChild("Right Shoulder"))
    local lh    = (lt and lt:FindFirstChild("LeftHip")) or (lt and lt:FindFirstChild("Left Hip"))
    local rh    = (lt and lt:FindFirstChild("RightHip")) or (lt and lt:FindFirstChild("Right Hip"))
    local llk   = lul and lul:FindFirstChild("LeftKnee")
    local rlk   = rul and rul:FindFirstChild("RightKnee")
    local lak   = lll and lll:FindFirstChild("LeftAnkle")
    local rak   = rll and rll:FindFirstChild("RightAnkle")

    limbsCache = {
        clone = clone,
        ut = ut, lt = lt, head = head,
        lua = lua, rua = rua, lul = lul, rul = rul,
        lll = lll, rll = rll, lf = lf, rf = rf,
        waist = waist, neck = neck, ls = ls, rs = rs,
        lh = lh, rh = rh, llk = llk, rlk = rlk, lak = lak, rak = rak
    }

    limbsOrig = {
        waistC0 = waist and waist.C0 or CFrame.new(),
        neckC0  = neck and neck.C0 or CFrame.new(),
        lsC0    = ls   and ls.C0   or CFrame.new(),
        rsC0    = rs   and rs.C0   or CFrame.new(),
        lhC0    = lh   and lh.C0   or CFrame.new(),
        rhC0    = rh   and rh.C0   or CFrame.new(),
        llkC0   = llk  and llk.C0  or CFrame.new(),
        rlkC0   = rlk  and rlk.C0  or CFrame.new(),
        lakC0   = lak  and lak.C0  or CFrame.new(),
        rakC0   = rak  and rak.C0  or CFrame.new(),
        lulSize = lul and lul.Size.Y or 1.2,
        rulSize = rul and rul.Size.Y or 1.2,
        lllSize = lll and lll.Size.Y or 1.05,
        rllSize = rll and rll.Size.Y or 1.05,
        lfSize  = lf  and lf.Size.Y  or 0.3,
        rfSize  = rf  and rf.Size.Y  or 0.3,
    }
end

local function startLimbsSystem()
    if limbsConn then limbsConn:Disconnect(); limbsConn = nil end
    limbsCache = nil
    limbsOrig  = nil
    limbsState.lastUTHeight = -1
    limbsState.lastLegScale = -1
    limbsState.lastCamEnabled = false
    limbsState.lastCamMode = ""
    limbsState.lastCamLook = Vector3.new()
    limbsState.smoothYaw = 0
    limbsState.smoothPitch = 0

    limbsConn = RunService.Stepped:Connect(LPH_NO_VIRTUALIZE(function()
        if not State.isReanimated then return end
        local clone = ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
        if not clone then return end
        if not limbsCache then cacheLimbsFast(clone) end
        if not limbsCache then return end

        -- UpperTorso + TorsoCam when NO custom animation is playing
        -- (When a custom animation IS playing, the animation heartbeat handles this)
        local animData = ReanimateAPI and ReanimateAPI.get_animation_data and ReanimateAPI.get_animation_data()
        local isPlaying = animData and animData.state and animData.state.is_playing
        if isPlaying then return end

        -- Ensure constraint cache exists so Head Tracker / Arm Pointer work
        -- even when no custom animation is currently playing.
        -- Rebuild whenever the clone changes so references stay valid.
        if animData and (not animData.constraints_cache or animData._lastConstraintClone ~= clone) then
            animData._lastConstraintClone = clone
            animData.constraints_cache = {}
            animData.bind_transforms = {}
            animData.bind_lengths = {}
            for _, descendant in ipairs(clone:GetDescendants()) do
                if descendant:IsA("AnimationConstraint") then
                    local attachment = descendant.Attachment1
                    if attachment and attachment.Parent then
                        animData.constraints_cache[attachment.Parent.Name] = descendant
                        animData.bind_transforms[descendant] = descendant.Transform
                        local att0 = descendant.Attachment0
                        local att1 = descendant.Attachment1
                        if att0 and att1 and att0.Parent and att1.Parent then
                            local len = (att1.WorldCFrame.Position - att0.WorldCFrame.Position).Magnitude
                            if len > 0.001 then
                                animData.bind_lengths[descendant] = len
                            end
                        end
                    end
                elseif descendant:IsA("Motor6D") or descendant:IsA("Motor") then
                    local childPart = descendant.Part1
                    if childPart and childPart.Parent and not animData.constraints_cache[childPart.Name] then
                        animData.constraints_cache[childPart.Name] = descendant
                        animData.bind_transforms[descendant] = descendant.Transform
                    end
                    -- Also index by the joint name itself for hip lookups
                    if not animData.constraints_cache[descendant.Name] then
                        animData.constraints_cache[descendant.Name] = descendant
                    end
                end
            end
        end
        if animData then
            -- Always repopulate constraints from the live cache so we never
            -- hold stale references after a reanimate toggle.
            table.clear(animData.constraints)
            table.clear(animData.original_transforms)
            for partName, constraint in pairs(animData.constraints_cache) do
                if constraint and constraint.Parent then
                    animData.constraints[partName] = constraint
                    animData.original_transforms[constraint] = animData.bind_transforms[constraint] or constraint.Transform
                end
            end
        end
        local anim = animData

        -- Fun head modes (spin / stare) take priority over camera head tracker
        if _G._HaloSpinHeadEnabled or _G._HaloStareEnabled or _G._HaloLookBehindEnabled
            or _G._HaloNodLoopEnabled or _G._HaloHeadTiltEnabled or _G._HaloCraneNeckEnabled then
            -- handled by fun tracking PreSimulation loop
        elseif _G._HaloHeadTrackerEnabled then
            local headConstraint = anim.constraints["Head"];
            if headConstraint then
                local camera = workspace.CurrentCamera;
                if camera then
                    local parentWorldCF = nil;
                    if headConstraint:IsA("Motor6D") and headConstraint.Part0 then
                        parentWorldCF = headConstraint.Part0.CFrame * headConstraint.C0;
                    else
                        local att0 = headConstraint.Attachment0;
                        if att0 and att0.Parent then
                            parentWorldCF = att0.WorldCFrame;
                        end;
                    end;
                    if parentWorldCF then
                        local bindTransform = anim.original_transforms[headConstraint];
                        if bindTransform then
                            local camLook = camera.CFrame.LookVector;
                            local localLookDir = parentWorldCF.Rotation:Inverse() * camLook;

                            -- Extract yaw & pitch and clamp to realistic neck limits
                            local yaw = math.atan2(localLookDir.X, -localLookDir.Z);
                            local pitch = math.asin(math.clamp(localLookDir.Y, -1, 1));
                            if not _G._HaloHeadTracker360 then
                                local maxYaw = math.rad(75);
                                local maxPitch = math.rad(55);
                                yaw = math.clamp(yaw, -maxYaw, maxYaw);
                                pitch = math.clamp(pitch, -maxPitch, maxPitch);
                            end

                            -- Rebuild clamped local look direction
                            local clampedDir = Vector3.new(
                                math.sin(yaw) * math.cos(pitch),
                                math.sin(pitch),
                                -math.cos(yaw) * math.cos(pitch)
                            ).Unit;

                            -- Compute target rotation from bind pose to clamped direction
                            local bindDir = bindTransform.LookVector;
                            local rotAxis = bindDir:Cross(clampedDir);
                            local targetTransform;
                            if rotAxis.Magnitude > 0.001 then
                                rotAxis = rotAxis.Unit;
                                local angle = math.acos(math.clamp(bindDir:Dot(clampedDir), -1, 1));
                                targetTransform = CFrame.fromAxisAngle(rotAxis, angle) * bindTransform;
                            elseif bindDir:Dot(clampedDir) < 0 then
                                local perp = bindDir:Cross(Vector3.new(0, 1, 0));
                                if perp.Magnitude < 0.001 then
                                    perp = bindDir:Cross(Vector3.new(1, 0, 0));
                                end;
                                targetTransform = CFrame.fromAxisAngle(perp.Unit, math.pi) * bindTransform;
                            else
                                targetTransform = bindTransform;
                            end;

                            -- Smooth interpolation so it feels like a real neck turning
                            local smoothed = _G._HaloHeadTrackerSmoothedCF or bindTransform;
                            smoothed = smoothed:Lerp(targetTransform, 0.15);
                            _G._HaloHeadTrackerSmoothedCF = smoothed;
                            headConstraint.Transform = smoothed;
                        end;
                    end;
                end;
            end;
        end;

        -- Arm Pointer: straight arm pointing at mouse target
        if _G._HaloLeftArmPointerEnabled or _G._HaloRightArmPointerEnabled then
            local camera = workspace.CurrentCamera
            local mouse = plr:GetMouse()
            if camera and mouse then
                local targetPos
                local unitRay = camera:ViewportPointToRay(mouse.X, mouse.Y)
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                local filterList = {}
                pcall(function()
                    if ReanimateAPI.get_clone then
                        local clone = ReanimateAPI.get_clone(plr)
                        if clone then table.insert(filterList, clone) end
                    end
                    if ReanimateAPI.get_real_character then
                        local real = ReanimateAPI.get_real_character(plr)
                        if real then table.insert(filterList, real) end
                    end
                end)
                rayParams.FilterDescendantsInstances = filterList
                local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, rayParams)
                if result then
                    targetPos = result.Position
                else
                    targetPos = unitRay.Origin + unitRay.Direction * 1000
                end

                local function pointArm(upperName, lowerName, handName, stretchMult)
                    local shoulderConstraint = anim.constraints[upperName]
                    if not shoulderConstraint then return end

                    -- Refresh to straight bind pose on first frame after re-enable
                    local isLeft = upperName:find("Left") ~= nil
                    local resetFlag = isLeft and _G._HaloLeftArmPointerNeedsReset or _G._HaloRightArmPointerNeedsReset
                    if resetFlag then
                        local orig = anim.original_transforms[shoulderConstraint]
                        if orig then shoulderConstraint.Transform = orig end
                        local elbowConstraint = anim.constraints[lowerName]
                        if elbowConstraint then elbowConstraint.Transform = CFrame.new() end
                        local wristConstraint = anim.constraints[handName]
                        if wristConstraint then wristConstraint.Transform = CFrame.new() end
                        if isLeft then _G._HaloLeftArmPointerNeedsReset = false
                        else _G._HaloRightArmPointerNeedsReset = false end
                    end

                    local shoulderWorldCF = nil;
                    if shoulderConstraint:IsA("Motor6D") and shoulderConstraint.Part0 then
                        shoulderWorldCF = shoulderConstraint.Part0.CFrame * shoulderConstraint.C0;
                    else
                        local att0 = shoulderConstraint.Attachment0
                        if att0 and att0.Parent then
                            shoulderWorldCF = att0.WorldCFrame
                        end
                    end
                    if not shoulderWorldCF then return end

                    local shoulderPos = shoulderWorldCF.Position
                    local aimDir = (targetPos - shoulderPos)
                    if aimDir.Magnitude <= 0.001 then return end
                    aimDir = aimDir.Unit

                    -- Use current animated transform as base so the pointer
                    -- rotates from the live pose (e.g. custom idle) instead
                    -- of fighting against stale bind data.
                    local bindTransform = shoulderConstraint.Transform
                    if not bindTransform then return end

                    -- R15 convention: the arm bone extends along the child's local -Y axis.
                    local childBoneDir = Vector3.new(0, -1, 0)
                    local bindBoneDir = (bindTransform.Rotation * childBoneDir).Unit
                    local localAimDir = shoulderWorldCF.Rotation:Inverse() * aimDir

                    -- Compute shortest rotation from bindBoneDir to localAimDir
                    local rotAxis = bindBoneDir:Cross(localAimDir)
                    local shoulderResult
                    if rotAxis.Magnitude > 0.001 then
                        rotAxis = rotAxis.Unit
                        local angle = math.acos(math.clamp(bindBoneDir:Dot(localAimDir), -1, 1))
                        local rotationCF = CFrame.fromAxisAngle(rotAxis, angle)
                        shoulderResult = rotationCF * bindTransform
                    elseif bindBoneDir:Dot(localAimDir) < 0 then
                        local perp = bindBoneDir:Cross(Vector3.new(0, 1, 0))
                        if perp.Magnitude < 0.001 then
                            perp = bindBoneDir:Cross(Vector3.new(1, 0, 0))
                        end
                        shoulderResult = CFrame.fromAxisAngle(perp.Unit, math.pi) * bindTransform
                    else
                        shoulderResult = bindTransform
                    end

                    shoulderConstraint.Transform = shoulderResult

                    -- Force elbow and wrist to pure bind pose (identity) so the arm
                    -- stays perfectly straight and never drifts over time.
                    local elbowConstraint = anim.constraints[lowerName]
                    if elbowConstraint then
                        elbowConstraint.Transform = CFrame.new()
                    end
                    local wristConstraint = anim.constraints[handName]
                    if wristConstraint then
                        wristConstraint.Transform = CFrame.new()
                    end

                    -- Stretch only the lower arm so it gets longer.
                    stretchMult = stretchMult or 1.0
                    if stretchMult ~= 1.0 then
                        local c = anim.constraints[lowerName]
                        if c then
                            local baseLen = anim.bind_lengths and anim.bind_lengths[c]
                            if not baseLen or baseLen < 0.001 then
                                if c:IsA("Motor6D") and c.Part1 and c.Part1:IsA("BasePart") then
                                    baseLen = c.Part1.Size.Y
                                else
                                    local att1 = c and c.Attachment1
                                    if att1 and att1.Parent and att1.Parent:IsA("BasePart") then
                                        baseLen = att1.Parent.Size.Y
                                    else
                                        baseLen = 1.2
                                    end
                                end
                            end
                            -- Stretch straight along local -Y (identity rotation)
                            -- so the arm stays perfectly straight; bind.Rotation
                            -- was reintroducing the bind-pose bend.
                            local boneDir = Vector3.new(0, -1, 0)
                            local stretchOffset = boneDir * baseLen * (stretchMult - 1.0)
                            c.Transform = CFrame.new(stretchOffset)
                        end
                    end
                end

                local stretchAmt = _G._HaloArmStretchAmount or 2.5
                local function stretchArmOnly(lowerName, handName, stretchMult)
                    if not stretchMult or stretchMult == 1.0 then return end
                    local lower = (animData and animData.constraints_cache and animData.constraints_cache[lowerName]) or (clone and clone:FindFirstChild(lowerName, true))
                    local offset = CFrame.new(0, -(stretchMult - 1.0) * 1.2, 0)
                    local baseL = (animData and animData.bind_transforms and animData.bind_transforms[lower]) or CFrame.new()
                    if lower and lower.Parent then lower.Transform = offset * baseL end
                end

                if _G._HaloRightArmPointerEnabled then
                    local isStretching = _G._HaloRightArmStretching or false
                    pointArm("RightUpperArm", "RightLowerArm", "RightHand", isStretching and stretchAmt or 1.0)
                elseif not _G._HaloLeftArmPointerEnabled and not _G._HaloRightArmPointerEnabled and _G._HaloRightArmStretching and stretchAmt ~= 1.0 then
                    stretchArmOnly("RightLowerArm", "RightHand", stretchAmt)
                end

                if _G._HaloLeftArmPointerEnabled then
                    local isStretching = _G._HaloLeftArmStretching or false
                    pointArm("LeftUpperArm", "LeftLowerArm", "LeftHand", isStretching and stretchAmt or 1.0)
                elseif not _G._HaloRightArmPointerEnabled and not _G._HaloLeftArmPointerEnabled and _G._HaloLeftArmStretching and stretchAmt ~= 1.0 then
                    stretchArmOnly("LeftLowerArm", "LeftHand", stretchAmt)
                end
            end

            -- ============================================
            -- ARM SLIDER: Upper arm welded to hip, stretch controls angle
            -- ============================================
            -- Unweld / restore original transforms when toggled off
            if not _G._HaloArmSliderEnabled and _G._HaloArmSliderPrevEnabled then
                _G._HaloArmSliderPrevEnabled = false
                for constraint, orig in pairs(_G._HaloArmSliderOriginalTransforms) do
                    if constraint and constraint.Parent then
                        pcall(function() constraint.Transform = orig end)
                    end
                end
                _G._HaloArmSliderOriginalTransforms = {}
            end
            if _G._HaloArmSliderEnabled then
                _G._HaloArmSliderPrevEnabled = true
                local offsetX = _G._HaloArmSliderOffsetX or 0
                local offsetY = _G._HaloArmSliderOffsetY or 0
                local stretch = _G._HaloArmSliderStretch or 1.0
                local rotEnabled = _G._HaloArmSliderRotationEnabled or false
                local rotDeg = _G._HaloArmSliderRotation or 0

                local rUpper = anim.constraints["RightUpperArm"] or _HaloFindConstraintOnClone(clone, "RightUpperArm")
                local rLower = anim.constraints["RightLowerArm"] or _HaloFindConstraintOnClone(clone, "RightLowerArm")
                local rHand = anim.constraints["RightHand"] or _HaloFindConstraintOnClone(clone, "RightHand")
                local hipJoint = anim.constraints["LowerTorso"] or anim.constraints["Waist"] or anim.constraints["Torso"]
                    or _HaloFindConstraintOnClone(clone, "LowerTorso") or _HaloFindConstraintOnClone(clone, "Waist")
                    or _HaloFindConstraintOnClone(clone, "Root") or _HaloFindConstraintOnClone(clone, "Torso")

                if rUpper and hipJoint then
                    -- Get the hip's live world CFrame (position + rotation)
                    local hipWorldCF
                    if hipJoint:IsA("Motor6D") then
                        if hipJoint.Part0 then
                            hipWorldCF = hipJoint.Part0.CFrame * hipJoint.C0
                        elseif hipJoint.Part1 then
                            hipWorldCF = hipJoint.Part1.CFrame * hipJoint.C1
                        end
                    else
                        local att0 = hipJoint.Attachment0
                        if att0 and att0.Parent then
                            hipWorldCF = att0.WorldCFrame
                        end
                    end

                    if hipWorldCF then
                        -- Target position: offset from hip in hip-local space
                        local targetPos = hipWorldCF.Position 
                            + hipWorldCF.RightVector * (0.3 + offsetX)
                            + hipWorldCF.UpVector * (0.2 + offsetY)
                            + hipWorldCF.LookVector * 0.25

                        -- Stretch controls base angle:
                        -- stretch 1.0 = -45 deg (pointing down)
                        -- stretch 10.0 = +85 deg (pointing up, capped)
                        local stretchAngleDeg = -45 + (stretch - 1) * (130 / 9)
                        stretchAngleDeg = math.clamp(stretchAngleDeg, -45, 85)

                        -- Rotation slider adds independent tilt
                        local totalAngleDeg = stretchAngleDeg
                        if rotEnabled then
                            totalAngleDeg = totalAngleDeg + rotDeg
                        end
                        local totalAngleRad = math.rad(totalAngleDeg)

                        -- Swing arm around shoulder (RightVector axis)
                        -- stretch 1.0 = down/back (image 1), stretch 10.0 = forward/up (image 2)
                        local t = math.clamp((stretch - 1) / 9, 0, 1)
                        local minAngle = math.rad(-15)     -- down/back
                        local maxAngle = math.rad(-135)    -- forward/up
                        local swingAngle = minAngle + t * (maxAngle - minAngle)

                        local armDir = (
                            -hipWorldCF.UpVector * math.cos(swingAngle)
                            - hipWorldCF.LookVector * math.sin(swingAngle)
                            + hipWorldCF.RightVector * 0.15
                        ).Unit

                        -- Build desired upper-arm world CFrame
                        -- RightVector = shoulder hinge axis (prevents twist/spin)
                        local yAxis = -armDir
                        local xAxis = hipWorldCF.RightVector
                        local zAxis = xAxis:Cross(yAxis).Unit
                        local desiredCF = CFrame.fromMatrix(targetPos, xAxis, yAxis)

                        -- Save original transforms before modifying (for unweld on toggle off)
                        if not _G._HaloArmSliderOriginalTransforms[rUpper] then
                            pcall(function()
                                _G._HaloArmSliderOriginalTransforms[rUpper] = rUpper.Transform
                            end)
                        end
                        if rLower and not _G._HaloArmSliderOriginalTransforms[rLower] then
                            pcall(function()
                                _G._HaloArmSliderOriginalTransforms[rLower] = rLower.Transform
                            end)
                        end
                        if rHand and not _G._HaloArmSliderOriginalTransforms[rHand] then
                            pcall(function()
                                _G._HaloArmSliderOriginalTransforms[rHand] = rHand.Transform
                            end)
                        end

                        -- Convert desired world CFrame into shoulder Transform
                        if rUpper:IsA("Motor6D") and rUpper.Part0 and rUpper.Part1 then
                            local part0CF = rUpper.Part0.CFrame
                            local c0 = rUpper.C0
                            local c1 = rUpper.C1
                            rUpper.Transform = c0:Inverse() * part0CF:Inverse() * desiredCF * c1
                        else
                            local att0 = rUpper.Attachment0
                            local att1 = rUpper.Attachment1
                            if att0 and att1 then
                                local desiredAtt1World = desiredCF * att1.CFrame
                                rUpper.Transform = att0.WorldCFrame:Inverse() * desiredAtt1World
                            end
                        end
                    end
                end

                if rLower then
                    local baseLen = anim.bind_lengths and anim.bind_lengths[rLower]
                    if not baseLen or baseLen < 0.001 then
                        if rLower:IsA("Motor6D") and rLower.Part1 and rLower.Part1:IsA("BasePart") then
                            baseLen = rLower.Part1.Size.Y
                        else
                            local att1 = rLower and rLower.Attachment1
                            if att1 and att1.Parent and att1.Parent:IsA("BasePart") then
                                baseLen = att1.Parent.Size.Y
                            else
                                baseLen = 1.2
                            end
                        end
                    end
                    if stretch ~= 1.0 then
                        local stretchOffset = Vector3.new(0, -baseLen * (stretch - 1.0), 0)
                        rLower.Transform = CFrame.new(stretchOffset)
                    else
                        rLower.Transform = CFrame.new()
                    end
                end

                if rHand then
                    rHand.Transform = CFrame.new()
                end
            end

        end
        -- Torso Stretcher + Torso Camera Control
        local doTorso = _G._HaloTorsoStretcherEnabled or _G._HaloLimbsTorsoCamControl
        if doTorso then
            local animData = ReanimateAPI and ReanimateAPI.get_animation_data and ReanimateAPI.get_animation_data()
            local waistConstraint = nil
            if animData and animData.constraints_cache and next(animData.constraints_cache) then
                waistConstraint = animData.constraints_cache["UpperTorso"] or animData.constraints_cache["Waist"] or animData.constraints_cache["LowerTorso"]
            end
            if not waistConstraint or not waistConstraint.Parent then
                local lt = clone:FindFirstChild("LowerTorso")
                if lt then waistConstraint = lt:FindFirstChild("Waist") end
                if not waistConstraint then
                    local ut = clone:FindFirstChild("UpperTorso")
                    if ut then waistConstraint = ut:FindFirstChild("Waist") end
                end
                if not waistConstraint then
                    for _, d in ipairs(clone:GetDescendants()) do
                        if (d:IsA("Motor6D") or d:IsA("AnimationConstraint")) and (d.Name == "Waist" or d.Name == "RootJoint" or d.Name == "Root") then
                            waistConstraint = d
                            break
                        end
                    end
                end
            end

            if waistConstraint and waistConstraint.Parent then
                local baseRot = waistConstraint.Transform.Rotation

                if _G._HaloLimbsTorsoCamControl then
                    local camera = workspace.CurrentCamera
                    if camera then
                        local parentWorldCF = nil
                        if waistConstraint:IsA("Motor6D") and waistConstraint.Part0 then
                            parentWorldCF = waistConstraint.Part0.CFrame * waistConstraint.C0
                        else
                            local att0 = waistConstraint.Attachment0
                            if att0 and att0.Parent then
                                parentWorldCF = att0.WorldCFrame
                            end
                        end

                        if parentWorldCF then
                            local camLook = camera.CFrame.LookVector
                            local localLookDir = parentWorldCF.Rotation:Inverse() * camLook
                            local yaw = math.atan2(localLookDir.X, -localLookDir.Z)
                            local pitch = math.asin(math.clamp(localLookDir.Y, -1, 1))

                            local camMode = _G._HaloLimbsTorsoCamMode or "360"
                            local camRotCF
                            if camMode == "Locked" then
                                yaw = math.clamp(yaw, -math.rad(45), math.rad(45))
                                pitch = math.clamp(pitch, -math.rad(30), math.rad(30))
                                camRotCF = CFrame.fromEulerAnglesYXZ(pitch, -yaw, 0)
                            elseif camMode == "Free" then
                                camRotCF = parentWorldCF.Rotation:Inverse() * camera.CFrame.Rotation
                            else
                                local fullPitch = pitch * 2.25
                                camRotCF = CFrame.fromEulerAnglesYXZ(fullPitch, -yaw, 0)
                            end

                            local smoothed = _G._HaloTorsoCamSmoothedCF or camRotCF
                            smoothed = smoothed:Lerp(camRotCF, 0.25)
                            _G._HaloTorsoCamSmoothedCF = smoothed
                            baseRot = smoothed * baseRot
                        end
                    end
                else
                    _G._HaloTorsoCamSmoothedCF = nil
                end

                local utHeight = _G._HaloLimbsUpperTorsoHeight or 1.0
                local stretchY = _G._HaloTorsoStretcherEnabled and ((utHeight - 1.0) * 2.5) or 0
                waistConstraint.Transform = CFrame.new(0, stretchY, 0) * baseRot
            end
            limbsState.wasTorsoOn = true
            limbsState.torsoCleanup = 0
        else
            if limbsState.wasTorsoOn then
                -- Smooth cleanup: lerp waist back to identity over several frames
                limbsState.torsoCleanup = limbsState.torsoCleanup + 1
                local animData = ReanimateAPI and ReanimateAPI.get_animation_data and ReanimateAPI.get_animation_data()
                local waistConstraint = nil
                if animData and animData.constraints_cache and next(animData.constraints_cache) then
                    waistConstraint = animData.constraints_cache["UpperTorso"] or animData.constraints_cache["Waist"] or animData.constraints_cache["LowerTorso"]
                end
                if not waistConstraint then
                    local lt = clone:FindFirstChild("LowerTorso")
                    if lt then waistConstraint = lt:FindFirstChild("Waist") end
                    if not waistConstraint then
                        local ut = clone:FindFirstChild("UpperTorso")
                        if ut then waistConstraint = ut:FindFirstChild("Waist") end
                    end
                end
                if waistConstraint and waistConstraint.Parent then
                    local current = waistConstraint.Transform
                    local target = CFrame.new()
                    waistConstraint.Transform = current:Lerp(target, 0.12)
                    if limbsState.torsoCleanup > 25 then
                        waistConstraint.Transform = target
                        limbsState.wasTorsoOn = false
                        limbsState.torsoCleanup = 0
                        _G._HaloTorsoCamSmoothedCF = nil
                    end
                else
                    limbsState.wasTorsoOn = false
                    limbsState.torsoCleanup = 0
                    _G._HaloTorsoCamSmoothedCF = nil
                end
            end
        end

        -- ============================================
        -- LEG STRETCHER (Independent of Torso)
        -- ============================================
        local doLegs = _G._HaloLegStretcherEnabled
        if doLegs then
            local legScale = math.clamp(_G._HaloLimbsLegHeight or 1.0, 0.4, 100.0)
            local animData = ReanimateAPI and ReanimateAPI.get_animation_data and ReanimateAPI.get_animation_data()
            local rll = (animData and animData.constraints_cache and (animData.constraints_cache["RightLowerLeg"] or animData.constraints_cache["RightKnee"]))
                or clone:FindFirstChild("RightKnee", true)
            local lll = (animData and animData.constraints_cache and (animData.constraints_cache["LeftLowerLeg"] or animData.constraints_cache["LeftKnee"]))
                or clone:FindFirstChild("LeftKnee", true)
            local rf  = (animData and animData.constraints_cache and (animData.constraints_cache["RightFoot"] or animData.constraints_cache["RightAnkle"]))
                or clone:FindFirstChild("RightAnkle", true)
            local lf  = (animData and animData.constraints_cache and (animData.constraints_cache["LeftFoot"] or animData.constraints_cache["LeftAnkle"]))
                or clone:FindFirstChild("LeftAnkle", true)

            if legScale ~= 1.0 then
                local kneeOffset = CFrame.new(0, -(legScale - 1.0) * 1.5, 0)
                local baseRll = (animData and animData.bind_transforms and animData.bind_transforms[rll]) or CFrame.new()
                local baseLll = (animData and animData.bind_transforms and animData.bind_transforms[lll]) or CFrame.new()
                if rll and rll.Parent then rll.Transform = kneeOffset * baseRll end
                if lll and lll.Parent then lll.Transform = kneeOffset * baseLll end
            end
            applyLegHipHeight(clone, legScale, true)
            limbsState.wasLegOn = true
            limbsState.legCleanup = 0
        else
            if limbsState.wasLegOn then
                limbsState.legCleanup = (limbsState.legCleanup or 0) + 1
                local animData = ReanimateAPI and ReanimateAPI.get_animation_data and ReanimateAPI.get_animation_data()
                local rll = (animData and animData.constraints_cache and (animData.constraints_cache["RightLowerLeg"] or animData.constraints_cache["RightKnee"]))
                    or clone:FindFirstChild("RightKnee", true)
                local lll = (animData and animData.constraints_cache and (animData.constraints_cache["LeftLowerLeg"] or animData.constraints_cache["LeftKnee"]))
                    or clone:FindFirstChild("LeftKnee", true)
                local rf  = (animData and animData.constraints_cache and (animData.constraints_cache["RightFoot"] or animData.constraints_cache["RightAnkle"]))
                    or clone:FindFirstChild("RightAnkle", true)
                local lf  = (animData and animData.constraints_cache and (animData.constraints_cache["LeftFoot"] or animData.constraints_cache["LeftAnkle"]))
                    or clone:FindFirstChild("LeftAnkle", true)

                local target = CFrame.new()
                if rll and rll.Parent then rll.Transform = rll.Transform:Lerp(target, 0.15) end
                if lll and lll.Parent then lll.Transform = lll.Transform:Lerp(target, 0.15) end
                if rf and rf.Parent then rf.Transform = rf.Transform:Lerp(target, 0.15) end
                if lf and lf.Parent then lf.Transform = lf.Transform:Lerp(target, 0.15) end

                if limbsState.legCleanup > 25 then
                    if rll and rll.Parent then rll.Transform = target end
                    if lll and lll.Parent then lll.Transform = target end
                    if rf and rf.Parent then rf.Transform = target end
                    if lf and lf.Parent then lf.Transform = target end
                    applyLegHipHeight(clone, 1.0, false)
                    limbsState.wasLegOn = false
                    limbsState.legCleanup = 0
                end
            end
        end
    end))
end
-- Hook into reanimate toggle (no extra locals — stays under register limit)
_G._HaloDoReanimToggle_prev_limbs = _G._HaloDoReanimToggle
_G._HaloDoReanimToggle = function()
    local wasReanimated = State.isReanimated
    local prev = _G._HaloDoReanimToggle_prev_limbs
    if type(prev) == "function" then prev() end
    if State.isReanimated and not wasReanimated then
        startLimbsSystem()
    elseif not State.isReanimated and wasReanimated then
        if limbsConn then limbsConn:Disconnect(); limbsConn = nil end
        limbsCache = nil
        limbsOrig = nil
    end
end

-- Rebuild the clone from scratch: clear cache so next frame re-binds
-- (IIFE keeps locals out of the saturated outer scope — avoids register limit 200)
(function()
    local orig = ReanimateAPI.rebuild_clone
    ReanimateAPI.rebuild_clone = function(...)
        local r = orig(...)
        limbsCache = nil
        limbsOrig = nil
        if State.isReanimated then
            task.delay(0.3, function()
                local clone = ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
                if clone then cacheLimbsFast(clone) end
            end)
        end
        return r
    end
end)()

-- Start immediately if already reanimated
if State.isReanimated then startLimbsSystem() end
end



-- Central Reset Function: Turns off all toggles & resets all sliders to default
function _G._HaloResetTogglesAndSliders()
    -- 1. Stretching Tab
    _G._HaloTorsoStretcherEnabled = false
    _G._HaloLegStretcherEnabled = false
    _G._HaloLimbsUpperTorsoHeight = 1.0
    _G._HaloLimbsLegHeight = 1.0
    if torsoStretcherToggle and torsoStretcherToggle.setVisualState then
        torsoStretcherToggle.setVisualState(false)
    end
    if legStretcherToggle and legStretcherToggle.setVisualState then
        legStretcherToggle.setVisualState(false)
    end
    if utSlider and utSlider.setValue then
        utSlider.setValue(1.0)
    end
    if legSlider and legSlider.setValue then
        legSlider.setValue(1.0)
    end

    -- 2. Arm Stretch
    _G._HaloLeftArmStretching = false
    _G._HaloRightArmStretching = false
    _G._HaloArmStretchAmount = 2.5
    if _G._HaloResetArmStretch then
        _G._HaloResetArmStretch()
    end

    -- 3. Limbs Tab
    _G._HaloHeadTrackerEnabled = false
    if htWidget and htWidget.setVisualState then htWidget.setVisualState(false) end

    _G._HaloLeftArmPointerEnabled = false
    if laWidget and laWidget.setVisualState then laWidget.setVisualState(false) end

    _G._HaloRightArmPointerEnabled = false
    if raWidget and raWidget.setVisualState then raWidget.setVisualState(false) end

    _G._HaloLimbsTorsoCamControl = false
    _G._HaloLimbsTorsoCamMode = "360"
    if _G._HaloUpdateCamToggleState then
        _G._HaloUpdateCamToggleState(false)
    end

    -- Extra limb tools
    _G._HaloDualArmPointerEnabled = false
    _G._HaloGunAimEnabled = false
    _G._HaloWaveArmEnabled = false
    _G._HaloHeadbangEnabled = false
    _G._HaloFloppyArmsEnabled = false
    _G._HaloReachMouseEnabled = false

    -- 4. Clear limb caches & restore hip height
    limbsCache = nil
    limbsOrig = nil
    standalonePointerCache = nil
    standaloneHeadCache = nil
    local clone = (ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)) or plr.Character
    if applyLegHipHeight then applyLegHipHeight(clone, 1.0, false) end
end

task.defer(function()
    if _G._HaloResetTogglesAndSliders then
        _G._HaloResetTogglesAndSliders()
    end
end)


StatesPanel.Parent = body
StatesPanel.Size = UDim2.new(1,-20,1,-148)
StatesPanel.Position = UDim2.new(0,10,0,104)
StatesPanel.BackgroundTransparency = 1; StatesPanel.BorderSizePixel = 0
StatesPanel.ZIndex = 32

-- States header label inside the StatesPanel
local statesHeader = Instance.new("TextLabel"); statesHeader.Parent = StatesPanel
statesHeader.BackgroundTransparency = 1; statesHeader.Size = UDim2.new(1,0,0,18)
statesHeader.Font = Enum.Font.GothamBold; statesHeader.TextSize = 11
statesHeader.Text = "State Animations"; statesHeader.TextColor3 = C.text
statesHeader.TextXAlignment = Enum.TextXAlignment.Left; statesHeader.ZIndex = 35

-- UI / Window settings (Drag + Tab Grid) — no reanim gate
do
    local function buildUIToggle(parent, title, subText, layoutOrder, defaultState, onChange)
        local frame = Instance.new("Frame"); frame.Parent = parent
        frame.Size = UDim2.new(1,0,0,54)
        frame.BackgroundColor3 = C.bg1; frame.BackgroundTransparency = 0.12; frame.BorderSizePixel = 0
        frame.LayoutOrder = layoutOrder
        do
            local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,10); c.Parent = frame
            local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.4; s.Thickness = 1; s.Parent = frame
        end
        local lbl = Instance.new("TextLabel"); lbl.Parent = frame
        lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0,10,0,6)
        lbl.Size = UDim2.new(1,-70,0,16); lbl.Font = Enum.Font.GothamBold
        lbl.Text = title; lbl.TextColor3 = C.text; lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 33
        local sub = Instance.new("TextLabel"); sub.Parent = frame
        sub.BackgroundTransparency = 1; sub.Position = UDim2.new(0,10,0,24)
        sub.Size = UDim2.new(1,-70,0,24); sub.Font = Enum.Font.Gotham
        sub.Text = subText; sub.TextColor3 = C.text3; sub.TextSize = 9
        sub.TextXAlignment = Enum.TextXAlignment.Left; sub.TextWrapped = true; sub.ZIndex = 33
        local bg = Instance.new("Frame"); bg.Parent = frame
        bg.Size = UDim2.new(0,42,0,24); bg.Position = UDim2.new(1,-54,0,16)
        bg.BackgroundColor3 = defaultState and C.green or C.bg3; bg.BorderSizePixel = 0; bg.ZIndex = 33
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,11); c.Parent = bg
        local knob = Instance.new("Frame"); knob.Parent = bg
        knob.Size = UDim2.new(0,18,0,18); knob.Position = defaultState and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
        knob.BackgroundColor3 = C.white; knob.BorderSizePixel = 0; knob.ZIndex = 34
        local ck = Instance.new("UICorner"); ck.CornerRadius = UDim.new(0,8); ck.Parent = knob
        local btn = Instance.new("TextButton"); btn.Parent = bg
        btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 35
        local state = defaultState
        btn.MouseButton1Click:Connect(function()
            state = not state
            if state then
                TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = C.green}):Play()
                TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(1,-21,0.5,-9)}):Play()
            else
                TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = C.bg3}):Play()
                TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0,3,0.5,-9)}):Play()
            end
            onChange(state)
        end)
    end

    local uiHeader = Instance.new("TextLabel")
    uiHeader.Parent = SettingsPanel
    uiHeader.BackgroundTransparency = 1
    uiHeader.Size = UDim2.new(1, 0, 0, 18)
    uiHeader.LayoutOrder = -10
    uiHeader.Font = Enum.Font.GothamBold
    uiHeader.TextSize = 11
    uiHeader.Text = "Window / UI"
    uiHeader.TextColor3 = C.text
    uiHeader.TextXAlignment = Enum.TextXAlignment.Left
    uiHeader.ZIndex = 33

    buildUIToggle(
        SettingsPanel,
        "Enable Dragging",
        "Turn off if the menu keeps unsticking while you still hold click (laggy devices)",
        -9,
        (_G._HaloDragEnabled == nil) and true or _G._HaloDragEnabled,
        function(state)
            _G._HaloDragEnabled = state
            if Notify then Notify("Dragging", state and "Enabled" or "Disabled", 1.8) end
        end
    )

    buildUIToggle(
        SettingsPanel,
        "Smooth Drag",
        "Lerp the window while dragging. Disable for instant/raw movement (less lag)",
        -8,
        (_G._HaloSmoothDrag == nil) and true or _G._HaloSmoothDrag,
        function(state)
            _G._HaloSmoothDrag = state
            if Notify then Notify("Smooth Drag", state and "Enabled" or "Disabled", 1.8) end
        end
    )

    buildUIToggle(
        SettingsPanel,
        "Tab Grid Mode",
        "Show all tabs as a grid so you can jump to any tab without horizontal scrolling",
        -7,
        (_G._HaloTabGridMode == nil) and false or _G._HaloTabGridMode,
        function(state)
            _G._HaloTabGridMode = state
            if _G._HaloSetTabGridMode then pcall(_G._HaloSetTabGridMode, state) end
            if SwitchTab and State and State.currentTab then pcall(SwitchTab, State.currentTab) end
            if Notify then Notify("Tab Grid", state and "Enabled" or "Disabled", 1.8) end
        end
    )
end

-- ANIMATION MAKER — Moon Animator style (FK only, N0IR theme)
-- Hierarchy + multi-track timeline + 3D rotation handles
-- Isolated task.spawn to avoid register limit
-- ============================================
task.spawn(function()
    -- Cleanup previous
    pcall(function()
        if ScreenGui then
            local old = ScreenGui:FindFirstChild("AnimMakerOverlay")
            if old then old:Destroy() end
        end
        if workspace.CurrentCamera then
            local g = workspace.CurrentCamera:FindFirstChild("N0IR_AM_Gizmo")
            if g then g:Destroy() end
        end
        do
            local g2 = workspace:FindFirstChild("N0IR_AM_Gizmo")
            if g2 then g2:Destroy() end
        end
        if _G._HaloAnimMaker and _G._HaloAnimMaker.gui then
            pcall(function() _G._HaloAnimMaker.gui:Destroy() end)
        end
        if _G._HaloAnimMaker and _G._HaloAnimMaker.stopGizmo then
            pcall(_G._HaloAnimMaker.stopGizmo)
        end
    end)

    local AM = {
        open = false,
        keyframes = {}, -- array of {Time=number, Data={ [bone]=CFrame }}
        currentTime = 0,
        duration = 3.0,
        selectedBone = "Head",
        playing = false,
        playConn = nil,
        gizmoConn = nil,
        gizmoFolder = nil,
        constraints = {},
        bindPose = {},
        gui = nil,
        trackRows = {},
        dirty = true,
    }
    -- preserve keyframes across re-exec if any
    if _G._HaloAnimMaker and type(_G._HaloAnimMaker.keyframes) == "table" then
        AM.keyframes = _G._HaloAnimMaker.keyframes
    end
    _G._HaloAnimMaker = AM
    _G._HaloAnimMakerOpen = false

    local BONES = {
        "Head", "UpperTorso", "LowerTorso",
        "RightUpperArm", "RightLowerArm", "RightHand",
        "LeftUpperArm", "LeftLowerArm", "LeftHand",
        "RightUpperLeg", "RightLowerLeg", "RightFoot",
        "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    }

    local HIERARCHY = {
        { name = "Head", depth = 1 },
        { name = "UpperTorso", depth = 0 },
        { name = "LowerTorso", depth = 0 },
        { name = "RightUpperArm", depth = 1 },
        { name = "RightLowerArm", depth = 2 },
        { name = "RightHand", depth = 3 },
        { name = "LeftUpperArm", depth = 1 },
        { name = "LeftLowerArm", depth = 2 },
        { name = "LeftHand", depth = 3 },
        { name = "RightUpperLeg", depth = 1 },
        { name = "RightLowerLeg", depth = 2 },
        { name = "RightFoot", depth = 3 },
        { name = "LeftUpperLeg", depth = 1 },
        { name = "LeftLowerLeg", depth = 2 },
        { name = "LeftFoot", depth = 3 },
    }

    local function notify(msg, dur)
        if Notify then pcall(Notify, tostring(msg), dur or 2) end
    end

    local function getClone()
        if ReanimateAPI and ReanimateAPI.get_clone then
            return ReanimateAPI.get_clone(plr)
        end
        return nil
    end

    local function rebuildConstraints()
        AM.constraints = {}
        AM.bindPose = {}
        local clone = getClone()
        if not clone then return false end
        for _, d in ipairs(clone:GetDescendants()) do
            local name = nil
            if d:IsA("AnimationConstraint") then
                local att = d.Attachment1
                if att and att.Parent then name = att.Parent.Name end
            elseif d:IsA("Motor6D") and d.Part1 then
                name = d.Part1.Name
            end
            if name then
                for _, b in ipairs(BONES) do
                    if b == name and not AM.constraints[name] then
                        AM.constraints[name] = d
                        pcall(function() AM.bindPose[name] = d.Transform end)
                        break
                    end
                end
            end
        end
        if AM.constraints["LowerTorso"] and not AM.constraints["Torso"] then
            AM.constraints["Torso"] = AM.constraints["LowerTorso"]
            AM.bindPose["Torso"] = AM.bindPose["LowerTorso"]
        end
        return next(AM.constraints) ~= nil
    end

    local function getBoneWorldCF(boneName)
        local clone = getClone()
        if not clone then return nil end
        local part = clone:FindFirstChild(boneName, true)
        if part and part:IsA("BasePart") then
            return part.CFrame
        end
        -- fallback from constraint
        local c = AM.constraints[boneName]
        if c then
            if c:IsA("Motor6D") and c.Part1 then
                return c.Part1.CFrame
            end
            local att1 = c.Attachment1
            if att1 then return att1.WorldCFrame end
        end
        return nil
    end

    local function capturePose()
        local data = {}
        for bone, c in pairs(AM.constraints) do
            if c and c.Parent then
                pcall(function() data[bone] = c.Transform end)
            end
        end
        return data
    end

    local function applyPose(data)
        if not data then return end
        for bone, cf in pairs(data) do
            local c = AM.constraints[bone]
            if c and c.Parent and typeof(cf) == "CFrame" then
                pcall(function() c.Transform = cf end)
            end
        end
    end

    local function sortKFs()
        table.sort(AM.keyframes, function(a, b) return (a.Time or 0) < (b.Time or 0) end)
    end

    local function poseAtTime(t)
        local kfs = AM.keyframes
        if #kfs == 0 then return end
        if #kfs == 1 or t <= (kfs[1].Time or 0) then
            applyPose(kfs[1].Data)
            return
        end
        if t >= (kfs[#kfs].Time or 0) then
            applyPose(kfs[#kfs].Data)
            return
        end
        for i = 1, #kfs - 1 do
            local a, b = kfs[i], kfs[i + 1]
            if t >= a.Time and t <= b.Time then
                local span = math.max((b.Time - a.Time), 1e-4)
                local alpha = (t - a.Time) / span
                for bone, cfA in pairs(a.Data or {}) do
                    local c = AM.constraints[bone]
                    local cfB = b.Data and b.Data[bone]
                    if c and c.Parent and typeof(cfA) == "CFrame" then
                        if typeof(cfB) == "CFrame" then
                            pcall(function() c.Transform = cfA:Lerp(cfB, alpha) end)
                        else
                            pcall(function() c.Transform = cfA end)
                        end
                    end
                end
                return
            end
        end
    end

    local function insertKF()
        if not rebuildConstraints() then
            notify("Reanimate first", 2)
            return
        end
        local t = tonumber(AM.currentTime) or 0
        for i = #AM.keyframes, 1, -1 do
            if math.abs((AM.keyframes[i].Time or 0) - t) < 0.015 then
                table.remove(AM.keyframes, i)
            end
        end
        table.insert(AM.keyframes, { Time = t, Data = capturePose() })
        sortKFs()
        AM.dirty = true
        if AM.refreshTimeline then AM.refreshTimeline() end
        notify(string.format("Keyframe @ %.2fs", t), 1.2)
    end

    local function deleteKFAtTime(t)
        for i = #AM.keyframes, 1, -1 do
            if math.abs((AM.keyframes[i].Time or 0) - t) < 0.02 then
                table.remove(AM.keyframes, i)
            end
        end
        AM.dirty = true
        if AM.refreshTimeline then AM.refreshTimeline() end
    end

    -- ===================== GIZMO (3-axis rotation handles) =====================
    local function destroyGizmo()
        if AM.gizmoConn then AM.gizmoConn:Disconnect(); AM.gizmoConn = nil end
        if AM.holdConn then AM.holdConn:Disconnect(); AM.holdConn = nil end
        if AM._gizmoDown then AM._gizmoDown:Disconnect(); AM._gizmoDown = nil end
        if AM._gizmoMove then AM._gizmoMove:Disconnect(); AM._gizmoMove = nil end
        if AM._gizmoUp then AM._gizmoUp:Disconnect(); AM._gizmoUp = nil end
        if AM.gizmoFolder then
            pcall(function() AM.gizmoFolder:Destroy() end)
            AM.gizmoFolder = nil
        end
        AM._gizmoDragging = nil
    end
    AM.stopGizmo = destroyGizmo

    local function makeHandle(parent, color, axis, size, cfOffset)
        local p = Instance.new("Part")
        p.Name = "Handle_" .. axis
        p.Anchored = true
        p.CanCollide = false
        p.CanQuery = true
        p.CanTouch = false
        p.Massless = true
        p.CastShadow = false
        p.Material = Enum.Material.Neon
        p.Color = color
        p.Transparency = 0.15
        p.Size = size
        p.Parent = parent
        p:SetAttribute("AMAxis", axis)
        -- keep local offset recipe for updates
        p:SetAttribute("AMOff", cfOffset)
        return p
    end

    local function updateGizmoTransform()
        if not AM.gizmoFolder then return end
        local cf = getBoneWorldCF(AM.selectedBone)
        if not cf then return end
        -- scale handles with camera distance so they stay clickable
        local cam = workspace.CurrentCamera
        local dist = 8
        if cam then
            dist = math.clamp((cf.Position - cam.CFrame.Position).Magnitude, 4, 40)
        end
        local s = dist * 0.06
        local ringThick = math.clamp(s * 0.35, 0.15, 0.45)
        local ringLen = math.clamp(s * 4.2, 1.8, 5.5)
        local arrowLen = math.clamp(s * 2.2, 1.2, 3.5)
        local arrowThick = math.clamp(s * 0.28, 0.12, 0.35)

        for _, p in ipairs(AM.gizmoFolder:GetChildren()) do
            if p:IsA("BasePart") then
                local axis = p:GetAttribute("AMAxis")
                if axis == "X" and p.Name == "Handle_X" then
                    p.Size = Vector3.new(ringThick, ringLen, ringLen)
                    p.CFrame = cf * CFrame.Angles(0, 0, math.rad(90))
                elseif axis == "Y" and p.Name == "Handle_Y" then
                    p.Size = Vector3.new(ringThick, ringLen, ringLen)
                    p.CFrame = cf
                elseif axis == "Z" and p.Name == "Handle_Z" then
                    p.Size = Vector3.new(ringThick, ringLen, ringLen)
                    p.CFrame = cf * CFrame.Angles(0, math.rad(90), 0)
                elseif axis == "X" and p.Name == "Arrow_X" then
                    p.Size = Vector3.new(arrowLen, arrowThick, arrowThick)
                    p.CFrame = cf * CFrame.new(arrowLen * 0.55, 0, 0)
                elseif axis == "Y" and p.Name == "Arrow_Y" then
                    p.Size = Vector3.new(arrowThick, arrowLen, arrowThick)
                    p.CFrame = cf * CFrame.new(0, arrowLen * 0.55, 0)
                elseif axis == "Z" and p.Name == "Arrow_Z" then
                    p.Size = Vector3.new(arrowThick, arrowThick, arrowLen)
                    p.CFrame = cf * CFrame.new(0, 0, arrowLen * 0.55)
                elseif p.Name == "Center" then
                    local cs = math.clamp(s * 0.5, 0.2, 0.45)
                    p.Size = Vector3.new(cs, cs, cs)
                    p.CFrame = cf
                end
            end
        end
    end

    local function pushLivePose()
        AM._livePose = capturePose()
    end

    local function rotateBoneByAxis(axis, degrees)
        local c = AM.constraints[AM.selectedBone]
        if not c or not c.Parent then return end
        local rad = math.rad(degrees)
        local rot
        if axis == "X" then
            rot = CFrame.Angles(rad, 0, 0)
        elseif axis == "Y" then
            rot = CFrame.Angles(0, rad, 0)
        else
            rot = CFrame.Angles(0, 0, rad)
        end
        pcall(function()
            c.Transform = c.Transform * rot
        end)
        pushLivePose()
        updateGizmoTransform()
    end

    local function setupGizmoInput()
        -- disconnect old
        if AM._gizmoDown then AM._gizmoDown:Disconnect(); AM._gizmoDown = nil end
        if AM._gizmoMove then AM._gizmoMove:Disconnect(); AM._gizmoMove = nil end
        if AM._gizmoUp then AM._gizmoUp:Disconnect(); AM._gizmoUp = nil end

        local mouse = plr:GetMouse()
        local dragging = nil -- {axis=string, last=Vector3}

        local function pickAxisFromTarget(target)
            if not target then return nil end
            if not AM.gizmoFolder then return nil end
            if not target:IsDescendantOf(AM.gizmoFolder) then return nil end
            return target:GetAttribute("AMAxis")
        end

        local function beginDrag(axis, pos)
            if not axis then return end
            dragging = { axis = axis, last = pos }
            AM._gizmoDragging = dragging
            -- highlight
            if AM.gizmoFolder then
                for _, p in ipairs(AM.gizmoFolder:GetChildren()) do
                    if p:IsA("BasePart") and p:GetAttribute("AMAxis") then
                        p.Transparency = (p:GetAttribute("AMAxis") == axis) and 0.05 or 0.55
                    end
                end
            end
        end

        local function endDrag()
            dragging = nil
            AM._gizmoDragging = nil
            if AM.gizmoFolder then
                for _, p in ipairs(AM.gizmoFolder:GetChildren()) do
                    if p:IsA("BasePart") and p:GetAttribute("AMAxis") then
                        p.Transparency = 0.15
                    end
                end
            end
        end

        -- Prefer mouse.Button1Down + Target (most reliable in exploit envs)
        AM._gizmoDown = mouse.Button1Down:Connect(function()
            if not AM.open or not AM.gizmoFolder then return end
            local axis = pickAxisFromTarget(mouse.Target)
            if axis then
                beginDrag(axis, Vector2.new(mouse.X, mouse.Y))
            end
        end)

        AM._gizmoUp = mouse.Button1Up:Connect(function()
            endDrag()
        end)

        -- Also bind UIS for touch / when mouse target fails but ray hits
        AM._gizmoUISDown = UserInputService.InputBegan:Connect(function(input, gp)
            if not AM.open or not AM.gizmoFolder then return end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local cam = workspace.CurrentCamera
            if not cam then return end
            local ray = cam:ViewportPointToRay(input.Position.X, input.Position.Y)
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Include
            local list = {}
            for _, ch in ipairs(AM.gizmoFolder:GetChildren()) do
                if ch:IsA("BasePart") then table.insert(list, ch) end
            end
            params.FilterDescendantsInstances = list
            local hit = workspace:Raycast(ray.Origin, ray.Direction * 500, params)
            if hit and hit.Instance then
                local axis = hit.Instance:GetAttribute("AMAxis")
                if axis then
                    beginDrag(axis, input.Position)
                end
            end
        end)

        AM._gizmoMove = UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local pos = input.Position
            local delta = pos - dragging.last
            dragging.last = pos
            local amount = delta.X * 0.45 + delta.Y * 0.2
            rotateBoneByAxis(dragging.axis, amount)
        end)

        AM._gizmoUpUIS = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                endDrag()
            end
        end)
    end

    local function buildGizmo()
        destroyGizmo()
        if AM._gizmoUISDown then AM._gizmoUISDown:Disconnect(); AM._gizmoUISDown = nil end
        if AM._gizmoUpUIS then AM._gizmoUpUIS:Disconnect(); AM._gizmoUpUIS = nil end

        local folder = Instance.new("Folder")
        folder.Name = "N0IR_AM_Gizmo"
        -- Parent to workspace so Mouse.Target + raycasts work reliably
        folder.Parent = workspace
        AM.gizmoFolder = folder

        -- Rings (cylinders)
        local hx = makeHandle(folder, Color3.fromRGB(220, 70, 70), "X", Vector3.new(0.2, 3, 3), "ring")
        hx.Shape = Enum.PartType.Cylinder
        local hy = makeHandle(folder, Color3.fromRGB(70, 220, 100), "Y", Vector3.new(0.2, 3, 3), "ring")
        hy.Shape = Enum.PartType.Cylinder
        local hz = makeHandle(folder, Color3.fromRGB(70, 140, 240), "Z", Vector3.new(0.2, 3, 3), "ring")
        hz.Shape = Enum.PartType.Cylinder

        -- Axis arrows (easier click targets)
        local ax = makeHandle(folder, Color3.fromRGB(220, 70, 70), "X", Vector3.new(2.2, 0.22, 0.22), "arrow")
        ax.Name = "Arrow_X"
        local ay = makeHandle(folder, Color3.fromRGB(70, 220, 100), "Y", Vector3.new(0.22, 2.2, 0.22), "arrow")
        ay.Name = "Arrow_Y"
        local az = makeHandle(folder, Color3.fromRGB(70, 140, 240), "Z", Vector3.new(0.22, 0.22, 2.2), "arrow")
        az.Name = "Arrow_Z"

        local center = Instance.new("Part")
        center.Name = "Center"
        center.Anchored = true
        center.CanCollide = false
        center.CanQuery = false
        center.CastShadow = false
        center.Size = Vector3.new(0.3, 0.3, 0.3)
        center.Shape = Enum.PartType.Ball
        center.Material = Enum.Material.Neon
        center.Color = Color3.fromRGB(255, 255, 255)
        center.Transparency = 0.15
        center.Parent = folder

        updateGizmoTransform()
        setupGizmoInput()

        if AM.gizmoConn then AM.gizmoConn:Disconnect() end
        AM.gizmoConn = RunService.RenderStepped:Connect(function()
            if not AM.open then return end
            updateGizmoTransform()
        end)

        -- Hold pose every frame so animations / trackers cannot overwrite while editing
        if AM.holdConn then AM.holdConn:Disconnect() end
        pushLivePose()
        AM.holdConn = RunService.PreSimulation:Connect(function()
            if not AM.open then return end
            -- keep anims killed
            pcall(function()
                if ReanimateAPI and ReanimateAPI.is_animation_playing and ReanimateAPI.is_animation_playing() then
                    if ReanimateAPI.stop_animation then ReanimateAPI.stop_animation() end
                end
            end)
            if AM._livePose and not AM.playing then
                applyPose(AM._livePose)
            end
        end)
    end

    -- ===================== PLAYBACK =====================
    local function stopPlay()
        AM.playing = false
        if AM.playConn then AM.playConn:Disconnect(); AM.playConn = nil end
        if AM.playBtn then AM.playBtn.Text = "▶" end
    end

    local function startPlay()
        if #AM.keyframes < 1 then notify("No keyframes", 1.5); return end
        if not rebuildConstraints() then notify("Reanimate first", 2); return end
        stopPlay()
        AM.playing = true
        if AM.playBtn then AM.playBtn.Text = "■" end
        local t0 = tick()
        local startT = AM.currentTime or 0
        local dur = math.max(AM.duration or 3, 0.05)
        if AM.keyframes[#AM.keyframes] then
            dur = math.max(dur, AM.keyframes[#AM.keyframes].Time or dur)
            AM.duration = dur
        end
        AM.playConn = RunService.Heartbeat:Connect(function()
            if not AM.playing then return end
            local t = startT + (tick() - t0)
            if t >= dur then
                t = dur
                AM.currentTime = t
                poseAtTime(t)
                if AM.setPlayhead then AM.setPlayhead(t) end
                stopPlay()
                return
            end
            AM.currentTime = t
            poseAtTime(t)
            if AM.setPlayhead then AM.setPlayhead(t) end
        end)
    end

    -- ===================== EXPORT =====================
    local function exportToCustoms(animName)
        animName = tostring(animName or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if animName == "" then notify("Name required", 2); return end
        if #AM.keyframes < 1 then notify("No keyframes", 2); return end
        sortKFs()
        local parts = {}
        table.insert(parts, "-- N0IR Animation Maker (Moon-style)\n")
        table.insert(parts, "-- " .. tostring(#AM.keyframes) .. " keyframes\n")
        table.insert(parts, "return {\n  [\"Animation\"] = {\n")
        for i, kf in ipairs(AM.keyframes) do
            local line = "    {Time = " .. string.format("%.4f", kf.Time or 0) .. ", Data = {\n"
            for bone, cf in pairs(kf.Data or {}) do
                if typeof(cf) == "CFrame" then
                    local comps = { cf:GetComponents() }
                    local nums = {}
                    for j = 1, 12 do nums[j] = string.format("%.6f", comps[j]) end
                    line = line .. '      ["' .. bone .. '"] = CFrame.new(' .. table.concat(nums, ", ") .. '),\n'
                end
            end
            line = line .. "    }},\n"
            table.insert(parts, line)
            if i % 15 == 0 then task.wait() end
        end
        table.insert(parts, "  }\n}\n")
        local output = table.concat(parts)

        local folder = (CONFIG and CONFIG.FOLDER) or "ReanimData"
        pcall(function() if makefolder then makefolder(folder) end end)
        local safe = animName:gsub("[^%w_%-]", "_")
        local filePath = folder .. "/Maker_" .. safe .. ".lua"
        local ok = pcall(function() if writefile then writefile(filePath, output) end end)
        if not ok then notify("writefile failed", 2); return end

        local list = CustomAnims or _G._ReanimCustomAnims
        if type(list) ~= "table" then
            list = {}
            CustomAnims = list
            _G._ReanimCustomAnims = list
        end
        local found = false
        for _, ca in ipairs(list) do
            if ca.name == animName then
                ca.url = filePath; ca.raw = true; ca.isJson = false
                found = true; break
            end
        end
        if not found then
            table.insert(list, { name = animName, url = filePath, raw = true, isJson = false })
        end
        CustomAnimations = CustomAnimations or {}
        CustomAnimations[animName] = filePath
        pcall(function()
            if SaveCustomAnims then SaveCustomAnims() end
            if _G._ReanimSaveCustomAnims then _G._ReanimSaveCustomAnims() end
        end)
        pcall(function()
            if RebuildCustomList then RebuildCustomList() end
            if _G._ReanimRebuildCustomList then _G._ReanimRebuildCustomList() end
        end)
        pcall(function() if setclipboard then setclipboard(output) end end)
        notify("Exported \"" .. animName .. "\" → Customs", 3)
    end

    -- ===================== UI =====================
    local function closeMaker()
        stopPlay()
        destroyGizmo()
        if AM._gizmoDown then AM._gizmoDown:Disconnect(); AM._gizmoDown = nil end
        if AM._gizmoMove then AM._gizmoMove:Disconnect(); AM._gizmoMove = nil end
        if AM._gizmoUp then AM._gizmoUp:Disconnect(); AM._gizmoUp = nil end
        if AM._gizmoUISDown then AM._gizmoUISDown:Disconnect(); AM._gizmoUISDown = nil end
        if AM._gizmoUpUIS then AM._gizmoUpUIS:Disconnect(); AM._gizmoUpUIS = nil end
        AM.open = false
        _G._HaloAnimMakerOpen = false
        AM._livePose = nil
        if AM.gui then AM.gui.Visible = false end
    end

    local function openMaker()
        local reanimOk = (State and State.isReanimated)
            or (ReanimateAPI and ReanimateAPI.is_reanimated and ReanimateAPI.is_reanimated())
        if not reanimOk then
            notify("Turn on Reanimation first", 2.5)
            return
        end
        if not rebuildConstraints() then
            notify("Clone bones not found — reanimate again", 3)
            return
        end

        -- Kill playing animations so FK posing sticks
        pcall(function()
            if ReanimateAPI and ReanimateAPI.stop_animation then
                ReanimateAPI.stop_animation()
            end
        end)
        _G._HaloSpinHeadEnabled = false
        _G._HaloStareEnabled = false
        _G._HaloIdleWobbleEnabled = false
        _G._HaloHeadTrackerEnabled = false
        _G._HaloLeftArmPointerEnabled = false
        _G._HaloRightArmPointerEnabled = false
        _G._HaloGunAimEnabled = false
        _G._HaloWaveArmEnabled = false
        _G._HaloHeadbangEnabled = false
        _G._HaloFloppyArmsEnabled = false
        _G._HaloHeliArmsEnabled = false
        _G._HaloHandsUpEnabled = false
        _G._HaloCrossArmsEnabled = false
        _G._HaloTPoseEnabled = false
        pcall(function()
            local clone = getClone()
            if clone then
                local anim = clone:FindFirstChild("Animate")
                if anim then anim.Disabled = true end
                local hum = clone:FindFirstChildOfClass("Humanoid")
                if hum then
                    for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
                        pcall(function() t:Stop(0) end)
                    end
                end
            end
        end)

        AM.open = true
        _G._HaloAnimMakerOpen = true

        if AM.gui then
            AM.gui.Visible = true
            buildGizmo()
            if AM.refreshTimeline then AM.refreshTimeline() end
            return
        end

        -- ===== Build Moon-style UI =====
        local gui = Instance.new("Frame")
        gui.Name = "AnimMakerOverlay"
        gui.Parent = ScreenGui
        gui.AnchorPoint = Vector2.new(0.5, 0.5)
        gui.Position = UDim2.new(0.5, 0, 0.55, 0)
        gui.Size = UDim2.new(0, 720, 0, 380)
        gui.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        gui.BackgroundTransparency = 0.04
        gui.BorderSizePixel = 0
        gui.ZIndex = 200
        gui.ClipsDescendants = true
        gui.Active = true
        do
            local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = gui
            local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(40, 40, 40); s.Thickness = 1; s.Parent = gui
        end
        AM.gui = gui

        -- TOP BAR
        local top = Instance.new("Frame")
        top.Parent = gui
        top.Size = UDim2.new(1, 0, 0, 36)
        top.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        top.BorderSizePixel = 0
        top.ZIndex = 201
        top.Active = true
        do
            local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = top
            local cover = Instance.new("Frame"); cover.Parent = top
            cover.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
            cover.BorderSizePixel = 0
            cover.Position = UDim2.new(0, 0, 1, -8)
            cover.Size = UDim2.new(1, 0, 0, 8)
            cover.ZIndex = 201
        end

        local title = Instance.new("TextLabel")
        title.Parent = top
        title.BackgroundTransparency = 1
        title.Position = UDim2.new(0, 12, 0, 0)
        title.Size = UDim2.new(0, 160, 1, 0)
        title.Font = Enum.Font.GothamBlack
        title.Text = "NØIR  ·  Animator"
        title.TextColor3 = Color3.fromRGB(240, 240, 240)
        title.TextSize = 13
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 202

        -- Drag from top bar
        do
            local dragging, dragStart, startPos
            top.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    -- don't start drag if clicking a button
                    dragging = true
                    dragStart = input.Position
                    startPos = gui.Position
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if not dragging then return end
                if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                    local d = input.Position - dragStart
                    gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
        end

        local function topBtn(text, x, w, cb)
            local b = Instance.new("TextButton")
            b.Parent = top
            b.Position = UDim2.new(0, x, 0.5, -12)
            b.Size = UDim2.new(0, w, 0, 24)
            b.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            b.BorderSizePixel = 0
            b.Font = Enum.Font.GothamBold
            b.Text = text
            b.TextColor3 = Color3.fromRGB(230, 230, 230)
            b.TextSize = 12
            b.ZIndex = 203
            b.AutoButtonColor = false
            do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = b end
            b.MouseButton1Click:Connect(cb)
            b.MouseEnter:Connect(function()
                TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            end)
            b.MouseLeave:Connect(function()
                TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(28, 28, 28)}):Play()
            end)
            return b
        end

        AM.playBtn = topBtn("▶", 180, 32, function()
            if AM.playing then stopPlay() else startPlay() end
        end)
        topBtn("Keyframe", 218, 70, function() insertKF() end)
        topBtn("Del KF", 294, 54, function()
            deleteKFAtTime(AM.currentTime or 0)
            notify("Deleted keyframes near playhead", 1.2)
        end)

        local nameBox = Instance.new("TextBox")
        nameBox.Parent = top
        nameBox.Position = UDim2.new(0, 360, 0.5, -12)
        nameBox.Size = UDim2.new(0, 140, 0, 24)
        nameBox.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        nameBox.BorderSizePixel = 0
        nameBox.Font = Enum.Font.GothamMedium
        nameBox.PlaceholderText = "Name..."
        nameBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
        nameBox.Text = ""
        nameBox.TextColor3 = Color3.fromRGB(240, 240, 240)
        nameBox.TextSize = 12
        nameBox.ZIndex = 203
        do
            local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = nameBox
            local p = Instance.new("UIPadding"); p.Parent = nameBox; p.PaddingLeft = UDim.new(0, 8)
        end

        local exp = topBtn("Export", 508, 64, function()
            exportToCustoms(nameBox.Text)
        end)
        exp.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
        exp.TextColor3 = Color3.fromRGB(10, 10, 10)
        exp.MouseEnter:Connect(function()
            TweenService:Create(exp, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(220, 220, 220)}):Play()
        end)
        exp.MouseLeave:Connect(function()
            TweenService:Create(exp, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(240, 240, 240)}):Play()
        end)

        local closeB = Instance.new("TextButton")
        closeB.Parent = top
        closeB.AnchorPoint = Vector2.new(1, 0.5)
        closeB.Position = UDim2.new(1, -10, 0.5, 0)
        closeB.Size = UDim2.new(0, 22, 0, 22)
        closeB.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        closeB.BorderSizePixel = 0
        closeB.Text = ""
        closeB.ZIndex = 203
        closeB.AutoButtonColor = false
        do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = closeB end
        closeB.MouseButton1Click:Connect(closeMaker)

        -- LEFT: bone hierarchy
        local left = Instance.new("Frame")
        left.Parent = gui
        left.Position = UDim2.new(0, 0, 0, 36)
        left.Size = UDim2.new(0, 168, 1, -36)
        left.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        left.BorderSizePixel = 0
        left.ZIndex = 201

        local leftTitle = Instance.new("TextLabel")
        leftTitle.Parent = left
        leftTitle.BackgroundTransparency = 1
        leftTitle.Position = UDim2.new(0, 10, 0, 6)
        leftTitle.Size = UDim2.new(1, -12, 0, 16)
        leftTitle.Font = Enum.Font.GothamBold
        leftTitle.Text = "Rig"
        leftTitle.TextColor3 = Color3.fromRGB(160, 160, 160)
        leftTitle.TextSize = 11
        leftTitle.TextXAlignment = Enum.TextXAlignment.Left
        leftTitle.ZIndex = 202

        local boneScroll = Instance.new("ScrollingFrame")
        boneScroll.Parent = left
        boneScroll.Position = UDim2.new(0, 0, 0, 24)
        boneScroll.Size = UDim2.new(1, 0, 1, -24)
        boneScroll.BackgroundTransparency = 1
        boneScroll.BorderSizePixel = 0
        boneScroll.ScrollBarThickness = 3
        boneScroll.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
        boneScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        boneScroll.ZIndex = 202
        local boneLayout = Instance.new("UIListLayout")
        boneLayout.Parent = boneScroll
        boneLayout.SortOrder = Enum.SortOrder.LayoutOrder
        boneLayout.Padding = UDim.new(0, 1)
        boneLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            boneScroll.CanvasSize = UDim2.new(0, 0, 0, boneLayout.AbsoluteContentSize.Y + 8)
        end)

        local boneBtns = {}
        local function selectBone(name)
            AM.selectedBone = name
            for n, b in pairs(boneBtns) do
                b.BackgroundColor3 = (n == name) and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(14, 14, 14)
                b.TextColor3 = (n == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 170)
            end
            updateGizmoTransform()
            if AM.selLbl then AM.selLbl.Text = "Selected: " .. name end
        end

        for i, entry in ipairs(HIERARCHY) do
            local b = Instance.new("TextButton")
            b.Parent = boneScroll
            b.Size = UDim2.new(1, -6, 0, 22)
            b.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
            b.BorderSizePixel = 0
            b.Font = Enum.Font.GothamMedium
            b.Text = string.rep("  ", entry.depth) .. entry.name
            b.TextColor3 = Color3.fromRGB(170, 170, 170)
            b.TextSize = 11
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.ZIndex = 203
            b.AutoButtonColor = false
            b.LayoutOrder = i
            do
                local p = Instance.new("UIPadding"); p.Parent = b; p.PaddingLeft = UDim.new(0, 8)
            end
            b.MouseButton1Click:Connect(function()
                selectBone(entry.name)
            end)
            boneBtns[entry.name] = b
        end

        -- RIGHT/BOTTOM timeline area
        local timeline = Instance.new("Frame")
        timeline.Parent = gui
        timeline.Position = UDim2.new(0, 168, 0, 36)
        timeline.Size = UDim2.new(1, -168, 1, -36)
        timeline.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
        timeline.BorderSizePixel = 0
        timeline.ZIndex = 201
        timeline.ClipsDescendants = true

        local toolRow = Instance.new("Frame")
        toolRow.Parent = timeline
        toolRow.Size = UDim2.new(1, 0, 0, 28)
        toolRow.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        toolRow.BorderSizePixel = 0
        toolRow.ZIndex = 202

        AM.selLbl = Instance.new("TextLabel")
        AM.selLbl.Parent = toolRow
        AM.selLbl.BackgroundTransparency = 1
        AM.selLbl.Position = UDim2.new(0, 10, 0, 0)
        AM.selLbl.Size = UDim2.new(0.4, 0, 1, 0)
        AM.selLbl.Font = Enum.Font.GothamMedium
        AM.selLbl.Text = "Selected: Head"
        AM.selLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
        AM.selLbl.TextSize = 11
        AM.selLbl.TextXAlignment = Enum.TextXAlignment.Left
        AM.selLbl.ZIndex = 203

        local timeReadout = Instance.new("TextLabel")
        timeReadout.Parent = toolRow
        timeReadout.BackgroundTransparency = 1
        timeReadout.Position = UDim2.new(0.45, 0, 0, 0)
        timeReadout.Size = UDim2.new(0.2, 0, 1, 0)
        timeReadout.Font = Enum.Font.GothamBold
        timeReadout.Text = "0.00s"
        timeReadout.TextColor3 = Color3.fromRGB(240, 240, 240)
        timeReadout.TextSize = 12
        timeReadout.ZIndex = 203

        local tip = Instance.new("TextLabel")
        tip.Parent = toolRow
        tip.BackgroundTransparency = 1
        tip.Position = UDim2.new(0.65, 0, 0, 0)
        tip.Size = UDim2.new(0.35, -8, 1, 0)
        tip.Font = Enum.Font.Gotham
        tip.Text = "Drag RGB rings on character to rotate"
        tip.TextColor3 = Color3.fromRGB(110, 110, 110)
        tip.TextSize = 10
        tip.TextXAlignment = Enum.TextXAlignment.Right
        tip.ZIndex = 203

        -- Ruler
        local ruler = Instance.new("Frame")
        ruler.Parent = timeline
        ruler.Position = UDim2.new(0, 0, 0, 28)
        ruler.Size = UDim2.new(1, 0, 0, 22)
        ruler.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        ruler.BorderSizePixel = 0
        ruler.ZIndex = 202
        ruler.ClipsDescendants = true

        local playhead = Instance.new("Frame")
        playhead.Parent = timeline
        playhead.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        playhead.BorderSizePixel = 0
        playhead.Size = UDim2.new(0, 2, 1, -28)
        playhead.Position = UDim2.new(0, 0, 0, 28)
        playhead.ZIndex = 210

        local tracks = Instance.new("ScrollingFrame")
        tracks.Parent = timeline
        tracks.Position = UDim2.new(0, 0, 0, 50)
        tracks.Size = UDim2.new(1, 0, 1, -50)
        tracks.BackgroundTransparency = 1
        tracks.BorderSizePixel = 0
        tracks.ScrollBarThickness = 4
        tracks.ScrollBarImageColor3 = Color3.fromRGB(180, 180, 180)
        tracks.CanvasSize = UDim2.new(0, 0, 0, 0)
        tracks.ZIndex = 202
        local tracksLayout = Instance.new("UIListLayout")
        tracksLayout.Parent = tracks
        tracksLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tracksLayout.Padding = UDim.new(0, 0)
        tracksLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tracks.CanvasSize = UDim2.new(0, 0, 0, tracksLayout.AbsoluteContentSize.Y + 4)
        end)

        local function timeToX(t, width)
            local dur = math.max(AM.duration or 3, 0.05)
            return math.clamp(t / dur, 0, 1) * math.max(width, 1)
        end

        function AM.setPlayhead(t)
            AM.currentTime = t
            timeReadout.Text = string.format("%.2fs", t)
            local w = timeline.AbsoluteSize.X
            local x = timeToX(t, w)
            playhead.Position = UDim2.new(0, x, 0, 28)
        end

        -- Click ruler / tracks to move playhead
        local function scrubFromX(x, absX)
            local w = timeline.AbsoluteSize.X
            local pct = math.clamp((absX - timeline.AbsolutePosition.X) / math.max(w, 1), 0, 1)
            local t = pct * math.max(AM.duration or 3, 0.05)
            AM.setPlayhead(t)
            if #AM.keyframes > 0 then poseAtTime(t) end
        end

        local scrubbing = false
        ruler.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                scrubbing = true
                scrubFromX(nil, input.Position.X)
            end
        end)
        tracks.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                scrubbing = true
                scrubFromX(nil, input.Position.X)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if scrubbing and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                scrubFromX(nil, input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                scrubbing = false
            end
        end)

        -- Draw second ticks on ruler
        local function rebuildRuler()
            for _, ch in ipairs(ruler:GetChildren()) do
                if ch:IsA("Frame") or ch:IsA("TextLabel") then ch:Destroy() end
            end
            local dur = math.max(AM.duration or 3, 0.05)
            local w = math.max(ruler.AbsoluteSize.X, 100)
            local step = 0.5
            if dur > 6 then step = 1 end
            if dur > 12 then step = 2 end
            local t = 0
            while t <= dur + 0.001 do
                local x = (t / dur) * w
                local tick = Instance.new("Frame")
                tick.Parent = ruler
                tick.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                tick.BorderSizePixel = 0
                tick.Size = UDim2.new(0, 1, 0, 8)
                tick.Position = UDim2.new(0, x, 1, -8)
                tick.ZIndex = 203
                local lbl = Instance.new("TextLabel")
                lbl.Parent = ruler
                lbl.BackgroundTransparency = 1
                lbl.Position = UDim2.new(0, x + 2, 0, 2)
                lbl.Size = UDim2.new(0, 30, 0, 12)
                lbl.Font = Enum.Font.Gotham
                lbl.Text = string.format("%.1f", t)
                lbl.TextColor3 = Color3.fromRGB(120, 120, 120)
                lbl.TextSize = 9
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.ZIndex = 203
                t = t + step
            end
        end

        function AM.refreshTimeline()
            for _, ch in ipairs(tracks:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            -- one track row per bone that has any keyframe data, else all major bones
            local used = {}
            for _, kf in ipairs(AM.keyframes) do
                for bone, _ in pairs(kf.Data or {}) do
                    used[bone] = true
                end
            end
            local order = {}
            for _, b in ipairs(BONES) do
                if used[b] or #AM.keyframes == 0 then
                    table.insert(order, b)
                end
            end
            if #order == 0 then order = BONES end

            local w = math.max(timeline.AbsoluteSize.X, 200)
            local dur = math.max(AM.duration or 3, 0.05)

            for i, bone in ipairs(order) do
                local row = Instance.new("Frame")
                row.Parent = tracks
                row.Size = UDim2.new(1, 0, 0, 22)
                row.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(15, 15, 15)
                row.BorderSizePixel = 0
                row.LayoutOrder = i
                row.ZIndex = 203

                local name = Instance.new("TextLabel")
                name.Parent = row
                name.BackgroundTransparency = 1
                name.Position = UDim2.new(0, 6, 0, 0)
                name.Size = UDim2.new(0, 100, 1, 0)
                name.Font = Enum.Font.Gotham
                name.Text = bone
                name.TextColor3 = Color3.fromRGB(140, 140, 140)
                name.TextSize = 10
                name.TextXAlignment = Enum.TextXAlignment.Left
                name.ZIndex = 204

                -- keyframe diamonds for this bone
                for _, kf in ipairs(AM.keyframes) do
                    if kf.Data and kf.Data[bone] then
                        local x = ((kf.Time or 0) / dur) * w
                        local diamond = Instance.new("TextButton")
                        diamond.Parent = row
                        diamond.Position = UDim2.new(0, x - 5, 0.5, -5)
                        diamond.Size = UDim2.new(0, 10, 0, 10)
                        diamond.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
                        diamond.BorderSizePixel = 0
                        diamond.Text = ""
                        diamond.ZIndex = 205
                        diamond.AutoButtonColor = false
                        diamond.Rotation = 45
                        do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 2); c.Parent = diamond end
                        local kfTime = kf.Time or 0
                        diamond.MouseButton1Click:Connect(function()
                            AM.setPlayhead(kfTime)
                            poseAtTime(kfTime)
                        end)
                    end
                end
            end
            rebuildRuler()
            AM.setPlayhead(AM.currentTime or 0)
        end

        -- Duration box
        local durBox = Instance.new("TextBox")
        durBox.Parent = toolRow
        durBox.Position = UDim2.new(0.35, 0, 0.5, -10)
        durBox.Size = UDim2.new(0, 48, 0, 20)
        durBox.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        durBox.BorderSizePixel = 0
        durBox.Font = Enum.Font.GothamMedium
        durBox.Text = "3.0"
        durBox.TextColor3 = Color3.fromRGB(220, 220, 220)
        durBox.TextSize = 11
        durBox.ZIndex = 203
        do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = durBox end
        durBox.FocusLost:Connect(function()
            local v = tonumber(durBox.Text)
            if v and v > 0.05 then
                AM.duration = v
                AM.refreshTimeline()
            end
        end)

        selectBone(AM.selectedBone or "Head")
        AM.refreshTimeline()
        buildGizmo()

        -- keep playhead correct on resize
        timeline:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            if AM.refreshTimeline then AM.refreshTimeline() end
        end)
    end

    -- Settings entry
    if SettingsPanel then
        local amHeader = Instance.new("TextLabel")
        amHeader.Parent = SettingsPanel
        amHeader.BackgroundTransparency = 1
        amHeader.Size = UDim2.new(1, 0, 0, 18)
        amHeader.LayoutOrder = 40
        amHeader.Font = Enum.Font.GothamBold
        amHeader.TextSize = 11
        amHeader.Text = "Animation Maker"
        amHeader.TextColor3 = C.text
        amHeader.TextXAlignment = Enum.TextXAlignment.Left
        amHeader.ZIndex = 33

        local amCard = Instance.new("Frame")
        amCard.Parent = SettingsPanel
        amCard.Size = UDim2.new(1, 0, 0, 78)
        amCard.BackgroundColor3 = C.bg1
        amCard.BackgroundTransparency = 0.12
        amCard.BorderSizePixel = 0
        amCard.LayoutOrder = 41
        amCard.ZIndex = 33
        do
            local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 8); c.Parent = amCard
            local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.65; s.Thickness = 1; s.Parent = amCard
        end

        local amSub = Instance.new("TextLabel")
        amSub.Parent = amCard
        amSub.BackgroundTransparency = 1
        amSub.Position = UDim2.new(0, 12, 0, 8)
        amSub.Size = UDim2.new(1, -24, 0, 32)
        amSub.Font = Enum.Font.Gotham
        amSub.Text = "Moon-style animator: bone hierarchy, timeline tracks, RGB rotation handles on the rig. Export → Customs."
        amSub.TextColor3 = C.text3
        amSub.TextSize = 10
        amSub.TextWrapped = true
        amSub.TextXAlignment = Enum.TextXAlignment.Left
        amSub.ZIndex = 34

        local openBtn = Instance.new("TextButton")
        openBtn.Parent = amCard
        openBtn.Position = UDim2.new(0, 12, 0, 44)
        openBtn.Size = UDim2.new(1, -24, 0, 26)
        openBtn.BackgroundColor3 = C.accent
        openBtn.BorderSizePixel = 0
        openBtn.Font = Enum.Font.GothamBold
        openBtn.Text = "Open Animator"
        openBtn.TextColor3 = Color3.fromRGB(10, 10, 10)
        openBtn.TextSize = 12
        openBtn.ZIndex = 34
        openBtn.AutoButtonColor = false
        do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = openBtn end
        openBtn.MouseButton1Click:Connect(openMaker)
    end

    _G._HaloOpenAnimMaker = openMaker
    _G._HaloCloseAnimMaker = closeMaker
end)

-- HITS TOOLKIT: Profiles, Poses, Packs, Hop, Anti-void, Preview
-- ============================================
do
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PROFILE_FILE = (CONFIG and CONFIG.FOLDER and (CONFIG.FOLDER .. "/HitsProfiles.json")) or "HitsProfiles.json"
    local PACK_FILE = (CONFIG and CONFIG.FOLDER and (CONFIG.FOLDER .. "/HitsAnimPack.json")) or "HitsAnimPack.json"
    local POSE_FILE = (CONFIG and CONFIG.FOLDER and (CONFIG.FOLDER .. "/HitsPoses.json")) or "HitsPoses.json"

    _G._HaloProfiles = _G._HaloProfiles or {}
    _G._HaloPoses = _G._HaloPoses or {}
    _G._HaloAntiVoid = (_G._HaloAntiVoid == nil) and true or _G._HaloAntiVoid
    _G._HaloAntiVoidY = _G._HaloAntiVoidY or -50
    _G._HaloLastSafeCF = _G._HaloLastSafeCF or nil
    _G._HaloAutoReanimAfterHop = _G._HaloAutoReanimAfterHop or false

    local function safeWrite(file, data)
        pcall(function()
            if writefile then writefile(file, data) end
        end)
    end
    local function safeRead(file)
        local ok, raw = pcall(function()
            if isfile and isfile(file) and readfile then return readfile(file) end
            return nil
        end)
        return ok and raw or nil
    end

    -- load persisted
    pcall(function()
        local raw = safeRead(PROFILE_FILE)
        if raw then
            local d = HttpService:JSONDecode(raw)
            if type(d) == "table" then _G._HaloProfiles = d end
        end
        raw = safeRead(POSE_FILE)
        if raw then
            local d = HttpService:JSONDecode(raw)
            if type(d) == "table" then _G._HaloPoses = d end
        end
    end)

    local function snapshotProfile()
        return {
            smoothDrag = _G._HaloSmoothDrag,
            tabGrid = _G._HaloTabGridMode,
            antiVoid = _G._HaloAntiVoid,
            armStretch = _G._HaloArmStretchAmount,
            torsoStretch = _G._HaloLimbsUpperTorsoHeight,
            legStretch = _G._HaloLimbsLegHeight,
            spinSpeed = _G._HaloSpinHeadSpeed,
        }
    end

    local function applyProfile(p)
        if not p then return end
        if p.smoothDrag ~= nil then
            _G._HaloSmoothDrag = p.smoothDrag
        end
        if p.tabGrid ~= nil and _G._HaloSetTabGridMode then
            pcall(_G._HaloSetTabGridMode, p.tabGrid)
        end
        if p.antiVoid ~= nil then _G._HaloAntiVoid = p.antiVoid end
        if p.armStretch then _G._HaloArmStretchAmount = p.armStretch end
        if p.torsoStretch then _G._HaloLimbsUpperTorsoHeight = p.torsoStretch end
        if p.legStretch then _G._HaloLimbsLegHeight = p.legStretch end
        if p.spinSpeed then _G._HaloSpinHeadSpeed = p.spinSpeed end
    end

    local function capturePose()
        local clone = ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
        if not clone then return nil end
        local pose = {}
        for _, d in ipairs(clone:GetDescendants()) do
            if d:IsA("AnimationConstraint") or d:IsA("Motor6D") then
                local key
                if d:IsA("Motor6D") and d.Part1 then
                    key = d.Part1.Name
                elseif d.Attachment1 and d.Attachment1.Parent then
                    key = d.Attachment1.Parent.Name
                end
                if key then
                    local cf = d.Transform
                    pose[key] = {cf:GetComponents()}
                end
            end
        end
        return pose
    end

    local function applyPose(pose)
        if not pose then return end
        local clone = ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
        if not clone then
            if Notify then Notify("Reanim first", 2) end
            return
        end
        for _, d in ipairs(clone:GetDescendants()) do
            local key
            if d:IsA("Motor6D") and d.Part1 then
                key = d.Part1.Name
            elseif d:IsA("AnimationConstraint") and d.Attachment1 and d.Attachment1.Parent then
                key = d.Attachment1.Parent.Name
            end
            if key and pose[key] then
                local c = pose[key]
                if type(c) == "table" and #c >= 12 then
                    pcall(function()
                        d.Transform = CFrame.new(unpack(c))
                    end)
                end
            end
        end
    end

    -- UI section header helper
    local function sectionHeader(text, order)
        local h = Instance.new("TextLabel")
        h.Parent = SettingsPanel
        h.BackgroundTransparency = 1
        h.Size = UDim2.new(1, 0, 0, 18)
        h.LayoutOrder = order
        h.Font = Enum.Font.GothamBold
        h.TextSize = 11
        h.Text = text
        h.TextColor3 = C.text
        h.TextXAlignment = Enum.TextXAlignment.Left
        h.ZIndex = 33
        return h
    end

    local function makeBtn(parent, text, order, w, callback)
        local b = Instance.new("TextButton")
        b.Parent = parent
        b.Size = UDim2.new(0, w or 90, 0, 26)
        b.BackgroundColor3 = C.bg3
        b.BackgroundTransparency = 0.05
        b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamBold
        b.Text = text
        b.TextColor3 = C.text2
        b.TextSize = 10
        b.AutoButtonColor = false
        b.LayoutOrder = order or 0
        b.ZIndex = 34
        do
            local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 7); c.Parent = b
            local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.4; s.Thickness = 1; s.Parent = b
        end
        b.MouseEnter:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = C.bg2, TextColor3 = C.text}):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = C.bg3, TextColor3 = C.text2}):Play()
        end)
        b.MouseButton1Click:Connect(callback)
        return b
    end

    -- Profiles card
    sectionHeader("Profiles", 40)
    local profCard = Instance.new("Frame")
    profCard.Parent = SettingsPanel
    profCard.Size = UDim2.new(1, 0, 0, 78)
    profCard.BackgroundColor3 = C.bg1
    profCard.BackgroundTransparency = 0.12
    profCard.BorderSizePixel = 0
    profCard.LayoutOrder = 41
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = profCard
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.4; s.Thickness = 1; s.Parent = profCard
    end
    local profName = Instance.new("TextBox")
    profName.Parent = profCard
    profName.Size = UDim2.new(1, -28, 0, 24)
    profName.Position = UDim2.new(0, 14, 0, 10)
    profName.BackgroundColor3 = C.bg3
    profName.BackgroundTransparency = 0.05
    profName.BorderSizePixel = 0
    profName.Font = Enum.Font.GothamMedium
    profName.PlaceholderText = "profile name..."
    profName.PlaceholderColor3 = C.text3
    profName.Text = ""
    profName.TextColor3 = C.text
    profName.TextSize = 11
    profName.ClearTextOnFocus = false
    profName.ZIndex = 34
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = profName end

    local profRow = Instance.new("Frame")
    profRow.Parent = profCard
    profRow.BackgroundTransparency = 1
    profRow.Position = UDim2.new(0, 14, 0, 42)
    profRow.Size = UDim2.new(1, -28, 0, 26)
    local profLayout = Instance.new("UIListLayout")
    profLayout.Parent = profRow
    profLayout.FillDirection = Enum.FillDirection.Horizontal
    profLayout.Padding = UDim.new(0, 6)

    makeBtn(profRow, "Save", 1, 70, function()
        local n = profName.Text
        if n == "" then n = "default" end
        _G._HaloProfiles[n] = snapshotProfile()
        safeWrite(PROFILE_FILE, HttpService:JSONEncode(_G._HaloProfiles))
        if Notify then Notify("Profile saved: " .. n, 2) end
    end)
    makeBtn(profRow, "Load", 2, 70, function()
        local n = profName.Text
        if n == "" then n = "default" end
        local p = _G._HaloProfiles[n]
        if not p then
            if Notify then Notify("No profile: " .. n, 2) end
            return
        end
        applyProfile(p)
        if Notify then Notify("Profile loaded: " .. n, 2) end
    end)
    makeBtn(profRow, "Delete", 3, 70, function()
        local n = profName.Text
        if n == "" then return end
        _G._HaloProfiles[n] = nil
        safeWrite(PROFILE_FILE, HttpService:JSONEncode(_G._HaloProfiles))
        if Notify then Notify("Deleted: " .. n, 2) end
    end)

    -- Pose bookmarks
    sectionHeader("Pose Bookmarks", 42)
    local poseCard = Instance.new("Frame")
    poseCard.Parent = SettingsPanel
    poseCard.Size = UDim2.new(1, 0, 0, 78)
    poseCard.BackgroundColor3 = C.bg1
    poseCard.BackgroundTransparency = 0.12
    poseCard.BorderSizePixel = 0
    poseCard.LayoutOrder = 43
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = poseCard
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.4; s.Thickness = 1; s.Parent = poseCard
    end
    local poseName = Instance.new("TextBox")
    poseName.Parent = poseCard
    poseName.Size = UDim2.new(1, -28, 0, 24)
    poseName.Position = UDim2.new(0, 14, 0, 10)
    poseName.BackgroundColor3 = C.bg3
    poseName.BackgroundTransparency = 0.05
    poseName.BorderSizePixel = 0
    poseName.Font = Enum.Font.GothamMedium
    poseName.PlaceholderText = "pose name..."
    poseName.PlaceholderColor3 = C.text3
    poseName.Text = ""
    poseName.TextColor3 = C.text
    poseName.TextSize = 11
    poseName.ClearTextOnFocus = false
    poseName.ZIndex = 34
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = poseName end

    local poseRow = Instance.new("Frame")
    poseRow.Parent = poseCard
    poseRow.BackgroundTransparency = 1
    poseRow.Position = UDim2.new(0, 14, 0, 42)
    poseRow.Size = UDim2.new(1, -28, 0, 26)
    local poseLayout = Instance.new("UIListLayout")
    poseLayout.Parent = poseRow
    poseLayout.FillDirection = Enum.FillDirection.Horizontal
    poseLayout.Padding = UDim.new(0, 6)

    makeBtn(poseRow, "Save Pose", 1, 80, function()
        if not State.isReanimated then
            if Notify then Notify("Reanim first", 2) end
            return
        end
        local n = poseName.Text
        if n == "" then n = "pose1" end
        local pose = capturePose()
        if not pose then
            if Notify then Notify("No clone", 2) end
            return
        end
        _G._HaloPoses[n] = pose
        safeWrite(POSE_FILE, HttpService:JSONEncode(_G._HaloPoses))
        if Notify then Notify("Pose saved: " .. n, 2) end
    end)
    makeBtn(poseRow, "Apply", 2, 70, function()
        local n = poseName.Text
        if n == "" then n = "pose1" end
        local pose = _G._HaloPoses[n]
        if not pose then
            if Notify then Notify("No pose: " .. n, 2) end
            return
        end
        applyPose(pose)
        if Notify then Notify("Pose applied: " .. n, 1.5) end
    end)
    makeBtn(poseRow, "Delete", 3, 70, function()
        local n = poseName.Text
        if n == "" then return end
        _G._HaloPoses[n] = nil
        safeWrite(POSE_FILE, HttpService:JSONEncode(_G._HaloPoses))
        if Notify then Notify("Pose deleted", 1.5) end
    end)

    -- Anim pack import/export
    sectionHeader("Anim Packs", 44)
    local packCard = Instance.new("Frame")
    packCard.Parent = SettingsPanel
    packCard.Size = UDim2.new(1, 0, 0, 52)
    packCard.BackgroundColor3 = C.bg1
    packCard.BackgroundTransparency = 0.12
    packCard.BorderSizePixel = 0
    packCard.LayoutOrder = 45
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = packCard
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.4; s.Thickness = 1; s.Parent = packCard
    end
    local packRow = Instance.new("Frame")
    packRow.Parent = packCard
    packRow.BackgroundTransparency = 1
    packRow.Position = UDim2.new(0, 14, 0, 12)
    packRow.Size = UDim2.new(1, -28, 0, 26)
    local packLayout = Instance.new("UIListLayout")
    packLayout.Parent = packRow
    packLayout.FillDirection = Enum.FillDirection.Horizontal
    packLayout.Padding = UDim.new(0, 6)

    makeBtn(packRow, "Export Favs", 1, 90, function()
        local favs = _G._HaloFavorites or State and State.favorites or {}
        local payload = HttpService:JSONEncode({type = "HitsAnimPack", v = 1, favs = favs})
        safeWrite(PACK_FILE, payload)
        if setclipboard then pcall(setclipboard, payload) end
        if Notify then Notify("Favs exported (file + clipboard)", 2.5) end
    end)
    makeBtn(packRow, "Import Pack", 2, 90, function()
        local raw = safeRead(PACK_FILE)
        if not raw and getclipboard then
            local ok, clip = pcall(getclipboard)
            if ok then raw = clip end
        end
        if not raw then
            if Notify then Notify("No pack in file/clipboard", 2) end
            return
        end
        local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
        if not ok or type(data) ~= "table" then
            if Notify then Notify("Invalid pack", 2) end
            return
        end
        if data.favs then
            _G._HaloFavorites = data.favs
            if State then State.favorites = data.favs end
            if Notify then Notify("Pack imported", 2) end
        else
            if Notify then Notify("Pack had no favs", 2) end
        end
    end)

    -- Server hop + auto reanim
    sectionHeader("Server Hop", 46)
    local hopCard = Instance.new("Frame")
    hopCard.Parent = SettingsPanel
    hopCard.Size = UDim2.new(1, 0, 0, 52)
    hopCard.BackgroundColor3 = C.bg1
    hopCard.BackgroundTransparency = 0.12
    hopCard.BorderSizePixel = 0
    hopCard.LayoutOrder = 47
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = hopCard
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.4; s.Thickness = 1; s.Parent = hopCard
    end
    local hopRow = Instance.new("Frame")
    hopRow.Parent = hopCard
    hopRow.BackgroundTransparency = 1
    hopRow.Position = UDim2.new(0, 14, 0, 12)
    hopRow.Size = UDim2.new(1, -28, 0, 26)
    local hopLayout = Instance.new("UIListLayout")
    hopLayout.Parent = hopRow
    hopLayout.FillDirection = Enum.FillDirection.Horizontal
    hopLayout.Padding = UDim.new(0, 6)

    makeBtn(hopRow, "Hop + Reanim", 1, 110, function()
        _G._HaloAutoReanimAfterHop = true
        pcall(function()
            if writefile then writefile("HitsAutoReanim.flag", "1") end
        end)
        pcall(function()
            if queue_on_teleport then
                queue_on_teleport([[
                    _G._HaloAutoReanimAfterHop = true
                ]])
            end
        end)
        if Notify then Notify("Hopping...", 2) end
        task.delay(0.3, function()
            pcall(function()
                TeleportService:Teleport(game.PlaceId, plr)
            end)
        end)
    end)
    makeBtn(hopRow, "Hop Only", 2, 80, function()
        if Notify then Notify("Hopping...", 2) end
        task.delay(0.2, function()
            pcall(function()
                TeleportService:Teleport(game.PlaceId, plr)
            end)
        end)
    end)

    -- Auto-reanim after hop
    task.spawn(function()
        local flag = false
        pcall(function()
            if isfile and isfile("HitsAutoReanim.flag") and readfile then
                flag = readfile("HitsAutoReanim.flag") == "1"
                if delfile then delfile("HitsAutoReanim.flag") end
            end
        end)
        if flag or _G._HaloAutoReanimAfterHop then
            _G._HaloAutoReanimAfterHop = false
            task.wait(1.2)
            if not State.isReanimated and type(_G._HaloDoReanimToggle) == "function" then
                pcall(_G._HaloDoReanimToggle)
                if Notify then Notify("Auto-reanim after hop", 2) end
            end
        end
    end)

    -- Anti-void
    sectionHeader("Safety", 48)
    local voidCard = Instance.new("Frame")
    voidCard.Parent = SettingsPanel
    voidCard.Size = UDim2.new(1, 0, 0, 54)
    voidCard.BackgroundColor3 = C.bg1
    voidCard.BackgroundTransparency = 0.12
    voidCard.BorderSizePixel = 0
    voidCard.LayoutOrder = 49
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = voidCard
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.4; s.Thickness = 1; s.Parent = voidCard
    end
    local voidLbl = Instance.new("TextLabel")
    voidLbl.Parent = voidCard
    voidLbl.BackgroundTransparency = 1
    voidLbl.Position = UDim2.new(0, 14, 0, 8)
    voidLbl.Size = UDim2.new(1, -70, 0, 16)
    voidLbl.Font = Enum.Font.GothamMedium
    voidLbl.Text = "Anti-Void Recovery"
    voidLbl.TextColor3 = C.text
    voidLbl.TextSize = 12
    voidLbl.TextXAlignment = Enum.TextXAlignment.Left
    voidLbl.ZIndex = 33
    local voidSub = Instance.new("TextLabel")
    voidSub.Parent = voidCard
    voidSub.BackgroundTransparency = 1
    voidSub.Position = UDim2.new(0, 14, 0, 28)
    voidSub.Size = UDim2.new(1, -70, 0, 16)
    voidSub.Font = Enum.Font.Gotham
    voidSub.Text = "Teleport back if you fall under the map"
    voidSub.TextColor3 = C.text3
    voidSub.TextSize = 10
    voidSub.TextXAlignment = Enum.TextXAlignment.Left
    voidSub.ZIndex = 33

    local voidBg = Instance.new("Frame")
    voidBg.Parent = voidCard
    voidBg.Size = UDim2.new(0, 42, 0, 24)
    voidBg.Position = UDim2.new(1, -54, 0.5, -12)
    voidBg.BackgroundColor3 = _G._HaloAntiVoid and C.green or C.bg3
    voidBg.BorderSizePixel = 0
    voidBg.ZIndex = 33
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = voidBg end
    local voidKnob = Instance.new("Frame", voidBg)
    voidKnob.Size = UDim2.new(0, 18, 0, 18)
    voidKnob.Position = _G._HaloAntiVoid and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    voidKnob.BackgroundColor3 = C.white
    voidKnob.BorderSizePixel = 0
    voidKnob.ZIndex = 34
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = voidKnob end
    local voidBtn = Instance.new("TextButton", voidBg)
    voidBtn.Size = UDim2.new(1, 0, 1, 0)
    voidBtn.BackgroundTransparency = 1
    voidBtn.Text = ""
    voidBtn.ZIndex = 35
    voidBtn.MouseButton1Click:Connect(function()
        _G._HaloAntiVoid = not _G._HaloAntiVoid
        if _G._HaloAntiVoid then
            TweenService:Create(voidBg, TweenInfo.new(0.18), {BackgroundColor3 = C.green}):Play()
            TweenService:Create(voidKnob, TweenInfo.new(0.18), {Position = UDim2.new(1, -21, 0.5, -9)}):Play()
        else
            TweenService:Create(voidBg, TweenInfo.new(0.18), {BackgroundColor3 = C.bg3}):Play()
            TweenService:Create(voidKnob, TweenInfo.new(0.18), {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
        end
        if Notify then Notify("Anti-Void", _G._HaloAntiVoid and "ON" or "OFF", 1.5) end
    end)

    -- Anti-void loop
    RunService.Heartbeat:Connect(function()
        if not _G._HaloAntiVoid then return end
        local char = plr.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if hrp.Position.Y > (_G._HaloAntiVoidY or -50) then
            _G._HaloLastSafeCF = hrp.CFrame
        else
            local safe = _G._HaloLastSafeCF
            if safe then
                hrp.CFrame = safe + Vector3.new(0, 4, 0)
                local clone = ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
                if clone then
                    local cHRP = clone:FindFirstChild("HumanoidRootPart")
                    if cHRP then cHRP.CFrame = hrp.CFrame end
                end
            end
        end
    end)

    -- Anim preview ghost
    sectionHeader("Anim Preview", 50)
    local prevCard = Instance.new("Frame")
    prevCard.Parent = SettingsPanel
    prevCard.Size = UDim2.new(1, 0, 0, 52)
    prevCard.BackgroundColor3 = C.bg1
    prevCard.BackgroundTransparency = 0.12
    prevCard.BorderSizePixel = 0
    prevCard.LayoutOrder = 51
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = prevCard
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.4; s.Thickness = 1; s.Parent = prevCard
    end
    local prevRow = Instance.new("Frame")
    prevRow.Parent = prevCard
    prevRow.BackgroundTransparency = 1
    prevRow.Position = UDim2.new(0, 14, 0, 12)
    prevRow.Size = UDim2.new(1, -28, 0, 26)
    local prevLayout = Instance.new("UIListLayout")
    prevLayout.Parent = prevRow
    prevLayout.FillDirection = Enum.FillDirection.Horizontal
    prevLayout.Padding = UDim.new(0, 6)

    local previewGhost = nil
    local function destroyPreview()
        if previewGhost then
            pcall(function() previewGhost:Destroy() end)
            previewGhost = nil
        end
    end

    makeBtn(prevRow, "Preview Last", 1, 100, function()
        destroyPreview()
        local animData = ReanimateAPI and ReanimateAPI.get_animation_data and ReanimateAPI.get_animation_data()
        local name = (NowPlayingLabel and NowPlayingLabel.Text) or "preview"
        local char = plr.Character
        if not char then
            if Notify then Notify("No character", 2) end
            return
        end
        local ok, ghost = pcall(function()
            local g = char:Clone()
            g.Name = "HitsPreviewGhost"
            for _, d in ipairs(g:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.Transparency = math.max(d.Transparency, 0.55)
                    d.CanCollide = false
                    d.Anchored = true
                elseif d:IsA("Decal") or d:IsA("Texture") then
                    d.Transparency = 0.55
                elseif d:IsA("Script") or d:IsA("LocalScript") then
                    d:Destroy()
                end
            end
            local hum = g:FindFirstChildOfClass("Humanoid")
            if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
            g.Parent = workspace
            local hrp = g:FindFirstChild("HumanoidRootPart") or g:FindFirstChild("Torso") or g.PrimaryPart
            local my = char:FindFirstChild("HumanoidRootPart")
            if hrp and my then
                hrp.CFrame = my.CFrame * CFrame.new(0, 0, -4)
            end
            return g
        end)
        if ok and ghost then
            previewGhost = ghost
            if Notify then Notify("Preview ghost spawned", 2) end
            task.delay(6, destroyPreview)
        else
            if Notify then Notify("Preview failed", 2) end
        end
    end)
    makeBtn(prevRow, "Clear Ghost", 2, 90, function()
        destroyPreview()
        if Notify then Notify("Preview cleared", 1.5) end
    end)

    _G._HaloApplyPose = applyPose
    _G._HaloCapturePose = capturePose
    _G._HaloApplyProfile = applyProfile
end

-- 0. Shaders Toggle Frame
local shadersFrame = Instance.new("Frame", SettingsPanel)
shadersFrame.Size = UDim2.new(1,0,0,54)
shadersFrame.BackgroundColor3 = C.bg1; shadersFrame.BackgroundTransparency = 0.4; shadersFrame.BorderSizePixel = 0
shadersFrame.LayoutOrder = 0
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,7); c.Parent = shadersFrame
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = shadersFrame
end

local shadersLbl = Instance.new("TextLabel", shadersFrame)
shadersLbl.BackgroundTransparency = 1; shadersLbl.Position = UDim2.new(0,10,0,6)
shadersLbl.Size = UDim2.new(1,-120,0,16); shadersLbl.Font = Enum.Font.GothamBold
shadersLbl.Text = "Shaders & Lighting"; shadersLbl.TextColor3 = C.text; shadersLbl.TextSize = 11
shadersLbl.TextXAlignment = Enum.TextXAlignment.Left

local shadersSub = Instance.new("TextLabel", shadersFrame)
shadersSub.BackgroundTransparency = 1; shadersSub.Position = UDim2.new(0,10,0,24)
shadersSub.Size = UDim2.new(1,-120,0,24); shadersSub.Font = Enum.Font.Gotham
shadersSub.Text = "Enable custom lighting and atmosphere effects"; shadersSub.TextColor3 = C.text3; shadersSub.TextSize = 9
shadersSub.TextXAlignment = Enum.TextXAlignment.Left; shadersSub.TextWrapped = true

local shadersToggleBg = Instance.new("Frame", shadersFrame)
shadersToggleBg.Size = UDim2.new(0,44,0,22); shadersToggleBg.Position = UDim2.new(1,-54,0,16)
shadersToggleBg.BackgroundColor3 = _G._HaloShadersEnabled and C.green or C.bg4; shadersToggleBg.BorderSizePixel = 0; shadersToggleBg.ZIndex = 33
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,11); c.Parent = shadersToggleBg end
local shadersKnob = Instance.new("Frame", shadersToggleBg)
shadersKnob.Size = UDim2.new(0,16,0,16); shadersKnob.Position = _G._HaloShadersEnabled and UDim2.new(1,-19,0,3) or UDim2.new(0,3,0,3)
shadersKnob.BackgroundColor3 = C.white; shadersKnob.BorderSizePixel = 0; shadersKnob.ZIndex = 34
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,8); c.Parent = shadersKnob end
local shadersToggleBtn = Instance.new("TextButton", shadersToggleBg)
shadersToggleBtn.Size = UDim2.new(1,0,1,0); shadersToggleBtn.BackgroundTransparency = 1; shadersToggleBtn.Text = ""; shadersToggleBtn.ZIndex = 35

local function updateShadersToggle(state)
    _G._HaloShadersEnabled = state
    SaveShadersConfig()
    if state then
        TweenService:Create(shadersToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = C.green}):Play()
        TweenService:Create(shadersKnob, TweenInfo.new(0.2), {Position = UDim2.new(1,-19,0,3)}):Play()
        Notify("Shaders enabled! Rejoin to apply effects.", 3)
    else
        TweenService:Create(shadersToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = C.bg4}):Play()
        TweenService:Create(shadersKnob, TweenInfo.new(0.2), {Position = UDim2.new(0,3,0,3)}):Play()
        Notify("Shaders disabled! Rejoin to remove effects.", 3)
    end
end

shadersToggleBtn.MouseButton1Click:Connect(function()
    updateShadersToggle(not _G._HaloShadersEnabled)
end)

-- 1. Import from AK Frame
local akFrame = Instance.new("Frame", SettingsPanel)
akFrame.Size = UDim2.new(1,0,0,54)
akFrame.BackgroundColor3 = C.bg1; akFrame.BackgroundTransparency = 0.4; akFrame.BorderSizePixel = 0
akFrame.LayoutOrder = 1
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,7); c.Parent = akFrame
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = akFrame
end

local akLbl = Instance.new("TextLabel", akFrame)
akLbl.BackgroundTransparency = 1; akLbl.Position = UDim2.new(0,10,0,6)
akLbl.Size = UDim2.new(1,-120,0,16); akLbl.Font = Enum.Font.GothamBold
akLbl.Text = "Import Animations"; akLbl.TextColor3 = C.text; akLbl.TextSize = 11
akLbl.TextXAlignment = Enum.TextXAlignment.Left

local akSub = Instance.new("TextLabel", akFrame)
akSub.BackgroundTransparency = 1; akSub.Position = UDim2.new(0,10,0,24)
akSub.Size = UDim2.new(1,-120,0,24); akSub.Font = Enum.Font.Gotham
akSub.Text = "Import custom animations from AK config files"; akSub.TextColor3 = C.text3; akSub.TextSize = 9
akSub.TextXAlignment = Enum.TextXAlignment.Left; akSub.TextWrapped = true

local akBtn = Instance.new("TextButton", akFrame)
akBtn.Size = UDim2.new(0,96,0,24); akBtn.Position = UDim2.new(1,-102,0.5,-12)
akBtn.BackgroundColor3 = C.bg2; akBtn.BackgroundTransparency = 0.2; akBtn.BorderSizePixel = 0
akBtn.Font = Enum.Font.GothamBold; akBtn.Text = "Import"; akBtn.TextColor3 = C.accent; akBtn.TextSize = 10
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,5); c.Parent = akBtn
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = akBtn
end

-- 2. Fortnite Emote Wheel Keybind Frame
local fnWheelFrame = Instance.new("Frame", SettingsPanel)
fnWheelFrame.Size = UDim2.new(1,0,0,54)
fnWheelFrame.BackgroundColor3 = C.bg1; fnWheelFrame.BackgroundTransparency = 0.4; fnWheelFrame.BorderSizePixel = 0
fnWheelFrame.LayoutOrder = 2
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,7); c.Parent = fnWheelFrame
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = fnWheelFrame
end

local fnLbl = Instance.new("TextLabel", fnWheelFrame)
fnLbl.BackgroundTransparency = 1; fnLbl.Position = UDim2.new(0,10,0,6)
fnLbl.Size = UDim2.new(1,-120,0,16); fnLbl.Font = Enum.Font.GothamBold
fnLbl.Text = "Fortnite Emote Wheel"; fnLbl.TextColor3 = C.text; fnLbl.TextSize = 11
fnLbl.TextXAlignment = Enum.TextXAlignment.Left

local fnSub = Instance.new("TextLabel", fnWheelFrame)
fnSub.BackgroundTransparency = 1; fnSub.Position = UDim2.new(0,10,0,24)
fnSub.Size = UDim2.new(1,-120,0,24); fnSub.Font = Enum.Font.Gotham
fnSub.Text = "Hold bound key in-game to open Fortnite Wheel"; fnSub.TextColor3 = C.text3; fnSub.TextSize = 9
fnSub.TextXAlignment = Enum.TextXAlignment.Left; fnSub.TextWrapped = true

local fnWheelBtn = Instance.new("TextButton", fnWheelFrame)
fnWheelBtn.Size = UDim2.new(0,96,0,24); fnWheelBtn.Position = UDim2.new(1,-102,0.5,-12)
fnWheelBtn.BackgroundColor3 = C.bg2; fnWheelBtn.BackgroundTransparency = 0.2; fnWheelBtn.BorderSizePixel = 0
fnWheelBtn.Font = Enum.Font.GothamBold; fnWheelBtn.Text = "Key: None"; fnWheelBtn.TextColor3 = C.accent; fnWheelBtn.TextSize = 10
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,5); c.Parent = fnWheelBtn
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = fnWheelBtn
end

-- 3. Reverse Animation Frame
local revFrame = Instance.new("Frame", SettingsPanel)
revFrame.Size = UDim2.new(1,0,0,90)
revFrame.BackgroundColor3 = C.bg1; revFrame.BackgroundTransparency = 0.4; revFrame.BorderSizePixel = 0
revFrame.LayoutOrder = 3
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,7); c.Parent = revFrame
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = revFrame
end

local revLbl = Instance.new("TextLabel", revFrame)
revLbl.BackgroundTransparency = 1; revLbl.Position = UDim2.new(0,10,0,6)
revLbl.Size = UDim2.new(1,-120,0,16); revLbl.Font = Enum.Font.GothamBold
revLbl.Text = "Hold to Reverse Animation"; revLbl.TextColor3 = C.text; revLbl.TextSize = 11
revLbl.TextXAlignment = Enum.TextXAlignment.Left

local revSub = Instance.new("TextLabel", revFrame)
revSub.BackgroundTransparency = 1; revSub.Position = UDim2.new(0,10,0,24)
revSub.Size = UDim2.new(1,-120,0,24); revSub.Font = Enum.Font.Gotham
revSub.Text = "Hold key to reverse play direction"; revSub.TextColor3 = C.text3; revSub.TextSize = 9
revSub.TextXAlignment = Enum.TextXAlignment.Left; revSub.TextWrapped = true

local revBtn = Instance.new("TextButton", revFrame)
revBtn.Size = UDim2.new(0,96,0,24); revBtn.Position = UDim2.new(1,-102,0,16)
revBtn.BackgroundColor3 = C.bg2; revBtn.BackgroundTransparency = 0.2; revBtn.BorderSizePixel = 0
revBtn.Font = Enum.Font.GothamBold; revBtn.Text = "Key: None"; revBtn.TextColor3 = C.accent; revBtn.TextSize = 10
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,5); c.Parent = revBtn
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = revBtn
end

revSpdLbl = Instance.new("TextLabel", revFrame)
revSpdLbl.BackgroundTransparency = 1; revSpdLbl.Position = UDim2.new(0,10,0,54)
revSpdLbl.Size = UDim2.new(0,120,0,20); revSpdLbl.Font = Enum.Font.GothamBold
revSpdLbl.Text = "Reverse Speed: 1.0x"; revSpdLbl.TextColor3 = C.text2; revSpdLbl.TextSize = 9
revSpdLbl.TextXAlignment = Enum.TextXAlignment.Left

local revTrack = Instance.new("Frame", revFrame)
revTrack.BackgroundColor3 = C.bg2; revTrack.BackgroundTransparency = 0.3; revTrack.BorderSizePixel = 0
revTrack.Position = UDim2.new(0,125,0,60)
revTrack.Size = UDim2.new(1,-140,0,8)
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = revTrack
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = revTrack
end

revFill = Instance.new("Frame", revTrack)
revFill.BackgroundColor3 = C.accent; revFill.BackgroundTransparency = 0.1; revFill.BorderSizePixel = 0
revFill.Size = UDim2.new(0.31,0,1,0)
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = revFill end

revHandle = Instance.new("Frame", revTrack)
revHandle.AnchorPoint = Vector2.new(0.5,0.5)
revHandle.BackgroundColor3 = C.accent; revHandle.BackgroundTransparency = 0; revHandle.BorderSizePixel = 0
revHandle.Position = UDim2.new(0.31,0,0.5,0)
revHandle.Size = UDim2.new(0,12,0,12)
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = revHandle
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.4; s.Thickness = 1; s.Parent = revHandle
end

-- Reverse Drag and speed setting logic
local revDrag = false
revTrack.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        revDrag = true
        local pct = math.clamp((inp.Position.X - revTrack.AbsolutePosition.X) / revTrack.AbsoluteSize.X, 0, 1)
        GlobalReverseSpeed = math.floor((0.1 + pct * 2.9) * 10 + 0.5) / 10
        revFill.Size = UDim2.new(pct, 0, 1, 0)
        revHandle.Position = UDim2.new(pct, 0, 0.5, 0)
        revSpdLbl.Text = "Reverse Speed: " .. string.format("%.1f", GlobalReverseSpeed) .. "x"
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 and revDrag then
        revDrag = false
        SaveData()
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if revDrag and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local pct = math.clamp((inp.Position.X - revTrack.AbsolutePosition.X) / revTrack.AbsoluteSize.X, 0, 1)
        GlobalReverseSpeed = math.floor((0.1 + pct * 2.9) * 10 + 0.5) / 10
        revFill.Size = UDim2.new(pct, 0, 1, 0)
        revHandle.Position = UDim2.new(pct, 0, 0.5, 0)
        revSpdLbl.Text = "Reverse Speed: " .. string.format("%.1f", GlobalReverseSpeed) .. "x"
    end
end)

-- Keybind update function
updateFnWheelBtnText = function()
    local keyName = _G._FortniteWheelKey and _G._FortniteWheelKey.Name or "None"
    fnWheelBtn.Text = "Key: " .. keyName
end

updateRevBtnText = function()
    local keyName = GlobalReverseKeybind and GlobalReverseKeybind.Name or "None"
    revBtn.Text = "Key: " .. keyName
end

-- Wire up Fortnite keybind dialog
local settingWheelKey = false
fnWheelBtn.MouseButton1Click:Connect(function()
    if settingWheelKey then return end
    settingWheelKey = true
    fnWheelBtn.Text = "Listening..."
    fnWheelBtn.BackgroundColor3 = C.yellow
    local keyConn
    keyConn = UserInputService.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(i, gp)
        if gp then return end
        keyConn:Disconnect()
        settingWheelKey = false
        fnWheelBtn.BackgroundColor3 = C.bg2
        if i.KeyCode == Enum.KeyCode.Escape then
            updateFnWheelBtnText()
            return
        end
        _G._FortniteWheelKey = i.KeyCode
        SaveData()
        updateFnWheelBtnText()
    end))
end)

-- Wire up Reverse keybind dialog
local settingRevKey = false
revBtn.MouseButton1Click:Connect(function()
    if settingRevKey then return end
    -- If a key is already bound, clicking the button unbinds it. The user has
    -- to click again to enter listening mode and pick a new key.
    if GlobalReverseKeybind then
        GlobalReverseKeybind = nil
        SaveData()
        updateRevBtnText()
        return
    end
    settingRevKey = true
    revBtn.Text = "Listening..."
    revBtn.BackgroundColor3 = C.yellow
    local keyConn
    keyConn = UserInputService.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(i, gp)
        if gp then return end
        keyConn:Disconnect()
        settingRevKey = false
        revBtn.BackgroundColor3 = C.bg2
        if i.KeyCode == Enum.KeyCode.Escape then
            updateRevBtnText()
            return
        end
        GlobalReverseKeybind = i.KeyCode
        SaveData()
        updateRevBtnText()
    end))
end)

-- Wire up Import from AK button
akBtn.MouseButton1Click:Connect(function()
    -- Run the whole import on its own thread so a heavy file never blocks the UI,
    -- and so we can yield during processing.
    task.spawn(function()
    local success, errorMsg = pcall(function()
        local function notifyUser(msg, isError)
            if WindUI and WindUI.Notify then
                pcall(function()
                    WindUI:Notify({
                        Title = isError and "Import Error" or "Animation Import",
                        Content = msg,
                        Duration = 5,
                        Icon = isError and "alert-triangle" or "download"
                    })
                end)
            elseif NotifyLib and NotifyLib.send then
                pcall(function()
                    NotifyLib.send(msg, { duration = 5 })
                end)
            end
        end

        if not readfile then
            notifyUser("Executor doesn't support file reading.", true)
            return
        end
        local raw, foundPath = nil, nil
        local pathsToCheck = {
            "workspace/ custom_animations.json",         -- Potassium format with space
            "workspace/custom_animations.json",          -- Standard format
            " custom_animations.json",                   -- Direct with space
            "custom_animations.json",                    -- Direct without space
            "ak/custom_animations.json",
            "ak/ custom_animations.json",
            "../workspace/ custom_animations.json",
            "../workspace/custom_animations.json",
            "../../workspace/ custom_animations.json",   -- Two levels up
            "../../workspace/custom_animations.json",
        }
        for _, path in ipairs(pathsToCheck) do
            local ok, content
            if isfile then
                local isF = false
                pcall(function() isF = isfile(path) end)
                if isF then ok, content = pcall(readfile, path) end
            else
                ok, content = pcall(readfile, path)
            end
            if ok and content and content ~= "" then
                raw = content
                foundPath = path
                break
            end
        end
        if not raw then
            notifyUser("Could not locate custom_animations.json in workspace folder.", true)
            return
        end

        -- Strip optional UTF-8 BOM cheaply (no whole-string :gsub, which doubles
        -- memory). The CR/LF normalization that used to follow was unnecessary
        -- because JSONDecode handles those fine anyway.
        if raw:sub(1, 3) == "\xEF\xBB\xBF" then
            raw = raw:sub(4)
        end

        local data
        do
            local ok2, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
            if not ok2 or type(decoded) ~= "table" then
                notifyUser("Failed to parse JSON. File may be too large or malformed.", true)
                return
            end
            data = decoded
        end
        -- Drop the raw string reference so GC can reclaim its memory before we
        -- start building thousands of entries / writing thousands of files.
        raw = nil
        task.wait()
        if collectgarbage then pcall(collectgarbage, "collect") end

        local kbData = {}
        local kbPaths = {
            "workspace/animation_keybinds.json",         -- Potassium standard
            "workspace/ animation_keybinds.json",        -- With space
            "animation_keybinds.json",
            "ak/animation_keybinds.json",
            "../workspace/animation_keybinds.json",
            "../../workspace/animation_keybinds.json",   -- Two levels up
        }
        for _, path in ipairs(kbPaths) do
            local ok, content
            if isfile then
                local isF = false
                pcall(function() isF = isfile(path) end)
                if isF then ok, content = pcall(readfile, path) end
            else
                ok, content = pcall(readfile, path)
            end
            if ok and content and content ~= "" then
                if content:sub(1, 3) == "\xEF\xBB\xBF" then content = content:sub(4) end
                local ok3, parsedKb = pcall(function() return HttpService:JSONDecode(content) end)
                if ok3 and type(parsedKb) == "table" then
                    kbData = parsedKb
                    break
                end
            end
        end

        local count = 0
        local boundCount = 0
        local _byName = {}
        for _, val in ipairs(CustomAnims) do _byName[val.name] = val end

        -- Yield budget: yield a frame whenever we've used 12ms of CPU so the
        -- game never freezes even with thousands of animations.
        local _frameStart = os.clock()
        local function _maybeYield()
            if os.clock() - _frameStart > 0.012 then
                task.wait()
                _frameStart = os.clock()
            end
        end

        local function addAnim(name, script)
            if type(name) == "string" and type(script) == "string" and name ~= "" and script ~= "" then
                -- Keep the EXACT name from the AK file (trim surrounding whitespace only)
                local animName = name:match("^%s*(.-)%s*$")
                if animName ~= "" then
                    pcall(function() ReanimateAPI.seed_animation_cache(animName, nil) end)

                    -- Detect if the data is JSON keyframe data
                    local firstChar = script:match("^%s*(.)")
                    local isJson = (firstChar == "{" or firstChar == "[")

                    -- Write each animation to its OWN file in the ReanimData folder.
                    -- Only the FILENAME is sanitized (filesystem safety); the animation
                    -- name itself stays exactly as it is in the AK file.
                    local ext = isJson and ".json" or ".lua"
                    local safeBase = animName:gsub("[^%w_%-]", "_")
                    local filePath = fpath(safeBase .. ext)
                    local wrote = false
                    pcall(function()
                        writefile(filePath, script)
                        wrote = true
                    end)
                    local storedValue = wrote and filePath or script

                    local existing = _byName[animName]
                    if existing then
                        existing.url = storedValue
                        existing.raw = true
                        existing.isJson = isJson
                        CustomAnimations[animName] = storedValue
                    else
                        local entry = { name = animName, url = storedValue, raw = true, isJson = isJson }
                        table.insert(CustomAnims, entry)
                        _byName[animName] = entry
                        CustomAnimations[animName] = storedValue
                    end
                    count = count + 1

                    -- Auto-bind keybind if one exists for this animation.
                    -- Try the exact name and a few common key-name formats.
                    local kbKey = kbData[name] or kbData[animName]
                    if type(kbKey) == "string" and kbKey ~= "" then
                        local kc = nil
                        local attempts = {
                            kbKey,
                            kbKey:upper(),
                            (#kbKey == 1 and kbKey:upper() or kbKey),
                            "Key" .. kbKey:upper(),
                        }
                        for _, kn in ipairs(attempts) do
                            local ok, res = pcall(function() return Enum.KeyCode[kn] end)
                            if ok and res then kc = res; break end
                        end
                        if kc then
                            local keybindName = "[Custom] " .. animName
                            Keybinds[keybindName] = { key = kc, btn = nil }
                            boundCount = boundCount + 1
                        end
                    end
                end
            end
        end

        -- Snapshot the keys, then process and DELETE each entry from the source
        -- table as we consume it. Releasing entries one-by-one lets the GC
        -- reclaim each animation's memory as we go, which is what prevents
        -- "block too big" / "memory allocation" failures on huge AK exports.
        local keysToProcess = {}
        for k in pairs(data) do keysToProcess[#keysToProcess + 1] = k end
        for i = 1, #keysToProcess do
            local key = keysToProcess[i]
            local val = data[key]
            if type(key) == "string" and type(val) == "string" then
                addAnim(key, val)
            elseif type(val) == "table" then
                local animName = val.name or val.Name or val.title or val.Title
                local animScript = val.script or val.Script or val.content or val.Content or val.code or val.Code or val.data or val.Data
                if type(animName) == "string" and type(animScript) == "string" then
                    addAnim(animName, animScript)
                elseif type(animScript) == "table" then
                    local ok, enc = pcall(function() return HttpService:JSONEncode(animScript) end)
                    if ok and enc then addAnim(animName or key, enc) end
                else
                    local ok, encoded = pcall(function() return HttpService:JSONEncode(val) end)
                    if ok and encoded then addAnim(key, encoded) end
                end
            end
            -- Drop the consumed entry so the source JSON table can shrink
            data[key] = nil
            _maybeYield()
        end
        data = nil
        keysToProcess = nil
        if collectgarbage then pcall(collectgarbage, "collect") end

        SaveCustomAnims()
        SaveKeybindsOnly()
        SaveData()
        
        pcall(function()
            if RebuildCustomList then
                RebuildCustomList()
            elseif _G._ReanimRebuildCustomList then
                _G._ReanimRebuildCustomList()
            end
        end)
        pcall(function()
            if RebuildVisible then
                RebuildVisible()
            end
        end)
        
        if UpdateCustomTabCount then
            UpdateCustomTabCount()
        end
        
        if count > 0 then
            notifyUser("Imported " .. count .. " animation(s), bound " .. boundCount .. " key(s)!")
        else
            notifyUser("No new animations imported.")
        end
    end)
    
    if not success then
        if WindUI and WindUI.Notify then
            pcall(function()
                WindUI:Notify({
                    Title = "Import Error",
                    Content = tostring(errorMsg),
                    Duration = 5,
                    Icon = "alert-triangle"
                })
            end)
        end
    end
    end) -- close the outer task.spawn that wraps the whole import
end)
end

local VROW_H     = 34
local VPAD       = 5
local VPOOL_SIZE = 22

local visibleAnims     = {}
local vPool            = {}
local animRowWidgets   = {}
local _rebuildAnimVer  = 0
local RefreshVirtualRows
local _createAnimRow
local customRowWidgets = {}
local RefreshCustomRows
-- Virtualization state: which slice of each list is currently built, and the
-- filtered/sorted custom-animation list that the custom window draws from.
local visibleCustom    = {}
local _animWinStart    = -1
local _customWinStart  = -1

local function CancelListening()
    if _G._HaloListeningKeyBtn then
        local id    = _G._HaloListenTarget and _G._HaloListenTarget.name
        local bound = id and Keybinds[id]
        _G._HaloListeningKeyBtn.Text             = bound and ("[" .. bound.key.Name .. "]") or "[+]"
        _G._HaloListeningKeyBtn.BackgroundColor3 = bound and C.bg3 or C.bg2
        _G._HaloListeningKeyBtn.TextColor3       = bound and C.accent or C.text3
        _G._HaloListeningKeyBtn = nil
    end
    _G._HaloListenTarget = nil
end

local function BindKey(keyCode)
    if not _G._HaloListenTarget then return end
    local name = _G._HaloListenTarget.name
    local btn  = _G._HaloListenTarget.keyBtn
    for existName, data in pairs(Keybinds) do
        if data.key == keyCode and existName ~= name then
            data.key = nil
            if data.btn and data.btn.Parent then
                data.btn.Text = "[+]"; data.btn.BackgroundColor3 = C.bg2
                data.btn.TextColor3 = C.text3
            end
        end
    end
    Keybinds[name] = { key = keyCode, btn = btn }
    btn.Text = "[" .. keyCode.Name .. "]"
    btn.BackgroundColor3 = C.bg3
    btn.TextColor3 = C.accent
    _G._HaloListeningKeyBtn = nil; _G._HaloListenTarget = nil
    SaveKeybindsOnly()
    Notify(keyCode.Name .. " -> " .. name, 2)
    
    -- Refresh Binds tab if it's currently active
    if State.currentTab == "Binds" then
        task.defer(RebuildBindsList)
    end
end

function UnbindKey(name, btn)
    Keybinds[name] = nil
    btn.Text = "[+]"; btn.BackgroundColor3 = C.bg2
    btn.TextColor3 = C.text3
    SaveKeybindsOnly()
end

function StopAnimation()
    ReanimateAPI.stop_animation()
    State.currentlyPlaying = nil
    State.selectedAnim     = nil
    if NowPlayingLabel then NowPlayingLabel.Text = "No animation playing" end
    if stopEmoteAudio then
        stopEmoteAudio(true)
    end
    -- Re-kick the state system so states resume immediately after manual stop
    if stateSystemActive and State.isReanimated then
        currentStateAnim = nil
        lastLogical = nil
    end
end

StopBtn.MouseButton1Click:Connect(StopAnimation)

local pendingAnim    = nil
local animWorkerBusy = false

function PlayAnimation(animName, speed, isCustom)
    if not ReanimateAPI.is_reanimated() then 
        Notify("Reanim Error", "Cannot play animation, not reanimated.", 3)
        return false 
    end

    local cleanName = animName:gsub("^%[Custom%] ", "")
    local isCustomAnim = isCustom or (CustomAnimations[cleanName] ~= nil)

    local function runPlay()
        local content
        if isCustomAnim then
            local fp = CustomAnimations[cleanName]
            if not fp then 
                Notify("Play Error", "Custom animation file path not found.", 4)
                return false 
            end
            -- Cache custom animations in memory; only re-read/re-parse on cache miss
            if not ReanimateAPI.get_animation_cache(cleanName) then
                local ok2, fileContent
                if type(fp) == "table" and fp.type == "ak" then
                    ok2, fileContent = true, fp.script
                else
                    local fpIsFile = false
                    if type(fp) == "string" then
                        if isfile then
                            local okF, resF = pcall(isfile, fp)
                            if okF and resF then
                                fpIsFile = true
                            end
                        end
                    end
                    if fpIsFile then
                        ok2, fileContent = pcall(readfile, fp)
                    else
                        ok2, fileContent = true, fp
                    end
                end
                if not ok2 or not fileContent or fileContent == "" then
                    Notify("Play Error", "Failed to read custom animation file.", 4)
                    return false
                end
                content = fileContent
                content = content:gsub("^\xEF\xBB\xBF", ""):gsub("\r\n", "\n"):gsub("\r", "\n")
                local firstChar = content:match("^%s*(.)")
                if firstChar == "[" or firstChar == "{" then
                    local parsed = parseJsonAnimation(content)
                    if not parsed then
                        local loaded_fn, err = loadstring("return " .. content)
                        if not loaded_fn then
                            loaded_fn, err = loadstring(content)
                        end
                        if loaded_fn then
                            local ok, data = pcall(function() return loaded_fn() end)
                            if ok and type(data) == "table" then
                                parsed = parseTableAnimation(data)
                            end
                        end
                    end
                    if not parsed then
                        Notify("Format Error", "Failed to parse custom animation.", 6)
                        return false
                    end
                    ReanimateAPI.seed_animation_cache(cleanName, parsed)
                else
                    -- Fix return-wrapped compiler syntax issues
                    if content:match("^%s*return%s*{%s*local") then
                        content = content:gsub("^%s*return%s*{%s*local", "local")
                        local varName = content:match("^%s*local%s+([%w_]+)%s*=")
                        if varName then
                            content = content:gsub("}%s*$", "")
                            content = content:gsub("return%s+[%w_]+%s*$", "")
                            content = content .. "\nreturn " .. varName
                        end
                    end

                    local loaded_fn, err = loadstring(content)
                    if not loaded_fn then
                        Notify("Compile Error", "Syntax error in custom animation: " .. tostring(err), 6)
                        return false
                    end
                    local ok, data = pcall(function() return loaded_fn() end)
                    if not ok then
                        Notify("Execution Error", "Failed to run custom animation: " .. tostring(data), 6)
                        return false
                    end
                    if typeof(data) ~= "table" then
                        Notify("Format Error", "Custom animation must return a table.", 6)
                        return false
                    end
                    local parsed = parseTableAnimation(data)
                    if not parsed then
                        parsed = data
                    end
                    ReanimateAPI.seed_animation_cache(cleanName, parsed)
                end
            end
            content = content or "cached"
        else
            -- Online animations - use cache
            content = AnimationCache[cleanName]
            if not content then
                local cachePath = GetCachePath(cleanName)
                local ok, cached = pcall(readfile, cachePath)
                if ok and cached and cached ~= "" then
                    content = cached
                    AnimationCache[cleanName] = content
                end
            end
            
            if not content then
                local val = AnimationList[cleanName]
                if not val then return false end
                
                if type(val) == "string" and (val:match("^https?://") or val:match("^http://")) then
                    local downloaded = request_get(val)
                    if downloaded and downloaded ~= "" then
                        content = downloaded
                        AnimationCache[cleanName] = content
                        task.spawn(function()
                            pcall(writefile, GetCachePath(cleanName), content)
                        end)
                    else
                        Notify("Download Error", "Failed to download animation.", 4)
                        return false
                    end
                elseif tonumber(val) then
                    local okObj, obj = pcall(function() return game:GetObjects("rbxassetid://" .. tostring(val))[1] end)
                    if okObj and obj then
                        content = obj
                    else
                        content = val
                    end
                else
                    content = val
                end
            end
            
            -- Pre-compile and seed API cache on first load so play_raw_animation never calls loadstring again
            if not ReanimateAPI.get_animation_cache(cleanName) then
                if type(content) == "string" then
                    -- Strip UTF-8 BOM and normalize line endings to prevent parse errors
                    content = content:gsub("^\xEF\xBB\xBF", ""):gsub("\r\n", "\n"):gsub("\r", "\n")
                    
                    -- Fix return-wrapped compiler syntax issues
                    if content:match("^%s*return%s*{%s*local") then
                        content = content:gsub("^%s*return%s*{%s*local", "local")
                        local varName = content:match("^%s*local%s+([%w_]+)%s*=")
                        if varName then
                            content = content:gsub("}%s*$", "")
                            content = content:gsub("return%s+[%w_]+%s*$", "")
                            content = content .. "\nreturn " .. varName
                        end
                    end

                    local firstChar = content:match("^%s*(.)")
                    if firstChar == "[" or firstChar == "{" then
                        local parsed = parseJsonAnimation(content)
                        if not parsed then
                            local loaded_fn, err = loadstring("return " .. content)
                            if not loaded_fn then loaded_fn, err = loadstring(content) end
                            if loaded_fn then
                                local ok, data = pcall(function() return loaded_fn() end)
                                if ok and type(data) == "table" then
                                    parsed = parseTableAnimation(data) or data
                                end
                            end
                        end
                        if parsed then
                            ReanimateAPI.seed_animation_cache(cleanName, parsed)
                        end
                    else
                        local loaded_fn, err = loadstring(content)
                        if not loaded_fn then
                            Notify("Compile Error", tostring(err), 5)
                            return false
                        end
                        local ok, data = pcall(function() return loaded_fn() end)
                        if not ok then
                            Notify("Execution Error", tostring(data), 5)
                            return false
                        end
                        if typeof(data) ~= "table" then
                            Notify("Format Error", "Animation did not return a table.", 5)
                            return false
                        end
                        local parsed = parseTableAnimation(data) or data
                        ReanimateAPI.seed_animation_cache(cleanName, parsed)
                    end
                elseif typeof(content) == "table" then
                    local parsed = parseTableAnimation(content) or content
                    ReanimateAPI.seed_animation_cache(cleanName, parsed)
                end
            end
        end

        -- Cache is always seeded above; force_reload=false so API uses it directly
        local result = ReanimateAPI.play_raw_animation(cleanName, content or "", speed or State.currentSpeed, false)
        if type(result) == "string" then 
            Notify("Play Error", result, 5)
            return false 
        end
        return true
    end

    -- If this exact animation is already playing, pressing the keybind/button again should stop it
    if State.selectedAnim == animName then
        StopAnimation()
        return true
    end

    -- Stop any active state animation first, before setting selectedAnim,
    -- so the heartbeat cannot race-stop the animation we are about to start.
    if currentStateAnim then
        pcall(function() ReanimateAPI.stop_animation() end)
        currentStateAnim = nil
    end

    -- Stop any animation currently playing before we begin the new one
    pcall(function() ReanimateAPI.stop_animation() end)

    State.currentlyPlaying = cleanName
    State.selectedAnim     = animName
    if NowPlayingLabel then NowPlayingLabel.Text = cleanName end

    -- Run the heavy loadstring/parse work off the main thread to avoid freezing
    task.spawn(function()
        local success = runPlay()
        if not success then
            State.currentlyPlaying = nil
            State.selectedAnim     = nil
            if NowPlayingLabel then NowPlayingLabel.Text = "No animation playing" end
            -- Re-kick the state system so states resume after a failed play
            if stateSystemActive and State.isReanimated then
                currentStateAnim = nil
                lastLogical = nil
            end
        end
    end)
    return true
end

-- Create a single real row for one animation. Closures capture `anim` directly
-- (no virtual pool). Returns the widget table.
_createAnimRow = function(anim, yPos)
    local displayName = anim.name:gsub("%.lua$", "")

    local row = Instance.new("Frame")
    row.Name = "AnimRow"; row.Parent = AnimListFrame
    row.BackgroundTransparency = 1
    row.Size = UDim2.new(1,-10,0,VROW_H-4)
    row.Position = UDim2.new(0,5,0,yPos)
    row.ZIndex = 33; row.Visible = true

    local playBtn = Instance.new("TextButton"); playBtn.Parent = row
    playBtn.BackgroundColor3 = C.bg2
    playBtn.BackgroundTransparency = 0.5; playBtn.BorderSizePixel = 0
    playBtn.Size = UDim2.new(1,-82,1,0)
    playBtn.Font = Enum.Font.GothamMedium; playBtn.Text = displayName
    playBtn.TextColor3 = C.text2; playBtn.TextSize = 11
    playBtn.TextXAlignment = Enum.TextXAlignment.Left
    playBtn.TextTruncate = Enum.TextTruncate.AtEnd
    playBtn.ZIndex = 34; playBtn.AutoButtonColor = false
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,8); c.Parent = playBtn
        local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0,10); p.Parent = playBtn
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.5; s.Thickness = 1; s.Parent = playBtn
    end

    local favBtn = Instance.new("TextButton"); favBtn.Parent = row
    favBtn.BackgroundColor3 = C.bg2
    favBtn.BackgroundTransparency = 0.3; favBtn.BorderSizePixel = 0
    favBtn.Position = UDim2.new(1,-80,0,0)
    favBtn.Size = UDim2.new(0,26,1,0); favBtn.Font = Enum.Font.GothamBold
    favBtn.Text = ""; favBtn.ZIndex = 34; favBtn.AutoButtonColor = false
    local favIcon
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,5); c.Parent = favBtn
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.8; s.Thickness = 1; s.Parent = favBtn
        favIcon = Instance.new("ImageLabel"); favIcon.Name = "Icon"; favIcon.Parent = favBtn
        favIcon.BackgroundTransparency = 1; favIcon.AnchorPoint = Vector2.new(0.5,0.5)
        favIcon.Position = UDim2.new(0.5,0,0.5,0); favIcon.Size = UDim2.new(0,14,0,14)
        favIcon.Image = CONFIG.ICONS.STAR_OUTLINE; favIcon.ZIndex = 35
    end

    local keyBtn = Instance.new("TextButton"); keyBtn.Parent = row
    keyBtn.BackgroundColor3 = C.bg2
    keyBtn.BackgroundTransparency = 0.3; keyBtn.BorderSizePixel = 0
    keyBtn.Position = UDim2.new(1,-50,0,0)
    keyBtn.Size = UDim2.new(0,46,1,0); keyBtn.Font = Enum.Font.GothamBold
    keyBtn.Text = ""; keyBtn.TextColor3 = C.text3
    keyBtn.TextSize = 9; keyBtn.ZIndex = 34; keyBtn.AutoButtonColor = false
    local keyIcon
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,5); c.Parent = keyBtn
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.8; s.Thickness = 1; s.Parent = keyBtn
        keyIcon = Instance.new("ImageLabel"); keyIcon.Name = "Icon"; keyIcon.Parent = keyBtn
        keyIcon.BackgroundTransparency = 1; keyIcon.AnchorPoint = Vector2.new(0.5,0.5)
        keyIcon.Position = UDim2.new(0.5,0,0.5,0); keyIcon.Size = UDim2.new(0,14,0,14)
        keyIcon.Image = CONFIG.ICONS.KEYBOARD; keyIcon.ZIndex = 35
    end

    local widget = { row=row, playBtn=playBtn, favBtn=favBtn, keyBtn=keyBtn,
                     favIcon=favIcon, keyIcon=keyIcon, anim=anim }

    -- Apply initial visual state
    local function refresh()
        local isPlaying = State.selectedAnim == anim.name
        playBtn.Text = (isPlaying and "> " or "") .. displayName
        playBtn.BackgroundColor3 = isPlaying and Color3.fromRGB(255,255,255) or C.bg2
        playBtn.BackgroundTransparency = isPlaying and 0.2 or 0.5
        playBtn.TextColor3 = isPlaying and Color3.fromRGB(0,0,0) or C.text2

        local isFav = Favorites[anim.name] ~= nil
        if favIcon then favIcon.Image = isFav and CONFIG.ICONS.STAR_FILLED or CONFIG.ICONS.STAR_OUTLINE end
        favBtn.BackgroundColor3 = isFav and C.yellow or C.bg2
        favBtn.BackgroundTransparency = isFav and 0 or 0.3

        local bound = Keybinds[anim.name]
        if _G._HaloListenTarget and _G._HaloListenTarget.name == anim.name then
            _G._HaloListeningKeyBtn = keyBtn
            _G._HaloListenTarget.keyBtn = keyBtn
            keyBtn.Text = "[ ? ]"
            if keyIcon then keyIcon.Visible = false end
            keyBtn.BackgroundColor3 = Color3.fromRGB(220,120,20)
            keyBtn.BackgroundTransparency = 0.1
            keyBtn.TextColor3 = Color3.fromRGB(255,255,255)
        elseif bound then
            keyBtn.Text = "["..bound.key.Name.."]"
            if keyIcon then keyIcon.Visible = false end
            Keybinds[anim.name].btn = keyBtn
            keyBtn.BackgroundColor3 = C.bg3
            keyBtn.BackgroundTransparency = 0.1
            keyBtn.TextColor3 = C.accent
        else
            keyBtn.Text = ""
            if keyIcon then keyIcon.Visible = true; keyIcon.Image = CONFIG.ICONS.KEYBOARD end
            keyBtn.BackgroundColor3 = C.bg2
            keyBtn.BackgroundTransparency = 0.3
            keyBtn.TextColor3 = C.text3
        end
    end
    widget.refresh = refresh
    refresh()

    playBtn.MouseEnter:Connect(function()
        local isPlaying = State.selectedAnim == anim.name
        TweenService:Create(playBtn, TweenInfo.new(0.15), {
            BackgroundTransparency = isPlaying and 0.1 or 0.35,
            Size = UDim2.new(1,-78,1,2)
        }):Play()
    end)
    playBtn.MouseLeave:Connect(function()
        local isPlaying = State.selectedAnim == anim.name
        TweenService:Create(playBtn, TweenInfo.new(0.15), {
            BackgroundTransparency = isPlaying and 0.2 or 0.5,
            Size = UDim2.new(1,-82,1,0)
        }):Play()
    end)
    playBtn.MouseButton1Click:Connect(function()
        if anim.name and anim.url then
            PlayAnimation(anim.name, State.currentSpeed, anim.raw)
            task.defer(function() if RefreshVirtualRows then RefreshVirtualRows() end end)
        end
    end)

    favBtn.MouseButton1Click:Connect(function()
        if Favorites[anim.name] then
            Favorites[anim.name] = nil
            Notify("Removed from favourites", 1.5)
        else
            Favorites[anim.name] = true
            Notify("Added to favourites!", 1.5)
        end
        refresh()
        SaveFavoritesOnly()
        if State.currentTab == "Favs" then task.defer(RebuildVisible) end
    end)

    keyBtn.MouseButton1Click:Connect(function()
        if Keybinds[anim.name] and _G._HaloListeningKeyBtn ~= keyBtn then
            UnbindKey(anim.name, keyBtn)
            refresh()
            return
        end
        if _G._HaloListeningKeyBtn then CancelListening() end
        _G._HaloListeningKeyBtn = keyBtn
        _G._HaloListenTarget = { name=anim.name, url=anim.url, keyBtn=keyBtn }
        keyBtn.Text = "[ ? ]"; keyBtn.BackgroundColor3 = Color3.fromRGB(220,120,20)
        keyBtn.TextColor3 = Color3.fromRGB(255,255,255)
    end)

    return widget
end

-- BuildRowPool is no longer needed (rows are real, created by RebuildVisible).
function BuildRowPool() end

-- Windowed virtualization: only build rows for the slice of animations that are
-- actually visible in the scroll viewport (plus a small buffer), and rebuild
-- that slice as the user scrolls. This keeps the number of live UI Instances
-- tiny (~a dozen) no matter how many animations are imported, which is what
-- stops large AK imports from freezing / crashing the game.
local updatingVirtual = false
RefreshVirtualRows = function()
    if not AnimListFrame or updatingVirtual then return end
    updatingVirtual = true

    local winH = 320
    pcall(function()
        local aws = AnimListFrame.AbsoluteWindowSize
        if aws and aws.Y > 0 then
            winH = aws.Y
        else
            winH = AnimListFrame.AbsoluteSize.Y
        end
    end)
    if winH <= 0 then winH = 320 end
    local scrollY  = AnimListFrame.CanvasPosition.Y
    local visCount = math.ceil(winH / VROW_H) + 3  -- rows on screen + buffer
    local startIdx = math.max(1, math.floor((scrollY - VPAD) / VROW_H))  -- 1 row of top buffer
    local endIdx   = math.min(#visibleAnims, startIdx + visCount)

    if startIdx == _animWinStart then
        for _, w in ipairs(animRowWidgets) do
            if w and w.refresh and w.row and w.row.Parent then pcall(w.refresh) end
        end
        updatingVirtual = false
        return
    end
    _animWinStart = startIdx

    -- Rebuild the slice: destroy the old rows and create only the visible ones.
    _rebuildAnimVer = (_rebuildAnimVer or 0) + 1
    for _, c in ipairs(AnimListFrame:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    animRowWidgets = {}
    local wi = 1
    for i = startIdx, endIdx do
        local anim = visibleAnims[i]
        if anim then
            local yPos = VPAD + (i - 1) * VROW_H
            animRowWidgets[wi] = _createAnimRow(anim, yPos)
            wi = wi + 1
        end
    end

    task.spawn(function()
        pcall(function()
            AnimListFrame.CanvasPosition = Vector2.new(0, scrollY)
        end)
        task.wait()
        pcall(function()
            AnimListFrame.CanvasPosition = Vector2.new(0, scrollY)
        end)
        updatingVirtual = false
    end)
end

RebuildVisible = function()
    visibleAnims = {}
    local term = SearchBox.Text:lower()
    local tab  = State.currentTab

    if tab == "Custom" or tab == "Settings" or tab == "States" or tab == "Speed" or tab == "Testing" or tab == "Tracking" or tab == "Binds" or tab == "Copier" or tab == "Stretching" then
        AnimListFrame.Visible = false
        CustomPanel.Visible   = (tab == "Custom")
        StatesPanel.Visible   = (tab == "States")
        SettingsPanel.Visible = (tab == "Settings")
        SpeedPanel.Visible    = (tab == "Speed")
        TestingPanel.Visible  = (tab == "Testing" or tab == "Copier")
        LimbsPanel.Visible    = (tab == "Tracking")
        BindsPanel.Visible    = (tab == "Binds")
        StretchingPanel.Visible = (tab == "Stretching")
        return
    end

    AnimListFrame.Visible = true
    CustomPanel.Visible   = false
    StatesPanel.Visible   = false
    SettingsPanel.Visible = false
    SpeedPanel.Visible    = false

    local source = {}
    local seen = {}
    if tab == "All" then
        for name, url in pairs(AnimationList) do
            local cleanName = name:gsub("%.lua$", "")
            if not seen[cleanName] then
                seen[cleanName] = true
                table.insert(source, { name = cleanName, url = url, raw = false })
            end
        end
        for _, ca in ipairs(CustomAnims) do
            local customName = "[Custom] " .. ca.name
            if not seen[customName] then
                seen[customName] = true
                table.insert(source, { name = customName, url = ca.url, raw = ca.raw })
            end
        end
    elseif tab == "Favs" then
        for name, _ in pairs(Favorites) do
            local cleanName = name:gsub("%.lua$", "")
            local url = AnimationList[cleanName] or AnimationList[name]
            if url then
                if not seen[cleanName] then
                    seen[cleanName] = true
                    table.insert(source, { name = cleanName, url = url, raw = false })
                end
            else
                local plain = name:match("^%[Custom%] (.+)$") or name
                for _, ca in ipairs(CustomAnims) do
                    if ca.name == plain then
                        local customName = "[Custom] " .. ca.name
                        if not seen[customName] then
                            seen[customName] = true
                            table.insert(source, { name = customName, url = ca.url, raw = ca.raw })
                        end
                        break
                    end
                end
            end
        end
    end

    table.sort(source, function(a, b) return a.name < b.name end)

    for _, e in ipairs(source) do
        if term == "" or e.name:lower():find(term, 1, true) then
            table.insert(visibleAnims, e)
        end
    end

    -- Virtualized list: set the canvas to the full height, reset scroll, then
    -- let RefreshVirtualRows build only the rows visible in the viewport.
    local totalH = VPAD*2 + #visibleAnims * VROW_H
    AnimListFrame.CanvasSize = UDim2.new(0,0,0,totalH)
    AnimListFrame.CanvasPosition = Vector2.new(0,0)
    _animWinStart = -1  -- force a fresh window build
    RefreshVirtualRows()
end
_G._HaloRebuildVisible = RebuildVisible

SearchBox:GetPropertyChangedSignal("Text"):Connect(RebuildVisible)

-- Rebuild the visible row window whenever the list is scrolled.
AnimListFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(RefreshVirtualRows)

-- Build one custom-anim row and wire up its buttons.
-- Returns the widget table so the caller can store it.
local function _createCustomRow(ca, yPos)
    local row = Instance.new("Frame"); row.Parent = customListFrame
    row.BackgroundTransparency = 1; row.BorderSizePixel = 0
    row.Size = UDim2.new(1,-12,0,VROW_H-4); row.ZIndex = 34
    row.Position = UDim2.new(0,6,0,yPos or 0)

    local playBtn = Instance.new("TextButton"); playBtn.Parent = row
    playBtn.BackgroundColor3 = C.bg2
    playBtn.BackgroundTransparency = 0.5; playBtn.BorderSizePixel = 0
    playBtn.Size = UDim2.new(1,-114,1,0)
    playBtn.Font = Enum.Font.GothamMedium; playBtn.Text = ca.name:gsub("%.lua$","")
    playBtn.TextColor3 = C.text2; playBtn.TextSize = 11
    playBtn.TextXAlignment = Enum.TextXAlignment.Left
    playBtn.TextTruncate = Enum.TextTruncate.AtEnd
    playBtn.ZIndex = 35; playBtn.AutoButtonColor = false
    do
        local c2 = Instance.new("UICorner"); c2.CornerRadius = UDim.new(0,8); c2.Parent = playBtn
        local p  = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0,10); p.Parent = playBtn
        local s2 = Instance.new("UIStroke"); s2.Color = C.border; s2.Transparency = 0.8; s2.Thickness = 1; s2.Parent = playBtn
    end

    local favBtn = Instance.new("TextButton"); favBtn.Parent = row
    favBtn.BackgroundColor3 = C.bg2; favBtn.BackgroundTransparency = 0.3
    favBtn.BorderSizePixel = 0; favBtn.Position = UDim2.new(1,-110,0,0)
    favBtn.Size = UDim2.new(0,26,1,0); favBtn.Font = Enum.Font.GothamBold
    favBtn.Text = ""; favBtn.ZIndex = 35; favBtn.AutoButtonColor = false
    do
        local c2 = Instance.new("UICorner"); c2.CornerRadius = UDim.new(0,5); c2.Parent = favBtn
        local ico = Instance.new("ImageLabel"); ico.Name = "Icon"; ico.Parent = favBtn
        ico.BackgroundTransparency = 1; ico.AnchorPoint = Vector2.new(0.5,0.5)
        ico.Position = UDim2.new(0.5,0,0.5,0); ico.Size = UDim2.new(0,14,0,14)
        ico.Image = CONFIG.ICONS.STAR_OUTLINE; ico.ZIndex = 36
    end

    local keyBtn = Instance.new("TextButton"); keyBtn.Parent = row
    keyBtn.BackgroundColor3 = C.bg2; keyBtn.BackgroundTransparency = 0.2
    keyBtn.BorderSizePixel = 0; keyBtn.Position = UDim2.new(1,-80,0,0)
    keyBtn.Size = UDim2.new(0,46,1,0); keyBtn.Font = Enum.Font.GothamBold
    keyBtn.Text = ""; keyBtn.TextColor3 = C.text3
    keyBtn.TextSize = 9; keyBtn.ZIndex = 35; keyBtn.AutoButtonColor = false
    do
        local c2 = Instance.new("UICorner"); c2.CornerRadius = UDim.new(0,5); c2.Parent = keyBtn
        local ico = Instance.new("ImageLabel"); ico.Name = "Icon"; ico.Parent = keyBtn
        ico.BackgroundTransparency = 1; ico.AnchorPoint = Vector2.new(0.5,0.5)
        ico.Position = UDim2.new(0.5,0,0.5,0); ico.Size = UDim2.new(0,14,0,14)
        ico.Image = CONFIG.ICONS.KEYBOARD; ico.ZIndex = 36
    end

    local delBtn = Instance.new("TextButton"); delBtn.Parent = row
    delBtn.BackgroundColor3 = Color3.fromRGB(200,70,70); delBtn.BackgroundTransparency = 0.3
    delBtn.BorderSizePixel = 0; delBtn.Position = UDim2.new(1,-30,0,0)
    delBtn.Size = UDim2.new(0,26,1,0); delBtn.Text = ""
    delBtn.ZIndex = 35; delBtn.AutoButtonColor = false
    do
        local c2 = Instance.new("UICorner"); c2.CornerRadius = UDim.new(0,5); c2.Parent = delBtn
        local ico = Instance.new("ImageLabel"); ico.Parent = delBtn
        ico.BackgroundTransparency = 1; ico.AnchorPoint = Vector2.new(0.5,0.5)
        ico.Position = UDim2.new(0.5,0,0.5,0); ico.Size = UDim2.new(0,12,0,12)
        ico.Image = "rbxassetid://6031094678"
        ico.ImageColor3 = Color3.fromRGB(255,255,255); ico.ZIndex = 36
    end

    -- Hover / press visuals
    playBtn.MouseEnter:Connect(function()
        if State.selectedAnim ~= ca.name then
            TweenService:Create(playBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.35, Size = UDim2.new(1,-110,1,2)}):Play()
        end
    end)
    playBtn.MouseLeave:Connect(function()
        TweenService:Create(playBtn, TweenInfo.new(0.15), {
            BackgroundTransparency = (State.selectedAnim == ca.name) and 0.2 or 0.5,
            Size = UDim2.new(1,-114,1,0)
        }):Play()
    end)
    playBtn.MouseButton1Down:Connect(function()
        TweenService:Create(playBtn, TweenInfo.new(0.08), {BackgroundTransparency = 0.25}):Play()
    end)
    delBtn.MouseEnter:Connect(function()
        TweenService:Create(delBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
    end)
    delBtn.MouseLeave:Connect(function()
        TweenService:Create(delBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0.3}):Play()
    end)

    -- Widget table (caIdx is mutable via upvalue trick — use a holder table)
    local w = { playBtn=playBtn, favBtn=favBtn, keyBtn=keyBtn, delBtn=delBtn,
                name=ca.name, row=row }

    playBtn.MouseButton1Click:Connect(function()
        PlayAnimation(ca.name, State.currentSpeed, true)
        task.defer(function() if RefreshCustomRows then RefreshCustomRows() end end)
    end)

    favBtn.MouseButton1Click:Connect(function()
        local favKey = "[Custom] " .. ca.name
        local favIcon = favBtn:FindFirstChild("Icon")
        if Favorites[favKey] then
            Favorites[favKey] = nil
            TweenService:Create(favBtn, TweenInfo.new(0.15), {
                BackgroundColor3 = C.bg2, BackgroundTransparency = 0.3 }):Play()
            if favIcon then favIcon.Image = CONFIG.ICONS.STAR_OUTLINE end
            Notify("Removed from favourites", 1.5)
        else
            Favorites[favKey] = true
            TweenService:Create(favBtn, TweenInfo.new(0.15), {
                BackgroundColor3 = C.yellow, BackgroundTransparency = 0 }):Play()
            if favIcon then favIcon.Image = CONFIG.ICONS.STAR_FILLED end
            Notify("Added to favourites!", 1.5)
        end
        SaveFavoritesOnly()
        if State.currentTab == "Favs" then task.defer(RebuildVisible) end
    end)

    keyBtn.MouseButton1Click:Connect(function()
        local ckName = "[Custom] " .. ca.name
        local keyIcon = keyBtn:FindFirstChild("Icon")
        if Keybinds[ckName] and _G._HaloListeningKeyBtn ~= keyBtn then
            UnbindKey(ckName, keyBtn)
            local bound = Keybinds[ckName]
            if bound then
                keyBtn.Text = "["..bound.key.Name.."]"
                if keyIcon then keyIcon.Visible = false end
            else
                keyBtn.Text = ""
                if keyIcon then keyIcon.Visible = true; keyIcon.Image = CONFIG.ICONS.KEYBOARD end
            end
            keyBtn.BackgroundColor3 = bound and C.bg3 or C.bg2
            keyBtn.TextColor3 = bound and C.accent or C.text3
            return
        end
        if _G._HaloListeningKeyBtn then CancelListening() end
        _G._HaloListeningKeyBtn = keyBtn
        _G._HaloListenTarget = { name = ckName, url = ca.url, keyBtn = keyBtn }
        keyBtn.Text = "[ ? ]"; keyBtn.BackgroundColor3 = Color3.fromRGB(220,120,20)
        keyBtn.TextColor3 = Color3.fromRGB(255,255,255)
        if keyIcon then keyIcon.Visible = false end
    end)

    delBtn.MouseButton1Click:Connect(function()
        -- Find current index of this anim in case the list shifted
        local currentIdx = nil
        for i, v in ipairs(CustomAnims) do
            if v.name == ca.name then currentIdx = i; break end
        end
        if not currentIdx then 
            return 
        end
        if State.selectedAnim == ca.name then StopAnimation() end
        local animName = ca.name
        
        -- Delete the actual file(s) from disk
        local animEntry = CustomAnims[currentIdx]
        if animEntry then
            local content = animEntry.url or animEntry.file
            local deleteFunc = delfile or deletefile or function() end
            
            if type(content) == "string" then
                pcall(function() deleteFunc(content) end)
                
                -- Also try variations of the filename
                local baseName = animName:gsub("%.lua$", ""):gsub("%.json$", "")
                local possiblePaths = {
                    content,
                    fpath("custom_" .. baseName .. ".dat"),
                    fpath(baseName .. ".lua"),
                    fpath(baseName .. ".json"),
                    "ReanimData/" .. baseName .. ".lua",
                    "ReanimData/" .. baseName .. ".json",
                    "ReanimData/" .. animName,
                }
                
                for _, path in ipairs(possiblePaths) do
                    pcall(function() deleteFunc(path) end)
                end
            end
        end
        
        table.remove(CustomAnims, currentIdx)
        CustomAnimations[animName] = nil
        
        SaveCustomAnims()
        SaveData()
        
        if UpdateCustomTabCount then
            UpdateCustomTabCount()
        end
        
        if RebuildCustomList then RebuildCustomList() end
        
        Notify("Deleted: " .. animName, 2)
    end)

    -- Apply / refresh visual state (also used by RefreshCustomRows on scroll).
    local function refresh()
        local isFav = Favorites["[Custom] " .. ca.name] ~= nil
        local favIcon = favBtn:FindFirstChild("Icon")
        if favIcon then
            favIcon.Image = isFav and CONFIG.ICONS.STAR_FILLED or CONFIG.ICONS.STAR_OUTLINE
        end
        favBtn.BackgroundColor3 = isFav and C.yellow or C.bg2
        favBtn.BackgroundTransparency = isFav and 0 or 0.3
        favBtn.TextColor3 = isFav and Color3.fromRGB(0,0,0) or C.yellow

        local ckName = "[Custom] " .. ca.name
        local bound = Keybinds[ckName]
        local keyIcon = keyBtn:FindFirstChild("Icon")
        if _G._HaloListenTarget and _G._HaloListenTarget.name == ckName then
            _G._HaloListeningKeyBtn = keyBtn
            _G._HaloListenTarget.keyBtn = keyBtn
            keyBtn.Text = "[ ? ]"
            if keyIcon then keyIcon.Visible = false end
            keyBtn.BackgroundColor3 = Color3.fromRGB(220,120,20)
            keyBtn.TextColor3 = Color3.fromRGB(255,255,255)
        elseif bound then
            keyBtn.Text = "["..bound.key.Name.."]"
            if keyIcon then keyIcon.Visible = false end
            Keybinds[ckName].btn = keyBtn
            keyBtn.BackgroundColor3 = C.bg3
            keyBtn.TextColor3 = C.accent
        else
            keyBtn.Text = ""
            if keyIcon then keyIcon.Visible = true; keyIcon.Image = CONFIG.ICONS.KEYBOARD end
            keyBtn.BackgroundColor3 = C.bg2
            keyBtn.TextColor3 = C.text3
        end

        local isPlaying = State.selectedAnim == ca.name
        playBtn.Text = (isPlaying and "> " or "") .. ca.name
        playBtn.BackgroundTransparency = isPlaying and 0.2 or 0.93
        playBtn.TextColor3 = isPlaying and Color3.fromRGB(0,0,0) or Color3.fromRGB(215,215,235)
    end
    w.refresh = refresh
    refresh()

    return w
end

-- Full rebuild: filter + sort the custom animations into the visible list, set
-- the canvas height, then let RefreshCustomRows build only the rows currently
-- on screen. Virtualized, so it never freezes regardless of how many exist.
function RebuildCustomList()
    _G._ReanimRebuildCustomList = RebuildCustomList
    local searchTerm = customSearchBox.Text:lower()
    visibleCustom = {}
    for _, ca in ipairs(CustomAnims) do
        local lower = ca.name:lower()
        local isNonAnim = lower:find("^reanim") or lower:find("stretcher") or lower:find("limbs") or lower:find("teleport") or lower:find("pointer") or lower:find("tracker") or lower:find("key") or lower:find("setting") or lower:find("config")
        if not isNonAnim then
            local displayName = ca.name:gsub("%.lua$","")
            if searchTerm == "" or displayName:lower():find(searchTerm, 1, true) then
                table.insert(visibleCustom, ca)
            end
        end
    end
    table.sort(visibleCustom, function(a, b) return a.name:lower() < b.name:lower() end)

    local totalH = VPAD*2 + #visibleCustom * VROW_H
    customListFrame.CanvasSize = UDim2.new(0,0,0,totalH)
    customListFrame.CanvasPosition = Vector2.new(0,0)
    _customWinStart = -1  -- force a fresh window build
    RefreshCustomRows()
end

-- Fast path after a single add: the list is virtualized now, so a full rebuild
-- is cheap (it only ever creates the visible rows).
function AppendCustomRow(ca)
    RebuildCustomList()
end

local _rebuildCustomDebounce = nil
customSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    if _rebuildCustomDebounce then task.cancel(_rebuildCustomDebounce) end
    _rebuildCustomDebounce = task.delay(0.15, function()
        _rebuildCustomDebounce = nil
        RebuildCustomList()
    end)
end)

-- Windowed virtualization for the custom list: only build rows for the slice
-- visible in the viewport, rebuilding as the user scrolls. Keeps the live
-- instance count tiny no matter how many custom animations exist.
local updatingCustom = false
RefreshCustomRows = function()
    if not customListFrame or updatingCustom then return end
    updatingCustom = true

    local winH = 320
    pcall(function()
        local aws = customListFrame.AbsoluteWindowSize
        if aws and aws.Y > 0 then
            winH = aws.Y
        else
            winH = customListFrame.AbsoluteSize.Y
        end
    end)
    if winH <= 0 then winH = 320 end
    local scrollY  = customListFrame.CanvasPosition.Y
    local visCount = math.ceil(winH / VROW_H) + 3
    local startIdx = math.max(1, math.floor((scrollY - VPAD) / VROW_H))
    local endIdx   = math.min(#visibleCustom, startIdx + visCount)

    -- Window unchanged: just refresh the visuals of the existing rows.
    if startIdx == _customWinStart then
        for _, w in ipairs(customRowWidgets) do
            if w and w.refresh and w.row and w.row.Parent then pcall(w.refresh) end
        end
        updatingCustom = false
        return
    end
    _customWinStart = startIdx

    for _, c in ipairs(customListFrame:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    customRowWidgets = {}
    local wi = 1
    for i = startIdx, endIdx do
        local ca = visibleCustom[i]
        if ca then
            local yPos = VPAD + (i - 1) * VROW_H
            customRowWidgets[wi] = _createCustomRow(ca, yPos)
            wi = wi + 1
        end
    end

    task.spawn(function()
        pcall(function()
            customListFrame.CanvasPosition = Vector2.new(0, scrollY)
        end)
        task.wait()
        pcall(function()
            customListFrame.CanvasPosition = Vector2.new(0, scrollY)
        end)
        updatingCustom = false
    end)
end

-- Rebuild the visible window whenever the custom list is scrolled.
customListFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
    if RefreshCustomRows then RefreshCustomRows() end
end)

-- RebuildBindsList: shows all animations with keybinds set
function RebuildBindsList()
    -- Clear existing rows
    for _, child in ipairs(BindsPanel:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    -- Add header with instructions
    local headerLabel = Instance.new("TextLabel")
    headerLabel.Name = "HeaderLabel"
    headerLabel.Parent = BindsPanel
    headerLabel.BackgroundTransparency = 1
    headerLabel.Size = UDim2.new(1, -10, 0, 20)
    headerLabel.Position = UDim2.new(0, 5, 0, 8)
    headerLabel.Font = Enum.Font.GothamMedium
    headerLabel.Text = "Click key button to rebind  |  Click Unbind to remove"
    headerLabel.TextColor3 = C.text3
    headerLabel.TextSize = 10
    headerLabel.TextXAlignment = Enum.TextXAlignment.Left
    headerLabel.ZIndex = 33
    
    -- Collect all animations with keybinds
    local boundAnims = {}
    for name, data in pairs(Keybinds) do
        if data and data.key then
            local displayName = name:gsub("^%[Custom%] ", ""):gsub("%.lua$", "")
            local isCustom = name:find("^%[Custom%]") ~= nil
            local url = nil
            
            if isCustom then
                -- Find the URL from CustomAnimations
                for _, ca in ipairs(CustomAnims) do
                    if "[Custom] " .. ca.name == name then
                        url = ca.url
                        break
                    end
                end
            else
                -- Find the URL from AnimationList
                url = AnimationList[name]
            end
            
            if url then
                table.insert(boundAnims, {
                    name = name,
                    displayName = displayName,
                    keyName = data.key.Name,
                    isCustom = isCustom,
                    url = url
                })
            end
        end
    end
    
    -- Sort alphabetically
    table.sort(boundAnims, function(a, b)
        return a.displayName:lower() < b.displayName:lower()
    end)
    
    -- Create rows for each bound animation
    local yPos = 34
    for _, anim in ipairs(boundAnims) do
        local row = Instance.new("Frame")
        row.Name = "BindRow"
        row.Parent = BindsPanel
        row.BackgroundTransparency = 1
        row.Size = UDim2.new(1, -10, 0, 30)
        row.Position = UDim2.new(0, 5, 0, yPos)
        row.ZIndex = 33
        
        -- Play button
        local playBtn = Instance.new("TextButton")
        playBtn.Parent = row
        playBtn.BackgroundColor3 = C.bg2
        playBtn.BackgroundTransparency = 0.5
        playBtn.BorderSizePixel = 0
        playBtn.Size = UDim2.new(1, -120, 1, 0)
        playBtn.Font = Enum.Font.GothamMedium
        playBtn.Text = anim.displayName
        playBtn.TextColor3 = C.text2
        playBtn.TextSize = 11
        playBtn.TextXAlignment = Enum.TextXAlignment.Left
        playBtn.TextTruncate = Enum.TextTruncate.AtEnd
        playBtn.ZIndex = 34
        playBtn.AutoButtonColor = false
        do
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 5)
            c.Parent = playBtn
            local p = Instance.new("UIPadding")
            p.PaddingLeft = UDim.new(0, 8)
            p.Parent = playBtn
            local s = Instance.new("UIStroke")
            s.Color = C.border
            s.Transparency = 0.8
            s.Thickness = 1
            s.Parent = playBtn
        end
        
        -- Key display button (click to rebind)
        local keyBtn = Instance.new("TextButton")
        keyBtn.Parent = row
        keyBtn.BackgroundColor3 = C.bg3
        keyBtn.BackgroundTransparency = 0
        keyBtn.BorderSizePixel = 0
        keyBtn.Position = UDim2.new(1, -114, 0, 0)
        keyBtn.Size = UDim2.new(0, 56, 1, 0)
        keyBtn.Font = Enum.Font.GothamBold
        keyBtn.Text = "[" .. anim.keyName .. "]"
        keyBtn.TextColor3 = C.accent
        keyBtn.TextSize = 10
        keyBtn.ZIndex = 34
        keyBtn.AutoButtonColor = false
        do
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 5)
            c.Parent = keyBtn
            local s = Instance.new("UIStroke")
            s.Color = C.border
            s.Transparency = 0.8
            s.Thickness = 1
            s.Parent = keyBtn
        end
        
        -- Hover effect for key button
        keyBtn.MouseEnter:Connect(function()
            if _G._HaloListeningKeyBtn ~= keyBtn then
                TweenService:Create(keyBtn, TweenInfo.new(0.1), {
                    BackgroundColor3 = C.accent, TextColor3 = Color3.fromRGB(10,10,10)
                }):Play()
            end
        end)
        keyBtn.MouseLeave:Connect(function()
            if _G._HaloListeningKeyBtn ~= keyBtn then
                TweenService:Create(keyBtn, TweenInfo.new(0.1), {
                    BackgroundColor3 = C.bg3, TextColor3 = C.accent
                }):Play()
            end
        end)
        
        -- Unbind button
        local unbindBtn = Instance.new("TextButton")
        unbindBtn.Parent = row
        unbindBtn.BackgroundColor3 = C.red
        unbindBtn.BackgroundTransparency = 0.3
        unbindBtn.BorderSizePixel = 0
        unbindBtn.Position = UDim2.new(1, -54, 0, 0)
        unbindBtn.Size = UDim2.new(0, 48, 1, 0)
        unbindBtn.Font = Enum.Font.GothamBold
        unbindBtn.Text = "Unbind"
        unbindBtn.TextColor3 = C.white
        unbindBtn.TextSize = 9
        unbindBtn.ZIndex = 34
        unbindBtn.AutoButtonColor = false
        do
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 5)
            c.Parent = unbindBtn
        end
        
        -- Hover effects
        playBtn.MouseEnter:Connect(function()
            TweenService:Create(playBtn, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.2, TextColor3 = C.text
            }):Play()
        end)
        playBtn.MouseLeave:Connect(function()
            TweenService:Create(playBtn, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.5, TextColor3 = C.text2
            }):Play()
        end)
        
        unbindBtn.MouseEnter:Connect(function()
            TweenService:Create(unbindBtn, TweenInfo.new(0.1), {
                BackgroundTransparency = 0
            }):Play()
        end)
        unbindBtn.MouseLeave:Connect(function()
            TweenService:Create(unbindBtn, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.3
            }):Play()
        end)
        
        -- Click handlers
        playBtn.MouseButton1Click:Connect(function()
            PlayAnimation(anim.name:gsub("^%[Custom%] ", ""), State.currentSpeed, anim.isCustom)
        end)
        
        keyBtn.MouseButton1Click:Connect(function()
            -- Start listening for new key
            if _G._HaloListeningKeyBtn then CancelListening() end
            _G._HaloListeningKeyBtn = keyBtn
            _G._HaloListenTarget = { name = anim.name, url = anim.url, keyBtn = keyBtn }
            keyBtn.Text = "[ ? ]"
            keyBtn.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
            keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
        
        unbindBtn.MouseButton1Click:Connect(function()
            Keybinds[anim.name] = nil
            SaveData()
            Notify("Unbound: " .. anim.displayName, 2)
            RebuildBindsList()
        end)
        
        yPos = yPos + 34
    end
    
    -- Update canvas size
    BindsPanel.CanvasSize = UDim2.new(0, 0, 0, yPos + 8)
    
    -- Show message if no keybinds are set
    if #boundAnims == 0 then
        local noBindsLabel = Instance.new("TextLabel")
        noBindsLabel.Name = "NoBindsLabel"
        noBindsLabel.Parent = BindsPanel
        noBindsLabel.BackgroundTransparency = 1
        noBindsLabel.Size = UDim2.new(1, -20, 0, 80)
        noBindsLabel.Position = UDim2.new(0, 10, 0, 40)
        noBindsLabel.Font = Enum.Font.GothamMedium
        noBindsLabel.Text = "No keybinds set yet\n\nGo to the All or Custom tab\nand click [+] to bind keys to animations"
        noBindsLabel.TextColor3 = C.text3
        noBindsLabel.TextSize = 12
        noBindsLabel.TextWrapped = true
        noBindsLabel.ZIndex = 33
        
        BindsPanel.CanvasSize = UDim2.new(0, 0, 0, 140)
    end
end

local STATE_TYPES = { "Idle", "Walk", "Run", "Jump", "Fall", "Climb", "SwimIdle", "Swim" }

local currentStateAnim = nil
local stateWatchConn   = nil
local stateHumConn     = nil
-- True while we've handed control back to the clone's default Animate script
-- because the current logical state has no custom animation assigned (e.g. you
-- jump but only set Idle/Run). Lets default jump/fall/etc. play instead of
-- freezing the previous custom animation.
local _stateFallbackActive = false

local getLogicalState = LPH_NO_VIRTUALIZE(function(hum)
    local hs = hum:GetState()
    -- The Jumping state is only active for the first instant of a jump, before
    -- upward velocity has been applied — so map it straight to "Jump" instead of
    -- letting the near-zero velocity fall through to Idle/Walk (which made jump
    -- animations never trigger).
    if hs == Enum.HumanoidStateType.Jumping then
        return "Jump"
    elseif hs == Enum.HumanoidStateType.Freefall then
        -- While airborne we are EITHER rising (jump) or descending/at-apex (fall).
        -- Never return a ground state here: the old "near-zero velocity" branch
        -- reported Idle at the apex of every jump, which made jumping look like it
        -- was playing the idle animation. Landing is handled when the humanoid
        -- leaves the Freefall state (the else branch below).
        local hrp = hum.RootPart
        if hrp and hrp.AssemblyLinearVelocity.Y > 0.1 then
            return "Jump"
        end
        return "Fall"
    elseif hs == Enum.HumanoidStateType.Climbing then
        return "Climb"
    elseif hs == Enum.HumanoidStateType.Swimming then
        local speed = hum.WalkSpeed > 0 and hum.MoveDirection.Magnitude > 0.1
        return speed and "Swim" or "SwimIdle"
    else
        -- Use horizontal velocity magnitude rather than MoveDirection so brief
        -- directional pauses (where MoveDirection momentarily zeros) don't
        -- register as Idle and flash the idle animation mid-movement.
        local hrp = hum.RootPart
        local horizSpeed = 0
        if hrp then
            local vel = hrp.AssemblyLinearVelocity
            horizSpeed = Vector2.new(vel.X, vel.Z).Magnitude
        end
        if horizSpeed > 14 then return "Run"
        elseif horizSpeed > 1.5 then return "Walk"
        else return "Idle" end
    end
end)

local stateScriptCache = {}

prefetchStateAnim = function(stKey)
    local entry = StateAnims[stKey]
    if not entry then return end
    local url = type(entry) == "table" and entry.url or entry
    if not url or url == "" then return end
    if stateScriptCache[url] then return end
    
    local isHttp = url:match("^https?://")
    local isLocalFile = not isHttp and isfile and readfile and isfile(url)
    
    task.spawn(function()
        local src = ""
        if isHttp then
            local ok, content = pcall(function() return game:HttpGet(url, true) end)
            if not ok or type(content) ~= "string" or #content == 0 then return end
            src = content
        elseif isLocalFile then
            local ok, content = pcall(readfile, url)
            if not ok or not content or content == "" then return end
            src = content
        else
            src = url
        end
        
        src = src:gsub("^\xEF\xBB\xBF", ""):gsub("\r\n", "\n"):gsub("\r", "\n")
        
        -- Try JSON parsing first
        local firstChar = src:match("^%s*(.)")
        if firstChar == "{" or firstChar == "[" then
            local parsed = parseJsonAnimation(src)
            if parsed then
                stateScriptCache[url] = { src = src, data = parsed }
                return
            end
        end
        local fn = loadstring(src)
        if not fn then return end
        local ok2, data = pcall(fn)
        if not ok2 or type(data) ~= "table" then return end
        stateScriptCache[url] = { src = src, data = data }
    end)
end

prefetchAllStates = function()
    for _, stKey in ipairs(STATE_TYPES) do
        prefetchStateAnim(stKey)
    end
end

local STATE_SPEED_MULT = 1.0
local stateLoading = {}

-- Hand control to (true) or take it back from (false) the clone's default
-- Animate script for un-assigned states. Idempotent so we only toggle on change.
local function _setStateFallback(active)
    if active == _stateFallbackActive then return end
    _stateFallbackActive = active
    if active then
        -- Stop the lingering custom animation so the default Animate (jump/fall
        -- /etc.) is what's visible, then re-enable the default Animate script.
        currentStateAnim = nil
        pcall(function() ReanimateAPI.stop_animation_for_transition() end)
        if _applyReanimDefaultAnimate then _applyReanimDefaultAnimate(true) end
    else
        -- Returning to a custom state: turn the default Animate back off so it
        -- doesn't fight the constraint-driven custom animation.
        if _applyReanimDefaultAnimate then _applyReanimDefaultAnimate(false) end
    end
end

function playStateAnim(stKey)
    local entry = StateAnims[stKey]
    local url   = type(entry) == "table" and entry.url or entry
    local raw   = type(entry) == "table" and entry.raw or false
    if not entry or not url or url == "" then
        -- No custom animation assigned for this state (e.g. you jump but only set
        -- Idle/Run). Fall back to the clone's default Animate so the correct
        -- default jump/fall/etc. plays instead of freezing the previous anim.
        _setStateFallback(true)
        return
    end
    -- A custom animation exists for this state: make sure the default Animate
    -- fallback is disabled before we drive the custom animation ourselves.
    _setStateFallback(false)
    if currentStateAnim == stKey then return end
    pcall(function() ReanimateAPI.stop_animation_for_transition() end)
    currentStateAnim = stKey
    local cachedEntry = stateScriptCache[url]
    
    local isHttp = url:match("^https?://")
    local isLocalFile = not isHttp and isfile and readfile and isfile(url)
    
    if isHttp or raw or isLocalFile then
        if not cachedEntry then
            if stateLoading[url] then return end
            stateLoading[url] = true
            task.spawn(function()
                local src = ""
                if isHttp then
                    local ok, content = pcall(function() return game:HttpGet(url, true) end)
                    if not ok or type(content) ~= "string" or #content == 0 then
                        warn("[StateAnim] HTTP fetch failed for", stKey, ":", content)
                        stateLoading[url] = nil
                        if currentStateAnim == stKey then currentStateAnim = nil end
                        return
                    end
                    src = content
                elseif isLocalFile then
                    local ok, content = pcall(readfile, url)
                    if not ok or not content or content == "" then
                        warn("[StateAnim] File read failed for", stKey, ":", url)
                        stateLoading[url] = nil
                        if currentStateAnim == stKey then currentStateAnim = nil end
                        return
                    end
                    src = content
                else
                    src = url
                end
                
                src = src:gsub("^\xEF\xBB\xBF", ""):gsub("\r\n", "\n"):gsub("\r", "\n")
                
                local data
                local parseMethod = "none"
                -- Try JSON parsing first
                local firstChar = src:match("^%s*(.)")
                warn("[StateAnim] Loading", stKey, "- first char:", firstChar, "- length:", #src)
                
                if firstChar == "{" or firstChar == "[" then
                    parseMethod = "json"
                    warn("[StateAnim] Attempting JSON parse for", stKey)
                    local parsed = parseJsonAnimation(src)
                    if parsed and #parsed > 0 then 
                        data = parsed
                        warn("[StateAnim] JSON parsed successfully for", stKey, "- frames:", #data)
                        -- Log first frame structure
                        if data[1] then
                            local boneCount = 0
                            for _ in pairs(data[1].Data or {}) do boneCount = boneCount + 1 end
                            warn("[StateAnim] First frame - Time:", data[1].Time, "- Bones:", boneCount)
                        end
                    else
                        warn("[StateAnim] JSON parsing returned nil or empty for", stKey)
                    end
                end
                
                if not data then
                    parseMethod = "lua"
                    local fn = loadstring(src)
                    if not fn then
                        warn("[StateAnim] loadstring failed for", stKey)
                        stateLoading[url] = nil
                        if currentStateAnim == stKey then currentStateAnim = nil end
                        return
                    end
                    local ok2, luaData = pcall(fn)
                    if not ok2 or type(luaData) ~= "table" then
                        warn("[StateAnim] Lua execution failed for", stKey, ":", luaData)
                        stateLoading[url] = nil
                        if currentStateAnim == stKey then currentStateAnim = nil end
                        return
                    end
                    
                    -- If luaData is already keyframes array, use it directly
                    if type(luaData[1]) == "table" and luaData[1].Time and luaData[1].Data then
                        data = luaData
                        warn("[StateAnim] Lua data is already keyframes format for", stKey)
                    else
                        -- Parse as table animation
                        data = parseTableAnimation(luaData)
                        if not data then
                            warn("[StateAnim] parseTableAnimation failed for", stKey)
                        end
                    end
                end
                
                if not data or #data == 0 then
                    warn("[StateAnim] No valid animation data for", stKey, "- method:", parseMethod)
                    stateLoading[url] = nil
                    if currentStateAnim == stKey then currentStateAnim = nil end
                    return
                end
                
                cachedEntry = { src = src, data = data }
                stateScriptCache[url] = cachedEntry
                stateLoading[url] = nil
                
                warn("[StateAnim] Successfully loaded", stKey, "with", #data, "frames via", parseMethod)
                
                -- Check if we are still matching the requested state
                if currentStateAnim == stKey then
                    if ReanimateAPI.play_keyframes and data then
                        pcall(function()
                            ReanimateAPI.play_keyframes(data, State.currentSpeed * STATE_SPEED_MULT)
                        end)
                    else
                        pcall(function()
                            ReanimateAPI.play_raw_animation(url, src, State.currentSpeed * STATE_SPEED_MULT)
                        end)
                    end
                end
            end)
        else
            if ReanimateAPI.play_keyframes and cachedEntry.data then
                pcall(function()
                    ReanimateAPI.play_keyframes(cachedEntry.data, State.currentSpeed * STATE_SPEED_MULT)
                end)
            else
                pcall(function()
                    ReanimateAPI.play_raw_animation(url, cachedEntry.src, State.currentSpeed * STATE_SPEED_MULT)
                end)
            end
        end
    else
        pcall(function()
            ReanimateAPI.play_animation(url, State.currentSpeed * STATE_SPEED_MULT)
        end)
    end
end

stopStateSystem = function()
    if stateWatchConn then stateWatchConn:Disconnect(); stateWatchConn = nil end
    if stateHumConn   then stateHumConn:Disconnect();   stateHumConn   = nil end
    stateSystemActive = false
    currentStateAnim  = nil
    _stateFallbackActive = false
    pcall(function() ReanimateAPI.stop_animation() end)
end

-- Enable/disable the reanimated clone's default Roblox Animate script.
-- When enabled, the clone plays the player's equipped animation pack
-- (idle/walk/run/jump/etc.) exactly like a normal character. We use this as the
-- fallback when the user has NO custom state animations set.
local function _setCloneDefaultAnimate(enabled)
    if not ReanimateAPI or not ReanimateAPI.get_clone then return end
    local clone = ReanimateAPI.get_clone(plr)
    if not clone then return end
    pcall(function()
        local animate = clone:FindFirstChild("Animate")
        if animate then animate.Disabled = (enabled == false) end
    end)
end
-- Expose so the enable flow / CharacterAdded handler can reach it.
_applyReanimDefaultAnimate = _setCloneDefaultAnimate

-- When suspended, ALL reanimation-driven animation is stopped and prevented from
-- restarting (used by Face Bang so the clone holds still instead of animating).
local _reanimAnimsSuspended = false

startStateSystem = function()
    if stateSystemActive then stopStateSystem() end
    if _reanimAnimsSuspended then return end
    local char = plr.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if not next(StateAnims) then return end

    -- Custom states take over: turn OFF the default Animate so it doesn't fight
    -- the constraint-driven state animations.
    _setCloneDefaultAnimate(false)

    stateSystemActive = true
    _stateFallbackActive = false
    local lastLogical = nil

    stateWatchConn = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
        if not State.isReanimated then stopStateSystem(); return end
        -- FPS optimization: throttle state checks to 20Hz instead of every frame
        _stateCheckThrottle = (_stateCheckThrottle or 0) + 1
        if _stateCheckThrottle % 2 ~= 0 then return end
        if State.selectedAnim then
            if currentStateAnim then currentStateAnim = nil end
            -- A manually selected animation takes priority — make sure the
            -- default-Animate fallback isn't left on fighting it.
            _setStateFallback(false)
            lastLogical = nil
            return
        end
        local logical = getLogicalState(hum)
        if logical ~= lastLogical then
            lastLogical = logical
            playStateAnim(logical)
        end
    end))
end

plr.CharacterAdded:Connect(function(character)
    stopStateSystem()
    currentStateAnim = nil
    character:WaitForChild("HumanoidRootPart", 10)
    task.wait(0.5)
    if State.isReanimated and not _reanimAnimsSuspended then
        if next(StateAnims) then
            startStateSystem()
        else
            -- No custom states: play the player's default Roblox animations.
            _setCloneDefaultAnimate(true)
        end
    end
end)

-- Stop EVERY reanimation animation (state system, any playing clip, and the
-- clone's default Animate) and keep them stopped until resumed. Used by Face Bang.
_G._HaloStopReanimAnims = function()
    _reanimAnimsSuspended = true
    pcall(stopStateSystem)
    pcall(function() ReanimateAPI.stop_animation() end)
    _setCloneDefaultAnimate(false)
    -- Also stop any tracks playing on the clone's own Animator
    pcall(function()
        local clone = ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
        if clone then
            local h  = clone:FindFirstChildOfClass("Humanoid")
            local an = h and h:FindFirstChildOfClass("Animator")
            if an then
                for _, t in ipairs(an:GetPlayingAnimationTracks()) do pcall(function() t:Stop(0) end) end
            end
        end
    end)
end

-- Re-allow reanimation animations and restore the correct mode.
_G._HaloResumeReanimAnims = function()
    _reanimAnimsSuspended = false
    if not State.isReanimated then return end
    if next(StateAnims) then
        startStateSystem()
    else
        _setCloneDefaultAnimate(true)
    end
end

local DropdownOverlay = Instance.new("Frame"); DropdownOverlay.Parent = StatesPanel
DropdownOverlay.Name = "DropdownOverlay"
DropdownOverlay.BackgroundColor3 = C.bg0
DropdownOverlay.BackgroundTransparency = 0.05
DropdownOverlay.BorderSizePixel = 0
DropdownOverlay.Size = UDim2.new(1, 0, 0, 240)
DropdownOverlay.Position = UDim2.new(0, 0, 0, 0)
DropdownOverlay.LayoutOrder = 99
DropdownOverlay.ZIndex = 200
DropdownOverlay.Visible = false
DropdownOverlay.ClipsDescendants = true
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = DropdownOverlay
    local s = Instance.new("UIStroke"); s.Color = C.border
    s.Transparency = 0.5; s.Thickness = 1.2; s.Parent = DropdownOverlay
end

local ddHeader = Instance.new("Frame"); ddHeader.Parent = DropdownOverlay
ddHeader.BackgroundColor3 = Color3.fromRGB(255,255,255); ddHeader.BackgroundTransparency = 0.95
ddHeader.BorderSizePixel = 0; ddHeader.Size = UDim2.new(1,0,0,32); ddHeader.ZIndex = 201
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,10); c.Parent = ddHeader end

local ddTitle = Instance.new("TextLabel"); ddTitle.Parent = ddHeader
ddTitle.BackgroundTransparency = 1; ddTitle.Position = UDim2.new(0,10,0,0)
ddTitle.Size = UDim2.new(1,-40,1,0); ddTitle.Font = Enum.Font.GothamBold
ddTitle.Text = "Select Animation"; ddTitle.TextColor3 = Color3.fromRGB(255,255,255)
ddTitle.TextSize = 12; ddTitle.TextXAlignment = Enum.TextXAlignment.Left; ddTitle.ZIndex = 202

local ddClose = Instance.new("TextButton"); ddClose.Parent = ddHeader
ddClose.AnchorPoint = Vector2.new(1,0.5); ddClose.Position = UDim2.new(1,-6,0.5,0)
ddClose.Size = UDim2.new(0,22,0,22); ddClose.BackgroundColor3 = Color3.fromRGB(255,80,80)
ddClose.BackgroundTransparency = 0.3; ddClose.BorderSizePixel = 0
ddClose.Font = Enum.Font.GothamBold; ddClose.Text = "X"
ddClose.TextColor3 = Color3.fromRGB(255,255,255); ddClose.TextSize = 14
ddClose.ZIndex = 202; ddClose.AutoButtonColor = false
do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = ddClose end

local ddSearch = Instance.new("TextBox"); ddSearch.Parent = DropdownOverlay
ddSearch.BackgroundColor3 = C.bg1; ddSearch.BackgroundTransparency = 0.4
ddSearch.BorderSizePixel = 0; ddSearch.Position = UDim2.new(0,8,0,38)
ddSearch.Size = UDim2.new(1,-16,0,28); ddSearch.ZIndex = 201
ddSearch.Font = Enum.Font.Gotham; ddSearch.PlaceholderText = "Search animations..."
ddSearch.PlaceholderColor3 = C.text3; ddSearch.Text = ""
ddSearch.TextColor3 = C.text; ddSearch.TextSize = 11
ddSearch.ClearTextOnFocus = false
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = ddSearch
    local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0,8); p.Parent = ddSearch
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = ddSearch
end

local ddList = Instance.new("ScrollingFrame"); ddList.Parent = DropdownOverlay
ddList.BackgroundTransparency = 1; ddList.BorderSizePixel = 0
ddList.Position = UDim2.new(0,8,0,72); ddList.Size = UDim2.new(1,-16,1,-80)
ddList.ScrollBarThickness = 3; ddList.ScrollBarImageColor3 = C.accent
ddList.ScrollBarImageTransparency = 0.5; ddList.ZIndex = 201
ddList.CanvasSize = UDim2.new(0,0,0,0)
do
    local l = Instance.new("UIListLayout"); l.Parent = ddList; l.Padding = UDim.new(0,3)
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ddList.CanvasSize = UDim2.new(0,0,0,l.AbsoluteContentSize.Y+6)
    end)
end

local ddCallback   = nil
local ddStateLabel = nil
local ddAllEntries = {}

function CloseDropdown()
    DropdownOverlay.Visible = false
    ddSearch.Text = ""; ddCallback = nil; ddStateLabel = nil
    for _, c in ipairs(ddList:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
    end
end

ddClose.MouseButton1Click:Connect(CloseDropdown)

local DD_MAX_ITEMS = 60
function PopulateDropdown(term)
    for _, c in ipairs(ddList:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
    end
    term = (term or ""):lower()
    local count = 0
    for _, entry in ipairs(ddAllEntries) do
        if count >= DD_MAX_ITEMS then
            local hint = Instance.new("TextLabel"); hint.Parent = ddList
            hint.BackgroundTransparency = 1; hint.Size = UDim2.new(1,0,0,22); hint.ZIndex = 202
            hint.Font = Enum.Font.GothamMedium; hint.Text = "Type to search for more..."
            hint.TextColor3 = C.text3; hint.TextSize = 10
            break
        end
        if term == "" or entry.name:lower():find(term, 1, true) then
            count = count + 1
            local btn = Instance.new("TextButton"); btn.Parent = ddList
            btn.BackgroundColor3 = C.bg2; btn.BackgroundTransparency = 0.5
            btn.BorderSizePixel = 0; btn.Size = UDim2.new(1,0,0,28); btn.ZIndex = 202
            btn.Font = Enum.Font.GothamMedium; btn.Text = entry.name
            btn.TextColor3 = C.text2; btn.TextSize = 11
            btn.TextXAlignment = Enum.TextXAlignment.Left; btn.AutoButtonColor = false
            btn.TextTruncate = Enum.TextTruncate.AtEnd
            do
                local c2 = Instance.new("UICorner"); c2.CornerRadius = UDim.new(0,5); c2.Parent = btn
                local p2 = Instance.new("UIPadding"); p2.PaddingLeft = UDim.new(0,8); p2.Parent = btn
                local s2 = Instance.new("UIStroke"); s2.Color = C.border; s2.Transparency = 0.8; s2.Thickness = 1; s2.Parent = btn
            end
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.7}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.93}):Play()
            end)
            local e = entry
            btn.MouseButton1Click:Connect(function()
                if ddCallback then ddCallback(e.name, e.url) end
                CloseDropdown()
            end)
        end
    end
end

local _ddSearchDebounce = nil
ddSearch:GetPropertyChangedSignal("Text"):Connect(function()
    if _ddSearchDebounce then task.cancel(_ddSearchDebounce) end
    _ddSearchDebounce = task.delay(0.12, function()
        _ddSearchDebounce = nil
        PopulateDropdown(ddSearch.Text)
    end)
end)

function OpenDropdown(stateType, displayBtn, onPick)
    ddAllEntries = {}
    for name, url in pairs(AnimationList) do
        table.insert(ddAllEntries, { name=name, url=url })
    end
    for _, ca in ipairs(CustomAnims) do
        table.insert(ddAllEntries, { name="[Custom] "..ca.name, url=ca.url })
    end
    table.sort(ddAllEntries, function(a,b) return a.name < b.name end)

    ddCallback   = onPick
    ddStateLabel = displayBtn
    ddTitle.Text = "Pick: " .. stateType
    ddSearch.Text = ""
    local row = displayBtn and displayBtn.Parent
    DropdownOverlay.LayoutOrder = ((row and row.LayoutOrder) or 0) + 0.1
    DropdownOverlay.Parent = StatesPanel
    DropdownOverlay.Size = UDim2.new(1, -4, 0, 240)
    DropdownOverlay.Position = UDim2.new(0, 2, 0, 0)
    DropdownOverlay.Visible  = true
    PopulateDropdown("")
    ddSearch:CaptureFocus()
end


do
local AddCustomModal = Instance.new("Frame"); AddCustomModal.Parent = Menu
AddCustomModal.Name = "AddCustomModal"
AddCustomModal.BackgroundColor3 = C.bg1
AddCustomModal.BackgroundTransparency = 0.05; AddCustomModal.BorderSizePixel = 0
AddCustomModal.Size = UDim2.new(1, 0, 1, -40); AddCustomModal.Position = UDim2.new(0, 0, 0, 40)
AddCustomModal.ZIndex = 100; AddCustomModal.Visible = false; AddCustomModal.ClipsDescendants = true
-- Modal backdrop for blur effect
local ModalBackdrop = Instance.new("Frame"); ModalBackdrop.Name = "Backdrop"
ModalBackdrop.Parent = AddCustomModal; ModalBackdrop.BackgroundColor3 = Color3.fromRGB(0,0,0)
ModalBackdrop.BackgroundTransparency = 0; ModalBackdrop.BorderSizePixel = 0
ModalBackdrop.Size = UDim2.new(1,0,1,0); ModalBackdrop.ZIndex = 99
ModalBackdrop.Visible = false
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 16); c.Parent = AddCustomModal
    local s = Instance.new("UIStroke"); s.Color = C.accent
    s.Transparency = 0.4; s.Thickness = 1.5; s.Parent = AddCustomModal
end

local acmHeader = Instance.new("Frame"); acmHeader.Parent = AddCustomModal
acmHeader.BackgroundColor3 = C.bg2; acmHeader.BackgroundTransparency = 0.4
acmHeader.BorderSizePixel = 0; acmHeader.Size = UDim2.new(1,0,0,38); acmHeader.ZIndex = 101
do
    local div = Instance.new("Frame"); div.Parent = acmHeader
    div.BackgroundColor3 = C.glassBorder; div.BackgroundTransparency = 0.7
    div.BorderSizePixel = 0; div.Position = UDim2.new(0,0,1,-1)
    div.Size = UDim2.new(1,0,0,1); div.ZIndex = 102
end

local acmTitle = Instance.new("TextLabel"); acmTitle.Parent = acmHeader
acmTitle.BackgroundTransparency = 1; acmTitle.Position = UDim2.new(0,14,0,0)
acmTitle.Size = UDim2.new(1,-50,1,0); acmTitle.Font = Enum.Font.GothamBold
acmTitle.Text = "Add Custom Animation"; acmTitle.TextColor3 = Color3.fromRGB(255,255,255)
acmTitle.TextSize = 13; acmTitle.TextXAlignment = Enum.TextXAlignment.Left; acmTitle.ZIndex = 102

local acmCloseBtn = Instance.new("TextButton"); acmCloseBtn.Parent = acmHeader
acmCloseBtn.AnchorPoint = Vector2.new(1,0.5); acmCloseBtn.Position = UDim2.new(1,-10,0.5,0)
acmCloseBtn.Size = UDim2.new(0,22,0,22); acmCloseBtn.BackgroundColor3 = C.accent
acmCloseBtn.BackgroundTransparency = 0.3; acmCloseBtn.BorderSizePixel = 0
acmCloseBtn.Font = Enum.Font.GothamBold; acmCloseBtn.Text = ""
acmCloseBtn.TextColor3 = Color3.fromRGB(10,10,10); acmCloseBtn.TextSize = 14
acmCloseBtn.ZIndex = 102; acmCloseBtn.AutoButtonColor = false
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = acmCloseBtn
    local ico = Instance.new("ImageLabel"); ico.Parent = acmCloseBtn
    ico.BackgroundTransparency = 1; ico.AnchorPoint = Vector2.new(0.5,0.5)
    ico.Position = UDim2.new(0.5,0,0.5,0); ico.Size = UDim2.new(0,10,0,10)
    ico.Image = "rbxassetid://6031094678"; ico.ImageColor3 = Color3.fromRGB(10,10,10); ico.ZIndex = 103
end

local acmBody = Instance.new("Frame"); acmBody.Parent = AddCustomModal
acmBody.BackgroundTransparency = 1; acmBody.Position = UDim2.new(0,12,0,46)
acmBody.Size = UDim2.new(1,-24,1,-96); acmBody.ZIndex = 101

local acmNameLbl = Instance.new("TextLabel"); acmNameLbl.Parent = acmBody
acmNameLbl.BackgroundTransparency = 1; acmNameLbl.Position = UDim2.new(0,0,0,0)
acmNameLbl.Size = UDim2.new(1,0,0,16); acmNameLbl.Font = Enum.Font.GothamSemibold
acmNameLbl.Text = "Animation Name"; acmNameLbl.TextColor3 = C.accent
acmNameLbl.TextSize = 10; acmNameLbl.TextXAlignment = Enum.TextXAlignment.Left; acmNameLbl.ZIndex = 102

local acmNameBox = Instance.new("TextBox"); acmNameBox.Parent = acmBody
acmNameBox.BackgroundColor3 = C.bg2; acmNameBox.BackgroundTransparency = 0.3
acmNameBox.BorderSizePixel = 0; acmNameBox.Position = UDim2.new(0,0,0,18)
acmNameBox.Size = UDim2.new(1,0,0,28); acmNameBox.ZIndex = 102
acmNameBox.Font = Enum.Font.Gotham; acmNameBox.PlaceholderText = "Leave empty to auto-generate"
acmNameBox.PlaceholderColor3 = C.text3
acmNameBox.Text = ""; acmNameBox.TextColor3 = C.text; acmNameBox.TextSize = 11
acmNameBox.ClearTextOnFocus = false
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = acmNameBox
    local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0,9); p.Parent = acmNameBox
    local s = Instance.new("UIStroke"); s.Color = C.accent; s.Transparency = 0.7; s.Thickness = 1; s.Parent = acmNameBox
end

local acmDataLbl = Instance.new("TextLabel"); acmDataLbl.Parent = acmBody
acmDataLbl.BackgroundTransparency = 1; acmDataLbl.Position = UDim2.new(0,0,0,54)
acmDataLbl.Size = UDim2.new(1,0,0,16); acmDataLbl.Font = Enum.Font.GothamSemibold
acmDataLbl.Text = "Keyframes Script"; acmDataLbl.TextColor3 = C.accent
acmDataLbl.TextSize = 10; acmDataLbl.TextXAlignment = Enum.TextXAlignment.Left; acmDataLbl.ZIndex = 102

local acmDataSub = Instance.new("TextLabel"); acmDataSub.Parent = acmBody
acmDataSub.BackgroundTransparency = 1; acmDataSub.Position = UDim2.new(0,0,0,70)
acmDataSub.Size = UDim2.new(1,0,0,12); acmDataSub.Font = Enum.Font.Gotham
acmDataSub.Text = "Click the box below, then Ctrl+V to paste"
acmDataSub.TextColor3 = C.text3; acmDataSub.TextSize = 9
acmDataSub.TextXAlignment = Enum.TextXAlignment.Left; acmDataSub.ZIndex = 102

local acmDataBox = Instance.new("TextBox"); acmDataBox.Parent = acmBody
acmDataBox.BackgroundColor3 = C.bg2; acmDataBox.BackgroundTransparency = 0.3
acmDataBox.BorderSizePixel = 0; acmDataBox.Position = UDim2.new(0,0,0,84)
acmDataBox.Size = UDim2.new(1,0,1,-148); acmDataBox.ZIndex = 102
acmDataBox.Font = Enum.Font.Code; acmDataBox.MultiLine = true; acmDataBox.ClearTextOnFocus = false
acmDataBox.TextWrapped = true; acmDataBox.ClipsDescendants = true
acmDataBox.PlaceholderText = "Paste keyframe script here..."
acmDataBox.PlaceholderColor3 = C.text3
acmDataBox.Text = ""; acmDataBox.TextColor3 = C.green; acmDataBox.TextSize = 10
acmDataBox.TextXAlignment = Enum.TextXAlignment.Left; acmDataBox.TextYAlignment = Enum.TextYAlignment.Top
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = acmDataBox
    local s = Instance.new("UIStroke"); s.Color = C.accent; s.Transparency = 0.7; s.Thickness = 1; s.Parent = acmDataBox
    local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0,8); p.PaddingTop = UDim.new(0,8); p.Parent = acmDataBox
end

local acmStatusLbl = Instance.new("TextLabel"); acmStatusLbl.Parent = acmBody
acmStatusLbl.BackgroundTransparency = 1; acmStatusLbl.Position = UDim2.new(0,0,1,-52)
acmStatusLbl.Size = UDim2.new(1,0,0,12); acmStatusLbl.Font = Enum.Font.GothamSemibold
acmStatusLbl.Text = "Status"; acmStatusLbl.TextColor3 = C.accent
acmStatusLbl.TextSize = 9; acmStatusLbl.TextXAlignment = Enum.TextXAlignment.Left; acmStatusLbl.ZIndex = 102

local acmStatus = Instance.new("TextLabel"); acmStatus.Parent = acmBody
acmStatus.BackgroundTransparency = 1; acmStatus.Position = UDim2.new(0,0,1,-38)
acmStatus.Size = UDim2.new(1,0,0,30); acmStatus.Font = Enum.Font.Gotham; acmStatus.TextWrapped = true
acmStatus.Text = "Enter keyframes data to add custom animation"
acmStatus.TextColor3 = C.text3; acmStatus.TextSize = 10
acmStatus.TextXAlignment = Enum.TextXAlignment.Left; acmStatus.ZIndex = 102

local acmBtnRow = Instance.new("Frame"); acmBtnRow.Parent = AddCustomModal
acmBtnRow.BackgroundTransparency = 1; acmBtnRow.BorderSizePixel = 0
acmBtnRow.AnchorPoint = Vector2.new(0,1); acmBtnRow.Position = UDim2.new(0,12,1,-10)
acmBtnRow.Size = UDim2.new(1,-24,0,34); acmBtnRow.ZIndex = 101

local acmCancelBtn = Instance.new("TextButton"); acmCancelBtn.Parent = acmBtnRow
acmCancelBtn.BackgroundColor3 = C.bg2; acmCancelBtn.BackgroundTransparency = 0.3
acmCancelBtn.BorderSizePixel = 0; acmCancelBtn.Size = UDim2.new(0.44,0,1,0)
acmCancelBtn.Font = Enum.Font.GothamSemibold; acmCancelBtn.Text = "Cancel"
acmCancelBtn.TextColor3 = C.text2; acmCancelBtn.TextSize = 11
acmCancelBtn.ZIndex = 102; acmCancelBtn.AutoButtonColor = false
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,7); c.Parent = acmCancelBtn
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Parent = acmCancelBtn
end
acmCancelBtn.MouseEnter:Connect(function()
    TweenService:Create(acmCancelBtn, TweenInfo.new(0.1), {BackgroundColor3 = C.bg3, BackgroundTransparency = 0.2}):Play()
end)
acmCancelBtn.MouseLeave:Connect(function()
    TweenService:Create(acmCancelBtn, TweenInfo.new(0.1), {BackgroundColor3 = C.bg2, BackgroundTransparency = 0.3}):Play()
end)

local acmAddBtn = Instance.new("TextButton"); acmAddBtn.Parent = acmBtnRow
acmAddBtn.AnchorPoint = Vector2.new(1,0); acmAddBtn.Position = UDim2.new(1,0,0,0)
acmAddBtn.BackgroundColor3 = C.accent; acmAddBtn.BackgroundTransparency = 0.2
acmAddBtn.BorderSizePixel = 0; acmAddBtn.Size = UDim2.new(0.52,0,1,0)
acmAddBtn.Font = Enum.Font.GothamBold; acmAddBtn.Text = "Add Animation"
acmAddBtn.TextColor3 = Color3.fromRGB(10,10,10); acmAddBtn.TextSize = 11
acmAddBtn.ZIndex = 102; acmAddBtn.AutoButtonColor = false
do 
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,7); c.Parent = acmAddBtn
    local s = Instance.new("UIStroke"); s.Color = C.accent; s.Transparency = 0.5; s.Thickness = 1; s.Parent = acmAddBtn
end
acmAddBtn.MouseEnter:Connect(function()
    TweenService:Create(acmAddBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
end)
acmAddBtn.MouseLeave:Connect(function()
    TweenService:Create(acmAddBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0.15}):Play()
end)

local acmBoxFocused = false
local _pendingPasteData = nil
acmDataBox.Focused:Connect(function() acmBoxFocused = true end)
acmDataBox.FocusLost:Connect(function() acmBoxFocused = false end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not acmBoxFocused then return end
    if input.KeyCode == Enum.KeyCode.V
    and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
      or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
        task.spawn(function()
            local ok, clip = pcall(getclipboard)
            if ok and type(clip) == "string" and #clip > 0 then
                _pendingPasteData = clip
                local preview = #clip > 200 and clip:sub(1, 200) .. "..." or clip
                acmDataBox.Text = preview
                acmStatus.Text = "Loaded " .. tostring(#clip) .. " chars"
                acmStatus.TextColor3 = Color3.fromRGB(100,220,140)
            end
        end)
    end
end)

function CloseAddCustomModal()
    -- Animate out
    TweenService:Create(AddCustomModal, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()
    if ModalBackdrop then
        TweenService:Create(ModalBackdrop, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    end
    task.delay(0.22, function()
        AddCustomModal.Visible = false
        if ModalBackdrop then ModalBackdrop.Visible = false end
        AddCustomModal.BackgroundTransparency = 0.05
        acmNameBox.Text = ""; acmDataBox.Text = ""
        acmStatus.Text = "Enter keyframes data to add custom animation"
        acmStatus.TextColor3 = C.text3
    end)
end

acmCloseBtn.MouseButton1Click:Connect(CloseAddCustomModal)
acmCancelBtn.MouseButton1Click:Connect(CloseAddCustomModal)

customOpenModalBtn.MouseButton1Click:Connect(function()
    _pendingPasteData = nil
    acmNameBox.Text = ""; acmDataBox.Text = ""
    acmStatus.Text = "Enter keyframes data to add custom animation"
    acmStatus.TextColor3 = C.text3
    AddCustomModal.Visible = true
    AddCustomModal.BackgroundTransparency = 1
    if ModalBackdrop then ModalBackdrop.Visible = true; ModalBackdrop.BackgroundTransparency = 1 end
    TweenService:Create(AddCustomModal, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.05}):Play()
    if ModalBackdrop then
        TweenService:Create(ModalBackdrop, TweenInfo.new(0.25), {BackgroundTransparency = 0.5}):Play()
    end
    acmNameBox:CaptureFocus()
end)

acmAddBtn.MouseButton1Click:Connect(function()
    -- Use _pendingPasteData if available (large pastes), else use TextBox text
    local rawData = _pendingPasteData or acmDataBox.Text
    rawData = rawData and rawData:gsub("^%s+", ""):gsub("%s+$", "") or ""
    if rawData == "" then
        acmStatus.Text = "Please paste keyframe data first."
        acmStatus.TextColor3 = Color3.fromRGB(255,160,80); return
    end
    -- Grab name immediately before spawning (TextBox state may change)
    local capturedName = acmNameBox.Text:match("^%s*(.-)%s*$")
    local capturedRaw  = rawData
    local capturedPaste = _pendingPasteData

    acmStatus.Text = "Validating..."; acmStatus.TextColor3 = Color3.fromRGB(180,180,220)
    -- Disable button to prevent double-submit
    acmAddBtn.Active = false

    task.spawn(function()
        local isJson = false

        -- Check if it's a file path
        if capturedRaw:match("^[A-Za-z]:\\") or capturedRaw:match("^/") then
            acmStatus.Text = "Reading file..."
            local fileContent
            local ok, err = pcall(function()
                if isfile and isfile(capturedRaw) then
                    fileContent = readfile(capturedRaw)
                else
                    local file = io.open(capturedRaw, "r")
                    if file then fileContent = file:read("*a"); file:close() end
                end
            end)
            if not ok or not fileContent then
                acmStatus.Text = "Failed to read file: " .. tostring(err or "file not found")
                acmStatus.TextColor3 = Color3.fromRGB(255,90,90)
                acmAddBtn.Active = true; return
            end
            capturedRaw = fileContent
        end

        -- NON-BLOCKING ADD: do NOT parse the animation here. Parsing/JSON-decoding
        -- and building keyframe CFrames for a large animation froze the game. We
        -- just store the raw data; PlayAnimation parses it (and seeds the cache)
        -- on the first play, then it's cached like normal.
        local firstChar = capturedRaw:match("^%s*(.)")
        isJson = (firstChar == "{" or firstChar == "[")

        -- Cheap sanity check only (no parsing): keyframe data always has a table.
        if not capturedRaw:find("{", 1, true) then
            acmStatus.Text = "That doesn't look like keyframe data."
            acmStatus.TextColor3 = Color3.fromRGB(255,90,90)
            acmAddBtn.Active = true; return
        end

        local name = capturedName ~= "" and capturedName or ("Custom_" .. tostring(#CustomAnims + 1))

        -- Insert into live tables immediately so the UI sees the new anim
        if #capturedRaw > _SAVE_INLINE_MAX then
            -- Write large data to its own file (we're already on a spawned thread)
            local safeFileName = fpath("custom_" .. name:gsub("[^%w_%-]", "_") .. ".dat")
            pcall(function() writefile(safeFileName, capturedRaw) end)
            table.insert(CustomAnims, { name = name, url = safeFileName, raw = true, isJson = isJson })
            CustomAnimations[name] = safeFileName
        else
            table.insert(CustomAnims, { name = name, url = capturedRaw, raw = true, isJson = isJson })
            CustomAnimations[name] = capturedRaw
        end

        -- Persist (SaveCustomAnims is already debounced + async internally)
        SaveCustomAnims()
        SaveData()

        -- Append the newly inserted entry to the UI
        local newEntry = CustomAnims[#CustomAnims]
        if newEntry and type(AppendCustomRow) == "function" then
            AppendCustomRow(newEntry)
        end
        
        -- Update Custom tab count after adding animation
        if UpdateCustomTabCount then
            UpdateCustomTabCount()
        end
        
        Notify("Added: " .. name, 2)
        _pendingPasteData = nil
        acmAddBtn.Active = true
        CloseAddCustomModal()
    end)
end)
end


local stateDisplayBtns = {}

function BuildStatesPanel()
    for _, c in ipairs(StatesPanel:GetChildren()) do
        if c.Name ~= "DropdownOverlay" and not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end
    stateDisplayBtns = {}

    for i, stType in ipairs(STATE_TYPES) do
        local row = Instance.new("Frame"); row.Parent = StatesPanel
        row.BackgroundColor3 = C.bg1; row.BackgroundTransparency = 0.2
        row.BorderSizePixel = 0; row.Size = UDim2.new(1,0,0,44); row.ZIndex = 34
        row.LayoutOrder = i
        do
            local cr = Instance.new("UICorner"); cr.CornerRadius = UDim.new(0,10); cr.Parent = row
            local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.5; s.Thickness = 1; s.Parent = row
        end

        local typeLbl = Instance.new("TextLabel"); typeLbl.Parent = row
        typeLbl.BackgroundTransparency = 1; typeLbl.Position = UDim2.new(0,14,0,0)
        typeLbl.Size = UDim2.new(0,65,1,0); typeLbl.Font = Enum.Font.GothamBold
        typeLbl.Text = stType; typeLbl.TextColor3 = C.accent; typeLbl.TextSize = 12
        typeLbl.TextXAlignment = Enum.TextXAlignment.Left; typeLbl.ZIndex = 35

        local currentName = "None"
        if StateAnims[stType] then
            local entry   = StateAnims[stType]
            local savedUrl = type(entry) == "table" and entry.url or entry
            for name, url in pairs(AnimationList) do
                if url == savedUrl then currentName = name; break end
            end
            if currentName == "None" then
                for _, ca in ipairs(CustomAnims) do
                    if ca.url == savedUrl then currentName = ca.name; break end
                end
            end
            if currentName == "None" then currentName = "Saved" end
        end

        local displayBtn = Instance.new("TextButton"); displayBtn.Parent = row
        displayBtn.Position = UDim2.new(0,85,0,8); displayBtn.Size = UDim2.new(1,-145,0,28)
        displayBtn.BackgroundColor3 = C.bg2; displayBtn.BackgroundTransparency = 0.4
        displayBtn.BorderSizePixel = 0; displayBtn.ZIndex = 35
        displayBtn.Font = Enum.Font.GothamMedium; displayBtn.Text = currentName
        displayBtn.TextColor3 = currentName == "None" and C.text3 or Color3.fromRGB(200, 200, 200)
        displayBtn.TextSize = 11; displayBtn.TextXAlignment = Enum.TextXAlignment.Left
        displayBtn.TextTruncate = Enum.TextTruncate.AtEnd; displayBtn.AutoButtonColor = false
        do
            local cr = Instance.new("UICorner"); cr.CornerRadius = UDim.new(0,7); cr.Parent = displayBtn
            local pd = Instance.new("UIPadding"); pd.PaddingLeft = UDim.new(0,12); pd.PaddingRight = UDim.new(0,24); pd.Parent = displayBtn
            local chev = Instance.new("ImageLabel"); chev.Parent = displayBtn
            chev.BackgroundTransparency = 1; chev.AnchorPoint = Vector2.new(1,0.5)
            chev.Position = UDim2.new(1,-2,0.5,0); chev.Size = UDim2.new(0,12,0,12)
            chev.Image = "rbxassetid://6034818372"
            chev.ImageColor3 = C.text3; chev.ZIndex = 36
        end

        local clrBtn = Instance.new("TextButton"); clrBtn.Parent = row
        clrBtn.AnchorPoint = Vector2.new(1,0.5); clrBtn.Position = UDim2.new(1,-10,0.5,0)
        clrBtn.Size = UDim2.new(0,52,0,28); clrBtn.BackgroundColor3 = C.bg2
        clrBtn.BackgroundTransparency = 0.3; clrBtn.BorderSizePixel = 0
        clrBtn.Font = Enum.Font.GothamBold; clrBtn.Text = "Clear"
        clrBtn.TextColor3 = C.text2; clrBtn.TextSize = 10; clrBtn.ZIndex = 35
        do
            local cr = Instance.new("UICorner"); cr.CornerRadius = UDim.new(0,7); cr.Parent = clrBtn
            local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.6; s.Thickness = 1; s.Parent = clrBtn
        end

        stateDisplayBtns[stType] = displayBtn

        displayBtn.MouseEnter:Connect(function()
            TweenService:Create(displayBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.bg3, BackgroundTransparency = 0.2}):Play()
        end)
        displayBtn.MouseLeave:Connect(function()
            TweenService:Create(displayBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.bg2, BackgroundTransparency = 0.4}):Play()
        end)

        clrBtn.MouseEnter:Connect(function()
            TweenService:Create(clrBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.red, BackgroundTransparency = 0.2, TextColor3 = C.white}):Play()
        end)
        clrBtn.MouseLeave:Connect(function()
            TweenService:Create(clrBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.bg2, BackgroundTransparency = 0.3, TextColor3 = C.text2}):Play()
        end)

        local st = stType; local db = displayBtn

        displayBtn.MouseButton1Click:Connect(function()
            if DropdownOverlay.Visible and ddStateLabel == db then CloseDropdown(); return end
            OpenDropdown(st, db, function(animName, animUrl)
                local isRaw = false
                for _, ca in ipairs(CustomAnims) do
                    if ca.url == animUrl then isRaw = ca.raw == true; break end
                end
                if not isRaw and type(animUrl) == "string" then
                    -- Check if it's Lua code (starts with return)
                    isRaw = animUrl:match("^%s*return") ~= nil
                end
                if not isRaw and type(animUrl) == "string" and animUrl:match("^https?://") then
                    -- HTTP URLs are raw
                    isRaw = true
                end
                if not isRaw and type(animUrl) == "string" and isfile and pcall(isfile, animUrl) and isfile(animUrl) then
                    -- Local file paths are raw (need to be loaded and parsed)
                    isRaw = true
                end
                warn("[StateAnim] Assigning", animName, "to", st, "- URL:", animUrl, "- isRaw:", isRaw)
                StateAnims[st] = { url = animUrl, raw = isRaw }
                SaveData()
                prefetchStateAnim(st)
                db.Text = animName; db.TextColor3 = Color3.fromRGB(200, 200, 200)
                if State.isReanimated then stopStateSystem(); startStateSystem() end
                Notify(st .. " -> " .. animName, 2)
            end)
        end)

        clrBtn.MouseButton1Click:Connect(function()
            StateAnims[st] = nil
            db.Text = "None"; db.TextColor3 = C.text3
            SaveData()
            if State.isReanimated then
                stopStateSystem()
                if next(StateAnims) then
                    startStateSystem()
                elseif _applyReanimDefaultAnimate then
                    -- Last custom state removed: revert to default Roblox animations.
                    _applyReanimDefaultAnimate(true)
                end
            end
            Notify(st .. " state cleared", 2)
            if DropdownOverlay.Visible and ddStateLabel == db then CloseDropdown() end
        end)
    end
end

local _statesPanelBuilt = false
function EnsureStatesPanelBuilt()
    if _statesPanelBuilt then return end
    _statesPanelBuilt = true
    BuildStatesPanel()
end

-- Lazy custom list — only build the custom-animation rows the first time the
-- Custom tab is actually opened, so opening the window never freezes building
-- rows for animations the user isn't even looking at yet.
local _customListBuilt = false
function EnsureCustomListBuilt()
    if _customListBuilt then return end
    _customListBuilt = true
    task.spawn(function()
        RebuildCustomList()
    end)
end

function SwitchTab(tabName)
    State.currentTab = tabName
    SetTabActive(TabButtons[tabName])
    if _G._HaloSetGridActive then pcall(_G._HaloSetGridActive, tabName) end
    if tabName == "States" then EnsureStatesPanelBuilt() end
    if tabName == "Custom" then EnsureCustomListBuilt() end
    if tabName == "Binds" then RebuildBindsList() end
    
    local panels = {
        AnimListFrame, CustomPanel, BindsPanel, StatesPanel, SettingsPanel,
        SpeedPanel, TestingPanel, LimbsPanel, StretchingPanel
    }

    -- Soft fade-out currently visible panels
    for _, p in ipairs(panels) do
        if p and p.Visible then
            p.Visible = false
        end
    end
    
    local targetPanel = nil
    if tabName == "All" or tabName == "Favs" then
        targetPanel = AnimListFrame
    elseif tabName == "Custom" then
        targetPanel = CustomPanel
    elseif tabName == "Binds" then
        targetPanel = BindsPanel
    elseif tabName == "States" then
        targetPanel = StatesPanel
    elseif tabName == "Speed" then
        targetPanel = SpeedPanel
    elseif tabName == "Settings" then
        targetPanel = SettingsPanel
    elseif tabName == "Copier" then
        targetPanel = TestingPanel
    elseif tabName == "Tracking" then
        targetPanel = LimbsPanel
    elseif tabName == "Stretching" then
        targetPanel = StretchingPanel
    end

    if targetPanel then
        targetPanel.Visible = true
        -- light pop-in
        local oldT = targetPanel.BackgroundTransparency
        if targetPanel:IsA("ScrollingFrame") or targetPanel:IsA("Frame") then
            targetPanel.BackgroundTransparency = math.min((oldT or 0.5) + 0.25, 0.95)
            TweenService:Create(targetPanel, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = oldT or 0.5
            }):Play()
        end
    end
    
    local noSearch = (tabName == "Custom" or tabName == "Settings" or tabName == "States" or tabName == "Speed" or tabName == "Binds" or tabName == "Copier" or tabName == "Tracking" or tabName == "Stretching")
    SearchBox.Visible = not noSearch
    hintLbl.Visible   = not noSearch

    -- Account for Tab Grid height when positioning content
    local gridExtra = 0
    if _G._HaloTabGridMode then
        local tg = body:FindFirstChild("TabGrid")
        if tg then gridExtra = math.max(0, tg.Size.Y.Offset - 26) end
    end
    local baseY = noSearch and 104 or 148
    local listY = baseY + gridExtra
    local sizeOff = (noSearch and -112 or -156) - gridExtra

    local allPanels = {
        AnimListFrame, CustomPanel, BindsPanel, StatesPanel, SettingsPanel,
        SpeedPanel, TestingPanel, LimbsPanel, StretchingPanel
    }
    for _, p in ipairs(allPanels) do
        if p then
            p.Position = UDim2.new(0, 10, 0, listY)
            p.Size = UDim2.new(1, -20, 1, sizeOff)
        end
    end

    if SearchBox then
        SearchBox.Position = UDim2.new(0, 10, 0, 104 + gridExtra)
    end
    if hintLbl then
        hintLbl.Position = UDim2.new(0, 10, 0, 134 + gridExtra)
    end

    RebuildVisible()
end

for tname, tb in pairs(TabButtons) do
    tb.MouseButton1Click:Connect(function() SwitchTab(tname) end)
end

-- Wire Tab Grid buttons
task.defer(function()
    local tg = body and body:FindFirstChild("TabGrid")
    if not tg then return end
    for _, child in ipairs(tg:GetChildren()) do
        if child:IsA("TextButton") then
            local name = nil
            for tname, _ in pairs(TabButtons) do
                if child.Text == tname:upper() then name = tname break end
            end
            if name then
                child.MouseButton1Click:Connect(function()
                    SwitchTab(name)
                end)
            end
        end
    end
end)

local SpeedTrack
local SpeedValueBox
local SpeedFill
local SpeedHandle
local SpeedLabel

do
    local bottomBar = Instance.new("Frame"); bottomBar.Parent = SpeedPanel
    bottomBar.BackgroundColor3 = C.bg1; bottomBar.BackgroundTransparency = 0.35
    bottomBar.BorderSizePixel = 0; bottomBar.Size = UDim2.new(1,0,0,196)
    bottomBar.Position = UDim2.new(0,0,0,0); bottomBar.ZIndex = 40
    bottomBar.LayoutOrder = 1
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 12); c.Parent = bottomBar
    end

    -- Cover the top rounded corners of bottomBar to keep them flat
    local topCover = Instance.new("Frame"); topCover.Parent = bottomBar
    topCover.BackgroundColor3 = C.bg1; topCover.BackgroundTransparency = 0.35
    topCover.BorderSizePixel = 0; topCover.Size = UDim2.new(1,0,0,12)
    topCover.Position = UDim2.new(0,0,0,0); topCover.ZIndex = 40

    local sepLine = Instance.new("Frame"); sepLine.Parent = bottomBar
    sepLine.BackgroundColor3 = C.border; sepLine.BackgroundTransparency = 0.5
    sepLine.BorderSizePixel = 0; sepLine.Size = UDim2.new(1,0,0,1)
    sepLine.Position = UDim2.new(0,0,0,0); sepLine.ZIndex = 41

    local speedRow = Instance.new("Frame"); speedRow.Parent = bottomBar
    speedRow.BackgroundTransparency = 1; speedRow.Size = UDim2.new(1,-24,0,24)
    speedRow.AnchorPoint = Vector2.new(0,0); speedRow.Position = UDim2.new(0,12,0,14); speedRow.ZIndex = 41

    SpeedLabel = Instance.new("TextLabel"); SpeedLabel.Parent = speedRow
    SpeedLabel.BackgroundTransparency = 1; SpeedLabel.Size = UDim2.new(0,88,1,0)
    SpeedLabel.Font = Enum.Font.GothamBold; SpeedLabel.Text = "Speed: 1.0"
    SpeedLabel.TextColor3 = C.text
    SpeedLabel.TextSize = 10; SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left; SpeedLabel.ZIndex = 42

    SpeedTrack = Instance.new("Frame"); SpeedTrack.Parent = speedRow
    SpeedTrack.BackgroundColor3 = C.bg2; SpeedTrack.BackgroundTransparency = 0.3
    SpeedTrack.BorderSizePixel = 0; SpeedTrack.Position = UDim2.new(0,96,0.5,-4)
    SpeedTrack.Size = UDim2.new(1,-200,0,8); SpeedTrack.ZIndex = 42
    do 
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = SpeedTrack 
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = SpeedTrack
    end

    SpeedFill = Instance.new("Frame"); SpeedFill.Parent = SpeedTrack
    SpeedFill.BackgroundColor3 = C.accent; SpeedFill.BackgroundTransparency = 0.1
    SpeedFill.BorderSizePixel = 0; SpeedFill.Size = UDim2.new(0.231,0,1,0); SpeedFill.ZIndex = 43
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = SpeedFill end

    SpeedHandle = Instance.new("Frame"); SpeedHandle.Parent = SpeedTrack
    SpeedHandle.AnchorPoint = Vector2.new(0.5,0.5)
    SpeedHandle.BackgroundColor3 = C.accent; SpeedHandle.BackgroundTransparency = 0
    SpeedHandle.BorderSizePixel = 0; SpeedHandle.Position = UDim2.new(0.231,0,0.5,0)
    SpeedHandle.Size = UDim2.new(0,12,0,12); SpeedHandle.ZIndex = 44
    do 
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = SpeedHandle 
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.4; s.Thickness = 1; s.Parent = SpeedHandle
    end

    SpeedValueBox = Instance.new("TextBox"); SpeedValueBox.Parent = speedRow
    SpeedValueBox.AnchorPoint = Vector2.new(1,0.5)
    SpeedValueBox.BackgroundColor3 = C.bg2; SpeedValueBox.BackgroundTransparency = 0.3
    SpeedValueBox.BorderSizePixel = 0; SpeedValueBox.Position = UDim2.new(1,-54,0.5,0)
    SpeedValueBox.Size = UDim2.new(0,40,0,22); SpeedValueBox.Font = Enum.Font.GothamBold
    SpeedValueBox.Text = "1.0"; SpeedValueBox.TextColor3 = C.text2
    SpeedValueBox.TextSize = 9; SpeedValueBox.ZIndex = 42; SpeedValueBox.ClearTextOnFocus = false
    do 
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,4); c.Parent = SpeedValueBox 
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = SpeedValueBox
    end

    local SpeedResetBtn = Instance.new("TextButton"); SpeedResetBtn.Parent = speedRow
    SpeedResetBtn.AnchorPoint = Vector2.new(1,0.5)
    SpeedResetBtn.BackgroundColor3 = C.bg3; SpeedResetBtn.BackgroundTransparency = 0.2
    SpeedResetBtn.BorderSizePixel = 0; SpeedResetBtn.Position = UDim2.new(1,0,0.5,0)
    SpeedResetBtn.Size = UDim2.new(0,48,0,22); SpeedResetBtn.Font = Enum.Font.GothamBold
    SpeedResetBtn.Text = "Reset"; SpeedResetBtn.TextColor3 = C.accent
    SpeedResetBtn.TextSize = 9; SpeedResetBtn.ZIndex = 42; SpeedResetBtn.AutoButtonColor = false
    do 
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,4); c.Parent = SpeedResetBtn 
        local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = SpeedResetBtn
    end
    SpeedResetBtn.MouseEnter:Connect(function()
        TweenService:Create(SpeedResetBtn, TweenInfo.new(0.12), {BackgroundColor3 = C.accent, BackgroundTransparency = 0.2, TextColor3 = Color3.fromRGB(10,10,10)}):Play()
    end)
    SpeedResetBtn.MouseLeave:Connect(function()
        TweenService:Create(SpeedResetBtn, TweenInfo.new(0.12), {BackgroundColor3 = C.bg3, BackgroundTransparency = 0.2, TextColor3 = C.accent}):Play()
    end)
    SpeedResetBtn.MouseButton1Click:Connect(function()
        ApplySpeed(1.0)
    end)

    local spKeysHeader = Instance.new("TextLabel"); spKeysHeader.Parent = bottomBar
    spKeysHeader.BackgroundTransparency = 1; spKeysHeader.Size = UDim2.new(1,-24,0,14)
    spKeysHeader.AnchorPoint = Vector2.new(0,0); spKeysHeader.Position = UDim2.new(0,12,0,48); spKeysHeader.ZIndex = 41
    spKeysHeader.Font = Enum.Font.GothamSemibold
    spKeysHeader.Text = "Speed Presets - click a value to edit, [+] to bind"
    spKeysHeader.TextColor3 = C.text3; spKeysHeader.TextSize = 8
    spKeysHeader.TextXAlignment = Enum.TextXAlignment.Left

    local spValRow = Instance.new("Frame"); spValRow.Parent = bottomBar
    spValRow.BackgroundTransparency = 1; spValRow.Size = UDim2.new(1,-24,0,22)
    spValRow.AnchorPoint = Vector2.new(0,0); spValRow.Position = UDim2.new(0,12,0,68); spValRow.ZIndex = 41

    local spKeyRow = Instance.new("Frame"); spKeyRow.Parent = bottomBar
    spKeyRow.BackgroundTransparency = 1; spKeyRow.Size = UDim2.new(1,-24,0,22)
    spKeyRow.AnchorPoint = Vector2.new(0,0); spKeyRow.Position = UDim2.new(0,12,0,94); spKeyRow.ZIndex = 41

for i = 1, 6 do
    local xScale = (i-1) * (1/6)
    local xSzOff = -3

    local vbox = Instance.new("TextBox"); vbox.Parent = spValRow
    vbox.BackgroundColor3 = C.bg2
    vbox.BackgroundTransparency = 0.05; vbox.BorderSizePixel = 0
    vbox.Position = UDim2.new(xScale, i==1 and 0 or 2, 0, 0)
    vbox.Size = UDim2.new(1/6, i==1 and -2 or (i==6 and -2 or xSzOff), 1, 0)
    vbox.Font = Enum.Font.GothamBold
    vbox.Text = string.format("%.1f", SpeedKeybinds[i].speed)
    vbox.TextColor3 = C.accent; vbox.TextSize = 8
    vbox.ClearTextOnFocus = false; vbox.ZIndex = 42
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,4); c.Parent = vbox
        local s = Instance.new("UIStroke"); s.Color = C.border
        s.Transparency = 0.6; s.Thickness = 1; s.Parent = vbox
    end

    local kbtn = Instance.new("TextButton"); kbtn.Parent = spKeyRow
    local sk0 = SpeedKeybinds[i]
    kbtn.Position = UDim2.new(xScale, i==1 and 0 or 2, 0, 0)
    kbtn.Size = UDim2.new(1/6, i==1 and -2 or (i==6 and -2 or xSzOff), 1, 0)
    kbtn.Font = Enum.Font.GothamBold
    kbtn.Text = sk0.key and ("["..sk0.key.Name.."]") or "[+]"
    kbtn.BackgroundColor3 = sk0.key and C.bg3 or C.bg2
    kbtn.BackgroundTransparency = 0.2
    kbtn.TextColor3 = sk0.key and C.accent or C.text3
    kbtn.TextSize = 7; kbtn.ZIndex = 42; kbtn.AutoButtonColor = false
    kbtn.TextTruncate = Enum.TextTruncate.AtEnd; kbtn.BorderSizePixel = 0
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,4); c.Parent = kbtn end

    SpeedKeybinds[i].btn = kbtn
    speedKeyWidgets[i] = { vbox = vbox, kbtn = kbtn }

    local ci = i
    vbox.FocusLost:Connect(function()
        local v = tonumber((vbox.Text:gsub("[^%d%.]", "")))
        if v and v > 0 then
            SpeedKeybinds[ci].speed = v
        end
        vbox.Text = tostring(SpeedKeybinds[ci].speed)
        SaveData()
    end)

    kbtn.MouseButton1Click:Connect(function()
        if _G._HaloListeningSpeedIdx == ci then
            _G._HaloListeningSpeedIdx = nil
            local sk = SpeedKeybinds[ci]
            kbtn.Text = sk.key and ("["..sk.key.Name.."]") or "[+]"
            kbtn.BackgroundColor3 = sk.key and C.bg3 or C.bg2
            kbtn.TextColor3 = sk.key and C.accent or C.text3
            return
        end
        if SpeedKeybinds[ci].key then
            SpeedKeybinds[ci].key = nil; kbtn.Text = "[+]"
            kbtn.BackgroundColor3 = C.bg2; kbtn.TextColor3 = C.text3
            SaveData(); return
        end
        _G._HaloListeningSpeedIdx = ci
        kbtn.Text = "[?]"; kbtn.BackgroundColor3 = Color3.fromRGB(180,80,20)
        kbtn.TextColor3 = Color3.fromRGB(255,220,180)
    end)

    kbtn.MouseEnter:Connect(function()
        TweenService:Create(kbtn, TweenInfo.new(0.1), {BackgroundTransparency=0}):Play()
    end)
    kbtn.MouseLeave:Connect(function()
        TweenService:Create(kbtn, TweenInfo.new(0.1), {BackgroundTransparency=0.2}):Play()
    end)
end

    -- Link toggle
    local linkFrame = Instance.new("Frame"); linkFrame.Parent = bottomBar
    linkFrame.BackgroundTransparency = 1; linkFrame.Size = UDim2.new(1,-24,0,16)
    linkFrame.Position = UDim2.new(0,12,0,124); linkFrame.ZIndex = 41

    local linkLbl = Instance.new("TextLabel"); linkLbl.Parent = linkFrame
    linkLbl.BackgroundTransparency = 1; linkLbl.Size = UDim2.new(0,200,1,0)
    linkLbl.Font = Enum.Font.GothamSemibold; linkLbl.TextSize = 8
    linkLbl.Text = "Reverse Speed Keys"
    linkLbl.TextColor3 = C.text3; linkLbl.TextXAlignment = Enum.TextXAlignment.Left; linkLbl.ZIndex = 42

    local linkBtn = Instance.new("TextButton"); linkBtn.Parent = linkFrame
    linkBtn.AnchorPoint = Vector2.new(1,0.5); linkBtn.Position = UDim2.new(1,0,0.5,0)
    linkBtn.Size = UDim2.new(0,56,0,14); linkBtn.Font = Enum.Font.GothamBold; linkBtn.TextSize = 7
    linkBtn.BorderSizePixel = 0; linkBtn.AutoButtonColor = false; linkBtn.ZIndex = 42
    do local cr = Instance.new("UICorner"); cr.CornerRadius = UDim.new(0,4); cr.Parent = linkBtn end
    local function updateLinkBtn()
        if linkRevToNormal then
            linkBtn.Text = "Linked"; linkBtn.BackgroundColor3 = C.accent; linkBtn.TextColor3 = Color3.fromRGB(0,0,0)
            linkBtn.BackgroundTransparency = 0.1
        else
            linkBtn.Text = "Separate"; linkBtn.BackgroundColor3 = C.bg2; linkBtn.TextColor3 = C.text3
            linkBtn.BackgroundTransparency = 0.2
        end
    end
    updateLinkBtn()
    linkBtn.MouseButton1Click:Connect(function()
        linkRevToNormal = not linkRevToNormal
        updateLinkBtn()
        SaveData()
    end)

    -- Reverse speed keybind value row
    local rspValRow = Instance.new("Frame"); rspValRow.Parent = bottomBar
    rspValRow.BackgroundTransparency = 1; rspValRow.Size = UDim2.new(1,-24,0,22)
    rspValRow.Position = UDim2.new(0,12,0,146); rspValRow.ZIndex = 41

    local rspKeyRow = Instance.new("Frame"); rspKeyRow.Parent = bottomBar
    rspKeyRow.BackgroundTransparency = 1; rspKeyRow.Size = UDim2.new(1,-24,0,22)
    rspKeyRow.Position = UDim2.new(0,12,0,172); rspKeyRow.ZIndex = 41

    for i = 1, 6 do
        local xScale = (i-1) * (1/6)
        local xSzOff = -3

        local rvbox = Instance.new("TextBox"); rvbox.Parent = rspValRow
        rvbox.BackgroundColor3 = C.bg2; rvbox.BackgroundTransparency = 0.05; rvbox.BorderSizePixel = 0
        rvbox.Position = UDim2.new(xScale, i==1 and 0 or 2, 0, 0)
        rvbox.Size = UDim2.new(1/6, i==1 and -2 or (i==6 and -2 or xSzOff), 1, 0)
        rvbox.Font = Enum.Font.GothamBold
        rvbox.Text = string.format("%.1f", ReverseSpeedKeybinds[i].speed)
        rvbox.TextColor3 = Color3.fromRGB(255,130,130); rvbox.TextSize = 8
        rvbox.ClearTextOnFocus = false; rvbox.ZIndex = 42
        do
            local cr = Instance.new("UICorner"); cr.CornerRadius = UDim.new(0,4); cr.Parent = rvbox
            local st = Instance.new("UIStroke"); st.Color = C.border; st.Transparency = 0.6; st.Thickness = 1; st.Parent = rvbox
        end

        local rkbtn = Instance.new("TextButton"); rkbtn.Parent = rspKeyRow
        local rsk0 = ReverseSpeedKeybinds[i]
        rkbtn.Position = UDim2.new(xScale, i==1 and 0 or 2, 0, 0)
        rkbtn.Size = UDim2.new(1/6, i==1 and -2 or (i==6 and -2 or xSzOff), 1, 0)
        rkbtn.Font = Enum.Font.GothamBold
        rkbtn.Text = rsk0.key and ("["..rsk0.key.Name.."]") or "[+]"
        rkbtn.BackgroundColor3 = rsk0.key and C.bg3 or C.bg2
        rkbtn.BackgroundTransparency = 0.2
        rkbtn.TextColor3 = rsk0.key and Color3.fromRGB(255,130,130) or C.text3
        rkbtn.TextSize = 7; rkbtn.ZIndex = 42; rkbtn.AutoButtonColor = false
        rkbtn.TextTruncate = Enum.TextTruncate.AtEnd; rkbtn.BorderSizePixel = 0
        do local cr = Instance.new("UICorner"); cr.CornerRadius = UDim.new(0,4); cr.Parent = rkbtn end

        ReverseSpeedKeybinds[i].btn = rkbtn
        revSpeedKeyWidgets[i] = { vbox = rvbox, kbtn = rkbtn }

        local ci = i
        rvbox.FocusLost:Connect(function()
            local v = tonumber((rvbox.Text:gsub("[^%d%.]", "")))
            if v and v > 0 then
                ReverseSpeedKeybinds[ci].speed = v
            end
            rvbox.Text = tostring(ReverseSpeedKeybinds[ci].speed)
            SaveData()
        end)

        rkbtn.MouseButton1Click:Connect(function()
            if _G._HaloListeningRevSpeedIdx == ci then
                _G._HaloListeningRevSpeedIdx = nil
                local sk = ReverseSpeedKeybinds[ci]
                rkbtn.Text = sk.key and ("["..sk.key.Name.."]") or "[+]"
                rkbtn.BackgroundColor3 = sk.key and C.bg3 or C.bg2
                rkbtn.TextColor3 = sk.key and Color3.fromRGB(255,130,130) or C.text3
                return
            end
            if ReverseSpeedKeybinds[ci].key then
                ReverseSpeedKeybinds[ci].key = nil; rkbtn.Text = "[+]"
                rkbtn.BackgroundColor3 = C.bg2; rkbtn.TextColor3 = C.text3
                SaveData(); return
            end
            _G._HaloListeningRevSpeedIdx = ci
            rkbtn.Text = "[?]"; rkbtn.BackgroundColor3 = Color3.fromRGB(180,80,20)
            rkbtn.TextColor3 = Color3.fromRGB(255,220,180)
        end)

        rkbtn.MouseEnter:Connect(function()
            TweenService:Create(rkbtn, TweenInfo.new(0.1), {BackgroundTransparency=0}):Play()
        end)
        rkbtn.MouseLeave:Connect(function()
            TweenService:Create(rkbtn, TweenInfo.new(0.1), {BackgroundTransparency=0.2}):Play()
        end)
    end
end

function ApplySpeed(speed)
    speed = math.clamp(math.floor(speed * 10 + 0.5) / 10, 0.0, 1000.0)
    State.currentSpeed   = speed
    local fraction = (speed - 0.0) / 3.9
    SpeedFill.Size       = UDim2.new(fraction, 0, 1, 0)
    SpeedHandle.Position = UDim2.new(fraction, 0, 0.5, 0)
    SpeedLabel.Text      = "Speed: " .. string.format("%.1f", speed)
    SpeedValueBox.Text   = string.format("%.1f", speed)
    if State.isReanimated then
        pcall(function() ReanimateAPI.set_animation_speed(speed) end)
    end
end

ApplySpeed(1.0)

SpeedTrack.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingSpeed = true
        local pct = (inp.Position.X - SpeedTrack.AbsolutePosition.X) / SpeedTrack.AbsoluteSize.X
        ApplySpeed(0.1 + pct * 3.9)
    end
end)
SpeedTrack.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then isDraggingSpeed = false end
end)
UserInputService.InputChanged:Connect(function(inp)
    if isDraggingSpeed and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local pct = (inp.Position.X - SpeedTrack.AbsolutePosition.X) / SpeedTrack.AbsoluteSize.X
        ApplySpeed(0.1 + pct * 3.9)
    end
end)
SpeedValueBox.FocusLost:Connect(function()
    local v = tonumber(SpeedValueBox.Text)
    if v then ApplySpeed(v)
    else SpeedValueBox.Text = string.format("%.1f", State.currentSpeed) end
end)

local VERTICAL_OFFSET = 3

local function isValidTeleportPosition(targetPart, targetPosition)
    if not targetPart then
        return false
    end
    if targetPart.Transparency >= 1 and targetPart.CanCollide then
        return false
    end
    if targetPosition.Y < -100 then
        return false
    end
    return true
end

local function doMouseTeleport()
    local player = plr or game:GetService("Players").LocalPlayer
    if not player then return end
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not rootPart then return end
    
    local mouse = Mouse or player:GetMouse()
    if not mouse then return end
    local target = mouse.Hit
    local targetPart = mouse.Target
    if not target then return end
    if not isValidTeleportPosition(targetPart, target.Position) then return end
    
    local teleportPosition = target.Position + Vector3.new(0, VERTICAL_OFFSET, 0)
    local moveOffset = teleportPosition - rootPart.Position
    rootPart.CFrame = rootPart.CFrame + moveOffset

    -- Sync reanimated models if active
    local api = ReanimateAPI or _G._HaloReanimateAPI
    if api then
        local models = {}
        local seen = { [character] = true }
        if api.get_clone then
            local cl = api.get_clone(player)
            if cl and cl:IsA("Model") and not seen[cl] then seen[cl] = true table.insert(models, cl) end
        end
        if api.get_real_character then
            local rc = api.get_real_character(player)
            if rc and rc:IsA("Model") and not seen[rc] then seen[rc] = true table.insert(models, rc) end
        end
        for _, m in ipairs(models) do
            local hrp = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso") or m:FindFirstChild("UpperTorso") or m.PrimaryPart
            if hrp then
                hrp.CFrame = hrp.CFrame + moveOffset
            end
        end
    end
end
_G._HaloDoMouseTeleport = doMouseTeleport

_G._HaloReanimConns = _G._HaloReanimConns or {}
_G._HaloReanimConns.KeybindInputBegan = UserInputService.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(input, gameProcessed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local kc = input.KeyCode

    if _G._HaloTeleportKey and kc == _G._HaloTeleportKey then
        if UserInputService:GetFocusedTextBox() then return end
        pcall(doMouseTeleport)
        return
    end

    if GlobalReverseKeybind and kc == GlobalReverseKeybind then
        -- Don't trigger rewind while the user is typing in chat or another
        -- input box (gameProcessed is true).
        if gameProcessed or UserInputService:GetFocusedTextBox() then return end
        if State.isReanimated and ReanimateAPI and ReanimateAPI.set_animation_speed then
            local speed = tonumber(GlobalReverseSpeed) or 1.0
            if speed <= 0 then speed = 1.0 end
            pcall(ReanimateAPI.set_animation_speed, -speed)
        end
        return
    end

    if _G._HaloInstantResetKey and kc == _G._HaloInstantResetKey then
        if gameProcessed then return end
        local char = plr.Character
        if not char then return end

        -- Cooldown so you can't spam-break it
        if _G._HaloResetLastTick and (tick() - _G._HaloResetLastTick < 0.8) then return end
        _G._HaloResetLastTick = tick()

        local savedCF = nil
        local wasReanimated = State.isReanimated
        if wasReanimated and ReanimateAPI and ReanimateAPI.get_clone then
            local clone = ReanimateAPI.get_clone(plr)
            if clone then
                local cloneHRP = clone:FindFirstChild("HumanoidRootPart")
                if cloneHRP then savedCF = cloneHRP.CFrame end
            end
        end
        if not savedCF then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then savedCF = hrp.CFrame end
        end

        -- Disable reanimation before killing so respawn works normally
        if State.isReanimated then
            pcall(function() ReanimateAPI.reanimate(false) end)
            State.isReanimated = false
            UpdateToggleBtn()
        end

        -- INSTANT RESPAWN: remove Roblox's built-in respawn delay
        local Players = game:GetService("Players")
        local oldRespawnTime = Players.RespawnTime
        Players.RespawnTime = 0

        -- Skip death animation
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local animator = hum:FindFirstChildOfClass("Animator")
            if animator then
                pcall(function()
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        track:Stop(0)
                    end
                end)
            end
            local animate = char:FindFirstChild("Animate")
            if animate then pcall(function() animate.Disabled = true end) end
            hum.Health = 0
        end

        -- Restore normal respawn time after we respawn
        task.delay(0.6, function()
            pcall(function() Players.RespawnTime = oldRespawnTime end)
        end)

        if savedCF then
            local spawnConn
            spawnConn = plr.CharacterAdded:Connect(function(newChar)
                spawnConn:Disconnect()
                -- Snap to saved position on the very next physics tick
                local hbConn
                hbConn = game:GetService("RunService").Heartbeat:Connect(function()
                    hbConn:Disconnect()
                    local hrp = newChar:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        pcall(function()
                            hrp.CFrame = savedCF
                            hrp.Velocity = Vector3.zero
                            hrp.RotVelocity = Vector3.zero
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            hrp.AssemblyAngularVelocity = Vector3.zero
                        end)
                    end
                    if wasReanimated then
                        pcall(function() ReanimateAPI.reanimate(true) end)
                        State.isReanimated = ReanimateAPI and ReanimateAPI.is_reanimated() or false
                        UpdateToggleBtn()
                        local newClone = ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
                        if newClone then
                            local newCloneHRP = newClone:FindFirstChild("HumanoidRootPart")
                            if newCloneHRP then
                                pcall(function()
                                    newCloneHRP.CFrame = savedCF
                                    newCloneHRP.Velocity = Vector3.zero
                                    newCloneHRP.RotVelocity = Vector3.zero
                                    newCloneHRP.AssemblyLinearVelocity = Vector3.zero
                                    newCloneHRP.AssemblyAngularVelocity = Vector3.zero
                                end)
                            end
                        end
                    end
                end)
            end)
        end
        return
    end

    -- Left Arm Pointer keybind toggle
    if _G._HaloLeftArmKey and kc == _G._HaloLeftArmKey then
        if gameProcessed then return end
        if not State.isReanimated then
            Notify("Turn on Reanimation first!", 2)
            return
        end
        _G._HaloLeftArmPointerEnabled = not (_G._HaloLeftArmPointerEnabled or false)
        if _G._HaloLeftArmPointerEnabled then
            _G._HaloLeftArmPointerNeedsReset = true
        end
        if _G._HaloUpdateLeftArmPointerUI then _G._HaloUpdateLeftArmPointerUI() end
        Notify("Left Arm Pointer: " .. (_G._HaloLeftArmPointerEnabled and "ON" or "OFF"), 2)
        return
    end

    -- Right Arm Pointer keybind toggle
    if _G._HaloRightArmKey and kc == _G._HaloRightArmKey then
        if gameProcessed then return end
        if not State.isReanimated then
            Notify("Turn on Reanimation first!", 2)
            return
        end
        _G._HaloRightArmPointerEnabled = not (_G._HaloRightArmPointerEnabled or false)
        if _G._HaloRightArmPointerEnabled then
            _G._HaloRightArmPointerNeedsReset = true
        end
        if _G._HaloUpdateRightArmPointerUI then _G._HaloUpdateRightArmPointerUI() end
        Notify("Right Arm Pointer: " .. (_G._HaloRightArmPointerEnabled and "ON" or "OFF"), 2)
        return
    end

    -- Player Tracker keybind toggle
    if _G._HaloTrackerKey and kc == _G._HaloTrackerKey then
        if gameProcessed then return end
        trEnabled = not trEnabled
        
        if trEnabled then
            
            Notify("Player Tracker: ON", 2)
        else
            
            Notify("Player Tracker: OFF", 2)
        end
        return
    end

    -- Head Tracker keybind toggle
    if _G._HaloHeadTrackerKey and kc == _G._HaloHeadTrackerKey then
        if gameProcessed then return end
        if not State.isReanimated then
            Notify("Turn on Reanimation first!", 2)
            return
        end
        _G._HaloHeadTrackerEnabled = not (_G._HaloHeadTrackerEnabled or false)
        if _G._HaloUpdateHeadTrackerUI then _G._HaloUpdateHeadTrackerUI() end
        Notify("Head Tracker: " .. (_G._HaloHeadTrackerEnabled and "ON" or "OFF"), 2)
        return
    end

    if _G._HaloListeningSpeedIdx then
        local idx = _G._HaloListeningSpeedIdx; _G._HaloListeningSpeedIdx = nil
        if kc == Enum.KeyCode.Escape then
            local sk = SpeedKeybinds[idx]; local b = speedKeyWidgets[idx].kbtn
            b.Text = sk.key and ("["..sk.key.Name.."]") or "[+]"
            b.BackgroundColor3 = sk.key and C.bg3 or C.bg2
            b.TextColor3 = sk.key and C.accent or C.text3
            return
        end
        for j = 1, 6 do
            if j ~= idx and SpeedKeybinds[j].key == kc then
                SpeedKeybinds[j].key = nil
                speedKeyWidgets[j].kbtn.Text = "[+]"
                speedKeyWidgets[j].kbtn.BackgroundColor3 = C.bg2
                speedKeyWidgets[j].kbtn.TextColor3 = C.text3
            end
        end
        SpeedKeybinds[idx].key = kc
        local b = speedKeyWidgets[idx].kbtn
        b.Text = "["..kc.Name.."]"; b.BackgroundColor3 = C.bg3
        b.TextColor3 = C.accent
        -- If linked, also set the reverse speed keybind
        if linkRevToNormal and revSpeedKeyWidgets[idx] then
            ReverseSpeedKeybinds[idx].key = kc
            local rb = revSpeedKeyWidgets[idx].kbtn
            rb.Text = "["..kc.Name.."]"; rb.BackgroundColor3 = C.bg3
            rb.TextColor3 = Color3.fromRGB(255,130,130)
        end
        SaveData(); return
    end

    if _G._HaloListeningRevSpeedIdx then
        local idx = _G._HaloListeningRevSpeedIdx; _G._HaloListeningRevSpeedIdx = nil
        if kc == Enum.KeyCode.Escape then
            local sk = ReverseSpeedKeybinds[idx]; local b = revSpeedKeyWidgets[idx].kbtn
            b.Text = sk.key and ("["..sk.key.Name.."]") or "[+]"
            b.BackgroundColor3 = sk.key and C.bg3 or C.bg2
            b.TextColor3 = sk.key and Color3.fromRGB(255,130,130) or C.text3
            return
        end
        for j = 1, 6 do
            if j ~= idx and ReverseSpeedKeybinds[j].key == kc then
                ReverseSpeedKeybinds[j].key = nil
                revSpeedKeyWidgets[j].kbtn.Text = "[+]"
                revSpeedKeyWidgets[j].kbtn.BackgroundColor3 = C.bg2
                revSpeedKeyWidgets[j].kbtn.TextColor3 = C.text3
            end
        end
        ReverseSpeedKeybinds[idx].key = kc
        local b = revSpeedKeyWidgets[idx].kbtn
        b.Text = "["..kc.Name.."]"; b.BackgroundColor3 = C.bg3
        b.TextColor3 = Color3.fromRGB(255,130,130)
        SaveData(); return
    end

    if _G._HaloListeningKeyBtn then
        if kc == Enum.KeyCode.Escape then CancelListening(); Notify("Keybind cancelled", 1.5); return end
        BindKey(kc); return
    end

    for i = 1, 6 do
        if SpeedKeybinds[i].key == kc then
            ApplySpeed(SpeedKeybinds[i].speed)
            -- If linked, also check reverse
            if linkRevToNormal and State.isReanimated and ReanimateAPI and ReanimateAPI.set_animation_speed then
                pcall(ReanimateAPI.set_animation_speed, -ReverseSpeedKeybinds[i].speed)
            end
            return
        end
    end

    for i = 1, 6 do
        if ReverseSpeedKeybinds[i].key == kc then
            if State.isReanimated and ReanimateAPI and ReanimateAPI.set_animation_speed then
                pcall(ReanimateAPI.set_animation_speed, -ReverseSpeedKeybinds[i].speed)
            end
            return
        end
    end

    if gameProcessed then return end

    for animName, data in pairs(Keybinds) do
        if data.key == kc then
            if not State.isReanimated then return end
            -- Skip if user is typing in a text box, but allow otherwise
            -- even when gameProcessed is true (some games set it inconsistently)
            local typing = false
            pcall(function()
                local guiService = game:GetService("GuiService")
                if guiService:GetFocusedTextBox() then typing = true end
            end)
            if typing then return end
            local customPlain = animName:match("^%[Custom%] (.+)$")
            if customPlain then
                PlayAnimation(animName, State.currentSpeed, true)
            else
                local url = AnimationList[animName]
                if url then
                    PlayAnimation(animName, State.currentSpeed, false)
                end
            end
            break
        end
    end
end))

_G._HaloReanimConns = _G._HaloReanimConns or {}
_G._HaloReanimConns.KeybindInputEnded = UserInputService.InputEnded:Connect(LPH_NO_VIRTUALIZE(function(input, gameProcessed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local kc = input.KeyCode
    if GlobalReverseKeybind and kc == GlobalReverseKeybind then
        if State.isReanimated and ReanimateAPI and ReanimateAPI.set_animation_speed then
            local resumeSpeed = tonumber(State.currentSpeed) or 1.0
            pcall(ReanimateAPI.set_animation_speed, resumeSpeed)
        end
    end
end))

local Camera = workspace.CurrentCamera

function isShiftLockActive()
    return UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
        and Camera.CameraType == Enum.CameraType.Custom
end

local _lastApiCheck  = 0
local _lastAnimCheck = 0


-- 4. VC Bypass Frame
local vcFrame = Instance.new("Frame", SettingsPanel)
vcFrame.Size = UDim2.new(1,0,0,90)
vcFrame.BackgroundColor3 = C.bg1; vcFrame.BackgroundTransparency = 0.4; vcFrame.BorderSizePixel = 0
vcFrame.LayoutOrder = 4
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,7); c.Parent = vcFrame
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = vcFrame
end

local vcLbl = Instance.new("TextLabel", vcFrame)
vcLbl.BackgroundTransparency = 1; vcLbl.Position = UDim2.new(0,10,0,6)
vcLbl.Size = UDim2.new(1,-120,0,16); vcLbl.Font = Enum.Font.GothamBold
vcLbl.Text = "VC Bypass"; vcLbl.TextColor3 = C.text; vcLbl.TextSize = 11
vcLbl.TextXAlignment = Enum.TextXAlignment.Left

local vcSub = Instance.new("TextLabel", vcFrame)
vcSub.BackgroundTransparency = 1; vcSub.Position = UDim2.new(0,10,0,24)
vcSub.Size = UDim2.new(1,-120,0,24); vcSub.Font = Enum.Font.Gotham
vcSub.Text = "Select a voice chat bypass method"; vcSub.TextColor3 = C.text3; vcSub.TextSize = 9
vcSub.TextXAlignment = Enum.TextXAlignment.Left; vcSub.TextWrapped = true

local masklolBtn = Instance.new("TextButton", vcFrame)
masklolBtn.Size = UDim2.new(0,130,0,28); masklolBtn.Position = UDim2.new(0,10,0,54)
masklolBtn.BackgroundColor3 = C.bg2; masklolBtn.BackgroundTransparency = 0.2; masklolBtn.BorderSizePixel = 0
masklolBtn.Font = Enum.Font.GothamBold; masklolBtn.Text = "(masklol) vcbypass"
masklolBtn.TextColor3 = C.accent; masklolBtn.TextSize = 10; masklolBtn.AutoButtonColor = false
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = masklolBtn
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = masklolBtn
end

local unicornsBtn = Instance.new("TextButton", vcFrame)
unicornsBtn.Size = UDim2.new(0,130,0,28); unicornsBtn.Position = UDim2.new(0,150,0,54)
unicornsBtn.BackgroundColor3 = C.bg2; unicornsBtn.BackgroundTransparency = 0.2; unicornsBtn.BorderSizePixel = 0
unicornsBtn.Font = Enum.Font.GothamBold; unicornsBtn.Text = "(uni's) vcbypass"
unicornsBtn.TextColor3 = C.accent; unicornsBtn.TextSize = 10; unicornsBtn.AutoButtonColor = false
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = unicornsBtn
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Transparency = 0.7; s.Thickness = 1; s.Parent = unicornsBtn
end

masklolBtn.MouseButton1Click:Connect(function()
    pcall(applyVCBypass)
    Notify("(masklol) VC Bypass applied", 3)
end)

unicornsBtn.MouseButton1Click:Connect(function()
    pcall(function()
        loadstring(game:HttpGet("https://shield.xao.wtf/api/loader/550af30c-aaa3-4338-acab-f44010a5ef09"))()
    end)
    Notify("(uni's) VC Bypass applied", 3)
end)


-- ============================================
-- VC BYPASS INTEGRATION
-- ============================================
local VCBypassEnabled = false
local VCBypassConns = {}
local VCBypassObjs = {}

local function cleanupVCBypass()
    for _, conn in ipairs(VCBypassConns) do
        pcall(function() conn:Enable() end)
    end
    table.clear(VCBypassConns)

    if VCBypassObjs.cloned then pcall(function() VCBypassObjs.cloned:Destroy() end) end
    if VCBypassObjs.hidden then pcall(function() VCBypassObjs.hidden:Destroy() end) end

    if VCBypassObjs.original and VCBypassObjs.container then
        pcall(function() VCBypassObjs.original.Parent = VCBypassObjs.container end)
    end

    pcall(function()
        local vcs = (cloneref or function(...) return ... end)(game:GetService("VoiceChatService"))
        vcs:leaveVoice()
        task.wait(0.5)
        vcs:joinVoice()
    end)

    VCBypassObjs = {}
    VCBypassEnabled = false
    pcall(function()
        writefile(fpath("ReanimVCBypass.json"), HttpService:JSONEncode({enabled = false}))
    end)
end

local function applyUnicornsVCBypass()
    pcall(function()
        loadstring(game:HttpGet("https://shield.xao.wtf/api/loader/550af30c-aaa3-4338-acab-f44010a5ef09"))()
    end)
end

local function applyVCBypass()
    if VCBypassEnabled then return end
    VCBypassEnabled = true

    pcall(function()
        writefile(fpath("ReanimVCBypass.json"), HttpService:JSONEncode({enabled = true}))
    end)

    task.spawn(function()
        local identifyexecutorname = (identifyexecutor and identifyexecutor()) or "Unknown"
        local clonereference = cloneref or function(...) return ... end
        local clonefunction = clonefunction or function(...) return ... end

        local voicechatservice = clonereference(game:GetService("VoiceChatService"))
        local voicechatinternal = clonereference(game:GetService("VoiceChatInternal"))
        local coregui = game:GetService("CoreGui")
        local startergui = game:GetService("StarterGui")
        local players = game:GetService("Players")
        local localplayer = players.LocalPlayer
        local getconnectionsfunc = clonefunction(getconnections)

        local mutedimage = "rbxasset://textures/ui/VoiceChat/MicLight/Muted.png"
        local hiddenfolder = Instance.new("Folder", game:GetService("RobloxReplicatedStorage"))
        hiddenfolder.Name = "HaloVCBypass"
        VCBypassObjs.hidden = hiddenfolder

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
            voicechatservice:joinVoice() 
            pcall(function()
                unibarcontainer = unibarmenu:WaitForChild("2", 15):WaitForChild("3", 15)
                micmutebutton = unibarcontainer:WaitForChild("toggle_mic_mute", 15)
            end)
        end

        if not micmutebutton then 
            VCBypassEnabled = false
            Notify("VC Bypass Error", "Mic button not found", 3)
            return 
        end

        startergui:SetCore("SendNotification", {Title = "Freedom Of Speech", Text = "Unmute to continue.", Duration = 5})

        repeat task.wait(2) until geticonlabel().Image ~= mutedimage

        voicechatservice:leaveVoice()
        task.wait(2)

        local connections = getconnectionsfunc(voicechatinternal.StateChanged)
        for i = 7, #connections do 
            if connections[i] then 
                connections[i]:Disable() 
                table.insert(VCBypassConns, connections[i])
            end 
        end

        task.wait(2)
        voicechatservice:joinVoice()

        pcall(function()
            unibarcontainer = unibarmenu:WaitForChild("2", 15):WaitForChild("3", 15)
            micmutebutton = unibarcontainer:WaitForChild("toggle_mic_mute", 15)
        end)

        if micmutebutton and unibarcontainer then
            local clonedmutebutton = micmutebutton:Clone()
            micmutebutton.Parent = hiddenfolder
            clonedmutebutton.Name = "toggle_mic_mute_new"
            clonedmutebutton.Parent = unibarcontainer
            VCBypassObjs.cloned = clonedmutebutton
            VCBypassObjs.original = micmutebutton
            VCBypassObjs.container = unibarcontainer

            local clonedicon = geticonlabel(clonedmutebutton)
            local originalicon = geticonlabel(micmutebutton)

            setmutestate(true)
            clonedicon.Image = mutedimage

            clonedmutebutton:WaitForChild("IconHitArea_toggle_mic_mute", 15).Activated:Connect(function()
                local newstate = not getcurrentmutestate()
                setmutestate(newstate)
                if newstate then
                    clonedicon.Image = mutedimage
                else
                    clonedicon.Image = originalicon.Image
                end
            end)
        end
    end)
end
local function buildSettingsUI()
        local sc = SettingsPanel
        local fnGui


    -- FPS Limiter Toggle
    local fpsFrame = new("Frame",sc,{Size=UDim2.new(1,-10,0,60),BackgroundColor3=C.bg2,BackgroundTransparency=0.45,BorderSizePixel=0})
    corner(fpsFrame,8); stroke(fpsFrame,C.glassBorder,1,0.6)

    new("TextLabel",fpsFrame,{Size=UDim2.new(1,-120,0,18),Position=UDim2.new(0,10,0,10),
        BackgroundTransparency=1,Text="FPS Limiter",TextColor3=C.text,TextSize=11,
        Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})

    new("TextLabel",fpsFrame,{Size=UDim2.new(1,-130,0,20),Position=UDim2.new(0,10,0,28),
        BackgroundTransparency=1,Text="Limits UI updates to improve performance on low-end devices.",
        TextColor3=C.text3,TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})

    local fpsToggleBg = new("Frame",fpsFrame,{Size=UDim2.new(0,44,0,22),Position=UDim2.new(1,-54,0,19),
        BackgroundColor3=C.bg4,BorderSizePixel=0}); corner(fpsToggleBg,11)
    local fpsToggleKnob = new("Frame",fpsToggleBg,{
        Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,3,0,3),
        BackgroundColor3=C.white,BorderSizePixel=0}); corner(fpsToggleKnob,8)
    local fpsToggleBtn = new("TextButton",fpsToggleBg,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""})

    local FPSLimiterEnabled = false
    local function updateFPSLimiterState()
        if FPSLimiterEnabled then
            tw(fpsToggleBg, 0.2, {BackgroundColor3 = C.green}):Play()
            tw(fpsToggleKnob, 0.2, {Position = UDim2.new(1,-18,0,3)}):Play()
            _G._HaloFPSLimit = true
        else
            tw(fpsToggleBg, 0.2, {BackgroundColor3 = C.bg4}):Play()
            tw(fpsToggleKnob, 0.2, {Position = UDim2.new(0,3,0,3)}):Play()
            _G._HaloFPSLimit = false
        end
    end
    fpsToggleBtn.MouseButton1Click:Connect(function()
        FPSLimiterEnabled = not FPSLimiterEnabled
        updateFPSLimiterState()
    end)


    -- Ghost Trails (Neon Visual Trail)
    local ghostFrame = new("Frame",sc,{Size=UDim2.new(1,-10,0,60),BackgroundColor3=C.bg2,BackgroundTransparency=0.45,BorderSizePixel=0})
    corner(ghostFrame,8); stroke(ghostFrame,C.glassBorder,1,0.6)

    new("TextLabel",ghostFrame,{Size=UDim2.new(1,-120,0,18),Position=UDim2.new(0,10,0,10),
        BackgroundTransparency=1,Text="Ghost Echo Trails",TextColor3=C.text,TextSize=11,
        Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})

    new("TextLabel",ghostFrame,{Size=UDim2.new(1,-130,0,20),Position=UDim2.new(0,10,0,28),
        BackgroundTransparency=1,Text="Creates premium neon ghost trails that mimic your active animations with a smooth fade.",
        TextColor3=C.text3,TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})

    local ghostToggleBg = new("Frame",ghostFrame,{Size=UDim2.new(0,44,0,22),Position=UDim2.new(1,-54,0,19),
        BackgroundColor3=C.bg4,BorderSizePixel=0}); corner(ghostToggleBg,11)
    local ghostToggleKnob = new("Frame",ghostToggleBg,{
        Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,3,0,3),
        BackgroundColor3=C.white,BorderSizePixel=0}); corner(ghostToggleKnob,8)
    local ghostToggleBtn = new("TextButton",ghostToggleBg,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""})

    local GhostTrailEnabled = false
    local ghostTrailConn = nil
    local lastGhostTime = 0

    local function spawnGhostClone()
        local char = plr.Character
        if not char then return end
        
        local ghostModel = Instance.new("Model")
        ghostModel.Name = "HaloGhostTrail"
        ghostModel.Parent = workspace
        
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 1 and part.Name ~= "HumanoidRootPart" and not part.Parent:IsA("Accessory") then
                local clone = Instance.new("Part")
                clone.Size = part.Size
                clone.CFrame = part.CFrame
                clone.Color = C.accent
                clone.Material = Enum.Material.Neon
                clone.CanCollide = false
                clone.Anchored = true
                clone.Transparency = 0.55
                clone.Parent = ghostModel
                
                local twInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tw = game:GetService("TweenService"):Create(clone, twInfo, {Transparency = 1})
                tw:Play()
            end
        end
        
        task.delay(0.5, function()
            ghostModel:Destroy()
        end)
    end

    local function updateGhostTrailState()
    if GhostTrailEnabled then
            tw(ghostToggleBg, 0.2, {BackgroundColor3 = C.green}):Play()
            tw(ghostToggleKnob, 0.2, {Position = UDim2.new(1,-18,0,3)}):Play()
            
            if ghostTrailConn then ghostTrailConn:Disconnect() end
            ghostTrailConn = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
                local now = tick()
                if now - lastGhostTime >= 0.25 then
                    lastGhostTime = now
                    pcall(spawnGhostClone)
                end
            end))
        else
            tw(ghostToggleBg, 0.2, {BackgroundColor3 = C.bg4}):Play()
            tw(ghostToggleKnob, 0.2, {Position = UDim2.new(0,3,0,3)}):Play()
            if ghostTrailConn then
                ghostTrailConn:Disconnect()
                ghostTrailConn = nil
            end
        end
    end

    ghostToggleBtn.MouseButton1Click:Connect(function()
        GhostTrailEnabled = not GhostTrailEnabled
        updateGhostTrailState()
    end)


    -- (Head Tracker, Arm Pointers, and Arm Stretch moved to Limbs Panel)


    _G.HaloHiddenPlayers = _G.HaloHiddenPlayers or {}
    _G.FriendListenerEnabled = false
    _G.FriendListenerAutoExecute = false

    local friendCache = {}
    local function cacheFriendship(p)
        if p == plr then return end
        task.spawn(function()
            local success, result = pcall(function()
                return plr:IsFriendsWith(p.UserId)
            end)
            if success then
                friendCache[p.UserId] = result
            end
        end)
    end
    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        cacheFriendship(p)
    end
    game:GetService("Players").PlayerAdded:Connect(cacheFriendship)

    local function isFriend(userId)
        if userId == plr.UserId then return true end
        if friendCache[userId] ~= nil then
            return friendCache[userId]
        end
        return false
    end

    -- Multi-layered State Manager
    local function getShouldMute(userId)
        if userId == plr.UserId then return false end
        _G.HaloHiddenPlayers = _G.HaloHiddenPlayers or {}
        local isHidden = _G.HaloHiddenPlayers[userId]
        local isFriendUser = isFriend(userId)
        local shouldMute = isHidden or (_G.FriendListenerEnabled and not isFriendUser)
        return shouldMute
    end

    local function updatePlayerState(p)
        if not p or p == plr then return end
        local shouldHide = _G.HaloHiddenPlayers and _G.HaloHiddenPlayers[p.UserId]
        local shouldMute = shouldHide or (_G.FriendListenerEnabled and not isFriend(p.UserId))

        -- 1. Roblox Core Muting (if supported by game setup)
        if shouldMute then
            pcall(function() game:GetService("StarterGui"):SetCore("ChatMutePlayer", p.Name) end)
        else
            pcall(function() game:GetService("StarterGui"):SetCore("ChatUnmutePlayer", p.Name) end)
        end

        -- 2. Visual Hiding (Local Parenting manipulation)
        local char = p.Character
        if char then
            if shouldHide then
                char.Parent = nil
            else
                if char.Parent == nil then
                    char.Parent = workspace
                end
            end
        end
    end

    local function applyAllMutes()
        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
            updatePlayerState(p)
        end
    end
    _G.HaloApplyAllMutes = applyAllMutes

    -- Monitor Character additions
    local function hookCharacter(p)
        p.CharacterAdded:Connect(function(char)
            task.wait(0.1)
            updatePlayerState(p)
        end)
        if p.Character then
            updatePlayerState(p)
        end
    end
    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p ~= plr then hookCharacter(p) end
    end
    game:GetService("Players").PlayerAdded:Connect(function(p)
        if p ~= plr then hookCharacter(p) end
    end)

    -- Modern Chat (TextChatService) Callback
    pcall(function()
        local TextChatService = game:GetService("TextChatService")
        local oldCallback = TextChatService.OnIncomingMessage
        TextChatService.OnIncomingMessage = function(message)
            local props = oldCallback and oldCallback(message) or Instance.new("TextChatMessageProperties")
            if message.TextSource then
                if getShouldMute(message.TextSource.UserId) then
                    props.Text = ""
                    props.PrefixText = ""
                end
            end
            return props
        end
    end)

    -- Modern Chat MessageReceived Hook
    pcall(function()
        local TextChatService = game:GetService("TextChatService")
        TextChatService.MessageReceived:Connect(function(textMessage)
            if textMessage.TextSource then
                if getShouldMute(textMessage.TextSource.UserId) then
                    local p = game:GetService("Players"):GetPlayerByUserId(textMessage.TextSource.UserId)
                    if p then
                        pcall(function() game:GetService("StarterGui"):SetCore("ChatMutePlayer", p.Name) end)
                    end
                end
            end
        end)
    end)

    -- Legacy Chat Scroller Listener (with Text property monitoring)
    local function setupScrollerListener(scroller)
        local function handleMessageFrame(child)
            if not child:IsA("Frame") then return end
            task.spawn(function()
                local textLabel = child:WaitForChild("TextLabel", 2)
                if textLabel and textLabel:IsA("TextLabel") then
                    local function checkText()
                        local text = textLabel.Text
                        if text ~= "" then
                            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                                if getShouldMute(p.UserId) then
                                    if text:find(p.Name) or text:find(p.DisplayName) then
                                        child:Destroy()
                                        break
                                    end
                                end
                            end
                        end
                    end
                    textLabel:GetPropertyChangedSignal("Text"):Connect(checkText)
                    checkText()
                end
            end)
        end
        scroller.ChildAdded:Connect(handleMessageFrame)
        for _, child in ipairs(scroller:GetChildren()) do
            handleMessageFrame(child)
        end
    end

    -- Hook legacy chat scroller immediately and if recreated
    task.spawn(function()
        local chatGui = plr:WaitForChild("PlayerGui"):WaitForChild("Chat", 10)
        if chatGui then
            local scroller = chatGui:FindFirstChild("Scroller", true)
            if scroller then setupScrollerListener(scroller) end
            chatGui.DescendantAdded:Connect(function(desc)
                if desc.Name == "Scroller" and desc:IsA("ScrollingFrame") then
                    setupScrollerListener(desc)
                end
            end)
        end
    end)

    -- Update mutes when players join/leave
    game:GetService("Players").PlayerAdded:Connect(function(p)
        applyAllMutes()
    end)

    -- Handle Toggle Calls
    _G.UpdateFriendListener = function(state)
        _G.FriendListenerEnabled = state
        applyAllMutes()
    end

    -- Load Friend Config
    pcall(function()
        if readfile and isfile and isfile("HaloV2Folder/friend_listener_config.json") then
            local data = game:GetService("HttpService"):JSONDecode(readfile("HaloV2Folder/friend_listener_config.json"))
            if data then
                _G.FriendListenerAutoExecute = data.autoExecute or false
                if _G.FriendListenerAutoExecute then
                    _G.FriendListenerEnabled = true
                    _G.UpdateFriendListener(true)
                end
            end
        end
    end)

    -- Fling Aura (Kill / Fling other players on contact)
    local flingAuraFrame = new("Frame",sc,{Size=UDim2.new(1,-10,0,60),BackgroundColor3=C.bg2,BackgroundTransparency=0.45,BorderSizePixel=0})
    corner(flingAuraFrame,8); stroke(flingAuraFrame,C.glassBorder,1,0.6)

    new("TextLabel",flingAuraFrame,{Size=UDim2.new(1,-120,0,18),Position=UDim2.new(0,10,0,10),
        BackgroundTransparency=1,Text="Fling Aura",TextColor3=C.text,TextSize=11,
        Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})

    new("TextLabel",flingAuraFrame,{Size=UDim2.new(1,-130,0,20),Position=UDim2.new(0,10,0,28),
        BackgroundTransparency=1,Text="Spins your physical character parts at extreme velocity to fling players on touch.",
        TextColor3=C.text3,TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})

    local flingToggleBg = new("Frame",flingAuraFrame,{Size=UDim2.new(0,44,0,22),Position=UDim2.new(1,-54,0,19),
        BackgroundColor3=C.bg4,BorderSizePixel=0}); corner(flingToggleBg,11)
    local flingToggleKnob = new("Frame",flingToggleBg,{
        Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,3,0,3),
        BackgroundColor3=C.white,BorderSizePixel=0}); corner(flingToggleKnob,8)
    local flingToggleBtn = new("TextButton",flingToggleBg,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""})

    local FlingAuraEnabled = false
    local flingAuraConn = nil

    local function updateFlingAuraState()
        if FlingAuraEnabled then
            tw(flingToggleBg, 0.2, {BackgroundColor3 = C.green}):Play()
            tw(flingToggleKnob, 0.2, {Position = UDim2.new(1,-18,0,3)}):Play()
            
            -- Spin loop
            if flingAuraConn then flingAuraConn:Disconnect() end
            flingAuraConn = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
                local char = plr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.RotVelocity = Vector3.new(0, 15000, 0)
                    hrp.Velocity = Vector3.new(0, 0.1, 0)
                end
            end))
        else
            tw(flingToggleBg, 0.2, {BackgroundColor3 = C.bg4}):Play()
            tw(flingToggleKnob, 0.2, {Position = UDim2.new(0,3,0,3)}):Play()
            if flingAuraConn then
                flingAuraConn:Disconnect()
                flingAuraConn = nil
            end
        end
    end

    flingToggleBtn.MouseButton1Click:Connect(function()
        FlingAuraEnabled = not FlingAuraEnabled
        updateFlingAuraState()
    end)

    -- Mobile Emote Wheel Button (draggable, for mobile/touch players)
    local mobileWheelFrame = new("Frame",sc,{Size=UDim2.new(1,-10,0,60),BackgroundColor3=C.bg2,BackgroundTransparency=0.45,BorderSizePixel=0})
    corner(mobileWheelFrame,8); stroke(mobileWheelFrame,C.glassBorder,1,0.6)

    new("TextLabel",mobileWheelFrame,{Size=UDim2.new(1,-120,0,18),Position=UDim2.new(0,10,0,10),
        BackgroundTransparency=1,Text="Mobile Wheel Button",TextColor3=C.text,TextSize=11,
        Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})

    new("TextLabel",mobileWheelFrame,{Size=UDim2.new(1,-130,0,20),Position=UDim2.new(0,10,0,28),
        BackgroundTransparency=1,Text="Draggable on-screen button to open the emote wheel.",
        TextColor3=C.text3,TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})

    local mobileToggleBg = new("Frame",mobileWheelFrame,{Size=UDim2.new(0,44,0,22),Position=UDim2.new(1,-54,0,19),
        BackgroundColor3=C.bg4,BorderSizePixel=0}); corner(mobileToggleBg,11)
    local mobileToggleKnob = new("Frame",mobileToggleBg,{
        Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,3,0,3),
        BackgroundColor3=C.white,BorderSizePixel=0}); corner(mobileToggleKnob,8)
    local mobileToggleBtn = new("TextButton",mobileToggleBg,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""})

    -- 2. Clear Cache section
    local cacheFrame = new("Frame",sc,{Size=UDim2.new(1,-10,0,60),BackgroundColor3=C.bg2,BackgroundTransparency=0.45,BorderSizePixel=0})
    corner(cacheFrame,8); stroke(cacheFrame,C.glassBorder,1,0.6)
    
    new("TextLabel",cacheFrame,{Size=UDim2.new(1,-120,0,18),Position=UDim2.new(0,10,0,10),
        BackgroundTransparency=1,Text="Clear Cache",TextColor3=C.text,TextSize=11,
        Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
        
    new("TextLabel",cacheFrame,{Size=UDim2.new(1,-130,0,20),Position=UDim2.new(0,10,0,28),
        BackgroundTransparency=1,Text="Deletes all cache, including favourites. Keeps custom anims.",
        TextColor3=C.text3,TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})

    local clearCacheBtn = new("TextButton",cacheFrame,{Size=UDim2.new(0,100,0,28),Position=UDim2.new(1,-110,0,16),
        BackgroundColor3=C.red,BackgroundTransparency=0.3,Text="Clear Cache",TextColor3=C.white,
        TextSize=10,Font=Enum.Font.GothamBold,BorderSizePixel=0}); corner(clearCacheBtn,6)

    -- The draggable button itself
    local mobileBtnGui = Instance.new("ScreenGui")
    mobileBtnGui.Name = "HaloMobileWheelBtn"
    mobileBtnGui.ResetOnSpawn = false
    mobileBtnGui.IgnoreGuiInset = true
    mobileBtnGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mobileBtnGui.DisplayOrder = 550
    pcall(function() mobileBtnGui.Parent = game:GetService("CoreGui") end)
    if not mobileBtnGui.Parent then mobileBtnGui.Parent = PlayerGui end

    local mobileBtn = Instance.new("ImageButton", mobileBtnGui)
    mobileBtn.Size = UDim2.new(0, 46, 0, 46)
    mobileBtn.Position = UDim2.new(1, -50, 0.5, 0)
    mobileBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    mobileBtn.BackgroundColor3 = C.bg0
    mobileBtn.BackgroundTransparency = 0.2
    mobileBtn.Image = ""
    mobileBtn.AutoButtonColor = false
    mobileBtn.BorderSizePixel = 0
    mobileBtn.Visible = false
    Instance.new("UICorner", mobileBtn).CornerRadius = UDim.new(0, 10)
    local mobileBtnStroke = Instance.new("UIStroke", mobileBtn)
    mobileBtnStroke.Color = C.glassBorder
    mobileBtnStroke.Thickness = 1
    mobileBtnStroke.Transparency = 0.4

    local mobileBtnIcon = Instance.new("TextLabel", mobileBtn)
    mobileBtnIcon.Size = UDim2.new(1, 0, 1, 0)
    mobileBtnIcon.BackgroundTransparency = 1
    mobileBtnIcon.Text = "E"
    mobileBtnIcon.TextColor3 = C.accent
    mobileBtnIcon.TextSize = 18
    mobileBtnIcon.Font = Enum.Font.GothamBold

    -- Dragging logic
    local draggingMobile = false
    local dragStartMobile, startPosMobile
    local dragMovedMobile = false
    mobileBtn.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingMobile = true
            dragMovedMobile = false
            dragStartMobile = input.Position
            startPosMobile = mobileBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    draggingMobile = false
                end
            end)
        end
    end))
    mobileBtn.InputChanged:Connect(LPH_JIT(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if draggingMobile and dragStartMobile then
                local delta = input.Position - dragStartMobile
                if delta.Magnitude > 4 then dragMovedMobile = true end
                
                -- Same clamp logic as the reanim window: keep the button fully on-screen.
                local parent = mobileBtn.Parent
                if not parent then return end
                local pap    = parent.AbsolutePosition
                local pas    = parent.AbsoluteSize
                local sz     = mobileBtn.AbsoluteSize
                local anchor = mobileBtn.AnchorPoint
                local scaleX = startPosMobile.X.Scale
                local scaleY = startPosMobile.Y.Scale
                local desiredOffsetX = startPosMobile.X.Offset + delta.X
                local desiredOffsetY = startPosMobile.Y.Offset + delta.Y
                local targetAbsX = pap.X + scaleX * pas.X + desiredOffsetX
                local targetAbsY = pap.Y + scaleY * pas.Y + desiredOffsetY
                local topLeftX = targetAbsX - anchor.X * sz.X
                local topLeftY = targetAbsY - anchor.Y * sz.Y
                topLeftX = math.clamp(topLeftX, pap.X, math.max(pap.X, pap.X + pas.X - sz.X))
                topLeftY = math.clamp(topLeftY, pap.Y, math.max(pap.Y, pap.Y + pas.Y - sz.Y))
                local newAbsX = topLeftX + anchor.X * sz.X
                local newAbsY = topLeftY + anchor.Y * sz.Y
                local newOffsetX = newAbsX - pap.X - scaleX * pas.X
                local newOffsetY = newAbsY - pap.Y - scaleY * pas.Y
                mobileBtn.Position = UDim2.new(scaleX, newOffsetX, scaleY, newOffsetY)
            end
        end
    end))

    mobileBtn.MouseButton1Click:Connect(function()
        if dragMovedMobile then return end
        if _G._OpenFortniteWheel then
            _G._OpenFortniteWheel()
        end
    end)

    local mobileEnabled = false

    pcall(function()
        local raw = readfile(CONFIG.FOLDER .. "/ReanimMobileWheelBtn.json")
        if raw then
            local data = HttpService:JSONDecode(raw)
            if data and (data.enabled == true or data.enabled == 1) then
                mobileEnabled = true
                _G._HaloMobileWheelEnabled = true
                mobileBtn.Visible = true
                mobileToggleBg.BackgroundColor3 = C.accent
                mobileToggleKnob.Position = UDim2.new(1,-18,0,3)
            end
            if data and data.posX and data.posY then
                mobileBtn.Position = UDim2.new(data.posX, data.posXO or 0, data.posY, data.posYO or 0)
            end
        end
    end)

    local mobileSavePath = CONFIG.FOLDER .. "/ReanimMobileWheelBtn.json"

    local function saveMobileBtnState()
        local jsonStr = HttpService:JSONEncode({
            enabled = mobileEnabled and 1 or 0,
            posX = mobileBtn.Position.X.Scale,
            posXO = mobileBtn.Position.X.Offset,
            posY = mobileBtn.Position.Y.Scale,
            posYO = mobileBtn.Position.Y.Offset,
        })
        pcall(function() makefolder(CONFIG.FOLDER) end)
        writefile(mobileSavePath, jsonStr)
    end

    local function doMobileToggle()
        mobileEnabled = not mobileEnabled
        mobileBtn.Visible = mobileEnabled
        _G._HaloMobileWheelEnabled = mobileEnabled
        if mobileEnabled then
            tw(mobileToggleBg, 0.2, {BackgroundColor3 = C.accent}):Play()
            tw(mobileToggleKnob, 0.2, {Position = UDim2.new(1,-18,0,3)}):Play()
        else
            tw(mobileToggleBg, 0.2, {BackgroundColor3 = C.bg4}):Play()
            tw(mobileToggleKnob, 0.2, {Position = UDim2.new(0,3,0,3)}):Play()
        end
        pcall(saveMobileBtnState)
        if _G._HaloUpdateMobileBtnText then pcall(_G._HaloUpdateMobileBtnText) end
    end

    _G._HaloToggleMobileWheel = doMobileToggle
    _G._HaloMobileWheelEnabled = mobileEnabled

    mobileToggleBtn.MouseButton1Click:Connect(function()
        doMobileToggle()
    end)

    if ScreenGui then
        ScreenGui.AncestryChanged:Connect(LPH_NO_VIRTUALIZE(function()
            if not ScreenGui.Parent then
                mobileBtn.Visible = false
                if ReanimateAPI and ReanimateAPI.stop_emote_audio then
                    pcall(ReanimateAPI.stop_emote_audio, true)
                end
                if fnGui then
                    pcall(function() fnGui:Destroy() end)
                end
                pcall(function()
                    for _, child in ipairs(game:GetService("SoundService"):GetChildren()) do
                        if child.Name == "HaloEmoteSound" or child.Name == "HaloClickSound" then
                            child:Stop(); child:Destroy()
                        end
                    end
                end)
            end
        end))
    end

    -- Instant Reset Keybind
    local irFrame = new("Frame",sc,{Size=UDim2.new(1,-10,0,54),BackgroundColor3=C.bg2,BackgroundTransparency=0.45,BorderSizePixel=0})
    corner(irFrame,8); stroke(irFrame,C.glassBorder,1,0.6)

    new("TextLabel",irFrame,{Size=UDim2.new(1,-120,0,16),Position=UDim2.new(0,10,0,6),
        BackgroundTransparency=1,Text="Instant Reset Key",TextColor3=C.text,TextSize=11,
        Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})

    new("TextLabel",irFrame,{Size=UDim2.new(1,-120,0,24),Position=UDim2.new(0,10,0,24),
        BackgroundTransparency=1,Text="Press to instantly reset and respawn at the same position.",
        TextColor3=C.text3,TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})

    local irBtn = new("TextButton",irFrame,{Size=UDim2.new(0,96,0,24),Position=UDim2.new(1,-102,0.5,-12),
        BackgroundColor3=C.bg2,BackgroundTransparency=0.2,BorderSizePixel=0,
        Font=Enum.Font.GothamBold,Text="Key: None",TextColor3=C.accent,TextSize=10})
    corner(irBtn,5); stroke(irBtn,C.border,1,0.7)

    local function updateIrBtnText()
        local keyName = _G._HaloInstantResetKey and _G._HaloInstantResetKey.Name or "None"
        irBtn.Text = "Key: " .. keyName
    end
    _G._UniUpdateIrBtnText = updateIrBtnText
    updateIrBtnText()

    local settingIrKey = false
    irBtn.MouseButton1Click:Connect(function()
        if settingIrKey then return end
        if _G._HaloInstantResetKey then
            _G._HaloInstantResetKey = nil
            SaveData()
            updateIrBtnText()
            return
        end
        settingIrKey = true
        irBtn.Text = "Listening..."
        irBtn.BackgroundColor3 = C.yellow
        local keyConn
        keyConn = UserInputService.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(i, gp)
            if gp then return end
            keyConn:Disconnect()
            settingIrKey = false
            irBtn.BackgroundColor3 = C.bg2
            if i.KeyCode == Enum.KeyCode.Escape then
                updateIrBtnText()
                return
            end
            _G._HaloInstantResetKey = i.KeyCode
            SaveData()
            updateIrBtnText()
        end))
    end)

    -- Mouse Teleport Keybind
    local tpFrame = new("Frame",sc,{Size=UDim2.new(1,-10,0,54),BackgroundColor3=C.bg2,BackgroundTransparency=0.45,BorderSizePixel=0})
    corner(tpFrame,8); stroke(tpFrame,C.glassBorder,1,0.6)

    new("TextLabel",tpFrame,{Size=UDim2.new(1,-120,0,16),Position=UDim2.new(0,10,0,6),
        BackgroundTransparency=1,Text="Teleport Key",TextColor3=C.text,TextSize=11,
        Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})

    new("TextLabel",tpFrame,{Size=UDim2.new(1,-120,0,24),Position=UDim2.new(0,10,0,24),
        BackgroundTransparency=1,Text="Press key to instantly teleport to your mouse cursor position.",
        TextColor3=C.text3,TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})

    local tpBtn = new("TextButton",tpFrame,{Size=UDim2.new(0,96,0,24),Position=UDim2.new(1,-102,0.5,-12),
        BackgroundColor3=C.bg2,BackgroundTransparency=0.2,BorderSizePixel=0,
        Font=Enum.Font.GothamBold,Text="Key: None",TextColor3=C.accent,TextSize=10})
    corner(tpBtn,5); stroke(tpBtn,C.border,1,0.7)

    local function updateTpBtnText()
        local keyName = _G._HaloTeleportKey and _G._HaloTeleportKey.Name or "None"
        tpBtn.Text = "Key: " .. keyName
    end
    _G._UniUpdateTpBtnText = updateTpBtnText
    updateTpBtnText()

    local settingTpKey = false
    tpBtn.MouseButton1Click:Connect(function()
        if settingTpKey then return end
        if _G._HaloTeleportKey then
            _G._HaloTeleportKey = nil
            SaveData()
            updateTpBtnText()
            return
        end
        settingTpKey = true
        tpBtn.Text = "Listening..."
        tpBtn.BackgroundColor3 = C.yellow
        local keyConn
        keyConn = UserInputService.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(i, gp)
            if gp then return end
            keyConn:Disconnect()
            settingTpKey = false
            tpBtn.BackgroundColor3 = C.bg2
            if i.KeyCode == Enum.KeyCode.Escape then
                updateTpBtnText()
                return
            end
            _G._HaloTeleportKey = i.KeyCode
            if GlobalReverseKeybind == i.KeyCode then
                GlobalReverseKeybind = nil
                if updateRevBtnText then updateRevBtnText() end
            end
            SaveData()
            updateTpBtnText()
        end))
    end)

    -- Version info / Credits
    local infoFrame = new("Frame",sc,{Size=UDim2.new(1,-10,0,50),BackgroundColor3=C.bg2,BackgroundTransparency=0.6,BorderSizePixel=0})
    corner(infoFrame,8); stroke(infoFrame,C.glassBorder,1,0.6)
    new("TextLabel",infoFrame,{Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1,Text="Halo Reanim\nVersion: " .. CONFIG.VERSION .. " | Best reanim out",
        TextColor3=C.text3,TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Center,TextYAlignment=Enum.TextYAlignment.Center})

    -- Wire up Import from AK button (merged into settings panel handler)

    -- Wire up Clear Cache button
    clearCacheBtn.MouseButton1Click:Connect(function()
        clearCacheBtn.Text = "Clearing..."
        pcall(function()
            local folder = CONFIG.FOLDER
            local cacheFolder = CONFIG.CACHE_FOLDER
            local deleteFunc = delfile or delete_file or (function(path) pcall(writefile, path, "") end)
            local listFilesFunc = listfiles or list_files

            -- 1. Delete known configuration files explicitly (both spellings/formats)
            local knownConfigs = {
                "ReanimFavorites.json",
                "ReanimFavourites.json",
                "ReanimStates.json",
                "ReanimKeybinds.json",
                "ReanimSpeedKeys.json",
                "ReanimRevSpeedKeys.json",
                "ReanimSpeed.json",
                "OnlineAnimationsCache.json",
                "ReanimCustomAnims.json",
                "ReanimTeleportKey.txt",
                "ReanimCmdBarKey.txt",
                "ReanimCmdBarPromptDone.txt",
                "ReanimDiscordPromptDone.txt"
            }
            for _, filename in ipairs(knownConfigs) do
                pcall(deleteFunc, folder .. "/" .. filename)
            end

            -- 2. Clear the cache folder completely (all cached online animation source files)
            local okCache, cacheFiles = pcall(function()
                if listFilesFunc then return listFilesFunc(cacheFolder) end
                return {}
            end)
            if okCache and type(cacheFiles) == "table" then
                for _, file in ipairs(cacheFiles) do
                    pcall(deleteFunc, file)
                end
            end

            -- 3. Delete any other configuration or non-animation files in ReanimData
            local okFolder, folderFiles = pcall(function()
                if listFilesFunc then return listFilesFunc(folder) end
                return {}
            end)
            if okFolder and type(folderFiles) == "table" then
                local ignored = {
                    reanimfavorites = true,
                    reanimfavourites = true,
                    reanimkeybinds = true,
                    reanimspeedkeys = true,
                    reanimstates = true,
                    reanimspeed = true,
                    onlineanimationscache = true
                }
                for _, file in ipairs(folderFiles) do
                    local n = file:match("([^/\\]+)%.[%w]+$")
                    if n then
                        local lowerName = n:lower()
                        local isLua = file:match("%.lua$")
                        local isJson = file:match("%.json$") or file:match("%.txt$")
                        local isAnim = (isLua or isJson) and not file:match("[Ss]ettings") and not file:match("[Cc]onfig") and not lowerName:match("^anim_%d+$") and not ignored[lowerName]
                        
                        if not isAnim then
                            pcall(deleteFunc, file)
                        end
                    elseif not file:match("/$") and not file:match("\\$") then
                        pcall(deleteFunc, file)
                    end
                end
            end

            -- 4. Reset in-memory state
            Favorites = {}
            StateAnims = {}
            Keybinds = {}
            SpeedKeybinds = {}
            for i = 1, 6 do
                SpeedKeybinds[i] = {speed = i * 0.5, key = nil}
            end
            table.clear(AnimationCache)

            -- 5. Reload data defaults and refresh UI
            -- AnimationList is hardcoded; no reload needed
            SaveData()
            RebuildVisible()
            Notify("Cache Cleared", "All settings and caches wiped except custom animations!", 4)
        end)
        clearCacheBtn.Text = "Clear Cache"
    end)
end
buildSettingsUI()

RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
    if not _reanimAPIReady then return end

    local currentTime = tick()

    if currentTime - _lastApiCheck >= 0.5 then
        local apiOk, apiVal = pcall(function() return ReanimateAPI.is_reanimated() end)
        local apiState = apiOk and apiVal or false
        if type(apiState) == "boolean" and apiState ~= State.isReanimated then
            State.isReanimated = apiState
            if not apiState then State.selectedAnim = nil end
            UpdateToggleBtn()
        end
        _lastApiCheck = currentTime
    end

    if State.isReanimated and not State.rawAnimPlaying then
        if currentTime - _lastAnimCheck >= 0.2 then
            local ok, playing = pcall(function() return ReanimateAPI.is_animation_playing() end)
            if ok and not playing and State.selectedAnim then
                State.selectedAnim = nil
                NowPlayingLabel.Text = "No animation playing"
                RefreshVirtualRows()
                RefreshCustomRows()
                if next(StateAnims) and not stateSystemActive then
                    startStateSystem()
                end
            end
            _lastAnimCheck = currentTime
        end
    end
end))

do
    -- Define the Fortnite Wheel UI structure
    task.spawn(LPH_NO_VIRTUALIZE(function()
        
        local OriginalEmotes = {}

        local wheelPages = {}
        local CustomWheelPages = {
            {"Dance Moves", "Fresh", "Electro Shuffle", "Ride The Pony", "Floss", "The Worm", "Take The L", "Boogie Down"},
            {"Hype", "Tidy", "Breakin'", "Disco Fever", "Orange Justice", "Zany", "Groove Jam", "Freestylin'"},
            {"True Heart", "Rambunctious", "Twist", "Living Large", "Llama Bell", "Fancy Feet", "Hula", "Electro Swing"},
            {"Phone It In", "Flamenco", "Backstroke", "Marsh Walk", "Scenario", "Dream Feet", "Switchstep", "Billy Bounce"},
            {"Infectious"}
        }

        local function buildWheelPages(searchQuery)
            wheelPages = {}
            local q = (searchQuery and searchQuery ~= "") and string.lower(searchQuery) or ""
            
            if q == "" then
                for i, page in ipairs(CustomWheelPages) do
                    local pageCopy = {}
                    for _, e in ipairs(page) do table.insert(pageCopy, e) end
                    table.insert(wheelPages, { page = i, emotes = pageCopy })
                end
            else
                local filtered = {}
                for _, page in ipairs(CustomWheelPages) do
                    for _, e in ipairs(page) do
                        if string.find(string.lower(e), q, 1, true) then
                            table.insert(filtered, e)
                        end
                    end
                end
                
                local pageEmotes = {}
                for i, e in ipairs(filtered) do
                    table.insert(pageEmotes, e)
                    if #pageEmotes == 8 then
                        table.insert(wheelPages, { page = #wheelPages + 1, emotes = pageEmotes })
                        pageEmotes = {}
                    end
                end
                if #pageEmotes > 0 then
                    table.insert(wheelPages, { page = #wheelPages + 1, emotes = pageEmotes })
                end
            end
            
            if #wheelPages == 0 then
                table.insert(wheelPages, { page = 1, emotes = {} })
            end
        end

        buildWheelPages("")
-- Ensure local audio and icons cache directories exist
        local audioFolder = CONFIG.FOLDER .. "/fortniteaudios"
        local iconsFolder = CONFIG.FOLDER .. "/fortniteicons"
        pcall(function() makefolder(audioFolder) end)
        pcall(function() makefolder(iconsFolder) end)

        -- Audio session tracking to prevent overlapping/stale audio
        local audioSession = 0
        local currentSound = nil

        local function stopEmoteAudio(instant)
            audioSession = audioSession + 1
            if currentSound then
                local soundObj = currentSound
                currentSound = nil
                if instant then
                    pcall(function() soundObj:Stop(); soundObj:Destroy() end)
                else
                    task.spawn(function()
                        local tween = TweenService:Create(soundObj, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {Volume = 0})
                        tween:Play()
                        tween.Completed:Wait()
                        pcall(function() soundObj:Stop(); soundObj:Destroy() end)
                    end)
                end
            end
        end
        if ReanimateAPI then
            ReanimateAPI.stop_emote_audio = stopEmoteAudio
        end

        -- Helper to download assets locally
        local function getLocalAsset(url, folder, filename)
            local localPath = folder .. "/" .. filename
            local ok, cached = pcall(readfile, localPath)
            local get_asset = getcustomasset or getsynasset
            if ok and cached and cached ~= "" then
                if type(get_asset) == "function" then
                    local ok2, res = pcall(get_asset, localPath)
                    if ok2 then return res end
                end
                return nil
            end
            local downloaded = request_get(url)
            if downloaded and downloaded ~= "" then
                pcall(function() writefile(localPath, downloaded) end)
                if type(get_asset) == "function" then
                    local ok2, res = pcall(get_asset, localPath)
                    if ok2 then return res end
                end
            end
            return nil
        end

        local function playEmoteAudio(emoteName)
            stopEmoteAudio(true)
            local session = audioSession
            task.spawn(function()
                local url = "" .. game:GetService("HttpService"):UrlEncode(emoteName) .. ".mp3"
                local assetId = getLocalAsset(url, audioFolder, emoteName .. ".mp3")
                if assetId and audioSession == session then
                    pcall(function()
                        local sound = Instance.new("Sound")
                        sound.Name = "HaloEmoteSound"
                        sound.SoundId = assetId
                        sound.Volume = 0
                        sound.Looped = true
                        sound.Parent = game:GetService("SoundService")
                        sound:Play()
                        if audioSession ~= session then
                            sound:Stop(); sound:Destroy()
                            return
                        end
                        currentSound = sound
                        TweenService:Create(sound, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {Volume = 0.3}):Play()
                    end)
                end
            end)
        end

        -- Sound helper for menu hover/click sound effects
        local function playClickSound()
            task.spawn(function()
                local assetId = getLocalAsset("", audioFolder, "Click.mp3")
                if assetId then
                    pcall(function()
                        local sound = Instance.new("Sound")
                        sound.Name = "HaloClickSound"
                        sound.SoundId = assetId
                        sound.Volume = 0.2
                        sound.Parent = game:GetService("SoundService")
                        sound:Play()
                        task.delay(1, function()
                            pcall(function() sound:Destroy() end)
                        end)
                    end)
                end
            end)
        end

        -- Stop audio when animation stops
        if ReanimateAPI and ReanimateAPI.on_animation_stop then
            ReanimateAPI.on_animation_stop(function(stoppedName)
                stopEmoteAudio(false)
            end)
        end

        -- Create Fortnite Wheel UI ScreenGui
        fnGui = Instance.new("ScreenGui")
        fnGui.Name = "FortniteWheelUI"
        fnGui.ResetOnSpawn = false
        fnGui.IgnoreGuiInset = true
        fnGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        fnGui.DisplayOrder = 600

        local successParent = pcall(function() fnGui.Parent = game:GetService("CoreGui") end)
        if not successParent then fnGui.Parent = PlayerGui end

        -- Full-screen darken overlay
        local screenOverlay = Instance.new("Frame", fnGui)
        screenOverlay.Size = UDim2.new(1, 0, 1, 0)
        screenOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        screenOverlay.BackgroundTransparency = 0.55
        screenOverlay.BorderSizePixel = 0
        screenOverlay.ZIndex = 1
        screenOverlay.Visible = false

        -- Main wheel container
        local mainFrame = Instance.new("Frame", fnGui)
        mainFrame.Size = UDim2.new(0, 600, 0, 560)
        mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        mainFrame.BackgroundTransparency = 1
        mainFrame.Visible = false
        mainFrame.ZIndex = 2

        -- Fortnite colors
        local FN = {
            bgDark = Color3.fromRGB(12, 12, 12),
            bgMid = Color3.fromRGB(22, 22, 22),
            bgSegment = Color3.fromRGB(32, 32, 32),
            bgSegmentHover = Color3.fromRGB(180, 180, 180),
            stroke = Color3.fromRGB(48, 48, 48),
            strokeHover = Color3.fromRGB(190, 190, 190),
            textWhite = Color3.fromRGB(255, 255, 255),
            textGray = Color3.fromRGB(180, 180, 180),
            textDim = Color3.fromRGB(100, 100, 100),
            accentBlue = Color3.fromRGB(200, 200, 200),
            navBg = Color3.fromRGB(22, 22, 22),
            navHover = Color3.fromRGB(180, 180, 180),
            centerBg = Color3.fromRGB(8, 8, 8),
            dotActive = Color3.fromRGB(255, 255, 255),
            dotInactive = Color3.fromRGB(50, 50, 50),
        }

        -- Outer glow ring (subtle blue glow behind wheel)
        local glowRing = Instance.new("Frame", mainFrame)
        glowRing.Size = UDim2.new(0, 440, 0, 440)
        glowRing.Position = UDim2.new(0.5, 0, 0.5, -15)
        glowRing.AnchorPoint = Vector2.new(0.5, 0.5)
        glowRing.BackgroundTransparency = 1
        glowRing.BorderSizePixel = 0
        glowRing.ZIndex = 2
        Instance.new("UICorner", glowRing).CornerRadius = UDim.new(0.5, 0)
        local glowStroke = Instance.new("UIStroke", glowRing)
        glowStroke.Color = FN.accentBlue
        glowStroke.Thickness = 3
        glowStroke.Transparency = 0.7

        -- Outer wheel background circle
        local wheelBg = Instance.new("Frame", mainFrame)
        wheelBg.Size = UDim2.new(0, 420, 0, 420)
        wheelBg.Position = UDim2.new(0.5, 0, 0.5, -15)
        wheelBg.AnchorPoint = Vector2.new(0.5, 0.5)
        wheelBg.BackgroundColor3 = FN.bgDark
        wheelBg.BackgroundTransparency = 0
        wheelBg.BorderSizePixel = 0
        wheelBg.ZIndex = 3
        Instance.new("UICorner", wheelBg).CornerRadius = UDim.new(0.5, 0)
        local wheelBgStroke = Instance.new("UIStroke", wheelBg)
        wheelBgStroke.Color = FN.stroke
        wheelBgStroke.Thickness = 2
        wheelBgStroke.Transparency = 0.2

        -- Inner circle (center hole of donut)
        local innerCircle = Instance.new("Frame", mainFrame)
        innerCircle.Size = UDim2.new(0, 155, 0, 155)
        innerCircle.Position = UDim2.new(0.5, 0, 0.5, -15)
        innerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
        innerCircle.BackgroundColor3 = FN.centerBg
        innerCircle.BackgroundTransparency = 0
        innerCircle.BorderSizePixel = 0
        innerCircle.ZIndex = 8
        Instance.new("UICorner", innerCircle).CornerRadius = UDim.new(0.5, 0)
        local innerStroke = Instance.new("UIStroke", innerCircle)
        innerStroke.Color = FN.stroke
        innerStroke.Thickness = 2
        innerStroke.Transparency = 0.3

        -- Center emote name label (inside inner circle)
        local centerLabel = Instance.new("TextLabel", mainFrame)
        centerLabel.Size = UDim2.new(0, 130, 0, 50)
        centerLabel.Position = UDim2.new(0.5, 0, 0.5, -15)
        centerLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        centerLabel.BackgroundTransparency = 1
        centerLabel.Text = ""
        centerLabel.TextColor3 = FN.textWhite
        centerLabel.TextSize = 14
        centerLabel.Font = Enum.Font.GothamBold
        centerLabel.TextWrapped = true
        centerLabel.ZIndex = 9

        -- Title above wheel
        local wheelTitleIcon = Instance.new("ImageLabel", mainFrame)
        wheelTitleIcon.Name = "WheelTitle"
        wheelTitleIcon.Size = UDim2.new(0, 420, 0, 85)
        wheelTitleIcon.Position = UDim2.new(0.5, 0, 0, -26)
        wheelTitleIcon.AnchorPoint = Vector2.new(0.5, 1)
        wheelTitleIcon.BackgroundTransparency = 1
        wheelTitleIcon.ScaleType = Enum.ScaleType.Fit
        wheelTitleIcon.ZIndex = 11

        task.spawn(function()
            pcall(function() delfile(iconsFolder .. "/_wheel_title.png") end)
            local url = "https://i.postimg.cc/JzbXQrW0/halowheel.png"
            local assetId = getLocalAsset(url, iconsFolder, "halowheel.png")
            if assetId then
                wheelTitleIcon.Image = assetId
            end
        end)

        -- Page indicator dots container
        local dotsFrame = Instance.new("Frame", mainFrame)
        dotsFrame.Size = UDim2.new(0, 140, 0, 16)
        dotsFrame.Position = UDim2.new(0.5, 0, 1, -22)
        dotsFrame.AnchorPoint = Vector2.new(0.5, 0)
        dotsFrame.BackgroundTransparency = 1
        dotsFrame.ZIndex = 10
        local dotsLayout = Instance.new("UIListLayout", dotsFrame)
        dotsLayout.FillDirection = Enum.FillDirection.Horizontal
        dotsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        dotsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        dotsLayout.Padding = UDim.new(0, 8)

        local arrowLeftUrl = "https://i.postimg.cc/mkMJrzKw/ic-fluent-arrow-left-24-filled.png"
        local arrowRightUrl = "https://i.postimg.cc/2yvM5bg7/ic-fluent-arrow-right-24-filled.png"

            local createNavArrow = function(posX, anchorX)
            local btn = Instance.new("ImageButton", mainFrame)
            btn.Size = UDim2.new(0, 48, 0, 48)
            btn.Position = UDim2.new(posX, 0, 0.5, -15)
            btn.AnchorPoint = Vector2.new(anchorX, 0.5)
            btn.BackgroundColor3 = FN.navBg
            btn.BackgroundTransparency = 0.1
            btn.Image = ""
            btn.BorderSizePixel = 0
            btn.ZIndex = 10
            btn.AutoButtonColor = false
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0.5, 0)
            local navStroke = Instance.new("UIStroke", btn)
            navStroke.Color = FN.stroke
            navStroke.Thickness = 1.5
            navStroke.Transparency = 0.3
            local arrowIcon = Instance.new("ImageLabel", btn)
            arrowIcon.Name = "ArrowIcon"
            arrowIcon.Size = UDim2.new(0, 22, 0, 22)
            arrowIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
            arrowIcon.AnchorPoint = Vector2.new(0.5, 0.5)
            arrowIcon.BackgroundTransparency = 1
            arrowIcon.ImageColor3 = FN.textWhite
            arrowIcon.ZIndex = 11
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = FN.navHover, BackgroundTransparency = 0}):Play()
                TweenService:Create(navStroke, TweenInfo.new(0.1), {Color = FN.strokeHover, Transparency = 0}):Play()
                TweenService:Create(btn, TweenInfo.new(0.08), {Size = UDim2.new(0, 52, 0, 52)}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = FN.navBg, BackgroundTransparency = 0.1}):Play()
                TweenService:Create(navStroke, TweenInfo.new(0.12), {Color = FN.stroke, Transparency = 0.3}):Play()
                TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 48, 0, 48)}):Play()
            end)
            return btn, arrowIcon
        end

        local leftArrow, leftArrowIcon = createNavArrow(0, 0.5)
        leftArrow.Position = UDim2.new(0, -8, 0.5, -15)
        leftArrow.AnchorPoint = Vector2.new(0.5, 0.5)
        local rightArrow, rightArrowIcon = createNavArrow(1, 0.5)
        rightArrow.Position = UDim2.new(1, 8, 0.5, -15)
        rightArrow.AnchorPoint = Vector2.new(0.5, 0.5)

        task.spawn(function()
            local asset = getLocalAsset(arrowLeftUrl, iconsFolder, "_arrow_left.png")
            if asset then pcall(function() leftArrowIcon.Image = asset end) end
        end)
        task.spawn(function()
            local asset = getLocalAsset(arrowRightUrl, iconsFolder, "_arrow_right.png")
            if asset then pcall(function() rightArrowIcon.Image = asset end) end
        end)

        local searchBox = Instance.new("TextBox", mainFrame)
        searchBox.Size = UDim2.new(0, 130, 0, 24)
        searchBox.Position = UDim2.new(0.5, 0, 0.5, -35)
        searchBox.AnchorPoint = Vector2.new(0.5, 0.5)
        searchBox.BackgroundColor3 = FN.bgDark
        searchBox.BackgroundTransparency = 0.2
        searchBox.BorderSizePixel = 0
        searchBox.Text = ""
        searchBox.PlaceholderText = "Search..."
        searchBox.TextColor3 = FN.textWhite
        searchBox.PlaceholderColor3 = FN.textDim
        searchBox.TextSize = 11
        searchBox.Font = Enum.Font.Gotham
        searchBox.ZIndex = 10
        searchBox.ClearTextOnFocus = false
        Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 6)
        
        centerLabel.Position = UDim2.new(0.5, 0, 0.5, 5)
        centerLabel.Size = UDim2.new(0, 130, 0, 30)
        local currentPageIdx = 1
        local currentHoveredEmote = nil
        local segmentFrames = {}
        local triggerEmote 

        local updateDots = function()
            for _, child in ipairs(dotsFrame:GetChildren()) do
                if child:IsA("Frame") then child:Destroy() end
            end
            for i = 1, #wheelPages do
                local dot = Instance.new("Frame", dotsFrame)
                dot.Size = UDim2.new(0, i == currentPageIdx and 18 or 8, 0, 8)
                dot.BackgroundColor3 = i == currentPageIdx and FN.dotActive or FN.dotInactive
                dot.BorderSizePixel = 0
                dot.ZIndex = 10
                Instance.new("UICorner", dot).CornerRadius = UDim.new(0, 4)
            end
        end

        local drawWheel = function()
           
            for _, seg in ipairs(segmentFrames) do
                pcall(function() seg:Destroy() end)
            end
            segmentFrames = {}

            local pageData = wheelPages[currentPageIdx]
            if not pageData then return end
            local emotes = pageData.emotes
            local totalEmotes = #emotes

            currentHoveredEmote = nil
            centerLabel.Text = ""
            updateDots()

            local outerRadius = 155
            local segSize = math.clamp(88 - (totalEmotes - 6) * 4, 64, 92)

            for i, emoteName in ipairs(emotes) do
                local angle = ((i - 1) / totalEmotes) * 360 - 90
                local rad = math.rad(angle)
                local xOffset = math.cos(rad) * outerRadius
                local yOffset = math.sin(rad) * outerRadius

                local seg = Instance.new("TextButton", mainFrame)
                seg.Name = "Seg_" .. i
                seg.Size = UDim2.new(0, segSize, 0, segSize)
                seg.Position = UDim2.new(0.5, xOffset, 0.5, yOffset - 15)
                seg.AnchorPoint = Vector2.new(0.5, 0.5)
                seg.BackgroundColor3 = FN.bgSegment
                seg.BackgroundTransparency = 0.1
                seg.Text = ""
                seg.BorderSizePixel = 0
                seg.AutoButtonColor = false
                seg.ZIndex = 6
                Instance.new("UICorner", seg).CornerRadius = UDim.new(0, 14)
                local segStroke = Instance.new("UIStroke", seg)
                segStroke.Color = FN.stroke
                segStroke.Thickness = 1.8
                segStroke.Transparency = 0.35

                -- Icon
                local icon = Instance.new("ImageLabel", seg)
                icon.Name = "Icon"
                icon.Size = UDim2.new(0.6, 0, 0.6, 0)
                icon.Position = UDim2.new(0.5, 0, 0.38, 0)
                icon.AnchorPoint = Vector2.new(0.5, 0.5)
                icon.BackgroundTransparency = 1
                icon.ImageColor3 = FN.textGray
                icon.ZIndex = 7

                task.spawn(function()
                    local url = "" .. game:GetService("HttpService"):UrlEncode(emoteName) .. ".png"
                    local assetId = getLocalAsset(url, iconsFolder, emoteName .. ".png")
                    if assetId then
                        icon.Image = assetId
                    end
                end)

                local segName = Instance.new("TextLabel", seg)
                segName.Size = UDim2.new(1, -4, 0, 14)
                segName.Position = UDim2.new(0.5, 0, 0.82, 0)
                segName.AnchorPoint = Vector2.new(0.5, 0.5)
                segName.BackgroundTransparency = 1
                segName.Text = emoteName
                segName.TextColor3 = FN.textDim
                segName.TextSize = 8
                segName.Font = Enum.Font.GothamSemibold
                segName.TextTruncate = Enum.TextTruncate.AtEnd
                segName.ZIndex = 7

                seg.MouseEnter:Connect(function()
                    playClickSound()
                    currentHoveredEmote = emoteName
                    centerLabel.Text = emoteName:upper()

                    for _, otherSeg in ipairs(segmentFrames) do
                        if otherSeg ~= seg and otherSeg.Parent then
                            TweenService:Create(otherSeg, TweenInfo.new(0.1), {
                                BackgroundColor3 = FN.bgSegment, BackgroundTransparency = 0.1
                            }):Play()
                            local os2 = otherSeg:FindFirstChildOfClass("UIStroke")
                            if os2 then TweenService:Create(os2, TweenInfo.new(0.1), {Color = FN.stroke, Transparency = 0.35}):Play() end
                            local oi = otherSeg:FindFirstChild("Icon")
                            if oi then TweenService:Create(oi, TweenInfo.new(0.1), {ImageColor3 = FN.textGray}):Play() end
                        end
                    end

                    TweenService:Create(seg, TweenInfo.new(0.08), {
                        BackgroundColor3 = FN.bgSegmentHover, BackgroundTransparency = 0
                    }):Play()
                    TweenService:Create(segStroke, TweenInfo.new(0.08), {Color = FN.strokeHover, Transparency = 0}):Play()
                    TweenService:Create(icon, TweenInfo.new(0.08), {ImageColor3 = FN.textWhite}):Play()
                    TweenService:Create(seg, TweenInfo.new(0.1), {Size = UDim2.new(0, segSize + 6, 0, segSize + 6)}):Play()
                end)

                seg.MouseLeave:Connect(function()
                    TweenService:Create(seg, TweenInfo.new(0.12), {
                        BackgroundColor3 = FN.bgSegment, BackgroundTransparency = 0.1,
                        Size = UDim2.new(0, segSize, 0, segSize)
                    }):Play()
                    TweenService:Create(segStroke, TweenInfo.new(0.12), {Color = FN.stroke, Transparency = 0.35}):Play()
                    TweenService:Create(icon, TweenInfo.new(0.12), {ImageColor3 = FN.textGray}):Play()
                end)

                seg.MouseButton1Click:Connect(function()
                    mainFrame.Visible = false
                    screenOverlay.Visible = false
                    triggerEmote(emoteName)
                end)

                table.insert(segmentFrames, seg)
            end
        end

        triggerEmote = function(emoteName)
            if not emoteName then return end
            task.spawn(function()
                if not ReanimateAPI.is_reanimated() then
                    Notify("Fortnite Wheel", "Please reanimate first!", 3)
                    return
                end

                stopEmoteAudio(true)

                local lowerName = emoteName:lower()
                local actualAnimName = nil
                local isCustom = false
                local animUrl = nil
                local isRaw = false

                for _, ca in ipairs(CustomAnims) do
                    if ca.name:lower() == lowerName then
                        actualAnimName = ca.name
                        isCustom = true
                        animUrl = ca.url
                        isRaw = ca.raw ~= false
                        break
                    end
                end

                if not actualAnimName then
                    for name, url in pairs(AnimationList) do
                        if name:lower() == lowerName then
                            actualAnimName = name
                            animUrl = url
                            isRaw = false
                            break
                        end
                    end
                end

                if not actualAnimName then
                    for name, url in pairs(presetList) do
                        if name:lower() == lowerName then
                            actualAnimName = name
                            animUrl = url
                            isRaw = false
                            break
                        end
                    end
                end

                if actualAnimName and animUrl then
                    local wasPlaying = State.selectedAnim == actualAnimName
                    PlayAnimation(actualAnimName, State.currentSpeed, isRaw)
                    
                    if not wasPlaying then
                        playEmoteAudio(actualAnimName)
                    end
                else
               
                    local fallbackUrl = "" .. game:GetService("HttpService"):UrlEncode(emoteName) .. ".lua"
                    local downloaded = request_get(fallbackUrl)
                    if downloaded and downloaded ~= "" then
                        AnimationList[emoteName] = fallbackUrl
                        pcall(function() writefile(GetCachePath(emoteName), downloaded) end)
                        local wasPlaying = State.selectedAnim == emoteName
                        PlayAnimation(emoteName, State.currentSpeed, false)
                        if not wasPlaying then
                            playEmoteAudio(emoteName)
                        end
                    else
                        Notify("Fortnite Wheel", "Animation not found!", 3)
                    end
                end
            end)
        end

        leftArrow.MouseButton1Click:Connect(function()
            playClickSound()
            currentPageIdx = currentPageIdx > 1 and currentPageIdx - 1 or #wheelPages
            drawWheel()
        end)
        rightArrow.MouseButton1Click:Connect(function()
            playClickSound()
            currentPageIdx = currentPageIdx < #wheelPages and currentPageIdx + 1 or 1
            drawWheel()
        end)

        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            buildWheelPages(searchBox.Text)
            drawWheel()
        end)

        drawWheel()

        local wheelScale = Instance.new("UIScale", mainFrame)
        wheelScale.Scale = 1

        local showWheel = function()
            mainFrame.Visible = true
            screenOverlay.Visible = true
            wheelScale.Scale = 0.85
            screenOverlay.BackgroundTransparency = 1
            TweenService:Create(wheelScale, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Scale = 1}):Play()
            TweenService:Create(screenOverlay, TweenInfo.new(0.15), {BackgroundTransparency = 0.55}):Play()
            searchBox.Text = ""
            buildWheelPages("")            currentPageIdx = currentPageIdx or 1
            drawWheel()
        end

        local hideWheel = function()
            TweenService:Create(wheelScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.85}):Play()
            TweenService:Create(screenOverlay, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
            task.delay(0.1, function()
                mainFrame.Visible = false
                screenOverlay.Visible = false
            end)
        end

        _G._OpenFortniteWheel = function()
            if not ScreenGui or not ScreenGui.Parent then return end
            if mainFrame.Visible then
                hideWheel()
            else
                showWheel()
            end
        end

        local isHolding = false
        local keyBeganConn = UserInputService.InputBegan:Connect(function(i, gp)
            if gp then return end
            if not ScreenGui or not ScreenGui.Parent then return end
            if _G._FortniteWheelKey and i.KeyCode == _G._FortniteWheelKey then
                isHolding = true
                showWheel()
            end
        end)

        local keyEndedConn = UserInputService.InputEnded:Connect(function(i, gp)
            if _G._FortniteWheelKey and i.KeyCode == _G._FortniteWheelKey then
                if isHolding and mainFrame.Visible then
                    isHolding = false
                    hideWheel()
                    if currentHoveredEmote then
                        triggerEmote(currentHoveredEmote)
                    end
                end
            end
        end)

        if _G._HaloReanimGlobalConns then
            table.insert(_G._HaloReanimGlobalConns, keyBeganConn)
            table.insert(_G._HaloReanimGlobalConns, keyEndedConn)
        end
    end))

end

pcall(function()
    ScreenGui.Parent = _screenGuiTarget
    if not ScreenGui.Parent then
        warn("[Halo Reanim] Failed to parent ScreenGui to " .. tostring(_screenGuiTarget))
        ScreenGui.Parent = PlayerGui
    end
    ScreenGui.Enabled = true
    Menu.Visible = true
end)

BuildRowPool()
SwitchTab("All")
-- RebuildCustomList() is now lazy — it builds the first time the Custom tab is
-- opened (via EnsureCustomListBuilt in SwitchTab), so the window opens instantly.
pcall(function()
    updateFnWheelBtnText()
    updateRevBtnText()
    if _G._UniUpdateIrBtnText then pcall(_G._UniUpdateIrBtnText) end
    if _G._UniUpdateTpBtnText then pcall(_G._UniUpdateTpBtnText) end
    if _G._UniUpdateCmdBarBtnText then pcall(_G._UniUpdateCmdBarBtnText) end
    local pct = math.clamp((GlobalReverseSpeed - 0.1) / 2.9, 0, 1)
    revFill.Size = UDim2.new(pct, 0, 1, 0)
    revHandle.Position = UDim2.new(pct, 0, 0.5, 0)
    revSpdLbl.Text = "Reverse Speed: " .. string.format("%.1f", GlobalReverseSpeed) .. "x"
end)
Notify("Reanimation loaded!", 2.5)
-- treehouse prompt moved to N0IR UI lib
pcall(promptCmdBarOnLoad)
pcall(promptDiscordOnLoad)

task.spawn(function()
    local ok, r = pcall(function()
        return loadstring(game:HttpGet(CONFIG.ANIMATIONS_URL))()
    end)
    if ok and type(r) == "table" and next(r) ~= nil then
        for name, url in pairs(r) do
            AnimationList[name] = url
        end
        if State.currentTab == "All" or State.currentTab == "Favs" then
            pcall(RebuildVisible)
        end
    end
end)

function _runEmbeddedReanimation()
    if _haloReanimHasRun then
        local found = pcall(function()
            local pg = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
            local cg = game:GetService("CoreGui")
            if pg then
                for _, sg in ipairs(pg:GetChildren()) do
                    if sg:IsA("ScreenGui") and sg.Name == "ReanimHaloMenu" then
                        sg.Enabled = true
                        for _, f in ipairs(sg:GetChildren()) do
                            if f:IsA("Frame") then f.Visible = true end
                        end
                        return true
                    end
                end
            end
            if cg then
                for _, sg in ipairs(cg:GetChildren()) do
                    if sg:IsA("ScreenGui") and sg.Name == "ReanimHaloMenu" then
                        sg.Enabled = true
                        for _, f in ipairs(sg:GetChildren()) do
                            if f:IsA("Frame") then f.Visible = true end
                        end
                        return true
                    end
                end
            end
            return false
        end)
        if found then return end
    end
    _haloReanimHasRun = true
    if not _haloReanimCode then
        warn("[Halo Reanim] Code is nil - already loaded?")
        return
    end
    local ok, fn = pcall(loadstring, _haloReanimCode)
    if not ok then
        warn("[Halo Reanim] loadstring failed: " .. tostring(fn))
        return
    end
    if not fn then
        warn("[Halo Reanim] loadstring returned nil")
        return
    end
    local ok2, err = pcall(fn)
    if not ok2 then
        warn("[Halo Reanim] execution failed: " .. tostring(err))
    end
    _haloReanimCode = nil
    -- Wait a moment for the ScreenGui to be parented
    task.wait(0.1)
end
_G._HaloReanimShowMenu = _runEmbeddedReanimation


-- ============================================================
-- AUTO NOCLIP (Active ONLY when animations are playing)
-- Keeps collisions normal when idle, and enables noclip only
-- during animation playback or copier activity.
-- ============================================================
local AutoNoclipEnabled = true
local AutoNoclipConn = nil
local AutoNoclipParts = {}

local function EnableAutoNoclip()
    if AutoNoclipConn then
        pcall(function() AutoNoclipConn:Disconnect() end)
        AutoNoclipConn = nil
    end
    AutoNoclipParts = {}
    AutoNoclipConn = RunService.Stepped:Connect(function()
        if not AutoNoclipEnabled then return end

        local isPlaying = false
        if ReanimateAPI and ReanimateAPI.is_animation_playing then
            local ok, p = pcall(ReanimateAPI.is_animation_playing)
            if ok and p then isPlaying = true end
        end
        if not isPlaying and _G._HaloAnimCopierActive then
            isPlaying = true
        end

        if isPlaying then
            -- Noclip active ONLY while playing animations
            local char = plr.Character
            if char then
                for _, child in pairs(char:GetDescendants()) do
                    if child:IsA("BasePart") and child.CanCollide == true then
                        child.CanCollide = false
                        AutoNoclipParts[child] = true
                    end
                end
            end
            local clone = ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
            if clone then
                for _, child in pairs(clone:GetDescendants()) do
                    if child:IsA("BasePart") and child.CanCollide == true then
                        child.CanCollide = false
                        AutoNoclipParts[child] = true
                    end
                end
            end
        else
            -- When NOT playing: restore collisions immediately
            if next(AutoNoclipParts) then
                for child, _ in pairs(AutoNoclipParts) do
                    if typeof(child) == "Instance" and child:IsA("BasePart") and child.Parent then
                        pcall(function() child.CanCollide = true end)
                    end
                end
                AutoNoclipParts = {}
            end
        end
    end)
end

local function DisableAutoNoclip()
    AutoNoclipEnabled = false
    if AutoNoclipConn then
        pcall(function() AutoNoclipConn:Disconnect() end)
        AutoNoclipConn = nil
    end
    for child, _ in pairs(AutoNoclipParts) do
        if typeof(child) == "Instance" and child:IsA("BasePart") and child.Parent then
            pcall(function() child.CanCollide = true end)
        end
    end
    AutoNoclipParts = {}
end

-- Start auto noclip listener
EnableAutoNoclip()

-- Re-enable on character respawn
plr.CharacterAdded:Connect(function()
    if AutoNoclipEnabled then
        task.wait(0.2)
        EnableAutoNoclip()
    end
end)

-- Expose toggle
_G._HaloToggleAutoNoclip = function()
    AutoNoclipEnabled = not AutoNoclipEnabled
    if AutoNoclipEnabled then
        EnableAutoNoclip()
        Notify("Auto Noclip ON", 2)
    else
        DisableAutoNoclip()
        Notify("Auto Noclip OFF", 2)
    end
end

-- ============================================================
-- INFINITE BASEPLATE MODULE (Static In-Place)
-- Widens the baseplate in its exact position so it stays fixed,
-- never overlaps, and works seamlessly with mfix and custom maps.
-- ============================================================
if not _G._HaloInfBaseplateApplied then
    _G._HaloInfBaseplateApplied = true
    task.spawn(function()
        local Workspace = game:GetService("Workspace")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        -- Disconnect and clean up any dynamic follow loops/parts
        if _G._HaloInfBPConn then
            _G._HaloInfBPConn:Disconnect()
            _G._HaloInfBPConn = nil
        end
        local cam = Workspace.CurrentCamera or Workspace:FindFirstChild("Camera")
        if cam then
            local oldDyn = cam:FindFirstChild("UnicornDynamicBaseplate")
            if oldDyn then oldDyn:Destroy() end
        end

        -- Search for existing baseplate in Workspace, Map, or Camera
        local baseplate = Workspace:FindFirstChild("Baseplate") or Workspace:FindFirstChild("baseplate")
        if not baseplate and cam and cam:FindFirstChild("ScopersModel") then
            baseplate = cam.ScopersModel:FindFirstChild("Baseplate") or cam.ScopersModel:FindFirstChild("baseplate")
        end
        if not baseplate then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower() == "baseplate" or obj.Name:lower() == "base") then
                    baseplate = obj
                    break
                end
            end
        end

        if baseplate and baseplate:IsA("BasePart") then
            -- Widen existing baseplate IN PLACE (Keep exact original Y and Position)
            local currentY = baseplate.Size.Y
            local currentPos = baseplate.Position

            baseplate.Size = Vector3.new(4096, currentY, 4096)
            baseplate.Position = Vector3.new(currentPos.X, currentPos.Y, currentPos.Z)
            baseplate.Anchored = true
            baseplate.CanCollide = true

            -- Match pink grass theme
            baseplate.Material = Enum.Material.Grass
            baseplate.Color = Color3.fromRGB(255, 255, 255)
            baseplate.Transparency = 0
            baseplate.Reflectance = 0
            baseplate.BottomSurface = Enum.SurfaceType.Smooth
            baseplate.TopSurface = Enum.SurfaceType.Smooth

            local hasTopDecal = false
            for _, child in ipairs(baseplate:GetChildren()) do
                if (child:IsA("Decal") or child:IsA("Texture")) and child.Face == Enum.NormalId.Top then
                    hasTopDecal = true
                end
            end

            if not hasTopDecal then
                local grassDecal = Instance.new("Decal")
                grassDecal.Texture = "rbxassetid://6375461772"
                grassDecal.Face = Enum.NormalId.Top
                grassDecal.Transparency = 0.1
                grassDecal.Parent = baseplate
            end
        else
            -- Create a static baseplate at one place if none exists
            local root = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) or nil
            local spawnY = root and (root.Position.Y - 3.5) or 0

            local newBP = Instance.new("Part")
            newBP.Name = "Baseplate"
            newBP.Size = Vector3.new(4096, 20, 4096)
            newBP.Position = Vector3.new(0, spawnY - 10, 0)
            newBP.Anchored = true
            newBP.CanCollide = true
            newBP.Material = Enum.Material.Grass
            newBP.Color = Color3.fromRGB(160, 160, 160)
            newBP.Transparency = 0
            newBP.Reflectance = 0
            newBP.BottomSurface = Enum.SurfaceType.Smooth
            newBP.TopSurface = Enum.SurfaceType.Smooth
            newBP.Parent = Workspace

            local grassDecal = Instance.new("Decal")
            grassDecal.Texture = "rbxassetid://6375461772"
            grassDecal.Face = Enum.NormalId.Top
            grassDecal.Transparency = 0.1
            grassDecal.Parent = newBP
        end

        -- Clean up invisible walls / blocking platform rooms if present
        task.spawn(function()
            local function tryDestroy()
                local map = Workspace:FindFirstChild("map") or Workspace:FindFirstChild("Map")
                if not map then return false end
                local extraRoom = map:FindFirstChild("extra_room") or map:FindFirstChild("Extra_Room")
                if not extraRoom then return false end

                local children = extraRoom:GetChildren()
                pcall(function() if children[4] then children[4]:Destroy() end end)
                pcall(function() if children[3] then children[3]:Destroy() end end)
                pcall(function() if children[2] then children[2]:Destroy() end end)
                pcall(function() 
                    local platform = extraRoom:FindFirstChild("platform") or extraRoom:FindFirstChild("Platform")
                    if platform then platform:Destroy() end
                end)
                return true
            end

            for i = 1, 12 do
                if tryDestroy() then break end
                task.wait(0.5)
            end
        end)

        pcall(function()
            if typeof(Notify) == "function" then
                Notify("Infinite Baseplate Loaded", "Dark grass | 4096x4096 fixed baseplate", 3)
            end
        end)
    end)
end


-- ============================================================
-- COMMAND SYSTEM (? prefix)
-- ?rj = rejoin server
-- ?permhide <name> = hide + mute + block a player (partial match)
-- ?unpermhide <name> = unhide a player
-- ============================================================
local PermHiddenPlayers = _G._HaloPermHiddenPlayers or {}
_G._HaloPermHiddenPlayers = PermHiddenPlayers

local function getPlayerByPartialName(partial)
    partial = partial:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then
            if p.Name:lower():find(partial, 1, true) or p.DisplayName:lower():find(partial, 1, true) then
                return p
            end
        end
    end
    return nil
end

local function permHidePlayer(targetPlayer)
    if not targetPlayer or targetPlayer == plr then return end
    PermHiddenPlayers[targetPlayer.UserId] = true

    -- Hide character
    pcall(function()
        if targetPlayer.Character then
            targetPlayer.Character.Parent = nil
        end
    end)

    -- Mute in legacy chat
    pcall(function()
        game:GetService("StarterGui"):SetCore("ChatMutePlayer", targetPlayer.Name)
    end)

    -- Mute VC
    pcall(function()
        local VoiceChatService = game:GetService("VoiceChatService")
        if VoiceChatService and VoiceChatService:IsVoiceEnabledForUserIdAsync(targetPlayer.UserId) then
            -- We can't directly mute others in VC, but we can locally mute
            local success = pcall(function()
                game:GetService("SoundService").LocalMuted[targetPlayer.UserId] = true
            end)
            if not success then
                -- Alternative: set their character parts to non-sound emitting
            end
        end
    end)

    Notify("PermHidden: " .. targetPlayer.Name, "Character hidden, chat + VC muted", 3)
end

local function unpermHidePlayer(targetPlayer)
    if not targetPlayer then return end
    PermHiddenPlayers[targetPlayer.UserId] = nil

    -- Unhide character
    pcall(function()
        if targetPlayer.Character and targetPlayer.Character.Parent == nil then
            targetPlayer.Character.Parent = workspace
        end
    end)

    -- Unmute in legacy chat
    pcall(function()
        game:GetService("StarterGui"):SetCore("ChatUnmutePlayer", targetPlayer.Name)
    end)

    Notify("Unhidden: " .. targetPlayer.Name, "Player restored", 2)
end

-- Hook character added for permhidden players
Players.PlayerAdded:Connect(function(p)
    if PermHiddenPlayers[p.UserId] then
        task.wait(0.3)
        permHidePlayer(p)
    end
end)

-- Re-apply hide when permhidden players respawn
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= plr and PermHiddenPlayers[p.UserId] then
        p.CharacterAdded:Connect(function()
            if PermHiddenPlayers[p.UserId] then
                task.wait(0.2)
                pcall(function() p.Character.Parent = nil end)
            end
        end)
    end
end

-- Chat filter for permhidden players (modern TextChatService)
pcall(function()
    local TextChatService = game:GetService("TextChatService")
    TextChatService.OnIncomingMessage = function(message)
        local props = Instance.new("TextChatMessageProperties")
        if message.TextSource then
            local senderId = message.TextSource.UserId
            if PermHiddenPlayers[senderId] then
                props.Text = ""
                props.PrefixText = ""
            end
        end
        return props
    end
end)

-- Legacy chat filter
local function filterLegacyChat()
    local chatGui = plr:WaitForChild("PlayerGui"):FindFirstChild("Chat")
    if not chatGui then return end
    local scroller = chatGui:FindFirstChild("Scroller", true)
    if not scroller then return end

    local function checkMessage(frame)
        if not frame:IsA("Frame") then return end
        task.spawn(function()
            local textLabel = frame:WaitForChild("TextLabel", 1)
            if not textLabel then return end

            local function hideIfPermHidden()
                local text = textLabel.Text
                for userId, _ in pairs(PermHiddenPlayers) do
                    local p = Players:GetPlayerByUserId(userId)
                    if p and (text:find(p.Name, 1, true) or text:find(p.DisplayName, 1, true)) then
                        frame:Destroy()
                        return
                    end
                end
            end

            textLabel:GetPropertyChangedSignal("Text"):Connect(hideIfPermHidden)
            hideIfPermHidden()
        end)
    end

    scroller.ChildAdded:Connect(checkMessage)
    for _, child in ipairs(scroller:GetChildren()) do
        checkMessage(child)
    end
end
task.spawn(filterLegacyChat)

-- Command parser
local function processCommand(msg)
    if not msg or msg:sub(1, 1) ~= "?" then return end
    local args = {}
    for arg in msg:sub(2):gmatch("%S+") do
        table.insert(args, arg)
    end
    local cmd = args[1] and args[1]:lower() or ""

    if cmd == "rj" then
        -- Rejoin server
        Notify("Rejoining server...", 2)
        task.delay(0.5, function()
            local TeleportService = game:GetService("TeleportService")
            pcall(function()
                TeleportService:Teleport(game.PlaceId, plr)
            end)
        end)

    elseif cmd == "permhide" and args[2] then
        local target = getPlayerByPartialName(args[2])
        if target then
            permHidePlayer(target)
        else
            Notify("PermHide Error", "No player matching '" .. args[2] .. "'", 3)
        end

    elseif cmd == "unpermhide" and args[2] then
        local target = getPlayerByPartialName(args[2])
        if target then
            unpermHidePlayer(target)
        else
            Notify("UnPermHide Error", "No player matching '" .. args[2] .. "'", 3)
        end
    end
end

-- Hook chat input (modern TextChatService)
pcall(function()
    local TextChatService = game:GetService("TextChatService")
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local textBox = plr:WaitForChild("PlayerGui"):FindFirstChild("ChatInputBarConfiguration", true)
        -- Modern chat: intercept sent messages
        TextChatService.SendingMessage:Connect(function(message)
            if message.Text and message.Text:sub(1, 1) == "?" then
                processCommand(message.Text)
                message.Text = "" -- Don't send command to chat
            end
        end)
    end
end)

-- Legacy chat command hook
local function hookLegacyChatCommands()
    local chatGui = plr:WaitForChild("PlayerGui"):WaitForChild("Chat", 10)
    if not chatGui then return end

    local chatBar = chatGui:FindFirstChild("ChatBar", true)
    if not chatBar then
        -- Try deeper search
        for _, obj in ipairs(chatGui:GetDescendants()) do
            if obj:IsA("TextBox") and obj.Name == "ChatBar" then
                chatBar = obj
                break
            end
        end
    end

    if chatBar and chatBar:IsA("TextBox") then
        chatBar.FocusLost:Connect(function(enterPressed)
            if not enterPressed then return end
            local text = chatBar.Text
            if text:sub(1, 1) == "?" then
                processCommand(text)
                chatBar.Text = ""
            end
        end)
    end
end
task.spawn(hookLegacyChatCommands)

-- Also check PlayerGui for any chat bar that gets created later
plr.PlayerGui.DescendantAdded:Connect(function(desc)
    if desc:IsA("TextBox") and desc.Name == "ChatBar" then
        desc.FocusLost:Connect(function(enterPressed)
            if not enterPressed then return end
            local text = desc.Text
            if text:sub(1, 1) == "?" then
                processCommand(text)
                desc.Text = ""
            end
        end)
    end
end)

-- ============================================================
-- AUTO 90 FOV - Injected
-- ============================================================
local function apply90FOV()
    pcall(function()
        local cam = workspace.CurrentCamera
        if cam then
            cam.FieldOfView = 90
        end
    end)
end

-- Apply immediately
apply90FOV()

-- Re-apply when character respawns
pcall(function()
    local Players = game:GetService("Players")
    local plr = Players.LocalPlayer
    if plr then
        plr.CharacterAdded:Connect(function()
            task.wait(0.05)
            apply90FOV()
        end)
    end
end)

-- Enforce 90 FOV if anything tries to change it
pcall(function()
    local cam = workspace.CurrentCamera
    if cam then
        cam:GetPropertyChangedSignal("FieldOfView"):Connect(function()
            pcall(function()
                if cam.FieldOfView ~= 105 then
                    cam.FieldOfView = 105
                end
            end)
        end)
    end
end)


-- ============================================
-- STANDALONE ARM/LEG/TORSO STRETCH & POINTER SYSTEM
-- Works continuously even when no custom animation is playing
-- and automatically survives respawns / resets.
-- ============================================
local standalonePointerConn = nil
local standalonePointerCache = nil
local standalonePointerBinds = {}
local standalonePointerLengths = {}

local function buildStandalonePointerCache()
    local clone = ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
    if not clone then return end
    standalonePointerCache = {}
    standalonePointerBinds = {}
    standalonePointerLengths = {}
    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("AnimationConstraint") then
            local att = d.Attachment1
            if att and att.Parent then
                standalonePointerCache[att.Parent.Name] = d
                standalonePointerCache[d.Name] = d
                standalonePointerBinds[d] = d.Transform
                local a0 = d.Attachment0; local a1 = d.Attachment1
                if a0 and a1 and a0.Parent and a1.Parent then
                    local len = (a1.WorldCFrame.Position - a0.WorldCFrame.Position).Magnitude
                    if len > 0.001 then standalonePointerLengths[d] = len end
                end
            end
        elseif d:IsA("Motor6D") then
            local child = d.Part1
            if child and child.Parent and not standalonePointerCache[child.Name] then
                standalonePointerCache[child.Name] = d
                standalonePointerCache[d.Name] = d
                standalonePointerBinds[d] = d.Transform
            end
        end
    end
end

local function doStandalonePointers()
    if not standalonePointerCache then buildStandalonePointerCache() end
    if not standalonePointerCache then return end

    -- 1. Standalone Leg Stretcher (Runs every frame & re-applies HipHeight continuously)
    if _G._HaloLegStretcherEnabled then
        local legScale = math.clamp(_G._HaloLimbsLegHeight or 1.0, 0.4, 100.0)
        if legScale ~= 1.0 then
            local kneeOffset = CFrame.new(0, -(legScale - 1.0) * 1.5, 0)
            local rll = standalonePointerCache["RightLowerLeg"] or standalonePointerCache["RightKnee"]
            local lll = standalonePointerCache["LeftLowerLeg"] or standalonePointerCache["LeftKnee"]
            local baseRll = (rll and standalonePointerBinds[rll]) or CFrame.new()
            local baseLll = (lll and standalonePointerBinds[lll]) or CFrame.new()
            if rll and rll.Parent then rll.Transform = kneeOffset * baseRll end
            if lll and lll.Parent then lll.Transform = kneeOffset * baseLll end
        end
        local clone = ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
        if applyLegHipHeight then applyLegHipHeight(clone, legScale, true) end
    end

    -- 2. Standalone Torso Stretcher
    if _G._HaloTorsoStretcherEnabled then
        local utHeight = _G._HaloLimbsUpperTorsoHeight or 1.0
        local waistConstraint = standalonePointerCache["UpperTorso"] or standalonePointerCache["Waist"] or standalonePointerCache["LowerTorso"]
        if waistConstraint and waistConstraint.Parent then
            local baseRot = waistConstraint.Transform.Rotation
            local stretchY = (utHeight - 1.0) * 2.5
            waistConstraint.Transform = CFrame.new(0, stretchY, 0) * baseRot
        end
    end

    -- 3. Standalone Arm Pointers & Stretchers
    local camera = workspace.CurrentCamera
    local mouse = plr:GetMouse()
    if not camera or not mouse then return end

    local targetPos
    local unitRay = camera:ViewportPointToRay(mouse.X, mouse.Y)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local filterList = {}
    pcall(function()
        if ReanimateAPI.get_clone then
            local clone = ReanimateAPI.get_clone(plr)
            if clone then table.insert(filterList, clone) end
        end
        if ReanimateAPI.get_real_character then
            local real = ReanimateAPI.get_real_character(plr)
            if real then table.insert(filterList, real) end
        end
    end)
    rayParams.FilterDescendantsInstances = filterList
    local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, rayParams)
    if result then targetPos = result.Position
    else targetPos = unitRay.Origin + unitRay.Direction * 1000 end

    local function _point(upperName, lowerName, handName, stretchMult)
        local shoulder = standalonePointerCache[upperName]
        if not shoulder then return end

        -- Refresh to straight bind pose on first frame after re-enable
        local isLeft = upperName:find("Left") ~= nil
        local resetFlag = isLeft and _G._HaloLeftArmPointerNeedsReset or _G._HaloRightArmPointerNeedsReset
        if resetFlag then
            local orig = standalonePointerBinds[shoulder]
            if orig then shoulder.Transform = orig end
            local elbow = standalonePointerCache[lowerName]
            if elbow then elbow.Transform = CFrame.new() end
            local wrist = standalonePointerCache[handName]
            if wrist then wrist.Transform = CFrame.new() end
            if isLeft then _G._HaloLeftArmPointerNeedsReset = false
            else _G._HaloRightArmPointerNeedsReset = false end
        end

        local shoulderWorldCF = nil
        if shoulder:IsA("Motor6D") and shoulder.Part0 then
            shoulderWorldCF = shoulder.Part0.CFrame * shoulder.C0
        else
            local a0 = shoulder.Attachment0
            if a0 and a0.Parent then shoulderWorldCF = a0.WorldCFrame end
        end
        if not shoulderWorldCF then return end
        local shoulderPos = shoulderWorldCF.Position
        local aimDir = (targetPos - shoulderPos)
        if aimDir.Magnitude <= 0.001 then return end
        aimDir = aimDir.Unit

        local bind = shoulder.Transform
        if not bind then return end

        local childBoneDir = Vector3.new(0, -1, 0)
        local bindBoneDir = (bind.Rotation * childBoneDir).Unit
        local localAimDir = shoulderWorldCF.Rotation:Inverse() * aimDir

        local rotAxis = bindBoneDir:Cross(localAimDir)
        local shoulderResult
        if rotAxis.Magnitude > 0.001 then
            rotAxis = rotAxis.Unit
            local angle = math.acos(math.clamp(bindBoneDir:Dot(localAimDir), -1, 1))
            shoulderResult = CFrame.fromAxisAngle(rotAxis, angle) * bind
        elseif bindBoneDir:Dot(localAimDir) < 0 then
            local perp = bindBoneDir:Cross(Vector3.new(0, 1, 0))
            if perp.Magnitude < 0.001 then perp = bindBoneDir:Cross(Vector3.new(1, 0, 0)) end
            shoulderResult = CFrame.fromAxisAngle(perp.Unit, math.pi) * bind
        else
            shoulderResult = bind
        end
        shoulder.Transform = shoulderResult

        -- LOCK elbow and wrist to bind pose so arm stays perfectly straight
        local elbow = standalonePointerCache[lowerName]
        if elbow then elbow.Transform = CFrame.new() end
        local wrist = standalonePointerCache[handName]
        if wrist then wrist.Transform = CFrame.new() end

        stretchMult = stretchMult or 1.0
        if stretchMult ~= 1.0 then
            local c = standalonePointerCache[lowerName]
            if c then
                local baseLen = standalonePointerLengths and standalonePointerLengths[c]
                if not baseLen or baseLen < 0.001 then
                    if c:IsA("Motor6D") and c.Part1 and c.Part1:IsA("BasePart") then
                        baseLen = c.Part1.Size.Y
                    else
                        local a1 = c and c.Attachment1
                        if a1 and a1.Parent and a1.Parent:IsA("BasePart") then
                            baseLen = a1.Parent.Size.Y
                        else
                            baseLen = 1.2
                        end
                    end
                end
                local boneDir = Vector3.new(0, -1, 0)
                local stretchOffset = boneDir * baseLen * (stretchMult - 1.0)
                c.Transform = CFrame.new(stretchOffset)
            end
        end
    end

    local stretchAmt = _G._HaloArmStretchAmount or 2.5
    local function _stretchOnly(lowerName, handName, stretchMult)
        if not stretchMult or stretchMult == 1.0 then return end
        local lower = standalonePointerCache and standalonePointerCache[lowerName]
        local hand  = standalonePointerCache and standalonePointerCache[handName]
        local offset = CFrame.new(0, -(stretchMult - 1.0) * 1.2, 0)
        local baseL = (standalonePointerBinds and standalonePointerBinds[lower]) or CFrame.new()
        local baseH = (standalonePointerBinds and standalonePointerBinds[hand]) or CFrame.new()
        if lower and lower.Parent then lower.Transform = offset * baseL end
        if hand and hand.Parent then hand.Transform = offset * baseH end
    end

    if _G._HaloRightArmPointerEnabled then
        _point("RightUpperArm", "RightLowerArm", "RightHand", (_G._HaloRightArmStretching and stretchAmt) or 1.0)
    elseif not _G._HaloLeftArmPointerEnabled and not _G._HaloRightArmPointerEnabled and _G._HaloRightArmStretching and stretchAmt ~= 1.0 then
        _stretchOnly("RightLowerArm", "RightHand", stretchAmt)
    end

    if _G._HaloLeftArmPointerEnabled then
        _point("LeftUpperArm", "LeftLowerArm", "LeftHand", (_G._HaloLeftArmStretching and stretchAmt) or 1.0)
    elseif not _G._HaloRightArmPointerEnabled and not _G._HaloLeftArmPointerEnabled and _G._HaloLeftArmStretching and stretchAmt ~= 1.0 then
        _stretchOnly("LeftLowerArm", "LeftHand", stretchAmt)
    end
end

local function startStandalonePointers()
    if standalonePointerConn then standalonePointerConn:Disconnect(); standalonePointerConn = nil end
    buildStandalonePointerCache()
    standalonePointerConn = RunService.PreSimulation:Connect(LPH_NO_VIRTUALIZE(function()
        if not State.isReanimated then return end
        local isPlaying = ReanimateAPI and ReanimateAPI.is_animation_playing and ReanimateAPI.is_animation_playing()
        if isPlaying then return end -- animation system handles pointers when playing
        if not (_G._HaloLeftArmPointerEnabled or _G._HaloRightArmPointerEnabled or _G._HaloLeftArmStretching or _G._HaloRightArmStretching or _G._HaloLegStretcherEnabled or _G._HaloTorsoStretcherEnabled) then return end
        -- Rebuild cache if invalidated
        for _, c in pairs(standalonePointerCache or {}) do
            if not c.Parent then buildStandalonePointerCache(); break end
        end
        doStandalonePointers()
    end))
end

local function stopStandalonePointers()
    if standalonePointerConn then standalonePointerConn:Disconnect(); standalonePointerConn = nil end
end

-- Hook into reanimate toggle (no extra locals — stays under register limit)
_G._HaloDoReanimToggle_prev_ptrs = _G._HaloDoReanimToggle
_G._HaloDoReanimToggle = function()
    local wasReanimated = State.isReanimated
    local prev = _G._HaloDoReanimToggle_prev_ptrs
    if type(prev) == "function" then prev() end
    if State.isReanimated and not wasReanimated then
        startStandalonePointers()
    elseif not State.isReanimated and wasReanimated then
        stopStandalonePointers()
    end
end

-- Start immediately if already reanimated
if State.isReanimated then startStandalonePointers() end

-- Rebuild cache and restore stretching on character swap
plr.CharacterAdded:Connect(function()
    task.wait(0.5)
    if State.isReanimated then
        buildStandalonePointerCache()
        if _G._HaloLegStretcherEnabled and applyLegHipHeight then
            local clone = ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
            applyLegHipHeight(clone, _G._HaloLimbsLegHeight or 1.0, true)
        end
        if startStandalonePointers then startStandalonePointers() end
        if startLimbsSystem then startLimbsSystem() end
    end
end)

-- ============================================
-- STANDALONE HEAD TRACKER SYSTEM
-- Works even when no custom animation is playing
-- ============================================
local standaloneHeadConn = nil
local standaloneHeadCache = nil
local standaloneHeadBind = nil
local standaloneHeadSmoothed = nil

local function buildStandaloneHeadCache()
    local clone = ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
    if not clone then return end
    standaloneHeadCache = nil
    standaloneHeadBind = nil
    standaloneHeadSmoothed = nil
    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("AnimationConstraint") then
            local att = d.Attachment1
            if att and att.Parent and att.Parent.Name == "Head" then
                standaloneHeadCache = d
                standaloneHeadBind = d.Transform
                break
            end
        elseif d:IsA("Motor6D") then
            local child = d.Part1
            if child and child.Name == "Head" then
                standaloneHeadCache = d
                standaloneHeadBind = d.Transform
                break
            end
        end
    end
end

local function doStandaloneHeadTracker()
    if not standaloneHeadCache or not standaloneHeadCache.Parent then return end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local parentWorldCF = nil
    if standaloneHeadCache:IsA("Motor6D") and standaloneHeadCache.Part0 then
        parentWorldCF = standaloneHeadCache.Part0.CFrame * standaloneHeadCache.C0
    else
        local att0 = standaloneHeadCache.Attachment0
        if att0 and att0.Parent then parentWorldCF = att0.WorldCFrame end
    end
    if not parentWorldCF then return end
    local bindTransform = standaloneHeadBind
    if not bindTransform then return end
    local camLook = camera.CFrame.LookVector
    local localLookDir = parentWorldCF.Rotation:Inverse() * camLook
    local yaw = math.atan2(localLookDir.X, -localLookDir.Z)
    local pitch = math.asin(math.clamp(localLookDir.Y, -1, 1))
    if not _G._HaloHeadTracker360 then
        local maxYaw = math.rad(75)
        local maxPitch = math.rad(55)
        yaw = math.clamp(yaw, -maxYaw, maxYaw)
        pitch = math.clamp(pitch, -maxPitch, maxPitch)
    end
    local clampedDir = Vector3.new(
        math.sin(yaw) * math.cos(pitch),
        math.sin(pitch),
        -math.cos(yaw) * math.cos(pitch)
    ).Unit
    local bindDir = bindTransform.LookVector
    local rotAxis = bindDir:Cross(clampedDir)
    local targetTransform
    if rotAxis.Magnitude > 0.001 then
        rotAxis = rotAxis.Unit
        local angle = math.acos(math.clamp(bindDir:Dot(clampedDir), -1, 1))
        targetTransform = CFrame.fromAxisAngle(rotAxis, angle) * bindTransform
    elseif bindDir:Dot(clampedDir) < 0 then
        local perp = bindDir:Cross(Vector3.new(0, 1, 0))
        if perp.Magnitude < 0.001 then perp = bindDir:Cross(Vector3.new(1, 0, 0)) end
        targetTransform = CFrame.fromAxisAngle(perp.Unit, math.pi) * bindTransform
    else
        targetTransform = bindTransform
    end
    standaloneHeadSmoothed = (standaloneHeadSmoothed or bindTransform):Lerp(targetTransform, 0.15)
    standaloneHeadCache.Transform = standaloneHeadSmoothed
end

local function startStandaloneHeadTracker()
    if standaloneHeadConn then standaloneHeadConn:Disconnect(); standaloneHeadConn = nil end
    buildStandaloneHeadCache()
    standaloneHeadConn = RunService.PreSimulation:Connect(LPH_NO_VIRTUALIZE(function()
        if not State.isReanimated then return end
        -- Fun head modes take priority over normal head tracker
        if _G._HaloSpinHeadEnabled or _G._HaloStareEnabled or _G._HaloLookBehindEnabled
            or _G._HaloNodLoopEnabled or _G._HaloHeadTiltEnabled or _G._HaloCraneNeckEnabled then
            return
        end
        if not _G._HaloHeadTrackerEnabled then return end
        local isPlaying = ReanimateAPI and ReanimateAPI.is_animation_playing and ReanimateAPI.is_animation_playing()
        if isPlaying then return end
        if not standaloneHeadCache or not standaloneHeadCache.Parent then
            buildStandaloneHeadCache()
        end
        doStandaloneHeadTracker()
    end))
end

local function stopStandaloneHeadTracker()
    if standaloneHeadConn then standaloneHeadConn:Disconnect(); standaloneHeadConn = nil end
end

-- ============================================
-- FUN TRACKING RUNTIME (Stare / Wobble / Spin / T-Pose)
-- Works with or without a playing custom animation.
-- ============================================
local _Fun = _G._HaloFunTrack or { conn = nil, spin = 0, cache = nil, binds = nil, headSmooth = nil }
_G._HaloFunTrack = _Fun

local function buildFunLimbCache()
    local clone = ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
    if not clone then
        _Fun.cache = nil
        _Fun.binds = nil
        return
    end
    _Fun.cache = {}
    _Fun.binds = {}
    local want = {
        Head = true,
        UpperTorso = true, LowerTorso = true, Torso = true, Waist = true,
        RightUpperArm = true, RightLowerArm = true, RightHand = true,
        LeftUpperArm = true, LeftLowerArm = true, LeftHand = true,
    }
    for _, d in ipairs(clone:GetDescendants()) do
        local name = nil
        if d:IsA("AnimationConstraint") then
            local att = d.Attachment1
            if att and att.Parent and want[att.Parent.Name] then
                name = att.Parent.Name
            end
        elseif d:IsA("Motor6D") and d.Part1 and want[d.Part1.Name] then
            name = d.Part1.Name
        end
        if name and not _Fun.cache[name] then
            _Fun.cache[name] = d
            _Fun.binds[name] = d.Transform
        end
    end
end

local function getParentWorldCF(constraint)
    if not constraint then return nil end
    if constraint:IsA("Motor6D") and constraint.Part0 then
        return constraint.Part0.CFrame * constraint.C0
    end
    local att0 = constraint.Attachment0
    if att0 and att0.Parent then
        return att0.WorldCFrame
    end
    return nil
end

local function nearestOtherPlayerHRP()
    local myRoot = nil
    local clone = ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
    if clone then
        myRoot = clone:FindFirstChild("HumanoidRootPart")
    end
    if not myRoot and plr.Character then
        myRoot = plr.Character:FindFirstChild("HumanoidRootPart")
    end
    if not myRoot then return nil end

    local best, bestDist = nil, math.huge
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= plr and other.Character then
            local hrp = other.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - myRoot.Position).Magnitude
                if d < bestDist then
                    bestDist = d
                    best = hrp
                end
            end
        end
    end
    return best
end

local function aimHeadAtWorldPos(headConstraint, bind, worldPos, smooth)
    local parentWorldCF = getParentWorldCF(headConstraint)
    if not parentWorldCF or not bind then return end
    local aimDir = (worldPos - parentWorldCF.Position)
    if aimDir.Magnitude < 0.05 then return end
    aimDir = aimDir.Unit
    local localAim = parentWorldCF.Rotation:Inverse() * aimDir
    local yaw = math.atan2(localAim.X, -localAim.Z)
    local pitch = math.asin(math.clamp(localAim.Y, -1, 1))
    -- soft neck limits unless spin is on
    yaw = math.clamp(yaw, -math.rad(80), math.rad(80))
    pitch = math.clamp(pitch, -math.rad(55), math.rad(55))
    local clampedDir = Vector3.new(
        math.sin(yaw) * math.cos(pitch),
        math.sin(pitch),
        -math.cos(yaw) * math.cos(pitch)
    ).Unit
    local bindDir = bind.LookVector
    local rotAxis = bindDir:Cross(clampedDir)
    local targetTransform
    if rotAxis.Magnitude > 0.001 then
        rotAxis = rotAxis.Unit
        local angle = math.acos(math.clamp(bindDir:Dot(clampedDir), -1, 1))
        targetTransform = CFrame.fromAxisAngle(rotAxis, angle) * bind
    else
        targetTransform = bind
    end
    if smooth then
        _Fun.headSmooth = (_Fun.headSmooth or bind):Lerp(targetTransform, 0.18)
        headConstraint.Transform = _Fun.headSmooth
    else
        headConstraint.Transform = targetTransform
    end
end

local function applyTPose()
    local rU = _Fun.cache and _Fun.cache.RightUpperArm
    local lU = _Fun.cache and _Fun.cache.LeftUpperArm
    local rL = _Fun.cache and _Fun.cache.RightLowerArm
    local lL = _Fun.cache and _Fun.cache.LeftLowerArm
    local rH = _Fun.cache and _Fun.cache.RightHand
    local lH = _Fun.cache and _Fun.cache.LeftHand
    -- Relative to bind: swing arms out to sides
    if rU then rU.Transform = CFrame.Angles(0, 0, math.rad(90)) end
    if lU then lU.Transform = CFrame.Angles(0, 0, math.rad(-90)) end
    if rL then rL.Transform = CFrame.new() end
    if lL then lL.Transform = CFrame.new() end
    if rH then rH.Transform = CFrame.new() end
    if lH then lH.Transform = CFrame.new() end
end

local function applyIdleWobble(dt)
    local t = tick()
    local head = _Fun.cache and _Fun.cache.Head
    local rU = _Fun.cache and _Fun.cache.RightUpperArm
    local lU = _Fun.cache and _Fun.cache.LeftUpperArm
    if head and _Fun.binds and _Fun.binds.Head and not _G._HaloSpinHeadEnabled and not _G._HaloStareEnabled and not _G._HaloHeadTrackerEnabled then
        local wob = CFrame.Angles(
            math.sin(t * 2.1) * 0.07,
            math.sin(t * 1.6) * 0.09,
            math.sin(t * 1.3) * 0.04
        )
        head.Transform = _Fun.binds.Head * wob
    end
    if not _G._HaloTPoseEnabled then
        if rU and _Fun.binds and _Fun.binds.RightUpperArm and not _G._HaloRightArmPointerEnabled then
            local wob = CFrame.Angles(
                math.sin(t * 1.8 + 1) * 0.06,
                0,
                math.sin(t * 2.3) * 0.05
            )
            rU.Transform = _Fun.binds.RightUpperArm * wob
        end
        if lU and _Fun.binds and _Fun.binds.LeftUpperArm and not _G._HaloLeftArmPointerEnabled then
            local wob = CFrame.Angles(
                math.sin(t * 1.9 + 2) * 0.06,
                0,
                math.sin(t * 2.1 + 0.5) * 0.05
            )
            lU.Transform = _Fun.binds.LeftUpperArm * wob
        end
    end
end

local function doFunTracking(dt)
    if not _Fun.cache then buildFunLimbCache() end
    if not _Fun.cache then return end
    for _, c in pairs(_Fun.cache) do
        if not c.Parent then
            buildFunLimbCache()
            break
        end
    end
    if not _Fun.cache then return end

    dt = dt or 0.016
    local t = tick()
    local head = _Fun.cache.Head
    local headBind = _Fun.binds and _Fun.binds.Head
    local rU, lU = _Fun.cache.RightUpperArm, _Fun.cache.LeftUpperArm
    local rL, lL = _Fun.cache.RightLowerArm, _Fun.cache.LeftLowerArm
    local rH, lH = _Fun.cache.RightHand, _Fun.cache.LeftHand
    local rUb = _Fun.binds and _Fun.binds.RightUpperArm
    local lUb = _Fun.binds and _Fun.binds.LeftUpperArm
    local waist = _Fun.cache.Waist or _Fun.cache.UpperTorso or _Fun.cache.Torso or _Fun.cache.LowerTorso
    local waistBind = (_Fun.binds and (_Fun.binds.Waist or _Fun.binds.UpperTorso or _Fun.binds.Torso or _Fun.binds.LowerTorso))

    local armPoseTaken = false
    local headTaken = false

    -- ===== ARMS (priority order) =====
    if _G._HaloHeliArmsEnabled then
        armPoseTaken = true
        _Fun.heli = (_Fun.heli or 0) + dt * 8
        local a = _Fun.heli
        if rU then rU.Transform = CFrame.Angles(math.rad(90), 0, a) end
        if lU then lU.Transform = CFrame.Angles(math.rad(90), 0, a + math.pi) end
        if rL then rL.Transform = CFrame.new() end
        if lL then lL.Transform = CFrame.new() end
    elseif _G._HaloHandsUpEnabled then
        armPoseTaken = true
        if rU then rU.Transform = CFrame.Angles(math.rad(-160), math.rad(-20), math.rad(20)) end
        if lU then lU.Transform = CFrame.Angles(math.rad(-160), math.rad(20), math.rad(-20)) end
        if rL then rL.Transform = CFrame.Angles(math.rad(-20), 0, 0) end
        if lL then lL.Transform = CFrame.Angles(math.rad(-20), 0, 0) end
    elseif _G._HaloCrossArmsEnabled then
        armPoseTaken = true
        if rU then rU.Transform = CFrame.Angles(math.rad(-70), math.rad(-40), math.rad(50)) end
        if lU then lU.Transform = CFrame.Angles(math.rad(-70), math.rad(40), math.rad(-50)) end
        if rL then rL.Transform = CFrame.Angles(math.rad(-80), 0, math.rad(20)) end
        if lL then lL.Transform = CFrame.Angles(math.rad(-80), 0, math.rad(-20)) end
    elseif _G._HaloShrugEnabled then
        armPoseTaken = true
        if rU then rU.Transform = CFrame.Angles(math.rad(-30), 0, math.rad(70)) end
        if lU then lU.Transform = CFrame.Angles(math.rad(-30), 0, math.rad(-70)) end
        if rL then rL.Transform = CFrame.Angles(math.rad(-50), 0, 0) end
        if lL then lL.Transform = CFrame.Angles(math.rad(-50), 0, 0) end
    elseif _G._HaloTPoseEnabled then
        armPoseTaken = true
        applyTPose()
    end

    -- ===== HEAD =====
    if _G._HaloSpinHeadEnabled and head and headBind then
        headTaken = true
        local spd = tonumber(_G._HaloSpinHeadSpeed) or 1.5
        _Fun.spin = (_Fun.spin + dt * spd * math.pi * 2) % (math.pi * 2)
        head.Transform = CFrame.Angles(0, _Fun.spin, 0) * headBind
        _Fun.headSmooth = nil
    elseif _G._HaloStareEnabled and head and headBind then
        headTaken = true
        local targetHRP = nearestOtherPlayerHRP()
        if targetHRP then
            aimHeadAtWorldPos(head, headBind, targetHRP.Position + Vector3.new(0, 1.5, 0), true)
        end
    elseif _G._HaloLookBehindEnabled and head and headBind then
        local targetHRP = nearestOtherPlayerHRP()
        local parentWorldCF = getParentWorldCF(head)
        if targetHRP and parentWorldCF then
            local toTarget = (targetHRP.Position - parentWorldCF.Position)
            local forward = parentWorldCF.LookVector
            local flatTo = Vector3.new(toTarget.X, 0, toTarget.Z)
            local flatFwd = Vector3.new(forward.X, 0, forward.Z)
            if flatTo.Magnitude > 0.1 and flatFwd.Magnitude > 0.1 then
                local dot = flatFwd.Unit:Dot(flatTo.Unit)
                if dot < -0.15 then
                    headTaken = true
                    -- look back toward them
                    aimHeadAtWorldPos(head, headBind, targetHRP.Position + Vector3.new(0, 1.5, 0), true)
                end
            end
        end
    elseif _G._HaloNodLoopEnabled and head and headBind then
        headTaken = true
        local nod = math.sin(t * 2.5) * math.rad(18)
        head.Transform = headBind * CFrame.Angles(nod, 0, 0)
    elseif _G._HaloHeadTiltEnabled and head and headBind then
        headTaken = true
        head.Transform = headBind * CFrame.Angles(0, 0, math.rad(18))
    end

    -- Crane neck (positional offset on head constraint)
    if _G._HaloCraneNeckEnabled and head then
        local base = head.Transform
        head.Transform = CFrame.new(0, 1.1, 0) * base
        headTaken = true
    end

    -- ===== TORSO =====
    if waist then
        local base = waist.Transform
        if _G._HaloTorsoFaceNearest then
            local targetHRP = nearestOtherPlayerHRP()
            local parentWorldCF = getParentWorldCF(waist)
            if targetHRP and parentWorldCF then
                local aimDir = (targetHRP.Position - parentWorldCF.Position)
                if aimDir.Magnitude > 0.1 then
                    local localAim = parentWorldCF.Rotation:Inverse() * aimDir.Unit
                    local yaw = math.atan2(localAim.X, -localAim.Z)
                    yaw = math.clamp(yaw, -math.rad(70), math.rad(70))
                    local target = CFrame.Angles(0, -yaw, 0) * (waistBind or CFrame.new())
                    _Fun.waistSmooth = (_Fun.waistSmooth or (waistBind or CFrame.new())):Lerp(target, 0.12)
                    waist.Transform = _Fun.waistSmooth
                    base = waist.Transform
                end
            end
        end
        if _G._HaloLeanBackEnabled then
            waist.Transform = CFrame.Angles(math.rad(-35), 0, 0) * (waistBind or base)
        end
        if _G._HaloDrunkSwayEnabled then
            local sway = CFrame.Angles(
                math.sin(t * 1.2) * 0.12,
                math.sin(t * 0.9) * 0.18,
                math.sin(t * 1.5) * 0.08
            )
            waist.Transform = (waist.Transform) * sway
        end
    end

    -- ===== TWITCH =====
    if _G._HaloTwitchEnabled then
        _Fun.twitchT = (_Fun.twitchT or 0) - dt
        if _Fun.twitchT <= 0 then
            _Fun.twitchT = 0.15 + math.random() * 0.55
            _Fun.twitchH = (math.random() - 0.5) * 0.25
            _Fun.twitchY = (math.random() - 0.5) * 0.3
            _Fun.twitchA = (math.random() - 0.5) * 0.2
        end
        if head and not headTaken and headBind then
            head.Transform = headBind * CFrame.Angles(_Fun.twitchH or 0, _Fun.twitchY or 0, 0)
        elseif head and headTaken then
            head.Transform = head.Transform * CFrame.Angles((_Fun.twitchH or 0) * 0.4, (_Fun.twitchY or 0) * 0.4, 0)
        end
        if not armPoseTaken then
            if rU and rUb and not _G._HaloRightArmPointerEnabled then
                rU.Transform = rUb * CFrame.Angles(_Fun.twitchA or 0, 0, 0)
            end
            if lU and lUb and not _G._HaloLeftArmPointerEnabled then
                lU.Transform = lUb * CFrame.Angles(-(_Fun.twitchA or 0), 0, 0)
            end
        end
    end

    -- ===== IDLE WOBBLE (lowest priority layer) =====
    if _G._HaloIdleWobbleEnabled then
        applyIdleWobble(dt)
    end
end

local function startFunTracking()
    if _Fun.conn then _Fun.conn:Disconnect(); _Fun.conn = nil end
    buildFunLimbCache()
    _Fun.conn = RunService.PreSimulation:Connect(LPH_NO_VIRTUALIZE(function(dt)
        if not State.isReanimated then return end
        if not (
            _G._HaloStareEnabled or _G._HaloIdleWobbleEnabled or _G._HaloSpinHeadEnabled or _G._HaloTPoseEnabled
            or _G._HaloLookBehindEnabled or _G._HaloHeadTiltEnabled or _G._HaloNodLoopEnabled
            or _G._HaloCraneNeckEnabled or _G._HaloHandsUpEnabled or _G._HaloCrossArmsEnabled
            or _G._HaloTorsoFaceNearest or _G._HaloDrunkSwayEnabled or _G._HaloTwitchEnabled
            or _G._HaloHeliArmsEnabled or _G._HaloLeanBackEnabled or _G._HaloShrugEnabled
        ) then
            return
        end
        doFunTracking(dt or 0.016)
    end))
end

local function stopFunTracking()
    if _Fun.conn then _Fun.conn:Disconnect(); _Fun.conn = nil end
end

-- Hook into reanimate toggle (chain after existing hooks, no extra locals)
_G._HaloDoReanimToggle_prev_head = _G._HaloDoReanimToggle
_G._HaloDoReanimToggle = function()
    local wasReanimated = State.isReanimated
    local prev = _G._HaloDoReanimToggle_prev_head
    if type(prev) == "function" then prev() end
    if State.isReanimated and not wasReanimated then
        startStandaloneHeadTracker()
        startFunTracking()
    elseif not State.isReanimated and wasReanimated then
        stopStandaloneHeadTracker()
        stopFunTracking()
    end
end

-- Start immediately if already reanimated
if State.isReanimated then
    startStandaloneHeadTracker()
    startFunTracking()
end

-- Rebuild cache on character swap
plr.CharacterAdded:Connect(function()
    task.wait(0.6)
    if State.isReanimated then
        buildStandaloneHeadCache()
        buildFunLimbCache()
    end
end)

-- ============================================================
-- EXTRA LIMB TOOLS RUNTIME (Gun Aim / Wave / Headbang / Floppy)
-- Isolated IIFE — keeps locals out of the main register pool
-- ============================================================
task.spawn(function()
    local _Extra = _G._HaloExtraLimbs or { conn = nil, t = 0, cache = nil, binds = nil }
    _G._HaloExtraLimbs = _Extra

    local function rebuildCache()
        local clone = ReanimateAPI and ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
        if not clone then _Extra.cache = nil; _Extra.binds = nil; return end
        _Extra.cache = {}
        _Extra.binds = {}
        local want = {
            Head = true,
            RightUpperArm = true, RightLowerArm = true, RightHand = true,
            LeftUpperArm = true, LeftLowerArm = true, LeftHand = true,
        }
        for _, d in ipairs(clone:GetDescendants()) do
            local name = nil
            if d:IsA("AnimationConstraint") then
                local att = d.Attachment1
                if att and att.Parent and want[att.Parent.Name] then name = att.Parent.Name end
            elseif d:IsA("Motor6D") and d.Part1 and want[d.Part1.Name] then
                name = d.Part1.Name
            end
            if name and not _Extra.cache[name] then
                _Extra.cache[name] = d
                _Extra.binds[name] = d.Transform
            end
        end
    end

    local function parentWorld(constraint)
        if not constraint then return nil end
        if constraint:IsA("Motor6D") and constraint.Part0 then
            return constraint.Part0.CFrame * constraint.C0
        end
        local att0 = constraint.Attachment0
        if att0 and att0.Parent then return att0.WorldCFrame end
        return nil
    end

    local function mouseWorldPos()
        local camera = workspace.CurrentCamera
        local mouse = plr:GetMouse()
        if not camera or not mouse then return nil end
        local unitRay = camera:ViewportPointToRay(mouse.X, mouse.Y)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local filter = {}
        pcall(function()
            local clone = ReanimateAPI.get_clone and ReanimateAPI.get_clone(plr)
            if clone then table.insert(filter, clone) end
            if plr.Character then table.insert(filter, plr.Character) end
        end)
        params.FilterDescendantsInstances = filter
        local hit = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, params)
        return hit and hit.Position or (unitRay.Origin + unitRay.Direction * 80)
    end

    local function aimUpperArm(upperName, lowerName, handName, aimPos, elbowBendDeg)
        local upper = _Extra.cache and _Extra.cache[upperName]
        if not upper then return end
        local worldCF = parentWorld(upper)
        if not worldCF or not aimPos then return end
        local aimDir = (aimPos - worldCF.Position)
        if aimDir.Magnitude < 0.05 then return end
        aimDir = aimDir.Unit
        local bind = (_Extra.binds and _Extra.binds[upperName]) or upper.Transform
        local childBoneDir = Vector3.new(0, -1, 0)
        local bindBoneDir = (bind.Rotation * childBoneDir).Unit
        local localAim = worldCF.Rotation:Inverse() * aimDir
        local rotAxis = bindBoneDir:Cross(localAim)
        local result = bind
        if rotAxis.Magnitude > 0.001 then
            local angle = math.acos(math.clamp(bindBoneDir:Dot(localAim), -1, 1))
            result = CFrame.fromAxisAngle(rotAxis.Unit, angle) * bind
        elseif bindBoneDir:Dot(localAim) < 0 then
            local perp = bindBoneDir:Cross(Vector3.new(0, 1, 0))
            if perp.Magnitude < 0.001 then perp = bindBoneDir:Cross(Vector3.new(1, 0, 0)) end
            result = CFrame.fromAxisAngle(perp.Unit, math.pi) * bind
        end
        upper.Transform = result
        local lower = _Extra.cache and _Extra.cache[lowerName]
        local hand = _Extra.cache and _Extra.cache[handName]
        if lower then lower.Transform = CFrame.Angles(math.rad(elbowBendDeg or -35), 0, 0) end
        if hand then hand.Transform = CFrame.new() end
    end

    local function tickExtra(dt)
        if not State.isReanimated then return end
        local any = _G._HaloGunAimEnabled or _G._HaloWaveArmEnabled
            or _G._HaloHeadbangEnabled or _G._HaloFloppyArmsEnabled
        if not any then return end
        if not _Extra.cache then rebuildCache() end
        if not _Extra.cache then return end
        _Extra.t = (_Extra.t or 0) + (dt or 0.016)
        local t = _Extra.t

        -- Gun Aim (right arm toward mouse, bent elbow)
        if _G._HaloGunAimEnabled then
            local aim = mouseWorldPos()
            aimUpperArm("RightUpperArm", "RightLowerArm", "RightHand", aim, -55)
        end

        -- Wave Arm
        if _G._HaloWaveArmEnabled then
            local side = _G._HaloWaveArmSide or "Right"
            local uName = side == "Left" and "LeftUpperArm" or "RightUpperArm"
            local lName = side == "Left" and "LeftLowerArm" or "RightLowerArm"
            local hName = side == "Left" and "LeftHand" or "RightHand"
            local upper = _Extra.cache[uName]
            local lower = _Extra.cache[lName]
            local hand = _Extra.cache[hName]
            local wave = math.sin(t * 6) * math.rad(40)
            local lift = math.rad(-90)
            local out = (side == "Left") and math.rad(-70) or math.rad(70)
            if upper then upper.Transform = CFrame.Angles(lift, 0, out + wave * 0.35) end
            if lower then lower.Transform = CFrame.Angles(math.rad(-20) + wave, 0, 0) end
            if hand then hand.Transform = CFrame.Angles(0, 0, wave * 0.5) end
        end

        -- Headbang
        if _G._HaloHeadbangEnabled then
            local head = _Extra.cache.Head
            local bind = (_Extra.binds and _Extra.binds.Head) or CFrame.new()
            if head then
                local spd = tonumber(_G._HaloHeadbangSpeed) or 1.4
                local bang = math.sin(t * spd * math.pi * 2) * math.rad(32)
                head.Transform = bind * CFrame.Angles(bang, 0, 0)
            end
        end

        -- Floppy Arms
        if _G._HaloFloppyArmsEnabled then
            local sway = math.sin(t * 1.8)
            local sway2 = math.sin(t * 2.3 + 1.1)
            local rU, rL = _Extra.cache.RightUpperArm, _Extra.cache.RightLowerArm
            local lU, lL = _Extra.cache.LeftUpperArm, _Extra.cache.LeftLowerArm
            local rH, lH = _Extra.cache.RightHand, _Extra.cache.LeftHand
            if rU then rU.Transform = CFrame.Angles(math.rad(15) + sway * 0.15, 0, math.rad(25) + sway * 0.1) end
            if lU then lU.Transform = CFrame.Angles(math.rad(15) + sway2 * 0.15, 0, math.rad(-25) + sway2 * 0.1) end
            if rL then rL.Transform = CFrame.Angles(math.rad(-25) + sway * 0.2, 0, 0) end
            if lL then lL.Transform = CFrame.Angles(math.rad(-25) + sway2 * 0.2, 0, 0) end
            if rH then rH.Transform = CFrame.Angles(sway * 0.15, 0, 0) end
            if lH then lH.Transform = CFrame.Angles(sway2 * 0.15, 0, 0) end
        end
    end

    local function start()
        if _Extra.conn then _Extra.conn:Disconnect(); _Extra.conn = nil end
        rebuildCache()
        _Extra.conn = RunService.PreSimulation:Connect(function(dt)
            pcall(tickExtra, dt)
        end)
    end

    local function stop()
        if _Extra.conn then _Extra.conn:Disconnect(); _Extra.conn = nil end
    end

    -- Chain into reanim toggle
    local prev = _G._HaloDoReanimToggle
    _G._HaloDoReanimToggle = function()
        local was = State.isReanimated
        if type(prev) == "function" then prev() end
        if State.isReanimated and not was then
            start()
        elseif not State.isReanimated and was then
            stop()
        end
    end

    if State.isReanimated then start() end
    plr.CharacterAdded:Connect(function()
        task.wait(0.6)
        if State.isReanimated then rebuildCache() end
    end)
end)

-- ============================================================
