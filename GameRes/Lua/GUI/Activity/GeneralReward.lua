local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local GeneralRewardCls = Class(BaseNodeClass)

function GeneralRewardCls:Ctor()

end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GeneralRewardCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GeneralReward', function(go)
		self:BindComponent(go)
	end)
end

function GeneralRewardCls:OnWillShow(items)
--	print("/////////////")
	self.items=items
	for i=1,#self.items do
		print(self.items[i].itemID)
	end
end

function GeneralRewardCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function GeneralRewardCls:OnResume()
	-- 界面显示时调用
	GeneralRewardCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function GeneralRewardCls:OnPause()
	-- 界面隐藏时调用
	GeneralRewardCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GeneralRewardCls:OnEnter()
	-- Node Enter时调用
	GeneralRewardCls.base.OnEnter(self)
end

function GeneralRewardCls:OnExit()
	-- Node Exit时调用
	GeneralRewardCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GeneralRewardCls:InitControls()
	local transform = self:GetUnityTransform()
	self.TranslucentLayer = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.TitleText = transform:Find('TitleText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Scroll_View = transform:Find('Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.Content = transform:Find('Scroll View/Viewport/Content')
	self:InitViews()
end


function GeneralRewardCls:InitViews()
	for i=1,#self.items do
		local item=require"GUI.Activity.GeneralRewardItem".New(self.Content,msg.items[i].itemID,msg.items[i].itemNum,msg.items[i].itemColor)	
		self:AddChild(item)
		print(self.items[i].itemID)
	end
end


function GeneralRewardCls:RegisterControlEvents()
	-- 注册 Scroll_View 的事件
	self.__event_scrollrect_onScroll_ViewValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnScroll_ViewValueChanged, self)
	self.Scroll_View.onValueChanged:AddListener(self.__event_scrollrect_onScroll_ViewValueChanged__)

end

function GeneralRewardCls:UnregisterControlEvents()
	-- 取消注册 Scroll_View 的事件
	if self.__event_scrollrect_onScroll_ViewValueChanged__ then
		self.Scroll_View.onValueChanged:RemoveListener(self.__event_scrollrect_onScroll_ViewValueChanged__)
		self.__event_scrollrect_onScroll_ViewValueChanged__ = nil
	end

end

function GeneralRewardCls:RegisterNetworkEvents()
	
end

function GeneralRewardCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function GeneralRewardCls:OnScroll_ViewValueChanged(posXY)
	--Scroll_View控件的点击事件处理
end

return GeneralRewardCls
