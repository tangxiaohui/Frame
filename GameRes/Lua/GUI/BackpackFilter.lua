local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local BackpackFilterCls = Class(BaseNodeClass)

function BackpackFilterCls:Ctor()
	self.CurrentFiltrate = "全部"
	self.FinishFiltrate = "全部"
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function BackpackFilterCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/BackpackFilter', function(go)
		self:BindComponent(go)
	end)
end

function BackpackFilterCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function BackpackFilterCls:IsTransition()
    return true
end

function BackpackFilterCls:OnResume()
	-- 界面显示时调用
	BackpackFilterCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:SetCurrentFilter()
--	self:RegisterNetworkEvents()
	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function BackpackFilterCls:OnExitTransitionDidStart(immediately)
	BackpackFilterCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function BackpackFilterCls:OnPause()
	-- 界面隐藏时调用
	BackpackFilterCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function BackpackFilterCls:OnEnter()
	-- Node Enter时调用
	BackpackFilterCls.base.OnEnter(self)
end

function BackpackFilterCls:OnExit()
	-- Node Exit时调用
	BackpackFilterCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function BackpackFilterCls:InitControls()
	local transform = self:GetUnityTransform()
	self.myGame = utility.GetGame()
	self.TranslucentLayer = transform:Find('TweenObj/SmallWindowBase/TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BigFarme = transform:Find('TweenObj/SmallWindowBase/BigFarme'):GetComponent(typeof(UnityEngine.UI.Image))
	self.UpperBorder = transform:Find('TweenObj/SmallWindowBase/UpperBorder'):GetComponent(typeof(UnityEngine.UI.Image))
	self.GrayFarme = transform:Find('TweenObj/SmallWindowBase/GrayFarme'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BlackTitleBase = transform:Find('TweenObj/SmallWindowBase/BlackTitleBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Title = transform:Find('TweenObj/SmallWindowBase/Title'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackFilterRetrunButton = transform:Find('TweenObj/BackpackFilterRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BackpackFilterQueDingButton = transform:Find('TweenObj/BackpackFilterQueDingButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.TitleText1 = transform:Find('TweenObj/OptionLayout/OptionAll/TitleText1'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ToggleAll = transform:Find('TweenObj/OptionLayout/OptionAll/ToggleAll'):GetComponent(typeof(UnityEngine.UI.Toggle))
	self.TitleText2 = transform:Find('TweenObj/OptionLayout/OptionWeapon/TitleText2'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ToggleWeapon = transform:Find('TweenObj/OptionLayout/OptionWeapon/ToggleWeapon'):GetComponent(typeof(UnityEngine.UI.Toggle))
	self.TitleText3 = transform:Find('TweenObj/OptionLayout/OptionArmor/TitleText3'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ToggleArmor = transform:Find('TweenObj/OptionLayout/OptionArmor/ToggleArmor'):GetComponent(typeof(UnityEngine.UI.Toggle))
	self.TitleText4 = transform:Find('TweenObj/OptionLayout/OptionAccessories/TitleText4'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ToggleAccessories = transform:Find('TweenObj/OptionLayout/OptionAccessories/ToggleAccessories'):GetComponent(typeof(UnityEngine.UI.Toggle))
	self.TitleText5 = transform:Find('TweenObj/OptionLayout/OptionShoesr/TitleText5'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ToggleShoesr = transform:Find('TweenObj/OptionLayout/OptionShoesr/ToggleShoesr'):GetComponent(typeof(UnityEngine.UI.Toggle))
	self.TitleText6 = transform:Find('TweenObj/OptionLayout/OptionFashion/TitleText6'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ToggleFashion = transform:Find('TweenObj/OptionLayout/OptionFashion/ToggleFashion'):GetComponent(typeof(UnityEngine.UI.Toggle))
	self.tweenObjectTrans = transform:Find('TweenObj')
	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
end


function BackpackFilterCls:RegisterControlEvents()
	-- 注册 BackpackFilterRetrunButton 的事件
	self.__event_button_onBackpackFilterRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackFilterRetrunButtonClicked, self)
	self.BackpackFilterRetrunButton.onClick:AddListener(self.__event_button_onBackpackFilterRetrunButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCloseButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)


	-- 注册 BackpackFilterQueDingButton 的事件
	self.__event_button_onBackpackFilterQueDingButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackFilterQueDingButtonClicked, self)
	self.BackpackFilterQueDingButton.onClick:AddListener(self.__event_button_onBackpackFilterQueDingButtonClicked__)

	-- 注册 ToggleAll 的事件
	self.__event_toggle_onToggleAllValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnToggleAllValueChanged, self)
	self.ToggleAll.onValueChanged:AddListener(self.__event_toggle_onToggleAllValueChanged__)

	-- 注册 ToggleWeapon 的事件
	self.__event_toggle_onToggleWeaponValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnToggleWeaponValueChanged, self)
	self.ToggleWeapon.onValueChanged:AddListener(self.__event_toggle_onToggleWeaponValueChanged__)

	-- 注册 ToggleArmor 的事件
	self.__event_toggle_onToggleArmorValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnToggleArmorValueChanged, self)
	self.ToggleArmor.onValueChanged:AddListener(self.__event_toggle_onToggleArmorValueChanged__)

	-- 注册 ToggleAccessories 的事件
	self.__event_toggle_onToggleAccessoriesValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnToggleAccessoriesValueChanged, self)
	self.ToggleAccessories.onValueChanged:AddListener(self.__event_toggle_onToggleAccessoriesValueChanged__)

	-- 注册 ToggleShoesr 的事件
	self.__event_toggle_onToggleShoesrValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnToggleShoesrValueChanged, self)
	self.ToggleShoesr.onValueChanged:AddListener(self.__event_toggle_onToggleShoesrValueChanged__)

	-- 注册 ToggleFashion 的事件
	self.__event_toggle_onToggleFashionValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnToggleFashionValueChanged, self)
	self.ToggleFashion.onValueChanged:AddListener(self.__event_toggle_onToggleFashionValueChanged__)
end

function BackpackFilterCls:UnregisterControlEvents()
	-- 取消注册 BackpackFilterRetrunButton 的事件
	if self.__event_button_onBackpackFilterRetrunButtonClicked__ then
		self.BackpackFilterRetrunButton.onClick:RemoveListener(self.__event_button_onBackpackFilterRetrunButtonClicked__)
		self.__event_button_onBackpackFilterRetrunButtonClicked__ = nil
	end

	-- 取消注册 BackpackFilterQueDingButton 的事件
	if self.__event_button_onBackpackFilterQueDingButtonClicked__ then
		self.BackpackFilterQueDingButton.onClick:RemoveListener(self.__event_button_onBackpackFilterQueDingButtonClicked__)
		self.__event_button_onBackpackFilterQueDingButtonClicked__ = nil
	end

	-- 取消注册 ToggleAll 的事件
	if self.__event_toggle_onToggleAllValueChanged__ then
		self.ToggleAll.onValueChanged:RemoveListener(self.__event_toggle_onToggleAllValueChanged__)
		self.__event_toggle_onToggleAllValueChanged__ = nil
	end

	-- 取消注册 ToggleWeapon 的事件
	if self.__event_toggle_onToggleWeaponValueChanged__ then
		self.ToggleWeapon.onValueChanged:RemoveListener(self.__event_toggle_onToggleWeaponValueChanged__)
		self.__event_toggle_onToggleWeaponValueChanged__ = nil
	end

	-- 取消注册 ToggleArmor 的事件
	if self.__event_toggle_onToggleArmorValueChanged__ then
		self.ToggleArmor.onValueChanged:RemoveListener(self.__event_toggle_onToggleArmorValueChanged__)
		self.__event_toggle_onToggleArmorValueChanged__ = nil
	end

	-- 取消注册 ToggleAccessories 的事件
	if self.__event_toggle_onToggleAccessoriesValueChanged__ then
		self.ToggleAccessories.onValueChanged:RemoveListener(self.__event_toggle_onToggleAccessoriesValueChanged__)
		self.__event_toggle_onToggleAccessoriesValueChanged__ = nil
	end

	-- 取消注册 ToggleShoesr 的事件
	if self.__event_toggle_onToggleShoesrValueChanged__ then
		self.ToggleShoesr.onValueChanged:RemoveListener(self.__event_toggle_onToggleShoesrValueChanged__)
		self.__event_toggle_onToggleShoesrValueChanged__ = nil
	end

	-- 取消注册 ToggleFashion 的事件
	if self.__event_toggle_onToggleFashionValueChanged__ then
		self.ToggleFashion.onValueChanged:RemoveListener(self.__event_toggle_onToggleFashionValueChanged__)
		self.__event_toggle_onToggleFashionValueChanged__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function BackpackFilterCls:SetCurrentFilter()
	if self.FinishFiltrate == self.CurrentFiltrate then
		return
	end
	if self.FinishFiltrate == "全部" then
		self.ToggleAll.isOn = true
		self.ToggleWeapon.isOn = false
		self.ToggleArmor.isOn = false
		self.ToggleAccessories.isOn = false
		self.ToggleShoesr.isOn = false
		self.ToggleFashion.isOn = false
	elseif self.FinishFiltrate == "武器" then
		self.ToggleAll.isOn = false
		self.ToggleWeapon.isOn = true
		self.ToggleArmor.isOn = false
		self.ToggleAccessories.isOn = false
		self.ToggleShoesr.isOn = false
		self.ToggleFashion.isOn = false
	elseif self.FinishFiltrate == "防具" then
		self.ToggleAll.isOn = false
		self.ToggleWeapon.isOn = false
		self.ToggleArmor.isOn = true
		self.ToggleAccessories.isOn = false
		self.ToggleShoesr.isOn = false
		self.ToggleFashion.isOn = false
	elseif self.FinishFiltrate == "饰品" then
		self.ToggleAll.isOn = false
		self.ToggleWeapon.isOn = false
		self.ToggleArmor.isOn = false
		self.ToggleAccessories.isOn = true
		self.ToggleShoesr.isOn = false
		self.ToggleFashion.isOn = false
	elseif self.FinishFiltrate == "鞋子" then
		self.ToggleAll.isOn = false
		self.ToggleWeapon.isOn = false
		self.ToggleArmor.isOn = false
		self.ToggleAccessories.isOn = false
		self.ToggleShoesr.isOn = true
		self.ToggleFashion.isOn = false
	elseif self.FinishFiltrate == "时装" then
		self.ToggleAll.isOn = false
		self.ToggleWeapon.isOn = false
		self.ToggleArmor.isOn = false
		self.ToggleAccessories.isOn = false
		self.ToggleShoesr.isOn = false
		self.ToggleFashion.isOn = true
	end
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function BackpackFilterCls:OnBackpackFilterRetrunButtonClicked()
	--BackpackFilterRetrunButton控件的点击事件处理

	self:Hide()
	-- self:Close()
end

function BackpackFilterCls:OnCloseButtonClicked()
    self:Close()
end

function BackpackFilterCls:OnBackpackFilterQueDingButtonClicked()
	--BackpackFilterQueDingButton控件的点击事件处理
	local eventMgr = self.myGame:GetEventManager()    --注册事件
  	eventMgr:PostNotification('ChangeCurrentFilter', nil, self.CurrentFiltrate)
  	self.FinishFiltrate = self.CurrentFiltrate
	self:Hide()
end

function BackpackFilterCls:OnToggleAllValueChanged(isToggle)
	--ToggleAll控件的点击事件处理
	self.CurrentFiltrate = "全部"
end

function BackpackFilterCls:OnToggleWeaponValueChanged(isToggle)
	--ToggleWeapon控件的点击事件处理
	self.CurrentFiltrate = "武器"
end

function BackpackFilterCls:OnToggleArmorValueChanged(isToggle)
	--ToggleArmor控件的点击事件处理
	self.CurrentFiltrate = "防具"
end

function BackpackFilterCls:OnToggleAccessoriesValueChanged(isToggle)
	--ToggleAccessories控件的点击事件处理
	self.CurrentFiltrate = "饰品"
end

function BackpackFilterCls:OnToggleShoesrValueChanged(isToggle)
	--ToggleShoesr控件的点击事件处理
	self.CurrentFiltrate = "鞋子"
end

function BackpackFilterCls:OnToggleFashionValueChanged(isToggle)
	--ToggleFashion控件的点击事件处理
	self.CurrentFiltrate = "时装"
end
return BackpackFilterCls

