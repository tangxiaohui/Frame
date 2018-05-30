local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local net = require "Network.Net"

local DaysFeverAwardList = Class(BaseNodeClass)

function  DaysFeverAwardList:Ctor(parent,id,tableStatus,index)
	self.parent = parent
	self.id = id 
	self.tableStatus = tableStatus
	self.index = index
end

function DaysFeverAwardList:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/7DayFeverIndex",function(go)
		self:BindComponent(go)
	end)
end

function DaysFeverAwardList:OnComponentReady()
	self:LinkComponent(self.parent)
	self:InitControls()
end

function DaysFeverAwardList:OnResume()
	DaysFeverAwardList.base.OnResume(self)
	self:RegisterControlEvents()
	self:LoadItem()
	self:RegisterNetworkEvenrs()
end

function DaysFeverAwardList:OnPause()
	DaysFeverAwardList.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function DaysFeverAwardList:OnEnter()
	DaysFeverAwardList.base.OnEnter(self)
end

function  DaysFeverAwardList:OnExit()
	DaysFeverAwardList.base.OnExit(self)
end

function  DaysFeverAwardList:InitControls()
	local transform = self:GetUnityTransform()

	self.activeGetButton = transform:Find("Button"):GetComponent(typeof(UnityEngine.UI.Button))
	self.getImage = transform:Find("Button"):GetComponent(typeof(UnityEngine.UI.Image))
	self.getText = transform:Find("Button/Text"):GetComponent(typeof(UnityEngine.UI.Text))
	self.descLabel = transform:Find("IndexLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.point = transform:Find("Layout")

	--已完成状态
	self.doneState = transform:Find("DoneText")
	self.base = transform:Find("Base"):GetComponent(typeof(UnityEngine.UI.Image))
	self.buyButton = transform:Find("BuyButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.buyButtonImage = transform:Find("BuyButton"):GetComponent(typeof(UnityEngine.UI.Image))
	self.priceText = self.buyButton.transform:Find("Text"):GetComponent(typeof(UnityEngine.UI.Text))
	self.itemIcon = self.buyButton.transform:Find("Image"):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.itemsObj = {}
	-- self.itemsicon = {}
	-- self.itemsnum = {}
	-- self.itemscolor = {}
	-- for i=1,4 do
	-- 	self.itemsObj[i] = self.point:Find("ItemBox"..i)
	-- end
	-- for i=1,4 do
	-- 	self.itemsicon[i] = self.itemsObj[i]:Find("Icon"):GetComponent(typeof(UnityEngine.UI.Image))
	-- end
	-- for i=1,4 do
	-- 	self.itemsnum[i] = self.itemsObj[i]:Find("ItemNumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	-- end
	-- for i=1,4 do
	-- 	self.itemscolor[i] = self.itemsObj[i]:Find("Frame"):GetComponent(typeof(UnityEngine.UI.Image))
	-- end
	self.GrayMaterial = utility.GetGrayMaterial()
	self.myGame = utility:GetGame()

end

function  DaysFeverAwardList:RegisterControlEvents()
	self._event_button_onActiveGetButtonClicked_ = UnityEngine.Events.UnityAction(self.OnActiveGetButtonClicked,self)
	self.activeGetButton.onClick:AddListener(self._event_button_onActiveGetButtonClicked_)

	self._event_button_onBuyButtonClicked_ = UnityEngine.Events.UnityAction(self.OnBuyButtonClicked,self)
	self.buyButton.onClick:AddListener(self._event_button_onBuyButtonClicked_)
end

function  DaysFeverAwardList:UnregisterControlEvents()
	if self._event_button_onActiveGetButtonClicked_ then
		self.activeGetButton.onClick:RemoveListener(self._event_button_onActiveGetButtonClicked_)
		self._event_button_onActiveGetButtonClicked_ = nil
	end
	if self._event_button_onBuyButtonClicked_ then
		self.buyButton.onClick:RemoveListener(self._event_button_onBuyButtonClicked_)
		self._event_button_onBuyButtonClicked_ = nil
	end
end

function DaysFeverAwardList:RegisterNetworkEvenrs()
	-- self.myGame:RegisterMsgHandler(net.ActivityGetAwardResult,self,self.OnActivityGetAwardResult)
end

function  DaysFeverAwardList:UnregisterNetworkEvents()
	-- self.myGame:UnRegisterMsgHandler(net.ActivityGetAwardResult,self,self.OnActivityGetAwardResult)
end

function  DaysFeverAwardList:OnActivityGetAwardResult(msg)
	if msg.status then
		self:ShowAwardPanel()
		-- self:LoadItem()
	end
end

function  DaysFeverAwardList:OnActiveGetButtonClicked()
	debug_print("tid:"..self.index)
	if self.status == 1 then
		self:OnActivityGetAwardRequest()
	end
end

function DaysFeverAwardList:OnBuyButtonClicked()
	if self.status == 1 then
		local windowManager = utility:GetGame():GetWindowManager()
		windowManager:Show(require "GUI.VIP.VipGiftPanel",self.id,2,self.index)
	end
end
	
function DaysFeverAwardList:OnActivityGetAwardRequest()
	self.myGame:SendNetworkMessage(require "Network/ServerService".ActivitySevenDayAwardRequest(self.index,self.id))
end

function DaysFeverAwardList:LoadItem()
	-- self:RemoveItem()
	if self.index == 2 then
		self.activeGetButton.gameObject:SetActive(false)
		self.buyButton.gameObject:SetActive(true)
		local activeData = require "StaticData.Activity.NewServerFeverGift":GetData(self.id)
		self.priceText.text = activeData:GetNeeditemNum()
		local id = activeData:GetNeeditemID()
		local gametool = require "Utils.GameTools"
		local _,data,itemName,iconPath,itemType = gametool.GetItemDataById(id)
		utility.LoadSpriteFromPath(iconPath,self.itemIcon)
	else
		self.activeGetButton.gameObject:SetActive(true)
		self.buyButton.gameObject:SetActive(false)
	end
	local 	isAlreceive = false
	for i=1,#self.tableStatus do
		if self.id == self.tableStatus[i].id then
			self.status = self.tableStatus[i].status
		end
	end
	if self.status ~= nil then
		if self.status == 0 then
			self.getImage.material = utility.GetGrayMaterial()
			self.buyButtonImage.material = utility.GetGrayMaterial()
			self:HideButtonState(false)
		-- self.getText.text = "领取"
		end
		if self.status == 1 then
			self:SetMaterial(utility.GetCommonMaterial())
		-- self.getText.text = "领取"
			self:HideButtonState(false)

		end
		if self.status == 2 then
			self:SetMaterial(utility.GetGrayMaterial())
			self:HideButtonState(true)
			isAlreceive = true
		-- self.getText.text = "已领取"
		end
	else 
		self.getImage.material = utility.GetGrayMaterial()
		self.buyButtonImage.material = utility.GetGrayMaterial()
		self:HideButtonState(false)
	end
	self:GetItem(self.id,isAlreceive,self.index)
end

function DaysFeverAwardList:HideButtonState(idHide)
	self.doneState.gameObject:SetActive(idHide)
	self.getText.gameObject:SetActive(not idHide)
end

function DaysFeverAwardList:GetItem(id,isAlreceive,index)
	self.node = {}
	self.items = {}
	self.nums = {}
	self.colors = {}
	local gametool = require "Utils.GameTools"
	local activeData
	if index == 1 then
		activeData = require "StaticData.Activity.NewServerFever":GetData(id)
	elseif index == 2 then
		activeData = require "StaticData.Activity.NewServerFeverGift":GetData(id)
	elseif index == 3 then
		activeData = require "StaticData.Activity.NewServerFeverProgress":GetData(id)
	end
	local itemId = activeData:GetItemID()
	local itemNum = activeData:GetItemNum()
	for i=0,itemId.Count - 1 do
		self.items[#self.items + 1] = itemId[i]
		self.nums[#self.nums + 1] = itemNum[i]
	end
	local descData = activeData:GetInfo()
	local desc = require "StaticData.Activity.Activefever":GetData(descData):GetDescription()
	self.descLabel.text = desc
	for i=1,#self.items do
		local awardItem = require "GUI.Active.ActiveAwardItem".New(self.point,self.items[i],self.nums[i],self.colors[i],isAlreceive)
		self:AddChild(awardItem)
		self.node[i] = awardItem
	end
end

function DaysFeverAwardList:SetMaterial(isGray)
	self.getImage.material = isGray
	self.base.material = isGray
	self.buyButtonImage.material = isGray
end

function DaysFeverAwardList:RemoveItem()
	if self.node ~= nil then
		for i=1,#self.node do
			self:RemoveChild(self.node[i],true)
		end
	end
end

function DaysFeverAwardList:ShowAwardPanel()
	local itemstables = {}
	local gametool = require "Utils.GameTools"
	for i=1,#self.items do
		local _,data,_,_,itype = gametool.GetItemDataById(self.items[i])
		local color = gametool.GetItemColorByType(itype,data)
		self.colors[i] = color
		debug_print(color)
	end
	
	for i=1,#self.items do
		itemstables[i] = {}
		itemstables[i].id = self.items[i]
		print("aaaaaaaaaaaaaa",itemstables[i].id)
		itemstables[i].count = self.nums[i]
		itemstables[i].color = self.colors[i]
	end
	local items = {}

	local windowManager = self:GetGame():GetWindowManager()
    local AwardCls = require "GUI.Task.GetAwardItem"
    windowManager:Show(AwardCls,itemstables)
end

-- function DaysFeverAwardList:HideAllChild()
-- 	for i=1,#self.itemsObj do
-- 		self.itemsObj[i].gameObject:SetActive(false)
-- 	end
-- end


-- function DaysFeverAwardList:Split(szFullString, szSeparator)  
-- 	local nFindStartIndex = 1  
-- 	local nSplitIndex = 1  
-- 	local nSplitArray = {}  
-- 	while true do  
--    		local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
--    		if not nFindLastIndex then  
--     		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
--     		break  
--    		end  
--    		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
--    		nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
--   		nSplitIndex = nSplitIndex + 1  
-- 	end  
-- 	return nSplitArray  
-- end  


return DaysFeverAwardList