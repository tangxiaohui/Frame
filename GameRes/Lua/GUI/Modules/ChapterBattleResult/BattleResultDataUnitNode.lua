--
-- User: fenghao
-- Date: 30/06/2017
-- Time: 8:30 AM
--

local BaseNodeClass = require "Framework.Base.Node"
local BattleResultDataUnitNode = Class(BaseNodeClass)
local utility = require "Utils.Utility"

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- icon
    self.headIcon = transform:Find("Base/HeadIcon"):GetComponent(typeof(UnityEngine.UI.Image))

    -- name
    self.nameLabel = transform:Find("CardNameLabel"):GetComponent(typeof(UnityEngine.UI.Text))

    -- damage
    self.damageLabel = transform:Find("DamageLabel"):GetComponent(typeof(UnityEngine.UI.Text))

    -- fill
    self.fillImage = transform:Find("Bar/Fill"):GetComponent(typeof(UnityEngine.UI.Image))

end

function BattleResultDataUnitNode:Ctor(transform)
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

function BattleResultDataUnitNode:OnResume()

end

function BattleResultDataUnitNode:OnPause()

end

function BattleResultDataUnitNode:Show(battleUnit, damageValue, maxDamageValue)
    damageValue = math.floor(damageValue or 0)

    -- 头像 --
    utility.LoadRoleHeadIcon(battleUnit:GetId(), self.headIcon)

    -- 姓名 --
    self.nameLabel.text = (battleUnit:GetStaticInfo())

    -- 伤害值 --
    self.damageLabel.text = damageValue

    -- 比值 --
    self.fillImage.fillAmount = damageValue / maxDamageValue

    self:ActiveComponent()
end

function BattleResultDataUnitNode:Close()
    self.nameLabel.text = ""
    self.damageLabel.text = "0"
    self.fillImage.fillAmount = 0

    self:InactiveComponent()
end

return BattleResultDataUnitNode
