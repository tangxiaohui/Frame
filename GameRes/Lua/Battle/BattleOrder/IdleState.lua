--
-- User: fbmly
-- Date: 5/1/17
-- Time: 4:08 PM
--

-- 消息相关


-- Transition Idle 2 FrameDelay.
local TransitionClass = require "Framework.FSM.Transition"

local Idle2FrameDelayTransition = Class(TransitionClass)

function Idle2FrameDelayTransition:Ctor()
end

function Idle2FrameDelayTransition:IsTriggered(_, data)
    return data.unitsToDisappear ~= nil and #data.unitsToDisappear > 0
end

function Idle2FrameDelayTransition:GetTargetState(_, data)
    return data.BattleOrderStatePool:Get(require "Battle.BattleOrder.FrameDelayState")
end



-- State Idle.
local StateClass = require "Framework.FSM.State"

local IdleState = Class(StateClass)

function IdleState:Ctor()
    self:AddTransition(Idle2FrameDelayTransition.New())
end

function IdleState:Enter(_, _)
    print("BattleOrderState, IdleState:Enter")
end
--
--function IdleState:Update(_, data)
--end
--
function IdleState:Exit(_, _)
    print("BattleOrderState, IdleState:Exit")
end
--
--function IdleState:Close(owner, data)
--end

return IdleState
