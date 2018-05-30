require "Battle.BattleUnit"
require "Object.LuaComponent"
local BattleUtility = require "Utils.BattleUtility"
local utility = require "Utils.Utility"
local MessageGuids = require "Framework.Business.MessageGuids"
local cos3dGame = utility.GetGame()

BattleTeamController = Class(LuaComponent)

function BattleTeamController:Ctor(members)
	self.members = members
	self.isAssistMarked = false
end

function BattleTeamController:Clear()
	self.movableUnits = nil
	self.movableUnitIndex = nil
	self.resetListeners = nil
	self.isAssistMarked = false
end

function BattleTeamController:ToString()
	return "BattleTeamController"
end

function BattleTeamController:IsController()
	return true
end

function BattleTeamController:Update()
	if self.members ~= nil then
		for k, v in pairs(self.members) do
			v:Update()
		end
	end
end

function BattleTeamController:Pause()
	-- debug_print("@Pause, BattleTeamController:Pause, side", self.luaGameObject.side)
	for k, v in pairs(self.members) do
		v:Pause()
	end
end

function BattleTeamController:Resume()
	-- debug_print("@Resume, BattleTeamController:Resume, side", self.luaGameObject.side)
	for k, v in pairs(self.members) do
		v:Resume()
	end
end

function BattleTeamController:OnBattleStarted()
	for k, v in pairs(self.members) do
		v:OnBattleStarted()
	end
end

local function SortMovableUnits(unitTable)
	BattleUtility.SortBattleUnits(unitTable)
end

local function AddResetListener(self, unit)
	self.resetListeners[#self.resetListeners + 1] = unit
end

local function UnitTakeAction(self)
	local unit = self.movableUnits[self.movableUnitIndex]
	self.resetListeners = {}
	AddResetListener(self, unit)
	unit:TakeAction()
end

function BattleTeamController:GetOrderedUnits()
	local units = {}
	for _, v in pairs(self.members) do
		if v:IsAlive() then
			units[#units + 1] = v
		end
	end
	SortMovableUnits(units)
	return units
end

function BattleTeamController:TakeAction(speedLimit)
	self.movableUnits = {}
	self.movableUnitIndex = 1
	for k, v in pairs(self.members) do
		if v:IsAlive() and not v:IsMoved() then
			local speed = v:GetSpeed()
			if (speed > speedLimit) or (speed == speedLimit and self.luaGameObject:IsBattleStarter()) then
				self.movableUnits[#self.movableUnits + 1] = v
			end
		end
	end
	SortMovableUnits(self.movableUnits)
	if #self.movableUnits > 0 then
		UnitTakeAction(self)
	end
end

function BattleTeamController:UnitReset(unit)
	-- 删掉 属于这个unit的 listener
	local resetListeners = self.resetListeners

	for i = 1, #resetListeners do
		if resetListeners[i] == unit then
			resetListeners[i] = resetListeners[#resetListeners]
			resetListeners[#resetListeners] = nil
			break
		end
	end
		
	-- 如果没注册了
	if #resetListeners == 0 then

		-- ##### 发送联动结束消息(已经没有了) ##### --
		if self.isAssistMarked then
			-- print(">>>>>>>>>>> 联动结束 <<<<<<<<<<<")
			self.isAssistMarked = false
			cos3dGame:DispatchEvent(MessageGuids.BattleEndAssistAttack, nil)

			-- 己方才播放
			cos3dGame:DispatchEvent(MessageGuids.BattleEndCameraZoomUp, nil)
		end

		-- TODO 等待当前所有行动的人 --


		-- 当前战斗结束, 不再让下一个人 或 下一队继续行动 --
		if self.luaGameObject:GetParent():IsBattleFinished() then
			return
		end

		-- 当前行动组都行动完了 --
		repeat
			self.movableUnitIndex = self.movableUnitIndex + 1
			if self.movableUnitIndex > #self.movableUnits then
				self.luaGameObject:OnRoundContinued()
				return
			end
		until (not self.movableUnits[self.movableUnitIndex]:IsMoved() and self.movableUnits[self.movableUnitIndex]:IsAlive())

		-- 检查被打方的敌人队伍的护盾情况
		self.luaGameObject:GetFoeTeam():CheckShields()

		-- 继续行动 --
		UnitTakeAction(self)
	end
end

local function GetSameOneTarget(assistAttackStarter, assistUnits)
	local recordUnit

	-- 先去记录带头攻击的人的目标 --
	local leaderTargetInfo = assistAttackStarter:GetTargets()
	if leaderTargetInfo:Count() ~= 1 then
		return false, nil
	end

	recordUnit = leaderTargetInfo:GetTarget(1)

	-- 再去比较其他人的目标 --
	for _, v in pairs(assistUnits) do
		local targetInfo = v:GetTargets()
		if targetInfo:Count() ~= 1 then
			return false, nil
		end

		if targetInfo:GetTarget(1) ~= recordUnit then
			return false, nil
		end
	end

	return true, recordUnit
end

function BattleTeamController:AssistAttack(assistAttackStarter)

	-- @@ 联动处理 @@ --
	local assistUnits = {}
	for i = self.movableUnitIndex + 1, #self.movableUnits do
		local unit = self.movableUnits[i]
		if unit ~= nil and unit ~= assistAttackStarter and unit:CanAssistAttack() then
			AddResetListener(self, unit)
			assistUnits[#assistUnits + 1] = unit
		end
	end

	-- print("@@@@ 联动人数", #assistUnits, #self.resetListeners)

	-- @@
	local order = 1
	local assistUnitCount = #assistUnits
	if assistUnitCount > 0 then
		-- # 可联动 # --
		utility.ASSERT(self.isAssistMarked == false, "联动状态已经开始了!")
		self.isAssistMarked = true

		-- # 联动开始 # --
		
		-- @ leader @ --
		assistAttackStarter:OnPlayAssistAttackEffect(order)

		-- @ assister @
		for i = 1, assistUnitCount do
			order = order + 1
			assistUnits[i]:OnPlayAssistAttackEffect(order)
			assistUnits[i]:OnAssistAttack(assistAttackStarter)
		end

		-- print(">>>>>>>>>>> 联动开始 <<<<<<<<<<<")
		cos3dGame:DispatchEvent(MessageGuids.BattleBeginAssistAttack, nil, assistAttackStarter, assistUnits)

		-- 己方
		if assistAttackStarter:OnGetSide() == 1 then

			local targetPos

			local isSame, sameTarget = GetSameOneTarget(assistAttackStarter, assistUnits)
			if isSame and sameTarget ~= nil then
				targetPos = sameTarget:GetGameObject().transform.position
			else
				targetPos = assistAttackStarter:GetFoeCenter().position
			end

			targetPos.y = targetPos.y + 1


			cos3dGame:DispatchEvent(MessageGuids.BattleStartCameraZoomUp, nil, targetPos, true)
		end
	else
		-- 普通攻击 --
		cos3dGame:DispatchEvent(MessageGuids.BattleTakeAttackAction, nil, assistAttackStarter)
	end
	
end