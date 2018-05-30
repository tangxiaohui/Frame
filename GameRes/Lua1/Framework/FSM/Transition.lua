-- require "Condition"
require "Class"

local Transition = Class()

function Transition:Ctor()
	self.condition = nil
	self.targetState = nil
end

function Transition:IsTriggered(owner, data)
	if self.condition then
		return self.condition:Test(owner, data)
	end
	return true
end

function Transition:SetTargetState(state)
	self.targetState = state
end

function Transition:GetTargetState()
	error('not implemented!')
end

function Transition:Execute(owner, data)
end

return Transition