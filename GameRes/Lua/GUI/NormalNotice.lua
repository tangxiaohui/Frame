local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
local NormalNoticeCls = Class(BaseNodeClass)

function NormalNoticeCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function NormalNoticeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/NormalNotice', function(go)
		self:BindComponent(go)
	end)
end

function NormalNoticeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function NormalNoticeCls:OnResume()
	-- 界面显示时调用
	NormalNoticeCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function NormalNoticeCls:OnPause()
	-- 界面隐藏时调用
	NormalNoticeCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function NormalNoticeCls:OnEnter()
	-- Node Enter时调用
	NormalNoticeCls.base.OnEnter(self)
end

function NormalNoticeCls:OnExit()
	-- Node Exit时调用
	NormalNoticeCls.base.OnExit(self)
end

function NormalNoticeCls:OnWillShow(TYPE, noticeString)
	self.TYPE = TYPE
	self.noticeString = noticeString
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function NormalNoticeCls:InitControls()
	local transform = self:GetUnityTransform()
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.DownerDecoration = transform:Find('DownerDecoration'):GetComponent(typeof(UnityEngine.UI.Image))
	self.UpperDecoration = transform:Find('UpperDecoration'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Box = transform:Find('Box'):GetComponent(typeof(UnityEngine.UI.Image))
	self.InfoLabel = transform:Find('InfoLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CrossButton = transform:Find('CrossButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.CancelButton = transform:Find('CancelButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ConferButton = transform:Find('ConferButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self.InfoLabel.text = string.gsub(self.noticeString,"\\n","\n")
end


function NormalNoticeCls:RegisterControlEvents()
	-- 注册 CrossButton 的事件
	self.__event_button_onCrossButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked, self)
	self.CrossButton.onClick:AddListener(self.__event_button_onCrossButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)


	-- 注册 CancelButton 的事件
	self.__event_button_onCancelButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCancelButtonClicked, self)
	self.CancelButton.onClick:AddListener(self.__event_button_onCancelButtonClicked__)

	-- 注册 ConferButton 的事件
	self.__event_button_onConferButtonClicked__ = UnityEngine.Events.UnityAction(self.OnConferButtonClicked, self)
	self.ConferButton.onClick:AddListener(self.__event_button_onConferButtonClicked__)
end

function NormalNoticeCls:UnregisterControlEvents()
	-- 取消注册 CrossButton 的事件
	if self.__event_button_onCrossButtonClicked__ then
		self.CrossButton.onClick:RemoveListener(self.__event_button_onCrossButtonClicked__)
		self.__event_button_onCrossButtonClicked__ = nil
	end

	-- 取消注册 CancelButton 的事件
	if self.__event_button_onCancelButtonClicked__ then
		self.CancelButton.onClick:RemoveListener(self.__event_button_onCancelButtonClicked__)
		self.__event_button_onCancelButtonClicked__ = nil
	end

	-- 取消注册 ConferButton 的事件
	if self.__event_button_onConferButtonClicked__ then
		self.ConferButton.onClick:RemoveListener(self.__event_button_onConferButtonClicked__)
		self.__event_button_onConferButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function NormalNoticeCls:RegisterNetworkEvents()
end

function NormalNoticeCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function NormalNoticeCls:OnCrossButtonClicked()
	self:Close()
end

function NormalNoticeCls:OnCancelButtonClicked()
	self:Close()
end

function NormalNoticeCls:OnConferButtonClicked()
	utility:GetGame():GetEventManager():PostNotification('NormalNoticeConfirm', nil, self.TYPE)
	self:Close()
end

return NormalNoticeCls
