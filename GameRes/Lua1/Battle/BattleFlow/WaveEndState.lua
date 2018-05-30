--
-- User: fenghao
-- Date: 5/17/17
-- Time: 2:45 PM
--

-- 到 胜利结算的Transition
local TransitionClass = require "Framework.FSM.Transition"

-- 到 波次过渡 的 Transition
local WaveEnd2WaveTransitionTransition = Class(TransitionClass)

function WaveEnd2WaveTransitionTransition:Ctor()
end

function WaveEnd2WaveTransitionTransition:IsTriggered(_, data)
    return data.needToWaveTransition == true
end

function WaveEnd2WaveTransitionTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.WaveTransitionState")
end

-- 到 胜利 脚本
local WaveEnd2ShowVictoryResultTransition = Class(TransitionClass)

function WaveEnd2ShowVictoryResultTransition:Ctor()
end

function WaveEnd2ShowVictoryResultTransition:IsTriggered(_, data)
    return data.needToShowVectoryResult == true
end

function WaveEnd2ShowVictoryResultTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.ShowVictoryResultState")
end

function WaveEnd2ShowVictoryResultTransition:Execute()
    debug_print("WaveEnd2ShowVictoryResultTransition:Execute")
    local messageGuids = require "Framework.Business.MessageGuids"
    utility.GetGame():DispatchEvent(messageGuids.BattleActivateHpGroupObject, nil, false)
end

-- 到 失败 脚本
local WaveEnd2ShowDefeatResultTransition = Class(TransitionClass)

function WaveEnd2ShowDefeatResultTransition:Ctor()
end

function WaveEnd2ShowDefeatResultTransition:IsTriggered(_, data)
    return data.needToShowDefeatResult == true
end

function WaveEnd2ShowDefeatResultTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.ShowDefeatResultState")
end

function WaveEnd2ShowDefeatResultTransition:Execute()
    debug_print("WaveEnd2ShowDefeatResultTransition:Execute")
    local messageGuids = require "Framework.Business.MessageGuids"
    utility.GetGame():DispatchEvent(messageGuids.BattleActivateHpGroupObject, nil, false)
end



-- 波次结束 状态
local StateClass = require "Framework.FSM.State"

local net = require "Network.Net"
local utility = require "Utils.Utility"

local WaveEndState = Class(StateClass)

function WaveEndState:Ctor()
    self:AddTransition(WaveEnd2ShowVictoryResultTransition.New())
    self:AddTransition(WaveEnd2ShowDefeatResultTransition.New())
    self:AddTransition(WaveEnd2WaveTransitionTransition.New())
end

function WaveEndState:IsOffline(owner)
    local firstFight = owner:GetFirstFightConfig()
    if firstFight ~= nil and firstFight:IsOffline() then
        return true
    end

    return owner:IsReplayMode()
end

local function RegisterEvents(self, owner, _)
    if self:IsOffline(owner) then
        return
    end

    utility.GetGame():RegisterMsgHandler(net.FightRecordResult, self, self.OnFightRecordResponse)

    local battleParams = owner:GetBattleParams()
    local response = battleParams:GetBattleResultResponsePrototype()
    utility.GetGame():RegisterMsgHandler(response, self, self.OnBattleResultResponse)
end

local function UnregisterEvents(self, owner, _)
    if self:IsOffline(owner) then
        return
    end

    utility.GetGame():UnRegisterMsgHandler(net.FightRecordResult, self, self.OnFightRecordResponse)

    local battleParams = owner:GetBattleParams()
    local response = battleParams:GetBattleResultResponsePrototype()
    utility.GetGame():UnRegisterMsgHandler(response, self, self.OnBattleResultResponse)
end

local function GetBattleResultLocalDataName(self)
    local battleParams = self.cachedOwner:GetBattleParams()
    return battleParams:GetBattleOverLocalDataName()
end

