--
-- User: fenghao
-- Date: 6/1/17
-- Time: 11:38 AM
--

-- 怪物多波数据 --
-- 每打完一波怪 就会由战斗记录器 把当前的所有怪生成为 CardStatusData
-- 并保存在当前波次数据中

require "Object.LuaObject"
local CardStatusData = require "Battle.Records.CardStatusData"

local CardWaveStatusData = Class(LuaObject)

function CardWaveStatusData:Ctor(members)
    self.waveData = {}
    for _, v in pairs(members) do
        self.waveData[#self.waveData + 1] = CardStatusData.New(v)
    end
end

-- 生成Protobuf (msg = infos)
function CardWaveStatusData:CopyToProtobuf(msg)
    for i = 1, #self.waveData do
        local cardStatusData = self.waveData[i]
        local pb = msg:add()
        cardStatusData:CopyToProtobuf(pb)
    end
end

return CardWaveStatusData