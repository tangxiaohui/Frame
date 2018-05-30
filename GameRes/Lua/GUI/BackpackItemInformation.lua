local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local BackpackItemInformationCls = Class(BaseNodeClass)

function BackpackItemInformationCls:Ctor()
end
function BackpackItemInformationCls:OnWillShow(msg)
	print(msg)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function BackpackItemInformationCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/BackpackItemInformation', function(go)
		self:BindComponent(go)
	end)
end

function BackpackItemInformationCls:OnWillShow(asd)
	print("哈哈")
end

function BackpackItemInformationCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function BackpackItemInformationCls:OnResume()
	-- 界面显示时调用
	BackpackItemInformationCls.base.OnResume(self)
	self:RegisterControlEvents()
--	self:RegisterNetworkEvents()
end

function BackpackItemInformationCls:OnPause()
	-- 界面隐藏时调用
	BackpackItemInformationCls.base.OnPause(self)
	self:UnregisterControlEvents()
--	self:UnregisterNetworkEvents()
end

function BackpackItemInformationCls:OnEnter()
	-- Node Enter时调用
	BackpackItemInformationCls.base.OnEnter(self)
end

function BackpackItemInformationCls:OnExit()
	-- Node Exit时调用
	BackpackItemInformationCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function BackpackItemInformationCls:InitControls()
	local transform = self:GetUnityTransform()
	self.TranslucentLayer = transform:Find('SmallWindowBase/TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BigFarme = transform:Find('SmallWindowBase/BigFarme'):GetComponent(typeof(UnityEngine.UI.Image))
	self.UpperBorder = transform:Find('SmallWindowBase/UpperBorder'):GetComponent(typeof(UnityEngine.UI.Image))
	self.GrayFarme = transform:Find('SmallWindowBase/GrayFarme'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BlackTitleBase = transform:Find('SmallWindowBase/BlackTitleBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Title = transform:Find('SmallWindowBase/Title'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BlackLine = transform:Find('BlackLine'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackItemInformationIcon = transform:Find('BackpackItemInformationIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackItemInformationFrameColor01 = transform:Find('FrameColor/BackpackItemInformationFrameColor01'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackItemInformationFrameColor02 = transform:Find('FrameColor/BackpackItemInformationFrameColor02'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackItemInformationFrameColor03 = transform:Find('FrameColor/BackpackItemInformationFrameColor03'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackItemInformationFrameColor04 = transform:Find('FrameColor/BackpackItemInformationFrameColor04'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BackpackItemInformationDescriptionLabel = transform:Find('BackpackItemInformationDescriptionLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BackpackItemInformationNameLabel = transform:Find('BackpackItemInformationNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BackpackItemInformationNumLabel = transform:Find('BackpackItemInformationNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BackpackItemInformationRetrunButton = transform:Find('BackpackItemInformationRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BackpackItemInformationCancelButton = transform:Find('ButtonLayout/BackpackItemInformationCancelButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BackpackItemInformationUseButton = transform:Find('ButtonLayout/BackpackItemInformationUseButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BackpackItemInformationWhereButton = transform:Find('BackpackItemInformationWhereButton'):GetComponent(typeof(UnityEngine.UI.Button))
end


function BackpackItemInformationCls:RegisterControlEvents()
	-- 注册 BackpackItemInformationRetrunButton 的事件
	self.__event_button_onBackpackItemInformationRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackItemInformationRetrunButtonClicked, self)
	self.BackpackItemInformationRetrunButton.onClick:AddListener(self.__event_button_onBackpackItemInformationRetrunButtonClicked__)

	-- 注册 BackpackItemInformationCancelButton 的事件
	self.__event_button_onBackpackItemInformationCancelButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackItemInformationCancelButtonClicked, self)
	self.BackpackItemInformationCancelButton.onClick:AddListener(self.__event_button_onBackpackItemInformationCancelButtonClicked__)

	-- 注册 BackpackItemInformationUseButton 的事件
	self.__event_button_onBackpackItemInformationUseButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackItemInformationUseButtonClicked, self)
	self.BackpackItemInformationUseButton.onClick:AddListener(self.__event_button_onBackpackItemInformationUseButtonClicked__)

	-- 注册 BackpackItemInformationWhereButton 的事件
	self.__event_button_onBackpackItemInformationWhereButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackItemInformationWhereButtonClicked, self)
	self.BackpackItemInformationWhereButton.onClick:AddListener(self.__event_button_onBackpackItemInformationWhereButtonClicked__)
end

function BackpackItemInformationCls:UnregisterControlEvents()
	-- 取消注册 BackpackItemInformationRetrunButton 的事件
	if self.__event_button_onBackpackItemInformationRetrunButtonClicked__ then
		self.BackpackItemInformationRetrunButton.onClick:RemoveListener(self.__event_button_onBackpackItemInformationRetrunButtonClicked__)
		self.__event_button_onBackpackItemInformationRetrunButtonClicked__ = nil
	end

	-- 取消注册 BackpackItemInformationCancelButton 的事件
	if self.__event_button_onBackpackItemInformationCancelButtonClicked__ then
		self.BackpackItemInformationCancelButton.onClick:RemoveListener(self.__event_button_onBackpackItemInformationCancelButtonClicked__)
		self.__event_button_onBackpackItemInformationCancelButtonClicked__ = nil
	end

	-- 取消注册 BackpackItemInformationUseButton 的事件
	if self.__event_button_onBackpackItemInformationUseButtonClicked__ then
		self.BackpackItemInformationUseButton.onClick:RemoveListener(self.__event_button_onBackpackItemInformationUseButtonClicked__)
		self.__event_button_onBackpackItemInformationUseButtonClicked__ = nil
	end

	-- 取消注册 BackpackItemInformationWhereButton 的事件
	if self.__event_button_onBackpackItemInformationWhereButtonClicked__ then
		self.BackpackItemInformationWhereButton.onClick:RemoveListener(self.__event_button_onBackpackItemInformationWhereButtonClicked__)
		self.__event_button_onBackpackItemInformationWhereButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function BackpackItemInformationCls:OnBackpackItemInformationRetrunButtonClicked()
	--BackpackItemInformationRetrunButton控件的点击事件处理
	self:Hide()
end

function BackpackItemInformationCls:OnBackpackItemInformationCancelButtonClicked()
	--BackpackItemInformationCancelButton控件的点击事件处理
end

function BackpackItemInformationCls:OnBackpackItemInformationUseButtonClicked()
	--BackpackItemInformationUseButton控件的点击事件处理
end

function BackpackItemInformationCls:OnBackpackItemInformationWhereButtonClicked()
	--BackpackItemInformationWhereButton控件的点击事件处理
end
return BackpackItemInformationCls
