local Players         = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player  = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local OpenNPCShop   = Remotes:WaitForChild("OpenNPCShop")
local SellCrops     = Remotes:WaitForChild("SellCrops")
local GetPlayerData = Remotes:WaitForChild("GetPlayerData")
local CropData      = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("CropData"))

local gui = Instance.new("ScreenGui")
gui.Name           = "NpcShopGui"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = player.PlayerGui

local function mc(p,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 8) c.Parent=p end

-- ── 배경 오버레이 ─────────────────────────────────────────────────────────
local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1,0,1,0)
overlay.BackgroundColor3 = Color3.new(0,0,0)
overlay.BackgroundTransparency = 0.6
overlay.BorderSizePixel = 0
overlay.ZIndex = 30
overlay.Visible = false
overlay.Parent = gui

-- ── 메인 패널 ─────────────────────────────────────────────────────────────
local panel = Instance.new("Frame")
panel.Size             = UDim2.new(0, 440, 0, 540)
panel.Position         = UDim2.new(0.5,-220,0.5,-270)
panel.BackgroundColor3 = Color3.fromRGB(30,20,10)
panel.BackgroundTransparency = 0.05
panel.BorderSizePixel  = 0
panel.ZIndex           = 31
panel.Visible          = false
panel.Parent           = gui
mc(panel, 14)
local _ps = Instance.new("UIStroke") _ps.Thickness=2 _ps.Color=Color3.fromRGB(200,150,50) _ps.Parent=panel

-- 헤더
local header = Instance.new("Frame")
header.Size             = UDim2.new(1,0,0,58)
header.BackgroundColor3 = Color3.fromRGB(100,65,15)
header.BackgroundTransparency = 0.1
header.BorderSizePixel  = 0
header.ZIndex           = 32
header.Parent           = panel
mc(header, 14)

local hTitle = Instance.new("TextLabel")
hTitle.Size              = UDim2.new(1,-70,1,0)
hTitle.Position          = UDim2.new(0,14,0,0)
hTitle.BackgroundTransparency = 1
hTitle.Text              = "🧙 마을 상인  -  곡물 거래소"
hTitle.TextColor3        = Color3.fromRGB(255,220,100)
hTitle.Font              = Enum.Font.GothamBold
hTitle.TextSize          = 18
hTitle.TextXAlignment    = Enum.TextXAlignment.Left
hTitle.ZIndex            = 33
hTitle.Parent            = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0,42,0,34)
closeBtn.Position         = UDim2.new(1,-50,0,12)
closeBtn.BackgroundColor3 = Color3.fromRGB(180,50,50)
closeBtn.BackgroundTransparency = 0.15
closeBtn.Text             = "✕"
closeBtn.TextColor3       = Color3.new(1,1,1)
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 17
closeBtn.ZIndex           = 33
closeBtn.Parent           = header
mc(closeBtn, 8)

-- 대사
local diag = Instance.new("TextLabel")
diag.Size              = UDim2.new(1,-16,0,52)
diag.Position          = UDim2.new(0,8,0,66)
diag.BackgroundColor3  = Color3.fromRGB(55,38,12)
diag.BackgroundTransparency = 0.12
diag.BorderSizePixel   = 0
diag.Text              = "\"어서오세요! 농작물을 팔아 골드를 버세요.\"\n                                      - 마을 상인"
diag.TextColor3        = Color3.fromRGB(240,215,160)
diag.Font              = Enum.Font.Gotham
diag.TextSize          = 13
diag.TextWrapped       = true
diag.TextXAlignment    = Enum.TextXAlignment.Left
diag.ZIndex            = 32
diag.Parent            = panel
mc(diag, 8)

-- 전부 판매 버튼
local sellAllBtn = Instance.new("TextButton")
sellAllBtn.Size             = UDim2.new(1,-16,0,44)
sellAllBtn.Position         = UDim2.new(0,8,0,126)
sellAllBtn.BackgroundColor3 = Color3.fromRGB(210,160,0)
sellAllBtn.BackgroundTransparency = 0.08
sellAllBtn.Text             = "💰 전부 판매하기"
sellAllBtn.TextColor3       = Color3.fromRGB(40,25,0)
sellAllBtn.Font             = Enum.Font.GothamBold
sellAllBtn.TextSize         = 17
sellAllBtn.ZIndex           = 32
sellAllBtn.Parent           = panel
mc(sellAllBtn, 10)

-- 작물 목록 헤더
local listHdr = Instance.new("TextLabel")
listHdr.Size              = UDim2.new(1,-16,0,28)
listHdr.Position          = UDim2.new(0,8,0,178)
listHdr.BackgroundTransparency = 1
listHdr.Text              = "📦 보유 작물 (수확 완료)"
listHdr.TextColor3        = Color3.fromRGB(160,255,140)
listHdr.Font              = Enum.Font.GothamBold
listHdr.TextSize          = 14
listHdr.TextXAlignment    = Enum.TextXAlignment.Left
listHdr.ZIndex            = 32
listHdr.Parent            = panel

-- 작물 스크롤 리스트
local listScroll = Instance.new("ScrollingFrame")
listScroll.Size               = UDim2.new(1,-16,1,-216)
listScroll.Position           = UDim2.new(0,8,0,210)
listScroll.BackgroundTransparency = 1
listScroll.ScrollBarThickness = 6
listScroll.ZIndex             = 32
listScroll.Parent             = panel
local _ll = Instance.new("UIListLayout") _ll.Padding=UDim.new(0,5) _ll.Parent=listScroll

