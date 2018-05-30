--
-- User: fenghao
-- Date: 5/30/17
-- Time: 5:24 PM
--

local TransitionClass = require "Framework.FSM.Transition"

-- 到 播放欢迎视频 转换
local JumpToSplashScene2PlaySplashVideoTransition = Class(TransitionClass)

function JumpToSplashScene2PlaySplashVideoTransition:Ctor()
end

function JumpToSplashScene2PlaySplashVideoTransition:IsTriggered(_, data)
end

function JumpToSplashScene2PlaySplashVideoTransition:GetTargetState(_, data)
end



-- 状态 跳转到欢迎画面
local StateClass = require "Framework.FSM.State"

local JumpToSplashSceneState = Class(StateClass)

function JumpToSplashSceneState:Ctor()
    self:AddTransition(JumpToSplashScene2PlaySplashVideoTransition.New())
end

function JumpToSplashSceneState:Enter(owner, data)
end

function JumpToSplashSceneState:Update(owner, data)
end

function JumpToSplashSceneState:Exit(owner, data)
end

return JumpToSplashSceneState