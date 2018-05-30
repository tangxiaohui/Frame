local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local GrowUpCls = Class(BaseNodeClass)

function GrowUpCls:Ctor()
	
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GrowUpCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GrowUp', function(go)
		self:BindComponent(go)
	end)
end

function GrowUpCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function GrowUpCls:OnResume()
	-- 界面显示时调用
	GrowUpCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function GrowUpCls:OnPause()
	-- 界面隐藏时调用
	GrowUpCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GrowUpCls:OnEnter()
	-- Node Enter时调用
	GrowUpCls.base.OnEnter(self)
end

function GrowUpCls:OnExit()
	-- Node Exit时调用
	GrowUpCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GrowUpCls:InitControls()
	local transform = self:GetUnityTransform()
	self.RedBase = transform:Find('RedBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.GrayBase = transform:Find('GrayBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.TopBase = transform:Find('Top/TopBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.PersonImage = transform:Find('Top/PersonImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.RedImage = transform:Find('Top/RedImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.RedImage2 = transform:Find('Top/RedImage2'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BeishuText = transform:Find('Top/BeishuText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Label1 = transform:Find('Top/Label1'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Label2 = transform:Find('Top/Label2'):GetComponent(typeof(UnityEngine.UI.Text))
	self.DiamondCostText = transform:Find('Top/DiamondCostText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.DiamondAcquiredText = transform:Find('Top/DiamondAcquiredText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BuyButton = transform:Find('Top/BuyButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BackImage = transform:Find('Down/BackImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Scroll_View = transform:Find('Down/Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.Viewport = transform:Find('Down/Scroll View/Viewport'):GetComponent(typeof(UnityEngine.UI.Mask))
end


function GrowUpCls:RegisterControlEvents()
	-- 注册 BuyButton 的事件
	self.__event_button_onBuyButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBuyButtonClicked, self)
	self.BuyButton.onClick:AddListener(self.__event_button_onBuyButtonClicked__)

	-- 注册 Scroll_View 的事件
	self.__event_scrollrect_onScroll_ViewValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnScroll_ViewValueChanged, self)
	self.Scroll_View.onValueChanged:AddListener(self.__event_scrollrect_onScroll_ViewValueChanged__)

end

function GrowUpCls:UnregisterControlEvents()
	-- 取消注册 BuyButton 的事件
	if self.__event_button_onBuyButtonClicked__ then
		self.BuyButton.onClick:RemoveListener(self.__event_button_onBuyButtonClicked__)
		self.__event_button_onBuyButtonClicked__ = nil
	end

	-- 取消注册 Scroll_View 的事件
	if self.__event_scrollrect_onScroll_ViewValueChanged__ then
		self.Scroll_View.onValueChanged:RemoveListener(self.__event_scrollrect_onScroll_ViewValueChanged__)
		self.__event_scrollrect_onScroll_ViewValueChanged__ = nil
	end

end

function GrowUpCls:RegisterNetworkEvents()
end

function GrowUpCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function GrowUpCls:OnBuyButtonClicked()
	--BuyButton控件的点击事件处理
end

function GrowUpCls:OnScroll_ViewValueChanged(posXY)
	--Scroll_View控件的点击事件处理
end

return GrowUpCls
