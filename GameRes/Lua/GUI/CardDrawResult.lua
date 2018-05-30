local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"

require "LUT.StringTable"
require "Collection.OrderedDictionary"
require "Collection.DataStack"
require "Const"
local CardDrawResultCls = Class(BaseNodeClass)

local DaojuPattern = "DaoJu"
local DiamondOnePattern = "DiamondOne"
local DiamondTenPattern = "DiamondTen"
local AllDaojuPattern = "AllDaoju"
local gameTool = require "Utils.GameTools"

function CardDrawResultCls:Ctor()
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CardDrawResultCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CardDrawResultEffect', function(go)
		self:BindComponent(go)
	end)
end

function CardDrawResultCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:InitVariable()
end

local function PlayGameSound(self, id)
	local audioManager = self:GetAudioManager()
	audioManager:FadeInBGM(id)
end

function CardDrawResultCls:OnResume()
	-- 界面显示时调用
	CardDrawResultCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:AddObserver()
	PlayGameSound(self,1004)
	--self:RegisterNetworkEvents()
end
function CardDrawResultCls:OnPause()
	-- 界面隐藏时调用
	CardDrawResultCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:RemoveObserver()
end

function CardDrawResultCls:OnEnter()
	-- Node Enter时调用
	CardDrawResultCls.base.OnEnter(self)
end

function CardDrawResultCls:OnExit()
	-- Node Exit时调用
	CardDrawResultCls.base.OnExit(self)
end

function CardDrawResultCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end


