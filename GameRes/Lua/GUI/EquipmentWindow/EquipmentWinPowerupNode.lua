local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "Const"
require "LUT.StringTable"
require "Collection.OrderedDictionary"
local net = require "Network.Net"
local messageGuids = require "Framework.Business.MessageGuids"
local messageManager = require "Network.MessageManager"
local EquipmentWinPowerupNodeCls = Class(BaseNodeClass)

function EquipmentWinPowerupNodeCls:Ctor(parent,ctrlWeaponPowerupButton,ctrlWeaponAutoPowerupButton,ctrlPetPowerupAutoButton)
	self.parent = parent

	-- 强化
	self.ctrlWeaponPowerupButton = ctrlWeaponPowerupButton
	-- 自动强化
	self.ctrlWeaponAutoPowerupButton = ctrlWeaponAutoPowerupButton
	--宠物和翅膀的一键添加
	self.ctrlPetPowerupAutoButton = ctrlPetPowerupAutoButton
	--当前已选择的Dic
	self.chooseDict = OrderedDictionary.New()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function EquipmentWinPowerupNodeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/EquipmentPowerup', function(go)
		self:BindComponent(go,false)
	end)
end

function EquipmentWinPowerupNodeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
	self:LoadPowerupStatus()
end

function EquipmentWinPowerupNodeCls:OnResume()
	-- 界面显示时调用
	EquipmentWinPowerupNodeCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self.isPlayingEffect = false
end

function EquipmentWinPowerupNodeCls:OnPause()
	-- 界面隐藏时调用
	EquipmentWinPowerupNodeCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:HideStatusNode()
	self:SetButtonsDefautTheme()
	if self.chooseDict ~= nil then
		self.chooseDict:Clear()
	end
end

function EquipmentWinPowerupNodeCls:OnEnter()
	-- Node Enter时调用
	EquipmentWinPowerupNodeCls.base.OnEnter(self)
end

