--
-- User: fenghao
-- Date: 15/07/2017
-- Time: 2:47 AM
--

require "Const"
require "Collection.OrderedDictionary"

local RoleUtility = {}

-- 获取开启的天赋数量 --
function RoleUtility.GetBasicTalentCount(color, stage)
    if color < KCardColorType_Blue then
        return 0
    end

    if color < KCardColorType_Purple then
        return 1
    end

    if stage < 2 then
        return 2
    end

    if stage < 4 then
        return 3
    end

    if stage < 6 then
        return 4
    end

    return 5
end


-- 获取当前天赋的信息(代价很昂贵, 仅仅获取一次就行!!) --
function RoleUtility.GetRoleTalents(talents, type)
    local RoleTalentsClass = require "Battle.Talent.RoleTalents"
    local retRoleTalents = RoleTalentsClass.New()
    
    if talents ~= nil then

        for i = 1, #talents do
            local talentID = talents[i]
            if talentID > 0 then
                local talentData = require "StaticData.Talent.RoleTalent":GetData(talentID)
                if talentData ~= nil and talentData:GetTalentType() == type then
                    retRoleTalents:Add(talentData)
                end
            end
        end

    end

    return retRoleTalents
end

-- 获取小宇宙属性
function RoleUtility.GetAllZodiacProperties(role, propertySet)
    propertySet = propertySet or require "Game.Property.PropertySet".New()
    local zodiacStateMgr = require "StaticData.Zodiac.ZodiacState"
    local spots = role:GetActivedZodiacSpot()
    if spots == nil then return end
    for i = 1, #spots do
        zodiacStateMgr:GetData(spots[i]):GetAllProperties(propertySet)
    end
    return propertySet
end

local function GetUserRoleData(uid)
    local UserDataType = require "Framework.UserDataType"
    local dataCacheMgr = require "Utils.Utility".GetGame():GetDataCacheManager()
    local cardBagData = dataCacheMgr:GetData(UserDataType.CardBagData)
    if cardBagData == nil then
        return nil
    end
    return cardBagData:GetRoleByUid(uid)
end

local function GetPlayerLevel()
    return require "Utils.Utility".GetCurrentPlayerLevel()
end

-- 1. 卡牌等级 是否小于 玩家等级
local function IsRoleLevelLessThanPlayerLevel(uid)
    local role = GetUserRoleData(uid)
    if role == nil then return false end
    return role:GetLv() < GetPlayerLevel()
end

-- 2. 是否拥有三种经验电池
local function HasAnyExpBattery()
    local propUtility = require "Utils.PropUtility"
    return (propUtility.IsItemEnough(kItemId_NormalEnergyExpBattery,1)) or
           (propUtility.IsItemEnough(kItemId_HighEnergyExpBattery,1)) or 
           (propUtility.IsItemEnough(kItemId_SuperEnergyExpBattery,1))
end

function RoleUtility.CanLevelUp(uid)
    return IsRoleLevelLessThanPlayerLevel(uid) and HasAnyExpBattery()
end

return RoleUtility
