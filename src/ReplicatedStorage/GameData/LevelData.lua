local LevelData = {}

LevelData.MaxLevel = 100

function LevelData.XPRequired(level)
    if level >= LevelData.MaxLevel then return math.huge end
    return math.floor(level ^ 2 * 100)
end

function LevelData.GetStats(level)
    return {
        attack    = 10 + level * 2,
        defense   = 5  + math.floor(level * 1.5),
        speed     = 16 + (level >= 25 and 1 or 0) + (level >= 50 and 1 or 0),
        luck      = math.floor(level * 0.5),
        farmSpeed = 1  + (level >= 40 and 0.5 or 0) + (level >= 70 and 0.5 or 0),
    }
end

LevelData.Milestones = {
    [5]   = "🥕 당근 씨앗 해금!",
    [10]  = "⚔ 철 검 구매 가능!",
    [15]  = "🥔 감자 씨앗 해금!",
    [20]  = "🌽 옥수수 씨앗 해금! 오크 등장!",
    [25]  = "🛡 강화 갑옷 구매 가능!",
    [30]  = "🍅 토마토 씨앗 해금! 트롤 등장!",
    [35]  = "🎃 호박 씨앗 해금!",
    [40]  = "🔥 화염 검 구매 가능! 뱀파이어 등장!",
    [50]  = "🍉 수박 씨앗 해금!",
    [60]  = "🍓 딸기 씨앗 해금! 다크나이트 등장!",
    [70]  = "🍄 버섯 씨앗 해금!",
    [75]  = "🗡 황금 검 구매 가능!",
    [80]  = "🍎 황금사과 해금! 드래곤 등장!",
    [100] = "👑 전설 레벨 달성! 전설 검 구매 가능!",
}

return LevelData
