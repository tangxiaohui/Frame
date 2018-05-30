--
-- User: fenghao
-- Date: 5/29/17
-- Time: 6:55 PM
--

local TransitionClass = require "Framework.FSM.Transition"

-- 到 初始化数据 转换

local Restarting2InitDataTransition = Class(TransitionClass)

function Restarting2InitDataTransition:Ctor()
end

function Restarting2InitDataTransition:IsTriggered(_, data)
end

function Restarting2InitDataTransition:GetTargetState(_, data)
end


-- 状态 重启
local StateClass = require "Framework.FSM.State"

local RestartingState = Class(StateClass)

function RestartingState:Ctor()
    self:AddTransition(Restarting2InitDataTransition.New())
end

function RestartingState:Enter(owner, data)
end

function RestartingState:Update(owner, data)
end

function RestartingState:Exit(owner, data)
end

return RestartingState
