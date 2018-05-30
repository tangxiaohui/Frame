local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local GuildApplyItemCls = Class(BaseNodeClass)
local GuildCommonFunc = require "GUI.Guild.GuildCommonFunc"

function GuildApplyItemCls:Ctor(parent, applyInfo)
	self.parent = parent
	self.applyInfo = applyInfo
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GuildApplyItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GuildApplyItem', function(go)
		self:BindComponent(go, false)
	end)
end

function GuildApplyItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LinkComponent(self.parent)
end

function GuildApplyItemCls:OnResume()
	-- 界面显示时调用
	GuildApplyItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function GuildApplyItemCls:OnPause()
	-- 界面隐藏时调用
	GuildApplyItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GuildApplyItemCls:OnEnter()
	-- Node Enter时调用
	GuildApplyItemCls.base.OnEnter(self)
end

function GuildApplyItemCls:OnExit()
	-- Node Exit时调用
	GuildApplyItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GuildApplyItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.Base = transform:Find('Head/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.PersonalInformationHeadIcon = transform:Find('Head/Base/PersonalInformationHeadIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Lv = transform:Find('Lv'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LevelNuLabel = transform:Find('LevelNuLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.MemberNameLabel = transform:Find('MemberNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.RefuseButton = transform:Find('RefuseButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ConferButton = transform:Find('ConferButton'):GetComponent(typeof(UnityEngine.UI.Button))

	self:InitView()
end

function GuildApplyItemCls:InitView()
	utility.LoadRoleHeadIcon(self.applyInfo.headID, self.PersonalInformationHeadIcon)
	self.Base.color = require "Utils.PropUtility".GetColorValue(self.applyInfo.headColor)
	self.LevelNuLabel.text = self.applyInfo.playerLevel
	self.MemberNameLabel.text = self.applyInfo.playerName
end

function GuildApplyItemCls:RegisterControlEvents()
	-- 注册 RefuseButton 的事件
	self.__event_button_onRefuseButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRefuseButtonClicked, self)
	self.RefuseButton.onClick:AddListener(self.__event_button_onRefuseButtonClicked__)

	-- 注册 ConferButton 的事件
	self.__event_button_onConferButtonClicked__ = UnityEngine.Events.UnityAction(self.OnConferButtonClicked, self)
	self.ConferButton.onClick:AddListener(self.__event_button_onConferButtonClicked__)
end

function GuildApplyItemCls:UnregisterControlEvents()
	-- 取消注册 RefuseButton 的事件
	if self.__event_button_onRefuseButtonClicked__ then
		self.RefuseButton.onClick:RemoveListener(self.__event_button_onRefuseButtonClicked__)
		self.__event_button_onRefuseButtonClicked__ = nil
	end

	-- 取消注册 ConferButton 的事件
	if self.__event_button_onConferButtonClicked__ then
		self.ConferButton.onClick:RemoveListener(self.__event_button_onConferButtonClicked__)
		self.__event_button_onConferButtonClicked__ = nil
	end
end

function GuildApplyItemCls:RegisterNetworkEvents()
end

function GuildApplyItemCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function GuildApplyItemCls:OnRefuseButtonClicked()
	self:HandleApply(1)
end

function GuildApplyItemCls:OnConferButtonClicked()
	self:HandleApply(0)
end

function GuildApplyItemCls:HandleApply(state)
	local ghId = self:GetCachedData(require "Framework.UserDataType".PlayerData):GetGonghuiID()
	utility:GetGame():SendNetworkMessage(require "Network/ServerService".GHHandleApplyRequest(ghId, self.applyInfo.playerUID, state))
end

return GuildApplyItemCls
