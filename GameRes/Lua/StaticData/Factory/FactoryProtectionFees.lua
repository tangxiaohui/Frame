require "StaticData.Manager"

FactoryProtectionFeesData = Class(LuaObject)
function FactoryProtectionFeesData:Ctor(id)
    local FactoryProtectionFeesMgr = Data.FactoryProtectionFees.Manager.Instance()
    self.data = FactoryProtectionFeesMgr:GetObject(id)
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
end
--获取保护的价格
function FactoryProtectionFeesData:GetProtectPrice()
    return self.data.protectPrice
end



FactoryProtectionFeesManager = Class(DataManager)

local FactoryProtectionFeesDataMgr = FactoryProtectionFeesManager.New(FactoryProtectionFeesData)
return FactoryProtectionFeesDataMgr