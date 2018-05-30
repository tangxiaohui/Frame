local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
require "System.LuaDelegate"
require "Const"
--local net = require "Network.Net"
--local messageManager = require "Network.MessageManager"
local KnapsackFilterCls = Class(BaseNodeClass)
windowUtility.SetMutex(KnapsackFilterCls, true)

function KnapsackFilterCls:Ctor()
	self.callback = LuaDelegate.New()
end

function KnapsackFilterCls:OnWillShow(currFilterType,ctable,func)
	self.currFilterType = currFilterType
	self:SetCallback(ctable,func)
	
end

function KnapsackFilterCls:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function KnapsackFilterCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/BackpackFilter', function(go)
		self:BindComponent(go)
	end)
end

function KnapsackFilterCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function KnapsackFilterCls:OnResume()
	-- 界面显示时调用
	KnapsackFilterCls.base.OnResume(self)
	self:RegisterControlEvents()

	self:InitPanelOn(self.currFilterType)

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function KnapsackFilterCls:OnPause()
	-- 界面隐藏时调用
	KnapsackFilterCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function KnapsackFilterCls:OnEnter()
	-- Node Enter时调用
	KnapsackFilterCls.base.OnEnter(self)
end

function KnapsackFilterCls:OnExit()
	-- Node Exit时调用
	KnapsackFilterCls.base.OnExit(self)
end

function KnapsackFilterCls:IsTransition()
    return false
end

function KnapsackFilterCls:OnExitTransitionDidStart(immediately)
	KnapsackFilterCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function KnapsackFilterCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function KnapsackFilterCls:InitControls()
	local transform = self:GetUnityTransform()
	
	self.tweenObjectTrans = transform:Find('Base')
	self.ReturnButton = transform:Find('Base/ReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- 确定按钮
	self.BackpackFilterQueDingButton = transform:Find('Base/BackpackFilterQueDingButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- all toggle
	self.OptionAll = transform:Find('Base/OptionLayout/OptionAll'):GetComponent(typeof(UnityEngine.UI.Toggle))

	-- OptionWeapon 武器
	self.OptionWeapon = transform:Find('Base/OptionLayout/OptionWeapon'):GetComponent(typeof(UnityEngine.UI.Toggle))

	-- OptionArmor  防具
	self.OptionArmor = transform:Find('Base/OptionLayout/OptionArmor'):GetComponent(typeof(UnityEngine.UI.Toggle))

	-- OptionAccessories  饰品
	self.OptionAccessories = transform:Find('Base/OptionLayout/OptionAccessories'):GetComponent(typeof(UnityEngine.UI.Toggle))

	-- OptionShoesr  鞋子
	self.OptionShoesr = transform:Find('Base/OptionLayout/OptionShoesr'):GetComponent(typeof(UnityEngine.UI.Toggle))

	-- OptionFashion  时装
	self.OptionFashion = transform:Find('Base/OptionLayout/OptionFashion'):GetComponent(typeof(UnityEngine.UI.Toggle))

	-- 晶石
	self.OptionSpar = transform:Find('Base/OptionLayout/OptionSpar'):GetComponent(typeof(UnityEngine.UI.Toggle))

	-- 绑定
	self.OptionBind = transform:Find('Base/OptionLayout/OptionBind'):GetComponent(typeof(UnityEngine.UI.Toggle))

	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self.myGame = utility:GetGame()
end


function KnapsackFilterCls:RegisterControlEvents()
	
	self.__event_button_onReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked, self)
	self.ReturnButton.onClick:AddListener(self.__event_button_onReturnButtonClicked__)

	--BackpackFilterQueDingButton 确定按钮
	self.__event_button_onBackpackFilterQueDingButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackFilterQueDingButtonClicked, self)
	self.BackpackFilterQueDingButton.onClick:AddListener(self.__event_button_onBackpackFilterQueDingButtonClicked__)
	
	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	-- all toggle
	self.__event_toggle_onOptionAllToggleValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnOptionAllToggleValueChanged, self)
	self.OptionAll.onValueChanged:AddListener(self.__event_toggle_onOptionAllToggleValueChanged__)

	-- OptionWeapon toggle
	self.__event_toggle_onOptionWeaponToggleValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnOptionWeaponToggleValueChanged, self)
	self.OptionWeapon.onValueChanged:AddListener(self.__event_toggle_onOptionWeaponToggleValueChanged__)

	-- OptionArmor toggle
	self.__event_toggle_onOptionArmorToggleValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnOptionArmorToggleValueChanged, self)
	self.OptionArmor.onValueChanged:AddListener(self.__event_toggle_onOptionArmorToggleValueChanged__)

	-- OptionAccessories toggle
	self.__event_toggle_onOptionAccessoriesToggleValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnOptionAccessoriesToggleValueChanged, self)
	self.OptionAccessories.onValueChanged:AddListener(self.__event_toggle_onOptionAccessoriesToggleValueChanged__)

	-- OptionShoesr toggle
	self.__event_toggle_onOptionShoesrToggleValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnOptionShoesrToggleValueChanged, self)
	self.OptionShoesr.onValueChanged:AddListener(self.__event_toggle_onOptionShoesrToggleValueChanged__)

	-- OptionFashion toggle
	self.__event_toggle_onOptionFashionToggleValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnOptionFashionToggleValueChanged, self)
	self.OptionFashion.onValueChanged:AddListener(self.__event_toggle_onOptionFashionToggleValueChanged__)

	--  晶石
	self.__event_toggle_onOptionSparToggleValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnOptionSparToggleValueChanged, self)
	self.OptionSpar.onValueChanged:AddListener(self.__event_toggle_onOptionSparToggleValueChanged__)

	--  绑定
	self.__event_toggle_onOptionBindToggleValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnOptionBindToggleValueChanged, self)
	self.OptionBind.onValueChanged:AddListener(self.__event_toggle_onOptionBindToggleValueChanged__)



	
