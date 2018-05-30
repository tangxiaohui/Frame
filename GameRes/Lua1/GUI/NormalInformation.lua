local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local NormalInformationCls = Class(BaseNodeClass)
local SystemDescriptionInfoData = require "StaticData/SystemConfig/SystemDescriptionInfo"

function NormalInformationCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function NormalInformationCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/NormalInformation', function(go)
		self:BindComponent(go)
	end)
end

function NormalInformationCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function NormalInformationCls:OnResume()
	-- 界面显示时调用
	NormalInformationCls.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.base

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function NormalInformationCls:OnPause()
	-- 界面隐藏时调用
	NormalInformationCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function NormalInformationCls:OnEnter()
	-- Node Enter时调用
	NormalInformationCls.base.OnEnter(self)
end

function NormalInformationCls:OnExit()
	-- Node Exit时调用
	NormalInformationCls.base.OnExit(self)
end

-- 参数对应SystemConfig表中descriptionInfo字段
function NormalInformationCls:OnWillShow(systemID)
	self.infoStr = SystemDescriptionInfoData:GetData(systemID):GetDescription()
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function NormalInformationCls:InitControls()
	local transform = self:GetUnityTransform()
	self.base = transform:Find('Base')
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.DownerDecoration = self.base:Find('DownerDecoration'):GetComponent(typeof(UnityEngine.UI.Image))
	self.UpperDecoration = self.base:Find('UpperDecoration'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Box = self.base:Find('Box'):GetComponent(typeof(UnityEngine.UI.Image))
	self.InfoLabel = self.base:Find('Scroll View/Viewport/Content/InfoLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Title = self.base:Find('Title'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CrossButton = self.base:Find('CrossButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- self.CancelButton = self.base:Find('CancelButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ConferButton = self.base:Find('ConferButton'):GetComponent(typeof(UnityEngine.UI.Button))

	self.InfoLabel.text = string.gsub(self.infoStr,"\\n","\n")
end


function NormalInformationCls:RegisterControlEvents()
	-- 注册 CrossButton 的事件
	self.__event_button_onCrossButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked, self)
	self.CrossButton.onClick:AddListener(self.__event_button_onCrossButtonClicked__)

	-- 注册 CancelButton 的事件
	-- self.__event_button_onCancelButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCancelButtonClicked, self)
	-- self.CancelButton.onClick:AddListener(self.__event_button_onCancelButtonClicked__)

	-- 注册 ConferButton 的事件
	self.__event_button_onConferButtonClicked__ = UnityEngine.Events.UnityAction(self.OnConferButtonClicked, self)
	self.ConferButton.onClick:AddListener(self.__event_button_onConferButtonClicked__)
end

function NormalInformationCls:UnregisterControlEvents()
	-- 取消注册 CrossButton 的事件
	if self.__event_button_onCrossButtonClicked__ then
		self.CrossButton.onClick:RemoveListener(self.__event_button_onCrossButtonClicked__)
		self.__event_button_onCrossButtonClicked__ = nil
	end

	-- 取消注册 CancelButton 的事件
	-- if self.__event_button_onCancelButtonClicked__ then
	-- 	self.CancelButton.onClick:RemoveListener(self.__event_button_onCancelButtonClicked__)
	-- 	self.__event_button_onCancelButtonClicked__ = nil
	-- end

	-- 取消注册 ConferButton 的事件
	if self.__event_button_onConferButtonClicked__ then
		self.ConferButton.onClick:RemoveListener(self.__event_button_onConferButtonClicked__)
		self.__event_button_onConferButtonClicked__ = nil
	end
end

function NormalInformationCls:RegisterNetworkEvents()
end

function NormalInformationCls:UnregisterNetworkEvents()
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function NormalInformationCls:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function NormalInformationCls:OnExitTransitionDidStart(immediately)
    NormalInformationCls.base.OnExitTransitionDidStart(self, immediately)

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
function NormalInformationCls:OnCrossButtonClicked()
	self:Close()
end

function NormalInformationCls:OnCancelButtonClicked()
	self:Close()
end

function NormalInformationCls:OnConferButtonClicked()
	self:Close()
end

return NormalInformationCls
