local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"
local TweenUtility = require "Utils.TweenUtility"

local MoveLabelNodeCls = Class(BaseNodeClass)

local moveSpeed = 8
local moveTime = 1

function MoveLabelNodeCls:Ctor(parent)
	self.parent = parent
	self.callback = LuaDelegate.New()
end

function MoveLabelNodeCls:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function MoveLabelNodeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/PlusLabel', function(go)
		self:BindComponent(go,false)
	end)
end

function MoveLabelNodeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent,true)
	self:InitControls()
end

function MoveLabelNodeCls:OnResume()
	-- 界面显示时调用
	MoveLabelNodeCls.base.OnResume(self)
end

function MoveLabelNodeCls:OnPause()
	-- 界面隐藏时调用
	MoveLabelNodeCls.base.OnPause(self)
end

function MoveLabelNodeCls:OnEnter()
	-- Node Enter时调用
	MoveLabelNodeCls.base.OnEnter(self)
end

function MoveLabelNodeCls:OnExit()
	-- Node Exit时调用
	MoveLabelNodeCls.base.OnExit(self)
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
function MoveLabelNodeCls:InitControls()
	local transform = self:GetUnityTransform()
	self.transform = transform
	self.valueLabel = transform:GetComponent(typeof(UnityEngine.UI.Text))

	self.keepTime = 0
end

local function DelayResetItem(self,value,isDouble)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	self.valueLabel.text = value
	if isDouble then
		self.valueLabel.color = UnityEngine.Color(1,0.1,0.1,1)
	end
	self.passedTime = 0
	self:ScheduleUpdate(self.Update)
end

function MoveLabelNodeCls:ResetItem(value,isDouble)
	-- coroutine.start(DelayResetItem,self,value,isDouble)
	self:StartCoroutine(DelayResetItem, value,isDouble)
end

function MoveLabelNodeCls:Update()
	self.keepTime = self.keepTime + UnityEngine.Time.deltaTime
	self.transform:Translate(Vector3.up * UnityEngine.Time.deltaTime * moveSpeed)

	local t = self.passedTime / moveTime
	local a = TweenUtility.Linear(1, 0 ,t)
	local color = self.valueLabel.color
	color.a = a
	self.valueLabel.color = color
	self.passedTime = self.passedTime + Time.unscaledDeltaTime

	if self.keepTime > moveTime then
		self.callback:Invoke()
	end
end

return MoveLabelNodeCls