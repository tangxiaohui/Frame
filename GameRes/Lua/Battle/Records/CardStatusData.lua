--
-- User: fenghao
-- Date: 6/1/17
-- Time: 11:32 AM
--

-- 卡牌数据, 这个数据会由战斗记录器 在战斗结束时 生成 --

local CardStatusData = Class(LuaObject)

function CardStatusData:Ctor(unit)
    self.id = unit:GetId()
    self.uid = unit:GetUid()
    self.pos = unit:GetLocation()
    self.hp = unit:GetCurHp()
    self.rage = unit:GetRage()
    self.alive = unit:IsAlive()
end

function CardStatusData:CopyToProtobuf(msg)
    msg.id = self.id
    msg.uid = self.uid or ""
    msg.pos = self.pos
    msg.hp = self.hp
    msg.rage = self.rage
    msg.alive = self.alive
end

return CardStatusData