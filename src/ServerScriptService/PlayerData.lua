local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LevelData   = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("LevelData"))
local EnhanceData = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("EnhanceData"))

local PlayerData = {}
local sessions = {}

-- 강화 성급을 반영해 실제 전투용 공격력(weaponDamage)을 다시 계산
function PlayerData.RecomputeWeaponDamage(pd)
    if not pd then return end
    local base = pd.weaponBaseDamage or pd.weaponDamage or 10
    local star = pd.weaponStar or 0
    pd.weaponBaseDamage = base
    pd.weaponStar       = star
    pd.weaponDamage     = base + EnhanceData.Bonus(base, star)
end

local function getRemote(name)
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    return r and r:FindFirstChild(name)
end

function PlayerData.Init(player)
    sessions[player.UserId] = {
        gold        = 100,
        level       = 1,
        xp          = 0,
        weapon          = "WoodSword",
        weaponBaseDamage= 10,
        weaponStar      = 0,
        weaponDamage    = 10,
        hunger      = 100,
        maxHunger   = 100,
        maxHealth   = 100,
        plots       = 2,
        inventory   = {},
        crops       = {},
        stats       = LevelData.GetStats(1),
        title       = "",
    }
    return sessions[player.UserId]
end

function PlayerData.Get(player)
    return sessions[player.UserId]
end

function PlayerData.Set(player, saved)
    if not sessions[player.UserId] then PlayerData.Init(player) end
    local pd = sessions[player.UserId]
    for k, v in pairs(saved) do pd[k] = v end
    -- 구버전 세이브 호환: 강화 필드가 없으면 현재 무기 공격력을 기본값(0★)으로 간주
    if saved.weaponBaseDamage == nil then
        pd.weaponBaseDamage = pd.weaponDamage or 10
        pd.weaponStar       = saved.weaponStar or 0
    end
    PlayerData.RecomputeWeaponDamage(pd)
end

function PlayerData.Remove(player)
    sessions[player.UserId] = nil
end

function PlayerData.GetSaveData(player)
    local pd = sessions[player.UserId]
    if not pd then return nil end
    return {
        gold         = pd.gold,
        level        = pd.level,
        xp           = pd.xp,
        weapon           = pd.weapon,
        weaponBaseDamage = pd.weaponBaseDamage,
        weaponStar       = pd.weaponStar,
        weaponDamage     = pd.weaponDamage,
        maxHealth        = pd.maxHealth,
        plots        = pd.plots,
        inventory    = pd.inventory,
        stats        = pd.stats,
        title        = pd.title,
    }
end

function PlayerData.AddXP(player, amount)
    local pd = sessions[player.UserId]
    if not pd or pd.level >= LevelData.MaxLevel then return end

    pd.xp = pd.xp + amount
    local leveled = false
    local milestone = nil

    while pd.level < LevelData.MaxLevel and pd.xp >= LevelData.XPRequired(pd.level) do
        pd.xp     = pd.xp - LevelData.XPRequired(pd.level)
        pd.level  = pd.level + 1
        pd.stats  = LevelData.GetStats(pd.level)
        pd.maxHealth = 100 + pd.level * 5
        leveled   = true

        if LevelData.Milestones[pd.level] then
            milestone = LevelData.Milestones[pd.level]
        end
        if pd.level == 100 then pd.title = "전설" end

        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.MaxHealth = pd.maxHealth
                hum.Health = math.min(hum.Health + 20, pd.maxHealth)
            end
        end
    end

    if leveled then
        local remote = getRemote("LevelUp")
        if remote then
            remote:FireClient(player, {
                level     = pd.level,
                stats     = pd.stats,
                milestone = milestone,
                maxHealth = pd.maxHealth,
                xp        = pd.xp,
                xpRequired = LevelData.XPRequired(pd.level),
            })
        end
    end

    return leveled
end

return PlayerData
