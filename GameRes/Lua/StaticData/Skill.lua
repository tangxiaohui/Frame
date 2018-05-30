
require "StaticData.Manager"

local SkillData = Class(LuaObject)

function SkillData:Ctor(id)
	local skillMgr = Data.Skill.Manager.Instance()
	self.data = skillMgr:GetObject(id)
	if self.data == nil then
		error(string.format("技能数据初始化失败, 技能ID: %d 不存在!", id))
	end
end

function SkillData:GetId()
	return self.data.id
end

function SkillData:GetRange()
	return self.data.range
end

--- ############################ ---
--- @@@@@@@@@ 战斗开始前 @@@@@@@@@ ---
--- ############################ ---

function SkillData:GetStage0Condition()
	return self.data.stage0Condition
end

function SkillData:GetStage0ConditionParam()
	return self.data.stage0ConditionParam
end

function SkillData:GetStage0Target()
	return self.data.stage0Target
end

function SkillData:GetStage0TargetParam()
	return self.data.stage0TargetParam
end

function SkillData:GetStage0ActionCondition()
	return self.data.stage0ActionCondition
end

function SkillData:GetStage0ActionConditionParam()
	return self.data.stage0ActionConditionParam
end

function SkillData:GetStage0Action()
	return self.data.stage0Action
end

function SkillData:GetStage0ActionParam1()
	return self.data.stage0ActionParam1	
end

function SkillData:GetStage0ActionParam2()
	return self.data.stage0ActionParam2
end

--- ############################ ---
--- @@@@@@@@@ 行动前 @@@@@@@@@ ---
--- ############################ ---

function SkillData:GetStage1Condition()
	return self.data.stage1Condition
end

function SkillData:GetStage1ConditionParam()
	return self.data.stage1ConditionParam
end

function SkillData:GetStage1Target()
	return self.data.stage1Target
end

function SkillData:GetStage1TargetParam()
	return self.data.stage1TargetParam
end

function SkillData:GetStage1ActionCondition()
	return self.data.stage1ActionCondition
end

function SkillData:GetStage1ActionConditionParam()
	return self.data.stage1ActionConditionParam
end

function SkillData:GetStage1Action()
	return self.data.stage1Action
end

function SkillData:GetStage1ActionParam1()
	return self.data.stage1ActionParam1
end

function SkillData:GetStage1ActionParam2()
	return self.data.stage1ActionParam2
end

--- ############################ ---
--- @@@@@@@@@ 行动时 @@@@@@@@@ ---
--- ############################ ---

function SkillData:GetStage2Target()
	return self.data.stage2Target
end

function SkillData:GetStage2TargetParam()
	return self.data.stage2TargetParam
end

function SkillData:GetStage2Action()
	return self.data.stage2Action
end

function SkillData:GetStage2ActionParam1()
	return self.data.stage2ActionParam1
end

function SkillData:GetStage2ActionParam2()
	return self.data.stage2ActionParam2
end

function SkillData:GetAttackCount()
	return self.data.attackCount
end


--- ############################ ---
--- @@@@@@@@@ 行动后 @@@@@@@@@ ---
--- ############################ ---

function SkillData:GetStage3Condition()
	return self.data.stage3Condition
end

function SkillData:GetStage3ConditionParam()
	return self.data.stage3ConditionParam
end

function SkillData:GetStage3Target()
	return self.data.stage3Target
end

function SkillData:GetStage3TargetParam()
	return self.data.stage3TargetParam
end

function SkillData:GetStage3ActionCondition()
	return self.data.stage3ActionCondition
end

function SkillData:GetStage3ActionConditionParam()
	return self.data.stage3ActionConditionParam
end

function SkillData:GetStage3Action()
	return self.data.stage3Action
end

function SkillData:GetStage3ActionParam1()
	return self.data.stage3ActionParam1
end

function SkillData:GetStage3ActionParam2()
	return self.data.stage3ActionParam2
