local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "Const"
require "LUT.StringTable"
require "Collection.OrderedDictionary"
local net = require "Network.Net"
local messageGuids = require "Framework.Business.MessageGuids"
local messageManager = require "Network.MessageManager"
local gameTool = require "Utils.GameTools"
local equipUpData = require "StaticData.EquipUp"
local equipData = require "StaticData.Equip"
local EquipUpgradeNodeCls = Class(BaseNodeClass)

function EquipUpgradeNodeCls:Ctor(parent)
	self.parent = parent
	--当前已选择的Dic
	self.chooseDict = OrderedDictionary.New()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function EquipUpgradeNodeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/EquipmentMix', function(go)
		self:BindComponent(go,false)
	end)
end

function EquipUpgradeNodeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function EquipUpgradeNodeCls:OnResume()
	-- 界面显示时调用
	EquipUpgradeNodeCls.base.OnResume(self)
	self:RegisterControlEvents()
	-- self:RegisterNetworkEvents()
	self.isPlayingEffect = false
end

function EquipUpgradeNodeCls:OnPause()
	-- 界面隐藏时调用
	EquipUpgradeNodeCls.base.OnPause(self)
	self:UnregisterControlEvents()
	-- self:UnregisterNetworkEvents()
	if self.chooseDict ~= nil then
		self.chooseDict:Clear()
	end
end

function EquipUpgradeNodeCls:OnEnter()
	-- Node Enter时调用
	EquipUpgradeNodeCls.base.OnEnter(self)
end

