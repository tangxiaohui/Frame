require "Class"
local BaseStateClass = require "Framework.FSM.State"

local StateMachine = Class(BaseStateClass)

function StateMachine:Ctor(owner, initialState, data)
	if owner == nil then
		error("owner不能为nil")
	end

	if initialState == nil then
		error("初始状态不能为 nil")
	end

	self.owner = owner

	self.nextState = initialState
	self.nextTransition = nil

	self.activeState = nil
	self.data = data or {}
end

function StateMachine:GetActiveState()
	return self.activeState
end

function StateMachine:GetData()
	return self.data
end

function StateMachine:GetOwner()
	return self.owner
end

local function SetNextState(self)
	if self.nextState ~= nil then
		-- 当前状态退出 --
		if self.activeState ~= nil then
			self.activeState:Exit(self.owner, self.data)
		end

		-- 执行过渡 --
		if self.nextTransition ~= nil then
			self.nextTransition:Execute(self.owner, self.data)
		end

		self.activeState = self.nextState
		self.nextState = nil
		self.nextTransition = nil

		-- 执行Enter --
		self.activeState:Enter(self.owner, self.data)
	end
end

function StateMachine:Update()
	SetNextState(self)

	-- 当前状态有效
	if self.activeState then
		local triggeredTransition = self.activeState:GetTriggeredTransition(self.owner, self.data)
		if triggeredTransition then
			-- 获取当前Transition所指向的状态 作为新状态
			local newState = triggeredTransition:GetTargetState(self.owner, self.data)
			self.nextState = newState
			self.nextTransition = triggeredTransition
			return
		end

		-- 执行当前状态的Update
 		self.activeState:Update(self.owner, self.data)
	end
end

function StateMachine:Close()
	if self.activeState then
		self.activeState:Exit(self.owner, self.data)
		self.activeState = nil
	end
	self.nextState = nil
	self.nextTransition = nil
end

function StateMachine:ToString()
	return "StateMachine"
end

return StateMachine