end


--- ############################ ---
--- @@@@@@@@@ 受攻击时 @@@@@@@@@ ---
--- ############################ ---

function SkillData:GetStage4Condition()
	return self.data.stage4Condition
end

function SkillData:GetStage4ConditionParam()
	return self.data.stage4ConditionParam
end

function SkillData:GetStage4Target()
	return self.data.stage4Target
end

function SkillData:GetStage4TargetParam()
	return self.data.stage4TargetParam
end

function SkillData:GetStage4ActionCondition()
	return self.data.stage4ActionCondition
end

function SkillData:GetStage4ActionConditionParam()
	return self.data.stage4ActionConditionParam
end

function SkillData:GetStage4Action()
	return self.data.stage4Action
end

function SkillData:GetStage4ActionParam1()
	return self.data.stage4ActionParam1
end

function SkillData:GetStage4ActionParam2()
	return self.data.stage4ActionParam2
end

--- ############################ ---
--- @@@@@@@@@ 受攻击后 @@@@@@@@@ ---
--- ############################ ---

function SkillData:GetStage5Condition()
	return self.data.stage5Condition
end

function SkillData:GetStage5ConditionParam()
	return self.data.stage5ConditionParam
end

function SkillData:GetStage5Target()
	return self.data.stage5Target
end

function SkillData:GetStage5TargetParam()
	return self.data.stage5TargetParam
end

function SkillData:GetStage5ActionCondition()
	return self.data.stage5ActionCondition
end

function SkillData:GetStage5ActionConditionParam()
	return self.data.stage5ActionConditionParam
end

function SkillData:GetStage5Action()
	return self.data.stage5Action
end

function SkillData:GetStage5ActionParam1()
	return self.data.stage5ActionParam1
end

function SkillData:GetStage5ActionParam2()
	return self.data.stage5ActionParam2
end


--- ############################ ---
--- @@@@@@@@@  死亡时  @@@@@@@@@ ---
--- ############################ ---

function SkillData:GetStage6Condition()
	return self.data.stage6Condition
end

function SkillData:GetStage6ConditionParam()
	return self.data.stage6ConditionParam
end

function SkillData:GetStage6Target()
	return self.data.stage6Target
end

function SkillData:GetStage6TargetParam()
	return self.data.stage6TargetParam
end

function SkillData:GetStage6ActionCondition()
	return self.data.stage6ActionCondition
end

function SkillData:GetStage6ActionConditionParam()
	return self.data.stage6ActionConditionParam
end

function SkillData:GetStage6Action()
	return self.data.stage6Action
end

function SkillData:GetStage6ActionParam1()
	return self.data.stage6ActionParam1
end

function SkillData:GetStage6ActionParam2()
	return self.data.stage6ActionParam2
end


--- ############################ ---
--- @@@@@@@@@ 受击特效参数 @@@@@@@@@ ---
--- ############################ ---

-- 飞行物 飞行时间
function SkillData:GetEffectBulletTime()
	return self.data.effectBulletTime
end

-- 受击(未受伤害)特效ID
function SkillData:GetUnderAttackEffectSpecialID()
	return self.data.underAttackEffectSpecialID
end

-- 受击(伤害)特效ID
function SkillData:GetUnderAttackDamageEffectSpecialID()
	return self.data.underAttackDamageEffectSpecialID
end

-- 受击动画(特效)循环间隔
function SkillData:GetUnderAttackEffectInterval()
	return self.data.underAttackEffectInterval
end

-- 受击的挂点
function SkillData:GetUnderAttackParentName()
	return self.data.underAttackParentName
end

-- 技能的UI资源
function SkillData:GetUiAnimationResID()
	return self.data.uiAnimationResID
end


local SkillDataManagerClass = Class(DataManager)

local skillDataManager = SkillDataManagerClass.New(SkillData)
return skillDataManager
