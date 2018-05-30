--
-- User: fenghao
-- Date: 06/07/2017
-- Time: 12:51 AM
--

local utility = require "Utils.Utility"

local TransitionClass = require "Framework.FSM.Transition"

-- 播放剧情 to 波次结束
local PlayScript2WaveEndTransition = Class(TransitionClass)

function PlayScript2WaveEndTransition:Ctor()
end

function PlayScript2WaveEndTransition:IsTriggered(_, data)
    return data.needToWaveEnd == true
end

function PlayScript2WaveEndTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.WaveEndState")
end

-- 播放剧情 to 准备开始
local PlayScript2PrepareStartTransition = Class(TransitionClass)

function PlayScript2PrepareStartTransition:Ctor()
end

function PlayScript2PrepareStartTransition:IsTriggered(_, data)
    return data.needToPrepareStart == true
end

function PlayScript2PrepareStartTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.PrepareStartState")
end

-- 播放剧情 to 战斗结束
local PlayScript2BattleEndTransition = Class(TransitionClass)

function PlayScript2BattleEndTransition:Ctor()
end

function PlayScript2BattleEndTransition:IsTriggered(_, data)
    return data.needToEndBattle == true
end

function PlayScript2BattleEndTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.BattleEndState")
end


local StateClass = require "Framework.FSM.State"
local PlayScriptState = Class(StateClass)

function PlayScriptState:Ctor()
    self:AddTransition(PlayScript2WaveEndTransition.New())
    self:AddTransition(PlayScript2PrepareStartTransition.New())
    self:AddTransition(PlayScript2BattleEndTransition.New())
end

local function SendActivateBattleUIEvents(active)
    local messageGuids = require "Framework.Business.MessageGuids"
    local game = utility.GetGame()
    game:DispatchEvent(messageGuids.BattleActivateSystemButtonList, nil, active)
    game:DispatchEvent(messageGuids.BattleActivateTopInformation, nil, active)
    game:DispatchEvent(messageGuids.BattleActivateRightProgress, nil, active)
end

local function ShowFirstFightBaseImage(self)
	local battlefield = self.cachedOwner:GetBattlefield()
	if self.waveNumber > battlefield:GetNumberOfLeftTeam() then
        self.cachedOwner:ShowFightBaseImage(0)

        local messageGuids = require "Framework.Business.MessageGuids"
        local game = utility.GetGame()
        game:DispatchEvent(messageGuids.BattleActivateCommonBaseImageInGroup2, nil)

        -- 结束之前一直隐藏 --
        local battlefield = self.cachedOwner:GetBattlefield()
        battlefield:SetActiveCurrentCameraObject(false)
	end
end

local function DoneState(self, data)
    -- 第一回合调到preparestart, 其他情况waveend
    local waveEnd = self.waveNumber > self.cachedOwner:GetBattlefield():GetNumberOfLeftTeam()
    if waveEnd then
        data.needToWaveEnd = true
    else
        data.needToPrepareStart = true
    end
end

local function OnScenarioCallback(self)
    SendActivateBattleUIEvents(true)
    DoneState(self, self.cachedData)
end

function PlayScriptState:Enter(owner, data)
    debug_print("^^^ PlayScriptState:Enter >>>>>>")

    -- >> 缓存
	self.cachedOwner = owner
    self.cachedData = data

    -- >> 更新waveNumber
    local waveNumber = owner:GetBattlefield():GetWaveNumber()
    if type(data.replacementScriptWaveNumber) == "number" then
        waveNumber = data.replacementScriptWaveNumber
        data.replacementScriptWaveNumber = nil
    end
    self.waveNumber = waveNumber


    -- >> 回放模式 or 没有配置剧情 都不会播放剧情
    if owner:IsReplayMode() or not owner:IsScriptEnabled() then
        DoneState(self, data)
        return
    end

    local ScriptUtility = require "Utils.ScriptUtility"
    -- >> 收集剧情步骤ID
    local collectedStepIds = ScriptUtility.GetScriptSteps(owner:GetBattleParams():GetScriptID(), waveNumber)
    -- 没有满足的剧情!
    if #collectedStepIds == 0 then
        DoneState(self, data)
        return
    end

    owner:SetBackgroundVolume(0.2)
	
	-- 显示第一场战斗的控件
	ShowFirstFightBaseImage(self)
	
    -- 隐藏其他控件 --
    SendActivateBattleUIEvents(false)
    
    local messageGuids = require "Framework.Business.MessageGuids"
    utility.GetGame():DispatchEvent(messageGuids.BattleActivateHpGroupObject, nil, false)

    -- 弹出剧情提示框 --
    local windowManager = utility.GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Scenario.Scenario", self, collectedStepIds, OnScenarioCallback)
end

function PlayScriptState:Update(owner, data)
end

function PlayScriptState:Exit(owner, data)
    debug_print("^^^ PlayScriptState:Exit >>>>>>")
	owner:SetBackgroundVolume(1)
    data.needToPrepareStart = nil
    data.needToWaveEnd = nil
end

return PlayScriptState

