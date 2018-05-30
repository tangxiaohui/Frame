--
-- User: fenghao
-- Date: 5/16/17
-- Time: 8:58 PM
--

-- 到 播放剧情的Transition(最后的!)
local TransitionClass = require "Framework.FSM.Transition"

local Starting2PlayScriptTransition = Class(TransitionClass)

function Starting2PlayScriptTransition:Ctor()
end

function Starting2PlayScriptTransition:IsTriggered(owner, data)
    if data.battleResult ~= nil then
        local b1 = data.battleResult == true or owner:IsFirstFight()
        local b2 = not owner:GetBattlefield():HasNextFoeTeam()
        return b1 and b2
    end
    return false
end

function Starting2PlayScriptTransition:Execute(owner, data)
    -- 执行变换时让这个wave变成 最高波次+1.
    data.replacementScriptWaveNumber = owner:GetBattlefield():GetNumberOfLeftTeam() + 1
end

function Starting2PlayScriptTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.PlayScriptState")
end

-- 到 WaveEnd的Transition
local Starting2WaveEndTransition = Class(TransitionClass)

function Starting2WaveEndTransition:Ctor()
end

function Starting2WaveEndTransition:IsTriggered(_, data)
    return data.battleResult ~= nil
end

function Starting2WaveEndTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.WaveEndState")
end

-- 到 回放跳过 状态 --
local Starting2ReplaySkipTransition = Class(TransitionClass)

function Starting2ReplaySkipTransition:Ctor()
end

function Starting2ReplaySkipTransition:IsTriggered(_, data)
    return data.needToSkipReplayBattle == true
end

function Starting2ReplaySkipTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.SkipReplayState")
end

-- 到 暂停 状态 --
local Starting2PausingTransition = Class(TransitionClass)

function Starting2PausingTransition:Ctor()
end

function Starting2PausingTransition:IsTriggered(_, data)
    return data.needToPause == true
end

function Starting2PausingTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.PausingState")
end

-- 开始种 到 战斗结束
local Starting2BattleEndTransition = Class(TransitionClass)

function Starting2BattleEndTransition:Ctor()
end

function Starting2BattleEndTransition:IsTriggered(_, data)
    return data.needToEndBattle == true
end

function Starting2BattleEndTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.BattleEndState")
end


-- 战斗开始中(开始打的状态的)
local messageGuids = require "Framework.Business.MessageGuids"
local cos3dGame = require "Utils.Utility".GetGame()

local StateClass = require "Framework.FSM.State"

local StartingState = Class(StateClass)

function StartingState:Ctor()
    self:AddTransition(Starting2PlayScriptTransition.New())
    self:AddTransition(Starting2WaveEndTransition.New())
    self:AddTransition(Starting2ReplaySkipTransition.New())
    self:AddTransition(Starting2PausingTransition.New())
    self:AddTransition(Starting2BattleEndTransition.New())
end

local function OnBattleFinished(self, isWin)
    -- debug_print(">>>>>>> isWin", isWin) -- true or false
    self.cachedData.battleResult = isWin
end

local function OnBattleReplayButtonClicked(self)
    self.cachedData.needToSkipReplayBattle = true
end

-- 切换到暂停状态
local function OnPauseFight(self)
    debug_print("激活暂停事件!")
    self.cachedData.needToPause = true
end

-- 测试代码
local testpause_firstflag = nil
local function OnDelayEvent(self, data)
    coroutine.wait(3)
    if testpause_firstflag == nil then
        data.needToPause = true
        testpause_firstflag = true
    end
end

local function TestPause(self, data)
    coroutine.start(OnDelayEvent, self, data)
end

local function IsReplayMode(owner)
    return owner:IsReplayMode()
end

function StartingState:Enter(owner, data)
    debug_print("^^^ StartingState:Enter >>>>>>> ")
    self.cachedData = data
    self.cachedData.battleResult = nil
    owner.battlefield:ClearCallbackOnBattleFinished()
    owner.battlefield:SetCallbackOnBattleFinished(self, OnBattleFinished)

    if not owner:IsFirstFight() then
        cos3dGame:DispatchEvent(messageGuids.BattleActiveReplayButton, nil, true)
    end

    if IsReplayMode(owner) then
        cos3dGame:RegisterEvent(messageGuids.BattleReplayButtonClicked, self, OnBattleReplayButtonClicked, nil)
    end

    -- 注册暂停事件
    cos3dGame:RegisterEvent(messageGuids.BattlePauseFight, self, OnPauseFight, nil)
end

function StartingState:Update(owner, data)
    owner.battlefield:Update()
    owner.battleOrderStateMachine:Update()
end

function StartingState:Exit(owner, data)
    debug_print("^^^ StartingState:Exit >>>>>>>> ")
    if not owner:IsFirstFight() then
        cos3dGame:DispatchEvent(messageGuids.BattleActiveReplayButton, nil, false)
    end

    if IsReplayMode(owner) then
        cos3dGame:UnregisterEvent(messageGuids.BattleReplayButtonClicked, self, OnBattleReplayButtonClicked, nil)
    end
    cos3dGame:UnregisterEvent(messageGuids.BattlePauseFight, self, OnPauseFight, nil)

    self.cachedData = nil
    data.needToSkipReplayBattle = nil
    data.needToPause = nil
    owner.battlefield:ClearCallbackOnBattleFinished()
end

return StartingState
