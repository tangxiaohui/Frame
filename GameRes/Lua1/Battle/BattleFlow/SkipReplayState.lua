--
-- User: fenghao
-- Date: 18/07/2017
-- Time: 2:08 AM
--

local TransitionClass = require "Framework.FSM.Transition"

-- 到 胜利结算的 转换 --
local SkipReplay2ShowVictoryResultTransition = Class(TransitionClass)

function SkipReplay2ShowVictoryResultTransition:Ctor()
end

function SkipReplay2ShowVictoryResultTransition:IsTriggered(_, data)
    return data.needToShowVectoryResult == true
end

function SkipReplay2ShowVictoryResultTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.ShowVictoryResultState")
end


-- 到 失败结算的 转换 --
local SkipReplay2ShowDefeatResultTransition = Class(TransitionClass)

function SkipReplay2ShowDefeatResultTransition:Ctor()
end

function SkipReplay2ShowDefeatResultTransition:IsTriggered(_, data)
    return data.needToShowDefeatResult == true
end

function SkipReplay2ShowDefeatResultTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.ShowDefeatResultState")
end


local StateClass = require "Framework.FSM.State"

local SkipReplayState = Class(StateClass)

local function SendActivateBattleUIEvents(active)
    local utility = require "Utils.Utility"
    local messageGuids = require "Framework.Business.MessageGuids"
    local game = utility.GetGame()
    game:DispatchEvent(messageGuids.BattleActivateSystemButtonList, nil, active)
    game:DispatchEvent(messageGuids.BattleActivateTopInformation, nil, active)
    game:DispatchEvent(messageGuids.BattleActivateRightProgress, nil, active)
end

function SkipReplayState:Ctor()
    self:AddTransition(SkipReplay2ShowVictoryResultTransition.New())
    self:AddTransition(SkipReplay2ShowDefeatResultTransition.New())
end

function SkipReplayState:Enter(owner, data)
    -- 清除数据 发消息 --
    owner:CancelBattlefieldEvents()
    SendActivateBattleUIEvents(false)

    local recordMessage = owner:GetLastBattleRecordMessage()
    if recordMessage.isWin then
        data.needToShowVectoryResult = true
    else
        data.needToShowDefeatResult = true
    end
end

function SkipReplayState:Update(owner, data)

end

function SkipReplayState:Exit(owner, data)
    data.needToShowVectoryResult = nil
    data.needToShowDefeatResult = nil
end

return SkipReplayState
