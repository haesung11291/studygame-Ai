local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name           = "Tutorial"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = player.PlayerGui

-- ── 어두운 배경 ──────────────────────────────────────────────────────────────
local overlay = Instance.new("Frame")
overlay.Size                 = UDim2.new(1,0,1,0)
overlay.BackgroundColor3     = Color3.new(0,0,0)
overlay.BackgroundTransparency = 0.45
overlay.BorderSizePixel      = 0
overlay.ZIndex               = 30
overlay.Parent               = gui

-- ── 메인 패널 ────────────────────────────────────────────────────────────────
local panel = Instance.new("Frame")
panel.Size               = UDim2.new(0, 580, 0, 520)
panel.Position           = UDim2.new(0.5,-290, 0.5,-280)
panel.BackgroundColor3   = Color3.fromRGB(18, 18, 30)
panel.BackgroundTransparency = 0.05
panel.BorderSizePixel    = 0
panel.ZIndex             = 31
panel.Parent             = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,16)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color     = Color3.fromRGB(100,180,255)
stroke.Parent    = panel

-- ── 제목 ─────────────────────────────────────────────────────────────────────
local titleBar = Instance.new("Frame")
titleBar.Size             = UDim2.new(1,0,0,52)
titleBar.BackgroundColor3 = Color3.fromRGB(30,50,90)
titleBar.BackgroundTransparency = 0.1
titleBar.BorderSizePixel  = 0
titleBar.ZIndex           = 32
titleBar.Parent           = panel
local tc = Instance.new("UICorner") tc.CornerRadius=UDim.new(0,16) tc.Parent=titleBar

local title = Instance.new("TextLabel")
title.Size                  = UDim2.new(1,0,1,0)
title.BackgroundTransparency= 1
title.Text                  = "🎮  게임 조작 가이드"
title.TextColor3            = Color3.fromRGB(180,220,255)
title.Font                  = Enum.Font.GothamBold
title.TextSize              = 22
title.ZIndex                = 33
title.Parent                = titleBar

-- ── 컨텐츠 ────────────────────────────────────────────────────────────────────
local content = Instance.new("ScrollingFrame")
content.Size               = UDim2.new(1,-20,1,-120)
content.Position           = UDim2.new(0,10,0,58)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 5
content.ScrollBarImageColor3 = Color3.fromRGB(100,180,255)
content.CanvasSize         = UDim2.new(0,0,0,640)
content.ZIndex             = 32
content.Parent             = panel

local layout = Instance.new("UIListLayout")
layout.Padding        = UDim.new(0,6)
layout.Parent         = content

