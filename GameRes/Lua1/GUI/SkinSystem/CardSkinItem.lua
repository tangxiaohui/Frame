local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "LUT.StringTable"
require "System.LuaDelegate"
local CardSkinItemCls = Class(BaseNodeClass)

function CardSkinItemCls:Ctor(parent,skinId,canClicked)
	self.parent = parent
	self.skinId = skinId
	self.canClicked = canClicked
	self.callback = LuaDelegate.New()
end

function CardSkinItemCls:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CardSkinItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CardSkin', function(go)
		self:BindComponent(go,false)
	end)
end

function CardSkinItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function CardSkinItemCls:OnResume()
	-- 界面显示时调用
	CardSkinItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:InitView()
end

function CardSkinItemCls:OnPause()
	-- 界面隐藏时调用
	CardSkinItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function CardSkinItemCls:OnEnter()
	-- Node Enter时调用
	CardSkinItemCls.base.OnEnter(self)
end

function CardSkinItemCls:OnExit()
	-- Node Exit时调用
	CardSkinItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CardSkinItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ClickedButton = transform:Find('Base/SkinIllust'):GetComponent(typeof(UnityEngine.UI.Button))
	self.skinLvLabel = transform:Find('Base/LV/NumFont'):GetComponent(typeof(UnityEngine.UI.Text))
	self.nameLabel = transform:Find('Base/name/NameCh'):GetComponent(typeof(UnityEngine.UI.Text))
	self.JPNameImage = transform:Find('Base/name/NameJp'):GetComponent(typeof(UnityEngine.UI.Image))
	self.iconImage = transform:Find('Base/SkinIllust'):GetComponent(typeof(UnityEngine.UI.Image))
	self.raceBaseImage = transform:Find('Base/Icon/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.raceImage = transform:Find('Base/Icon/Racial'):GetComponent(typeof(UnityEngine.UI.Image))
	self.KizunaCountLabel = transform:Find('Base/Kizuna/NumFont'):GetComponent(typeof(UnityEngine.UI.Text))
	self.noticeLabel = transform:Find('Base/Notice/NoticeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.SkinIllustImage = transform:Find('Base/SkinIllust'):GetComponent(typeof(UnityEngine.UI.Image))

	self.myGame = utility:GetGame()
end


function CardSkinItemCls:RegisterControlEvents()
	self.__event_button_onClickedButtonClicked__ = UnityEngine.Events.UnityAction(self.OnClickedButtonClicked, self)
	self.ClickedButton.onClick:AddListener(self.__event_button_onClickedButtonClicked__)
end

function CardSkinItemCls:UnregisterControlEvents()
	if self.__event_button_onClickedButtonClicked__ then
		self.ClickedButton.onClick:RemoveListener(self.__event_button_onClickedButtonClicked__)
		self.__event_button_onClickedButtonClicked__ = nil
	end
end

function CardSkinItemCls:RegisterNetworkEvents()

end

function CardSkinItemCls:UnregisterNetworkEvents()

end
-----------------------------------------------------------------------
local function GetCachedData(self,cardId,skinId)
	local UserDataType = require "Framework.UserDataType"
    local cacheData = self:GetCachedData(UserDataType.CardSkinsData)
    local skinData,cardData = cacheData:GetOneSkinData(cardId,skinId)
    return skinData,cardData
end

function CardSkinItemCls:InitView()
	local gameTool = require "Utils.GameTools"

	--local skinId = self.skinData:GetCardSkinId()
	local infoData,data,name,iconPath,itype = gameTool.GetItemDataById(self.skinId)
	local color = gameTool.GetItemColorByType(itype,data)
	local cardId = data:GetRoleid()
	local _,roleData = gameTool.GetItemDataById(cardId)
	utility.LoadRaceIcon(roleData:GetRace(),self.raceImage)
	utility.LoadCardSkinBaseIcon(color,self.raceBaseImage)
	local portraitName = roleData:GetPortraitImage()
	gameTool.SetRoleCardName(portraitName,nil,self.JPNameImage)
	self.nameLabel.text = name
	self.noticeLabel.text = data:GetDescription()
	utility.LoadIllustCardSkinPortraitImage(self.skinId,self.SkinIllustImage)
	self.SkinIllustImage:SetNativeSize()

	local UserDataType = require "Framework.UserDataType"
    local cacheData = self:GetCachedData(UserDataType.CardSkinsData)
    local skinData,cardSkinData = cacheData:GetOneSkinData(cardId,self.skinId)
    local skinLv
    if skinData == nil then
    	skinLv = 0 
    else
		skinLv = skinData:GetCardSkinLevel() 

		local kizunaId = data:GetKizuna()
		local kizunaLevel = 0
		if kizunaId ~= 0 then
			local CardSkinDataUtils = require "Utils.CardSkinUtils"
			kizunaLevel = CardSkinDataUtils.GetOpenedKizunaState(skinData,cardId)
		end
		debug_print("@@@",kizunaLevel)
		self.KizunaCountLabel.text = kizunaLevel
 	end
 	self.skinLvLabel.text = skinLv

	--local skinLv = self.skinData:GetCardSkinLevel()
	--self.skinLvLabel.text = skinLv
	--立绘
	--羁绊
	


	
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function CardSkinItemCls:OnClickedButtonClicked()
	if self.canClicked then
		self.callback:Invoke()
	end
end



return CardSkinItemCls