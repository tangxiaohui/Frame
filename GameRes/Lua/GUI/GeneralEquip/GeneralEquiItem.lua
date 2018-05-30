local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"
require "Const"

local gameTool = require "Utils.GameTools"
local PropUtility = require "Utils.PropUtility"

local GeneralEquiItemCls = Class(BaseNodeClass)

function GeneralEquiItemCls:Ctor(parent,onlyDisplay)
	self.parent = parent
	self.onlyDisplay = onlyDisplay
	self.callback = LuaDelegate.New()
	self:InitVariable()
end

function GeneralEquiItemCls:SetCallback(table, func)
    self.callback:Set(table, func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GeneralEquiItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/FullEquipItem', function(go)
		self:BindComponent(go,false)
	end)
end

function GeneralEquiItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end



function GeneralEquiItemCls:OnResume()
	-- 界面显示时调用
	GeneralEquiItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:ResetItem()
end

function GeneralEquiItemCls:OnPause()
	-- 界面隐藏时调用
	GeneralEquiItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:ClearVariable()
end

function GeneralEquiItemCls:OnEnter()
	-- Node Enter时调用
	GeneralEquiItemCls.base.OnEnter(self)
end

function GeneralEquiItemCls:OnExit()
	-- Node Exit时调用
	GeneralEquiItemCls.base.OnExit(self)
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GeneralEquiItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.transform = transform
	--self.BaseButton = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Button))
	self.baseImage = transform:Find("CardIllust/Base"):GetComponent(typeof(UnityEngine.UI.Image))
	--self.baseImage.raycastTarget = not self.onlyDisplay
	self.BackLightImage = transform:Find('BackLight'):GetComponent(typeof(UnityEngine.UI.Image))
	self.nameLabel = transform:Find('CardName'):GetComponent(typeof(UnityEngine.UI.Text))
	self.iconImage = transform:Find('CardIllust/Icon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.starFrame = transform:Find('Stars/5Star')
	self.typeImage = transform:Find('ItemType/ItemTypeIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.bindingObj = transform:Find('Binding').gameObject
	self.bindingObj:SetActive(not self.onlyDisplay)
	self.bingNameLabel = self.bindingObj.transform:Find('Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.mainAttrImage = transform:Find('Attr/Attr'):GetComponent(typeof(UnityEngine.UI.Image))
	self.mainAttrLabel = transform:Find('Attr/Num'):GetComponent(typeof(UnityEngine.UI.Text))
	self.mainAttrObj = transform:Find('Attr').gameObject
	self.descLabel = transform:Find('CardInfo/InfoBase/InfoLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 宝石
	self.gemButton1 = transform:Find('CardInfo/GemBase/Button1'):GetComponent(typeof(UnityEngine.UI.Button))
	self.gemButtonImage1 = transform:Find('CardInfo/GemBase/Button1/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.gemButtonLabel1 = transform:Find('CardInfo/GemBase/Button1/Label1'):GetComponent(typeof(UnityEngine.UI.Text))

	self.gemButton2 = transform:Find('CardInfo/GemBase/Button2'):GetComponent(typeof(UnityEngine.UI.Button))
	self.gemButtonImage2 = transform:Find('CardInfo/GemBase/Button2/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.gemButtonLabel2 = transform:Find('CardInfo/GemBase/Button2/Label2'):GetComponent(typeof(UnityEngine.UI.Text))

	self.gemeBaseObj = transform:Find('CardInfo/GemBase').gameObject
	self.infoRect = transform:Find('CardInfo/Base'):GetComponent(typeof(UnityEngine.RectTransform))  

	self.leftAttrLaebl = transform:Find('CardInfo/Base/Scroll View/Viewport/Content/Left/LeftLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.rightAttrLaebl = transform:Find('CardInfo/Base/Scroll View/Viewport/Content/Left/RightLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.attrElement = transform:Find("CardInfo/Base/Scroll View/Viewport/Content/Left"):GetComponent(typeof(UnityEngine.UI.LayoutElement))
	
	self.RarityImage =  transform:Find("Rare/Image"):GetComponent(typeof(UnityEngine.UI.Image))
	self.transform = transform
	--self.HPLabel = transform:Find("HP/Num"):GetComponent(typeof(UnityEngine.UI.Text))
	--self.ATKLabel = transform:Find("ATK/Num"):GetComponent(typeof(UnityEngine.UI.Text))
	--self.ActiveLabel = transform:Find("CardSkill/Scroll View/Viewport/Content/Active/ActiveLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	--self.PassiveLabel = transform:Find("CardSkill/Scroll View/Viewport/Content/Passive/PassiveLabel"):GetComponent(typeof(UnityEngine.UI.Text))
end

function GeneralEquiItemCls:InitVariable()
	self.id = nil
	self.icon = nil
	self.name = nil
	self.star = nil
	self.rarity = nil
	self.color = nil
	self.etype = nil
	self.bindingName = nil
	self.mainAttrID = nil
	self.mainAttrStr = nil
	self.desc = nil
	self.gemID1 = nil
	self.gemID2 = nil
	self.leftAttr = nil
	self.rightAttr = nil
	self.scale = nil
end

function GeneralEquiItemCls:RegisterControlEvents()
	-- self.__event_button_onBaseButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBaseButtonClicked, self)
	-- self.BaseButton.onClick:AddListener(self.__event_button_onBaseButtonClicked__)
end

function GeneralEquiItemCls:UnregisterControlEvents()
	-- if self.__event_button_onBaseButtonClicked__ then
	-- 	self.BaseButton.onClick:RemoveListener(self.__event_button_onBaseButtonClicked__)
	-- 	self.__event_button_onBaseButtonClicked__ = nil
	-- end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function GeneralEquiItemCls:SetAllVariable(id,icon,name,star,color,etype,bindingName,mainAttrID,mainAttrStr,desc,gemID1,gemID2,leftAttr,rightAttr,scale)
	self.id = id
	self.icon = icon
	self.name = name
	self.star = star
	self.rarity = require "StaticData.StartoSSR":GetData(star):GetRarity()
	self.color = color
	self.etype = etype
	self.bindingName = bindingName
	self.mainAttrID = nil
	self.mainAttrStr = nil
	self.desc = desc
	self.gemID1 = gemID1
	self.gemID2 = gemID2
	self.leftAttr = leftAttr
	self.rightAttr = rightAttr
	self.scale = scale
end


local function WaitLoaded(self,func)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	func(self)
end

function GeneralEquiItemCls:SetId(id)
	self.id = id
end

local function SetIconFunc(self)
	if self.icon ~= nil then
		utility.LoadSpriteFromPath(self.icon,self.iconImage)
		self.iconImage:SetNativeSize()
	end
end

function GeneralEquiItemCls:SetIcon(icon)
	if self.icon ~= nil then
		self.icon = icon
		self:StartCoroutine(WaitLoaded,SetIconFunc)
	else
		self.icon = icon	
	end	
end

local function SetNameFunc(self)
	if self.name ~= nil then
		self.nameLabel.text = self.name
	end
end

function GeneralEquiItemCls:SetName(name)
	if self.name ~= nil then
		self.name = name
		self:StartCoroutine(WaitLoaded,SetNameFunc)
	else
		self.name = name	
	end	
end

local function SetStarFunc(self)
	if self.star ~= nil then
		-- gameTool.AutoSetRoleStar(self.starFrame,self.star)
	end
end

local function SetRarityFunc(self)
	if self.rarity ~= nil then
		utility.LoadSpriteFromPath(self.rarity,self.RarityImage)
	end
end


function GeneralEquiItemCls:SetStar(star)
	if self.star ~= nil then
		self.star = star
		self:StartCoroutine(WaitLoaded,SetStarFunc)
	else
		self.star = star	
	end	
end

function GeneralEquiItemCls:SetRarity(rarity)
	if self.rarity ~= nil then
		self.rarity = rarity
		self:StartCoroutine(WaitLoaded,SetRarityFunc)
	else
		self.rarity = rarity	
	end	
end


local baseIcon = {"ItemBase","ItemBaseGreen","ItemBaseBlue","ItemBasePurple","ItemBaseRed"}
local function SetColorFunc(self)
	if self.color ~= nil then
		local color =  PropUtility.GetRGBColorValue(self.color)
		self.nameLabel.color = color
		
		utility.LoadTextureSprite(
			"CardInfo",
			baseIcon[self.color+1],
			self.baseImage
		)
		
		self.BackLightImage.color = require "Utils.GameTools".GetBackLightColor(self.color)
	end
end

function GeneralEquiItemCls:SetColor(color)
	if self.color ~= nil then
		self.color = color
		self:StartCoroutine(WaitLoaded,SetColorFunc)
	else
		self.color = color	
	end	
end

local function SetEtypeFunc(self)
	if self.etype ~= nil then
		local path = gameTool.GetEquipTagImagePath(self.etype)
		utility.LoadSpriteFromPath(path,self.typeImage)
	end	
end

function GeneralEquiItemCls:SetEtype(etype)
	if self.etype ~= nil then
		self.etype = etype
		self:StartCoroutine(WaitLoaded,SetEtypeFunc)
	else
		self.etype = etype	
	end	
end

local function SetBindingNameFunc(self)
	if self.onlyDisplay then
		return
	end
	if self.bindingName ~= nil then
		self.bindingObj:SetActive(true)
		self.bingNameLabel.text = self.bindingName
	else
		self.bindingObj:SetActive(false)
	end
end

function GeneralEquiItemCls:SetBindingName(bindingName)
	if self.bindingName ~= nil then
		self.bindingName = bindingName
		self:StartCoroutine(WaitLoaded,SetBindingNameFunc)
	else
		self.bindingName = bindingName	
	end	
end

local function GetMainAttrPath(mainId)
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

local function SetMainAttrStrFunc(self)
	self.mainAttrLabel.text = self.mainAttrStr
end

local function SetMainAttrIDFunc(self)
	-- 主属性
	local isMain = IsMainAttr(self.mainAttrID)
	self.mainAttrObj:SetActive(isMain)
	if isMain then
		local mainAttrPath = GetMainAttrPath(self.mainAttrID)
		utility.LoadSpriteFromPath(mainAttrPath,self.mainAttrImage)
		SetMainAttrStrFunc(self)
		-- if self.star ~= nil then
			-- gameTool.SetGradientColor(self.mainAttrLabel,self.star)
		-- end
		
	end
	if self.rarity ~= nil then
		utility.LoadSpriteFromPath(self.rarity,self.RarityImage)
	end
end

function GeneralEquiItemCls:SetMainAttrID(mainAttrID)
	if self.mainAttrID ~= nil then
		self.mainAttrID = mainAttrID
		self:StartCoroutine(WaitLoaded,SetMainAttrIDFunc)
	else
		self.mainAttrID = mainAttrID	
	end	
end

function GeneralEquiItemCls:SetMainAttrStr(mainAttrStr)
	if self.mainAttrStr ~= nil then
		self.mainAttrStr = mainAttrStr
		self:StartCoroutine(WaitLoaded,SetMainAttrStrFunc)
	else
		self.mainAttrStr = mainAttrStr	
	end	
end

local function SetDescFunc(self)
	if self.desc ~= nil then
		self.descLabel.text = self.desc
	end
end

function GeneralEquiItemCls:SetDesc(desc)
	if self.desc ~= nil then
		self.desc = desc
		self:StartCoroutine(WaitLoaded,SetDescFunc)
	else
		self.desc = desc	
	end	
end

local function SetGemActive(self)
	local _,data = gameTool.GetItemDataById(self.id)
	local gemNum = data:GetGemNum()
	self.gemButton1.gameObject:SetActive(gemNum>=1)
	self.gemButton2.gameObject:SetActive(gemNum>=2)

	if gemNum == 0 then
		self.gemeBaseObj:SetActive(false)
		local pos = self.infoRect.anchoredPosition
		pos.y = pos.y + 32
		self.infoRect.anchoredPosition = pos

		local sizeDelta = self.infoRect.sizeDelta
		sizeDelta.y = sizeDelta.y + 55
		self.infoRect.sizeDelta = sizeDelta
	end
end

local function SetGemData(self,id)
	local _,data,_,icon = gameTool.GetItemDataById(id)
	local dict,mainId = data:GetEquipAttribute()
	local _,_,mainStr = gameTool.GetEquipInfoStr(dict,mainId)
	return icon,mainStr
end

local function SetGemID1Func(self)
	if self.gemID1 ~= nil then
		local icon,str = SetGemData(self,self.gemID1)
		utility.LoadSpriteFromPath(icon,self.gemButtonImage1)
		self.gemButtonLabel1.text = str		
	end
end

function GeneralEquiItemCls:SetGemID1(gemID1)
	if self.gemID1 ~= nil then
		self.gemID1 = gemID1
		self:StartCoroutine(WaitLoaded,SetGemID1Func)
	else
		self.gemID1 = gemID1	
	end	
end

local function SetGemID2Func(self)
	if self.gemID2 ~= nil then
		local icon,str = SetGemData(self,self.gemID2)
		utility.LoadSpriteFromPath(icon,self.gemButtonImage2)
		self.gemButtonLabel2.text = str
	end
end

function GeneralEquiItemCls:SetGemID2(gemID2)
	if self.gemID2 ~= nil then
		self.gemID2 = gemID2
		self:StartCoroutine(WaitLoaded,SetGemID1Func)
	else
		self.gemID2 = gemID2	
	end	
end

local function SetLeftAttrFunc(self)
	if self.leftAttr ~= nil then
		self.leftAttrLaebl.text = self.leftAttr
		self.attrElement.preferredHeight = self.leftAttrLaebl.preferredHeight + 2
	end
end

function GeneralEquiItemCls:SetLeftAttr(leftAttr)
	if self.leftAttr ~= nil then
		self.leftAttr = leftAttr
		self:StartCoroutine(WaitLoaded,SetLeftAttrFunc)
	else
		self.leftAttr = leftAttr	
	end	
end

local function SetRightAttrFunc(self)
	if self.rightAttr ~= nil then
		self.rightAttrLaebl.text = self.rightAttr
	end
end

function GeneralEquiItemCls:SetRightAttr(rightAttr)
	if self.rightAttr ~= nil then
		self.rightAttr = rightAttr
		self:StartCoroutine(WaitLoaded,SetRightAttrFunc)
	else
		self.rightAttr = rightAttr	
	end	
end

local function SetScaleFunc(self)
	if self.scale ~= nil then
		self.transform.localScale = self.scale
	end
end

function GeneralEquiItemCls:SetScale(scale)
	if self.scale ~= nil then
		self.scale = scale
		self:StartCoroutine(WaitLoaded,SetScaleFunc)
	else
		self.scale = scale	
	end	
end

function GeneralEquiItemCls:SetUID(uid)
	self.uid = uid
end

function GeneralEquiItemCls:ClearVariable()
	self.id = nil
	self.icon = nil
	self.name = nil
	self.star = nil
	self.rarity = nil
	self.color = nil
	self.etype = nil
	self.bindingName = nil
	self.mainAttrID = nil
	self.mainAttrStr = nil
	self.desc = nil
	self.gemID1 = nil
	self.gemID2 = nil
	self.leftAttr = nil
	self.rightAttr = nil
	self.scale = nil
end

local function SetPanel(self)
	-- 名字
	SetNameFunc(self)
	-- icon
	SetIconFunc(self)
	-- 星级
	SetStarFunc(self)
	-- 颜色
	SetColorFunc(self)
	-- 类型
	SetEtypeFunc(self)
	-- 绑定
	SetBindingNameFunc(self)
	-- 主属性
	SetMainAttrIDFunc(self)
	-- 描述
	SetDescFunc(self)
	-- 宝石
	SetGemActive(self)
	SetGemID1Func(self)
	SetGemID2Func(self)
	-- 属性
	SetLeftAttrFunc(self)
	SetRightAttrFunc(self)
	SetScaleFunc(self)
end

local function DelayReset(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	SetPanel(self)
end

function GeneralEquiItemCls:ResetItem()
	self:StartCoroutine(DelayReset)
end

-- function GeneralEquiItemCls:OnBaseButtonClicked()
-- 	self.callback:Invoke(self.id)
-- end

return GeneralEquiItemCls