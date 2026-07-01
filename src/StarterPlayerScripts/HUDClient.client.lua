local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")

local player  = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local UpdateHUD    = Remotes:WaitForChild("UpdateHUD")
local LevelUp      = Remotes:WaitForChild("LevelUp")
local Notification = Remotes:WaitForChild("Notification")
local MonsterDied  = Remotes:WaitForChild("MonsterDied")
local CropReady    = Remotes:WaitForChild("CropReady")

local gui = Instance.new("ScreenGui")
gui.Name         = "HUD"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player.PlayerGui

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
end

local function makeLabel(parent, text, size, color, bold, xAlign)
    local l = Instance.new("TextLabel")
    l.Size = size or UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or Color3.new(1,1,1)
    l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextSize = 14
    l.TextXAlignment = xAlign or Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

-- ── STATS PANEL (top-left) ──────────────────────────────────────────────────
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 268, 0, 158)
panel.Position = UDim2.new(0, 10, 0, 10)
panel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
panel.BackgroundTransparency = 0.22
panel.BorderSizePixel = 0
panel.Parent = gui
makeCorner(panel, 10)
local _ps = Instance.new("UIStroke") _ps.Thickness=1 _ps.Color=Color3.fromRGB(80,80,120) _ps.Parent=panel

-- 닉네임
local nameLbl = makeLabel(panel, "👤 " .. player.Name, UDim2.new(1,-10,0,22), Color3.fromRGB(255,255,180), true)
nameLbl.Position = UDim2.new(0,5,0,5)
nameLbl.TextSize = 13

local goldLbl   = makeLabel(panel, "💰 골드: 100G",    UDim2.new(1,-10,0,22), Color3.fromRGB(255,215,0),  true)
goldLbl.Position = UDim2.new(0,5,0,29)

local levelLbl  = makeLabel(panel, "⭐ 레벨: 1",       UDim2.new(1,-10,0,22), Color3.fromRGB(130,210,255), true)
levelLbl.Position = UDim2.new(0,5,0,52)

local function makeBar(parent, yOff, fillColor, iconText)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,-10,0,14)
    bg.Position = UDim2.new(0,5,0,yOff)
    bg.BackgroundColor3 = Color3.fromRGB(40,40,60)
    bg.BorderSizePixel = 0
    bg.Parent = parent
    makeCorner(bg, 7)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(1,0,1,0)
    fill.BackgroundColor3 = fillColor
    fill.BorderSizePixel = 0
    fill.Parent = bg
    makeCorner(fill, 7)

    local lbl = makeLabel(bg, iconText, UDim2.new(1,0,1,0), Color3.new(1,1,1), false, Enum.TextXAlignment.Center)
    lbl.TextSize = 10
    lbl.ZIndex = 2

    return fill, lbl
end

local xpFill,  xpLbl  = makeBar(panel,  80, Color3.fromRGB(100,200,255), "0 / 100 XP")
local hpFill,  hpLbl  = makeBar(panel, 100, Color3.fromRGB(240,70,70),   "❤ 100 / 100")
local hunFill, hunLbl = makeBar(panel, 120, Color3.fromRGB(255,160,30),  "🍖 100 / 100")

-- ── STATE CACHE ─────────────────────────────────────────────────────────────
local cache = { gold=100, level=1, xp=0, xpRequired=100, hunger=100, maxHunger=100 }

-- Update health bar every frame
local char = player.Character or player.CharacterAdded:Wait()
RunService.Heartbeat:Connect(function()
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then
        local r = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        hpFill.Size = UDim2.new(r, 0, 1, 0)
        hpFill.BackgroundColor3 = r < 0.3 and Color3.fromRGB(200,30,30) or Color3.fromRGB(240,70,70)
        hpLbl.Text = "❤ " .. math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
    end
end)
player.CharacterAdded:Connect(function(c) char = c end)

