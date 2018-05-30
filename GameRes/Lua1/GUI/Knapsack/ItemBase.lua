require "Const"


local UnityEngine_Color = UnityEngine.Color
SelectedColor = UnityEngine_Color(0.48235,0.48235,0.48235,1)
NoSelectedColor = UnityEngine_Color(1,1,1,1)

local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ItemBaseNodeCls = Class(BaseNodeClass)

function ItemBaseNodeCls:Ctor(parent,itemWidth,itemHigh)
	self.parent = parent
	self.itemWidth = itemWidth
	self.itemHigh = itemHigh

	self.callback = LuaDelegate.New()
end


function ItemBaseNodeCls:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ItemBaseNodeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/MyGeneralItem', function(go)
		self:BindComponent(go,false)
	end)
end

function ItemBaseNodeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function ItemBaseNodeCls:OnResume()
	-- 界面显示时调用
	ItemBaseNodeCls.base.OnResume(self)
	self:RegisterControlEvents()
	--self:RegisterNetworkEvents()
end

function ItemBaseNodeCls:OnPause()
	-- 界面隐藏时调用
	ItemBaseNodeCls.base.OnPause(self)
	self:UnregisterControlEvents()
	--self:UnregisterNetworkEvents()
end

function ItemBaseNodeCls:OnEnter()
	-- Node Enter时调用
	ItemBaseNodeCls.base.OnEnter(self)
end

function ItemBaseNodeCls:OnExit()
	-- Node Exit时调用
	ItemBaseNodeCls.base.OnExit(self)
end



