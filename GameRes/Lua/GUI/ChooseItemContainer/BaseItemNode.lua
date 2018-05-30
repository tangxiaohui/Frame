require "Const"
local UnityEngine_Color = UnityEngine.Color
SelectedColor = UnityEngine_Color(0.48235,0.48235,0.48235,1)
NoSelectedColor = UnityEngine_Color(1,1,1,1)

local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"

local BaseItemNodeCls = Class(BaseNodeClass)

function BaseItemNodeCls:Ctor(parent,itemWidth,itemHigh)
	self.parent = parent
	self.itemWidth = itemWidth
	self.itemHigh = itemHigh

	self.callback = LuaDelegate.New()
end

function BaseItemNodeCls:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function BaseItemNodeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/MyGeneralItem', function(go)
		self:BindComponent(go,false)
	end)
end

function BaseItemNodeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function BaseItemNodeCls:OnResume()
	-- 界面显示时调用
	BaseItemNodeCls.base.OnResume(self)
end

function BaseItemNodeCls:OnPause()
	-- 界面隐藏时调用
	BaseItemNodeCls.base.OnPause(self)
end

function BaseItemNodeCls:OnEnter()
	-- Node Enter时调用
	BaseItemNodeCls.base.OnEnter(self)
end

function BaseItemNodeCls:OnExit()
	-- Node Exit时调用
	BaseItemNodeCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function BaseItemNodeCls:InitControls()
	local transform = self:GetUnityTransform()

	self.transform = transform
	self.rectTransform = transform:GetComponent(typeof(UnityEngine.RectTransform))
	
	-- -- 选中状态
	-- self.OnSelectState = transform:Find('OnSelectState').gameObject
	-- -- 数量
	-- self.countLabel = transform:Find('GeneralItemNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- -- 名称
	-- self.nameLabel = transform:Find('ItemNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.nameLabel.gameObject:SetActive(true)

	-- -- 设置名字样式
	-- local rectTransform = self.nameLabel.rectTransform
	-- rectTransform.anchorMax = Vector2(1,1)
	-- rectTransform.anchorMin = Vector2(0.5,0.5)
	-- rectTransform.offsetMin = Vector2(-66.64,0)
	-- rectTransform.offsetMax = Vector2(0,100)

	-- self.nameLabel.fontSize = 22
	-- self.nameLabel.color = UnityEngine.Color(1,1,1,1)
	-- local outline = self.nameLabel:GetComponent(typeof(UnityEngine.UI.Outline))
	-- outline.effectColor =  UnityEngine.Color(0,0,0,1)   --UnityEngine.Color(0,0,0,1)
	-- outline.effectDistance = Vector2(1.5,-1.5)  --Vector2(2,-2)

	-- -- 图标
	-- self.ItemIcon = transform:Find('ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- -- 颜色
	-- self.colorFrame = transform:Find('Frame')
	-- -- 碎片图片
	-- self.DebrisIcon = transform:Find('DebrisIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	
	

	-- -- 套装属性
	-- self.flag = transform:Find('Flag').gameObject
	-- -- 等级label
	-- self.LevelLabel = transform:Find('ItemLevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	self.active = false
end


function BaseItemNodeCls:RegisterControlEvents()
	
end

function BaseItemNodeCls:UnregisterControlEvents()
	
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
local function DelayOnBind(self,data)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	self.rectTransform.sizeDelta = Vector2(self.itemWidth,self.itemHigh)

	self:ResetItem(data)
end

function BaseItemNodeCls:OnBind(data,index)
	self.index = index
	self.data = data
	-- coroutine.start(DelayOnBind,self,data)
	self:StartCoroutine(DelayOnBind, data)
end

function BaseItemNodeCls:OnUnbind()
	
end
--------------------------------------------------------------------------
local function DelayResetPosition(self,position)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	
	self.rectTransform.anchoredPosition = position
end

function BaseItemNodeCls:ResetPosition(position)
	-- coroutine.start(DelayResetPosition,self,position)
	self:StartCoroutine(DelayResetPosition, position)
end

function BaseItemNodeCls:ResetItem(data)
	-- 重置数据
end

function BaseItemNodeCls:OnInfoButtonClicked(...)
	self.callback:Invoke(self.index,self.active,...)
end

function BaseItemNodeCls:SetNodeActive(active)
	self.active = active
end

function BaseItemNodeCls:GetNodeActive()
	if self.active == nil then
		self.active = false
	end
	return self.active
end

function BaseItemNodeCls:SetSelectedState(active)
	self.active = active
end

return BaseItemNodeCls