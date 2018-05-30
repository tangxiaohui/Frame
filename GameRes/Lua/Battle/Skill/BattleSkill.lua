require "Object.LuaComponent"
require "Const"
local utility = require "Utils.Utility"

BattleSkill = Class(LuaComponent)

function BattleSkill:Ctor(data)
	self.data = data
end

function BattleSkill:ToString()
	return "战斗技能, " .. self.data:ToString()
end

-- 获取攻击次数
function BattleSkill:GetAttackCount()
	return self.data:GetAttackCount()
end

-- 初始化组件 --
function BattleSkill:OnSetLuaGameObject()
	if self.luaGameObject == nil then
		print("BattleSkill:Initialize failed, cause luaGameObject is nil.")
		return
	end

	local owner = self.luaGameObject
	self.unitSelector = owner:GetComponent("BattleUnitSelector")
	self.unitController = owner:GetComponent("BattleUnitController")
	self.unitMotion = owner:GetComponent("MotionController")
end

-->>>>>> 工具函数 <<<<<<--

-- 获取List的Count --
local function GetListCount(list)
	if list ~= nil then
		return list.Count
	end
	return 0
end

-- 获取值从C#数组中 --
local function GetValueFromList(list, index)
	if GetListCount(list) > 0 then
		return list[index]
	end
	return 0
end

-- 检查是否相等
local function CheckSame(value1, value2, errorMsg)
	if value1 > 0 and value1 ~= value2 then
		error(errorMsg)
	end
end





local function CanUseAction(self, conditionList, conditionParamList, checkEmptyList)
	-- TODO 检查 conditionList 和 conditionParamList 长度相等 --
	local battleSkillConditionUtils = require "Utils.BattleSkillConditionUtils"

	if GetListCount(conditionList) == 0 and checkEmptyList then
		return false
	end

	-- 获取 循环次数 --
	local loopCount = GetListCount(conditionList) - 1
	local param
	for i = 0, loopCount do
		param = GetValueFromList(conditionParamList, i)
		if not battleSkillConditionUtils.IsTrue(self.luaGameObject, conditionList[i], param) then
			return false
		end
	end 

	return true
end

-- @@ 一对一 @@ --
local function ExecuteActionInOneToOne(self, targetInfos, actionConditionList, actionConditionParamList, actionList, actionParam1List, actionParam2List)

	local battleSkillActionUtils = require "Utils.BattleSkillActionUtils"
	local actionListCount = GetListCount(actionList)

	-- 没有要执行的 action --
	if actionListCount == 0 then return end

	-- 目标组个数
	local targetGroupCount = #targetInfos

	-- 没有任何目标组 不用执行 --
	if targetGroupCount == 0 then return end

	-- >>> 检查参数是否错误 <<< --
	CheckSame(targetGroupCount, actionListCount, string.format("目标组和行为个数不一致! id = %d", self:GetId()))
	CheckSame(GetListCount(actionConditionList), actionListCount, string.format("行为参数和行为执行条件个数不一致! id = %d", self:GetId()))
	CheckSame(GetListCount(actionConditionParamList), actionListCount, string.format("行为参数和行为执行条件参数个数不一致! id = %d", self:GetId()))
	CheckSame(GetListCount(actionParam1List), targetGroupCount, string.format("目标组和行为参数1个数不一致! id = %d", self:GetId()))
	CheckSame(GetListCount(actionParam2List), targetGroupCount, string.format("目标组和行为参数2个数不一致! id = %d", self:GetId()))

	-- 执行行为 --
	for i = 1, targetGroupCount do
		battleSkillActionUtils.Execute(
			self,
			targetInfos[i],
			GetValueFromList(actionConditionList, i-1),
			GetValueFromList(actionConditionParamList, i-1),
			actionList[i-1], 
			GetValueFromList(actionParam1List, i-1),
			GetValueFromList(actionParam2List, i-1)
		)
	end
end

