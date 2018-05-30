require "Battle.Skill.BattleSkill"

PassiveSkill = Class(BattleSkill)

function PassiveSkill:ToString()
	return "被动技能, "..self.data:ToString()
end

function PassiveSkill:Use()
	-- TODO : 被动技能不能被直接Use! --
	error("被动技能不能触发Use操作!")
end

-- 行动时
function PassiveSkill:OnAction()
	-- debug_print("@PassiveSkill:OnAction,", self.luaGameObject:GetGameObject().name)
	
	-- 执行 行动时序列 --
	local actionList = self.data:GetStage2Action()
	local actionParam1List = self.data:GetStage2ActionParam1()
	local actionParam2List = self.data:GetStage2ActionParam2()

	-- 获取目标 --
	local targetInfo = self:SelectTargets(self.data:GetStage2Target(), self.data:GetStage2TargetParam())

	-- ## 执行行为 ## --
	return ExecuteAction(self, {targetInfo}, nil, nil, actionList, actionParam1List, actionParam2List)
end

