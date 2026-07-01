local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local UserInputService    = game:GetService("UserInputService")
local TweenService        = game:GetService("TweenService")
local RunService          = game:GetService("RunService")

local player  = Players.LocalPlayer
local mouse   = player:GetMouse()
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local PlantSeed     = Remotes:WaitForChild("PlantSeed")
local HarvestCrop   = Remotes:WaitForChild("HarvestCrop")
local SellCrops     = Remotes:WaitForChild("SellCrops")
local AttackMonster = Remotes:WaitForChild("AttackMonster")
local BuyItem       = Remotes:WaitForChild("BuyItem")
local EatFood       = Remotes:WaitForChild("EatFood")
local GetPlayerData = Remotes:WaitForChild("GetPlayerData")

local CropData  = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("CropData"))
local ShopData  = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("ShopData"))

local gui = Instance.new("ScreenGui")
gui.Name           = "GameUI"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = player.PlayerGui

local function makeCorner(p, r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 8) c.Parent=p end
local function makeStroke(p, t, c) local s=Instance.new("UIStroke") s.Thickness=t or 1 s.Color=c or Color3.new(1,1,1) s.Parent=p end

-- ── COMBAT ATTACK COOLDOWN ────────────────────────────────────────────────
local canAttack   = true
local ATTACK_CD   = 0.6

-- ── FARMING PANEL ────────────────────────────────────────────────────────
local farmOpen = false
local farmPanel = Instance.new("Frame")
farmPanel.Name   = "FarmPanel"
farmPanel.Size   = UDim2.new(0, 340, 0, 500)
farmPanel.Position = UDim2.new(0, 10, 0.5, -250)
farmPanel.BackgroundColor3 = Color3.fromRGB(20, 35, 20)
farmPanel.BackgroundTransparency = 0.1
farmPanel.BorderSizePixel = 0
farmPanel.Visible = false
farmPanel.ZIndex  = 5
farmPanel.Parent  = gui
makeCorner(farmPanel, 12)
makeStroke(farmPanel, 2, Color3.fromRGB(80,160,60))

local farmTitle = Instance.new("TextLabel")
farmTitle.Size = UDim2.new(1,0,0,36)
farmTitle.BackgroundColor3 = Color3.fromRGB(40,80,30)
farmTitle.BackgroundTransparency = 0.1
farmTitle.BorderSizePixel = 0
farmTitle.Text = "🌾 농장 관리  [F]"
farmTitle.TextColor3 = Color3.fromRGB(180,255,120)
farmTitle.Font = Enum.Font.GothamBold
farmTitle.TextSize = 16
farmTitle.ZIndex = 6
farmTitle.Parent = farmPanel
makeCorner(farmTitle, 12)

-- Crop selector
local selectedCrop = "Wheat"
local cropOrder = {"Wheat","Carrot","Potato","Corn","Tomato","Pumpkin","Watermelon","Strawberry","Mushroom","GoldenApple"}

local cropSelectorFrame = Instance.new("Frame")
cropSelectorFrame.Size = UDim2.new(1,-10,0,70)
cropSelectorFrame.Position = UDim2.new(0,5,0,42)
cropSelectorFrame.BackgroundTransparency = 1
cropSelectorFrame.ZIndex = 6
cropSelectorFrame.Parent = farmPanel

local cropScroll = Instance.new("ScrollingFrame")
cropScroll.Size = UDim2.new(1,0,1,0)
cropScroll.BackgroundTransparency = 1
cropScroll.ScrollBarThickness = 4
cropScroll.CanvasSize = UDim2.new(0, #cropOrder * 68, 0, 0)
cropScroll.ScrollingDirection = Enum.ScrollingDirection.X
cropScroll.ZIndex = 6
cropScroll.Parent = cropSelectorFrame

local cropBtns = {}
for i, cType in ipairs(cropOrder) do
    local c = CropData[cType]
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 62, 1, -4)
    btn.Position = UDim2.new(0, (i-1)*66+2, 0, 2)
    btn.BackgroundColor3 = Color3.fromRGB(40,80,30)
    btn.BackgroundTransparency = 0.2
    btn.Text = c.name .. "\n" .. c.price .. "G"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.ZIndex = 7
    btn.Parent = cropScroll
    makeCorner(btn, 6)

    btn.MouseButton1Click:Connect(function()
        selectedCrop = cType
        for _, b in pairs(cropBtns) do
            b.BackgroundColor3 = Color3.fromRGB(40,80,30)
        end
        btn.BackgroundColor3 = Color3.fromRGB(80,160,50)
    end)
    cropBtns[cType] = btn
end
cropBtns[selectedCrop].BackgroundColor3 = Color3.fromRGB(80,160,50)

