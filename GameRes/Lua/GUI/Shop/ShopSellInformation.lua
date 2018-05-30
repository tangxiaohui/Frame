local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
local ShopSellInformationCls = Class(BaseNodeClass)
windowUtility.SetMutex(ShopSellInformationCls, true)

function ShopSellInformationCls:Ctor()
end
function ShopSellInformationCls:OnWillShow(sellDict)
	self.sellDict = sellDict
	-- self.countList = countList
	-- self.itemUIdList = itemUIdList
	-- self.smallSell = smallSell
	-- self.middleSell = middleSell
	-- self.bigSell = bigSell
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ShopSellInformationCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ShopSellInformation', function(go)
		self:BindComponent(go)
	end)
end

function ShopSellInformationCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ShopSellInformationCls:OnResume()
	-- 界面显示时调用
	ShopSellInformationCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	--elf:InitView()
	self:ResetView()
	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function ShopSellInformationCls:OnPause()
	-- 界面隐藏时调用
	ShopSellInformationCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function ShopSellInformationCls:OnEnter()
	-- Node Enter时调用
	ShopSellInformationCls.base.OnEnter(self)
end

function ShopSellInformationCls:OnExit()
	-- Node Exit时调用
	ShopSellInformationCls.base.OnExit(self)
end

function ShopSellInformationCls:IsTransition()
    return true
end

function ShopSellInformationCls:OnExitTransitionDidStart(immediately)
	ShopSellInformationCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function ShopSellInformationCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ShopSellInformationCls:InitControls()
	local transform = self:GetUnityTransform()
	
	self.ShopSellInformationRetrunButton = transform:Find('Base/ShopItemInformationRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ShopSellInformationQueDingButton = transform:Find('Base/ShopSellInformationQueDingButton'):GetComponent(typeof(UnityEngine.UI.Button))

	self.sellLayout = transform:Find("Base/SellLayout")
	self.ShopSellInformationNumLabel = transform:Find('Base/ShopSellInformationNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.tweenObjectTrans = transform:Find('Base')
	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
end


function ShopSellInformationCls:RegisterControlEvents()
	-- 注册 ShopSellInformationRetrunButton 的事件
	self.__event_button_onShopSellInformationRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnShopSellInformationRetrunButtonClicked, self)
	self.ShopSellInformationRetrunButton.onClick:AddListener(self.__event_button_onShopSellInformationRetrunButtonClicked__)

	-- 注册 ShopSellInformationQueDingButton 的事件
	self.__event_button_onShopSellInformationQueDingButtonClicked__ = UnityEngine.Events.UnityAction(self.OnShopSellInformationQueDingButtonClicked, self)
	self.ShopSellInformationQueDingButton.onClick:AddListener(self.__event_button_onShopSellInformationQueDingButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnShopSellInformationRetrunButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)


end

function ShopSellInformationCls:UnregisterControlEvents()
	-- 取消注册 ShopSellInformationRetrunButton 的事件
	if self.__event_button_onShopSellInformationRetrunButtonClicked__ then
		self.ShopSellInformationRetrunButton.onClick:RemoveListener(self.__event_button_onShopSellInformationRetrunButtonClicked__)
		self.__event_button_onShopSellInformationRetrunButtonClicked__ = nil
	end

	-- 取消注册 ShopSellInformationQueDingButton 的事件
	if self.__event_button_onShopSellInformationQueDingButtonClicked__ then
		self.ShopSellInformationQueDingButton.onClick:RemoveListener(self.__event_button_onShopSellInformationQueDingButtonClicked__)
		self.__event_button_onShopSellInformationQueDingButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function ShopSellInformationCls:RegisterNetworkEvents()
end

function ShopSellInformationCls:UnregisterNetworkEvents()
end

function ShopSellInformationCls:ItemBagSellRequest(id)
	utility:GetGame():SendNetworkMessage( require"Network/ServerService".ItemBagSellRequest(id))
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ShopSellInformationCls:OnShopSellInformationRetrunButtonClicked()
	--ShopSellInformationRetrunButton控件的点击事件处理
	self:Close()
end

function ShopSellInformationCls:OnShopSellInformationQueDingButtonClicked()
	--ShopSellInformationQueDingButton控件的点击事件处理
	if self.sellString ~= "" then
		self:ItemBagSellRequest(self.sellString)
	end
	self.sellString = ""
	self:Close()
end

-------------------------------------------------------------------------


function ShopSellInformationCls:ResetView()
	self.sellList = {}
	-- 出售的物品uid列表
	self.sellString = ""
	-- 出售的价格
	local totalPrices = 0

	local keys = self.sellDict:GetKeys()

	local nodeCls = require "GUI.Shop.ShopSellItemNode"
	for i = 1 ,#keys do
		
		local uid = keys[i]
		local count = self.sellDict:GetEntryByKey(uid)

		local UserDataType = require "Framework.UserDataType"
		local itemDataBag = self:GetCachedData(UserDataType.ItemBagData)
		local data = itemDataBag:GetItem(uid)
		local id = data:GetId()


		local node = nodeCls.New(self.sellLayout,uid,count)
		self:AddChild(node)

		self.sellList[#self.sellList + 1] = node
		self.sellString = string.format("%s%s%s",self.sellString,uid,",")
		print(self.sellString )

		local price = require "StaticData.Item":GetData(id):GetMaxNumber()
		price = price * count
		totalPrices = totalPrices + price 
	end
	self.ShopSellInformationNumLabel.text = totalPrices

end

return ShopSellInformationCls