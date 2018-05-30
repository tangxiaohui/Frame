--
-- User: fenghao
-- Date: 6/5/17
-- Time: 8:17 PM
--

require "Battle.Parameters.BattleUnitParameter"

BattleTeamParameter = Class(LuaObject)

function BattleTeamParameter:Ctor()
    self.units = {}
end

function BattleTeamParameter:AddUnit(unitParameter)
    if unitParameter ~= nil then
        self.units[#self.units + 1] = unitParameter
    end
end

function BattleTeamParameter:GetUnit(pos)
    return self.units[pos]
end

function BattleTeamParameter:Count()
    return #self.units
end

-- msg = CardItemWaveData
function BattleTeamParameter:CopyToProtobuf(msg)
    local unitCount = self:Count()
    for i = 1, unitCount do
        local pb = msg.cards:add()
        self.units[i]:CopyToProtobuf(pb)
    end
end

-- msg = CardItemWaveData
function BattleTeamParameter:InitByProtobuf(msg)
    local unitCount = #msg.cards
    for i = 1, unitCount do
        local battleUnitParameter = BattleUnitParameter.New()
        battleUnitParameter:InitByProtobuf(msg.cards[i])
        self:AddUnit(battleUnitParameter)
    end
end