end

function KnapsackFilterCls:UnregisterControlEvents()

	if self.__event_button_onReturnButtonClicked__ then
		self.ReturnButton.onClick:RemoveListener(self.__event_button_onReturnButtonClicked__)
		self.__event_button_onReturnButtonClicked__ = nil
	end

	-- 确定按钮
	if self.__event_button_onBackpackFilterQueDingButtonClicked__ then
		self.BackpackFilterQueDingButton.onClick:RemoveListener(self.__event_button_onBackpackFilterQueDingButtonClicked__)
		self.__event_button_onBackpackFilterQueDingButtonClicked__ = nil
	end

	-- all toggle
	if self.__event_toggle_onOptionAllToggleValueChanged__ then
		self.OptionAll.onValueChanged:RemoveListener(self.__event_toggle_onOptionAllToggleValueChanged__)
		self.__event_toggle_onOptionAllToggleValueChanged__ = nil
	end

	-- OptionWeapon toggle
	if self.__event_toggle_onOptionWeaponToggleValueChanged__ then
		self.OptionWeapon.onValueChanged:RemoveListener(self.__event_toggle_onOptionWeaponToggleValueChanged__)
		self.__event_toggle_onOptionWeaponToggleValueChanged__ = nil
	end

	-- OptionArmor toggle
	if self.__event_toggle_onOptionAccessoriesToggleValueChanged__ then
		self.OptionAccessories.onValueChanged:RemoveListener(self.__event_toggle_onOptionAccessoriesToggleValueChanged__)
		self.__event_toggle_onOptionAccessoriesToggleValueChanged__ = nil
	end

	-- OptionAccessories toggle
	if self.__event_toggle_onOptionAccessoriesToggleValueChanged__ then
		self.OptionAccessories.onValueChanged:RemoveListener(self.__event_toggle_onOptionAccessoriesToggleValueChanged__)
		self.__event_toggle_onOptionAccessoriesToggleValueChanged__ = nil
	end

	-- OptionShoesr toggle
	if self.__event_toggle_onOptionShoesrToggleValueChanged__ then
		self.OptionShoesr.onValueChanged:RemoveListener(self.__event_toggle_onOptionShoesrToggleValueChanged__)
		self.__event_toggle_onOptionShoesrToggleValueChanged__ = nil
	end

	-- OptionFashion toggle
	if self.__event_toggle_onOptionFashionToggleValueChanged__ then
		self.OptionFashion.onValueChanged:RemoveListener(self.__event_toggle_onOptionFashionToggleValueChanged__)
		self.__event_toggle_onOptionFashionToggleValueChanged__ = nil
	end

	-- 晶石 toggle
	if self.__event_toggle_onOptionSparToggleValueChanged__ then
		self.OptionSpar.onValueChanged:RemoveListener(self.__event_toggle_onOptionSparToggleValueChanged__)
		self.__event_toggle_onOptionSparToggleValueChanged__ = nil
	end

	-- 绑定 toggle
	if self.__event_toggle_onOptionBindToggleValueChanged__ then
		self.OptionBind.onValueChanged:RemoveListener(self.__event_toggle_onOptionBindToggleValueChanged__)
		self.__event_toggle_onOptionBindToggleValueChanged__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end


