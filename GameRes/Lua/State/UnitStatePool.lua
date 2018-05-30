local require = require
require "Battle.States.StatePool"
require "Battle.States.State"

local UnitStatePool = Class(StatePool)

function UnitStatePool:GetState(id)
    return State.New(id)
end

function UnitStatePool:Get(id)
    if self.states[id] ~= nil then
        return self.states[id]
    end
    
    local newState = self:GetState(id)
    self.states[id] = newState
    return newState
end

local pool = UnitStatePool.New()
return pool