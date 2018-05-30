local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "LUT.StringTable"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ShopItemCls = Class(BaseNodeClass)

function ShopItemCls:Ctor(parent)
	self.parent = parent
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ShopItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ShopItem', function(go)
		self:BindComponent(go,false)
	end)
end

function ShopItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function ShopItemCls:OnResume()
	-- 界面显示时调用
	ShopItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function ShopItemCls:OnPause()
	-- 界面隐藏时调用
	ShopItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function ShopItemCls:OnEnter()
	-- Node Enter时调用
	ShopItemCls.base.OnEnter(self)
end

function ShopItemCls:OnExit()
	-- Node Exit时调用
	ShopItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ShopItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ShopItemIcon = transform:Find('ShopItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ColorTrans = transform:Find('Frame/Colors')
	self.ChipObj = transform:Find("Chip").gameObject
	self.DebrisIcon = transform:Find("DebrisIcon").gameObject
	self.ShopItemNumLabel = transform:Find('ShopItemNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ShopItemNameLabel = transform:Find('ShopItemNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ShopItemDiamondIcon = transform:Find('ShopItemDiamondIcon').gameObject
	self.ShopItemGoldIcon = transform:Find('ShopItemGoldIcon').gameObject
	self.ShopCurrencyIcon = transform:Find('ShopCurrencyIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ShopItemValueNumLabel = transform:Find('ShopItemValueNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ShopItemButton = self.ShopItemIcon.transform:GetComponent(typeof(UnityEngine.UI.Button))
	self.sellOut = transform:Find('SellOut').gameObject

	self.chipImage = self.ChipObj.transform:GetComponent(typeof(UnityEngine.UI.Image))
	self.colorImage = self.ColorTrans.transform:Find('Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.hslMarterial = self.colorImage.material
	self.grayMarterial = utility.GetGrayMaterial()

	self.myGame = utility:GetGame()
end


function ShopItemCls:RegisterControlEvents()
	self.__event_button_onShopItemButtonClicked__ = UnityEngine.Events.UnityAction(self.OnShopItemIconClicked, self)
	self.ShopItemButton.onClick:AddListener(self.__event_button_onShopItemButtonClicked__)
end

function ShopItemCls:UnregisterControlEvents()
	if self.__event_button_onShopItemButtonClicked__ then
		self.ShopItemButton.onClick:RemoveListener(self.__event_button_onShopItemButtonClicked__)
		self.__event_button_onShopItemButtonClicked__ = nil
	end
end

function ShopItemCls:RegisterNetworkEvents()

end

function ShopItemCls:UnregisterNetworkEvents()

end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ShopItemCls:OnShopItemIconClicked()
	-- TODO:装备类型判断

	local windowManager = self.myGame:GetWindowManager()
    windowManager:Show(require "GUI.Shop.ShopItemInformation",self.itemId,self.name,self.itemNum,self.needItemID,self.needItemNum,
    	self.itemDesc,self.iconPath,self.itemType,self.shopId,self.IconSprite,self.shopType,self.itemColor)
end


-----------------------------------------------------------------------

local function InitItemView(self)
	
	while(not self:IsReady())
		do
		coroutine.step(1)
	end
	-- 折扣
	local price = self.needItemNum * self.discount
	self.needItemNum = math.ceil(price)

	self.ShopItemNameLabel.text = self.name
	self.ShopItemNumLabel.text = self.itemNum
	self.ShopItemValueNumLabel.text = self.needItemNum
	

	local gameTool = require "Utils.GameTools"
	
	-- 设置货币图标
	local _,data,_,currencyIcon,itemType = gameTool.GetItemDataById(self.needItemID)
	utility.LoadSpriteFromPath(currencyIcon,self.ShopCurrencyIcon)

	-- 设置图片图标
	utility.LoadSpriteFromPath(self.iconPath,self.ShopItemIcon)

	
	local PropUtility = require "Utils.PropUtility"
    --print("颜色 颜色 颜色 颜色", self.itemColor)
    PropUtility.AutoSetRGBColor(self.ColorTrans, self.itemColor)

    -- 是否为碎片
    if self.itemType == "RoleChip" or  self.itemType == "EquipChip" then
    	self.ChipObj:SetActive(true)
    	self.DebrisIcon:SetActive(true)    	
    else
    	self.ChipObj:SetActive(false)
    	self.DebrisIcon:SetActive(false)
    end

	if self.state == 0 then

		self.ShopItemButton.interactable = true
		self.sellOut:SetActive(false)
		--self.colorImage.material = self.hslMarterial
		--self.chipImage.material = nil
		self.ShopItemNumLabel.color = UnityEngine.Color(1,1,1,1)
	elseif self.state == 1 then
		
		-- 是否可以重复购买
		--if self.buyOnlyOne == 1 then			
		--	self.ShopItemButton.interactable = true
		--	return 
		--end
		self.sellOut:SetActive(true)
		self.ShopItemButton.interactable = false
		--self.colorImage.material = self.grayMarterial
		--self.colorImage.color = UnityEngine.Color(1,1,1,1)
		self.colorImage.color = UnityEngine.Color(0.494117,0.494117,0.494117,1)
		self.chipImage.material = self.grayMarterial
		self.ShopItemNumLabel.color = UnityEngine.Color(0.494117,0.494117,0.494117,1)
	end
end


function ShopItemCls:GetItemData(id,shopType)
	-- 获取Item Data
	-- TODO : Add商店类型
	local shopData =utility.GetShopData(shopType):GetData(id)

	-- if shopType == KShopType_Normal then		
	-- 	-- 普通商店
		
	-- 	shopData = require "StaticData.Shop.ShopData":GetData(id)
	-- elseif shopType == KShopType_ProtectPrincess then
	-- 	-- 保护公主商店

	-- 	shopData = require "StaticData.Shop.DefendThePrincessShop":GetData(id)
	-- elseif shopType == KShopType_Arena then
	-- 	-- 竞技场商店
		
	-- 	shopData = require "StaticData.Shop.ArenaShopData":GetData(id)
	-- elseif shopType == KShopType_BlackMarket then
	-- 	-- 黑市商店
		
	-- 	shopData = require "StaticData.Shop.BlackMarketData":GetData(id)
	-- 	-- error("黑市商店 shopData is null")
	-- elseif shopType == KShopType_ArmyGroup then
	-- 	--军团商店
	-- 	shopData = require "StaticData.Shop.LegionShop":GetData(id)
	-- elseif shopType == KShopType_Gem then
	-- 	-- 宝石商店
	-- 	shopData = require "StaticData.Shop.GemShop":GetData(id)
	-- elseif shopType == KShopType_GuildPoint then
	-- 	--公会积分战
	-- 	shopData = require "StaticData.Shop.PointFightShop":GetData(id)
	-- elseif shopType == KShopType_Tower then
	-- 	--爬塔
	-- 	shopData = require "StaticData.Shop.TowerShopMgr":GetData(id)
	-- elseif shopType == KShopType_IntegralShop then
	-- 	--积分抽卡商店
	-- 	shopData = require "StaticData.Shop.DrawPointShop":GetData(id)
	
	-- elseif shopType == KShopType_LotteryShop then
	-- 	--积分抽卡商店
	-- 	debug_print("GetData(id)",id)
	-- 	shopData = require "StaticData.Shop.AroundShop":GetData(id)
	
	-- end

	local itemId = shopData:GetItemID()
	
	local gametool = require "Utils.GameTools"
	local infoData,data,name,iconPath,itemType = gametool.GetItemDataById(itemId)

	local itemNum = shopData:GetItemNum()
	local itemColor = shopData:GetItemColor()
	local needItemID = shopData:GetNeedItemID()
	local needItemNum = shopData:GetNeedItemNum()
	local buyOnlyOne = shopData:GetBuyOnlyOne()
	local itemDesc
	if itemType  == "RoleChip"  or self.itemType == "EquipChip" then
		itemDesc =   string.format("%s%s",ShopStringTable[5],name) --"集齐一定数量可以获得"..name
	else
		itemDesc = infoData:GetDesc()
	end

	-- 名称
	self.name = name
	-- 图片路径
	self.iconPath = iconPath
	-- 数量
	self.itemNum = itemNum
	-- 颜色
	self.itemColor = gametool.GetItemColorByType(itemType,data)
	-- 购物使用Item ID
	self.needItemID = needItemID
	-- 购买使用Item 数量
	self.needItemNum = needItemNum
	-- 是否可以重复购买
	self.buyOnlyOne = buyOnlyOne
	-- 描述
	self.itemDesc = itemDesc
	-- ID
	self.itemId = itemId
	-- Item类型
	self.itemType = itemType

end

function ShopItemCls:ResteInfo(itemMsg,shopType,discount)
	self:GetItemData(itemMsg.id,shopType)
	self.state = itemMsg.state
	self.shopId = itemMsg.id
	self.shopType = shopType
	self.discount = discount
	-- coroutine.start(InitItemView,self)
	self:StartCoroutine(InitItemView)
end

function ShopItemCls:GetNodeActive()
	-- node 是否显示
	return self.nodeActiveState
end

function ShopItemCls:SetNodeActice(active)
	-- 设置node 显示状态
	self.nodeActiveState = active
end


return ShopItemCls