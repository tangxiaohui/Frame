--
-- User: fenghao
-- Date: 5/29/17
-- Time: 6:42 PM
--

-- 到 登录渠道的 转换
local TransitionClass = require "Framework.FSM.Transition"

local PrepareToLoginChannel2ChannelLoginingTransition = Class(TransitionClass)

function PrepareToLoginChannel2ChannelLoginingTransition:Ctor()
end

function PrepareToLoginChannel2ChannelLoginingTransition:IsTriggered(_, data)
end

function PrepareToLoginChannel2ChannelLoginingTransition:GetTargetState(_, data)
end


-- 状态 准备登录渠道
local StateClass = require "Framework.FSM.State"

local PrepareToLoginChannelState = Class(StateClass)

function PrepareToLoginChannelState:Ctor()
    self:AddTransition(PrepareToLoginChannel2ChannelLoginingTransition.New())
end

function PrepareToLoginChannelState:Enter(owner, data)
end

function PrepareToLoginChannelState:Update(owner, data)
end

function PrepareToLoginChannelState:Exit(owner, data)
end

return PrepareToLoginChannelState