UpdateHUD.OnClientEvent:Connect(function(data)
    if data.gold  then
        cache.gold = data.gold
        goldLbl.Text = "💰 골드: " .. data.gold .. "G"
    end
    if data.level then
        cache.level = data.level
        levelLbl.Text = "⭐ 레벨: " .. data.level .. (data.level==100 and " 👑MAX" or "")
    end
    if data.xp and data.xpRequired then
        cache.xp = data.xp ; cache.xpRequired = data.xpRequired
        local r = math.clamp(data.xp / data.xpRequired, 0, 1)
        TweenService:Create(xpFill, TweenInfo.new(0.4), {Size=UDim2.new(r,0,1,0)}):Play()
        xpLbl.Text = data.xp .. " / " .. data.xpRequired .. " XP"
    end
    if data.hunger then
        cache.hunger = data.hunger
        local r = math.clamp(data.hunger / (cache.maxHunger or 100), 0, 1)
        hunFill.Size = UDim2.new(r, 0, 1, 0)
        hunFill.BackgroundColor3 = r < 0.3 and Color3.fromRGB(200,50,50) or Color3.fromRGB(255,160,30)
        hunLbl.Text = "🍖 " .. data.hunger .. " / " .. (cache.maxHunger or 100)
    end
end)

-- ── LEVEL UP BANNER ─────────────────────────────────────────────────────────
LevelUp.OnClientEvent:Connect(function(data)
    -- Update cache
    cache.level = data.level
    levelLbl.Text = "⭐ 레벨: " .. data.level
    if data.xp and data.xpRequired then
        local r = math.clamp(data.xp / data.xpRequired, 0, 1)
        xpFill.Size = UDim2.new(r, 0, 1, 0)
        xpLbl.Text = data.xp .. " / " .. data.xpRequired .. " XP"
    end

    local banner = Instance.new("Frame")
    banner.Size = UDim2.new(0, 420, 0, 110)
    banner.Position = UDim2.new(0.5, -210, 0.35, 0)
    banner.BackgroundColor3 = Color3.fromRGB(255, 210, 0)
    banner.BackgroundTransparency = 0.05
    banner.BorderSizePixel = 0
    banner.ZIndex = 20
    banner.Parent = gui
    makeCorner(banner, 14)

    local t1 = makeLabel(banner, "🎉 레벨 업!  Lv." .. data.level, UDim2.new(1,0,0.55,0), Color3.fromRGB(40,20,0), true, Enum.TextXAlignment.Center)
    t1.TextSize = 30 ; t1.ZIndex = 21

    if data.milestone then
        local t2 = makeLabel(banner, data.milestone, UDim2.new(1,0,0.45,0), Color3.fromRGB(60,30,0), false, Enum.TextXAlignment.Center)
        t2.Position = UDim2.new(0,0,0.55,0)
        t2.TextSize = 16 ; t2.ZIndex = 21
    end

    TweenService:Create(banner, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5,-210, 0.28, 0)
    }):Play()

    task.delay(3.2, function()
        TweenService:Create(banner, TweenInfo.new(0.4), {
            Position = UDim2.new(0.5,-210, 0.15, 0),
            BackgroundTransparency = 1,
        }):Play()
        task.wait(0.45)
        banner:Destroy()
    end)
end)

-- ── NOTIFICATION SYSTEM ──────────────────────────────────────────────────────
local notifs = {}
local COLORS = {
    success = Color3.fromRGB(40,185,90),
    error   = Color3.fromRGB(210,50,50),
    info    = Color3.fromRGB(80,160,240),
    combat  = Color3.fromRGB(240,110,30),
    warning = Color3.fromRGB(240,190,0),
}

local function showNotif(msg, nType)
    local color = COLORS[nType] or COLORS.info
    local slot  = #notifs + 1

    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 310, 0, 42)
    f.Position = UDim2.new(1, 10, 1, -(50 + (slot-1)*48))
    f.BackgroundColor3 = color
    f.BackgroundTransparency = 0.12
    f.BorderSizePixel = 0
    f.ZIndex = 10
    f.Parent = gui
    makeCorner(f, 8)

    local l = makeLabel(f, msg, UDim2.new(1,-12,1,0), Color3.new(1,1,1), false)
    l.Position = UDim2.new(0,6,0,0)
    l.TextWrapped = true
    l.TextSize = 13
    l.ZIndex = 11

    TweenService:Create(f, TweenInfo.new(0.3), {
        Position = UDim2.new(1,-320, 1, -(50+(slot-1)*48))
    }):Play()

    table.insert(notifs, f)

    task.delay(3.2, function()
        TweenService:Create(f, TweenInfo.new(0.3), {
            Position = UDim2.new(1, 10, f.Position.Y.Scale, f.Position.Y.Offset),
            BackgroundTransparency = 1,
        }):Play()
        task.wait(0.35)
        local idx = table.find(notifs, f)
        if idx then table.remove(notifs, idx) end
        f:Destroy()
    end)
end

Notification.OnClientEvent:Connect(showNotif)

