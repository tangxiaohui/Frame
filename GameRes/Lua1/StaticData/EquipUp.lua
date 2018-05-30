require "StaticData.Manager"

EquipPetsUpData = Class(LuaObject)

function EquipPetsUpData:Ctor(id)
    local EquipPetsUpDataMgr = Data.EquipUp.Manager.Instance()
    self.data = EquipPetsUpDataMgr:GetObject(id)
    if self.data == nil then
        error(string.format("装备进阶，ID: %s 不存在", id))
        return
    end
end

function EquipPetsUpData:GetID()
    return self.data.id
end

function EquipPetsUpData:GetBaseType()
    return self.data.baseType
end

function EquipPetsUpData:GetColor()
    return self.data.color
end

function EquipPetsUpData:GetDisplayId()
    return self.data.displayId
end

function EquipPetsUpData:GetItemColor()
    return self.data.itemColor
end

function EquipPetsUpData:GetItemType()
    return self.data.itemType
end

function EquipPetsUpData:GetItemNum()
    return self.data.itemNum
end

function EquipPetsUpData:GetCost2()
    return self.data.needCoinNum
end

function EquipPetsUpData:GetCost1()
    return self.data.needDiamondNum
end

function EquipPetsUpData:GetOutputType()
    return self.data.outputType
end

function EquipPetsUpData:GetCost()
    local cost = {self.data.needCoinNum,self.data.needDiamondNum}
    return cost
end




EquipPetsUpInfoManager = Class(DataManager)

local EquipPetsUpInfoMgr = EquipPetsUpInfoManager.New(EquipPetsUpData)

function EquipPetsUpInfoMgr:GetKeys()
	return Data.EquipUp.Manager.Instance():GetKeys()
end

return EquipPetsUpInfoMgr