-- @@ 一对多 @@ --
local function ExecuteActionInOneToMany(self, targetInfo, actionConditionList, actionConditionParamList, actionList, actionParam1List, actionParam2List)

	local battleSkillActionUtils = require "Utils.BattleSkillActionUtils"
	local actionCount = GetListCount(actionList)
	-- debug_print("@ExecuteActionInOneToMany", actionCount, self.luaGameObject:GetGameObject().name)
	-- 不需要再往下执行 --
	if actionCount == 0 then
		return
	end

	-- >>> 检查参数是否错误 <<< --
	CheckSame(GetListCount(actionConditionList), actionCount, string.format("行为参数和行为执行条件个数不一致! id = %d", self:GetId()))
	CheckSame(GetListCount(actionConditionParamList), actionCount, string.format("行为参数和行为执行条件参数个数不一致! id = %d", self:GetId()))
	CheckSame(GetListCount(actionParam1List), actionCount, string.format("行为和参数1个数不一致! id = %d", self:GetId()))
	CheckSame(GetListCount(actionParam2List), actionCount, string.format("行为和参数2个数不一致! id = %d", self:GetId()))

	-- 执行行为 --
	for i = 1, actionCount do
		battleSkillActionUtils.Execute(
			self, 
			targetInfo, 
			GetValueFromList(actionConditionList, i-1),
			GetValueFromList(actionConditionParamList, i-1),
			actionList[i-1], 
			GetValueFromList(actionParam1List, i-1),
			GetValueFromList(actionParam2List, i-1)
		)
	end
end

local function ExecuteAction(self, targetInfos, actionConditionList, actionConditionParamList, actionList, actionParam1List, actionParam2List)
	local targetInfoCount = #targetInfos
	if targetInfoCount == 1 then
		-- 1 对 多
		return ExecuteActionInOneToMany(self, targetInfos[1], actionConditionList, actionConditionParamList, actionList, actionParam1List, actionParam2List)
	else
		-- 1 对 1
		return ExecuteActionInOneToOne(self, targetInfos, actionConditionList, actionConditionParamList, actionList, actionParam1List, actionParam2List)
	end
end

--------------------------------------------------
---------------  获取/选择/判断函数  ---------------
--------------------------------------------------

-- 是否为己方
function BattleSkill:IsRightSide()
	return self.luaGameObject:OnGetSide() == 1
end

-- 获得Battlefield
function BattleSkill:GetBattlefield()
	return self.luaGameObject:GetBattlefield()
end

-- 选择一组目标
function BattleSkill:SelectTargets(targetTypeId, targetParam)
	return self.unitSelector:GetTargets(targetTypeId, targetParam)
end

-- 选择多组目标
function BattleSkill:SelectMultiTargets(targetTypeIdList, targetParamList)
	return self.unitSelector:GetMultiTargets(targetTypeIdList, targetParamList)
end



--------------------------------------------------
----------------  静态data的接口  -----------------
--------------------------------------------------

function BattleSkill:GetId()
	return self.data:GetId()
end

-- 远程技能 --
function BattleSkill:IsLongRange()
	return self.data:GetRange() == kSkillType_LongRange
end

-- 闪现(*.*) --
function BattleSkill:IsBlink()
	return self.data:GetRange() == kSkillType_Blink
end

-- 飞行物飞行时间 --
function BattleSkill:GetEffectBulletTime()
	return self.data:GetEffectBulletTime()
end

-- 受击未受伤时的 特效ID
function BattleSkill:GetUnderAttackEffectSpecialID()
	return self.data:GetUnderAttackEffectSpecialID()
end

-- 受击且伤害时的 特效ID
function BattleSkill:GetUnderAttackDamageEffectSpecialID()
	return self.data:GetUnderAttackDamageEffectSpecialID()
end

-- 获取受击未受伤时的 循环间隔
function BattleSkill:GetUnderAttackEffectInterval()
	return self.data:GetUnderAttackEffectInterval()
end

-- 受击挂点
function BattleSkill:GetUnderAttackParentName()
	return self.data:GetUnderAttackParentName()
end

-- 技能资源UI
function BattleSkill:GetUiAnimationResID()
	return self.data:GetUiAnimationResID()
end


--------------------------------------------------
----------------  技能阶段的回调  ------------------
--------------------------------------------------

