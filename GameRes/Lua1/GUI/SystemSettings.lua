local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local SystemSettingsCls = Class(BaseNodeClass)

function SystemSettingsCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function SystemSettingsCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/SystemSettings', function(go)
		self:BindComponent(go)
	end)
end

function SystemSettingsCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function SystemSettingsCls:OnResume()
	-- 界面显示时调用
	SystemSettingsCls.base.OnResume(self)
	self:GetUnityTransform():SetAsLastSibling()
	self:RegisterControlEvents()
--	self:RegisterNetworkEvents()
	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)
        
        transform.localScale = Vector3(s, s, s)
    end)
end

function SystemSettingsCls:OnPause()
	-- 界面隐藏时调用
	SystemSettingsCls.base.OnPause(self)
	self:UnregisterControlEvents()
--	self:UnregisterNetworkEvents()
	self:FadeOut(function(self, t)
			print('HelloWorld')
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
end

function SystemSettingsCls:OnExitTransitionDidStart(immediately)
	SystemSettingsCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function SystemSettingsCls:OnEnter()
	-- Node Enter时调用
	SystemSettingsCls.base.OnEnter(self)
end

function SystemSettingsCls:OnExit()
	-- Node Exit时调用
	SystemSettingsCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function SystemSettingsCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()

--	self.GrayFarme = transform:Find('Base/WindowBase/GrayFarme'):GetComponent(typeof(UnityEngine.UI.Image))
	self.SystemSettingsRetrunButton = transform:Find('Base/SystemSettingsRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))

	self.BlueBigPoint1 = transform:Find('Base/SoundEffect/BluePointSwitch1/BluePointSwitchOpen1/BlueBigPoint1'):GetComponent(typeof(UnityEngine.UI.Image))--音效开
	self.OpenText1 = transform:Find('Base/SoundEffect/BluePointSwitch1/BluePointSwitchOpen1/OpenText1'):GetComponent(typeof(UnityEngine.UI.Text))--音效开
	self.BlueBigPoint2 = transform:Find('Base/SoundEffect/BluePointSwitch1/BluePointSwitchClose1/BlueBigPoint2'):GetComponent(typeof(UnityEngine.UI.Image))--音效关
	self.CloseText1 = transform:Find('Base/SoundEffect/BluePointSwitch1/BluePointSwitchClose1/CloseText1'):GetComponent(typeof(UnityEngine.UI.Text))--音效关
	self.SoundEffectButton = transform:Find('Base/SoundEffect/BluePointSwitch1/SoundEffectButton'):GetComponent(typeof(UnityEngine.UI.Button))--音效Button

	self.BlueBigPoint3 = transform:Find('Base/SoundBGM/BluePointSwitch2/BluePointSwitchOpen2/BlueBigPoint3'):GetComponent(typeof(UnityEngine.UI.Image))--音乐开
	self.OpenText2 = transform:Find('Base/SoundBGM/BluePointSwitch2/BluePointSwitchOpen2/OpenText2'):GetComponent(typeof(UnityEngine.UI.Text))--音乐开
	self.BlueBigPoint4 = transform:Find('Base/SoundBGM/BluePointSwitch2/BluePointSwitchClose2/BlueBigPoint4'):GetComponent(typeof(UnityEngine.UI.Image))--音乐关
	self.CloseText2 = transform:Find('Base/SoundBGM/BluePointSwitch2/BluePointSwitchClose2/CloseText2'):GetComponent(typeof(UnityEngine.UI.Text))--音乐关
	self.SoundBGMButton = transform:Find('Base/SoundBGM/BluePointSwitch2/SoundBGMButton'):GetComponent(typeof(UnityEngine.UI.Button))--音乐Button

	self.SystemSettingsBlacklistButton = transform:Find('Base/SystemSettingsBlacklistButton'):GetComponent(typeof(UnityEngine.UI.Button))--黑名单
	self.SystemSettingsCDkeyButton = transform:Find('Base/SystemSettingsCDkeyButton'):GetComponent(typeof(UnityEngine.UI.Button))--兑换码
	self.tweenObjectTrans = transform:Find('Base')

	self.Effect = transform:Find('Effect'):GetComponent(typeof(UnityEngine.AudioSource))
	self.BGM = transform:Find('BGM'):GetComponent(typeof(UnityEngine.AudioSource))
end


function SystemSettingsCls:RegisterControlEvents()
	-- 注册 SystemSettingsRetrunButton 的事件
	self.__event_button_onSystemSettingsRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSystemSettingsRetrunButtonClicked, self)
	self.SystemSettingsRetrunButton.onClick:AddListener(self.__event_button_onSystemSettingsRetrunButtonClicked__)

	-- 注册 SystemSettingsBlacklistButton 的事件
	self.__event_button_onSystemSettingsBlacklistButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSystemSettingsBlacklistButtonClicked, self)
	self.SystemSettingsBlacklistButton.onClick:AddListener(self.__event_button_onSystemSettingsBlacklistButtonClicked__)

	-- 注册 SystemSettingsCDkeyButton 的事件
	self.__event_button_onSystemSettingsCDkeyButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSystemSettingsCDkeyButtonClicked, self)
	self.SystemSettingsCDkeyButton.onClick:AddListener(self.__event_button_onSystemSettingsCDkeyButtonClicked__)

	-- 注册 音效 的事件
	self.__event_button_onSoundEffectButtonButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSystemSettingsSoundEffectButtonClicked, self)
	self.SoundEffectButton.onClick:AddListener(self.__event_button_onSoundEffectButtonButtonClicked__)

	-- 注册 BGM 的事件
	self.__event_button_onSoundBGMButtonButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSoundBGMButtonClicked, self)
	self.SoundBGMButton.onClick:AddListener(self.__event_button_onSoundBGMButtonButtonClicked__)
