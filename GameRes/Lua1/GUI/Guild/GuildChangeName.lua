local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local GuildChangeNameCls = Class(BaseNodeClass)

function GuildChangeNameCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GuildChangeNameCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GuildChangeName', function(go)
		self:BindComponent(go)
	end)
end

function GuildChangeNameCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function GuildChangeNameCls:OnResume()
	-- 界面显示时调用
	GuildChangeNameCls.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.base

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function GuildChangeNameCls:OnPause()
	-- 界面隐藏时调用
	GuildChangeNameCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GuildChangeNameCls:OnEnter()
	-- Node Enter时调用
	GuildChangeNameCls.base.OnEnter(self)
end

function GuildChangeNameCls:OnExit()
	-- Node Exit时调用
	GuildChangeNameCls.base.OnExit(self)
end

function GuildChangeNameCls:OnWillShow(originalName)
	self.originalName = originalName
end

function GuildChangeNameCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GuildChangeNameCls:InitControls()
	local transform = self:GetUnityTransform()
	self.base = transform:Find('Base')
	self.CancelButton = self.base:Find('CancelButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ConfirmButton = self.base:Find('ConfirmButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.CrossButton = self.base:Find('CrossButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Text = self.base:Find('NameInputFiled/Text'):GetComponent(typeof(UnityEngine.UI.InputField))
	self.Price = self.base:Find('NeedDiaLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self.Price.text = require "StaticData.SystemConfig.SystemConfig":GetData(3):GetParameNum()[0]
end


function GuildChangeNameCls:RegisterControlEvents()
	-- 注册 CancelButton 的事件
	self.__event_button_onCancelButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCancelButtonClicked, self)
	self.CancelButton.onClick:AddListener(self.__event_button_onCancelButtonClicked__)

	-- 注册 ConfirmButton 的事件
	self.__event_button_onConfirmButtonClicked__ = UnityEngine.Events.UnityAction(self.OnConfirmButtonClicked, self)
	self.ConfirmButton.onClick:AddListener(self.__event_button_onConfirmButtonClicked__)

	-- 注册 CrossButton 的事件
	self.__event_button_onCrossButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked, self)
	self.CrossButton.onClick:AddListener(self.__event_button_onCrossButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)
end

function GuildChangeNameCls:UnregisterControlEvents()
	-- 取消注册 CancelButton 的事件
	if self.__event_button_onCancelButtonClicked__ then
		self.CancelButton.onClick:RemoveListener(self.__event_button_onCancelButtonClicked__)
		self.__event_button_onCancelButtonClicked__ = nil
	end

	-- 取消注册 ConfirmButton 的事件
	if self.__event_button_onConfirmButtonClicked__ then
		self.ConfirmButton.onClick:RemoveListener(self.__event_button_onConfirmButtonClicked__)
		self.__event_button_onConfirmButtonClicked__ = nil
	end

	-- 取消注册 CrossButton 的事件
	if self.__event_button_onCrossButtonClicked__ then
		self.CrossButton.onClick:RemoveListener(self.__event_button_onCrossButtonClicked__)
		self.__event_button_onCrossButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end

end

function GuildChangeNameCls:RegisterNetworkEvents()
end

function GuildChangeNameCls:UnregisterNetworkEvents()
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function GuildChangeNameCls:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function GuildChangeNameCls:OnExitTransitionDidStart(immediately)
    GuildChangeNameCls.base.OnExitTransitionDidStart(self, immediately)

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
function GuildChangeNameCls:OnCancelButtonClicked()
	self:Close()
end

function GuildChangeNameCls:OnConfirmButtonClicked()
	local name = string.gsub(self.Text.text, "^%s*(.-)%s*$", "%1")
	local ghId = self:GetCachedData(require "Framework.UserDataType".PlayerData):GetGonghuiID()
	utility:GetGame():GetEventManager():PostNotification('SetGuildName', nil, name)
	utility:GetGame():SendNetworkMessage(require "Network/ServerService".GHSetLogoRequest(1, name, ghId, 0))
	self:Close()
	-- if name==self.originalName then
	-- 	local windowManager = utility:GetGame():GetWindowManager()
 --        windowManager:Show(require "GUI.Dialogs.ErrorDialog","改名需要与原来的名字有所区别！")
	-- 	-- require "GUI/Guild/GuilcCommonFunc".ShowErrorTip("改名需要与原来的名字有所区别！")
	-- else
	-- 	local ghId = self:GetCachedData(require "Framework.UserDataType".PlayerData):GetGonghuiID()
	-- 	utility:GetGame():GetEventManager():PostNotification('SetGuildName', nil, name)
	-- 	utility:GetGame():SendNetworkMessage(require "Network/ServerService".GHSetLogoRequest(1, name, ghId, 0))
	-- 	self:Close()
	-- end
end

function GuildChangeNameCls:OnCrossButtonClicked()
	self:Close()
end

return GuildChangeNameCls
