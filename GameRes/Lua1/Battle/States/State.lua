
require "Object.LuaObject"
require "Const"
local BattleStateActionUtils = require "Utils.BattleStateActionUtils"

local State = Class(LuaObject)

function State:Ctor(staticData, owner)
    self.staticData = staticData
    self.id = self.staticData:GetId()       -- state id --
    self.owner = owner                      -- BattleUnit --
    self.goEffect = nil
    self:ResetPassedTurns()
end

-- 显示buff的特效 --
local function CreateEffect(self)
    local effectId = self.staticData:GetEffect()
    if effectId > 0 then
        local goEffect = ResCtrl.EffectPool.Instance():Pop(effectId)
        if goEffect ~= nil then
            self.goEffect = goEffect
            local transform = self.goEffect.transform
            transform:SetParent(self.owner:GetHitTransform(self.staticData:GetEffectParentName()), true)
            transform.localPosition = Vector3.New(0, 0, 0)
            transform.localScale = Vector3.New(1, 1, 1)
            transform.localRotation = Quaternion.identity

            self.effectAnimator = self.goEffect:GetComponent(typeof(UnityEngine.Animator))
        end
    end
end

-- 关闭buff的特效 --
local function DestroyEffect(self)
    local effectId = self.staticData:GetEffect()
    if effectId > 0 and self.goEffect ~= nil then
        -- debug_print("@@@ effect", self.goEffect.name)
        UnityEngine.Object.Destroy(self.goEffect)
        self.goEffect = nil
        self.effectAnimator = nil
    end
end

local function OnStateVisibleChanged(self, visible)
    if visible then
        if self.effectAnimator ~= nil then
            self.effectAnimator:Play("Start", 0, 0)
        end
    else
        if self.effectAnimator ~= nil then
            self.effectAnimator:Play("Empty", 0, 0)
        end
    end
end

function State:Setup()
    -- 开始显示图标 & 特效 --
    self.owner:AddBuffForUI(self.id, self.staticData:GetIcon())
    CreateEffect(self)
end

function State:Close()
    -- 开始删除图标 & 特效 --
    self.owner:RemoveBuffForUI(self.id)
    DestroyEffect(self)
end

-- 设置与默认值不同的回合数 --
function State:SetTurns(turns)
    self.turns = turns
end

function State:GetTurns()
    if type(self.turns) == "number" then
        return self.turns
    end
    return self.staticData:GetDefaultTurns()
end

function State:ResetPassedTurns()
    self.passedTurns = -1
end

function State:ConsumeTurn()
    -- debug_print("@@@ Consume Turn @@@", self.owner:GetGameObject().name, self.passedTurns, self.passedTurns+1)
    self.passedTurns = self.passedTurns + 1
end

function State:IsForever()
    return self:GetTurns() <= 0
end

function State:IsGone()
    if self:IsForever() then
        return false
    end
    return self.passedTurns >= self:GetTurns()
end

function State:AddSources(sources)
    -- 添加打击源 --
end

function State:GetPriority()
    return self.staticData:GetPriority()
end

function State:GetId()
    return self.id
end

-- # BattleUnit # --
function State:GetOwner()
    return self.owner
end

function State:GetTraitMaps()
    return self.staticData:GetTraitMaps()
end

function State:GetActionMaps()
    return self.staticData:GetActionMaps()
end

function State:Execute(phase)
    BattleStateActionUtils.Execute(self, phase)
end

function State:SetVisible(visible)
    if self.goEffect ~= nil then
        self.goEffect:SetActive(visible)
        OnStateVisibleChanged(self, visible)
    end
end

return State
