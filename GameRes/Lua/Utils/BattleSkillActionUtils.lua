

require "Const"


local BattleSkillActionUtils = {}

-- 工具函数 --
local function GetBattleUnit(battleSkill)
	return battleSkill.luaGameObject
end

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

local function CanExecute(battleSkill, targetBattleUnit)
	local team1 = battleSkill.luaGameObject:GetParent() --BattleTeam
	local team2 = targetBattleUnit:GetParent()			--BattleTeam
	if team1 ~= team2 and team2:GetLastShield() ~= nil then
		return false
	end
	return true
end

local function ExecuteCondition(battleUnit, actionCondition, actionConditionParam)
	return require "Utils.BattleSkillConditionUtils".IsTrue(battleUnit, actionCondition, actionConditionParam)
end

-- 接口 用于实现每一个 action --
local ActionInterfaces = {}

-- @ 0 @ 无行为 --
ActionInterfaces[kSkillAction_None] = nil

-- @ 1 @ 增加状态(普通状态和状态免疫) --
ActionInterfaces[kSkillAction_AddState] = function(battleSkill, targetBattleUnit, targetType, stateId, turns)
	-- debug_print("@skill action", "技能发起者", battleSkill.luaGameObject:GetGameObject().name, "目标", targetBattleUnit:GetGameObject().name, "类型", targetType, "状态ID", stateId, "回合数", turns)
	targetBattleUnit:AddUnitState(stateId, nil, turns)
end

-- @ 2 @ 取消状态 --
ActionInterfaces[kSkillAction_CancelState] = function(battleSkill, targetBattleUnit, targetType, stateId)
	targetBattleUnit:RemoveUnitState(stateId)
end

-- @ 3 @ 增加攻击力系数 --
ActionInterfaces[kSkillAction_AddApRate] = function(battleSkill, targetBattleUnit, targetType, apRate)
	targetBattleUnit:AddExtraApRate(apRate)
end

-- @ 4 @ 增加攻击力点数 --
ActionInterfaces[kSkillAction_AddApValue] = function(battleSkill, targetBattleUnit, targetType, apValue)
	targetBattleUnit:AddExtraApValue(apValue)
end

-- @ 5 @ 增加防御力系数 --
ActionInterfaces[kSkillAction_AddDpRate] = function(battleSkill, targetBattleUnit, targetType, dpRate)
	targetBattleUnit:AddExtraDpRate(dpRate)
end

-- @ 6 @ 增加防御力点数 --
ActionInterfaces[kSkillAction_AddDpValue] = function(battleSkill, targetBattleUnit, targetType, dpValue)
	targetBattleUnit:AddExtraDpValue(dpValue)
end

-- @ 7 @ 增加血量上限系数 --
ActionInterfaces[kSkillAction_AddHpLimitRate] = function(battleSkill, targetBattleUnit, targetType, hpLimitRate)
	targetBattleUnit:AddExtraHpLimitRate(hpLimitRate)
end

-- @ 8 @ 增加血量上限点数 --
ActionInterfaces[kSkillAction_AddHpLimitValue] = function(battleSkill, targetBattleUnit, targetType, hpLimitValue)
	targetBattleUnit:AddExtraHpLimitValue(hpLimitValue)
end

-- @ 9 @ 增加速度系数 --
ActionInterfaces[kSkillAction_AddSpeedRate] = function(battleSkill, targetBattleUnit, targetType, speedRate)
	targetBattleUnit:AddExtraSpeedRate(speedRate)
end

-- @ 10 @ 增加速度点数 --
ActionInterfaces[kSkillAction_AddSpeedValue] = function(battleSkill, targetBattleUnit, targetType, speedValue)
	-- debug_print("@skill action", "增加速度点数", targetBattleUnit:GetGameObject().name, "增速前", targetBattleUnit:GetSpeed())
	targetBattleUnit:AddExtraSpeedValue(speedValue)
	-- debug_print("@skill action", "增加速度点数", targetBattleUnit:GetGameObject().name, "增速后", targetBattleUnit:GetSpeed())
end

-- @ 11 @ 增加暴击率 --
ActionInterfaces[kSkillAction_AddCritRate] = function(battleSkill, targetBattleUnit, targetType, critRate)
	targetBattleUnit:AddExtraCritRate(critRate)
end

-- @ 12 @ 增加暴击伤害系数 --
ActionInterfaces[kSkillAction_AddCritDamageRate] = function(battleSkill, targetBattleUnit, targetType, critDamageRate)
	targetBattleUnit:AddExtraCritDamageRate(critDamageRate)
