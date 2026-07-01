local Players          = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player  = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local OpenBlacksmith = Remotes:WaitForChild("OpenBlacksmith")
local EnhanceWeapon  = Remotes:WaitForChild("EnhanceWeapon")
local EnhanceResult  = Remotes:WaitForChild("EnhanceResult")
local GetPlayerData  = Remotes:WaitForChild("GetPlayerData")

local EnhanceData = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("EnhanceData"))
local ShopData    = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("ShopData"))

local function weaponName(id)
    for _, w in ipairs(ShopData.weapons) do
        if w.id == id then return w.name end
    end
    return id or "무기"
end

-- 성급 표시 문자열 (채움/빈 별)
local function starString(star)
    local s = ""
    for i = 1, EnhanceData.MaxStar do
        s = s .. (i <= star and "★" or "☆")
    end
    return s
end

local function mc(p,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 8) c.Parent=p end

-- ── GUI ────────────────────────────────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name           = "BlacksmithGui"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = player.PlayerGui

local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1,0,1,0)
overlay.BackgroundColor3 = Color3.new(0,0,0)
overlay.BackgroundTransparency = 0.6
overlay.BorderSizePixel = 0
overlay.ZIndex = 30
overlay.Visible = false
overlay.Parent = gui

local panel = Instance.new("Frame")
panel.Size             = UDim2.new(0, 440, 0, 500)
panel.Position         = UDim2.new(0.5,-220,0.5,-250)
panel.BackgroundColor3 = Color3.fromRGB(26,22,20)
panel.BackgroundTransparency = 0.05
panel.BorderSizePixel  = 0
panel.ZIndex           = 31
panel.Visible          = false
panel.Parent           = gui
mc(panel, 14)
local _ps = Instance.new("UIStroke") _ps.Thickness=2 _ps.Color=Color3.fromRGB(220,120,40) _ps.Parent=panel

-- 헤더
local header = Instance.new("Frame")
header.Size             = UDim2.new(1,0,0,58)
header.BackgroundColor3 = Color3.fromRGB(120,55,20)
header.BackgroundTransparency = 0.1
header.BorderSizePixel  = 0
header.ZIndex           = 32
header.Parent           = panel
mc(header, 14)

local hTitle = Instance.new("TextLabel")
hTitle.Size              = UDim2.new(1,-70,1,0)
hTitle.Position          = UDim2.new(0,14,0,0)
hTitle.BackgroundTransparency = 1
hTitle.Text              = "🔨 대장간  -  장비 강화"
hTitle.TextColor3        = Color3.fromRGB(255,210,140)
hTitle.Font              = Enum.Font.GothamBold
hTitle.TextSize          = 18
hTitle.TextXAlignment    = Enum.TextXAlignment.Left
hTitle.ZIndex            = 33
hTitle.Parent            = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0,42,0,34)
closeBtn.Position         = UDim2.new(1,-50,0,12)
closeBtn.BackgroundColor3 = Color3.fromRGB(180,50,50)
closeBtn.Text             = "✕"
closeBtn.TextColor3       = Color3.new(1,1,1)
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 17
closeBtn.ZIndex           = 33
closeBtn.Parent           = header
mc(closeBtn, 8)

-- 대사
local diag = Instance.new("TextLabel")
diag.Size              = UDim2.new(1,-16,0,44)
diag.Position          = UDim2.new(0,8,0,66)
diag.BackgroundColor3  = Color3.fromRGB(45,32,26)
diag.BackgroundTransparency = 0.12
diag.BorderSizePixel   = 0
diag.Text              = "\"무기를 가져와봐. 별을 박아주지... 운이 좋다면 말이야.\""
diag.TextColor3        = Color3.fromRGB(240,205,160)
diag.Font              = Enum.Font.Gotham
diag.TextSize          = 13
diag.TextWrapped       = true
diag.ZIndex            = 32
diag.Parent            = panel
mc(diag, 8)

-- 무기 이름
local weaponLbl = Instance.new("TextLabel")
weaponLbl.Size              = UDim2.new(1,-16,0,34)
weaponLbl.Position          = UDim2.new(0,8,0,118)
weaponLbl.BackgroundTransparency = 1
weaponLbl.Text              = "무기"
weaponLbl.TextColor3        = Color3.fromRGB(255,235,180)
weaponLbl.Font              = Enum.Font.GothamBold
weaponLbl.TextSize          = 22
weaponLbl.ZIndex            = 32
weaponLbl.Parent            = panel

-- 성급 표시
local starLbl = Instance.new("TextLabel")
starLbl.Size              = UDim2.new(1,-16,0,40)
starLbl.Position          = UDim2.new(0,8,0,154)
starLbl.BackgroundTransparency = 1
starLbl.Text              = starString(0)
starLbl.TextColor3        = Color3.fromRGB(255,200,60)
starLbl.Font              = Enum.Font.GothamBold
starLbl.TextSize          = 26
starLbl.ZIndex            = 32
starLbl.Parent            = panel

