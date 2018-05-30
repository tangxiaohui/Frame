require "Object.LuaComponent"
local TweenUtility = require "Utils.TweenUtility"

local UnityEngine_Time = UnityEngine.Time

MotionController = Class(LuaComponent)

function MotionController:Ctor(transform, moveTime)
	self.isMoving = false
	self.moveTime = 0.6
	self.transform = transform
	if moveTime ~= nil then
		self.moveTime = moveTime
	end
end

function MotionController:ToString()
	return "MotionController"
end

function MotionController:IsController()
	return true
end

function MotionController:MoveToPositionOnTime(position, moveToCallback, time)
	-- print("MoveToPositionOnTime with time:"..time.." moveTime: "..self.moveTime)
	self.srcPos = self.transform.position
	self.destPos = position
	self.inverseTotalTime = 1 / time
	self.passedTime = 0
	self.moveToCallback = moveToCallback
	self.isMoving = true
	-- print("@@@ MoveToPositionOnTime", time, self.inverseTotalTime, self.luaGameObject:GetGameObject().name)
end

function MotionController:MoveToPosition(position, moveToCallback, moveTimeScaler)
	self:MoveToPositionOnTime(position, moveToCallback, self.moveTime * (moveTimeScaler or 1))
end

function MotionController:MoveToTarget(dstTarget, moveToCallback, moveTimeScaler)
	self:MoveToPosition(dstTarget.transform.position, moveToCallback, moveTimeScaler or 1)
end

function MotionController:IsMoving()
	return self.isMoving
end

function MotionController:Stop()
	self.isMoving = false
	self.moveToCallback = nil
end

function MotionController:Update()
	if self.isMoving then
		local t = self.passedTime * self.inverseTotalTime
		local finished = false
		if t >= 1 then
			t = 1
			finished = true
		end

		local pos = self.transform.position
		pos.x = TweenUtility.Linear(self.srcPos.x, self.destPos.x, t)
		pos.z = TweenUtility.Linear(self.srcPos.z, self.destPos.z, t)
		self.transform.position = pos

		if finished then
			if self.moveToCallback ~= nil and self.moveToCallback.Arrived ~= nil then
				self.moveToCallback:Arrived()
			end
			self:Stop()
		end

		self.passedTime = self.passedTime + UnityEngine_Time.deltaTime
	end
end