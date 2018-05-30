local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local GuildMercenaryCardCls = Class(BaseNodeClass)
require "Collection.OrderedDictionary"

function GuildMercenaryCardCls:Ctor()
	self.selected = 0
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GuildMercenaryCardCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GuildMercenaryCard', function(go)
		self:BindComponent(go)
	end)
end

function GuildMercenaryCardCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function GuildMercenaryCardCls:OnResume()
	-- 界面显示时调用
	GuildMercenaryCardCls.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.base

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function GuildMercenaryCardCls:OnPause()
	-- 界面隐藏时调用
	GuildMercenaryCardCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GuildMercenaryCardCls:OnEnter()
	-- Node Enter时调用
	GuildMercenaryCardCls.base.OnEnter(self)
end

function GuildMercenaryCardCls:OnExit()
	-- Node Exit时调用
	GuildMercenaryCardCls.base.OnExit(self)
end

function GuildMercenaryCardCls:OnWillShow(usedCardUIDs)
	self.usedCardUIDs = usedCardUIDs
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GuildMercenaryCardCls:InitControls()
	local transform = self:GetUnityTransform()
	self.base = transform:Find('Base')
	self.Layout = transform:Find('Base/Scroll View/Viewport/Content')
	self.CrossButton = transform:Find('Base/CrossButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ConfirmButton = transform:Find('Base/ConfirmButton'):GetComponent(typeof(UnityEngine.UI.Button))

	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self:InitView()
end

function GuildMercenaryCardCls:InitView()
	self.cardDict = OrderedDictionary.New()

	local UserDataType = require "Framework.UserDataType"
    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
    for i=1,cardBagData:RoleCount() do
    	local cardInfo = cardBagData:GetRoleByPos(i)
		if not self:IsCardUsed(cardInfo.uid) and not self.cardDict:Contains(cardInfo.uid) then
			local childNode = require "GUI.Guild.GuildMercenaryCardItem".New(self.Layout, cardInfo)
			childNode:SetCallback(self, self.SelectCard)
			self:AddChild(childNode)
			self.cardDict:Add(cardInfo.uid, childNode)
		end
	end
end

function GuildMercenaryCardCls:IsCardUsed(cardUID)
	for i=1,#self.usedCardUIDs do
		if self.usedCardUIDs[i]==cardUID then
			return true
		end
	end
	return false
end

function GuildMercenaryCardCls:SelectCard(cardUID)
	if self.cardDict:Contains(self.selected) then
		local node1 = self.cardDict:GetEntryByKey(self.selected)
		node1:DoUnselect()
	end
	if self.cardDict:Contains(cardUID) then
		local node2 = self.cardDict:GetEntryByKey(cardUID)
		node2:DoSelect()
		self.selected = cardUID
	end
end

function GuildMercenaryCardCls:RegisterControlEvents()
	-- 注册 CrossButton 的事件
	self.__event_button_onCrossButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked, self)
	self.CrossButton.onClick:AddListener(self.__event_button_onCrossButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	-- 注册 ConfirmButton 的事件
	self.__event_button_onConfirmButtonClicked__ = UnityEngine.Events.UnityAction(self.OnConfirmButtonClicked, self)
	self.ConfirmButton.onClick:AddListener(self.__event_button_onConfirmButtonClicked__)

end

function GuildMercenaryCardCls:UnregisterControlEvents()
	-- 取消注册 CrossButton 的事件
	if self.__event_button_onCrossButtonClicked__ then
		self.CrossButton.onClick:RemoveListener(self.__event_button_onCrossButtonClicked__)
		self.__event_button_onCrossButtonClicked__ = nil
	end

	-- 取消注册 ConfirmButton 的事件
	if self.__event_button_onConfirmButtonClicked__ then
		self.ConfirmButton.onClick:RemoveListener(self.__event_button_onConfirmButtonClicked__)
		self.__event_button_onConfirmButtonClicked__ = nil
	end

	
	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end

end

function GuildMercenaryCardCls:RegisterNetworkEvents()
end

function GuildMercenaryCardCls:UnregisterNetworkEvents()
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function GuildMercenaryCardCls:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function GuildMercenaryCardCls:OnExitTransitionDidStart(immediately)
    GuildMercenaryCardCls.base.OnExitTransitionDidStart(self, immediately)

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
function GuildMercenaryCardCls:OnCrossButtonClicked()
	self:Close()
end

function GuildMercenaryCardCls:OnConfirmButtonClicked()
	self:Close()
	if self.selected~=0 then
		local ghId = self:GetCachedData(require "Framework.UserDataType".PlayerData):GetGonghuiID()
		utility:GetGame():SendNetworkMessage(require "Network/ServerService".GHAddGuyongjunRequest(ghId, self.selected))
	end
end

return GuildMercenaryCardCls
