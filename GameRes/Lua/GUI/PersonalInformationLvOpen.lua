local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local PersonalInformationLvOpenCls = Class(BaseNodeClass)

function PersonalInformationLvOpenCls:Ctor()
	print('修改名字OnCtor')
end

function PersonalInformationLvOpenCls:OnWillShow(func, table)
	self.func = func
	self.table = table

	--self.func(self.table)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function PersonalInformationLvOpenCls:OnInit()
	print('修改名字OnInit')
end

function PersonalInformationLvOpenCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	print('修改名字OnComponentReady')
end

function PersonalInformationLvOpenCls:OnResume()
	-- 界面显示时调用
	PersonalInformationLvOpenCls.base.OnResume(self)
	self:RegisterControlEvents()
	--self:RegisterNetworkEvents()
	print('修改名字OnResume')
end

function PersonalInformationLvOpenCls:OnPause()
	-- 界面隐藏时调用
	PersonalInformationLvOpenCls.base.OnPause(self)
	self:UnregisterControlEvents()
	--self:UnregisterNetworkEvents()
print('修改名字OnPause')
end

function PersonalInformationLvOpenCls:OnEnter()
	-- Node Enter时调用
	PersonalInformationLvOpenCls.base.OnEnter(self)
	print('修改名字OnEnter')
end

function PersonalInformationLvOpenCls:OnExit()
	-- Node Exit时调用
	PersonalInformationLvOpenCls.base.OnExit(self)
	print('修改名字OnExit')	
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function PersonalInformationLvOpenCls:InitControls()
	local transform = self:GetUnityTransform()
	self.PersonalInformationLvOpenImage = transform:Find('PersonalInformationLvOpenImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.PersonalInformationLvOpenLabel = transform:Find('PersonalInformationLvOpenLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.PersonalInformationReturn = transform:Find('Button'):GetComponent(typeof(UnityEngine.UI.Button))
end


function PersonalInformationLvOpenCls:RegisterControlEvents()
	self.__event_button_onPersonalInformationRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnPersonalInformationRetrunButtonClicked, self)
	self.PersonalInformationReturn.onClick:AddListener(self.__event_button_onPersonalInformationRetrunButtonClicked__)
end

function PersonalInformationLvOpenCls:UnregisterControlEvents()
	self.__event_button_onPersonalInformationRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnPersonalInformationRetrunButtonClicked, self)
	self.PersonalInformationReturn.onClick:RemoveListener(self.__event_button_onPersonalInformationRetrunButtonClicked__)
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function PersonalInformationLvOpenCls:OnPersonalInformationRetrunButtonClicked()
	self:Close()
end
return PersonalInformationLvOpenCls