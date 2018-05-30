--
-- User: fenghao
-- Date: 5/29/17
-- Time: 6:55 PM
--

local TransitionClass = require "Framework.FSM.Transition"

-- 到 准备登录 转换
local BackToLoginScene2PrepareToLoginChannelTransition = Class(TransitionClass)

function BackToLoginScene2PrepareToLoginChannelTransition:Ctor()
end

function BackToLoginScene2PrepareToLoginChannelTransition:IsTriggered(_, data)
end

function BackToLoginScene2PrepareToLoginChannelTransition:GetTargetState(_, data)
end


-- 状态 返回登录场景
local StateClass = require "Framework.FSM.State"

local BackToLoginSceneState = Class(StateClass)

function BackToLoginSceneState:Ctor()
    self:AddTransition(BackToLoginScene2PrepareToLoginChannelTransition.New())
end

function BackToLoginSceneState:Enter(owner, data)
end

function BackToLoginSceneState:Update(owner, data)
end

function BackToLoginSceneState:Exit(owner, data)
end

return BackToLoginSceneState