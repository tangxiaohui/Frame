local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local TweenUtility = require "Utils.TweenUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"

local messageGuids = require "Framework.Business.MessageGuids"
require "Const"
require "LUT.StringTable"
require "Collection.OrderedDictionary"

-- 合成宝石node最大数量
local maxGemNodeCount = 4
-- 颜色最大值
local maxStoneColor = 5

-- cost金币
local costGoldIndex = 1
-- cost钻石
local costDiamondIndex = 2
----------------------------------------------------------------------

local GemCompoundCls = Class(BaseNodeClass)

function GemCompoundCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GemCompoundCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GemCombine', function(go)
		self:BindComponent(go)
	end)
end

function GemCompoundCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:InitGemComooundNode()
	self:LoadScrollNodeContent()
end

function GemCompoundCls:OnResume()
	-- 界面显示时调用
	GemCompoundCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()

	self:RegisterEventObserver()
	self:ResetGemBagContent()
	self:OnStoneQueryRequest()
end

function GemCompoundCls:OnPause()
	-- 界面隐藏时调用
	GemCompoundCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnRegisterEventObserver()
end

function GemCompoundCls:OnEnter()
	-- Node Enter时调用
	GemCompoundCls.base.OnEnter(self)
end

function GemCompoundCls:OnExit()
	-- Node Exit时调用
	GemCompoundCls.base.OnExit(self)
end


function GemCompoundCls:RegisterEventObserver()
	-- 添加事件的监听
	self:RegisterEvent(messageGuids.AddedOneEquip,self.AddedOneEquip)
end