-- 战斗开始
function BattleSkill:OnBattleStart()

	-- debug_print("@BattleSkill:OnBattleStart", self.luaGameObject:GetGameObject().name)
	
	-- 读表 获取 两个List --
	if CanUseAction(self, self.data:GetStage0Condition(), self.data:GetStage0ConditionParam(), false) then

		-- 执行序列 --
		local actionConditionList = self.data:GetStage0ActionCondition()
		local actionConditionParamList = self.data:GetStage0ActionConditionParam()

		local actionList = self.data:GetStage0Action()
		local actionParam1List = self.data:GetStage0ActionParam1()
		local actionParam2List = self.data:GetStage0ActionParam2()

		-- 获取目标 --
		local targetInfos = self:SelectMultiTargets(self.data:GetStage0Target(), self.data:GetStage0TargetParam())

		-- ## 执行行为 ## --
		return ExecuteAction(self, targetInfos, actionConditionList, actionConditionParamList, actionList, actionParam1List, actionParam2List)
	end
end

-- 行动前
function BattleSkill:OnActionStart()

	-- debug_print("@BattleSkill:OnActionStart", self.luaGameObject:GetGameObject().name)

	-- 执行 行动前序列 --
	local actionConditionList = self.data:GetStage1ActionCondition()
	local actionConditionParamList = self.data:GetStage1ActionConditionParam()

	local actionList = self.data:GetStage1Action()
	local actionParam1List = self.data:GetStage1ActionParam1()
	local actionParam2List = self.data:GetStage1ActionParam2()

	-- 获取目标 --
	local targetInfo = self:SelectTargets(self.data:GetStage1Target(), self.data:GetStage1TargetParam())
	if targetInfo ~= nil then
		-- ## 执行行为 ## --
		return ExecuteAction(self, {targetInfo}, actionConditionList, actionConditionParamList, actionList, actionParam1List, actionParam2List)
	end
end

-- 行动时
function BattleSkill:OnAction()

	-- debug_print("@BattleSkill:OnAction,", self.luaGameObject:GetGameObject().name)

	-- 执行 行动时序列 --
	local actionList = self.data:GetStage2Action()
	local actionParam1List = self.data:GetStage2ActionParam1()
	local actionParam2List = self.data:GetStage2ActionParam2()

	-- 获取目标 --
	local targetInfo = self.luaGameObject:GetTargets()

	-- ## 执行行为 ## --
	return ExecuteAction(self, {targetInfo}, nil, nil, actionList, actionParam1List, actionParam2List)

end

-- 行动后
function BattleSkill:OnActionExit()

	-- debug_print("@BattleSkill:OnActionExit", self.luaGameObject:GetGameObject().name)

	if CanUseAction(self, self.data:GetStage3Condition(), self.data:GetStage3ConditionParam(), false) then

		-- 执行行动后 序列 --
		local actionConditionList = self.data:GetStage3ActionCondition()
		local actionConditionParamList = self.data:GetStage3ActionConditionParam()

		local actionList = self.data:GetStage3Action()
		local actionParam1List = self.data:GetStage3ActionParam1()
		local actionParam2List = self.data:GetStage3ActionParam2()

		-- 获取目标 --
		local targetInfo = self:SelectTargets(self.data:GetStage3Target(), self.data:GetStage3TargetParam())
		if targetInfo ~= nil then
			-- ## 执行行为 ## --
			return ExecuteAction(self, {targetInfo}, actionConditionList, actionConditionParamList, actionList, actionParam1List, actionParam2List)
		end
	end	

end

-- 受击时
function BattleSkill:OnUnderAttack()

	-- debug_print("@BattleSkill:OnUnderAttack", self.luaGameObject:GetGameObject().name)

	self.luaGameObject:ExecuteUnitStateAction(kUnitState_Phase_UnderAttack)

	if CanUseAction(self, self.data:GetStage4Condition(), self.data:GetStage4ConditionParam(), false) then

		-- 执行行动后 序列 --
		local actionConditionList = self.data:GetStage4ActionCondition()
		local actionConditionParamList = self.data:GetStage4ActionConditionParam()

		local actionList = self.data:GetStage4Action()
		local actionParam1List = self.data:GetStage4ActionParam1()
		local actionParam2List = self.data:GetStage4ActionParam2()

		-- 获取目标 --
		local targetInfo = self:SelectTargets(self.data:GetStage4Target(), self.data:GetStage4TargetParam())
		if targetInfo ~= nil then
			-- ## 执行行为 ## --
			return ExecuteAction(self, {targetInfo}, actionConditionList, actionConditionParamList, actionList, actionParam1List, actionParam2List)
		end

	end	

