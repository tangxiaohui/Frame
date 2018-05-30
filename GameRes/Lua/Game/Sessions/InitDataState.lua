--
-- User: fenghao
-- Date: 5/29/17
-- Time: 6:34 PM
--

-- 到 跳转到欢迎画面 状态
local TransitionClass = require "Framework.FSM.Transition"

local InitData2JumpToSplashSceneTransition = Class(TransitionClass)

function InitData2JumpToSplashSceneTransition:Ctor()

end

function InitData2JumpToSplashSceneTransition:IsTriggered(_, data)
end

function InitData2JumpToSplashSceneTransition:GetTargetState(_, data)
end


-- 状态 初始化数据
local StateClass = require "Framework.FSM.State"

local InitDataState = Class(StateClass)

function InitDataState:Ctor()
    self:AddTransition(InitData2JumpToSplashSceneTransition.New())
end

function InitDataState:Enter(owner, data)
end

function InitDataState:Update(owner, data)
end

function InitDataState:Exit(owner, data)
end

return InitDataState