-- 정보 박스 (공격력 / 다음 단계)
local infoBox = Instance.new("Frame")
infoBox.Size              = UDim2.new(1,-16,0,110)
infoBox.Position          = UDim2.new(0,8,0,200)
infoBox.BackgroundColor3  = Color3.fromRGB(40,34,30)
infoBox.BackgroundTransparency = 0.1
infoBox.BorderSizePixel   = 0
infoBox.ZIndex            = 32
infoBox.Parent            = panel
mc(infoBox, 10)

local infoLbl = Instance.new("TextLabel")
infoLbl.Size              = UDim2.new(1,-20,1,-12)
infoLbl.Position          = UDim2.new(0,10,0,6)
infoLbl.BackgroundTransparency = 1
infoLbl.Text              = ""
infoLbl.TextColor3        = Color3.fromRGB(235,225,210)
infoLbl.Font              = Enum.Font.Gotham
infoLbl.TextSize          = 16
infoLbl.TextXAlignment    = Enum.TextXAlignment.Left
infoLbl.TextYAlignment    = Enum.TextYAlignment.Top
infoLbl.RichText          = true
infoLbl.ZIndex            = 33
infoLbl.Parent            = infoBox

-- 결과 메시지
local resultLbl = Instance.new("TextLabel")
resultLbl.Size              = UDim2.new(1,-16,0,30)
resultLbl.Position          = UDim2.new(0,8,0,318)
resultLbl.BackgroundTransparency = 1
resultLbl.Text              = ""
resultLbl.TextColor3        = Color3.fromRGB(255,255,255)
resultLbl.Font              = Enum.Font.GothamBold
resultLbl.TextSize          = 18
resultLbl.ZIndex            = 32
resultLbl.Parent            = panel

-- 강화 버튼
local enhanceBtn = Instance.new("TextButton")
enhanceBtn.Size             = UDim2.new(1,-16,0,60)
enhanceBtn.Position         = UDim2.new(0,8,1,-118)
enhanceBtn.BackgroundColor3 = Color3.fromRGB(220,120,30)
enhanceBtn.Text             = "🔨 강화하기"
enhanceBtn.TextColor3       = Color3.fromRGB(35,20,0)
enhanceBtn.Font             = Enum.Font.GothamBold
enhanceBtn.TextSize         = 20
enhanceBtn.ZIndex           = 32
enhanceBtn.Parent           = panel
mc(enhanceBtn, 12)

-- 골드 표시
local goldLbl = Instance.new("TextLabel")
goldLbl.Size              = UDim2.new(1,-16,0,28)
goldLbl.Position          = UDim2.new(0,8,1,-52)
goldLbl.BackgroundTransparency = 1
goldLbl.Text              = "보유 골드: -"
goldLbl.TextColor3        = Color3.fromRGB(255,215,90)
goldLbl.Font              = Enum.Font.GothamBold
goldLbl.TextSize          = 16
goldLbl.ZIndex            = 32
goldLbl.Parent            = panel

-- ── 상태 / 렌더링 ───────────────────────────────────────────────────────────
local state = { weapon="WoodSword", base=10, star=0, dmg=10, gold=0 }
local busy = false

local function render()
    weaponLbl.Text = weaponName(state.weapon)
    starLbl.Text   = starString(state.star)

    goldLbl.Text = "보유 골드: " .. state.gold .. "G"

    if state.star >= EnhanceData.MaxStar then
        infoLbl.Text = "현재 공격력: <b>" .. state.dmg .. "</b>\n\n<font color='#ffd24a'>최고 강화 단계 달성! ★" .. EnhanceData.MaxStar .. "</font>"
        enhanceBtn.Text = "✨ 최고 강화 완료"
        enhanceBtn.BackgroundColor3 = Color3.fromRGB(90,90,90)
        enhanceBtn.AutoButtonColor = false
        return
    end

    local target  = state.star + 1
    local rate    = EnhanceData.SuccessRate(target)
    local cost    = EnhanceData.Cost(state.base, target)
    local nextDmg = state.base + EnhanceData.Bonus(state.base, target)
    local gain    = nextDmg - state.dmg

    -- 확률 색상
    local rateColor = "#6cd66c"
    if rate < 35 then rateColor = "#e05050"
    elseif rate < 65 then rateColor = "#e0b000" end

    infoLbl.Text =
        "현재 공격력: <b>" .. state.dmg .. "</b>\n" ..
        "★" .. state.star .. " → ★" .. target ..
        "  (공격력 <font color='#6cd66c'>+" .. gain .. "</font> → " .. nextDmg .. ")\n" ..
        "성공 확률: <font color='" .. rateColor .. "'><b>" .. rate .. "%</b></font>\n" ..
        "비용: <font color='#ffd24a'>" .. cost .. "G</font>"

    enhanceBtn.AutoButtonColor = true
    if state.gold < cost then
        enhanceBtn.Text = "🔨 강화하기 (골드 부족)"
        enhanceBtn.BackgroundColor3 = Color3.fromRGB(110,80,50)
    else
        enhanceBtn.Text = "🔨 강화하기  (" .. cost .. "G)"
        enhanceBtn.BackgroundColor3 = Color3.fromRGB(220,120,30)
    end