end

-- @ 13 @ 增加抗暴率 --
ActionInterfaces[kSkillAction_AddDecritRate] = function(battleSkill, targetBattleUnit, targetType, decritRate)
	targetBattleUnit:AddExtraDecritRate(decritRate)
end

-- @ 14 @ 增加闪避率 --
ActionInterfaces[kSkillAction_AddAvoidRate] = function(battleSkill, targetBattleUnit, targetType, avoidRate)
	targetBattleUnit:AddExtraAvoidRate(avoidRate)
end

-- @ 15 @ 增加命中率 --
ActionInterfaces[kSkillAction_AddHitRate] = function(battleSkill, targetBattleUnit, targetType, hitRate)
	targetBattleUnit:AddExtraHitRate(hitRate)
end

-- @ 16 @ 增加吸血率 --
ActionInterfaces[kSkillAction_AddVamRate] = function(battleSkill, targetBattleUnit, targetType, vamRate)
	targetBattleUnit:AddExtraVamRate(vamRate)
end

-- @ 17 @ 增加当前血量点数 --
ActionInterfaces[kSkillAction_AddHpValue] = function(battleSkill, targetBattleUnit, targetType, hpValue)
	if hpValue > 0 then
		targetBattleUnit:AddHp(hpValue)
	else
		targetBattleUnit:LoseHp(-hpValue)
	end
end

-- @ 18 @ 增加当前血量系数 -- 
ActionInterfaces[kSkillAction_AddHpRate] = function(battleSkill, targetBattleUnit, targetType, hpRate)
	debug_print("增加血量系数", targetBattleUnit:GetGameObject().name, hpRate)
	local hpValue = math.floor(targetBattleUnit:GetMaxHp() * hpRate / 100)
	if hpValue > 0 then
		targetBattleUnit:AddHp(hpValue)
	else
		targetBattleUnit:LoseHp(-hpValue)
	end
end

-- @ 19 @ 增加普攻额外伤害点数 --
ActionInterfaces[kSkillAction_AddAttackDamageValue] = function(battleSkill, targetBattleUnit, targetType, attackDamageValue)
	targetBattleUnit:AddExtraAttackDamageValue(attackDamageValue)
end

-- @ 20 @ 增加技攻额外伤害点数 --
ActionInterfaces[kSkillAction_AddSkillDamageValue] = function(battleSkill, targetBattleUnit, targetType, skillDamageValue)
	targetBattleUnit:AddExtraSkillDamageValue(skillDamageValue)
end

-- @ 21 @ 伤害系数 --
ActionInterfaces[kSkillAction_AddDamageRate] = function(battleSkill, targetBattleUnit, targetType, damageRate)
	-- debug_print("@伤害系数", targetBattleUnit:GetGameObject().name, damageRate)
	targetBattleUnit:SetSkillDamageRate(damageRate)
end

-- @ 22 @ 满血复活 --
ActionInterfaces[kSkillAction_Relive] = function(battleSkill, targetBattleUnit, targetType)
	targetBattleUnit:AddHp(targetBattleUnit:GetMaxHp(), false)
end

-- @ 23 @ 伤害系数随机 param1下限 param2上限
ActionInterfaces[kSkillAction_RandomRangeDamageRate] = function(battleSkill, targetBattleUnit, targetType, startDamageRate, endDamageRate)
	-- debug_print("@伤害系数随机", targetBattleUnit:GetGameObject().name, startDamageRate, endDamageRate)
	local probability = require "Utils.Probability"
	local damageRate = probability:RandomRange(startDamageRate, endDamageRate)
	targetBattleUnit:SetSkillDamageRate(damageRate)
end

-- @ 25 @ 根据生命来设置伤害系数  (damageRate = rate + hpRate / 5)
ActionInterfaces[kSkillAction_SetDamageRateByHp] = function(battleSkill, targetBattleUnit, targetType, rate)
	local damageRate = math.floor(rate + targetBattleUnit:GetHpRate() / 5)
	targetBattleUnit:SetSkillDamageRate(damageRate)
end

-- @ 26 @ 根据攻击来设置伤害系数  (damageRate = rate + sqrt(atk)/5)
ActionInterfaces[kSkillAction_SetDamageRateByAp] = function(battleSkill, targetBattleUnit, targetType, rate)
	local damageRate = math.floor(rate + math.sqrt(targetBattleUnit:GetAp()) / 5)
	targetBattleUnit:SetSkillDamageRate(damageRate)
end

