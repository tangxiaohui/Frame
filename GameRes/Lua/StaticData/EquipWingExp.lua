require "StaticData.Manager"

EquipWingExpData = Class(LuaObject)

function EquipWingExpData:Ctor(id)
    local EquipWingExpMgr = Data.EquipWingExp.Manager.Instance()
    self.data = EquipWingExpMgr:GetObject(id)
    if self.data == nil then
        error(string.format("翅膀经验信息不存在，ID: %s 不存在", id))
        return
    end
end

function EquipWingExpData:GetId()
    return self.data.id
end

function EquipWingExpData:GetBlueProvideExp()
    return self.data.blueProvideExp
end

function EquipWingExpData:GetGreenProvideExp()
	return self.data.greenProvideExp
end

function EquipWingExpData:GetExpXishu()
	return self.data.expXishu
end

function EquipWingExpData:GetCoinXishu()
    return self.data.coinXishu
end

EquipWingExpManager = Class(DataManager)

local EquipWingExpDataMgr = EquipWingExpManager.New(EquipWingExpData)
return EquipWingExpDataMgr