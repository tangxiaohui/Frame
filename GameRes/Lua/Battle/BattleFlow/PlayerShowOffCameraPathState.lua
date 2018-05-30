--
-- User: fenghao
-- Date: 5/16/17
-- Time: 8:46 PM
--

-- 到 波次开始 状态
local TransitionClass = require "Framework.FSM.Transition"

local PlayerShowOffCameraPath2WaveStartTransition = Class(TransitionClass)

function PlayerShowOffCameraPath2WaveStartTransition:Ctor()
end

function PlayerShowOffCameraPath2WaveStartTransition:IsTriggered(_, data)
    return data.needToWaveStart == true
end

function PlayerShowOffCameraPath2WaveStartTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.WaveStartState")
end

-- 到 结束战斗状态 Transition
local PlayerShowOffCameraPath2BattleEndTransition = Class(TransitionClass)

function PlayerShowOffCameraPath2BattleEndTransition:Ctor()
end

function PlayerShowOffCameraPath2BattleEndTransition:IsTriggered(_, data)
    return data.needToEndBattle == true
end

function PlayerShowOffCameraPath2BattleEndTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.BattleEndState")
end

-- 镜头转向 状态
-- 播放呼吸后时的摄像机路径
-- 播放完人物的showoff 需要让摄像机镜头转到 正确的位置.

local StateClass = require "Framework.FSM.State"
local camPathEvnt = require "Event.CameraPathEventHandler"

local PlayerShowOffCameraPathState = Class(StateClass)

function PlayerShowOffCameraPathState:Ctor()
    self:AddTransition(PlayerShowOffCameraPath2WaveStartTransition.New())
    self:AddTransition(PlayerShowOffCameraPath2BattleEndTransition.New())
end

function PlayerShowOffCameraPathState:OnCameraPathFinished(_)
    self.cachedData.needToWaveStart = true
end

function PlayerShowOffCameraPathState:Enter(owner, data)
    print("PlayShowOffCameraPathState:Enter >>>")
    self.cachedData = data
    camPathEvnt:RegisterEventHandler(self)
    data.cameraPaths.showOffAtBeginning:SetActive(true)
end

function PlayerShowOffCameraPathState:Update(owner, data)
end

function PlayerShowOffCameraPathState:Exit(owner, data)
    print("PlayShowOffCameraPathState:Exit >>>")
    self.cachedData = nil
    camPathEvnt:UnRegisterEventHandler(self)
    data.needToWaveStart = nil
end

return PlayerShowOffCameraPathState