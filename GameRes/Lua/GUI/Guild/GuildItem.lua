local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local GuildItemCls = Class(BaseNodeClass)
local GuildCommonFunc = require "GUI.Guild.GuildCommonFunc"

function GuildItemCls:Ctor(parent, ghInfo)
	self.parent = parent
	self.ghInfo = ghInfo
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GuildItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GuildItem', function(go)
		self:BindComponent(go, false)
	end)
end

function GuildItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LinkComponent(self.parent)
end

function GuildItemCls:OnResume()
	-- 界面显示时调用
	GuildItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function GuildItemCls:OnPause()
	-- 界面隐藏时调用
	GuildItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GuildItemCls:OnEnter()
	-- Node Enter时调用
	GuildItemCls.base.OnEnter(self)
end

function GuildItemCls:OnExit()
	-- Node Exit时调用
	GuildItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GuildItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.Box = transform:Find('Box'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipLevelNuLabel = transform:Find('BackpackEquipLevelNuLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.GuildNameLabel = transform:Find('GuildNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.MemberNumLabel = transform:Find('MemberNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.GuildInfoLabel = transform:Find('GuildInfoLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.JoinButton = transform:Find('JoinButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ButtonText = transform:Find('JoinButton/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.IconFrame = transform:Find('IconFrame/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Base1 = transform:Find('IconFrame/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.GuildIcon = transform:Find('IconFrame/GuildIcon'):GetComponent(typeof(UnityEngine.UI.Image))

	self:InitView()
end

function GuildItemCls:InitView()
	self.GuildNameLabel.text = self.ghInfo.name
	self.GuildInfoLabel.text = self.ghInfo.showmsg
	self.MemberNumLabel.text = "成员人数: "..self.ghInfo.total
	self.BackpackEquipLevelNuLabel.text = "Lv"..self.ghInfo.level
	self:SetGray(self.ghInfo.alreadyApply==1)
	local iconPath, iconColor, _ = GuildCommonFunc.GetGuildIconInfo(self.ghInfo.logoID)
	self.Base1.color = iconColor
	utility.LoadSpriteFromPath(iconPath,self.GuildIcon)
	self.IconFrame.color = iconColor
end

function GuildItemCls:SetGray(bGray)
	self.JoinButton.enabled = not bGray
	if bGray then
		self.JoinButton:GetComponent(typeof(UnityEngine.UI.Image)).material = utility.GetGrayMaterial()
		self.ButtonText.material = utility.GetGrayMaterial("Text")
	else
		self.JoinButton:GetComponent(typeof(UnityEngine.UI.Image)).material = utility.GetCommonMaterial()
		self.ButtonText.material = utility.GetCommonMaterial("Text")
	end
end

function GuildItemCls:RegisterControlEvents()
	-- 注册 JoinButton 的事件
	self.__event_button_onJoinButtonClicked__ = UnityEngine.Events.UnityAction(self.OnJoinButtonClicked, self)
	self.JoinButton.onClick:AddListener(self.__event_button_onJoinButtonClicked__)

end

function GuildItemCls:UnregisterControlEvents()
	-- 取消注册 JoinButton 的事件
	if self.__event_button_onJoinButtonClicked__ then
		self.JoinButton.onClick:RemoveListener(self.__event_button_onJoinButtonClicked__)
		self.__event_button_onJoinButtonClicked__ = nil
	end

end

function GuildItemCls:RegisterNetworkEvents()
	utility:GetGame():RegisterMsgHandler(net.S2CGHJoinResult, self, self.GHJoinResult)
end

function GuildItemCls:UnregisterNetworkEvents()
	utility:GetGame():UnRegisterMsgHandler(net.S2CGHJoinResult, self, self.GHJoinResult)
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function GuildItemCls:OnJoinButtonClicked()
	utility:GetGame():SendNetworkMessage(require "Network/ServerService".GHJoinRequest(self.ghInfo.ghID))
end

function GuildItemCls:GHJoinResult(msg)
	local windowManager = utility.GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Dialogs.NormalDialog","申请成功")
	if msg.ghID==self.ghInfo.ghID then
		self:SetGray(true)
		self.ghInfo.alreadyApply = 1
	end
end

return GuildItemCls
