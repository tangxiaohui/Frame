require "StaticData.Manager"

MaxStatusData = Class(LuaObject)
function MaxStatusData:Ctor(id)

    local MaxStatusMgr = Data.MaxStatus.Manager.Instance()

    self.data = MaxStatusMgr:GetObject(id)
    if self.data == nil then
        error(string.format("属性信息不存在，ID: %s 不存在", id))
        return
    end
end

function MaxStatusData:GetID()
    return self.data.id
end

function MaxStatusData:GetMaxPower()
    return self.data.MaxPower
end


MaxStatusManager = Class(DataManager)

local MaxStatusDataMgr = MaxStatusManager.New(MaxStatusData)
return MaxStatusDataMgr