-- Plot grid
local plotScroll = Instance.new("ScrollingFrame")
plotScroll.Size = UDim2.new(1,-10,1,-180)
plotScroll.Position = UDim2.new(0,5,0,118)
plotScroll.BackgroundTransparency = 1
plotScroll.ScrollBarThickness = 6
plotScroll.ZIndex = 6
plotScroll.Parent = farmPanel

local plotGrid = Instance.new("UIGridLayout")
plotGrid.CellSize = UDim2.new(0, 145, 0, 100)
plotGrid.CellPadding = UDim2.new(0, 6, 0, 6)
plotGrid.Parent = plotScroll

local plotButtons = {}

local function refreshPlots(pd)
    for _, b in pairs(plotButtons) do b:Destroy() end
    plotButtons = {}

    for i = 1, (pd and pd.plots or 2) do
        local plotData = pd and pd.crops[i]
        local btn = Instance.new("TextButton")
        btn.BackgroundColor3 = plotData
            and (plotData.grown and Color3.fromRGB(100,200,60) or Color3.fromRGB(80,130,50))
            or Color3.fromRGB(40,80,30)
        btn.BackgroundTransparency = 0.1
        btn.BorderSizePixel = 0
        btn.ZIndex = 7
        btn.Parent = plotScroll
        makeCorner(btn, 8)

        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1,0,1,0)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.new(1,1,1)
        txt.Font = Enum.Font.Gotham
        txt.TextSize = 13
        txt.TextWrapped = true
        txt.ZIndex = 8
        txt.Parent = btn

        if plotData then
            if plotData.grown then
                txt.Text = "🌾 " .. (CropData[plotData.type] and CropData[plotData.type].name or plotData.type) .. "\n[수확 가능]\n클릭: 수확"
            else
                local left = math.max(0, math.ceil((plotData.plantedAt + plotData.growTime) - os.time()))
                txt.Text = "⏳ " .. (CropData[plotData.type] and CropData[plotData.type].name or plotData.type) .. "\n" .. left .. "초 남음"
            end
        else
            txt.Text = "🌱 농지 " .. i .. "\n[비어 있음]\n클릭: " .. (CropData[selectedCrop] and CropData[selectedCrop].name or selectedCrop) .. " 심기"
        end

        local plotIdx = i
        btn.MouseButton1Click:Connect(function()
            if plotData and plotData.grown then
                HarvestCrop:FireServer(plotIdx)
            elseif not plotData then
                PlantSeed:FireServer(selectedCrop, plotIdx)
            end
            task.wait(0.2)
            local fresh = GetPlayerData:InvokeServer()
            if fresh then refreshPlots(fresh) end
        end)

        table.insert(plotButtons, btn)
    end

    plotScroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil((pd and pd.plots or 2) / 2) * 112)
end

-- Sell + Inventory row
local bottomRow = Instance.new("Frame")
bottomRow.Size = UDim2.new(1,-10,0,55)
bottomRow.Position = UDim2.new(0,5,1,-62)
bottomRow.BackgroundTransparency = 1
bottomRow.ZIndex = 6
bottomRow.Parent = farmPanel

local sellBtn = Instance.new("TextButton")
sellBtn.Size = UDim2.new(0.48,0,1,0)
sellBtn.BackgroundColor3 = Color3.fromRGB(220,180,0)
sellBtn.BackgroundTransparency = 0.1
sellBtn.Text = "💰 전부 판매"
sellBtn.TextColor3 = Color3.fromRGB(30,20,0)
sellBtn.Font = Enum.Font.GothamBold
sellBtn.TextSize = 15
sellBtn.ZIndex = 7
sellBtn.Parent = bottomRow
makeCorner(sellBtn)
sellBtn.MouseButton1Click:Connect(function() SellCrops:FireServer() end)

local eatBtn = Instance.new("TextButton")
eatBtn.Size = UDim2.new(0.48,0,1,0)
eatBtn.Position = UDim2.new(0.52,0,0,0)
eatBtn.BackgroundColor3 = Color3.fromRGB(200,80,30)
eatBtn.BackgroundTransparency = 0.1
eatBtn.Text = "🍽 먹기 (" .. (CropData[selectedCrop] and CropData[selectedCrop].name or "") .. ")"
eatBtn.TextColor3 = Color3.new(1,1,1)
eatBtn.Font = Enum.Font.GothamBold
eatBtn.TextSize = 13
eatBtn.ZIndex = 7
eatBtn.Parent = bottomRow
makeCorner(eatBtn)
eatBtn.MouseButton1Click:Connect(function() EatFood:FireServer(selectedCrop) end)