MonsterDied.OnClientEvent:Connect(function(monType, monName, gold, xp)
    showNotif("⚔ " .. monName .. " 처치! +" .. gold .. "G  +" .. xp .. "XP", "combat")
end)

CropReady.OnClientEvent:Connect(function(plotId, cropName)
    showNotif("🌾 " .. cropName .. " 수확 가능! (" .. plotId .. "번 농지)", "info")
end)

-- ── 인벤토리 패널 [I키] ──────────────────────────────────────────────────
local CropData = require(game:GetService("ReplicatedStorage"):WaitForChild("GameData"):WaitForChild("CropData"))
local ShopData = require(game:GetService("ReplicatedStorage"):WaitForChild("GameData"):WaitForChild("ShopData"))
local GetPlayerData = Remotes:WaitForChild("GetPlayerData")

local function weaponDisplayName(id)
    for _, w in ipairs(ShopData.weapons) do
        if w.id == id then return w.name end
    end
    return id or "없음"
end

local invPanel = Instance.new("Frame")
invPanel.Name   = "InventoryPanel"
invPanel.Size   = UDim2.new(0, 340, 0, 460)
invPanel.Position = UDim2.new(0.5,-170,0.5,-230)
invPanel.BackgroundColor3 = Color3.fromRGB(18,18,30)
invPanel.BackgroundTransparency = 0.05
invPanel.BorderSizePixel = 0
invPanel.Visible = false
invPanel.ZIndex  = 25
invPanel.Parent  = gui
local _ic = Instance.new("UICorner") _ic.CornerRadius = UDim.new(0,14) _ic.Parent = invPanel
local _is = Instance.new("UIStroke") _is.Thickness = 2 _is.Color = Color3.fromRGB(150,100,255) _is.Parent = invPanel

local invTitle = Instance.new("TextLabel")
invTitle.Size = UDim2.new(1,0,0,44)
invTitle.BackgroundColor3 = Color3.fromRGB(50,30,80)
invTitle.BackgroundTransparency = 0.1
invTitle.BorderSizePixel = 0
invTitle.Text = "🎒 인벤토리  [I]"
invTitle.TextColor3 = Color3.fromRGB(210,180,255)
invTitle.Font = Enum.Font.GothamBold
invTitle.TextSize = 18
invTitle.ZIndex = 26
invTitle.Parent = invPanel
local _itc = Instance.new("UICorner") _itc.CornerRadius = UDim.new(0,14) _itc.Parent = invTitle

-- 닫기 버튼
local _iclose = Instance.new("TextButton")
_iclose.Size = UDim2.new(0,38,0,30)
_iclose.Position = UDim2.new(1,-44,0,7)
_iclose.BackgroundColor3 = Color3.fromRGB(180,50,50)
_iclose.BackgroundTransparency = 0.15
_iclose.Text = "✕"
_iclose.TextColor3 = Color3.new(1,1,1)
_iclose.Font = Enum.Font.GothamBold
_iclose.TextSize = 15
_iclose.ZIndex = 27
_iclose.Parent = invPanel
Instance.new("UICorner",_iclose).CornerRadius = UDim.new(0,6)
_iclose.MouseButton1Click:Connect(function() invPanel.Visible = false end)

-- 무기 섹션
local weaponBox = Instance.new("Frame")
weaponBox.Size = UDim2.new(1,-16,0,60)
weaponBox.Position = UDim2.new(0,8,0,52)
weaponBox.BackgroundColor3 = Color3.fromRGB(60,30,90)
weaponBox.BackgroundTransparency = 0.15
weaponBox.BorderSizePixel = 0
weaponBox.ZIndex = 26
weaponBox.Parent = invPanel
Instance.new("UICorner",weaponBox).CornerRadius = UDim.new(0,8)

local weaponLbl = Instance.new("TextLabel")
weaponLbl.Name = "WeaponLbl"
weaponLbl.Size = UDim2.new(1,-10,1,0)
weaponLbl.Position = UDim2.new(0,10,0,0)
weaponLbl.BackgroundTransparency = 1
weaponLbl.Text = "⚔ 장착 무기: -"
weaponLbl.TextColor3 = Color3.fromRGB(220,190,255)
weaponLbl.Font = Enum.Font.GothamBold
weaponLbl.TextSize = 15
weaponLbl.TextXAlignment = Enum.TextXAlignment.Left
weaponLbl.TextWrapped = true
weaponLbl.ZIndex = 27
weaponLbl.Parent = weaponBox

