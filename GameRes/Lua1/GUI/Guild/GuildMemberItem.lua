local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local GuildMemberItemCls = Class(BaseNodeClass)
local GuildCommonFunc = require "GUI.Guild.GuildCommonFunc"

function GuildMemberItemCls:Ctor(parent, memInfo, job)
	self.parent = parent
	self.memInfo = memInfo
	self.job = job
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GuildMemberItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GuildMemberItem', function(go)
		self:BindComponent(go, false)
	end)
end

function GuildMemberItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LinkComponent(self.parent)
end

function GuildMemberItemCls:OnResume()
	-- 界面显示时调用
	GuildMemberItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function GuildMemberItemCls:OnPause()
	-- 界面隐藏时调用
	GuildMemberItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GuildMemberItemCls:OnEnter()
	-- Node Enter时调用
	GuildMemberItemCls.base.OnEnter(self)
end

function GuildMemberItemCls:OnExit()
	-- Node Exit时调用
	GuildMemberItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GuildMemberItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.Box = transform:Find('Box'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Base = transform:Find('Head/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.PersonalInformationHeadIcon = transform:Find('Head/Base/PersonalInformationHeadIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Lv = transform:Find('Lv'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LevelNuLabel = transform:Find('LevelNuLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.MemberNameLabel = transform:Find('MemberNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ONline = transform:Find('ONline'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OFFline = transform:Find('OFFline'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ManagerTitle = transform:Find('ManagerTitle'):GetComponent(typeof(UnityEngine.UI.Text))
	self.MemberTributeLabel = transform:Find('MemberTributeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.MoreButton = transform:Find('MoreButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ButtonText = transform:Find('MoreButton/Text'):GetComponent(typeof(UnityEngine.UI.Text))

	self:InitView()
end

function GuildMemberItemCls:InitView()
	self.MemberNameLabel.text = self.memInfo.playerName
	self.LevelNuLabel.text = self.memInfo.playerLevel
	self.ONline.gameObject:SetActive(self.memInfo.online)
	self.OFFline.gameObject:SetActive(not self.memInfo.online)
	self.MemberTributeLabel.text = "贡献："..self.memInfo.contribution
	self.ManagerTitle.text = require "StaticData.LegionInfo":GetData(self.memInfo.job):GetName()
	self.Base.color = require "Utils.PropUtility".GetColorValue(self.memInfo.headColor)
	utility.LoadRoleHeadIcon(self.memInfo.headID, self.PersonalInformationHeadIcon)
	self.MoreButton.gameObject:SetActive(self.job==1)
	if self.job==1 then
		self.MoreButton.enabled = self.memInfo.job~=1
		if self.memInfo.job==1 then	--会长
			self.MoreButton:GetComponent(typeof(UnityEngine.UI.Image)).material = utility.GetGrayMaterial()
			self.ButtonText.material = utility.GetGrayMaterial("Text")
		end
	end
end

function GuildMemberItemCls:RegisterControlEvents()
	-- 注册 MoreButton 的事件
	self.__event_button_onMoreButtonClicked__ = UnityEngine.Events.UnityAction(self.OnMoreButtonClicked, self)
	self.MoreButton.onClick:AddListener(self.__event_button_onMoreButtonClicked__)
end

function GuildMemberItemCls:UnregisterControlEvents()
	-- 取消注册 MoreButton 的事件
	if self.__event_button_onMoreButtonClicked__ then
		self.MoreButton.onClick:RemoveListener(self.__event_button_onMoreButtonClicked__)
		self.__event_button_onMoreButtonClicked__ = nil
	end
end

function GuildMemberItemCls:RegisterNetworkEvents()
end

function GuildMemberItemCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function GuildMemberItemCls:OnMoreButtonClicked()
	utility:GetGame():GetWindowManager():Show(require "GUI/Guild/GuildManage", self.memInfo)
end

return GuildMemberItemCls
