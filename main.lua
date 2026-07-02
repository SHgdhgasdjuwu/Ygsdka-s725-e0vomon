-- [[ NR Evomon v3 — ModernV2 UI Port ]] --

local ModernV2 = loadstring(game:HttpGet("https://raw.githubusercontent.com/woihqdoishaodh/Grexss/refs/heads/main/Main.lua"))()

local Svc = {
    Players  = game:GetService("Players"),
    Run      = game:GetService("RunService"),
    UIS      = game:GetService("UserInputService"),
    VIM      = game:GetService("VirtualInputManager"),
    Http     = game:GetService("HttpService"),
    Teleport = game:GetService("TeleportService"),
}

local plr  = Svc.Players.LocalPlayer
local PGui = plr:WaitForChild("PlayerGui")

local S = {
    AutoCatch       = false,
    AutoFarm        = false,
    AutoLeave       = false,
    TpFarm          = false,
    PlayerESP       = false,
    ChestFarm       = false,
    NoBall          = false,
    AutoKingBall    = false,
    AutoAdvBall     = false,
    AutoPrismBall   = false,
    ShowPityOverlay = false,
    CatchShinyOnly  = false,
    CatchShinyPris  = false,
    PrisReady       = false,
    Running         = true,
    Closed          = false,
    ChestDelay      = 4,
    ScanRadius      = 500,
    LoopDelay       = 2,
    DebugMode       = true,
    LastDebug       = 0,
    DebugInterval   = 0.5,
    ChestIdx        = 0,
    ESPCache        = {},
    LastPetName     = nil,
}

local isSpamming = false
local selBoss    = nil
local selPlayer  = nil
local S_BossLoop = false

local cToggle, farmToggle, lToggle, tpToggle = nil, nil, nil, nil

-- ==========================================
-- PET NAMES
-- ==========================================
local PetNames = {
    ["Pet0_18"]="Pebble",    ["Pet0_19"]="Pebroll",   ["Pet0_34"]="Budling",
    ["Pet0_16"]="Mopebun",   ["Pet0_31"]="Clampip",   ["Pet0_21"]="Sparkit",
    ["Pet0_52"]="Lavite",    ["Pet0_80"]="Datubud",   ["Pet0_85"]="Mudbud",
    ["Pet0_54"]="Stardrift", ["Pet0_46"]="Glaclide",  ["Pet0_47"]="Glacone",
    ["Pet0_10"]="Chirppy",   ["Pet0_11"]="Chirplume", ["Pet0_74"]="Tinkog",
    ["Pet0_13"]="Humdig",    ["Pet0_14"]="Flutterby", ["Pet0_24"]="Gulpfish",
    ["Pet0_25"]="Mirefish",  ["Pet0_61"]="Frostseer", ["Pet0_64"]="Gempillar",
    ["Pet0_49"]="Chitmite",  ["Pet0_50"]="Chitgladi", ["Pet0_37"]="Vipip",
    ["Pet0_38"]="Vipour",    ["Pet0_66"]="Tarro",     ["Pet0_67"]="Tarragon",
    ["Pet0_72"]="Starloop",  ["Pet0_73"]="Starmuse",  ["Pet0_82"]="Wispuff",
    ["Pet0_83"]="Wispshade", ["Pet0_44"]="Fluffet",   ["Pet0_58"]="Spikub",
    ["Pet0_59"]="Spikumane",
}
local function petName(n) return PetNames[n] or n end

-- ==========================================
-- BOSS LIST
-- ==========================================
local BOSS_LIST = {
    { configId=10001, battlePoolId=9000001,  name="1. Pebgolem"     },
    { configId=10002, battlePoolId=9000002,  name="2. Clamspire"    },
    { configId=10004, battlePoolId=9000003,  name="3. Empixy"       },
    { configId=10005, battlePoolId=9000004,  name="4. Datunymph"    },
    { configId=10008, battlePoolId=9000005,  name="5. Glacitadel"   },
    { configId=10009, battlePoolId=9000006,  name="6. Volcrest"     },
    { configId=10011, battlePoolId=9000007,  name="7. Tinkore"      },
    { configId=10012, battlePoolId=9000008,  name="8. Frostseer"    },
    { configId=10014, battlePoolId=9000009,  name="9. Chitaladin"   },
    { configId=10016, battlePoolId=9000010,  name="10. Viparch"     },
    { configId=10017, battlePoolId=9000011,  name="11. Starmuse"    },
    { configId=10019, battlePoolId=9000012,  name="12. Spikumane"   },
    { configId=10020, battlePoolId=9000014,  name="13. Sundercrene" },
    { configId=10021, battlePoolId=9000013,  name="14. Arcapex"     },
}
local bossNames, bossMap = {}, {}
for _, b in ipairs(BOSS_LIST) do
    table.insert(bossNames, b.name)
    bossMap[b.name] = b
end
selBoss = bossMap[bossNames[1]]

-- ==========================================
-- PET CONFIG ID MAP
-- ==========================================
local PET_CONFIG_MAP = {
    ["Pet0_1"]  = 1000001, ["Pet0_2"]  = 1000002, ["Pet0_3"]  = 1000003,
    ["Pet0_4"]  = 1000004, ["Pet0_5"]  = 1000005, ["Pet0_6"]  = 1000006,
    ["Pet0_7"]  = 1000007, ["Pet0_8"]  = 1000008, ["Pet0_9"]  = 1000009,
    ["Pet0_10"] = 1000010, ["Pet0_11"] = 1000011, ["Pet0_12"] = 1000012,
    ["Pet0_13"] = 1000013, ["Pet0_14"] = 1000014, ["Pet0_15"] = 1000015,
    ["Pet0_16"] = 1000016, ["Pet0_17"] = 1000017, ["Pet0_18"] = 1000018,
    ["Pet0_19"] = 1000019, ["Pet0_20"] = 1000020, ["Pet0_21"] = 1000021,
    ["Pet0_22"] = 1000022, ["Pet0_23"] = 1000023, ["Pet0_24"] = 1000024,
    ["Pet0_25"] = 1000025, ["Pet0_26"] = 1000026, ["Pet0_27"] = 1000027,
    ["Pet0_28"] = 1000028, ["Pet0_29"] = 1000029, ["Pet0_30"] = 1000030,
    ["Pet0_31"] = 1000031, ["Pet0_32"] = 1000032, ["Pet0_33"] = 1000033,
    ["Pet0_34"] = 1000034, ["Pet0_35"] = 1000035, ["Pet0_36"] = 1000036,
    ["Pet0_37"] = 1000037, ["Pet0_38"] = 1000038, ["Pet0_39"] = 1000039,
    ["Pet0_40"] = 1000040, ["Pet0_41"] = 1000041, ["Pet0_42"] = 1000042,
    ["Pet0_43"] = 1000043, ["Pet0_44"] = 1000044, ["Pet0_45"] = 1000045,
    ["Pet0_46"] = 1000046, ["Pet0_47"] = 1000047, ["Pet0_48"] = 1000048,
    ["Pet0_49"] = 1000049, ["Pet0_50"] = 1000050, ["Pet0_51"] = 1000051,
    ["Pet0_52"] = 1000052, ["Pet0_53"] = 1000053, ["Pet0_54"] = 1000054,
    ["Pet0_55"] = 1000055, ["Pet0_56"] = 1000056, ["Pet0_57"] = 1000057,
    ["Pet0_58"] = 1000058, ["Pet0_59"] = 1000059, ["Pet0_60"] = 1000060,
    ["Pet0_61"] = 1000061, ["Pet0_62"] = 1000062, ["Pet0_63"] = 1000063,
    ["Pet0_64"] = 1000064, ["Pet0_65"] = 1000065, ["Pet0_66"] = 1000066,
    ["Pet0_67"] = 1000067, ["Pet0_68"] = 1000068, ["Pet0_69"] = 1000069,
    ["Pet0_70"] = 1000070, ["Pet0_71"] = 1000071, ["Pet0_72"] = 1000072,
    ["Pet0_73"] = 1000073, ["Pet0_74"] = 1000074, ["Pet0_75"] = 1000075,
    ["Pet0_76"] = 1000076, ["Pet0_77"] = 1000077, ["Pet0_78"] = 1000078,
    ["Pet0_79"] = 1000079, ["Pet0_80"] = 1000080, ["Pet0_81"] = 1000081,
    ["Pet0_82"] = 1000082, ["Pet0_83"] = 1000083, ["Pet0_84"] = 1000084,
    ["Pet0_85"] = 1000085, ["Pet0_86"] = 1000086, ["Pet0_87"] = 1000087,
    ["Pet0_88"] = 1000088, ["Pet0_89"] = 1000089, ["Pet0_90"] = 1000090,
    ["Pet0_91"] = 1000091, ["Pet0_92"] = 1000092, ["Pet0_93"] = 1000093,
    ["Pet0_94"] = 1000094, ["Pet0_95"] = 1000095, ["Pet0_96"] = 1000096,
    ["Pet0_97"] = 1000097, ["Pet0_98"] = 1000098, ["Pet0_99"] = 1000099,
    ["Pet0_100"]= 1000100, ["Pet0_101"]= 1000101, ["Pet0_102"]= 1000102,
    ["Pet0_103"]= 1000103, ["Pet0_104"]= 1000104, ["Pet0_105"]= 1000105,
    ["Pet0_106"]= 1000106, ["Pet0_107"]= 1000107, ["Pet0_108"]= 1000108,
}

