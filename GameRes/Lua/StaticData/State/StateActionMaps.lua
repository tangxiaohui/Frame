
require "Object.LuaObject"
require "Collection.OrderedDictionary"
require "Const"

-- @@ ActionEntry 类定义 @@ --
local ActionEntryClass = Class()

function ActionEntryClass:Ctor(id, param1, param2)
    self.id = id
    self.param1 = param1
    self.param2 = param2
end

function ActionEntryClass:GetId()
    return self.id
end

function ActionEntryClass:GetParam1()
    return self.param1
end

function ActionEntryClass:GetParam2()
    return self.param2
end

-- @@ PhaseEntryList 类定义 @@ --
local PhaseEntryListClass = Class()

function PhaseEntryListClass:Ctor()
    self.actionEntries = {}
end

function PhaseEntryListClass:Add(actionId, actionParam1, actionParam2)
    self.actionEntries[#self.actionEntries + 1] = ActionEntryClass.New(actionId, actionParam1, actionParam2)
end

function PhaseEntryListClass:GetEntry(pos)
    return self.actionEntries[pos]
end

function PhaseEntryListClass:Count()
    return #self.actionEntries
end


-- @@ StateActionMaps 类定义 @@ --
local StateActionMaps = Class(LuaObject)

-- 获取参数的函数 --
local function GetParamUtil(params, index)
    if params == nil or params.Count == 0 then
        return nil
    end
    return params[index]
end

-- 检查数据的正确性 --
local function CheckActionDataValidL(data)
    local phases = data.phases 
    local actionIds = data.actionIds
    local actionParams1 = data.actionParams1
    local actionParams2 = data.actionParams2

    -- 执行阶段和行为个数一定要一致!! --
    if phases.Count ~= actionIds.Count then
        error(
            string.format(
                "执行阶段和行为个数不一致! id = %d", data.id
            )
        )
    end

    -- 参考执行阶段的个数 --
    local count = phases.Count

    -- # 检测 actionParams1 的个数 # --
    if actionParams1.Count > 0 and actionParams1.Count ~= count then
        error(
            string.format(
                "执行阶段和行为参数1个数不一致! id = %d", data.id
            )
        )
    end

    -- # 检测 actionParams2 的个数 # --
    if actionParams2.Count > 0 and actionParams2.Count ~= count then
        error(
            string.format(
                "执行阶段和行为参数2个数不一致! id = %d", data.id
            )
        )
    end
end

-- add
local function AddNewActionEntry(self, phase, actionId, actionParam1, actionParam2)
    if type(phase) ~= "number" then
        error("参数 phase 不是 number 类型!")
    end

    if type(actionId) ~= "number" then
        error("参数 actionId 不是 number 类型!")
    end

    -- 在构造的时候 过滤掉 None 的阶段 --
    if phase == kUnitState_Phase_None then
        return
    end

    local entryList = self.maps:GetEntryByKey(phase)
    if entryList == nil then
        entryList = PhaseEntryListClass.New()
        self.maps:Add(phase, entryList)
    end

    entryList:Add(actionId, actionParam1, actionParam2)
end

-- 初始化数据 --
local function Init(self, data)
    self.maps:Clear()

    local phases = data.phases 
    local actionIds = data.actionIds
    local actionParams1 = data.actionParams1
    local actionParams2 = data.actionParams2

    local wParam
    local lParam

    -- 循环处理 --
    local max = phases.Count - 1
    for i = 0, max do
        AddNewActionEntry(
            self,
            phases[i],
            actionIds[i],
            GetParamUtil(actionParams1, i),
            GetParamUtil(actionParams2, i)
        )
    end
end

function StateActionMaps:Ctor(data)
    CheckActionDataValidL(data)
    self.maps = OrderedDictionary.New()
    Init(self, data)
end


function StateActionMaps:GetEntriesByPhase(phase)
    return self.maps:GetEntryByKey(phase)
end

return StateActionMaps
