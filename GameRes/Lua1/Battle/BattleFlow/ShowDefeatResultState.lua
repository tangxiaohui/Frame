--
-- User: fenghao
-- Date: 5/19/17
-- Time: 11:36 AM
--
-- 到 战斗结束的Transition
local TransitionClass = require "Framework.FSM.Transition"

local ShowDefeatResult2BattleEndTransition = Class(TransitionClass)

function ShowDefeatResult2BattleEndTransition:Ctor()
end

function ShowDefeatResult2BattleEndTransition:IsTriggered(_, data)
    return data.needToEndBattle == true
end

function ShowDefeatResult2BattleEndTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.BattleEndState")
end


-- 失败 结算 状态
local StateClass = require "Framework.FSM.State"

local ShowDefeatResultState = Class(StateClass)

function ShowDefeatResultState:Ctor()
    self:AddTransition(ShowDefeatResult2BattleEndTransition.New())
end

function ShowDefeatResultState:Enter(owner, data)
    debug_print("ShowDefeatResultState:Enter >>>>>")
	
	owner:SetBackgroundVolume(0)
	
    self.cachedOwner = owner
    self.cachedData = data


    local firstFightConfig = owner:GetFirstFightConfig()
    if firstFightConfig ~= nil and firstFightConfig:IsOffline() then
        data.needToEndBattle = true
        return
    end

    local myGame = require "Utils.Utility".GetGame()
    myGame:GetAudioManager():PlaySE(16)

    local BattleResultModuleClass = require "GUI.Modules.BattleResultModule"
    local windowManager = owner:GetGame():GetWindowManager()
    local battleResultWindowInstance = windowManager:Show(BattleResultModuleClass)
    battleResultWindowInstance:SetWin(false)
    battleResultWindowInstance:SetOwner(owner)
    battleResultWindowInstance:SetCloseCallback(self, self.OnResultWindowClose)
    self.battleResultWindow = battleResultWindowInstance
end

function ShowDefeatResultState:Update(owner, data)
end

function ShowDefeatResultState:Exit(owner, data)
    debug_print("ShowDefeatResultState:Exit >>>>>>>")
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

function ShowDefeatResultState:OnResultWindowClose(replay)
    if not replay then
        self.cachedData.needToEndBattle = true
    else
        -- 回放 --
        local utility = require "Utils.Utility"
        local fightRecordMessage = self.cachedOwner:GetLastBattleRecordMessage()
        utility.StartReplay(fightRecordMessage, self.cachedData.battleResultMsg)
    end
end

return ShowDefeatResultState