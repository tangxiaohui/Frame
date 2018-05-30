
require "StaticData.Manager"

local StateData = Class(LuaObject)

function StateData:Ctor(id)
    local stateDataMgr = Data.UnitState.Manager.Instance()
    self.data = stateDataMgr:GetObject(id)
    if self.data == nil then
        error(string.format("状态初始化失败, 状态ID: %s 不存在", id))
    end

    -- @ 建立特征数据 @ --
    local TraitMapsClass = require "StaticData.State.StateTraitMaps"
    self.traitMaps = TraitMapsClass.New(self.data)

    -- @ 建立行为数据 @ --
    local ActionMapsClass = require "StaticData.State.StateActionMaps"
    self.actionMaps = ActionMapsClass.New(self.data)

    -- print("打印:::::", self:ToString())
end

function StateData:ToString()
    return string.format(
        "id:%d, priority:%d, turns:%d, icon:%s, effect:%d",
        self:GetId(),
        self:GetPriority(),
        self:GetDefaultTurns(),
        self:GetIcon(),
        self:GetEffect()
    )
end

function StateData:GetId()
    return self.data.id
end

function StateData:GetPriority()
    return self.data.priority
end

function StateData:GetDefaultTurns()
    return self.data.turns
end

function StateData:GetTraitMaps()
    return self.traitMaps
end

function StateData:GetActionMaps()
    return self.actionMaps
end

function StateData:GetIcon()
    return self.data.icon
end

function StateData:GetEffect()
    return self.data.effect
end

function StateData:GetEffectParentName()
    return self.data.effectParentName
end

local StateDataManagerCls = Class(DataManager)
return StateDataManagerCls.New(StateData)
