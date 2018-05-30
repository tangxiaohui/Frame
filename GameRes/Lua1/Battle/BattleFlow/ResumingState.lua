--
-- User: fenghao
-- Date: 5/17/17
-- Time: 2:40 PM
--

local TransitionClass = require "Framework.FSM.Transition"

local Resuming2StartingTransition = Class(TransitionClass)

function Resuming2StartingTransition:Ctor()
end

function Resuming2StartingTransition:IsTriggered(_, data)
    return data.needToStartBattle == true
end

function Resuming2StartingTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.StartingState")
end


-- 恢复 状态
local StateClass = require "Framework.FSM.State"

local ResumingState = Class(StateClass)

function ResumingState:Ctor()
    self:AddTransition(Resuming2StartingTransition.New())
end

-- local function OnDelayEvent(self, owner, data)
--     coroutine.wait(3)
--     data.needToStartBattle = true
--     coroutine.step(1)
--     -- 恢复战斗 --
--     owner:GetBattlefield():Resume()
--     UnityEngine.Time.timeScale = owner:GetCurrentSpeed()
-- end

function ResumingState:Enter(owner, data)
    debug_print("ResumingState:Enter >>> ")

    data.needToStartBattle = true
    owner:GetBattlefield():Resume()
    UnityEngine.Time.timeScale = owner:GetCurrentSpeed()
    
    -- TODO 这里可以显示倒计时的UI
    -- coroutine.start(OnDelayEvent, self, owner, data)
end

function ResumingState:Update(owner, data)
end

function ResumingState:Exit(owner, data)
    debug_print("ResumingState:Exit >>> ")
    data.needToStartBattle = nil
end

return ResumingState
