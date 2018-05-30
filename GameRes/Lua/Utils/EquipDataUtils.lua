
local PropertySet = require "Game.Property.PropertySet"
require "Const"
require "Collection.OrderedDictionary"

local EquipDataUtils = {}

function EquipDataUtils.CanAddEquipBasicAndRaceProperties(role, equipData)
    if equipData == nil or role == nil then
        return false
    end

    -- 当装备需要只在种族符合时才加属性 --
    if equipData:IsMainPropOnlyAddRace() then
        local raceId = equipData:GetRaceAdd()
        if raceId > 0 and role:GetRace() ~= raceId then
            return false
        end
    end

    return true
end

-- # 获得装备基本属性(含等级因素)
function EquipDataUtils.CalculateEquipBasicProperties(equipData, propertySet)
    local attributes = equipData:GetEquipAttribute()
    for propertyId = 1, kPropertyID_MaxCount do
        local value = attributes:GetEntryByKey(propertyId)
        if type(value) == "number" then
            propertySet:AddValue(propertyId, value)
        end
    end
end

-- # 获得种族加成
function EquipDataUtils.CalculateEquipRaceProperties(role, equipData, propertySet)
    local equipRaceData = require "StaticData.EquipRace":SafeGetData(equipData:GetEquipID())
    if equipRaceData ~= nil then
        if equipRaceData:GetRaceID() == role:GetRace() then
            propertySet:AddValue(equipRaceData:GetAddPropID(), equipRaceData:GetAddPropValue())
        end
    end
end

-- # 获得宝石加成
function EquipDataUtils.CalculateEquipGems(role, equipData, propertySet)
    local ids = equipData:GetStoneID()

    if ids == nil then
        return
    end

    for i = 1, #ids do
        local gemId = ids[i]
        if type(gemId) == "number" and gemId > 0 then
            -- FIXME: 伪造EquipData用户类, 这样可以复用方法!
            local fakeEquipData = require "Data.EquipBag.EquipData".New()
            fakeEquipData:UpdateData{
                equipUID = "",
                equipID = gemId,
                level = 1,
                pos = -1,
                bindCardUID = "",
                onWhichCard = equipData:GetOnWhichCard(),
                exp = 0,
                color = 1,
                stoneID = nil,
                stoneUID = ""
            }

            EquipDataUtils.CalculateEquipAllProperties(role, fakeEquipData, propertySet)
        end
    end
end

-- # 获得专属加成
function EquipDataUtils.CalculateUniqueEquipProperties(role, equipData, propertySet)
    local uniqueEquipData = require "StaticData.EquipExclusive":SafeGetData(equipData:GetEquipID())
    if uniqueEquipData ~= nil then
        -- 存在羁绊才能加属性 --
        if uniqueEquipData:IsKizunaContains(role:GetId()) then
            propertySet:AddValue(uniqueEquipData:GetJibanAddPropID(), uniqueEquipData:GetAddPropValue())
        end
    end
end

-- # 获得当前装备的所有加成
function EquipDataUtils.CalculateEquipAllProperties(role, equipData, propertySet)
    if EquipDataUtils.CanAddEquipBasicAndRaceProperties(role, equipData) then
        -- @ 1. 基本属性
        EquipDataUtils.CalculateEquipBasicProperties(equipData, propertySet)

        -- @ 2. 种族加成
        EquipDataUtils.CalculateEquipRaceProperties(role, equipData, propertySet)
    end

    -- @ 3. 宝石
    EquipDataUtils.CalculateEquipGems(role, equipData, propertySet)

    -- @ 4. 专属
    EquipDataUtils.CalculateUniqueEquipProperties(role, equipData, propertySet)
end

-- # 哪些装备类型在 宝石连锁 计算范围内
local function DoesNeedToCheckGemLinkage(type)
    return type == KEquipType_EquipWeapon or 
           type == KEquipType_EquipArmor or
           type == KEquipType_EquipAccessories or
           type == KEquipType_EquipShoesr
end

