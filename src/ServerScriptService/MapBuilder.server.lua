local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- 구역 중심 좌표
local VILLAGE = Vector3.new(0,   0,   0)
local HUNT    = Vector3.new(600, 0,   0)
local FARM    = Vector3.new(-600,0,   0)

-- 기본 Baseplate 제거 (게임 바닥과 z-fighting 방지)
local baseplate = workspace:FindFirstChild("Baseplate")
if baseplate then baseplate:Destroy() end

local map = Instance.new("Folder")
map.Name   = "Map"
map.Parent = workspace

-- ── 헬퍼 ────────────────────────────────────────────────────────────────────
local function part(parent, size, cf, color, mat, transparency, canCollide)
    local p = Instance.new("Part")
    p.Size        = size
    p.CFrame      = cf
    p.BrickColor  = BrickColor.new(color or "Medium green")
    p.Material    = mat or Enum.Material.SmoothPlastic
    p.Transparency= transparency or 0
    p.Anchored    = true
    p.CanCollide  = canCollide ~= false
    p.Parent      = parent
    return p
end

local function wedge(parent, size, cf, color, mat)
    local p = Instance.new("WedgePart")
    p.Size       = size
    p.CFrame     = cf
    p.BrickColor = BrickColor.new(color or "Bright red")
    p.Material   = mat or Enum.Material.SmoothPlastic
    p.Anchored   = true
    p.Parent     = parent
    return p
end

local function label3D(part3D, text, size, yOff)
    local bg = Instance.new("BillboardGui")
    bg.Size        = UDim2.new(0, size or 200, 0, 50)
    bg.StudsOffset = Vector3.new(0, yOff or 4, 0)
    bg.AlwaysOnTop = false
    bg.Parent      = part3D
    local lbl = Instance.new("TextLabel")
    lbl.Size                  = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency= 1
    lbl.TextColor3            = Color3.new(1,1,1)
    lbl.TextStrokeTransparency= 0
    lbl.Font                  = Enum.Font.GothamBold
    lbl.TextScaled            = true
    lbl.Text                  = text
    lbl.Parent                = bg
end

-- 나무
local function makeTree(parent, pos)
    local trunk = part(parent, Vector3.new(1.5,6,1.5), CFrame.new(pos + Vector3.new(0,3,0)), "Reddish brown", Enum.Material.Wood)
    part(parent, Vector3.new(6,5,6),   CFrame.new(pos + Vector3.new(0,8.5,0)),  "Dark green", Enum.Material.Grass, 0)
    part(parent, Vector3.new(4,4,4),   CFrame.new(pos + Vector3.new(0,12,0)),   "Dark green", Enum.Material.Grass, 0)
    part(parent, Vector3.new(2.5,3,2.5),CFrame.new(pos + Vector3.new(0,15,0)), "Bright green", Enum.Material.Grass, 0)
end

-- 죽은 나무 (사냥터용)
local function makeDeadTree(parent, pos)
    part(parent, Vector3.new(1.5,7,1.5), CFrame.new(pos+Vector3.new(0,3.5,0)), "Dark orange", Enum.Material.Wood)
    part(parent, Vector3.new(4,1.5,1.5), CFrame.new(pos+Vector3.new(2,7,0)),   "Dark orange", Enum.Material.Wood)
    part(parent, Vector3.new(2.5,1,1),   CFrame.new(pos+Vector3.new(-1.5,6,0)),"Dark orange", Enum.Material.Wood)
end