local S_TargetFarm       = false
local S_SelectedConfigId = nil

local CONFIG_TO_DISPLAY = {}
local DISPLAY_TO_CONFIG = {}
for model, configId in pairs(PET_CONFIG_MAP) do
    local dname = PetNames[model]
    if dname then
        CONFIG_TO_DISPLAY[configId] = dname
        DISPLAY_TO_CONFIG[dname]    = configId
    end
end

local PET_DROPDOWN_LIST = {}
for dname in pairs(DISPLAY_TO_CONFIG) do table.insert(PET_DROPDOWN_LIST, dname) end
table.sort(PET_DROPDOWN_LIST)
S_SelectedConfigId = DISPLAY_TO_CONFIG[PET_DROPDOWN_LIST[1]] or nil

-- ==========================================
-- SKILL SYSTEM — single declaration block, no duplicates
-- ==========================================
local AUTO_SKILL_ENABLED = false
local SKILL_DEBUG        = true
local SKILL_CLICK_DELAY  = 0.5      -- random mode
local SKILL_ENTRY_DELAY  = 2.5      -- wait after battle starts before first fire
local SKILL_SLOT_DELAY   = { [1]=1.2, [2]=1.2, [3]=1.2, [4]=1.2 }

local SKILL_KEYCODES = {
    [1] = Enum.KeyCode.One,
    [2] = Enum.KeyCode.Two,
    [3] = Enum.KeyCode.Three,
    [4] = Enum.KeyCode.Four,
}

local SKILL_CONFIG_ENABLED = false
local SKILL_QUEUE          = {}
local skillQueueIdx        = 1
local listSkilConfig       = nil

local _cachedScrollView    = nil

local function getScrollView()
    if _cachedScrollView and _cachedScrollView.Parent then
        return _cachedScrollView
    end
    local prefabs = PGui:FindFirstChild("UIPrefabs", true)
    if not prefabs then return nil end
    local bw = prefabs:FindFirstChild("MainBattleWindow", true)
    if not bw then return nil end
    local sv = bw:FindFirstChild("PetNormalSkillScrollView", true)
    if sv and sv.Parent then _cachedScrollView = sv return sv end
    return nil
end

local function getSkillButtons()
    local sv = getScrollView()
    if not sv then return {} end
    local buttons = {}
    for _, item in ipairs(sv:GetChildren()) do
        if item.Name == "PetSkillItem" then
            local frame = item:FindFirstChild("ItemFrame")
            local btn   = frame and frame:FindFirstChild("SkillButton")
            if btn and btn.Visible and btn.Parent then
                table.insert(buttons, btn)
            end
        end
    end
    return buttons
end

local function fireSkillSlot(slotIndex, btn)
    local kc = SKILL_KEYCODES[slotIndex]
    if kc then
        local ok = pcall(function()
            Svc.VIM:SendKeyEvent(true,  kc, false, game)
            task.wait(0.05)
            Svc.VIM:SendKeyEvent(false, kc, false, game)
        end)
        if SKILL_DEBUG then warn(string.format("[SKILL] key=%s slot=%d ok=%s", tostring(kc), slotIndex, tostring(ok))) end
        return ok
    end
    -- mouse fallback for slot > 4
    if not btn or not btn.Parent then return false end
    local ok = pcall(function()
        local ap = btn.AbsolutePosition
        local as = btn.AbsoluteSize
        Svc.VIM:SendMouseButtonEvent(ap.X + as.X/2, ap.Y + as.Y/2, 0, true,  game, 1)
        task.wait(0.05)
        Svc.VIM:SendMouseButtonEvent(ap.X + as.X/2, ap.Y + as.Y/2, 0, false, game, 1)
    end)
    if SKILL_DEBUG then warn(string.format("[SKILL] mouse fallback slot=%s ok=%s", tostring(slotIndex), tostring(ok))) end
    return ok
end

local function updateSkillConfigLabel()
    if not listSkilConfig then return end
    if #SKILL_QUEUE == 0 then
        pcall(function() listSkilConfig:SetText("Skill List: (empty)") end)
        return
    end
    local parts = {}
    for i, entry in ipairs(SKILL_QUEUE) do
        table.insert(parts, i .. ". Skill " .. entry.slot)
    end
    pcall(function() listSkilConfig:SetText("Skill List: " .. table.concat(parts, " → ")) end)
end

-- ==========================================
-- CACHE SCAN
-- ==========================================
local function findPetUidByConfig(targetConfigId)
    local rc    = workspace:FindFirstChild("RuntimeCache")
    local rcs   = rc  and rc:FindFirstChild("RuntimeCacheServer")
    local cache = rcs and rcs:FindFirstChild("CreatureModelCache")
    if not cache then warn("[TargetFarm] CreatureModelCache not found") return nil end
    for _, entry in ipairs(cache:GetChildren()) do
        local rawCid =
            entry:GetAttribute("configid") or entry:GetAttribute("configId") or
            entry:GetAttribute("ConfigId") or entry:GetAttribute("ConfigID")
        local cid = tonumber(rawCid)
        if cid == targetConfigId then
            local uid =
                entry:GetAttribute("creatureUid") or entry:GetAttribute("creatureuid") or
                entry:GetAttribute("CreatureUid") or entry:GetAttribute("CreatureUID")
            if uid then
                S.LastPetName = CONFIG_TO_DISPLAY[targetConfigId] or tostring(targetConfigId)
                return tostring(uid)
            else
                warn(string.format("[TargetFarm] configId %d matched '%s' but creatureUid attr nil", targetConfigId, entry.Name))
            end
        end
    end
    return nil
end

local function enterPetBattle(creatureUid)
    local ok, err = pcall(function()
        game:GetService("ReplicatedStorage")
            :WaitForChild("Remote"):WaitForChild("Battle")
            :WaitForChild("ReqEnterPetBattle"):FireServer(creatureUid)
    end)
    if not ok then warn("[TargetFarm] FireServer failed:", err) end
    return ok
end

local islandDisplayNames   = {}
local islandAssetByDisplay = {}

if not _G.NR_hooked then
    _G.NR_hooked = true
    local ok, err = pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local ok2, name = pcall(function() return self.Name end)
            if ok2 and name == "ReqSetMainPet" and method == "InvokeServer" then
                local args = {...}
                if args[1] and type(args[1]) == "string" then _G.NR_petUID = args[1] end
            end
            return oldNamecall(self, ...)
        end)
    end)
    if not ok then warn("[NR] hookmetamethod gagal:", err) end
end
_G.NR_petUID = nil

task.spawn(function()
    task.wait(1)
    Svc.VIM:SendKeyEvent(true,  Enum.KeyCode.Two, false, game) task.wait(0.1)
    Svc.VIM:SendKeyEvent(false, Enum.KeyCode.Two, false, game) task.wait(0.3)
    Svc.VIM:SendKeyEvent(true,  Enum.KeyCode.One, false, game) task.wait(0.1)
    Svc.VIM:SendKeyEvent(false, Enum.KeyCode.One, false, game)
end)

local function pressKey(k, dur)
    pcall(function()
        Svc.VIM:SendKeyEvent(true,  k, false, game) task.wait(dur or 0.05)
        Svc.VIM:SendKeyEvent(false, k, false, game)
    end)
end

local cachedPris  = { cur = nil, max = nil }
local cachedShiny = { cur = nil, max = nil }

local function getPityInfo()
    local sp = PGui:FindFirstChild("SparklePityText", true)
    if sp then
        local c, m = sp.Text:match("(%d+)/(%d+)")
        if c and m then cachedPris.cur = tonumber(c) cachedPris.max = tonumber(m) end
    end
    return cachedPris.cur, cachedPris.max
end

local function getShinyPityInfo()
    local sp = PGui:FindFirstChild("ShinyPityText", true)
    if sp then
        local c, m = sp.Text:match("(%d+)/(%d+)")
        if c and m then cachedShiny.cur = tonumber(c) cachedShiny.max = tonumber(m) end
    end
    return cachedShiny.cur, cachedShiny.max
end

local _catchCache, _catchCacheTime = false, 0
local function catchVisible()
    local now = os.clock()
    if now - _catchCacheTime < 0.3 then return _catchCache end
    _catchCacheTime = now
    _catchCache = (
        PGui:FindFirstChild("Catch",       true) ~= nil or
        PGui:FindFirstChild("CatchButton", true) ~= nil or
        PGui:FindFirstChild("Catch(2/2)",  true) ~= nil or
        PGui:FindFirstChild("BattleGui",   true) ~= nil
    )
    return _catchCache
end

local function isShiny()
    if not PGui:FindFirstChild("BattleGui", true) then return false end
    local sp = PGui:FindFirstChild("ShinyPityText", true)
    return sp and sp.Text == "--"
end

local function findPet()
    local char = plr.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil, nil end
    local bM, bP, bD = nil, nil, S.ScanRadius
    for _, obj in pairs(workspace:GetDescendants()) do
        if not obj.Name:match("^Pet0_%d+$") then continue end
        if not obj:IsA("Model") then continue end
        if obj == char then continue end
        if Svc.Players:GetPlayerFromCharacter(obj) then continue end
        local fp = obj:GetFullName()
        if not fp:find("RuntimeCacheServer") then continue end
        if not fp:find("CreatureModelCache")  then continue end
        local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
        local hum  = obj:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.Health > 0 then
            local d = (root.Position - hrp.Position).Magnitude
            if d < bD then bD=d bM=obj bP=root end
        end
    end
    return bM, bP, bD
