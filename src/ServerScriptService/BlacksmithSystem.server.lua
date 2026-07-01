-- 대장간: 대장장이 NPC 상호작용 + 장비 강화 처리
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerData  = require(ServerScriptService:WaitForChild("PlayerData"))
local EnhanceData = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("EnhanceData"))
local ShopData    = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("ShopData"))

local Remotes        = ReplicatedStorage:WaitForChild("Remotes")
local OpenBlacksmith = Remotes:WaitForChild("OpenBlacksmith")
local EnhanceWeapon  = Remotes:WaitForChild("EnhanceWeapon")
local EnhanceResult  = Remotes:WaitForChild("EnhanceResult")
local Notify         = Remotes:WaitForChild("Notification")
local UpdateHUD      = Remotes:WaitForChild("UpdateHUD")

-- 무기 표시 이름 조회
local function weaponName(id)
    for _, w in ipairs(ShopData.weapons) do
        if w.id == id then return w.name end
    end
    return id or "무기"
end

-- ── 대장장이 NPC ProximityPrompt 연결 ───────────────────────────────────────
local connected = false
local function tryConnect(desc)
    if connected then return end
    if desc.Name ~= "BlacksmithPrompt" then return end
    if not desc:IsA("ProximityPrompt") then return end
    connected = true
    desc.Triggered:Connect(function(player)
        OpenBlacksmith:FireClient(player)
    end)
    print("[Blacksmith] 대장장이 NPC 연결 완료 ✓")
end

workspace.DescendantAdded:Connect(tryConnect)
for _, desc in ipairs(workspace:GetDescendants()) do
    if connected then break end
    tryConnect(desc)
end

-- ── 강화 요청 처리 ──────────────────────────────────────────────────────────
EnhanceWeapon.OnServerEvent:Connect(function(player)
    local pd = PlayerData.Get(player) or PlayerData.Init(player)
    if not pd then return end

    -- 안전: 강화 필드 보정
    PlayerData.RecomputeWeaponDamage(pd)

    local star = pd.weaponStar or 0
    if star >= EnhanceData.MaxStar then
        Notify:FireClient(player, "이미 최고 강화 단계(★" .. EnhanceData.MaxStar .. ")입니다!", "error")
        return
    end

    local target = star + 1
    local cost   = EnhanceData.Cost(pd.weaponBaseDamage, target)
    if pd.gold < cost then
        Notify:FireClient(player, "골드 부족! (강화 비용: " .. cost .. "G, 보유: " .. pd.gold .. "G)", "error")
        return
    end

    -- 비용 차감
    pd.gold = pd.gold - cost

    -- 확률 판정
    local rate    = EnhanceData.SuccessRate(target)
    local roll    = math.random(1, 100)
    local success = roll <= rate

    if success then
        pd.weaponStar = target
        PlayerData.RecomputeWeaponDamage(pd)
        Notify:FireClient(player,
            "✨ 강화 성공! " .. weaponName(pd.weapon) .. " ★" .. target ..
            " (공격력 " .. pd.weaponDamage .. ")", "success")
    else
        -- 실패: 성급 유지, 비용만 소모 (강화 단계 하락/파괴 없음)
        Notify:FireClient(player,
            "💥 강화 실패... ★" .. star .. " 유지 (" .. cost .. "G 소모)", "error")
    end

    UpdateHUD:FireClient(player, { gold = pd.gold })

    -- 다음 강화 정보 미리 계산해서 클라이언트로 전달
    local nextStar = pd.weaponStar + 1
    EnhanceResult:FireClient(player, {
        success      = success,
        roll         = roll,
        rate         = rate,
        star         = pd.weaponStar,
        weaponDamage = pd.weaponDamage,
        gold         = pd.gold,
        maxed        = pd.weaponStar >= EnhanceData.MaxStar,
        nextRate     = EnhanceData.SuccessRate(nextStar),
        nextCost     = EnhanceData.Cost(pd.weaponBaseDamage, nextStar),
    })
end)
