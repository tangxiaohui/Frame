--
-- User: fbmly
-- Date: 4/20/17
-- Time: 11:03 AM
--

local staticTableUtility = require "Utils.StaticTableUtility"
local utility = require "Utils.Utility"

local UnityEngine_Color = UnityEngine.Color

local PropUtility = {}

function PropUtility.IsAnyPropType(id)
    local type = staticTableUtility.GetTypeFromID(id)
    return  type == kStaticTableId_Card or
            type == kStaticTableId_Equipment or
            type == kStaticTableId_Skill or
            type == kStaticTableId_GeneralItem or
            type == kStaticTableId_Currency or
            type == kStaticTableId_CardCrap or
            type == kStaticTableId_EquipmentCrap or
            type == kStaticTableId_LevelReward or
            type == kStaticTableId_ProtectPrincessBox or
            type == kStaticTableId_FactoryBoxToFix or
            type == kStaticTableId_ClubProp
end

-- 获得道具图标
function PropUtility.GetIcon(id)
end

function PropUtility.GetColor(id)
    local type = staticTableUtility.GetTypeFromID(id)
    if type == kStaticTableId_Card then
        return 0
    elseif type == kStaticTableId_Equipment then
        return 0
    elseif type == kStaticTableId_Skill then
        return 0
    elseif type == kStaticTableId_GeneralItem then
        return 0
    elseif type == kStaticTableId_Currency then
        return 0
    elseif type == kStaticTableId_CardCrap then
        return 0
    elseif type == kStaticTableId_EquipmentCrap then
        return 0
    elseif type == kStaticTableId_LevelReward then
        return 0
    elseif type == kStaticTableId_ProtectPrincessBox then
        return 0
    elseif type == kStaticTableId_FactoryBoxToFix then
        return 0
    elseif type == kStaticTableId_ClubProp then
        return 0
    end
    error("不支持的类型", type)
end

-- 获得品质颜色值(HSL)
function PropUtility.GetColorValue(color)
    if color == 1 then
        return UnityEngine_Color(0.09765625, 0.5, 0.5, 1)
    elseif color == 2 then
        return UnityEngine_Color(0.3203125, 0.5, 0.5, 1)
    elseif color == 3 then
        return UnityEngine_Color(0.5, 0.5, 0.5, 1)
    elseif color == 4 then
        return UnityEngine_Color(0.828125, 0.5, 0.5, 1)
    elseif color == 5 then
        return UnityEngine_Color(0.722222, 0.5, 0.5, 1)
    else
        return UnityEngine_Color(0.5859375, 0, 0.71875, 1)
    end
end

function PropUtility.GetGrayHSLColor()
    return UnityEngine_Color(0.5, 0, 0.5, 1)
end

-- 获得品质颜色值
function PropUtility.GetRGBColorValue(color)
    if color == 1 then
        return UnityEngine_Color(0.0313725, 0.901960, 0.294117, 1)
    elseif color == 2 then
        return UnityEngine_Color(0, 0.69411, 1, 1)
    elseif color == 3 then
        return UnityEngine_Color(0.737254, 0.309803, 0.917647, 1)
    elseif color == 4 then
        return UnityEngine_Color(1, 0.733333, 0.203921, 1)
    elseif color == 5 then
        return UnityEngine_Color(1, 0, 0, 1)
    else
        return UnityEngine_Color(1, 1, 1, 1)
    end
end


-- 自动设置颜色
function PropUtility.AutoSetColor(parentTransform, color)
    local unityColor = PropUtility.GetColorValue(color)
    local images = parentTransform:GetComponentsInChildren(typeof(UnityEngine.UI.Image))
    local count = images.Length
    for i = 0, count - 1 do
        images[i].color = unityColor
    end
end

-- 自动设置颜色
function PropUtility.AutoSetRGBColor(parentTransform, color)
    local unityColor = PropUtility.GetRGBColorValue(color)
    local images = parentTransform:GetComponentsInChildren(typeof(UnityEngine.UI.Image))
    local count = images.Length
    for i = 0, count - 1 do
        images[i].color = unityColor
    end
