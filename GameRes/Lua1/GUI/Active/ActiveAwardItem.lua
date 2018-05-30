local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"

local ActiveAwardItemCls = Class(BaseNodeClass)

function  ActiveAwardItemCls:Ctor(parent,id,num,color,isAlreceive)
	self.parent = parent
	self.id = id
	self.num = num
	self.colors = nil
	self.isAlreceive = isAlreceive
end

function  ActiveAwardItemCls:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/ItemBox",function(go)
		self:BindComponent(go)
	end)
end

function ActiveAwardItemCls:OnComponentReady()
	self:InitControls()
	self:LinkComponent(self.parent)
end

function ActiveAwardItemCls:OnResume()
	ActiveAwardItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:ShowItem()
end

function ActiveAwardItemCls:OnPause()
	ActiveAwardItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function ActiveAwardItemCls:OnEnter()
	ActiveAwardItemCls.base.OnEnter(self)
end

function ActiveAwardItemCls:OnExit()
	ActiveAwardItemCls.base.OnExit(self)
end

function ActiveAwardItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.infoButton = transform:Find("Icon"):GetComponent(typeof(UnityEngine.UI.Button))
	self.icon = transform:Find("Icon"):GetComponent(typeof(UnityEngine.UI.Image))
	self.color = transform:Find("Frame"):GetComponent(typeof(UnityEngine.UI.Image))
	self.numLabel = transform:Find("ItemNumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.DebrisCorner = transform:Find("DebrisCorner").gameObject
	self.DebrisIcon = transform:Find("DebrisIcon").gameObject
	self.hslMaterial = self.color.material
	self.GrayMaterial = utility.GetGrayMaterial()
end

function ActiveAwardItemCls:RegisterControlEvents()
	self._event_button_onInfoButtonClicked_ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked,self)
	self.infoButton.onClick:AddListener(self._event_button_onInfoButtonClicked_)
end

function ActiveAwardItemCls:UnregisterControlEvents()
	if self._event_button_onInfoButtonClicked_ then
		self.infoButton.onClick:RemoveListener(self._event_button_onInfoButtonClicked_)
		self._event_button_onInfoButtonClicked_ = nil
	end
end
function  ActiveAwardItemCls:OnInfoButtonClicked()
	-- local windowManager = utility:GetGame():GetWindowManager()
	-- windowManager:Show(require "GUI.CommonItemWin",self.id)
	local gameTool = require "Utils.GameTools"
	gameTool.ShowItemWin(self.id)
end

function ActiveAwardItemCls:ShowItem()
	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"
	self.numLabel.text = self.num
	local _,data,itemName,iconPath,itemType = gametool.GetItemDataById(self.id)
	utility.LoadSpriteFromPath(iconPath,self.icon)
	if self.colors == -1 or self.colors == nil then
		local color = gametool.GetItemColorByType(itemType,data)
 		PropUtility.AutoSetRGBColor(self.color,color)
	else
		PropUtility.AutoSetRGBColor(self.color,self.colors)
	end
	 if itemType == "RoleChip" or  itemType == "EquipChip" then
        self.DebrisIcon:SetActive(true)
        self.DebrisCorner:SetActive(true)
    else
    	self.DebrisIcon:SetActive(false)
        self.DebrisCorner:SetActive(false)
    end
	if self.isAlreceive then
		self:SetMaterial(self.GrayMaterial)

	else
		self:SetMaterial(utility.GetCommonMaterial())
		self.color.material = self.hslMaterial
	end
end

function ActiveAwardItemCls:SetMaterial(isGray)
	self.icon.material = isGray
	self.color.material = isGray
end

return ActiveAwardItemCls