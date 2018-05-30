local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local net = require "Network.Net"

local ActiveAwardListCls = Class(BaseNodeClass)

function  ActiveAwardListCls:Ctor(parent,id,tableStatus,type,activeId)
	self.parent = parent
	self.id = id 
	self.tableStatus = tableStatus
	self.activeId = activeId
	self.type = type
end

function ActiveAwardListCls:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/ActiveIndex",function(go)
		self:BindComponent(go)
	end)
end

function ActiveAwardListCls:OnComponentReady()
	self:LinkComponent(self.parent)
	self:InitControls()
end

function ActiveAwardListCls:OnResume()
	ActiveAwardListCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:LoadItem()
	-- self:RegisterNetworkEvenrs()
end

function ActiveAwardListCls:OnPause()
	ActiveAwardListCls.base.OnPause(self)
	self:UnregisterControlEvents()
	-- self:UnregisterNetworkEvents()
end

function ActiveAwardListCls:OnEnter()
	ActiveAwardListCls.base.OnEnter(self)
end

function  ActiveAwardListCls:OnExit()
	ActiveAwardListCls.base.OnExit(self)
end

function  ActiveAwardListCls:InitControls()
	local transform = self:GetUnityTransform()

	self.activeGetButton = transform:Find("Button"):GetComponent(typeof(UnityEngine.UI.Button))
	self.getImage = transform:Find("Button"):GetComponent(typeof(UnityEngine.UI.Image))
	self.getText = transform:Find("Button/Text"):GetComponent(typeof(UnityEngine.UI.Text))
	self.descLabel = transform:Find("IndexLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.point = transform:Find("Layout")

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

function  ActiveAwardListCls:RegisterControlEvents()
	self._event_button_onActiveGetButtonClicked_ = UnityEngine.Events.UnityAction(self.OnActiveGetButtonClicked,self)
	self.activeGetButton.onClick:AddListener(self._event_button_onActiveGetButtonClicked_)
end

function  ActiveAwardListCls:UnregisterControlEvents()
	if self._event_button_onActiveGetButtonClicked_ then
		self.activeGetButton.onClick:RemoveListener(self._event_button_onActiveGetButtonClicked_)
		self._event_button_onActiveGetButtonClicked_ = nil
	end
end

function ActiveAwardListCls:RegisterNetworkEvenrs()
	-- self.myGame:RegisterMsgHandler(net.ActivityGetAwardResult,self,self.OnActivityGetAwardResult)
end

function  ActiveAwardListCls:UnregisterNetworkEvents()
	-- self.myGame:UnregisterMsgHandler(net.ActivityGetAwardResult,self,self.OnActivityGetAwardResult)
end

function  ActiveAwardListCls:OnActivityGetAwardResult(msg)
	debug_print("收到回复",msg.status)
	if msg.status then
		self:ShowAwardPanel()
		self:LoadItem()
	end
end

function  ActiveAwardListCls:OnActiveGetButtonClicked()
	-- debug_print("发送领取奖励协议")
	if self.status == 1 then
		self:OnActivityGetAwardRequest()
	end
end
	
function ActiveAwardListCls:OnActivityGetAwardRequest()
	self.myGame:SendNetworkMessage(require "Network/ServerService".ActivityGetAwardRequest(self.activeId,self.id))
end

function ActiveAwardListCls:LoadItem()
	-- self:HideAllChild()
	self:RemoveItem()
	local isAlreceive = false
	for i=1,#self.tableStatus do
		if self.id == self.tableStatus[i].id then
			self.status = self.tableStatus[i].status
		end
	end
	if self.status ~= nil then
		if self.status == 0 then
			self.getImage.material = self.GrayMaterial
			self.doneState.gameObject:SetActive(false)
			self.getText.gameObject:SetActive(true)
		-- self.getText.text = "领取"
		end
		if self.status == 1 then
			self:SetMaterial(utility.GetCommonMaterial())
		-- self.getText.text = "领取"
			self.doneState.gameObject:SetActive(false)
			self.getText.gameObject:SetActive(true)

		end
		if self.status == 2 then
			self:SetMaterial(self.GrayMaterial)
			self.doneState.gameObject:SetActive(true)
			self.getText.gameObject:SetActive(false)
			isAlreceive = true
		-- self.getText.text = "已领取"
		end
	else 
		self.getImage.material = self.GrayMaterial
		self.doneState.gameObject:SetActive(false)
		self.getText.gameObject:SetActive(true)
	end
	self:GetItem(self.type,self.id,isAlreceive)
end

function ActiveAwardListCls:GetItem(type,id,isAlreceive)
	self.node = {}
	self.items = {}
	self.nums = {}
	self.colors = {}
	if type == 1 or type == 2 then
		local activeData = require "StaticData.Activity.ActivityConsumption":GetData(self.id)
		self.items = utility.Split(activeData:GetItemID(),";")
		self.nums = utility.Split(activeData:GetItemNum(),";")
		self.colors = utility.Split(activeData:GetItemColor(),";")
		local desc = require "StaticData.Activity.ActiveItem":GetData(self.id):GetDescription()
		self.descLabel.text = desc
	else
		local activeData
		if type == 5 then
			activeData = require "StaticData.Activity.NewServerLogin":GetData(self.id)
		elseif type == 7 then
			activeData = require "StaticData.Activity.NewServerLevel":GetData(self.id)
		elseif type == 8 then
			activeData = require "StaticData.Activity.NewServerPower":GetData(self.id)
		end
		local gametool = require "Utils.GameTools"
		local itemId = activeData:GetItemID()
		local itemNum = activeData:GetItemNum()
		for i=0,itemId.Count - 1 do
			self.items[#self.items + 1] = itemId[i]
			self.nums[#self.nums + 1] = itemNum[i]
		end
		local descData = activeData:GetInfo()
		local desc = require "StaticData.Activity.Activefever":GetData(descData):GetDescription()
		self.descLabel.text = desc
	end
	for i=1,#self.items do
			local awardItem = require "GUI.Active.ActiveAwardItem".New(self.point,self.items[i],self.nums[i],self.colors[i],isAlreceive)
			self:AddChild(awardItem)
			self.node[i] = awardItem
	end
end

function ActiveAwardListCls:SetMaterial(isGray)
	self.getImage.material = isGray
	self.box.material = isGray
	self.base.material = isGray
end

function ActiveAwardListCls:RemoveItem()
	if self.node ~= nil then
		for i=1,#self.node do
			self:RemoveChild(self.node[i],true)
			self.node = {}
		end
	end
end

function ActiveAwardListCls:ShowAwardPanel()
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

-- function ActiveAwardListCls:HideAllChild()
-- 	for i=1,#self.itemsObj do
-- 		self.itemsObj[i].gameObject:SetActive(false)
-- 	end
-- end


-- function ActiveAwardListCls:Split(szFullString, szSeparator)  
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


return ActiveAwardListCls