require "StaticData.Manager"

EquipSetData = Class(LuaObject)

function EquipSetData:Ctor(id)
    local EquipSetMgr = Data.EquipSet.Manager.Instance()
    self.data = EquipSetMgr:GetObject(id)
    if self.data == nil then
        error(string.format("装备套装信息不存在，ID: %s 不存在", id))
        return
    end

    local EquipSetInfoMgr = Data.EquipSetInfo.Manager.Instance()
    self.infoData = EquipSetInfoMgr:GetObject(self.data.info)
    if self.infoData == nil then
        error(string.format("装备套装描述信息不存在，ID: %s 不存在", self.data.info))
        return
    end
end

function EquipSetData:GetId()
    return self.data.id
end

function EquipSetData:GetInfo()
    return self.data.info
end

function EquipSetData:GetMaxProperty()
	return self.data.maxProperty
end


function EquipSetData:GetTaozhuangList()
    return self.data.taozhuangList
end

function EquipSetData:GetSuitName()
	return self.infoData.name
end

EquipSetManager = Class(DataManager)

local EquipSetDataMgr = EquipSetManager.New(EquipSetData)
return EquipSetDataMgr