-- # 获得宝石连锁 --
function EquipDataUtils.CalculateAllGemsLinkage(role, propertySet)
    local equipDataList = role:GetEquipDataList()
    if equipDataList == nil then
        return
    end

    local PassedEquipCount = 0   -- 满足的个数(大于等于4就代表应该连锁了)

    local recordGemColor    -- 记录的宝石连锁颜色

    local count = equipDataList:Count()

    for i = 1, count do
        local equipData = equipDataList:GetEntryByIndex(i)

        -- @ 1. 检查 [装备是否可以镶嵌宝石] 以及 [该装备类型是否处于宝石连锁检查条件]
        if equipData ~= nil and equipData:GetGemNum() > 0 and DoesNeedToCheckGemLinkage(equipData:GetEquipType()) then
            -- @ 2. 检查 [当前镶嵌的宝石个数 == 最大可镶嵌宝石个数]
            local gemIds = equipData:GetStoneID()
            if type(gemIds) ~= "table" or #gemIds ~= equipData:GetGemNum() then
                return false
            end

            -- @ 3. 循环检查每个宝石
            for j = 1, #gemIds do
            
                local id = gemIds[j]

                -- # 没有镶嵌宝石 则没有连锁
                if id <= 0 then
                    return false
                end

                -- # 获取当前镶嵌宝石的颜色 是否都一致
                local equipGemColor = require "StaticData.Equip":GetData(id):GetColorID()
                if type(recordGemColor) ~= "number" then
                    recordGemColor = equipGemColor
                elseif recordGemColor ~= equipGemColor then
                    return false
                end
            end
            -- @ 4. 检查完毕后 通过数+1
            PassedEquipCount = PassedEquipCount + 1
        end
    end

    if PassedEquipCount >= 4 and type(recordGemColor) == "number" and recordGemColor > 0 then
        local gemLinkageData = require "StaticData.EquipChain":SafeGetData(recordGemColor)
        if gemLinkageData ~= nil then
            propertySet:AddValue(gemLinkageData:GetAddPropID(), gemLinkageData:GetAddPropValue())
            return true
        end
    end

    return false
end

-- #> 套装数组内存储结构实现
local function AddToSuits(suits, suitID, _)
    if type(suitID) == "number" and suitID > 0 then
        local count = suits[suitID] or 0
        count = count + 1
        suits[suitID] = count
    end
end

-- # 获得装备套装加成
function EquipDataUtils.CalculateEquipSuits(role, propertySet)
    -- GetTaozhuangID
    local allSuits

    -- @1. 先按套装分组
    local equipDataList = role:GetEquipDataList()
    if equipDataList ~= nil then
        local count = equipDataList:Count()
        if count > 0 then
            allSuits = {}
            for i = 1, count do
                local equipData = equipDataList:GetEntryByIndex(i)
                if equipData ~= nil then
                    -- @ 检索 套装ID
                    AddToSuits(allSuits, equipData:GetTaozhuangID(), equipData)
                end
            end
        end
    end

    -- @2. 每个套装再检索
    if allSuits ~= nil then
        for suitID, count in pairs(allSuits) do
            -- @ 3. 检查当前套装是否可以加成
            local staticSuitData = require "StaticData.EquipSet":SafeGetData(suitID)
            if staticSuitData ~= nil then
                -- 有这个套装信息 则继续检查 --
                -- count
                local maxPropertyCount = staticSuitData:GetMaxProperty()
                local startPropertyId = suitID * 100
                local endPropertyId = startPropertyId + maxPropertyCount - 1
                for i = startPropertyId, endPropertyId do
                    local staticSuitPropertyData = require "StaticData.EquipSetProperty":SafeGetData(i)
                    if staticSuitPropertyData ~= nil and staticSuitPropertyData:GetHasNum() <= count then
                        propertySet:AddValue(staticSuitPropertyData:GetAddPropID(), staticSuitPropertyData:GetAddValue())
                    end
                end
            end
        end
    end
end

function EquipDataUtils.GetPropertySetOnCard(role, outPropertySet)
    local propertySet = outPropertySet or PropertySet.New()
    
    local equipDataList = role:GetEquipDataList()

    if equipDataList ~= nil then
        local count = equipDataList:Count()
        for i = 1, count do
            local equipData = equipDataList:GetEntryByIndex(i)
            if equipData ~= nil then
                EquipDataUtils.CalculateEquipAllProperties(role, equipData, propertySet)
            end
        end
    end

    -- 宝石连锁
    EquipDataUtils.CalculateAllGemsLinkage(role, propertySet)

    -- 装备套装
    EquipDataUtils.CalculateEquipSuits(role, propertySet)

    return propertySet
end

return EquipDataUtils
