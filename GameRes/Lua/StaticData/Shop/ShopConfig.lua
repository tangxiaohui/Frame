require "StaticData.Manager"

ShopConfigData = Class(LuaObject)

function ShopConfigData:Ctor(id)
    local ShopConfigMgr = Data.ShopConfig.Manager.Instance()
    self.data = ShopConfigMgr:GetObject(id)
    if self.data == nil then
        error(string.format("商店基础配置信息不存在，ID: %s 不存在", id))
        return
    end
end

function ShopConfigData:GetId()
    return self.data.shopType
end

function ShopConfigData:GetRefreshTime()
    return self.data.refreshTime
end

function ShopConfigData:GetOpenLevel()
    return self.data.openLevel
end

function ShopConfigData:GetAlwaysOpen()
    return self.data.alwaysOpen
end



ShopConfigManager = Class(DataManager)

local ShopConfigDataMgr = ShopConfigManager.New(ShopConfigData)

function ShopConfigDataMgr:GetKeys()
    return Data.ShopConfig.Manager.Instance():GetKeys()
end
return ShopConfigDataMgr