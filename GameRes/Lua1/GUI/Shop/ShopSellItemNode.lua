require "Const"


local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"

local ShopSellItemNodeCls = Class(BaseNodeClass)

function ShopSellItemNodeCls:Ctor(parent,uid,count)
	self.parent = parent
	self.uid = uid
	self.count = count
end


-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ShopSellItemNodeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/MyGeneralItem', function(go)
		self:BindComponent(go,false)
	end)
end

function ShopSellItemNodeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function ShopSellItemNodeCls:OnResume()
	-- 界面显示时调用
	ShopSellItemNodeCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:ResetItem(self.uid,self.count)
end

function ShopSellItemNodeCls:OnPause()
	-- 界面隐藏时调用
	ShopSellItemNodeCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function ShopSellItemNodeCls:OnEnter()
	-- Node Enter时调用
	ShopSellItemNodeCls.base.OnEnter(self)
end

function ShopSellItemNodeCls:OnExit()
	-- Node Exit时调用
	ShopSellItemNodeCls.base.OnExit(self)
end



-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ShopSellItemNodeCls:InitControls()
	local transform = self:GetUnityTransform()

	self.transform = transform
	self.rectTransform = transform:GetComponent(typeof(UnityEngine.RectTransform))
	-- 数量
	self.countLabel = transform:Find('GeneralItemNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 名称
	self.nameLabel = transform:Find('ItemNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 图标
	self.ItemIcon = transform:Find('ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 颜色
	self.colorFrame = transform:Find('Frame')
	-- 碎片图片
	self.DebrisIcon = transform:Find('DebrisIcon'):GetComponent(typeof(UnityEngine.UI.Image))
end


function ShopSellItemNodeCls:RegisterControlEvents()
	-- 注册 BackpackRetrunButton 的事件
	-- self.__event_button_onInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked, self)
	-- self.infoButton.onClick:AddListener(self.__event_button_onInfoButtonClicked__)
end

function ShopSellItemNodeCls:UnregisterControlEvents()
	-- 取消注册 BackpackRetrunButton 的事件
	-- if self.__event_button_onInfoButtonClicked__ then
	-- 	self.infoButton.onClick:RemoveListener(self.__event_button_onInfoButtonClicked__)
	-- 	self.__event_button_onInfoButtonClicked__ = nil
	-- end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------


--------------------------------------------------------------------------

function ShopSellItemNodeCls:ResetItem(uid,count)
	-- 重置数据
	--if dataType
	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"
	
	local UserDataType = require "Framework.UserDataType"
	local itemDataBag = self:GetCachedData(UserDataType.ItemBagData)
	local data = itemDataBag:GetItem(uid)
	local id = data:GetId()

	local _,itemData,name,iconPath,itemType = gametool.GetItemDataById(id)

	color = itemData:GetColor()

	self.nameLabel.gameObject:SetActive(true)
	self.nameLabel.text = name

	self.countLabel.text = count

	utility.LoadSpriteFromPath(iconPath,self.ItemIcon)

	-- 
	if color == nil then 
		color = gametool.GetItemColorByType(itemType,itemData)
	end
	
	-- 设置样式
	PropUtility.AutoSetRGBColor(self.colorFrame,color)

end


----------------------------------------------------------------



return ShopSellItemNodeCls