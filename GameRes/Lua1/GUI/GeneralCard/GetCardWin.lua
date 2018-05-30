local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
-----------------------------------------------------------------------
local GetCardWinCls = Class(BaseNodeClass)
windowUtility.SetMutex(GetCardWinCls, true)

function GetCardWinCls:Ctor()
end

function GetCardWinCls:OnWillShow(roleID,addDict)
	self.roleID = roleID
	self.addDict = addDict
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GetCardWinCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CardCombineResult', function(go)
		self:BindComponent(go)
	end)
end

function GetCardWinCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function GetCardWinCls:OnResume()
	-- 界面显示时调用
	GetCardWinCls.base.OnResume(self)
	self:RegisterControlEvents()

	self:AddCardNode()

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function GetCardWinCls:OnPause()
	-- 界面隐藏时调用
	GetCardWinCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function GetCardWinCls:OnEnter()
	-- Node Enter时调用
	GetCardWinCls.base.OnEnter(self)
end

function GetCardWinCls:OnExit()
	-- Node Exit时调用
	GetCardWinCls.base.OnExit(self)
end

function GetCardWinCls:IsTransition()
    return false
end

function GetCardWinCls:OnExitTransitionDidStart(immediately)
	GetCardWinCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function GetCardWinCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GetCardWinCls:InitControls()
	local transform = self:GetUnityTransform()

	self.tweenObjectTrans = transform:Find("CardDrawResultBase")
	self.RetrunButton = self.tweenObjectTrans:GetComponent(typeof(UnityEngine.UI.Button))
	self.cardPoint = transform:Find("tweenObject/StaticCanvas/CardPoint")
	self.hintLabel = transform:Find("tweenObject/StaticCanvas/HIntLabel").gameObject
	self.maskObj = transform:Find("tweenObject/Mask/WhiteMask").gameObject
	self.backHint = transform:Find("tweenObject/StaticCanvas/Text").gameObject
	self.backLightImage = transform:Find("tweenObject/StaticCanvas/CardPoint/BackLight"):GetComponent(typeof(UnityEngine.UI.Image))
	self.effectObj = transform:Find("tweenObject/Effect").gameObject
	self.getEffectObj = transform:Find('tweenObject/chouka_CK_Effect_Renwu/Point').gameObject
	self.canClicked = false
end


function GetCardWinCls:RegisterControlEvents()
	-- 注册 ShopRetrunButton 的事件
	self.__event_button_onRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked, self)
	self.RetrunButton.onClick:AddListener(self.__event_button_onRetrunButtonClicked__)
end

function GetCardWinCls:UnregisterControlEvents()
	-- 取消注册 ShopRetrunButton 的事件
	if self.__event_button_onRetrunButtonClicked__ then
		self.RetrunButton.onClick:RemoveListener(self.__event_button_onRetrunButtonClicked__)
		self.__event_button_onRetrunButtonClicked__ = nil
	end
end

local function GetRoleDataFromBag(self,id)
	local UserDataType = require "Framework.UserDataType"
	local data = self:GetCachedData(UserDataType.CardBagData)
	return data:GetRoleById(id)
end

local function SetNode(self,node)
	local gameTool = require "Utils.GameTools"
	--local roleData = GetRoleDataFromBag(self,self.roleID)
	local infoData,staticData,_,_,itype = gameTool.GetItemDataById(self.roleID)

	node:SetId(self.roleID)
	node:SetIcon(staticData:GetPortraitImage())
	node:SetStar(staticData:GetStar())
	node:SetRarity(staticData:GetRarity())
	node:SetRace(staticData:GetRace())
	local major = staticData:GetMajorAttr()
	local majorPath = gameTool.GetMajorAttrImagePath(major)
	node:SetCardType(majorPath)
	local color = staticData:GetColorID()
	local hp = staticData:GetBasicHp(color,1,0)
	local atk = staticData:GetBasicAp(color,1,0)
	node:SetHP(string.format("%s",math.floor(hp)))
	node:SetATK(string.format("%s",math.floor(atk)))
	local activeSkill = string.format("%s%s%s%s","....",infoData:GetActiveSkillName(),":",infoData:GetActiveSkillDesc())
	node:SetActiveSkill(activeSkill)
	local passiveSkill = string.format("%s%s%s%s","....",infoData:GetPassiveSkillName(),":",infoData:GetPassiveSkillDesc())
	node:SetPassiveSkill(passiveSkill)
	node:SetScale(Vector3(1,1,1))

	local color = gameTool.GetItemColorByType(itype,staticData)
	self.backLightImage.color = gameTool.GetBackLightColor(color)
end

local function IsChangeDebris(self)
	if self.addDict ~= nil then
		local isAdd = self.addDict:GetEntryByKey(self.roleID)	
		if not isAdd then
			self.hintLabel:SetActive(true)
			return true
		end
	end
	return false
end

local function PlayAnimator(self)
	--coroutine.step(20)
	self.effectObj:SetActive(true)
	self.cardPoint.gameObject:SetActive(true)
end

local function IsAllMailComponentsReady(self)
	if not self.node:HasUnityGameObject() then
        return false
    end
    return true
end

local function DelayGetCard(self)
	while(not IsAllMailComponentsReady(self))
    do
        coroutine.step(1)
    end
    self.getEffectObj:SetActive(true)
    coroutine.wait(1)
    self.canClicked = true    
    self.backLightImage.gameObject:SetActive(true)
    --self.maskObj:SetActive(true)
    self:StartCoroutine(PlayAnimator)
    local result = IsChangeDebris(self)
	self.backHint:SetActive(not result)
end

function GetCardWinCls:AddCardNode()
	local node = require "GUI.GeneralCard.GeneralCardItem".New(self.cardPoint)
	SetNode(self,node)
	self.node = node
	self.cardPoint.gameObject:SetActive(false)
	self:AddChild(self.node)
	self:StartCoroutine(DelayGetCard)
end

function GetCardWinCls:OnRetrunButtonClicked()
	if not self.canClicked then
		return
	end
	self:Close()
end

return GetCardWinCls