function WaveEndState:Enter(owner, data)
    debug_print("^^^ WaveEndState:Enter >>>>>>>")

    self.cachedOwner = owner
    self.cachedData = data

    -- 记录胜利或者失败
    self.battleResult = self.cachedData.battleResult
    self.cachedData.battleResult = nil

    debug_print("@@战斗结束, 胜利?", self.battleResult)

    -- @ 1. 注册事件
    RegisterEvents(self, owner, data)


    local messageGuids = require "Framework.Business.MessageGuids"
    local myGame = utility.GetGame()

    -- @ 2. 当前波次结束 发送消息
    myGame:DispatchEvent(messageGuids.FightWaveExit, nil)


    -- 胜利才能判断 是否有没有下波怪!!
    self.noMoreWave = true
    if self.battleResult then
        -- 设置下一个游标 --
        local battlefield = owner:GetBattlefield()
        if battlefield:HasNextFoeTeam() then
            self.noMoreWave = false
            data.needToWaveTransition = true
            return
        end
    end

    -- @ 3. 战斗结束 --
    myGame:DispatchEvent(messageGuids.FightFightExit, nil)

    -- 最后一波处理的逻辑 --
    -- 先删除上次残留数据(如果有) --
    if not self:IsOffline(owner) then
        local name = GetBattleResultLocalDataName(self)
        local localDataMgr = utility.GetGame():GetLocalDataManager()
        localDataMgr:Drop(name)
    end

    -- 清除数据 发消息 --
    owner:CancelBattlefieldEvents()

    if not self:IsOffline(owner) then
        debug_print("@@发送战斗结束协议, 胜利?", self.battleResult)
        owner:SendBattleRecord(self.battleResult)
    else
        self:OnFightRecordResponse()
        self:OnBattleResultResponse()
    end
end

--function WaveEndState:Update(owner, data)
--end

function WaveEndState:Exit(owner, data)
    debug_print("^^^ WaveEndState:Exit >>>>>>>")

    self.cachedOwner = nil
    self.cachedData = nil

    -- @ 2. 注册事件
    UnregisterEvents(self, owner, data)

--    data.needToShowVectoryResult = nil
--    data.needToShowDefeatResult = nil
    data.needToWaveTransition = nil
end

local function SendActivateBattleUIEvents(active)
    local messageGuids = require "Framework.Business.MessageGuids"
    local game = utility.GetGame()
    game:DispatchEvent(messageGuids.BattleActivateSystemButtonList, nil, active)
    game:DispatchEvent(messageGuids.BattleActivateTopInformation, nil, active)
    game:DispatchEvent(messageGuids.BattleActivateRightProgress, nil, active)
end


function WaveEndState:OnFightRecordResponse(msg)
    debug_print("WaveEndState:OnFightRecordResponse ######", self.battleResult, self.cachedData.needToShowDefeatResult, self.cachedData.needToShowVectoryResult)

    self.cachedOwner:FightResponse()

    -- 失败 跳到失败的处理状态
    if not self.battleResult then
        SendActivateBattleUIEvents(false)
        self.cachedData.needToShowDefeatResult = true
        return
    end
end

function WaveEndState:OnBattleResultResponse(msg)
    -- debug_print("WaveEndState:OnBattleResultResponse #######", self.battleResult, self.cachedData.needToShowDefeatResult, self.cachedData.needToShowVectoryResult)

    utility.ASSERT(self.noMoreWave == true, "服务器和客户端数据不同步!!!!")

    self.cachedData.needToShowDefeatResult = nil
    self.battleResult = true
    self.cachedOwner:FightResponse()

    -- 存储数据 --
    if not self:IsOffline(self.cachedOwner) then
        local name = GetBattleResultLocalDataName(self)
        local localDataMgr = utility.GetGame():GetLocalDataManager()
        localDataMgr:Drop(name)
        localDataMgr:SetMainData(name, msg)

        -- 进入显示结算 --
        self.cachedData.battleResultMsg = msg
    end

    SendActivateBattleUIEvents(false)
    
    -- 特殊处理世界BOSS的胜利与失败.
    if msg ~= nil and type(msg.lastBlow) == "boolean" then
        debug_print("World Boss Fight Only", msg.lastBlow)
        if msg.lastBlow then
            self.cachedData.needToShowVectoryResult = true
        else
            self.cachedData.needToShowDefeatResult = true
        end
        return
    end
    -- 其他情况以客户端为准.
    self.cachedData.needToShowVectoryResult = true
end



return WaveEndState