-- 건물 (벽 분리형 - 문 공간 열림)
local function makeBuilding(parent, center, w, h, d, wallColor, roofColor, signText)
    local folder = Instance.new("Folder")
    folder.Name   = signText or "Building"
    folder.Parent = parent

    local wt  = 0.7   -- 벽 두께
    local dw  = 4.0   -- 문 너비
    local dh  = 4.5   -- 문 높이
    local lrW = (w - dw) / 2     -- 앞벽 좌우 섹션 너비
    local lrX = (w + dw) / 4     -- 좌우 섹션 중심 X 거리

    -- 내부 바닥
    part(folder, Vector3.new(w - wt*2, 0.3, d - wt*2),
         CFrame.new(center + Vector3.new(0, 0.15, 0)),
         "Light stone grey", Enum.Material.SmoothPlastic)

    -- 뒷벽
    part(folder, Vector3.new(w, h, wt),
         CFrame.new(center + Vector3.new(0, h/2, -d/2)),
         wallColor, Enum.Material.SmoothPlastic)

    -- 왼쪽 벽
    part(folder, Vector3.new(wt, h, d),
         CFrame.new(center + Vector3.new(-w/2, h/2, 0)),
         wallColor, Enum.Material.SmoothPlastic)

    -- 오른쪽 벽
    part(folder, Vector3.new(wt, h, d),
         CFrame.new(center + Vector3.new(w/2, h/2, 0)),
         wallColor, Enum.Material.SmoothPlastic)

    -- 앞벽 - 문 왼쪽
    part(folder, Vector3.new(lrW, h, wt),
         CFrame.new(center + Vector3.new(-lrX, h/2, d/2)),
         wallColor, Enum.Material.SmoothPlastic)

    -- 앞벽 - 문 오른쪽
    part(folder, Vector3.new(lrW, h, wt),
         CFrame.new(center + Vector3.new(lrX, h/2, d/2)),
         wallColor, Enum.Material.SmoothPlastic)

    -- 앞벽 - 문 위
    if h > dh then
        part(folder, Vector3.new(dw, h - dh, wt),
             CFrame.new(center + Vector3.new(0, (h + dh) / 2, d/2)),
             wallColor, Enum.Material.SmoothPlastic)
    end

    -- 창문 (앞면 좌우)
    part(folder, Vector3.new(2, 2, 0.2),
         CFrame.new(center + Vector3.new(-lrX, h * 0.65, d/2 + 0.15)),
         "Cyan", Enum.Material.Glass, 0.35)
    part(folder, Vector3.new(2, 2, 0.2),
         CFrame.new(center + Vector3.new(lrX, h * 0.65, d/2 + 0.15)),
         "Cyan", Enum.Material.Glass, 0.35)

    -- 지붕
    local rh = w * 0.35
    wedge(folder, Vector3.new(d, rh, w/2),
          CFrame.new(center + Vector3.new(0, h + rh/2 - 0.2,  w/4)) * CFrame.Angles(0,  math.pi/2, 0), roofColor)
    wedge(folder, Vector3.new(d, rh, w/2),
          CFrame.new(center + Vector3.new(0, h + rh/2 - 0.2, -w/4)) * CFrame.Angles(0, -math.pi/2, 0), roofColor)

    -- 건물 이름 (지붕 위)
    if signText then
        local anchor = part(folder, Vector3.new(0.1,0.1,0.1),
                            CFrame.new(center + Vector3.new(0, h + rh + 4, 0)),
                            "White", Enum.Material.SmoothPlastic, 1, false)
        label3D(anchor, signText, 250, 0)
    end

    return folder
end

