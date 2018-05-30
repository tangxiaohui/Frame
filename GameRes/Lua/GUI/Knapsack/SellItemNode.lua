local BaseNodeClass = require "GUI.Knapsack.ItemBase"
local utility = require "Utils.Utility"

local SellItemNode = Class(BaseNodeClass)

function SellItemNode:Ctor(parent,itemWidth,itemHigh)

end


function SellItemNode:OnInit()
	SellItemNode.base.OnInit(self)
	self:InitConctrl()
end

function SellItemNode:InitConctrl()
	local transform = self:GetUnityTransform()
	self.sellObj = transform:Find("ItemSellInfo").gameObject
	self.ItemSellInfoText = transform:Find('ItemSellInfo/ItemSellInfoText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.sellObj:SetActive(true)
	self.ItemAttributeLabel = transform:Find('ItemAttributeLabel').gameObject
end

function SellItemNode:OnResume()
	SellItemNode.base.OnResume(self)
end
function SellItemNode:OnPause()
	-- 界面隐藏时调用
	SellItemNode.base.OnPause(self)
end

local function DelaySetItemPrice(self,price)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	self.ItemSellInfoText.text = price
	self.ItemAttributeLabel.gameObject:SetActive(false)
	
end

function SellItemNode:ResetItem()
	SellItemNode.base.ResetItem(self,self.data)
	-- coroutine.start(DelaySetItemPrice,self,self.price)
	self:StartCoroutine(DelaySetItemPrice, self.price)
end
local function GetPrice(level,data)
	local price=0
	local EquipStrengthen= require "StaticData.EquipStrengthen"
	for i=1,level-1 do
		local EquipStrengthenData = EquipStrengthen:GetData(i)
		if data:GetEquipType()==2 then
			--debug_print(EquipStrengthenData:GetADefeneNeedCoin(),math.floor(EquipStrengthenData:GetADefeneNeedCoin()))
			price=price+EquipStrengthenData:GetADefeneNeedCoin()
		else
			price=price+EquipStrengthenData:GetAttackNeedCoin()
		--	debug_print(price,level)
		end

		
	
	end
	price=price*0.7
	--debug_print(price,level)
	price =price + data:GetPrice()
	--debug_print(price,level)
	-- local price = data:GetPrice()
	-- require "StaticData.Equip":GetData(id):GetType()
	--debug_print("price",price,data:GetLevel())
    return math.floor(price)
end
function SellItemNode:OnBind(data,index)
	self.data = data
	local price
	local itemType = data:GetKnapsackItemType()

	if itemType == KKnapsackItemType_EquipNormal then
		--debug_print(data:GetEquipType(),"  sjgdjsgdjsdgjh",data:GetLevel())
		price = GetPrice(data:GetLevel(),data)

	elseif itemType == KKnapsackItemType_EquipDebris then
		tempPrice = data:GetPrice()
		price = tempPrice * data:GetNumber()
	end

	self.price = price
	SellItemNode.base.OnBind(self,data,index)
	
end


function SellItemNode:OnInfoButtonClicked()
	SellItemNode.base.SellItemCallback(self,self.index,self.price,self.data)
end



-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------


return SellItemNode