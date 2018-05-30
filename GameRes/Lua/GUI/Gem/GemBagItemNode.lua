require "Const"


local UnityEngine_Color = UnityEngine.Color
SelectedColor = UnityEngine_Color(0.48235,0.48235,0.48235,1)
NoSelectedColor = UnityEngine_Color(1,1,1,1)

local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"

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
end

function ItemBaseNodeCls:OnPause()
	-- 界面隐藏时调用
	ItemBaseNodeCls.base.OnPause(self)
	self:UnregisterControlEvents()
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

	-- 图标
	self.ItemIcon = transform:Find('ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 颜色
	self.colorFrame = transform:Find('Frame')
	-- 碎片图片
	self.DebrisIcon = transform:Find('DebrisIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 信息按钮
	self.infoButton = transform:Find('ItemInfoButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- 选中状态
	self.OnSelectState = transform:Find('OnSelectState').gameObject

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
local function DelayOnBind(self,data)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	self.rectTransform.sizeDelta = Vector2(self.itemWidth,self.itemHigh)

	self:ResetItem(data)
end

function ItemBaseNodeCls:OnBind(data,index)
	self.index = index
	self.data = data
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
	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"

	local id
	local color	
	local itemType = data:GetKnapsackItemType()
	local count

	if itemType == KKnapsackItemType_Item then
		id = data:GetId()
		count = data:GetNumber()
	elseif itemType == KKnapsackItemType_EquipNormal then 
		id = data:GetEquipID()
		count = 1
	end 
	

	local itemInfoData,itemData,name,iconPath,itemType = gametool.GetItemDataById(id)

	utility.LoadSpriteFromPath(iconPath,self.ItemIcon)

	-- 数量
	self.countLabel.text = count

	-- 名字
	self.nameLabel.text = name

	-- 
	color = data:GetColor()
	
	-- 设置样式
	PropUtility.AutoSetColor(self.colorFrame,color)
	
	self.itemID = id
	--self.itemData = data
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

function ItemBaseNodeCls:SetSelectedState(active)
	self.selectedState = active
	self.OnSelectState:SetActive(self.selectedState )
	if self.selectedState then
		self.ItemIcon.color = SelectedColor
	else
		self.ItemIcon.color = NoSelectedColor
	end
end


----------------------------------------------------------------


local function DelayItemClickedCallback(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	-- 信息按钮
	self.callback:Invoke(self,self.index,self.itemID,self.data)
end


function ItemBaseNodeCls:OnInfoButtonClicked()
	-- coroutine.start(DelayItemClickedCallback,self)
	self:StartCoroutine(DelayItemClickedCallback)
end


function ItemBaseNodeCls:SetNodeActive(active)
	self.active = active
end

function ItemBaseNodeCls:GetNodeActive()
	return self.active
end


return ItemBaseNodeCls