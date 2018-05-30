--
-- User: fenghao
-- Date: 6/9/17
-- Time: 8:17 PM
--

require "Object.LuaObject"

local BattleInternalReplayData = Class(LuaObject)

function BattleInternalReplayData:Ctor(fightRecordMessage, responseMsg)
    self.fightRecordMessage = fightRecordMessage
    self.responseMsg = responseMsg
end

function BattleInternalReplayData:GetFightRecordMessage()
    return self.fightRecordMessage
end

function BattleInternalReplayData:GetResponseMsg()
    return self.responseMsg
end

return BattleInternalReplayData