end

-- ==========================================
-- PITY OVERLAY
-- ==========================================
local pityOverlayGui = Instance.new("ScreenGui")
pityOverlayGui.Name           = "NRPityOverlay"
pityOverlayGui.ResetOnSpawn   = false
pityOverlayGui.IgnoreGuiInset = true
pityOverlayGui.DisplayOrder   = 50
pityOverlayGui.Enabled        = false
pityOverlayGui.Parent         = PGui

local pityOverlayLbl = Instance.new("TextLabel")
pityOverlayLbl.AnchorPoint            = Vector2.new(0.5, 0)
pityOverlayLbl.Position               = UDim2.new(0.5, 0, 0, 68)
pityOverlayLbl.Size                   = UDim2.new(0.25, 0, 0, 80)
pityOverlayLbl.BackgroundTransparency = 1
pityOverlayLbl.Text                   = "💎 —/—\n✨ —/—"
pityOverlayLbl.TextScaled             = true
pityOverlayLbl.Font                   = Enum.Font.GothamBold
pityOverlayLbl.TextColor3             = Color3.new(1,1,1)
pityOverlayLbl.TextStrokeTransparency = 0
pityOverlayLbl.TextStrokeColor3       = Color3.new(0,0,0)
pityOverlayLbl.TextXAlignment         = Enum.TextXAlignment.Center
pityOverlayLbl.TextYAlignment         = Enum.TextYAlignment.Top
pityOverlayLbl.Parent                 = pityOverlayGui

-- ==========================================
-- SOUND
-- ==========================================
local function playSound(double)
    task.spawn(function()
        pcall(function()
            local ss    = game:GetService("SoundService")
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://4612359460"
            sound.Volume  = 1
            sound.Parent  = ss
            sound.Loaded:Wait()
            sound:Play()
            if double then task.wait(sound.TimeLength + 0.2) sound:Play() end
            task.wait(sound.TimeLength + 0.5)
            sound:Destroy()
        end)
    end)
end

-- ==========================================
-- SYNC HELPERS
-- ==========================================
local function setAutoLeaveSync(v)
    S.AutoLeave = v
    if lToggle then pcall(function() lToggle:SetValue(v) end) end
end
local function setAutoCatchSync(v)
    S.AutoCatch = v
    if cToggle then pcall(function() cToggle:SetValue(v) end) end
end
local function setAutoFarmSync(v)
    S.AutoFarm = v
    if farmToggle then pcall(function() farmToggle:SetValue(v) end) end
end
local function setTpFarmSync(v)
    S.TpFarm = v
    if tpToggle then pcall(function() tpToggle:SetValue(v) end) end
end

local function onShinyDetected()
    warn("✨ SHINY DETECTED!")
    isSpamming  = false
    S.PrisReady = false
    setAutoCatchSync(false)
    setAutoFarmSync(false)
    setAutoLeaveSync(false)
    if S.TpFarm then setTpFarmSync(false) end
    playSound(false)
    local ballKey = S.AutoKingBall and Enum.KeyCode.Three
        or S.AutoAdvBall   and Enum.KeyCode.Two
        or S.AutoPrismBall and Enum.KeyCode.Four
    if ballKey then
        task.spawn(function()
            task.wait(0.5)
            pressKey(ballKey, 0.1)
            task.wait(0.5)
            isSpamming = true
            for _ = 1, 30 do pressKey(Enum.KeyCode.E, 0.05) task.wait(0.15) end
            isSpamming = false
        end)
    end
end

local function onPrismaticReady()
    warn("💎 PRISMATIC PITY 149/150!")
    S.PrisReady = true
    setAutoLeaveSync(true)
    playSound(true)
end

local function handleCatch()
    if (S.CatchShinyOnly or S.CatchShinyPris) and isShiny() then onShinyDetected() return end
    if S.CatchShinyPris then
        local cur, max = getPityInfo()
        if cur and max and cur >= (max - 1) then
            if not S.AutoLeave then onPrismaticReady() end
            pressKey(Enum.KeyCode.C, 0.1) return
        end
    end
    if S.AutoLeave then
        pressKey(Enum.KeyCode.C, 0.1)
    elseif not S.NoBall then
        pressKey(Enum.KeyCode.E, 0.05) task.wait(0.1)
    end
end

local function tpFarmTick()
    local char = plr.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local m, p, d = findPet()
    if not (m and p) then return end
    S.LastPetName = petName(m.Name)
    hrp.CFrame = p.CFrame * CFrame.new(0, 0, 2.5)
    task.wait(0.15)
    local keys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}
    for _ = 1, 3 do
        local k = keys[math.random(1,4)]
        Svc.VIM:SendKeyEvent(true,  k, false, game) task.wait(0.08)
        Svc.VIM:SendKeyEvent(false, k, false, game) task.wait(0.05)
    end
    pressKey(Enum.KeyCode.E, 0.05)
    task.wait(0.3)
    if not catchVisible() then
        hrp.CFrame = p.CFrame * CFrame.new(0, 0, 1)
        task.wait(0.1)
        pressKey(Enum.KeyCode.E, 0.05)
    end
end

local function doEnterBattle(boss)
    pcall(function()
        local rc    = workspace:FindFirstChild("RuntimeCache")
        local rcs   = rc  and rc:FindFirstChild("RuntimeCacheServer")
        local cache = rcs and rcs:FindFirstChild("CreatureModelCache")
        if cache then
            for _, child in ipairs(cache:GetChildren()) do
                local cid = child:GetAttribute("configId") or child:GetAttribute("ConfigId")
                if tonumber(cid) == boss.configId then
                    local pm = child:FindFirstChildWhichIsA("Model")
                    local br = pm and (pm:FindFirstChild("HumanoidRootPart") or pm.PrimaryPart)
                    local char = plr.Character
                    local mr = char and char:FindFirstChild("HumanoidRootPart")
                    if br and mr then mr.CFrame = br.CFrame * CFrame.new(0,0,4) end
                    break
                end
            end
        end
    end)
    task.wait(0.2)
    if not _G.NR_petUID then return false end
    local ok = pcall(function()
        game:GetService("ReplicatedStorage")
            :WaitForChild("Remote"):WaitForChild("Battle")
            :WaitForChild("ReqEnterNpcBattle")
            :FireServer(boss.configId, boss.battlePoolId, _G.NR_petUID)
    end)
    if ok then
        local waited = 0
        repeat task.wait(0.5) waited += 0.5 until waited >= 15
    end
    return ok
end

-- ==========================================
-- ESP
-- ==========================================
local function createESP(player)
    if player == plr or S.ESPCache[player] then return end
    local con = {}
    local function apply(char)
        if not char then return end
        local hl = Instance.new("Highlight")
        hl.FillColor = Color3.fromRGB(0,170,255) hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.new(1,1,1) hl.Adornee = char hl.Enabled = S.PlayerESP hl.Parent = char
        con.hl = hl
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0,160,0,40) bb.AlwaysOnTop = true
        bb.ExtentsOffset = Vector3.new(0,2.5,0) bb.Enabled = S.PlayerESP bb.Parent = char
        con.bb = bb
        local l = Instance.new("TextLabel", bb)
        l.Size = UDim2.fromScale(1,1) l.BackgroundTransparency = 1 l.TextSize = 12
        l.Font = Enum.Font.SourceSansBold l.TextColor3 = Color3.new(1,1,1) l.TextStrokeTransparency = 0
        con.lbl = l
        local rp = char:WaitForChild("HumanoidRootPart", 5)
        if rp then bb.Adornee = rp end
    end
    if player.Character then apply(player.Character) end
    player.CharacterAdded:Connect(apply)
    S.ESPCache[player] = con
end

local function removeESP(player)
    local c = S.ESPCache[player]
    if c then
        pcall(function() if c.hl then c.hl:Destroy() end if c.bb then c.bb:Destroy() end end)
        S.ESPCache[player] = nil
    end
end

for _, p in ipairs(Svc.Players:GetPlayers()) do createESP(p) end
Svc.Players.PlayerAdded:Connect(createESP)
Svc.Players.PlayerRemoving:Connect(removeESP)

Svc.Run.RenderStepped:Connect(function()
    if not S.PlayerESP then return end
    local char   = plr.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    for tgt, obj in pairs(S.ESPCache) do
        local tc = tgt.Character
        local tr = tc and tc:FindFirstChild("HumanoidRootPart")
        if tr and obj.bb and obj.lbl then
            obj.bb.Enabled = true
            obj.lbl.Text = tgt.Name .. "\n[" .. string.format("%.1f", (tr.Position-myRoot.Position).Magnitude*0.28) .. " m]"
        elseif obj.bb then obj.bb.Enabled = false end
    end
end)

-- ==========================================
-- BATTLE STATE DETECTION
-- ==========================================
local function getBattleCharacterModel()
    local rc  = workspace:FindFirstChild("RuntimeCache")
    local rcc = rc and rc:FindFirstChild("RuntimeCacheClient")
    local bcm = rcc and rcc:FindFirstChild("BattleCharacterModel")
    if not bcm then return nil end
    return bcm:FindFirstChild(plr.Name)
end

local function isBattle()
    return getBattleCharacterModel() ~= nil
end

