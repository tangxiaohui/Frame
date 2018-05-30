--
-- User: fenghao
-- Date: 5/29/17
-- Time: 6:46 PM
--

local TransitionClass = require "Framework.FSM.Transition"

-- 到 重新连接过渡 转换
local Disconnected2ReconnectingFadeTransition = Class(TransitionClass)

function Disconnected2ReconnectingFadeTransition:Ctor()
end

function Disconnected2ReconnectingFadeTransition:IsTriggered(_, data)
end

function Disconnected2ReconnectingFadeTransition:GetTargetState(_, data)
end

-- 到 返回登录过渡 转换
local Disconnected2BackToLoginSceneTransition = Class(TransitionClass)

function Disconnected2BackToLoginSceneTransition:Ctor()
end

function Disconnected2BackToLoginSceneTransition:IsTriggered(_, data)
end

function Disconnected2BackToLoginSceneTransition:GetTargetState(_, data)
end


-- 状态 断线
local StateClass = require "Framework.FSM.State"

local DisconnectedState = Class(StateClass)

function DisconnectedState:Ctor()
    self:AddTransition(Disconnected2ReconnectingFadeTransition.New())
    self:AddTransition(Disconnected2BackToLoginSceneTransition.New())
end

function DisconnectedState:Enter(owner, data)
end

function DisconnectedState:Update(owner, data)
end

function DisconnectedState:Exit(owner, data)
end

return DisconnectedState