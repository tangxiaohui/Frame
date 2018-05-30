local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local SystemSettingsBlacklistCls = Class(BaseNodeClass)

function SystemSettingsBlacklistCls:Ctor()
	self.BlackList = {}
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function SystemSettingsBlacklistCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/SystemSettingsBlacklist', function(go)
		self:BindComponent(go)
	end)
end
function SystemSettingsBlacklistCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
function SystemSettingsBlacklistCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()											
end

function SystemSettingsBlacklistCls:OnResume()
	-- 界面显示时调用
	SystemSettingsBlacklistCls.base.OnResume(self)
	-- self:GetUnityTransform():SetAsLastSibling()

	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:RegisterEvent('RemoveList',self.RemoveList)
	self.game:SendNetworkMessage(require "Network.ServerService".TalkBlackQueryResult())
	
end

function SystemSettingsBlacklistCls:OnPause()
	-- 界面隐藏时调用
	SystemSettingsBlacklistCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnregisterEvent('RemoveList',self.RemoveList)
end

function SystemSettingsBlacklistCls:OnEnter()
	-- Node Enter时调用
	SystemSettingsBlacklistCls.base.OnEnter(self)
end

function SystemSettingsBlacklistCls:OnExit()
	-- Node Exit时调用
	SystemSettingsBlacklistCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function SystemSettingsBlacklistCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()
	--完成按钮
	self.SystemSettingsBlacklistConfirmButton = transform:Find('SystemSettingsBlacklistConfirmButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.SystemSettingsBlacklistCloseButton = transform:Find('CrossButton'):GetComponent(typeof(UnityEngine.UI.Button))
	
	self.Content = transform:Find('Scroll View/Viewport/Content')
	--背景按钮
	self.BackgroundButton = transform:Find('WhiteWindowBase/TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	
end

function SystemSettingsBlacklistCls:RemoveList(msg)
	self.Content:GetChild(msg-1).gameObject:SetActive(false)
end

function SystemSettingsBlacklistCls:RegisterControlEvents()
	-- 注册 SystemSettingsBlacklistConfirmButton 的事件
	self.__event_button_onSystemSettingsBlacklistConfirmButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSystemSettingsBlacklistConfirmButtonClicked, self)
	self.SystemSettingsBlacklistConfirmButton.onClick:AddListener(self.__event_button_onSystemSettingsBlacklistConfirmButtonClicked__)


	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSystemSettingsBlacklistConfirmButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	self.__event_button_onSystemSettingsBlacklistCloseButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSystemSettingsBlacklistConfirmButtonClicked, self)
	self.SystemSettingsBlacklistCloseButton.onClick:AddListener(self.__event_button_onSystemSettingsBlacklistCloseButtonClicked__)

end

function SystemSettingsBlacklistCls:UnregisterControlEvents()
	-- 取消注册 SystemSettingsBlacklistConfirmButton 的事件
	if self.__event_button_onSystemSettingsBlacklistConfirmButtonClicked__ then
		self.SystemSettingsBlacklistConfirmButton.onClick:RemoveListener(self.__event_button_onSystemSettingsBlacklistConfirmButtonClicked__)
		self.__event_button_onSystemSettingsBlacklistConfirmButtonClicked__ = nil
	end

	if self.__event_button_onSystemSettingsBlacklistCloseButtonClicked__ then
		self.SystemSettingsBlacklistCloseButton.onClick:RemoveListener(self.__event_button_onSystemSettingsBlacklistCloseButtonClicked__)
		self.__event_button_onSystemSettingsBlacklistCloseButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function SystemSettingsBlacklistCls:RegisterNetworkEvents()
	self.game:RegisterMsgHandler(net.S2CTalkBlackQueryResult, self, self.TalkBlackQueryResult)
end

function SystemSettingsBlacklistCls:UnregisterNetworkEvents()
	self.game:UnRegisterMsgHandler(net.S2CTalkBlackQueryResult, self, self.TalkBlackQueryResult)
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function SystemSettingsBlacklistCls:OnSystemSettingsBlacklistConfirmButtonClicked()
	--SystemSettingsBlacklistConfirmButton控件的点击事件处理
	self:Close()
end

function SystemSettingsBlacklistCls:TalkBlackQueryResult(msg)
	--print(msg.blackItem[0].playerUID)
	if #msg.blackItem ==0 then
		return 
	end
	for i=1,#msg.blackItem do 
		self.BlackList[i] = require "GUI.SystemSettingsBlacklistPlayer".New(i,self.Content,msg.blackItem[i].playerUID,msg.blackItem[i].playerName,msg.blackItem[i].playerLevel,msg.blackItem[i].headColor,msg.blackItem[i].headID) --,
		self:AddChild(self.BlackList[i])
	end
end

return SystemSettingsBlacklistCls
