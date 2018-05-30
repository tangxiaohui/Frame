local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local unityUtils = require "Utils.Unity"
--local net = require "Network.Net"
local GuildChangeHeadCls = Class(BaseNodeClass)
require "Collection.OrderedDictionary"

function GuildChangeHeadCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GuildChangeHeadCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GuildChangeHead', function(go)
		self:BindComponent(go)
	end)
end

function GuildChangeHeadCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function GuildChangeHeadCls:OnResume()
	-- 界面显示时调用
	GuildChangeHeadCls.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.base

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function GuildChangeHeadCls:OnPause()
	-- 界面隐藏时调用
	GuildChangeHeadCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GuildChangeHeadCls:OnEnter()
	-- Node Enter时调用
	GuildChangeHeadCls.base.OnEnter(self)
	self:SelectHeadIcon(self.originalId)
end

function GuildChangeHeadCls:OnExit()
	-- Node Exit时调用
	GuildChangeHeadCls.base.OnExit(self)
end

function GuildChangeHeadCls:OnWillShow(iconId, ghLevel)
	self.originalId = iconId
	self.selectedId = 0
	self.ghLevel = ghLevel
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GuildChangeHeadCls:InitControls()
	local transform = self:GetUnityTransform()
	self.base = transform:Find('Base')
	self.Scroll_View = self.base:Find('Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.Viewport = self.base:Find('Scroll View/Viewport'):GetComponent(typeof(UnityEngine.UI.Mask))
	self.ChangeHeadButton = self.base:Find('ChangeHeadButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Content = self.base:Find('Scroll View/Viewport/Content')

	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self:InitItemList()
end

function GuildChangeHeadCls:InitItemList()
	self.iconDict = OrderedDictionary.New()

	local LegionIconMgr = Data.LegionIcon.Manager.Instance()
	local keys = LegionIconMgr:GetKeys()
	for key=1, keys.Length do
		if not self.iconDict:Contains(key) then
			local childNode = require "GUI.Guild.GuildChangeHeadItem".New(self.Content, key, self.ghLevel)
			childNode:SetCallback(self, self.SelectHeadIcon)
			self:AddChild(childNode)
			self.iconDict:Add(key, childNode)
		end
	end
end

function GuildChangeHeadCls:SelectHeadIcon(id)
	if id==self.selectedId then
		return
	end
	
	if self.iconDict:Contains(self.selectedId) then
		local node1 = self.iconDict:GetEntryByKey(self.selectedId)
		node1:DoUnselect()
	end
	if self.iconDict:Contains(id) then
		local node2 = self.iconDict:GetEntryByKey(id)
		node2:DoSelect()
		self.selectedId = id
	end
end

function GuildChangeHeadCls:RegisterControlEvents()
	-- 注册 Scroll_View 的事件
	self.__event_scrollrect_onScroll_ViewValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnScroll_ViewValueChanged, self)
	self.Scroll_View.onValueChanged:AddListener(self.__event_scrollrect_onScroll_ViewValueChanged__)

	-- 注册 ChangeHeadButton 的事件
	self.__event_button_onChangeHeadButtonClicked__ = UnityEngine.Events.UnityAction(self.OnChangeHeadButtonClicked, self)
	self.ChangeHeadButton.onClick:AddListener(self.__event_button_onChangeHeadButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)
end

function GuildChangeHeadCls:UnregisterControlEvents()
	-- 取消注册 Scroll_View 的事件
	if self.__event_scrollrect_onScroll_ViewValueChanged__ then
		self.Scroll_View.onValueChanged:RemoveListener(self.__event_scrollrect_onScroll_ViewValueChanged__)
		self.__event_scrollrect_onScroll_ViewValueChanged__ = nil
	end

	-- 取消注册 ChangeHeadButton 的事件
	if self.__event_button_onChangeHeadButtonClicked__ then
		self.ChangeHeadButton.onClick:RemoveListener(self.__event_button_onChangeHeadButtonClicked__)
		self.__event_button_onChangeHeadButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function GuildChangeHeadCls:RegisterNetworkEvents()
end

function GuildChangeHeadCls:UnregisterNetworkEvents()
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function GuildChangeHeadCls:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function GuildChangeHeadCls:OnExitTransitionDidStart(immediately)
    GuildChangeHeadCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.base

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function GuildChangeHeadCls:OnScroll_ViewValueChanged(posXY)
	--Scroll_View控件的点击事件处理
end

function GuildChangeHeadCls:OnScrollbar__1_ValueChanged(value)
	--Scrollbar__1_控件的点击事件处理
end

function GuildChangeHeadCls:OnChangeHeadButtonClicked()
	self:Close()
	if self.selectedId==self.originalId then
		return
	end

	local ghId = self:GetCachedData(require "Framework.UserDataType".PlayerData):GetGonghuiID()
	if ghId==0 then
		utility:GetGame():GetEventManager():PostNotification('SetGuildLogo', nil, self.selectedId)
	else
		utility:GetGame():SendNetworkMessage(require "Network/ServerService".GHSetLogoRequest(2, "", ghId, self.selectedId))
	end
end

function GuildChangeHeadCls:OnReturnButtonClicked()
	self:Close()
end

return GuildChangeHeadCls
