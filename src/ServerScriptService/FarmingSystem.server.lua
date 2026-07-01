local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService        = game:GetService("TweenService")

local PlayerData = require(ServerScriptService:WaitForChild("PlayerData"))
local CropData   = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("CropData"))
local Remotes    = ReplicatedStorage:WaitForChild("Remotes")

local FARM = Vector3.new(-600, 0, 0)
local function getPlotPos(plotId)
    local idx = plotId - 1
    local row = math.floor(idx / 5)
    local col = idx % 5
    return FARM + Vector3.new(-48 + col*24, 0.8, -20 + row*22)
end

local plantVisuals = {}

local PlantSeed   = Remotes:WaitForChild("PlantSeed")
local HarvestCrop = Remotes:WaitForChild("HarvestCrop")
local SellCrops   = Remotes:WaitForChild("SellCrops")
local EatFood     = Remotes:WaitForChild("EatFood")
local CropReady   = Remotes:WaitForChild("CropReady")
local Notify      = Remotes:WaitForChild("Notification")
local UpdateHUD   = Remotes:WaitForChild("UpdateHUD")

local function getPd(player)
    local pd = PlayerData.Get(player)
    if not pd then pd = PlayerData.Init(player) end
    return pd
end

-- plotId가 nil이면 첫 번째 빈 농지 자동 탐색
local function findEmptyPlot(pd)
    for i = 1, pd.plots do
        if not pd.crops[i] then return i end
    end
    return nil
end

-- plotId가 nil이면 첫 번째 수확 가능한 농지 자동 탐색
local function findGrownPlot(pd)
    for i = 1, pd.plots do
        if pd.crops[i] and pd.crops[i].grown then return i end
    end
    return nil
end

PlantSeed.OnServerEvent:Connect(function(player, cropType, plotId)
    local pd   = getPd(player)
    local crop = CropData[cropType]
    if not pd then return end
    if not crop then
        Notify:FireClient(player, "[오류] 알 수 없는 작물: " .. tostring(cropType), "error")
        return
    end

    -- plotId 없으면 자동으로 빈 밭 찾기
    if not plotId or plotId == 0 then
        plotId = findEmptyPlot(pd)
        if not plotId then
            Notify:FireClient(player, "모든 농지가 가득 찼습니다!", "error")
            return
        end
    end

    if pd.level < crop.levelRequired then
        Notify:FireClient(player, "레벨 " .. crop.levelRequired .. " 이상 필요합니다!", "error") return
    end
    if plotId < 1 or plotId > pd.plots then
        Notify:FireClient(player, "보유하지 않은 농지입니다! (보유: " .. pd.plots .. "개)", "error") return
    end
    if pd.crops[plotId] then
        Notify:FireClient(player, "이미 작물이 있습니다!", "error") return
    end
    if pd.gold < crop.price then
        Notify:FireClient(player, "골드 부족! (필요: " .. crop.price .. "G, 보유: " .. pd.gold .. "G)", "error") return
    end

    pd.gold = pd.gold - crop.price
    local growTime = math.floor(crop.growTime / (pd.stats and pd.stats.farmSpeed or 1))
    pd.crops[plotId] = {
        type      = cropType,
        plantedAt = os.time(),
        growTime  = growTime,
        grown     = false,
    }

    UpdateHUD:FireClient(player, { gold = pd.gold })
    Notify:FireClient(player, crop.name .. " 심기 완료! (" .. growTime .. "초 후 수확)", "success")

    local key = player.UserId .. "_" .. plotId
    if plantVisuals[key] then plantVisuals[key]:Destroy() end
    local seedPart = Instance.new("Part")
    seedPart.Size       = Vector3.new(0.8, 0.8, 0.8)
    seedPart.Shape      = Enum.PartType.Ball
    seedPart.CFrame     = CFrame.new(getPlotPos(plotId))
    seedPart.Anchored   = true
    seedPart.CanCollide = false
    seedPart.BrickColor = BrickColor.new("Reddish brown")
    seedPart.Material   = Enum.Material.Ground
    seedPart.Parent     = workspace
    plantVisuals[key]   = seedPart

    task.delay(growTime, function()
        local current = getPd(player)
        if not current then return end
        local plot = current.crops[plotId]
        if plot and plot.type == cropType and not plot.grown then
            plot.grown = true
            if player.Parent then
                CropReady:FireClient(player, plotId, crop.name)
                Notify:FireClient(player, "🌾 " .. crop.name .. " 수확 가능! (" .. plotId .. "번 농지)", "info")

                local visual = plantVisuals[key]
                if visual and visual.Parent then
                    TweenService:Create(visual, TweenInfo.new(0.6, Enum.EasingStyle.Bounce), {
                        Size = Vector3.new(2.5, 2.5, 2.5)
                    }):Play()
                    visual.BrickColor = BrickColor.new("Bright green")
                    local sp = Instance.new("Sparkles")
                    sp.SparkleColor = Color3.fromRGB(50, 255, 50)
                    sp.Parent = visual
                end
            end
        end
    end)
end)

