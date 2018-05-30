--
-- User: fenghao
-- Date: 23/06/2017
-- Time: 4:06 PM
--

local NodeClass = require "Framework.Base.UINode"

local BattleUnitActionItem = Class(NodeClass)

local utility = require "Utils.Utility"

local AtlasesLoader = require "Utils.AtlasesLoader"

local function InitControls(self)
    local transform = self:GetUnityTransform()

    self.originalLocalPosition = transform.localPosition

    -- 头像
    self.headIcon = transform:Find("Base/Image"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 敌方/右方 --
    self.sideIcon = transform:Find("Image"):GetComponent(typeof(UnityEngine.UI.Image))
end

function BattleUnitActionItem:Ctor(transform, startRatio, endRatio)
    self.startRatio = startRatio
    self.endRatio = endRatio
    self.unit = nil
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

function BattleUnitActionItem:GetStartRatio()
    return self.startRatio
end

function BattleUnitActionItem:GetEndRatio()
    return self.endRatio
end

function BattleUnitActionItem:GetLocalPositionX()
    local transform = self:GetUnityTransform()
    return transform.localPosition.x
end

function BattleUnitActionItem:SetLocalPositionX(x)
    local transform = self:GetUnityTransform()
    local pos = transform.localPosition
    pos.x = x
    transform.localPosition = pos
end

function BattleUnitActionItem:GetLocalPositionY()
    local transform = self:GetUnityTransform()
    return transform.localPosition.y
end

function BattleUnitActionItem:SetLocalPositionY(y)
    local transform = self:GetUnityTransform()
    local pos = transform.localPosition
    pos.y = y
    transform.localPosition = pos
end

function BattleUnitActionItem:GetLocalPosition()
    local transform = self:GetUnityTransform()
    return transform.localPosition
end

function BattleUnitActionItem:SetLocalPosition(pos)
    local transform = self:GetUnityTransform()
    transform.localPosition = pos
end

local function LoadHeadIcon(self)
    utility.LoadRoleHeadIcon(self.unit:GetId(), self.headIcon)
end

local function LoadSideIcon(self)
    local iconName
    if self.unit:OnGetSide() == 1 then
        iconName = "BlueCircle"
    else
        iconName = "RedCircle"
    end
    utility.LoadAtlasesSprite("Fighting",iconName,self.sideIcon)
end

function BattleUnitActionItem:SetData(unit)
    -- # 1. 设置数据 # --
    self.unit = unit

    -- # 2. 设置卡牌头像 # --
    LoadHeadIcon(self)

    -- # 3. 加载side图标 # --
    LoadSideIcon(self)

    -- # 3. 显示 # --
    self:ActiveComponent()

end

function BattleUnitActionItem:Clear()
    self.unit = nil
    self.headIcon.sprite = nil
    self.sideIcon.sprite = nil
    self:InactiveComponent()
    self:SetLocalPosition(self.originalLocalPosition)
end

function BattleUnitActionItem:OnResume()
    -- override
end

function BattleUnitActionItem:OnPause()
    -- override
end

return BattleUnitActionItem