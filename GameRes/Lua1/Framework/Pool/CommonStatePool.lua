--
-- User: fenghao
-- Date: 5/9/17
-- Time: 5:57 PM
--

local require = require
require "Framework.Pool.Pool"

local CommonStatePool = Class(Pool)

local function GetStateImpl(prototype)
    return prototype.New()
end

function CommonStatePool:Get(prototype)
    if self.states[prototype] ~= nil then
        return self.states[prototype]
    end

    local newState = GetStateImpl(prototype)
    self.states[prototype] = newState
    return newState
end

function CommonStatePool:Ctor()
    self.states = {}
end

return CommonStatePool