-- @ 27 @ 根据闪避率来设置伤害系数 (damageRate = rate + avoidRate)
ActionInterfaces[kSkillAction_SetDamageRateByAvoidRate] = function(battleSkill, targetBattleUnit, targetType, rate)
	local damageRate = math.floor(rate + targetBattleUnit:GetAvoidRate())
	targetBattleUnit:SetSkillDamageRate(damageRate)
end

-- @ 28 @ 根据防御来设置伤害系数 (damageRate = rate + dp/125)
ActionInterfaces[kSkillAction_SetDamageRateByDp] = function(battleSkill, targetBattleUnit, targetType, rate)
	local damageRate = math.floor(rate + targetBattleUnit:GetDp() / 125)
	targetBattleUnit:SetSkillDamageRate(damageRate)
end

-- @ 30 @ 增加减伤系数
ActionInterfaces[kSkillAction_DamageReductionRate] = function(battleSkill, targetBattleUnit, targetType, damageRate)
	-- debug_print("@@ 减伤系数::", damageRate)
	targetBattleUnit:SetDamageReductionRate(damageRate)
end

-- @ 31 @ 增加怒气
ActionInterfaces[kSkillAction_AddRage] = function(battleSkill, targetBattleUnit, targetType, rage)
	debug_print("@rage: 技能行为 增加怒气", rage, "点", targetBattleUnit:GetGameObject().name)
	if rage < 0 and targetBattleUnit:IsImmuneToState(kStateFlag_SubRage) then
		debug_print("@rage: 技能行为", "免疫减怒")
		return
	end
	targetBattleUnit:AddRage(rage)
end

-- @ 32 @ 选择前排时伤害系数
ActionInterfaces[kSkillAction_DamageRateOnFrontRow] = function(battleSkill, targetBattleUnit, targetType, damageRate)
	if targetType == kSkillTarget_FrontrowMembers or targetType == kSkillTarget_FrontrowFoes then
		targetBattleUnit:SetSkillDamageRate(damageRate)
	end
end

-- @ 33 @ 选择后排时伤害系数
ActionInterfaces[kSkillAction_DamageRateOnBackRow] = function(battleSkill, targetBattleUnit, targetType, damageRate)
	if targetType == kSkillTarget_BackrowMembers or targetType == kSkillTarget_BackrowFoes then
		targetBattleUnit:SetSkillDamageRate(damageRate)
	end
end

-- @ 34 @ 伤害翻倍
ActionInterfaces[kSkillAction_DoubleDamage] = function(battleSkill, targetBattleUnit, targetType)
	local damageRate = targetBattleUnit:GetSkillDamageRate() * 2
	targetBattleUnit:SetSkillDamageRate(damageRate)
end

-- @ 35 @ 决斗（双方由发起方开始互相普攻直到一方死亡，param1为普攻最大次数） (只对剑八)
ActionInterfaces[kSkillAction_FightRepeatly] = function(battleSkill, targetBattleUnit, targetType)
	
end

-- @ 36 @ 根据（1-血量%）执行系数操作，param1为行为，2为增加量=param2*（100-血量%）
ActionInterfaces[kSkillAction_AddPropertyByHpPercent] = function(battleSkill, targetBattleUnit, targetType, actionType, param2)
	ActionInterfaces[actionType](battleSkill, targetBattleUnit, targetType, param2 * (100-targetBattleUnit:GetHpRate()))
end

-- @ 37 @ 根据当前敌人数量决定执行系数操作，param1为行为，2为增加量=param2*（敌人数量）
ActionInterfaces[kSkillAction_AddPropertyByFoeCount] = function(battleSkill, targetBattleUnit, targetType, actionType, param2)
	ActionInterfaces[actionType](battleSkill, targetBattleUnit, targetType, 60 + param2 * GetAliveUnitCount(targetBattleUnit:GetFoes()))
end 

-- @ 38 @ 在自己场上唤醒一个盾，盾的等级星级颜色与召唤者相同
ActionInterfaces[kSkillAction_AddShield] = function(battleSkill, targetBattleUnit, targetType)
	-- 不使用! --
end

