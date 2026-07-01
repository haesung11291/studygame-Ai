-- 장비 강화 데이터 (대장간)
local EnhanceData = {}

EnhanceData.MaxStar = 10

-- 목표 성급(1~10)에 도달할 성공 확률(%)
-- 예: 0★ → 1★ 은 99%, 9★ → 10★ 은 10%
EnhanceData.Rates = { 99, 80, 72, 65, 60, 57, 43, 34, 29, 10 }

function EnhanceData.SuccessRate(targetStar)
    return EnhanceData.Rates[targetStar] or 0
end

-- 성급당 공격력 보너스: 기본 공격력의 12%씩 누적 (10★ = 기본의 +120%)
function EnhanceData.Bonus(baseDamage, star)
    return math.floor(baseDamage * 0.12 * star + 0.5)
end

-- 강화 비용(골드) — 무기 기본 공격력과 목표 성급에 비례
function EnhanceData.Cost(baseDamage, targetStar)
    return math.floor((baseDamage * 4 + 80) * targetStar)
end

return EnhanceData
