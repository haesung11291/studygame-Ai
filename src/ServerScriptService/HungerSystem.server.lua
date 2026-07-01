local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerData = require(ServerScriptService:WaitForChild("PlayerData"))
local Remotes    = ReplicatedStorage:WaitForChild("Remotes")
local UpdateHUD  = Remotes:WaitForChild("UpdateHUD")
local Notify     = Remotes:WaitForChild("Notification")

-- 허기 감소: 30초마다 -5
task.spawn(function()
    while true do
        task.wait(30)
        for _, player in ipairs(Players:GetPlayers()) do
            local pd = PlayerData.Get(player)
            if pd then
                pd.hunger = math.max(0, pd.hunger - 5)

                if pd.hunger == 0 then
                    local char = player.Character
                    if char then
                        local hum = char:FindFirstChild("Humanoid")
                        if hum and hum.Health > 0 then
                            hum:TakeDamage(5)
                        end
                    end
                    Notify:FireClient(player, "🍖 배가 고파요! 작물을 먹어 허기를 채우세요!", "warning")
                end

                UpdateHUD:FireClient(player, { hunger = pd.hunger })
            end
        end
    end
end)

-- 허기 50 이상일 때 체력 자연 회복
task.spawn(function()
    while true do
        task.wait(8)
        for _, player in ipairs(Players:GetPlayers()) do
            local pd = PlayerData.Get(player)
            if pd and pd.hunger > 50 then
                local char = player.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum and hum.Health < hum.MaxHealth then
                        hum.Health = math.min(hum.MaxHealth, hum.Health + 2)
                    end
                end
            end
        end
    end
end)
