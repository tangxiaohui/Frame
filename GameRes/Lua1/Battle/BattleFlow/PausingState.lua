--
-- User: fenghao
-- Date: 5/17/17
-- Time: 2:38 PM
--

local TransitionClass = require "Framework.FSM.Transition"

-- 暂停2恢复
local Pausing2ResumingTransition = Class(TransitionClass)

function Pausing2ResumingTransition:Ctor()
end

function Pausing2ResumingTransition:IsTriggered(_, data)
    return data.needToResume == true
end

function Pausing2ResumingTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.ResumingState")
end

-- 暂停 到 战斗结束
local Pausing2BattleEndTransition = Class(TransitionClass)

function Pausing2BattleEndTransition:Ctor()
end

function Pausing2BattleEndTransition:IsTriggered(_, data)
    return data.needToEndBattle == true
end

function Pausing2BattleEndTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.BattleEndState")
end



-- 暂停时 状态
local StateClass = require "Framework.FSM.State"
local messageGuids = require "Framework.Business.MessageGuids"
local cos3dGame = require "Utils.Utility".GetGame()

local PausingState = Class(StateClass)

function PausingState:Ctor()
    self:AddTransition(Pausing2ResumingTransition.New())
    self:AddTransition(Pausing2BattleEndTransition.New())
end

-- 处理战斗的恢复
local function OnResumeFight(self)
    debug_print("激活恢复事件!")
    self.cachedData.needToResume = true
end

local function OnBattleExitFight(self)
    debug_print("结束战斗!!!")
    self.cachedData.needToEndBattle = true
end

function PausingState:Enter(owner, data)
    debug_print("PausingState:Enter >>>>>")
    self.cachedData = data
   
    owner:GetBattlefield():Pause()
    UnityEngine.Time.timeScale = 0
    
    -- 注册Resume事件
    cos3dGame:RegisterEvent(messageGuids.BattleResumeFight, self, OnResumeFight, nil)
    cos3dGame:RegisterEvent(messageGuids.BattleExitFight, self, OnBattleExitFight, nil)
end

function PausingState:Update(owner, data)
    
end

function PausingState:Exit(owner, data)
    debug_print("PausingState:Exit >>>>>")
    data.needToResume = nil
    data.needToEndBattle = nil

    -- 取消注册Resume事件
    cos3dGame:UnregisterEvent(messageGuids.BattleResumeFight, self, OnResumeFight, nil)
    cos3dGame:UnregisterEvent(messageGuids.BattleExitFight, self, OnBattleExitFight, nil)
end

return PausingState
