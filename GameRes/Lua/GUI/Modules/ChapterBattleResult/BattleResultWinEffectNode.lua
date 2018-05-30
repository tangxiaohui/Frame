--
-- User: fenghao
-- Date: 30/06/2017
-- Time: 12:10 AM
--

local BaseNodeClass = require "Framework.Base.Node"
local BattleResultWinEffectNode = Class(BaseNodeClass)

local function DoesItNeedToShake(star)
    return star == 3
end

local function Shake(self)
    local gameObject = self:GetParent():GetUnityGameObject()
    local cameraShakerComponent = gameObject:GetComponent(typeof(EZCameraShake.CameraShaker))
    if cameraShakerComponent == nil then
        cameraShakerComponent = gameObject:AddComponent(typeof(EZCameraShake.CameraShaker))
    end
    cameraShakerComponent:Shake(200, true)
end

local function PlayStarAnimation(self, star)
    coroutine.wait(1)

    local currentAnimator

    local realStar = math.min(star, #self.starAnimators)

    -- local useShake = DoesItNeedToShake

    for i = 1, realStar do
        currentAnimator = self.starAnimators[i]
        currentAnimator:Play("Empty")
        currentAnimator:Play("Show")
        Shake(self)
        coroutine.wait(0.3)
    end
end

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- 星星的Animator --
    self.starAnimators = {
        transform:Find("Star1"):GetComponent(typeof(UnityEngine.Animator)),
        transform:Find("Star2"):GetComponent(typeof(UnityEngine.Animator)),
        transform:Find("Star3"):GetComponent(typeof(UnityEngine.Animator))
    }
end

function BattleResultWinEffectNode:Ctor(transform)
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

function BattleResultWinEffectNode:OnResume()
end

function BattleResultWinEffectNode:OnPause()
end

function BattleResultWinEffectNode:Show(star)
    print("胜利星 >>>>", star)
    self:ActiveComponent()
    self:StartCoroutine(PlayStarAnimation, star)
end

function BattleResultWinEffectNode:Close()
    self:InactiveComponent()
    self:StopAllCoroutines()
end

return BattleResultWinEffectNode
