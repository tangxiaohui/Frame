--
-- User: fenghao
-- Date: 6/7/17
-- Time: 5:12 PM
--

require "Object.LuaObject"

local BattleInternalData = Class(LuaObject)

function BattleInternalData:Ctor()
    self.isReplay = false
    self.fightRecord = nil
end

function BattleInternalData:SetReplay(replay)
    self.isReplay = replay
end

function BattleInternalData:GetReplay()
    return self.isReplay
end

function BattleInternalData:SetFightRecord(record)
    self.fightRecord = record
end

function BattleInternalData:GetFightRecord()
    return self.fightRecord
end

function BattleInternalData:Verify()
    if self.isReplay then
        if self.fightRecord == nil then
            error("回放模式 没有设置记录!!!")
        end
    end
end

return BattleInternalData
