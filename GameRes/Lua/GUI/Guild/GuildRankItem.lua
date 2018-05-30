local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local GuildRankItemCls = Class(BaseNodeClass)
local GuildCommonFunc = require "GUI.Guild.GuildCommonFunc"

function GuildRankItemCls:Ctor(parent, rankInfo,isInGuild)
	self.parent = parent
	self.rankInfo = rankInfo
	self.isInGuild = isInGuild
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GuildRankItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GuildRankItem', function(go)
		self:BindComponent(go, false)
	end)
end

function GuildRankItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LinkComponent(self.parent)
end

function GuildRankItemCls:OnResume()
	-- 界面显示时调用
	GuildRankItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function GuildRankItemCls:OnPause()
	-- 界面隐藏时调用
	GuildRankItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GuildRankItemCls:OnEnter()
	-- Node Enter时调用
	GuildRankItemCls.base.OnEnter(self)
	self:SetJoinButtonState(self.isInGuild)
end

function GuildRankItemCls:OnExit()
	-- Node Exit时调用
	GuildRankItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GuildRankItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.Box = transform:Find('Box'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipLevelNuLabel = transform:Find('BackpackEquipLevelNuLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.GuildNameLabel = transform:Find('GuildNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.MemberNumLabel = transform:Find('MemberNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.GuildInfoLabel = transform:Find('GuildInfoLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.JoinButton = transform:Find('JoinButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Text = transform:Find('JoinButton/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.IconFrame = transform:Find('IconFrame/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Base1 = transform:Find('IconFrame/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.GuildIcon = transform:Find('IconFrame/GuildIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.PowerLabel = transform:Find('PowerLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self:InitView()
end

function GuildRankItemCls:InitView()
	self.BackpackEquipLevelNuLabel.text = "Lv"..self.rankInfo.lv
	self.GuildNameLabel.text = self.rankInfo.name
	self.MemberNumLabel.text = "成员人数: "..self.rankInfo.people..'/'..require "StaticData.LegionLv":GetData(self.rankInfo.lv):GetPeople()
	self.GuildInfoLabel.text = self.rankInfo.showmsg
	self.PowerLabel.text = self.rankInfo.act
	self:SetGray(self.rankInfo.alreadyApply==1)
	local iconPath, iconColor, _ = GuildCommonFunc.GetGuildIconInfo(self.rankInfo.logoID)
	self.IconFrame.color = iconColor
	utility.LoadSpriteFromPath(iconPath,self.GuildIcon)
end

function GuildRankItemCls:SetGray(bGray)
	self.JoinButton.enabled = not bGray
	if bGray then
		self.JoinButton:GetComponent(typeof(UnityEngine.UI.Image)).material = utility.GetGrayMaterial()
		self.Text.material = utility.GetGrayMaterial("Text")
	else
		self.JoinButton:GetComponent(typeof(UnityEngine.UI.Image)).material = utility.GetCommonMaterial()
		self.Text.material = utility.GetCommonMaterial("Text")
	end
end

function GuildRankItemCls:RegisterControlEvents()
	-- 注册 JoinButton 的事件
	self.__event_button_onJoinButtonClicked__ = UnityEngine.Events.UnityAction(self.OnJoinButtonClicked, self)
	self.JoinButton.onClick:AddListener(self.__event_button_onJoinButtonClicked__)

end

function GuildRankItemCls:UnregisterControlEvents()
	-- 取消注册 JoinButton 的事件
	if self.__event_button_onJoinButtonClicked__ then
		self.JoinButton.onClick:RemoveListener(self.__event_button_onJoinButtonClicked__)
		self.__event_button_onJoinButtonClicked__ = nil
	end

end

function GuildRankItemCls:RegisterNetworkEvents()
end

function GuildRankItemCls:UnregisterNetworkEvents()
end

function GuildRankItemCls:SetJoinButtonState(isShow)
	if isShow then
		self.JoinButton.gameObject:SetActive(true)
	else
		self.JoinButton.gameObject:SetActive(false)
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function GuildRankItemCls:OnJoinButtonClicked()
	utility:GetGame():SendNetworkMessage(require "Network/ServerService".GHJoinRequest(self.rankInfo.ghID))
end

return GuildRankItemCls
