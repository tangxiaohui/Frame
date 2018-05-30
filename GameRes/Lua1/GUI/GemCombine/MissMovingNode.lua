local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"
local TweenUtility = require "Utils.TweenUtility"

local MissMovingNodeCls = Class(BaseNodeClass)

local totalTime = 0.45

function MissMovingNodeCls:Ctor(parent)
	self.parent = parent
	self.callback = LuaDelegate.New()
end

function MissMovingNodeCls:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function MissMovingNodeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/MissMoving', function(go)
		self:BindComponent(go,false)
	end)
end

function MissMovingNodeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent,true)
	self:InitControls()
end

function MissMovingNodeCls:OnResume()
	-- 界面显示时调用
	MissMovingNodeCls.base.OnResume(self)
end

function MissMovingNodeCls:OnPause()
	-- 界面隐藏时调用
	MissMovingNodeCls.base.OnPause(self)
end

function MissMovingNodeCls:OnEnter()
	-- Node Enter时调用
	MissMovingNodeCls.base.OnEnter(self)
end

function MissMovingNodeCls:OnExit()
	-- Node Exit时调用
	MissMovingNodeCls.base.OnExit(self)
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
function MissMovingNodeCls:InitControls()
	local transform = self:GetUnityTransform()
	
	self.missTable = {}
	self.missTable[1] = transform:Find('Miss1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.missTable[2] = transform:Find('Miss2'):GetComponent(typeof(UnityEngine.UI.Image))
	self.missTable[3] = transform:Find('Miss3'):GetComponent(typeof(UnityEngine.UI.Image))
	self.missTable[4] = transform:Find('Miss4'):GetComponent(typeof(UnityEngine.UI.Image))

	self.missValue = 0
	self.ActiveItem = nil
	self:ScheduleUpdate(self.Update)
end

local function DelayShowMiss(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	self.missValue = self.missValue + 1
	if self.missValue > 4 then
		self.missValue = 1
	end
	local missnode = self.missTable[self.missValue]
	missnode.color = UnityEngine.Color(1,1,1,1)
	missnode.gameObject:SetActive(true)
	self.ActiveItem = missnode

	local beforeValue = self.missValue - 1
	if beforeValue == 0 then
		beforeValue = 4
	end
	if 1 <= beforeValue and beforeValue <= 4 then
		local beforeNode = self.missTable[beforeValue]
		beforeNode.gameObject:SetActive(false)
	end

	self.passedTime = 0
end

function MissMovingNodeCls:ShowMiss()
	-- coroutine.start(DelayShowMiss,self)
	self:StartCoroutine(DelayShowMiss)
end

function MissMovingNodeCls:HideMiss()
	-- body
end

function MissMovingNodeCls:Update()
	
	if self.ActiveItem ~= nil then
		local t = self.passedTime / totalTime

		local finished = false
    	if t >= 1 then
        	t = 1
        	finished = true
    	end

		local a = TweenUtility.Linear(1, 0 ,t)
		local color = self.ActiveItem.color
		color.a = a
		self.ActiveItem.color = color
		self.passedTime = self.passedTime + Time.unscaledDeltaTime

		if finished then
			self.ActiveItem.color = UnityEngine.Color(1,1,1,1)
			self.ActiveItem.gameObject:SetActive(false)
			self.ActiveItem = nil
		end
	end
	
end

return MissMovingNodeCls