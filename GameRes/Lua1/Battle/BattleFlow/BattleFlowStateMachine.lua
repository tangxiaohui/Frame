--
-- User: fenghao
-- Date: 5/16/
-- Time: 5:44 PM
--

-- 战斗流程管理的状态机
-- 负责战斗流程的管理, 从 战斗开始 波次开始 波次结束 到战斗结束等

local StateMachineClass = require "Framework.FSM.StateMachine"
local messageGuids = require "Framework.Business.MessageGuids"
local utility = require "Utils.Utility"
    

local BattleFlowStateMachine = Class(StateMachineClass)

local function OnJumpScene(self)
    -- debug_print("@@@@@@ JumpScene @@@@@@@")
    self.data.needToEndBattle = true
end

function BattleFlowStateMachine:Ctor()
    utility.GetGame():RegisterEvent(messageGuids.JumpToNormalScene, self, OnJumpScene)
end

function BattleFlowStateMachine:Close()
    utility.GetGame():UnregisterEvent(messageGuids.JumpToNormalScene, self, OnJumpScene)
    BattleFlowStateMachine.base.Close(self)
end

return BattleFlowStateMachine
