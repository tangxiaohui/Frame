require "Const"

local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"
local EquipDataClass = require "Data.EquipBag.EquipData"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local SuitItemNodeCls = Class(BaseNodeClass)

function SuitItemNodeCls:Ctor(parent)
	self.parent = parent
	self.callback = LuaDelegate.New()
end


function SuitItemNodeCls:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function SuitItemNodeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/MyGeneralItem', function(go)
		self:BindComponent(go,false)
	end)
end

function SuitItemNodeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function SuitItemNodeCls:OnResume()
	-- 界面显示时调用
	SuitItemNodeCls.base.OnResume(self)
	self:RegisterControlEvents()
	--self:RegisterNetworkEvents()
end

function SuitItemNodeCls:OnPause()
	-- 界面隐藏时调用
	SuitItemNodeCls.base.OnPause(self)
	self:UnregisterControlEvents()
	--self:UnregisterNetworkEvents()
end

function SuitItemNodeCls:OnEnter()
	-- Node Enter时调用
	SuitItemNodeCls.base.OnEnter(self)
end

function SuitItemNodeCls:OnExit()
	-- Node Exit时调用
	SuitItemNodeCls.base.OnExit(self)
end



-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function SuitItemNodeCls:InitControls()
	local transform = self:GetUnityTransform()

	self.transform = transform
	self.rectTransform = transform:GetComponent(typeof(UnityEngine.RectTransform))
	-- 数量
	self.countLabel = transform:Find('GeneralItemNumLabel').gameObject
	self.countLabel:SetActive(false)
	-- 名称
	self.nameLabel = transform:Find('ItemNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 图标
	self.ItemIcon = transform:Find('ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 颜色
	self.colorFrame = transform:Find('Frame')
	-- 碎片图片
	self.DebrisIcon = transform:Find('DebrisIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 信息按钮
	self.infoButton = transform:Find('ItemInfoButton'):GetComponent(typeof(UnityEngine.UI.Button))
	
	self.flag = transform:Find('Flag').gameObject
	self.flag:SetActive(true)

	self.ItemData = EquipDataClass.New()
end


function SuitItemNodeCls:RegisterControlEvents()
	-- 注册 BackpackRetrunButton 的事件
	self.__event_button_onInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked, self)
	self.infoButton.onClick:AddListener(self.__event_button_onInfoButtonClicked__)
end

function SuitItemNodeCls:UnregisterControlEvents()
	-- 取消注册 BackpackRetrunButton 的事件
	if self.__event_button_onInfoButtonClicked__ then
		self.infoButton.onClick:RemoveListener(self.__event_button_onInfoButtonClicked__)
		self.__event_button_onInfoButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
local function DelayOnBind(self,id,dataType)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	self:ResetItem(id,dataType)
end

function SuitItemNodeCls:OnBind(id,dataType)
	-- coroutine.start(DelayOnBind,self,id,dataType)
	self:StartCoroutine(DelayOnBind, id,dataType)
end

function SuitItemNodeCls:OnUnbind()
	
end
--------------------------------------------------------------------------
local function DelayResetPosition(self,position)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	
	self.rectTransform.anchoredPosition = position
end

function SuitItemNodeCls:ResetPosition(position)
	-- coroutine.start(DelayResetPosition,self,position)
	self:StartCoroutine(DelayResetPosition, position)
end

function SuitItemNodeCls:ResetItem(id,dataType)
	-- 重置数据
	--if dataType
	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"
	local color

	local itemInfoData,itemData,name,iconPath,itemType = gametool.GetItemDataById(id)
	utility.LoadSpriteFromPath(iconPath,self.ItemIcon)

	-- 
	if color == nil then 
		color = gametool.GetItemColorByType(itemType,itemData)
	end
	
	-- 设置样式
	PropUtility.AutoSetRGBColor(self.colorFrame,color)
	self.itemID = id
	self.itemType = dataType
end


----------------------------------------------------------------

function SuitItemNodeCls:DisposeObjectActive(gameObject,active)
	-- 处理物体显示
	local isActive = not active
	if gameObject.activeSelf == isActive then
		gameObject:SetActive(active)
	end
end

function SuitItemNodeCls:OnInfoButtonClicked()
	
	local windowManager = utility:GetGame():GetWindowManager()
	local NodeClass = require "GUI.Knapsack.EquipWinNode"
	windowManager:Show(NodeClass,self.itemID)
end

function SuitItemNodeCls:SetNodeActive(active)
	self.active = active
end

function SuitItemNodeCls:GetNodeActive()
	return self.active
end


return SuitItemNodeCls