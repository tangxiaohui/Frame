
require "Object.LuaObject"
require "Collection.OrderedDictionary"
require "Const"
local BattleStateTraitUtils = require "Utils.BattleStateTraitUtils"

local StateManager = Class(LuaComponent)

function StateManager:Ctor()
    -- # 存放所有状态 # --
    self.states = OrderedDictionary.New()

    -- # 存放黑名单 # --
    local StateBlackListClass = require "Battle.States.StateBlackList"
    self.blackList = StateBlackListClass.New()

    -- # 禁用列表(仅 id => true) # --
    self.disabledStateMaps = {}

    -- # 控制显示状态 # --
    self.isVisible = false
end

local function IsVisible(self)
    return self.isVisible
end

local function SetVisible(self, visible)
    if self.isVisible ~= visible then
        self.isVisible = visible

        -- 循环设置 --
        local count = self.states:Count()
        for i = 1, count do
            local state = self.states:GetEntryByIndex(i)
            if state ~= nil then
                state:SetVisible(visible)
            end
        end
    end
end

-- function StateManager:Remove(id)
--     local currentState = self.states:GetEntryByKey(id)
--     if currentState ~= nil then
--         RemoveFromBlackList(self, currentState)
--         currentState:Close()
--         self.states:Remove(id)
--         return true
--     end
--     return false
-- end


-- # 私有函数 # --
local function GetTotalRate(self, func)
    local count = self.states:Count()
    local rate = 0
    for i = 1, count do
        local state = self.states:GetEntryByIndex(i)
        if state ~= nil then
            rate = rate + func(state)
        end
    end
    return rate
end

local function HasAny(self, func)
    local count = self.states:Count()
    for i = 1, count do
        local state = self.states:GetEntryByIndex(i)
        if state ~= nil and func(state) then
            return true
        end
    end
    return false
end


local function GetNewState(self, staticData)
    local StateClass = require "Battle.States.State"
    return StateClass.New(staticData, self.luaGameObject)
end

local function AddToBlackList(self, state)
    local entryList = BattleStateTraitUtils.GetRejectList(state)
    if entryList ~= nil then
        local count = entryList:Count()
        local entry
        local stateId
        for i = 1, count do
            entry = entryList:GetEntry(i)
            stateId = entry:GetParam1()
            if type(stateId) == "number" and stateId > 0 then
                self.blackList:Add(stateId)
                self:Remove(stateId)
            end
        end
    end
end

local function RemoveFromBlackList(self, state)
    local entryList = BattleStateTraitUtils.GetRejectList(state)
    if entryList ~= nil then
        local count = entryList:Count()
        local entry
        local stateId
        for i = 1, count do
            entry = entryList:GetEntry(i)
            stateId = entry:GetParam1()
            if type(stateId) == "number" and stateId > 0 then
                self.blackList:Remove(stateId)
            end
        end
    end
end

local function IsInStateBlackList(self, id)
    return self.blackList:Contains(id)
end

local function IsInDisabledList(self, id)
    return self.disabledStateMaps[id] ~= nil
end

local function IsRejectedTheState(self, id)
    return IsInDisabledList(self, id) or IsInStateBlackList(self, id)
end

local function HandleCounteractState(self, staticData)
    local entryList = BattleStateTraitUtils.GetCounteractList(staticData)
    local found = false
    if entryList ~= nil then
        local count = entryList:Count()
        local entry
        local stateId
        for i = 1, count do
            entry = entryList:GetEntry(i)
            stateId = entry:GetParam1()
            if type(stateId) == "number" and stateId > 0 then
                local res = self:Remove(stateId)
                found = found or res
            end
        end
    end
    return found
end

function StateManager:Add(id, sources, overrideTurns) 

    -- # 是否禁止加入当前状态 (当前人物禁用, 当前状态禁用) # --
    if IsRejectedTheState(self, id) then
        return false
    end

    local currentState = self.states:GetEntryByKey(id)
    
    -- # 再上了一次buff, 应该叠加 # --
    if currentState ~= nil then
        currentState:ResetPassedTurns()
        currentState:AddSources(sources)
        return true
    end

    -- # 获取静态数据 # --
    local stateDataMgr = require "StaticData.State.State"
    local staticData = stateDataMgr:GetData(id)

    -- # 处理抵消状态 # --
    if HandleCounteractState(self, staticData) then
        print(string.format("counteract!!! id = %d", id))
        return false
    end

    -- # 创建新的状态 # --
    currentState = GetNewState(self, staticData)
    AddToBlackList(self, currentState)
    currentState:AddSources(sources)
    currentState:SetTurns(overrideTurns)
    currentState:Setup()
    currentState:SetVisible(IsVisible(self))
    self.states:Add(id, currentState)

    return true
