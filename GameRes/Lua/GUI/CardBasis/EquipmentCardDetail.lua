--
-- User: fbmly
-- Date: 5/5/17
-- Time: 2:53 PM
--

local BaseNodeClass = require "Framework.Base.Node"

local utility = require "Utils.Utility"

local EquipmentCardDetail = Class(BaseNodeClass)

function EquipmentCardDetail:Ctor(transform)
    self:BindComponent(transform.gameObject, false)
    self:InitControls()
end

function EquipmentCardDetail:OnResume()
    EquipmentCardDetail.base.OnResume(self)
end

function EquipmentCardDetail:OnPause()
    EquipmentCardDetail.base.OnPause(self)
end

function EquipmentCardDetail:InitControls()
    local transform = self:GetUnityTransform()

    -- 进阶按钮
    self.CardRiseButton = transform:Find("EquipmentAdvancedButton"):GetComponent(typeof(UnityEngine.UI.Button))

    --- # 属性 #

    -- # 姓名
    self.heroEquipmentPropertyNameLabel = transform:Find("Property/HeroEquipmentPropertyNameLabel"):GetComponent(typeof(UnityEngine.UI.Text))

    -- # 等级
    self.heroEquipmentPropertyLvLabel = transform:Find("Property/Lv3/HeroEquipmentPropertyLvLabel"):GetComponent(typeof(UnityEngine.UI.Text))

    -- # 战斗力
    self.heroEquipmentPropertyStrengthLabel = transform:Find("Property/Strength/HeroEquipmentPropertyStrengthLabel"):GetComponent(typeof(UnityEngine.UI.Text))

    -- # 星级
    self.heroEquipmentStars = {}
    self.heroEquipmentStars[1] = transform:Find("Property/StarLayout3/HeroEquipmentPropertyStarIcon01").gameObject
    self.heroEquipmentStars[2] = transform:Find("Property/StarLayout3/HeroEquipmentPropertyStarIcon02").gameObject
    self.heroEquipmentStars[3] = transform:Find("Property/StarLayout3/HeroEquipmentPropertyStarIcon03").gameObject
    self.heroEquipmentStars[4] = transform:Find("Property/StarLayout3/HeroEquipmentPropertyStarIcon04").gameObject
    self.heroEquipmentStars[5] = transform:Find("Property/StarLayout3/HeroEquipmentPropertyStarIcon05").gameObject

    -- # 生命
    self.heroLifeLabel = transform:Find("Property/PropertyLabel/01Life/HeroPropertyLifeLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.heroLifeSlider = transform:Find("Property/PropertyLabel/01Life/Slider1"):GetComponent(typeof(UnityEngine.UI.Image))

    -- # 攻击
    self.heroAttackLabel = transform:Find("Property/PropertyLabel/02Attack/HeroPropertyAttackLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.heroAttackSlider = transform:Find("Property/PropertyLabel/02Attack/Slider2"):GetComponent(typeof(UnityEngine.UI.Image))

    -- # 防御
    self.heroDefenseLabel = transform:Find("Property/PropertyLabel/03Defense/HeroPropertyDefenseLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.heroDefenseSlider = transform:Find("Property/PropertyLabel/03Defense/Slider3"):GetComponent(typeof(UnityEngine.UI.Image))

    -- # 速度
    self.heroSpeedLabel = transform:Find("Property/PropertyLabel/04Speed/HeroPropertySpeedLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.heroSpeedSlider = transform:Find("Property/PropertyLabel/04Speed/Slider4"):GetComponent(typeof(UnityEngine.UI.Image))

    -- # 暴击
    self.heroCritLabel = transform:Find("Property/PropertyLabel/05Crit/HeroPropertyCritLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.heroCritSlider = transform:Find("Property/PropertyLabel/05Crit/Slider5"):GetComponent(typeof(UnityEngine.UI.Image))

    -- # 暴抗
    self.heroResistCritLabel = transform:Find("Property/PropertyLabel/06ResistCrit/HeroPropertyResistCritLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.heroResistCritSlider = transform:Find("Property/PropertyLabel/06ResistCrit/Slider6"):GetComponent(typeof(UnityEngine.UI.Image))

    -- # 命中
    self.heroHitRateLabel = transform:Find("Property/PropertyLabel/07HitRate/HeroPropertyHitRateLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.heroHitRateSlider = transform:Find("Property/PropertyLabel/07HitRate/Slider7"):GetComponent(typeof(UnityEngine.UI.Image))

    -- # 闪避
    self.heroDodgeLabel = transform:Find("Property/PropertyLabel/08Dodge/HeroPropertyDodgeLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.heroDodgeSlider = transform:Find("Property/PropertyLabel/08Dodge/Slider8"):GetComponent(typeof(UnityEngine.UI.Image))
end


local function HideAllStar(heroEquipmentStars)
    for i = 1, #heroEquipmentStars do
        heroEquipmentStars[i]:SetActive(false)
    end
end


function EquipmentCardDetail:SetData(heroData)

    -- Lv等级
    self.heroEquipmentPropertyLvLabel.text = heroData:GetLv()

    -- 姓名
    self.heroEquipmentPropertyNameLabel.text = (heroData:GetInfo())

    -- 战斗力
    self.heroEquipmentPropertyStrengthLabel.text = heroData:GetPower()

    -- 星级
    HideAllStar(self.heroEquipmentStars)
	
	
    -- 显示星级
    local star = math.min(5, heroData:GetStar())
    if star < 0 then
        star = 0
    end

    for i = 1, star do
        self.heroEquipmentStars[i]:SetActive(true)
    end

    local SystemConfigMgr = require "StaticData.SystemConfig.SystemConfig"

    -- 生命
    self.heroLifeLabel.text = heroData:GetHp()
    self.heroLifeSlider.fillAmount = utility.Clamp01(heroData:GetHp() / SystemConfigMgr:GetData(1001):GetParameNum()[0])

    -- 攻击
    self.heroAttackLabel.text = heroData:GetAp()
    self.heroAttackSlider.fillAmount = utility.Clamp01(heroData:GetAp() / SystemConfigMgr:GetData(1002):GetParameNum()[0])

    -- 防御
    self.heroDefenseLabel.text = heroData:GetDp()
    self.heroDefenseSlider.fillAmount = utility.Clamp01(heroData:GetDp() / SystemConfigMgr:GetData(1003):GetParameNum()[0])

    -- 速度
    self.heroSpeedLabel.text = heroData:GetSpeed()
    self.heroSpeedSlider.fillAmount = utility.Clamp01(heroData:GetSpeed() / SystemConfigMgr:GetData(1004):GetParameNum()[0])

    -- 暴击
    self.heroCritLabel.text = heroData:GetCritRate() .. "%"
    self.heroCritSlider.fillAmount = utility.Clamp01(heroData:GetCritRate() / (SystemConfigMgr:GetData(1005):GetParameNum()[0] / 100))

    -- 抗暴
    self.heroResistCritLabel.text = heroData:GetDecritRate() .. "%"
    self.heroResistCritSlider.fillAmount = utility.Clamp01(heroData:GetDecritRate() / (SystemConfigMgr:GetData(1006):GetParameNum()[0] / 100))

    -- 命中
    self.heroHitRateLabel.text = (heroData:GetHitRate() - 100) .. "%"
    self.heroHitRateSlider.fillAmount = utility.Clamp01((heroData:GetHitRate() - 100) / (SystemConfigMgr:GetData(1007):GetParameNum()[0] / 100))

    -- 闪避
    self.heroDodgeLabel.text = heroData:GetAvoidRate() .. "%"
    self.heroDodgeSlider.fillAmount = utility.Clamp01(heroData:GetAvoidRate() / (SystemConfigMgr:GetData(1008):GetParameNum()[0] / 100))

    self.cardRiseData = heroData
end

return EquipmentCardDetail