--
-- User: fenghao
-- Date: 5/30/17
-- Time: 5:31 PM
--

local TransitionClass = require "Framework.FSM.Transition"

-- 到 资源更新 转换
local JumpToLoginScene2AssetUpdatingTransition = Class(TransitionClass)

function JumpToLoginScene2AssetUpdatingTransition:Ctor()
end

function JumpToLoginScene2AssetUpdatingTransition:IsTriggered(_, data)
end

function JumpToLoginScene2AssetUpdatingTransition:GetTargetState(_, data)
end


-- 状态 跳转到登录场景
local StateClass = require "Framework.FSM.State"

local JumpToLoginSceneState = Class(StateClass)

function JumpToLoginSceneState:Ctor()
    self:AddTransition(JumpToLoginScene2AssetUpdatingTransition.New())
end

function JumpToLoginSceneState:Enter(owner, data)
end

function JumpToLoginSceneState:Update(owner, data)
end

function JumpToLoginSceneState:Exit(owner, data)
end

return JumpToLoginSceneState
