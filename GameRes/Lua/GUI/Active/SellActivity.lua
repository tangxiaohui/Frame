local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local SellActivityCls = Class(BaseNodeClass)

function SellActivityCls:Ctor(parent,operationActicityData)
	self.parent = parent 
	self.operationActicityData = operationActicityData
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function SellActivityCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/SellActivity', function(go)
		self:BindComponent(go)
	end)
end

function SellActivityCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function SellActivityCls:OnResume()
	-- 界面显示时调用
	SellActivityCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	
end

function SellActivityCls:OnPause()
	-- 界面隐藏时调用
	SellActivityCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function SellActivityCls:OnEnter()
	-- Node Enter时调用
	SellActivityCls.base.OnEnter(self)
end

function SellActivityCls:OnExit()
	-- Node Exit时调用
	SellActivityCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function SellActivityCls:InitControls()
	local transform = self:GetUnityTransform()
	self.DescriptionBase = transform:Find('DescriptionBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.TitleBase = transform:Find('DescriptionBase/TitleBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.TitleLabel = transform:Find('DescriptionBase/TitleBase/TitleLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.DescriptionLabel = transform:Find('DescriptionBase/DescriptionLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.NoticeLabel = transform:Find('DescriptionBase/NoticeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Icon = transform:Find('DescriptionBase/Icon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Base = transform:Find('ExchangeBox/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Deco1 = transform:Find('ExchangeBox/Deco1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Deco2 = transform:Find('ExchangeBox/Deco2'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Scroll_View = transform:Find('ExchangeBox/Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.Viewport = transform:Find('ExchangeBox/Scroll View/Viewport'):GetComponent(typeof(UnityEngine.UI.Mask))
	self.ExchangeIllustBase = transform:Find('ExchangeIllustBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LasttimeLabel = transform:Find('ExchangeIllustBase/LasttimeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ActiveTitle_ = transform:Find('ExchangeIllustBase/ActiveTitle '):GetComponent(typeof(UnityEngine.UI.Text))
	self.layout=transform:Find('ExchangeBox/Scroll View/Viewport/Content')
	self:InitViews()
end

function SellActivityCls:InitViews()
	self.TitleLabel.text=self.operationActicityData.baseInfo.title
	self.DescriptionLabel.text=self.operationActicityData.baseInfo.description
	self.ActiveTitle_.text=self.operationActicityData.baseInfo.introduction
	--hzj_print(self.operationActicityData.endTime,self:GetTimeManager():GetServerTimestamp(),self.operationActicityData.startTime)
	local timeStr = utility.GetLocalTimeFromTimeStamp("剩余时间：%d天%H时%M分",self.operationActicityData.baseInfo.endTime-self:GetTimeManager():GetServerTimestamp())
	self.LasttimeLabel.text=timeStr

	--hzj_print("operationActicityData",#self.operationActicityData.items)
	self.items = {}
	for i=1,#self.operationActicityData.itemGroups do
		self.items[#self.items+1] = require "GUI.Active.LimitDiscountItem".New(self.operationActicityData.itemGroups[i],self.operationActicityData.data,self.layout,i,self.operationActicityData.type,self.operationActicityData.id)
		self:AddChild(self.items[#self.items])
	end

end
function SellActivityCls:GetActivityID()
	return self.operationActicityData.id
end

function SellActivityCls:RegisterControlEvents()
	-- 注册 Scroll_View 的事件
	self.__event_scrollrect_onScroll_ViewValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnScroll_ViewValueChanged, self)
	self.Scroll_View.onValueChanged:AddListener(self.__event_scrollrect_onScroll_ViewValueChanged__)

end

function SellActivityCls:UnregisterControlEvents()
	-- 取消注册 Scroll_View 的事件
	if self.__event_scrollrect_onScroll_ViewValueChanged__ then
		self.Scroll_View.onValueChanged:RemoveListener(self.__event_scrollrect_onScroll_ViewValueChanged__)
		self.__event_scrollrect_onScroll_ViewValueChanged__ = nil
	end

end

function SellActivityCls:RegisterNetworkEvents()
end

function SellActivityCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function SellActivityCls:OnScroll_ViewValueChanged(posXY)
	--Scroll_View控件的点击事件处理
end

return SellActivityCls
