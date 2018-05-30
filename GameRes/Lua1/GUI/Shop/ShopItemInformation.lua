local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "LUT.StringTable"

---------------------------------------------------------------------
local ShopItemInformationCls = Class(BaseNodeClass)
windowUtility.SetMutex(ShopItemInformationCls, true)

function ShopItemInformationCls:Ctor()
end

function ShopItemInformationCls:OnWillShow(itemId,name,itemNum,needItemID,needItemNum,itemDesc,iconPath,itemType,
	shopId,IconSprite,shopType,itemColor)
	self.itemId = itemId
	self.name = name
	self.itemNum = itemNum
	self.needItemID = needItemID
	self.needItemNum = needItemNum
	self.itemDesc = itemDesc
	self.iconPath = iconPath
	self.itemType = itemType
	self.shopId = shopId
	self.IconSprite = IconSprite
	self.shopType = shopType
	self.itemColor = itemColor
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ShopItemInformationCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ShopItemInformation', function(go)
		self:BindComponent(go)
	end)
end

function ShopItemInformationCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ShopItemInformationCls:OnResume()
	-- 界面显示时调用
	ShopItemInformationCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:BringToFront()
	--self:CardSuipianBagQueryRequest()
	--self:RobQueryRequest()

	self:InitItemView()
	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function ShopItemInformationCls:OnPause()
	-- 界面隐藏时调用
	ShopItemInformationCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function ShopItemInformationCls:OnEnter()
	-- Node Enter时调用
	ShopItemInformationCls.base.OnEnter(self)
end

function ShopItemInformationCls:OnExit()
	-- Node Exit时调用
	ShopItemInformationCls.base.OnExit(self)
end


function ShopItemInformationCls:IsTransition()
    return true
end

