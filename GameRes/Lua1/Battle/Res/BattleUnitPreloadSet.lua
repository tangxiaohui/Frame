
require "Collection.OrderedDictionary"
local utility = require "Utils.Utility"

local UnitItem = Class()

function UnitItem:Ctor(id, count)
    self.id = id
    self.count = count
end

function UnitItem:GetId()
    return self.id
end

function UnitItem:GetCount()
    return self.count
end



local BattleUnitPreloadSet = Class()

function BattleUnitPreloadSet:Ctor()
    self.tempDictionary = OrderedDictionary.New()
    self.internalSet = {}
end

local function RecordRoleIdToDictionary(dict, id)
    local n = dict:GetEntryByKey(id) or 0
    dict:Set(id, n+1)
end

local function GetId(teamParameter, pos)
    return teamParameter:GetUnit(pos):GetRole():GetId()
end

local function RecordTeamTemporarily(dict, teamParameter)
    local count = teamParameter:Count()
    for i = 1, count do
        RecordRoleIdToDictionary(dict, GetId(teamParameter, i))
    end
end

local function Union_SetMax(dict, i, internalSet)
    local key = dict:GetKeyFromIndex(i)
    local value = dict:GetEntryByIndex(i)
    local o_n = internalSet[key] or 0
    internalSet[key] = math.max(value, o_n)
end

-- dict: OrderedDictionary,  internalSet: table(in lua)
local function Union(dict, internalSet)
    local count = dict:Count()
    for i = 1, count do
        Union_SetMax(dict, i, internalSet)
    end
end

function BattleUnitPreloadSet:Union(teamParameter1, teamParameter2)
    utility.ASSERT(self.tempDictionary:Count() == 0, "tempDictionary长度不为空!")
    RecordTeamTemporarily(self.tempDictionary, teamParameter1)
    RecordTeamTemporarily(self.tempDictionary, teamParameter2)
    Union(self.tempDictionary, self.internalSet)
    self.tempDictionary:Clear()
end

function BattleUnitPreloadSet:Foreach(func)
    for k, v in pairs(self.internalSet) do
        func(k, v)
    end
end

function BattleUnitPreloadSet:GetArrayReadonly()
    local array = {}
    for k, v in pairs(self.internalSet) do
        array[#array + 1] = UnitItem.New(k, v)
    end
    return array
end

return BattleUnitPreloadSet
