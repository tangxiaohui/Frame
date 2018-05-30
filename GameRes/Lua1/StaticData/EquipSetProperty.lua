require "StaticData.Manager"

EquipSetPropertyData = Class(LuaObject)

function EquipSetPropertyData:Ctor(id)
    local EquipSetPropertyMgr = Data.EquipSetProperty.Manager.Instance()
    self.data = EquipSetPropertyMgr:GetObject(id)
    if self.data == nil then
        error(string.format("装备套装属性信息不存在，ID: %s 不存在", id))
        return
    end
end

function EquipSetPropertyData:GetId()
    return self.data.id
end


function EquipSetPropertyData:GetHasNum()
    return self.data.hasNum
end

function EquipSetPropertyData:GetAddPropID()
    return self.data.addPropID
end

function EquipSetPropertyData:GetAddValue()
    return self.data.addValue
end


EquipSetPropertyManager = Class(DataManager)

local EquipSetPropertyDataMgr = EquipSetPropertyManager.New(EquipSetPropertyData)
return EquipSetPropertyDataMgr