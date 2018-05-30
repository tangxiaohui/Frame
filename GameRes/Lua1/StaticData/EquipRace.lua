require "StaticData.Manager"

EquipRaceData = Class(LuaObject)

function EquipRaceData:Ctor(id)
    local EquipRaceMgr = Data.EquipRace.Manager.Instance()
    self.data = EquipRaceMgr:GetObject(id)
    if self.data == nil then
        error(string.format("装备种族信息不存在，ID: %s 不存在", id))
        return
    end
end

function EquipRaceData:GetId()
    return self.data.equipID
end

function EquipRaceData:GetRaceID()
    return self.data.raceID
end

function EquipRaceData:GetAddPropID()
    return self.data.addPropID
end

function EquipRaceData:GetAddPropValue()
    return self.data.addPropValue
end

EquipRaceManager = Class(DataManager)

local EquipRaceDataMgr = EquipRaceManager.New(EquipRaceData)
return EquipRaceDataMgr