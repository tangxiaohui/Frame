--
-- User: fenghao
-- Date: 23/06/2017
-- Time: 10:15 PM
--

local NodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local messageGuids = require "Framework.Business.MessageGuids"

local BattleSkillEffectNode = Class(NodeClass)

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- 根节点 --
    self.rootAnimator = transform:GetComponent(typeof(UnityEngine.Animator))

    -- Base
    self.BaseImg = transform:Find("Base"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 四张立绘
    self.cardPortrait1 = transform:Find("CardPortrait1"):GetComponent(typeof(UnityEngine.UI.Image))
    self.cardPortrait2 = transform:Find("CardPortrait2"):GetComponent(typeof(UnityEngine.UI.Image))
    self.cardPortrait3 = transform:Find("CardPortrait3"):GetComponent(typeof(UnityEngine.UI.Image))
    self.cardPortrait4 = transform:Find("CardPortrait4"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 卡牌的名字
    self.cardNameLabel = transform:Find("CardName"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 卡牌对应的图标
    self.cardNameIcon = transform:Find("CardNameIcon/Image"):GetComponent(typeof(UnityEngine.UI.Image))
end

local function SendActivateBattleUIEvents(self, active)
    self:DispatchEvent(messageGuids.BattleActivateSystemButtonList, nil, active)
    self:DispatchEvent(messageGuids.BattleActivateTopInformation, nil, active)
    self:DispatchEvent(messageGuids.BattleActivateRightProgress, nil, active)
end

local function OnShowSkillPortraitEffect(self, unit)
    SendActivateBattleUIEvents(self, false)

    self.cardNameLabel.text = (unit:GetStaticInfo())

	utility.LoadRoleNameIcon(unit:GetId(), self.cardNameIcon)
	self.cardNameIcon:SetNativeSize()
	
    utility.LoadBattlePortraitImage(unit:GetId(), self.cardPortrait1)
	utility.LoadBattlePortraitImage(unit:GetId(), self.cardPortrait2)
	utility.LoadBattlePortraitImage(unit:GetId(), self.cardPortrait3)
	utility.LoadBattlePortraitImage(unit:GetId(), self.cardPortrait4)

    self.BaseImg.color = require "Utils.GameTools".GetMajorAttrColor(unit:GetMajorAttr())

    self:ActiveComponent()
    self.rootAnimator:Play("chuxian", 0, 0)
    self.rootAnimator:Update(0)
    local audioManager = self:GetAudioManager()
    audioManager:PlaySE(17)
end

local function OnHideSkillPortraitEffect(self, unit)
    SendActivateBattleUIEvents(self, true)
    self.rootAnimator:Play("chuxian", 0, 0)
    self.rootAnimator:Update(0)
    self:InactiveComponent()
end

function BattleSkillEffectNode:Ctor(transform)
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
    self:InactiveComponent()
    SendActivateBattleUIEvents(self, true)
end

function BattleSkillEffectNode:OnResume()
    local messageGuids = require "Framework.Business.MessageGuids"
    self:RegisterEvent(messageGuids.BattleShowSkillPortraitEffect, OnShowSkillPortraitEffect, nil)
    self:RegisterEvent(messageGuids.BattleHideSkillPortraitEffect, OnHideSkillPortraitEffect, nil)
end

function BattleSkillEffectNode:OnPause()

    local messageGuids = require "Framework.Business.MessageGuids"
    self:UnregisterEvent(messageGuids.BattleShowSkillPortraitEffect, OnShowSkillPortraitEffect, nil)
    self:UnregisterEvent(messageGuids.BattleHideSkillPortraitEffect, OnHideSkillPortraitEffect, nil)
end

return BattleSkillEffectNode
