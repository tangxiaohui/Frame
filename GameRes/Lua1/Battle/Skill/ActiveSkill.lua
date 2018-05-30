require "Battle.Skill.BattleSkill"

local utility = require "Utils.Utility"
local MessageGuids = require "Framework.Business.MessageGuids"
local cos3dGame = utility.GetGame()
require "Const"

local __PORTRAIT_DELAY_TIME__ = 2

ActiveSkill = Class(BattleSkill)

function ActiveSkill:ToString()
	return "主动技能, "..self.data:ToString()
end

local function isAllTargets(self)
	local targetInfo = self.luaGameObject:GetTargets()
	return targetInfo:GetTargetType() == kSkillTarget_AllMembers or targetInfo:GetTargetType() == kSkillTarget_AllFoes
end

local function OnUseSkill(self, newTargetInfo, portraitDelay)

	-- debug_print("@@ OnUseSkill 2", self, newTargetInfo, portraitDelay)


	-- @@ 设置新的目标 @@ --
	if newTargetInfo ~= nil then
		self.luaGameObject:SetTargets(newTargetInfo)
	end

	-- >>> 开始行动 <<< --
	self:Action()

	local isRightSide = self:IsRightSide()

	-- debug_print("@is right side", isRightSide, portraitDelay, debug.traceback())

	-- 己方 & 等待立绘完成 --
	if isRightSide and type(portraitDelay) == "number" and portraitDelay > 0 then
		coroutine.wait(portraitDelay)
	end

	-- 扣怒气 --
	-- debug_print("@rage: 使用技能消耗5点怒气", self.luaGameObject:GetGameObject().name)
	self.luaGameObject:AddRage(-5)

	if isRightSide then
		-- debug_print("@hide skill portrait effect")
		cos3dGame:DispatchEvent(MessageGuids.BattleHideSkillPortraitEffect, nil, self.luaGameObject)
	end

	-- TODO 技能现在没有敌方拿名字的
	-- print("技能气泡检测 >>>> ", isRightSide, utility.IsCameraPathEnable())
	if not isRightSide or not utility.IsCameraPathEnable() then
		local _,_,_,_,activeSkillName = self.luaGameObject:GetStaticInfo()
		cos3dGame:DispatchEvent(MessageGuids.BattleShowSkillBubble, nil, self.luaGameObject, activeSkillName)
	end

	-- 开始行动 --
	cos3dGame:DispatchEvent(MessageGuids.BattleTakeAction, nil, self.luaGameObject, true)


	local isAll = isAllTargets(self)

	if not self:IsBlink() then
		if isAll then
			local foeCenter = self.luaGameObject:GetFoeCenter()
			self.luaGameObject:RotateToTarget(foeCenter.gameObject)
		else
			-- 旋转到第一个人 开始放技能 --
			local targetInfo = self.luaGameObject:GetTargets()
			local targetUnit = targetInfo:GetTarget(1)
			local targetGameObject = targetUnit:GetGameObject()
			self.luaGameObject:RotateToTarget(targetGameObject)
		end
	end

	if self:IsLongRange() or self:IsBlink() then
		self.unitController:Breath2Skill()
	else
		if self.unitController:HasStateSkill01() and self.unitController:HasStateSkill02() then
			-- 跳转到蓄力 那条线
			if self.luaGameObject:OnGetSide() == 1 then
				self.unitController:HideHpBar()
			end
			print('breath 2 skill01')
			self.unitController:Breath2Skill01()
			return
		else
			print('breath 2 run')
			self.unitController:Breath2Run()
		end

		self:MoveToTarget()
	end
end

local function UseImpl(self, newTargetInfo, portraitDelay)
	-- debug_print("@@ OnUseSkill 1", self, newTargetInfo, portraitDelay, debug.traceback())
	coroutine.start(OnUseSkill, self, newTargetInfo, portraitDelay)
end

