--
-- User: fenghao
-- Date: 5/16/17
-- Time: 8:37 PM
--

-- 到 己方准备动作 的 Transition
local TransitionClass = require "Framework.FSM.Transition"

local ScenePreview2PlayerShowOffTransition = Class(TransitionClass)

function ScenePreview2PlayerShowOffTransition:Ctor()
end

function ScenePreview2PlayerShowOffTransition:IsTriggered(_, data)
    return data.isPlayerShowOff == true
end

function ScenePreview2PlayerShowOffTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.PlayerShowOffState")
end

-- 场景预览状态

local StateClass = require "Framework.FSM.State"
local utility = require "Utils.Utility"
local messageGuids = require "Framework.Business.MessageGuids"
require "Const"

local ScenePreviewState = Class(StateClass)

function ScenePreviewState:Ctor()
    self:AddTransition(ScenePreview2PlayerShowOffTransition.New())
end

local function ShowFirstFightGuide(self, owner)
	return false
	-- if owner:IsFirstFight() then
	-- 	local guideMgr = utility.GetGame():GetGuideManager()
	-- 	if not guideMgr:IsGuideEvntDone(kGuideEvnt_FightTips) then
	-- 		guideMgr:AddGuideEvnt(kGuideEvnt_FightTips)
	-- 		guideMgr:SortGuideEvnt()
	-- 		guideMgr:ShowGuidance()
	-- 		return true
	-- 	end
	-- end
	-- return false
end

local function OnGuideEventDone(self, stepId)
	if stepId > 0 then
		local newPlayerGuideStepData = require "StaticData.NewPlayerGuideStep":GetData(stepId)
		local eventId = newPlayerGuideStepData:GetGuideEvent()
		if eventId == kGuideEvnt_FightTips then
			self.cachedData.isPlayerShowOff = true
		end	
	end
end

local function OnDelayEnd(self, owner, data)

	-- @ 第一场战斗 @ --
	if owner:IsFirstFight() then
		-- @@ 显示 600 话 @@ --
		utility.GetGame():DispatchEvent(messageGuids.BattleActivateFirstStartImageInGroup2, nil)

		-- 先显示 --
		owner:ShowFirstFightStartImage(0.5)
		coroutine.wait(2.5)
		-- 后关闭 --
		owner:HideFirstFightStartImage(0.3)
	end

	coroutine.wait(0.4)

	-- 通用底图隐藏(Tween) --
	owner:HideFightBaseImage(0.1)

	coroutine.wait(0.1)

	-- Group1 显示 Group2 隐藏 --
	utility.GetGame():DispatchEvent(messageGuids.BattleActiveGroup1, nil)

	coroutine.wait(0.15)

	-- 有新手引导 ?? --
	if ShowFirstFightGuide(self, owner) then
		return
	end

	-- 没新手引导直接关闭 --
	data.isPlayerShowOff = true
end


function ScenePreviewState:Enter(owner, data)
    print("ScenePreviewState:Enter >>>>>>")
	
	self.cachedOwner = owner
	self.cachedData = data
	
	utility.GetGame():RegisterEvent(messageGuids.PlayerGuideEventDone, self, OnGuideEventDone, nil)

	coroutine.start(OnDelayEnd, self, owner, data)
end

function ScenePreviewState:Update(owner, data)
end

function ScenePreviewState:Exit(_, data)
    print("ScenePreviewState:Exit >>>>>>")
	
	self.cachedOwner = nil
	self.cachedData = nil

	utility.GetGame():UnregisterEvent(messageGuids.PlayerGuideEventDone, self, OnGuideEventDone, nil)
	
    data.isPlayerShowOff = nil
end

return ScenePreviewState