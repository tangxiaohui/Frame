require "StaticData.Manager"

SystemBasisInfoData = Class(LuaObject)

function SystemBasisInfoData:Ctor(id)
    local SystemBasisInfoMgr = Data.SystemBasisInfo.Manager.Instance()
    
    self.data = SystemBasisInfoMgr:GetObject(id)
    if self.data == nil then
        error(string.format("系统设置SystemConfig信息不存在，ID: %s 不存在", id))
        return
    end

end

function SystemBasisInfoData:GetName()
    return self.data.name
end

function SystemBasisInfoData:GetShowContent()
    return self.data.showContent
end


SystemBasisInfoManager = Class(DataManager)

local SystemBasisInfoDataMgr = SystemBasisInfoManager.New(SystemBasisInfoData)
return SystemBasisInfoDataMgr