function EquipUpgradeNodeCls:OnExit()
	-- Node Exit时调用
	EquipUpgradeNodeCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function EquipUpgradeNodeCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()
	self.item1 = transform:Find("Item1")
	self.item2 = transform:Find("Item2")
	--item1
	self.item1Name = self.item1:Find("ItemNameBase/InfoItemNameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.item1TypeIcon = self.item1:Find("ItemNameBase/InfoItemTypeIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	self.item1Frame = self.item1:Find("ItemBox/Frame"):GetComponent(typeof(UnityEngine.UI.Image))
	self.item1Icon = self.item1:Find("ItemBox/EquipIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	--item2
	self.item2Name = self.item2:Find("ItemNameBase/InfoItemNameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.item2TypeIcon = self.item2:Find("ItemNameBase/InfoItemTypeIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	self.item2Frame = self.item2:Find("ItemBox/Frame"):GetComponent(typeof(UnityEngine.UI.Image))
	self.item2Icon = self.item2:Find("ItemBox/EquipIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	--星级
	self.item1Stars = {}
	self.item2Stars = {}
	for i=1,5 do
		self.item1Stars[i] = self.item1:Find("ItemBox/EquipStarLayout/EquipStarIcon"..i).gameObject
		self.item2Stars[i] = self.item2:Find("ItemBox/EquipStarLayout/EquipStarIcon"..i).gameObject
	end
	
	self.RarityImage1 =   self.item1:Find("ItemBox/Rarity"):GetComponent(typeof(UnityEngine.UI.Image))
	self.RarityImage2 =   self.item2:Find("ItemBox/Rarity"):GetComponent(typeof(UnityEngine.UI.Image))

	--添加道具
	self.buttonList = {}
	self.baseAsAddMateriaButton = {}
	self.Frame = {}
	self.ItemIcon = {}
	self.PlusImage = {}
	for i=1,6 do
		self.buttonList[i] = transform:Find("LevelUpBase/AddMaterialBoxLayout/AddMaterialBox"..i)
		self.baseAsAddMateriaButton[i] = self.buttonList[i]:Find("baseAsAddMateriaButton"):GetComponent(typeof(UnityEngine.UI.Button))
		self.Frame[i] = self.buttonList[i]:Find("Frame"):GetComponent(typeof(UnityEngine.UI.Image))
		self.ItemIcon[i] = self.buttonList[i]:Find("ItemIcon"):GetComponent(typeof(UnityEngine.UI.Image))
		self.PlusImage[i] = self.buttonList[i]:Find("PlusImage"):GetComponent(typeof(UnityEngine.UI.Image))
	end

	--花费选框
	self.cost = {}
	self.costButton = {}
	self.costCheckMark = {}
	self.costNumText = {}
	for i=1,2 do
		self.cost[i] = transform:Find("LevelUpBase/CoinYouNeed/Cost"..i)
		self.costButton[i] =  self.cost[i]:Find("Button"):GetComponent(typeof(UnityEngine.UI.Button))
		self.costCheckMark[i] =  self.costButton[i].transform:Find("Checkmark").gameObject
		self.costNumText[i] = self.cost[i]:Find("NumText"):GetComponent(typeof(UnityEngine.UI.Text))
	end

	--进阶
	self.upButton = transform:Find("LevelUpBase/UpButton"):GetComponent(typeof(UnityEngine.UI.Button))
end

function EquipUpgradeNodeCls:ShowPanel()
	self:LoadItem(self.id,self.equipType)
	
	for i=1,#self.buttonList do
		self.ItemIcon[i].enabled=false
		self.PlusImage[i].enabled=true
		self.Frame[i]:GetComponent(typeof(UnityEngine.UI.Image)).color=UnityEngine.Color(1,1,1,1)
	end
end

function EquipUpgradeNodeCls:LoadItem(id,equipType)
	self:HideStar()
	local data = equipData:GetData(id)
	local infodata,data,name,iconPath,itype = gameTool.GetItemDataById(id)
 	self.item1Name.text = name
 	utility.LoadSpriteFromPath(iconPath,self.item1Icon)
 	local tagImagePath = gameTool.GetEquipTagImagePath(equipType)
	utility.LoadSpriteFromPath(tagImagePath,self.item1TypeIcon)
	local PropUtility = require "Utils.PropUtility" 
	PropUtility.AutoSetRGBColor(self.item1Frame,data:GetColorID())
	local star = data:GetStarID()
	local rarity = data:GetRarity()
	utility.LoadSpriteFromPath(rarity,self.RarityImage1)
	--生成item
	local equipBasicData = require "StaticData.EquipUpBasic":GetData(equipType)
	self.madeId = equipBasicData:GetEquipUpId(data:GetColorID())
	local equipMadeId = equipUpData:GetData(self.madeId):GetDisplayId()
	local madeData = equipData:GetData(equipMadeId)
	local infodata2,data2,name2,iconPath2,itype2 = gameTool.GetItemDataById(equipMadeId)
 	self.item2Name.text = name2
 	utility.LoadSpriteFromPath(iconPath2,self.item2Icon)
	utility.LoadEquipmentSlotTypeIcon(madeData:GetType(),self.item2TypeIcon)
	local PropUtility = require "Utils.PropUtility" 
	PropUtility.AutoSetRGBColor(self.item2Frame,madeData:GetColorID())
	local star2 = madeData:GetStarID()
	local rarity2 = madeData:GetRarity()
	utility.LoadSpriteFromPath(rarity2,self.RarityImage2)
	-- for i=1,#self.item1Stars do
		-- if star >= i then
			-- self.item1Stars[i]:SetActive(true)
		-- end
		-- if star2 >= i then
			-- self.item2Stars[i]:SetActive(true)
		-- end
	-- end
	self:SetCost(self.madeId)
end

--设置花费方式
function EquipUpgradeNodeCls:SetCost(id)
	local data = equipUpData:GetData(id)
	local cost = data:GetCost()
	for i=1,#self.cost do
		self.costNumText[i].text = cost[i]
		self.costCheckMark[i]:SetActive(false)
	end
end

function EquipUpgradeNodeCls:HideStar()
	for i=1,#self.item1Stars do
		self.item1Stars[i]:SetActive(false)
		self.item2Stars[i]:SetActive(false)
	end
end

-------------------------------------------------------------------------------------------------
function EquipUpgradeNodeCls:RegisterControlEvents()
	-- 注册勾选花费框事件
	self.OnCostButtonClicked = {}
	self._event_button_onCostButtonClicked_ = {}
	self.OnCostButtonClicked[1] = self.OnCostButton1Clicked
	self.OnCostButtonClicked[2] = self.OnCostButton2Clicked
	for i=1,#self.OnCostButtonClicked do
		self._event_button_onCostButtonClicked_[i] = UnityEngine.Events.UnityAction(self.OnCostButtonClicked[i],self)
		self.costButton[i].onClick:AddListener(self._event_button_onCostButtonClicked_[i])
	end

	self.__event_button_onbaseAsAddMateriaButtonClicked__ = {}
	for i=1,#self.baseAsAddMateriaButton do
		self.__event_button_onbaseAsAddMateriaButtonClicked__[i] = UnityEngine.Events.UnityAction(self.OnbaseAsAddMateriaButtonClicked,self)
		self.baseAsAddMateriaButton[i].onClick:AddListener(self.__event_button_onbaseAsAddMateriaButtonClicked__[i])
	end

	self.__event_button_onUpButtonClicked__ = UnityEngine.Events.UnityAction(self.OnUpButtonClicked, self)
	self.upButton.onClick:AddListener(self.__event_button_onUpButtonClicked__)
	
end

function EquipUpgradeNodeCls:UnregisterControlEvents()
	--取消注册勾选花费框事件
	for i=1,#self._event_button_onCostButtonClicked_ do
		if self._event_button_onCostButtonClicked_[i] then
			self.costButton[i].onClick:RemoveListener(self._event_button_onCostButtonClicked_[i])
			self._event_button_onCostButtonClicked_[i] = nil
		end
	end

	for i=1,#self.__event_button_onbaseAsAddMateriaButtonClicked__ do
		if self.__event_button_onbaseAsAddMateriaButtonClicked__[i] then
			self.baseAsAddMateriaButton[i].onClick:RemoveListener(self.__event_button_onbaseAsAddMateriaButtonClicked__[i])
			self.__event_button_onbaseAsAddMateriaButtonClicked__[i] = nil
		end
	end
	
	if self.__event_button_onUpButtonClicked__ then
		self.upButton.onClick:RemoveListener(self.__event_button_onUpButtonClicked__)
		self.__event_button_onUpButtonClicked__ = nil
	end

end



----------------------------------------------------------------------

function EquipUpgradeNodeCls:RefreshItem(uid,id,equipUpID,equipData)
	self.id = id
	self.equipType = equipUpID
	self:ShowPanel()
	self.equipData = equipData
	-- coroutine.start(DelayRefreshItem,self,uid)
end

-----------------------------------------------------------------------
--- 回掉函数
-----------------------------------------------------------------------

function EquipUpgradeNodeCls:ClickedPetItemCallBack(uid,active,index)
	-- body

	if  active then
		if  self.chooseDict:Count() < #self.buttonList then
			self.chooseDict:Add(index,uid)
		end
	else
		if self.chooseDict:Contains(index) then
			self.chooseDict:Remove(index)
		end
	end
	
end



function EquipUpgradeNodeCls:ClosePetPowerUpFunc()
	-- 确定按钮


	print("CloseFunc")
	self.chooseDict:Clear()

end

function EquipUpgradeNodeCls:ConfirmEquipUpFunc()

	local UserDataType = require "Framework.UserDataType"
 	local tempData = self:GetCachedData(UserDataType.EquipBagData)
 	local EquipPetsLevel = require"StaticData.EquipPetsLevel"
 	local EquipPetsExp = require"StaticData.EquipPetsExp"
 	for i=1,#self.buttonList do
		self.ItemIcon[i].enabled=false
		self.PlusImage[i].enabled=true
		self.Frame[i]:GetComponent(typeof(UnityEngine.UI.Image)).color=UnityEngine.Color(1,1,1,1)
	end
	self.consumeEquipUIDList = self.equipData:GetEquipUID()
	for i=1,self.chooseDict:Count() do
		local petUid = self.chooseDict:GetEntryByIndex(i)
		local petData=tempData:GetItem(petUid)
		local petColor = petData:GetColor()
		local data = EquipPetsExp:GetData(petColor)


		local gameTool = require "Utils.GameTools"
		local AtlasesLoader = require "Utils.AtlasesLoader"
		local PropUtility = require "Utils.PropUtility"
 		PropUtility.AutoSetRGBColor(self.Frame[i],petColor)
 		local _,_,_,iconPath,_ = gameTool.GetItemDataById(petData:GetEquipID()) 	
		utility.LoadSpriteFromPath(iconPath,self.ItemIcon[i])
		self.ItemIcon[i].enabled=true
		self.PlusImage[i].enabled=false
		if self.consumeEquipUIDList=="" then
			self.consumeEquipUIDList=petUid
		else
			self.consumeEquipUIDList=self.consumeEquipUIDList..","..petUid

		end

	end

end


-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------        

function EquipUpgradeNodeCls:OnAddButtonClicked()

		local itemCls = require "GUI.ChooseItemContainer.ChooseMulItemNode"
		local data = self:GetGemDataDict(self.equipType)
		local windowManager = self:GetGame():GetWindowManager()
		windowManager:Show(require "GUI.ChooseItemContainer.ChooseItemContainer",self,self.ClickedPetItemCallBack,itemCls,data,self.ConfirmEquipUpFunc,6,self.chooseDict,self.ClosePetPowerUpFunc)
end

--获取装备的数据集合
function EquipUpgradeNodeCls:GetGemDataDict(type)
	local UserDataType = require "Framework.UserDataType"
	local cachedData = self:GetCachedData(UserDataType.EquipBagData)

    local data = cachedData:RetrievalByResultFunc(function(item)
        local itemType = item:GetEquipType()
        	
        if itemType == type then
        	if self.equipData:GetColor()~=item:GetColor() then
        		return nil
        	end

        	if self.equipData:GetEquipUID()==item:GetEquipUID() then
        		return nil
        	end

        	local uid = item:GetEquipUID()
        	return true,uid
        end
       	return nil 
    end)
 
	return data
end


function EquipUpgradeNodeCls:OnbaseAsAddMateriaButtonClicked()
	--baseAsAddMateriaButton控件的点击事件处理
	self:OnAddButtonClicked()
end

function EquipUpgradeNodeCls:OnUpButtonClicked()
	local count = self.chooseDict:Count()
	if count < 6 then
		local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        local windowManager = utility:GetGame():GetWindowManager()
        windowManager:Show(ErrorDialogClass, "进阶装备数量不足")
	else
		if self.costType == nil then
			local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        	local windowManager = utility:GetGame():GetWindowManager()
        	windowManager:Show(ErrorDialogClass, "请先选择消耗货币类型！")
		else
			self:EquipAdvancedRequest(self.costType,self.madeId,self.consumeEquipUIDList)
		end
	end
end


function EquipUpgradeNodeCls:EquipAdvancedRequest(needType,advancedId,consumeEquipUIDList)
	self.game:SendNetworkMessage( require"Network/ServerService".EquipAdvancedRequest(needType,advancedId,consumeEquipUIDList))
end

function EquipUpgradeNodeCls:OnCostButton1Clicked()
	self:SetCostButton(1)
end

function EquipUpgradeNodeCls:OnCostButton2Clicked()
	self:SetCostButton(2)
end

function EquipUpgradeNodeCls:SetCostButton(index)
	for i=1,#self.cost do
		self.costCheckMark[i]:SetActive(false)
	end
	self.costCheckMark[index]:SetActive(true)
	self.costType = index
end


return EquipUpgradeNodeCls