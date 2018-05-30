--
-- User: fenghao
-- Date: 5/29/17
-- Time: 6:46 PM
--

local TransitionClass = require "Framework.FSM.Transition"

-- 到 断线 转换
local Connected2DisconnectedTransition = Class(TransitionClass)

function Connected2DisconnectedTransition:Ctor()
end

function Connected2DisconnectedTransition:IsTriggered(_, data)
end

function Connected2DisconnectedTransition:GetTargetState(_, data)
end

-- 到 返回登录场景 转换
local Connected2BackToLoginSceneTransition = Class(TransitionClass)

function Connected2BackToLoginSceneTransition:Ctor()
end

function Connected2BackToLoginSceneTransition:IsTriggered(_, data)
end

function Connected2BackToLoginSceneTransition:GetTargetState(_, data)
end



-- 状态 已连接
local StateClass = require "Framework.FSM.State"

local ConnectedState = Class(StateClass)

function ConnectedState:Ctor()
    self:AddTransition(Connected2DisconnectedTransition.New())
    self:AddTransition(Connected2BackToLoginSceneTransition.New())
end

function ConnectedState:Enter(owner, data)
end

function ConnectedState:Update(owner, data)
end

function ConnectedState:Exit(owner, data)
end

return ConnectedState