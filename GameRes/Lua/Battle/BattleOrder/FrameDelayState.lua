--
-- User: fbmly
-- Date: 5/1/17
-- Time: 4:16 PM
--

-- 延迟一帧处理 --
-- Transition FrameDelay 2 Disappear.
local TransitionClass = require "Framework.FSM.Transition"

local FrameDelay2DisappearTransition = Class(TransitionClass)

function FrameDelay2DisappearTransition:Ctor()
end

function FrameDelay2DisappearTransition:IsTriggered(_, data)
    return (Time.frameCount - data.__enterDelayFrame) >= 1
end

function FrameDelay2DisappearTransition:GetTargetState(_, data)
    return data.BattleOrderStatePool:Get(require "Battle.BattleOrder.DisappearState")
end

-- State FrameDelay.
local StateClass = require "Framework.FSM.State"

local FrameDelayState = Class(StateClass)

function FrameDelayState:Ctor()
    self:AddTransition(FrameDelay2DisappearTransition.New())
end

function FrameDelayState:Enter(_, data)
    print("BattleOrderState, DisappearState:Enter")
    data.__enterDelayFrame = Time.frameCount
end

function FrameDelayState:Update(_, _)
end

function FrameDelayState:Exit(_, data)
    print("BattleOrderState, DisappearState:Exit")
    data.__enterDelayFrame = nil
end

return FrameDelayState
