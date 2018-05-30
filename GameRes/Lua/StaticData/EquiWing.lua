require "StaticData.Manager"

EquiWingData = Class(LuaObject)

function EquiWingData:Ctor(id)
    local EquiWingMgr = Data.EquiWing.Manager.Instance()
    self.data = EquiWingMgr:GetObject(id)
    if self.data == nil then
        error(string.format("翅膀信息不存在，ID: %s 不存在", id))
        return
    end
end

function EquiWingData:GetId()
    return self.data.id
end

function EquiWingData:GetNeedBuildNum()
    return self.data.needBuildNum
end

function EquiWingData:GetNeedSuipianID()
	return self.data.needSuipianID
end

function EquiWingData:GetNeedCoin()
	return self.data.needCoin
end

EquiWingManager = Class(DataManager)

local EquiWingDataMgr = EquiWingManager.New(EquiWingData)
return EquiWingDataMgr