-- ==========================================
-- MAIN LOOPS
-- ==========================================
task.spawn(function()
    while task.wait(S.LoopDelay) do
        if not S.Running then break end
        if not (S.AutoFarm or S.AutoCatch or S.AutoLeave or S.TpFarm) then continue end
        if catchVisible() then
            if S.AutoCatch then handleCatch() end
            continue
        end
        if S.AutoFarm then
            if S.TpFarm then
                pcall(tpFarmTick)
            else
                pcall(function()
                    local m, p, d = findPet()
                    if m and p then
                        S.LastPetName = petName(m.Name)
                        local char = plr.Character
                        local hum  = char and char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            local keys = {Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D}
                            for _ = 1, math.random(2,4) do
                                local k = keys[math.random(1,4)]
                                Svc.VIM:SendKeyEvent(true,  k, false, game) task.wait(math.random(10,25)/100)
                                Svc.VIM:SendKeyEvent(false, k, false, game) task.wait(0.05)
                            end
                            hum:MoveTo(p.Position)
                        end
                    end
                end)
            end
        elseif S.TpFarm then
            pcall(tpFarmTick)
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if not S.Running then break end
        if S.AutoCatch and catchVisible() then handleCatch() end
    end
end)

task.spawn(function()
    while task.wait(0.05) do
        if not S.Running then break end
        if S.ChestFarm then
            local rc  = workspace:FindFirstChild("RuntimeCache")
            local rcc = rc and rc:FindFirstChild("RuntimeCacheClient")
            local dir = rcc and rcc:FindFirstChild("Chest")
            if dir then
                local list = {}
                for _, c in ipairs(dir:GetChildren()) do
                    if c:IsA("Folder") or c:IsA("Model") then table.insert(list, c) end
                end
                if #list > 0 then
                    S.ChestIdx = S.ChestIdx + 1
                    if S.ChestIdx > #list then S.ChestIdx = 1 end
                    local bp   = list[S.ChestIdx]:FindFirstChildWhichIsA("BasePart", true)
                    local char = plr.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if bp and root then root.CFrame = bp.CFrame * CFrame.new(0,3,0) end
                end
            end
            local el = 0
            while el < S.ChestDelay and S.ChestFarm do
                pressKey(Enum.KeyCode.E, 0.05) task.wait(0.05) el += 0.2
            end
        else task.wait(0.05) end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if not S.Running then break end
        if not S_BossLoop or not selBoss then continue end
        doEnterBattle(selBoss)
        if S_BossLoop then task.wait(1) end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if not S.Running then break end
        if S.ShowPityOverlay then
            local petLabel  = S.LastPetName and ("[" .. S.LastPetName .. "]") or ""
            local cur, max  = getPityInfo()
            local prisText  = (cur and max) and string.format("💎 %d/%d", cur, max) or "💎 —/—"
            local sc, sm    = getShinyPityInfo()
            local shinyText = (sc and sm) and string.format("✨ %d/%d", sc, sm) or "✨ —/—"
            pityOverlayLbl.Text = petLabel ~= ""
                and (petLabel.."\n"..prisText.."\n"..shinyText)
                or  (prisText.."\n"..shinyText)
        end
        if S.CatchShinyPris then
            local cur, max = getPityInfo()
            if cur and max then
                if cur >= (max-1) then S.PrisReady = true end
                if S.PrisReady and not S.AutoLeave then
                    onPrismaticReady()
                elseif not (cur >= max-1) and not S.PrisReady and S.AutoLeave and not isShiny() then
                    setAutoLeaveSync(false)
                end
            end
        end
    end
end)

