require "StaticData.Manager"

CoinBuyData = Class(LuaObject)

function CoinBuyData:Ctor(id)
    local CoinBuyMgr = Data.CoinBuy.Manager.Instance()
    self.data = CoinBuyMgr:GetObject(id)
    if self.data == nil then
        error(string.format("购买金币信息不存在，ID: %s 不存在", id))
        return
    end
end

function CoinBuyData:GetId()
    return self.data.id
end

function CoinBuyData:GetPrice()
    return self.data.price
end

function CoinBuyData:GetNum()
    return self.data.num
end




CoinBuyManager = Class(DataManager)

local CoinBuyDataMgr = CoinBuyManager.New(CoinBuyData)

function CoinBuyDataMgr:GetKeys()
    return Data.CoinBuy.Manager.Instance():GetKeys()
end

return CoinBuyDataMgr