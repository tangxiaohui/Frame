
local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"

local HeroScene = Class(BaseNodeClass)

function HeroScene:Ctor()
end

function HeroScene:OnInit()
    utility.LoadNewGameObjectAsync(
        "UI/Prefabs/NeoCardInfoKai",
        function(go)
            self:BindComponent(go)
        end
    )
end

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- 最外层的Animator
    self.rootAnimator = transform:GetComponent(typeof(UnityEngine.Animator))

    -- 卡牌左边标签页的 transform --
    local HeroTableNodeClass = require "GUI.Hero.HeroTableNode"
    self.heroTableNode = HeroTableNodeClass.New(transform:Find("CardGroup"), self.rootAnimator)
    self:AddChild(self.heroTableNode)

    -- 详细卡牌页面 transform --
    local HeroDetailNodeClass = require "GUI.Hero.HeroDetailViewNode"
    self.detailNode = HeroDetailNodeClass.New(transform:Find("DetailGroup"), self.rootAnimator)
    self:AddChild(self.detailNode)

    -- 按钮 --
    self.backButton = transform:Find("LeftTopGroup/BackButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 返回到英雄界面按钮 --
    self.backToHeroButton = transform:Find("BackButton2"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 到装备信息按钮 --
    self.goEquipButton = transform:Find("GoEquipInfoButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.goEquipButtonObject = self.goEquipButton.gameObject

    -- 升级按钮 --
    self.levelUpButton = transform:Find("CardPowerupButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.levelUpRedDot = transform:Find("CardPowerupButton/Red"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 进阶按钮 --
    self.stageUpButton = transform:Find("CardUpgradeButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.stageUpRedDot = transform:Find("CardUpgradeButton/Red"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 天赋按钮 --
    self.talentButton = transform:Find("TalentButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.talentRedDot = transform:Find("TalentButton/Red"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 突破按钮 --
    self.breakButton =  transform:Find("CardPowerupButton/CardBreakButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.breakRedDot = transform:Find("CardPowerupButton/CardBreakButton/Red"):GetComponent(typeof(UnityEngine.UI.Image))

    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)

    --userData:GetLevel() >= 40  先屏蔽突破功能
    self.breakButton.transform.gameObject:SetActive(false)
	-- 卡册按钮 --
	self.skinButton = transform:Find("CardSkinButton"):GetComponent(typeof(UnityEngine.UI.Button))
end

-- 更新升级红点状态
local function UpdateLevelUpRedDotState(self, uid)
    self.levelUpRedDot.enabled = require "Utils.RedDotUtils".HasRoleLevelUpRedDot(uid)
end

local function IsCurrentAnimationState(animator, stateName)
    local stateInfo = animator:GetCurrentAnimatorStateInfo(0)
    return stateInfo:IsName(stateName)
end

local function OnBackButtonClicked(self)
    if IsCurrentAnimationState(self.rootAnimator, "zhuangbeixinxi") or IsCurrentAnimationState(self.rootAnimator, "zhuangbeixinxi_yingxiongdianji") then
        self.rootAnimator:ResetTrigger("HeroClicked")
        self.rootAnimator:ResetTrigger("BackHero")
        self.rootAnimator:ResetTrigger("JumpToEquip")
        self.rootAnimator:SetTrigger("BackHero")
    else
        local myGame = require "Utils.Utility".GetGame()
        local sceneManager = myGame:GetSceneManager()
        sceneManager:PopScene()
    end
end

local function OnBackToHeroButtonClicked(self)
    self.rootAnimator:ResetTrigger("HeroClicked")
    self.rootAnimator:ResetTrigger("BackHero")
    self.rootAnimator:ResetTrigger("JumpToEquip")
    self.rootAnimator:SetTrigger("BackHero")
end

local function OnGoEquipButtonClicked(self)
    utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[5].systemGuideID,self)
    
    self.rootAnimator:ResetTrigger("HeroClicked")
    self.rootAnimator:ResetTrigger("BackHero")
    self.rootAnimator:ResetTrigger("JumpToEquip")
    self.rootAnimator:SetTrigger("JumpToEquip")
end

local function OnLevelUpButtonClicked(self)
    local messageGuids = require "Framework.Business.MessageGuids"
    self:DispatchEvent(messageGuids.CardLevelUpClicked, nil)
end

local function OnStageUpButtonClicked(self)
    local messageGuids = require "Framework.Business.MessageGuids"
    self:DispatchEvent(messageGuids.CardStageUpClicked, nil)
end

local function OnTalentButtonClicked(self)
    local messageGuids = require "Framework.Business.MessageGuids"
    self:DispatchEvent(messageGuids.CardTalentClicked, nil)
end

local function OnBreakButtonClicked(self)
    local messageGuids = require "Framework.Business.MessageGuids"
    self:DispatchEvent(messageGuids.CardBreakClicked, nil)
end

local function OnSkinButtonClicked(self)
    local messageGuids = require "Framework.Business.MessageGuids"
    self:DispatchEvent(messageGuids.CardSkinClicked, nil)
end



local function OnGoEquipmentButtonDisabled(self, isDisabled)
    self.goEquipButtonObject:SetActive(not isDisabled)
end



function HeroScene:OnComponentReady()
    InitControls(self)
end

local function OnAddGuideEvent(self)
    -- 新手引导 --
    local guideMgr = utility.GetGame():GetGuideManager()

    -- 已测 --
    guideMgr:AddGuideEvnt(kGuideEvnt_GetHeroPanelTips)
    guideMgr:AddGuideEvnt(kGuideEvnt_SelectInitialHero)
    guideMgr:AddGuideEvnt(kGuideEvnt_GoHeroEquipPanel)
    guideMgr:AddGuideEvnt(kGuideEvnt_HeroEquipPanelTips)
    guideMgr:AddGuideEvnt(kGuideEvnt_HeroLevelupWindowOn)
    guideMgr:AddGuideEvnt(kGuideEvnt_GetReadyEquipGideTips)
    guideMgr:AddGuideEvnt(kGuideEvnt_ClickWeaponFrame)
    guideMgr:AddGuideEvnt(kGuideEvnt_ClickWeaponFrameAgain)

    -- 未测 --
     guideMgr:AddGuideEvnt(kGuideEvnt_GetReadyHeroPanelGideTips)
  --  guideMgr:AddGuideEvnt(kGuideEvnt_GetHeroPanelTips)

    guideMgr:AddGuideEvnt(kGuideEvnt_ChooseyourGreen)
    guideMgr:AddGuideEvnt(kGuideEvnt_2ndGotoCardDetail)
    guideMgr:AddGuideEvnt(kGuideEvnt_2ndCardDetailTalk)
    guideMgr:AddGuideEvnt(kGuideEvnt_2ndCardUpgrade)
    guideMgr:AddGuideEvnt(kGuideEvnt_3rdGotoCardDetail)
    guideMgr:AddGuideEvnt(kGuideEvnt_3rdCardDetailTalk)
    
    guideMgr:SortGuideEvnt()
    guideMgr:ShowGuidance()
end

local function DelayWaitForHeroNodeReady(self)
    repeat
        coroutine.step(1)
    until(self.heroTableNode:IsReady())

    --coroutine.wait(1.5)

    -- finished --
    OnAddGuideEvent(self)
end

function HeroScene:LocalRedDotChanged()

    local  roleID = self.heroTableNode:GetSelectedItemID()
    local calculateRed = require"Utils.CalculateRed"
    self.stageUpRedDot.enabled = calculateRed.GetRoleAdvancedRedDataByID(roleID)
    self.talentRedDot.enabled = (calculateRed.GetRoleTalentRedDataByID(roleID)or calculateRed.GetRoleTeamTalentRedDataByID(roleID))
    self.levelUpRedDot.enabled =calculateRed.GetUpgradeRoleRedDataByID(roleID)
    -- local redDotUtils = require "Utils.RedDotUtils"
    -- self.stageUpRedDot.enabled = redDotUtils.CanCardStageUp(uid)
    -- self.talentRedDot.enabled = redDotUtils.CanCardTalentUp(uid)
    -- UpdateLevelUpRedDotState(self, uid)
end

local function OnItemBagUpdate(self, itemData)
    if itemData == nil then
        return
    end

    local itemId = itemData:GetId()
    if itemId == kItemId_NormalEnergyExpBattery or itemId == kItemId_HighEnergyExpBattery or itemId == kItemId_SuperEnergyExpBattery then
        UpdateLevelUpRedDotState(self, self.heroTableNode:GetSelectedItemUID())
    end
end

local function OnLoadPlayerResponse(self)
    UpdateLevelUpRedDotState(self, self.heroTableNode:GetSelectedItemUID())
end

local function OnHeroDetailViewRefresh(self, _, userRoleData, _, _, _)
	if userRoleData == nil then
		return
	end

    self:LocalRedDotChanged()--(self, userRoleData:GetUid())
end


function HeroScene:OnResume()
    HeroScene.base.OnResume(self)

    -- 注册 BackButton
    self.__event_backButtonClicked__ = UnityEngine.Events.UnityAction(OnBackButtonClicked, self)
    self.backButton.onClick:AddListener(self.__event_backButtonClicked__)

    -- 注册 BackToEquipButton
    self.__event_backToHeroButtonClicked__ = UnityEngine.Events.UnityAction(OnBackToHeroButtonClicked, self)
    self.backToHeroButton.onClick:AddListener(self.__event_backToHeroButtonClicked__)

    -- self.goEquipButton
    -- 注册 GoEquipButton
    self.__event_goEquipButtonClicked__ = UnityEngine.Events.UnityAction(OnGoEquipButtonClicked, self)
    self.goEquipButton.onClick:AddListener(self.__event_goEquipButtonClicked__)

    -- 注册 levelUpButton
    self.__event_levelUpButtonClicked__ = UnityEngine.Events.UnityAction(OnLevelUpButtonClicked, self)
    self.levelUpButton.onClick:AddListener(self.__event_levelUpButtonClicked__)

    -- 注册 stageUpButton
    self.__event_stageUpButtonClicked__ = UnityEngine.Events.UnityAction(OnStageUpButtonClicked, self)
    self.stageUpButton.onClick:AddListener(self.__event_stageUpButtonClicked__)

    -- 注册 talentButton
    self.__event_talentButtonClicked__ = UnityEngine.Events.UnityAction(OnTalentButtonClicked, self)
    self.talentButton.onClick:AddListener(self.__event_talentButtonClicked__)

    -- 注册 breakButton
    self.__event_breakButtonClicked__ = UnityEngine.Events.UnityAction(OnBreakButtonClicked, self)
    self.breakButton.onClick:AddListener(self.__event_breakButtonClicked__)
	
	 -- 注册 skinButton
    self.__event_skinButtonClicked__ = UnityEngine.Events.UnityAction(OnSkinButtonClicked, self)
    self.skinButton.onClick:AddListener(self.__event_skinButtonClicked__)

    -- 注册 装备按钮禁用消息 --
    local messageGuids = require "Framework.Business.MessageGuids"
    self:RegisterEvent(messageGuids.GoEquipmentButtonDisabled, OnGoEquipmentButtonDisabled, nil)
	
	self:RegisterEvent(messageGuids.HeroDetailViewRefresh, OnHeroDetailViewRefresh, nil)

    self:RegisterEvent(messageGuids.LocalRedDotChanged, self.LocalRedDotChanged)

    self:RegisterEvent(messageGuids.AddedOneItem, OnItemBagUpdate)
    self:RegisterEvent(messageGuids.UpdatedOneItem, OnItemBagUpdate)

    self:RegisterEvent(messageGuids.UpdatedPlayerData, OnLoadPlayerResponse)

	self:StartCoroutine(DelayWaitForHeroNodeReady)

    require "Utils.GameAnalysisUtils".EnterScene("角色界面")
    require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_CardView)
    utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[5].systemGuideID,self)

end

function HeroScene:OnPause()
    HeroScene.base.OnPause(self)

    -- 取消注册 BackButton
    if self.__event_backButtonClicked__ then
        self.backButton.onClick:RemoveListener(self.__event_backButtonClicked__)
        self.__event_backButtonClicked__ = nil
    end

    -- 取消注册 BackToEquipButton
    if self.__event_backToHeroButtonClicked__ then
        self.backToHeroButton.onClick:RemoveListener(self.__event_backToHeroButtonClicked__)
        self.__event_backToHeroButtonClicked__ = nil
    end

    -- 取消注册 GoEquipButton
    if self.__event_goEquipButtonClicked__ then
        self.goEquipButton.onClick:RemoveListener(self.__event_goEquipButtonClicked__)
        self.__event_goEquipButtonClicked__ = nil
    end

    -- 取消注册 leveUpButton
    if self.__event_levelUpButtonClicked__ then
        self.levelUpButton.onClick:RemoveListener(self.__event_levelUpButtonClicked__)
        self.__event_levelUpButtonClicked__ = nil
    end

    -- 取消注册
    if self.__event_stageUpButtonClicked__ then
        self.stageUpButton.onClick:RemoveListener(self.__event_stageUpButtonClicked__)
        self.__event_stageUpButtonClicked__ = nil
    end

    -- 取消注册
    if self.__event_talentButtonClicked__ then
        self.talentButton.onClick:RemoveListener(self.__event_talentButtonClicked__)
        self.__event_talentButtonClicked__ = nil
    end

    -- 取消注册
    if self.__event_breakButtonClicked__ then
        self.breakButton.onClick:RemoveListener(self.__event_breakButtonClicked__)
        self.__event_breakButtonClicked__ = nil
    end

	-- 取消注册
    if self.__event_skinButtonClicked__ then
        self.skinButton.onClick:RemoveListener(self.__event_skinButtonClicked__)
        self.__event_skinButtonClicked__ = nil
    end

    -- 取消注册 装备按钮禁用消息 --
    local messageGuids = require "Framework.Business.MessageGuids"
    self:UnregisterEvent(messageGuids.GoEquipmentButtonDisabled, OnGoEquipmentButtonDisabled, nil)

    self:UnregisterEvent(messageGuids.LocalRedDotChanged, self.LocalRedDotChanged)

    self:UnregisterEvent(messageGuids.HeroDetailViewRefresh, OnHeroDetailViewRefresh, nil)
    
    self:UnregisterEvent(messageGuids.AddedOneItem, OnItemBagUpdate)
    self:UnregisterEvent(messageGuids.UpdatedOneItem, OnItemBagUpdate)

    self:UnregisterEvent(messageGuids.UpdatedPlayerData, OnLoadPlayerResponse)
end

return HeroScene