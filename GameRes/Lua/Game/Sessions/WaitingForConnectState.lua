--
-- User: fenghao
-- Date: 5/29/17
-- Time: 6:44 PM
--

-- 到 连接中 转换
local TransitionClass = require "Framework.FSM.Transition"

local WaitingForConnect2ConnectingTransition = Class(TransitionClass)

function WaitingForConnect2ConnectingTransition:Ctor()
end

function WaitingForConnect2ConnectingTransition:IsTriggered(_, data)
end

function WaitingForConnect2ConnectingTransition:GetTargetState(_, data)
end


-- 状态 等待连接
local StateClass = require "Framework.FSM.State"

local WaitingForConnectState = Class(StateClass)

function WaitingForConnectState:Ctor()
    self:AddTransition(WaitingForConnect2ConnectingTransition.New())
end

function WaitingForConnectState:Enter(owner, data)
end

function WaitingForConnectState:Update(owner, data)
end

function WaitingForConnectState:Exit(owner, data)
end

return WaitingForConnectState