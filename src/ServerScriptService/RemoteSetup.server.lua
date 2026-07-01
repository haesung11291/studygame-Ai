local ReplicatedStorage = game:GetService("ReplicatedStorage")

local folder = Instance.new("Folder")
folder.Name = "Remotes"
folder.Parent = ReplicatedStorage

local events = {
    "PlantSeed", "HarvestCrop", "SellCrops", "AttackMonster",
    "BuyItem", "EatFood",
    "UpdateHUD", "LevelUp", "Notification", "MonsterDied", "CropReady",
    "OpenNPCShop",
    "OpenBlacksmith", "EnhanceWeapon", "EnhanceResult",
}

for _, name in ipairs(events) do
    local re = Instance.new("RemoteEvent")
    re.Name = name
    re.Parent = folder
end

local rf = Instance.new("RemoteFunction")
rf.Name = "GetPlayerData"
rf.Parent = folder
