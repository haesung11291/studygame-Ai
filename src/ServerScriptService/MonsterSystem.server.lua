local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerData    = require(ServerScriptService:WaitForChild("PlayerData"))
local MonsterData   = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("MonsterData"))
local LevelData     = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("LevelData"))
local Remotes       = ReplicatedStorage:WaitForChild("Remotes")

local AttackMonster = Remotes:WaitForChild("AttackMonster")
local MonsterDied   = Remotes:WaitForChild("MonsterDied")
local Notify        = Remotes:WaitForChild("Notification")
local UpdateHUD     = Remotes:WaitForChild("UpdateHUD")

local HUNT_CENTER    = Vector3.new(600, 0, 0)
local MAX_MONSTERS   = 15
local SPAWN_RADIUS   = 110
local monsters       = {}
local idCounter      = 0

local MONSTER_COLORS = {
    Slime      = BrickColor.new("Bright green"),
    Zombie     = BrickColor.new("Moss"),
    Goblin     = BrickColor.new("Lime green"),
    Skeleton   = BrickColor.new("White"),
    Orc        = BrickColor.new("Olive"),
    Troll      = BrickColor.new("Sand green"),
    Vampire    = BrickColor.new("Magenta"),
    DarkKnight = BrickColor.new("Black"),
    Dragon     = BrickColor.new("Bright red"),
}

local function getAvgLevel()
    local list = Players:GetPlayers()
    if #list == 0 then return 1 end
    local sum = 0
    for _, p in ipairs(list) do
        local pd = PlayerData.Get(p)
        sum = sum + (pd and pd.level or 1)
    end
    return sum / #list
end