function EquipmentWinPowerupNodeCls:OnExit()
	-- Node Exit时调用
	EquipmentWinPowerupNodeCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function EquipmentWinPowerupNodeCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()
	--Item边框
	self.itemFrame=transform:Find('ItemBox/Frame')
	--装备图片
	self.EquipIcon=transform:Find('ItemBox/EquipIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.CrossButton = transform:Find('CrossButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--等级
	self.EquipLevelNuLabel=transform:Find('ItemBox/BackpackEquipLevelNuLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	--星级
	self.StarLayout=transform:Find('ItemBox/EquipStarLayout')
	
	--ssr
	self.RarityImage=transform:Find('ItemBox/Rarity'):GetComponent(typeof(UnityEngine.UI.Image))
	
	--宝石一
	self.GemFirstPlusButton = transform:Find('ItemBox/GemFirstPlusButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--宝石二
	self.GemSecondPlusButton = transform:Find('ItemBox/GemSecondPlusButton'):GetComponent(typeof(UnityEngine.UI.Button))

	--装备类型图片
	self.InfoItemTypeIcon = transform:Find('ItemNameBase/InfoItemTypeIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	--装备名称
	self.InfoItemNameLabel = transform:Find('ItemNameBase/InfoItemNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.RoleBindingObj= transform:Find('BingdingNameBase')
	--绑定名字
	self.CardNameLabel = transform:Find('BingdingNameBase/CardNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--装备描述
	self.EquipINfoTextLabel = transform:Find('InfoBase/EquipINfoTextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--消耗金币
	self.NeoCardEquipPowerupCoinYouNeedLabel = transform:Find('LevelUpBase/CoinYouNeed/NeoCardEquipPowerupCoinYouNeedLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--提升等级
	self.NeoCardEquipPowerupCoinYouNeedLabel2 = transform:Find('LevelUpBase/LevelNum/NeoCardEquipPowerupCoinYouNeedLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--提升等级名称
	self.EquipPowerupStatus1NameLabel6 = transform:Find('LevelUpBase/EquipPowerupStatusLayout/EquipPowerupStatus1/EquipPowerupStatus1NameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.EquipPowerupOldStatus16 = transform:Find('LevelUpBase/EquipPowerupStatusLayout/EquipPowerupStatus1/EquipPowerupStatusBase1/EquipPowerupOldStatus1'):GetComponent(typeof(UnityEngine.UI.Text))
	self.EquipPowerupNewStatus1_6 = transform:Find('LevelUpBase/EquipPowerupStatusLayout/EquipPowerupStatus1/EquipPowerupStatusBase1/EquipPowerupNewStatus1 '):GetComponent(typeof(UnityEngine.UI.Text))
	
	self.EquipPowerupStatus1NameLabel7 = transform:Find('LevelUpBase/EquipPowerupStatusLayout/EquipPowerupStatus1 (1)/EquipPowerupStatus1NameLabel'):GetComponent(typeof(UnityEngine.UI.Text))	
	self.EquipPowerupOldStatus17 = transform:Find('LevelUpBase/EquipPowerupStatusLayout/EquipPowerupStatus1 (1)/EquipPowerupStatusBase1/EquipPowerupOldStatus1'):GetComponent(typeof(UnityEngine.UI.Text))
	self.EquipPowerupNewStatus1_7 = transform:Find('LevelUpBase/EquipPowerupStatusLayout/EquipPowerupStatus1 (1)/EquipPowerupStatusBase1/EquipPowerupNewStatus1 '):GetComponent(typeof(UnityEngine.UI.Text))
	self.EquipPetPowerupMax = transform:Find('LevelUpMax')
	self.EquipPowerupMaxText = transform:Find('LevelUpMax/NeoCardEquipPowerupCoinYouNeedLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.EquipPetPowerupPanel = transform:Find('LevelUpBase')
	self.EquipPetPowerupPanel.gameObject:SetActive(true)
	self.EquipPetPowerupMax.gameObject:SetActive(false)
	--宠物Button
	self.buttonList={}
	self.buttonList[1]={}
	self.buttonList[1].baseAsAddMateriaButton = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox/baseAsAddMateriaButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.buttonList[1].Frame = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox/Frame')
	self.buttonList[1].ItemIcon = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox/ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.buttonList[1].PlusImage = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox/PlusImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.buttonList[1].levelText = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox/ItemLevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
	self.buttonList[2]={}
	self.buttonList[2].baseAsAddMateriaButton = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox (1)/baseAsAddMateriaButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.buttonList[2].Frame = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox (1)/Frame')
	self.buttonList[2].ItemIcon = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox (1)/ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.buttonList[2].PlusImage = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox (1)/PlusImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.buttonList[2].levelText = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox (1)/ItemLevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
	self.buttonList[3]={}
	self.buttonList[3].baseAsAddMateriaButton = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox (2)/baseAsAddMateriaButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.buttonList[3].Frame = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox (2)/Frame')
	self.buttonList[3].ItemIcon = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox (2)/ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.buttonList[3].PlusImage = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox (2)/PlusImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.buttonList[3].levelText = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox (2)/ItemLevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	self.buttonList[4]={}
	self.buttonList[4].baseAsAddMateriaButton = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox (3)/baseAsAddMateriaButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.buttonList[4].Frame = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox (3)/Frame')
	self.buttonList[4].ItemIcon = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox (3)/ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.buttonList[4].PlusImage = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox (3)/PlusImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.buttonList[4].levelText = transform:Find('LevelUpBase/AddMaterialBoxLayout/AddMaterialBox (3)/ItemLevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--提示
	self.Notice = transform:Find('Notice'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Notice__1_ = transform:Find('Notice (1)'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Notice__2_ = transform:Find('Notice (2)'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Bar = transform:Find('Bar')
	self.StatusBase = transform:Find('StatusBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LevelUpBase = transform:Find('LevelUpBase').gameObject

	for i=1,#self.buttonList do
		self.buttonList[i].ItemIcon.enabled=false
		self.buttonList[i].levelText.gameObject:SetActive(false)
	end

	-- 属性挂点
	self.StatusPoint = transform:Find('StatusBase/EquipPowerupStatusLayout')
	-- 属性列表
	self.StatusNodeTabel = {}
	-- 普通强化花费
	self.normalUpCostLabel = transform:Find('StatusBase/CoinYouNeed/NeoCardEquipPowerupCoinYouNeedLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 获得经验文字描述
	self.upHintLabel =  transform:Find('LevelUpBase/LevelNum/CoinYouNeedText '):GetComponent(typeof(UnityEngine.UI.Text))

	-- 特效
	local effectCanvas = transform:Find('EffectCanvas'):GetComponent(typeof(UnityEngine.RectTransform))
	utility.SetRectDefaut(effectCanvas)
	self.effectPatical = transform:Find('EffectCanvas/UI_zhuangbeiqianghua/Glow1'):GetComponent(typeof(UnityEngine.ParticleSystem))
	
end

function EquipmentWinPowerupNodeCls:LoadPowerupStatus()
	-- 加载强化属性Node
	local nodeCls = require "GUI.EquipmentWindow.EquipPowerupStatus"
	for i = 1, 6 do
		local node = nodeCls.New(self.StatusPoint)
		self.StatusNodeTabel[#self.StatusNodeTabel + 1] = node
	end
end


function EquipmentWinPowerupNodeCls:InitViews()
--	self.itemID=
 	local UserDataType = require "Framework.UserDataType"
 	local tempData = self:GetCachedData(UserDataType.EquipBagData)
 	self.equipData=tempData:GetItem(self.equipUID)
 	self.equipID=self.equipData:GetEquipID()
 	self.equipType =self.equipData:GetEquipType()
 	--debug_print(self.equipType)
 	if self.equipType==KEquipType_EquipPet then
 		self:InitPetViews()
 	elseif self.equipType == KEquipType_EquipWeapon or self.equipType == KEquipType_EquipArmor then
 		
 		-- 普通装备强化
 		self:InitNormalEquipPanel()
 		self:InitEquipInfoView()
 		self:RefreshStatusNode()
 		local cost = self:GetUpCost()
 		self.normalUpCostLabel.text = cost
 	elseif self.equipType == KEquipType_EquipFashion then
 		self:InitFashionVariable(self.equipID)
 		self:InitFashionPanel()
 		self:InitEquipInfoView()
 		self:RefreshFashionView()
 	elseif self.equipType == KEquipType_EquipWing then
 		self:InitWingVariable(self.equipID)
 		self:InitWingPanel()
 		self:InitEquipInfoView()
 		self:RefreshFashionView()
 		self:UpdateExpAndCoin(0)
 	end
end
----------------------------------------------------
function EquipmentWinPowerupNodeCls:InitWingPanel()
	self.upHintLabel.text = "提升经验"
	self.Notice.gameObject:SetActive(true)
	self.Notice__1_ .gameObject:SetActive(false)
	self.Notice__2_ .gameObject:SetActive(false)
	self.Bar.gameObject:SetActive(false)
	self.StatusBase .gameObject:SetActive(false)
	self.GemFirstPlusButton .gameObject:SetActive(false)
	self.GemSecondPlusButton .gameObject:SetActive(false)
	self.LevelUpBase:SetActive(true)
	self.StatusBase.gameObject:SetActive(false)
	self.ctrlWeaponPowerupButton.gameObject:SetActive(true)
	self.ctrlPetPowerupAutoButton.gameObject:SetActive(true)
end

----------------初始化寵物信息------------
function EquipmentWinPowerupNodeCls:InitPetViews()
	---隐藏不需要的信息
	self.Notice.gameObject:SetActive(true)
	self.Notice__1_ .gameObject:SetActive(false)
	self.Notice__2_ .gameObject:SetActive(false)
	self.Bar.gameObject:SetActive(false)
	self.StatusBase .gameObject:SetActive(false)
	self.GemFirstPlusButton .gameObject:SetActive(false)
	self.GemSecondPlusButton .gameObject:SetActive(false)
	self.LevelUpBase:SetActive(true)

	---初始化宠物信息
	self.consumeEquipUIDList=""
	local gameTool = require "Utils.GameTools"
	local AtlasesLoader = require "Utils.AtlasesLoader"
	local PropUtility = require "Utils.PropUtility" 
	self.level=self.equipData:GetLevel()
 	self.EquipLevelNuLabel.text=self.equipData:GetLevel()..'/'..utility.GetPetMaxLevel()
	local rarity = self.equipData:GetRarity()
	utility.LoadSpriteFromPath(rarity,self.RarityImage)
 	-- gameTool.AutoSetStar(self.StarLayout,self.equipData:GetStar())
 	PropUtility.AutoSetColor(self.itemFrame,self.equipData:GetColor())

 	local infodata,data,name,iconPath,itype = gameTool.GetItemDataById(self.equipID)
 	self.InfoItemNameLabel.text=name
 	--绑定
 	local bindCardUID = self.equipData:GetBindCardUID()
	local isBind = bindCardUID ~= ""
	self.RoleBindingObj.gameObject:SetActive(isBind)
	if isBind then
		local UserDataType = require "Framework.UserDataType"
		local RoleCachedData = self:GetCachedData(UserDataType.CardBagData)
		local bindRoleId = RoleCachedData:GetIdFromUid(bindCardUID)
		local roleStaticData = require "StaticData.RoleInfo":GetData(bindRoleId)
		local roleName = roleStaticData:GetName()
		self.CardNameLabel.text = roleName
	end

	-- 图标
	utility.LoadSpriteFromPath(iconPath,self.EquipIcon)

	local equipType =self.equipData:GetEquipType()
	local tagImagePath = gameTool.GetEquipTagImagePath(equipType)
	utility.LoadSpriteFromPath(tagImagePath,self.InfoItemTypeIcon)

	--描述
	self.EquipINfoTextLabel.text = infodata:GetDesc()
	----------------------设置升级变化值----------------------
	--
	--self.NeoCardEquipPowerupCoinYouNeedLabel.text=0
	--提升等级
	--self.NeoCardEquipPowerupCoinYouNeedLabel2 .text=0
	self.NeoCardEquipPowerupCoinYouNeedLabel2.text=0
	self.NeoCardEquipPowerupCoinYouNeedLabel.text=0
	
	self.EquipPowerupOldStatus16.text =self.level
	self.EquipPowerupNewStatus1_6.text = self.level+1
	--设置主属性的参数显示
	local mainPropID=self.equipData:GetEquipStaticData():GetMainPropID()
  	local _,basis=self.equipData:GetBasisValue(mainPropID)
  	local addition =self.equipData:GetEquipStaticData():GetPromoteValue()

	self.EquipPowerupStatus1NameLabel7.text = EquipStringTable[mainPropID]
	self.EquipPowerupOldStatus17 .text= self.equipData:CalculateAddValue(basis,addition,self.level)
	self.EquipPowerupNewStatus1_7 .text=self.equipData:CalculateAddValue(basis,addition,self.level+1)


	self.ctrlWeaponPowerupButton.gameObject:SetActive(true)
	self.ctrlPetPowerupAutoButton.gameObject:SetActive(true)

	-- local chooseNum = 4
	-- if (9- self.level)<=4 then
	-- 	chooseNum=9- self.level
	-- end
	-- debug_print("chooseNum",chooseNum)
	if (utility.GetPetMaxLevel()- self.level)<=0 then
		self.EquipPowerupMaxText.text="宠物已满级"
		self.EquipPetPowerupMax.gameObject:SetActive(true)
		self.EquipPetPowerupPanel.gameObject:SetActive(false)
	else
		self.EquipPetPowerupMax.gameObject:SetActive(false)
		self.EquipPetPowerupPanel.gameObject:SetActive(true)
	end


end

function EquipmentWinPowerupNodeCls:KEquipType_EquipArmor()
	-- 初始化装备信息
end

----------------------------------------------------------------------------------
function EquipmentWinPowerupNodeCls:InitNormalEquipPanel()
	-- 初始化普通装备强化panel
	self.LevelUpBase:SetActive(false)
	self.ctrlWeaponPowerupButton.gameObject:SetActive(true)
	self.ctrlWeaponAutoPowerupButton.gameObject:SetActive(true)
	self.StatusBase.gameObject:SetActive(true)
	self.upHintLabel.text = EquipStringTable[39]
end

function EquipmentWinPowerupNodeCls:InitEquipInfoView()
	-- 初始化装备信息
	local gameTool = require "Utils.GameTools"
	local AtlasesLoader = require "Utils.AtlasesLoader"
	local PropUtility = require "Utils.PropUtility" 
	local rarity = self.equipData:GetRarity()
	utility.LoadSpriteFromPath(rarity,self.RarityImage)
 	-- gameTool.AutoSetStar(self.StarLayout,self.equipData:GetStar())
 	PropUtility.AutoSetColor(self.itemFrame,self.equipData:GetColor())

 	local infodata,data,name,iconPath,itype = gameTool.GetItemDataById(self.equipID)
 	self.InfoItemNameLabel.text=name
  	--绑定
 	local bindCardUID = self.equipData:GetBindCardUID()
	local isBind = bindCardUID ~= ""
	self.RoleBindingObj.gameObject:SetActive(isBind)
	if isBind then
		local UserDataType = require "Framework.UserDataType"
		local RoleCachedData = self:GetCachedData(UserDataType.CardBagData)
		local bindRoleId = RoleCachedData:GetIdFromUid(bindCardUID)
		local roleStaticData = require "StaticData.RoleInfo":GetData(bindRoleId)
		local roleName = roleStaticData:GetName()
		self.CardNameLabel.text = roleName
	end

	-- 图标
	utility.LoadSpriteFromPath(iconPath,self.EquipIcon)

	local equipType =self.equipData:GetEquipType()
	local tagImagePath = gameTool.GetEquipTagImagePath(equipType)
	utility.LoadSpriteFromPath(tagImagePath,self.InfoItemTypeIcon)

	--描述
	self.EquipINfoTextLabel.text = infodata:GetDesc()

	-- 等级
	self.level = self.equipData:GetLevel()
	self.equipLevelLimit = self:GetPlayerCurrLevel()

 	self.EquipLevelNuLabel.text =  string.format("%s%s%s",self.level,"/",self.equipLevelLimit)
	if self.equipType == KEquipType_EquipWing then
		debug_print()
		if self.maxEquipLevel - self.level<=0 then
			self.EquipPowerupMaxText.text="翅膀已满级"
			self.EquipPetPowerupMax.gameObject:SetActive(true)
			self.EquipPetPowerupPanel.gameObject:SetActive(false)
		else
			self.EquipPetPowerupMax.gameObject:SetActive(false)
			self.EquipPetPowerupPanel.gameObject:SetActive(true)
		end
	end

end

function EquipmentWinPowerupNodeCls:GetPlayerCurrLevel()
	-- 获取玩家当前等级
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    local level = userData:GetLevel()
    level = math.min(kMaxPlayerLevelNum,level)
    return level
end

function EquipmentWinPowerupNodeCls:GetAttributeDict()
	-- 获取属性字典
	local attDict,mainId = self.equipData:GetEquipAttribute()
  	local addition =self.equipData:GetEquipStaticData():GetPromoteValue()
 
  	return attDict,mainId,addition
end

function EquipmentWinPowerupNodeCls:RefreshStatusNode()
	-- 刷新属性node
	local attDict,mainId,addition = self:GetAttributeDict()

	local keys = attDict:GetKeys()
	for i = 1,#keys do
		local node = self.StatusNodeTabel[i]
		local active = node:GetActive()
		if not active then
			self:AddChild(node)
			node:SetActive(true)
		end

		local attId = keys[i]
		local attValue = attDict:GetEntryByKey(attId)
		if self.level >= self.equipLevelLimit then
			addition = 0
		end
		node:RefreshItem(attId,attValue,mainId,addition)
	end
end

function EquipmentWinPowerupNodeCls:HideStatusNode()
	for i = 1 ,#self.StatusNodeTabel do
		local node = self.StatusNodeTabel[i]
		local active = node:GetActive()
		if active then
			self:RemoveChild(node)
			node:SetActive(false)
		end
	end
end

function EquipmentWinPowerupNodeCls:GetUpCost()
	-- 获取消耗花费
	local staticData = require "StaticData.EquipStrengthen":GetData(self.level)
	local cost

	if self.equipType == KEquipType_EquipWeapon then
		cost = staticData:GetAttackNeedCoin()
	elseif self.equipType == KEquipType_EquipArmor then
		cost = staticData:GetADefeneNeedCoin()
	end

	return cost
end

function EquipmentWinPowerupNodeCls:InitFashionVariable(id)
	-- 初始化时装变量
	local staticdata = require  "StaticData.EquipFashion":GetData(self.equipID)
	self.maxEquipLevel = staticdata:GetMaxLv()
	self.oneFashionExp = staticdata:GetExp01()

	self.fashionUidStr = ""
end

function EquipmentWinPowerupNodeCls:InitWingVariable(id)
	-- 初始化翅膀变量
	local staticdata = require  "StaticData.EquipWingExp":GetData(1)
	self.maxEquipLevel = 80
	self.blueProvideExp = staticdata:GetBlueProvideExp()
	self.greenProvideExp = staticdata:GetGreenProvideExp()
	self.coinXishu = staticdata:GetCoinXishu()

	self.WingUidStr = ""
end

function EquipmentWinPowerupNodeCls:InitFashionPanel()
	-- 初始化时装panel

	self.Notice__1_ .gameObject:SetActive(false)
	self.Notice__2_ .gameObject:SetActive(false)
	self.Bar.gameObject:SetActive(false)
	self.StatusBase .gameObject:SetActive(false)
	self.GemFirstPlusButton .gameObject:SetActive(false)
	self.GemSecondPlusButton .gameObject:SetActive(false)
	self.ctrlWeaponAutoPowerupButton.gameObject:SetActive(false)
	self.Notice.gameObject:SetActive(true)
	self.LevelUpBase:SetActive(true)
	self.ctrlWeaponPowerupButton.gameObject:SetActive(true)

	self.upHintLabel.text = EquipStringTable[39]
	self.NeoCardEquipPowerupCoinYouNeedLabel2.text = 0
end

function EquipmentWinPowerupNodeCls:RefreshFashionView()
	-- 刷新时装强化
	self.EquipLevelNuLabel.text =  string.format("%s%s%s",self.level,"/",self.maxEquipLevel)
	
	-- 等级
	self.EquipPowerupOldStatus16.text = self.level
	self.EquipPowerupNewStatus1_6.text = math.min(self.level + 1 ,self.maxEquipLevel)

	-- 主属性
	local attDict,mainId,addition = self:GetAttributeDict()
	local mainValue = attDict:GetEntryByKey(mainId)
	if self.level >= self.maxEquipLevel then
		addition = 0
	end

	local gameTool = require "Utils.GameTools"
	self.EquipPowerupOldStatus17 .text = gameTool.UpdatePropValue(mainId,mainValue)
	self.EquipPowerupNewStatus1_7 .text = gameTool.UpdatePropValue(mainId,mainValue + addition)
	local mainStr = EquipStringTable[mainId]
	self.EquipPowerupStatus1NameLabel7.text = mainStr
end

function EquipmentWinPowerupNodeCls:UpdateExpAndCoin(exp)
	-- 刷新经验 和金币
	local costCoin = exp * self.coinXishu
	self.NeoCardEquipPowerupCoinYouNeedLabel.text = costCoin
	self.NeoCardEquipPowerupCoinYouNeedLabel2.text = exp
end

-------------------------------------------------------------------------------------------------
function EquipmentWinPowerupNodeCls:RegisterControlEvents()
		-- 注册 baseAsAddMateriaButton 的事件
	self.__event_button_onbaseAsAddMateriaButtonClicked__ = UnityEngine.Events.UnityAction(self.OnbaseAsAddMateriaButtonClicked, self)
	self.buttonList[1].baseAsAddMateriaButton.onClick:AddListener(self.__event_button_onbaseAsAddMateriaButtonClicked__)

	-- 注册 baseAsAddMateriaButton1 的事件
	self.__event_button_onbaseAsAddMateriaButton1Clicked__ = UnityEngine.Events.UnityAction(self.OnbaseAsAddMateriaButton1Clicked, self)
	self.buttonList[2].baseAsAddMateriaButton.onClick:AddListener(self.__event_button_onbaseAsAddMateriaButton1Clicked__)

	-- 注册 baseAsAddMateriaButton2 的事件
	self.__event_button_onbaseAsAddMateriaButton2Clicked__ = UnityEngine.Events.UnityAction(self.OnbaseAsAddMateriaButton2Clicked, self)
	self.buttonList[3].baseAsAddMateriaButton.onClick:AddListener(self.__event_button_onbaseAsAddMateriaButton2Clicked__)

	-- 注册 baseAsAddMateriaButton3 的事件
	self.__event_button_onbaseAsAddMateriaButton3Clicked__ = UnityEngine.Events.UnityAction(self.OnbaseAsAddMateriaButton3Clicked, self)
	self.buttonList[4].baseAsAddMateriaButton.onClick:AddListener(self.__event_button_onbaseAsAddMateriaButton3Clicked__)

	--	强化
	self.__event_button_onctrlWeaponPowerupButton_OneClicked__ = UnityEngine.Events.UnityAction(self.OnctrlWeaponPowerupButtonClicked, self)
	self.ctrlWeaponPowerupButton.onClick:AddListener(self.__event_button_onctrlWeaponPowerupButton_OneClicked__)

	--	自动强化
	self.__event_button_onctrlWeaponAutoPowerupButton_OneClicked__ = UnityEngine.Events.UnityAction(self.OnctrlWeaponAutoPowerupButtonClicked, self)
	self.ctrlWeaponAutoPowerupButton.onClick:AddListener(self.__event_button_onctrlWeaponAutoPowerupButton_OneClicked__)
		--	宠物一键添加
	self.__event_button_onctrlPetPowerupAutoButton_OnClicked__ = UnityEngine.Events.UnityAction(self.OnctrlPetPowerupAutoButtonClicked, self)
	self.ctrlPetPowerupAutoButton.onClick:AddListener(self.__event_button_onctrlPetPowerupAutoButton_OnClicked__)
	
end

function EquipmentWinPowerupNodeCls:UnregisterControlEvents()

	-- 取消注册 宠物一键添加的事件
	if self.__event_button_onctrlPetPowerupAutoButton_OnClicked__ then
		self.ctrlPetPowerupAutoButton.onClick:RemoveListener(self.__event_button_onctrlPetPowerupAutoButton_OnClicked__)
		self.__event_button_onctrlPetPowerupAutoButton_OnClicked__ = nil
	end

		-- 取消注册 baseAsAddMateriaButton 的事件
	if self.__event_button_onbaseAsAddMateriaButtonClicked__ then
		self.buttonList[1].baseAsAddMateriaButton.onClick:RemoveListener(self.__event_button_onbaseAsAddMateriaButtonClicked__)
		self.__event_button_onbaseAsAddMateriaButtonClicked__ = nil
	end

	-- 取消注册 baseAsAddMateriaButton1 的事件
	if self.__event_button_onbaseAsAddMateriaButton1Clicked__ then
		self.buttonList[2].baseAsAddMateriaButton.onClick:RemoveListener(self.__event_button_onbaseAsAddMateriaButton1Clicked__)
		self.__event_button_onbaseAsAddMateriaButton1Clicked__ = nil
	end

	-- 取消注册 baseAsAddMateriaButton2 的事件
	if self.__event_button_onbaseAsAddMateriaButton2Clicked__ then
		self.buttonList[3].baseAsAddMateriaButton.onClick:RemoveListener(self.__event_button_onbaseAsAddMateriaButton2Clicked__)
		self.__event_button_onbaseAsAddMateriaButton2Clicked__ = nil
	end

	-- 取消注册 baseAsAddMateriaButton3 的事件
	if self.__event_button_onbaseAsAddMateriaButton3Clicked__ then
		self.buttonList[4].baseAsAddMateriaButton.onClick:RemoveListener(self.__event_button_onbaseAsAddMateriaButton3Clicked__)
		self.__event_button_onbaseAsAddMateriaButton3Clicked__ = nil
	end

	-- --取消注册 强化 的事件
	if self.__event_button_onctrlWeaponPowerupButton_OneClicked__ then
		self.ctrlWeaponPowerupButton.onClick:RemoveListener(self.__event_button_onctrlWeaponPowerupButton_OneClicked__)
		self.__event_button_onctrlWeaponPowerupButton_OneClicked__ = nil
	end

	-- --取消注册 自动强化 的事件
	if self.__event_button_onctrlWeaponAutoPowerupButton_OneClicked__ then
		self.ctrlWeaponAutoPowerupButton.onClick:RemoveListener(self.__event_button_onctrlWeaponAutoPowerupButton_OneClicked__)
		self.__event_button_onctrlWeaponAutoPowerupButton_OneClicked__ = nil
	end
end



----------------------------------------------------------------------
local function DelayRefreshItem(self,uid)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	print(uid)
	self.equipUID=uid
	self:InitViews()
end

function EquipmentWinPowerupNodeCls:RefreshItem(uid)
	-- coroutine.start(DelayRefreshItem,self,uid)
	self:StartCoroutine(DelayRefreshItem, uid)
end

--获取装备的数据集合
function EquipmentWinPowerupNodeCls:GetGemDataDict()
	-- 获取宝石dict
	local UserDataType = require "Framework.UserDataType"
	local cachedData = self:GetCachedData(UserDataType.EquipBagData)

    local data = cachedData:RetrievalByResultFunc(function(item)
        local itemType = item:GetEquipType()
        	
        if itemType == KEquipType_EquipPet then
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

function EquipmentWinPowerupNodeCls:GetEquipDataDict(itype)
	local UserDataType = require "Framework.UserDataType"
	local cachedData = self:GetCachedData(UserDataType.EquipBagData)

    local data = cachedData:RetrievalByResultFunc(function(item)
        local itemType = item:GetEquipType()
        
        if itemType == itype then
        	if self.equipData:GetEquipID() ~= item:GetEquipID() then
        		return nil
        	end
        	if self.equipData:GetEquipUID() == item:GetEquipUID() then
        		return nil
        	end
        	local uid = item:GetEquipUID()
        	return true,uid
        end
       	return nil 
    end)
 	
	return data
end

function EquipmentWinPowerupNodeCls:GetEquipDataDictByColor()
	local UserDataType = require "Framework.UserDataType"
	local cachedData = self:GetCachedData(UserDataType.EquipBagData)

    local data = cachedData:RetrievalByResultFunc(function(item)
        local color = item:GetColor()
        if color < 3 and color > 0 then
        	local itemType = item:GetEquipType() 
        
        	if itemType ~= KEquipType_EquipWeapon and itemType ~= KEquipType_EquipArmor and itemType ~= KEquipType_EquipAccessories and itemType ~= KEquipType_EquipShoesr then
        		return nil
        	end

        	if self.equipData:GetEquipUID() == item:GetEquipUID() then
        		return nil
        	end
        	local uid = item:GetEquipUID()
        	return true,uid
        end
       	return nil 
    end)

	data:Reverse()
	return data
end

-----------------------------------------------------------------------
--- 回掉函数
-----------------------------------------------------------------------

function EquipmentWinPowerupNodeCls:ClickedPetItemCallBack(uid,active,index,tables)
	-- body
	--debug_print("ClickedPetItemCallBack",uid,active,index,tables.active,tables.index,tables.uid)
	if  tables.active then
		if  self.chooseDict:Count() < #self.buttonList then
			self.chooseDict:Add(index,uid)
		end
	else
		if self.chooseDict:Contains(index) then
			self.chooseDict:Remove(index)
		end
	end

	-- for i=1, self.chooseDict:Count() do
	-- 	debug_print(self.chooseDict:GetEntryByIndex(i))
	-- end
	
end

function EquipmentWinPowerupNodeCls:ConfirmFashiomFunc()
	-- 确定按钮
	self.fashionUidStr = ""

	local UserDataType = require "Framework.UserDataType"
 	local CachedData = self:GetCachedData(UserDataType.EquipBagData)
	
	-- 所得经验
	local allExp = 0
	for i = 1 ,self.chooseDict:Count() do
		local uid = self.chooseDict:GetEntryByIndex(i)
		local itemData = CachedData:GetItem(uid)
		local itemColor = itemData:GetColor()
		
		local gameTool = require "Utils.GameTools"
		local AtlasesLoader = require "Utils.AtlasesLoader"
		local PropUtility = require "Utils.PropUtility"

 		PropUtility.AutoSetColor(self.buttonList[i].Frame,itemColor)
 		local _,_,_,iconPath,_ = gameTool.GetItemDataById(itemData:GetEquipID()) 	
		utility.LoadSpriteFromPath(iconPath,self.buttonList[i].ItemIcon)
		self.buttonList[i].levelText.gameObject:SetActive(true)
		self.buttonList[i].levelText.text="Lv"..itemData:GetLevel()
		self.buttonList[i].ItemIcon.enabled=true
		self.buttonList[i].PlusImage.enabled=false
		
		-- uid字符串
		self.fashionUidStr = string.format("%s%s%s",self.fashionUidStr,uid,",")

		local level = itemData:GetLevel()
		level = level * self.oneFashionExp
		allExp = allExp + level
	end

	self.NeoCardEquipPowerupCoinYouNeedLabel2.text = allExp
	print(self.fashionUidStr,"uid字符串")
end

function EquipmentWinPowerupNodeCls:ConfirmWingFunc()
	-- 确定按钮
	self.WingUidStr = ""

	local UserDataType = require "Framework.UserDataType"
 	local CachedData = self:GetCachedData(UserDataType.EquipBagData)
	-- 所得经验
	local allExp = 0
	for i = 1 ,self.chooseDict:Count() do
		local uid = self.chooseDict:GetEntryByIndex(i)
		local itemData = CachedData:GetItem(uid)
		local itemColor = itemData:GetColor()
		
		local gameTool = require "Utils.GameTools"
		local AtlasesLoader = require "Utils.AtlasesLoader"
		local PropUtility = require "Utils.PropUtility"

 		PropUtility.AutoSetColor(self.buttonList[i].Frame,itemColor)
 		local _,_,_,iconPath,_ = gameTool.GetItemDataById(itemData:GetEquipID()) 	
		utility.LoadSpriteFromPath(iconPath,self.buttonList[i].ItemIcon)
		self.buttonList[i].ItemIcon.enabled=true
		self.buttonList[i].PlusImage.enabled=false
		self.buttonList[i].levelText.gameObject:SetActive(true)
		self.buttonList[i].levelText.text="Lv"..itemData:GetLevel()
		
		-- uid字符串
		self.WingUidStr = string.format("%s%s%s",self.WingUidStr,uid,",")

		local level
		if itemColor == 1 then
			level = self.greenProvideExp
		elseif itemColor == 2 then
			level = self.blueProvideExp
		end
		allExp = allExp + level
	end
	self:UpdateExpAndCoin(allExp)
	self.chooseDict:Clear()
	print(self.WingUidStr,"uid字符串")
end

function EquipmentWinPowerupNodeCls:CalculateUpLevel(petUpExp)
--	debug_print(petUpExp,"petUpExp")
	--当前的经验
	local EquipPetsLevel = require"StaticData.EquipPetsLevel"
	local data =EquipPetsLevel:GetData(self.level)
	--当前的经验值
	local currentExp=data:GetNeedExp()+petUpExp
	--debug_print(currentExp,petUpExp,self.level)

	local upNum = 0
	local lastLevelExp = 0
	for i=self.level,utility.GetPetMaxLevel() do
		local tempExp = EquipPetsLevel:GetData(i):GetNeedExp()
		if tempExp>=currentExp and currentExp>lastLevelExp then
			upNum=i-self.level
			print(tempExp,lastLevelExp,currentExp,upNum)
			lastLevelExp=tempExp
			break
		else
			upNum=i-self.level

		end
	end
--debug_print(upNum)
	self.NeoCardEquipPowerupCoinYouNeedLabel2.text=upNum
end

function EquipmentWinPowerupNodeCls:ClosePetPowerUpFunc()
	-- 确定按钮


	debug_print("CloseFunc")
	self.consumeEquipUIDList=""
	self.NeoCardEquipPowerupCoinYouNeedLabel2.text=0
	self.NeoCardEquipPowerupCoinYouNeedLabel.text=0
	self.chooseDict:Clear()

end

function EquipmentWinPowerupNodeCls:ConfirmPetPowerUpFunc()
	-- 时装确定按钮

	local UserDataType = require "Framework.UserDataType"
 	local tempData = self:GetCachedData(UserDataType.EquipBagData)
 	local EquipPetsLevel = require"StaticData.EquipPetsLevel"
 	local EquipPetsExp = require"StaticData.EquipPetsExp"

 	--选中宠物提供的总共经验值
	local petUpExp = 0
	--选中宠物提花费总共金币
	local petUpCoin = 0
	debug_print("ConfirmPetPowerUpFunc",self.chooseDict:Count())
	if self.chooseDict:Count()<=0 then
		self.consumeEquipUIDList=""
		self.chooseDict:Clear()
		self.NeoCardEquipPowerupCoinYouNeedLabel2.text=0
		self.NeoCardEquipPowerupCoinYouNeedLabel.text=0
	else
		self.consumeEquipUIDList=""
		for i=1,self.chooseDict:Count() do
			local petUid = self.chooseDict:GetEntryByIndex(i)
		debug_print("ConfirmPetPowerUpFunc",petUid)

			local petData=tempData:GetItem(petUid)
			print(petData:GetColor())
			local petColor = petData:GetColor()
			local data = EquipPetsExp:GetData(petColor)
			petUpExp=petUpExp+data:GetPetExp()*petData:GetLevel()
			petUpCoin=petUpCoin+data:GetPetExp()*data:GetExpXishu()*data:GetCoinXishu()*petData:GetLevel()
			
			--
			debug_print(petData:GetLevel())



			local gameTool = require "Utils.GameTools"
			local AtlasesLoader = require "Utils.AtlasesLoader"
			local PropUtility = require "Utils.PropUtility"
	 		PropUtility.AutoSetColor(self.buttonList[i].Frame,petColor)
	 		local _,_,_,iconPath,_ = gameTool.GetItemDataById(petData:GetEquipID()) 	
			utility.LoadSpriteFromPath(iconPath,self.buttonList[i].ItemIcon)
			self.buttonList[i].levelText.text="Lv"..petData:GetLevel()
			self.buttonList[i].levelText.gameObject:SetActive(true)
			self.buttonList[i].ItemIcon.enabled=true
			self.buttonList[i].PlusImage.enabled=false
			if self.consumeEquipUIDList=="" then
				self.consumeEquipUIDList=petUid
			else
			self.consumeEquipUIDList=petUid..','..self.consumeEquipUIDList

			end

		end
		self.NeoCardEquipPowerupCoinYouNeedLabel.text=petUpCoin
	--debug_print(petUpExp)
		self:CalculateUpLevel(petUpExp)
	end

	

end

function EquipmentWinPowerupNodeCls:SetButtonsDefautTheme()
	-- 设置button默认
	for i=1,#self.buttonList do
		self.buttonList[i].ItemIcon.enabled=false
		self.buttonList[i].PlusImage.enabled=true
		self.buttonList[i].levelText.gameObject:SetActive(false)
		self.buttonList[i].Frame:GetComponent(typeof(UnityEngine.UI.Image)).color=UnityEngine.Color(1,1,1,1)
	end
end
----------------------------------------------------------------------
local function CoroutinePlayingEffect(self)
	self.effectPatical:Play()
	coroutine.wait(0.6)
	self.isPlayingEffect = false
end

local function PlayingEffect(self)
	-- 播放特效
	self.isPlayingEffect = true
	-- coroutine.start(CoroutinePlayingEffect,self)
	self:StartCoroutine(CoroutinePlayingEffect)
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------        

function EquipmentWinPowerupNodeCls:OnAddButtonClicked( ... )
	-- body

	for i=1,#self.buttonList do
		self.buttonList[i].ItemIcon.enabled=false
		self.buttonList[i].PlusImage.enabled=true
		self.buttonList[i].levelText.gameObject:SetActive(false)
		self.buttonList[i].Frame:GetComponent(typeof(UnityEngine.UI.Image)).color=UnityEngine.Color(1,1,1,1)
		end

	if self.equipType==KEquipType_EquipPet then
 		local chooseNum = 4
		if (utility.GetPetMaxLevel()- self.level)<=4 then
			chooseNum=utility.GetPetMaxLevel()- self.level
		end
		-- debug_print("chooseNum",chooseNum)
		-- if chooseNum<=0 then
		-- 	self.EquipPetPowerupMax.gameObject:SetActive(true)
		-- 	self.EquipPetPowerupPanel.gameObject:SetActive(false)
		-- else
		-- 	self.EquipPetPowerupMax.gameObject:SetActive(false)
		-- 	self.EquipPetPowerupPanel.gameObject:SetActive(true)
		-- end

		local itemCls = require "GUI.ChooseItemContainer.ChooseMulItemNode"
		local data = self:GetGemDataDict()
		local windowManager = self:GetGame():GetWindowManager()
		windowManager:Show(require "GUI.ChooseItemContainer.ChooseItemContainer",self,self.ClickedPetItemCallBack,itemCls,data,self.ConfirmPetPowerUpFunc,chooseNum,self.chooseDict,self.ClosePetPowerUpFunc)
	elseif self.equipType == KEquipType_EquipFashion then
		-- 时装
		local chooseNum = #self.buttonList
		if (self.maxEquipLevel - self.level) < chooseNum then
			chooseNum = self.maxEquipLevel - self.level		
		end

		local itemCls = require "GUI.ChooseItemContainer.ChooseMulItemNode"
		local data = self:GetEquipDataDict(KEquipType_EquipFashion)
		local windowManager = self:GetGame():GetWindowManager()
		windowManager:Show(require "GUI.ChooseItemContainer.ChooseItemContainer",self,self.ClickedPetItemCallBack,itemCls,data,self.ConfirmFashiomFunc,chooseNum,self.chooseDict,self.ClosePetPowerUpFunc)
 	elseif self.equipType == KEquipType_EquipWing then
 		-- 翅膀
 		local chooseNum = #self.buttonList
 		if (self.maxEquipLevel - self.level) < chooseNum then
			chooseNum = self.maxEquipLevel - self.level		
		end

		local itemCls = require "GUI.ChooseItemContainer.ChooseMulItemNode"
		local data = self:GetEquipDataDictByColor()
		local windowManager = self:GetGame():GetWindowManager()
		windowManager:Show(require "GUI.ChooseItemContainer.ChooseItemContainer",self,self.ClickedPetItemCallBack,itemCls,data,self.ConfirmWingFunc,chooseNum,self.chooseDict,self.ClosePetPowerUpFunc)
 	end
end


function EquipmentWinPowerupNodeCls:OnbaseAsAddMateriaButtonClicked()
	--baseAsAddMateriaButton控件的点击事件处理
	self:OnAddButtonClicked()
end

function EquipmentWinPowerupNodeCls:OnbaseAsAddMateriaButton1Clicked()
	--baseAsAddMateriaButton1控件的点击事件处理
	self:OnAddButtonClicked()
end

function EquipmentWinPowerupNodeCls:OnbaseAsAddMateriaButton2Clicked()
	--baseAsAddMateriaButton2控件的点击事件处理
	self:OnAddButtonClicked()
end

function EquipmentWinPowerupNodeCls:OnbaseAsAddMateriaButton3Clicked()
	--baseAsAddMateriaButton3控件的点击事件处理
	self:OnAddButtonClicked()
end

function EquipmentWinPowerupNodeCls:OnctrlWeaponPowerupButtonClicked()
	if self.isPlayingEffect == true then
		return
	end
	-- 强化
	if self.equipType==KEquipType_EquipPet then 		
 		if self.consumeEquipUIDList ~="" then
 			hzj_print('宠物强化',self.consumeEquipUIDList)
 			self.game:SendNetworkMessage(require "Network.ServerService".PetLevelUpRequest(self.equipUID,self.consumeEquipUIDList))
		end
 	elseif self.equipType == KEquipType_EquipArmor or self.equipType == KEquipType_EquipWeapon then
 		self:OnEquipLevelUpRequest(self.equipUID)
 	elseif self.equipType == KEquipType_EquipFashion then
 		self:OnFashionLevelUpRequest(self.equipUID,self.fashionUidStr)
 	elseif self.equipType == KEquipType_EquipWing then
 		if self.WingUidStr ~= "" and self.WingUidStr ~= nil then
 			self:OnEquipBeishiLevelUpRequest(self.equipUID,self.WingUidStr)
 		end
 	end
end

function EquipmentWinPowerupNodeCls:OnctrlPetPowerupAutoButtonClicked()
	if self.equipType==KEquipType_EquipPet then
		self:GetAutoAddPetData()
	elseif self.equipType == KEquipType_EquipWing then
		self:GetAutoAddWingData()
	end
end
--获取一键添加翅膀数据集合
function EquipmentWinPowerupNodeCls:GetAutoAddWingData()
	local data = self:GetEquipDataDictByColor()

	local currentCount = self.chooseDict:Count()
	local needAddNum=4-currentCount


	-- local UserDataType = require "Framework.UserDataType"
 -- 	local tempData = self:GetCachedData(UserDataType.EquipBagData)

	-- debug_print(needAddNum,"一键添加需要的个数")
	-- for i = 1 ,self.chooseDict:Count() do
	-- 	local uid = self.chooseDict:GetEntryByIndex(i)
	-- 	local itemData = tempData:GetItem(uid)
	-- 	local itemColor = itemData:GetColor()
	-- 	debug_print(itemColor,uid,"&&&&&&&&&&")
	-- end
	for j=1, data:Count() do
		local tempUid = data:GetEntryByIndex(j):GetEquipUID()
		hzj_print(tempUid,"所有的UID")
	end
	for i=1,needAddNum do
		for j=1, data:Count() do
			local tempUid = data:GetEntryByIndex(j):GetEquipUID()
			debug_print(tempUid,"一键添加UID")

			local tempLevel = data:GetEntryByIndex(j):GetLevel()
			if not self.chooseDict:Contains(j)  then
				hzj_print(tempUid,j)
				self.chooseDict:Add(j,tempUid)
				break			
			end

		end
	end	
	-- for i = 1 ,self.chooseDict:Count() do
	-- 	local uid = self.chooseDict:GetEntryByIndex(i)
	-- 	local itemData = tempData:GetItem(uid)
	-- 	local itemColor = itemData:GetColor()
	-- 	debug_print(itemColor,uid,"&&&&End&&&&&&")
	-- end
	if self.chooseDict:Count() ==0 then
		local windowManager = utility:GetGame():GetWindowManager()
		local ConfirmDialogClass = require "GUI.Dialogs.ErrorDialog"
		windowManager:Show(ConfirmDialogClass, "剩余都是高级装备请手动添加吧阿鲁！")
	end

	self:ConfirmWingFunc()

end
--获取一键添加数据集合
function EquipmentWinPowerupNodeCls:GetAutoAddPetData()
	
	local needAddExpNum = utility.GetPetMaxLevel()-tonumber(self.NeoCardEquipPowerupCoinYouNeedLabel2.text)-self.level
	debug_print(tonumber(self.NeoCardEquipPowerupCoinYouNeedLabel2.text),needAddNum,self.level)
	--已经添加的数量
	local currentCount = self.chooseDict:Count()
	--剩余需要添加的数量
	local needAddNum=4-currentCount

	-- 达到满级需要添加的个数大于剩余需要添加的
	if needAddExpNum>= needAddNum then
	--	debug_print("一键添加需要",needAddNum,"一级宠物")

	else
		needAddNum=needAddExpNum
		--debug_print("一键添加需要",needAddExpNum,"一级宠物")
	end

	local UserDataType = require "Framework.UserDataType"
 	local tempData = self:GetCachedData(UserDataType.EquipBagData)
	-- for i = 1 ,self.chooseDict:Count() do
	-- 	local uid = self.chooseDict:GetEntryByIndex(i)
	-- 	local itemData = tempData:GetItem(uid)
	-- 	local itemColor = itemData:GetColor()
	-- 	debug_print(itemColor,uid,"&&&&&&&&&&")
	-- end
	
	local data = self:GetGemDataDict()
	for i=1,needAddNum do
		for j=1, data:Count() do
			local tempUid = data:GetEntryByIndex(j):GetEquipUID()
			local tempLevel = data:GetEntryByIndex(j):GetLevel()
			if not self.chooseDict:Contains(j) and tempLevel==1   then
				debug_print(tempUid,j)
				self.chooseDict:Add(j,tempUid)
				break			
			end

		end
	end	
	-- for i = 1 ,self.chooseDict:Count() do
	-- 	local uid = self.chooseDict:GetEntryByIndex(i)
	-- 	local itemData = tempData:GetItem(uid)
	-- 	local itemColor = itemData:GetColor()
	-- 	debug_print(itemColor,uid,"++++++++++++++")
	-- end
	if self.chooseDict:Count() ==0 then
		local windowManager = utility:GetGame():GetWindowManager()
		local ConfirmDialogClass = require "GUI.Dialogs.ErrorDialog"
		windowManager:Show(ConfirmDialogClass, "剩余都是高级装备请手动添加吧阿鲁！")
	end
	self:ConfirmPetPowerUpFunc()
end




function EquipmentWinPowerupNodeCls:OnctrlWeaponAutoPowerupButtonClicked()
	-- 自动强化
	if self.isPlayingEffect == true then
		return
	end
	self:OnEquipAutoLevelUpRequest(self.equipUID)
end
--强化返回
function EquipmentWinPowerupNodeCls:PetLevelUpResult(msg)
	PlayingEffect(self)
	print("PetLevelUpResult",msg.nowLevel)
		for i=1,#self.buttonList do
		self.buttonList[i].ItemIcon.enabled=false
		self.buttonList[i].PlusImage.enabled=true
		self.buttonList[i].levelText.gameObject:SetActive(false)
		self.buttonList[i].Frame:GetComponent(typeof(UnityEngine.UI.Image)).color=UnityEngine.Color(1,1,1,1)
	end
	self.NeoCardEquipPowerupCoinYouNeedLabel2.text=0
	self.NeoCardEquipPowerupCoinYouNeedLabel.text=0
	self.consumeEquipUIDList=""
	self.chooseDict:Clear()
	self:InitViews()
	self:DispatchEvent(messageGuids.UpdataKnapsackWindow,nil,4)


end

function EquipmentWinPowerupNodeCls:RegisterNetworkEvents()
	 
    self.game:RegisterMsgHandler(net.S2CPetLevelUpResult, self, self.PetLevelUpResult)
    self.game:RegisterMsgHandler(net.S2CEquipLevelUpResult, self, self.OnEquipLevelUpResponse)
	self.game:RegisterMsgHandler(net.S2CEquipAutoLevelUpResult, self, self.OnEquipAutoLevelUpResponse)
	self.game:RegisterMsgHandler(net.S2CFashionLevelUpResult, self, self.OnFashionLevelUpResponse)
	self.game:RegisterMsgHandler(net.S2CEquipBeishiLevelUpResult, self, self.OnEquipBeishiLevelUpResponse)
end
--取消监听网络事件
function EquipmentWinPowerupNodeCls:UnregisterNetworkEvents()
    self.game:UnRegisterMsgHandler(net.S2CPetLevelUpResult, self, self.PetLevelUpResult)
    self.game:UnRegisterMsgHandler(net.S2CEquipLevelUpResult, self, self.OnEquipLevelUpResponse)
	self.game:UnRegisterMsgHandler(net.S2CEquipAutoLevelUpResult, self, self.OnEquipAutoLevelUpResponse)
	self.game:UnRegisterMsgHandler(net.S2CFashionLevelUpResult, self, self.OnFashionLevelUpResponse)
	self.game:UnRegisterMsgHandler(net.S2CEquipBeishiLevelUpResult, self, self.OnEquipBeishiLevelUpResponse)
end


function EquipmentWinPowerupNodeCls:OnEquipLevelUpRequest(uid)
	self.game:SendNetworkMessage( require"Network/ServerService".EquipLevelUpRequest(uid))
end

function EquipmentWinPowerupNodeCls:OnEquipAutoLevelUpRequest(uid)
	self.game:SendNetworkMessage( require"Network/ServerService".EquipAutoLevelUpRequest(uid))
end

function EquipmentWinPowerupNodeCls:OnFashionLevelUpRequest(fashionUID,consumeFashionUIDList)
	self.game:SendNetworkMessage( require"Network/ServerService".OnFashionLevelUpRequest(fashionUID,consumeFashionUIDList))
end

function EquipmentWinPowerupNodeCls:OnEquipBeishiLevelUpRequest(equipUID,consumeEquipUIDList)
	self.game:SendNetworkMessage( require"Network/ServerService".OnEquipBeishiLevelUpRequest(equipUID,consumeEquipUIDList))
end

function EquipmentWinPowerupNodeCls:OnEquipLevelUpResponse(msg)
	PlayingEffect(self)
	self:InitViews()
	self:DispatchEvent(messageGuids.UpdataKnapsackWindow,nil,1,true)
end

function EquipmentWinPowerupNodeCls:OnEquipAutoLevelUpResponse(msg)
	PlayingEffect(self)
	self:InitViews()
	self:DispatchEvent(messageGuids.UpdataKnapsackWindow,nil,1,true)
end

function EquipmentWinPowerupNodeCls:OnFashionLevelUpResponse(msg)
	print(msg.state,msg.nowLevel,"????????????????????????")
	self:InitViews()
end

function EquipmentWinPowerupNodeCls:OnEquipBeishiLevelUpResponse(msg)
	self:ClosePetPowerUpFunc()
	hzj_print("翅膀升级成功哦")
	PlayingEffect(self)
	self.chooseDict:Clear()
	self.WingUidStr = ""
	self:UpdateExpAndCoin(0)
	self:SetButtonsDefautTheme()
	self:InitViews()
end


return EquipmentWinPowerupNodeCls