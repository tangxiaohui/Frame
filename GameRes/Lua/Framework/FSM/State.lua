--require "Transition"
require "Class"

local State = Class()

function State:Ctor()
	self.transitions = {}
end

function State:Enter(owner, data)
end

function State:Update(owner, data)
end

function State:Exit(owner, data)
end

function State:AddTransition(transition)
	if transition then
		self.transitions[#self.transitions + 1] = transition
	end
end

function State:RemoveTransition(transition)
	if transition then
		for i = 1, #self.transitions do
			if self.transitions[i] == transition then
				table.remove(self.transitions, i)
				break
			end
		end
	end
end

function State:GetTriggeredTransition(owner, data)
	local transitions = self.transitions
	if transitions then
		for i = 1, #transitions do
			if transitions[i] and transitions[i]:IsTriggered(owner, data) then
				return transitions[i]
			end
		end
	end
	return nil
end

return State