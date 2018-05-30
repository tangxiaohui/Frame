--
-- User: fenghao
-- Date: 6/5/17
-- Time: 8:17 PM
--

require "Object.LuaObject"
require "Game.Role"

BattleUnitParameter = Class(LuaObject)

function BattleUnitParameter:Ctor(role, location, scaleRate)
    self.role = role
    self.location = location
	self.scaleRate = scaleRate
end

function BattleUnitParameter:GetRole()
    return self.role
end

function BattleUnitParameter:GetLocation()
    return self.location
end

function BattleUnitParameter:GetScaleRate()
	return self.scaleRate or 100
end

-- 设置最大血量
function BattleUnitParameter:SetMaxHp(maxHp)
    self.maxHp = maxHp
end

-- 获得最大血量
function BattleUnitParameter:GetMaxHp()
    return self.maxHp
end

-- 设置当前血量
function BattleUnitParameter:SetCurHp(curHp)
    self.curHp = curHp
end

-- 获得当前血量
function BattleUnitParameter:GetCurHp()
    return self.curHp
end

-- msg = FightingCardData
function BattleUnitParameter:CopyToProtobuf(msg)
    msg.pos = self:GetLocation()
	msg.scaleRate = self:GetScaleRate()
    self.role:CopyToProtobuf(msg.card, msg.equips)
end

-- msg = FightingCardData
function BattleUnitParameter:InitByProtobuf(msg)
    self.location = msg.pos
	self.scaleRate = msg.scaleRate
    self.role = Role.New()
    self.role:InitByProtobuf(msg.card, msg.equips)
end
