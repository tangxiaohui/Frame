require "StaticData.Manager"

StaminaBuyData = Class(LuaObject)

function StaminaBuyData:Ctor(id)
    local StaminaBuyMgr = Data.StaminaBuy.Manager.Instance()
    self.data = StaminaBuyMgr:GetObject(id)
    if self.data == nil then
        error(string.format("购买体力信息不存在，ID: %s 不存在", id))
        return
    end
end

function StaminaBuyData:GetId()
    return self.data.id
end

function StaminaBuyData:GetPrice()
    return self.data.price
end

function StaminaBuyData:GetNum()
    return self.data.num
end




StaminaBuyManager = Class(DataManager)

local StaminaBuyDataMgr = StaminaBuyManager.New(StaminaBuyData)

function StaminaBuyDataMgr:GetKeys()
    return Data.StaminaBuy.Manager.Instance():GetKeys()
end

return StaminaBuyDataMgr