--
-- User: fenghao
-- Date: 20/06/2017
-- Time: 4:36 PM
--

local BaseNodeClass = require "Framework.Base.Node"
local HeroDetailEquipmentPanel = Class(BaseNodeClass)

local TweenUtility = require "Utils.TweenUtility"

local MainEquipment = 1
local SecondaryEquipment = 2

local function GetPosition(startPos, endPos, ratio)
    local x = TweenUtility.EaseOutBack(startPos.x, endPos.x, ratio)
    local y = TweenUtility.EaseOutBack(startPos.y, endPos.y, ratio)
    return Vector3.New(x, y, 0)
end

local function GetStartEndParameters(self, mode)
    if mode == MainEquipment then
        return self.originalWearingLayout1Position, self.originalWearingLayout2Position
    else
        return self.originalWearingLayout2Position, self.originalWearingLayout1Position
    end
end

local function SwitchMode(mode)
    if mode == MainEquipment then
        return SecondaryEquipment
    else
        return MainEquipment
    end
end

local function SwitchTransform(self, mode)
    if mode == MainEquipment then
        self.wearingLayout1:SetAsLastSibling()
        self.wearingLayout2:SetAsFirstSibling()
    else
        self.wearingLayout2:SetAsLastSibling()
        self.wearingLayout1:SetAsFirstSibling()
    end
end

-- 立即切换模式
local function SetModeImmediate(self, targetMode)
    if self.mode ~= targetMode then
        local startPosition, endPosition = GetStartEndParameters(self, targetMode)
        self.wearingLayout1.localPosition = GetPosition(startPosition, endPosition, 0)
        self.wearingLayout2.localPosition = GetPosition(endPosition, startPosition, 0)
        self.mode = targetMode
        SwitchTransform(self, self.mode)
    end
end

local function OnSwitchAnimation(self)
    local startPosition, endPosition = GetStartEndParameters(self, self.mode)
    local passedTime = 0
    local totalTime = 0.2
    local finished = false

    self.canvasGroup1.interactable = false
    self.canvasGroup2.interactable = false

    repeat
        local t = passedTime / totalTime
        if t >= 1 then
            t = 1
            finished = true
        end

        self.wearingLayout1.localPosition = GetPosition(startPosition, endPosition, t)
        self.wearingLayout2.localPosition = GetPosition(endPosition, startPosition, t)

        passedTime = passedTime + UnityEngine.Time.unscaledDeltaTime

        coroutine.step(1)
    until(finished == true)

    self.mode = SwitchMode(self.mode)
    SwitchTransform(self, self.mode)
    self.coSwitchAnim = nil
    self.isSwitching = false

    self.canvasGroup1.interactable = true
    self.canvasGroup2.interactable = true
end

local function InitControls(self)
    local transform = self:GetUnityTransform()

    self.mode = MainEquipment
    self.wearingLayout1 = transform:Find("WearingLayout1")
    self.wearingLayout2 = transform:Find("WearingLayout2")

    self.canvasGroup1 = self.wearingLayout1:GetComponent(typeof(UnityEngine.CanvasGroup))
    self.canvasGroup2 = self.wearingLayout2:GetComponent(typeof(UnityEngine.CanvasGroup))

    self.SwitchButton = transform:Find("SwitchButton"):GetComponent(typeof(UnityEngine.UI.Button))

    self.originalWearingLayout1Position = self.wearingLayout1.localPosition
    self.originalWearingLayout2Position = self.wearingLayout2.localPosition

    local EquipmentSlotClass = require "GUI.Hero.HeroEquipmentSlot"

    self.equipments = {
        -- group 1
        EquipmentSlotClass.New(1,  self.wearingLayout1:Find("EquipmentSlot1")),
        EquipmentSlotClass.New(2,  self.wearingLayout1:Find("EquipmentSlot2")),
        EquipmentSlotClass.New(3,  self.wearingLayout1:Find("EquipmentSlot3")),
        EquipmentSlotClass.New(4,  self.wearingLayout1:Find("EquipmentSlot4")),
        EquipmentSlotClass.New(5,  self.wearingLayout1:Find("EquipmentSlot5")),

        -- group 2
        EquipmentSlotClass.New(6,  self.wearingLayout2:Find("EquipmentSlot1")),
        EquipmentSlotClass.New(7,  self.wearingLayout2:Find("EquipmentSlot2")),
        -- EquipmentSlotClass.New(8,  self.wearingLayout2:Find("EquipmentSlot3")),
        -- EquipmentSlotClass.New(9,  self.wearingLayout2:Find("EquipmentSlot4")),
        EquipmentSlotClass.New(10, self.wearingLayout2:Find("EquipmentSlot5"))
    }

    for i = 1, #self.equipments do
        self:AddChild(self.equipments[i])
    end

    -- 战斗力 --
    self.powerLabel = transform:Find("Power/PowerLabel"):GetComponent(typeof(UnityEngine.UI.Text))