end

-- 受击后
function BattleSkill:OnUnderAttackExit()

	-- debug_print("@BattleSkill:OnUnderAttackExit", self.luaGameObject:GetGameObject().name)

	self.luaGameObject:ExecuteUnitStateAction(kUnitState_Phase_UnderAttackExit)

	if CanUseAction(self, self.data:GetStage5Condition(), self.data:GetStage5ConditionParam(), false) then
		-- debug_print("@BattleSkill:OnUnderAttackExit 1", self.luaGameObject:GetGameObject().name)
		-- 执行行动后 序列 --
		local actionConditionList = self.data:GetStage5ActionCondition()
		local actionConditionParamList = self.data:GetStage5ActionConditionParam()

		local actionList = self.data:GetStage5Action()
		local actionParam1List = self.data:GetStage5ActionParam1()
		local actionParam2List = self.data:GetStage5ActionParam2()

		-- 获取目标 --
		local targetInfo = self:SelectTargets(self.data:GetStage5Target(), self.data:GetStage5TargetParam())

		-- debug_print("@BattleSkill:OnUnderAttackExit 2", self.luaGameObject:GetGameObject().name, targetInfo:Count())

		if targetInfo ~= nil then
			-- ## 执行行为 ## --
			return ExecuteAction(self, {targetInfo}, actionConditionList, actionConditionParamList, actionList, actionParam1List, actionParam2List)
		end

	end	

end

-- 死亡时
function BattleSkill:OnDead()

	-- debug_print("@BattleSkill:OnDead", self.luaGameObject:GetGameObject().name)
	
	self.luaGameObject:ExecuteUnitStateAction(kUnitState_Phase_Dead)

	if CanUseAction(self, self.data:GetStage6Condition(), self.data:GetStage6ConditionParam(), false) then

		-- 执行行动后 序列 --
		local actionConditionList = self.data:GetStage6ActionCondition()
		local actionConditionParamList = self.data:GetStage6ActionConditionParam()

		local actionList = self.data:GetStage6Action()
		local actionParam1List = self.data:GetStage6ActionParam1()
		local actionParam2List = self.data:GetStage6ActionParam2()

		-- 获取目标 --
		local targetInfo = self:SelectTargets(self.data:GetStage6Target(), self.data:GetStage6TargetParam())
		if targetInfo ~= nil then
			-- ## 执行行为 ## --
			return ExecuteAction(self, {targetInfo}, actionConditionList, actionConditionParamList, actionList, actionParam1List, actionParam2List)
		end
	end	

end


--------------------------------------------------
-------------------  技能使用  --------------------
--------------------------------------------------

-- 是否可以使用此技能 (子技能可以判断) --
function BattleSkill:CanUse()
	return CanUseAction(self, self.data:GetStage1Condition(), self.data:GetStage1ConditionParam(), false)
end

-- 真正开始行动! 供子类调用! --
function BattleSkill:Action()
	-- 执行自己的被动技能的行动前 -- 
	self.luaGameObject:GetPassiveSkill():OnActionStart()

	-- 执行自己当前主动技能的行动前 --
	self:OnActionStart()

	-- 执行目标的被动 受击时 --
	local targetInfo = self.luaGameObject:GetTargets()
	local targets = targetInfo:GetTargets()
	for i = 1, #targets do
		local passiveSkill = targets[i]:GetPassiveSkill()
		if passiveSkill ~= nil then
			passiveSkill:OnUnderAttack(self.luaGameObject)
		end
	end

	-- 在行动时阶段, 执行BUFF操作!
	self.luaGameObject:ExecuteUnitStateAction(kUnitState_Phase_Action)

	-- 执行自己的被动技能的行动时 --
	self.luaGameObject:GetPassiveSkill():OnAction()

	-- 开始行动 --
	self:OnAction()
end

-- [主动使用时的接口, 被动技能调用无效]
function BattleSkill:Use()
	-- 选择/设置 目标 --
	local targetInfo = self:SelectTargets(self.data:GetStage2Target(), self.data:GetStage2TargetParam())
	self.luaGameObject:SetTargets(targetInfo)
end