-- 到底是使用攻击 还是 技能 --
local function OnSelectionFinished(self, type, targetInfo)
	
	local battlefield = self.luaGameObject:GetBattlefield()
	if not battlefield:IsReplayMode() then
	
		-- 非回放模式 --
	
		if self.manuallyFlag then
			self.manuallyFlag = false

			-- @1. 收集波数
			local wave = battlefield:GetWaveNumber()

			-- @2. 收集回合数
			local round = battlefield:GetRoundNumber()

			-- @3. 站位
			local pos = self.luaGameObject:GetLocation()

			local targetType = 0
			local targetParam = 0

			-- @4. targets
			local retTargets = {}
			if targetInfo ~= nil and targetInfo:Count() > 0 then
				targetType = targetInfo:GetTargetType()
				targetParam = targetInfo:GetTargetParam()
				
				-- 循环构建位置 --
				for i = 1, targetInfo:Count() do
					local currentTarget = targetInfo:GetTarget(i)
					retTargets[#retTargets + 1] = currentTarget:GetLocation()
				end
			end

			-- @5. discarded
			local discarded = type == kTargetSelection_Attack

			cos3dGame:DispatchEvent(MessageGuids.BattleSkillManuallySelection, nil, wave, round, pos, retTargets, targetType, targetParam, discarded)
		end
	end

	if type == kTargetSelection_Attack then
		cos3dGame:DispatchEvent(MessageGuids.BattleHideSkillPortraitEffect, nil, self.luaGameObject)
		cos3dGame:DispatchEvent(MessageGuids.BattleSkillBlackBoardWhite,nil,0.2,1)
		self.luaGameObject:ManualSkillDiscarded() -- 放弃技能使用普攻 --
		self.luaGameObject:UseAttackSkill()
	else
		UseImpl(self, targetInfo, nil)
	end
end

----------------------------------------
-- 临时 - 技能处理和获取 -----------------
----------------------------------------
local function HandleReplaySkillSelection(self)
	print("处理技能选择的回放!")

	local battlefield = self:GetBattlefield()

	-- TODO: 这里需要在战斗协议的手动数据里增加 side 字段!
	
	local replayMOData = battlefield:GetSkillSelectionData(battlefield:GetWaveNumber(), battlefield:GetRoundNumber(), self.luaGameObject:GetLocation())
	if replayMOData == nil then
		return false
	end

	print("拿到了手动数据!!!>>>>>>>>>>")

	-- 构建数组
	if replayMOData.discarded then
		print("放弃技能 使用了攻击!")
		self.luaGameObject:ManualSkillDiscarded() -- 放弃技能使用普攻 --
		self.luaGameObject:UseAttackSkill()
	else
	
		local newTargetInfo
	
		if replayMOData.targets ~= nil and #replayMOData.targets > 0 then
		
			require "Battle.BattleTargetInfo"
			local targetType = replayMOData.targetType
			local targetParam = replayMOData.targetParam
			local unitTargets = {}
			local members
			if targetType > 0 then
				members = self.luaGameObject:GetFoes()
			elseif targetType < 0 then
				members = self.luaGameObject:GetMembers()
			end
			
			-- 恢复成指定单位 --
			if members ~= nil then
				for i = 1, #replayMOData.targets do
					local unit = members[replayMOData.targets[i]] -- 通过站位拿到对应的BattleUnit
					if unit ~= nil and unit:IsAlive() then	-- 如果还活着就加入到里面去!
						unitTargets[#unitTargets + 1] = unit
					end
				end
			end
			
			newTargetInfo = BattleTargetInfo.New(unitTargets, targetType, targetParam)
		end
		
		if self:IsRightSide() then
			cos3dGame:DispatchEvent(MessageGuids.BattleShowSkillPortraitEffect, nil, self.luaGameObject)
			cos3dGame:DispatchEvent(MessageGuids.BattleSkillBlackBoardBlack,nil,1,0.3)
		end
		UseImpl(self, newTargetInfo, __PORTRAIT_DELAY_TIME__)
	end

	return true
end

local function OnWaitingForVideoFinished(self)
	local battlefield = self.luaGameObject:GetBattlefield()
	
	-- @ wait
	repeat
		coroutine.step(1)
	until(battlefield:IsFirstVideoFinished())
	
	self:Action()
	
	-- 第一场战斗播放完毕后 , 直接通知伤害即可 --
	local skillCount = self:GetAttackCount()
	for i = 1, skillCount - 1 do
		self.unitController:NextAttack()
	end

	_G.BattleUnitOnNotifyDamage(self.luaGameObject:GetGameObject())
	
	self.luaGameObject:NotifySkillStateExit()

	-- 速度变慢+模糊
	local originalSpeed = UnityEngine.Time.timeScale
	UnityEngine.Time.timeScale = 0.3
	local cameraObject = battlefield:EnableRadiarBlur()
	
	coroutine.wait(2 * UnityEngine.Time.timeScale)
	UnityEngine.Time.timeScale = originalSpeed
	battlefield:DisableRadiarBlur(cameraObject)

	-- @ wait 0.2
	coroutine.wait(1)
	
	_G.BattleUnitHandleResetLogic(self.luaGameObject:GetGameObject())

	
end

function ActiveSkill:CanUse()
	-- @@ 1. 怒气是否到达5 @@ --
	if self.luaGameObject:GetRage() < 5 then
		return false
	end

	-- @@ 2. 是否满足条件 @@ --
	return ActiveSkill.base.CanUse(self)
end

function ActiveSkill:Use()
	ActiveSkill.base.Use(self)

	print(">>>> 发技能", self.luaGameObject:GetGameObject().name)

	local battlefield = self:GetBattlefield()

	-- 选择目标 --
	local targetInfo = self.luaGameObject:GetTargets()

	local isAll = isAllTargets(self)

	local targetUnit = targetInfo:GetTarget(1)

	-- @@ 非回放模式 @@ --
	if not battlefield:IsReplayMode() then
		-- 手动模式下 会启动目标选择UI --
		if battlefield:GetBattleMode() == kBattleMode_Manual then
			-- 如果是己方的时候 则支持手动 --
			if self:IsRightSide() then
				self.manuallyFlag = true
				-- 发送消息, 让用户选择目标
				cos3dGame:DispatchEvent(MessageGuids.BattleShowSkillPortraitEffect, nil, self.luaGameObject) --(策划说手动还得显示!)
        		cos3dGame:DispatchEvent(MessageGuids.BattleSkillBlackBoardBlack,nil,1,0.3)
				cos3dGame:DispatchEvent(MessageGuids.BattleSkillTargetSelection, nil, self, isAll, targetUnit:OnGetSide(), OnSelectionFinished)
				return
			end
		end
	else
		-- FIXME: 需要在战斗协议的手动数据里增加Side参数, 然后去掉这里的 IsRightSide 判断
		if self:IsRightSide() then
			--- 查找手动输入参数 ---
			if HandleReplaySkillSelection(self) then
				return
			end
		end
	end

	-- 正常发技能立绘显示 --
	if self:IsRightSide() then
		cos3dGame:DispatchEvent(MessageGuids.BattleShowSkillPortraitEffect, nil, self.luaGameObject)
    	cos3dGame:DispatchEvent(MessageGuids.BattleSkillBlackBoardBlack,nil,1,0.3)	
	else
		-- 敌人&有第一波的配置才播 视频 --
		print("波数: ", battlefield:GetWaveNumber(), "位置: ", self.luaGameObject:GetLocation())
		
		if battlefield:PrepareFirstFightVideo(battlefield:GetWaveNumber(), self.luaGameObject:GetLocation(), self.luaGameObject) then
			coroutine.start(OnWaitingForVideoFinished, self)
			return
		end
	end

	-- 开始使用技能! --
	UseImpl(self, nil, __PORTRAIT_DELAY_TIME__)
end

function ActiveSkill:MoveToTarget()
	local targetInfo = self.luaGameObject:GetTargets()

	if targetInfo:GetTargetType() == kSkillTarget_AllFoes then
		self.unitMotion:MoveToPosition(self.luaGameObject:GetFront().position, self)
	else
		local target = targetInfo:GetTarget(1)
		local targetGameObject = target:GetGameObject()

		self.unitController:SetColliderTarget(targetGameObject)
		self.unitMotion:MoveToTarget(targetGameObject, self, self.luaGameObject:GetMoveTimeScaler(target))
	end
end

function ActiveSkill:Arrived()
	print('Arrived!!!@@@')

	self.unitMotion:Stop()
	self.unitController:ResetColliderTarget()

	-- 如果是全体技能 应该让角度归90度 冲前
	
	if isAllTargets(self) then
		self.luaGameObject:RestoreRotation()
	end

	if self.unitController:IsCurAnimatorStateSkill02() then
		self.unitController:Skill022Skill()
	else
		-- FIXME 修复跑到技能时 状态是 受击到呼吸的问题 (看能否解决!)
		-- if not self.unitController:IsCurAnimatorStateRun() then
		-- self.unitController:Breath2Run()
		-- end
		self.unitController:Run2Skill()
	end
end