local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ZodiacCls = Class(BaseNodeClass)

function ZodiacCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ZodiacCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Zodiac', function(go)
		self:BindComponent(go)
	end)
end

function ZodiacCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

local function RecalculateAttributes(activedSpots)
	local attr = {}
	for i = 1, 15 do
		attr[i] = 0
	end
	
	if (activedSpots == nil) then
		return attr
	end
	
	local zodiacStateMgr = require "StaticData.Zodiac.ZodiacState"
	for i = 1, #activedSpots do
		local spot = zodiacStateMgr:GetData(activedSpots[i])
		local types = spot:GetPoweType()
		local values = spot:GetPowerNum()
		for j = 1, types.Count do
			local index = types:get_Item(j - 1)
			local value = values:get_Item(j - 1)
			attr[index] = attr[index] + value
		end
	end
	return attr
end

local function UpdateAttributes(self)
	local attr = RecalculateAttributes(self.activedSpots)
	local nextId = 1
	for i = 1, 15 do
		if i < 7 then
			self.attr[i].base.gameObject:SetActive(false)
		end
		
		if (attr[i] > 0) and (nextId < 7) then
			self.attr[nextId].name.text = EquipStringTable[i]
			self.attr[nextId].value.text = attr[i]
			self.attr[nextId].base.gameObject:SetActive(true)
			nextId = nextId + 1
		end
	end
end

local function DelayStartSystemGuide(self,data)
	while (not data:IsReady()) do
		coroutine.step(1)
	end
	hzj_print("*****",	data.star[1].spot[0].preparedBtn)
	--星宫系统引导

	utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[6].systemGuideID,self)


end
function ZodiacCls:OnResume()
	-- 界面显示时调用
	debug_print("*****************", "OnResume")
	ZodiacCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:UpdateActivedSpots()
--	utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[6].systemGuideID,self)
	self:StartCoroutine(DelayStartSystemGuide,self.itemStar)
end

function ZodiacCls:OnPause()
	-- 界面隐藏时调用
	ZodiacCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function ZodiacCls:OnWillShow(zodiac, activedSpots, lv, cardId)
	self.zodiac = zodiac
	self.activedSpots = activedSpots
	self.lv = lv
	self.cardId = cardId
	-- debug_print("***************** OnWillShow ", self.activedSpots)
	-- for k, v in pairs(self.activedSpots) do
	-- 	debug_print("***************** OnWillShow### ", v)
	-- end
end

function ZodiacCls:OnEnter()
	-- Node Enter时调用
	ZodiacCls.base.OnEnter(self)
end

function ZodiacCls:OnExit()
	-- Node Exit时调用
	ZodiacCls.base.OnExit(self)
end


