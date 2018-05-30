local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local net = require "Network.Net"

local ExchangeIndexCls = Class(BaseNodeClass)

function  ExchangeIndexCls:Ctor(parent,id,state,tableStatus,type,activeId)
	self.parent = parent
	self.id = id 
	self.tableStatus = tableStatus
	self.activeId = activeId
	self.type = type
	self.status = state
end

function ExchangeIndexCls:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/ActiveExchangeIndex",function(go)
		self:BindComponent(go)
	end)
end

function ExchangeIndexCls:OnComponentReady()
	self:LinkComponent(self.parent)
	self:InitControls()
end

function ExchangeIndexCls:OnResume()
	ExchangeIndexCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:LoadItem()
	-- self:RegisterNetworkEvenrs()
end

function ExchangeIndexCls:OnPause()
	ExchangeIndexCls.base.OnPause(self)
	self:UnregisterControlEvents()
	-- self:UnregisterNetworkEvents()
end

function ExchangeIndexCls:OnEnter()
	ExchangeIndexCls.base.OnEnter(self)
end

function  ExchangeIndexCls:OnExit()
	ExchangeIndexCls.base.OnExit(self)
end

function  ExchangeIndexCls:InitControls()
	local transform = self:GetUnityTransform()

	self.activeGetButton = transform:Find("Button"):GetComponent(typeof(UnityEngine.UI.Button))
	self.getImage = transform:Find("Button"):GetComponent(typeof(UnityEngine.UI.Image))
	self.getText = transform:Find("Button/Text"):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.descLabel = transform:Find("IndexLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.point = transform:Find("Layout")
	self.getPoint = transform:Find("Layout2")

	--已完成状态
	self.doneState = transform:Find("DoneText")
	self.box = transform:Find("Box"):GetComponent(typeof(UnityEngine.UI.Image))
	self.base = transform:Find("Base"):GetComponent(typeof(UnityEngine.UI.Image))
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

function  ExchangeIndexCls:RegisterControlEvents()
	self._event_button_onActiveGetButtonClicked_ = UnityEngine.Events.UnityAction(self.OnActiveGetButtonClicked,self)
	self.activeGetButton.onClick:AddListener(self._event_button_onActiveGetButtonClicked_)
end

function  ExchangeIndexCls:UnregisterControlEvents()
	if self._event_button_onActiveGetButtonClicked_ then
		self.activeGetButton.onClick:RemoveListener(self._event_button_onActiveGetButtonClicked_)
		self._event_button_onActiveGetButtonClicked_ = nil
	end
end


function  ExchangeIndexCls:OnActiveGetButtonClicked()
	-- debug_print("发送领取奖励协议")
	self:OnActivityGetAwardRequest()
end
	
function ExchangeIndexCls:OnActivityGetAwardRequest()
	debug_print(self.activeId,self.id,"OnActivityGetAwardRequest")
	self.myGame:SendNetworkMessage(require "Network/ServerService".ActivityGetAwardRequest(self.activeId,self.id))
end

function ExchangeIndexCls:LoadItem()
	-- self:HideAllChild()
	self:RemoveItem()
	local isAlreceive = false
	-- for i=1,#self.tableStatus do
	-- 	if self.id == self.tableStatus[i].id then
	-- 		debug_print(self.id,self.tableStatus[i].id,self.tableStatus[i].state)
	-- 		self.status = self.tableStatus[i].state
	-- 	end
	-- end
	if self.status ~= nil then
		-- if self.status == 0 then
		-- 	self.getImage.material = self.GrayMaterial
		-- 	self.doneState.gameObject:SetActive(false)
		-- 	self.getText.gameObject:SetActive(true)
		-- -- self.getText.text = "领取"
		-- end
		-- if self.status == 1 then
		-- 	self:SetMaterial(utility.GetCommonMaterial())
		-- -- self.getText.text = "领取"
		-- 	self.doneState.gameObject:SetActive(false)
		-- 	self.getText.gameObject:SetActive(true)

		-- end
		if self.status == 2 then
			self:SetMaterial(self.GrayMaterial)
			self.doneState.gameObject:SetActive(true)
			self.getText.gameObject:SetActive(false)
			isAlreceive = true
		-- self.getText.text = "已领取"
		else
			self:SetMaterial(utility.GetCommonMaterial())
		self.doneState.gameObject:SetActive(false)
		self.getText.gameObject:SetActive(true)
		end
	else 
		self:SetMaterial(utility.GetCommonMaterial())
		self.doneState.gameObject:SetActive(false)
		self.getText.gameObject:SetActive(true)
	end
	self:GetItem(self.type,self.id)
end

function ExchangeIndexCls:GetItem(type,id)
	self.node = {}
	self.items = {}
	self.nums = {}
	self.colors = {}
	local activeData = require "StaticData.Activity.ExchangeIndex":GetData(self.id)
	local gametool = require "Utils.GameTools"
	local itemId = activeData:GetNeedItemID()
	local itemNum = activeData:GetNeedItemNum()
	local getItem = activeData:GetItemID()
	local getItemNum = activeData:GetItemNum()
	for i=0,itemId.Count - 1 do
		self.items[#self.items + 1] = itemId[i]
		self.nums[#self.nums + 1] = itemNum[i]
	end
	-- local descData = activeData:GetInfo()
	-- local desc = require "StaticData.Activity.Activefever":GetData(descData):GetDescription()
	-- self.descLabel.text = desc
	for i=1,#self.items do
		local awardItem = require "GUI.Active.ActiveAwardItem".New(self.point,self.items[i],self.nums[i],self.colors[i],false)
		self:AddChild(awardItem)
		self.node[i] = awardItem
	end
	for i=0,getItem.Count - 1 do
		local awardItem = require "GUI.Active.ActiveAwardItem".New(self.getPoint,getItem[i],getItemNum[i],self.colors[i],false)
		self:AddChild(awardItem)
		self.node[#self.node + 1] = awardItem
	end
end

function ExchangeIndexCls:SetMaterial(isGray)
	self.getImage.material = isGray
	self.box.material = isGray
	self.base.material = isGray
end

function ExchangeIndexCls:RemoveItem()
	if self.node ~= nil then
		for i=1,#self.node do
			self:RemoveChild(self.node[i],true)
			self.node = {}
		end
	end
end

function ExchangeIndexCls:ShowAwardPanel()
	local itemstables = {}
	for i=1,#self.items do
		itemstables[i] = {}
		itemstables[i].id = self.items[i]
		print("aaaaaaaaaaaaaa",itemstables[i].id)
		itemstables[i].count = self.nums[i]
		itemstables[i].color = self.color[i]
	end
	local items = {}

	local windowManager = self:GetGame():GetWindowManager()
    local AwardCls = require "GUI.Task.GetAwardItem"
    windowManager:Show(AwardCls,itemstables)
end

-- function ExchangeIndexCls:HideAllChild()
-- 	for i=1,#self.itemsObj do
-- 		self.itemsObj[i].gameObject:SetActive(false)
-- 	end
-- end


-- function ExchangeIndexCls:Split(szFullString, szSeparator)  
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


return ExchangeIndexCls