require "Const"

local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"

local TaskAwardItemCls = Class(BaseNodeClass)

function TaskAwardItemCls:Ctor(parent,isClicked,labelTheme)
	self.parent = parent	
	self.isClicked = isClicked
	self.labelTheme = labelTheme
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function TaskAwardItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/MyGeneralItem', function(go)
		self:BindComponent(go,false)
	end)
end

function TaskAwardItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent,true)
	self:InitControls()
end

function TaskAwardItemCls:OnResume()
	-- 界面显示时调用
	TaskAwardItemCls.base.OnResume(self)
	self:RegisterControlEvents()
end

function TaskAwardItemCls:OnPause()
	-- 界面隐藏时调用
	TaskAwardItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function TaskAwardItemCls:OnEnter()
	-- Node Enter时调用
	TaskAwardItemCls.base.OnEnter(self)
end

function TaskAwardItemCls:OnExit()
	-- Node Exit时调用
	TaskAwardItemCls.base.OnExit(self)
end

function TaskAwardItemCls:GetRootHangingPoint()
    return self:GetUIManager():GetDialogLayer()
end


-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function TaskAwardItemCls:InitControls()
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
	-- 边框图片
	self.colorBorder = transform:Find('Frame/Image'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 碎片图片
	self.DebrisIcon = transform:Find('DebrisIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 信息按钮
	self.infoButton = transform:Find('ItemInfoButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.infoButton.interactable = self.isClicked

	-- 选中状态
	self.OnSelectState = transform:Find('OnSelectState').gameObject

	-- 边框材质
	self.bordeMaterial = self.colorBorder.material

	self.activeState = false

	if self.labelTheme ~= nil then
		self:SetLabelTheme()
	end
end


function TaskAwardItemCls:RegisterControlEvents()
	-- 注册 BackpackRetrunButton 的事件
	self.__event_button_onInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked, self)
	self.infoButton.onClick:AddListener(self.__event_button_onInfoButtonClicked__)
end

function TaskAwardItemCls:UnregisterControlEvents()
	-- 取消注册 BackpackRetrunButton 的事件
	if self.__event_button_onInfoButtonClicked__ then
		self.infoButton.onClick:RemoveListener(self.__event_button_onInfoButtonClicked__)
		self.__event_button_onInfoButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------

local function DelaySetLabelTheme(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	self.nameLabel.fontSize = self.labelTheme.fontSize
	self.nameLabel.color = self.labelTheme.fontColor   -- UnityEngine.Color(1,1,1,1)
	local outline = self.nameLabel:GetComponent(typeof(UnityEngine.UI.Outline))
	outline.effectColor =  self.labelTheme.fonteffectColor   --UnityEngine.Color(0,0,0,1)
	outline.effectDistance = self.labelTheme.effectDistance  --Vector2(2,-2)
end

function TaskAwardItemCls:SetLabelTheme()
	-- coroutine.start(DelaySetLabelTheme,self)
	self:StartCoroutine(DelaySetLabelTheme)
end

function DelayRefreshItem(self,id,count)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"

	local itemInfoData,itemData,name,iconPath,itemType = gametool.GetItemDataById(id)

	utility.LoadSpriteFromPath(iconPath,self.ItemIcon)

	-- 数量
	-- if count ~= 1 then
		self.countLabel.gameObject:SetActive(true)
		self.countLabel.text = count
	-- end

	-- 名字
	self.nameLabel.text = name

	-- 
	local color = gametool.GetItemColorByType(itemType,itemData)
	
	-- 设置样式
	if not self.isGrayColor then
		PropUtility.AutoSetRGBColor(self.colorFrame,color)
	end
end

function TaskAwardItemCls:RefreshItem(id,count)
	-- 刷新Item
	self.ItemId = id
	-- coroutine.start(DelayRefreshItem,self,id,count)
	self:StartCoroutine(DelayRefreshItem, id,count)
end


function TaskAwardItemCls:OnInfoButtonClicked()
	local windowManager = utility:GetGame():GetWindowManager()
   	windowManager:Show(require "GUI.CommonItemWin",self.ItemId)
end

function TaskAwardItemCls:GetActive()
	return self.activeState
end

function TaskAwardItemCls:SetActive(active)
	self.activeState = active
end


local function DelaySetLocalScale(self,scale)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	self.transform.localScale = scale
end


function TaskAwardItemCls:SetLocalScale(scale)
	-- coroutine.start(DelaySetLocalScale,self,scale)
	self:StartCoroutine(DelaySetLocalScale, scale)
end

local function DelaySetLocalScale(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	self.nameLabel.gameObject:SetActive(false)
end


function TaskAwardItemCls:HideNameLabel()
	-- coroutine.start(DelaySetLocalScale,self)
	self:StartCoroutine(DelaySetLocalScale)
end

function TaskAwardItemCls:SetIconMaterial(material,isGrayColor)
	self.ItemIcon.material = material

	if material ~= nil then
		self.colorBorder.material = material
		self.colorBorder.color = UnityEngine.Color(1,1,1,1)
		self.isGrayColor = isGrayColor
	else
		self.colorBorder.material = self.bordeMaterial
		self.isGrayColor = isGrayColor
	end
end

local function DelaySetNameLabelPosition(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	self.rectTransform.sizeDelta = Vector2(128,128)

	local rectTransform = self.nameLabel.rectTransform
	rectTransform.anchorMax = Vector2(1,1)
	rectTransform.anchorMin = Vector2(0.5,0.5)
	rectTransform.offsetMin = Vector2(-50,0)
	rectTransform.offsetMax = Vector2(0,100)

	self.nameLabel.fontSize = 28
	self.countLabel.fontSize = 25
	self.nameLabel.color = UnityEngine.Color(1,1,1,1)
	local outline = self.nameLabel:GetComponent(typeof(UnityEngine.UI.Outline))
	outline.effectColor = UnityEngine.Color(0,0,0,1)
	outline.effectDistance = Vector2(2,-2)
end

function TaskAwardItemCls:SetNameLabelPosition( )
	-- coroutine.start(DelaySetNameLabelPosition,self)
	self:StartCoroutine(DelaySetNameLabelPosition)
end


return TaskAwardItemCls