require "Battle.States.State"
require "Const"

CommonState = Class(State)

function CommonState:Ctor()
end

function CommonState:Enter(owner, data, isReenter)
end

function CommonState:Execute()
end

function CommonState:Exit(owner, data)
end