end

function SystemSettingsCls:UnregisterControlEvents()
	-- 取消注册 SystemSettingsRetrunButton 的事件
	if self.__event_button_onSystemSettingsRetrunButtonClicked__ then
		self.SystemSettingsRetrunButton.onClick:RemoveListener(self.__event_button_onSystemSettingsRetrunButtonClicked__)
		self.__event_button_onSystemSettingsRetrunButtonClicked__ = nil
	end

	-- 取消注册 SystemSettingsBlacklistButton 的事件
	if self.__event_button_onSystemSettingsBlacklistButtonClicked__ then
		self.SystemSettingsBlacklistButton.onClick:RemoveListener(self.__event_button_onSystemSettingsBlacklistButtonClicked__)
		self.__event_button_onSystemSettingsBlacklistButtonClicked__ = nil
	end

	-- 取消注册 SystemSettingsCDkeyButton 的事件
	if self.__event_button_onSystemSettingsCDkeyButtonClicked__ then
		self.SystemSettingsCDkeyButton.onClick:RemoveListener(self.__event_button_onSystemSettingsCDkeyButtonClicked__)
		self.__event_button_onSystemSettingsCDkeyButtonClicked__ = nil
	end

	-- 取消注册 音效 的事件
	if self.__event_button_onSoundEffectButtonButtonClicked__ then
		self.SystemSettingsCDkeyButton.onClick:RemoveListener(self.__event_button_onSoundEffectButtonButtonClicked__)
		self.__event_button_onSoundEffectButtonButtonClicked__ = nil
	end

	-- 取消注册 BGM 的事件
	if self.__event_button_onSoundBGMButtonButtonClicked__ then
		self.SystemSettingsCDkeyButton.onClick:RemoveListener(self.__event_button_onSoundBGMButtonButtonClicked__)
		self.__event_button_onSoundBGMButtonButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function SystemSettingsCls:OnSystemSettingsRetrunButtonClicked()
	--SystemSettingsRetrunButton控件的点击事件处理
	self:Close()
end

function SystemSettingsCls:OnSystemSettingsBlacklistButtonClicked()
	--SystemSettingsBlacklistButton控件的点击事件处理
	self.game:SendNetworkMessage(require "Network.ServerService".TalkBlackQueryResult())
	local UserDataType = require "Framework.UserDataType"
	local userData = self:GetCachedData(UserDataType.PlayerData)
	if userData:GetLevel() < 9 then
		local windowManager = utility:GetGame():GetWindowManager()
		local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
   	 	windowManager:Show(ErrorDialogClass, "该功能9级开启")
		return
	end
	local windowManager = self.game:GetWindowManager()
    windowManager:Show(require "GUI.SystemSettingsBlacklist")
end

function SystemSettingsCls:OnSystemSettingsCDkeyButtonClicked()
	--SystemSettingsCDkeyButton控件的点击事件处理
	local windowManager = self.game:GetWindowManager()
    windowManager:Show(require "GUI.SystemSettingsRewardCode")
end

function SystemSettingsCls:OnSystemSettingsSoundEffectButtonClicked()
	if self.BlueBigPoint1.gameObject.activeSelf == true then
		self.Effect:Stop()
		self.BlueBigPoint1.gameObject:SetActive(false)
		self.OpenText1.gameObject:SetActive(false)
		self.BlueBigPoint2.gameObject:SetActive(true)
		self.CloseText1.gameObject:SetActive(true)
	elseif self.BlueBigPoint1.gameObject.activeSelf == false then
		self.Effect:Play()
		self.BlueBigPoint1.gameObject:SetActive(true)
		self.OpenText1.gameObject:SetActive(true)
		self.BlueBigPoint2.gameObject:SetActive(false)
		self.CloseText1.gameObject:SetActive(false)
	end
end

function SystemSettingsCls:OnSoundBGMButtonClicked()
	if self.BlueBigPoint3.gameObject.activeSelf == true then
		self.BGM:Stop()
		self.BlueBigPoint3.gameObject:SetActive(false)
		self.OpenText2.gameObject:SetActive(false)
		self.BlueBigPoint4.gameObject:SetActive(true)
		self.CloseText2.gameObject:SetActive(true)
	elseif self.BlueBigPoint3.gameObject.activeSelf == false then
		self.BGM:Play()
		self.BlueBigPoint3.gameObject:SetActive(true)
		self.OpenText2.gameObject:SetActive(true)
		self.BlueBigPoint4.gameObject:SetActive(false)
		self.CloseText2.gameObject:SetActive(false)
	end
end
return SystemSettingsCls
