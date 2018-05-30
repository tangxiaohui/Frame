--
-- User: fenghao
-- Date: 5/16/17
-- Time: 8:44 PM
--

-- 到 镜头转向的Transition
local TransitionClass = require "Framework.FSM.Transition"

local PlayShowOff2PlayShowOffCameraPathTransition = Class(TransitionClass)

function PlayShowOff2PlayShowOffCameraPathTransition:Ctor()
end

function PlayShowOff2PlayShowOffCameraPathTransition:IsTriggered(_, data)
    return data.isPlayerShowOffCameraPath == true
end

function PlayShowOff2PlayShowOffCameraPathTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.PlayerShowOffCameraPathState")
end

-- 到 结束战斗状态 Transition
local PlayShowOff2BattleEndTransition = Class(TransitionClass)

function PlayShowOff2BattleEndTransition:Ctor()
end

function PlayShowOff2BattleEndTransition:IsTriggered(_, data)
    return data.needToEndBattle == true
end

function PlayShowOff2BattleEndTransition:GetTargetState(_, data)
    return data.BattleFlowStatePool:Get(require "Battle.BattleFlow.BattleEndState")
end

-- 人物准备动作时的 状态
-- 等待人物播放完 show off

local StateClass = require "Framework.FSM.State"

local unityUtils = require "Utils.Unity"

local PlayShowOffState = Class(StateClass)

function PlayShowOffState:Ctor()
    self:AddTransition(PlayShowOff2PlayShowOffCameraPathTransition.New())
    self:AddTransition(PlayShowOff2BattleEndTransition.New())
end

local effectRoot
local function GetEffectRoot()
    if effectRoot == nil then
        effectRoot = unityUtils:GetTransformByObjectName("EffectRoot")
    end
    return effectRoot
end

local function CollectEffect(effect)
    coroutine.wait(5)
    local EffectPool = ResCtrl.EffectPool
    effect:SetActive(false)
    EffectPool.Instance():Push(40, effect)
end

local function ShowRole(unit, effect)
    coroutine.wait(0.5)
    unit:OnShowRole()
    coroutine.start(CollectEffect, effect)
end

local function DelayShowRole(unit, i)
--    print("DelayShowRole!")
    coroutine.wait(i * 0.3)
    local EffectPool = ResCtrl.EffectPool
    local effect = EffectPool.Instance():Pop(40)
    local gameObject = unit:GetGameObject()
    effect.transform:SetParent(GetEffectRoot())
    effect.transform.localPosition = gameObject.transform.localPosition
    effect.transform.localRotation = gameObject.transform.localRotation
    coroutine.start(ShowRole, unit, effect)
end

local function DelayWait(count, data)
    coroutine.wait(count * 0.3 + 0.5 + 2)
    data.isPlayerShowOffCameraPath = true
end

function PlayShowOffState:Enter(owner, data)
    print("PlayShowOffState:Enter >>>>>>")

    local battlefield = owner:GetBattlefield()

    -- @ 创建人物, 显示人物 --
    battlefield:SetupRight(function()

        local members = battlefield:GetRightTeam():GetMembers()
        local index = 0
        local max = table.maxn(members)
--        print(max)
        for i = 1, max do
            local unit = members[i]
            if unit ~= nil then
                index = index + 1
                coroutine.start(DelayShowRole, unit, index)
            end
        end

        coroutine.start(DelayWait, index, data)
    end)
end

function PlayShowOffState:Update(owner, data)
end

function PlayShowOffState:Exit(_, data)
    print("PlayShowOffState:Exit >>>>>>")


    data.isPlayerShowOffCameraPath = nil
end

return PlayShowOffState