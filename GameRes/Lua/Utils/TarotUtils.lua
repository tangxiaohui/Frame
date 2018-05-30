local utility = require "Utils.Utility"

local TarotUtils = {}

-- >> 私有函数

local function GetTarotData(id)
    return require "StaticData.Tarot.Tarot":GetData(id)
end

local function IsItemEnough(itemId, itemNum)
    return utility.IsItemEnough(itemId, itemNum)
end

local function GetCurrentProgressId()
    local UserDataType = require "Framework.UserDataType"
    local dataCacheMgr = utility.GetGame():GetDataCacheManager()
    local tarotUserData = dataCacheMgr:GetData(UserDataType.TarotData)
    return tarotUserData:GetTarotProgressId()
end

local function GetOpenedCardNum()
    local UserDataType = require "Framework.UserDataType"
    local dataCacheMgr = utility.GetGame():GetDataCacheManager()
    local tarotUserData = dataCacheMgr:GetData(UserDataType.TarotData)
    return tarotUserData:GetNumOfTarotCards()
end

-- 1. 塔罗牌是否达到开放等级
function TarotUtils.IsLeastLevelReached(checkOnly)
    return utility.IsCanOpenModule(kSystemBasis_Tarot, checkOnly)
end

-- 2. 获取当前stage.
function TarotUtils.GetCurrentStage(id)
    local UserDataType = require "Framework.UserDataType"
    local dataCacheMgr = utility.GetGame():GetDataCacheManager()
    local tarotUserData = dataCacheMgr:GetData(UserDataType.TarotData)
    return tarotUserData:GetTarotFlags(id) or kTarotState_Unactive
end

-- 3. 通过当前stage获取下一个stage (没有下一个stage 返回-1).
function TarotUtils.GetNextStage(stage)
    if stage == kTarotState_Unactive then
        return kTarotState_Inverted
    elseif stage == kTarotState_Inverted then
        return kTarotState_Straight
    end
    return -1
end

-- 4. 通过当前stage获取上一个stage (没有上一个stage 返回-1)
function TarotUtils.GetPreviousStage(stage)
    if stage == kTarotState_Inverted then
        return kTarotState_Unactive
    elseif stage == kTarotState_Straight then
        return kTarotState_Inverted
    end
    return -1
end

-- 5. 当前卡牌是否为正位.
function TarotUtils.IsTheTarotCardTop(id)
    return TarotUtils.GetCurrentStage(id) == kTarotState_Straight
end

-- 6. 是否可激活某张卡(非正位&&材料够).
function TarotUtils.CanActiveTheTarotCard(id)
    if TarotUtils.IsTheTarotCardTop(id) then return false end
    local nextStage = TarotUtils.GetNextStage(TarotUtils.GetCurrentStage(id))
    return (IsItemEnough(TarotUtils.GetTarotItemAtStage(id, nextStage)))
end

-- 7. 是否有任意塔罗牌可以激活(待测)
function TarotUtils.CanActiveAnyTarotCard()
    return require "StaticData.Tarot.Tarot":Any(function(tarotData)
        return TarotUtils.CanActiveTheTarotCard(tarotData:GetId())
    end)
end

-- 8. 是否达到最大卡数.
function TarotUtils.IsTheMinimumNumberOfCardReachedForProgress()
    local num = GetOpenedCardNum()
    local progressData = require "StaticData.Tarot.TarotProgress":GetData(GetCurrentProgressId())
    return num >= progressData:GetConditionTarotNum()
end

-- 9. 进度光环材料是否足够.
function TarotUtils.IsItemEnoughForProgress()
    return IsItemEnough(TarotUtils.GetCurrentTarotProgressItem())
end

-- 10. 是否可激活进度光环.
function TarotUtils.CanActiveTarotProgress()
    return TarotUtils.IsTheMinimumNumberOfCardReachedForProgress() and TarotUtils.IsItemEnoughForProgress()
end

-- 11. 获取指定id 指定stage的属性对(id, value).
function TarotUtils.GetTarotPropertyAtStage(id, stage)
    local tarotData = GetTarotData(id)
    local propertyId = tarotData:GetStagePropertyId(stage)
    if propertyId > 0 then
        return propertyId, tarotData:GetStagePropertyValue(stage)
    end
    return nil
end

-- 12. 获取指定id 指定stage的物品对(itemId, itemNum).
function TarotUtils.GetTarotItemAtStage(id, stage)
    local tarotData = GetTarotData(id)
    return tarotData:GetStageItemId(stage), tarotData:GetStageItemNum(stage)
end

-- 13. 获取当前的进度所需物品对(itemId, itemNum).
function TarotUtils.GetCurrentTarotProgressItem()
    local progressData = require "StaticData.Tarot.TarotProgress":GetData(GetCurrentProgressId())
    return progressData:GetItemId(), progressData:GetItemNum()
end

-- 14. 有红点(待测)
function TarotUtils.HasRedDot()
    return TarotUtils.IsLeastLevelReached(true) and (TarotUtils.CanActiveAnyTarotCard() or TarotUtils.CanActiveTarotProgress())
end

return TarotUtils