HarvestCrop.OnServerEvent:Connect(function(player, plotId)
    local pd = getPd(player)
    if not pd then return end

    -- plotId 없으면 자동으로 수확 가능한 밭 찾기
    if not plotId or plotId == 0 then
        plotId = findGrownPlot(pd)
        if not plotId then
            -- 아직 자라는 중인 밭이 있는지 확인
            local growing = false
            for i = 1, pd.plots do
                if pd.crops[i] and not pd.crops[i].grown then
                    local left = math.max(0, math.ceil((pd.crops[i].plantedAt + pd.crops[i].growTime) - os.time()))
                    Notify:FireClient(player, "아직 자라는 중! (" .. left .. "초 남음)", "error")
                    growing = true
                    break
                end
            end
            if not growing then
                Notify:FireClient(player, "수확 가능한 작물이 없습니다!", "error")
            end
            return
        end
    end

    local plot = pd.crops[plotId]
    if not plot then
        Notify:FireClient(player, "심은 작물이 없습니다!", "error") return
    end
    if not plot.grown then
        local left = math.max(0, math.ceil((plot.plantedAt + plot.growTime) - os.time()))
        Notify:FireClient(player, "아직 자라는 중! (" .. left .. "초 남음)", "error") return
    end

    local cropType = plot.type
    pd.inventory[cropType] = (pd.inventory[cropType] or 0) + 1
    pd.crops[plotId] = nil

    local key = player.UserId .. "_" .. plotId
    if plantVisuals[key] then
        plantVisuals[key]:Destroy()
        plantVisuals[key] = nil
    end

    local crop = CropData[cropType]
    Notify:FireClient(player, (crop and crop.name or cropType) .. " 수확! (인벤: " .. pd.inventory[cropType] .. "개)", "success")
end)

SellCrops.OnServerEvent:Connect(function(player)
    local pd = getPd(player)
    if not pd then return end

    local total = 0
    for cropType, count in pairs(pd.inventory) do
        if count > 0 and CropData[cropType] then
            total = total + CropData[cropType].sellPrice * count
            pd.inventory[cropType] = 0
        end
    end

    if total == 0 then
        Notify:FireClient(player, "팔 작물이 없습니다!", "error") return
    end

    pd.gold = pd.gold + total
    UpdateHUD:FireClient(player, { gold = pd.gold })
    Notify:FireClient(player, "💰 +" .. total .. "G 획득!", "success")
end)

EatFood.OnServerEvent:Connect(function(player, cropType)
    local pd   = getPd(player)
    local crop = CropData[cropType]
    if not pd or not crop then return end

    if (pd.inventory[cropType] or 0) <= 0 then
        Notify:FireClient(player, "인벤토리에 " .. crop.name .. "이(가) 없습니다!", "error") return
    end

    pd.inventory[cropType] = pd.inventory[cropType] - 1
    local restoreAmount = math.floor(crop.sellPrice / 5)
    pd.hunger = math.min(pd.maxHunger, pd.hunger + restoreAmount)

    local char = player.Character
    if char and pd.hunger > 30 then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.Health = math.min(hum.MaxHealth, hum.Health + 10)
        end
    end

    UpdateHUD:FireClient(player, { hunger = pd.hunger })
    Notify:FireClient(player, "🍽 " .. crop.name .. " 섭취! 허기 +" .. restoreAmount, "success")
end)