local function InitViews(self)
	UpdateAttributes(self)
	
	local item = require "GUI.Zodiac.Star".New(self)
	self.itemStar=item
	self:AddChild(item)
	
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ZodiacCls:InitControls()
	local transform = self:GetUnityTransform()
	
	self.zodiacPoint = transform:Find("ZodiacPoint")
	
	self.attr = {}
	self.attr[1] = {}
	self.attr[1].base = transform:Find("Status/Layout/ZodiacStatusItem")
	self.attr[1].name = transform:Find("Status/Layout/ZodiacStatusItem/StatusLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.attr[1].value = transform:Find("Status/Layout/ZodiacStatusItem/Frame/NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.attr[2] = {}
	self.attr[2].base = transform:Find("Status/Layout/ZodiacStatusItem (1)")
	self.attr[2].name = transform:Find("Status/Layout/ZodiacStatusItem (1)/StatusLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.attr[2].value = transform:Find("Status/Layout/ZodiacStatusItem (1)/Frame/NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.attr[3] = {}
	self.attr[3].base = transform:Find("Status/Layout/ZodiacStatusItem (2)")
	self.attr[3].name = transform:Find("Status/Layout/ZodiacStatusItem (2)/StatusLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.attr[3].value = transform:Find("Status/Layout/ZodiacStatusItem (2)/Frame/NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.attr[4] = {}
	self.attr[4].base = transform:Find("Status/Layout/ZodiacStatusItem (3)")
	self.attr[4].name = transform:Find("Status/Layout/ZodiacStatusItem (3)/StatusLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.attr[4].value = transform:Find("Status/Layout/ZodiacStatusItem (3)/Frame/NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.attr[5] = {}
	self.attr[5].base = transform:Find("Status/Layout/ZodiacStatusItem (4)")
	self.attr[5].name = transform:Find("Status/Layout/ZodiacStatusItem (4)/StatusLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.attr[5].value = transform:Find("Status/Layout/ZodiacStatusItem (4)/Frame/NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.attr[6] = {}
	self.attr[6].base = transform:Find("Status/Layout/ZodiacStatusItem (5)")
	self.attr[6].name = transform:Find("Status/Layout/ZodiacStatusItem (5)/StatusLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.attr[6].value = transform:Find("Status/Layout/ZodiacStatusItem (5)/Frame/NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	
	self.selectedSpotAttr1 = transform:Find("ActiveBase/AddStatus/StatusItem1")
	self.selectedSpotAttr1Type = transform:Find("ActiveBase/AddStatus/StatusItem1/StatusLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.selectedSpotAttr1Value = transform:Find("ActiveBase/AddStatus/StatusItem1/Frame/NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.selectedSpotAttr2 = transform:Find("ActiveBase/AddStatus/StatusItem2")
	self.selectedSpotAttr2Type = transform:Find("ActiveBase/AddStatus/StatusItem2/StatusLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.selectedSpotAttr2Value = transform:Find("ActiveBase/AddStatus/StatusItem2/Frame/NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	
	self.selectedSpotCostName = transform:Find("ActiveBase/Material/ItemName"):GetComponent(typeof(UnityEngine.UI.Text))
	self.selectedSpotCostIcon = transform:Find("ActiveBase/Material/MyGeneralItem/ItemIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	self.selectedSpotCostProgressbar = transform:Find("ActiveBase/Material/Progress/Base/Fill"):GetComponent(typeof(UnityEngine.UI.Image))
	self.selectedSpotCostProgressbarLabel = transform:Find("ActiveBase/Material/Progress/NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	
	self.Base = transform:Find('Base/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.UpDeco = transform:Find('Base/UpDeco'):GetComponent(typeof(UnityEngine.UI.Image))
	self.DownDeco = transform:Find('Base/DownDeco'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Base1 = transform:Find('Status/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Base2 = transform:Find('Status/Title/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Text = transform:Find('Status/Title/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.StatusLabel = transform:Find('Status/Layout/ZodiacStatusItem/StatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Frame = transform:Find('Status/Layout/ZodiacStatusItem/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NumLabel = transform:Find('Status/Layout/ZodiacStatusItem/Frame/NumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.StatusLabel1 = transform:Find('Status/Layout/ZodiacStatusItem (1)/StatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Frame1 = transform:Find('Status/Layout/ZodiacStatusItem (1)/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NumLabel1 = transform:Find('Status/Layout/ZodiacStatusItem (1)/Frame/NumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.StatusLabel2 = transform:Find('Status/Layout/ZodiacStatusItem (2)/StatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Frame2 = transform:Find('Status/Layout/ZodiacStatusItem (2)/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NumLabel2 = transform:Find('Status/Layout/ZodiacStatusItem (2)/Frame/NumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.StatusLabel3 = transform:Find('Status/Layout/ZodiacStatusItem (3)/StatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Frame3 = transform:Find('Status/Layout/ZodiacStatusItem (3)/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NumLabel3 = transform:Find('Status/Layout/ZodiacStatusItem (3)/Frame/NumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.StatusLabel4 = transform:Find('Status/Layout/ZodiacStatusItem (4)/StatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Frame4 = transform:Find('Status/Layout/ZodiacStatusItem (4)/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NumLabel4 = transform:Find('Status/Layout/ZodiacStatusItem (4)/Frame/NumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.StatusLabel5 = transform:Find('Status/Layout/ZodiacStatusItem (5)/StatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Frame5 = transform:Find('Status/Layout/ZodiacStatusItem (5)/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NumLabel5 = transform:Find('Status/Layout/ZodiacStatusItem (5)/Frame/NumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Base3 = transform:Find('ActiveBase/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.StatusLabel6 = transform:Find('ActiveBase/AddStatus/StatusItem1/StatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Frame6 = transform:Find('ActiveBase/AddStatus/StatusItem1/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NumLabel6 = transform:Find('ActiveBase/AddStatus/StatusItem1/Frame/NumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.StatusLabel7 = transform:Find('ActiveBase/AddStatus/StatusItem2/StatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Frame7 = transform:Find('ActiveBase/AddStatus/StatusItem2/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NumLabel7 = transform:Find('ActiveBase/AddStatus/StatusItem2/Frame/NumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Base4 = transform:Find('ActiveBase/Material/MyGeneralItem/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BaseBg = transform:Find('ActiveBase/Material/MyGeneralItem/BaseBg'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ItemIcon = transform:Find('ActiveBase/Material/MyGeneralItem/ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.DebrisIcon = transform:Find('ActiveBase/Material/MyGeneralItem/DebrisIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Image = transform:Find('ActiveBase/Material/MyGeneralItem/Frame/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.DebrisCorner = transform:Find('ActiveBase/Material/MyGeneralItem/DebrisCorner'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ItemNameLabel = transform:Find('ActiveBase/Material/MyGeneralItem/ItemNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ItemSellInfoIcon = transform:Find('ActiveBase/Material/MyGeneralItem/ItemSellInfo/ItemSellInfoIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ItemSellInfoText = transform:Find('ActiveBase/Material/MyGeneralItem/ItemSellInfo/ItemSellInfoText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OnSelectBase = transform:Find('ActiveBase/Material/MyGeneralItem/OnSelectState/OnSelectBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.OnSelectState = transform:Find('ActiveBase/Material/MyGeneralItem/OnSelectState/OnSelectState'):GetComponent(typeof(UnityEngine.UI.Image))
	self.GeneralItemNumLabel = transform:Find('ActiveBase/Material/MyGeneralItem/GeneralItemNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ItemLevelLabel = transform:Find('ActiveBase/Material/MyGeneralItem/ItemLevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Flag = transform:Find('ActiveBase/Material/MyGeneralItem/Flag'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Text1 = transform:Find('ActiveBase/Material/MyGeneralItem/Flag/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Image1 = transform:Find('ActiveBase/Material/MyGeneralItem/OnMultiSelect/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Coner1 = transform:Find('ActiveBase/Material/MyGeneralItem/OnMultiSelect/Coner1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Coner2 = transform:Find('ActiveBase/Material/MyGeneralItem/OnMultiSelect/Coner2'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Coner3 = transform:Find('ActiveBase/Material/MyGeneralItem/OnMultiSelect/Coner3'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Coner4 = transform:Find('ActiveBase/Material/MyGeneralItem/OnMultiSelect/Coner4'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ItemAttributeLabel = transform:Find('ActiveBase/Material/MyGeneralItem/ItemAttributeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BindImage = transform:Find('ActiveBase/Material/MyGeneralItem/BindImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ItemInfoButton = transform:Find('ActiveBase/Material/MyGeneralItem/ItemInfoButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Bottom = transform:Find('ActiveBase/Material/MyGeneralItem/Gems/ButtonBox/Gem1/Bottom'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Image2 = transform:Find('ActiveBase/Material/MyGeneralItem/Gems/ButtonBox/Gem1/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Bottom1 = transform:Find('ActiveBase/Material/MyGeneralItem/Gems/ButtonBox/Gem2/Bottom'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Image3 = transform:Find('ActiveBase/Material/MyGeneralItem/Gems/ButtonBox/Gem2/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.RaceIconImage = transform:Find('ActiveBase/Material/MyGeneralItem/RaceIconImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ItemName = transform:Find('ActiveBase/Material/ItemName'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Base5 = transform:Find('ActiveBase/Material/Progress/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Fill = transform:Find('ActiveBase/Material/Progress/Base/Fill'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NumLabel8 = transform:Find('ActiveBase/Material/Progress/NumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ActiveButton = transform:Find('ActiveBase/ActiveButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Title = transform:Find('Title'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ReturnButton = transform:Find('ReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	
	InitViews(self)
end

function ZodiacCls:RegisterControlEvents()
	-- 注册 ItemInfoButton 的事件
	self.__event_button_onItemInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnItemInfoButtonClicked, self)
	self.ItemInfoButton.onClick:AddListener(self.__event_button_onItemInfoButtonClicked__)

	-- 注册 ActiveButton 的事件
	self.__event_button_onActiveButtonClicked__ = UnityEngine.Events.UnityAction(self.OnActiveButtonClicked, self)
	self.ActiveButton.onClick:AddListener(self.__event_button_onActiveButtonClicked__)

	-- 注册 ReturnButton 的事件
	self.__event_button_onReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked, self)
	self.ReturnButton.onClick:AddListener(self.__event_button_onReturnButtonClicked__)
end

function ZodiacCls:UnregisterControlEvents()
	-- 取消注册 ItemInfoButton 的事件
	if self.__event_button_onItemInfoButtonClicked__ then
		self.ItemInfoButton.onClick:RemoveListener(self.__event_button_onItemInfoButtonClicked__)
		self.__event_button_onItemInfoButtonClicked__ = nil
	end

	-- 取消注册 ActiveButton 的事件
	if self.__event_button_onActiveButtonClicked__ then
		self.ActiveButton.onClick:RemoveListener(self.__event_button_onActiveButtonClicked__)
		self.__event_button_onActiveButtonClicked__ = nil
	end

	-- 取消注册 ReturnButton 的事件
	if self.__event_button_onReturnButtonClicked__ then
		self.ReturnButton.onClick:RemoveListener(self.__event_button_onReturnButtonClicked__)
		self.__event_button_onReturnButtonClicked__ = nil
	end
end

function ZodiacCls:RegisterNetworkEvents()
end

function ZodiacCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ZodiacCls:OnItemInfoButtonClicked()
	--ItemInfoButton控件的点击事件处理
end

function ZodiacCls:OnActiveButtonClicked()
	utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[6].systemGuideID,self)
	
	--ActiveButton控件的点击事件处理
	-- debug_print("*****************", "OnActiveButtonClicked")
	self:GetGame():SendNetworkMessage(require"Network/ServerService".CardTheSmallUniverseRequest(self.cardId, self.selectedSpotId))
end

function ZodiacCls:OnReturnButtonClicked()
	--ReturnButton控件的点击事件处理
	self:Close()
end

function ZodiacCls:GetZodiacPoint()
	return self.zodiacPoint
end

function ZodiacCls:GetZodiacData()
	return self.zodiac
end

function ZodiacCls:GetActivedSpots()
	return self.activedSpots
end

function ZodiacCls:UpdateActivedSpots()
	local cardsData = self:GetCachedData(require "Framework.UserDataType".CardBagData)
	local cardData = cardsData:GetRoleByUid(self.cardId)
	self.activedSpots = cardData:GetActivedZodiacSpot()
	UpdateAttributes(self)
end

function ZodiacCls:GetLv()
	return self.lv
end

-- spot is kinda ZodiacStateData
function ZodiacCls:SelectSpot(spotId, spot, enable)
	self.selectedSpotId = spotId
	self.ActiveButton.interactable = enable
	
	if spot == nil then
		self.selectedSpotAttr1.gameObject:SetActive(false)
		self.selectedSpotAttr2.gameObject:SetActive(false)
		return
	end
	
	local types = spot:GetPoweType()
	local values = spot:GetPowerNum()
	self.selectedSpotAttr1Type.text = EquipStringTable[types:get_Item(0)]
	self.selectedSpotAttr1Value.text = values:get_Item(0)
	self.selectedSpotAttr1.gameObject:SetActive(true)
	if types.Count == 1 then
		self.selectedSpotAttr2.gameObject:SetActive(false)
	else
		self.selectedSpotAttr2Type.text = EquipStringTable[types:get_Item(1)]
		self.selectedSpotAttr2Value.text = values:get_Item(1)
		self.selectedSpotAttr2.gameObject:SetActive(true)
	end
	
	local bagData = self:GetCachedData(require "Framework.UserDataType".ItemBagData)
	local pointType = spot:GetPointType()
	local cur, need, name, icon
	local gameTool = require "Utils.GameTools"
	if pointType == 1 then -- 星石
		cur = bagData:GetItemCountById(spot:GetStoneType())
		need = spot:GetStoneNum()
		local _info, _data, _name, _icon, _path, _type = gameTool.GetItemDataById(spot:GetStoneType())
		name = _name
		icon = _icon
	else -- 星魂
		cur = bagData:GetItemCountById(spot:GetSoulType())
		need = spot:GetSoulNum()
		local _info, _data, _name, _icon, _path, _type = gameTool.GetItemDataById(spot:GetSoulType())
		name = _name
		icon = _icon
	end
	self.selectedSpotCostProgressbar.fillAmount = cur/need
	self.selectedSpotCostProgressbarLabel.text = ""..cur.."/"..need
	self.selectedSpotCostName.text = name
	utility.LoadSpriteFromPath(icon, self.selectedSpotCostIcon)
end

return ZodiacCls