end

local function refreshFromServer()
    local pd = GetPlayerData:InvokeServer()
    if not pd then
        task.wait(0.3)              -- 데이터가 아직 준비 안 됐으면 한 번 더 시도
        pd = GetPlayerData:InvokeServer()
    end
    if not pd then return end
    state.weapon = pd.weapon or "WoodSword"
    state.base   = pd.weaponBaseDamage or pd.weaponDamage or 10
    state.star   = pd.weaponStar or 0
    state.dmg    = pd.weaponDamage or state.base
    state.gold   = pd.gold or 0
    render()
end

-- ── 열기/닫기 ─────────────────────────────────────────────────────────────
local isOpen = false

local function openUI()
    if isOpen then return end
    isOpen = true
    resultLbl.Text = ""
    overlay.Visible = true
    panel.Visible   = true
    panel.Size = UDim2.new(0,100,0,100)
    panel.Position = UDim2.new(0.5,-50,0.5,-50)
    TweenService:Create(panel, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0,440,0,500), Position = UDim2.new(0.5,-220,0.5,-250)
    }):Play()
    task.spawn(refreshFromServer)
end

local function closeUI()
    if not isOpen then return end
    isOpen = false
    TweenService:Create(panel, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0,80,0,80), Position = UDim2.new(0.5,-40,0.5,-40)
    }):Play()
    TweenService:Create(overlay, TweenInfo.new(0.25), {BackgroundTransparency=1}):Play()
    task.wait(0.28)
    panel.Visible   = false
    overlay.Visible = false
    overlay.BackgroundTransparency = 0.6
end

closeBtn.MouseButton1Click:Connect(closeUI)
overlay.MouseButton1Click:Connect(closeUI)
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Escape then closeUI() end
end)

enhanceBtn.MouseButton1Click:Connect(function()
    if busy then return end
    if state.star >= EnhanceData.MaxStar then return end
    local cost = EnhanceData.Cost(state.base, state.star + 1)
    if state.gold < cost then
        resultLbl.Text = "골드가 부족합니다!"
        resultLbl.TextColor3 = Color3.fromRGB(255,90,90)
        return
    end
    busy = true
    enhanceBtn.Text = "🔨 강화 중..."
    resultLbl.Text = ""
    EnhanceWeapon:FireServer()
end)

-- 강화 결과 수신 → 연출 + 갱신
EnhanceResult.OnClientEvent:Connect(function(res)
    busy = false
    state.star = res.star
    state.dmg  = res.weaponDamage
    state.gold = res.gold
    render()

    if res.success then
        resultLbl.Text = "✨ 강화 성공!  ★" .. res.star .. " 달성!"
        resultLbl.TextColor3 = Color3.fromRGB(120,255,120)
        starLbl.TextColor3 = Color3.fromRGB(255,235,120)
        starLbl.Size = UDim2.new(1,-16,0,52)
        TweenService:Create(starLbl, TweenInfo.new(0.4, Enum.EasingStyle.Bounce), {Size=UDim2.new(1,-16,0,40)}):Play()
    else
        resultLbl.Text = "💥 강화 실패...  (확률 " .. res.rate .. "%, 주사위 " .. res.roll .. ")"
        resultLbl.TextColor3 = Color3.fromRGB(255,90,90)
        -- 패널 흔들기
        local op = panel.Position
        for i = 1, 4 do
            local dir = (i % 2 == 0) and 1 or -1
            TweenService:Create(panel, TweenInfo.new(0.04), {Position = op + UDim2.new(0,8*dir,0,0)}):Play()
            task.wait(0.045)
        end
        panel.Position = op
    end
end)

OpenBlacksmith.OnClientEvent:Connect(openUI)

-- 서버 경유 없이 클라이언트에서 직접 프롬프트 발동 감지 (안정적인 직통 경로)
local ProximityPromptService = game:GetService("ProximityPromptService")
ProximityPromptService.PromptTriggered:Connect(function(prompt)
    print("[Blacksmith] 프롬프트 발동 감지:", prompt and prompt.Name)   -- 진단용
    if prompt and prompt.Name == "BlacksmithPrompt" then
        openUI()
    end
end)
print("[Blacksmith] 클라이언트 준비 완료 ✓")   -- 스크립트가 끝까지 실행됐는지 확인
