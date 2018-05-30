local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local TweenUtility = require "Utils.TweenUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
local messageGuids = require "Framework.Business.MessageGuids"
require "Collection.OrderedDictionary"
require "Collection.DataQueue"
require "Const"


local maxMaterialNodeCount = 4
local GoldCombineMode = 1
local DiamondCombineMode = 2
local maxMovingLabelCount = 5

local GemCombineCls = Class(BaseNodeClass)

function GemCombineCls:Ctor()
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GemCombineCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/SinGemCombine', function(go)
		self:BindComponent(go)
	end)
end

function GemCombineCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function GemCombineCls:OnResume()
	-- 界面显示时调用
	GemCombineCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:RegisterEvents()

	self:LoadMissedNode()
	self:OnStoneQueryRequest()
	self:LoadMaterialBoxNode()
	self:RefreshGemBoxPanel()
end

function GemCombineCls:OnPause()
	-- 界面隐藏时调用
	GemCombineCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnregisterEvents()
end

function GemCombineCls:OnEnter()
	-- Node Enter时调用
	GemCombineCls.base.OnEnter(self)
end

function GemCombineCls:OnExit()
	-- Node Exit时调用
	GemCombineCls.base.OnExit(self)
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
function GemCombineCls:InitControls()
	local transform = self:GetUnityTransform()

	-- 返回按钮
	self.returnButton = transform:Find('ReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- 槽位挂点
	self.AddMateriaPoint = transform:Find('Base/AddMaterialBoxLayout')
	-- 宝石挂点
	self.gemNodePoint = transform:Find('SelectCardBase/SelectBoxBase/GemBox/Viewport/Content')
	-- 幸运值文字挂点
	self.luckyPoint = transform:Find('LuckyPoint/NumPoint')
	-- 失败挂点
	self.missPoint = transform:Find('Miss')
	-- 宝石槽位路径
	self.LightPathTable = {}
	self.LightPathTable[1] = transform:Find('Base/LightPathBase/LightPath1').gameObject
	self.LightPathTable[2] = transform:Find('Base/LightPathBase/LightPath2').gameObject
	self.LightPathTable[3] = transform:Find('Base/LightPathBase/LightPath3').gameObject
	self.LightPathTable[4] = transform:Find('Base/LightPathBase/LightPath4').gameObject
	-- 合成失败
	self.missImageTable = {}
	self.missImageTable[1] = transform:Find('Miss/Miss1').gameObject
	self.missImageTable[2] = transform:Find('Miss/Miss2').gameObject
	self.missImageTable[3] = transform:Find('Miss/Miss3').gameObject
	self.missImageTable[4] = transform:Find('Miss/Miss4').gameObject
	-- 待合成的宝石
	self.combineGemImage = transform:Find('GemBase/ResultGemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.combineLightObj = transform:Find('GemBase/Light').gameObject
	self.combineBottomImage = transform:Find('GemBase/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.grayMaterial = self.combineBottomImage.material
	self.combineBorderImage = transform:Find('GemBase/Gem'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 消耗
	self.goldCostLabel = transform:Find('Check/ToggleGold/GemCombineCoinLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.diamondCostLabel = transform:Find('Check/ToggleDiamond/GemCombineDiamondLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 幸运值
	self.luckyLabel = transform:Find('LuckyPoint/Now'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 幸运值图片
	self.luckyFillImage = transform:Find('LuckyPoint/Shadow/Fill'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 金币选项
	self.GoldToggle = transform:Find('Check/ToggleGold'):GetComponent(typeof(UnityEngine.UI.Toggle))
	-- 砖石选项
	self.DiamondToggle = transform:Find('Check/ToggleDiamond'):GetComponent(typeof(UnityEngine.UI.Toggle))
	-- 合成按钮
	self.combineButton = transform:Find('MixButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- 商店
	self.shopButton = transform:Find('ShopButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- 说明
	self.descriptionButton = transform:Find('DescriptionButton'):GetComponent(typeof(UnityEngine.UI.Button))

	self.myGame = utility:GetGame()

	-- 槽位列表
	self.materialNodeDict = OrderedDictionary.New()
	-- 宝石字典
	self.gemNodeDict = OrderedDictionary.New()
	-- 已经选中的宝石列表
	self.onCheckedGemNodeDict = OrderedDictionary.New()
	-- 宝石列表
	self.nodePoolDict = OrderedDictionary.New()
	-- 幸运值字典
	self.luckyPropDict = OrderedDictionary.New()
	-- 幸运文字
	self.luckyMovingQueue = DataQueue.New()
	-- 合成模式
	self.combineMode = GoldCombineMode
	-- 失败miss
	self.missValue = 0
end

function GemCombineCls:RegisterControlEvents()
	-- 返回按钮
	self.__event_button_onreturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnreturnButtonClicked, self)
	self.returnButton.onClick:AddListener(self.__event_button_onreturnButtonClicked__)

	self.__event_button_oncombineButtonClicked__ = UnityEngine.Events.UnityAction(self.OncombineButtonClicked, self)
	self.combineButton.onClick:AddListener(self.__event_button_oncombineButtonClicked__)

	self.__event_button_onShopButtonClicked__ = UnityEngine.Events.UnityAction(self.OnShopButtonClicked, self)
	self.shopButton.onClick:AddListener(self.__event_button_onShopButtonClicked__)

	self.__event_button_onDescriptionButtonClicked__ = UnityEngine.Events.UnityAction(self.OnDescriptionButtonClicked, self)
	self.descriptionButton.onClick:AddListener(self.__event_button_onDescriptionButtonClicked__)

	self.__event_button_onGoldToggleChanged__ = UnityEngine.Events.UnityAction_bool(self.OnGoldToggleChanged, self)
	self.GoldToggle.onValueChanged:AddListener(self.__event_button_onGoldToggleChanged__)

	self.__event_button_onDiamondToggleChanged__ = UnityEngine.Events.UnityAction_bool(self.OnDiamondToggleChanged, self)
	self.DiamondToggle.onValueChanged:AddListener(self.__event_button_onDiamondToggleChanged__)
end

function GemCombineCls:UnregisterControlEvents()
	-- 返回按钮
	if self.__event_button_onreturnButtonClicked__ then
		self.returnButton.onClick:RemoveListener(self.__event_button_onreturnButtonClicked__)
		self.__event_button_onreturnButtonClicked__ = nil
	end

	if self.__event_button_oncombineButtonClicked__ then
		self.combineButton.onClick:RemoveListener(self.__event_button_oncombineButtonClicked__)
		self.__event_button_oncombineButtonClicked__ = nil
	end

	if self.__event_button_onShopButtonClicked__ then
		self.shopButton.onClick:RemoveListener(self.__event_button_onShopButtonClicked__)
		self.__event_button_onShopButtonClicked__ = nil
	end

	if self.__event_button_onDescriptionButtonClicked__ then
		self.descriptionButton.onClick:RemoveListener(self.__event_button_onDescriptionButtonClicked__)
		self.__event_button_onDescriptionButtonClicked__ = nil
	end

	if self.__event_button_onGoldToggleChanged__ then
		self.GoldToggle.onValueChanged:RemoveListener(self.__event_button_onGoldToggleChanged__)
		self.__event_button_onGoldToggleChanged__ = nil
	end

	if self.__event_button_onDiamondToggleChanged__ then
		self.DiamondToggle.onValueChanged:RemoveListener(self.__event_button_onDiamondToggleChanged__)
		self.__event_button_onDiamondToggleChanged__ = nil
	end
end
----------------------------------------------------------------------
------------------网络事件注册----------------------------------------
function GemCombineCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CStoneComposeResult, self, self.OnStoneComposeResponse)
	self.myGame:RegisterMsgHandler(net.S2CStoneQueryResult, self, self.OnStoneQueryResponse)
end

function GemCombineCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CStoneComposeResult, self, self.OnStoneComposeResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CStoneQueryResult, self, self.OnStoneQueryResponse)
end

function GemCombineCls:OnStoneComposeRequest(list,costType)
	self.myGame:SendNetworkMessage( require"Network/ServerService".StoneComposeRequest(list,costType))
end

function GemCombineCls:OnStoneQueryRequest()
	self.myGame:SendNetworkMessage( require"Network/ServerService".StoneQueryRequest())
end

local function UpdateDictValue(dict,key,value)
	-- 更新字典值
	if dict:Contains(key) then
		dict:Remove(key)
	end
	dict:Add(key,value)
end

local function ResetProgress(label,image,currValue,maxValue)
	-- 设置图片进度
	local prop
	if maxValue == 0 then
		prop = 0
	else
		prop = currValue / maxValue
	end
	image.fillAmount = tonumber(prop)
	prop = string.format("%.3f",prop)
	prop = prop * 100
	prop = math.floor(prop)
	if prop > 100 then
		prop = 100 
	end
	label.text = string.format("%s%s",prop,"%")
end

local function ShowAward(self)
	local id = self.toGemId
	local gametool = require "Utils.GameTools"
	local item = {}
	item.id = id
	item.count = count
	local _,data,_,_,itype = gametool.GetItemDataById(id)
	item.color = gametool.GetItemColorByType(itype,data)
	
	local items = {item}
	local windowManager = self:GetGame():GetWindowManager()
    local AwardCls = require "GUI.Task.GetAwardItem"
    windowManager:Show(AwardCls,items)
end

function GemCombineCls:OnStoneComposeResponse(msg)
	-- 宝石合成结果
	if msg.isSuccess then
		UpdateDictValue(self.luckyPropDict,self.onCheckedGemNodeID,0)
		ResetProgress(self.luckyLabel,self.luckyFillImage,0,self.fullLuck)
		self:MaterialNodeCallBack(self.onCheckedGemNodeID,true)
		self:RefreshGemBoxPanel()
		ShowAward(self)
	else
		local currLucky = msg.prop
		local beforeProp = self.luckyPropDict:GetEntryByKey(self.onCheckedGemNodeID)
		local temp = beforeProp
		-- local add = (currLucky - beforeProp) / self.fullLuck *100
		-- local addProp = string.format("%.1f",add)

		local beforeProp = string.format("%.3f", beforeProp/self.fullLuck)
		beforeProp = beforeProp * 100
		beforeProp = math.floor(beforeProp)
		local currProp = string.format("%.3f", currLucky/self.fullLuck)
		currProp = currProp * 100
		currProp = math.floor(currProp)
		--local addProp = (currProp - beforeProp) * 100
		local addProp = currProp - beforeProp
		addProp = string.format("%s%s%s","+",addProp,"%")
		local node = self:GetMovingLuckyNode()
		node:ResetItem(addProp,msg.rat ~= 1)
		UpdateDictValue(self.luckyPropDict,self.onCheckedGemNodeID,currLucky)
		ResetProgress(self.luckyLabel,self.luckyFillImage,currLucky,self.fullLuck)
		self.missNode:ShowMiss()
	end
end

function GemCombineCls:OnStoneQueryResponse(msg)
	-- 宝石合成Query
	for i = 1 ,#msg.stoneID do		
		local key = msg.stoneID[i]
		local value = msg.stoneComposeProp[i]
		UpdateDictValue(self.luckyPropDict,key,value)
	end
end
-----------------------------------------------------------------------
 function GemCombineCls:RegisterEvents()
    self:RegisterEvent(messageGuids.AddedOneEquip,self.OnAddedOneEquip)
end

function GemCombineCls:UnregisterEvents()
	self:UnregisterEvent(messageGuids.AddedOneEquip,self.OnAddedOneEquip)
end

function GemCombineCls:OnAddedOneEquip()
	self:RefreshGemBoxPanel()
end
-----------------------------------------------------------------------
function GemCombineCls:LoadMaterialBoxNode()
	-- 加载合成宝石槽位
	local nodeCls = require "GUI.GemCombine.AddMaterialBox"
	for i = 1,maxMaterialNodeCount do
		local node = nodeCls.New(self.AddMateriaPoint)
		node:SetCallback(self,self.MaterialNodeCallBack)
		self:AddChild(node)
		self.materialNodeDict:Add(i,node)
	end
end

function GemCombineCls:MaterialNodeCallBack(id,deleted)
	local removeTable = {}
	if id == self.onCheckedGemNodeID then
		local count = self.materialNodeDict:Count()
		for i = 1 , count do
			local node = self.materialNodeDict:GetEntryByIndex(i)
			local state = node:GetCheckedState()
			if state then
				node:ResetDefaut()
			end

			local index = self.sameTable[i]
			if index ~= nil then
				local item = self.nodePoolDict:GetEntryByIndex(index)
				local uid = item:GetUid()
				removeTable[#removeTable + 1] = uid
				item:SetCheckedState(false)			
			end

			self.LightPathTable[i]:SetActive(false)
		end
		self.combineGemImage.gameObject:SetActive(false)
		self.combineLightObj:SetActive(false)
		self.combineBottomImage.material = self.grayMaterial
		self.combineBorderImage.color = UnityEngine.Color(1,1,1,1)
		self:ResetCost(0,0)

		self.onCheckedGemNodeID = nil
		self.sameTable = nil
		ResetProgress(self.luckyLabel,self.luckyFillImage,0,self.fullLuck)
		self.missNode:HideMiss()
	end

	if deleted then
		for i = 1 ,#removeTable do
			local uid = removeTable[i]
			local node = self.nodePoolDict:GetEntryByKey(uid)
			if node ~= nil then
				self:RemoveChild(node)
				self.nodePoolDict:Remove(uid)
				self.gemNodeDict:Remove(uid)
			end
		end
	end
end

function GemCombineCls:GetGemData()
	-- 获取所有宝石数据
	local UserDataType = require "Framework.UserDataType"
	local dict
	
	-- 获取原石
	local itemBagData = self:GetCachedData(UserDataType.ItemBagData)	
	local tempDict = itemBagData:RetrievalByResultFunc(function(item)
    	local itemID = item:GetId()
    	local compareID = math.floor(itemID/1000)
    	if  compareID == 10399 then 
        	return true,itemID
        end
    	return nil 
    end)

	-- 获取宝石
	local equipBagData = self:GetCachedData(UserDataType.EquipBagData)
	dict = equipBagData:RetrievalByResultFunc(function(item)
		local itemType = item:GetEquipType()
		if  itemType == KEquipType_EquipGem then
			local uid = item:GetEquipUID()
			return true,uid
        end
        return nil 
    end,tempDict)

    return dict
end

function GemCombineCls:GetGemNodeFromDict(key)
	-- 获取宝石node
	local node
	if self.gemNodeDict:Contains(key) then
		node = self.gemNodeDict:GetEntryByKey(key)
	else
		node = require "GUI.GemCombine.GemNode".New(self.gemNodePoint)
		node:SetCallback(self,self.GemNodeCallBack)
		self.gemNodeDict:Add(key,node)
	end
	return node

end

local function GetSametableUid(self)
	local dirty = false
	if self.sameTable ~= nil and #self.sameTable > 0 then
		dirty = true
		local temp = {}
		for i = 1 ,#self.sameTable do
			local index = self.sameTable[i]
			local uid = self.nodePoolDict:GetEntryByIndex(index):GetUid()
			temp[#temp + 1] = uid
		end
		return dirty,temp
	end
	return dirty
end

local function ResetSameTable(self,dirty,tempUids)
	if dirty then
		self.sameTable = {}
		for i = 1 ,#tempUids do
			local index = self.nodePoolDict:GetEntryByKey(tempUids[i]):GetIndex()
			self.sameTable[#self.sameTable + 1] = index
		end
	end
end

function GemCombineCls:RefreshGemBoxPanel()
	-- 加载宝石背包
	local dirty,tempUids = GetSametableUid(self)
	self.nodePoolDict:Clear()
	local dict = self:GetGemData()
	local keys = dict:GetKeys()
	for i = 1,#keys do
		local key = keys[i]
		local gemData = dict:GetEntryByKey(key)
	
		local node = self:GetGemNodeFromDict(key)		
		local active = node:GetNodeActive()
		node:ResetItem(gemData,key,i)
		if not active then
			self:AddChild(node)
			node:SetNodeActive(true)
		end
		UpdateDictValue(self.nodePoolDict,key,node)
	end
	
	ResetSameTable(self,dirty,tempUids)
end

local function ExistsInTable(table,value)
	for i = 1 ,#table do
		if table[i] == value then
			return true
		end
	end
	return false
end

local function AutoFillSametable(self,index,id)
	local length = #self.sameTable
	local fillCount = maxMaterialNodeCount - length
	local gemNodeCount = self.nodePoolDict:Count()
	local endIndex =  math.min((index + fillCount),gemNodeCount)
	for i = index + 1 ,endIndex do
		local isSame = self:IsSameItem(i,id)
		if isSame then
			if not ExistsInTable(self.sameTable,i) then
				self.sameTable[#self.sameTable + 1] = i
				length = length + 1
			end
		else
			break
		end
	end

	if length < maxMaterialNodeCount then
		local startIndex = index - (maxMaterialNodeCount - length)
		startIndex = math.max(1,startIndex)

		for i = index -1 , startIndex , -1 do
			local isSame = self:IsSameItem(i,id)
			if isSame then
				if not ExistsInTable(self.sameTable,i) then
					self.sameTable[#self.sameTable + 1] = i
				end
			else
				break
			end
		end
	end
end

function GemCombineCls:AddNode2Table(index,id)
	if self.sameTable ~= nil and #self.sameTable < maxMaterialNodeCount then
		if not ExistsInTable(self.sameTable,index) then
			self.sameTable[#self.sameTable + 1] = index
			AutoFillSametable(self,index,id)
		end
	end
end

function GemCombineCls:GemNodeCallBack(id,index,itype,state)
	-- 宝石点击事件
	if self.onCheckedGemNodeID == nil then
		self.onCheckedGemNodeID = id
		self:SetCheckedGemToCombine(id,index,itype)
	elseif self.onCheckedGemNodeID == id then
		if state then
			self:MaterialNodeCallBack(id)
		else
			self:AddNode2Table(index,id)
			self:MaterialBoxNode(self.sameTable)
		end
	else
	end
end

function GemCombineCls:SetCheckedGemToCombine(id,index,itype)
	-- 设置选中的宝石 准备合成
	local sameTable = self:SelectedSameGem(id,index,itype)
	self:MaterialBoxNode(sameTable)
end

local function GetSameItemGemTable(self,id,index)
	-- 获取相同原石
	local UserDataType = require "Framework.UserDataType"
	local data = self:GetCachedData(UserDataType.ItemBagData)
	local count = data:GetItemCountById(id)

	local length = math.min(count,maxMaterialNodeCount)
	local sameTable = {}
	for i = 1,length do
		sameTable[#sameTable + 1] = index
	end

	return sameTable
end

local function GetSameEquipGemTable(self,id,index)
	-- 获取相同原石
	local gemNodeCount = self.nodePoolDict:Count()
	local endIndex = math.min(index + maxMaterialNodeCount -1,gemNodeCount)

	local sameTable = {index}
	local length = 1
	for i = index + 1 ,endIndex do
		local isSame = self:IsSameItem(i,id)
		if isSame then
			sameTable[#sameTable + 1] = i
			length = length + 1
		else
			break
		end
	end

	if length < maxMaterialNodeCount then
		local startIndex = index - (maxMaterialNodeCount - length)
		startIndex = math.max(1,startIndex)

		for i = index -1 , startIndex , -1 do
			local isSame = self:IsSameItem(i,id)
			if isSame then
				sameTable[#sameTable + 1] = i
			else
				break
			end
		end
	end
	return sameTable
end

function GemCombineCls:IsSameItem(index,id)
	-- 是否相同
	local item = self.nodePoolDict:GetEntryByIndex(index)
	local itemId = item:GetId()
	return itemId == id
end

function GemCombineCls:SelectedSameGem(id,index,itype)
	-- 查找相同的宝石列表
	local sameTable = {}
	if itype == KKnapsackItemType_Item then
		sameTable = GetSameItemGemTable(self,id,index)
	elseif itype == KKnapsackItemType_EquipNormal then
		sameTable = GetSameEquipGemTable(self,id,index)
	end

	self.sameTable = sameTable
	return sameTable
end

function GemCombineCls:MaterialBoxNode(sameTable)
	-- 刷新宝石合成槽位
	local keys = self.materialNodeDict:GetKeys()
	for i = 1 ,#keys do
		local node = self.materialNodeDict:GetEntryByKey(keys[i])
		local index = sameTable[i]
		local active = index ~= nil
		self.LightPathTable[i]:SetActive(active)
		if active then
			local item = self.nodePoolDict:GetEntryByIndex(index)
			local id = item:GetId()
			local data = item:GetData()
			item:SetCheckedState(true)
			node:ResetItem(id,data)
			node:SetCheckedState(true)
		end
	end

	local staticData = require "StaticData.EquipGem":GetData(self.onCheckedGemNodeID)
	local toStone = staticData:GetToStone()
	local costGold = staticData:GetCoinCost()
	local costDiamond = staticData:GetDiamondCost()
	self:ResetCost(costGold,costDiamond)
	self.fullLuck  = staticData:GetFullLuck()
	local currLucky = self.luckyPropDict:GetEntryByKey(self.onCheckedGemNodeID)
	ResetProgress(self.luckyLabel,self.luckyFillImage,currLucky,self.fullLuck)

	if #sameTable == maxMaterialNodeCount then
		self:ResetCombineGem(toStone)
	end
end

function GemCombineCls:ResetCombineGem(toStone)
	-- 重置待合成的宝石
	self.combineGemImage.gameObject:SetActive(true)
	self.combineLightObj:SetActive(true)
	self.combineBottomImage.material = utility.GetCommonMaterial()

	local toID
	if toStone == 0 then
		toID = self.onCheckedGemNodeID
		self.GemLevelIsMax = true
	else
		toID = toStone
		self.GemLevelIsMax = false
	end

	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"
	local _,data,name,iconPath,itemType = gametool.GetItemDataById(toID)
	utility.LoadSpriteFromPath(iconPath,self.combineGemImage)
	local color = gametool.GetItemColorByType(itemType,data)
	PropUtility.AutoSetColor(self.combineBorderImage,color)
	self.toGemId = toID
end

function GemCombineCls:GetMovingLuckyNode()
	-- Get 幸运文字
	local nodeCls = require "GUI.GemCombine.MoveLabelNode"
	local count = self.luckyMovingQueue:Count()
	if count >= maxMovingLabelCount then
		local removenode = self.luckyMovingQueue:Dequeue()
		self:RemoveChild(removenode)
	end
	local node = nodeCls.New(self.luckyPoint)
	node:SetCallback(self,self.LuckyMovingCallBack)
	self:AddChild(node)
	self.luckyMovingQueue:Enqueue(node)
	return node
end

function GemCombineCls:LuckyMovingCallBack()
	local node = self.luckyMovingQueue:Dequeue()
	self:RemoveChild(node)
end

function GemCombineCls:ResetCost(gold,diamond)
	self.goldCostLabel.text = gold
	self.diamondCostLabel.text = diamond
end

-- function GemCombineCls:SetMissImage()
-- 	self.missValue = self.missValue + 1
-- 	if self.missValue > maxMaterialNodeCount then
-- 		self.missValue = 1
-- 	end
-- 	local missnode = self.missImageTable[self.missValue]
-- 	missnode:SetActive(true)

-- 	local beforeValue = self.missValue - 1
-- 	if beforeValue == 0 then
-- 		beforeValue = 4
-- 	end
-- 	if 1 <= beforeValue and beforeValue <= 4 then
-- 		local beforeNode = self.missImageTable[beforeValue]
-- 		beforeNode:SetActive(false)
-- 	end
-- end

-- function GemCombineCls:HideMissImage()
-- 	for i = 1 ,#self.missImageTable do
-- 		self.missImageTable[i]:SetActive(false)
-- 	end
-- end

function GemCombineCls:LoadMissedNode()
	self.missNode = require "GUI.GemCombine.MissMovingNode".New(self.missPoint)
	self:AddChild(self.missNode)
end
-----------------------------------------------------------------------
function GemCombineCls:OnreturnButtonClicked()
	-- 返回
	local sceneManager = self.myGame:GetSceneManager()
    sceneManager:PopScene()
end

function GemCombineCls:OncombineButtonClicked()
	if self.sameTable == nil then
		return
	end

	local str = ""
	for i = 1 , #self.sameTable do
		local index = self.sameTable[i]
		--local keys = self.nodePoolDict:GetKeys()
		--local uid = keys[index]
		local node = self.nodePoolDict:GetEntryByIndex(index)
		local uid = node:GetUid()
		str = string.format("%s%s%s",str,uid,",")
	end
	print("请求 >>",str)
	self:OnStoneComposeRequest(str,self.combineMode)
end

function GemCombineCls:OnGoldToggleChanged()
	if self.GoldToggle.isOn then 
		self.combineMode = GoldCombineMode
	end
end

function GemCombineCls:OnDiamondToggleChanged()
	if self.DiamondToggle.isOn then 
		self.combineMode = DiamondCombineMode
	end
end

function GemCombineCls:OnShopButtonClicked()
	local windowManager = self.myGame:GetWindowManager()
   	windowManager:Show(require "GUI.Shop.Shop",KShopType_Gem)
end

function GemCombineCls:OnDescriptionButtonClicked()
	local str = utility.GetDescriptionStr(32)
	local windowManager = self.myGame:GetWindowManager()
    windowManager:Show(require "GUI.CommonDescriptionModule",str)
end

return GemCombineCls