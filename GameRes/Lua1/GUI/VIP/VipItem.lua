local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"

local VipItemCls = Class(BaseNodeClass)

function  VipItemCls:Ctor(parent,id,num,color)
	self.parent = parent
	self.id = id
	self.num = num
	self.colors = color
end

function  VipItemCls:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/Item",function(go)
		self:BindComponent(go)
	end)
end

function VipItemCls:OnComponentReady()
	self:InitControls()
	self:LinkComponent(self.parent)
end

function VipItemCls:OnResume()
	VipItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:ShowItem()
end

function VipItemCls:OnPause()
	VipItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function VipItemCls:OnEnter()
	VipItemCls.base.OnEnter(self)
end

function VipItemCls:OnExit()
	VipItemCls.base.OnExit(self)
end

function VipItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.infoButton = transform:Find("Icon"):GetComponent(typeof(UnityEngine.UI.Button))
	self.icon = transform:Find("Icon"):GetComponent(typeof(UnityEngine.UI.Image))
	self.color = transform:Find("Frame"):GetComponent(typeof(UnityEngine.UI.Image))
	self.numLabel = transform:Find("NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.nameLabel = transform:Find("ItemNameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.DebrisCorner = transform:Find("DebrisCorner").gameObject
	self.DebrisIcon = transform:Find("DebrisIcon").gameObject
end

function VipItemCls:RegisterControlEvents()
	self._event_button_onInfoButtonClicked_ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked,self)
	self.infoButton.onClick:AddListener(self._event_button_onInfoButtonClicked_)
end

function VipItemCls:UnregisterControlEvents()
	if self._event_button_onInfoButtonClicked_ then
		self.infoButton.onClick:RemoveListener(self._event_button_onInfoButtonClicked_)
		self._event_button_onInfoButtonClicked_ = nil
	end
end
function  VipItemCls:OnInfoButtonClicked()
	local gameTool = require "Utils.GameTools"
	gameTool.ShowItemWin(self.id)
	-- local windowManager = utility:GetGame():GetWindowManager()
	-- windowManager:Show(require "GUI.CommonItemWin",self.id)
end

function VipItemCls:ShowItem()
	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"
	self.numLabel.text = self.num
	local _,data,itemName,iconPath,itemType = gametool.GetItemDataById(self.id)
	utility.LoadSpriteFromPath(iconPath,self.icon)
	if self.colors ~= nil and tonumber(self.colors) ~= -1 then
		PropUtility.AutoSetRGBColor(self.color,self.colors)
	else
		local color = gametool.GetItemColorByType(itemType,data)
 		PropUtility.AutoSetRGBColor(self.color,color)
	end
	 if itemType == "RoleChip" or  itemType == "EquipChip" then
	 	self.DebrisIcon:SetActive(true)
	 	self.DebrisCorner:SetActive(true)
	 else
	 	self.DebrisIcon:SetActive(false)
		self.DebrisCorner:SetActive(false)
	 end
	self.nameLabel.text = itemName
end

return VipItemCls