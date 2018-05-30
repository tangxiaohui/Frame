local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local EquipData = require "StaticData.Equip"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local BackpackEquipmentInformationCls = Class(BaseNodeClass)

function BackpackEquipmentInformationCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function BackpackEquipmentInformationCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/BackpackEquipmentInformation', function(go)
		self:BindComponent(go)
	end)
end
function BackpackEquipmentInformationCls:OnWillShow(ItemType,EquipID)   -- ItemType : string ，，，，EquipID ：装备ID
	self.ItemType = ItemType
end

function BackpackEquipmentInformationCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function BackpackEquipmentInformationCls:OnResume()
	-- 界面显示时调用
	BackpackEquipmentInformationCls.base.OnResume(self)
	self:GetUnityTransform():SetAsLastSibling()
	self:RegisterControlEvents()
--	self:RegisterNetworkEvents()
end

function BackpackEquipmentInformationCls:OnPause()
	-- 界面隐藏时调用
	BackpackEquipmentInformationCls.base.OnPause(self)
	self:UnregisterControlEvents()
--	self:UnregisterNetworkEvents()
end

function BackpackEquipmentInformationCls:OnEnter()
	-- Node Enter时调用
	BackpackEquipmentInformationCls.base.OnEnter(self)
end

function BackpackEquipmentInformationCls:OnExit()
	-- Node Exit时调用
	BackpackEquipmentInformationCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function BackpackEquipmentInformationCls:InitControls()
	local transform = self:GetUnityTransform()
	self.BackpackEquipmentInformationRetrunButton = transform:Find('BackpackEquipmentInformationRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))--返回按钮

	self.Type = transform:Find('Attributes/Type'):GetComponent(typeof(UnityEngine.UI.Image)) -- 装备类型
	self.BackpackEquipmentInformationTypeLabel = transform:Find('Attributes/Type/BackpackEquipmentInformationTypeLabel'):GetComponent(typeof(UnityEngine.UI.Text))--装备类型文字
	self.BackpackEquipmentInformationLvNumLabel = transform:Find('Attributes/Lv/BackpackEquipmentInformationLvNumLabel'):GetComponent(typeof(UnityEngine.UI.Text)) --装备等级文字
	self.BackpackEquipmentInformationBinLabel = transform:Find('Attributes/Bin/BackpackEquipmentInformationBinLabel'):GetComponent(typeof(UnityEngine.UI.Text)) -- 绑定

	--属性
	self.BackpackEquipmentInformationDescriptionLabel = transform:Find('Attributes/Description/BackpackEquipmentInformationDescriptionLabel'):GetComponent(typeof(UnityEngine.UI.Text))--装备说明
	self.BackpackEquipmentInformationAttributesLabel1 = transform:Find('Attributes/AttributesLayout/BackpackEquipmentInformationAttributes/BackpackEquipmentInformationAttributesLabel1'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BackpackEquipmentInformationAttributesLabel2 = transform:Find('Attributes/AttributesLayout/BackpackEquipmentInformationAttributes (1)/BackpackEquipmentInformationAttributesLabel2'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BackpackEquipmentInformationAttributesLabel3 = transform:Find('Attributes/AttributesLayout/BackpackEquipmentInformationAttributes (2)/BackpackEquipmentInformationAttributesLabel3'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BackpackEquipmentInformationAttributesLabel4 = transform:Find('Attributes/AttributesLayout/BackpackEquipmentInformationAttributes (3)/BackpackEquipmentInformationAttributesLabel4'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BackpackEquipmentInformationAttributesLabel5 = transform:Find('Attributes/AttributesLayout/BackpackEquipmentInformationAttributes (4)/BackpackEquipmentInformationAttributesLabel5'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BackpackEquipmentInformationAttributesLabel6 = transform:Find('Attributes/AttributesLayout/BackpackEquipmentInformationAttributes (5)/BackpackEquipmentInformationAttributesLabel6'):GetComponent(typeof(UnityEngine.UI.Text))
	

	self.SetShowLayout = transform:Find('SetProperty1/SetShowLayout'):GetComponent(typeof(UnityEngine.UI.Image)) --套装图片（GridLayoutGrop）
	self.Base2 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow/Base2'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationSetIcon1 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow/BackpackEquipmentInformationSetIcon1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationSetExamineButton1 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow/BackpackEquipmentInformationSetExamineButton1'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BackpackEquipmentInformationColor011 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow/FrameColor1/BackpackEquipmentInformationColor011'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationColor021 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow/FrameColor1/BackpackEquipmentInformationColor021'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationColor031 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow/FrameColor1/BackpackEquipmentInformationColor031'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationColor041 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow/FrameColor1/BackpackEquipmentInformationColor041'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Base3 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow (1)/Base3'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationSetIcon2 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow (1)/BackpackEquipmentInformationSetIcon2'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationSetExamineButton2 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow (1)/BackpackEquipmentInformationSetExamineButton2'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BackpackEquipmentInformationColor012 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow (1)/FrameColor2/BackpackEquipmentInformationColor012'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationColor022 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow (1)/FrameColor2/BackpackEquipmentInformationColor022'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationColor032 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow (1)/FrameColor2/BackpackEquipmentInformationColor032'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationColor042 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow (1)/FrameColor2/BackpackEquipmentInformationColor042'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Base4 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow (2)/Base4'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationSetIcon3 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow (2)/BackpackEquipmentInformationSetIcon3'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationSetExamineButton3 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow (2)/BackpackEquipmentInformationSetExamineButton3'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BackpackEquipmentInformationColor013 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow (2)/FrameColor3/BackpackEquipmentInformationColor013'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationColor023 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow (2)/FrameColor3/BackpackEquipmentInformationColor023'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationColor033 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow (2)/FrameColor3/BackpackEquipmentInformationColor033'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationColor043 = transform:Find('SetProperty1/SetShowLayout/BackpackEquipmentInformationSetShow (2)/FrameColor3/BackpackEquipmentInformationColor043'):GetComponent(typeof(UnityEngine.UI.Image))
	self.TitleText = transform:Find('SetProperty1/TitleText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Base5 = transform:Find('SetProperty1/SetAttributes/Base5'):GetComponent(typeof(UnityEngine.UI.Image))
	self.SetNameLabel = transform:Find('SetProperty1/SetAttributes/SetNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BackpackEquipmentInformationSetTitileLabel1 = transform:Find('SetProperty1/SetAttributes/Layout/SetProperty2/BackpackEquipmentInformationSetTitileLabel1'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BackpackEquipmentInformationSetAttributesLabel011 = transform:Find('SetProperty1/SetAttributes/Layout/SetProperty2/BackpackEquipmentInformationSetAttributesLabel011'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BackpackEquipmentInformationSetAttributesLabel012 = transform:Find('SetProperty1/SetAttributes/Layout/SetProperty2/BackpackEquipmentInformationSetAttributesLabel012'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BackpackEquipmentInformationSetTitileLabel2 = transform:Find('SetProperty1/SetAttributes/Layout/SetProperty (1)/BackpackEquipmentInformationSetTitileLabel2'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BackpackEquipmentInformationSetAttributesLabel013 = transform:Find('SetProperty1/SetAttributes/Layout/SetProperty (1)/BackpackEquipmentInformationSetAttributesLabel013'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BackpackEquipmentInformationSetAttributesLabel014 = transform:Find('SetProperty1/SetAttributes/Layout/SetProperty (1)/BackpackEquipmentInformationSetAttributesLabel014'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BackpackEquipmentInformationSetTitileLabel3 = transform:Find('SetProperty1/SetAttributes/Layout/SetProperty (2)/BackpackEquipmentInformationSetTitileLabel3'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BackpackEquipmentInformationSetAttributesLabel015 = transform:Find('SetProperty1/SetAttributes/Layout/SetProperty (2)/BackpackEquipmentInformationSetAttributesLabel015'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BackpackEquipmentInformationSetAttributesLabel016 = transform:Find('SetProperty1/SetAttributes/Layout/SetProperty (2)/BackpackEquipmentInformationSetAttributesLabel016'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Base6 = transform:Find('Show/Base6'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationIcon = transform:Find('Show/BackpackEquipmentInformationIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationColor014 = transform:Find('Show/FrameColor4/BackpackEquipmentInformationColor014'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationColor024 = transform:Find('Show/FrameColor4/BackpackEquipmentInformationColor024'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationColor034 = transform:Find('Show/FrameColor4/BackpackEquipmentInformationColor034'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationColor044 = transform:Find('Show/FrameColor4/BackpackEquipmentInformationColor044'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Base7 = transform:Find('Name/Base7'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationNameLabel = transform:Find('Name/BackpackEquipmentInformationNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.StarImage = transform:Find('Star/StarImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.StarImage__1_ = transform:Find('Star/StarImage (1)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.StarImage__2_ = transform:Find('Star/StarImage (2)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.StarImage__3_ = transform:Find('Star/StarImage (3)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.StarImage__4_ = transform:Find('Star/StarImage (4)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackEquipmentInformationWhereButton = transform:Find('BackpackEquipmentInformationWhereButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BackpackEquipmentInformationCancelButton = transform:Find('ButtonLayout/BackpackEquipmentInformationCancelButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BackpackEquipmentInformationWearButton = transform:Find('ButtonLayout/BackpackEquipmentInformationWearButton'):GetComponent(typeof(UnityEngine.UI.Button))
end


function BackpackEquipmentInformationCls:RegisterControlEvents()
	-- 注册 BackpackEquipmentInformationRetrunButton 的事件
	self.__event_button_onBackpackEquipmentInformationRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackEquipmentInformationRetrunButtonClicked, self)
	self.BackpackEquipmentInformationRetrunButton.onClick:AddListener(self.__event_button_onBackpackEquipmentInformationRetrunButtonClicked__)

	-- 注册 BackpackEquipmentInformationSetExamineButton1 的事件
	self.__event_button_onBackpackEquipmentInformationSetExamineButton1Clicked__ = UnityEngine.Events.UnityAction(self.OnBackpackEquipmentInformationSetExamineButton1Clicked, self)
	self.BackpackEquipmentInformationSetExamineButton1.onClick:AddListener(self.__event_button_onBackpackEquipmentInformationSetExamineButton1Clicked__)

	-- 注册 BackpackEquipmentInformationSetExamineButton2 的事件
	self.__event_button_onBackpackEquipmentInformationSetExamineButton2Clicked__ = UnityEngine.Events.UnityAction(self.OnBackpackEquipmentInformationSetExamineButton2Clicked, self)
	self.BackpackEquipmentInformationSetExamineButton2.onClick:AddListener(self.__event_button_onBackpackEquipmentInformationSetExamineButton2Clicked__)

	-- 注册 BackpackEquipmentInformationSetExamineButton3 的事件
	self.__event_button_onBackpackEquipmentInformationSetExamineButton3Clicked__ = UnityEngine.Events.UnityAction(self.OnBackpackEquipmentInformationSetExamineButton3Clicked, self)
	self.BackpackEquipmentInformationSetExamineButton3.onClick:AddListener(self.__event_button_onBackpackEquipmentInformationSetExamineButton3Clicked__)

	-- 注册 BackpackEquipmentInformationWhereButton 的事件
	self.__event_button_onBackpackEquipmentInformationWhereButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackEquipmentInformationWhereButtonClicked, self)
	self.BackpackEquipmentInformationWhereButton.onClick:AddListener(self.__event_button_onBackpackEquipmentInformationWhereButtonClicked__)

	-- 注册 BackpackEquipmentInformationCancelButton 的事件
	self.__event_button_onBackpackEquipmentInformationCancelButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackEquipmentInformationCancelButtonClicked, self)
	self.BackpackEquipmentInformationCancelButton.onClick:AddListener(self.__event_button_onBackpackEquipmentInformationCancelButtonClicked__)

	-- 注册 BackpackEquipmentInformationWearButton 的事件
	self.__event_button_onBackpackEquipmentInformationWearButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackEquipmentInformationWearButtonClicked, self)
	self.BackpackEquipmentInformationWearButton.onClick:AddListener(self.__event_button_onBackpackEquipmentInformationWearButtonClicked__)
end

function BackpackEquipmentInformationCls:UnregisterControlEvents()
	-- 取消注册 BackpackEquipmentInformationRetrunButton 的事件
	if self.__event_button_onBackpackEquipmentInformationRetrunButtonClicked__ then
		self.BackpackEquipmentInformationRetrunButton.onClick:RemoveListener(self.__event_button_onBackpackEquipmentInformationRetrunButtonClicked__)
		self.__event_button_onBackpackEquipmentInformationRetrunButtonClicked__ = nil
	end

	-- 取消注册 BackpackEquipmentInformationSetExamineButton1 的事件
	if self.__event_button_onBackpackEquipmentInformationSetExamineButton1Clicked__ then
		self.BackpackEquipmentInformationSetExamineButton1.onClick:RemoveListener(self.__event_button_onBackpackEquipmentInformationSetExamineButton1Clicked__)
		self.__event_button_onBackpackEquipmentInformationSetExamineButton1Clicked__ = nil
	end

	-- 取消注册 BackpackEquipmentInformationSetExamineButton2 的事件
	if self.__event_button_onBackpackEquipmentInformationSetExamineButton2Clicked__ then
		self.BackpackEquipmentInformationSetExamineButton2.onClick:RemoveListener(self.__event_button_onBackpackEquipmentInformationSetExamineButton2Clicked__)
		self.__event_button_onBackpackEquipmentInformationSetExamineButton2Clicked__ = nil
	end

	-- 取消注册 BackpackEquipmentInformationSetExamineButton3 的事件
	if self.__event_button_onBackpackEquipmentInformationSetExamineButton3Clicked__ then
		self.BackpackEquipmentInformationSetExamineButton3.onClick:RemoveListener(self.__event_button_onBackpackEquipmentInformationSetExamineButton3Clicked__)
		self.__event_button_onBackpackEquipmentInformationSetExamineButton3Clicked__ = nil
	end

	-- 取消注册 BackpackEquipmentInformationWhereButton 的事件
	if self.__event_button_onBackpackEquipmentInformationWhereButtonClicked__ then
		self.BackpackEquipmentInformationWhereButton.onClick:RemoveListener(self.__event_button_onBackpackEquipmentInformationWhereButtonClicked__)
		self.__event_button_onBackpackEquipmentInformationWhereButtonClicked__ = nil
	end

	-- 取消注册 BackpackEquipmentInformationCancelButton 的事件
	if self.__event_button_onBackpackEquipmentInformationCancelButtonClicked__ then
		self.BackpackEquipmentInformationCancelButton.onClick:RemoveListener(self.__event_button_onBackpackEquipmentInformationCancelButtonClicked__)
		self.__event_button_onBackpackEquipmentInformationCancelButtonClicked__ = nil
	end

	-- 取消注册 BackpackEquipmentInformationWearButton 的事件
	if self.__event_button_onBackpackEquipmentInformationWearButtonClicked__ then
		self.BackpackEquipmentInformationWearButton.onClick:RemoveListener(self.__event_button_onBackpackEquipmentInformationWearButtonClicked__)
		self.__event_button_onBackpackEquipmentInformationWearButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function BackpackEquipmentInformationCls:OnBackpackEquipmentInformationRetrunButtonClicked()
	--BackpackEquipmentInformationRetrunButton控件的点击事件处理
	self:Hide()
end

function BackpackEquipmentInformationCls:OnBackpackEquipmentInformationSetExamineButton1Clicked()
	--BackpackEquipmentInformationSetExamineButton1控件的点击事件处理
end

function BackpackEquipmentInformationCls:OnBackpackEquipmentInformationSetExamineButton2Clicked()
	--BackpackEquipmentInformationSetExamineButton2控件的点击事件处理
end

function BackpackEquipmentInformationCls:OnBackpackEquipmentInformationSetExamineButton3Clicked()
	--BackpackEquipmentInformationSetExamineButton3控件的点击事件处理
end

function BackpackEquipmentInformationCls:OnBackpackEquipmentInformationWhereButtonClicked()
	--BackpackEquipmentInformationWhereButton控件的点击事件处理
end

function BackpackEquipmentInformationCls:OnBackpackEquipmentInformationCancelButtonClicked()
	--BackpackEquipmentInformationCancelButton控件的点击事件处理
end

function BackpackEquipmentInformationCls:OnBackpackEquipmentInformationWearButtonClicked()
	--BackpackEquipmentInformationWearButton控件的点击事件处理
end
return BackpackEquipmentInformationCls
