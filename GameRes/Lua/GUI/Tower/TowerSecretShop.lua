local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
require "LUT.StringTable"

local TowerSecretShop = Class(BaseNodeClass)
windowUtility.SetMutex(TowerSecretShop, true)

function  TowerSecretShop:Ctor()
	
end

function TowerSecretShop:OnWillShow(id)
	self.id = id
end

function  TowerSecretShop:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/secretshop",function(go)
		self:BindComponent(go)
	end)
end

function TowerSecretShop:OnComponentReady()
	self:InitControls()
end

function TowerSecretShop:OnResume()
	TowerSecretShop.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.transform

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function TowerSecretShop:OnPause()
	TowerSecretShop.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function TowerSecretShop:OnEnter()
	TowerSecretShop.base.OnEnter(self)
	self:LoadPanel(self.id)
end

function TowerSecretShop:OnExit()
	TowerSecretShop.base.OnExit(self)
end

function TowerSecretShop:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function  TowerSecretShop:InitControls()
	local transform = self:GetUnityTransform()
	self.transform = transform:Find("Base")

	self.itemNum = transform:Find("Base/Itemlayout/ShopItem/ShopItemNumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.itemName = transform:Find("Base/Itemlayout/ShopItem/ShopItemNameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.itemPrice = transform:Find("Base/Itemlayout/ShopItem/ShopItemValueNumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.itemPriceIcon = transform:Find("Base/Itemlayout/ShopItem/ShopCurrencyIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	self.itemIcon = transform:Find("Base/Itemlayout/ShopItem/ShopItemIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	self.itemFrame = transform:Find("Base/Itemlayout/ShopItem/Frame/Colors/Image"):GetComponent(typeof(UnityEngine.UI.Image))
	self.confirmButton = transform:Find("Base/Itemlayout/ShopItem/Button"):GetComponent(typeof(UnityEngine.UI.Button))
	self.playerDia = transform:Find("Base/Currency/ShopCurrencyNumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.returnButton = transform:Find("Base/ShopRetrunButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.DebrisCorner = transform:Find("Base/Itemlayout/ShopItem/DebrisIcon").gameObject
	self.DebrisIcon = transform:Find("Base/Itemlayout/ShopItem/Chip").gameObject

	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function TowerSecretShop:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function TowerSecretShop:OnExitTransitionDidStart(immediately)
    TowerSecretShop.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.transform

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

----------------------------------------------------------------------------
--事件处理--
----------------------------------------------------------------------------
function TowerSecretShop:RegisterControlEvents()
	--注册退出事件
	self._event_button_onreturnButtonClicked_ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.returnButton.onClick:AddListener(self._event_button_onreturnButtonClicked_)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	self._event_button_onConfirmButtonClicked_ = UnityEngine.Events.UnityAction(self.OnConfirmButtonClicked,self)
	self.confirmButton.onClick:AddListener(self._event_button_onConfirmButtonClicked_)

end

function TowerSecretShop:UnregisterControlEvents()
	--取消注册退出事件
	if self._event_button_onreturnButtonClicked_ then
		self.returnButton.onClick:RemoveListener(self._event_button_onreturnButtonClicked_)
		self._event_button_onreturnButtonClicked_ = nil
	end

	if self._event_button_onConfirmButtonClicked_ then
		self.confirmButton.onClick:RemoveListener(self._event_button_onConfirmButtonClicked_)
		self._event_button_onConfirmButtonClicked_ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function TowerSecretShop:RegisterNetworkEvents()
	utility:GetGame():RegisterMsgHandler(net.S2CBuyResult,self,self.BuyResult)
	utility:GetGame():RegisterMsgHandler(net.S2CLoadPlayerResult,self,self.UpdatePlayerData)
end

function TowerSecretShop:UnregisterNetworkEvents()
	utility:GetGame():UnRegisterMsgHandler(net.S2CBuyResult,self,self.BuyResult)
	utility:GetGame():UnRegisterMsgHandler(net.S2CLoadPlayerResult,self,self.UpdatePlayerData)
end

function TowerSecretShop:LoadPanel(id)
	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"
	local shopData = require "StaticData.Shop.TowerSecretShop":GetData(id)
	self.itemCount = shopData:GetItemNum()
	self.itemId = shopData:GetItemID()
	self.itemNum.text = self.itemCount
	local _,data,itemName,iconPath,itemType = gametool.GetItemDataById(self.itemId)
	utility.LoadSpriteFromPath(iconPath,self.itemIcon)
	if shopData:GetItemColor() == -1 or shopData:GetItemColor() == nil then
		hzj_print("	hzj_print(shopData:GetItemColor() == -1 or shopData:GetItemColor() == nil )")
		local color = gametool.GetItemColorByType(itemType,data)
		self.itemColor = color
 		PropUtility.AutoSetRGBColor(self.itemFrame,color)
	else
		hzj_print("shopData:GetItemColor()",data:GetColor())

		self.itemColor = gametool.GetItemColorByType(itemType,data)
		PropUtility.AutoSetRGBColor(self.itemFrame,data:GetColor())
	end
	if itemType == "RoleChip" or  itemType == "EquipChip" then
        self.DebrisIcon:SetActive(true)
        self.DebrisCorner:SetActive(true)
    else
    	self.DebrisIcon:SetActive(false)
        self.DebrisCorner:SetActive(false)
    end
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    local diamond = userData:GetDiamond()
	self.playerDia.text = diamond
	self.itemName.text = itemName
	local _,_,_,iconPath,_ = gametool.GetItemDataById(shopData:GetNeedItemID())
	utility.LoadSpriteFromPath(iconPath,self.itemPriceIcon)
	self.needDiamond=shopData:GetNeedItemNum()
	self.itemPrice.text =  shopData:GetNeedItemNum()
end

function TowerSecretShop:OnReturnButtonClicked()
	self:Close(true)
end

function TowerSecretShop:BuyResult(msg)
	self:ShowAwardPanel(self.id)
	self:OnReturnButtonClicked()
end

function TowerSecretShop:ShowAwardPanel(id)
	local itemstables = {}
	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"
	local _,data,itemName,iconPath,itemType = gametool.GetItemDataById(self.itemId)
	itemstables[1] = {}
	itemstables[1].id = self.itemId
	itemstables[1].count = self.itemCount
	itemstables[1].color = self.itemColor

	local windowManager = self:GetGame():GetWindowManager()
    local AwardCls = require "GUI.Task.GetAwardItem"
    windowManager:Show(AwardCls,itemstables)
end

function TowerSecretShop:BuyRequest()
	utility:GetGame():SendNetworkMessage( require "Network.ServerService".BuyRequest())
end
function TowerSecretShop:UpdatePlayerData()
	
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)

	self.playerDia.text = userData:GetDiamond()


end
local function OnConfirmBuy(self)
   
	self:BuyRequest()

end

local function OnCancelBuy(self)
end
function TowerSecretShop:OnConfirmButtonClicked()
	local utility = require "Utils.Utility"
	utility.ShowBuyConfirmDialog("是否花费"..self.needDiamond.."钻石购买此物品？", self, OnConfirmBuy, OnCancelBuy)
end

return TowerSecretShop