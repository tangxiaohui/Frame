
require "Const"

local BattleSkillConditionUtils = {}

-- 工具函数 --
local function GetAliveUnitCount(units)
	local currentMemberCount = 0

	local maxLoopCount = table.maxn(units)
	for i = 1, maxLoopCount do
		if units[i] ~= nil and units[i]:IsAlive() then
			currentMemberCount = currentMemberCount + 1
		end
	end

	return currentMemberCount
end

local function AnyUnit(units, filterfunc)
	local maxLoopCount = table.maxn(units)
	for i = 1, maxLoopCount do
		if units[i] ~= nil and units[i]:IsAlive() and filterfunc(units[i]) then
			return true
		end
	end
	return false
end

-- 接口 用于实现每一个condition --
local ConditionInterfaces = {}

-- @@ 0 @@ 无条件触发 -- 
ConditionInterfaces[kSkillCondition_Uncondition] = function()
	return true
end

-- @@ 1 @@ 自己生命值小于等于% (参数 填整数 百分比)  (未测试 和 21的功能是一样的! 以后要重构掉!) --
ConditionInterfaces[kSkillCondition_HpOfSelfIsLessOrEqualToPercent] = function(battleUnit, conditionHpRate)
	local hpRate = battleUnit:GetCurHp() / battleUnit:GetMaxHp() * 100
	return hpRate <= conditionHpRate
end

-- @@ 2 @@ 受到状态 (参数是 state id) (未测试) --
ConditionInterfaces[kSkillCondition_State] = function(battleUnit, stateId)
	return battleUnit:HasUnitState(stateId)
end

-- @@ 3 @@ 装备道具 (参数是 装备id) (未测试) --
ConditionInterfaces[kSkillCondition_Equip] = function(battleUnit, equipId)
	-- TODO 判断当前人物是否拥有某件装备 --
	return true
end

-- @@ 4 @@ 己方人数大于等于时 (未测试) --
ConditionInterfaces[kSkillCondition_GreaterOrEqualToMemberCount] = function(battleUnit, memberCount)
	local members = battleUnit:GetMembers()
	local currentMemberCount = GetAliveUnitCount(members)
	return currentMemberCount >= memberCount
end

-- @@ 5 @@ 己方人数小于等于时 (未测试) --
ConditionInterfaces[kSkillCondition_LessOrEqualToMemberCount] = function(battleUnit, memberCount)
	local members = battleUnit:GetMembers()
	local currentMemberCount = GetAliveUnitCount(members)
	return currentMemberCount <= memberCount
end

-- @@ 6 @@ 敌方人数大于等于时 (未测试) --
ConditionInterfaces[kSkillCondition_GreaterOrEqualToFoeCount] = function(battleUnit, foeCount)
	local foes = battleUnit:GetFoes()
	local currentFoeCount = GetAliveUnitCount(foes)
	return currentFoeCount >= foeCount
end

-- @@ 7 @@ 敌方人数小于等于时 (未测试) --
ConditionInterfaces[kSkillCondition_LessOrEqualToFoeCount] = function(battleUnit, foeCount)
	local foes = battleUnit:GetFoes()
	local currentFoeCount = GetAliveUnitCount(foes)
	return currentFoeCount <= foeCount
end

-- @@ 8 @@ 己方有单位生命值小于等于%时 (包括自己) (未测试) --
ConditionInterfaces[kSkillCondition_HpOfMembersLessOrEqualToPercent] = function(battleUnit, hpRate)
	local members = battleUnit:GetMembers()
	return AnyUnit(members, function(unit)
		return unit:GetHpRate() <= hpRate
	end)
end

-- @@ 9 @@ 己方场上存在指定角色 (参数是角色id) (未测试) --
ConditionInterfaces[kSkillCondition_RoleOfMembers] = function(battleUnit, roleId)
	local members = battleUnit:GetMembers()
	return AnyUnit(members, function(unit)
		return unit:GetId() == roleId
	end)
end

-- @@ 10 @@ 击杀--
ConditionInterfaces[kSkillCondition_Kill] = function(battleUnit)
	return battleUnit:IsKiller()
end