-- ── SHOP PANEL ────────────────────────────────────────────────────────────
local shopOpen = false
local shopPanel = Instance.new("Frame")
shopPanel.Name = "ShopPanel"
shopPanel.Size = UDim2.new(0, 360, 0, 520)
shopPanel.Position = UDim2.new(1,-375,0.5,-260)
shopPanel.BackgroundColor3 = Color3.fromRGB(20,20,35)
shopPanel.BackgroundTransparency = 0.1
shopPanel.BorderSizePixel = 0
shopPanel.Visible = false
shopPanel.ZIndex = 5
shopPanel.Parent = gui
makeCorner(shopPanel, 12)
makeStroke(shopPanel, 2, Color3.fromRGB(100,100,220))

local shopTitle = Instance.new("TextLabel")
shopTitle.Size = UDim2.new(1,0,0,36)
shopTitle.BackgroundColor3 = Color3.fromRGB(40,40,80)
shopTitle.BackgroundTransparency = 0.1
shopTitle.BorderSizePixel = 0
shopTitle.Text = "🏪 상점  [B]"
shopTitle.TextColor3 = Color3.fromRGB(180,180,255)
shopTitle.Font = Enum.Font.GothamBold
shopTitle.TextSize = 16
shopTitle.ZIndex = 6
shopTitle.Parent = shopPanel
makeCorner(shopTitle, 12)

local function makeShopSection(title, yOff)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-10,0,22)
    lbl.Position = UDim2.new(0,5,0,yOff)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(200,200,255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.ZIndex = 6
    lbl.Parent = shopPanel
    return lbl
end

local function makeShopItem(parent, itemData, itemType, yOff)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-10,0,46)
    row.Position = UDim2.new(0,5,0,yOff)
    row.BackgroundColor3 = Color3.fromRGB(30,30,50)
    row.BackgroundTransparency = 0.1
    row.BorderSizePixel = 0
    row.ZIndex = 6
    row.Parent = parent
    makeCorner(row, 6)

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(0.6,0,1,0)
    info.Position = UDim2.new(0,8,0,0)
    info.BackgroundTransparency = 1
    info.Text = itemData.name .. "\nLv." .. itemData.level .. " 필요  |  " ..
        (itemData.damage and ("공격력 " .. itemData.damage) or ("농지 " .. itemData.plots .. "칸"))
    info.TextColor3 = Color3.new(1,1,1)
    info.Font = Enum.Font.Gotham
    info.TextSize = 12
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextWrapped = true
    info.ZIndex = 7
    info.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,95,0,32)
    btn.Position = UDim2.new(1,-100,0.5,-16)
    btn.BackgroundColor3 = itemData.price == 0 and Color3.fromRGB(80,80,80) or Color3.fromRGB(220,180,0)
    btn.BackgroundTransparency = 0.1
    btn.Text = itemData.price == 0 and "기본 지급" or (itemData.price .. "G")
    btn.TextColor3 = Color3.fromRGB(30,20,0)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.ZIndex = 7
    btn.Parent = row
    makeCorner(btn, 6)

    if itemData.price > 0 then
        btn.MouseButton1Click:Connect(function()
            BuyItem:FireServer(itemType, itemData.id)
        end)
    end

    return row
end

makeShopSection("⚔ 무기", 44)
for i, w in ipairs(ShopData.weapons) do
    makeShopItem(shopPanel, w, "weapon", 42 + i * 50)
end

makeShopSection("🌱 농지 확장", 300)
for i, l in ipairs(ShopData.land) do
    makeShopItem(shopPanel, l, "land", 298 + i * 50)
end

-- ── SHORTCUT BUTTONS (bottom-center) ─────────────────────────────────────
local shortcuts = Instance.new("Frame")
shortcuts.Size = UDim2.new(0, 200, 0, 44)
shortcuts.Position = UDim2.new(0.5,-100,1,-54)
shortcuts.BackgroundTransparency = 1
shortcuts.ZIndex = 5
shortcuts.Parent = gui

local function makeShortcutBtn(text, x, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 90, 1, 0)
    b.Position = UDim2.new(0, x, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(30,30,40)
    b.BackgroundTransparency = 0.2
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.ZIndex = 6
    b.Parent = shortcuts
    makeCorner(b)
    b.MouseButton1Click:Connect(callback)
    return b
end

makeShortcutBtn("🌾 농장 [F]", 0, function()
    farmOpen = not farmOpen
    farmPanel.Visible = farmOpen
    if farmOpen then
        local pd = GetPlayerData:InvokeServer()
        if pd then refreshPlots(pd) end
    end
end)

makeShortcutBtn("🏪 상점 [B]", 104, function()
    shopOpen = not shopOpen
    shopPanel.Visible = shopOpen
end)

-- ── KEYBOARD SHORTCUTS ───────────────────────────────────────────────────
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        farmOpen = not farmOpen
        farmPanel.Visible = farmOpen
        if farmOpen then
            local pd = GetPlayerData:InvokeServer()
            if pd then refreshPlots(pd) end
        end
    elseif input.KeyCode == Enum.KeyCode.B then
        shopOpen = not shopOpen
        shopPanel.Visible = shopOpen

    elseif input.KeyCode == Enum.KeyCode.Three then
        -- 서버가 빈 농지를 자동으로 찾아서 심음 (plotId 없이 전송)
        PlantSeed:FireServer(selectedCrop, nil)
        if farmOpen then
            task.delay(0.5, function()
                local fresh = GetPlayerData:InvokeServer()
                if fresh then refreshPlots(fresh) end
            end)
        end

    elseif input.KeyCode == Enum.KeyCode.Four then
        -- 4번 키: 수확 가능한 첫 번째 밭 수확 (plotId 없이 전송)
        HarvestCrop:FireServer(nil)
        if farmOpen then
            task.delay(0.5, function()
                local fresh = GetPlayerData:InvokeServer()
                if fresh then refreshPlots(fresh) end
            end)
        end
    end
end)

