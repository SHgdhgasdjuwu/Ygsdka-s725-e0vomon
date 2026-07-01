-- [[ NR Evomon v3 — ModernV2 UI Port ]] --

local ModernV2 = loadstring(game:HttpGet("https://raw.githubusercontent.com/FayintXhub/FayintLibrary/refs/heads/main/YintUI"))()

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

-- ==========================================
-- STATE
-- ==========================================
local S = {
    AutoCatch       = false,
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

-- toggle object refs (filled after UI build)
local cToggle, lToggle, tpToggle = nil, nil, nil

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
-- PET CONFIG ID MAP (model -> configId)
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

-- ==========================================
-- AUTO FARM SELECTED STATE
-- ==========================================
local S_TargetFarm     = false
local S_SelectedPet    = nil   -- display name e.g. "Pebble"
local S_TargetLoop     = false

-- Reverse map: display name -> model key
local PET_NAME_TO_MODEL = {}
for model, dname in pairs(PetNames) do
    PET_NAME_TO_MODEL[dname] = model
end

-- Build sorted display list for dropdown
local PET_DROPDOWN_LIST = {}
for model, dname in pairs(PetNames) do
    table.insert(PET_DROPDOWN_LIST, dname .. " (" .. model .. ")")
end
table.sort(PET_DROPDOWN_LIST)

-- Parse display string back to model key
local function parseDropdownEntry(entry)
    -- format: "Pebble (Pet0_18)"
    local model = entry:match("%((.-)%)")
    return model
end

local function findTargetInCache(targetModelName)
    local rc    = workspace:FindFirstChild("RuntimeCache")
    local rcs   = rc and rc:FindFirstChild("RuntimeCacheServer")
    local cache = rcs and rcs:FindFirstChild("CreatureModelCache")
    if not cache then return nil, nil end

    for _, container in ipairs(cache:GetChildren()) do
        local petModel = container:FindFirstChildWhichIsA("Model")
        if not petModel then continue end

        if petModel.Name == targetModelName then
            local uid = container:GetAttribute("creatureUid")
                or container:GetAttribute("CreatureUid")
                or petModel:GetAttribute("creatureUid")
                or container.Name

            -- ambil posisi model untuk tp kalau perlu nanti
            local root = petModel:FindFirstChild("HumanoidRootPart") or petModel.PrimaryPart
            local pos  = root and root.Position or nil

            return tostring(uid), pos
        end
    end
    return nil, nil
end

-- ==========================================
-- FIRE TARGET BATTLE
-- ==========================================
local function enterTargetBattle(creatureUid)
    local ok, err = pcall(function()
        game:GetService("ReplicatedStorage")
            :WaitForChild("Remote")
            :WaitForChild("Battle")
            :WaitForChild("ReqEnterPetBattle")
            :FireServer(creatureUid)
    end)
    if not ok then
        warn("[TargetFarm] FireServer gagal:", err)
    end
    return ok
end

local function findAndEnterTarget(targetModelName)
    local char = plr.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local uid, petPos = findTargetInCache(targetModelName)

    if uid and petPos then
        local dist = (hrp.Position - petPos).Magnitude
        if dist <= S.ScanRadius then
            warn(string.format("[TargetFarm] %s in range (%.0f studs) — entering direct", targetModelName, dist))
            return enterTargetBattle(uid)
        else
            warn(string.format("[TargetFarm] %s found but far (%.0f studs) — tp-ing", targetModelName, dist))
            hrp.CFrame = CFrame.new(petPos) * CFrame.new(0, 0, 3)
            task.wait(0.6)
            uid, petPos = findTargetInCache(targetModelName)
            if uid then return enterTargetBattle(uid) end
        end
        return false
    end

    -- Not in cache at all — this is a real "not spawned nearby" case, not a bug to roam past.
    -- Sweep a progressively wider radius around the player's current position by re-scanning
    -- the cache after small movements, instead of jumping to an unrelated creature's location.
    warn("[TargetFarm] " .. targetModelName .. " not in cache — sweeping local area")

    local char2 = plr.Character
    local hrp2  = char2 and char2:FindFirstChild("HumanoidRootPart")
    if not hrp2 then return false end

    local origin = hrp2.Position
    local sweepOffsets = {
        Vector3.new(60, 0, 0),  Vector3.new(-60, 0, 0),
        Vector3.new(0, 0, 60),  Vector3.new(0, 0, -60),
        Vector3.new(120, 0, 0), Vector3.new(-120, 0, 0),
    }

    for _, offset in ipairs(sweepOffsets) do
        hrp2.CFrame = CFrame.new(origin + offset)
        task.wait(0.6) -- let server replicate CreatureModelCache for this area

        uid, petPos = findTargetInCache(targetModelName)
        if uid and petPos then
            warn(string.format("[TargetFarm] %s appeared after sweep — entering", targetModelName))
            hrp2.CFrame = CFrame.new(petPos) * CFrame.new(0, 0, 3)
            task.wait(0.3)
            uid, _ = findTargetInCache(targetModelName)
            if uid then return enterTargetBattle(uid) end
        end
    end

    warn("[TargetFarm] " .. targetModelName .. " not found in any swept zone — likely not spawned this cycle")
    return false
end
-- ==========================================
-- TARGET FARM LOOP (replace yang lama)
-- ==========================================
task.spawn(function()
    while true do
        task.wait(1)
        if not S.Running then break end
        if not S_TargetFarm or not S_SelectedPet then continue end

        local modelKey = PET_NAME_TO_MODEL[S_SelectedPet]
        if not modelKey then
            warn("[TargetFarm] model key tidak ditemukan untuk:", S_SelectedPet)
            continue
        end

        local ok = findAndEnterTarget(modelKey)

        if ok then
            local waited = 0
            repeat task.wait(0.5) waited += 0.5 until waited >= 12
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- INTERCEPT PET UID
-- ==========================================
if not _G.NR_hooked then
    _G.NR_hooked = true
    local ok, err = pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local ok2, name = pcall(function() return self.Name end)
            if ok2 and name == "ReqSetMainPet" and method == "InvokeServer" then
                local args = {...}
                if args[1] and type(args[1]) == "string" then
                    _G.NR_petUID = args[1]
                end
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

-- ==========================================
-- CORE HELPERS
-- ==========================================
local function pressKey(k, dur)
    pcall(function()
        Svc.VIM:SendKeyEvent(true,  k, false, game) task.wait(dur or 0.05)
        Svc.VIM:SendKeyEvent(false, k, false, game)
    end)
end

local function getPityInfo()
    local sp = PGui:FindFirstChild("SparklePityText", true)
    if sp then
        local c, m = sp.Text:match("(%d+)/(%d+)")
        if c and m then return tonumber(c), tonumber(m) end
    end
    return nil, nil
end

local function getShinyPityInfo()
    local sp = PGui:FindFirstChild("ShinyPityText", true)
    if sp then
        local c, m = sp.Text:match("(%d+)/(%d+)")
        if c and m then return tonumber(c), tonumber(m) end
    end
    return nil, nil
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
-- PITY OVERLAY (standalone ScreenGui)
-- ==========================================
local pityOverlayGui = Instance.new("ScreenGui")
pityOverlayGui.Name          = "NRPityOverlay"
pityOverlayGui.ResetOnSpawn  = false
pityOverlayGui.IgnoreGuiInset= true
pityOverlayGui.DisplayOrder  = 50
pityOverlayGui.Enabled       = false
pityOverlayGui.Parent        = PGui

local pityOverlayLbl = Instance.new("TextLabel")
pityOverlayLbl.AnchorPoint         = Vector2.new(0.5, 0)
pityOverlayLbl.Position            = UDim2.new(0.5, 0, 0, 68)
pityOverlayLbl.Size                = UDim2.new(0.25, 0, 0, 80)
pityOverlayLbl.BackgroundTransparency = 1
pityOverlayLbl.Text                = "💎 —/—\n✨ —/—"
pityOverlayLbl.TextScaled          = true
pityOverlayLbl.Font                = Enum.Font.GothamBold
pityOverlayLbl.TextColor3          = Color3.new(1,1,1)
pityOverlayLbl.TextStrokeTransparency = 0
pityOverlayLbl.TextStrokeColor3    = Color3.new(0,0,0)
pityOverlayLbl.TextXAlignment      = Enum.TextXAlignment.Center
pityOverlayLbl.TextYAlignment      = Enum.TextYAlignment.Top
pityOverlayLbl.Parent              = pityOverlayGui

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
-- SHINY / PRISMATIC HANDLERS
-- ==========================================
local function setAutoLeaveSync(v)
    S.AutoLeave = v
    if lToggle then pcall(function() lToggle:SetValue(v) end) end
end

local function setAutoCatchSync(v)
    S.AutoCatch = v
    if cToggle then pcall(function() cToggle:SetValue(v) end) end
end

local function setTpFarmSync(v)
    S.TpFarm = v
    if tpToggle then pcall(function() tpToggle:SetValue(v) end) end
end

local function onShinyDetected()
    warn("✨ SHINY DETECTED!")
    isSpamming = false
    S.PrisReady = false
    setAutoCatchSync(false)
    setAutoLeaveSync(false)
    if S.TpFarm then setTpFarmSync(false) end
    playSound(false)

    local ballKey = S.AutoKingBall and Enum.KeyCode.Three
        or S.AutoAdvBall  and Enum.KeyCode.Two
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
    if (S.CatchShinyOnly or S.CatchShinyPris) and isShiny() then
        onShinyDetected() return
    end
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
                    local pm   = child:FindFirstChildWhichIsA("Model")
                    local br   = pm  and (pm:FindFirstChild("HumanoidRootPart") or pm.PrimaryPart)
                    local char = plr.Character
                    local mr   = char and char:FindFirstChild("HumanoidRootPart")
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
-- MAIN LOOPS
-- ==========================================
task.spawn(function()
    while task.wait(S.LoopDelay) do
        if not S.Running then break end
        if not (S.AutoCatch or S.AutoLeave or S.TpFarm) then continue end
        if catchVisible() then handleCatch() continue end
        if S.AutoCatch then
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

-- Watchdog
task.spawn(function()
    while task.wait(1.5) do
        if not S.Running then break end
        if (S.AutoCatch or S.AutoLeave or S.TpFarm) and catchVisible() then
            handleCatch()
        end
    end
end)

-- Chest loop
task.spawn(function()
    while task.wait() do
        if not S.Running then break end
        if S.ChestFarm then
            local rc = workspace:FindFirstChild("RuntimeCache")
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
                    local bp = list[S.ChestIdx]:FindFirstChildWhichIsA("BasePart", true)
                    local char = plr.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if bp and root then root.CFrame = bp.CFrame * CFrame.new(0,3,0) end
                end
            end
            local el = 0
            while el < S.ChestDelay and S.ChestFarm do
                pressKey(Enum.KeyCode.E, 0.05) task.wait(0.2) el += 0.2
            end
        else task.wait(0.5) end
    end
end)

-- Boss loop
task.spawn(function()
    while true do
        task.wait(0.5)
        if not S.Running then break end
        if not S_BossLoop or not selBoss then continue end
        doEnterBattle(selBoss)
        if S_BossLoop then task.wait(1) end
    end
end)

-- Pity watcher
task.spawn(function()
    while task.wait(1) do
        if not S.Running then break end
        -- Overlay update
        if S.ShowPityOverlay then
            local petLabel = S.LastPetName and ("[" .. S.LastPetName .. "]") or ""
            local cur, max = getPityInfo()
            local prisText = (cur and max) and string.format("💎 %d/%d", cur, max) or "💎 —/—"
            local shinyText = "✨ —/—"
            local sp = PGui:FindFirstChild("ShinyPityText", true)
            if sp then
                local sc, sm = sp.Text:match("(%d+)/(%d+)")
                if sc and sm then shinyText = string.format("✨ %s/%s", sc, sm) end
            end
            pityOverlayLbl.Text = petLabel ~= "" and (petLabel.."\n"..prisText.."\n"..shinyText) or (prisText.."\n"..shinyText)
        end
        -- Auto prismatic logic
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

local MenuIcon = ModernV2:CreateMenuIcon({
    Image        = "grid",
    Size         = 48,
    IconColor    = Color3.fromRGB(255, 255, 255),
    BGColor      = Color3.fromRGB(18, 18, 26),
    StrokeColor  = Color3.fromRGB(108, 68, 200),
    StrokeThick  = 1.5,
    Draggable    = true,
})

local window = ModernV2:Window({
	Title = "J4rz Hub",
	Content = "Free",
	Image = "85817114798115",
	Color = Color3.fromRGB(78, 127, 252),
	Uitransparent = 0.12,
	ShowUser = true,
	Search = true,
	ConfigEnabled = true,
	NotifyOnCallbackError = false,
	Loadingscreen = false,
	Enable3DRenderer = false,
	Keybind = "RightControl",
	Config = {
		ConfigFolder = "ModernV2Example",
		AutoSaveFile = "Default",
		AutoSave = true,
		AutoLoad = true,
		Overwrite = true,
		Format = "JSON",
		ShowAutoSaveToggle = true,
		TextGradient = true,
	},
})

window:AttachMenuIcon(MenuIcon)

-- ==========================================
-- RESPONSIVE WINDOW SCALING (built-in Scales only)
-- ==========================================
local Camera = workspace.CurrentCamera
local lastScaleName = nil

local function pickScale(vpX, vpY)
    if vpX <= 600 then
        return "Mobile"
    elseif vpX <= 700 then
        return "Compact"
    elseif vpX <= 900 then
        return "Small"
    elseif vpX <= 1100 then
        return "Default"
    end
    return "Large"
end

local function applyResponsive()
    if not Camera or not Camera.Parent then
        Camera = workspace.CurrentCamera
    end
    if not Camera then return end

    local vp = Camera.ViewportSize
    if vp.X <= 0 or vp.Y <= 0 then return end

    local chosen = pickScale(vp.X, vp.Y)

    if chosen ~= lastScaleName then
        lastScaleName = chosen
        window:SetSize(ModernV2.Scales[chosen])
    end
end

applyResponsive()

if Camera then
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsive)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
    if Camera then
        Camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsive)
    end
    applyResponsive()
end)

window:SetAccount({
    Username = plr.DisplayName,
    Profile  = ModernV2.UserProfile,
    Expires  = "Never",
})

window:AddTabLabel("FARMING")

-- ==========================================
-- BATTLE STATE DETECTION (selalu re-check, bukan sekali jalan)
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
-- AUTO SKILL SPAM LOOP — MainBattleWindow path, full signal fire
-- ==========================================
local AUTO_SKILL_ENABLED = false
local SKILL_CLICK_DELAY  = 1
local SKILL_DEBUG        = true

local function getSkillButtons()
    local ok, scrollView = pcall(function()
        return PGui
            :WaitForChild("UIPrefabs", 2)
            :WaitForChild("MainBattleWindow", 2)
            :WaitForChild("MainCanvasGroup", 2)
            :WaitForChild("PetSkillFrame", 2)
            :WaitForChild("PetNormalSkillScrollView", 2)
    end)

    if not ok or not scrollView then
        if SKILL_DEBUG then warn("[NR SKILL] scrollView gagal ditemukan:", scrollView) end
        return {}
    end

    local buttons = {}
    for _, item in ipairs(scrollView:GetChildren()) do
        if item.Name == "PetSkillItem" then
            local itemFrame = item:FindFirstChild("ItemFrame")
            local btn = itemFrame and itemFrame:FindFirstChild("SkillButton")
            if btn and btn.Visible then
                table.insert(buttons, btn)
            end
        end
    end
    return buttons
end

local function fireFullClick(btn)
    if not btn then return false end

    local sigNames = {"MouseButton1Down", "MouseButton1Click", "MouseButton1Up", "Activated"}
    local anyOk = false

    for _, sigName in ipairs(sigNames) do
        local sig = btn[sigName]
        if sig then
            local ok = pcall(function() firesignal(sig) end)
            if ok then anyOk = true end
        end
    end

    if not anyOk then
        -- fallback ke VIM kalau firesignal gak tersedia di executor
        local okVim = pcall(function()
            local absPos  = btn.AbsolutePosition
            local absSize = btn.AbsoluteSize
            local x = absPos.X + absSize.X / 2
            local y = absPos.Y + absSize.Y / 2
            Svc.VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
            task.wait(1)
            Svc.VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
        end)
        anyOk = okVim
    end

    return anyOk
end

local skillRotateIdx = 0

local function fireSkillTick()
    local buttons = getSkillButtons()
    if #buttons == 0 then
        if SKILL_DEBUG then print("[NR SKILL] tidak ada SkillButton visible ditemukan") end
        return false
    end

    local randIdx = math.random(1, #buttons)
    local btn = buttons[randIdx]

    local ok = fireFullClick(btn)

    if SKILL_DEBUG then
        print(string.format("[NR SKILL] slot=%d/%d (random) fired=%s path=%s",
            randIdx, #buttons, tostring(ok), btn:GetFullName()))
    end

    return ok
end

task.spawn(function()
    while S.Running do
        task.wait(0.5)

        if not AUTO_SKILL_ENABLED then
            continue
        end

        if isBattle() then
            fireSkillTick()
            task.wait(SKILL_CLICK_DELAY)
        end
    end
end)

-- ==========================================
-- TAB: GENERAL
-- ==========================================
local GenTab = window:AddTab({ Name="General", Icon="lucide:settings-2", Type="Double" })

local AutoSec = GenTab:AddSection({ Name="Automation", Position="Left" })

cToggle = AutoSec:AddToggle({
    Name     = "Auto Farm & Catch",
    Default  = false,
    Flag     = "AutoCatch",
    Callback = function(v)
        S.AutoCatch = v
        if not v and S.TpFarm then setTpFarmSync(false) end
    end,
})

AutoSec:AddToggle({
    Name     = "⚔️ Auto Skill (Battle)",
    Default  = false,
    Flag     = "AutoSkill",
    Callback = function(v) AUTO_SKILL_ENABLED = v end,
})

lToggle = AutoSec:AddToggle({
    Name     = "Auto Leave",
    Default  = false,
    Flag     = "AutoLeave",
    Callback = function(v)
        S.AutoLeave = v
    end,
})

tpToggle = AutoSec:AddToggle({
    Name     = "Teleport Farm Mode",
    Default  = false,
    Flag     = "TpFarm",
    Callback = function(v)
        S.TpFarm = v
    end,
})

AutoSec:AddToggle({
    Name     = "Manual Catch (No Ball)",
    Default  = false,
    Flag     = "NoBall",
    Callback = function(v) S.NoBall = v end,
})

local StatusSec = GenTab:AddSection({ Name="Status", Position="Right" })
local farmStatLbl = StatusSec:AddLabel({ Text="Farm: Idle", Wrapped=true })
local petStatLbl  = StatusSec:AddLabel({ Text="Last Pet: —", Wrapped=true })

task.spawn(function()
    while task.wait(1) do
        if not S.Running then break end
        local state = "Idle"
        if S.CatchShinyOnly then state = "✨ Shiny Hunt"
        elseif S.CatchShinyPris then state = "💎 Shiny+Pris Hunt"
        elseif S.AutoCatch and S.TpFarm then state = "🚀 TP Farming"
        elseif S.AutoCatch then state = "🏃 Walking Farm"
        elseif S.AutoLeave then state = "↩ Auto Leave" end
        pcall(function() farmStatLbl:SetText("Farm: " .. state) end)
        if S.LastPetName then
            pcall(function() petStatLbl:SetText("Last Pet: " .. S.LastPetName) end)
        end
    end
end)

-- ==========================================
-- SECTION: AUTO FARM SELECTED
-- ==========================================
local TargetSec = GenTab:AddSection({ Name="Auto Farm (Selected)", Position="Left" })

local targetPetDropdown = TargetSec:AddDropdown({
    Name    = "Select Target Pet",
    Default = PET_DROPDOWN_LIST[1],
    Values  = PET_DROPDOWN_LIST,
    Multi   = false,
    Search  = true,
    Callback = function(v)
        local model = parseDropdownEntry(v)
        S_SelectedPet = model and PetNames[model] or nil
    end,
})

-- Set default selection
do
    local defaultModel = parseDropdownEntry(PET_DROPDOWN_LIST[1])
    S_SelectedPet = defaultModel and PetNames[defaultModel] or nil
end

TargetSec:AddToggle({
    Name     = "🎯 Auto Farm (Selected)",
    Default  = false,
    Flag     = "TargetFarm",
    Callback = function(v)
        S_TargetFarm = v
    end,
})
TargetSec:AddButton({
    Name = "🔍 Find & Enter Once",
    Icon = "lucide:crosshair",
    Callback = function()
        if not S_SelectedPet then
            window:Notify({ Title="Target Farm", Content="Pilih pet dulu!", Duration=2, Icon="lucide:alert-circle" })
            return
        end
        local modelKey = PET_NAME_TO_MODEL[S_SelectedPet]
        if not modelKey then
            window:Notify({ Title="Target Farm", Content="Model key tidak ditemukan.", Duration=2, Icon="lucide:x" })
            return
        end
        task.spawn(function()
            local uid, pos = findTargetInCache(modelKey)
            if not uid then
                window:Notify({ Title="Target Farm", Content=S_SelectedPet.." tidak ada di cache.", Duration=3, Icon="lucide:x" })
                return
            end
            window:Notify({ Title="Target Farm", Content="Entering "..S_SelectedPet.." (uid="..uid..")", Duration=2, Icon="lucide:crosshair" })
            enterTargetBattle(uid)
        end)
    end,
})

TargetSec:AddLabel({ Text="UID diambil langsung dari CreatureModelCache via PetConfigId attribute.", Wrapped=true })

-- ==========================================
-- TAB: SHINY
-- ==========================================
local ShinyTab = window:AddTab({ Name="Shiny", Icon="lucide:sparkles", Type="Double" })

local ShinySec = ShinyTab:AddSection({ Name="Detection Modes", Position="Left" })

ShinySec:AddToggle({
    Name     = "Show Pity Overlay",
    Default  = false,
    Flag     = "PityOverlay",
    Callback = function(v)
        S.ShowPityOverlay = v
        pityOverlayGui.Enabled = v
    end,
})

local soToggle = ShinySec:AddToggle({
    Name     = "✨ Catch Shiny Only",
    Default  = false,
    Flag     = "CatchShinyOnly",
    Callback = function(v)
        S.CatchShinyOnly = v
        if v then
            S.CatchShinyPris = false
            setAutoCatchSync(true)
            setAutoLeaveSync(true)
        else
            setAutoCatchSync(false)
            setAutoLeaveSync(false)
        end
    end,
})

local spToggle2 = ShinySec:AddToggle({
    Name     = "💎 Catch Shiny & Prismatic",
    Default  = false,
    Flag     = "CatchShinyPris",
    Callback = function(v)
        S.CatchShinyPris = v
        if v then
            S.CatchShinyOnly = false
            pcall(function() soToggle:SetValue(false) end)
            setAutoCatchSync(true)
            local cur, max = getPityInfo()
            if cur and max and cur >= (max-1) then
                setAutoLeaveSync(true)
            else
                setAutoLeaveSync(false)
            end
        else
            S.PrisReady = false
            setAutoCatchSync(false)
            setAutoLeaveSync(false)
        end
    end,
})

local BallSec = ShinyTab:AddSection({ Name="Ball on Shiny Detect", Position="Right" })

BallSec:AddToggle({
    Name="👑 King Ball", Default=false, Flag="KingBall",
    Callback=function(v) S.AutoKingBall=v if v then S.AutoAdvBall=false S.AutoPrismBall=false end end,
})
BallSec:AddToggle({
    Name="⚡ Advanced Ball", Default=false, Flag="AdvBall",
    Callback=function(v) S.AutoAdvBall=v if v then S.AutoKingBall=false S.AutoPrismBall=false end end,
})
BallSec:AddToggle({
    Name="🔮 Prismatic Ball", Default=false, Flag="PrismBall",
    Callback=function(v) S.AutoPrismBall=v if v then S.AutoKingBall=false S.AutoAdvBall=false end end,
})

local PitySec = ShinyTab:AddSection({ Name="Pity Counter", Position="Right" })
local pityDisplayLbl = PitySec:AddLabel({ Text="💎 Prismatic: —/—\n✨ Shiny: —/—", Wrapped=true })

task.spawn(function()
    while task.wait(1) do
        if not S.Running then break end
        local cur, max = getPityInfo()
        local prisText  = (cur and max)
            and string.format("💎 Prismatic: %d/%d%s", cur, max, cur>=(max-1) and " ⚠️" or "")
            or  "💎 Prismatic: —/—"
        local sc, sm   = getShinyPityInfo()
        local shinyText = sc and sm
            and string.format("✨ Shiny: %d/%d%s", sc, sm, sc>=sm and " ⚠️" or "")
            or  "✨ Shiny: —/—"
        pcall(function() pityDisplayLbl:SetText(prisText .. "\n" .. shinyText) end)
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
        S.PlayerESP = v
        for _, obj in pairs(S.ESPCache) do
            if obj.hl then obj.hl.Enabled = v end
            if obj.bb then obj.bb.Enabled = v end
        end
    end,
})
ESPSec:AddParagraph({ Name="Info", Content="Blue highlight + name + distance (meters) realtime." })

-- ==========================================
-- TAB: BOSS FARM
-- ==========================================
local BossTab = window:AddTab({ Name="Boss", Icon="lucide:swords", Type="Single" })
local BossSec = BossTab:AddSection({ Name="Boss Farm", Position="Center" })

BossSec:AddDropdown({
    Name="Select Boss", Default=bossNames[1], Values=bossNames, Multi=false, Search=false,
    Callback=function(v) selBoss = bossMap[v] end,
})

BossSec:AddButton({
    Name="Enter Battle (1x)", Icon="lucide:sword",
    Callback=function()
        if not selBoss then
            window:Notify({ Title="Boss", Content="Select a boss first!", Duration=2, Icon="lucide:alert-circle" }) return
        end
        if S_BossLoop then
            window:Notify({ Title="Boss", Content="Turn off Loop for manual 1x.", Duration=2, Icon="lucide:alert-circle" }) return
        end
        if not _G.NR_petUID then
            window:Notify({ Title="Boss", Content="No Pet UID — select a pet in-game!", Duration=3, Icon="lucide:alert-circle" }) return
        end
        task.spawn(function()
            window:Notify({ Title="Boss", Content="Entering "..selBoss.name.."...", Duration=2, Icon="lucide:sword" })
            local ok = doEnterBattle(selBoss)
            window:Notify({
                Title   = "Boss",
                Content = ok and (selBoss.name.." done!") or "Battle failed.",
                Duration= 2,
                Icon    = ok and "lucide:check" or "lucide:x",
            })
        end)
    end,
})

BossSec:AddToggle({
    Name="🔁 Loop Boss Battle", Default=false, Flag="BossLoop",
    Callback=function(v)
        S_BossLoop = v
        if v and not selBoss then selBoss = bossMap[bossNames[1]] end
    end,
})

BossSec:AddParagraph({
    Name="Info",
    Content="Select boss → Enter Battle.\nLoop ON = auto repeat.\nPet UID required (select a pet in the game menu first).",
})

-- ==========================================
-- TAB: CHEST
-- ==========================================
local ChestTab = window:AddTab({ Name="Chest", Icon="lucide:package", Type="Single" })
local ChestSec = ChestTab:AddSection({ Name="Chest Farm", Position="Center" })

ChestSec:AddToggle({
    Name="Auto Farm Chest", Default=false, Flag="ChestFarm",
    Callback=function(v) S.ChestFarm = v end,
})
ChestSec:AddButton({
    Name="Next Chest (Manual)", Icon="lucide:package-open",
    Callback=function()
        local rc  = workspace:FindFirstChild("RuntimeCache")
        local rcc = rc  and rc:FindFirstChild("RuntimeCacheClient")
        local dir = rcc and rcc:FindFirstChild("Chest")
        if not dir then
            window:Notify({ Title="Chest", Content="No chest folder found.", Duration=2, Icon="lucide:x" }) return
        end
        local list = {}
        for _, c in ipairs(dir:GetChildren()) do
            if c:IsA("Folder") or c:IsA("Model") then table.insert(list, c) end
        end
        if #list == 0 then return end
        S.ChestIdx = S.ChestIdx + 1
        if S.ChestIdx > #list then S.ChestIdx = 1 end
        local bp   = list[S.ChestIdx]:FindFirstChildWhichIsA("BasePart", true)
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if bp and root then root.CFrame = bp.CFrame * CFrame.new(0,3,0) end
    end,
})

-- ==========================================
-- TAB: SERVER HOP
-- ==========================================
local SrvTab = window:AddTab({ Name="Server", Icon="lucide:globe", Type="Single" })
local SrvSec = SrvTab:AddSection({ Name="Server Hop", Position="Center" })

SrvSec:AddParagraph({ Name="Info", Content="Randomly switches to another non-full public server." })
SrvSec:AddButton({
    Name="Server Hop", Icon="lucide:shuffle",
    Callback=function()
        window:Notify({ Title="Server Hop", Content="Looking for server...", Duration=2, Icon="lucide:loader" })
        task.spawn(ServerHop)
    end,
})

-- ==========================================
-- TAB: TELEPORT
-- ==========================================
local TeleTab = window:AddTab({ Name="Teleport", Icon="lucide:map-pin", Type="Single" })
local TeleSec = TeleTab:AddSection({ Name="Teleport to Player", Position="Center" })

TeleSec:AddDropdown({
    Name            = "Select Player",
    Default         = nil,
    Values          = {},
    Multi           = false,
    Search          = true,
    RefreshInterval = 3,
    OptionsProvider = function()
        local names = {}
        for _, p in ipairs(Svc.Players:GetPlayers()) do
            if p ~= plr then table.insert(names, p.Name) end
        end
        if #names == 0 then table.insert(names, "(No players)") end
        return names
    end,
    Callback = function(v) selPlayer = v end,
})

TeleSec:AddButton({
    Name="Teleport", Icon="lucide:navigation",
    Callback=function()
        if not selPlayer or selPlayer == "(No players)" then
            window:Notify({ Title="Teleport", Content="No player selected!", Duration=2, Icon="lucide:alert-circle" }) return
        end
        local tgt  = Svc.Players:FindFirstChild(selPlayer)
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if tgt and root then
            local tc = tgt.Character
            local tr = tc and tc:FindFirstChild("HumanoidRootPart")
            if tr then
                root.CFrame = tr.CFrame * CFrame.new(0,0,3)
                window:Notify({ Title="Teleport", Content="Teleported to "..selPlayer, Duration=2, Icon="lucide:check" })
            end
        end
    end,
})

-- ==========================================
-- TAB: DEBUG
-- ==========================================
window:AddTabLabel("MISC")
local DbgTab = window:AddTab({ Name="Debug", Icon="lucide:bug", Type="Single" })
local DbgSec = DbgTab:AddSection({ Name="Debug Tools", Position="Center" })

local scanLbl = DbgSec:AddLabel({
    Text    = string.format("Scan radius: %.0fm  |  Loop delay: %ds", S.ScanRadius*0.28, S.LoopDelay),
    Wrapped = true,
})

DbgSec:AddButton({
    Name="Scan Pets (F9 Console)", Icon="lucide:search",
    Callback=function()
        local char = plr.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then print("❌ No HumanoidRootPart") return end
        local found = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= char and not Svc.Players:GetPlayerFromCharacter(obj) then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                local hum  = obj:FindFirstChildOfClass("Humanoid")
                if root and hum and hum.Health > 0 then
                    table.insert(found, {name=obj.Name, dist=(root.Position-hrp.Position).Magnitude})
                end
            end
        end
        table.sort(found, function(a,b) return a.dist < b.dist end)
        print("═══ DEBUG: "..#found.." entities ═══")
        for i, v in ipairs(found) do
            print(string.format("[#%d] %s | %.0f m %s", i, v.name, v.dist, v.dist<=S.ScanRadius and "✅" or "❌"))
        end
        pcall(function() scanLbl:SetText("Found "..#found.." — check F9!") end)
        window:Notify({ Title="Debug", Content="Found "..#found.." entities. Check F9.", Duration=3, Icon="lucide:search" })
    end,
})

DbgSec:AddButton({
    Name="Check Pet UID", Icon="lucide:key",
    Callback=function()
        local uid = tostring(_G.NR_petUID or "Not detected")
        print("[NR] Pet UID:", uid)
        window:Notify({ Title="Pet UID", Content=uid, Duration=3, Icon="lucide:key" })
    end,
})

-- ==========================================
-- DONE
-- ==========================================
print("⚡ J4rzz Evomon loaded!")
window:Notify({
    Title    = "J4rzz Evomon v1.0a",
    Content  = "Loaded! RightControl to toggle.",
    Duration = 4,
    Icon     = "lucide:zap",
})
