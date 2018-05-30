require "StaticData.Manager"

SystemConfigData = Class(LuaObject)

function SystemConfigData:Ctor(id)
    local SystemConfigMgr = Data.SystemConfig.Manager.Instance()
    
    self.data = SystemConfigMgr:GetObject(id)
    if self.data == nil then
        error(string.format("系统设置SystemConfig信息不存在，ID: %s 不存在", id))
        return
    end

end

function SystemConfigData:GetId()
    return self.data.id
end

function SystemConfigData:GetParameNum()
    return self.data.parameNum
end


SystemConfigManager = Class(DataManager)

local SystemConfigDataMgr = SystemConfigManager.New(SystemConfigData)
return SystemConfigDataMgr