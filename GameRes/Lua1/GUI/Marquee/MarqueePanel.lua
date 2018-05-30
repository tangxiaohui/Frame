local WindowNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local messageGuids = require "Framework.Business.MessageGuids"
local TweenUtility = require "Utils.TweenUtility"

local MarqueePanel = Class(WindowNodeClass)
windowUtility.SetMutex(MarqueePanel, true)

function MarqueePanel:Ctor()
	self.items = {}

	self.currentItem = nil		-- 控件

	self.framesToSkip = 1		-- 延时

	self.passedTime = 0			-- 时间
	self.hasRepeatedTimes = 0   -- 次数
end

local function PopNextItem(self)
	if #self.items == 0 then
		return nil
	end

	if self.currentItem ~= nil then
		return nil
	end

	-- 取出最后一个 --
	local currentItem = self.items[#self.items]

	-- 重置Label --
	self.labelComponent.enabled = true
	self.labelComponent.text = currentItem:GetContent()
	self.framesToSkip = 1

	-- 重置时间和次数 --
	self.passedTime = 0
	self.hasRepeatedTimes = 0

	-- 移除最后一个
	self.items[#self.items] = nil

	return currentItem
end

local function OnUpdate(self)
	-- 判断是否有效
	if self.currentItem == nil then
		self.currentItem = PopNextItem(self)
		return 
	end

	-- 跳过帧数
	if self.framesToSkip > 1 then
		self.framesToSkip = self.framesToSkip - 1
		return
	end

	-- 判断t
	local finished
	local t = self.passedTime / self.currentItem:GetIntervalInSeconds()
	if t >= 1 then
		t = 1
		finished = true
	end

	-- 锁定大小
	local sizeDelta = self.labelTransform.sizeDelta
	sizeDelta.x = self.labelComponent.preferredWidth
	self.labelTransform.sizeDelta = sizeDelta

	-- 插值
	local x = TweenUtility.Linear(0, -(self.labelComponent.preferredWidth + self.viewPortWidth), t)
	-- debug_print("end = ", -(self.labelComponent.preferredWidth + self.viewPortWidth))
	local pos = self.labelTransform.anchoredPosition
	pos.x = x
	self.labelTransform.anchoredPosition = pos
	self.passedTime = self.passedTime + UnityEngine.Time.unscaledDeltaTime

	-- 完成时的操作
	if finished then
		self.passedTime = 0
		self.hasRepeatedTimes = self.hasRepeatedTimes + 1
		if self.hasRepeatedTimes >= self.currentItem:GetRepeatTimes() then
			self.currentItem = nil
			self.labelComponent.enabled = false
		end
	end
end



local function OnEnterLobby(self)
	self:ActiveComponent()
	self:ScheduleUpdate(OnUpdate)
end

local function OnExitLobby(self)
	self:UnscheduleUpdate()
	self.passedTime = 0
	self:InactiveComponent()
end

local function OnCompareByPriority(item1, item2)
	return item1:GetPriority() < item2:GetPriority()
end

local function OnSendMarquee(self, msg)
	-- 插入到头部 --
	self.items[#self.items + 1] = require "GUI.Marquee.MarqueeItem".New(msg)
	-- 简单排序(先实现) 由低到高
	table.sort(self.items, OnCompareByPriority)
end

local function OnOldNoticeRoll(self, msg)
	-- local newMsg = {}
	-- newMsg.repeatTimes = msg.repeatedNum
	-- newMsg.intervalInSeconds = 5
	-- newMsg.priority = 100
	-- newMsg.content = msg.msg

	-- if msg.isInsertBefore then
	-- 	newMsg.priority = 100
	-- else
	-- 	newMsg.priority = 0
	-- end

	-- OnSendMarquee(self, msg)
end

local function InitControls(self)
	local transform = self:GetUnityTransform()
	self.viewPortBaseTransform = transform:Find("Base")
	self.viewPortWidth = self.viewPortBaseTransform.sizeDelta.x
	self.labelTransform = transform:Find("Base/Label")
	self.labelComponent = self.labelTransform:GetComponent(typeof(UnityEngine.UI.Text))
	self.labelComponent.enabled = false

	debug_print("the width of the view port is", self.viewPortWidth)
	OnEnterLobby(self)
end

local function RegisterEvents(self)
	self:RegisterEvent(messageGuids.EnterLobbyScene, OnEnterLobby)
    self:RegisterEvent(messageGuids.ExitLobbyScene, OnExitLobby)
    self:RegisterEvent(messageGuids.SendMarquee, OnSendMarquee)
    --self:RegisterEvent("PlayNoticeRoll", OnOldNoticeRoll)
end

local function UnregisterEvents(self)
	self:UnregisterEvent(messageGuids.EnterLobbyScene, OnEnterLobby)
	self:UnregisterEvent(messageGuids.ExitLobbyScene, OnExitLobby)
	self:UnregisterEvent(messageGuids.SendMarquee, OnSendMarquee)
	--self:UnregisterEvent("PlayNoticeRoll", OnOldNoticeRoll)
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function MarqueePanel:OnInit()
	utility.LoadNewGameObjectAsync('UI/Prefabs/MarqueePanel', function(go)
		self:BindComponent(go)
	end)
end

function MarqueePanel:OnComponentReady()
	InitControls(self)
end

function MarqueePanel:OnResume()
	MarqueePanel.base.OnResume(self)
	RegisterEvents(self)
end

function MarqueePanel:OnPause()
	MarqueePanel.base.OnPause(self)
	UnregisterEvents(self)
end

function MarqueePanel:GetRootHangingPoint()
	return self:GetUIManager():GetForegroundLayer()	
end

return MarqueePanel
