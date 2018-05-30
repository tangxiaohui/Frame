local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ZodiacDrawResultCls = Class(BaseNodeClass)

function ZodiacDrawResultCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ZodiacDrawResultCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ZodiacDrawResult', function(go)
		self:BindComponent(go)
	end)
end

function ZodiacDrawResultCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

local function ShowItem(self, id, count, color)
	local node = require "GUI.Task.AwardItem".New(self.ItemPoint, id, count, color)
	self:AddChild(node)
end

local function ShowItems(self)
	if self.items == nil then
		return
	end
	
	for i = 1, #self.items do
		local id = self.items[i].itemID
		local count = self.items[i].itemNum
		local color = self.items[i].itemColor
		ShowItem(self, id, count, color)
	end
end

function ZodiacDrawResultCls:OnResume()
	-- 界面显示时调用
	ZodiacDrawResultCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	ShowItems(self)
end

function ZodiacDrawResultCls:OnPause()
	-- 界面隐藏时调用
	ZodiacDrawResultCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function ZodiacDrawResultCls:OnEnter()
	-- Node Enter时调用
	ZodiacDrawResultCls.base.OnEnter(self)
end

function ZodiacDrawResultCls:OnExit()
	-- Node Exit时调用
	ZodiacDrawResultCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ZodiacDrawResultCls:InitControls()
	local transform = self:GetUnityTransform()
	self.ZodiacDrawResultBase = transform:Find('Point/ZodiacDrawResultBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Line = transform:Find('Point/Frame/Line'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Line1 = transform:Find('Point/Frame/Line'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Title = transform:Find('Point/Title/Title'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Scroll_View = transform:Find('Point/Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.Viewport = transform:Find('Point/Scroll View/Viewport'):GetComponent(typeof(UnityEngine.UI.Mask))
	self.CardDrawResultBackButton = transform:Find('Point/CardDrawResultBackButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ItemPoint = transform:Find('Point/Scroll View/Viewport/Content') 

	--背景按钮
	self.BackgroundButton = transform:Find('Point/ZodiacDrawResultBase'):GetComponent(typeof(UnityEngine.UI.Button))
end


function ZodiacDrawResultCls:RegisterControlEvents()
	-- 注册 Scroll_View 的事件
	self.__event_scrollrect_onScroll_ViewValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnScroll_ViewValueChanged, self)
	self.Scroll_View.onValueChanged:AddListener(self.__event_scrollrect_onScroll_ViewValueChanged__)

	-- 注册 CardDrawResultBackButton 的事件
	self.__event_button_onCardDrawResultBackButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCardDrawResultBackButtonClicked, self)
	self.CardDrawResultBackButton.onClick:AddListener(self.__event_button_onCardDrawResultBackButtonClicked__)

		-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCardDrawResultBackButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)
end

function ZodiacDrawResultCls:UnregisterControlEvents()
	-- 取消注册 Scroll_View 的事件
	if self.__event_scrollrect_onScroll_ViewValueChanged__ then
		self.Scroll_View.onValueChanged:RemoveListener(self.__event_scrollrect_onScroll_ViewValueChanged__)
		self.__event_scrollrect_onScroll_ViewValueChanged__ = nil
	end

	-- 取消注册 CardDrawResultBackButton 的事件
	if self.__event_button_onCardDrawResultBackButtonClicked__ then
		self.CardDrawResultBackButton.onClick:RemoveListener(self.__event_button_onCardDrawResultBackButtonClicked__)
		self.__event_button_onCardDrawResultBackButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function ZodiacDrawResultCls:RegisterNetworkEvents()
end

function ZodiacDrawResultCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ZodiacDrawResultCls:OnScroll_ViewValueChanged(posXY)
	--Scroll_View控件的点击事件处理
end

function ZodiacDrawResultCls:OnCardDrawResultBackButtonClicked()
	--CardDrawResultBackButton控件的点击事件处理
	self:Close()
end

function ZodiacDrawResultCls:OnWillShow(items)
	self.items = items
end

return ZodiacDrawResultCls
