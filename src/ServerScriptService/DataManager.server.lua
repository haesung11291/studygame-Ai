local Players             = game:GetService("Players")
local DataStoreService    = game:GetService("DataStoreService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerData = require(ServerScriptService:WaitForChild("PlayerData"))
local LevelData  = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("LevelData"))
local Remotes    = ReplicatedStorage:WaitForChild("Remotes")
local store      = DataStoreService:GetDataStore("FarmHuntV1")

-- GetPlayerData RemoteFunction은 전역 1회 설정 (항상 사용 가능하도록)
Remotes:WaitForChild("GetPlayerData").OnServerInvoke = function(p)
    local d = PlayerData.Get(p)
    if not d then return nil end
    return {
        gold         = d.gold,
        level        = d.level,
        xp           = d.xp,
        xpRequired   = LevelData.XPRequired(d.level),
        hunger       = d.hunger,
        maxHunger    = d.maxHunger,
        plots        = d.plots,
        inventory    = d.inventory,
        crops        = d.crops,
        weapon           = d.weapon,
        weaponBaseDamage = d.weaponBaseDamage,
        weaponStar       = d.weaponStar,
        weaponDamage     = d.weaponDamage,
        stats            = d.stats,
        title        = d.title,
    }
end

local function applyCharacterHealth(player, pd)
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum.MaxHealth = pd.maxHealth
        hum.Health    = pd.maxHealth
    end
end

local function onPlayerAdded(player)
    -- 중복 초기화 방지
    if PlayerData.Get(player) then return end

    local pd = PlayerData.Init(player)

    local ok, saved = pcall(function()
        return store:GetAsync("u_" .. player.UserId)
    end)
    if ok and saved then
        PlayerData.Set(player, saved)
        pd = PlayerData.Get(player)
    end

    task.spawn(function()
        local char = player.Character or player.CharacterAdded:Wait()
        applyCharacterHealth(player, pd)
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            local fresh = PlayerData.Get(player)
            if fresh then applyCharacterHealth(player, fresh) end
        end)
    end)

    task.wait(2)
    local updateHUD = Remotes:WaitForChild("UpdateHUD")
    local fresh = PlayerData.Get(player)
    if fresh then
        updateHUD:FireClient(player, {
            gold       = fresh.gold,
            level      = fresh.level,
            xp         = fresh.xp,
            xpRequired = LevelData.XPRequired(fresh.level),
            hunger     = fresh.hunger,
            plots      = fresh.plots,
        })
    end
end

local function savePlayer(player)
    local data = PlayerData.GetSaveData(player)
    if not data then return end
    pcall(function()
        store:SetAsync("u_" .. player.UserId, data)
    end)
    PlayerData.Remove(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(savePlayer)

-- Studio Play 모드에서 PlayerAdded보다 스크립트가 늦게 로드될 때를 위한 fallback
for _, p in ipairs(Players:GetPlayers()) do
    task.spawn(onPlayerAdded, p)
end

game:BindToClose(function()
    for _, p in ipairs(Players:GetPlayers()) do
        savePlayer(p)
    end
end)

-- 5분마다 자동 저장
task.spawn(function()
    while true do
        task.wait(300)
        for _, p in ipairs(Players:GetPlayers()) do
            local data = PlayerData.GetSaveData(p)
            if data then
                pcall(function() store:SetAsync("u_" .. p.UserId, data) end)
            end
        end
    end
end)
