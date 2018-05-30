require "StaticData.Manager"

EquipFashionData = Class(LuaObject)

function EquipFashionData:Ctor(id)
    local EquipFashionMgr = Data.EquipFashion.Manager.Instance()
    self.data = EquipFashionMgr:GetObject(id)
    if self.data == nil then
        error(string.format("时装信息不存在，ID: %s 不存在", id))
        return
    end
end

function EquipFashionData:GetId()
    return self.data.id
end

function EquipFashionData:GetMaxLv()
    return self.data.maxLv
end

function EquipFashionData:GetMaterial01()
	return self.data.material01
end

function EquipFashionData:GetExp01()
	return self.data.exp01
end

function EquipFashionData:GetMaterial02()
	return self.data.material02
end

function EquipFashionData:GetExp02()
    return self.data.exp02
end



EquipFashionManager = Class(DataManager)

local EquipFashionDataMgr = EquipFashionManager.New(EquipFashionData)
return EquipFashionDataMgr