require "StaticData.Manager"

EquipPetsExpData = Class(LuaObject)

function EquipPetsExpData:Ctor(id)
    local EquipPetsExpDataMgr = Data.EquipPetsExp.Manager.Instance()
    self.data = EquipPetsExpDataMgr:GetObject(id)
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
end

function EquipPetsExpData:GetColor()
    return self.data.color
end

function EquipPetsExpData:GetPetExp()
    return self.data.petExp
end

function EquipPetsExpData:GetExpXishu()
    return self.data.expXishu
end

function EquipPetsExpData:GetCoinXishu()
    return self.data.coinXishu
end


EquipPetsExpInfoManager = Class(DataManager)

local EquipPetsExpInfoMgr = EquipPetsExpInfoManager.New(EquipPetsExpData)
return EquipPetsExpInfoMgr


