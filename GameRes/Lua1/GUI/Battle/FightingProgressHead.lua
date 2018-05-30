--
-- User: fbmly
-- Date: 4/25/17
-- Time: 8:43 PM
--

local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local AtlasesLoader = require "Utils.AtlasesLoader"
require "Enum"

local Side_Left = Side.Left
local Side_Right = Side.Right

local FightingProgressHead = Class(BaseNodeClass)

local function LoadSideIcon(self)
    local iconName
    if self.unit:OnGetSide() == 1 then
        iconName = "BlueCircle"
    else
        iconName = "RedCircle"
    end

	local atlasName = "Fighting"
    utility.LoadAtlasesSprite(atlasName,iconName,self.frameSprite1)
	
end

local function LoadSideSquareIcon(self)
    local iconName
    if self.unit:OnGetSide() == 1 then
        iconName = "BlueSquare"
    else
        iconName = "RedSquare"
    end

    utility.LoadAtlasesSprite("Fighting", iconName, self.frameSprite2)
end

local function UpdateView(self)
    self.unitIcon.enabled = false
    -- debug_print("@@@@@ 加载图标", self.unit:GetId())
    utility.LoadRoleHeadIcon(self.unit:GetId(), self.unitIcon)
	self.unitIcon.enabled = true

    self.deadx1image.fillAmount = 0
    self.deadx2image.fillAmount = 0
    if self.deadAnimator.isActiveAndEnabled then
        self.deadAnimator:Play("Empty", 0, 0)
    end

    LoadSideIcon(self)
    LoadSideSquareIcon(self)
end

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- 图标 --
    self.unitIcon = transform:Find("Base/FightingProgressHeadFrameIcon"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 死亡Animator --
    self.deadAnimator = transform:Find("UI_siwang"):GetComponent(typeof(UnityEngine.Animator))
    self.deadx1image = transform:Find("UI_siwang/X1"):GetComponent(typeof(UnityEngine.UI.Image))
    self.deadx2image = transform:Find("UI_siwang/X2"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 圆框 --
    self.frameSprite1 = transform:Find("FightingProgressHeadFrame"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 菱形框 --
    self.frameSprite2 = transform:Find("Image"):GetComponent(typeof(UnityEngine.UI.Image))

    -- canvas group
    self.rootCanvasGroup = transform:GetComponent(typeof(UnityEngine.CanvasGroup))
end

function FightingProgressHead:Ctor(transform)
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

function FightingProgressHead:SetData(unit)
    self.unit = unit
    UpdateView(self)
end

function FightingProgressHead:GetBattleUnit()
    return self.unit
end

function FightingProgressHead:Clear()
    self.unit = nil
    self:SetScale(1)
    self:SetAlpha(0)
    self:SetFrame2Enabled(true)

    self.deadx1image.fillAmount = 0
    self.deadx2image.fillAmount = 0
    if self.deadAnimator.isActiveAndEnabled then
        self.deadAnimator:Play("Empty", 0, 0)
    end
end

function FightingProgressHead:OnResume()

end

function FightingProgressHead:OnPause()

end

function FightingProgressHead:GetPositionX()
    local transform = self:GetUnityTransform()
    return transform.localPosition.x
end

function FightingProgressHead:SetPositionX(x)
    local transform = self:GetUnityTransform()
    local p = transform.localPosition
    p.x = x
    transform.localPosition = p
end

function FightingProgressHead:SetPosition(pos)
    local transform = self:GetUnityTransform()
    transform.localPosition = pos
end

function FightingProgressHead:GetPosition()
    local transform = self:GetUnityTransform()
    return transform.localPosition
end

function FightingProgressHead:SetAlpha(alpha)
    self.rootCanvasGroup.alpha = alpha
end

function FightingProgressHead:SetFrame2Enabled(enabled)
    self.frameSprite2.enabled = enabled
end

function FightingProgressHead:SetScale(scale)
    local transform = self:GetUnityTransform()
    transform.localScale = Vector3(scale, scale, scale)
end

function FightingProgressHead:SetBezierPathPos(pos)
    self.bezierPathPos = pos
end

function FightingProgressHead:GetBezierPathPos()
    return self.bezierPathPos
end

function FightingProgressHead:PlayDeadAnimation()
    self.deadx1image.fillAmount = 0
    self.deadx2image.fillAmount = 0
    if self.deadAnimator.isActiveAndEnabled then
        self.deadAnimator:Play("Start", 0, 0)
    else
        self.deadx1image.fillAmount = 1
        self.deadx2image.fillAmount = 1
    end
end

return FightingProgressHead
