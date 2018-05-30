
local StateManagerClass = require "Battle.States.StateManager"

function BattleUnit:InitStateManager()
    self.stateManager = StateManagerClass.New()
    self.stateManager:SetVisible(false)
    self.stateImmunityTable = {}
    self:AddComponent(self.stateManager)
end

function BattleUnit:CloseStateManager()
    if self.stateManager then
        self.stateManager:Clear()
    end
end

function BattleUnit:GetStateManager()
    return self.stateManager
end

-- 重置回合所使用的数据
function BattleUnit:ResetStateData()
    self:ConsumeUnitStateTurn()
end

local function IsImmuneToState(self, id)
    return self.role:IsImmuneToState(id) or self.stateImmunityTable[id] == true
end

function BattleUnit:IsImmuneToState(id)
    return IsImmuneToState(self, id)
end

function BattleUnit:AddStateImmunity(id)
    if type(id) ~= nil then
        self.stateImmunityTable[id] = true
    end
end

function BattleUnit:RemoveStateImmunity(id)
    if type(id) ~= nil then
        self.stateImmunityTable[id] = nil
    end
end

-- 加状态
function BattleUnit:AddUnitState(id, sources, turns)
    -- # 具有此状态的免疫 # --
    if IsImmuneToState(self, id) then
        return
    end

    self.stateManager:Add(id, sources, turns)
end

-- 去掉状态
function BattleUnit:RemoveUnitState(id)
    return self.stateManager:Remove(id)
end

-- 查询人物所拥有的状态
function BattleUnit:HasUnitState(id)
    return self.stateManager:Contains(id)
end


-- 状态管理 处理 --
function BattleUnit:ExecuteUnitStateAction(phase)
    self.stateManager:Execute(phase)
end

-- 消耗状态的回合数 --
function BattleUnit:ConsumeUnitStateTurn()
    self.stateManager:ConsumeTurn()
end

-- [[人物状态获取]] --


-- 是否无敌
function BattleUnit:HasGodState()
    return self.stateManager:HasGodFlag()
end

-- 是否不能移动
function BattleUnit:HasCannotMoveState()
    return self.stateManager:HasCannotMoveFlag()
end

function BattleUnit:UpdateStateManager()
    -- TODO StateManager Update Event
end

function BattleUnit:SetUnitStateEffectEnabled(enabled)
    self.stateManager:SetEffectEnabled(enabled)
end