function KnapsackFilterCls:OnOptionAllToggleValueChanged()
	if self.OptionAll.isOn then 
		self.currFilterType = KEquipType_EquipAll
	end
end

function KnapsackFilterCls:OnOptionWeaponToggleValueChanged()
	if self.OptionWeapon.isOn then 
		self.currFilterType = KEquipType_EquipWeapon
	end
end

function KnapsackFilterCls:OnOptionArmorToggleValueChanged()
	if self.OptionArmor.isOn then 
		self.currFilterType = KEquipType_EquipArmor
	end
end

function KnapsackFilterCls:OnOptionAccessoriesToggleValueChanged()
	if self.OptionAccessories.isOn then 
		self.currFilterType = KEquipType_EquipAccessories
	end
end

function KnapsackFilterCls:OnOptionShoesrToggleValueChanged()
	if self.OptionShoesr.isOn then 
		self.currFilterType = KEquipType_EquipShoesr
	end
end

function KnapsackFilterCls:OnOptionFashionToggleValueChanged()

	if self.OptionFashion.isOn then 
		self.currFilterType = KEquipType_EquipFashion
	end
end

function KnapsackFilterCls:OnOptionSparToggleValueChanged()

	if self.OptionSpar.isOn then 
		self.currFilterType = KEquipType_EquipSpar
	end
end

function KnapsackFilterCls:OnOptionBindToggleValueChanged()

	if self.OptionBind.isOn then 
		self.currFilterType = KEquipType_EquipBind
	end
end




function KnapsackFilterCls:OnBackpackFilterQueDingButtonClicked()
	self.callback:Invoke(self.currFilterType)
	self:Close()
end

function KnapsackFilterCls:InitPanelOn(itype)
	-- 初始化选择绑定
	if itype == KEquipType_EquipAll then
		self.OptionAll.isOn = true
	elseif itype == KEquipType_EquipWeapon then
		self.OptionWeapon.isOn = true
	elseif itype == KEquipType_EquipArmor then
		self.OptionArmor.isOn = true
	elseif itype == KEquipType_EquipAccessories then
		self.OptionAccessories.isOn = true
	elseif itype == KEquipType_EquipFashion then
		self.OptionFashion.isOn = true
	elseif itype == KEquipType_EquipSpar then
		self.OptionSpar.isOn = true
	elseif itype == KEquipType_EquipBind then
		self.OptionBind.isOn = true
	end
end

function KnapsackFilterCls:OnReturnButtonClicked()
	self:Close()
end


return KnapsackFilterCls