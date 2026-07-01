-- 플레이어 무기에 맞는 Tool을 백팩에 제공
local Players         = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local PlayerData      = require(ServerScriptService:WaitForChild("PlayerData"))

local WEAPON_CONFIGS = {
    WoodSword   = { name="🪵 나무 검",   color="Reddish brown",    mat=Enum.Material.Wood,  neon=false },
    IronSword   = { name="⚔ 철 검",     color="Medium stone grey", mat=Enum.Material.Metal, neon=false },
    FireSword   = { name="🔥 화염 검",   color="Bright red",       mat=Enum.Material.Neon,  neon=true  },
    GoldSword   = { name="✨ 황금 검",   color="Bright yellow",    mat=Enum.Material.Metal, neon=false },
    LegendSword = { name="💎 전설 검",   color="Cyan",             mat=Enum.Material.Neon,  neon=true  },
}

local function giveWeaponTool(player)
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then return end

    local pd = PlayerData.Get(player)
    if not pd then return end

    local weapType = pd.weapon or "WoodSword"
    local cfg      = WEAPON_CONFIGS[weapType] or WEAPON_CONFIGS.WoodSword
    local star     = pd.weaponStar or 0

    -- 기존 무기 도구 제거
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") and item:GetAttribute("IsWeapon") then item:Destroy() end
    end
    local char = player.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and item:GetAttribute("IsWeapon") then item:Destroy() end
        end
    end

    -- Tool 생성
    local tool = Instance.new("Tool")
    tool.Name         = cfg.name .. (star > 0 and (" ★" .. star) or "")
    tool.CanBeDropped = false
    tool.RequiresHandle = true
    tool:SetAttribute("IsWeapon", true)

    -- 손잡이 (Handle)
    local handle = Instance.new("Part")
    handle.Name      = "Handle"
    handle.Size      = Vector3.new(0.35, 2.8, 0.35)
    handle.BrickColor = BrickColor.new(cfg.color)
    handle.Material  = cfg.mat
    handle.CastShadow = true
    handle.Parent    = tool

    if cfg.neon then
        local light = Instance.new("PointLight")
        light.Brightness = 3
        light.Range      = 10
        light.Color      = BrickColor.new(cfg.color).Color
        light.Parent     = handle
    end

    -- 가드 (코등이)
    local guard = Instance.new("Part")
    guard.Size      = Vector3.new(1.4, 0.3, 0.35)
    guard.BrickColor = BrickColor.new(cfg.color)
    guard.Material  = cfg.mat
    guard.CFrame    = handle.CFrame * CFrame.new(0, 0.8, 0)
    guard.Parent    = tool
    local gw = Instance.new("WeldConstraint")
    gw.Part0 = handle; gw.Part1 = guard; gw.Parent = handle

    -- 칼날 (Blade)
    local blade = Instance.new("Part")
    blade.Size      = Vector3.new(0.25, 2.2, 0.25)
    blade.BrickColor = BrickColor.new(cfg.color)
    blade.Material  = cfg.neon and Enum.Material.Neon or Enum.Material.SmoothPlastic
    blade.Transparency = cfg.neon and 0.15 or 0
    blade.CFrame    = handle.CFrame * CFrame.new(0, 2.5, 0)
    blade.Parent    = tool
    local bw = Instance.new("WeldConstraint")
    bw.Part0 = handle; bw.Part1 = blade; bw.Parent = handle

    -- 강화 발광 효과: 성급이 높을수록 칼날이 더 환하게 빛남
    if star > 0 then
        blade.Material = Enum.Material.Neon
        blade.Color    = Color3.fromRGB(255, 230, 120):Lerp(Color3.fromRGB(255, 80, 40), math.min(star/10, 1))
        local glow = Instance.new("PointLight")
        glow.Brightness = 1 + star * 0.7
        glow.Range      = 6 + star
        glow.Color      = blade.Color
        glow.Parent     = blade
        if star >= 7 then
            local sp = Instance.new("Sparkles")
            sp.SparkleColor = blade.Color
            sp.Parent = blade
        end
    end

    tool.Parent = backpack
end

local function setupPlayer(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        giveWeaponTool(player)
    end)

    -- 무기/강화 변경 감지 (폴링)
    task.spawn(function()
        local lastKey = nil
        while player.Parent do
            task.wait(1.5)
            local pd = PlayerData.Get(player)
            if pd then
                local key = (pd.weapon or "") .. "_" .. (pd.weaponStar or 0)
                if key ~= lastKey then
                    lastKey = key
                    if player.Character then
                        giveWeaponTool(player)
                    end
                end
            end
        end
    end)
end

Players.PlayerAdded:Connect(setupPlayer)
for _, p in ipairs(Players:GetPlayers()) do
    setupPlayer(p)
end