-- ==========================================
-- AUTO SKILL LOOP — single instance, both modes
-- ==========================================
task.spawn(function()
    local entryWaited = false
    while S.Running do
        task.wait(0.1)
        if not AUTO_SKILL_ENABLED then
            entryWaited = false
            continue
        end
        if not isBattle() then
            _cachedScrollView = nil
            entryWaited       = false
            continue
        end
        if not entryWaited then
            if SKILL_DEBUG then warn("[SKILL] Battle start — entry delay", SKILL_ENTRY_DELAY, "s") end
            task.wait(SKILL_ENTRY_DELAY)
            entryWaited   = true
            skillQueueIdx = 1
        end
        local buttons = getSkillButtons()
        if #buttons == 0 then
            if SKILL_DEBUG then warn("[SKILL] No buttons — retry 0.5s") end
            task.wait(0.5)
            continue
        end
        if SKILL_CONFIG_ENABLED and #SKILL_QUEUE > 0 then
            if skillQueueIdx > #SKILL_QUEUE then skillQueueIdx = 1 end
            local entry     = SKILL_QUEUE[skillQueueIdx]
            local targetIdx = entry.slot
            if targetIdx > #buttons then
                if SKILL_DEBUG then warn(string.format("[SKILL] slot %d requested, only %d visible — skip", targetIdx, #buttons)) end
                skillQueueIdx += 1
                task.wait(0.1)
                continue
            end
            if SKILL_DEBUG then warn(string.format("[SKILL] config | queue[%d] → slot %d", skillQueueIdx, targetIdx)) end
            fireSkillSlot(targetIdx, buttons[targetIdx])
            local delay = SKILL_SLOT_DELAY[targetIdx] or 1.2
            skillQueueIdx += 1
            task.wait(delay)
        else
            local ri = math.random(1, #buttons)
            if SKILL_DEBUG then warn(string.format("[SKILL] random | slot %d", ri)) end
            fireSkillSlot(ri, buttons[ri])
            task.wait(SKILL_CLICK_DELAY)
        end
    end
end)

-- ==========================================
-- TARGET FARM LOOP
-- ==========================================
local S_TargetFarmSignal = Instance.new("BindableEvent")

task.spawn(function()
    while true do
        if not S.Running then break end
        if not S_TargetFarm or not S_SelectedConfigId then
            S_TargetFarmSignal.Event:Wait()
            continue
        end
        if isBattle() then
            repeat task.wait(0.5) until not isBattle() or not S_TargetFarm
            continue
        end
        local uid = findPetUidByConfig(S_SelectedConfigId)
        if uid then
            warn(string.format("[TargetFarm] configId %d (%s) → uid %s", S_SelectedConfigId, CONFIG_TO_DISPLAY[S_SelectedConfigId] or "?", uid))
            local ok = enterPetBattle(uid)
            if ok then
                local ws = os.clock()
                repeat task.wait(0.2) until isBattle() or (os.clock() - ws) >= 3
                local fired = false
                local conn  = S_TargetFarmSignal.Event:Connect(function() fired = true end)
                repeat task.wait(0.3) until not isBattle() or not S_TargetFarm or fired
                conn:Disconnect()
            else
                task.wait(0.3)
            end
        else
            warn(string.format("[TargetFarm] configId %d (%s) not in cache — retry", S_SelectedConfigId, CONFIG_TO_DISPLAY[S_SelectedConfigId] or "?"))
            task.wait(0.3)
        end
    end
end)

local S_AutoChestClaim  = false
local CHEST_CLAIM_CYCLE = 4

local function claimAllChests()
    local rc  = workspace:FindFirstChild("RuntimeCache")
    local rcc = rc  and rc:FindFirstChild("RuntimeCacheClient")
    local dir = rcc and rcc:FindFirstChild("Chest")
    if not dir then warn("[ChestClaim] Folder Chest tidak ditemukan") return 0 end
    local remote = game:GetService("ReplicatedStorage")
        :WaitForChild("Remote"):WaitForChild("Chest"):WaitForChild("ReqClaimExploreReward")
    local claimed = 0
    for _, child in ipairs(dir:GetChildren()) do
        local ok, err = pcall(function() remote:InvokeServer(child.Name) end)
        if ok then claimed += 1 task.wait(0.15)
        else warn("[ChestClaim] Gagal claim " .. child.Name .. " | " .. tostring(err)) end
    end
    return claimed
end

task.spawn(function()
    while S.Running do
        task.wait(CHEST_CLAIM_CYCLE)
        if not S_AutoChestClaim then continue end
        local n = claimAllChests()
        if n > 0 then warn(string.format("[ChestClaim] Claimed %d chest(s)", n)) end
    end
end)

-- ==========================================
-- BUILD UI
-- ==========================================
ModernV2:AddTheme({
    Name        = "J4rz Evomon",
    Accent      = Color3.fromRGB(108, 68, 200),
    Background  = Color3.fromRGB(8, 8, 13),
    Surface     = Color3.fromRGB(18, 18, 26),
    Outline     = Color3.fromRGB(30, 30, 45),
    Text        = Color3.fromRGB(232, 232, 248),
    Placeholder = Color3.fromRGB(60, 60, 90),
    Button      = Color3.fromRGB(108, 68, 200),
    Icon        = Color3.fromRGB(255, 255, 255),
})

ModernV2.Scales = {
    Small   = UDim2.fromOffset(540, 380),
    Compact = UDim2.fromOffset(600, 380),
    Mobile  = UDim2.fromOffset(640, 385),
    Default = UDim2.fromOffset(640, 480),
    Large   = UDim2.fromOffset(800, 600),
}

local MenuIcon = ModernV2:CreateMenuIcon({
    Image       = "grid",
    Size        = 48,
    IconColor   = Color3.fromRGB(255,255,255),
    BGColor     = Color3.fromRGB(18,18,26),
    StrokeColor = Color3.fromRGB(108,68,200),
    StrokeThick = 1.5,
    Draggable   = true,
})

local window = ModernV2:Window({
    Title               = "J4rz Hub",
    Content             = "Free",
    Image               = "85817114798115",
    Color               = Color3.fromRGB(78,127,252),
    Uitransparent       = 0.12,
    ShowUser            = true,
    Search              = true,
    ConfigEnabled       = true,
    NotifyOnCallbackError= false,
    Loadingscreen       = false,
    Enable3DRenderer    = false,
    Size                = ModernV2.IsMobile and ModernV2.Scales.Small or ModernV2.Scales.Large,
    Keybind             = "RightControl",
    Config = {
        ConfigFolder      = "ModernV2Example",
        AutoSaveFile      = "Default",
        AutoSave          = false,
        AutoLoad          = false,
        Overwrite         = true,
        Format            = "JSON",
        ShowAutoSaveToggle= true,
        TextGradient      = false,
    },
})

window:AttachMenuIcon(MenuIcon)
window:SetAccount({ Username=plr.DisplayName, Profile=ModernV2.UserProfile, Expires="Never" })
window:AddTabLabel("FARMING")

-- ==========================================
-- TAB: GENERAL
-- ==========================================
local GenTab = window:AddTab({ Name="General", Icon="lucide:settings-2", Type="Double" })
local AutoSec = GenTab:AddSection({ Name="Automation", Position="Left" })

farmToggle = AutoSec:AddToggle({
    Name="Auto Farm", Default=false, Flag="AutoFarm",
    Callback=function(v) S.AutoFarm=v if not v and S.TpFarm then setTpFarmSync(false) end end,
})
cToggle = AutoSec:AddToggle({
    Name="Auto Catch", Default=false, Flag="AutoCatch",
    Callback=function(v) S.AutoCatch=v end,
})
lToggle = AutoSec:AddToggle({
    Name="Auto Leave", Default=false, Flag="AutoLeave",
    Callback=function(v) S.AutoLeave=v end,
})
tpToggle = AutoSec:AddToggle({
    Name="Teleport Farm Mode", Default=false, Flag="TpFarm",
    Callback=function(v) S.TpFarm=v end,
})
AutoSec:AddToggle({
    Name="Manual Catch (No Ball)", Default=false, Flag="NoBall",
    Callback=function(v) S.NoBall=v end,
})

-- Add these near the top with other locals, after S = { ... }
local _sessionPrefs   = nil
local _battleSettings = nil
local _BattleService  = nil
local _ReqAutoBattle  = nil
local _battleSpeedupConn = nil

local function injectAutoBattle()
    pcall(function()
        -- cache BattleService once
        if not _BattleService then
            pcall(function()
                local Script = game:GetService("ReplicatedStorage"):WaitForChild("Script")
                _BattleService = require(Script:WaitForChild("Battle"):WaitForChild("BattleService"))
            end)
        end
        if not _ReqAutoBattle then
            pcall(function()
                _ReqAutoBattle = game:GetService("ReplicatedStorage")
                    :WaitForChild("Remote"):WaitForChild("Battle")
                    :WaitForChild("ReqAutoBattle")
            end)
        end

        -- re-scan GC every call — refs go stale on new battle
        _sessionPrefs   = nil
        _battleSettings = nil
        for _, obj in pairs(getgc(true)) do
            if type(obj) == "table" then
                if not _sessionPrefs and rawget(obj, "preferBattleSpeed") ~= nil then
                    _sessionPrefs = obj
                end
                if not _battleSettings and rawget(obj, "battleSpeedEnabled") ~= nil then
                    _battleSettings = obj
                end
            end
            if _sessionPrefs and _battleSettings then break end
        end

        if _sessionPrefs then
            _sessionPrefs.preferBattleSpeed = true
            _sessionPrefs.preferAutoBattle  = true
        end
        if _battleSettings then
            _battleSettings.battleSpeedEnabled = true
            _battleSettings.autoBattleEnabled  = true
        end

        if _BattleService and _BattleService.getCurrentBattle and _BattleService.getCurrentBattle() ~= nil then
            pcall(function() _BattleService.autoBattle(true) end)
            if _ReqAutoBattle then
                pcall(function() _ReqAutoBattle:InvokeServer(true) end)
            end
        end
    end)
end

-- Replace the Battle Speed Up toggle with this:
AutoSec:AddToggle({
    Name="Auto x2 Speed", Default=false, Flag="BattleSpeedup",
    Callback=function(v)
        S.BattleSpeedup = v
        if _battleSpeedupConn then
            _battleSpeedupConn:Disconnect()
            _battleSpeedupConn = nil
        end
        if v then
            task.spawn(injectAutoBattle) -- immediate first hit
            -- re-inject every 3s so stale GC refs get refreshed each battle
            _battleSpeedupConn = Svc.Run.Heartbeat:Connect(function()
                if not S.BattleSpeedup then return end
                if isBattle() then
                    pcall(injectAutoBattle)
                end
            end)
            -- throttle: only fire once per 3s
            local _lastInject = 0
            _battleSpeedupConn:Disconnect()
            _battleSpeedupConn = nil
            task.spawn(function()
                while S.BattleSpeedup and S.Running do
                    task.wait(3)
                    if S.BattleSpeedup and isBattle() then
                        pcall(injectAutoBattle)
                    end
                end
            end)
        end
    end,
})

local StatusSec   = GenTab:AddSection({ Name="Status", Position="Right" })
local farmStatLbl = StatusSec:AddLabel({ Text="Farm: Idle", Wrapped=true })
local petStatLbl  = StatusSec:AddLabel({ Text="Last Pet: —", Wrapped=true })

task.spawn(function()
    while task.wait(1) do
        if not S.Running then break end
        local state = "Idle"
        if     S.CatchShinyOnly then state = "✨ Shiny Hunt"
        elseif S.CatchShinyPris then state = "💎 Shiny+Pris Hunt"
        elseif S.AutoFarm and S.TpFarm then state = "🚀 TP Farming"
        elseif S.AutoFarm  then state = "🏃 Walking Farm"
        elseif S.AutoCatch then state = "🎯 Auto Catch"
        elseif S.AutoLeave then state = "↩ Auto Leave" end
        pcall(function() farmStatLbl:SetText("Farm: "..state) end)
        if S.LastPetName then pcall(function() petStatLbl:SetText("Last Pet: "..S.LastPetName) end) end
    end
end)

-- Auto Farm Selected
local TargetSec = GenTab:AddSection({ Name="Auto Farm (Selected)", Position="Left" })

TargetSec:AddDropdown({
    Name="Select Target Pet", Default=PET_DROPDOWN_LIST[1], Values=PET_DROPDOWN_LIST, Multi=false, Search=true,
    Callback=function(v)
        S_SelectedConfigId = DISPLAY_TO_CONFIG[v] or nil
        warn(string.format("[TargetFarm] Selected: %s → configId %s", v, tostring(S_SelectedConfigId)))
        if S_TargetFarm and S_SelectedConfigId then S_TargetFarmSignal:Fire() end
    end,
})
TargetSec:AddToggle({
    Name="Auto Farm (Selected)", Default=false, Flag="TargetFarm",
    Callback=function(v)
        S_TargetFarm = v
        if v and S_SelectedConfigId then S_TargetFarmSignal:Fire() end
    end,
})

-- ==========================================
-- SKILL CONFIGURATION SECTION
-- ==========================================
local SkillSec = GenTab:AddSection({ Name="Skill Configuration", Position="Right" })

listSkilConfig = SkillSec:AddLabel({ Text="Skill List: (empty)", Wrapped=true })

local function makeSkillButton(slot, name)
    SkillSec:AddButton({
        Name=name, Icon="lucide:zap",
        Callback=function()
            local found = nil
            for i, entry in ipairs(SKILL_QUEUE) do
                if entry.slot == slot then found = i break end
            end
            if found then
                table.remove(SKILL_QUEUE, found)
                if skillQueueIdx > #SKILL_QUEUE then skillQueueIdx = 1 end
                window:Notify({ Title="Skill Config", Content=name.." removed", Duration=1.5, Icon="lucide:minus" })
            else
                table.insert(SKILL_QUEUE, { slot=slot })
                window:Notify({ Title="Skill Config", Content=name.." → pos "..#SKILL_QUEUE, Duration=1.5, Icon="lucide:plus" })
            end
            updateSkillConfigLabel()
            if SKILL_DEBUG then
                warn("[SKILL] Queue:") for i, e in ipairs(SKILL_QUEUE) do warn(string.format("  [%d] slot=%d", i, e.slot)) end
            end
        end,
    })
end

makeSkillButton(1, "Skill 1")
makeSkillButton(2, "Skill 2")
makeSkillButton(3, "Skill 3")
makeSkillButton(4, "Skill 4")

SkillSec:AddSlider({
    Name="Skill Delay (s) — Config Mode", Min=0.5, Max=10.0, Default=5.0, Increment=0.1, Flag="SkillSlotDelay",
    Callback=function(v) for i=1,4 do SKILL_SLOT_DELAY[i]=v end end,
})
SkillSec:AddSlider({
    Name="Entry Delay (s) — First skill after battle start", Min=0.5, Max=10.0, Default=3.0, Increment=0.5, Flag="SkillEntryDelay",
    Callback=function(v) SKILL_ENTRY_DELAY=v end,
})
SkillSec:AddButton({
    Name="Clear Queue", Icon="lucide:trash-2",
    Callback=function()
        SKILL_QUEUE={} skillQueueIdx=1 updateSkillConfigLabel()
        window:Notify({ Title="Skill Config", Content="Queue cleared.", Duration=1.5, Icon="lucide:trash-2" })
    end,
})
SkillSec:AddToggle({
    Name="Auto Skill", Default=false, Flag="AutoSkill",
    Callback=function(v) AUTO_SKILL_ENABLED=v end,
})
SkillSec:AddToggle({
    Name="Use Skill Config", Default=false, Flag="UseSkillConfig",
    Callback=function(v)
        SKILL_CONFIG_ENABLED=v skillQueueIdx=1
        if SKILL_DEBUG then warn("[SKILL] UseSkillConfig =", v, "| Queue =", #SKILL_QUEUE) end
    end,
})

SkillSec:AddParagraph({
    Name="Info",
    Content="Entry delay = delay before the first skill. \nSkill delay = delay between skills in the queue.",
})

-- ==========================================
-- TAB: SHINY
-- ==========================================
local ShinyTab = window:AddTab({ Name="Shiny", Icon="lucide:sparkles", Type="Double" })
local ShinySec = ShinyTab:AddSection({ Name="Detection Modes", Position="Left" })

ShinySec:AddToggle({
    Name="Show Pity Overlay", Default=false, Flag="PityOverlay",
    Callback=function(v) S.ShowPityOverlay=v pityOverlayGui.Enabled=v end,
})

local soToggle = ShinySec:AddToggle({
    Name="Catch Shiny Only", Default=false, Flag="CatchShinyOnly",
    Callback=function(v)
        S.CatchShinyOnly=v
        if v then S.CatchShinyPris=false setAutoFarmSync(true) setAutoCatchSync(true) setAutoLeaveSync(true)
        else setAutoFarmSync(false) setAutoCatchSync(false) setAutoLeaveSync(false) end
    end,
})

ShinySec:AddToggle({
    Name="Catch Shiny & Prismatic", Default=false, Flag="CatchShinyPris",
    Callback=function(v)
        S.CatchShinyPris=v
        if v then
            S.CatchShinyOnly=false pcall(function() soToggle:SetValue(false) end)
            setAutoFarmSync(true) setAutoCatchSync(true)
            local cur, max = getPityInfo()
            if cur and max and cur>=(max-1) then setAutoLeaveSync(true) else setAutoLeaveSync(false) end
        else
            S.PrisReady=false setAutoFarmSync(false) setAutoCatchSync(false) setAutoLeaveSync(false)
        end
    end,
})

local BallSec = ShinyTab:AddSection({ Name="Ball on Shiny Detect", Position="Right" })
BallSec:AddToggle({ Name="King Ball",      Default=false, Flag="KingBall",  Callback=function(v) S.AutoKingBall=v  if v then S.AutoAdvBall=false  S.AutoPrismBall=false end end })
BallSec:AddToggle({ Name="Advanced Ball",  Default=false, Flag="AdvBall",   Callback=function(v) S.AutoAdvBall=v   if v then S.AutoKingBall=false S.AutoPrismBall=false end end })
BallSec:AddToggle({ Name="Prismatic Ball", Default=false, Flag="PrismBall", Callback=function(v) S.AutoPrismBall=v if v then S.AutoKingBall=false S.AutoAdvBall=false  end end })

local PitySec      = ShinyTab:AddSection({ Name="Pity Counter", Position="Right" })
local pityDisplayLbl = PitySec:AddLabel({ Text="💎 Prismatic: —/—\n✨ Shiny: —/—", Wrapped=true })

task.spawn(function()
    while task.wait(1) do
        if not S.Running then break end
        local cur, max  = getPityInfo()
        local prisText  = (cur and max) and string.format("💎 Prismatic: %d/%d%s", cur, max, cur>=(max-1) and " ⚠️" or "") or "💎 Prismatic: —/—"
        local sc, sm    = getShinyPityInfo()
        local shinyText = (sc and sm) and string.format("✨ Shiny: %d/%d%s", sc, sm, sc>=sm and " ⚠️" or "") or "✨ Shiny: —/—"
        pcall(function() pityDisplayLbl:SetText(prisText.."\n"..shinyText) end)
    end
end)

-- ==========================================
-- TAB: ESP
-- ==========================================
window:AddTabLabel("TOOLS")
local ESPTab = window:AddTab({ Name="ESP", Icon="lucide:eye", Type="Single" })
local ESPSec = ESPTab:AddSection({ Name="Player ESP", Position="Center" })

ESPSec:AddToggle({
    Name="Player Highlight + Name + Distance", Default=false, Flag="PlayerESP",
    Callback=function(v)
        S.PlayerESP=v
        for _, obj in pairs(S.ESPCache) do
            if obj.hl then obj.hl.Enabled=v end
            if obj.bb then obj.bb.Enabled=v end
        end
    end,
})
ESPSec:AddParagraph({ Name="Info", Content="Blue highlight + name + distance (meters) realtime." })

-- ==========================================
-- TAB: BOSS
-- ==========================================
local BossTab = window:AddTab({ Name="Boss", Icon="lucide:swords", Type="Single" })
local BossSec = BossTab:AddSection({ Name="Boss Farm", Position="Center" })

BossSec:AddDropdown({ Name="Select Boss", Default=bossNames[1], Values=bossNames, Multi=false, Search=false, Callback=function(v) selBoss=bossMap[v] end })
BossSec:AddButton({
    Name="Enter Battle (1x)", Icon="lucide:sword",
    Callback=function()
        if not selBoss then window:Notify({ Title="Boss", Content="Select a boss first!", Duration=2, Icon="lucide:alert-circle" }) return end
        if S_BossLoop  then window:Notify({ Title="Boss", Content="Turn off Loop for manual 1x.", Duration=2, Icon="lucide:alert-circle" }) return end
        if not _G.NR_petUID then window:Notify({ Title="Boss", Content="No Pet UID!", Duration=3, Icon="lucide:alert-circle" }) return end
        task.spawn(function()
            window:Notify({ Title="Boss", Content="Entering "..selBoss.name.."...", Duration=2, Icon="lucide:sword" })
            local ok = doEnterBattle(selBoss)
            window:Notify({ Title="Boss", Content=ok and (selBoss.name.." done!") or "Battle failed.", Duration=2, Icon=ok and "lucide:check" or "lucide:x" })
        end)
    end,
})
BossSec:AddToggle({
    Name="🔁 Loop Boss Battle", Default=false, Flag="BossLoop",
    Callback=function(v) S_BossLoop=v if v and not selBoss then selBoss=bossMap[bossNames[1]] end end,
})

-- ==========================================
-- TAB: CHEST
-- ==========================================
local ChestTab     = window:AddTab({ Name="Chest", Icon="lucide:package", Type="Single" })
local ChestSec     = ChestTab:AddSection({ Name="Chest Farm", Position="Center" })
local ChestInstSec = ChestTab:AddSection({ Name="Chest Instant", Position="Center" })

ChestSec:AddToggle({ Name="Auto Farm Chest", Default=false, Flag="ChestFarm", Callback=function(v) S.ChestFarm=v end })
ChestSec:AddButton({
    Name="Next Chest (Manual)", Icon="lucide:package-open",
    Callback=function()
        local rc  = workspace:FindFirstChild("RuntimeCache")
        local rcc = rc  and rc:FindFirstChild("RuntimeCacheClient")
        local dir = rcc and rcc:FindFirstChild("Chest")
        if not dir then window:Notify({ Title="Chest", Content="No chest folder found.", Duration=2, Icon="lucide:x" }) return end
        local list = {}
        for _, c in ipairs(dir:GetChildren()) do if c:IsA("Folder") or c:IsA("Model") then table.insert(list,c) end end
        if #list==0 then return end
        S.ChestIdx = S.ChestIdx+1
        if S.ChestIdx>#list then S.ChestIdx=1 end
        local bp   = list[S.ChestIdx]:FindFirstChildWhichIsA("BasePart", true)
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if bp and root then root.CFrame = bp.CFrame * CFrame.new(0,3,0) end
    end,
})
ChestInstSec:AddButton({
    Name="Claim All Chests (Now)", Icon="lucide:package-open",
    Callback=function()
        task.spawn(function()
            window:Notify({ Title="Chest", Content="Claiming all chests...", Duration=2, Icon="lucide:loader" })
            local n = claimAllChests()
            window:Notify({ Title="Chest", Content=string.format("Claimed %d chest(s)!", n), Duration=3, Icon=n>0 and "lucide:check" or "lucide:x" })
        end)
    end,
})
ChestInstSec:AddToggle({ Name="Auto Claim All Chests", Default=false, Flag="AutoChestClaim", Callback=function(v) S_AutoChestClaim=v end })
ChestInstSec:AddSlider({ Name="Claim Cycle Delay (s)", Min=1, Max=30, Default=4, Increment=1, Flag="ChestClaimCycle", Callback=function(v) CHEST_CLAIM_CYCLE=v end })

-- ==========================================
-- TAB: TELEPORT
-- ==========================================
local TeleTab = window:AddTab({ Name="Teleport", Icon="lucide:map-pin", Type="Double" })
local TeleSec = TeleTab:AddSection({ Name="Teleport to Player", Position="Left" })

TeleSec:AddDropdown({
    Name="Select Player", Default=nil, Values={}, Multi=false, Search=true, RefreshInterval=3,
    OptionsProvider=function()
        local names = {}
        for _, p in ipairs(Svc.Players:GetPlayers()) do if p~=plr then table.insert(names,p.Name) end end
        if #names==0 then table.insert(names,"(No players)") end
        return names
    end,
    Callback=function(v) selPlayer=v end,
})
TeleSec:AddButton({
    Name="Teleport to Player", Icon="lucide:navigation",
    Callback=function()
        if not selPlayer or selPlayer=="(No players)" then window:Notify({ Title="Teleport", Content="No player selected!", Duration=2, Icon="lucide:alert-circle" }) return end
        local tgt  = Svc.Players:FindFirstChild(selPlayer)
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if tgt and root then
            local tc = tgt.Character
            local tr = tc and tc:FindFirstChild("HumanoidRootPart")
            if tr then root.CFrame = tr.CFrame * CFrame.new(0,0,3) window:Notify({ Title="Teleport", Content="Teleported to "..selPlayer, Duration=2, Icon="lucide:check" }) end
        end
    end,
})

local IslandSec = TeleTab:AddSection({ Name="Teleport to Island", Position="Right" })

local IslandConfig = (function()
    local ok, cfg = pcall(function()
        return require(game:GetService("ReplicatedStorage"):WaitForChild("Config"):WaitForChild("IslandConfig"))
    end)
    if ok and type(cfg)=="table" then return cfg end
    warn("[IslandTP] Failed to load IslandConfig") return {}
end)()

local islandFolder = workspace:FindFirstChild("Scene") and workspace.Scene:FindFirstChild("Island")
islandDisplayNames   = {}
islandAssetByDisplay = {}

if islandFolder then
    for _, entry in ipairs(IslandConfig) do
        if entry.displayName and entry.assetName then
            if islandFolder:FindFirstChild(entry.assetName) then
                table.insert(islandDisplayNames, entry.displayName)
                islandAssetByDisplay[entry.displayName] = entry.assetName
            end
        end
    end
end

local selIsland = islandDisplayNames[1] or nil

if #islandDisplayNames==0 then
    IslandSec:AddLabel({ Text="⚠️ No islands found in scene.", Wrapped=true })
else
    IslandSec:AddDropdown({ Name="Select Island", Default=islandDisplayNames[1], Values=islandDisplayNames, Multi=false, Search=true, Callback=function(v) selIsland=v end })
    IslandSec:AddButton({
        Name="Teleport to Island", Icon="lucide:map-pin",
        Callback=function()
            if not selIsland then window:Notify({ Title="Island TP", Content="Select an island first!", Duration=2, Icon="lucide:alert-circle" }) return end
            local assetName = islandAssetByDisplay[selIsland]
            if not assetName then window:Notify({ Title="Island TP", Content="Asset not mapped: "..selIsland, Duration=3, Icon="lucide:x" }) return end
            local folder = workspace:FindFirstChild("Scene") and workspace.Scene:FindFirstChild("Island")
            if not folder then window:Notify({ Title="Island TP", Content="workspace.Scene.Island missing.", Duration=3, Icon="lucide:x" }) return end
            local targetModel = folder:FindFirstChild(assetName)
            if not targetModel then window:Notify({ Title="Island TP", Content=assetName.." unloaded — rejoin.", Duration=4, Icon="lucide:x" }) return end
            local landPart = targetModel:FindFirstChildWhichIsA("BasePart", true)
            if not landPart then window:Notify({ Title="Island TP", Content="No BasePart in "..assetName, Duration=2, Icon="lucide:x" }) return end
            local char = plr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then window:Notify({ Title="Island TP", Content="Character not ready.", Duration=2, Icon="lucide:x" }) return end
            root.CFrame = CFrame.new(landPart.Position + Vector3.new(0,5,0))
            window:Notify({ Title="Island TP", Content="Teleported to "..selIsland.." ("..assetName..")", Duration=3, Icon="lucide:check" })
        end,
    })
    IslandSec:AddParagraph({ Name="Info", Content=string.format("%d island(s) available. Dropdown excludes unloaded entries.", #islandDisplayNames) })
end

-- ==========================================
-- TAB: MISC
-- ==========================================
window:AddTabLabel("Other")
local DbgTab = window:AddTab({ Name="Misc", Icon="lucide:wrench", Type="Double" })

-- ==========================================
-- MISC STATE
-- ==========================================
local MiscS = {
    AntiAFK        = false,
    Noclip         = false,
    FullBright     = false,
    InfiniteJump   = false,
    SpeedEnabled   = false,
    JumpEnabled    = false,
    SpeedValue     = 16,
    JumpValue      = 50,
    FlingEnabled   = false,
    FlingPower     = 100,
    GravityEnabled = false,
    GravityValue   = 196.2,
    TimeEnabled    = false,
    TimeValue      = 14,
    FogEnabled     = false,
    FogValue       = 100000,
    ThirdPerson    = false,
    TPDist         = 15,
}

local _origLighting = {
    Brightness     = game:GetService("Lighting").Brightness,
    Ambient        = game:GetService("Lighting").Ambient,
    OutdoorAmbient = game:GetService("Lighting").OutdoorAmbient,
    FogEnd         = game:GetService("Lighting").FogEnd,
    ClockTime      = game:GetService("Lighting").ClockTime,
}

-- ==========================================
-- MISC: CHARACTER HELPERS
-- ==========================================
local function getChar()
    return plr.Character
end
local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- WalkSpeed / JumpPower persist across respawn
local function applySpeed(v)
    local h = getHum()
    if h then h.WalkSpeed = v end
end
local function applyJump(v)
    local h = getHum()
    if h then h.JumpPower = v end
end

plr.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid", 5)
    task.wait(0.5)
    if MiscS.SpeedEnabled then applySpeed(MiscS.SpeedValue) end
    if MiscS.JumpEnabled   then applyJump(MiscS.JumpValue)  end
end)

-- Anti-AFK
local antiAFKConn = nil
local function setAntiAFK(v)
    MiscS.AntiAFK = v
    if v then
        if antiAFKConn then antiAFKConn:Disconnect() end
        antiAFKConn = Svc.Run.Heartbeat:Connect(function()
            -- Reset idle timer via VirtualInputManager mouse nudge
            pcall(function()
                Svc.VIM:SendMouseMoveEvent(0, 0, game)
            end)
        end)
    else
        if antiAFKConn then antiAFKConn:Disconnect() antiAFKConn = nil end
    end
end

-- Noclip
local noclipConn = nil
local function setNoclip(v)
    MiscS.Noclip = v
    if v then
        noclipConn = Svc.Run.Stepped:Connect(function()
            local char = getChar()
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        local char = getChar()
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end

-- Fullbright
local function setFullBright(v)
    MiscS.FullBright = v
    local L = game:GetService("Lighting")
    if v then
        L.Brightness     = 2
        L.Ambient        = Color3.new(1,1,1)
        L.OutdoorAmbient = Color3.new(1,1,1)
    else
        L.Brightness     = _origLighting.Brightness
        L.Ambient        = _origLighting.Ambient
        L.OutdoorAmbient = _origLighting.OutdoorAmbient
    end
end

-- Infinite Jump
local ijConn = nil
local function setInfiniteJump(v)
    MiscS.InfiniteJump = v
    if v then
        ijConn = Svc.UIS.JumpRequest:Connect(function()
            local h = getHum()
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if ijConn then ijConn:Disconnect() ijConn = nil end
    end
end

-- Fling (pushes nearby players)
local function doFling()
    local hrp = getHRP()
    if not hrp then return end
    for _, p in ipairs(Svc.Players:GetPlayers()) do
        if p == plr then continue end
        local c  = p.Character
        local tr = c and c:FindFirstChild("HumanoidRootPart")
        if tr and (tr.Position - hrp.Position).Magnitude <= 20 then
            local dir = (tr.Position - hrp.Position).Unit
            local vel = Instance.new("BodyVelocity")
            vel.Velocity       = dir * MiscS.FlingPower + Vector3.new(0, MiscS.FlingPower * 0.5, 0)
            vel.MaxForce       = Vector3.new(1e5,1e5,1e5)
            vel.P              = 1e4
            vel.Parent         = tr
            game:GetService("Debris"):AddItem(vel, 0.2)
        end
    end
end

-- Gravity
local function applyGravity(v)
    workspace.Gravity = v
end

-- Time of Day
local function applyTime(v)
    game:GetService("Lighting").ClockTime = v
end

-- Fog
local function applyFog(v)
    game:GetService("Lighting").FogEnd = v
end

-- Third Person Force (unlocks zoom past default max)
local camConn = nil
local function setThirdPerson(v, dist)
    MiscS.ThirdPerson = v
    if camConn then camConn:Disconnect() camConn = nil end
    if v then
        local cam = workspace.CurrentCamera
        camConn = Svc.Run.RenderStepped:Connect(function()
            if cam.CameraType == Enum.CameraType.Custom then
                cam.CameraMinZoomDistance = dist
                cam.CameraMaxZoomDistance = dist
            end
        end)
    else
        workspace.CurrentCamera.CameraMinZoomDistance = 0.5
        workspace.CurrentCamera.CameraMaxZoomDistance = 400
    end
end

-- ==========================================
-- MISC UI — LEFT COLUMN
-- ==========================================
local MiscLeftSec = DbgTab:AddSection({ Name="Player", Position="Left" })

MiscLeftSec:AddToggle({
    Name="Anti AFK", Default=false, Flag="MiscAntiAFK",
    Callback=function(v) setAntiAFK(v) end,
})

MiscLeftSec:AddToggle({
    Name="Infinite Jump", Default=false, Flag="MiscInfJump",
    Callback=function(v) setInfiniteJump(v) end,
})

MiscLeftSec:AddToggle({
    Name="Noclip", Default=false, Flag="MiscNoclip",
    Callback=function(v) setNoclip(v) end,
})

MiscLeftSec:AddToggle({
    Name="WalkSpeed Override", Default=false, Flag="MiscSpeed",
    Callback=function(v)
        MiscS.SpeedEnabled = v
        if v then applySpeed(MiscS.SpeedValue)
        else  applySpeed(16) end
    end,
})
MiscLeftSec:AddSlider({
    Name="WalkSpeed", Min=2, Max=500, Default=16, Increment=1, Flag="MiscSpeedVal",
    Callback=function(v)
        MiscS.SpeedValue = v
        if MiscS.SpeedEnabled then applySpeed(v) end
    end,
})

MiscLeftSec:AddToggle({
    Name="JumpPower Override", Default=false, Flag="MiscJump",
    Callback=function(v)
        MiscS.JumpEnabled = v
        if v then applyJump(MiscS.JumpValue)
        else  applyJump(50) end
    end,
})
MiscLeftSec:AddSlider({
    Name="JumpPower", Min=10, Max=500, Default=50, Increment=5, Flag="MiscJumpVal",
    Callback=function(v)
        MiscS.JumpValue = v
        if MiscS.JumpEnabled then applyJump(v) end
    end,
})

MiscLeftSec:AddToggle({
    Name="Custom Gravity", Default=false, Flag="MiscGravity",
    Callback=function(v)
        MiscS.GravityEnabled = v
        if v then applyGravity(MiscS.GravityValue)
        else  applyGravity(196.2) end
    end,
})
MiscLeftSec:AddSlider({
    Name="Gravity", Min=0, Max=500, Default=196, Increment=1, Flag="MiscGravityVal",
    Callback=function(v)
        MiscS.GravityValue = v
        if MiscS.GravityEnabled then applyGravity(v) end
    end,
})

-- ==========================================
-- MISC UI — RIGHT COLUMN
-- ==========================================
local MiscRightSec = DbgTab:AddSection({ Name="World", Position="Right" })

MiscRightSec:AddToggle({
    Name="Fullbright", Default=false, Flag="MiscFullBright",
    Callback=function(v) setFullBright(v) end,
})

MiscRightSec:AddToggle({
    Name="No Fog", Default=false, Flag="MiscNoFog",
    Callback=function(v)
        MiscS.FogEnabled = v
        if v then applyFog(1e9)
        else  applyFog(_origLighting.FogEnd) end
    end,
})

MiscRightSec:AddToggle({
    Name="Time of Day Override", Default=false, Flag="MiscTime",
    Callback=function(v)
        MiscS.TimeEnabled = v
        if not v then applyTime(_origLighting.ClockTime) end
    end,
})
MiscRightSec:AddSlider({
    Name="Clock Time (0–24)", Min=0, Max=24, Default=14, Increment=0.5, Flag="MiscTimeVal",
    Callback=function(v)
        MiscS.TimeValue = v
        if MiscS.TimeEnabled then applyTime(v) end
    end,
})

-- ==========================================
-- MISC: ANTI-LAG
-- ==========================================
local AntiLagS = {
    Enabled        = false,
    ShadowsKilled  = false,
    ParticlesKilled= false,
    TexturesLow    = false,
    RenderDist     = 500,
    FPSCapEnabled  = false,
    FPSCapValue    = 60,
}

local _origRender = {
    QualityLevel      = settings().Rendering.QualityLevel,
    MeshPartLOD       = settings().Rendering.MeshPartDetailLevel,
    ShadowSoftness    = game:GetService("Lighting").ShadowSoftness,
    GlobalShadows     = game:GetService("Lighting").GlobalShadows,
}

local fpsCapConn = nil

local function killParticles(v)
    AntiLagS.ParticlesKilled = v
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Smoke")
        or obj:IsA("Fire")            or obj:IsA("Sparkles") then
            obj.Enabled = not v
        end
    end
end

local function setLowTextures(v)
    AntiLagS.TexturesLow = v
    local r = settings().Rendering
    if v then
        r.QualityLevel        = Enum.QualityLevel.Level01
        r.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Disabled
    else
        r.QualityLevel        = _origRender.QualityLevel
        r.MeshPartDetailLevel = _origRender.MeshPartLOD
    end
end

local function setShadows(v)
    AntiLagS.ShadowsKilled = v
    local L = game:GetService("Lighting")
    if v then
        L.GlobalShadows  = false
        L.ShadowSoftness = 0
    else
        L.GlobalShadows  = true
        L.ShadowSoftness = _origRender.ShadowSoftness
    end
end

local function setFPSCap(enabled, cap)
    if fpsCapConn then fpsCapConn:Disconnect() fpsCapConn = nil end
    AntiLagS.FPSCapEnabled = enabled
    if not enabled then return end
    local interval = 1 / cap
    local last     = os.clock()
    fpsCapConn = Svc.Run.RenderStepped:Connect(function()
        local now  = os.clock()
        local delta = now - last
        if delta < interval then
            -- busy-wait the remainder to throttle frame submission
            repeat task.wait() until (os.clock() - last) >= interval
        end
        last = os.clock()
    end)
end

local function applyAntiLagPreset(v)
    AntiLagS.Enabled = v
    killParticles(v)
    setLowTextures(v)
    setShadows(v)
    if v then
        pcall(function() workspace.StreamingMinRadius = AntiLagS.RenderDist end)
    else
        if _origRender.MaxDistance then
            pcall(function() workspace.StreamingMinRadius = _origRender.MaxDistance end)
        end
    end
end

-- ==========================================
-- ANTI-LAG UI SECTION
-- ==========================================
local AntiLagSec = DbgTab:AddSection({ Name="Anti Lag", Position="Left" })

AntiLagSec:AddToggle({
    Name="Anti Lag (Preset — all below)", Default=false, Flag="AntiLagPreset",
    Callback=function(v) applyAntiLagPreset(v) end,
})
AntiLagSec:AddToggle({
    Name="Kill Shadows", Default=false, Flag="AntiLagShadows",
    Callback=function(v) setShadows(v) end,
})
AntiLagSec:AddToggle({
    Name="Kill Particles / Fire / Smoke", Default=false, Flag="AntiLagParticles",
    Callback=function(v) killParticles(v) end,
})
AntiLagSec:AddToggle({
    Name="Low Textures + Mesh LOD", Default=false, Flag="AntiLagTextures",
    Callback=function(v) setLowTextures(v) end,
})
AntiLagSec:AddToggle({
    Name="Frame Rate Cap", Default=false, Flag="AntiLagFPSCap",
    Callback=function(v)
        AntiLagS.FPSCapEnabled = v
        setFPSCap(v, AntiLagS.FPSCapValue)
    end,
})
AntiLagSec:AddSlider({
    Name="FPS Cap Value", Min=15, Max=240, Default=60, Increment=5, Flag="AntiLagFPSVal",
    Callback=function(v)
        AntiLagS.FPSCapValue = v
        if AntiLagS.FPSCapEnabled then setFPSCap(true, v) end
    end,
})


-- Re-apply particle kill on new descendants
workspace.DescendantAdded:Connect(function(obj)
    if not AntiLagS.ParticlesKilled then return end
    if obj:IsA("ParticleEmitter") or obj:IsA("Smoke")
    or obj:IsA("Fire")            or obj:IsA("Sparkles") then
        obj.Enabled = false
    end
end)

-- ==========================================
-- MISC UI — REJOIN / SERVER HOP SHORTCUTS
-- ==========================================
local MiscSrvSec = DbgTab:AddSection({ Name="Session", Position="Right" })

MiscSrvSec:AddButton({
    Name="Rejoin Server", Icon="lucide:refresh-cw",
    Callback=function()
        window:Notify({ Title="Session", Content="Rejoining...", Duration=2, Icon="lucide:loader" })
        task.wait(1)
        Svc.Teleport:Teleport(game.PlaceId, plr)
    end,
})
MiscSrvSec:AddButton({
    Name="Server Hop", Icon="lucide:shuffle",
    Callback=function()
        window:Notify({ Title="Session", Content="Looking for server...", Duration=2, Icon="lucide:loader" })
        task.spawn(ServerHop)
    end,
})
MiscSrvSec:AddButton({
    Name="Copy UserID", Icon="lucide:copy",
    Callback=function()
        pcall(function() setclipboard(tostring(plr.UserId)) end)
        window:Notify({ Title="Misc", Content="UserID copied: "..plr.UserId, Duration=2, Icon="lucide:check" })
    end,
})
MiscSrvSec:AddButton({
    Name="Copy PlaceID", Icon="lucide:copy",
    Callback=function()
        pcall(function() setclipboard(tostring(game.PlaceId)) end)
        window:Notify({ Title="Misc", Content="PlaceID copied: "..game.PlaceId, Duration=2, Icon="lucide:check" })
    end,
})

print("⚡ J4rzz Evomon loaded!")
window:Notify({ Title="J4rzz Evomon v1.0a", Content="Loaded! RightControl to toggle.", Duration=4, Icon="lucide:zap" })