end

local function CloseState(self, state)
    RemoveFromBlackList(self, state)
    state:Close()
end

function StateManager:Clear()
    local count = self.states:Count()
    for i = 1, count do
        local state = self.states:GetEntryByIndex(i)
        if state ~= nil then
            CloseState(self, state)
        end
    end
    self.states:Clear()
end


function StateManager:Remove(id)
    local currentState = self.states:GetEntryByKey(id)
    if currentState ~= nil then
        CloseState(self, currentState)
        self.states:Remove(id)
        return true
    end
    return false
end

function StateManager:Contains(id)
    return self.states:Contains(id)
end

local __REMOVED_LIST__ = {}
function StateManager:ConsumeTurn()

    local count = self.states:Count()

    for i = 1, count do
        local state = self.states:GetEntryByIndex(i)
        if state ~= nil then
            state:ConsumeTurn()

            -- 当前状态该结束了! --
            if state:IsGone() then
                -- debug_print("@@@ consume turn isgone @@@", self.luaGameObject:GetGameObject().name)
                __REMOVED_LIST__[#__REMOVED_LIST__ + 1] = state:GetId()
            end
        end
    end

    -- 这时候可以检查是否需要删除buff了 --
    for i = #__REMOVED_LIST__, 1, -1 do
        self:Remove(__REMOVED_LIST__[i])
        __REMOVED_LIST__[i] = nil
    end

    -- TODO 检查长度是否为0 --
end

-- 执行 buff 行为 --
local function Execute(self, phase)
    local count = self.states:Count()
    for i = 1, count do
        local state = self.states:GetEntryByIndex(i)
        if state ~= nil then
            state:Execute(phase)
        end
    end
end

function StateManager:Execute(phase)
    Execute(self, phase)                -- 仅匹配阶段才会执行
    Execute(self, kUnitState_Phase_Any) -- 任意阶段每次都会执行
end

-- Note: 目前这个仅支持在Add时判断!
function StateManager:SetStateEnabled(id, enabled)
    if enabled then
        self.disabledStateMaps[id] = true
    else
        self.disabledStateMaps[id] = nil
    end
end

-- ### 状态获取接口 ### --

-- @ 攻击力系数 @ --
function StateManager:GetApRate()
    return GetTotalRate(self, BattleStateTraitUtils.GetApRate)
end

-- @ 防御力系数 @ --
function StateManager:GetDpRate()
    return GetTotalRate(self, BattleStateTraitUtils.GetDpRate)
end

-- @ 速度系数 @ --
function StateManager:GetSpeedRate()
    return GetTotalRate(self, BattleStateTraitUtils.GetSpeedRate)
end

-- @ 暴击率 @ --
function StateManager:GetCritRate()
    return GetTotalRate(self, BattleStateTraitUtils.GetCritRate)
end

-- @ 暴击伤害系数 @ --
function StateManager:GetCritDamageRate()
    return GetTotalRate(self, BattleStateTraitUtils.GetCritDamageRate)
end

-- @ 抗暴率 @ --
function StateManager:GetDecritRate()
    return GetTotalRate(self, BattleStateTraitUtils.GetDecritRate)
end

-- @ 闪避率 @ --
function StateManager:GetAvoidRate()
    return GetTotalRate(self, BattleStateTraitUtils.GetAvoidRate)
end

-- @ 命中率 @ --
function StateManager:GetHitRate()
    return GetTotalRate(self, BattleStateTraitUtils.GetHitRate)
end

-- @ 吸血率 @ --
function StateManager:GetVamRate()
    return GetTotalRate(self, BattleStateTraitUtils.GetVamRate)
end

-- @ 伤害系数 @ --
function StateManager:GetDamageRate()
    return GetTotalRate(self, BattleStateTraitUtils.GetDamageRate)
end

-- ### 获取标志接口 ### --
function StateManager:HasGodFlag()
    return HasAny(self, BattleStateTraitUtils.HasGodFlag)
end

function StateManager:HasCannotMoveFlag()
    return HasAny(self, BattleStateTraitUtils.HasCannotMoveFlag)
end

-- ### 显示/隐藏所有特效显示 ### --
function StateManager:SetVisible(visible)
    SetVisible(self, visible)
end


return StateManager
