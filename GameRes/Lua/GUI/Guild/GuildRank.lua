local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local GuildRankCls = Class(BaseNodeClass)
require "Collection.OrderedDictionary"

function GuildRankCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GuildRankCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GuildRank', function(go)
		self:BindComponent(go)
	end)
end

function GuildRankCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function GuildRankCls:OnResume()
	-- 界面显示时调用
	GuildRankCls.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.base

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function GuildRankCls:OnPause()
	-- 界面隐藏时调用
	GuildRankCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GuildRankCls:OnEnter()
	-- Node Enter时调用
	GuildRankCls.base.OnEnter(self)
end

function GuildRankCls:OnExit()
	-- Node Exit时调用
	GuildRankCls.base.OnExit(self)
end

function GuildRankCls:OnWillShow(rankArray,isInGuild)
	self.isInGuild = isInGuild
	self.rankArray = rankArray
	print("rank "..#rankArray.." items")
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GuildRankCls:InitControls()
	local transform = self:GetUnityTransform()
	self.base = transform:Find('Base')
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Base__1_ = transform:Find('Base/Base (1)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.DownerDecoration = self.base:Find('DownerDecoration'):GetComponent(typeof(UnityEngine.UI.Image))
	self.UpperDecoration = self.base:Find('UpperDecoration'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CrossButton = self.base:Find('CrossButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Scroll_View = self.base:Find('Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.Viewport = self.base:Find('Scroll View/Viewport'):GetComponent(typeof(UnityEngine.UI.Mask))
	self.Title = self.base:Find('Title'):GetComponent(typeof(UnityEngine.UI.Image))

	self.Content = self.base:Find('Scroll View/Viewport/Content')
	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self:InitItemList()
end

function GuildRankCls:InitItemList()
	self.rankDict = OrderedDictionary.New()
	for i=1,#self.rankArray do
		print("i="..i)
		local rankInfo = self.rankArray[i]
		local ghID = rankInfo.ghID
		if not self.rankDict:Contains(ghID) then
			local childNode = require "GUI.Guild.GuildRankItem".New(self.Content, rankInfo,self.isInGuild)
			self:AddChild(childNode)
			self.rankDict:Add(ghID, childNode)
		end
	end
end

function GuildRankCls:RegisterControlEvents()
	-- 注册 CrossButton 的事件
	self.__event_button_onCrossButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked, self)
	self.CrossButton.onClick:AddListener(self.__event_button_onCrossButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	-- 注册 Scroll_View 的事件
	self.__event_scrollrect_onScroll_ViewValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnScroll_ViewValueChanged, self)
	self.Scroll_View.onValueChanged:AddListener(self.__event_scrollrect_onScroll_ViewValueChanged__)

end

function GuildRankCls:UnregisterControlEvents()
	-- 取消注册 CrossButton 的事件
	if self.__event_button_onCrossButtonClicked__ then
		self.CrossButton.onClick:RemoveListener(self.__event_button_onCrossButtonClicked__)
		self.__event_button_onCrossButtonClicked__ = nil
	end

	-- 取消注册 Scroll_View 的事件
	if self.__event_scrollrect_onScroll_ViewValueChanged__ then
		self.Scroll_View.onValueChanged:RemoveListener(self.__event_scrollrect_onScroll_ViewValueChanged__)
		self.__event_scrollrect_onScroll_ViewValueChanged__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function GuildRankCls:RegisterNetworkEvents()
	utility:GetGame():RegisterMsgHandler(net.S2CGHJoinResult, self, self.GHJoinResult)
end

function GuildRankCls:UnregisterNetworkEvents()
	utility:GetGame():UnRegisterMsgHandler(net.S2CGHJoinResult, self, self.GHJoinResult)
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function GuildRankCls:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function GuildRankCls:OnExitTransitionDidStart(immediately)
    GuildRankCls.base.OnExitTransitionDidStart(self, immediately)

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
function GuildRankCls:OnCrossButtonClicked()
	self:Close()
end

function GuildRankCls:OnScroll_ViewValueChanged(posXY)
	--Scroll_View控件的点击事件处理
end

function GuildRankCls:GHJoinResult(msg)
	self:Close()
end

return GuildRankCls
