local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local LimitDiscountItemCls = Class(BaseNodeClass)

function LimitDiscountItemCls:Ctor(itemData,customData,parent,index,type,activityId)
	self.itemData=itemData
	self.parent=parent
	self.customData=customData
	self.index=index
	self.type=type
	self.activityId=activityId
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function LimitDiscountItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/LimitDiscountItem', function(go)
		self:BindComponent(go)
	end)
end

function LimitDiscountItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LinkComponent(self.parent)
end

function LimitDiscountItemCls:OnResume()
	-- 界面显示时调用
	LimitDiscountItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function LimitDiscountItemCls:OnPause()
	-- 界面隐藏时调用
	LimitDiscountItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function LimitDiscountItemCls:OnEnter()
	-- Node Enter时调用
	LimitDiscountItemCls.base.OnEnter(self)
end

function LimitDiscountItemCls:OnExit()
	-- Node Exit时调用
	LimitDiscountItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function LimitDiscountItemCls:InitControls()
	local transform = self:GetUnityTransform()
	-- self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.Box = transform:Find('Box'):GetComponent(typeof(UnityEngine.UI.Image))
	--名字
	self.IndexLabel = transform:Find('IndexLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
	self.layout = transform:Find('Item')
	self.BuyButton = transform:Find('BuyButton'):GetComponent(typeof(UnityEngine.UI.Button))

	--原价
	self.OriginPriceText = transform:Find('OriginPriceText'):GetComponent(typeof(UnityEngine.UI.Text))
	--现价
	self.NowPriceText = transform:Find('NowPriceText'):GetComponent(typeof(UnityEngine.UI.Text))
	--self.RedLineImage = transform:Find('RedLineImage'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.BuyTimesLabel = transform:Find('BuyTimesLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--购买次数提示
	self.BuyTimesText = transform:Find('BuyTimesText'):GetComponent(typeof(UnityEngine.UI.Text))


	self:InitViews()
end

function LimitDiscountItemCls:InitViews()


	local GameTools = require "Utils.GameTools"
    local _,staticData,name,iconPath,itemType = GameTools.GetItemDataById(self.itemData.items[1].itemId)
	self.IndexLabel.text = name
	hzj_print(self.index,"self.index")
	self.limitDiscountInfoData = self.customData.sale.itemGroups[self.index].items[1]
	self:SetCurrentView()

	self.item = require "GUI.Active.AwardGeneralItem".New(self.layout,self.itemData.items[1].itemId,self.itemData.items[1].count,nil,itemType)
	self:AddChild(self.item)

end


function LimitDiscountItemCls:SetCurrentView()

	local remainCount = self.limitDiscountInfoData.maxTimes-self.limitDiscountInfoData.numberOfPurchases

	if remainCount <= 0 then
		self.BuyButton.enabled = false
		self.BuyButton.targetGraphic.material = utility.GetGrayMaterial()
	else
		self.BuyButton.enabled = true
		self.BuyButton.targetGraphic.material = utility.GetCommonMaterial()
	end

	self.BuyTimesText.text = remainCount.."/"..self.limitDiscountInfoData.maxTimes
	self.OriginPriceText.text = self.limitDiscountInfoData.original_price
	self.NowPriceText.text =  self.limitDiscountInfoData.current_price
	-- body
end
function LimitDiscountItemCls:ResetViews()
	
end


function LimitDiscountItemCls:RegisterControlEvents()

	-- 注册 BuyButton 的事件
	self.__event_button_onBuyButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBuyButtonClicked, self)
	self.BuyButton.onClick:AddListener(self.__event_button_onBuyButtonClicked__)

end

function LimitDiscountItemCls:UnregisterControlEvents()

	-- 取消注册 BuyButton 的事件
	if self.__event_button_onBuyButtonClicked__ then
		self.BuyButton.onClick:RemoveListener(self.__event_button_onBuyButtonClicked__)
		self.__event_button_onBuyButtonClicked__ = nil
	end

end

function LimitDiscountItemCls:RegisterNetworkEvents()
	  utility.GetGame():RegisterMsgHandler(net.S2COperationActivityPickItemResult, self, self.OperationActivityPickItemResult)

end

function LimitDiscountItemCls:UnregisterNetworkEvents()
	  utility.GetGame():UnRegisterMsgHandler(net.S2COperationActivityPickItemResult, self, self.OperationActivityPickItemResult)

end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function LimitDiscountItemCls:OperationActivityPickItemResult(msg)
--	hzj_print("msg",msg.activityType ,self.type , msg.activityId , self.activityId , msg.itemGroupId , self.itemData.id)
	
	local data  = msg.data.saleItemFlush.itemGroup.items[1]
	--hzj_print("msg",data.original_price,data.current_price,data.numberOfPurchases,data.maxTimes)
	if msg.activityType == self.type and msg.activityId == self.activityId and msg.itemGroupId == self.itemData.id then
		self.limitDiscountInfoData=data
		self:SetCurrentView()

	local modV = math.floor(self.itemData.items[1].itemId/100000)
		if modV==100 then

			local UserDataType = require "Framework.UserDataType"
			local cardBagData = self:GetCachedData(UserDataType.CardBagData)
			local card= cardBagData:GetRoleById(self.itemData.items[1].itemId)

			self.addCardDict = OrderedDictionary.New()
			if card ==nil then
				self.addCardDict:Add(self.itemData.items[1].itemId,self.itemData.items[1].itemId)
			end
			local windowManager = self:GetGame():GetWindowManager()
	   		windowManager:Show(require "GUI.GeneralCard.GetCardWin",self.itemData.items[1].itemId,addCardDict)
	   	elseif modV==101 then
			local gameTool = require "Utils.GameTools"
			gameTool.GetItemWin(self.itemData.items[1].itemId)
		else
			local items = {}
			items[#items+1]={}
			items[#items].id=self.itemData.items[1].itemId
			items[#items].count=self.itemData.items[1].count
			items[#items].color= -1--self.itemData.items[1].itemColor
			local windowManager = self:GetGame():GetWindowManager()
			local AwardCls = require "GUI.Task.GetAwardItem"
			windowManager:Show(AwardCls,items)
		end
	end
end

local function OnConfirmBuy(self)
	utility.GetGame():SendNetworkMessage(require "Network.ServerService".OperationActivityPickItemRequest(self.type,self.activityId,self.itemData.id))
   
end

local function OnCancelBuy(self)
  	
end


function LimitDiscountItemCls:OnBuyButtonClicked()


	utility.ShowBuyConfirmDialog("是否花费"..self.limitDiscountInfoData.current_price.."钻石购买折扣商品？", self, OnConfirmBuy, OnCancelBuy)

	--BuyButton控件的点击事件处理
	hzj_print(self.type,self.activityId,self.itemData.id)


end

return LimitDiscountItemCls
