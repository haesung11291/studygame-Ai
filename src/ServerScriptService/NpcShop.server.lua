local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes     = ReplicatedStorage:WaitForChild("Remotes")
local OpenNPCShop = Remotes:WaitForChild("OpenNPCShop")

local connected = false

local function tryConnect(desc)
    if connected then return end
    if desc.Name ~= "MerchantPrompt" then return end
    if not desc:IsA("ProximityPrompt") then return end
    connected = true
    desc.Triggered:Connect(function(player)
        OpenNPCShop:FireClient(player)
    end)
    print("[NpcShop] 상인 NPC 연결 완료 ✓")
end

-- DescendantAdded를 먼저 구독 (MapBuilder가 나중에 추가해도 캐치)
workspace.DescendantAdded:Connect(tryConnect)

-- 이미 존재하는 경우도 처리 (MapBuilder가 먼저 실행됐을 때)
for _, desc in ipairs(workspace:GetDescendants()) do
    if connected then break end
    tryConnect(desc)
end
