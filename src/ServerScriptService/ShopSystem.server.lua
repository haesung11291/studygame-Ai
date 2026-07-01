local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerData = require(ServerScriptService:WaitForChild("PlayerData"))
local ShopData   = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("ShopData"))
local Remotes    = ReplicatedStorage:WaitForChild("Remotes")

local BuyItem   = Remotes:WaitForChild("BuyItem")
local Notify    = Remotes:WaitForChild("Notification")
local UpdateHUD = Remotes:WaitForChild("UpdateHUD")

BuyItem.OnServerEvent:Connect(function(player, itemType, itemId)
    local pd = PlayerData.Get(player)
    if not pd then return end

    if itemType == "weapon" then
        local item
        for _, w in ipairs(ShopData.weapons) do
            if w.id == itemId then item = w break end
        end
        if not item then return end

        if pd.level < item.level then
            Notify:FireClient(player, "레벨 " .. item.level .. " 이상 필요!", "error") return
        end
        if pd.gold < item.price then
            Notify:FireClient(player, "골드 부족! (필요: " .. item.price .. "G)", "error") return
        end
        if (pd.weaponBaseDamage or pd.weaponDamage) >= item.damage then
            Notify:FireClient(player, "이미 더 강한 무기를 보유 중!", "error") return
        end

        pd.gold             = pd.gold - item.price
        pd.weapon           = item.id
        pd.weaponBaseDamage = item.damage
        pd.weaponStar       = 0           -- 새 무기는 강화 단계 초기화
        PlayerData.RecomputeWeaponDamage(pd)
        UpdateHUD:FireClient(player, { gold = pd.gold })
        Notify:FireClient(player, "⚔ " .. item.name .. " 구매! (공격력: " .. pd.weaponDamage .. ")", "success")

    elseif itemType == "land" then
        local item
        for _, l in ipairs(ShopData.land) do
            if l.id == itemId then item = l break end
        end
        if not item then return end

        if pd.level < item.level then
            Notify:FireClient(player, "레벨 " .. item.level .. " 이상 필요!", "error") return
        end
        if pd.gold < item.price then
            Notify:FireClient(player, "골드 부족! (필요: " .. item.price .. "G)", "error") return
        end
        if pd.plots >= item.plots then
            Notify:FireClient(player, "이미 더 많은 농지를 보유 중!", "error") return
        end

        pd.gold  = pd.gold - item.price
        pd.plots = item.plots
        UpdateHUD:FireClient(player, { gold = pd.gold, plots = pd.plots })
        Notify:FireClient(player, "🌱 농지 " .. item.plots .. "칸으로 확장!", "success")
    end
end)
