--
-- User: fenghao
-- Date: 5/17/17
-- Time: 2:47 PM
--

-- 到 战斗结束的Transition
local TransitionClass = require "Framework.FSM.Transition"

local ShowVictoryResult2BattleEndTransition = Class(TransitionClass)

function ShowVictoryResult2BattleEndTransition:Ctor()
end

function ShowVictoryResult2BattleEndTransition:IsTriggered(_, data)
    return data.needToEndBattle == true
end

function ShowVictoryResult2BattleEndTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.BattleEndState")
end



-- 胜利 结算 状态
local StateClass = require "Framework.FSM.State"
local utility = require "Utils.Utility"

local ShowVictoryResultState = Class(StateClass)

function ShowVictoryResultState:Ctor()
    self:AddTransition(ShowVictoryResult2BattleEndTransition.New())
end

function ShowVictoryResultState:Enter(owner, data)
    debug_print("ShowVictoryResultState:Enter >>>>>>>")

	owner:SetBackgroundVolume(0)
	
    self.cachedOwner = owner
    self.cachedData = data

    local windowManager = owner:GetGame():GetWindowManager()
    local battleParams = owner:GetBattleParams()
    local ResultViewClassName = battleParams:GetBattleResultViewClassName()

    if type(ResultViewClassName) == "string" and data.battleResultMsg ~= nil then
        utility.GetGame():GetAudioManager():PlaySE(15)

        local ResultViewClass = require(ResultViewClassName)
        local battleResultWindowInstance = windowManager:Show(ResultViewClass)
        battleResultWindowInstance:SetWin(true)
        battleResultWindowInstance:SetCloseCallback(self, self.OnResultWindowClose)
        battleResultWindowInstance:SetOwner(owner)
        battleResultWindowInstance:SetBattleResultMsg(data.battleResultMsg)
        self.battleResultWindow = battleResultWindowInstance
    else
        self:OnResultWindowClose(false)
    end
end

function ShowVictoryResultState:OnResultWindowClose(replay)
--    print("OnResultWindowClose!!!@@@@@~~~###")
    debug_print("###### OnResultWindowClose !!!!!", replay)
    if not replay then
        self.cachedData.needToEndBattle = true
    else
        -- 回放 --
        local utility = require "Utils.Utility"
        local fightRecordMessage = self.cachedOwner:GetLastBattleRecordMessage()
        utility.StartReplay(fightRecordMessage, self.cachedData.battleResultMsg)
    end
end

function ShowVictoryResultState:Update(owner, data)
end

function ShowVictoryResultState:Exit(owner, data)
    debug_print("ShowVictoryResultState:Exit >>>>>>>>")
    self.cachedData = nil
    data.needToEndBattle = nil

    if self.battleResultWindow ~= nil then
        local windowManager = owner:GetGame():GetWindowManager()
        windowManager:Close(self.battleResultWindow, true)
        self.battleResultWindow = nil
    end
	
    owner:StopBackgroundMusic()
    owner:SetBackgroundVolume(1)
end

return ShowVictoryResultState