function GemCompoundCls:UnRegisterEventObserver()
	-- 取消添加事件的监听
	self:UnregisterEvent(messageGuids.AddedOneEquip,self.AddedOneEquip)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GemCompoundCls:InitControls()
	local transform = self:GetUnityTransform()

	-- 返回按钮
	self.ReturnButton = transform:Find('ReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	
	-- 宝石Node按钮point 1
	self.GemNodeButtonPoint1 = transform:Find('Base/GemNodeButtonPoint1')

	-- 宝石Node按钮point 2
	self.GemNodeButtonPoint2 = transform:Find('Base/GemNodeButtonPoint2')

	-- 宝石Node按钮point 3
	self.GemNodeButtonPoint3 = transform:Find('Base/GemNodeButtonPoint3')

	-- 宝石Node按钮point 4
	self.GemNodeButtonPoint4 = transform:Find('Base/GemNodeButtonPoint4')

	-- 宝石node point点列表
	self.nodePoint = {self.GemNodeButtonPoint1,self.GemNodeButtonPoint2,self.GemNodeButtonPoint3,self.GemNodeButtonPoint4}

	-- 宝石背包挂点
	self.GemBagTrans = transform:Find('GemCompoundBag/GemBag')

	-- 已选择宝石列表
	self.OnSelectedGemDict = OrderedDictionary.New()

	-- 宝石商店按钮
	self.GemCombineShopButton = transform:Find('GemCombineShopButton'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 宝石合成说明按钮
	self.GemCombineInfoButton = transform:Find('GemCombineInfoButton'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 金币选择按钮
	self.CheckCoinToggle = transform:Find('CoinToggleGroup/ToggleGold'):GetComponent(typeof(UnityEngine.UI.Toggle))

	-- 钻石选择按钮
	self.CheckDiamondToggle = transform:Find('CoinToggleGroup/ToggleDiamond'):GetComponent(typeof(UnityEngine.UI.Toggle))

	-- 金币数量Label
	self.CheckCoinLabel = transform:Find('CoinToggleGroup/ToggleGold/GemCombineCoinLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 钻石数量Label
	self.CheckDiamondLabel = transform:Find('CoinToggleGroup/ToggleDiamond/GemCombineCoinLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 幸运值图片
	self.luckyNumImage = transform:Find('LuckyPointResultSliderMask/FillFrame'):GetComponent(typeof(UnityEngine.UI.Image))
	
	-- 幸运值Label
	self.luckyNumLabel = transform:Find('LuckyPointResultLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
	-- 合成按钮
	self.compoundButton = transform:Find('GemCombineGetupButton'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 待合成的宝石图片
	self.toStoneIcon = transform:Find('Base/GemCombineGemResultButton/GemCombineGemResultIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.defaultToStoneIcon = self.toStoneIcon.sprite

	-- 带合成的宝石颜色Frame
	self.toStoneColorFrame = transform:Find('Base/GemCombineGemResultButton/Farme')

	-- 以选择的宝石node
	self.sameNodeList = {}

	self.myGame = utility:GetGame()
	self.CheckCoin = costGoldIndex

	-- 幸运值字典
	self.luckyPropDict = OrderedDictionary.New()
end


function GemCompoundCls:RegisterControlEvents()
	-- 注册 返回 的事件
	self.__event_button_onReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked, self)
	self.ReturnButton.onClick:AddListener(self.__event_button_onReturnButtonClicked__)

	-- 注册 宝石商店按钮 的事件
	self.__event_button_onGemCombineShopButtonClicked__ = UnityEngine.Events.UnityAction(self.OnGemCombineShopButtonClicked, self)
	self.GemCombineShopButton.onClick:AddListener(self.__event_button_onGemCombineShopButtonClicked__)

	-- 注册 宝石合成说明按钮 的事件
	self.__event_button_onGemCombineInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnGemCombineInfoButtonClicked, self)
	self.GemCombineInfoButton.onClick:AddListener(self.__event_button_onGemCombineInfoButtonClicked__)

	-- 注册 合成按钮 的事件
	self.__event_button_oncompoundButtonClicked__ = UnityEngine.Events.UnityAction(self.OncompoundButtonClicked, self)
	self.compoundButton.onClick:AddListener(self.__event_button_oncompoundButtonClicked__)

	-- 金币 toggle
	self.__event_toggle_onCheckCoinToggleToggleValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnCheckCoinToggleToggleValueChanged, self)
	self.CheckCoinToggle.onValueChanged:AddListener(self.__event_toggle_onCheckCoinToggleToggleValueChanged__)

	-- 钻石选择 toggle
	self.__event_toggle_onCheckDiamondToggleValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnCheckDiamondToggleValueChanged, self)
	self.CheckDiamondToggle.onValueChanged:AddListener(self.__event_toggle_onCheckDiamondToggleValueChanged__)
end

function GemCompoundCls:UnregisterControlEvents()
	-- 取消注册 返回 的事件
	if self.__event_button_onReturnButtonClicked__ then
		self.ReturnButton.onClick:RemoveListener(self.__event_button_onReturnButtonClicked__)
		self.__event_button_onReturnButtonClicked__ = nil
	end

	-- 取消注册 宝石商店按钮 的事件
	if self.__event_button_onGemCombineShopButtonClicked__ then
		self.GemCombineShopButton.onClick:RemoveListener(self.__event_button_onGemCombineShopButtonClicked__)
		self.__event_button_onGemCombineShopButtonClicked__ = nil
	end

	-- 取消注册 宝石合成说明按钮 的事件
	if self.__event_button_onGemCombineInfoButtonClicked__ then
		self.GemCombineInfoButton.onClick:RemoveListener(self.__event_button_onGemCombineInfoButtonClicked__)
		self.__event_button_onGemCombineInfoButtonClicked__ = nil
	end

	-- 取消注册 合成按钮 的事件
	if self.__event_button_oncompoundButtonClicked__ then
		self.compoundButton.onClick:RemoveListener(self.__event_button_oncompoundButtonClicked__)
		self.__event_button_oncompoundButtonClicked__ = nil
	end

	-- 取消选择金币 toggle
	if self.__event_toggle_onCheckCoinToggleToggleValueChanged__ then
		self.CheckCoinToggle.onValueChanged:RemoveListener(self.__event_toggle_onCheckCoinToggleToggleValueChanged__)
		self.__event_toggle_onCheckCoinToggleToggleValueChanged__ = nil
	end

	-- 取消钻石选择 toggle
	if self.__event_toggle_onCheckDiamondToggleValueChanged__ then
		self.CheckDiamondToggle.onValueChanged:RemoveListener(self.__event_toggle_onCheckDiamondToggleValueChanged__)
		self.__event_toggle_onCheckDiamondToggleValueChanged__ = nil
	end
end
----------------------------------------------------------------------
------------------网络事件注册----------------------------------------
function GemCompoundCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CStoneComposeResult, self, self.OnStoneComposeResponse)
	self.myGame:RegisterMsgHandler(net.S2CStoneQueryResult, self, self.OnStoneQueryResponse)
end

function GemCompoundCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CStoneComposeResult, self, self.OnStoneComposeResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CStoneQueryResult, self, self.OnStoneQueryResponse)
end
-----------------------------------------------------------------------
function GemCompoundCls:OnStoneComposeRequest(list,costType)
	self.myGame:SendNetworkMessage( require"Network/ServerService".StoneComposeRequest(list,self.CheckCoin))
end

function GemCompoundCls:OnStoneQueryRequest()
	self.myGame:SendNetworkMessage( require"Network/ServerService".StoneQueryRequest())
end

function GemCompoundCls:OnStoneComposeResponse(msg)
	-- 宝石合成结果
	self:DisposeCompoundResult(msg)
end

function GemCompoundCls:OnStoneQueryResponse(msg)
	-- 宝石合成Query
	for i = 1 ,#msg.stoneID do		
		local key = msg.stoneID[i]
		local value = msg.stoneComposeProp[i]
		self:SetGemPropDictValue(self.luckyPropDict,key,value)
	end
end

-----------------------------------------------------------------------
function GemCompoundCls:InitGemComooundNode()
	-- 初始宝石合成node
	
	-- 宝石Node列表
	self.GemButtonNodeList = {}

	for i = 1 ,maxGemNodeCount do
		local parent = self.nodePoint[i]
		local node = require "GUI.Gem.AddGemButtonNode".New(parent)
		self:AddChild(node)
		
		self.GemButtonNodeList[#self.GemButtonNodeList + 1] = node
	end
end

function GemCompoundCls:LoadScrollNodeContent()
  -- 加载 批量出售滑动控件
  self.ScrollNode = require "GUI.Gem.GemBagScrollNode".New(self.GemBagTrans,self,self.OnItemClicked)
  self:AddChild(self.ScrollNode)
end

function GemCompoundCls:ResetWaitCompoundView()
	-- 重置待合成的宝石
	self:SetWaitCompoundViewDefaut()
	for i = 1 ,#self.sameNodeList do
		
		local node = self.GemButtonNodeList[i]
		node:SetGemTheme(self.ItemID,self.itemData)
	end

	self:ResetCost(self.ItemID)
	self:ResetCompoundGem(self.ItemID)

	if #self.sameNodeList < maxGemNodeCount then
		self.notEnoughNode = true
	else
		self.notEnoughNode = false
	end
end

function GemCompoundCls:SetWaitCompoundViewDefaut()
	-- 重置待合成的宝石默认状态
	for i = 1 ,maxGemNodeCount do
		
		local node = self.GemButtonNodeList[i]
		node:SetDefautTheme()
	end
	self:ResetCompoundGemDefaut()
end

function GemCompoundCls:ResetCompoundGem(id)
	-- 重置要合成的宝石
	local staticData = require "StaticData.EquipGem":GetData(id)
	local toStone = staticData:GetToStone()
	self.maxLuckyNum = staticData:GetFullLuck()

	local toID
	if toStone == 0 then
		-- 已经到最高等级
		toID = id
		self.MaxLevelStone = true
	else
		toID = toStone
	end
	
	local gametool = require "Utils.GameTools"
	local _,data,name,iconPath,itemType = gametool.GetItemDataById(toID)

	utility.LoadSpriteFromPath(iconPath,self.toStoneIcon)
	local color = gametool.GetItemColorByType(itemType,data)
	
	local PropUtility = require "Utils.PropUtility"

	PropUtility.AutoSetColor(self.toStoneColorFrame,color)

	-- if self.lastToStone ~= toStone then
	-- 	print("*********")
	-- 	self.luckyNumLabel.text = string.format("%s%s%s","0","/","0")
	-- 	self.luckyNumImage.fillAmount = 0
	-- 	self.lastToStone = toStone		
	-- else
	-- 	self.luckyNumLabel.text = string.format("%s%s%s",50,"/",self.maxLuckyNum)
	-- 	self.luckyNumImage.fillAmount = self.luckyPropNum/self.maxLuckyNum
	-- end
	local luckyProp = self.luckyPropDict:GetEntryByKey(id)
	self.luckyNumLabel.text = string.format("%s%s%s",luckyProp,"/",self.maxLuckyNum)
	self.luckyNumImage.fillAmount = luckyProp/self.maxLuckyNum
end

function GemCompoundCls:ResetCompoundGemDefaut()
	-- 重置默认状态
	local PropUtility = require "Utils.PropUtility"
	PropUtility.AutoSetColor(self.toStoneColorFrame,0)
	self.toStoneIcon.sprite = self.defaultToStoneIcon
	self.CheckCoinLabel.text = 0
	self.CheckDiamondLabel.text = 0
	self.luckyNumLabel.text = string.format("%s%s%s","0","/","0")
	self.luckyNumImage.fillAmount = 0
	--self.luckyPropNum = 0
end

function GemCompoundCls:ResetCost(id)
	-- 重置消耗

	local staticData = require "StaticData.EquipGem":GetData(id)

	local costGold = staticData:GetCoinCost()
	local costDiamond = staticData:GetDiamondCost()

	self.CheckCoinLabel.text = costGold
	self.CheckDiamondLabel.text = costDiamond
end

function GemCompoundCls:OnItemClicked(node,index,id,itemData)
	-- 背包按钮点击回调
	self.ItemID = id
	self.itemData = itemData
	self.MaxLevelStone = false

	for i = 1 ,#self.sameNodeList do
		if self.sameNodeList[i] == index then
			-- 卸下已经选中的node
			self.ScrollNode:ClearSelectedState()
			self.ScrollNode:SetItemSelecetdState()
			self.sameNodeList = {}
			self:SetWaitCompoundViewDefaut()
			return
		end
	end

	self.ScrollNode:ClearSelectedState()
	local sameList

	local itemType = itemData:GetKnapsackItemType()
	if itemType == KKnapsackItemType_EquipNormal then
		sameList = self:SelectedEquipGemCount(index,id)
		self.itemType = KKnapsackItemType_EquipNormal
	elseif itemType == KKnapsackItemType_Item then
		sameList = self:SelectedItemGemCount(index,id) 
		self.itemType = KKnapsackItemType_Item
	end

	for i=1,#sameList do
		self.ScrollNode:AddSelectedState(sameList[i],true)
	end		

	self.ScrollNode:SetItemSelecetdState()
	self.sameNodeList = sameList
	self:ResetWaitCompoundView()
end

function GemCompoundCls:SelectedItemGemCount(index,id)
	-- 查询原石数量
	local UserDataType = require "Framework.UserDataType"
	local data = self:GetCachedData(UserDataType.ItemBagData)

	local count = data:GetItemCountById(id)

	local length = math.min(count,maxGemNodeCount)

	local sameList = {}
	for i = 1 ,length do
		sameList[#sameList + 1] = index
	end

	return sameList
end


function GemCompoundCls:SelectedEquipGemCount(index,id)
	-- 查询宝石数量

	local sameGemList = {index}
	-- 判断item后面是否有同类型
	local endIndex = math.min(index + maxGemNodeCount -1,self.dataCount)
	local length = 1

	for i = index + 1 ,endIndex do
		
		local isSame = self:IsSameItemByIndex(i,id)
		if isSame then 
			sameGemList[#sameGemList + 1] = i
			length = length + 1
		else
			--length = i - index
			break
		end
	end
	
	if length ~= 0 then

		local stratIndex = index - (maxGemNodeCount - length)
		stratIndex = math.max(1,stratIndex)		
		for i = index -1 ,stratIndex , -1 do
			local isSame = self:IsSameItemByIndex(i,id)
			
			if isSame then				
				sameGemList[#sameGemList + 1] = i
			else
				break
			end
		end
	end

	return sameGemList
end

function GemCompoundCls:IsSameItemByIndex(index,id)
	--  在背包中根据Index判断是否是相同装备
	local item = self.data:GetEntryByIndex(index)
	itemType = item:GetKnapsackItemType()

	local itemID

	if itemType == KKnapsackItemType_EquipNormal then
		 itemID = item:GetEquipID()
	elseif itemType == KKnapsackItemType_Item then
		 itemID = item:GetId()
	end
	
	return itemID==id

end


function GemCompoundCls:ResetGemBagContent()
	-- 刷新背包数据
	local UserDataType = require "Framework.UserDataType"
	
	local data,count

	local itemBagData = self:GetCachedData(UserDataType.ItemBagData)
	local itemDataDict = itemBagData:RetrievalByResultFunc(function(item)
       local itemID = item:GetId()

       local compareID = math.floor(itemID/1000)
       if  compareID == 10399 then 
          return true,itemID
        end

        return nil 
      end)

	local tempData = self:GetCachedData(UserDataType.EquipBagData)
    data = tempData:RetrievalByResultFunc(function(item)
       local itemType = item:GetEquipType()

       if  itemType == KEquipType_EquipGem then
          local uid = item:GetEquipUID()
          return true,uid
        end

        return nil 
      end,itemDataDict)
  	count = data:Count()


  self.ScrollNode:UpdateScrollContent(count,data)
  self.data = data
  self.dataCount = count
end

function GemCompoundCls:AddedOneEquip()
	-- 增加一个装备
	self:ResetGemBagContent()
end

function GemCompoundCls:DisposeCompoundResult(msg)
	-- 处理合成结果

		print("宝石合成结果",msg.isSuccess,msg.prop,msg.rat,msg.equipUID)
	--  optional  int32 equipID=3; //源宝石ID
 --    optional  bool isSuccess=4;
 --    optional  int32 prop=5;//暴击概率

	-- optional  int32 rat=6;//暴击倍数	
	-- optional  string equipUID=7; //合成后的宝石ID
	if msg.isSuccess then
		-- 成功
		self:SetWaitCompoundViewDefaut()
		self:ResetGemBagContent()
		self.ScrollNode:ClearSelectedState()
		self.ScrollNode:SetItemSelecetdState()
		self.sameNodeList = {}
		self.luckyNumLabel.text = string.format("%s%s%s",0,"/",0)
		self.luckyNumImage.fillAmount = 0
		self:SetGemPropDictValue(self.luckyPropDict,msg.equipID,0)

	else
		-- 失败
		self.luckyNumLabel.text = string.format("%s%s%s",msg.prop,"/",self.maxLuckyNum)
		self.luckyNumImage.fillAmount = msg.prop / self.maxLuckyNum

		if msg.rat ~= 1 then
			-- 暴击
			print("暴击")
		end
		--self.luckyPropNum = msg.prop
		self:SetGemPropDictValue(self.luckyPropDict,msg.equipID,msg.prop)
	end
end

function GemCompoundCls:OnStoneCompose()
	-- 发送合成请求
	-- 获取合成列表
	local listStr = ""

	for i = 1 ,#self.sameNodeList do
		local item = self.data:GetEntryByIndex(self.sameNodeList[i])
		local uid

		if self.itemType == KKnapsackItemType_Item then
			uid = item:GetUid()
		elseif self.itemType == KKnapsackItemType_EquipNormal then
			uid = item:GetEquipUID()
		end

		listStr = string.format("%s%s%s",listStr,uid,",")
	end
	
	self:OnStoneComposeRequest(listStr,1)
end

function GemCompoundCls:SetGemPropDictValue(dict,key,value)
	-- 设置幸运值字典
	if dict:Contains(key) then
		dict:Remove(key)
	end
	dict:Add(key,value)
end


------------------------------------------------------------------------
function GemCompoundCls:OnReturnButtonClicked()
	-- 返回
	local sceneManager = self.myGame:GetSceneManager()
    sceneManager:PopScene()
end

function GemCompoundCls:OnGemCombineShopButtonClicked()
	-- 商店点击事件
	local windowManager = self.myGame:GetWindowManager()
   	windowManager:Show(require "GUI.Shop.Shop",KShopType_Gem)
end

function GemCompoundCls:OnGemCombineInfoButtonClicked()
	-- 说明点击事件
	print("说明点击事件")
end

function GemCompoundCls:OncompoundButtonClicked()
	-- 合成按钮

	if self.MaxLevelStone then

		local windowManager = self:GetWindowManager()
		windowManager:Show(require "GUI.Dialogs.ErrorDialog","该宝石已经是最高等级无法合成")
	elseif self.notEnoughNode then
		local windowManager = self:GetWindowManager()
		windowManager:Show(require "GUI.Dialogs.ErrorDialog","合成所需宝石数量不足")
	else
		self:OnStoneCompose()
	end

end

function GemCompoundCls:OnCheckCoinToggleToggleValueChanged()

	if self.CheckCoinToggle.isOn then 
		self.CheckCoin = costGoldIndex
	end
end

function GemCompoundCls:OnCheckDiamondToggleValueChanged()

	if self.CheckDiamondToggle.isOn then 
		self.CheckCoin = costDiamondIndex
	end
end

return GemCompoundCls