require "StaticData.Manager"

FactoryItemInfoData = Class(LuaObject)

function FactoryItemInfoData:Ctor(id)
    local FactoryItemInfoMgr = Data.FactoryItemInfo.Manager.Instance()
    self.data = FactoryItemInfoMgr:GetObject(id)
    if self.data == nil then
        error(string.format("工厂信息数据不存在，ID: %s 不存在", id))
        return
    end
end

function FactoryItemInfoData:GetId()
    return self.data.id
end

function FactoryItemInfoData:GetName()
    return self.data.name
end

function FactoryItemInfoData:GetDesc()
    return self.data.desc
end




FactoryItemInfoManager = Class(DataManager)

local FactoryItemInfoDataMgr = FactoryItemInfoManager.New(FactoryItemInfoData)
return FactoryItemInfoDataMgr