local function pickType(avgLevel)
    local pool = {}
    for t, d in pairs(MonsterData) do
        if d.levelRequired <= avgLevel then
            for _ = 1, d.spawnWeight do table.insert(pool, t) end
        end
    end
    if #pool == 0 then return "Slime" end
    return pool[math.random(#pool)]
end

local function spawnMonster()
    if #monsters >= MAX_MONSTERS then return end

    local avgLevel = getAvgLevel()
    local monType  = pickType(avgLevel)
    local data     = MonsterData[monType]

    local angle = math.random() * math.pi * 2
    local dist  = math.random(30, SPAWN_RADIUS)
    local pos   = HUNT_CENTER + Vector3.new(math.cos(angle) * dist, 5, math.sin(angle) * dist)

    local model = Instance.new("Model")
    model.Name  = monType

    local body = Instance.new("Part")
    body.Name        = "HumanoidRootPart"
    body.Size        = Vector3.new(2, 3, 1)
    body.CFrame      = CFrame.new(pos)
    body.BrickColor  = MONSTER_COLORS[monType] or BrickColor.new("Bright red")
    body.Material    = Enum.Material.SmoothPlastic
    body.Parent      = model

    local head = Instance.new("Part")
    head.Name       = "Head"
    head.Size       = Vector3.new(1.5, 1.5, 1.5)
    head.CFrame     = CFrame.new(pos + Vector3.new(0, 2.5, 0))
    head.BrickColor = MONSTER_COLORS[monType] or BrickColor.new("Bright red")
    head.Material   = Enum.Material.SmoothPlastic
    head.Parent     = model

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = body
    weld.Part1 = head
    weld.Parent = body

    local gui = Instance.new("BillboardGui")
    gui.Size         = UDim2.new(0, 200, 0, 64)
    gui.StudsOffset  = Vector3.new(0, 5, 0)
    gui.AlwaysOnTop  = true
    gui.Parent       = body

    local label = Instance.new("TextLabel")
    label.Size                 = UDim2.new(1, 0, 0, 28)
    label.BackgroundTransparency = 1
    label.TextColor3           = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.1
    label.Font                 = Enum.Font.GothamBold
    label.TextScaled           = true
    label.Text                 = data.name
    label.Parent               = gui

    -- HP 배경 바
    local hpBg = Instance.new("Frame")
    hpBg.Size            = UDim2.new(1, -10, 0, 20)
    hpBg.Position        = UDim2.new(0, 5, 0, 32)
    hpBg.BackgroundColor3= Color3.fromRGB(60, 12, 12)
    hpBg.BorderSizePixel = 0
    hpBg.Parent          = gui
    local hpBgC = Instance.new("UICorner") hpBgC.CornerRadius = UDim.new(0,5) hpBgC.Parent = hpBg

    -- HP 채움 바
    local hpFill = Instance.new("Frame")
    hpFill.Size            = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3= Color3.fromRGB(60, 210, 60)
    hpFill.BorderSizePixel = 0
    hpFill.Parent          = hpBg
    local hpFC = Instance.new("UICorner") hpFC.CornerRadius = UDim.new(0,5) hpFC.Parent = hpFill

    -- HP 텍스트
    local hpTxt = Instance.new("TextLabel")
    hpTxt.Size                 = UDim2.new(1, 0, 1, 0)
    hpTxt.BackgroundTransparency= 1
    hpTxt.Text                 = "❤ " .. data.hp .. " / " .. data.hp
    hpTxt.TextColor3           = Color3.new(1, 1, 1)
    hpTxt.TextStrokeTransparency= 0.2
    hpTxt.Font                 = Enum.Font.GothamBold
    hpTxt.TextScaled           = true
    hpTxt.ZIndex               = 2
    hpTxt.Parent               = hpBg

    local hum = Instance.new("Humanoid")
    hum.MaxHealth  = data.hp
    hum.Health     = data.hp
    hum.WalkSpeed  = data.speed
    hum.DisplayName = ""
    hum.Parent     = model

    model.PrimaryPart = body
    model.Parent      = workspace

    idCounter += 1
    local mId = tostring(idCounter)
    body:SetAttribute("MonsterId", mId)

    local mon = {
        id        = mId,
        model     = model,
        body      = body,
        hum       = hum,
        label     = label,
        hpFill    = hpFill,
        hpTxt     = hpTxt,
        maxHp     = data.hp,
        data      = data,
        monType   = monType,
        currentHp = data.hp,
        alive     = true,
    }
    monsters[mId] = mon

    task.spawn(function()
        while mon.alive and model.Parent do
            local nearest, nearDist, nearChar = nil, 45, nil
            for _, p in ipairs(Players:GetPlayers()) do
                local c = p.Character
                if c and c:FindFirstChild("HumanoidRootPart") then
                    local d = (c.HumanoidRootPart.Position - body.Position).Magnitude
                    if d < nearDist then
                        nearDist  = d
                        nearest   = p
                        nearChar  = c
                    end
                end
            end

            if nearChar then
                hum:MoveTo(nearChar.HumanoidRootPart.Position)
                if nearDist < 5 then
                    local pd = PlayerData.Get(nearest)
                    local tHum = nearChar:FindFirstChild("Humanoid")
                    if tHum and tHum.Health > 0 then
                        local dmg = math.max(1, data.damage - (pd and pd.stats.defense or 0))
                        tHum:TakeDamage(dmg)
                    end
                    task.wait(1.5)
                else
                    task.wait(0.2)
                end
            else
                local wx = body.Position.X + math.random(-15, 15)
                local wz = body.Position.Z + math.random(-15, 15)
                hum:MoveTo(Vector3.new(wx, body.Position.Y, wz))
                task.wait(3)
            end
        end
    end)
end

AttackMonster.OnServerEvent:Connect(function(player, monsterId)
    local pd = PlayerData.Get(player)
    if not pd then
        pd = PlayerData.Init(player)  -- fallback: 데이터 즉시 초기화
    end
    if not pd then return end

    local mon = monsters[monsterId]
    if not mon then
        -- 이미 죽은 몬스터 → 조용히 무시
        return
    end
    if not mon.alive then return end

    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    -- 거리 체크 완화 (클라이언트 35스터드 탐색 + 여유)
    local dist = (mon.body.Position - char.HumanoidRootPart.Position).Magnitude
    if dist > 28 then
        Notify:FireClient(player, "너무 멀리 있습니다! (" .. math.floor(dist) .. "스터드)", "error")
        return
    end

    local dmg = pd.weaponDamage + pd.stats.attack + math.random(1, 8)
    mon.currentHp = mon.currentHp - dmg
    mon.hum.Health = math.max(0, mon.currentHp)

    -- HP 바 시각 업데이트
    local ratio = math.clamp(mon.currentHp / mon.maxHp, 0, 1)
    if mon.hpFill then
        mon.hpFill.Size = UDim2.new(ratio, 0, 1, 0)
        mon.hpFill.BackgroundColor3 = ratio > 0.5
            and Color3.fromRGB(60, 210, 60)
            or (ratio > 0.25 and Color3.fromRGB(230, 180, 0) or Color3.fromRGB(210, 45, 45))
    end
    if mon.hpTxt then
        mon.hpTxt.Text = "❤ " .. math.max(0, math.floor(mon.currentHp)) .. " / " .. mon.maxHp
    end

    Notify:FireClient(player, "⚔ -" .. dmg .. " 데미지!", "combat")

    if mon.currentHp <= 0 then
        mon.alive = false

        for _, p in ipairs(Players:GetPlayers()) do
            local pChar = p.Character
            if pChar and pChar:FindFirstChild("HumanoidRootPart") then
                local pDist = (pChar.HumanoidRootPart.Position - mon.body.Position).Magnitude
                if pDist <= 60 then
                    local pData = PlayerData.Get(p)
                    if pData then
                        local gold = math.floor(mon.data.reward * (p == player and 1.5 or 1.0))
                        pData.gold = pData.gold + gold
                        PlayerData.AddXP(p, mon.data.xp)

                        MonsterDied:FireClient(p, mon.monType, mon.data.name, gold, mon.data.xp)
                        UpdateHUD:FireClient(p, {
                            gold       = pData.gold,
                            xp         = pData.xp,
                            level      = pData.level,
                            xpRequired = LevelData.XPRequired(pData.level),
                        })
                    end
                end
            end
        end

        monsters[monsterId] = nil
        mon.model:Destroy()
    end
end)

task.spawn(function()
    task.wait(5)
    for _ = 1, 5 do spawnMonster() task.wait(0.5) end
    while true do
        task.wait(4)   -- 젠 속도 3배 (기존 12초 → 4초)
        spawnMonster()
    end
end)