-- 작물 섹션 헤더
local cropHdr = Instance.new("TextLabel")
cropHdr.Size = UDim2.new(1,-16,0,26)
cropHdr.Position = UDim2.new(0,8,0,120)
cropHdr.BackgroundTransparency = 1
cropHdr.Text = "📦 수확한 작물"
cropHdr.TextColor3 = Color3.fromRGB(160,255,140)
cropHdr.Font = Enum.Font.GothamBold
cropHdr.TextSize = 14
cropHdr.TextXAlignment = Enum.TextXAlignment.Left
cropHdr.ZIndex = 26
cropHdr.Parent = invPanel

local cropScroll = Instance.new("ScrollingFrame")
cropScroll.Size = UDim2.new(1,-16,1,-158)
cropScroll.Position = UDim2.new(0,8,0,150)
cropScroll.BackgroundTransparency = 1
cropScroll.ScrollBarThickness = 5
cropScroll.ZIndex = 26
cropScroll.Parent = invPanel
local _cl = Instance.new("UIListLayout") _cl.Padding = UDim.new(0,4) _cl.Parent = cropScroll

local function refreshInv()
    for _, c in ipairs(cropScroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    local pd = GetPlayerData:InvokeServer()
    if not pd then return end

    local starTxt = (pd.weaponStar and pd.weaponStar > 0) and (" ★" .. pd.weaponStar) or ""
    weaponLbl.Text = "⚔ 장착 무기: " .. weaponDisplayName(pd.weapon) .. starTxt ..
                     "  │  공격력: " .. (pd.weaponDamage or 0)

    local hasItem = false
    if pd.inventory then
        for cType, cnt in pairs(pd.inventory) do
            if cnt and cnt > 0 and CropData[cType] then
                hasItem = true
                local crop = CropData[cType]
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1,0,0,48)
                row.BackgroundColor3 = Color3.fromRGB(25,50,20)
                row.BackgroundTransparency = 0.2
                row.BorderSizePixel = 0
                row.ZIndex = 27
                row.Parent = cropScroll
                Instance.new("UICorner",row).CornerRadius = UDim.new(0,7)

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1,-10,1,0)
                lbl.Position = UDim2.new(0,8,0,0)
                lbl.BackgroundTransparency = 1
                lbl.Text = "🌾 " .. crop.name .. "  ×" .. cnt ..
                           "   │   " .. crop.sellPrice .. "G/개   합계: " .. cnt*crop.sellPrice .. "G"
                lbl.TextColor3 = Color3.fromRGB(200,255,170)
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 13
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.ZIndex = 28
                lbl.Parent = row
            end
        end
    end

    if not hasItem then
        local el = Instance.new("TextLabel")
        el.Size = UDim2.new(1,0,0,40)
        el.BackgroundTransparency = 1
        el.Text = "인벤토리가 비어 있습니다"
        el.TextColor3 = Color3.fromRGB(130,130,130)
        el.Font = Enum.Font.Gotham
        el.TextSize = 14
        el.ZIndex = 27
        el.Parent = cropScroll
    end
    cropScroll.CanvasSize = UDim2.new(0,0,0, hasItem and (#cropScroll:GetChildren()-1)*52 or 40)
end

local invOpen = false
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.I then
        invOpen = not invOpen
        invPanel.Visible = invOpen
        if invOpen then task.spawn(refreshInv) end
    end
end)

-- 단축키 버튼 (HUD 패널 아래)
local invShortcut = Instance.new("TextButton")
invShortcut.Size = UDim2.new(0,108,0,32)
invShortcut.Position = UDim2.new(0,10,0,148)
invShortcut.BackgroundColor3 = Color3.fromRGB(50,30,80)
invShortcut.BackgroundTransparency = 0.2
invShortcut.BorderSizePixel = 0
invShortcut.Text = "🎒 인벤 [I]"
invShortcut.TextColor3 = Color3.fromRGB(200,170,255)
invShortcut.Font = Enum.Font.GothamBold
invShortcut.TextSize = 12
invShortcut.ZIndex = 5
invShortcut.Parent = gui
Instance.new("UICorner",invShortcut).CornerRadius = UDim.new(0,6)
invShortcut.MouseButton1Click:Connect(function()
    invOpen = not invOpen
    invPanel.Visible = invOpen
    if invOpen then task.spawn(refreshInv) end
end)
