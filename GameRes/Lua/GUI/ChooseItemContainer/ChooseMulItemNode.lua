local BaseNodeClass = require "GUI.ChooseItemContainer.BaseItemNode"
local utility = require "Utils.Utility"


local ChooseMulItemNodeCls = Class(BaseNodeClass)

function ChooseMulItemNodeCls:Ctor(parent,itemWidth,itemHigh)

end

function ChooseMulItemNodeCls:OnInit()
	ChooseMulItemNodeCls.base.OnInit(self)
	self:InitControls()
end

function ChooseMulItemNodeCls:InitControls()
	ChooseMulItemNodeCls.base.InitControls(self)
	-- 信息按钮
	self.infoButton = self.transform:Find('ItemInfoButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- 选中状态
	self.OnSingleSelectState = self.transform:Find('OnSelectState').gameObject
	-- 图标
	self.ItemIcon = self.transform:Find('ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 颜色
	self.colorFrame = self.transform:Find('Frame')
	-- 名称
	self.nameLabel = self.transform:Find('ItemNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--LV
	self.lvLabel = self.transform:Find('ItemLevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	self.nameLabel.gameObject:SetActive(true)
	self.lvLabel.gameObject:SetActive(true)

	-- 设置名字样式
	local rectTransform = self.nameLabel.rectTransform
	rectTransform.anchorMax = Vector2(1,1)
	rectTransform.anchorMin = Vector2(0.5,0.5)
	rectTransform.offsetMin = Vector2(-66.64,0)
	rectTransform.offsetMax = Vector2(0,86)

	self.nameLabel.fontSize = 22
	self.nameLabel.color = UnityEngine.Color(1,1,1,1)
	local outline = self.nameLabel:GetComponent(typeof(UnityEngine.UI.Outline))
	outline.effectColor =  UnityEngine.Color(0,0,0,1)   --UnityEngine.Color(0,0,0,1)
	outline.effectDistance = Vector2(1.5,-1.5)

	-- 属性
	self.attributeLabel = self.transform:Find('ItemAttributeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.attributeLabel.gameObject:SetActive(true)
	
end

function ChooseMulItemNodeCls:OnResume()
	ChooseMulItemNodeCls.base.OnResume(self)
	self:RegisterControlEvents()
end

function ChooseMulItemNodeCls:OnPause()
	-- 界面隐藏时调用
	ChooseMulItemNodeCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function ChooseMulItemNodeCls:RegisterControlEvents()
	-- 注册 信息按钮 的事件
	self.__event_button_onInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked, self)
	self.infoButton.onClick:AddListener(self.__event_button_onInfoButtonClicked__)
end

function ChooseMulItemNodeCls:UnregisterControlEvents()
	-- 取消注册 信息按钮 的事件
	if self.__event_button_onInfoButtonClicked__ then
		self.infoButton.onClick:RemoveListener(self.__event_button_onInfoButtonClicked__)
		self.__event_button_onInfoButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
-----------------------------------------------------------------------

function ChooseMulItemNodeCls:ResetItem(data)
	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"

	local id = data:GetEquipID()
	local itemInfoData,itemData,name,iconPath,itemType = gametool.GetItemDataById(id)
	local color = gametool.GetItemColorByType(itemType,itemData)

	self.nameLabel.text = name
	utility.LoadSpriteFromPath(iconPath,self.ItemIcon)
	PropUtility.AutoSetRGBColor(self.colorFrame,color)
	local dict,mainId = itemData:GetEquipAttribute()
	local _,_,manStr = gametool.GetEquipInfoStr(dict,mainId)
	self.attributeLabel.text = manStr
	self.lvLabel.text ='Lv'.. data:GetLevel()
	self.uid = data:GetEquipUID()
end

function ChooseMulItemNodeCls:OnInfoButtonClicked()
	self.active = not self.active
	ChooseMulItemNodeCls.base.OnInfoButtonClicked(self,self.uid,self.active,self.index,self)
	--debug_print("OnInfoButtonClicked",self,self.uid,self.active,self.index)
end

function ChooseMulItemNodeCls:SetSelectedState(active)
	--debug_print("SetSelectedState",active)
	ChooseMulItemNodeCls.base.SetSelectedState(self,active)
	--debug_print(self.active)
	self.OnSingleSelectState:SetActive(self.active)
end

return ChooseMulItemNodeCls