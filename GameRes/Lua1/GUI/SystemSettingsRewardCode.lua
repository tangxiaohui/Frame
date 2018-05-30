local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local SystemSettingsRewardCodeCls = Class(BaseNodeClass)

function SystemSettingsRewardCodeCls:Ctor()
end
function SystemSettingsRewardCodeCls:OnWillShow()

end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function SystemSettingsRewardCodeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/SystemSettingsRewardCode', function(go)
		self:BindComponent(go)
	end)
end

function SystemSettingsRewardCodeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function SystemSettingsRewardCodeCls:IsTransition()
    return true
end

function SystemSettingsRewardCodeCls:OnResume()
	-- 界面显示时调用
	SystemSettingsRewardCodeCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function SystemSettingsRewardCodeCls:OnPause()
	-- 界面隐藏时调用
	SystemSettingsRewardCodeCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function SystemSettingsRewardCodeCls:OnExitTransitionDidStart(immediately)
	SystemSettingsRewardCodeCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function SystemSettingsRewardCodeCls:OnEnter()
	-- Node Enter时调用
	SystemSettingsRewardCodeCls.base.OnEnter(self)
end

function SystemSettingsRewardCodeCls:OnExit()
	-- Node Exit时调用
	SystemSettingsRewardCodeCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function SystemSettingsRewardCodeCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()
	self.SystemSettingsRewardCodeRetrunButton = transform:Find('tweenObjectTrans/SystemSettingsRewardCodeRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BackpackWhereGoToButton = transform:Find('tweenObjectTrans/ButtonLayout/BackpackWhereGoToButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.InputBox = transform:Find('tweenObjectTrans/InputBox'):GetComponent(typeof(UnityEngine.UI.InputField))
	-- self.SystemSettingsRewardInputBoxLabel = transform:Find('tweenObjectTrans/InputBox/SystemSettingsRewardInputBoxLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.tweenObjectTrans = transform:Find('tweenObjectTrans')
end

function SystemSettingsRewardCodeCls:RegisterControlEvents()
	-- 注册 SystemSettingsRewardCodeRetrunButton 的事件
	self.__event_button_onSystemSettingsRewardCodeRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSystemSettingsRewardCodeRetrunButtonClicked, self)
	self.SystemSettingsRewardCodeRetrunButton.onClick:AddListener(self.__event_button_onSystemSettingsRewardCodeRetrunButtonClicked__)

	-- 注册 BackpackWhereGoToButton 的事件
	self.__event_button_onBackpackWhereGoToButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackWhereGoToButtonClicked, self)
	self.BackpackWhereGoToButton.onClick:AddListener(self.__event_button_onBackpackWhereGoToButtonClicked__)

end

function SystemSettingsRewardCodeCls:UnregisterControlEvents()
	-- 取消注册 SystemSettingsRewardCodeRetrunButton 的事件
	if self.__event_button_onSystemSettingsRewardCodeRetrunButtonClicked__ then
		self.SystemSettingsRewardCodeRetrunButton.onClick:RemoveListener(self.__event_button_onSystemSettingsRewardCodeRetrunButtonClicked__)
		self.__event_button_onSystemSettingsRewardCodeRetrunButtonClicked__ = nil
	end

	-- 取消注册 BackpackWhereGoToButton 的事件
	if self.__event_button_onBackpackWhereGoToButtonClicked__ then
		self.BackpackWhereGoToButton.onClick:RemoveListener(self.__event_button_onBackpackWhereGoToButtonClicked__)
		self.__event_button_onBackpackWhereGoToButtonClicked__ = nil
	end

end

function SystemSettingsRewardCodeCls:RegisterNetworkEvents()
	self.game:RegisterMsgHandler(net.S2CExchangeCodeResult, self, self.ExchangeCodeResult)
end
function SystemSettingsRewardCodeCls:UnregisterNetworkEvents()
	self.game:UnRegisterMsgHandler(net.S2CExchangeCodeResult, self, self.ExchangeCodeResult)
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function SystemSettingsRewardCodeCls:OnSystemSettingsRewardCodeRetrunButtonClicked()
	--SystemSettingsRewardCodeRetrunButton控件的点击事件处理
	self:Hide()
end

function SystemSettingsRewardCodeCls:OnBackpackWhereGoToButtonClicked()
	--BackpackWhereGoToButton控件的点击事件处理
	self.game:SendNetworkMessage(require "Network.ServerService".Code(self.InputBox.text))
end

function SystemSettingsRewardCodeCls:ExchangeCodeResult(msg)

end
return SystemSettingsRewardCodeCls
