local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
require "LUT.ArrayString"
-----------------------------------------------------------------------
local CardUpGradeResultCls = Class(BaseNodeClass)
windowUtility.SetMutex(CardUpGradeResultCls, true)

function CardUpGradeResultCls:Ctor()
end

function CardUpGradeResultCls:OnWillShow(showType,cardData,oldInfo,newInfo)
	self.showType = showType
    self.cardData = cardData
    self.oldInfo = oldInfo
    self.newInfo = newInfo

    self:OnResetView()
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CardUpGradeResultCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CardUpgradeResult', function(go)
		self:BindComponent(go)
	end)
end

function CardUpGradeResultCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function CardUpGradeResultCls:OnResume()
	-- 界面显示时调用
	CardUpGradeResultCls.base.OnResume(self)
	self:RegisterControlEvents()

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function CardUpGradeResultCls:OnPause()
	-- 界面隐藏时调用
	CardUpGradeResultCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function CardUpGradeResultCls:OnEnter()
	-- Node Enter时调用
	CardUpGradeResultCls.base.OnEnter(self)
end

function CardUpGradeResultCls:OnExit()
	-- Node Exit时调用
	CardUpGradeResultCls.base.OnExit(self)
end

function CardUpGradeResultCls:IsTransition()
    return false
end

