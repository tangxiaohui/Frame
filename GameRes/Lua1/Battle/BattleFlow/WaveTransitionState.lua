--
-- User: fenghao
-- Date: 5/17/17
-- Time: 2:44 PM
--

-- 到 波次开始 过渡
local TransitionClass = require "Framework.FSM.Transition"

local WaveTransition2WaveStartTransition = Class(TransitionClass)

function WaveTransition2WaveStartTransition:Ctor()
end

function WaveTransition2WaveStartTransition:IsTriggered(_, data)
    return data.needToWaveStart == true
end

function WaveTransition2WaveStartTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.WaveStartState")
end

-- 波次过渡 状态
local StateClass = require "Framework.FSM.State"

local WaveTransitionState = Class(StateClass)

function WaveTransitionState:Ctor()
    self:AddTransition(WaveTransition2WaveStartTransition.New())
end

function WaveTransitionState:Enter(owner, data)
    print("WaveTransitionState:Enter >>>>>")
    data.needToWaveStart = true
end

function WaveTransitionState:Update(owner, data)
end

function WaveTransitionState:Exit(owner, data)
    print("WaveTransitionState:Exit >>>>>>")
end

return WaveTransitionState