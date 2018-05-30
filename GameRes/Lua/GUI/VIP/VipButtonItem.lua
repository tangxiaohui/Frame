local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"

local VipButtonItemCls = Class(BaseNodeClass)

function  VipButtonItemCls:Ctor(parent,id,vip)
	self.parent = parent
	self.id = id
	self.vip = vip
	self.callback = LuaDelegate.New()
end

function VipButtonItemCls:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end

function  VipButtonItemCls:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/VipTag",function(go)
		self:BindComponent(go)
	end)
end

function VipButtonItemCls:OnComponentReady()
	self:InitControls()
	self:LinkComponent(self.parent)
end

function VipButtonItemCls:OnResume()
	VipButtonItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:ShowItem()
end

function VipButtonItemCls:OnPause()
	VipButtonItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function VipButtonItemCls:OnEnter()
	VipButtonItemCls.base.OnEnter(self)
end

function VipButtonItemCls:OnExit()
	VipButtonItemCls.base.OnExit(self)
end


function VipButtonItemCls:InitControls()
	local transform = self:GetUnityTransform()
	transform.name = self.id
	self.infoButton = transform:GetComponent(typeof(UnityEngine.UI.Button))
	self.clickedState = transform:Find("On")
	self.closedState = transform:Find("Off")
	self.onvipLabel = self.clickedState:Find("VIPLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.offvipLabel = self.closedState:Find("VIPLabel"):GetComponent(typeof(UnityEngine.UI.Text))

	self.myGame = utility:GetGame()
end

function VipButtonItemCls:RegisterControlEvents()
	self._event_button_onInfoButtonClicked_ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked,self)
	self.infoButton.onClick:AddListener(self._event_button_onInfoButtonClicked_)
end

function VipButtonItemCls:UnregisterControlEvents()
	if self._event_button_onInfoButtonClicked_ then
		self.infoButton.onClick:RemoveListener(self._event_button_onInfoButtonClicked_)
		self._event_button_onInfoButtonClicked_ = nil
	end
end

function  VipButtonItemCls:OnInfoButtonClicked()
	self.callback:Invoke(self.id,self.clickedState,self.closedState)
	-- print("aaaaa",self.isOn)
end

function VipButtonItemCls:SwitchControl(isOn)
	self.clickedState.gameObject:SetActive(isOn)
	self.closedState.gameObject:SetActive(not isOn)
end

function VipButtonItemCls:SetVipId()
	return self.id
end

function VipButtonItemCls:ShowItem()
	if self.vip == self.id then
		self:SwitchControl(true)
	end
	self.onvipLabel.text = "VIP"..self.id
	self.offvipLabel.text = "VIP"..self.id
end

return VipButtonItemCls