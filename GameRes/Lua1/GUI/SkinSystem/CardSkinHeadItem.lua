local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "LUT.StringTable"
require "System.LuaDelegate"
local CardSkinHeadItemCls = Class(BaseNodeClass)

function CardSkinHeadItemCls:Ctor(parent,cardId,skinId,canClicked)
	self.parent = parent
	self.cardId = cardId
	self.skinId = skinId
	self.canClicked = canClicked
	self.callback = LuaDelegate.New()
end

function CardSkinHeadItemCls:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CardSkinHeadItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CardSkinIcon', function(go)
		self:BindComponent(go,false)
	end)
end

function CardSkinHeadItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function CardSkinHeadItemCls:OnResume()
	-- 界面显示时调用
	CardSkinHeadItemCls.base.OnResume(self)
	self:ResetView(self.cardId,self.skinId)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function CardSkinHeadItemCls:OnPause()
	-- 界面隐藏时调用
	CardSkinHeadItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function CardSkinHeadItemCls:OnEnter()
	-- Node Enter时调用
	CardSkinHeadItemCls.base.OnEnter(self)
end

function CardSkinHeadItemCls:OnExit()
	-- Node Exit时调用
	CardSkinHeadItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CardSkinHeadItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ClickedButton = transform:Find('Base/Icon'):GetComponent(typeof(UnityEngine.UI.Button))
	self.IconImage = self.ClickedButton.transform:GetComponent(typeof(UnityEngine.UI.Image))
	self.nameLabel = transform:Find('NameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ColorFrame = transform:Find('Frame')
	self.levelColorFrame = transform:Find('Lv/Frame')
	self.levelLabel = transform:Find('Lv/LvLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.KizunaLabel = transform:Find('Kizuna/KizunaLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.KizunaImage = transform:Find('Kizuna'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LvGameObject = transform:Find('Lv').gameObject
	self.kizunaGameObject = transform:Find('Kizuna').gameObject
	self.EquipedGameObject = transform:Find('Equiped').gameObject

	self.myGame = utility:GetGame()
end


function CardSkinHeadItemCls:RegisterControlEvents()
	self.__event_button_onClickedButtonClicked__ = UnityEngine.Events.UnityAction(self.OnClickedButtonClicked, self)
	self.ClickedButton.onClick:AddListener(self.__event_button_onClickedButtonClicked__)
end

function CardSkinHeadItemCls:UnregisterControlEvents()
	if self.__event_button_onClickedButtonClicked__ then
		self.ClickedButton.onClick:RemoveListener(self.__event_button_onClickedButtonClicked__)
		self.__event_button_onClickedButtonClicked__ = nil
	end
end

function CardSkinHeadItemCls:RegisterNetworkEvents()

end

function CardSkinHeadItemCls:UnregisterNetworkEvents()

end
-----------------------------------------------------------------------
local function GetCachedData(self,cardId,skinId)
	local UserDataType = require "Framework.UserDataType"
    local cacheData = self:GetCachedData(UserDataType.CardSkinsData)
    local skinData,cardData = cacheData:GetOneSkinData(cardId,skinId)
    return skinData,cardData
end

function CardSkinHeadItemCls:ResetView(cardId,skinId)
	local cachedData,cardData = GetCachedData(self,cardId,skinId)
	local gameTool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"
	local _,staticData,name,iconPath,itype = gameTool.GetItemDataById(skinId)
	self.nameLabel.text = name
	utility.LoadCardSkinHeadIcon(skinId,self.IconImage)

	self.haded = false
	self.equipState = false
	if cachedData ~= nil then
		local level = cachedData:GetCardSkinLevel()
		self.levelLabel.text = level
		local color = gameTool.GetItemColorByType(itype,staticData)
		PropUtility.AutoSetRGBColor(self.ColorFrame,color)
		PropUtility.AutoSetRGBColor(self.levelColorFrame,color)
		self.KizunaImage.material = nil

		local kizunaId = staticData:GetKizuna()
    	if kizunaId ~= 0 then
    		local CardSkinDataUtils = require "Utils.CardSkinUtils"
    		local result = CardSkinDataUtils.GetOpenedKizunaState(cachedData,cardId)
    		self.KizunaLabel.text = result
    	end

    	-- 穿戴的卡牌
    	self.skinUid = cachedData:GetCardSkinUID()
    	local cardEquipSkin = cardData:GetcurrSkinId()
    	if cardEquipSkin == skinId then
    		self.equipState = true
    	end

    	self.IconImage.material = nil
		
		self.haded = true
	else
		local imageMaterial = utility.GetGrayMaterial()
		self.IconImage.material = imageMaterial
	end
	self.EquipedGameObject:SetActive(self.equipState)
end

function DelayHideEquiped(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	self.EquipedGameObject:SetActive(false)
end

function DelayHide(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	self.kizunaGameObject:SetActive(false)
	self.EquipedGameObject:SetActive(false)
end

function CardSkinHeadItemCls:UpdateEquipState()
	self.equipState = false
	self:StartCoroutine(DelayHideEquiped)
end

function CardSkinHeadItemCls:SimpleShowHead()
	self:StartCoroutine(DelayHide)
end

function CardSkinHeadItemCls:GetSkinUid()
	return self.skinUid
end

function CardSkinHeadItemCls:GetCardId()
	return self.cardId
end

function CardSkinHeadItemCls:GetEquipState()
	return self.equipState
end

function CardSkinHeadItemCls:GetSkinId()
	return self.skinId
end

function CardSkinHeadItemCls:GetHaded()
	return self.haded
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function CardSkinHeadItemCls:OnClickedButtonClicked()
	if self.canClicked then
		self.callback:Invoke(self)
	end
end



return CardSkinHeadItemCls