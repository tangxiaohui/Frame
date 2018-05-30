require "StaticData.Manager"

EquipInfoData = Class(LuaObject)

function EquipInfoData:Ctor(id)
    local equipInfoMgr = Data.EquipInfo.Manager.Instance()
    self.data = equipInfoMgr:GetObject(id)
    if self.data == nil then
        error(string.format("装备信息不存在，ID: %s 不存在", id))
        return
    end
end

function EquipInfoData:GetId()
    return self.data.id
end

function EquipInfoData:GetName()
    return self.data.name
end

function EquipInfoData:GetDesc()
    return self.data.desc
end

function EquipInfoData:GetFakeDesc()
	return self.data.fakeDesc
end

EquipInfoManager = Class(DataManager)

local equipInfoManager = EquipInfoManager.New(EquipInfoData)
return equipInfoManager