end


-----------------------------------------------------------------------
--- 道具是否足够
-----------------------------------------------------------------------
local function IsCardTypeEnough(itemId, itemNum)
    error("未实现卡牌判断")
end

local function IsEquipTypeEnough(itemId, itemNum)
    error("未实现装备判断")
end

local function IsSkillTypeEnough(itemId, itemNum)
    error("未实现技能判断")
end

local function IsGeneralItemTypeEnough(itemId, itemNum)
    local dataCacheMgr = utility.GetGame():GetDataCacheManager()
    local UserDataType = require "Framework.UserDataType"
    local itemBagData = dataCacheMgr:GetData(UserDataType.ItemBagData)
    return itemBagData:GetItemCountById(itemId) >= itemNum, nil, itemBagData:GetItemCountById(itemId)
end

local function IsCurrencyTypeEnough(itemId, itemNum)
    if itemId == kCurrencyId_Diamond then
        return utility.IsDiamondEnough(itemNum)
    elseif itemId == kCurrencyId_Coin then
        return utility.IsCoinEnough(itemNum)
    else
        error(string.format("未支持的货币类型: %s", itemId))
    end
end

local function IsCardCrapTypeEnough(itemId, itemNum)
    error("未实现卡牌碎片判断")
end

local function IsEquipmentCrapTypeEnough(itemId, itemNum)
    error("未实现装备碎片判断")
end

local function IsLevelTypeEnough(itemId, itemNum)
    error("未实现关卡判断")
end

local function IsLevelRewardTypeEnough(itemId, itemNum)
    error("未实现关卡奖励判断")
end

local function IsChapterTypeEnough(itemId, itemNum)
    error("未实现章节判断")
end

local function IsProtectPrincessBoxTypeEnough(itemId, itemNum)
    error("未实现保卫公主箱子判断")
end

local function IsFactoryBoxToFixTypeEnough(itemId, itemNum)
    error("未实现工厂箱子判断")
end

local function IsCorpsTypeEnough(itemId, itemNum)
    error("未实现的判断")
end

local function IsCorpsMapTypeEnough(itemId, itemNum)
    error("未实现的判断")
end

local function IsClubPropTypeEnough(itemId, itemNum)
    error("未实现的判断")
end

local ItemEnoughHandler = {
    [kStaticTableId_Card] = IsCardTypeEnough,
    [kStaticTableId_Equipment] = IsEquipmentCrapTypeEnough,
    [kStaticTableId_Skill] = IsSkillTypeEnough,
    [kStaticTableId_GeneralItem] = IsGeneralItemTypeEnough,
    [kStaticTableId_Currency] = IsCurrencyTypeEnough,
    [kStaticTableId_CardCrap] = IsCardCrapTypeEnough,
    [kStaticTableId_EquipmentCrap] = IsEquipmentCrapTypeEnough,
    [kStaticTableId_Level] = IsLevelTypeEnough,
    [kStaticTableId_LevelReward] = IsLevelRewardTypeEnough,
    [kStaticTableId_Chapter] = IsChapterTypeEnough,
    [kStaticTableId_ProtectPrincessBox] = IsProtectPrincessBoxTypeEnough,
    [kStaticTableId_FactoryBoxToFix] = IsFactoryBoxToFixTypeEnough,
    [kStaticTableId_Corps] = IsCorpsTypeEnough,
    [kStaticTableId_CorpsMap] = IsCorpsMapTypeEnough,
    [kStaticTableId_ClubProp] = IsClubPropTypeEnough
}


function PropUtility.IsItemEnough(itemId, itemNum)
    local staticTableUtility = require "Utils.StaticTableUtility"
    local itemMainType = staticTableUtility.GetTypeFromID(itemId)
    local handler = ItemEnoughHandler[itemMainType]
    if handler ~= nil then
        return handler(itemId, itemNum)
    end
    return nil
end




return PropUtility
