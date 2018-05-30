local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "LUT.StringTable"
local messageGuids = require "Framework.Business.MessageGuids"
local EquipmentWinUpgradeNodeCls = Class(BaseNodeClass)

function EquipmentWinUpgradeNodeCls:Ctor(parent,ctrlUpgradeButton)
	self.parent = parent
	self.ctrlUpgradeButton = ctrlUpgradeButton
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function EquipmentWinUpgradeNodeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/EquipmentUpgrade', function(go)
		self:BindComponent(go,false)
	end)
end

function EquipmentWinUpgradeNodeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function EquipmentWinUpgradeNodeCls:OnResume()
	-- 界面显示时调用
	EquipmentWinUpgradeNodeCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function EquipmentWinUpgradeNodeCls:OnPause()
	-- 界面隐藏时调用
	EquipmentWinUpgradeNodeCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function EquipmentWinUpgradeNodeCls:OnEnter()
	-- Node Enter时调用
	EquipmentWinUpgradeNodeCls.base.OnEnter(self)
end

function EquipmentWinUpgradeNodeCls:OnExit()
	-- Node Exit时调用
	EquipmentWinUpgradeNodeCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function EquipmentWinUpgradeNodeCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()
	--边框
	self.Frame = transform:Find('ItemBox/Frame')
	--装备图
	self.EquipIcon = transform:Find('ItemBox/EquipIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	--星级
	self.EquipStarLayout = transform:Find('ItemBox/EquipStarLayout')
	--图标
	self.InfoItemTypeIcon = transform:Find('ItemNameBase/InfoItemTypeIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	--名字
	self.InfoItemNameLabel = transform:Find('ItemNameBase/InfoItemNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--图标
	self.InfoItemTypeIcon1 = transform:Find('ItemNameBase (1)/InfoItemTypeIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	--升级之后的名字
	self.InfoItemNameLabel1 = transform:Find('ItemNameBase (1)/InfoItemNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--升级之后的颜色
	self.Frame1 = transform:Find('ItemBox (1)/Frame')
	--升级之后的图片
	self.EquipIcon1 = transform:Find('ItemBox (1)/EquipIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	--升级之后的星级
	self.EquipStarLayout1 = transform:Find('ItemBox (1)/EquipStarLayout')
	
	
	--升级变化
	
	self.EquipPowerupStatusLayout= transform:Find('StatusBase/EquipPowerupStatusLayout')
	self.EquipPowerupStatus1NameLabel = transform:Find('StatusBase/EquipPowerupStatus1NameLabel'):GetComponent(typeof(UnityEngine.UI.Text))	
	self.EquipPowerupOldStatus1 = transform:Find('StatusBase/EquipPowerupOldStatus'):GetComponent(typeof(UnityEngine.UI.Text))
	self.EquipPowerupNewStatus1_ = transform:Find('StatusBase/EquipPowerupStatusLayout/EquipPowerupStatus1/EquipPowerupStatusBase1/EquipPowerupNewStatus1 '):GetComponent(typeof(UnityEngine.UI.Text))
	

	self.EquipPowerupStatus1NameLabel1 = transform:Find('StatusBase/EquipPowerupStatus1NameLabel1'):GetComponent(typeof(UnityEngine.UI.Text))
	self.EquipPowerupOldStatus11 = transform:Find('StatusBase/EquipPowerupOldStatus1'):GetComponent(typeof(UnityEngine.UI.Text))
	self.EquipPowerupNewStatus1_1 = transform:Find('StatusBase/EquipPowerupStatusLayout/EquipPowerupStatus1 (1)/EquipPowerupStatusBase1/EquipPowerupNewStatus1 '):GetComponent(typeof(UnityEngine.UI.Text))
	

	self.NeedPanel= transform:Find('NeedBase/NeedPanel')
	--需要物品的颜色
	self.Frame2 = transform:Find('NeedBase/NeedPanel/ItemBox/Frame')
	self.NeedName = transform:Find('NeedBase/NeedPanel/Notice'):GetComponent(typeof(UnityEngine.UI.Text))
	--需要物品的图
	self.EquipIcon2 = transform:Find('NeedBase/NeedPanel/ItemBox/EquipIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	--Frame
	self.EquipIcon2Frame = transform:Find('NeedBase/NeedPanel/ItemBox/Frame')--:GetComponent(typeof(UnityEngine.UI.Image))
	--百分比
	self.fill = transform:Find('NeedBase/NeedPanel/Bar/Fill'):GetComponent(typeof(UnityEngine.UI.Image))
	--数字提示
	self.NumLabel = transform:Find('NeedBase/NeedPanel/NumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--进阶满的提示
	self.Notice = transform:Find('NeedBase/NoticeText'):GetComponent(typeof(UnityEngine.UI.Text))
	--消耗提示
	self.NeoCardEquipPowerupCoinYouNeedLabel = transform:Find('CoinYouNeed/NeoCardEquipPowerupCoinYouNeedLabel'):GetComponent(typeof(UnityEngine.UI.Text))
end
function EquipmentWinUpgradeNodeCls:InitViews()
--	self.itemID=
 	local UserDataType = require "Framework.UserDataType"
 	local tempData = self:GetCachedData(UserDataType.EquipBagData)
 	self.equipData=tempData:GetItem(self.equipUID)
 	self.equipID=self.equipData:GetEquipID()
 	self.equipType =self.equipData:GetEquipType()

 	if self.equipType==KEquipType_EquipPet then
 		self:InitPetViews()
 	elseif self.equipType == KEquipType_EquipWing then
 		-- 翅膀进阶
 		self:InitWingVariable()
 		self:InitWingPanel()
 		self:ResetWingItem()
 		self:ResetWingAttr()
 		self:ResetNeedItem()
 	end
end
------------------------------------------------------------------
function EquipmentWinUpgradeNodeCls:InitWingVariable()
	-- 翅膀变量
	self.currentWingColor = self.equipData:GetColor()
	local upId
	if self.roleUid ~= nil then
		local UserDataType = require "Framework.UserDataType"
 		local cachedData = self:GetCachedData(UserDataType.CardBagData)
 		local roledata = cachedData:GetRoleByUid(self.roleUid)
 		local race = roledata:GetRace()
 		local temp = math.min(self.currentWingColor,3)
 		upId = race * 10 + temp
	end
	self.wingUpId = upId
end

function EquipmentWinUpgradeNodeCls:InitWingPanel()
	-- 翅膀界面
	if self.currentWingColor > 3 then
		self.Notice.enabled = true
		self.NeedPanel.gameObject:SetActive(false)
		self.Notice.text = "当前为最高阶"
	else
		self.Notice.enabled = false
		self.NeedPanel.gameObject:SetActive(true)
	end
end

function EquipmentWinUpgradeNodeCls:ResetWingItem()
	-- 翅膀属性
	local gameTool = require "Utils.GameTools"
	local AtlasesLoader = require "Utils.AtlasesLoader"
	local PropUtility = require "Utils.PropUtility"

	local nextColor
	if self.currentWingColor > 3 then
		nextColor = self.currentWingColor
	else
		nextColor = self.currentWingColor + 1
	end
	-- 颜色
	PropUtility.AutoSetColor(self.Frame,self.currentWingColor)
	PropUtility.AutoSetColor(self.Frame1,nextColor)

	-- 星星
	-- local star = self.equipData:GetStar()
	-- gameTool.AutoSetStar(self.EquipStarLayout,star)
	-- gameTool.AutoSetStar(self.EquipStarLayout1,star)	

	local _,_,name,iconPath = gameTool.GetItemDataById(self.equipID)
	-- 名字
	self.InfoItemNameLabel.text = name
	self.InfoItemNameLabel1.text = name

	-- 图标
	local tagImagePath = gameTool.GetEquipTagImagePath(self.equipType)
	utility.LoadSpriteFromPath(tagImagePath,self.InfoItemTypeIcon)
	utility.LoadSpriteFromPath(tagImagePath,self.InfoItemTypeIcon1)

	-- 图片
	utility.LoadSpriteFromPath(iconPath,self.EquipIcon)
	debug_print("iconPath",iconPath)
	utility.LoadSpriteFromPath(iconPath,self.EquipIcon1)
	
end

function EquipmentWinUpgradeNodeCls:ResetWingAttr()
	-- 翅膀属性变化
	local gameTool = require "Utils.GameTools"
	local mainPropID = self.equipData:GetEquipStaticData():GetMainPropID()

	local staticData = require "StaticData.EquipWingUp":GetData(self.wingUpId)
	local addId = staticData:GetAddField()
	local addValue = staticData:GetAddValue()

  	local attrdict = self.equipData:GetEquipAttribute(addId)
  	local currValue = attrdict:GetEntryByKey(addId)
  	local afterValue = currValue + addValue
	self.EquipPowerupStatus1NameLabel1.text = EquipStringTable[addId]
	self.EquipPowerupOldStatus11 .text = currValue
	self.EquipPowerupNewStatus1_1 .text = afterValue

	-- 颜色
	self.EquipPowerupStatus1NameLabel.text = "品阶"
	self.EquipPowerupOldStatus1.text = self.currentWingColor
	self.EquipPowerupNewStatus1_.text = math.min(self.currentWingColor+1,4)
end

function EquipmentWinUpgradeNodeCls:ResetNeedItem()
	-- 需要物品
	local PropUtility = require "Utils.PropUtility" 
	local staticData = require "StaticData.EquipWingUp":GetData(self.wingUpId)
	local needNum = staticData:GetNeedNum()
	local needSuipianID = staticData:GetNeedSuipianID()
	local needCoin = staticData:GetNeedCoin()

	local gameTool = require "Utils.GameTools"
	local itemData,_,name,iconPath = gameTool.GetItemDataById(needSuipianID)
	
	self.NeedName.text = string.format("%s%s","需要",name)

	local UserDataType = require "Framework.UserDataType"
 	local cachedData = self:GetCachedData(UserDataType.ItemBagData)
 	local hasNum = cachedData:GetItemCountById(needSuipianID)
 	self.NumLabel.text = string.format("%s%s%s",hasNum,"/",needNum)
 	self.fill.fillAmount = hasNum/needNum
	self.NeoCardEquipPowerupCoinYouNeedLabel.text = needCoin

	local needEquipData=require "StaticData.Item":GetData(needSuipianID)
	PropUtility.AutoSetColor(self.EquipIcon2Frame,needEquipData:GetColor())
	
	utility.LoadSpriteFromPath(iconPath,self.EquipIcon2)
	self.ctrlUpgradeButton.gameObject:SetActive(true)
end

----------------初始化寵物信息------------
function EquipmentWinUpgradeNodeCls:InitPetViews()
	self.NeoCardEquipPowerupCoinYouNeedLabel.text=0
	self.currentColor=self.equipData:GetColor()
	local gameTool = require "Utils.GameTools"
	local AtlasesLoader = require "Utils.AtlasesLoader"
	local PropUtility = require "Utils.PropUtility" 

------------------初始化當前装备信息------------------------------
	--设置星级
	-- gameTool.AutoSetStar(self.EquipStarLayout,self.equipData:GetStar())	
	
	--设置颜色
	PropUtility.AutoSetColor(self.Frame,self.currentColor)
	--
	local infodata,data,name,iconPath,itype = gameTool.GetItemDataById(self.equipID)
	--设置ICon
	utility.LoadSpriteFromPath(iconPath,self.EquipIcon)
	--设置图标
	local tagImagePath = gameTool.GetEquipTagImagePath(self.equipType)
	utility.LoadSpriteFromPath(tagImagePath,self.InfoItemTypeIcon)
	self.InfoItemNameLabel.text=name

------------------初始化升级之后的信息--------------------------------
	if self.currentColor<4 then
		self.ctrlUpgradeButton.gameObject:SetActive(true)
		self.EquipPowerupStatusLayout.gameObject:SetActive(true)
		self.NeedPanel.gameObject:SetActive(true)
		self.Notice.enabled=false
		local staticData = require "StaticData.EquipPetsUp":GetData(self.currentColor+1)
		--升级之后的
		local upEquipData = require "StaticData.Equip":GetData(staticData:GetDisplayId())
		local upGradeId = staticData:GetDisplayId()
		local infodata,data,name,itemIconPath,ItemType = gameTool.GetItemDataById(upGradeId)
		--星级
		-- gameTool.AutoSetStar(self.EquipStarLayout1,upEquipData:GetStarID())
		self.InfoItemNameLabel1.text=name
		--Icon
		utility.LoadSpriteFromPath(itemIconPath,self.EquipIcon1)
		--图标
		local upEquipType =upEquipData:GetType()
		local tagImagePath = gameTool.GetEquipTagImagePath(upEquipType)
		utility.LoadSpriteFromPath(tagImagePath,self.InfoItemTypeIcon1)
 		--设置颜色
 		local color = upEquipData:GetColorID()
	 	PropUtility.AutoSetColor(self.Frame1,color)
		--升级花费
		self.NeoCardEquipPowerupCoinYouNeedLabel.text=staticData:GetCost()

		--升级之前的属性
		local mainPropID=self.equipData:GetEquipStaticData():GetMainPropID()
	  	local _,basis=self.equipData:GetBasisValue(mainPropID)
	  	local addition =self.equipData:GetEquipStaticData():GetPromoteValue()
	  	local level = self.equipData:GetLevel()
		self.EquipPowerupStatus1NameLabel.text=EquipStringTable[mainPropID]
		self.EquipPowerupOldStatus1.text=self.equipData:CalculateAddValue(basis,addition,level)
		self.EquipPowerupNewStatus1_.text=upEquipData:GetHpLimit()
 		--升級之後的屬性
	  	local upMainPropID=upEquipData:GetMainPropID()
	  	local _,upBasis=upEquipData:GetBasisValue(upMainPropID+1)
		self.EquipPowerupStatus1NameLabel1.text=EquipStringTable[mainPropID+1]
 		_,basis=self.equipData:GetBasisValue(mainPropID+1)
		self.EquipPowerupOldStatus11.text=basis.."%"
		self.EquipPowerupNewStatus1_1.text=upBasis.."%"

		--进阶所需要的物品
		local needItemId =staticData:GetItemId()
		local needInfodata,needData,needName,needNtemIconPath,needItemType = gameTool.GetItemDataById(needItemId)
		self.NeedName.text=needName

		local needEquipData=require "StaticData.Item":GetData(needItemId)
		--进阶所需物品的颜色
	 	local color = needEquipData:GetColor()
		PropUtility.AutoSetColor(self.Frame2,color)
		utility.LoadSpriteFromPath(needNtemIconPath,self.EquipIcon2)

		local UserDataType = require "Framework.UserDataType"		
		local itemBagData = self:GetCachedData(UserDataType.ItemBagData)
		local needNum = staticData:GetNeedNum()
		local ownNum = itemBagData:GetItemCountById(needItemId)
		self.NumLabel.text=ownNum..'/'..needNum
		self.fill.fillAmount=ownNum/needNum
	else
		-- self.ctrlUpgradeButton.gameObject:SetActive(false)
		self.Notice.enabled=true
		self.Notice.text='宠物已经进阶到满级'
		self.EquipPowerupStatusLayout.gameObject:SetActive(false)
		self.NeedPanel.gameObject:SetActive(false)
		self.NeoCardEquipPowerupCoinYouNeedLabel.text=0

		--设置星级
		-- gameTool.AutoSetStar(self.EquipStarLayout1,self.equipData:GetStar())	
		
		--设置颜色
		PropUtility.AutoSetColor(self.Frame1,self.currentColor)
		--
		local infodata,data,name,iconPath,itype = gameTool.GetItemDataById(self.equipID)
		--设置ICon
		utility.LoadSpriteFromPath(iconPath,self.EquipIcon1)
		--设置图标
		local tagImagePath = gameTool.GetEquipTagImagePath(self.equipType)
		utility.LoadSpriteFromPath(tagImagePath,self.InfoItemTypeIcon1)
		self.InfoItemNameLabel1.text=name
		debug_print("设置图标",name)

		local mainPropID=self.equipData:GetEquipStaticData():GetMainPropID()
	  	local _,basis=self.equipData:GetBasisValue(mainPropID)
	  	local addition =self.equipData:GetEquipStaticData():GetPromoteValue()
	  	local level = self.equipData:GetLevel()
	  	self.EquipPowerupStatus1NameLabel1.text=EquipStringTable[mainPropID+1]
		self.EquipPowerupStatus1NameLabel.text=EquipStringTable[mainPropID]
		
		self.EquipPowerupOldStatus1.text=self.equipData:CalculateAddValue(basis,addition,level)
		_,basis=self.equipData:GetBasisValue(mainPropID+1)
		self.EquipPowerupOldStatus11.text=basis
		
	end
---------------------进阶需要的物品--------------------------


end

function EquipmentWinUpgradeNodeCls:RegisterControlEvents()
	--	进阶
	self.__event_button_onctrlUpgradeButton_OneClicked__ = UnityEngine.Events.UnityAction(self.OnctrlUpgradeButtonClicked, self)
	self.ctrlUpgradeButton.onClick:AddListener(self.__event_button_onctrlUpgradeButton_OneClicked__)
	
end

function EquipmentWinUpgradeNodeCls:UnregisterControlEvents()
	-- --取消注册 进阶 的事件
	if self.__event_button_onctrlUpgradeButton_OneClicked__ then
		self.ctrlUpgradeButton.onClick:RemoveListener(self.__event_button_onctrlUpgradeButton_OneClicked__)
		self.__event_button_onctrlUpgradeButton_OneClicked__ = nil
	end
end



function EquipmentWinUpgradeNodeCls:PetAdvancedResult(msg)
	print(msg.equipUID,msg.cardUID,'**************************************')
	
	self:DispatchEvent(messageGuids.UpdataKnapsackWindow,nil,4)
	self:InitViews()
end




function EquipmentWinUpgradeNodeCls:RegisterNetworkEvents()
	self.game:RegisterMsgHandler(net.S2CPetAdvancedResult, self, self.PetAdvancedResult)
	self.game:RegisterMsgHandler(net.S2CEquipChibangColorUpResult,self,self.OnEquipChibangColorUpResponse)
end

function EquipmentWinUpgradeNodeCls:UnregisterNetworkEvents()
	self.game:UnRegisterMsgHandler(net.S2CPetAdvancedResult, self, self.PetAdvancedResult)
	self.game:RegisterMsgHandler(net.S2CEquipChibangColorUpResult,self,self.OnEquipChibangColorUpResponse)
end

function EquipmentWinUpgradeNodeCls:OnEquipChibangColorUpRequest(equipUID)
	self.game:SendNetworkMessage(require "Network.ServerService".OnEquipChibangColorUpRequest(equipUID))
end

function EquipmentWinUpgradeNodeCls:OnEquipChibangColorUpResponse(msg)
	-- 翅膀进阶
	print("翅膀进阶成功",msg.success,msg.ismax)
	self:InitViews()
end
-----------------------------------------------------------------------
local function DelayRefreshItem(self,uid,roleUid)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	print(uid)
	self.equipUID=uid
	self.roleUid = roleUid
	self:InitViews()
end

function EquipmentWinUpgradeNodeCls:RefreshItem(uid,roleUid)
	-- coroutine.start(DelayRefreshItem,self,uid,roleUid)
	self:StartCoroutine(DelayRefreshItem, uid,roleUid)
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function EquipmentWinUpgradeNodeCls:OnctrlUpgradeButtonClicked()
	-- 进阶

 	if self.equipType==KEquipType_EquipPet then
 		if self.currentColor<4 then

 				print(self.equipUID)
		self.game:SendNetworkMessage(require "Network.ServerService".PetAdvancedRequest(self.equipUID))
	    else

	    end
	elseif self.equipType == KEquipType_EquipWing then
		-- 翅膀进阶
		if self.currentWingColor < 4 then
			local staticData = require "StaticData.EquipWingUp":GetData(self.wingUpId)
			local level = self.equipData:GetLevel()
			if level >= staticData:GetLevelLimit() then
				self:OnEquipChibangColorUpRequest(self.equipUID)
			else
				local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        		local windowManager = utility:GetGame():GetWindowManager()
        		windowManager:Show(ErrorDialogClass, string.format("本次进阶需要翅膀等级到达%s级！",staticData:GetLevelLimit()))
			end
		end
 	end
	

end

return EquipmentWinUpgradeNodeCls