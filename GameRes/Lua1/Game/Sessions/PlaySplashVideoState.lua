--
-- User: fenghao
-- Date: 5/29/17
-- Time: 6:35 PM
--

-- 到 跳转到登录场景 转换
local TransitionClass = require "Framework.FSM.Transition"

local PlaySplashVideo2JumpToLoginSceneTransition = Class(TransitionClass)

function PlaySplashVideo2JumpToLoginSceneTransition:Ctor()
end

function PlaySplashVideo2JumpToLoginSceneTransition:IsTriggered(_, data)
end

function PlaySplashVideo2JumpToLoginSceneTransition:GetTargetState(_, data)
end



-- 状态 播放欢迎画面视频
local StateClass = require "Framework.FSM.State"

local PlaySplashVideoState = Class(StateClass)

function PlaySplashVideoState:Ctor()
    self:AddTransition(PlaySplashVideo2JumpToLoginSceneTransition.New())
end

function PlaySplashVideoState:Enter(owner, data)
end

function PlaySplashVideoState:Update(owner, data)
end

function PlaySplashVideoState:Exit(owner, data)
end

return PlaySplashVideoState
