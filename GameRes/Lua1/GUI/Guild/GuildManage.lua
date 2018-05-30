local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local GuildManageCls = Class(BaseNodeClass)
local GuildCommonFunc = require "GUI.Guild.GuildCommonFunc"

function GuildManageCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GuildManageCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GuildManage', function(go)
		self:BindComponent(go)
	end)
end

function GuildManageCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function GuildManageCls:OnResume()
	-- 界面显示时调用
	GuildManageCls.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.base

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function GuildManageCls:OnPause()
	-- 界面隐藏时调用
	GuildManageCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GuildManageCls:OnEnter()
	-- Node Enter时调用
	GuildManageCls.base.OnEnter(self)
end

function GuildManageCls:OnExit()
	-- Node Exit时调用
	GuildManageCls.base.OnExit(self)
end

function GuildManageCls:OnWillShow(memInfo)
	self.memInfo = memInfo
end

function GuildManageCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GuildManageCls:InitControls()
	local transform = self:GetUnityTransform()
	transform.localPosition = Vector3(6,16,0)
	self.base = transform:Find('Base')
	self.Base = self.base:Find('Head/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.PersonalInformationHeadIcon = self.base:Find('Head/Base/PersonalInformationHeadIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LevelNuLabel = self.base:Find('LevelNuLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ONline = self.base:Find('ONline'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OFFline = self.base:Find('OFFline'):GetComponent(typeof(UnityEngine.UI.Text))
	self.MemberNameLabel = self.base:Find('MemberNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.MemberTributeLabel = self.base:Find('MemberTributeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.KickOutButton = self.base:Find('KickOutButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.MoveButton = self.base:Find('MoveButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.HandoutButton = self.base:Find('HandoutButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.CrossButton = self.base:Find('CrossButton'):GetComponent(typeof(UnityEngine.UI.Button))
		--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self.windowManager = utility:GetGame():GetWindowManager()

	self:InitView()
end

function GuildManageCls:InitView()
	self.Base.color = require "Utils.PropUtility".GetColorValue(self.memInfo.headColor)
	utility.LoadRoleHeadIcon(self.memInfo.headID, self.PersonalInformationHeadIcon)
	self.LevelNuLabel.text = self.memInfo.playerLevel
	self.ONline.gameObject:SetActive(self.memInfo.online)
	self.OFFline.gameObject:SetActive(not self.memInfo.online)
	self.MemberNameLabel.text = self.memInfo.playerName
	self.MemberTributeLabel.text = "贡献："..self.memInfo.contribution
end

function GuildManageCls:RegisterControlEvents()
	-- 注册 KickOutButton 的事件
	self.__event_button_onKickOutButtonClicked__ = UnityEngine.Events.UnityAction(self.OnKickOutButtonClicked, self)
	self.KickOutButton.onClick:AddListener(self.__event_button_onKickOutButtonClicked__)

	-- 注册 MoveButton 的事件
	self.__event_button_onMoveButtonClicked__ = UnityEngine.Events.UnityAction(self.OnMoveButtonClicked, self)
	self.MoveButton.onClick:AddListener(self.__event_button_onMoveButtonClicked__)

	-- 注册 HandoutButton 的事件
	self.__event_button_onHandoutButtonClicked__ = UnityEngine.Events.UnityAction(self.OnHandoutButtonClicked, self)
	self.HandoutButton.onClick:AddListener(self.__event_button_onHandoutButtonClicked__)

	-- 注册 CrossButton 的事件
	self.__event_button_onCrossButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked, self)
	self.CrossButton.onClick:AddListener(self.__event_button_onCrossButtonClicked__)

		-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)
end

function GuildManageCls:UnregisterControlEvents()
	-- 取消注册 KickOutButton 的事件
	if self.__event_button_onKickOutButtonClicked__ then
		self.KickOutButton.onClick:RemoveListener(self.__event_button_onKickOutButtonClicked__)
		self.__event_button_onKickOutButtonClicked__ = nil
	end

	-- 取消注册 MoveButton 的事件
	if self.__event_button_onMoveButtonClicked__ then
		self.MoveButton.onClick:RemoveListener(self.__event_button_onMoveButtonClicked__)
		self.__event_button_onMoveButtonClicked__ = nil
	end

	-- 取消注册 HandoutButton 的事件
	if self.__event_button_onHandoutButtonClicked__ then
		self.HandoutButton.onClick:RemoveListener(self.__event_button_onHandoutButtonClicked__)
		self.__event_button_onHandoutButtonClicked__ = nil
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

function GuildManageCls:RegisterNetworkEvents()
	utility:GetGame():RegisterMsgHandler(net.S2CGHManagerMemResult, self, self.GHManagerMemResult)
end

function GuildManageCls:UnregisterNetworkEvents()
	utility:GetGame():UnRegisterMsgHandler(net.S2CGHManagerMemResult, self, self.GHManagerMemResult)
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function GuildManageCls:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function GuildManageCls:OnExitTransitionDidStart(immediately)
    GuildManageCls.base.OnExitTransitionDidStart(self, immediately)

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
function GuildManageCls:OnKickOutButtonClicked()
	self.windowManager:Show(require "GUI/Guild/GuildManageConfirm", self.memInfo, "KICKOUT")
end

function GuildManageCls:OnMoveButtonClicked()
	self.windowManager:Show(require "GUI/Guild/GuildManageConfirm", self.memInfo, "TRANSFER")
end

function GuildManageCls:OnHandoutButtonClicked()
	self.windowManager:Show(require "GUI/Guild/GuildManageConfirm", self.memInfo, "HANDOVER")
end

function GuildManageCls:OnCrossButtonClicked()
	self:Close()
end

function GuildManageCls:GHManagerMemResult(msg)
	self:Close()
end

return GuildManageCls
