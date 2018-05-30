require "StaticData.Manager"

FactoryConfigData = Class(LuaObject)
function FactoryConfigData:Ctor(id)
    local FactoryConfigMgr = Data.FactoryConfig.Manager.Instance()
    self.data = FactoryConfigMgr:GetObject(id)
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
end

function FactoryConfigData:Slot4Vip()
    return self.data.slot4Vip
end

function FactoryConfigData:Slot4Diamond()
    return self.data.slot4Diamond
end

function FactoryConfigData:Slot5Vip()
    return self.data.slot5Vip
end

function FactoryConfigData:Slot5Diamond()
    return self.data.slot5Diamond
end



FactoryConfigManager = Class(DataManager)

local FactoryConfigDataMgr = FactoryConfigManager.New(FactoryConfigData)
return FactoryConfigDataMgr