-- 농장 사용 안내판
local function makeFarmGuide(parent, pos)
    -- 지지대 2개
    for _, xo in ipairs({-9, 9}) do
        part(parent, Vector3.new(0.7, 10, 0.7),
             CFrame.new(pos + Vector3.new(xo, 5, 0)), "Reddish brown", Enum.Material.Wood)
    end

    -- 안내판 본체
    local board = part(parent, Vector3.new(0.5, 9, 20),
                       CFrame.new(pos + Vector3.new(0, 9.5, 0)), "Reddish brown", Enum.Material.Wood)

    local sg = Instance.new("SurfaceGui")
    sg.Face        = Enum.NormalId.Front
    sg.SizingMode  = Enum.SurfaceGuiSizingMode.FixedSize
    sg.CanvasSize  = Vector2.new(520, 380)
    sg.Parent      = board

    local bg = Instance.new("Frame")
    bg.Size             = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(18,55,18)
    bg.BorderSizePixel  = 0
    bg.Parent           = sg

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size               = UDim2.new(1,0,0.18,0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text               = "🌾  농사 사용법"
    titleLbl.TextColor3         = Color3.fromRGB(255,220,50)
    titleLbl.Font               = Enum.Font.GothamBold
    titleLbl.TextScaled         = true
    titleLbl.Parent             = bg

    local steps = {
        "① [F] 키 → 농장 패널 열기",
        "② 씨앗 종류 선택 (패널 상단 목록)",
        "③ 빈 농지 칸 클릭 → 씨앗 심기",
        "④ 시간 경과 후 초록색 = 수확 가능",
        "⑤ 수확된 칸 클릭 → 수확",
        "⑥ [💰 전부 판매] → 골드 획득",
        "⑦ [🍽 먹기] → 허기 회복",
    }

    for i, step in ipairs(steps) do
        local row = Instance.new("Frame")
        row.Size                = UDim2.new(0.96,0,0.107,0)
        row.Position            = UDim2.new(0.02,0, 0.19 + (i-1)*0.113, 0)
        row.BackgroundColor3    = Color3.fromRGB(10,40,10)
        row.BackgroundTransparency = 0.3
        row.BorderSizePixel     = 0
        row.Parent              = bg

        local lbl = Instance.new("TextLabel")
        lbl.Size                = UDim2.new(1,-10,1,0)
        lbl.Position            = UDim2.new(0,8,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Text                = step
        lbl.TextColor3          = Color3.fromRGB(220,255,180)
        lbl.Font                = Enum.Font.Gotham
        lbl.TextScaled          = true
        lbl.TextXAlignment      = Enum.TextXAlignment.Left
        lbl.Parent              = row
    end
end

-- 우물
local function makeWell(parent, pos)
    part(parent, Vector3.new(4,0.5,4), CFrame.new(pos+Vector3.new(0,0.25,0)), "Medium stone grey", Enum.Material.Cobblestone)
    part(parent, Vector3.new(3,0.3,3), CFrame.new(pos+Vector3.new(0,0.5,0)),  "Dark blue",        Enum.Material.Glass, 0.3)
    -- 기둥 4개
    for _, off in ipairs({Vector3.new(1.5,0,1.5),Vector3.new(-1.5,0,1.5),Vector3.new(1.5,0,-1.5),Vector3.new(-1.5,0,-1.5)}) do
        part(parent, Vector3.new(0.4,3,0.4), CFrame.new(pos+off+Vector3.new(0,2,0)), "Reddish brown", Enum.Material.Wood)
    end
    part(parent, Vector3.new(4,0.3,0.4), CFrame.new(pos+Vector3.new(0,3.2,0)),    "Reddish brown", Enum.Material.Wood)
end

-- 포탈
local portalCooldowns = {}

local function makePortal(parent, pos, destPos, labelText, colorName)
    local folder = Instance.new("Folder")
    folder.Name   = labelText
    folder.Parent = parent

    -- 외곽 링
    local ring = part(folder, Vector3.new(0.8, 10, 10),
        CFrame.new(pos) * CFrame.Angles(0, 0, math.pi/2),
        colorName, Enum.Material.Neon, 0, false)

    -- 중심 판 (플레이어가 통과하는 투명 트리거)
    local inner = part(folder, Vector3.new(0.4, 8, 8),
        CFrame.new(pos) * CFrame.Angles(0, 0, math.pi/2),
        colorName, Enum.Material.Neon, 0.5, false)

    local sparkles = Instance.new("Sparkles")
    sparkles.SparkleColor = BrickColor.new(colorName).Color
    sparkles.Parent = inner

    label3D(ring, labelText, 240, 7)

    -- 안내 라벨
    local subLbl = Instance.new("BillboardGui")
    subLbl.Size        = UDim2.new(0,200,0,30)
    subLbl.StudsOffset = Vector3.new(0,-5,0)
    subLbl.Parent      = ring
    local subTxt = Instance.new("TextLabel")
    subTxt.Size = UDim2.new(1,0,1,0)
    subTxt.BackgroundTransparency = 1
    subTxt.Text = "[ 포탈 안으로 걸어 들어가세요 ]"
    subTxt.TextColor3 = Color3.new(1,1,1)
    subTxt.TextStrokeTransparency = 0
    subTxt.Font = Enum.Font.Gotham
    subTxt.TextScaled = true
    subTxt.Parent = subLbl

    -- Touched 방식: 걸어서 통과하면 이동
    inner.Touched:Connect(function(hit)
        local character = hit.Parent
        if not character then return end
        local player = Players:GetPlayerFromCharacter(character)
        if not player then return end

        -- 쿨다운 (2초)
        if portalCooldowns[player.UserId] then return end
        portalCooldowns[player.UserId] = true

        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            task.wait(0.05)
            root.CFrame = CFrame.new(destPos + Vector3.new(0, 5, 0))
        end

        task.delay(2, function()
            portalCooldowns[player.UserId] = nil
        end)
    end)

    -- 깜빡임
    task.spawn(function()
        while folder.Parent do
            TweenService:Create(inner,
                TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                {Transparency = 0.75}):Play()
            task.wait(2.6)
        end
    end)

    return folder
end

-- 울타리 하나
local function makeFence(parent, p1, p2)
    local mid  = (p1 + p2) / 2
    local len  = (p2 - p1).Magnitude
    local cf   = CFrame.new(mid, p2) * CFrame.Angles(0,0,0)
    part(parent, Vector3.new(0.3,2,len), CFrame.lookAt(mid, p2) * CFrame.Angles(0,math.pi/2,0), "Reddish brown", Enum.Material.Wood)
end

-- ── 마을 건설 ────────────────────────────────────────────────────────────────
local village = Instance.new("Folder") village.Name="Village" village.Parent=map

-- 바닥
part(village, Vector3.new(200,1,200), CFrame.new(VILLAGE+Vector3.new(0,-0.5,0)), "Medium green", Enum.Material.Grass)

-- 돌길 (십자형)
part(village, Vector3.new(6,0.2,140), CFrame.new(VILLAGE+Vector3.new(0,0.1,0)),   "Medium stone grey", Enum.Material.Cobblestone)
part(village, Vector3.new(140,0.2,6), CFrame.new(VILLAGE+Vector3.new(0,0.1,0)),   "Medium stone grey", Enum.Material.Cobblestone)

-- 우물 (중앙)
makeWell(village, VILLAGE + Vector3.new(0,0,0))

-- 건물들
makeBuilding(village, VILLAGE+Vector3.new(0,0,-45),   28,12,18, "Bright yellow",  "Bright red",   "🏠 여관")
makeBuilding(village, VILLAGE+Vector3.new(40,0,0),    22,10,16, "Light blue",      "Dark blue",    "🏪 상점")
makeBuilding(village, VILLAGE+Vector3.new(-40,0,0),   20,10,14, "Sand yellow",     "Reddish brown","📋 게시판")
makeBuilding(village, VILLAGE+Vector3.new(0,0,45),    18, 9,14, "Bright orange",   "Bright red",   "🔨 대장간")

-- 나무
for _, off in ipairs({
    Vector3.new(-70,0,-70), Vector3.new(70,0,-70),
    Vector3.new(-70,0,70),  Vector3.new(70,0,70),
    Vector3.new(-55,0,0),   Vector3.new(55,0,-20),
    Vector3.new(-30,0,-60), Vector3.new(30,0,-60),
}) do makeTree(village, VILLAGE+off) end

-- 울타리
local vr = 95
for i = 0, 11 do
    local a1 = math.rad(i*30)     local a2 = math.rad((i+1)*30)
    local p1 = VILLAGE + Vector3.new(math.cos(a1)*vr, 0, math.sin(a1)*vr)
    local p2 = VILLAGE + Vector3.new(math.cos(a2)*vr, 0, math.sin(a2)*vr)
    makeFence(village, p1+Vector3.new(0,0.5,0), p2+Vector3.new(0,0.5,0))
end

-- 스폰 위치
local spawn = Instance.new("SpawnLocation")
spawn.Size       = Vector3.new(6,1,6)
spawn.CFrame     = CFrame.new(VILLAGE + Vector3.new(0, 0.5, -15))
spawn.BrickColor = BrickColor.new("Bright green")
spawn.Anchored   = true
spawn.Duration   = 0
spawn.Parent     = village

-- 마을 표지판
local signPost = part(village, Vector3.new(0.4,5,0.4), CFrame.new(VILLAGE+Vector3.new(-8,2.5,65)), "Reddish brown", Enum.Material.Wood)
label3D(signPost, "🏘 마을 중심가", 220, 4)

-- ── 상점 내부 NPC ────────────────────────────────────────────────────────
-- (상인 NPC 삭제됨 — 작물 판매는 [F] 농장 패널의 "💰 전부 판매" 버튼으로 가능)

-- ── 대장간 NPC (대장장이) ──────────────────────────────────────────────────
local function makeBlacksmith(parent, pos)
    local nf = Instance.new("Folder")
    nf.Name   = "BlacksmithNPC"
    nf.Parent = parent

    -- 몸통(가죽 앞치마 느낌) + 머리
    local body = part(nf, Vector3.new(2.2,3,1.1), CFrame.new(pos+Vector3.new(0,2.5,0)), "Reddish brown", Enum.Material.SmoothPlastic)
    body.Name = "BlacksmithBody"
    local head = part(nf, Vector3.new(2,2,2), CFrame.new(pos+Vector3.new(0,5.5,0)), "Nougat", Enum.Material.SmoothPlastic)
    -- 두건
    part(nf, Vector3.new(2.1,0.6,2.1), CFrame.new(pos+Vector3.new(0,6.6,0)), "Really black", Enum.Material.SmoothPlastic)
    -- 팔
    part(nf, Vector3.new(0.8,2.6,0.8), CFrame.new(pos+Vector3.new(-1.6,2.5,0)), "Nougat", Enum.Material.SmoothPlastic)
    part(nf, Vector3.new(0.8,2.6,0.8), CFrame.new(pos+Vector3.new( 1.6,2.5,0)), "Nougat", Enum.Material.SmoothPlastic)

    for _, p in ipairs(nf:GetDescendants()) do
        if p:IsA("Part") and p ~= body then
            local w = Instance.new("WeldConstraint")
            w.Part0 = body; w.Part1 = p; w.Parent = body
        end
    end

    label3D(head, "🔨 대장장이 (E)", 170, 3)

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name                  = "BlacksmithPrompt"
    prompt.ActionText            = "장비 강화 (E 길게)"
    prompt.ObjectText            = "대장장이"
    prompt.MaxActivationDistance = 12
    prompt.HoldDuration          = 1.5    -- E를 1.5초 길게 눌러야 강화창 열림
    prompt.RequiresLineOfSight   = false
    prompt.Parent = body

    -- 모루 + 화로 소품 (NPC 옆)
    local anvilBase = part(parent, Vector3.new(2.4,1.2,1.4), CFrame.new(pos+Vector3.new(3,1,0)), "Dark stone grey", Enum.Material.Metal)
    part(parent, Vector3.new(3.4,0.7,1.8), CFrame.new(pos+Vector3.new(3,1.9,0)), "Really black", Enum.Material.Metal)
    local forge = part(parent, Vector3.new(2.4,2.4,2.4), CFrame.new(pos+Vector3.new(-3,1.3,0)), "Dark stone grey", Enum.Material.Slate)
    local ember = part(parent, Vector3.new(1.4,1.0,1.4), CFrame.new(pos+Vector3.new(-3,2.2,0)), "Bright orange", Enum.Material.Neon)
    local fl = Instance.new("PointLight")
    fl.Color = Color3.fromRGB(255,140,40); fl.Brightness = 3; fl.Range = 12; fl.Parent = ember
    local fire = Instance.new("Fire")
    fire.Heat = 8; fire.Size = 5; fire.Color = Color3.fromRGB(255,150,40); fire.Parent = ember
end

-- 대장간 건물 내부 (VILLAGE+(0,0,45))
makeBlacksmith(village, VILLAGE + Vector3.new(0, 0, 40))

-- 마을 → 각 구역 포탈
makePortal(village,
    VILLAGE + Vector3.new(-20, 4, 78),
    HUNT + Vector3.new(0, 0, -20),
    "⚔ 사냥터 포탈", "Bright red")

makePortal(village,
    VILLAGE + Vector3.new(20, 4, 78),
    FARM + Vector3.new(0, 0, -20),
    "🌾 농장 포탈", "Bright green")

-- 포탈 안내판
local pSign = part(village, Vector3.new(0.3,4,0.3), CFrame.new(VILLAGE+Vector3.new(0,2,70)), "Reddish brown", Enum.Material.Wood)
label3D(pSign, "← 농장   포탈 구역   사냥터 →", 300, 4)

-- ── 사냥터 건설 ──────────────────────────────────────────────────────────────
local huntZone = Instance.new("Folder") huntZone.Name="HuntZone" huntZone.Parent=map

-- 바닥 (어둡게)
part(huntZone, Vector3.new(300,1,300), CFrame.new(HUNT+Vector3.new(0,-0.5,0)), "Dark orange", Enum.Material.Ground)
part(huntZone, Vector3.new(300,0.2,300),CFrame.new(HUNT+Vector3.new(0,0.1,0)), "Really black", Enum.Material.Ground, 0.5)

-- 안개 분위기용 어두운 바위
for i = 1, 12 do
    local ang = math.rad(i * 30)
    local r   = math.random(40, 130)
    local rPos = HUNT + Vector3.new(math.cos(ang)*r, 0, math.sin(ang)*r)
    part(huntZone, Vector3.new(math.random(3,8), math.random(2,6), math.random(3,8)),
        CFrame.new(rPos+Vector3.new(0,2,0)), "Dark stone grey", Enum.Material.Rock)
end

-- 죽은 나무들
for i = 1, 10 do
    local ang = math.rad(i * 36 + 15)
    local r   = math.random(50, 100)
    makeDeadTree(huntZone, HUNT + Vector3.new(math.cos(ang)*r, 0, math.sin(ang)*r))
end

-- 경계 표지판
local hSign = part(huntZone, Vector3.new(0.3,5,0.3), CFrame.new(HUNT+Vector3.new(0,2.5,-130)), "Dark stone grey", Enum.Material.Rock)
label3D(hSign, "⚔ 사냥터  (위험!)", 220, 5)

-- 마을 귀환 포탈
makePortal(huntZone,
    HUNT + Vector3.new(0, 4, -60),
    VILLAGE + Vector3.new(0, 0, 10),
    "🏘 마을로 귀환", "Bright blue")

-- ── 농장 건설 ────────────────────────────────────────────────────────────────
local farmZone = Instance.new("Folder") farmZone.Name="FarmZone" farmZone.Parent=map

-- 바닥 (밝은 녹색)
part(farmZone, Vector3.new(300,1,300), CFrame.new(FARM+Vector3.new(0,-0.5,0)), "Bright green", Enum.Material.Grass)

-- 밭 구획 (갈색)
for row = 0, 3 do
    for col = 0, 4 do
        part(farmZone,
            Vector3.new(12,0.3,10),
            CFrame.new(FARM + Vector3.new(-48+col*24, 0.15, -20+row*22)),
            "Reddish brown", Enum.Material.Ground)
    end
end

-- 허수아비
for i = 1, 4 do
    local sPos = FARM + Vector3.new(-36+i*24, 0, 20)
    part(farmZone, Vector3.new(0.3,4,0.3), CFrame.new(sPos+Vector3.new(0,2,0)), "Reddish brown", Enum.Material.Wood)
    part(farmZone, Vector3.new(3,0.3,0.3), CFrame.new(sPos+Vector3.new(0,3.5,0)), "Reddish brown", Enum.Material.Wood)
    part(farmZone, Vector3.new(1.5,1.5,0.3), CFrame.new(sPos+Vector3.new(0,4.5,0)), "Bright orange", Enum.Material.SmoothPlastic)
    label3D(
        part(farmZone, Vector3.new(0.1,0.1,0.1), CFrame.new(sPos+Vector3.new(0,5,0)), "White", Enum.Material.SmoothPlastic, 1),
        "🌾", 60, 0
    )
end

-- 농장 나무들
for _, off in ipairs({
    Vector3.new(-110,0,-80), Vector3.new(110,0,-80),
    Vector3.new(-110,0,80),  Vector3.new(110,0,80),
    Vector3.new(-110,0,0),   Vector3.new(110,0,0),
}) do makeTree(farmZone, FARM+off) end

-- 창고
makeBuilding(farmZone, FARM+Vector3.new(0,0,-80), 24,10,16, "Sand yellow","Bright red","🏚 농장 창고")

-- 농장 입구 사용 안내판
makeFarmGuide(farmZone, FARM + Vector3.new(0, 0, -115))

-- 농장 표지판
local fSign = part(farmZone, Vector3.new(0.3,5,0.3), CFrame.new(FARM+Vector3.new(0,2.5,-130)), "Reddish brown", Enum.Material.Wood)
label3D(fSign, "🌾 농장 구역", 200, 5)

-- 마을 귀환 포탈
makePortal(farmZone,
    FARM + Vector3.new(0, 4, -60),
    VILLAGE + Vector3.new(0, 0, 10),
    "🏘 마을로 귀환", "Bright blue")

print("[MapBuilder] 맵 생성 완료 ✓")
