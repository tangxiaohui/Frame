--
-- User: fenghao
-- Date: 09/07/2017
-- Time: 11:35 PM
--

require "Object.LuaObject"
require "Collection.OrderedDictionary"
local utility = require "Utils.Utility"

-- # 伤害Entry # --
local DamageSourceEntry = Class()

function DamageSourceEntry:Ctor(unitController, damageValue, isCrit, isHeal)
    self.unitController = unitController
    self.damageValue = damageValue
    self.isCrit = isCrit
    self.isHeal = isHeal
end

function DamageSourceEntry:GetUnitController()
    return self.unitController
end

function DamageSourceEntry:GetDamageValue()
    return self.damageValue
end

function DamageSourceEntry:IsCrit()
    return self.isCrit
end

function DamageSourceEntry:IsHeal()
    return self.isHeal
end



local BattleDamageSourceInfo = Class(LuaObject)

function BattleDamageSourceInfo:Ctor(owner)
    self.owner = owner  -- BattleUnit
    self.sources = OrderedDictionary.New()
    self:ResetCurrentIndex()
end

function BattleDamageSourceInfo:ResetCurrentIndex()
    self.currentIndex = 0
end

function BattleDamageSourceInfo:Clear()
    self.sources:Clear()
    self:ResetCurrentIndex()
end

function BattleDamageSourceInfo:Add(battleUnitController, damage, isCrit, isHeal)
    utility.ASSERT(battleUnitController ~= nil, "battleUnitController不能为nil")
    utility.ASSERT(damage ~= nil, "damage 不能为 nil")
    utility.ASSERT(isCrit ~= nil, "isCrit 不能为 nil")
    utility.ASSERT(isHeal ~= nil, "isHeal 不能为 nil")
    local entry = DamageSourceEntry.New(battleUnitController, damage, isCrit, isHeal)
    self.sources:Add(entry, entry)
end

function BattleDamageSourceInfo:Next()
    local index = self.currentIndex + 1
    if index <= self:Count() then
        self.currentIndex = index
        return self.sources:GetEntryByIndex(self.currentIndex)
    end
    return nil
end

function BattleDamageSourceInfo:GetUnits()

    local indexTable = {}

    local retUnits = {}

    local count = self:Count()

    for i = 1, count do
        local entry = self.sources:GetEntryByIndex(i)
        local battleUnit = entry:GetUnitController().luaGameObject
        if battleUnit ~= nil and indexTable[battleUnit] == nil then
            retUnits[#retUnits + 1] = battleUnit
            indexTable[battleUnit] = true
        end
    end

    return retUnits
end

function BattleDamageSourceInfo:Count()
    return self.sources:Count()
end

return BattleDamageSourceInfo
