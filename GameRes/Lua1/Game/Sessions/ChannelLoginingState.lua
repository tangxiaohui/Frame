--
-- User: fenghao
-- Date: 5/29/17
-- Time: 6:54 PM
--

-- 到 请求服务器列表 转换
local TransitionClass = require "Framework.FSM.Transition"

local ChannelLogining2RequestServerListTransition = Class(TransitionClass)

function ChannelLogining2RequestServerListTransition:Ctor()
end

function ChannelLogining2RequestServerListTransition:IsTriggered(_, data)
end

function ChannelLogining2RequestServerListTransition:GetTargetState(_, data)
end


-- 状态 登录渠道
local StateClass = require "Framework.FSM.State"

local ChannelLoginingState = Class(StateClass)

function ChannelLoginingState:Ctor()
    self:AddTransition(ChannelLogining2RequestServerListTransition.New())
end

function ChannelLoginingState:Enter(owner, data)
end

function ChannelLoginingState:Update(owner, data)
end

function ChannelLoginingState:Exit(owner, data)
end

return ChannelLoginingState


