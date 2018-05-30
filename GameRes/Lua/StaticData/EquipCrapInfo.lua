require "StaticData.Manager"

EquipCrapInfoData = Class(LuaObject)

function EquipCrapInfoData:Ctor(id)
    local EquipCrapInfoMgr = Data.EquipCrapInfo.Manager.Instance()
    self.data = EquipCrapInfoMgr:GetObject(id)
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
end

function EquipCrapInfoData:GetId()
    return self.data.id
end

function EquipCrapInfoData:GetName()
    return self.data.name
end


EquipCrapInfoManager = Class(DataManager)

local EquipCrapInfoDataMgr = EquipCrapInfoManager.New(EquipCrapInfoData)
return EquipCrapInfoDataMgr