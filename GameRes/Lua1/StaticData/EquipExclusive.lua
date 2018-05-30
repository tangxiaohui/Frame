require "StaticData.Manager"

EquipExclusiveData = Class(LuaObject)

function EquipExclusiveData:Ctor(id)
    local EquipExclusiveMgr = Data.EquipExclusive.Manager.Instance()
    self.data = EquipExclusiveMgr:GetObject(id)
    if self.data == nil then
        error(string.format("装备羁绊加成信息不存在，ID: %s 不存在", id))
        return
    end

    
end

function EquipExclusiveData:GetId()
    return self.data.equipID
end

function EquipExclusiveData:GetJibanCardID()
    return self.data.jibanCardID
end

function EquipExclusiveData:IsKizunaContains(cardID)
    local jibanCardIDList = self:GetJibanCardID()
    local max = jibanCardIDList.Count - 1
    for i = 0, max do
        local jibanCardID = jibanCardIDList[i]
        if jibanCardID == cardID then
            return true
        end
    end
    return false
end

function EquipExclusiveData:GetJibanAddPropID()
    return self.data.jibanAddPropID
end

function EquipExclusiveData:GetAddPropType()
    return self.data.addPropType
end

function EquipExclusiveData:GetAddPropValue()
    return self.data.addPropValue
end

EquipExclusiveManager = Class(DataManager)

local EquipExclusiveDataMgr = EquipExclusiveManager.New(EquipExclusiveData)

function EquipExclusiveDataMgr:GetKeys()
	return Data.EquipExclusive.Manager.Instance():GetKeys()
end

return EquipExclusiveDataMgr