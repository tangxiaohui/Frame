local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local SystemSettingsBlacklistPlayerCls = Class(BaseNodeClass)

function SystemSettingsBlacklistPlayerCls:Ctor(i,parent,PlayerUID,playerName,playerLevel,headColor,headID)
	self.Parent = parent
	self.playerName = playerName
	self.playerLevel = playerLevel
	self.headColor = headColor
	self.headID = headID
	self.PlayerUID = PlayerUID
	self.I = i
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function SystemSettingsBlacklistPlayerCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/SystemSettingsBlacklistPlayer', function(go)
		self:BindComponent(go,false)
	end)
end

function SystemSettingsBlacklistPlayerCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LinkComponent(self.Parent)
end

function SystemSettingsBlacklistPlayerCls:OnResume()
	-- 界面显示时调用
	SystemSettingsBlacklistPlayerCls.base.OnResume(self)
	self:GetUnityTransform():SetAsLastSibling()
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:InitView()
end

function SystemSettingsBlacklistPlayerCls:OnPause()
	-- 界面隐藏时调用
	SystemSettingsBlacklistPlayerCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function SystemSettingsBlacklistPlayerCls:OnEnter()
	-- Node Enter时调用
	SystemSettingsBlacklistPlayerCls.base.OnEnter(self)
end

function SystemSettingsBlacklistPlayerCls:OnExit()
	-- Node Exit时调用
	SystemSettingsBlacklistPlayerCls.base.OnExit(self)
end

function SystemSettingsBlacklistPlayerCls:InitView()
	self.SystemSettingsBlacklistPlayerNameLabel.text = self.playerName
	self.SystemSettingsBlacklistPlayerLvLabel.text = self.playerLevel
    utility.LoadRoleHeadIcon(self.headID , self.SystemSettingsBlacklistPlayerHeadIcon)
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function SystemSettingsBlacklistPlayerCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()
	--头像
	self.SystemSettingsBlacklistPlayerHeadIcon = transform:Find('Head/Base/PersonalInformationHeadIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	--删除
	self.SystemSettingsBlacklistPlayerDeleteButton = transform:Find('SystemSettingsBlacklistPlayerDeleteButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--名字
	self.SystemSettingsBlacklistPlayerNameLabel = transform:Find('Name/SystemSettingsBlacklistPlayerNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--等级
	self.SystemSettingsBlacklistPlayerLvLabel = transform:Find('Lv/SystemSettingsBlacklistPlayerLvLabel'):GetComponent(typeof(UnityEngine.UI.Text))
end


function SystemSettingsBlacklistPlayerCls:RegisterControlEvents()
	-- 注册 SystemSettingsBlacklistPlayerDeleteButton 的事件
	self.__event_button_onSystemSettingsBlacklistPlayerDeleteButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSystemSettingsBlacklistPlayerDeleteButtonClicked, self)
	self.SystemSettingsBlacklistPlayerDeleteButton.onClick:AddListener(self.__event_button_onSystemSettingsBlacklistPlayerDeleteButtonClicked__)

end

function SystemSettingsBlacklistPlayerCls:UnregisterControlEvents()
	-- 取消注册 SystemSettingsBlacklistPlayerDeleteButton 的事件
	if self.__event_button_onSystemSettingsBlacklistPlayerDeleteButtonClicked__ then
		self.SystemSettingsBlacklistPlayerDeleteButton.onClick:RemoveListener(self.__event_button_onSystemSettingsBlacklistPlayerDeleteButtonClicked__)
		self.__event_button_onSystemSettingsBlacklistPlayerDeleteButtonClicked__ = nil
	end

end

function SystemSettingsBlacklistPlayerCls:RegisterNetworkEvents()
	self.game:RegisterMsgHandler(net.S2CTalkDismissFromBlackResult, self, self.TalkDismissFromBlackResult)
end
function SystemSettingsBlacklistPlayerCls:UnregisterNetworkEvents()
	self.game:UnRegisterMsgHandler(net.S2CTalkDismissFromBlackResult, self, self.TalkDismissFromBlackResult)
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
local function RemoveBlackPlayer(self)
	self.game:SendNetworkMessage(require "Network.ServerService".TalkDismissFromBlackResult(self.PlayerUID))
	local eventMgr = self.game:GetEventManager()    --注册事件
  	eventMgr:PostNotification('RemoveList', nil, self.I)
end
function SystemSettingsBlacklistPlayerCls:OnSystemSettingsBlacklistPlayerDeleteButtonClicked()
	--SystemSettingsBlacklistPlayerDeleteButton控件的点击事件处理
	local windowManager = utility:GetGame():GetWindowManager()
	-- local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
 --    windowManager:Show(ErrorDialogClass, "成功移除黑名单")
	local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
	windowManager:Show(ConfirmDialogClass, "确定将“"..self.playerName.."”移除黑名单吗？",self, RemoveBlackPlayer)
end

function SystemSettingsBlacklistPlayerCls:TalkDismissFromBlackResult(msg)
end
return SystemSettingsBlacklistPlayerCls
