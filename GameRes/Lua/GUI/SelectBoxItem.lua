require "Const"

local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"

local SelectBoxItemCls = Class(BaseNodeClass)

function SelectBoxItemCls:Ctor(parent,id)
	self.parent = parent
	self.id = id
	self.callback = LuaDelegate.New()
end


function SelectBoxItemCls:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function SelectBoxItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/MyGeneralItem', function(go)
		self:BindComponent(go,false)
	end)
end

function SelectBoxItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function SelectBoxItemCls:OnResume()
	-- 界面显示时调用
	SelectBoxItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:ShowPanel()
	--self:RegisterNetworkEvents()
end

function SelectBoxItemCls:OnPause()
	-- 界面隐藏时调用
	SelectBoxItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	--self:UnregisterNetworkEvents()
end

function SelectBoxItemCls:OnEnter()
	-- Node Enter时调用
	SelectBoxItemCls.base.OnEnter(self)
end

function SelectBoxItemCls:OnExit()
	-- Node Exit时调用
	SelectBoxItemCls.base.OnExit(self)
end



-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function SelectBoxItemCls:InitControls()
	local transform = self:GetUnityTransform()

	self.transform = transform
	-- 数量
	self.countLabel = transform:Find('GeneralItemNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.countLabel.gameObject:SetActive(true)
	-- 名称
	self.nameLabel = transform:Find('ItemNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.nameLabel.gameObject:SetActive(true)
	-- 图标
	self.ItemIcon = transform:Find('ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 颜色
	self.colorFrame = transform:Find('Frame')
	-- 信息按钮
	self.infoButton = transform:Find('ItemInfoButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- 选中状态
	self.OnSelectState = transform:Find('OnSelectState').gameObject

	-- 碎片图标 --
    self.DebrisIcon = transform:Find("DebrisIcon").gameObject
    self.DebrisCorner = transform:Find("DebrisCorner").gameObject

	self.selectedState = false

end


function SelectBoxItemCls:RegisterControlEvents()
	-- 注册 BackpackRetrunButton 的事件
	self.__event_button_onInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked, self)
	self.infoButton.onClick:AddListener(self.__event_button_onInfoButtonClicked__)
end

function SelectBoxItemCls:UnregisterControlEvents()
	-- 取消注册 BackpackRetrunButton 的事件
	if self.__event_button_onInfoButtonClicked__ then
		self.infoButton.onClick:RemoveListener(self.__event_button_onInfoButtonClicked__)
		self.__event_button_onInfoButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function SelectBoxItemCls:OnInfoButtonClicked()
	self.callback:Invoke(self.id)
end

function SelectBoxItemCls:ShowPanel()
	local data = require "StaticData.ItemBox":GetData(self.id)
	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"
	local num = data:GetItemNum()
	local itemId = data:GetItemID()
	self.countLabel.text = num
	local _,data,itemName,iconPath,itemType = gametool.GetItemDataById(itemId)
	utility.LoadSpriteFromPath(iconPath,self.ItemIcon)
	self.nameLabel.text = itemName
	local color = gametool.GetItemColorByType(itemType,data)

	-- 显示/隐藏 碎片图标 --
    if itemType == "RoleChip" or  itemType == "EquipChip" then
        self.DebrisIcon:SetActive(true)
        self.DebrisCorner:SetActive(true)
    else
    	self.DebrisIcon:SetActive(false)
        self.DebrisCorner:SetActive(false)
    end
	
 	PropUtility.AutoSetRGBColor(self.colorFrame,color)
end

function SelectBoxItemCls:SetButtonState(id)
	if id == self.id then
		self.OnSelectState:SetActive(true)
	else
		self.OnSelectState:SetActive(false)
	end
end

function SelectBoxItemCls:GetId()
	return self.id
end

return SelectBoxItemCls