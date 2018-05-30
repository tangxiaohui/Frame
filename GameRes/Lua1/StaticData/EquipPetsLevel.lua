require "StaticData.Manager"

EquipPetsLevelData = Class(LuaObject)

function EquipPetsLevelData:Ctor(id)
    local EquipPetsLevelDataMgr = Data.EquipPetsLevel.Manager.Instance()
    self.data = EquipPetsLevelDataMgr:GetObject(id)
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
end

function EquipPetsLevelData:GetLevel()
    return self.data.level
end

function EquipPetsLevelData:GetNeedExp()
    return self.data.needExp
end
EquipPetsLevelInfoManager = Class(DataManager)

local EquipPetsLevelInfoMgr = EquipPetsLevelInfoManager.New(EquipPetsLevelData)

function EquipPetsLevelInfoMgr:GetKeys()	
    return Data.EquipPetsLevel.Manager.Instance():GetKeys()
end
return EquipPetsLevelInfoMgr
