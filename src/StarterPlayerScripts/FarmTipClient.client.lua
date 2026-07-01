-- 농장 구역에 처음 진입하면 농사 안내 팝업 표시
local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player  = Players.LocalPlayer
local FARM    = Vector3.new(-600, 0, 0)
local RADIUS  = 180  -- 농장 반경

local gui = Instance.new("ScreenGui")
gui.Name           = "FarmTipGui"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = player.PlayerGui

-- ── 배경 ──────────────────────────────────────────────────────────────────
local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1,0,1,0)
overlay.BackgroundColor3 = Color3.new(0,0,0)
overlay.BackgroundTransparency = 0.55
overlay.BorderSizePixel = 0
overlay.ZIndex = 40
overlay.Visible = false
overlay.Parent = gui

-- ── 패널 ──────────────────────────────────────────────────────────────────
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 500, 0, 500)
panel.Position = UDim2.new(0.5,-250,0.5,-250)
panel.BackgroundColor3 = Color3.fromRGB(18,55,18)
panel.BackgroundTransparency = 0.05
panel.BorderSizePixel = 0
panel.ZIndex = 41
panel.Visible = false
panel.Parent = gui
local pc = Instance.new("UICorner") pc.CornerRadius = UDim.new(0,16) pc.Parent = panel
local ps = Instance.new("UIStroke") ps.Thickness = 2.5 ps.Color = Color3.fromRGB(80,200,80) ps.Parent = panel

-- 헤더
local hdr = Instance.new("Frame")
hdr.Size = UDim2.new(1,0,0,58)
hdr.BackgroundColor3 = Color3.fromRGB(30,90,30)
hdr.BackgroundTransparency = 0.1
hdr.BorderSizePixel = 0
hdr.ZIndex = 42
hdr.Parent = panel
Instance.new("UICorner",hdr).CornerRadius = UDim.new(0,16)

local hTitle = Instance.new("TextLabel")
hTitle.Size = UDim2.new(1,0,1,0)
hTitle.BackgroundTransparency = 1
hTitle.Text = "🌾  농장에 오신 것을 환영합니다!"
hTitle.TextColor3 = Color3.fromRGB(200,255,150)
hTitle.Font = Enum.Font.GothamBold
hTitle.TextSize = 20
hTitle.ZIndex = 43
hTitle.Parent = hdr

-- 설명 영역
local steps = {
    { icon = "①", text = "[F] 키를 눌러 농장 패널 열기" },
    { icon = "②", text = "상단에서 씨앗 종류 선택" },
    { icon = "③", text = "빈 농지 칸을 클릭 → 씨앗 심기" },
    { icon = "④", text = "기다리면 초록색 구슬이 생겨요 = 수확 가능!" },
    { icon = "⑤", text = "농지 칸 다시 클릭 → 수확" },
    { icon = "⑥", text = "[💰 전부 판매] 버튼 → 골드 획득" },
    { icon = "⑦", text = "[🍽 먹기] 버튼 → 허기 회복" },
}

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = panel

-- 더미 헤더 공간용 Frame
local spacer = Instance.new("Frame")
spacer.Size = UDim2.new(1,0,0,66)
spacer.BackgroundTransparency = 1
spacer.ZIndex = 42
spacer.Parent = panel

for _, step in ipairs(steps) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-20,0,46)
    row.BackgroundColor3 = Color3.fromRGB(20,60,20)
    row.BackgroundTransparency = 0.25
    row.BorderSizePixel = 0
    row.ZIndex = 42
    row.Parent = panel
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,8)

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0,44,1,0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = step.icon
    iconLbl.TextColor3 = Color3.fromRGB(255,220,80)
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.TextSize = 22
    iconLbl.ZIndex = 43
    iconLbl.Parent = row

    local textLbl = Instance.new("TextLabel")
    textLbl.Size = UDim2.new(1,-50,1,0)
    textLbl.Position = UDim2.new(0,46,0,0)
    textLbl.BackgroundTransparency = 1
    textLbl.Text = step.text
    textLbl.TextColor3 = Color3.fromRGB(220,255,180)
    textLbl.Font = Enum.Font.Gotham
    textLbl.TextSize = 15
    textLbl.TextXAlignment = Enum.TextXAlignment.Left
    textLbl.ZIndex = 43
    textLbl.Parent = row
end

-- 팁 라벨
local tip = Instance.new("TextLabel")
tip.Size = UDim2.new(1,-20,0,30)
tip.BackgroundTransparency = 1
tip.Text = "💡 레벨이 높을수록 더 다양한 씨앗을 심을 수 있어요!"
tip.TextColor3 = Color3.fromRGB(180,230,180)
tip.Font = Enum.Font.Gotham
tip.TextSize = 13
tip.ZIndex = 42
tip.Parent = panel

-- 닫기 버튼
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,180,0,42)
closeBtn.Position = UDim2.new(0.5,-90,1,-50)
closeBtn.BackgroundColor3 = Color3.fromRGB(60,160,60)
closeBtn.BackgroundTransparency = 0.1
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✅  농사 시작하기!"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.ZIndex = 43
closeBtn.Parent = panel
Instance.new("UICorner",closeBtn).CornerRadius = UDim.new(0,10)

-- ── 열기 / 닫기 ───────────────────────────────────────────────────────────
local function closePanel()
    TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0,80,0,80), Position = UDim2.new(0.5,-40,0.5,-40), BackgroundTransparency=1
    }):Play()
    TweenService:Create(overlay, TweenInfo.new(0.25), {BackgroundTransparency=1}):Play()
    task.wait(0.35)
    panel.Visible   = false
    overlay.Visible = false
    overlay.BackgroundTransparency = 0.55
end

closeBtn.MouseButton1Click:Connect(closePanel)
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Escape then closePanel() end
end)

-- ── 농장 진입 감지 ────────────────────────────────────────────────────────
local shown = false

task.spawn(function()
    while true do
        task.wait(0.5)
        if shown then break end
        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        if (root.Position - FARM).Magnitude < RADIUS then
            shown = true

            -- 등장 애니메이션
            panel.Size = UDim2.new(0,80,0,80)
            panel.Position = UDim2.new(0.5,-40,0.5,-40)
            panel.BackgroundTransparency = 1
            overlay.BackgroundTransparency = 1
            panel.Visible   = true
            overlay.Visible = true

            TweenService:Create(overlay, TweenInfo.new(0.35), {BackgroundTransparency=0.55}):Play()
            TweenService:Create(panel, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0,500,0,500),
                Position = UDim2.new(0.5,-250,0.5,-250),
                BackgroundTransparency = 0.05,
            }):Play()
        end
    end
end)