-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CardDrawResultCls:InitControls()
	local transform = self:GetUnityTransform()

	self.comfirmButton = transform:Find('CardDrawResult/Point/CardDrawResultBackButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.oneButton = transform:Find('CardDrawResult/Point/CardDrawResultDiamondOneButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.tenButton = transform:Find('CardDrawResult/Point/CardDrawResultDiamondTenButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.roleCardButton = transform:Find('DradCardItem/Point/FullCardItem/CardIllust/CardPortrait'):GetComponent(typeof(UnityEngine.UI.Button))
	self.equipCardButton = transform:Find('DradCardItem/Point/FullEquipItem/CardIllust/Base'):GetComponent(typeof(UnityEngine.UI.Button))
	self.confirmHintLabel = transform:Find("Hint/ConfirmHintLabel").gameObject
	self.debrisHintObj = transform:Find("Hint/DebrisHintLabel").gameObject
	self.debrisHintLabel = self.debrisHintObj:GetComponent(typeof(UnityEngine.UI.Text))
	self.passButton = transform:Find("PassButton"):GetComponent(typeof(UnityEngine.UI.Button))

	self.cardAnimator = transform:Find("DradCardItem/Point"):GetComponent(typeof(UnityEngine.Animator))

	self.resultObj = transform:Find("CardDrawResult/Point").gameObject
	self.remainText = transform:Find("CardDrawResult/Point/RemainTime"):GetComponent(typeof(UnityEngine.UI.Text))

	self.itemLayout = transform:Find("CardDrawResult/Point/Scroll View/Viewport/Content")
	self.itemLayoutRect = transform:Find("CardDrawResult/Point/Scroll View"):GetComponent(typeof(UnityEngine.RectTransform))
	self.itemScrollRect = self.itemLayoutRect.transform:GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.itemScrollMask = self.itemLayoutRect.transform:Find("Viewport"):GetComponent(typeof(UnityEngine.UI.Image))
	self.itemGridLayout = self.itemLayout:GetComponent(typeof(UnityEngine.UI.GridLayoutGroup))

	-- 碎片
	self.debrisObj = transform:Find("DebrisItem/CardItem").gameObject
	self.debrisIcon = transform:Find("DebrisItem/CardItem/Base/Icon"):GetComponent(typeof(UnityEngine.UI.Image))
	self.debrisStarFrame = transform:Find("DebrisItem/CardItem/Base/Stars")
	self.debrisRaceIcon = transform:Find("DebrisItem/CardItem/Base/RaceIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	self.debrisNameLabel = transform:Find("DebrisItem/CardItem/Base/HeroName"):GetComponent(typeof(UnityEngine.UI.Text))
	self.debrisColorImage = transform:Find("DebrisItem/CardItem/Base/Frame"):GetComponent(typeof(UnityEngine.UI.Image)) 
	self.debrisFront = transform:Find('DebrisItem/CardItem/Base/FragmentIcon').gameObject
	self.debrisBack = transform:Find('DebrisItem/CardItem/Base/Fragment').gameObject

	-- 卡牌
	self.cardFullItem = transform:Find("DradCardItem/Point/FullCardItem").gameObject
	self.roleHeadIcon = self.cardFullItem.transform:Find("CardIllust/CardPortrait"):GetComponent(typeof(UnityEngine.UI.Image))
	self.roleRaceIcon = self.cardFullItem.transform:Find("Racial/RacialIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	self.starFrame = self.cardFullItem.transform:Find("StarFrame/5Star")
	self.ActiveSkillLabel = self.cardFullItem.transform:Find("CardSkill/Scroll View/Viewport/Content/Active/ActiveLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.PassiveSkillLabel = self.cardFullItem.transform:Find("CardSkill/Scroll View/Viewport/Content/Passive/PassiveLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.ActiveSkillLabelElement = self.cardFullItem.transform:Find("CardSkill/Scroll View/Viewport/Content/Active"):GetComponent(typeof(UnityEngine.UI.LayoutElement))
	self.PassiveSkillLabelElement = self.cardFullItem.transform:Find("CardSkill/Scroll View/Viewport/Content/Passive"):GetComponent(typeof(UnityEngine.UI.LayoutElement))
	self.CHNNameLabel = self.cardFullItem.transform:Find("CardName/CardNameImageCHN"):GetComponent(typeof(UnityEngine.UI.Image))
	self.JPNameLabel = self.cardFullItem.transform:Find("CardName/CardNameImageJP"):GetComponent(typeof(UnityEngine.UI.Image))
	self.roleHpLabel = self.cardFullItem.transform:Find("HP/Num"):GetComponent(typeof(UnityEngine.UI.Text))
	self.roleATKLabel = self.cardFullItem.transform:Find("ATK/Num"):GetComponent(typeof(UnityEngine.UI.Text))
	self.cardTypeImage = self.cardFullItem.transform:Find("CardSkill/CardType"):GetComponent(typeof(UnityEngine.UI.Image))
	self.cardRarityImage = self.cardFullItem.transform:Find("Rare/Image"):GetComponent(typeof(UnityEngine.UI.Image))
	self.cardNameText = self.cardFullItem.transform:Find("Name/Text"):GetComponent(typeof(UnityEngine.UI.Text))
	
	-- 装备
	self.equipFullItem = transform:Find("DradCardItem/Point/FullEquipItem").gameObject
	self.equipIcon = self.equipFullItem.transform:Find("CardIllust/Icon"):GetComponent(typeof(UnityEngine.UI.Image))
	self.equipTypeImage = self.equipFullItem.transform:Find("ItemType/ItemTypeIcon"):GetComponent(typeof(UnityEngine.UI.Image)) 
	self.equipStarFrame = self.equipFullItem.transform:Find("Stars/5Star")
	self.equipNameLabel = self.equipFullItem.transform:Find("CardName"):GetComponent(typeof(UnityEngine.UI.Text)) 
	self.equipInfoLabel = self.equipFullItem.transform:Find("CardInfo/InfoBase/InfoLabel"):GetComponent(typeof(UnityEngine.UI.Text)) 
	self.equipSuitObj = self.equipFullItem.transform:Find("CardInfo/SuitFlag").gameObject
	self.leftAttrLabel = self.equipFullItem.transform:Find("CardInfo/Base/Scroll View/Viewport/Content/Left/LeftLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.rightAttrLabel = self.equipFullItem.transform:Find("CardInfo/Base/Scroll View/Viewport/Content/Left/RightLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.attrElement = self.equipFullItem.transform:Find("CardInfo/Base/Scroll View/Viewport/Content/Left"):GetComponent(typeof(UnityEngine.UI.LayoutElement))
	self.equipBaseImage = self.equipFullItem.transform:Find("CardIllust/Base"):GetComponent(typeof(UnityEngine.UI.Image))
	self.mainAttrImage = self.equipFullItem.transform:Find("Attr/Attr"):GetComponent(typeof(UnityEngine.UI.Image))
	self.mainAttrLabel = self.equipFullItem.transform:Find("Attr/Num"):GetComponent(typeof(UnityEngine.UI.Text))
	self.mainAttrObj = self.equipFullItem.transform:Find("Attr").gameObject
	self.equipRarityImage = self.equipFullItem.transform:Find("Rare/Image"):GetComponent(typeof(UnityEngine.UI.Image))

	self.gemBaseObj = self.equipFullItem.transform:Find("CardInfo/GemBase").gameObject
	self.gemButton1Obj = self.gemBaseObj.transform:Find("Button1").gameObject
	self.gemButton2Obj = self.gemBaseObj.transform:Find("Button2").gameObject
	self.baseInfoRect = self.equipFullItem.transform:Find("CardInfo/Base"):GetComponent(typeof(UnityEngine.RectTransform))
	self.cardInfoDefautPoint = self.baseInfoRect.anchoredPosition
	self.cardInfoNoGemPoint = Vector2(self.baseInfoRect.anchoredPosition.x,self.baseInfoRect.anchoredPosition.y+33)

	self.cardInfoDefautSize = self.baseInfoRect.sizeDelta
	self.cardInfoNoGemSize = Vector2(self.baseInfoRect.sizeDelta.x,self.baseInfoRect.sizeDelta.y+50)	

	-- 特效
	self.ckEffectObj = transform:Find("chouka_CK_Effect/Point").gameObject
	self.cardItemObj = transform:Find("DradCardItem/Point").gameObject
	self.shuaEffectObj = transform:Find("chouka_shua/Point").gameObject
	self.ckRoleEffectObj = transform:Find("chouka_CK_Effect_Renwu/Point").gameObject
	self.star4EffectObj = transform:Find("chouka_CK_sixing/Point").gameObject
	self.star5EffectObj = transform:Find("chouka_CK_wuxing/Point").gameObject
	self.color1EffectObj = transform:Find("chouka_lvka/Point").gameObject
	self.color2EffectObj = transform:Find("chouka_lanka/Point").gameObject
	self.color3EffectObj = transform:Find("chouka_zika/Point").gameObject
	self.BackLightImage = transform:Find("DradCardItem/Point/BackLight"):GetComponent(typeof(UnityEngine.UI.Image))

	-- 抽卡结果
	self.oneButtonRect = self.oneButton.transform:Find("TextImage"):GetComponent(typeof(UnityEngine.RectTransform))
	self.oneButtonImage = self.oneButton.transform:Find("DiamondIcon").gameObject
	self.onebuttonNumLabel = self.oneButton.transform:Find("CardDrawResultDiamondOneNumLabel").gameObject

	self.tenButtonRect = self.tenButton.transform:Find("Text"):GetComponent(typeof(UnityEngine.RectTransform))
	self.tenButtonImage = self.tenButton.transform:Find("DiamondIcon").gameObject
	self.tenButtonNumLabel = self.tenButton.transform:Find("CardDrawResultDiamondTenNumLabel").gameObject
end

function CardDrawResultCls:InitVariable()
	self.myGame = utility:GetGame()
	self.itemDict = OrderedDictionary.New()
	self.totalItemDict = OrderedDictionary.New()
	self.nodePool = DataStack.New()
	self.useNodeList = DataStack.New()
end

function CardDrawResultCls:RegisterControlEvents()
	-- 注册 CardDrawResultDiamondOneButton 的事件
	self.__event_button_onComfirmButtonClicked__ = UnityEngine.Events.UnityAction(self.OnComfirmButtonClicked, self)
	self.comfirmButton.onClick:AddListener(self.__event_button_onComfirmButtonClicked__)

	-- 注册 onebutton 的事件
	self.__event_button_onOneButtonClicked__ = UnityEngine.Events.UnityAction(self.onOneButtonClicked, self)
	self.oneButton.onClick:AddListener(self.__event_button_onOneButtonClicked__)

	-- 注册 tenbutton 的事件
	self.__event_button_onTenButtonClicked__ = UnityEngine.Events.UnityAction(self.onTenButtonClicked, self)
	self.tenButton.onClick:AddListener(self.__event_button_onTenButtonClicked__)

	self.__event_button_OnRoleCardClidked__ = UnityEngine.Events.UnityAction(self.OnCardClidked, self)
	self.roleCardButton.onClick:AddListener(self.__event_button_OnRoleCardClidked__)

	self.__event_button_OnEquipCardClidked__ = UnityEngine.Events.UnityAction(self.OnCardClidked, self)
	self.equipCardButton.onClick:AddListener(self.__event_button_OnEquipCardClidked__)

	self.__event_button_OnPassButtonClidked__ = UnityEngine.Events.UnityAction(self.OnPassButtonClidked, self)
	self.passButton.onClick:AddListener(self.__event_button_OnPassButtonClidked__)
end

function CardDrawResultCls:UnregisterControlEvents()
	-- 取消注册 CardDrawResultDiamondOneButton 的事件
	if self.__event_button_onComfirmButtonClicked__ then
		self.comfirmButton.onClick:RemoveListener(self.__event_button_onComfirmButtonClicked__)
		self.__event_button_onComfirmButtonClicked__ = nil
	end

	if self.__event_button_onOneButtonClicked__ then
		self.oneButton.onClick:RemoveListener(self.__event_button_onOneButtonClicked__)
		self.__event_button_onOneButtonClicked__ = nil
	end

	if self.__event_button_onTenButtonClicked__ then
		self.tenButton.onClick:RemoveListener(self.__event_button_onTenButtonClicked__)
		self.__event_button_onTenButtonClicked__ = nil
	end

	if self.__event_button_OnRoleCardClidked__ then
		self.roleCardButton.onClick:RemoveListener(self.__event_button_OnRoleCardClidked__)
		self.__event_button_OnRoleCardClidked__ = nil
	end

	if self.__event_button_OnEquipCardClidked__ then
		self.equipCardButton.onClick:RemoveListener(self.__event_button_OnEquipCardClidked__)
		self.__event_button_OnEquipCardClidked__ = nil
	end

	if self.__event_button_OnPassButtonClidked__ then
		self.passButton.onClick:RemoveListener(self.__event_button_OnPassButtonClidked__)
		self.__event_button_OnPassButtonClidked__ = nil
	end
end

function CardDrawResultCls:AddObserver()
    -- self:RegisterEvent('ResumeCoroutineState',self.ResumeCoroutineState)
    -- self:RegisterEvent('ResetXunbaolingCount',self.ResetXunbaolingCount)
end

function CardDrawResultCls:RemoveObserver()
	-- self:UnregisterEvent('ResumeCoroutineState',self.ResumeCoroutineState)
	-- self:UnregisterEvent('ResetXunbaolingCount',self.ResetXunbaolingCount)
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
local function AddItemToDict(items,dict)
	for i=1,#items do
		dict:Add(i,items[i])
	end
end

local function SetItemDict(self,ctype)
	-- 设置数量
	local count = 0
	if ctype == DaojuPattern then
		count = 1
		self.itemDict:Add(1,self.msg.item)
		self.totalItemDict:Add(1,self.msg.item)
	elseif ctype == DiamondOnePattern then
		count = 1
		self.itemDict:Add(1,self.msg.item)
		self.totalItemDict:Add(1,self.msg.item)
	elseif ctype == DiamondTenPattern then
		count = 10
		AddItemToDict(self.msg.item,self.itemDict)
		AddItemToDict(self.msg.item,self.totalItemDict)
	elseif ctype == AllDaojuPattern then
		count = #self.msg.items
		AddItemToDict(self.msg.items,self.itemDict)
		AddItemToDict(self.msg.items,self.totalItemDict)
	end	
	
	self.itemCount = count
end

local function GetItemCountFromBag(self,id)
	local UserDataType = require "Framework.UserDataType"
	local data = self:GetCachedData(UserDataType.ItemBagData)
	return data:GetItemCountById(id)
end

local function GetMainAttrImagePath(mainId)
	local fixed = "UI/Atlases/CardInfo/"
	local path
	if mainId == kPropertyID_HpLimit then
		path = "HP"
	elseif mainId == kPropertyID_Ap then
		path = "ATK"
	elseif mainId == kPropertyID_Dp then
		path = "def"
	elseif mainId == kPropertyID_Speed then
		path = "spd"
	end
	return string.format("%s%s",fixed,path)		
end

local function IsMainAttr(mainId)
	if mainId == kPropertyID_HpLimit then
		return true
	elseif mainId == kPropertyID_Ap then
		return true
	elseif mainId == kPropertyID_Dp then
		return true
	elseif mainId == kPropertyID_Speed then
		return true
	else
		return false
	end
end

local baseIcon = {"ItemBase","ItemBaseGreen","ItemBaseBlue","ItemBasePurple","ItemBaseRed"}
local function SetEquipPanel(self)
	--self.cardFullItem:SetActive(false)
	--self.equipFullItem:SetActive(true)
	utility.LoadSpriteFromPath(self.itemIcon,self.equipIcon)
	self.equipIcon:SetNativeSize()
	-- 装备类型
	local etypePath = gameTool.GetEquipTagImagePath(self.itemData:GetType())
	utility.LoadSpriteFromPath(etypePath,self.equipTypeImage)
	-- 装备星级
	-- gameTool.AutoSetRoleStar(self.equipStarFrame,self.itemStar)
	--ssr
	utility.LoadSpriteFromPath(self.rarity,self.equipRarityImage)
	-- 装备名字
	self.equipNameLabel.text = self.itemName
	self.equipNameLabel.color = require "Utils.PropUtility".GetRGBColorValue(self.itemColor)
	-- 描述
	self.equipInfoLabel.text = self.itemInfo:GetDesc()
	-- 套装
	self.equipSuitObj:SetActive(self.itemData:GetTaozhuangID() ~= 0)
	-- 属性
	local attrDict,mainId = self.itemData:GetEquipAttribute()
	local leftStr,rightStr = gameTool.GetEquipInfoStr(attrDict,mainId)
	self.rightAttrLabel.text = rightStr
	local addStr = gameTool.GetEquipPrivateInfoStr(self.currItem.itemID)
	self.leftAttrLabel.text = string.format("%s%s",leftStr,addStr)
	self.attrElement.preferredHeight = self.leftAttrLabel.preferredHeight + 10

	if IsMainAttr(mainId) then
		self.mainAttrObj:SetActive(true)
		local mainImagePath = GetMainAttrImagePath(mainId)
		utility.LoadSpriteFromPath(mainImagePath,self.mainAttrImage)
		local _,mainStr = self.itemData:GetBasisValue(mainId)		
		self.mainAttrLabel.text = mainStr
		gameTool.SetGradientColor(self.mainAttrLabel,self.itemStar)
	else
		self.mainAttrObj:SetActive(false)
	end

	-- 背景
	utility.LoadTextureSprite(
		"CardInfo",
		baseIcon[self.itemColor+1],
		self.equipBaseImage
	)


	-- 是否显示宝石
	local gemNum = self.itemData:GetGemNum()
	if gemNum == 0 then
		self.gemBaseObj:SetActive(false)
		self.baseInfoRect.anchoredPosition = self.cardInfoNoGemPoint
		self.baseInfoRect.sizeDelta = self.cardInfoNoGemSize
	else
		self.gemBaseObj:SetActive(true)
		self.baseInfoRect.anchoredPosition = self.cardInfoDefautPoint
		self.baseInfoRect.sizeDelta = self.cardInfoDefautSize
		self.gemButton2Obj:SetActive(gemNum>1)
	end

end

-- local function LocalSetRoleIcon(self,image)
	-- self.roleHeadIcon.Sprite = image
-- end

-- function CardDrawResultCls:SetRoleIcon(image)
	-- self.roleHeadIcon.sprite = image
	-- LocalSetRoleIcon(self,image)
-- end


local skillLabelStr = ">>."
local function SetRolePanel(self)
	--self.equipFullItem:SetActive(false)
	--self.cardFullItem:SetActive(true)
	-- 立绘
	local roleMgr = require "StaticData.Role"
    local roleData = roleMgr:GetData(self.currItem.itemID)
    local portraitImage = self.itemData:GetPortraitImage()

	-- 抽卡立绘
	utility.LoadIllustRolePortraitImage(self.currItem.itemID, self.roleHeadIcon)

	-- 種族
	utility.LoadRaceIcon(self.itemData:GetRace(),self.roleRaceIcon)

	-- 星級
	utility.LoadSpriteFromPath(self.rarity,self.cardRarityImage)
	-- gameTool.AutoSetRoleStar(self.starFrame,self.itemStar)
	
	-- 技能
	self.ActiveSkillLabel.text = string.format("%s%s%s%s",skillLabelStr,self.itemInfo:GetActiveSkillName(),":",self.itemInfo:GetActiveSkillDesc())
	self.PassiveSkillLabel.text = string.format("%s%s%s%s",skillLabelStr,self.itemInfo:GetPassiveSkillName(),":",self.itemInfo:GetPassiveSkillDesc())
	self.ActiveSkillLabelElement.preferredHeight = self.ActiveSkillLabel.preferredHeight + 15
	self.PassiveSkillLabelElement.preferredHeight = self.PassiveSkillLabel.preferredHeight + 15

	-- 名字
	local roleinfoData = require "StaticData.RoleInfo"
	local name = roleinfoData:GetData(self.currItem.itemID):GetCardName()
	self.cardNameText.text = name
	-- gameTool.SetRoleCardName(portraitImage,self.CHNNameLabel,self.JPNameLabel)
	-- gameTool.SetGradientColor(self.CHNNameLabel,self.itemStar)
	-- gameTool.SetGradientColor(self.JPNameLabel,self.itemStar)

	-- 类型
	local major = self.itemData:GetMajorAttr()
	local majorPath = gameTool.GetMajorAttrImagePath(major)
	utility.LoadSpriteFromPath(majorPath,self.cardTypeImage)

	-- 血量 攻擊
	local hp = self.itemData:GetBasicHp(self.itemColor,1,0)
	local atk =self.itemData:GetBasicAp(self.itemColor,1,0)
	self.roleHpLabel.text = string.format("%s",math.floor(hp))
	self.roleATKLabel.text = string.format("%s",math.floor(atk))
	gameTool.SetGradientColor(self.roleHpLabel,self.itemStar)
	gameTool.SetGradientColor(self.roleATKLabel,self.itemStar)
end

local function GetItemStar(itemType,itemData)
	local star = 0
	if itemType == "Role" or itemType == "RoleChip" then
		star = itemData:GetStar()
	elseif itemType == "Equip" or itemType == "EquipChip" then
		star = itemData:GetStarID()
	end
	return star
end

local function SetCurrItem(self)
	self.currItem = self.itemDict:GetEntryByIndex(1)
	local itemInfo,itemData,itemName,itemIcon,itemType = gameTool.GetItemDataById(self.currItem.itemID)
	self.itemInfo = itemInfo
	self.itemData = itemData
	self.itemName = itemName
	self.itemIcon = itemIcon
	self.itemType = itemType
	
	
	self.itemStar = GetItemStar(itemType,itemData)
	local rarityData = require "StaticData.StartoSSR":GetData(self.itemStar)
	self.rarity = rarityData:GetSSR()
	self.itemColor = gameTool.GetItemColorByType(itemType,itemData)

	if itemType == "Role" then
		SetRolePanel(self)
		self.getRoleCount = self.getRoleCount + 1
	elseif itemType == "Equip" then
		SetEquipPanel(self)
	end
end

local function SetObjActive(obj)
	if obj.activeSelf then
		obj:SetActive(false)
	end
	obj:SetActive(true)
end

local function SetDebrisPanel(self)
	utility.LoadRaceIcon(self.itemData:GetRace(),self.debrisRaceIcon)
	self.debrisRaceIcon.gameObject:SetActive(true)
	self.debrisFront:SetActive(true)
	self.debrisBack:SetActive(true)
end

local function SetNormalItemPanel(self)
	self.debrisRaceIcon.gameObject:SetActive(false)
	self.debrisFront:SetActive(false)
	self.debrisBack:SetActive(false)
end

local function OnPlayCardDebrisItem(self,isPass)
	-- 碎片 item
	self.canPass = false
	if not isPass then
		coroutine.wait(0.4)
	else		
		self.ckEffectObj:SetActive(false)
	end
	self.debrisObj:SetActive(true)
	if self.itemType == "RoleChip" then
		SetDebrisPanel(self)
	elseif self.itemType == "Item" then
		SetNormalItemPanel(self)
	end

	utility.LoadSpriteFromPath(self.itemIcon,self.debrisIcon)
	gameTool.AutoSetRoleStar(self.debrisStarFrame,self.itemStar)
	local propUtility = require "Utils.PropUtility"
	local color = propUtility.GetRGBColorValue(self.itemColor)
	self.debrisColorImage.color = color
	self.debrisNameLabel.text = string.format("%sx%s",self.itemInfo:GetName(),self.currItem.itemNum)
	self.debrisNameLabel.color = color

	coroutine.wait(1.5)
	self.debrisObj:SetActive(false)
	self.itemCount = self.itemCount - 1
	local key = self.itemDict:GetKeys()[1]
	self.itemDict:Remove(key)
	self:ExamineDict()
end

local function OnPlayColorEffect(self)
	if self.itemColor == 1 then
		SetObjActive(self.color1EffectObj)
		self.currColorEffect = self.color1EffectObj
	elseif self.itemColor == 2 then
		SetObjActive(self.color2EffectObj)
		self.currColorEffect = self.color2EffectObj
	elseif self.itemColor == 3 then
		SetObjActive(self.color3EffectObj)
		self.currColorEffect = self.color3EffectObj
	end	
end

local function OnPlayStarEffect(self)
	-- if self.itemStar == 5 then
		-- SetObjActive(self.star5EffectObj)
	-- else
		-- SetObjActive(self.star4EffectObj)
	-- end
end

local function OnRecycleEffect(self)
	if self.currColorEffect ~= nil then
		self.currColorEffect:SetActive(false)
	end
end

local function CheckChangeDebris(self,id,dict)
	if dict == nil or dict:Count()==0 then
		return true
	end
	local length = dict:Count()
	for i = 1 ,length do
		local addId = dict:GetEntryByIndex(i)
		if addId == id then
			dict:Remove(addId)
			return false
		end
	end
	return true
end

local function DelayCanClicked(self,isRole)
	coroutine.wait(1)
	if isRole then
		local change = CheckChangeDebris(self,self.currItem.itemID,self.AddCardDict)
		if change then
			self.debrisHintObj:SetActive(true)
			local num = self.itemData:GetDecomposeNum()
			self.debrisHintLabel.text = string.format("已有卡牌已经自动转化成%s个碎片",num)
		else
			self.confirmHintLabel:SetActive(true)
		end
	else
		self.confirmHintLabel:SetActive(true)
	end
	self.cardButtonCanClicked = true
end

local colorTable = {defautColor,greenColor,blueColor,purpleColor,orangeColor}

local function OnPlayCardItem(self,isPass)
	self.canPass = false
	if isPass then
		self.ckEffectObj:SetActive(false)		
	end

	local isRole
	if self.itemType == "Role" then
		coroutine.wait(0.1)		
		SetObjActive(self.ckRoleEffectObj)
		self.cardAnimator:SetTrigger ("StartRole")
		-- 播放刷特效
		coroutine.wait(4.5)
		SetObjActive(self.shuaEffectObj)
		isRole = true
	elseif self.itemType == "Equip" then
		self.cardAnimator:SetTrigger ("StartEquip")
	end
		
	self.BackLightImage.color = require "Utils.GameTools".GetBackLightColor(self.itemColor)

	coroutine.wait(2)
	-- 播放星级特效
	OnPlayStarEffect(self)
	-- 播放颜色特效
	OnPlayColorEffect(self)
	self:StartCoroutine(DelayCanClicked,isRole)
end

local function OnPlayCardItemEnd(self)
	OnRecycleEffect(self)
	coroutine.wait(0.5)
	-- 一次抽卡結束
	self.itemCount = self.itemCount - 1
	local key = self.itemDict:GetKeys()[1]
	self.itemDict:Remove(key)
	self:ExamineDict()
end

local function IsNewCard(self,id)
	for i = 1 ,#self.addCardList do
		local addId = self.addCardList[i]
		if addId == id then
			self.addCardList[i] = nil
			return true
		end
	end
	return false
end

local function SetItemNodeVariable(self,node,nodeInfo)
	local itemInfo,itemData,itemName,itemIcon,itemType = gameTool.GetItemDataById(nodeInfo.itemID)
	local color = gameTool.GetItemColorByType(itemType,itemData)
	local star = GetItemStar(itemType,itemData)
	self.itemInfo = itemInfo
	self.itemData = itemData
	self.itemName = itemName
	self.itemIcon = itemIcon
	self.itemType = itemType
	self.itemStar = star
	if star ~= 0 then
	local rarityData = require "StaticData.StartoSSR":GetData(star)
	self.rarity = rarityData:GetSSR()
	end

	self.itemColor = color
	self.currItem = nodeInfo


	if itemType == "Role" then
		node:SetPattern(1)
		node:SetName(itemName)
		node:SetRace(itemData:GetRace())
		local isNew = IsNewCard(self,nodeInfo.itemID)
		node:SetIsNew(isNew)
		node:SetNeedEffect(true)
		SetRolePanel(self)
	elseif itemType == "RoleChip" then
		node:SetPattern(3)
		node:SetName(string.format("%sx%s",itemName,nodeInfo.itemNum))
		node:SetRace(itemData:GetRace())
	elseif itemType == "Equip" then
		node:SetPattern(2)
		node:SetName(string.format("%sx%s",itemName,nodeInfo.itemNum))
		node:SetNeedEffect(true)
		SetEquipPanel(self)
	else
		node:SetPattern(2)
		node:SetName(string.format("%sx%s",itemName,nodeInfo.itemNum))
	end
	node:SetStar(star)
	node:SetColor(color)
	node:SetId(nodeInfo.itemID)
	node:SetIcon(itemIcon)

	return itemType
end

local function GetNodeFromPool(self)
	local itemCls = require "GUI.CardDrawItem"
	local node = self.nodePool:Pop()
	if node == nil then
		node = itemCls.New(self.itemLayout)
	end
	return node
end

local function DestroyObj(obj)
	coroutine.step(1)
	UnityEngine.Object.Destroy(go)
end

local function SortLayerOrder(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	-- local moduleLayer =  self:GetUIManager():GetModuleLayer()
	-- utility.LoadNewGameObjectAsync('UI/Prefabs/EnemyGameObject', function(go)
	-- 	go.transform:SetParent(moduleLayer)
	-- 	self:StartCoroutine(DestroyObj,go)
	-- end)

end

local function StopGameSound(self)
	_G.PlayGameME(0)
end

local function PlayGameSoundEffect(self, id)
	_G.PlayGameME(id)
end

local function GetSoundEffect(itype)
	local id
	if itype == "Role" then
		id = 10
	elseif itype == "Equip" then
		id = 11
	else
		id = 12
	end
	return id
end

local function SelectPlayPattern(self,isPass)
	self:StartCoroutine(OnPlayCardItem,isPass)		
	--if self.itemType == "Role" or self.itemType == "Equip" then
	--	self:StartCoroutine(OnPlayCardItem,isPass)		
	--else
		--self:StartCoroutine(OnPlayCardDebrisItem,isPass)
	--end
end

local function OnPlayCKEffect(self)
	--SetObjActive(self.ckEffectObj)
	--self.canPass = true
	--local soundId = GetSoundEffect(self.itemType)
	--PlayGameSoundEffect(self,soundId)
	--coroutine.wait(3.1)
	SelectPlayPattern(self)
end

local function OnShowItems(self)
	-- 显示Items
	self.resultObj:SetActive(true)


	local keys = self.totalItemDict:GetKeys()
	if #keys <= 5 then
		self.itemLayoutRect.anchoredPosition = Vector2(0,-133)
		self.itemGridLayout.childAlignment = UnityEngine.TextAnchor.MiddleCenter
	else
		self.itemLayoutRect.anchoredPosition = Vector2(0,0)
		self.itemGridLayout.childAlignment = UnityEngine.TextAnchor.UpperLeft
	end

	self.itemScrollRect.vertical = (#keys > 10)
	self.itemScrollMask.enabled = (#keys > 10)

    for i =1 ,#keys do
    	node = GetNodeFromPool(self)
    	node:SetCallback(self,self.OnItemClicked)
    	node:SetId(i)
    	local itemType = SetItemNodeVariable(self,node,self.totalItemDict:GetEntryByIndex(i))
    	if itemType == "Role" or itemType == "Equip" then
    		self.resultObj:SetActive(false)
    		self:StartCoroutine(OnPlayCKEffect)
    		coroutine.yield()
    	end
    	
    	self:AddChild(node)
    	self.useNodeList:Push(node)
    	coroutine.wait(0.5)
    end
    self.showItemCoroutine = nil
    self.nextStepButtonCanCliecked = true
    self.comfirmButton.gameObject:SetActive(true)
    self.oneButton.gameObject:SetActive(true)
    self.tenButton.gameObject:SetActive(true)
    self.remainText.gameObject:SetActive(true)
end

function CardDrawResultCls:ExamineDict()
	if self.itemCount > 0 then
		self.showItemCoroutine = self:StartCoroutine(OnShowItems)
	end
end

local function SetHintPanel(self)
		debug_print("ooooooooooooooooooooooooooooooooooooooooooooo")
	if self.cardTypePattern == DaojuPattern or self.cardTypePattern == AllDaojuPattern then

		self.oneButtonImage:SetActive(false)
		self.onebuttonNumLabel:SetActive(false)
		self.tenButtonImage:SetActive(false)
		self.tenButtonNumLabel:SetActive(false)
		self.oneButtonRect.anchoredPosition = Vector2(0,-2.5)
		self.tenButtonRect.anchoredPosition = Vector2(0,-2.5)

		local UserDataType = require "Framework.UserDataType"
		local data = self:GetCachedData(UserDataType.ItemBagData)
		local count= data:GetItemCountById(10300003)
		self.remainText.text=string.format(CardDrawStringTable[9],count)
	elseif self.cardTypePattern == DiamondOnePattern or self.cardTypePattern == DiamondTenPattern then
		self.oneButtonImage:SetActive(true)
		self.onebuttonNumLabel:SetActive(true)
		self.tenButtonImage:SetActive(true)
		self.tenButtonNumLabel:SetActive(true)
		self.oneButtonRect.anchoredPosition = Vector2(57.7,-2.5)
		self.tenButtonRect.anchoredPosition = Vector2(57.7,-2.5)

		local UserDataType = require "Framework.UserDataType"
	    local userData = self:GetCachedData(UserDataType.PlayerData)
	    local diamond = userData:GetDiamond()
		self.remainText.text=string.format(CardDrawStringTable[10],diamond)--"当前剩余钻石"..diamond
	end
end

local function DelayOnShowItem(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	self.resultObj:SetActive(false)
	self.debrisHintObj:SetActive(false)
	self.itemDict:Clear()
	self.totalItemDict:Clear()
	SetItemDict(self,self.cardTypePattern)
	self:ExamineDict()
	SetHintPanel(self)
	self.remainText.gameObject:SetActive(false)
	self.comfirmButton.gameObject:SetActive(false)
	self.oneButton.gameObject:SetActive(false)
	self.tenButton.gameObject:SetActive(false)


end

local function SetNewCardlist(self,dict)
	local keys = dict:GetKeys()
	local result = {}
	for i = 1,#keys do
		result[#result + 1] = keys[i]
	end
	return result
end

function CardDrawResultCls:OnShowItem(msg,count,cardType,xunbaolingCount,remainCount,AddCardDict,flag)
	self.msg = msg
	self.count = count
	self.cardTypePattern = cardType
	self.xunbaolingCount = xunbaolingCount
	self.remainCount = remainCount
	self.AddCardDict = AddCardDict
	self.addCardCount = AddCardDict:Count()
	self.addCardList = SetNewCardlist(self,AddCardDict)
	self.flag=flag
	self.getRoleCount = 0
	self.nextStepButtonCanCliecked = false
	self:StartCoroutine(DelayOnShowItem)
end
--------------------------------------------------------------------------
local function Guide(self)
	-- 新手引导
    local guideMgr = utility.GetGame():GetGuideManager()
	guideMgr:AddGuideEvnt(kGuideEvnt_DiamondDrawTips)
	guideMgr:AddGuideEvnt(kGuideEvnt_DiamondDraw)
	if self.cardTypePattern == DiamondOnePattern then
		guideMgr:AddGuideEvnt(kGuideEvnt_Draw2MainPanel)
	end
	guideMgr:SortGuideEvnt()
	guideMgr:ShowGuidance()
end

local function DisError(self,str)
	local windowManager = utility:GetGame():GetWindowManager()
  	windowManager:Show(require "GUI.Dialogs.ErrorDialog",str)
end

function CardDrawResultCls:OnComfirmButtonClicked()
	if not self.nextStepButtonCanCliecked then
		return
	end
	self.nextStepButtonCanCliecked = false

	-- 隐藏公告
	local eventMgr = self.myGame:GetEventManager()
    eventMgr:PostNotification('ShowPlayNotice')
    eventMgr:PostNotification('ShowCardDraw')
	-- 隐藏货币
	local messageGuids = require "Framework.Business.MessageGuids"
    self:DispatchEvent(messageGuids.EnterLobbyScene)
    Guide(self)

    local sceneManager = self.myGame:GetSceneManager()
    sceneManager:PopScene()
end

local function CheckIsHideItem(self,limit)
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    local diamond = userData:GetDiamond()
    local result = false
    if diamond >= tonumber(limit) then
    	result = true
    end
    return result
end

local function OnRecycleResultItem(self)
	local count = self.useNodeList:Count()
	for i = 1 ,count do
		local node = self.useNodeList:Pop()
		self.nodePool:Push(node)
		self:RemoveChild(node)
	end
	self.useNodeList:Clear()
end

local xunbaolingID = 10300003
function CardDrawResultCls:onOneButtonClicked()
	if not self.nextStepButtonCanCliecked then
		return
	end
		self.remainText.gameObject:SetActive(false)
	if self.cardTypePattern == DaojuPattern or self.cardTypePattern == AllDaojuPattern then
		if GetItemCountFromBag(self,xunbaolingID) > 0 then
			OnRecycleResultItem(self)
			self.myGame:SendNetworkMessage( require"Network/ServerService".ChoukaDaojuChooseRequest())
			self.nextStepButtonCanCliecked = false
		else
			DisError(self,"寻宝器数量不足")
		end
	elseif self.cardTypePattern == DiamondOnePattern or self.cardTypePattern == DiamondTenPattern then
		debug_print("Flag",self.flag)

		if CheckIsHideItem(self,CardDrawStringTable[6]) then
			OnRecycleResultItem(self)
			if self.flag== true then
			self.myGame:SendNetworkMessage( require"Network/ServerService".GodChooseOneRequet())

			else
			self.myGame:SendNetworkMessage( require"Network/ServerService".ChoukaDiamondChooseRequest())

			end
			self.nextStepButtonCanCliecked = false
		else
			DisError(self,"钻石数量不足")
		end
	end
end

function CardDrawResultCls:onTenButtonClicked()
	if not self.nextStepButtonCanCliecked then
		return
	end
	self.remainText.gameObject:SetActive(false)
	if self.cardTypePattern == DaojuPattern or self.cardTypePattern == AllDaojuPattern then
		if GetItemCountFromBag(self,xunbaolingID) > 0 then
			OnRecycleResultItem(self)
			self.myGame:SendNetworkMessage( require"Network/ServerService".UseAllTreasureRequest())
			self.nextStepButtonCanCliecked = false
		else
			DisError(self,"寻宝器数量不足")
		end
	elseif self.cardTypePattern == DiamondOnePattern or self.cardTypePattern == DiamondTenPattern then
		if CheckIsHideItem(self,CardDrawStringTable[7]) then 
			debug_print("Flag",self.flag)
			OnRecycleResultItem(self)
			if self.flag== true then
				self.myGame:SendNetworkMessage( require"Network/ServerService".GodChooseTenRequest())

			else
				self.myGame:SendNetworkMessage( require"Network/ServerService".ChoukaDiamondChooseTenRequest())
			end

			self.nextStepButtonCanCliecked = false
		else
			DisError(self,"钻石数量不足")
		end
	end
end

function CardDrawResultCls:OnItemClicked(id)
end

function CardDrawResultCls:OnCardClidked()
	-- if self.cardButtonCanClicked then
	-- 	self.cardButtonCanClicked = false
	-- 	self.confirmHintLabel:SetActive(false)
	-- 	self.debrisHintObj:SetActive(false)
	-- 	self:StartCoroutine(OnPlayCardItemEnd)
	-- 	self.cardAnimator:SetTrigger ("OnClick")
	-- end
end

local function DelayResumeShow(self)
	coroutine.wait(0.25)
	self.resultObj:SetActive(true)
	self.debrisHintLabel.text = ""
	self.confirmHintLabel:SetActive(false)
	self.debrisHintLabel.gameObject:SetActive(false)
	
	coroutine.resume(self.showItemCoroutine)
end

function CardDrawResultCls:OnPassButtonClidked()
	if not self.cardButtonCanClicked then
		return
	end
	self.cardButtonCanClicked = false
	if self.showItemCoroutine ~= nil then
		if coroutine.status(self.showItemCoroutine) == "dead" then
			return
		end
		self.cardAnimator:SetTrigger ("OnClick")
		OnRecycleEffect(self)
		self:StartCoroutine(DelayResumeShow)
	end

end

return CardDrawResultCls