--
-- User: fenghao
-- Date: 5/16/17
-- Time: 8:54 PM
--

-- 开始中的 的Transition
local TransitionClass = require "Framework.FSM.Transition"

local PrepareStart2StartingTransition = Class(TransitionClass)

function PrepareStart2StartingTransition:Ctor()
end

function PrepareStart2StartingTransition:IsTriggered(_, data)
    return data.needToStartBattle == true
end

function PrepareStart2StartingTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.StartingState")
end

-- 
local PrepareStart2BattleEndTransition = Class(TransitionClass)

function PrepareStart2BattleEndTransition:Ctor()
end

function PrepareStart2BattleEndTransition:IsTriggered(_, data)
    return data.needToEndBattle == true
end

function PrepareStart2BattleEndTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.BattleEndState")
end


-- 战斗准备开始状态, 做一些等待, 显示UI的处理

local StateClass = require "Framework.FSM.State"

local PrepareStartState = Class(StateClass)

function PrepareStartState:Ctor()
    self:AddTransition(PrepareStart2StartingTransition.New())
    self:AddTransition(PrepareStart2BattleEndTransition.New())
end

local function DelayWaitFirstWave(owner, data)
    coroutine.wait(2)
    owner.battlefield:StartBattle()
    data.needToStartBattle = true
end

local function DelayWaitLaterWaves(owner, data)
    owner.battlefield:StartBattle()
    data.needToStartBattle = true
end

function PrepareStartState:Enter(owner, data)
    debug_print("^^^ PrepareStartState:Enter >>>>>>")

    local battlefield = owner:GetBattlefield()
    local numWave = battlefield:GetWaveNumber()
    if numWave == 1 then
--        print("PrepareStartState:Enter >>>> ")
        local animator = owner.battlefield:GetBattleStartAnimator()
        animator:Play("BattleStartAppearAnim")
        coroutine.start(DelayWaitFirstWave, owner, data)
    else
        coroutine.start(DelayWaitLaterWaves, owner, data)
    end

    local messageGuids = require "Framework.Business.MessageGuids"
    local utility = require "Utils.Utility"
    utility.GetGame():DispatchEvent(messageGuids.BattleActivateHpGroupObject, nil, true)
end

function PrepareStartState:Update(owner, data)
    owner.battleOrderStateMachine:Update()
end

function PrepareStartState:Exit(owner, data)
    debug_print("^^^ PrepareStartState:Exit >>>>> ")
    data.needToStartBattle = nil
end

return PrepareStartState