-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ItemBaseNodeCls:InitControls()
	local transform = self:GetUnityTransform()

	self.transform = transform
	self.rectTransform = transform:GetComponent(typeof(UnityEngine.RectTransform))
	-- 数量
	self.countLabel = transform:Find('GeneralItemNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 名称
	self.nameLabel = transform:Find('ItemNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.nameLabel.gameObject:SetActive(true)
	
	self.redDotImage = transform:Find('RedDot'):GetComponent(typeof(UnityEngine.UI.Image))
	self.redDotImage.gameObject:SetActive(false)

	-- 设置名字样式
	local rectTransform = self.nameLabel.rectTransform
	rectTransform.anchorMax = Vector2(1,1)
	rectTransform.anchorMin = Vector2(0.5,0.5)
	rectTransform.offsetMin = Vector2(-60,0)
	rectTransform.offsetMax = Vector2(0,88)

	self.nameLabel.fontSize = 22
	self.nameLabel.color = UnityEngine.Color(1,1,1,1)
	local outline = self.nameLabel:GetComponent(typeof(UnityEngine.UI.Outline))
	outline.effectColor =  UnityEngine.Color(0,0,0,1)   --UnityEngine.Color(0,0,0,1)
	outline.effectDistance = Vector2(1.5,-1.5)  --Vector2(2,-2)

	-- 图标
	self.ItemIcon = transform:Find('ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 颜色
	self.colorFrame = transform:Find('Frame')
	-- 碎片图片
	self.DebrisIcon = transform:Find('DebrisIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.debrisCorner = transform:Find("DebrisCorner"):GetComponent(typeof(UnityEngine.UI.Image))
	-- 信息按钮
	self.infoButton = transform:Find('ItemInfoButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- 选中状态
	self.OnSelectState = transform:Find('OnSelectState').gameObject

	-- 套装属性
	self.flag = transform:Find('Flag').gameObject
	-- 等级label
	self.LevelLabel = transform:Find('ItemLevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 绑定
	self.bindObj = transform:Find('BindImage').gameObject
	-- 主属性
	self.ItemAttributeLabel = transform:Find('ItemAttributeLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	self.selectedState = false

end


function ItemBaseNodeCls:RegisterControlEvents()
	-- 注册 BackpackRetrunButton 的事件
	self.__event_button_onInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked, self)
	self.infoButton.onClick:AddListener(self.__event_button_onInfoButtonClicked__)
end

function ItemBaseNodeCls:UnregisterControlEvents()
	-- 取消注册 BackpackRetrunButton 的事件
	if self.__event_button_onInfoButtonClicked__ then
		self.infoButton.onClick:RemoveListener(self.__event_button_onInfoButtonClicked__)
		self.__event_button_onInfoButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
local function DelayOnBind(self,data,dataType)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	self.rectTransform.sizeDelta = Vector2(self.itemWidth,self.itemHigh)

	self:ResetItem(data)
end

function ItemBaseNodeCls:OnBind(data,index)
	self.index = index
	self.ItemType = data:GetKnapsackItemType()
	-- coroutine.start(DelayOnBind,self,data)
	self:StartCoroutine(DelayOnBind, data)
end

function ItemBaseNodeCls:OnUnbind()
	
end
--------------------------------------------------------------------------
local function DelayResetPosition(self,position)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	
	self.rectTransform.anchoredPosition = position
end

function ItemBaseNodeCls:ResetPosition(position)
	-- coroutine.start(DelayResetPosition,self,position)
	self:StartCoroutine(DelayResetPosition, position)
end

function ItemBaseNodeCls:ResetItem(data)
	-- 重置数据
	--if dataType
	self.redDotImage.gameObject:SetActive(false)
	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"

	local id
	local color
	local uid
	local attr = false

	if self.ItemType == KKnapsackItemType_EquipNormal then
	
		id = data:GetEquipID()
		local level = data:GetLevel()

		local KEquipType = data:GetEquipType()

		local isHide = (KEquipType == KEquipType_EquipAccessories) or (KEquipType == KEquipType_EquipShoesr)
		self:SetNormalEquipContent(level, isHide)
		uid = data:GetEquipUID()
		attr = true

	elseif self.ItemType == KKnapsackItemType_Item then
		id = data:GetId()		
		color = data:GetColor()
		local count = data:GetNumber()
		self:SetItemContent(count)
		uid = data:GetUid()
		local infoData,data,name,iconPath,itype = gametool.GetItemDataById(id)
		local useNum = data:GetCanUse()

		if useNum == 6 or useNum == 5 then 
			self.redDotImage.gameObject:SetActive(true)
		else
			self.redDotImage.gameObject:SetActive(false)
		end

	elseif self.ItemType == KKnapsackItemType_EquipDebris then
		-- 装备碎片
		id = data:GetEquipSuipianID()
		local count = data:GetNumber()
		self:SetEquipDebrisContent(count,id)
		uid = data:GetEquipSuipianID()
	end

	local itemInfoData,itemData,name,iconPath,itemType = gametool.GetItemDataById(id)

	self.nameLabel.text = name
	utility.LoadSpriteFromPath(iconPath,self.ItemIcon)

	-- 
	if color == nil then 
		color = gametool.GetItemColorByType(itemType,itemData)
	end
	
	-- 设置样式
	PropUtility.AutoSetRGBColor(self.colorFrame,color)

	-- 设置套装
	local issuit
	local isbind
	if self.ItemType == KKnapsackItemType_EquipNormal then
		issuit = itemData:GetTaozhuangID() ~= 0
		isbind = data:GetBindCardUID() ~= ""
	end
	self.flag:SetActive(issuit)
	self.bindObj:SetActive(isbind)

	if attr then
		local dict,mainId = data:GetEquipAttribute()
		local _,_,mainStr = gametool.GetEquipInfoStr(dict,mainId)
		self.ItemAttributeLabel.text = mainStr
	end
	self.ItemAttributeLabel.gameObject:SetActive(attr)

	self.itemID = id
	self.itemData = data
	self.uid = uid

end

function ItemBaseNodeCls:SetOnSelectedState()
	-- 设置选中状态
	self.selectedState = not self.selectedState
	self.OnSelectState:SetActive(self.selectedState )
	if self.selectedState then
		self.ItemIcon.color = SelectedColor
	else
		self.ItemIcon.color = NoSelectedColor
	end

end

function ItemBaseNodeCls:SetSelecredState(active)
	self.selectedState = active
	self.OnSelectState:SetActive(self.selectedState )
	if self.selectedState then
		self.ItemIcon.color = SelectedColor
	else
		self.ItemIcon.color = NoSelectedColor
	end
end


----------------------------------------------------------------
function ItemBaseNodeCls:SetNormalEquipContent(level, isHide)
	-- 处理数量
	self:DisposeObjectActive(self.countLabel.gameObject,false)
	self:DisposeObjectActive(self.LevelLabel.gameObject,true)

	if isHide then
		self.LevelLabel.text = "" 
	else
		self.LevelLabel.text = string.format("%s%s","Lv",level) 
	end

	-- 处理碎片图标
	self:DisposeObjectActive(self.DebrisIcon.gameObject,false)
	self:DisposeObjectActive(self.debrisCorner.gameObject,false)
end


function ItemBaseNodeCls:SetItemContent(count)
	-- 处理数量
	self:DisposeObjectActive(self.LevelLabel.gameObject,false)
	self:DisposeObjectActive(self.countLabel.gameObject,true)
	self.countLabel.text = count

	-- 处理碎片图标
	self:DisposeObjectActive(self.DebrisIcon.gameObject,false)
	self:DisposeObjectActive(self.debrisCorner.gameObject,false)
end

function ItemBaseNodeCls:SetEquipDebrisContent(count,id)
	-- 处理数量
	self:DisposeObjectActive(self.LevelLabel.gameObject,false)
	self:DisposeObjectActive(self.countLabel.gameObject,true)
	local staticData = require "StaticData.EquipCrap":GetData(id)
	local needCount = staticData:GetNeedBuildNum()

	self.countLabel.text = string.format("%s%s%s",count,"/",needCount)
	if count>=needCount then
		self.redDotImage.gameObject:SetActive(true)
	else
		self.redDotImage.gameObject:SetActive(false)
	end

	-- 处理碎片图标
	self:DisposeObjectActive(self.DebrisIcon.gameObject,true)
	self:DisposeObjectActive(self.debrisCorner.gameObject,true)
end


function ItemBaseNodeCls:DisposeObjectActive(gameObject,active)
	-- 处理物体显示
	local isActive = not active
	if gameObject.activeSelf == isActive then
		gameObject:SetActive(active)
	end

end

local function DelayItemClickedCallback(self,itemType,itemID,itemData)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	-- 信息按钮
	self.callback:Invoke(itemType,itemID,itemData,self,self.index)
end

function ItemBaseNodeCls:SellItemCallback(index,price,data)
	self.active = not self.active
	self.callback:Invoke(index,price,data,self.active)
end


function ItemBaseNodeCls:OnInfoButtonClicked()
	self.callback:Invoke(self.ItemType,self.uid,self.itemID)
end


-- function ItemBaseNodeCls:ItemClickedCallback(itemType,itemID,itemData)
-- 	-- 回调方法
-- 	coroutine.start(DelayItemClickedCallback,self,self.ItemType,itemID,itemData)
-- end


function ItemBaseNodeCls:GetItemID(data,dataType)
	-- 获取Item ID
	local id
	if self.ItemType == KKnapsackItemType_EquipNormal then
		-- 普通装备
		id = data:GetEquipID()
		return id
	elseif self.ItemType == KKnapsackItemType_Item then
		-- 物品Item
		id = data:GetId()
		return id		
	elseif self.ItemType == KKnapsackItemType_EquipDebris then
		-- 装备碎片
		id = data:GetEquipSuipianID()
		return id
	end

	error("获取Item ID数据错误")
	return nil

end


function ItemBaseNodeCls:SetNodeActive(active)
	self.active = active
end

function ItemBaseNodeCls:GetNodeActive()
	if self.active == nil then
		self.active = false
	end
	return self.active
end

function ItemBaseNodeCls:SetSelectedState(active)
	self.active = active
	self.OnSelectState:SetActive(active)
end

return ItemBaseNodeCls