function CardUpGradeResultCls:OnExitTransitionDidStart(immediately)
	CardUpGradeResultCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function CardUpGradeResultCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CardUpGradeResultCls:InitControls()
	local transform = self:GetUnityTransform()

	self.tweenObjectTrans = transform:Find("CardDrawResultBase")
	self.RetrunButton = self.tweenObjectTrans:GetComponent(typeof(UnityEngine.UI.Button))
	self.cardPoint = transform:Find("CardItem/Point")
	self.BackLight = transform:Find("CardItem/BackLight"):GetComponent(typeof(UnityEngine.UI.Image))
	self.animator = transform:GetComponent(typeof(UnityEngine.Animator))
	self.effectObj = transform:Find("chouka_shua/Point").gameObject

	-- 生命
	self.oldLifeLabel = transform:Find('CardRiseBase/Attr1Label'):GetComponent(typeof(UnityEngine.UI.Text))
	self.newLifeLabel = transform:Find('CardRiseBase/Attr1PlusLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 攻击
	self.oldApLabel = transform:Find('CardRiseBase/Attr2Label '):GetComponent(typeof(UnityEngine.UI.Text))
	self.newApLabel = transform:Find('CardRiseBase/Attr2PlusLabel '):GetComponent(typeof(UnityEngine.UI.Text))
	
	-- 防御
	self.oldDpLabel = transform:Find('CardRiseBase/Attr3Label '):GetComponent(typeof(UnityEngine.UI.Text))
	self.newDpLabel = transform:Find('CardRiseBase/Attr3PlusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
	-- 速度
	self.oldSpeedLabel = transform:Find('CardRiseBase/Attr4Label '):GetComponent(typeof(UnityEngine.UI.Text))
	self.newSpeedLabel = transform:Find('CardRiseBase/Attr4PlusLabel '):GetComponent(typeof(UnityEngine.UI.Text))

	self.titleLabel = transform:Find("Title/Title"):GetComponent(typeof(UnityEngine.UI.Text))
	-- -- 品阶
	self.stageLaebl = transform:Find('CardRiseBase/Stagelabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.oldStageLabel = transform:Find('CardRiseBase/Attr1Label'):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.newStageLabel = transform:Find('CardRiseBase/Attr1Label'):GetComponent(typeof(UnityEngine.UI.Text))
	self.canClicked = false
end


function CardUpGradeResultCls:RegisterControlEvents()
	-- 注册 ShopRetrunButton 的事件
	self.__event_button_onRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked, self)
	self.RetrunButton.onClick:AddListener(self.__event_button_onRetrunButtonClicked__)
end

function CardUpGradeResultCls:UnregisterControlEvents()
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
	local roleData = GetRoleDataFromBag(self,self.roleID)
	local infoData,staticData = gameTool.GetItemDataById(self.roleID)

	node:SetId(self.roleID)
	node:SetIcon(staticData:GetPortraitImage())
	node:SetStar(roleData:GetStar())
	node:SetRarity(roleData:GetRarity())
	node:SetRace(roleData:GetRace())
	local major = staticData:GetMajorAttr()
	local majorPath = gameTool.GetMajorAttrImagePath(major)
	node:SetCardType(majorPath)
	node:SetHP(roleData:GetHp())
	node:SetATK(roleData:GetAp())
	local activeSkill = string.format("%s%s%s%s","....",infoData:GetActiveSkillName(),":",infoData:GetActiveSkillDesc())
	node:SetActiveSkill(activeSkill)
	local passiveSkill = string.format("%s%s%s%s","....",infoData:GetPassiveSkillName(),":",infoData:GetPassiveSkillDesc())
	node:SetPassiveSkill(passiveSkill)
	node:SetScale(Vector3(0.65,0.65,1))
	return roleData
end

local function IsChangeDebris(self)
	if self.addDict ~= nil then
		local isAdd = self.addDict:GetEntryByKey(self.roleID)	
		if not isAdd then
			self.hintLabel:SetActive(true)
		end
	end
end

local function DelayPlayEffect(self)
	coroutine.wait(0.333)
	self.effectObj:SetActive(true)
	coroutine.wait(3)
	self.canClicked = true
end

function CardUpGradeResultCls:CallBack()
	self.animator:SetTrigger ("Start")
	self:StartCoroutine(DelayPlayEffect)
end

local function SetInfo(self)
	local stageStr = ""
	if self.showType == 1 then
		self.titleLabel.text = "进阶成功"
		stageStr = string.format("%s%s","+",self.newInfo.nextStage)
	elseif self.showType == 2 then
		self.titleLabel.text = "升品成功"
	elseif self.showType == 3 then
		self.titleLabel.text = BreakTroughString[4]
		stageStr = self.newInfo.stageStr
	end

	if self.showType == 1 or self.showType == 2 then
		local colorStr = Color[self.newInfo.color]
		self.stageLaebl.text = string.format("%s%s",colorStr,stageStr)
		local PropUtility = require "Utils.PropUtility"
		self.stageLaebl.color = PropUtility.GetRGBColorValue(self.newInfo.color)
	else
		self.stageLaebl.text = stageStr
	end

	self.oldLifeLabel.text = string.format("%s%s","生命： ",self.oldInfo.life)
	self.newLifeLabel.text = self.newInfo.life

	self.oldApLabel.text = string.format("%s%s","攻击： ",self.oldInfo.ap)
	self.newApLabel.text = self.newInfo.ap

	self.oldDpLabel.text = string.format("%s%s","防御： ",self.oldInfo.dp)
	self.newDpLabel.text = self.newInfo.dp

	self.oldSpeedLabel.text = string.format("%s%s","速度： ",self.oldInfo.speed)
	self.newSpeedLabel.text = self.newInfo.speed
end

function CardUpGradeResultCls:AddCardNode()
	local node = require "GUI.GeneralCard.GeneralCardItem".New(self.cardPoint)
	local roleData = SetNode(self,node)
	node:SetCallback(self,self.CallBack)
	node:SetScale(Vector3(1,1,1))
	self:AddChild(node)
	self.BackLight.gameObject:SetActive(true)
	local color = roleData:GetColor()
	self.BackLight.color = require "Utils.GameTools".GetBackLightColor(color)
	SetInfo(self)
end

local function DelayResetView(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	self:AddCardNode()
end

function CardUpGradeResultCls:OnResetView()
	self.roleID = self.cardData:GetId()
	self:StartCoroutine(DelayResetView)
end

function CardUpGradeResultCls:OnRetrunButtonClicked()
	if not self.canClicked  then
		return
	end
	self:Close()
end

return CardUpGradeResultCls