-- ── 공격 슬래시 이펙트 ───────────────────────────────────────────────────
local Debris = game:GetService("Debris")

local function spawnSlash(root)
    local angles = {45, -45}
    local colors = {BrickColor.new("Bright yellow"), BrickColor.new("Bright orange")}
    for i = 1, 2 do
        local s = Instance.new("Part")
        s.Size        = Vector3.new(0.3, 7, 7)
        s.CFrame      = root.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(0, 0, math.rad(angles[i]))
        s.Anchored    = true
        s.CanCollide  = false
        s.Material    = Enum.Material.Neon
        s.BrickColor  = colors[i]
        s.Transparency = 0.1
        s.Parent      = workspace
        Debris:AddItem(s, 0.3)
        TweenService:Create(s, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Transparency = 1, Size = Vector3.new(0.1, 9, 9)
        }):Play()
    end
    -- 원형 충격파
    local ring = Instance.new("Part")
    ring.Size       = Vector3.new(0.2, 0.2, 0.2)
    ring.Shape      = Enum.PartType.Ball
    ring.CFrame     = root.CFrame * CFrame.new(0, 0, -3)
    ring.Anchored   = true
    ring.CanCollide = false
    ring.Material   = Enum.Material.Neon
    ring.BrickColor = BrickColor.new("Bright yellow")
    ring.Transparency = 0.3
    ring.Parent     = workspace
    Debris:AddItem(ring, 0.25)
    TweenService:Create(ring, TweenInfo.new(0.25), {
        Size = Vector3.new(10, 10, 10), Transparency = 1
    }):Play()
end

-- ── 왼쪽 클릭: 슬래시 이펙트만 ─────────────────────────────────────────
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if farmOpen or shopOpen then return end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then spawnSlash(root) end
end)

-- ── 전투 상태 표시 라벨 ──────────────────────────────────────────────────
local combatLbl = Instance.new("TextLabel")
combatLbl.Size = UDim2.new(0, 260, 0, 28)
combatLbl.Position = UDim2.new(0.5, -130, 0, 60)
combatLbl.BackgroundTransparency = 1
combatLbl.Text = ""
combatLbl.TextColor3 = Color3.fromRGB(255, 90, 90)
combatLbl.Font = Enum.Font.GothamBold
combatLbl.TextSize = 18
combatLbl.TextStrokeTransparency = 0.3
combatLbl.ZIndex = 15
combatLbl.Parent = gui

-- ── 자동 공격 루프 (task.spawn - 0.6초마다 실행) ─────────────────────────
local AUTO_RANGE = 18  -- 탐색 범위

task.spawn(function()
    task.wait(2)  -- 캐릭터 및 데이터 로딩 대기
    while true do
        task.wait(ATTACK_CD)

        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        -- 가장 가까운 몬스터 탐색 (workspace 직접 자녀 AND 전체 자손 모두 검색)
        local nearest, nearDist = nil, AUTO_RANGE
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") then
                -- 모든 Part 중 MonsterId 속성이 있는 것 탐색
                for _, p in ipairs(obj:GetChildren()) do
                    if p:IsA("BasePart") then
                        local mId = p:GetAttribute("MonsterId")
                        if mId then
                            local d = (p.Position - root.Position).Magnitude
                            if d < nearDist then
                                nearDist = d
                                nearest = p
                            end
                        end
                    end
                end
            end
        end

        if nearest then
            combatLbl.Text = "⚔ 공격 중! (" .. math.floor(nearDist) .. "m)"
            combatLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
            spawnSlash(root)
            AttackMonster:FireServer(nearest:GetAttribute("MonsterId"))
            task.delay(1.5, function() combatLbl.Text = "" end)
        else
            combatLbl.Text = ""
        end
    end
end)

-- Auto-refresh farm panel every 5s when open
task.spawn(function()
    while true do
        task.wait(5)
        if farmOpen then
            local pd = GetPlayerData:InvokeServer()
            if pd then refreshPlots(pd) end
        end
    end
end)
