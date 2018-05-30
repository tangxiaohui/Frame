--
-- User: fenghao
-- Date: 5/16/17
-- Time: 8:41 PM
--

-- 到 准备动作的Transition
local TransitionClass = require "Framework.FSM.Transition"

local WaveStart2WaveStartShowOffTransition = Class(TransitionClass)

function WaveStart2WaveStartShowOffTransition:Ctor()
end

function WaveStart2WaveStartShowOffTransition:IsTriggered(_, data)
    return data.needToPlayWaveStartShowOff == true
end

function WaveStart2WaveStartShowOffTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.WaveStartShowOffState")
end

-- 到 战斗结束的 转换
local WaveStart2BattleEndTransition = Class(TransitionClass)

function WaveStart2BattleEndTransition:Ctor()
end

function WaveStart2BattleEndTransition:IsTriggered(_, data)
    return data.needToEndBattle == true
end

function WaveStart2BattleEndTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.BattleEndState")
end


-- 波次开始 状态
local StateClass = require "Framework.FSM.State"

local WaveStartState = Class(StateClass)

function WaveStartState:Ctor()
    self:AddTransition(WaveStart2WaveStartShowOffTransition.New())
    self:AddTransition(WaveStart2BattleEndTransition.New())
end

function WaveStartState:Enter(owner, data)
    print("WaveStartState:Enter >>>>>>")

    local battlefield = owner:GetBattlefield()
    
    battlefield:NextWave(function()
        -- 进入新的波次
        local messageGuids = require "Framework.Business.MessageGuids"
        local utility = require "Utils.Utility"
        local myGame = utility.GetGame()
        myGame:DispatchEvent(messageGuids.FightWaveEnter, nil, battlefield:GetWaveNumber())
        data.needToPlayWaveStartShowOff = true
    end)
end

function WaveStartState:Update(owner, data)
end

function WaveStartState:Exit(_, data)
    print("WaveStartState:Exit >>>>>>")
    data.needToPlayWaveStartShowOff = nil
end

return WaveStartState
