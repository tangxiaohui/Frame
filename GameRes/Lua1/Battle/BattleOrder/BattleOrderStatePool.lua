--
-- User: fbmly
-- Date: 5/1/17
-- Time: 7:11 PM
--

local require = require
require "Framework.Pool.Pool"

local BattleOrderStatePool = Class(Pool)

local function GetStateImpl(prototype)
    return prototype.New()
end

function BattleOrderStatePool:Get(prototype)
    if self.states[prototype] ~= nil then
        return self.states[prototype]
    end

    local newState = GetStateImpl(prototype)
    self.states[prototype] = newState
    return newState
end

function BattleOrderStatePool:Ctor()
    self.states = {}
end

return BattleOrderStatePool