
require "Object.LuaObject"
require "Collection.OrderedDictionary"


-- @@ Entry 类定义 @@ --
local TraitEntryClass = Class()

function TraitEntryClass:Ctor(id, param1, param2)
    self.id = id
    self.param1 = param1
    self.param2 = param2
end

function TraitEntryClass:GetId()
    return self.id
end

function TraitEntryClass:GetParam1()
    return self.param1
end

function TraitEntryClass:GetParam2()
    return self.param2
end


-- @@ List 类定义 @@ --
local TraitEntryListClass = Class()

function TraitEntryListClass:Ctor()
    self.entries = {}
end

function TraitEntryListClass:Add(traitId, param1, param2)
    self.entries[#self.entries + 1] = TraitEntryClass.New(traitId, param1, param2)
end

function TraitEntryListClass:GetEntry(pos)
    return self.entries[pos]
end

function TraitEntryListClass:Count()
    return #self.entries
end


-- @@ StateTraitMaps的定义 @@ --
local StateTraitMaps = Class(LuaObject)

-- 获取参数的函数 --
local function GetParamUtil(params, index)
    if params == nil or params.Count == 0 then
        return nil
    end
    return params[index]
end

-- 数据正确性校验 --
local function CheckTraitDataValidL(data)
    local traitIds = data.traitIds
    local traitParams1 = data.traitParams1
    local traitParams2 = data.traitParams2

    -- ## 肯定是拿 traitIds 的数量当基准的! ## --
    local count = traitIds.Count

    -- # 检测 traitParams1 的 # --
    if traitParams1.Count > 0 and traitParams1.Count ~= count then
        error(
            string.format(
                "特征和特征参数1的数量不一致! id = %d", data.id
            )
        )
    end

    -- # 检测 traitParams2 的 # --
    if traitParams2.Count > 0 and traitParams2.Count ~= count then
        error(
            string.format(
                "特征和特征参数2的数量不一致! id = %d", data.id
            )
        )
    end 
end

local function AddNewTraitEntry(self, traitId, param1, param2)
    if type(traitId) ~= "number" then
        error("参数 traitId 不是 number 类型!")
    end

    local entryList = self.maps:GetEntryByKey(traitId)
    if entryList == nil then
        entryList = TraitEntryListClass.New()
        self.maps:Add(traitId, entryList)
    end

    entryList:Add(traitId, param1, param2)
end

-- 初始化数据
local function Init(self, data)
    self.maps:Clear()

    local traitIds = data.traitIds
    local traitParams1 = data.traitParams1
    local traitParams2 = data.traitParams2

    local traitId
    local wParam
    local lParam

    -- 循环处理 --
    local max = traitIds.Count - 1
    for i = 0, max do
        traitId = traitIds[i]
        wParam = GetParamUtil(traitParams1, i)
        lParam = GetParamUtil(traitParams2, i)
        AddNewTraitEntry(self, traitId, wParam, lParam)
    end

end

function StateTraitMaps:Ctor(data)
    CheckTraitDataValidL(data)
    self.maps = OrderedDictionary.New()
    Init(self, data)
end

function StateTraitMaps:GetKeys()
    return self.maps:GetKeys()
end

function StateTraitMaps:GetEntries(id)
    return self.maps:GetEntryByKey(id)
end

return StateTraitMaps
