require "Battle.BattleTeamController"
require "Enum"
local unityUtils = require "Utils.Unity"
local utility = require "Utils.Utility"

BattleTeam = Class(LuaGameObject)

require "Battle.BattleTeam_Shield"

function BattleTeam:Ctor(side, front, center)
	self.side = side
	self.front = front
	self.center = center
	self.members = {}
	self.battleTeamParameter = nil

	self:InitShield()

	-- 加入组件 --
	local ctrl = BattleTeamController.New(self.members)
	self:AddComponent(ctrl)
	self.ctrl = ctrl
end

function BattleTeam:SetData(battleTeamParameter)
	self.battleTeamParameter = battleTeamParameter
end

function BattleTeam:Clear()
	self.ctrl:Clear()
	self.battleTeamParameter = nil
	local max = table.maxn(self.members)
	for i = 1, max do
		local unit = self.members[i]
		if unit ~= nil then
			unit:Clear()
		end
		self.members[i] = nil
	end
	self:ClearShield()
end

function BattleTeam:Setup(objects)
	utility.ASSERT(self.battleTeamParameter ~= nil, "必须得有数据才能创建模型!")
	utility.ASSERT(table.maxn(self.members) == 0, "已经创建过角色, 需要先调用 Clear 函数")

	local scaleFactor = 0.01

	local count = self.battleTeamParameter:Count()
	for i = 1, count do
		local unitParameter = self.battleTeamParameter:GetUnit(i)
		if unitParameter ~= nil then
			local location = unitParameter:GetLocation()
			
			-- # 初始化 BattleUnit # --
			local newUnit = BattleUnit.New(
				unitParameter, 
				self.side == Side.Right, 
				unitParameter:GetScaleRate() * scaleFactor
			)
			
			newUnit:SetParent(self)
			newUnit:Setup()
			self.members[location] = newUnit
		end
	end
end

function BattleTeam:ToString()
	return "BattleTeam"
end

function BattleTeam:Pause()
	-- debug_print("@Pause, BattleTeam:Pause, side", self.side)
	self.ctrl:Pause()
end

function BattleTeam:Resume()
	-- debug_print("@Resume, BattleTeam:Resume, side", self.side)
	self.ctrl:Resume()
end

function BattleTeam:GetMaxSpeed()
	local maxSpeed = 0
	for k, v in pairs(self.members) do
		if v:IsAlive() and not v:IsMoved() then
			local speed = v:GetSpeed()
			if speed > maxSpeed then
				maxSpeed = speed
			end
		end
	end

	return maxSpeed
end

function BattleTeam:UnitReset(unit)
	-- 重置 unit
	self.ctrl:UnitReset(unit)
end

function BattleTeam:OnRoundContinued()
	self:GetParent():OnRoundContinued()
end

function BattleTeam:AssistAttack(assistAttackStarter)
	self.ctrl:AssistAttack(assistAttackStarter)
end

function BattleTeam:IsBattleStarter()
	return self.side == self:GetParent():GetBattleStarter()
end

function BattleTeam:TakeAction(speedLimit)
	self.ctrl:TakeAction(speedLimit)
end

function BattleTeam:GetFoes()
	return self:GetFoeTeam().members
end

function BattleTeam:GetFoeTeam()
	return self:GetParent():GetFoeTeam(self)
end

function BattleTeam:GetMembers()
	return self.members
end

function BattleTeam:GetOrderedUnits()
	return self.ctrl:GetOrderedUnits()
end

function BattleTeam:IsAllMoved()
	for k, v in pairs(self.members) do
		if v:IsAlive() and not v:IsMoved() then
			return false
		end
	end

	return true
end

function BattleTeam:IsAllDead()
	for k, v in pairs(self.members) do
		if v:IsAlive() then
			return false
		end
	end
	return true
end

function BattleTeam:NumOfAlives()
	local count = 0
	for k, v in pairs(self.members) do
		if v:IsAlive() then
			count = count + 1
		end
	end
	return count
end

function BattleTeam:IsAnyFrontrowAlive()
	for i = 1, 3 do
		local unit = self.members[i]
		if unit ~= nil and unit:IsAlive() then
			return true
		end
	end
	return false
end

function BattleTeam:IsAnyBackrowAlive()
	for i = 4, 6 do
		local unit = self.members[i]
		if unit ~= nil and unit:IsAlive() then
			return true
		end
	end
	return false
end

function BattleTeam:NewRound()
	self:NewShieldRound()
	for k, v in pairs(self.members) do
		if v:IsAlive() then
			v:NewRound()
		end
	end
end

function BattleTeam:OnNewWave(wave)
	for k, v in pairs(self.members) do
		if v:IsAlive() then
			v:OnNewWave(wave)
		end
	end
end

function BattleTeam:OnBattleStarted()
	self.ctrl:OnBattleStarted()
end

function BattleTeam:OnGetSide()
	if self.side == Side.Left then
		return 0
	elseif self.side == Side.Right then
		return 1
	end
	
	return -1
end

function BattleTeam:GetFoeCenter()
	return self:GetFoeTeam():GetCenter()
end

function BattleTeam:GetCenter()
	return self.center
end

function BattleTeam:GetFront()
	return self.front
end

function BattleTeam:PlayAssistAttackAnimation(id, delay)
    return self:GetParent():PlayAssistAttackAnimation(id, delay)
end

function BattleTeam:SetSkillBackgroundActive(unit, active)
    return self:GetParent():SetSkillBackgroundActive(unit, active)
end