function ShopItemInformationCls:OnExitTransitionDidStart(immediately)
	ShopItemInformationCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function ShopItemInformationCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ShopItemInformationCls:InitControls()
	local transform = self:GetUnityTransform()
	self.ShopItemInformationIcon = transform:Find('Base/ShopItemInformationBase/ShopItemInformationIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ShopItemInformationDescriptionLabel = transform:Find('Base/ShopItemInformationDescriptionLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ShopItemInformationNameLabel = transform:Find('Base/ShopItemInformationNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ShopItemInformationNumLabel = transform:Find('Base/ShopItemInformationNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ShopItemInformationRetrunButton = transform:Find('Base/ShopItemInformationRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ShopItemInformationBuyButton = transform:Find('Base/ShopItemInformationBuyButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.infomationButton = transform:Find('Base/ShopItemInformationButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--self.ShopItemInformationCancelButton = transform:Find('Base/ShopItemInformationCancelButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--self.InformationBoxBase = transform:Find('Base/InformationBox/InformationBoxBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ShopItemInformationPossessionNumLabel = transform:Find('Base/InformationBox/HadNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--self.ShopItemInformationBuyNumLabel = transform:Find('Base/InformationBox/ShopItemInformationBuyNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ShopItemInformationPriceNumLabel = transform:Find('Base/InformationBox/BuyNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.tweenObjectTrans = transform:Find('Base')

	self.currencyIcon = transform:Find('Base/InformationBox/currencyIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.FrameTrans = transform:Find('Base/Frame')
	self.ChipObj = transform:Find('Base/Chip').gameObject
	self.DebrisIcon = transform:Find('Base/DebrisIcon').gameObject
	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	-- TODO添加常量
	--self.needItemIDEnum = {Diamond= 10410001,Gold=10410002,Shengwang = 10410004}
	self.currencyIconPath = {"UI/Atlases/TheMain/TheMain_DiamondIcon","UI/Atlases/TheMain/TheMain_MoneyIcon","UI/Atlases/Icon/gongzhubi_xiao"}

	self.myGame = utility:GetGame()
end


function ShopItemInformationCls:RegisterControlEvents()
	-- 注册 ShopItemInformationRetrunButton 的事件
	self.__event_button_onShopItemInformationRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnShopItemInformationRetrunButtonClicked, self)
	self.ShopItemInformationRetrunButton.onClick:AddListener(self.__event_button_onShopItemInformationRetrunButtonClicked__)
	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnShopItemInformationRetrunButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)
	-- 注册 ShopItemInformationBuyButton 的事件
	self.__event_button_onShopItemInformationBuyButtonClicked__ = UnityEngine.Events.UnityAction(self.OnShopItemInformationBuyButtonClicked, self)
	self.ShopItemInformationBuyButton.onClick:AddListener(self.__event_button_onShopItemInformationBuyButtonClicked__)

	 --注册 infomationButton 的事件
	self.__event_button_oninfomationButtonClicked__ = UnityEngine.Events.UnityAction(self.OninfomationButtonClicked, self)
	self.infomationButton.onClick:AddListener(self.__event_button_oninfomationButtonClicked__)

end

function ShopItemInformationCls:UnregisterControlEvents()
	-- 取消注册 ShopItemInformationRetrunButton 的事件
	if self.__event_button_onShopItemInformationRetrunButtonClicked__ then
		self.ShopItemInformationRetrunButton.onClick:RemoveListener(self.__event_button_onShopItemInformationRetrunButtonClicked__)
		self.__event_button_onShopItemInformationRetrunButtonClicked__ = nil
	end
	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
	-- 取消注册 ShopItemInformationBuyButton 的事件
	if self.__event_button_onShopItemInformationBuyButtonClicked__ then
		self.ShopItemInformationBuyButton.onClick:RemoveListener(self.__event_button_onShopItemInformationBuyButtonClicked__)
		self.__event_button_onShopItemInformationBuyButtonClicked__ = nil
	end

	-- 取消注册 infomationButton 的事件
	if self.__event_button_oninfomationButtonClicked__ then
		self.infomationButton.onClick:RemoveListener(self.__event_button_oninfomationButtonClicked__)
		self.__event_button_oninfomationButtonClicked__ = nil
	end

end

function ShopItemInformationCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CRobQueryResult, self, self.OnRobQueryResponse)
end

function ShopItemInformationCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CRobQueryResult, self, self.OnRobQueryResponse)
end
-----------------------------------------------------------------------


function ShopItemInformationCls:RobQueryRequest()
	self.myGame:SendNetworkMessage( require"Network/ServerService".RobQueryRequest(0,-1))
end

function ShopItemInformationCls:ShopBuyRequest(shopType,itemId)
	self.myGame:SendNetworkMessage( require"Network/ServerService".ShopBuyRequest(shopType,itemId))
end


function ShopItemInformationCls:OnRobQueryResponse(msg)
	local itemCount = 0
	for i=1,#msg.repairBoxItems do
		if msg.repairBoxItems[i].repairBoxID == self.itemId then
			itemCount = itemCount + 1
		end
	end
	self:ResetBagCount(itemCount)
end


-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ShopItemInformationCls:OnShopItemInformationRetrunButtonClicked()
	--ShopItemInformationRetrunButton控件的点击事件处理
	self:Hide()
end

function ShopItemInformationCls:onClicked()
	self:Hide()
	self:ShopBuyRequest(self.shopType,self.shopId)
end
local function OnConfirmBuy(self)
	local windowManager = self:GetGame():GetWindowManager()  
	windowManager:CloseAll(true)
    local messageGuids = require "Framework.Business.MessageGuids"
    utility.GetGame():GetEventManager():PostNotification(messageGuids.OnCoinBuyWithDiamond)
end

local function OnCancelBuy(self)
  	
end
function ShopItemInformationCls:OnShopItemInformationBuyButtonClicked()
	--ShopItemInformationBuyButton控件的点击事件处理
	if self.needItemID == 10410002 then
		local result,func = utility.IsCoinEnough(self.needItemNum)
		if result then
			self:onClicked()
		else	
	   	    utility.ShowBuyConfirmDialog("金币不足，是否前往宝藏页面购买？", self, OnConfirmBuy, OnCancelBuy)
		end
	else
		self:onClicked()
	end
end

function ShopItemInformationCls:OninfomationButtonClicked()
	require "Utils.GameTools".ShowItemWin(self.itemId)
end
---------------------------------------------------------------------------
function ShopItemInformationCls:InitItemView()
	
	self.ShopItemInformationNameLabel.text = self.name
	
	self.ShopItemInformationDescriptionLabel.text = self.itemDesc
	
	self.ShopItemInformationNumLabel.text = self.itemNum
	
	self.ShopItemInformationPriceNumLabel.text = self.needItemNum
	
	self.ShopItemInformationIcon.sprite = self.IconSprite

	--local str = string.format("%s%s",ShopStringTable[3],self.itemNum) 
	--self.ShopItemInformationBuyNumLabel.text = str
	
	local gametool = require "Utils.GameTools"

	local _,_,_,path = gametool.GetItemDataById(self.needItemID)

	utility.LoadSpriteFromPath(path,self.currencyIcon)
	utility.LoadSpriteFromPath(self.iconPath,self.ShopItemInformationIcon)

	self:GetItemBagNum(self.itemType,self.itemId)

	local PropUtility = require "Utils.PropUtility"
    print("颜色 颜色 颜色 颜色", self.itemColor)
    PropUtility.AutoSetRGBColor(self.FrameTrans, self.itemColor)
	
	-- 设置碎片
	if self.itemType == "RoleChip" or  self.itemType == "EquipChip" then
    	self.ChipObj:SetActive(true)
    	self.DebrisIcon:SetActive(true)
    else
    	self.ChipObj:SetActive(false)
    	self.DebrisIcon:SetActive(false)
    end
end

function ShopItemInformationCls:GetItemBagNum(itemType,itemId)
	-- 查询Item数量
	if itemType == "Equip" then
		self:SelectEquipBagCountById(itemId)
	elseif itemType == "Item" then
		self:SelectItemBagCountById(itemId)
	elseif itemType == "RoleChip" then
		self:SelectRoleChipBagCountById(itemId)
	elseif itemType == "FactoryItem" then		
		self:RobQueryRequest()
	elseif itemType == "EquipChip" then
		self:SelectEquipDebrisBagCountById(itemId)
	end

end

function ShopItemInformationCls:SelectItemBagCountById(id)
	local UserDataType = require "Framework.UserDataType"

    local ItemBagData = self:GetCachedData(UserDataType.ItemBagData)
    local count = ItemBagData:GetItemCountById(id)
    self:ResetBagCount(count)
end

function ShopItemInformationCls:SelectEquipBagCountById(id)
	local UserDataType = require "Framework.UserDataType"

    local EquipBagData = self:GetCachedData(UserDataType.EquipBagData)
    local count = EquipBagData:GetItemCountById(id)

    self:ResetBagCount(count)
end

function ShopItemInformationCls:SelectEquipDebrisBagCountById(id)
	local UserDataType = require "Framework.UserDataType"

    local EquipDebrisBagData = self:GetCachedData(UserDataType.EquipDebrisBag)
    local count = EquipDebrisBagData:GetItemCountById(id)
    self:ResetBagCount(count)
end

function ShopItemInformationCls:SelectRoleChipBagCountById(id)
	local UserDataType = require "Framework.UserDataType"

    local EquipDebrisBagData = self:GetCachedData(UserDataType.CardChipBagData)
    local count = EquipDebrisBagData:GetItemCountById(id)
    self:ResetBagCount(count)
end

function ShopItemInformationCls:ResetBagCount(count)
	--local str = string.format("%s%s",ShopStringTable[4],count)
	self.ShopItemInformationPossessionNumLabel.text = count
end

return ShopItemInformationCls