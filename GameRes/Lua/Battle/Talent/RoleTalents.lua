--
-- User: fenghao
-- Date: 15/07/2017
-- Time: 1:16 PM
--

require "Object.LuaObject"
require "Collection.OrderedDictionary"

local RoleTalents = Class(LuaObject)

function RoleTalents:Ctor()
    self.allTalents = OrderedDictionary.New()
end

function RoleTalents:Add(talentData)
    -- 数据为nil 不加入
    if talentData == nil then
        return
    end

    local talentID = talentData:GetId()
    -- 重复不加入
    if self.allTalents:Contains(talentID) then
        return
    end

    -- 加入天赋数据 --
    self.allTalents:Add(talentID, talentData)
end

function RoleTalents:Clear()
    self.allTalents:Clear()
end

function RoleTalents:Get(pos)
	return self.allTalents:GetEntryByIndex(pos)
end

function RoleTalents:Count()
    return self.allTalents:Count()
end

-- 是否存在天赋ID 
function RoleTalents:Exists(talentID)
	return self.allTalents:Contains(talentID)
end

-- 是否具有对某状态免疫 --
function RoleTalents:IsImmuneToState(id)
    if id > 0 then
        local count = self:Count()
        for i = 1, count do
            local talentData = self.allTalents:GetEntryByIndex(i)
            if talentData ~= nil and talentData:GetImmunityID() == id then
                return true
            end
        end
    end
    return false
end

function RoleTalents:GetExtendIDs()
    local extendIds = {}
    local count = self:Count()
    for i = 1, count do
        local talentData = self.allTalents:GetEntryByIndex(i)
        if talentData ~= nil and talentData:GetExtendID() > 0 then
            extendIds[#extendIds + 1] = talentData:GetExtendID()
        end
    end

    return extendIds
end

function RoleTalents:GetTalentIDs()
	return self.allTalents:GetKeys()
end

--- >>> add func 实现 <<< ---                                                                                                                     xz

local function AddAp_Impl(talentData)
    return talentData:GetAp()
end

local function AddApRate_Impl(talentData)
    return talentData:GetApRate()
end

local function AddHpLimit_Impl(talentData)
    return talentData:GetHpLimit()
end

local function AddHpLimitRate_Impl(talentData)
    return talentData:GetHpLimitRate()
end

local function AddDp_Impl(talentData)
    return talentData:GetDp()
end

local function AddAngerNum_Impl(talentData)
    return talentData:GetAngerNum()
end

local function AddCritRate_Impl(talentData)
    return talentData:GetCritRate()
end

local function AddCritDamage_Impl(talentData)
    return talentData:GetCritDamage()
end

local function AddAvoidRate_Impl(talentData)
    return talentData:GetAvoidRate()
end

local function AddVamRate_Impl(talentData)
    return talentData:GetVamRate()
end

local function AddAttackDamage_Impl(talentData)
    return talentData:GetAttackDamage()
end

local function AddSkillDamage_Impl(talentData)
    return talentData:GetSkillDamage()
end

local function AddDecritRate_Impl(talentData)
    return talentData:GetDecritRate()
end

local function AddSpeed_Impl(talentData)
    return talentData:GetSpeed()
end

local function AddHitRate_Impl(talentData)
    return talentData:GetHitRate()
end
---  add func end  ---

-- 获取数值的总和的通用实现 --
local function GetTotalValue(self, filterfunc, addFunc)
    local total = 0
    local count = self:Count()
    local flag
	
	-- print("@@@@@", count)
    for i = 1, count do
        local talentData = self.allTalents:GetEntryByIndex(i)
        if talentData ~= nil then
            flag = true
			
			if filterfunc ~= nil and type(filterfunc) == "function" then
				flag = filterfunc(talentData)
			end

            -- 为真才计算 --
            if flag then
                total = total + addFunc(talentData)
				-- print("@@@@@ ", total)
            end

        end
    end
    return total
end

-- 获取总的攻击附加值
function RoleTalents:GetTotalAp(filterfunc)
    return GetTotalValue(self, filterfunc, AddAp_Impl)
end

-- 获取总的攻击系数
function RoleTalents:GetTotalApRate(filterfunc)
    return GetTotalValue(self, filterfunc, AddApRate_Impl)
end

-- 获得总的血量上限附加值
function RoleTalents:GetTotalHpLimit(filterfunc)
    return GetTotalValue(self, filterfunc, AddHpLimit_Impl)
end

-- 获得总的血量上限系数
function RoleTalents:GetTotalHpLimitRate(filterfunc)
    return GetTotalValue(self, filterfunc, AddHpLimitRate_Impl)
end

-- 获得总的防御附加值
function RoleTalents:GetTotalDp(filterfunc)
    return GetTotalValue(self, filterfunc, AddDp_Impl)
end

-- 获得总的怒气值
function RoleTalents:GetTotalAngerNum(filterfunc)
    return GetTotalValue(self, filterfunc, AddAngerNum_Impl)
end

-- 获得总的暴击率
function RoleTalents:GetTotalCritRate(filterfunc)
    return GetTotalValue(self, filterfunc, AddCritRate_Impl)
end

-- 获得总的暴击伤害系数
function RoleTalents:GetTotalCritDamage(filterfunc)
    return GetTotalValue(self, filterfunc, AddCritDamage_Impl)
end

-- 获得总的闪避率
function RoleTalents:GetTotalAvoidRate(filterfunc)
    return GetTotalValue(self, filterfunc, AddAvoidRate_Impl)
end

-- 获得总的吸血率
function RoleTalents:GetTotalVamRate(filterfunc)
    return GetTotalValue(self, filterfunc, AddVamRate_Impl)
end

-- 获取总的普攻附加伤害值
function RoleTalents:GetTotalAttackDamage(filterfunc)
    return GetTotalValue(self, filterfunc, AddAttackDamage_Impl)
end

-- 获取总的技攻附加伤害值
function RoleTalents:GetTotalSkillDamage(filterfunc)
    return GetTotalValue(self, filterfunc, AddSkillDamage_Impl)
end

-- 获取总的抗暴率
function RoleTalents:GetTotalDecritRate(filterfunc)
    return GetTotalValue(self, filterfunc, AddDecritRate_Impl)
end

-- 获取总速度附加值
function RoleTalents:GetTotalSpeed(filterfunc)
    return GetTotalValue(self, filterfunc, AddSpeed_Impl)
end

-- 获取总命中率
function RoleTalents:GetTotalHitRate(filterfunc)
    return GetTotalValue(self, filterfunc, AddHitRate_Impl)
end



function RoleTalents:ToString()
	return string.format("ap=%d, apRate=%d, hpLimit=%d, hpLimitRate=%d, dp=%d, anger=%d, critRate=%d, critDamage=%d, avoidRate=%d, vamRate=%d, attack damage=%d, skill damage=%d, decritRate=%d, speed=%d, hitRate=%d",
			self:GetTotalAp(),
			self:GetTotalApRate(),
			self:GetTotalHpLimit(),
			self:GetTotalHpLimitRate(),
			self:GetTotalDp(),
			self:GetTotalAngerNum(),
			self:GetTotalCritRate(),
			self:GetTotalCritDamage(),
			self:GetTotalAvoidRate(),
			self:GetTotalVamRate(),
			self:GetTotalAttackDamage(),
			self:GetTotalSkillDamage(),
			self:GetTotalDecritRate(),
			self:GetTotalSpeed(),
			self:GetTotalHitRate()
	)
end

return RoleTalents
