local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"

local ActiveItemCls = Class(BaseNodeClass)

local gameTool = require "Utils.GameTools"
local AtlasesLoader = require "Utils.AtlasesLoader"
--fkag
function ActiveItemCls:Ctor(parent,id,flag,name,OperationActicity)
	self.parent = parent
	self.flag = flag
	self.name = name
	self.id=id
	self.OperationActicity=OperationActicity
	self.callback = LuaDelegate.New()
end

function ActiveItemCls:SetCallback(ctable,func)
	-- print(func)
	 self.callback:Set(ctable,func)
end

function ActiveItemCls:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/ActiveButton",function(go)
		self:BindComponent(go)
	end)
end

function ActiveItemCls:OnComponentReady()
	self:LinkComponent(self.parent)
	self:InitControls()

end

function ActiveItemCls:OnResume()
	ActiveItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:ShowName()
	
	-- ShowButton(self)
end

function ActiveItemCls:OnPause()
	ActiveItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function ActiveItemCls:OnEnter()
	ActiveItemCls.base.OnEnter(self)
	-- self:ShowPanel()
end

function ActiveItemCls:OnExit()
	ActiveItemCls.base.OnExit(self)
end

function ActiveItemCls:InitControls()
	local transform = self:GetUnityTransform()
	-- transform.name = self.id
	self.infoButton = transform:GetComponent(typeof(UnityEngine.UI.Button))
	transform.localRotation = Quaternion.Euler(0,0,7.2)
	-- self.rectTransform = transform:GetComponent(typeof(UnityEngine.RectTransform))
	self.onObj = transform:Find("On")
	self.offObj = transform:Find("Off")
	self.redDot = transform:Find("RedDot").gameObject
	self.onLabel = transform:Find("On/ActiveNameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.offLabel = transform:Find("Off/ActiveNameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.labelrect = self.activeLabel:GetComponen t(typeof(UnityEngine.RectTransform))
	self.myGame = utility:GetGame()
	-- self.outline = self.activeLabel:GetComponent(typeof(UnityEngine.UI.Outline))
 --    self.buttonImage = self.activeButton.gameObject:GetComponent(typeof(UnityEngine.UI.Image))
 	self.redDot:SetActive(false)
end

function ActiveItemCls:RegisterControlEvents()
	self._event_button_onInfoButtonClicked_ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked,self)
	self.infoButton.onClick:AddListener(self._event_button_onInfoButtonClicked_)
end

function ActiveItemCls:UnregisterControlEvents()
	if self._event_button_onInfoButtonClicked_ then
		self.infoButton.onClick:RemoveListener(self._event_button_onInfoButtonClicked_)
		self._event_button_onInfoButtonClicked_ = nil
	end
end

function ActiveItemCls:OnInfoButtonClicked()
	-- print("发送协议")

	-- self:OnActivityQueryRequest(self.id)
	self.callback:Invoke(self.id,self.onObj,self.offObj,self.OperationActicity)
	-- print(self.id)
end

function ActiveItemCls:ShowOnOrOff()
	self.onObj.gameObject:SetActive(false)
	self.offObj.gameObject:SetActive(true)

end

function ActiveItemCls:ShowName()

	self.onLabel.text = self.name
	self.offLabel.text = self.name
	-- self.activeButton.name = self.id
	if self.flag then	
		-- self:OnActivityQueryRequest(self.firstid)
		self.onObj.gameObject:SetActive(true)
		self.offObj.gameObject:SetActive(false)
	end
end

function ActiveItemCls:OnActivityQueryRequest(activeid)
	self.myGame:SendNetworkMessage( require "Network.ServerService".ActivityQueryRequest(activeid))
end


function ActiveItemCls:SetRedDot(red)
	-- debug_print(red)
	self.redDot:SetActive(red == 1)
end


return ActiveItemCls