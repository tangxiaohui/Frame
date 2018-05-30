--
-- User: fenghao
-- Date: 19/06/2017
-- Time: 12:16 AM
--

local BaseNodeClass = require "Framework.Base.Node"
local HeroDetailRightViewNode = Class(BaseNodeClass)
local utility = require "Utils.Utility"
require "LUT.StringTable"
require "Const"

local function InitControls(self)
    local transform = self:GetUnityTransform()

    local EquipmentPanelClass = require "GUI.Hero.HeroDetailEquipmentPanel"
    self.equipmentPanel = EquipmentPanelClass.New(transform:Find("WearingBase"))
    self:AddChild(self.equipmentPanel)

    local AttributePanelClass = require "GUI.Hero.HeroDetailAttributePanel"
    self.attributePanel = AttributePanelClass.New(transform:Find("CardInfo"))
    self:AddChild(self.attributePanel)

    -- 左/右按钮 --
    self.leftArrowButton = transform:Find("NeoCardInfoLeftArrowButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.rightArrowButton = transform:Find("NeoCardInfoRightArrowButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.styleButton = transform:Find("StyleButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.styleButtonImage = transform:Find("StyleButton"):GetComponent(typeof(UnityEngine.UI.Image))
    self.beStrongButton = transform:Find("BeStrongButton"):GetComponent(typeof(UnityEngine.UI.Button))

end

function HeroDetailRightViewNode:Ctor(transform, rootAnimator)
    self.rootAnimator = rootAnimator
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

function HeroDetailRightViewNode:Refresh(_, userRoleData, _)
    -- 右边的页面 只供玩家已拥有卡牌 显示 --
    debug_print(" HeroDetailRightViewNode:Refresh(",userRoleData)
    if userRoleData == nil then
        -- 取消/隐藏 --
        return
    end

    self.currentUserRoleData = userRoleData

    -- 刷新装备面版 --
    self.equipmentPanel:Refresh(userRoleData)

    -- 刷新属性面板 --
    self.attributePanel:Refresh(userRoleData)
	
	utility.LoadSpriteFromPath(self.currentUserRoleData:GetZodiac():GetIcon(), self.styleButtonImage)
end

local function OnEquipmentSlotClicked(self, equipmentSlot)
    if not utility.IsCanOpenModule(KSystemBasis_HeroEquipment) then
        return
    end

    local equipmentSlotType = equipmentSlot:GetType()
    local equipmentPos = equipmentSlot:GetPos()
    local equipmentItemData = equipmentSlot:GetItemData()

    local windowManager = self:GetGame():GetWindowManager()
    debug_print("equipmentItemData",equipmentItemData,equipmentPos)
    if equipmentItemData == nil then
        if equipmentSlotType == KEquipType_EquipWing then
            local windId = self.currentUserRoleData:GetbeishiID()
            windowManager:Show(require "GUI.EquipmentWindow.EquipmentWindow",nil,windId,KEquipWinShowType_Combine,self.currentUserRoleData:GetUid())
        else
            windowManager:Show(require "GUI.ChangeEquip.ChangeEquip",self.currentUserRoleData:GetId(),equipmentSlotType,equipmentPos,true)
        end        
    else
        windowManager:Show(require "GUI.EquipmentWindow.EquipmentWindow", equipmentItemData:GetEquipUID(), equipmentItemData:GetEquipID(), KEquipWinShowType_BaseInfo, self.currentUserRoleData:GetUid())
    end
end

local function OnCardLevelUpClicked(self)
    if utility.IsCanOpenModule(KSystemBasis_HeroLevelUp) then
        local windowManager = utility.GetGame():GetWindowManager()
        windowManager:Show(require "GUI.Modules.CardUpGradeModule",self.currentUserRoleData)
    end
end

local function OnStageUpClicked(self)
    if utility.IsCanOpenModule(KSystemBasis_HeroStageUp1) then
        if self.currentUserRoleData == nil then
            local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
            local windowManager = utility:GetGame():GetWindowManager()
            windowManager:Show(ErrorDialogClass, CrapStringTable[1])
        else
            local windowManager = self:GetGame():GetWindowManager()
            windowManager:Show(require "GUI.CardRise.CardRise",self.currentUserRoleData)
        end
    end
end

local function OnTalentClicked(self)
    -- print("TODO 天赋")
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Talent.Talent",self.currentUserRoleData:GetId())
end

local function OnBreakClicked(self)
    if self.currentUserRoleData:GetLv() < 40 then
        utility.ShowErrorDialog("卡牌等级需达到40级开启")
    else
        local windowManager = self:GetGame():GetWindowManager()
        windowManager:Show(require "GUI.BreakThrough.BreakThrough",self.currentUserRoleData)
    end
end

local function OnSkinClicked(self)
    
end

local function OnLeftArrowButtonClicked(self)
    -- print(">>>>@@@@ Left Switch! @@@@<<<<")
    local messageGuids = require "Framework.Business.MessageGuids"
    self:DispatchEvent(messageGuids.HeroCardLeftSwitch, nil)
end

local function OnRightArrowButtonClicked(self)
    local messageGuids = require "Framework.Business.MessageGuids"
    self:DispatchEvent(messageGuids.HeroCardRightSwitch, nil)
end

local function OnStyleButtonClicked(self)
    utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[5].systemGuideID,self)
	
    local levelLimit = require "StaticData.SystemConfig.SystemBasis":GetData(kSystemBasis_Zodiac):GetMinLevel()
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    if userData:GetLevel() < levelLimit then
        local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        local windowManager = self:GetGame():GetWindowManager()
        local hintStr = string.format(CommonStringTable[0],levelLimit)
        windowManager:Show(ErrorDialogClass, hintStr)
        return
    end
	
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Zodiac.Zodiac", self.currentUserRoleData:GetZodiac(), self.currentUserRoleData:GetActivedZodiacSpot(), self.currentUserRoleData:GetLv(), self.currentUserRoleData:GetUid())
end

local function OnBeStrongButtonClicked(self)
   local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.SkinSystem.SkinInfoCls",self.currentUserRoleData:GetId())
end

function HeroDetailRightViewNode:OnResume()
    HeroDetailRightViewNode.base.OnResume(self)


    local messageGuids = require "Framework.Business.MessageGuids"

    self:RegisterEvent(messageGuids.CardLevelUpClicked, OnCardLevelUpClicked, nil)
    self:RegisterEvent(messageGuids.CardStageUpClicked, OnStageUpClicked, nil)
    self:RegisterEvent(messageGuids.CardTalentClicked, OnTalentClicked, nil)
    self:RegisterEvent(messageGuids.CardBreakClicked, OnBreakClicked, nil)
	self:RegisterEvent(messageGuids.CardSkinClicked, OnSkinClicked, nil)
    self:RegisterEvent(messageGuids.HeroEquipmentSlotClicked, OnEquipmentSlotClicked, nil)


    self.__event_button_leftArrowButtonClicked__ = UnityEngine.Events.UnityAction(OnLeftArrowButtonClicked, self)
    self.leftArrowButton.onClick:AddListener(self.__event_button_leftArrowButtonClicked__)

    self.__event_button_rightArrowButtonClicked__ = UnityEngine.Events.UnityAction(OnRightArrowButtonClicked, self)
    self.rightArrowButton.onClick:AddListener(self.__event_button_rightArrowButtonClicked__)

      self.__event_button_styleButtonClicked__ = UnityEngine.Events.UnityAction(OnStyleButtonClicked, self)
    self.styleButton.onClick:AddListener(self.__event_button_styleButtonClicked__)

      self.__event_button_beStrongButtonClicked__ = UnityEngine.Events.UnityAction(OnBeStrongButtonClicked, self)
    self.beStrongButton.onClick:AddListener(self.__event_button_beStrongButtonClicked__)
end

function HeroDetailRightViewNode:OnPause()
    HeroDetailRightViewNode.base.OnPause(self)

    local messageGuids = require "Framework.Business.MessageGuids"

    self:UnregisterEvent(messageGuids.CardLevelUpClicked, OnCardLevelUpClicked, nil)
    self:UnregisterEvent(messageGuids.CardStageUpClicked, OnStageUpClicked, nil)
    self:UnregisterEvent(messageGuids.CardTalentClicked, OnTalentClicked, nil)
    self:UnregisterEvent(messageGuids.CardBreakClicked, OnBreakClicked, nil)
	self:UnregisterEvent(messageGuids.CardSkinClicked, OnSkinClicked, nil)

    self:UnregisterEvent(messageGuids.HeroEquipmentSlotClicked, OnEquipmentSlotClicked, nil)

    if self.__event_button_styleButtonClicked__ then
        self.styleButton.onClick:RemoveListener(self.__event_button_styleButtonClicked__)
        self.__event_button_styleButtonClicked__ = nil
    end

    if self.__event_button_beStrongButtonClicked__ then
        self.beStrongButton.onClick:RemoveListener(self.__event_button_beStrongButtonClicked__)
        self.__event_button_beStrongButtonClicked__ = nil
    end

    if self.__event_button_leftArrowButtonClicked__ then
        self.leftArrowButton.onClick:RemoveListener(self.__event_button_leftArrowButtonClicked__)
        self.__event_button_leftArrowButtonClicked__ = nil
    end

    if self.__event_button_rightArrowButtonClicked__ then
        self.rightArrowButton.onClick:RemoveListener(self.__event_button_rightArrowButtonClicked__)
        self.__event_button_rightArrowButtonClicked__ = nil
    end
end

return HeroDetailRightViewNode
