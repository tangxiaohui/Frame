--
-- User: fenghao
-- Date: 20/06/2017
-- Time: 12:44 AM
--

local BaseNodeClass = require "Framework.Base.Node"
local HeroDetailAttributePanel = Class(BaseNodeClass)

local function OnUpdate(self)
    self.lifeLabel:Update()
    self.lifeSlider:Update()

    self.AtkLabel:Update()
    self.AtkSlider:Update()

    self.DefLabel:Update()
    self.DefSlider:Update()

    self.SpdLabel:Update()
    self.SpdSlider:Update()

    self.CrtLabel:Update()
    self.CrtSlider:Update()

    self.ResLabel:Update()
    self.ResSlider:Update()

    self.HitLabel:Update()
    self.HitSlider:Update()

    self.DodgeLabel:Update()
    self.DodgeSlider:Update()
end

-- # 三个回调函数
local function OnSetImagePercentValue(self, value, owner)
    owner.fillAmount = value
end

local function OnSetTextValue(self, value, owner)
    owner.text = utility.ToInteger(value)
end

local function OnSetTextPercentValue(self, value, owner)
    owner.text = string.format("%d%%", utility.ToInteger(value))
end

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- 战斗力 --
    self.powerLabel = transform:Find("Power/PowerLabel"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 碎片 --(GetNeedCardSuipianNum)
    self.fragmentLabel = transform:Find("FragmentNum/Label"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 碎片来源按钮
    self.fragmentSourceButton = transform:Find("FragmentNum/Button"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 种族
    self.raceLabel = transform:Find("RaceText"):GetComponent(typeof(UnityEngine.UI.Text))

    local cardStatusLayout = transform:Find("CardStatusLayout")


    local AnimatedValueControlClass = require "GUI.Controls.AnimatedValueControl"
    
    -- 生命
    self.lifeLabel = AnimatedValueControlClass.New(cardStatusLayout:Find("Life/Label"):GetComponent(typeof(UnityEngine.UI.Text)))
    self.lifeLabel:SetCallbackOnUpdate(self, OnSetTextValue)
    self.lifeSlider = AnimatedValueControlClass.New(cardStatusLayout:Find("Life/Slider"):GetComponent(typeof(UnityEngine.UI.Image)))
    self.lifeSlider:SetCallbackOnUpdate(self, OnSetImagePercentValue)

    -- 攻击
    self.AtkLabel = AnimatedValueControlClass.New(cardStatusLayout:Find("ATK/Label"):GetComponent(typeof(UnityEngine.UI.Text)))
    self.AtkLabel:SetCallbackOnUpdate(self, OnSetTextValue)
    self.AtkSlider = AnimatedValueControlClass.New(cardStatusLayout:Find("ATK/Slider"):GetComponent(typeof(UnityEngine.UI.Image)))
    self.AtkSlider:SetCallbackOnUpdate(self, OnSetImagePercentValue)

    -- 防御
    self.DefLabel = AnimatedValueControlClass.New(cardStatusLayout:Find("DEF/Label"):GetComponent(typeof(UnityEngine.UI.Text)))
    self.DefLabel:SetCallbackOnUpdate(self, OnSetTextValue)
    self.DefSlider = AnimatedValueControlClass.New(cardStatusLayout:Find("DEF/Slider"):GetComponent(typeof(UnityEngine.UI.Image)))
    self.DefSlider:SetCallbackOnUpdate(self, OnSetImagePercentValue)

    -- 速度
    self.SpdLabel = AnimatedValueControlClass.New(cardStatusLayout:Find("SPD/Label"):GetComponent(typeof(UnityEngine.UI.Text)))
    self.SpdLabel:SetCallbackOnUpdate(self, OnSetTextValue)
    self.SpdSlider = AnimatedValueControlClass.New(cardStatusLayout:Find("SPD/Slider"):GetComponent(typeof(UnityEngine.UI.Image)))
    self.SpdSlider:SetCallbackOnUpdate(self, OnSetImagePercentValue)

    -- 暴击率
    self.CrtLabel = AnimatedValueControlClass.New(cardStatusLayout:Find("CRT/Label"):GetComponent(typeof(UnityEngine.UI.Text)))
    self.CrtLabel:SetCallbackOnUpdate(self, OnSetTextPercentValue)
    self.CrtSlider = AnimatedValueControlClass.New(cardStatusLayout:Find("CRT/Slider"):GetComponent(typeof(UnityEngine.UI.Image)))
    self.CrtSlider:SetCallbackOnUpdate(self, OnSetImagePercentValue)

    -- 抗暴率
    self.ResLabel = AnimatedValueControlClass.New(cardStatusLayout:Find("RES/Label"):GetComponent(typeof(UnityEngine.UI.Text)))
    self.ResLabel:SetCallbackOnUpdate(self, OnSetTextPercentValue)
    self.ResSlider = AnimatedValueControlClass.New(cardStatusLayout:Find("RES/Slider"):GetComponent(typeof(UnityEngine.UI.Image)))
    self.ResSlider:SetCallbackOnUpdate(self, OnSetImagePercentValue)

    -- 命中率
    self.HitLabel = AnimatedValueControlClass.New(cardStatusLayout:Find("HIT/Label"):GetComponent(typeof(UnityEngine.UI.Text)))
    self.HitLabel:SetCallbackOnUpdate(self, OnSetTextPercentValue)
    self.HitSlider = AnimatedValueControlClass.New(cardStatusLayout:Find("HIT/Slider"):GetComponent(typeof(UnityEngine.UI.Image)))
    self.HitSlider:SetCallbackOnUpdate(self, OnSetImagePercentValue)

    -- 闪避率
    self.DodgeLabel = AnimatedValueControlClass.New(cardStatusLayout:Find("DODGE/Label"):GetComponent(typeof(UnityEngine.UI.Text)))
    self.DodgeLabel:SetCallbackOnUpdate(self, OnSetTextPercentValue)
    self.DodgeSlider = AnimatedValueControlClass.New(cardStatusLayout:Find("DODGE/Slider"):GetComponent(typeof(UnityEngine.UI.Image)))
    self.DodgeSlider:SetCallbackOnUpdate(self, OnSetImagePercentValue)

    -- Update --
    self:ScheduleUpdate(OnUpdate)
end
function HeroDetailAttributePanel:SetHeroID(heroId)
    debug_print("HeroDetailAttributePanel:SetHeroID(heroId)",heroId)
    self.heroId=heroId
end
local function OnFragmentSourceButtonClicked(self)

    local utility = require "Utils.Utility"
    if self.heroId ~= nil then
        local roleMgr = require "StaticData.Role"
        self.data = roleMgr:GetData(self.heroId)       
        utility.ShowSourceWin( self.data:GetScrapId())
    elseif self.userRoleData ~= nil then
       utility.ShowSourceWin(self.userRoleData:GetScrapId())
    end
end

function HeroDetailAttributePanel:Ctor(transform)
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

function HeroDetailAttributePanel:OnResume()
    HeroDetailAttributePanel.base.OnResume(self)

    -- 注册 查看碎片获取源的按钮 --
    self.__event_fragmentSourceButtonClicked__ = UnityEngine.Events.UnityAction(OnFragmentSourceButtonClicked, self)
    self.fragmentSourceButton.onClick:AddListener(self.__event_fragmentSourceButtonClicked__)
end

function HeroDetailAttributePanel:OnPause()
    HeroDetailAttributePanel.base.OnPause(self)

    -- 取消注册 查看碎片获取源的按钮 --
    if self.__event_fragmentSourceButtonClicked__ then
        self.fragmentSourceButton.onClick:RemoveListener(self.__event_fragmentSourceButtonClicked__)
        self.__event_fragmentSourceButtonClicked__ = nil
    end
end

function HeroDetailAttributePanel:Refresh(userRoleData)
    debug_print("    userRoleData",userRoleData);
    self.userRoleData = nil

	local UserDataType = require "Framework.UserDataType"

    -- 战斗力的更新 --
    self.powerLabel.text = userRoleData:GetPower()

    -- 碎片 --
    local fragmentBagData = self:GetCachedData(UserDataType.CardChipBagData)
    local currentFragments = fragmentBagData:GetCardChipCount(userRoleData:GetScrapId())
    local needFragments = userRoleData:GetNeedCardSuipianNum()
    if needFragments == nil then
        self.fragmentLabel.text = currentFragments
    else
        self.fragmentLabel.text = string.format("%d/%d", currentFragments, needFragments)
    end

    -- 种族 --
    local _, raceName = userRoleData:GetRace()
    self.raceLabel.text = raceName

    -->>> 更新属性值 <<<--
    local SystemConfigMgr = require "StaticData.SystemConfig.SystemConfig"
    local utility = require "Utils.Utility"

    --- 生命 ---
    self.lifeLabel:SetValue(userRoleData:GetHp())
    self.lifeSlider:SetValue(utility.Clamp01(userRoleData:GetHp() / SystemConfigMgr:GetData(1001):GetParameNum()[0]))

    --- 攻击 ---
    self.AtkLabel:SetValue(userRoleData:GetAp())
    self.AtkSlider:SetValue(utility.Clamp01(userRoleData:GetAp() / SystemConfigMgr:GetData(1002):GetParameNum()[0]))

    --- 防御 ---
    self.DefLabel:SetValue(userRoleData:GetDp())
    self.DefSlider:SetValue(utility.Clamp01(userRoleData:GetDp() / SystemConfigMgr:GetData(1003):GetParameNum()[0]))

    --- 速度 ---
    self.SpdLabel:SetValue(userRoleData:GetSpeed())
    self.SpdSlider:SetValue(utility.Clamp01(userRoleData:GetSpeed() / SystemConfigMgr:GetData(1004):GetParameNum()[0]))

    --- 暴击率 ---
    self.CrtLabel:SetValue(userRoleData:GetCritRate())
    self.CrtSlider:SetValue(utility.Clamp01(userRoleData:GetCritRate() / (SystemConfigMgr:GetData(1005):GetParameNum()[0] / 100)))

    --- 抗暴率 ---
    self.ResLabel:SetValue(userRoleData:GetDecritRate())
    self.ResSlider:SetValue(utility.Clamp01(userRoleData:GetDecritRate() / (SystemConfigMgr:GetData(1006):GetParameNum()[0] / 100)))

    --- 命中率 ---
    self.HitLabel:SetValue(userRoleData:GetHitRate())
    self.HitSlider:SetValue(utility.Clamp01((userRoleData:GetHitRate()) / (SystemConfigMgr:GetData(1007):GetParameNum()[0] / 100)))

    --- 闪避率 ---
    self.DodgeLabel:SetValue(userRoleData:GetAvoidRate())
    self.DodgeSlider:SetValue(utility.Clamp01(userRoleData:GetAvoidRate() / (SystemConfigMgr:GetData(1008):GetParameNum()[0] / 100)))

    -- 存到self中
    self.userRoleData = userRoleData
end

return HeroDetailAttributePanel