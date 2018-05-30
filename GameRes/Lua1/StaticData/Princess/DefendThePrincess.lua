--
-- User: fenghao
-- Date: 04/07/2017
-- Time: 5:24 PM
--

require "StaticData.Manager"

local DefendThePrincessData = Class(LuaObject)

function DefendThePrincessData:Ctor(id)
    local defendThePrincessMgr = Data.DefendThePrincess.Manager.Instance()
    self.data = defendThePrincessMgr:GetObject(id)
    if self.data == nil then
        error(string.format("保卫公主主表 ID: %d 数据不存在!", id))
        return
    end
end

function DefendThePrincessData:GetGateID()
    return self.data.gateID
end

function DefendThePrincessData:GetGateType()
    return self.data.gateType
end

function DefendThePrincessData:GetBaseCoin()
    return self.data.baseCoin
end

function DefendThePrincessData:GetCoinFactor()
    return self.data.coinXishu
end

function DefendThePrincessData:GetProtectCoin()
    return self.data.protectCoin
end


local DefendThePrincessManager = Class(DataManager)
return DefendThePrincessManager.New(DefendThePrincessData)
