
local RedDotUtils = {}

local function GetRedDotData()
    local UserDataType = require "Framework.UserDataType"
    local dataManager = require "Utils.Utility".GetGame():GetDataCacheManager()
    return dataManager:GetData(UserDataType.RedDotData)
end

function RedDotUtils.CanCardStageUp(uid)
    local redDotData = GetRedDotData()
    if redDotData == nil then
        return false
    end

    local redState = redDotData:GetCardRedData(uid)
    return redState == 1 or redState == 3 or redState == 4 or redState == 5
end

function RedDotUtils.CanCardTalentUp(uid)
    local redDotData = GetRedDotData()
    if redDotData == nil then
        return false
    end

    local redState = redDotData:GetCardRedData(uid)
    return redState == 2 or redState == 3 or redState == 4 or redState == 5 or redState == 6 or redState == 7
end

function RedDotUtils.HasZodiacRedDot()
    local redDotData = GetRedDotData()
    if redDotData == nil then
        return false
    end
    local guideRed = require "Network.PB.S2CGuideRedResult"
    -- debug_print("星座红点状态", guideRed.star, redDotData:GetModuleRedState(guideRed.star))
    return redDotData:GetModuleRedState(guideRed.star) == 1
end

-- note: 这里是链接的, 我想把处理塔罗牌的数据判断逻辑放在一个单独脚本中, 这里可以可以去和红点产生链接. (保留)
function RedDotUtils.HasTarotRedDot()
    return require "Utils.TarotUtils".HasRedDot()
end

function RedDotUtils.HasRoleLevelUpRedDot(uid)
    return require "Utils.RoleUtility".CanLevelUp(uid)
end

return RedDotUtils