-- ── 데이터 새로고침 ────────────────────────────────────────────────────────
local function refreshShop()
    for _, c in ipairs(listScroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end

    local pd = GetPlayerData:InvokeServer()
    if not pd then return end

    local totalG, rowCount = 0, 0

    if pd.inventory then
        for cType, cnt in pairs(pd.inventory) do
            if cnt and cnt > 0 and CropData[cType] then
                rowCount = rowCount + 1
                local crop  = CropData[cType]
                local value = cnt * crop.sellPrice
                totalG = totalG + value

                local row = Instance.new("Frame")
                row.Size              = UDim2.new(1,0,0,54)
                row.BackgroundColor3  = Color3.fromRGB(38,55,20)
                row.BackgroundTransparency = 0.15
                row.BorderSizePixel   = 0
                row.ZIndex            = 33
                row.Parent            = listScroll
                mc(row, 8)

                -- 아이콘 박스
                local iconBox = Instance.new("Frame")
                iconBox.Size              = UDim2.new(0,48,1,-8)
                iconBox.Position          = UDim2.new(0,4,0,4)
                iconBox.BackgroundColor3  = Color3.fromRGB(20,40,10)
                iconBox.BackgroundTransparency = 0.2
                iconBox.BorderSizePixel   = 0
                iconBox.ZIndex            = 34
                iconBox.Parent            = row
                mc(iconBox, 6)
                local iconLbl = Instance.new("TextLabel")
                iconLbl.Size = UDim2.new(1,0,1,0)
                iconLbl.BackgroundTransparency = 1
                iconLbl.Text = "🌾"
                iconLbl.TextSize = 26
                iconLbl.ZIndex = 35
                iconLbl.Parent = iconBox

                -- 정보
                local info = Instance.new("TextLabel")
                info.Size              = UDim2.new(1,-60,0.6,0)
                info.Position          = UDim2.new(0,58,0,4)
                info.BackgroundTransparency = 1
                info.Text              = crop.name .. "  ×" .. cnt
                info.TextColor3        = Color3.fromRGB(220,255,170)
                info.Font              = Enum.Font.GothamBold
                info.TextSize          = 15
                info.TextXAlignment    = Enum.TextXAlignment.Left
                info.ZIndex            = 34
                info.Parent            = row

                local subInfo = Instance.new("TextLabel")
                subInfo.Size           = UDim2.new(1,-60,0.4,0)
                subInfo.Position       = UDim2.new(0,58,0.6,0)
                subInfo.BackgroundTransparency = 1
                subInfo.Text           = crop.sellPrice .. "G/개  →  합계 " .. value .. "G"
                subInfo.TextColor3     = Color3.fromRGB(180,220,140)
                subInfo.Font           = Enum.Font.Gotham
                subInfo.TextSize       = 12
                subInfo.TextXAlignment = Enum.TextXAlignment.Left
                subInfo.ZIndex         = 34
                subInfo.Parent         = row
            end
        end
    end

    if rowCount == 0 then
        local el = Instance.new("TextLabel")
        el.Size = UDim2.new(1,0,0,50)
        el.BackgroundTransparency = 1
        el.Text = "수확한 작물이 없습니다\n[F] 농장 패널에서 재배하세요"
        el.TextColor3 = Color3.fromRGB(140,140,140)
        el.Font = Enum.Font.Gotham
        el.TextSize = 14
        el.ZIndex = 33
        el.Parent = listScroll
    end

    listScroll.CanvasSize = UDim2.new(0,0,0, rowCount*59 + 10)

    if totalG > 0 then
        sellAllBtn.Text = "💰 전부 판매하기  (+" .. totalG .. "G)"
        sellAllBtn.BackgroundColor3 = Color3.fromRGB(210,160,0)
    else
        sellAllBtn.Text = "💰 전부 판매하기  (작물 없음)"
        sellAllBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    end
end

-- ── 열기/닫기 ─────────────────────────────────────────────────────────────
local isOpen = false

local function openShop()
    if isOpen then return end
    isOpen = true
    overlay.Visible = true
    panel.Visible   = true
    panel.Size = UDim2.new(0,100,0,100)
    panel.Position = UDim2.new(0.5,-50,0.5,-50)
    TweenService:Create(panel, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0,440,0,540), Position = UDim2.new(0.5,-220,0.5,-270)
    }):Play()
    task.spawn(refreshShop)
end

local function closeShop()
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

closeBtn.MouseButton1Click:Connect(closeShop)
overlay.MouseButton1Click:Connect(closeShop)

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Escape then closeShop() end
end)

sellAllBtn.MouseButton1Click:Connect(function()
    SellCrops:FireServer()
    task.wait(0.3)
    refreshShop()
end)

OpenNPCShop.OnClientEvent:Connect(openShop)

-- 서버 경유 없이 클라이언트에서 직접 프롬프트 발동 감지 (안정적인 직통 경로)
local ProximityPromptService = game:GetService("ProximityPromptService")
ProximityPromptService.PromptTriggered:Connect(function(prompt)
    if prompt and prompt.Name == "MerchantPrompt" then
        openShop()
    end
end)