local function section(icon, title2, desc, color)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1,-10,0,70)
    row.BackgroundColor3 = Color3.fromRGB(28,28,45)
    row.BackgroundTransparency = 0.1
    row.BorderSizePixel  = 0
    row.ZIndex           = 33
    row.Parent           = content
    local rc = Instance.new("UICorner") rc.CornerRadius=UDim.new(0,10) rc.Parent=row

    -- 색상 사이드바
    local bar = Instance.new("Frame")
    bar.Size             = UDim2.new(0,4,1,-8)
    bar.Position         = UDim2.new(0,4,0,4)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel  = 0
    bar.ZIndex           = 34
    bar.Parent           = row
    Instance.new("UICorner",bar).CornerRadius = UDim.new(0,2)

    -- 아이콘 + 제목
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size               = UDim2.new(0.35,0,0,28)
    titleLbl.Position           = UDim2.new(0,16,0,8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text               = icon .. "  " .. title2
    titleLbl.TextColor3         = color
    titleLbl.Font               = Enum.Font.GothamBold
    titleLbl.TextSize           = 15
    titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
    titleLbl.ZIndex             = 34
    titleLbl.Parent             = row

    -- 설명
    local descLbl = Instance.new("TextLabel")
    descLbl.Size               = UDim2.new(1,-20,0,46)
    descLbl.Position           = UDim2.new(0,16,0,24)
    descLbl.BackgroundTransparency = 1
    descLbl.Text               = desc
    descLbl.TextColor3         = Color3.fromRGB(200,200,220)
    descLbl.Font               = Enum.Font.Gotham
    descLbl.TextSize           = 13
    descLbl.TextXAlignment     = Enum.TextXAlignment.Left
    descLbl.TextWrapped        = true
    descLbl.ZIndex             = 34
    descLbl.Parent             = row

    return row
end

-- 조작 안내 항목
section("⚔",  "전투",     "[왼쪽 클릭]  범위 내 가장 가까운 몬스터 공격  |  쿨다운 0.6초\n몬스터는 사냥터 포탈을 통해 이동하세요.",
    Color3.fromRGB(255,100,80))

section("🌾",  "농장",     "[F 키]  농장 패널 열기/닫기\n패널에서 씨앗 선택 → 농지 클릭으로 심기  |  수확 가능하면 초록색으로 표시됩니다.",
    Color3.fromRGB(80,200,100))

section("💰",  "판매",     "[F 키] 농장 패널 → 💰 전부 판매 버튼\n인벤토리의 모든 작물을 골드로 교환합니다.",
    Color3.fromRGB(255,210,0))

section("🏪",  "상점",     "[B 키]  상점 열기/닫기\n무기 강화 및 농지 확장 구매 가능  |  레벨 조건 확인 필요.",
    Color3.fromRGB(120,160,255))

section("🍽",  "허기 관리","[F 키] 농장 패널 → 🍽 먹기 버튼\n허기가 0이 되면 체력이 감소합니다.  허기 50 이상 시 자연 회복.",
    Color3.fromRGB(255,160,60))

section("🗺",  "포탈 이동","마을 남쪽 포탈 구역 → ProximityPrompt(E) 사용\n⚔ 사냥터 포탈 / 🌾 농장 포탈 / 🏘 마을 귀환 포탈",
    Color3.fromRGB(180,100,255))

section("⭐",  "레벨업",   "몬스터 처치 & 작물 판매로 경험치 획득  |  레벨 100까지 성장\n레벨업 시 공격력·방어력·농사 속도 등 스탯 자동 증가.",
    Color3.fromRGB(255,220,80))

section("💾",  "저장",     "게임을 나갈 때 자동으로 저장됩니다.\n골드 / 레벨 / 무기 / 농지 크기가 유지됩니다.",
    Color3.fromRGB(160,160,200))

-- ── 닫기 버튼 ────────────────────────────────────────────────────────────────
local closeBtn = Instance.new("TextButton")
closeBtn.Size               = UDim2.new(0,200,0,44)
closeBtn.Position           = UDim2.new(0.5,-100,1,-52)
closeBtn.BackgroundColor3   = Color3.fromRGB(60,140,240)
closeBtn.BackgroundTransparency = 0.05
closeBtn.Text               = "✅  시작하기!"
closeBtn.TextColor3         = Color3.new(1,1,1)
closeBtn.Font               = Enum.Font.GothamBold
closeBtn.TextSize           = 17
closeBtn.BorderSizePixel    = 0
closeBtn.ZIndex             = 32
closeBtn.Parent             = panel
Instance.new("UICorner",closeBtn).CornerRadius = UDim.new(0,10)

local function closePanel()
    TweenService:Create(panel, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size     = UDim2.new(0,100,0,100),
        Position = UDim2.new(0.5,-50,0.5,-50),
        BackgroundTransparency = 1,
    }):Play()
    TweenService:Create(overlay, TweenInfo.new(0.3), {BackgroundTransparency=1}):Play()
    task.wait(0.4)
    gui:Destroy()
end

closeBtn.MouseButton1Click:Connect(closePanel)

-- ESC 키로도 닫기
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Escape then
        closePanel()
    end
end)

-- ── 등장 애니메이션 ───────────────────────────────────────────────────────────
panel.Size     = UDim2.new(0,100,0,100)
panel.Position = UDim2.new(0.5,-50,0.5,-50)
panel.BackgroundTransparency = 1
overlay.BackgroundTransparency = 1

task.wait(1.2)

TweenService:Create(overlay, TweenInfo.new(0.4), {BackgroundTransparency=0.45}):Play()
TweenService:Create(panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size     = UDim2.new(0,580,0,520),
    Position = UDim2.new(0.5,-290,0.5,-260),
    BackgroundTransparency = 0.05,
}):Play()
