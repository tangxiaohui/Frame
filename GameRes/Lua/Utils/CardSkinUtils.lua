local PropertySet = require "Game.Property.PropertySet"
require "Const"
require "Collection.OrderedDictionary"

local CardSkinDataUtils = {}

function CardSkinDataUtils.GetSkinAddProperties(SkinData)
    -- 固定attack,hp
    local skinStaticData = SkinData:GetSkinStaticData()
    local level = SkinData:GetCardSkinLevel()
    local attack = skinStaticData:GetGongjiliindex() * level
    local hp = skinStaticData:GetHpLimitindex() * level
    return attack,hp
end

function CardSkinDataUtils.GetSkinsIdArray(cardSkinData)
    local CardskinStaticData = cardSkinData:GetCardskinStaticData()
    return CardskinStaticData:GetSkinid()
end

-- @解锁皮肤加成
function CardSkinDataUtils.CalculateHadSkinAddProperties(cardSkinData,propertySet)
    local skinIdsArray = CardSkinDataUtils.GetSkinsIdArray(cardSkinData)
    for i = 0 ,skinIdsArray.Count-1 do
        local skinId = skinIdsArray[i]
        local skinData = cardSkinData:GetSkinDataById(skinId)
        if  propertySet ~= nil and skinData ~= nil then
            local attack,hp = CardSkinDataUtils.GetSkinAddProperties(skinData)
           -- propertySet:AddValue(kPropertyID_HpLimit,hp)
           -- propertySet:AddValue(kPropertyID_Ap,attack)
            debug_print("解锁皮肤加成",attack,hp,"ID",skinId)
        end
    end
end

function CardSkinDataUtils.GetKizunaIdArray(skinData)
    return skinData:GetSkinKizunaStaticData():GetKizuna()
end

function CardSkinDataUtils.CalculateSkinKizunaAddProperties(skinData)
    local idArray = CardSkinDataUtils.GetKizunaIdArray(skinData)
end

function CardSkinDataUtils.GetBaseStateAdded(kizunaStaticData)
    local idArray = kizunaStaticData:GetStatusid()
    local addArray = kizunaStaticData:GetStatusrate()
    return idArray,addArray
end

--local CardSkinDataUtils.cacheData = nil
function CardSkinDataUtils.GetSkinLevelById(cardId,skinId)
    -- 将data 缓存起来
    if CardSkinDataUtils.cacheData == nil then
        Utility = require "Utils.Utility"
        local cacheManager = Utility.GetGame():GetDataCacheManager()
        local UserDataType = require "Framework.UserDataType"
        CardSkinDataUtils.cacheData = cacheManager:GetData(UserDataType.CardSkinsData)
    end
    local skinData = CardSkinDataUtils.cacheData:GetOneSkinData(cardId,skinId)
    if skinData == nil then
        return 0
    else
        return skinData:GetCardSkinLevel()
    end
end

function CardSkinDataUtils.CheckCurrLevelAndTargetLevel(checkLevelArray,skinIdArray,cardId)
    local result = false
    for i = 0 ,skinIdArray.Count-1 do
        local level = CardSkinDataUtils.GetSkinLevelById(cardId,skinIdArray[i])
        local checkLevel = checkLevelArray[i]
        if checkLevel > level then
            result = false
            break
        end
        result = true 
    end
    return result
end

function CardSkinDataUtils.GetOpenedKizunaState(skinData,cardId)
    local skinIdsArray = CardSkinDataUtils.GetKizunaIdArray(skinData) 
    -- 1阶段
    local result = false
    local resultState = 0
    local checkLevelArray 
    checkLevelArray = skinData:GetSkinKizunaStaticData():GetKizunalevel1()
    result = CardSkinDataUtils.CheckCurrLevelAndTargetLevel(checkLevelArray,skinIdsArray,cardId)
    if result then
        resultState = 1
    else
        return resultState
    end

    -- 2阶段
    checkLevelArray = skinData:GetSkinKizunaStaticData():GetKizunalevel2()
    result = CardSkinDataUtils.CheckCurrLevelAndTargetLevel(checkLevelArray,skinIdsArray,cardId)
    if result then
        resultState = 2
    else
        return resultState
    end

    -- 3阶段
    checkLevelArray = skinData:GetSkinKizunaStaticData():GetKizunalevel3()
    result = CardSkinDataUtils.CheckCurrLevelAndTargetLevel(checkLevelArray,skinIdsArray,cardId)
    if result then
        resultState = 3
    else
        return resultState   
    end

    return resultState
end

-- @羁绊皮肤加成
function CardSkinDataUtils.CalculateHadKizunaAddProperties(cardSkinData,propertySet)
    local cardId = cardSkinData:GetCardId()
    local cardSkinDict = cardSkinData:GetCardSkins()
    local keys = cardSkinDict:GetKeys()
    for i = 1 , #keys do
        local skinId = keys[i]
        local skinData = cardSkinDict:GetEntryByKey(skinId)
        local state = CardSkinDataUtils.GetOpenedKizunaState(skinData,cardId)
        if state ~= 0 then
            local keys,values = GetBaseStateAdded(skinData:GetSkinKizunaStaticData())
            for j = 0 ,keys.Count-1 do
                local value = values[j] * state
                propertySet:AddValue(keys[i],value)
            end
        end
    end
end

-- @获得当前装备的所有加成
function CardSkinDataUtils.CalculateCardSkinAllProperties(cardSkinData, propertySet)
   -- 1.解锁皮肤加成
   CardSkinDataUtils.CalculateHadSkinAddProperties(cardSkinData, propertySet)
   -- 2.羁绊皮肤加成
   CardSkinDataUtils.CalculateHadKizunaAddProperties(cardSkinData,propertySet)
end


return CardSkinDataUtils
