require "Object.LuaGameObject"
require "Object.Component.MotionController"
local collision = require "Event.CollisionEventHandler"

Bullet = Class(LuaGameObject)

-- 获取技能的飞行物时间 -- 
local function GetBulletTime(self)
	local unit = self.owner.luaGameObject
	local currentSkill

	if unit:IsUsingSkill() then
		currentSkill = unit:GetActiveSkill()
	else
		currentSkill = unit:GetAttackSkill()
	end

	if currentSkill == nil then
		return 1
	end

	return currentSkill:GetEffectBulletTime()
end

-- 判断特效ID是否有效 --
local function IsEffectIdValid(self)
	return type(self.effectId) == "number" and self.effectId ~= 0
end

-- 获取效果的预制体的实例化
local function GetEffectGameObject(self)
	local effectGameObject = ResCtrl.EffectPool.Instance():Pop(self.effectId)
	
	local effectTransform = effectGameObject.transform

	--> 设置父对象 <--
	effectTransform:SetParent(self.owner:GetGameObject().transform, true)

	--> 设置偏移 <--
	local offsetTransform = effectTransform:Find("Position")
	if offsetTransform ~= nil then
		effectTransform.localPosition = offsetTransform.localPosition
	else
		effectTransform.localPosition = Vector3(0,0,0)
	end

	--> 设置缩放 <--
	effectTransform.localScale = Vector3(1,1,1)

	effectGameObject:SetActive(true)

	return effectGameObject, effectTransform
end

function Bullet:Ctor(effectId, owner)
	self.effectId = effectId
	if not IsEffectIdValid(self) then
		error("无效的效果ID!")
	end

	self.owner = owner
	
	self.moveTime = GetBulletTime(self)

	self.effectGameObject, self.effectTransform = GetEffectGameObject(self)
	if self.effectGameObject == nil then
		error(string.format("效果id %d 实例化失败!", self.effectId))
	end

	-- Collider 组件 --
	self.colliderListener = self.effectGameObject:GetComponent(typeof(BattleUnitColliderListener))
	if self.colliderListener == nil then
		self.colliderListener = self.effectGameObject:AddComponent(typeof(BattleUnitColliderListener))
	end

	-- Motion 组件 --
	local motion = MotionController.New(self.effectTransform)
	self:AddComponent(motion)
	self.motion = motion

	--> 飞向何方 <--
	self.targetUnit = nil
end

function Bullet:ToString()
	return "Bullet"
end

local function LookAt(self, targetTransform)
	self.effectTransform:LookAt(targetTransform)
end

function Bullet:MoveToTarget(targetUnit, moveToCallback)
	print("@飞行物移动:", self.owner:GetGameObject().name, targetUnit:GetGameObject().name)
	self.targetUnit = targetUnit
	self.colliderListener.Target = targetUnit:GetGameObject()
	collision:RegisterEventHandler(self)
	LookAt(self, targetUnit:GetGameObject().transform)
	self.motion:MoveToPositionOnTime(targetUnit:GetGameObject().transform.position, moveToCallback, self.moveTime)
end

function Bullet:OnCollisionDetected(targetGameObject)
	if self.colliderListener.Target == targetGameObject then
		self:Arrived()
	end
end

local function OnBulletArrived(self)
end

function Bullet:Arrived()
	print("@飞行物移动 Bullet::Arrived", self.owner:GetGameObject().name)
	self.motion:Stop()
	self.effectGameObject:SetActive(false)
	self.owner:RemoveBullet(self)
	self.colliderListener.Target = nil
	collision:UnRegisterEventHandler(self)

	if self.targetUnit ~= nil then
		print("@ 飞行物目标 >>>", self.targetUnit:GetGameObject().name)
		_G.OnReceiveDamageRealImplementation(self.owner, self.targetUnit)
	end

	-- 归还特效 --
	if self.effectGameObject ~= nil then
		UnityEngine.Object.Destroy(self.effectGameObject)
	end
	-- ResCtrl.EffectPool.Instance():Push(self.effectId, self.effectGameObject)

	OnBulletArrived(self)
end