-- @ 39 @ 额外伤害(参数是指定伤害系数)
ActionInterfaces[kSkillAction_ExtraDamage] = function(battleSkill, targetBattleUnit, targetType, damageRate)
	-- debug_print("@@skill action", "额外伤害", damageRate, "自己", battleSkill.luaGameObject:GetGameObject().name, "目标", targetBattleUnit:GetGameObject().name)	

	-- 计算伤害
	local damageValue, isCritDamage = battleSkill.unitController:CalculateDamage(targetBattleUnit, damageRate)

	-- 发送伤害记录
	local messageGuids = require "Framework.Business.MessageGuids"
	require "Utils.Utility".GetGame():DispatchEvent(messageGuids.FightAddDamageRecord, nil, battleSkill.luaGameObject, damageValue)
	
	debug_print("额外伤害@@", damageValue, isCritDamage, battleSkill.luaGameObject:GetGameObject().name, targetBattleUnit:GetGameObject().name)

	-- 失去HP并在死亡时倒下并重置状态
	targetBattleUnit:LoseHp(damageValue, isCritDamage)
	targetBattleUnit:HandleUnitDie(true, false)
end

-- @ 40 @ 按最大血量的百分比 改变当前血量(但不会死亡!)
ActionInterfaces[kSkillAction_LoseHpByMaxRate] = function(battleSkill, targetBattleUnit, targetType, hpRate)
	local hpToLose = math.floor(targetBattleUnit:GetMaxHp() * hpRate / 100)
	local currentHp = targetBattleUnit:GetCurHp()
	-- debug_print("扣除血量百分比", hpToLose, currentHp)
	if hpToLose >= currentHp then
		targetBattleUnit:LoseHp(currentHp - 1)
	else
		targetBattleUnit:LoseHp(hpToLose)
	end
end

-- @ 41 @ 设置为必暴击
ActionInterfaces[kSkillAction_MarkAsMustBeCrit] = function(battleSkill, targetBattleUnit, targetType)
	-- debug_print("@必暴击", targetBattleUnit:GetGameObject().name)
	targetBattleUnit:MarkAsMustBeCrit()
end

-- @ 42 @ 设置为必命中
ActionInterfaces[kSkillAction_MarkAsMustBeHitMark] = function(battleSkill, targetBattleUnit, targetType)
	-- debug_print("@必命中", targetBattleUnit:GetGameObject().name)
	targetBattleUnit:MarkAsMustBeHitMark()
end

-- @ 43 @ 按自己指定的伤害系数 来治疗target
ActionInterfaces[kSkillAction_HealByDamageRate] = function(battleSkill, targetBattleUnit, targetType, damageRate)
	local hpValue = battleSkill.luaGameObject:CalculateHeal(damageRate)
	-- debug_print("@治疗1", "自己", battleSkill.luaGameObject:GetGameObject().name, "目标", targetBattleUnit:GetGameObject().name, "伤害系数", damageRate, "加血量", hpValue)
	targetBattleUnit:AddHp(hpValue)
end

-- @ 44 @ 按自己的最大血上限*rate 来治疗 target
ActionInterfaces[kSkillAction_HealByMaxHpRateSelf] = function(battleSkill, targetBattleUnit, targetType, hpRate)
	local hpValue = math.floor(battleSkill.luaGameObject:GetMaxHp() * math.abs(hpRate) / 100)
	-- debug_print("@治疗2", "自己", battleSkill.luaGameObject:GetGameObject().name, "目标", targetBattleUnit:GetGameObject().name, "比率", hpRate, "加血量", hpValue)
	targetBattleUnit:AddHp(hpValue)
end

-- @ 45 @ 添加状态免疫
ActionInterfaces[kSkillAction_AddStateImmunity] = function(battleSkill, targetBattleUnit, targetType, stateId)
	targetBattleUnit:AddStateImmunity(stateId)
end

-- @ 46 @ 移除状态免疫
ActionInterfaces[kSkillAction_RemoveStateImmunity] = function(battleSkill, targetBattleUnit, targetType, stateId)
	targetBattleUnit:RemoveStateImmunity(stateId)
end

-- 执行一个行为 --
function BattleSkillActionUtils.Execute(battleSkill, targetInfo, actionCondition, actionConditionParam, actionId, actionParam1, actionParam2)
	local routine = ActionInterfaces[actionId]
	if routine ~= nil then
		local targets = targetInfo:GetTargets()
		local targetType = targetInfo:GetTargetType()
		local targetCount = #targets

		for i = 1, targetCount do
			-- debug_print("@skill action", "Execute", "canExecute", CanExecute(battleSkill, targets[i]), "自己", battleSkill.luaGameObject:GetGameObject().name, "目标", targets[i]:GetGameObject().name, actionCondition, actionConditionParam, actionId, actionParam1, actionParam2)
			if CanExecute(battleSkill, targets[i]) and ExecuteCondition(targets[i], actionCondition, actionConditionParam) then
				routine(battleSkill, targets[i], targetType, actionParam1, actionParam2)
			end
		end
	end
end


return BattleSkillActionUtils