end

local function OnSwitchButtonClicked(self)
    if self.isSwitching then
        return
    end

    self.isSwitching = true
    self.coSwitchAnim = self:StartCoroutine(OnSwitchAnimation)
end

local function OnRoleEquipChanged(self, cardID, itemUID, toPos)
    if self.currentRoleData == nil or self.currentRoleData:GetId() ~= cardID then
        return
    end
    --hzj_print("更换装备", cardID, itemUID, toPos)
    self.equipments[toPos]:SetEquipment(itemUID)
	
	-- # 更新其他槽位状态 # --
	local slotCount = math.min(self.currentRoleData:GetEquipmentSlotCount(), #self.equipments)
	for i = 1, slotCount do
		self.equipments[i]:UpdateStatus()
	end
end

function HeroDetailEquipmentPanel:Ctor(transform)
    self.isSwitching = false
    self.coSwitchAnim = nil
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

function HeroDetailEquipmentPanel:LocalRedDotChanged()
     for i = 1, #self.equipments do
       -- hzj_print("******************",i)
        self.equipments[i]:SetRedDot()
    end


end
function HeroDetailEquipmentPanel:OnResume()
    HeroDetailEquipmentPanel.base.OnResume(self)

    self.__event_button_SwitchButtonClicked__ = UnityEngine.Events.UnityAction(OnSwitchButtonClicked, self)
    self.SwitchButton.onClick:AddListener(self.__event_button_SwitchButtonClicked__)

    local messageGuids = require "Framework.Business.MessageGuids"
    self:RegisterEvent(messageGuids.EquipChanged, OnRoleEquipChanged, nil)
    self:RegisterEvent(messageGuids.LocalRedDotChanged, self.LocalRedDotChanged)
    self:LocalRedDotChanged()
end

function HeroDetailEquipmentPanel:OnPause()
    HeroDetailEquipmentPanel.base.OnPause(self)

    if self.__event_button_SwitchButtonClicked__ then
        self.SwitchButton.onClick:RemoveListener(self.__event_button_SwitchButtonClicked__)
        self.__event_button_SwitchButtonClicked__ = nil
    end

    local messageGuids = require "Framework.Business.MessageGuids"
    self:UnregisterEvent(messageGuids.EquipChanged, OnRoleEquipChanged, nil)
    self:UnregisterEvent(messageGuids.LocalRedDotChanged, self.LocalRedDotChanged)

    self.isSwitching = false
    if self.coSwitchAnim ~= nil then
        coroutine.stop(self.coSwitchAnim)
        self.coSwitchAnim = nil
    end
end

function HeroDetailEquipmentPanel:Refresh(userRoleData)
	SetModeImmediate(self, MainEquipment)
	local slotCount = math.min(userRoleData:GetEquipmentSlotCount(), #self.equipments)
	local UserDataType = require "Framework.UserDataType"
	local equipBagData = self:GetCachedData(UserDataType.EquipBagData)
	local equipmentDict = equipBagData:GetOneCardEquipsByUid(userRoleData:GetUid())




	self.powerLabel.text = userRoleData:GetPower()
	self.currentRoleData = userRoleData
	
	for i = 1, slotCount do
		local equipType = userRoleData:GetEquipmentTypeByPos(i)
       -- hzj_print(equipType,"equipType");
		self.equipments[i]:SetType(equipType)
		self.equipments[i]:SetOwner(userRoleData)
		self.equipments[i]:Reset()
		self.equipments[i]:SetEquipment(equipmentDict:GetEntryByKey(self.equipments[i]:GetPos()))
		self.equipments[i]:UpdateStatus()
	end
end


return HeroDetailEquipmentPanel
