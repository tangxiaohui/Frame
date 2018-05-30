require "StaticData.Manager"

EquipCrapData = Class(LuaObject)

function EquipCrapData:Ctor(id)
    local EquipCrapMgr = Data.EquipCrap.Manager.Instance()
    self.data = EquipCrapMgr:GetObject(id)
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
end

function EquipCrapData:GetId()
    return self.data.id
end

function EquipCrapData:GetInfo()
    return self.data.info
end

function EquipCrapData:GetEquipid()
	return self.data.equipid
end

function EquipCrapData:GetSellPrice()
	return self.data.sellPrice
end

function EquipCrapData:GetNeedBuildNum()
	return self.data.needBuildNum
end
EquipCrapManager = Class(DataManager)

local EquipCrapDataMgr = EquipCrapManager.New(EquipCrapData)
return EquipCrapDataMgr