require "Battle.Skill.BattleSkill"
require "Const"

Attack = Class(BattleSkill)

function Attack:ToString()
	return "普攻技能, "..self.data:ToString()
end

function Attack:Use()
	-- debug_print("@@ 技能id @@", self:GetId())

	Attack.base.Use(self)

	-- 行动开始  --
	self:Action()

	local targetInfo = self.luaGameObject:GetTargets()

	-- 是否为全体 --
	local isAll = targetInfo:GetTargetType() == kSkillTarget_AllMembers or targetInfo:GetTargetType() == kSkillTarget_AllFoes

	-- 获取第一个目标 --
	local targetUnit = targetInfo:GetTarget(1)
	local targetGameObject = targetUnit:GetGameObject()


	if isAll then
		local foeCenter = self.luaGameObject:GetFoeCenter()
		-- 旋转朝向
		self.luaGameObject:RotateToTarget(foeCenter.gameObject)
	else
		-- 旋转朝向目标
		self.luaGameObject:RotateToTarget(targetGameObject)
	end

	debug_print("发动普攻!!!", self:GetId(), self:IsLongRange(), self.data:GetRange())

	if self:IsLongRange() then
		-- 既然是远程 直接攻击就好
		self.unitController:Breath2Attack()
	else
		-- 不是远程 得跑过去
		self.unitController:Breath2Run()
		self.unitController:SetColliderTarget(targetGameObject)

		local timeScaler = self.luaGameObject:GetMoveTimeScaler(targetUnit)
		-- print(">>>>>>>> source :",self.luaGameObject:GetGameObject().name, "target gameObject ::: ", targetGameObject.name, "time scaler ::",timeScaler)
		self.unitMotion:MoveToTarget(targetGameObject, self, timeScaler)
	end
end

function Attack:Arrived()
	-- print("@@@@@@ Attack:Arrived @@@@@@")
	self.unitMotion:Stop()
	self.unitController:ResetColliderTarget()
	self.unitController:Run2Attack()
end