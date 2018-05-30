local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local WeituoHeroPanelCls = Class(BaseNodeClass)

function WeituoHeroPanelCls:Ctor(parent)
	self.parent=parent
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function WeituoHeroPanelCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/WeituoHeroPanel', function(go)
		self:BindComponent(go,false)
	end)
end

function WeituoHeroPanelCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LinkComponent(self.parent, true)
	--self:LinkComponent(self.parent)

end

function WeituoHeroPanelCls:OnResume()
	-- 界面显示时调用
	WeituoHeroPanelCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:GetUnityTransform().gameObject:SetActive(false)
	--self:Show(false)
end

function WeituoHeroPanelCls:OnPause()
	-- 界面隐藏时调用
	WeituoHeroPanelCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function WeituoHeroPanelCls:OnEnter()
	-- Node Enter时调用
	WeituoHeroPanelCls.base.OnEnter(self)
end

function WeituoHeroPanelCls:OnExit()
	-- Node Exit时调用
	WeituoHeroPanelCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function WeituoHeroPanelCls:InitControls()
	local transform = self:GetUnityTransform()
	transform:SetParent(self.parent)
	self.BaseImage = transform:Find('BaseImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.TitleText = transform:Find('TitleText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.GiveUpButton = transform:Find('GiveUpButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--self:Show(false)
end


function WeituoHeroPanelCls:RegisterControlEvents()
	-- 注册 GiveUpButton 的事件
	self.__event_button_onGiveUpButtonClicked__ = UnityEngine.Events.UnityAction(self.OnGiveUpButtonClicked, self)
	self.GiveUpButton.onClick:AddListener(self.__event_button_onGiveUpButtonClicked__)
end

function WeituoHeroPanelCls:UnregisterControlEvents()
	-- 取消注册 GiveUpButton 的事件
	if self.__event_button_onGiveUpButtonClicked__ then
		self.GiveUpButton.onClick:RemoveListener(self.__event_button_onGiveUpButtonClicked__)
		self.__event_button_onGiveUpButtonClicked__ = nil
	end
end

function WeituoHeroPanelCls:RegisterNetworkEvents()
end

function WeituoHeroPanelCls:UnregisterNetworkEvents()
end

function WeituoHeroPanelCls:Show(flag)

	self:GetUnityTransform().gameObject:SetActive(flag)
	--hzj_print("Show(flag)",flag)
end


-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function WeituoHeroPanelCls:OnGiveUpButtonClicked()
	--GiveUpButton控件的点击事件处理
end

return WeituoHeroPanelCls
