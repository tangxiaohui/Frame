--
-- User: fenghao
-- Date: 6/2/17
-- Time: 10:30 PM
--

-- 到 战斗准备开始 的转换
local TransitionClass = require "Framework.FSM.Transition"

local WaveStartShowOff2PlayScriptTransition = Class(TransitionClass)

function WaveStartShowOff2PlayScriptTransition:Ctor()
end

function WaveStartShowOff2PlayScriptTransition:IsTriggered(_, data)
    return data.needToPlayScript == true
end

function WaveStartShowOff2PlayScriptTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.PlayScriptState")
end

-- 到 战斗结束的 转换
local WaveStartShowOff2BattleEndTransition = Class(TransitionClass)

function WaveStartShowOff2BattleEndTransition:Ctor()
end

function WaveStartShowOff2BattleEndTransition:IsTriggered(_, data)
    return data.needToEndBattle == true
end

function WaveStartShowOff2BattleEndTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.BattleEndState")
end


-- 波次开始前的ShowOff(目前用于敌人显示)
local StateClass = require "Framework.FSM.State"

local unityUtils = require "Utils.Unity"

local utility = require "Utils.Utility"

local WaveStartShowOffState = Class(StateClass)

-- Effect表里的ID, PVP和非PVP模式所使用的出场特效不一样.
local function GetEffectId(owner)
    if owner:IsPVPMode() then
        return 40
    else
        return 120
    end
end


local effectRoot
local function GetEffectRoot()
    if effectRoot == nil then
        effectRoot = unityUtils:GetTransformByObjectName("EffectRoot")
    end
    return effectRoot
end

local function CollectEffect(effect, owner)
    coroutine.wait(5)
    local EffectPool = ResCtrl.EffectPool
    effect:SetActive(false)
    EffectPool.Instance():Push(GetEffectId(owner), effect)
end

local function ShowRole(unit, effect, owner)
    coroutine.wait(0.25)
    unit:OnShowRole()
    coroutine.start(CollectEffect, effect, owner)
end

local function DelayShowRole(unit, i, owner)
    coroutine.wait(i * 0.2)
    local EffectPool = ResCtrl.EffectPool
    local effect = EffectPool.Instance():Pop(GetEffectId(owner))
    local gameObject = unit:GetGameObject()
    effect.transform:SetParent(GetEffectRoot())
    effect.transform.localPosition = gameObject.transform.localPosition
    effect.transform.localRotation = gameObject.transform.localRotation
    coroutine.start(ShowRole, unit, effect, owner)
end

local function DelayWait(_unitsToWait_, count, data)

    -- 等待它显示出来 --
    coroutine.wait(count * 0.3 + 0.1)

    -- 等待所有的人物都回到 Breath 状态 -- 
    repeat
        coroutine.step(1)

        for i = #_unitsToWait_, 1, -1 do
            if _unitsToWait_[i]:IsBreathState() then
                --print(_unitsToWait_[i]:GetGameObject().name, "Ready!")
                _unitsToWait_[i] = _unitsToWait_[#_unitsToWait_]
                _unitsToWait_[#_unitsToWait_] = nil
            end
        end
    until(#_unitsToWait_ == 0)

    data.needToPlayScript = true
end

function WaveStartShowOffState:Ctor()
    self:AddTransition(WaveStartShowOff2PlayScriptTransition.New())
    self:AddTransition(WaveStartShowOff2BattleEndTransition.New())
end

local _unitsToWait_ = {}
function WaveStartShowOffState:Enter(owner, data)
    print("WaveStartShowOffState:Enter >>>>>")

    local battlefield = owner:GetBattlefield()

    local members = battlefield:GetLeftTeam():GetMembers()
    local index = 0
    local max = table.maxn(members)

    utility.ClearArrayTableContent(_unitsToWait_)

    for i = 1, max do
        local unit = members[i]
        if unit ~= nil then
            index = index + 1
            _unitsToWait_[#_unitsToWait_ + 1] = unit
            coroutine.start(DelayShowRole, unit, index, owner)
        end
    end

    coroutine.start(DelayWait, _unitsToWait_, index, data)

end

function WaveStartShowOffState:Update(owner, data)
end

function WaveStartShowOffState:Exit(owner, data)
    print("WaveStartShowOffState:Exit >>>>>")
    data.needToPlayScript = nil
end

return WaveStartShowOffState