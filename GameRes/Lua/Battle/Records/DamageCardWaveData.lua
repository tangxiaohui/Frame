--
-- User: fenghao
-- Date: 6/1/17
-- Time: 11:51 AM
--

-- 怪物多波伤害值

require "Object.LuaObject"
require "Collection.OrderedDictionary"

local DamageCardItemDataClass = require "Battle.Records.DamageCardItemData"

local DamageCardWaveData = Class(LuaObject)

function DamageCardWaveData:Ctor()
    self.cardDict = OrderedDictionary.New()
end

function DamageCardWaveData:AddDamage(pos, damageValue)
    local damageData = self.cardDict:GetEntryByKey(pos)
    if damageData == nil then
        damageData = DamageCardItemDataClass.New(pos)
        self.cardDict:Add(pos, damageData)
    end
    damageData:AddDamage(damageValue)
end

function DamageCardWaveData:CopyToProtobuf(msg)
    local count = self.cardDict:Count()
    for i = 1, count do
        local damageData = self.cardDict:GetEntryByIndex(i)
        if damageData ~= nil then
            local pb = msg:add()
            damageData:CopyToProtobuf(pb)
        end
    end
end

function DamageCardWaveData:ToString()
    local stringTable = {}
    local count = self.cardDict:Count()
    for i = 1, count do
        local damageData = self.cardDict:GetEntryByIndex(i)
        stringTable[#stringTable + 1] = damageData:ToString()
    end
    return table.concat(stringTable, "\n")
end

return DamageCardWaveData