-- @@ 11 @@ 命中--
ConditionInterfaces[kSkillCondition_Hit] = function(battleUnit)
	return battleUnit:HasHit()
end

-- @@ 12 @@ 闪避--
ConditionInterfaces[kSkillCondition_Avoid] = function(battleUnit)
	return battleUnit:HasAvoided()
end

-- @@ 13 @@ 暴击 --
ConditionInterfaces[kSkillCondition_Crit] = function(battleUnit)
	return battleUnit:HasCrited()
end

-- @@ 14 @@ 刚才的目标的种族 (参数是 种族) (未测试) --
ConditionInterfaces[kSkillCondition_RaceOfTargets] = function(battleUnit, race)
	-- TODO 刚才目标 种族的判断 --
	return false
end

-- @@ 15 @@ 刚才的目标的属性 (参数是 主属性) (未测试) --
ConditionInterfaces[kSkillCondition_MajorAttrOfTargets] = function(battleUnit, majorAttr)
	-- TODO 刚才目标的 主属性的判断 --
	return false
end

-- @@ 16 @@ 刚才的目标的hp小于等于% (参数是 hp rate) (未测试) --
ConditionInterfaces[kSkillCondition_HpOfTargetsIsLessOrEqualToPercent] = function(battleUnit, hpRate)
	-- TODO 刚才的目标的hp小于等于%的判断 --
	return false
end

-- @@ 17 @@ 敌方有存在指定主属性的人 (参数是 attr)
ConditionInterfaces[kSkillCondition_AttributeOfFoesExist] = function(battleUnit, attr)
	local foes = battleUnit:GetFoes()
	return AnyUnit(foes, function(unit)
		return unit:GetMajorAttr() == attr
	end)
end

-- @@ 18 @@ 敌方有存在指定种族的人 (参数是 race)
ConditionInterfaces[kSkillCondition_RaceOfFoeExist] = function(battleUnit, race)
	local foes = battleUnit:GetFoes()
	return AnyUnit(foes, function(unit)
		return unit:GetRace() == race
	end)
end

-- @@ 20 @@ 概率触发 (参数是 概率) --
ConditionInterfaces[kSkillCondition_Probability] = function(battleUnit, rate)
	debug_print("@@battleUnit", battleUnit:GetGameObject().name, "参数概率", rate, debug.traceback())
	local probability = require "Utils.Probability"
	return probability:Hit(rate)
	-- local b = probability:Hit(rate)
	-- debug_print("@@battleUnit", battleUnit:GetGameObject().name, "参数概率", rate, b)
	-- return b
end

-- @@ 21 @@ 当前BattleUnit血量%是否小于等于hpRate
ConditionInterfaces[kSkillCondition_HpRateLE] = function(battleUnit, hpRate)
	debug_print("@当前血量小于", hpRate, "%", "目标", battleUnit:GetGameObject().name)
	return battleUnit:GetHpRate() <= hpRate
end

-- @@ 22 @@ 当前BattleUnit的血量%是否大于等于hpRate
ConditionInterfaces[kSkillCondition_HpRateBE] = function(battleUnit, hpRate)
	return battleUnit:GetHpRate() >= hpRate
end

-- @@ 30 @@ 当前battleUnit是否使用的是技能
ConditionInterfaces[kSkillCondition_UsingSkill] = function(battleUnit)
	return battleUnit:IsUsingSkill()
end

-- @@ 31 @@ 当前battleUnit是否使用的是普攻
ConditionInterfaces[kSkillCondition_UsingAttack] = function(battleUnit)
	return not battleUnit:IsUsingSkill()
end

-- @@ 32 @@ 当前battleUnit是否还活着
ConditionInterfaces[kSkillCondition_IsAlive] = function(battleUnit)
	return battleUnit:IsAlive()
end

-- 外部接口 用于测试技能 Condition 是否为true
function BattleSkillConditionUtils.IsTrue(battleUnit, conditionId, conditionParam)
	local routine = ConditionInterfaces[conditionId]
	if routine ~= nil then
		return routine(battleUnit, conditionParam)
	end
	return false
end


return BattleSkillConditionUtils
