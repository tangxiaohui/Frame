--
-- User: fenghao
-- Date: 6/1/17
-- Time: 11:48 AM
--

require "Object.LuaObject"

-- 单个卡牌的总伤害值

local DamageCardItemData = Class(LuaObject)

function DamageCardItemData:Ctor(pos)
    self.pos = pos
    self.totalDamages = 0
end

function DamageCardItemData:AddDamage(value)
    self.totalDamages = self.totalDamages + value
end

function DamageCardItemData:CopyToProtobuf(msg)
    msg.pos = self.pos
    msg.totalDamages = self.totalDamages
end

function DamageCardItemData:ToString()
    return string.format("站位: %d, 伤害信息: %d", self.pos, self.totalDamages)
end

return DamageCardItemData

