--
-- User: fenghao
-- Date: 5/29/17
-- Time: 6:51 PM
--

local TransitionClass = require "Framework.FSM.Transition"
-- 到 连接中 转换

local ReconnectingFade2ConnectingTransition = Class(TransitionClass)

function ReconnectingFade2ConnectingTransition:Ctor()
end

function ReconnectingFade2ConnectingTransition:IsTriggered(_, data)
end

function ReconnectingFade2ConnectingTransition:GetTargetState(_, data)
end


-- 状态 重连接过渡
local StateClass = require "Framework.FSM.State"

local ReconnectingFadeState = Class(StateClass)

function ReconnectingFadeState:Ctor()
    self:AddTransition(ReconnectingFade2ConnectingTransition.New())
end

function ReconnectingFadeState:Enter(owner, data)
end

function ReconnectingFadeState:Update(owner, data)
end

function ReconnectingFadeState:Exit(owner, data)
end

return ReconnectingFadeState